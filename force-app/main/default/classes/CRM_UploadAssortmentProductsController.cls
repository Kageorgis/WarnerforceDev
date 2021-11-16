/**
   @Author Cognizant
   @name CRM_UploadAssortmentProductsController
   @CreateDate 10 Feb 2016
   @Description This class is used to upload (update/insert) the Assortment products.
   @Version <1.0>
   @reference Requirement no 83
*/
global with sharing class CRM_UploadAssortmentProductsController {
    
    public Id assortmentId;
    public Bundle__c assortment;
    public static Integer counter=0;
    public Integer maxCopyRowLimit{get; set;}
    public boolean shareFlag{get; set;}
    public boolean assortPriceFlag{get; set;}
    public static ApexPages.StandardController theController;
    public static Integer totalFailedRecords;
    public String handsontableversion{get; set;}
    /** 
     *  Method to fetch the custom setting record to set boolean flag which make grid Editable / Read only for logged in user
     *  @name getRCEditAccess US#897
     *  @param None
     *  @return boolean flag for Assortment edit access 
     *  @throws None
     */
    global Boolean getRCEditAccess() {
        return (Schema.sObjectType.Bundle__c.isCreateable() || Schema.sObjectType.Bundle__c.isUpdateable() || Schema.sObjectType.Bundle__c.isDeletable());
    }
    //public static boolean isDigitalDeal=false;
    //US:936: US Games
    public Boolean isUSACANMEXTerritory{get;set;}
    
    /**
    *  @Description - constructor
    *  @name  CRM_UploadAssortmentProductsController 
    */
    global CRM_UploadAssortmentProductsController(ApexPages.StandardController stdController) {
        assortmentId = stdController.getId();
        theController = stdController;
        //US:936:US Games
        isUSACANMEXTerritory = false;
        //Req #458: Share % should not be shown for Promotional Assortments
        shareFlag = true;
        assortPriceFlag= true;
        List<Bundle__c> assortmentList = [Select Id,RecordTypeId, Price_Book__r.Country__c, Price_Book__r.Product_Type__c From Bundle__c where Id =:assortmentId Limit 1];
        if(assortmentList.size() > 0 ){
            if(assortmentList.get(0).RecordTypeId == CRM_RecordTypeUtil.RT_Promotional_Assortment){
                shareFlag = false;
            }else if(assortmentList.get(0).RecordTypeId == CRM_RecordTypeUtil.RT_ASSORTMENT_SEASONAL ){
                assortPriceFlag = false; 
            }
            //US:936:US Games
            Bundle__c assortment = assortmentList.get(0);
            if(assortment.Price_Book__c != NULL && assortment.Price_Book__r.Product_Type__c == CRM_AppConstants.PRICEBOOK_PRODUCT_TYPE_PHYSICAL && 
               CRM_AppConstants.US_PRICEBOOK.contains(assortment.Price_Book__r.Country__c))
                isUSACANMEXTerritory = true;
        }
        maxCopyRowLimit = CRM_Max_Product_Limit__c.getInstance('Upload_Extract_Products') != null ? Integer.valueOf(CRM_Max_Product_Limit__c.getInstance('Upload_Extract_Products').Count__c) : 10000;
        handsontableversion = CRM_Default_Configuration__c.getOrgDefaults().Handsontable_Pro_Version__c;
    }
    
    /**
    *  @Description - wrapper class
    *  @name  AssortmentLineItemWrapper 
    */
    global class AssortmentLineItemWrapper implements Comparable{
        public Bundle_Product__c lineItemRecord;
        public String validation='';
        public Id existingId;
        public boolean isRowModified=false;
        public boolean isRowRemoved=false;
        public boolean previouslySelectedForRemoval=false;
        public DigitalDealWrapper digital=new DigitalDealWrapper();
        
        //US : 994 
        public string recrodStatus='';
        
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
            AssortmentLineItemWrapper compareToOl = (AssortmentLineItemWrapper)compareTo;
            if (existingId == compareToOl.existingId) return 0;
            if (existingId > compareToOl.existingId) return 1;
            return -1;        
        }
        // totalFailedRecords: Number of failed records during (insert/update/delete) operations to be displayed on VF page
        // totalFailedRecords will be taken from first wrapper record always by VF javascript 
        public Integer numFailedRecords;
    }
    /**
    *  @Description - inner wrapper class
    *  @name  DigitalDealWrapper 
    */
     global class DigitalDealWrapper{
        public String videoVersion;
        public String channel;
        public String format;
        public String language;
     }
     global boolean getDigitalDeal() {
        if (assortment == null) {
            assortment = [select id, Price_Book__c,Price_Book__r.Product_Type__c from Bundle__c where id=: assortmentId];
        }
        if(assortment!= null && assortment.Price_Book__c!=null && assortment.Price_Book__r.Product_Type__c == 'Digital') {
            //isDigitalDeal = true;
            return true;
        }
        return false;
    }
    /**
     * Method to get logged in uSer Locale
     */
    global String getUserLocale() {
        String currentUserLocale = UserInfo.getLocale();
        if (currentUserLocale.contains('_')) {
            currentUserLocale = currentUserLocale.replace( '_', '-');
        }

        /*if (currentUserLocale.contains('en-')) {
            currentUserLocale = currentUserLocale.substringBefore('-');
        }*/
        return currentUserLocale;
    }

    /**
     *  Method to fetch the Order Product from assortmentId  
     *  @name getAssortmentLineItems
     *  @param Id assortmentId
     *  @return CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper[]
     *  @throws None
     */
    @RemoteAction
    global static list<AssortmentLineItemWrapper> getAssortmentLineItems(Id assortmentId) {
        // Construct a list of Order Line Items
        List<AssortmentLineItemWrapper> returnWrapperList = new List<AssortmentLineItemWrapper>();
        // Find what products are in the Assortment
        try{
                String strQuery = 'SELECT Product__r.Universal_Picture_Code__c, Assortment_Price__c, Product__r.Street_Date__c,Product__r.Name,Product__r.External_Id__c,Product__r.RecordTypeId,'+
                                  'Bundle__r.Price_Book__c,Bundle__r.Assortment_Status__c, Bundle__r.CurrencyISOCode, Bundle__r.Name, Product__r.ProductCode,Bundle__r.Id, id,Automatically_Add_Product__c';
                if(Schema.SObjectType.Bundle_Product__c.fields.Share__c.isAccessible()){
                    strQuery += ',Share__c';
                }                    
                strQuery += ' FROM Bundle_Product__c'+
                            ' WHERE Bundle__c = \''+assortmentId+'\''+
                            ' ORDER BY Product__r.Name';
                List<Bundle_Product__c> assortmentProducts = database.query(strQuery);         
                for(Bundle_Product__c lineItem : assortmentProducts) {
                         
                            AssortmentLineItemWrapper lineItemWrapper = new AssortmentLineItemWrapper();
                            lineItemWrapper.existingId = lineItem.id;
                            lineItemWrapper.lineItemRecord = lineItem;
                            lineItemWrapper.validation = '';
                            lineItemWrapper.recrodStatus = ''; // US : 994
                            //returnWrapperList.add(lineItemWrapper);
                            
                            //Req : 808 - Begin
                            if(lineItem.Product__r.RecordTypeId!=null && lineItem.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL
                            && lineItem.Product__r.External_Id__c!=null && lineItem.Product__r.External_Id__c.contains('_')) {
                                    string[] split= lineItem.Product__r.External_Id__c.split('_');           
                                    lineItemWrapper.digital.language = split.size()>1?split[1]:'';
                                    lineItemWrapper.digital.videoVersion = split.size()>2?split[2]:'';
                                    lineItemWrapper.digital.channel = split.size()>3?split[3]:'';
                                    lineItemWrapper.digital.format = split.size()>4?split[4]:'';
                            }
                            returnWrapperList.add(lineItemWrapper);
                            //Req : 808 - End
                }
                returnWrapperList.sort();
        }
        catch(Exception e) {
                logException(assortmentId,e);
                throw e;
        }
        return returnWrapperList;
    }
    
    public static void logException(Id assortmentId,Exception e){
                    CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                    errorLog.recordId = assortmentId;
                    // Modules can be of type -> Deals / Targets / Demand / Orders / Co-Ops / Planning / General / Reporting / Non Functional
                    errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_DEALS;
                    errorLog.lineNumber = String.valueOf(e.getLineNumber());
                    errorLog.errorMessage = e.getMessage();
                    errorLog.stackTrace = e.getStackTraceString();
                    
                    // Call the logError method which will insert all errors into CRM_Error_Log__c object
                    CRM_ErrorLogger.logError(errorLog);
    }
    
    /**
     *  Method to fetch priceBookEntries for Physical/Digital deals corresponding to a combination  
     *  @name getPricebookEntriesPhysical
     *  @param Pricebook, currencyISOCode, combination list and type of Deal
     *  @return map<String,PricebookEntry>
     *  @throws None
     */
    global static map<String,PricebookEntry> getPricebookEntries(Id pbId,String currencyISOCode, Set<String> combination1Set,Set<String> combination2Set,Boolean isDealDigital) {
            map<String,PricebookEntry> pricebookEntryMap = new map<String,PricebookEntry>();
            String soqlString = 'Select id, UnitPrice,Product2.Id,PriceBook2.name,product2.Universal_Picture_Code__c,product2.Street_Date__c,Pricebook2Id,currencyISOCode,'+
                                ' product2.name,product2.External_Id__c,product2.productCode, IsActive, product2.IsActive, product2.RecordTypeId'+
                                ' From PricebookEntry'+
                                ' where Pricebook2Id =: pbId'+
                                ' AND currencyISOCode =:currencyISOCode'+
                                ' AND isActive = true';
            if ((combination1Set.size()>0 || combination2Set.size()>0)){
                if(isDealDigital) {
                    soqlString+=' AND (product2.External_Id__c IN: combination1Set)';
                }else {
                    soqlString+=' AND (product2.productCode IN: combination1Set OR product2.Universal_Picture_Code__c IN: combination2Set)';
                }
            }
            soqlString+=' limit 50000';

            list<PricebookEntry> pbEntries = database.query(soqlString);
            for(PricebookEntry pbEntry : pbEntries) {
                if(isDealDigital) {
                    if(pbEntry.product2.External_Id__c!=null)pricebookEntryMap.put(pbEntry.Pricebook2Id+'_'+pbEntry.product2.External_Id__c.toLowercase(),pbEntry);
                    //if(pbEntry.product2.Product_Format__c!=null)pricebookEntryMap.put(pbEntry.Pricebook2Id+'_'+pbEntry.product2.Product_Format__c.toLowercase(),pbEntry);
                    pricebookEntryMap.put(pbEntry.Pricebook2Id+'_'+string.valueOf(pbEntry.product2Id).toLowercase()+'_'+pbEntry.currencyISOCode,pbEntry);
                }else{
                    if(pbEntry.product2.productCode != null && pbEntry.product2.productCode != '') {
                        pricebookEntryMap.put(pbEntry.Pricebook2Id+'_'+pbEntry.currencyISOCode+'_'+pbEntry.product2.productCode.tolowercase()+'_',pbEntry);
                        pricebookEntryMap.put(pbEntry.Pricebook2Id+'_'+pbEntry.currencyISOCode+'_'+pbEntry.product2.productCode.tolowercase()+'_null',pbEntry);
                    }
                    if(pbEntry.product2.Universal_Picture_Code__c != null && pbEntry.product2.Universal_Picture_Code__c != '') {
                        pricebookEntryMap.put(pbEntry.Pricebook2Id+'_'+pbEntry.currencyISOCode+'__'+pbEntry.product2.Universal_Picture_Code__c.tolowercase(),pbEntry);
                        pricebookEntryMap.put(pbEntry.Pricebook2Id+'_'+pbEntry.currencyISOCode+'_null_'+pbEntry.product2.Universal_Picture_Code__c.tolowercase(),pbEntry);
                    }
                    if(pbEntry.product2.productCode != null && pbEntry.product2.productCode != '' && pbEntry.product2.Universal_Picture_Code__c!=null && pbEntry.product2.Universal_Picture_Code__c !='') {
                        pricebookEntryMap.put(pbEntry.Pricebook2Id+'_'+pbEntry.currencyISOCode+'_'+pbEntry.product2.productCode.tolowercase()+'_'+pbEntry.product2.Universal_Picture_Code__c.tolowercase(),pbEntry);
                    }
                }
            }
            return pricebookEntryMap;
    }
  
    /**
     *  Method to collect success/failure record after dml-insert/update  
     *  @name showResult
     *  @param results, actual list on which dml is performed and string
     *  @return CRM_UploadOrderProductsController.OrderLineItemWrapper[]
     *  @throws None
     */
     
    global static list<AssortmentLineItemWrapper> showResult(list<Database.SaveResult> results, list<Bundle_Product__c> dmlList,String successResultString) {
            List<AssortmentLineItemWrapper> returnWrapperList = new List<AssortmentLineItemWrapper>();
            set<Id> recordIdSet = new set<Id>();
            for(Integer i=0;i<results.size();i++){
                    AssortmentLineItemWrapper lineItemWrapper = new AssortmentLineItemWrapper();
                    lineItemWrapper.lineItemRecord = dmlList.get(i);
                    lineItemWrapper.isRowModified =false;       
                    
                    if (results.get(i).isSuccess()){
                        lineItemWrapper.existingId = results.get(i).getId();
                        recordIdSet.add(lineItemWrapper.existingId);
                        lineItemWrapper.validation = successResultString;
                        lineItemWrapper.recrodStatus = CRM_AppConstants.SUCCESS_MSG; //US : 994
                        lineItemWrapper.isRowModified = false;
                    }
                    else if (!results.get(i).isSuccess()){
                        // DML operation failed
                        Database.Error error = results.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();
                        dmlList.get(i);//failed record from the list
                        lineItemWrapper.lineItemRecord = dmlList.get(i);
                        lineItemWrapper.existingId = dmlList.get(i).Id;
                        
                        //Defect#4452 - commented code to persist values if error occured.
                        //if(lineItemWrapper.existingId!=null)recordIdSet.add(lineItemWrapper.existingId);
                        //else {
                        //    lineItemWrapper.lineItemRecord.Pricebookentry.Product2.Universal_Picture_Code__c = dmlList.get(i).Pricebookentry.Product2.Universal_Picture_Code__c;
                        //    lineItemWrapper.lineItemRecord.Pricebookentry.Product2.ProductCode = dmlList.get(i).Pricebookentry.Product2.ProductCode;
                        //}
                        lineItemWrapper.validation = failedDML;
                        lineItemWrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                        totalFailedRecords++;
                    }
                    returnWrapperList.add(lineItemWrapper);
            }
            // fetch all modified lineItems from database with populated formula fields
            String strQuery = 'SELECT Id, Assortment_Price__c, Product__r.Universal_Picture_Code__c, Product__r.Street_Date__c,Bundle__r.Price_Book__c,Product__r.RecordTypeId,'+
                              'Bundle__r.CurrencyISOCode, Bundle__r.Name, Product__r.ProductCode, Product__r.Name,Automatically_Add_Product__c,Product__r.External_Id__c';
            if(Schema.SObjectType.Bundle_Product__c.fields.Share__c.isAccessible()){
                strQuery += ',Share__c';
            }                    
            strQuery += ' FROM Bundle_Product__c'+
                        ' WHERE Id IN: recordIdSet'+
                        ' ORDER BY Product__r.Name';   
            system.debug('strQuery :::  274 :::::   '+strQuery);            
            List<Bundle_Product__c> assortmentProducts = Database.query(strQuery);
            Map<Id,Bundle_Product__c> lineItems = new Map<Id,Bundle_Product__c>(assortmentProducts);
            for(AssortmentLineItemWrapper wrapper:returnWrapperList) {
                if(lineItems.containsKey(wrapper.existingId)) {
                    wrapper.lineItemRecord = lineItems.get(wrapper.existingId);
                    if( wrapper.lineItemRecord.Product__r.RecordTypeId!=null &&  wrapper.lineItemRecord.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL
                      &&  wrapper.lineItemRecord.Product__r.External_Id__c!=null &&  wrapper.lineItemRecord.Product__r.External_Id__c.contains('_')) {
                         string[] split= wrapper.lineItemRecord.Product__r.External_Id__c.split('_');           
                         wrapper.digital.language = split.size()>1?split[1]:'';
                         wrapper.digital.videoVersion = split.size()>2?split[2]:'';
                         wrapper.digital.channel = split.size()>3?split[3]:'';
                         wrapper.digital.format = split.size()>4?split[4]:'';
                    }
                }else{
                    //Defect#4452 
                    if( wrapper.lineItemRecord.Product__r.RecordTypeId!=null &&  wrapper.lineItemRecord.Product__r.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL
                      &&  wrapper.lineItemRecord.Product__r.External_Id__c!=null &&  wrapper.lineItemRecord.Product__r.External_Id__c.contains('_')) {
                         string[] split= wrapper.lineItemRecord.Product__r.External_Id__c.split('_');           
                         wrapper.digital.language = split.size()>1?split[1]:'';
                         wrapper.digital.videoVersion = split.size()>2?split[2]:'';
                         wrapper.digital.channel = split.size()>3?split[3]:'';
                         wrapper.digital.format = split.size()>4?split[4]:'';
                    }
                }
            }
            return returnWrapperList;
    }

    
     /**
     *  Method to fetch user input and perform insert/update operation on modified records  
     *  @name setOrderLineItems
     *  @param CRM_UploadOrderProductsController.OrderLineItemWrapper[] and order Id
     *  @return sorted CRM_UploadOrderProductsController.OrderLineItemWrapper[]
     *  @throws None
     */
    @RemoteAction
    global static list<AssortmentLineItemWrapper> setAssortmentLineItems(List<AssortmentLineItemWrapper> lineItemWrapperList, Id assortmentId, boolean isDigitalDeal) {
        // Set Total Failed Records as 0
        totalFailedRecords = 0;
        // Commit the targets to Account_Product__c 
        List<Bundle_Product__c> updateList = new List<Bundle_Product__c>();
        List<Bundle_Product__c> insertList = new List<Bundle_Product__c>();
        List<AssortmentLineItemWrapper> deleteList = new List<AssortmentLineItemWrapper>();
        List<AssortmentLineItemWrapper> returnList = new List<AssortmentLineItemWrapper>();
         
        Set<String> productCodeSet = new Set<String>();
        Set<String> productUPCSet = new Set<String>();
        Set<String> digitalCombinationSet = new Set<String>();
        set<id> productIds = new set<id>();
        
        map<String,PricebookEntry> pricebookEntryMap = new map<String,PricebookEntry>();
        CRM_ProductPricingHandler pricingHandler;
        list<CRM_ProductPricingHandler.DealWrapper> pricingHandlerOrderWrpList = new list<CRM_ProductPricingHandler.DealWrapper>();
        
        try{
                Bundle__c bundleInstance = [select id,Price_Book__c,Price_Book__r.Country__c,Pricing_Account__c,Start_Date__c,End_Date__c,CurrencyISOCode,Automatically_Add_Products__c from Bundle__c where Id =: assortmentId];
                String strCountryCode = bundleInstance.Price_Book__r.Country__c;
                // Commit the targets to Account_Product__c
                Bundle_Product__c objLineItem = new Bundle_Product__c();
                 for (AssortmentLineItemWrapper wrapper : lineItemWrapperList) {
                        if(wrapper.isRowRemoved!=null && wrapper.isRowRemoved){
                                deleteList.add(wrapper);
                        }
                        else if(wrapper.isRowModified) {
                                if (wrapper.validation != null && wrapper.validation == System.Label.CRM_Upload_Message_Not_Valid_Automatic_Flag) { 
                                    totalFailedRecords++;
                                    wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                    returnList.add(wrapper);
                                    continue;
                                }
                                if (wrapper.lineItemRecord != null &&wrapper.lineItemRecord.Id != null ) { 
                                    updateList.add(wrapper.lineItemRecord);
                                }        
                                else { // new row
                                    if(isDigitalDeal){
                                        
                                        if((wrapper.digital.format == null || wrapper.digital.format == '') ||
                                           (wrapper.digital.channel == null || wrapper.digital.channel == '') || 
                                           (wrapper.digital.language == null || wrapper.digital.language == '') ||
                                           (wrapper.digital.videoVersion == null || wrapper.digital.videoVersion == '')
                                        ){
                                             wrapper.validation = Label.CRM_digital_product_error;
                                             wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                             totalFailedRecords++;
                                             returnList.add(wrapper);
                                             continue;
                                        }
                                        if(wrapper.digital.videoVersion != null && wrapper.digital.format != null 
                                        && wrapper.digital.channel !=null && wrapper.digital.language != null) {
                                            digitalCombinationSet.add(strCountryCode+'_'+wrapper.digital.language+'_'+wrapper.digital.videoVersion+'_'+wrapper.digital.channel+'_'+wrapper.digital.format);
                                        }
                                    }
                                    else if(wrapper.lineItemRecord != null){
                                        if(wrapper.lineItemRecord.Product__r.ProductCode!=null)productCodeSet.add(wrapper.lineItemRecord.Product__r.ProductCode);
                                        if(wrapper.lineItemRecord.Product__r.Universal_Picture_Code__c!=null)productUPCSet.add(wrapper.lineItemRecord.Product__r.Universal_Picture_Code__c);
                                    }
                                    insertList.add(wrapper.lineItemRecord);
                                }
                        }
                        else { // no modification done to existing rows
                            wrapper.validation = '';
                            wrapper.recrodStatus = ''; //US : 994
                            returnList.add(wrapper);
                        }
                }
              
                list<Database.SaveResult> updateResults = Database.update(updateList,false);
                
                returnList.addAll(showResult(updateResults,updateList,Label.CRM_Upload_Message_Updated));
                if(insertList.size()>0) {
                        String combination;
                        //Req :808 - Begin
                        if(isDigitalDeal) {
                            pricebookEntryMap = getPricebookEntries(bundleInstance.Price_Book__c,bundleInstance.CurrencyISOCode,digitalCombinationSet,null,true);
                        }else{
                            pricebookEntryMap = getPricebookEntries(bundleInstance.Price_Book__c,bundleInstance.CurrencyISOCode,productCodeSet,productUPCSet,false);
                        }
                        //Req :808 - End                       
                        // prepare list of DealWrappers to get the pricebook entry period details
                        for(PricebookEntry pbEntry:pricebookEntryMap.values()) {
                                     CRM_ProductPricingHandler.DealWrapper pricingHandlerOrderWrp = new CRM_ProductPricingHandler.DealWrapper();
                                     pricingHandlerOrderWrp.dealId = assortmentId;
                                     pricingHandlerOrderWrp.accountId = bundleInstance.Pricing_Account__c;
                                     pricingHandlerOrderWrp.dealCurrency = bundleInstance.currencyISOCode;
                                     pricingHandlerOrderWrp.productId = pbEntry.product2Id;
                                     pricingHandlerOrderWrp.pricebookId = bundleInstance.Price_Book__c;
                                     pricingHandlerOrderWrp.dealStartDate = bundleInstance.Start_Date__c;
                                     pricingHandlerOrderWrp.dealEndDate  = bundleInstance.End_Date__c;
                                     pricingHandlerOrderWrpList.add(pricingHandlerOrderWrp);
                                     productIds.add(pbEntry.product2Id);
                        }
                        if(pricingHandlerOrderWrpList.size()>0) {
                            pricingHandler = new CRM_ProductPricingHandler(pricingHandlerOrderWrpList);
                        }
                        
                        insertList.clear();
                        for (AssortmentLineItemWrapper wrapper : lineItemWrapperList) {
                                if(isDigitalDeal) {
                                    if(wrapper.digital.videoVersion!=null && wrapper.digital.videoVersion!='') {
                                        combination = strCountryCode+'_'+wrapper.digital.language+'_'+wrapper.digital.videoVersion+'_'+wrapper.digital.channel+'_'+wrapper.digital.format;
                                        combination = bundleInstance.Price_Book__c+'_'+combination.tolowercase();
                                    }
                                }
                                else {
                                    combination = wrapper.lineItemRecord.Product__r.productCode+'_'+wrapper.lineItemRecord.Product__r.Universal_Picture_Code__c;
                                    combination = bundleInstance.Price_Book__c+'_'+bundleInstance.currencyISOCode+'_'+combination.tolowercase();
                                }
                                if(wrapper.lineItemRecord == null){
                                    Product2 prod = new Product2();
                                    Bundle_Product__c bp = new Bundle_Product__c(Product__r = prod);
                                    wrapper.lineItemRecord = bp;
                                }
                                system.debug('wrapper : '+wrapper.lineItemRecord);
                                if(wrapper.isRowModified && wrapper.lineItemRecord.Id == null) {
                                            wrapper.lineItemRecord.Bundle__c = null;
                                            wrapper.validation = '';        
                                            wrapper.recrodStatus = ''; //US : 994
                                            if(pricebookEntryMap!=null && pricebookEntryMap.containsKey(combination)) {
                                                wrapper.lineItemRecord.Product__r = pricebookEntryMap.get(combination).Product2;
                                                wrapper.lineItemRecord.Product__r.ProductCode = pricebookEntryMap.get(combination).Product2.ProductCode;
                                                wrapper.lineItemRecord.Product__r.Universal_Picture_Code__c = pricebookEntryMap.get(combination).Product2.Universal_Picture_Code__c;
                                                wrapper.lineItemRecord.Product__c = pricebookEntryMap.get(combination).Product2Id;
                                                CRM_ProductPricingHandler.DealWrapper pricingHandlerDealWrp = new CRM_ProductPricingHandler.DealWrapper();
                                                pricingHandlerDealWrp.dealId = assortmentId;
                                                pricingHandlerDealWrp.accountId = bundleInstance.Pricing_Account__c;
                                                pricingHandlerDealWrp.dealCurrency = bundleInstance.currencyISOCode;
                                                pricingHandlerDealWrp.productId = pricebookEntryMap.get(combination).Product2Id;
                                                pricingHandlerDealWrp.pricebookId = bundleInstance.Price_Book__c;
                                                pricingHandlerDealWrp.dealStartDate = bundleInstance.Start_Date__c;
                                                pricingHandlerDealWrp.dealEndDate  = bundleInstance.End_Date__c;
                                                //pricingHandlerDealWrp.channel = wrapper.digital.channel;
                                                //pricingHandlerDealWrp.language = wrapper.digital.language;
                                                //pricingHandlerDealWrp.productFormat  = wrapper.digital.format;
                                                // Requirement: #3239
                                                if (pricebookEntryMap != null && pricebookEntryMap.containsKey(combination) && pricebookEntryMap.get(combination) != null && pricebookEntryMap.get(combination).product2 != null && pricebookEntryMap.get(combination).product2.IsActive == false){
                                                    wrapper.validation = Label.CRM_Upload_Message_Product_Not_Active;
                                                    wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; // US : 994
                                                    totalFailedRecords++;
                                                    returnList.add(wrapper);
                                                    continue;
                                                }
                                                //if product is not of same type as of deal then throw error 
                                                String recTypeId = pricebookEntryMap.get(combination).product2.recordtypeId;
                                                
                                                if(!((isDigitalDeal && recTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL)||(!isDigitalDeal && recTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL))){
                                                    wrapper.validation = Label.CRM_Upload_Message_Type_Mismatch;
                                                    wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; // US : 994
                                                    totalFailedRecords++;
                                                    returnList.add(wrapper);
                                                    continue;
                                                }
                                                if(pricingHandler == null) {
                                                        wrapper.validation = Label.CRM_Upload_Message_NotFound;
                                                        wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; // US : 994
                                                        totalFailedRecords++;
                                                        returnList.add(wrapper);
                                                        continue;
                                                }
                                                Pricebook_Entry_Period__c pbep = pricingHandler.getProductDatedPricebookEntryPeriod(pricingHandlerDealWrp);
                                                //if no pbep exists then throw error
                                                //if product PBEP Start Date does not lie in deal dates, then throw error
                                                if(pbep == null) {
                                                        wrapper.validation = Label.CRM_Upload_Message_PBEP;
                                                        wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; // US : 994
                                                        totalFailedRecords++;
                                                        returnList.add(wrapper);
                                                        continue;
                                                }
                                                //wrapper.lineItemRecord.PriceBookEntry = null;
                                                wrapper.lineItemRecord.Bundle__c = assortmentId;
                                                if(wrapper.lineItemRecord.Automatically_Add_Product__c == null){
                                                    wrapper.lineItemRecord.Automatically_Add_Product__c = false;
                                                }
                                                //wrapper.lineItemRecord.List_Price__c = pricingHandler.getProductDatedListPrice(pricingHandlerDealWrp);
                                                Decimal lstPrice = pbep.Account_Price__c != null ? pbep.Account_Price__c : pbep.List_Price__c;
                                                wrapper.lineItemRecord.List_Price__c = lstPrice;
                                                if(wrapper.lineItemRecord.Assortment_Price__c==null) { // if user has not provided unit price then get it from pricebook entry period
                                                       //wrapper.lineItemRecord.Assortment_Price__c = pricingHandler.getProductDatedListPrice(pricingHandlerDealWrp);
                                                       wrapper.lineItemRecord.Assortment_Price__c = lstPrice;
                                                       insertList.add(wrapper.lineItemRecord);
                                                }
                                                else 
                                                    insertList.add(wrapper.lineItemRecord);
                                            }
                                            else {
                                                wrapper.validation = Label.CRM_Upload_Message_NotFound;
                                                wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; // US : 994
                                                totalFailedRecords++;
                                                returnList.add(wrapper);
                                            }
                                            
                                }
                        }
                        
                        list<Database.SaveResult> insertResults = Database.insert(insertList,false);
                        returnList.addAll(showResult(insertResults,insertList,Label.CRM_Upload_Message_Created));
                }
                if(deleteList.size()>0) {
                   List<AssortmentLineItemWrapper> listDeleted=deleteAssortmentLineItems(deleteList); 
                  
                   if(listDeleted.size()>0) {
                        returnList.addAll(listDeleted);
                   }
                }
      
                returnList.sort();
        }
        catch(Exception e) {
                logException(assortmentId,e);
                throw e;
        }
        if(!returnList.isEmpty()) {
            returnList[0].numFailedRecords = totalFailedRecords;
        }

        return returnList;
    }
    
    /**
     *  Method to fetch user input and perform delete operation on existing records  
     *  @name deleteAssortmentLineItems
     *  @param CRM_UploadOrderProductsController.OrderLineItemWrapper[] and order Id
     *  @return sorted CRM_UploadOrderProductsController.OrderLineItemWrapper[]
     *  @throws None
     */
     
    //@RemoteAction
    global static list<AssortmentLineItemWrapper> deleteAssortmentLineItems(List<AssortmentLineItemWrapper> toDeletelineItemWrapperList) {
        // Commit the targets to Account_Product__c 
        List<Bundle_Product__c> removeList = new List<Bundle_Product__c>();
        List<AssortmentLineItemWrapper> returnList = new List<AssortmentLineItemWrapper>();
        
        Id assortmentId;
        String assortmentStatus;
        if(toDeletelineItemWrapperList!=null)
        for (AssortmentLineItemWrapper wrapper : toDeletelineItemWrapperList) {
                if (wrapper.existingId != null ) { // row is updated
                    assortmentId = wrapper.lineItemRecord.Bundle__c;
                    assortmentStatus = wrapper.lineItemRecord.Bundle__r.Assortment_Status__c;
                    wrapper.isRowRemoved =false;
                    wrapper.isRowModified =false;
                    removeList.add(wrapper.lineItemRecord);
                }        
        }
          try {
                    list<Database.DeleteResult> removeListResults = Database.delete(removeList,false);
                    for(Integer i=0;i<removeListResults.size();i++){
                                AssortmentLineItemWrapper lineItemWrapper = new AssortmentLineItemWrapper();
                                lineItemWrapper.lineItemRecord = removeList.get(i);
                                lineItemWrapper.isRowModified =false;
                                lineItemWrapper.isRowRemoved =false;
                                
                                if (!removeListResults.get(i).isSuccess()){
                                    // DML operation failed
                                    Database.Error error = removeListResults.get(i).getErrors().get(0);
                                    String failedDML = error.getMessage();
                                    lineItemWrapper.existingId = removeList.get(i).Id;
                                    lineItemWrapper.validation = failedDML;
                                    lineItemWrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; // US : 994
                                    totalFailedRecords++;
                                    returnList.add(lineItemWrapper);
                                }
                }
                returnList.sort();
        }
        catch(Exception e) {
                logException(assortmentId,e);
                for(Integer i=0;i<returnList.size();i++){
                        returnList[i].validation = e.getMessage();
                        returnList[i].recrodStatus = CRM_AppConstants.ERROR_MSG; // US : 994
                        totalFailedRecords++;
                }
                returnList.sort();
                //throw e;
        }
        return returnList;
    }
    
    //US : 989
    public string getHandsonTable_Pro_Licencekey (){
        return CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c != null ? CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c : '';
    }
    
    /**
     *  Method to export CSV file
     *  @name exportCSVFile
     *  @param List<String> excelHeaderNames
     *  @return PageReference - Redirect URL
     *  @throws None
     */
     
    @RemoteAction
    global static PageReference exportCSVFile(List<String> excelHeaderNames) {
        String urlLocatorPage = '/apex/CRM_ExportCSVFileFromUploadExtract';
        PageReference pageref = new PageReference(urlLocatorPage);
        pageref.getParameters().put('excelHeaderNames',String.join(excelHeaderNames,','));
        system.debug('excelHeaderNames : '+excelHeaderNames);
        return pageref;
    }
    
    public class MyCustomException extends Exception{}
}