/**
   @Author Cognizant
   @name CRM_ProductBibleController
   @CreateDate 12 Oct 2016
   @Description This class is used to upload (insert/delete) the deal products.
   @Version <1.0>
   @reference Requirement no ER-3312
*/
global with sharing class CRM_ProductBibleController{
     
    public Id dealId{get; set;}
    public Opportunity deal; 
    public String handsontableversion{get; set;}
    public static Set<String> setMpmNumbers;
    public static Set<Id> setProdIds;
    public static Integer totalFailedRecords;
    public static Map<String,String> mapColToWrapperLabels{get; set;}
    public static Set<String> setProductColumnLabels{get; set;} 
    public static List<CRM_DataObjects.PicklistOption> picklistTalentRole{get; set;} 
    public String pickWrapJSONString{get; set;}
    public String pickWrapJSONStringFilter{get; set;}
    public static Set<String> lstMpmNumbers;
    public static List<OpportunityWrapper> finalWrapperList = new List<OpportunityWrapper>();
     
    /**
    *  @Description - constructor
    *  @name  CRM_ProductBibleController 
    */
    global CRM_ProductBibleController(ApexPages.StandardController stdController) {
        dealId =  stdController.getId(); 
        deal = [select id, NR_Deal_Unique_Key__c, Pricebook2Id, Sales_Organisation__c,Market_Type__c, RecordTypeId,RecordType.Name,RecordType.DeveloperName,Product_Type__c, CurrencyISOCode, AccountId,Account.Digital_Country_Code__c, Account.Consignment_Customer__c from Opportunity where id=: dealId];
        Boolean isDigi=false;
        if(deal.RecordTypeId!=null && deal.RecordType.Name!= null && deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
            isDigi= true;
        }
        handsontableversion = CRM_Default_Configuration__c.getOrgDefaults().Handsontable_Pro_Version__c; 
        mapColToWrapperLabels = getColumnNames(isDigi); 
        List<string> lstTalentRole =Label.CRM_Roles.split(','); 
        
        PicklistWrapper picklistWrap = new PicklistWrapper(
                                                getFilterPicklistValues(lstTalentRole),
                                                getPicklistValuesForFilter('Title__c', 'Content_Type__c'),
                                                getPicklistValuesForFilter('Product2', 'Product_Market__c'));
        pickWrapJSONStringFilter = JSON.serialize(picklistWrap);
    }
    
     /**
    * Method to specify if the deal is Physical /Digital
    * @param none
    * @return True if the deal is Digital or false if deal is physical
    */
    global boolean getDigitalDeal() {
        if (deal == null) {
            deal = [select id, NR_Deal_Unique_Key__c, Pricebook2Id, Sales_Organisation__c,Market_Type__c, RecordTypeId,RecordType.Name,RecordType.DeveloperName,Product_Type__c, CurrencyISOCode, AccountId,Account.Digital_Country_Code__c, Account.Consignment_Customer__c from Opportunity where id=: dealId];
        }
        if(deal.RecordTypeId!=null && deal.RecordType.Name!= null && deal.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL) {
             return true;
        }
        return false;
    }
    
    /**
    * Method to get the licence key of handsontable from custom setting
    * @param none
    * @return string with licence key
    */
    public string getHandsonTable_Pro_Licencekey (){
        return CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c != null ? CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c : '';
    }
      
    /**
     * Method to fetch picklist values for specified object and field
     * @param object_name Object name for whose field we need the picklist values
     * @param field_name Field name for which picklist fields need to be fetched
     */
    global static PicklistVal getFilterPicklistValues(List<string> lstTalentRole) {
        
        List<CRM_DataObjects.PicklistOption> options = new List<CRM_DataObjects.PicklistOption>();
        List<String> piclistVales = new List<String>(); 
        for(String field_name:lstTalentRole ) {
            CRM_DataObjects.PicklistOption selOption = new CRM_DataObjects.PicklistOption(field_name, field_name);
            if(field_name ==lstTalentRole[0]){
                selOption.selected = true;
            }
            options.add(selOption); 
            piclistVales.add(field_name);
        }
        PicklistVal pickWrap = new PicklistVal(piclistVales,options);
        return pickWrap; //return the List
    }
    
    /**
     * Method to fetch picklist values for specified object and field
     * @param object_name Object name for whose field we need the picklist values
     * @param field_name Field name for which picklist fields need to be fetched
     */
    global static PicklistVal getPicklistValuesForFilter(String object_name, String field_name) {
      
      List<CRM_DataObjects.PicklistOption> options = new List<CRM_DataObjects.PicklistOption>();
      List<String> piclistVales = new List<String>();  
      Schema.DescribeSObjectResult sobject_describe = Schema.getGlobalDescribe().get(object_name).getDescribe(); //describe the sobject
      Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
      List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
      CRM_DataObjects.PicklistOption selOption1 = new CRM_DataObjects.PicklistOption(Label.CRM_All_Value_For_Content_Type, Label.CRM_All_Value_For_Content_Type);  
      piclistVales.add(Label.CRM_All_Value_For_Content_Type);
      options.add(selOption1);
     
      for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            CRM_DataObjects.PicklistOption selOption = new CRM_DataObjects.PicklistOption(a.getValue(), a.getLabel());
            if(a.getValue()=='EST'){
               selOption.selected = true;
            }else if(a.getValue()=='Feature'){
               selOption.selected = true;
            }
            piclistVales.add(a.getLabel()); //add the value and label to our final list
            options.add(selOption);
      } 
      PicklistVal pickWrap = new PicklistVal(piclistVales,options);
      return pickWrap; //return the List
    }
    
    
     /**
    *  @name getPicklistValueSet
    *  @param CRM_DataObjects.PicklistOption[] picklistOptions
    *  @return List of String containing picklist values.
    *  @throws None
    */
    public static List<String> getPicklistValueSet(CRM_DataObjects.PicklistOption[] picklistOptions){
        List<String> picklistValSet = new List<String>();
        if(picklistOptions != null){
            for(CRM_DataObjects.PicklistOption po : picklistOptions){
                picklistValSet.add(po.value);
            }
        }
        return picklistValSet;
    }
    
    /**
    *  @name getSObjectFields
    *  @param String objectName,String columnName
    *  @return  String - label of the field
    *  @throws None
    */
    private static String getSObjectFields(String objectName,String columnName){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objectName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        return fieldMap.get(columnName).getDescribe().getLabel();
    }
    
    /**
    *  @name getColumnNames
    *  @param isDigitalDeal to fetch digital or physical columns names to be displayed
    *  @return  Map<String,String> which is column label and 
    *  @throws None
    */
    private static Map<String,String> getColumnNames( Boolean isDigitalDeal ){
        //Get the Columns to be displayed from custom setting CRM_Field_Bible__c  start 
        List<CRM_Field_Bible__c> csAllValues = CRM_Field_Bible__c.getAll().values();
        ProductSequenceRule[] productAssignmentRules = new ProductSequenceRule[]{}; //get the custom setting
        Map<String,String> mapColToWrapperLabelLocal =new Map<String,String>(); 
        setProductColumnLabels =new Set<String>();
        String dealRecordType = isDigitalDeal ? CRM_AppConstants.DIGITAL_INITIALS : CRM_AppConstants.PHYSICAL_INITIALS;
        Set<String> setObjectName =new Set<String>();
        
        //Get the custom setting         
        for(CRM_Field_Bible__c csValues : csAllValues){
            String customSettingKey = '^';
            customSettingKey +=  (csValues.Column_Label__c != null ? csValues.Column_Label__c : '(.*)');
            customSettingKey += '-'+ (csValues.Wrapper_Label__c != null ? csValues.Wrapper_Label__c : '(.*)');
            customSettingKey += '$';
            productAssignmentRules.add(new ProductSequenceRule(customSettingKey,csValues));
        }
        
        //Sort the custom setting records as per the column numbering
        if(!productAssignmentRules.isEmpty())
            productAssignmentRules.sort();
        
        //Form the column header labels
        for(ProductSequenceRule pgAssignmentRule : productAssignmentRules){
            CRM_Field_Bible__c rule = pgAssignmentRule.rule; 
            if( dealRecordType == rule.Record_Type__c){
                if(rule.Column_Label__c!='isDealProduct'  && rule.Column_Label__c!= 'Age'  && rule.Column_Label__c!= 'Current RP' && rule.Column_Label__c!= 'WSP' && rule.Column_Label__c != 'localTitleName' && rule.Column_Label__c!= 'Validation'){
                    String colName =getSObjectFields(rule.Object__c,rule.Column_Label__c);
                    setProductColumnLabels.add(colName);
                    mapColToWrapperLabelLocal.put(colName,rule.Wrapper_Label__c);
                }else{
                    if( rule.Column_Label__c == 'Age'){
                        setProductColumnLabels.add(Label.CRM_Bible_Age);
                        mapColToWrapperLabelLocal.put(Label.CRM_Bible_Age,rule.Wrapper_Label__c);
                    }else if( rule.Column_Label__c == 'Current RP'){
                        setProductColumnLabels.add(Label.CRM_Current_RP_Bible);
                        mapColToWrapperLabelLocal.put(Label.CRM_Current_RP_Bible,rule.Wrapper_Label__c);
                    }else if( rule.Column_Label__c == 'Validation'){
                        setProductColumnLabels.add(Label.CRM_Upload_Field_Validation);
                        mapColToWrapperLabelLocal.put(Label.CRM_Upload_Field_Validation,rule.Wrapper_Label__c);
                    }else if( rule.Column_Label__c == 'localTitleName' ){
                        String colName =getSObjectFields(rule.Object__c,'Name');
                        setProductColumnLabels.add(colName);
                        mapColToWrapperLabelLocal.put(colName,rule.Wrapper_Label__c);
                    }else{
                        setProductColumnLabels.add(rule.Column_Label__c);
                        mapColToWrapperLabelLocal.put(rule.Column_Label__c,rule.Wrapper_Label__c);
                    }
                }
            }
        } 
        return mapColToWrapperLabelLocal;
    } 
   
    /**
    * Method to get the Products on load of the page
    * @param OpportunityId , isDigitalDeal return true if deal is digital else false
    * @return List<OpportunityWrapper>
    */   
    @RemoteAction
    public static List<OpportunityWrapper> getProducts(Boolean onloadFlag,Id opportunityId, Boolean isDigitalDeal,FilterWrapper filterWrap){
        //Prepare picklist filter values set from Picklist Option 
        List<String> setSearchRoles = new List<String>();
        setSearchRoles = getPicklistValueSet(filterWrap.roleFilter);// get the roles selected 
        if(setSearchRoles.isEmpty()){
            setSearchRoles.add(Label.CRM_AllRoles);
        }
        lstMpmNumbers = new Set<String>();
        
        //Get the Deal details with existing Deal Products
        List<Opportunity> deals = [SELECT id, Start_Date__c, AccountId,Account.Digital_Country_Code__c, Market_Type__c,RecordTypeId,
                                        CurrencyIsoCode, StageName, Account.Sales_Organization__c, Bundle__c, CloseDate,
                                        Sales_Organisation__c,Bundle__r.RecordTypeId,Pricebook2Id,Account.Price_Book__r.Country__c,
                                       Account.Storefront__c,
                                        (SELECT PricebookEntryId, Quantity FROM OpportunityLineItems) 
                                        FROM Opportunity 
                                        WHERE Id =:opportunityId limit 1]; 
        
        //Show error if deal cannot add/delete the deal products start
        if(CRM_AddProductsHelper.getPreventAddProductsFlag()) {
            throw new CRM_DigitalBibleException(Label.CRM_Deal_Entry_NoAccessError);
        }
        else if(!deals.isEmpty() && (deals[0].StageName == CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED || deals[0].StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED)){
            throw new CRM_DigitalBibleException(Label.CRM_RefreshProductPrice_DealStageError);
        }else if(!deals.isEmpty() && deals[0].Pricebook2Id == null){ //added for no price book on deal error
            throw new CRM_DigitalBibleException(Label.CRM_Deal_with_NoPriceBookError);
        }
        // Show error if deal cannot add/delete the deal products end
        
        // First fetch a list of current items and quantities
        Map<Id, OpportunityLineItem> currentItems = new Map<Id, OpportunityLineItem>();
        for (OpportunityLineItem dealWrapper : deals[0].OpportunityLineItems) {
                currentItems.put(dealWrapper.PricebookEntryId, dealWrapper);
        }
       //Create the wrapper with required details
        List<OpportunityWrapper> items = new List<OpportunityWrapper>();
        CRM_DataObjects.ParentRecord dealOrOrder = new CRM_DataObjects.ParentRecord();
        dealOrOrder.salesOrg = deals[0].Account.Sales_Organization__c;
        dealOrOrder.currencyCode = deals[0].CurrencyIsoCode;
        dealOrOrder.startDate = deals[0].Start_Date__c;
        dealOrOrder.bundleId = deals[0].Bundle__c;
        dealOrOrder.accountId = deals[0].AccountId;
        dealOrOrder.endDate = deals[0].CloseDate; 
        dealOrOrder.recordType = CRM_AppConstants.OPPORTUNITY_OBJECT;
        dealOrOrder.dealRecord = deals[0]; 
        Date startDate = deals[0].Start_Date__c; 
        
        //Call the method searchProducts to fill the wrapper with column values
        items = searchProducts(currentItems,onloadFlag,dealOrOrder, deals[0].Pricebook2Id,filterWrap); 
        //Set wrapper fields such as isDealProduct,existingId,quantity if the Product is an existing Deal product in the deal
        
        //If no role/character search present then just assign the existing list
        
        if(lstMpmNumbers.isEmpty() && !setSearchRoles.isEmpty() && setSearchRoles[0]==Label.CRM_AllRoles){
            finalWrapperList =items;
        }
        if(!finalWrapperList.isEmpty()){
            // Set the index for each line item for updating the rows when the record row is inserted/Deleted
            for(Integer i=0; i< finalWrapperList.size(); i++) {
                finalWrapperList[i].rowIndex = i;
            } 
            
            //Fetch all MPMNumbers for Talent Role and Talent Name sort on page
            if(!finalWrapperList.isEmpty()) {
                finalWrapperList[0].setMpmNumber =new List<String>();
                finalWrapperList[0].setMpmNumber.addall(setMpmNumbers);
                finalWrapperList[0].setProductIds =new List<Id>();
                finalWrapperList[0].setProductIds.addAll(setProdIds);
            }  
        }
        return finalWrapperList;  
    }
    
    /**
    *  @Description - method to search the salesforce products from a pricebook based on the applied filters
    *  @name  searchProducts 
    *  @param  dealOrOrder - dealOrOrder details for which product will be searched based on the start date
    *  @param  pricebookId - Id of the pricebook where products to be searched
    *  @return OpportunityWrapper[] - list of ProductItems which macthed the applied filters
    */
    public static OpportunityWrapper[] searchProducts( Map<Id, OpportunityLineItem> currentItems ,Boolean onloadFlag,CRM_DataObjects.ParentRecord dealOrOrder, Id pricebookId,FilterWrapper filterWrap) {
        
        List<String> contentTypeSet = getPicklistValueSet(filterWrap.contentType);
        List<String> channelSet = getPicklistValueSet(filterWrap.channel);
        List<String> setSearchRoles = getPicklistValueSet(filterWrap.roleFilter);// get the roles selected 
        String mpmSearchCharacter='';
        mpmSearchCharacter = filterWrap.searchText; 
        if(onloadFlag ){//&& contentTypeSet.isEmpty() && channelSet.isEmpty()){
            contentTypeSet.add('Feature');
            channelSet.add('EST'); 
        } 
        
        Date startDate = dealOrOrder.startDate;
        Date endDate = dealOrOrder.endDate;
        Map<String,Pricebook_Entry_Period__c> mapPriceBookEntryPeriod = new Map<String,Pricebook_Entry_Period__c>();
        List<Pricebook_Entry_Period__c> fetchedPBEPList = new List<Pricebook_Entry_Period__c>();
        Set<Id> setProductIds = new Set<Id>();
        Map<String, PricebookEntry> mapUniqueKeyToPricebookInstance = new Map<String, PricebookEntry>();
        Map <String, OpportunityWrapper> finalFilteredProductsMap = new Map<String, OpportunityWrapper>{};
        Integer filterCount = 0;
        setMpmNumbers = new Set<String>();
        setProdIds =new Set<Id>();
        
        if (startDate != null && endDate != null) {
            String startDateStr = DateTime.newInstance(startDate.year(),startDate.month(),startDate.day()).format('yyyy-MM-dd');
            String endDateStr = DateTime.newInstance(endDate.year(),endDate.month(),endDate.day()).format('yyyy-MM-dd');
            String queryStr =   'SELECT Id, Product__c, List_Price__c, Product__r.Name, Price_Book__c,'+
                                    'CurrencyISOCode, Start_Date__c, End_Date__c, Account_Price__c,Product__r.Product_Genre__c,' +
                                    'Client_Avail__r.Start_Date__c,Client_Avail__r.End_Date__c,Product__r.MPM__c,Retailer_Product_ID__c,'+
                                    'Product__r.ProductCode,Product__r.Tittle_Content_Type__c,Product__r.Local_Title__r.Title__r.Digital_UPC__c,Client_Avail_Price__r.SRP__c,'+
                                    'Product__r.Title_Country__c,Product__r.Product_Market__c,Product__r.Product_Format__c,'+
                                    'Product__r.Local_Title__r.Title__r.US_Theatrical_Release_Date_New__c,'+
                                    'Client_Avail__r.Status__c,Price_Tier__c,Product__r.Local_Title__r.Local_Rating__c,Product__r.Local_Title__r.name,'+
                                    'Product__r.Local_Title__r.Category__c,Product__r.Local_Title__r.Title__r.Title_Tag__c, Product__r.Topics__c,Product__r.Local_Title__r.Talent__c '+
                                    'FROM Pricebook_Entry_Period__c ' +
                                    'WHERE Price_Book__c =: pricebookId'+
                                    ' AND Start_Date__c <=:endDate' + 
                                    ' AND End_Date__c >=: startDate'+  
                          ' AND CurrencyIsoCode = \''+dealOrOrder.CurrencyCode +'\'' +
                          ' AND ( Product__r.Type__c IN (\'' +CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE +'\', \'' +CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE +'\'))'+ 
                                    ' AND (Client_Avail__r.Status__c IN (\''+CRM_AppConstants.STATUS_TENTATIVE +'\', \''+ CRM_AppConstants.CRM_Client_Avail_Status_Confirmed +'\'))';
                            
            if(!contentTypeSet.isEmpty() && !contentTypeSet.contains(Label.CRM_All_Value_For_Content_Type) ){
                queryStr +=  ' AND (Product__r.Tittle_Content_Type__c IN :contentTypeSet)';
            }
            if(!channelSet.isEmpty() && !channelSet.contains(Label.CRM_All_Value_For_Content_Type)){
                queryStr +=  ' AND (Product__r.Product_Market__c IN :channelSet)'; 
            }
            
            queryStr +=' Order By CreatedDate DESC';
            for(Pricebook_Entry_Period__c pbep : Database.query(queryStr)) {
                fetchedPBEPList.add(pbep);
                setProductIds.add(pbep.Product__c); 
            }
        } 
        
        //Fetch the valid PBE record for the products that are having the pbeps
        PricebookEntry[] priceBookEntries = queryPricebookentries(dealOrOrder, pricebookId,setProductIds);
        //generate the unique key to identigy the products
        for(PricebookEntry pbe : priceBookEntries) {
              String key = (pbe.Product2Id + '-' + pricebookId +'-'+ pbe.CurrencyIsoCode).toLowercase();
               if (!mapUniqueKeyToPricebookInstance.containsKey(key)) {
                mapUniqueKeyToPricebookInstance.put(key, pbe);
                setMpmNumbers.add(pbe.Product2.MPM__c); 
            }
        }
        //query MPM talent if there is character search or a role search
        system.debug('');
        if((!setSearchRoles.isEmpty() &&  setSearchRoles[0]!=Label.CRM_AllRoles)|| mpmSearchCharacter!=''){  
            lstMpmNumbers = CRM_ProductBibleController.getProductsWithMPMFilter(setMpmNumbers,filterWrap);
        }
        String dateFmt2 =getUserDateFormat();
        dateFmt2 =dateFmt2.toUpperCase();
        String dateFmt = dateFmt2.replace('D','d');
        //Find the correct products with valid PBEP and PBE records and form the wrapper
        for(Pricebook_Entry_Period__c pbePeriod : fetchedPBEPList){
            String key = (pbePeriod.Product__c + '-'+ pricebookId + '-'+ pbePeriod.CurrencyISOCode).toLowercase();
            
            if (mapUniqueKeyToPricebookInstance.containskey(key)) {
                PricebookEntry pe = mapUniqueKeyToPricebookInstance.get(key);
                if(pbePeriod.Account_Price__c != null){
                    pe.UnitPrice =  pbePeriod.Account_Price__c;
                }else{
                    pe.UnitPrice =  pbePeriod.List_Price__c;
                }
                //generate the wrapper
                OpportunityWrapper newItem = getProductItem(pe,dateFmt, pbePeriod,dealOrOrder.startDate, dealOrOrder.recordType);
                if (currentItems.containsKey(pe.id)) {
                    newItem.isDealProduct = true; 
                    newItem.existingId = currentItems.get(pe.id).id;  
                    newItem.quantity = (Integer)currentItems.get(pe.id).Quantity;
                } 
                if (!finalFilteredProductsMap.containsKey(key)) {
                    finalFilteredProductsMap.put(key, newItem);
                    if(!lstMpmNumbers.isEmpty() && lstMpmNumbers.contains(newItem.mpmName)){
                        finalWrapperList.add(newItem);
                    }
                }
            } 
        }  
        System.debug('finalFilteredProducts.size()::'+finalFilteredProductsMap.size());
        return finalFilteredProductsMap.values();
    } 
    
    /**
    *  @name queryPricebookentries
    *  @param CRM_DataObjects.ParentRecord dealOrOrder,Id pricebookId,Set<Id> setProductIds
    *  @return List<PricebookEntry>- fetched list of pricebookentries
    *  @throws None
    */
    private static List<PricebookEntry> queryPricebookentries(CRM_DataObjects.ParentRecord dealOrOrder,Id pricebookId,Set<Id> setProductIds) {
       Opportunity dealRecord= dealOrOrder.dealRecord;
       String queryString = 'SELECT Id,Product2Id ,CurrencyIsoCode,Product2.MPM__c,Product2.RecordTypeId,'+ 
                            ' UnitPrice'+
                            ' FROM PricebookEntry'+
                            ' WHERE Pricebook2Id =:pricebookId'+
                            ' AND IsActive = true AND Product2.IsActive = true'+
                            ' AND ( Product2.Type__c = \'' +CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE +'\' OR'+
                                    ' Product2.Type__c= \'' + CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE+'\' )'+
                            ' AND Product2.SAP_Material_Type__c != \'SBOM\''+
                            ' AND Product2Id IN:setProductIds'+
                            ' AND CurrencyIsoCode = \'' +dealRecord.CurrencyIsoCode+'\'';
                            
        system.debug('PBE queryString---->'+queryString);
        return (Database.query(queryString));
    }
    
    /**
    *  @name getProductItem
    *  @param PricebookEntry pe, Pricebook_Entry_Period__c pbep,Date startDate, string recordType
    *  @return OpportunityWrapper
    *  @throws None
    */
    private static OpportunityWrapper getProductItem(PricebookEntry pe ,String dateFmt ,Pricebook_Entry_Period__c pbep,Date startDate, string recordType) {
        // Create new item and initialise basic details
        OpportunityWrapper newItem = new OpportunityWrapper();
        newItem.productId = pbep.Product__c;
        newItem.name = pbep.Product__r.Name;
        newItem.productCode = pbep.Product__r.ProductCode;
        newItem.pricebookEntryId = pe.Id;
        newItem.format = pbep.Product__r.Product_Format__c;
        newItem.productMarket = pbep.Product__r.Product_Market__c != null ? pbep.Product__r.Product_Market__c : ''; 
        newItem.mpmName = pbep.Product__r.MPM__c;
        newItem.pbepRetailerId = pbep.Retailer_Product_ID__c;
        newItem.localTitleCategory = pbep.Product__r.Local_Title__r.Category__c; 
        String startDateStr = pbep.Start_Date__c ==null ? '' :DateTime.newInstance(pbep.Start_Date__c.year(),pbep.Start_Date__c.month(),pbep.Start_Date__c.day()).format(dateFmt); 
        newItem.pbepStartDate =pbep.Start_Date__c != null ? startDateStr : '';  
        String endDateStr = pbep.End_Date__c==null ?'' :DateTime.newInstance(pbep.End_Date__c.year(),pbep.End_Date__c.month(),pbep.End_Date__c.day()).format(dateFmt);
        newItem.pbepEndDate=pbep.End_Date__c != null ?endDateStr : ''; 
        newItem.clientAvailStatus = pbep.Client_Avail__r.Status__c;
        newItem.pbepPriceTier = pbep.Price_Tier__c; 
        newItem.pbepAccountPrice = pbep.Account_Price__c;
        newItem.productGenre = pbep.Product__r.Product_Genre__c;
        newItem.titleTag = pbep.Product__r.Local_Title__r.Title__r.Title_Tag__c; 
        newItem.productTopic =pbep.Product__r.Topics__c;
        newItem.productContentType =pbep.Product__r.Tittle_Content_Type__c;      
        newItem.productTitleAge = pbep.Product__r.Local_Title__r.Title__r.US_Theatrical_Release_Date_New__c !=null? (String.valueOf((pbep.Product__r.Local_Title__r.Title__r.US_Theatrical_Release_Date_New__c).year())) :'';
        newItem.listPrice = pe.UnitPrice;
        newItem.localTitleRating=pbep.Product__r.Local_Title__r.Local_Rating__c;
        newItem.localTitleName =pbep.Product__r.Local_Title__r.Name;
        newItem.digitalUPC = pbep.Product__r.Local_Title__r.Title__r.Digital_UPC__c;
        newItem.rateCardSRP = pbep.Client_Avail_Price__r.SRP__c;  
        setProdIds.add(pbep.Product__c); 
        return newItem;
    }
  
    /**
    *  @name getProductsWithMPMFilter
    *  @param List<String> mpmNos (Contains all mpms valid for the Deal), List<CRM_DataObjects.PicklistOption> options (contains the selected role),String searchText (contains the entered talent name text)
    *  @return Set of filtered set of String containing MPM Numbers
    *  @throws None
    */
    @RemoteAction
    public static Set<String> getProductsWithMPMFilter(Set<String> mpmNos , FilterWrapper filterWrap){
        //Prepare picklist filter values set from Picklist Option
         
        List<String> setSearchRoles = getPicklistValueSet(filterWrap.roleFilter);// get the roles selected 
        Set<String> mpmNumbersFound =new Set<String>(); 
        if(!setSearchRoles.isEmpty() || (filterWrap.searchText!='' && filterWrap.searchText!=null)){ 
            //form the query for MPM Talent
            String queryStr = 'SELECT id,MPM__c,toLabel(Role__c),Character__c,Talent__r.Name,MPM__r.MPM_Number__c'+ 
                                ' FROM MPM_Talent__c'+
                                ' WHERE MPM__r.MPM_Number__c IN:mpmNos AND Role__c!=null ';
             if(!setSearchRoles.isEmpty() && setSearchRoles[0]!=Label.CRM_AllRoles){
                 queryStr+= 'AND Role__c includes (\''+setSearchRoles[0]+'\')';
             }
            if(filterWrap.searchText != '' && filterWrap.searchText!=null ){      
                queryStr+= ' AND Talent__r.Name like '+'\'%' +filterWrap.searchText+'%\'';
            }
            for(MPM_Talent__c mpmTalentRecord : Database.query(queryStr)){
                mpmNumbersFound.add(mpmTalentRecord.MPM__r.MPM_Number__c);
            }
        } 
        return mpmNumbersFound;
    } 
    
     /**
     *  Method to fetch user input and perform insert/update operation on modified records  
     *  @name saveDealBibleProducts
     *  @param List<OpportunityWrapper> lstItemWrapperListUpdateDel,Id opportunityId, Boolean isDigitalDeal
     *  @return sorted List of OpportunityWrapper[]
     *  @throws None
     */  
    @RemoteAction
    global static List<OpportunityWrapper> saveDealBibleProducts(List<OpportunityWrapper> lstItemWrapperListUpdateDel,Id opportunityId, Boolean isDigitalDeal) {
         // Run through list of records to update and track the upsert records
        List<OpportunityLineItem> lstDealProdsToInsert = new List<OpportunityLineItem>();
        List<OpportunityLineItem> toDelete = new List<OpportunityLineItem>();
        List<OpportunityWrapper> listLiWrappersToInsert = new List<OpportunityWrapper>();
        List<OpportunityWrapper> listLiWrappersToDelete = new List<OpportunityWrapper>();
        /*************************Fetch existing Deal Products***********************************/
        List<OpportunityLineItem> currentItems = [SELECT Id, PricebookEntryId, Quantity  FROM OpportunityLineItem WHERE OpportunityId = :opportunityId];
        totalFailedRecords = 0;
        // Build a map with priue book entry id as key
        Map<Id, OpportunityLineItem> currentItemsMap = new Map<Id, OpportunityLineItem>();
        // set the index for each line item
        for (OpportunityLineItem dealWrapper : currentItems) {
            currentItemsMap.put(dealWrapper.PricebookEntryId, dealWrapper); 
        }
        
       /*************************Insert the selected rows ***********************************/
        for (OpportunityWrapper dealWrapper : lstItemWrapperListUpdateDel) {
            dealWrapper.recrodStatus = ''; 
            if(dealWrapper.isDealProduct == true && dealWrapper.isRowModified !=null && dealWrapper.existingId == null && dealWrapper.isRowModified == true && (dealWrapper.validation == null || dealWrapper.validation == '')){ 
                dealWrapper.recrodStatus = '';  
                dealWrapper.errorOccured = false;
                if (dealWrapper.quantity != null && dealWrapper.quantity > 0){
                    dealWrapper.listPrice = dealWrapper.listPrice == null ? 0 : dealWrapper.listPrice;
                    // New product to add
                    lstDealProdsToInsert.add(new OpportunityLineItem(
                        OpportunityId = opportunityId,
                        PricebookEntryId = dealWrapper.pricebookEntryId,
                        Quantity = dealWrapper.quantity,
                        UnitPrice = dealWrapper.listPrice,
                        listPrice__c = dealWrapper.listPrice,
                        discount = 0
                    ));
                    listLiWrappersToInsert.add(dealWrapper);
                }
            }else if((dealWrapper.isDealProduct == false && dealWrapper.existingId !=null && dealWrapper.isRowModified !=null && dealWrapper.isRowModified == true && (dealWrapper.validation == null || dealWrapper.validation == ''))){
                System.debug('delete dealWrapper::'+dealWrapper); 
                listLiWrappersToDelete.add(dealWrapper); 
            }else{
                 dealWrapper.errorOccured = false;
            }
        }
        List<Integer> lstRowIndexToAdd =new List<Integer>();
        List<Integer> lstRowIndexToRemove =new List<Integer>();
        /*************************Delete the selected rows ***********************************/
        if(!listLiWrappersToDelete.isEmpty()) {
            lstRowIndexToRemove =  deleteOpportunityLineItems(listLiWrappersToDelete,opportunityId); 
        }    
        System.debug('insert Size::'+lstDealProdsToInsert.size());
          
        /*************************Update the results for the selected rows ***********************************/
        if(!lstDealProdsToInsert.isEmpty()){
            list<Database.SaveResult> result = Database.insert(lstDealProdsToInsert,false);
            lstRowIndexToAdd = upsertDMLResultForTactics(result,listLiWrappersToInsert,opportunityId);
        }
        lstRowIndexToAdd.addall(lstRowIndexToRemove);
        lstRowIndexToAdd.sort();  
        
        if(!lstItemWrapperListUpdateDel.isEmpty()) {
            lstItemWrapperListUpdateDel[0].numFailedRecords = totalFailedRecords;
        } 
        system.debug('lineItemWrapperList::'+lstItemWrapperListUpdateDel);
        return lstItemWrapperListUpdateDel;
    }
    
     /**
     *  Method to update success/failure result on the record after dml-insert/update  
     *  @name updateDMLResult
     *  @param results, actual list on which dml is performed and string
     *  @return None
     *  @throws None
    */
    global static List<Integer> upsertDMLResultForTactics(list<Database.SaveResult> results,List<OpportunityWrapper> tacticWrapperList,Id opportunityId) {
        List<Integer> lstRowIndexToAdd = new List<Integer>(); 
        for(Integer i=0;i<results.size();i++){
              OpportunityWrapper lineItemWrapper = tacticWrapperList.get(i);
            if (!results.get(i).isSuccess()){
                // DML operation failed
                Database.Error error = results.get(i).getErrors().get(0);
                String failedDML = error.getMessage();
                totalFailedRecords++;
                lineItemWrapper.validation = failedDML;
                lineItemWrapper.errorOccured = true;
                lineItemWrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                lstRowIndexToAdd.add(lineItemWrapper.rowIndex);
            }else{
                lineItemWrapper.existingId = results.get(i).getId();
                lineItemWrapper.errorOccured = false;
                lineItemWrapper.isDealProduct = true;
                lineItemWrapper.recrodStatus = CRM_AppConstants.SUCCESS_MSG; //US : 994
                lineItemWrapper.validation = System.label.CRM_Upload_Message_Created;
                lineItemWrapper.isRowModified = false;
                lstRowIndexToAdd.add(lineItemWrapper.rowIndex);
            }
        } 
        lstRowIndexToAdd.sort();
        return lstRowIndexToAdd;
    } 
    
    /**
     *  Method to fetch user input and perform delete operation on existing records
     *  @name deleteOpportunityLineItems
     *  @param List<OpportunityWrapper> lstLiWrappersToDelete,Id opportunityid
     *  @return Integer[] list of row indexes to be removed from original list
     *  @throws None
     */ 
    global static List<Integer> deleteOpportunityLineItems(List<OpportunityWrapper> lstLiWrappersToDelete,Id opportunityid) {
        List<Id> listLineItemsToRemove = new List<Id>();
        List<OpportunityWrapper> listLiWrappersToRemove = new List<OpportunityWrapper>(); 
        List<Integer> lstRowIndexToRemove = new List<Integer>();
        Id OppId;
        
        if(lstLiWrappersToDelete!=null) {
            for (OpportunityWrapper wrapper : lstLiWrappersToDelete) {
                if (wrapper.existingId != null ) { // row is updated
                    OppId = opportunityid;
                    wrapper.isRowModified = false;
                    wrapper.isDealProduct = false;
                    wrapper.errorOccured = false;
                    wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                    listLiWrappersToRemove.add(wrapper);                    
                    listLineItemsToRemove.add(wrapper.existingId);
                }
                else {
                    lstRowIndexToRemove.add(wrapper.rowIndex);
                }
            }
        }
        try { 
            list<Database.DeleteResult> deleteLiResults = Database.delete(listLineItemsToRemove,false); 
            for(Integer i=0; i < deleteLiResults.size(); i++){
                OpportunityWrapper lineItemWrapper = listLiWrappersToRemove.get(i);
                lineItemWrapper.isRowModified = false; 
                if (!deleteLiResults.get(i).isSuccess()){
                    // DML operation failed
                    Database.Error error = deleteLiResults.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    totalFailedRecords++;
                    lineItemWrapper.existingId = listLineItemsToRemove[0];
                    lineItemWrapper.validation = failedDML;
                    lineItemWrapper.errorOccured = true;
                    lineItemWrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                 } else {
                    lstRowIndexToRemove.add(lineItemWrapper.rowIndex);
                    lineItemWrapper.validation = System.label.CRM_Deleted;
                    lineItemWrapper.existingId =null;
                    lineItemWrapper.recrodStatus = CRM_AppConstants.SUCCESS_MSG; //US : 994
                }
            }
        }catch(Exception e) {
            logException(OppId,e);
            
            for(Integer i=0; i < listLiWrappersToRemove.size(); i++){
                OpportunityWrapper lineItemWrapper = listLiWrappersToRemove[i];
                lineItemWrapper.isRowModified = false;
                lineItemWrapper.existingId = lineItemWrapper.existingId;
                lineItemWrapper.validation = e.getMessage();
                lineItemWrapper.errorOccured = true;
                lineItemWrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
             }
        }
        lstRowIndexToRemove.sort();
        return lstRowIndexToRemove;
    }
    
     /**
     *  Method to log the error
     *  @name logException
     *  @param Id oppId,Exception e
     *  @return Integer[] list of row indexes to be removed from original list
     *  @throws None 
     */ 
    public static void logException(Id oppId,Exception e){
                CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                errorLog.recordId = oppId;
                // Modules can be of type -> Deals / Targets / Demand / Orders / Co-Ops / Planning / General / Reporting / Non Functional
                errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_DEALS;
                errorLog.lineNumber = String.valueOf(e.getLineNumber());
                errorLog.errorMessage = e.getMessage();
                errorLog.stackTrace = e.getStackTraceString(); 
                // Call the logError method which will insert all errors into CRM_Error_Log__c object
                CRM_ErrorLogger.logError(errorLog);
    }
    
    /**
     * Method to get logged in uSer Locale Language code
    */
    global String getUserLocaleLanguage() {
        return UserInfo.getLocale().split('_')[0];
    }
    
    global String getUserLocaleLowerCase() {
        String currentUserLocale = UserInfo.getLocale();
        currentUserLocale = currentUserLocale.contains('_') ? currentUserLocale.replace( '_', '-') : 'en-US';
        return currentUserLocale.toLowerCase();
    }
  /** 
     *  Method to fetch the custom setting record to set boolean flag which make grid Editable / Read only for logged in user
     *  @name getIsGridInReadOnlyMode
     *  @param None
     *  @return boolean flag for RateCard edit access 
     *  @throws None
     */
    global Boolean getRCEditAccess() {
        return (Schema.sObjectType.OpportunityLineItem.isCreateable() || Schema.sObjectType.OpportunityLineItem.isUpdateable() || Schema.sObjectType.OpportunityLineItem.isDeletable());
    }
    /**  
    *  name getUserDateFormat: e.g. M/d/yyyy
    *  param none
    *  return string
    *  throw none
    */  
    global static String getUserDateFormat(){
        return CRM_ApplicationUtility.getLocaleToDateTimeFmtMap(UserInfo.getLocale()).substringBefore(' ');
    } 
     
    public String getResourceURL() {
        String currentUserLocale = UserInfo.getLocale();
        String resourceName = CRM_MultiOrder_Templates__c.getInstance(currentUserLocale) != null ? CRM_MultiOrder_Templates__c.getInstance(currentUserLocale).Template_API_Name__c : 'CRM_MultiOrder_Template_EN';
        List<StaticResource> resourceList = [SELECT Name, NamespacePrefix, SystemModStamp 
                                             FROM StaticResource 
                                             WHERE Name = :resourceName LIMIT 1];
                        
        if(!resourceList.isEmpty()) {
           String namespace = resourceList[0].NamespacePrefix;
           return '/resource/' 
              + resourceList[0].SystemModStamp.getTime() + '/' 
              + (namespace != null && namespace != '' ? namespace + '__' : '') 
              + resourceName; 
        } else return '';
    }

    /**
     * Method to get logged in uSer Locale
     */
    global String getUserLocale() {
        String currentUserLocale = UserInfo.getLocale();
        if (currentUserLocale.contains('_')) {
            currentUserLocale = currentUserLocale.replace( '_', '-');
        }
        return currentUserLocale;
    } 
     
    /**
    *  @name ProductSequenceRule 
    *  @Description Comparable class to sort and fetch the column labels
    *  @param CRM_DataObjects.ParentRecord dealOrOrder,Id pricebookId,Set<Id> setProductIds
    *  @return List<PricebookEntry>- fetched list of pricebookentries
    *  @throws None
    */
    global class ProductSequenceRule implements Comparable {
        public String ruleKey {get;set;}
        public CRM_Field_Bible__c rule {get;set;}
        
        global ProductSequenceRule(String key, CRM_Field_Bible__c rule){
            this.rule = rule;
            this.ruleKey = key;
        }
        
        global Integer compareTo(object compareTo) {
            if(rule.Order__c == ((ProductSequenceRule)compareTo).rule.Order__c){
                return 0;
            }
            else if(rule.Order__c > ((ProductSequenceRule)compareTo).rule.Order__c){
                return 1;
            } 
            return -1;
        }
    } 
    
     /**
    * Wrapper Class to store Picklist values
    */
    public class PicklistWrapper{
        
        PicklistVal contentTypeValues;
        PicklistVal channelValues;
        PicklistVal roleFilter;
        public PicklistWrapper(
                                PicklistVal roleFilter,
                                PicklistVal contentTypeValues,
                                PicklistVal channelValues
                               )
        {
            this.roleFilter = roleFilter;
            this.contentTypeValues = contentTypeValues;
            this.channelValues = channelValues;
        }
    }
    
    /**
    *  @Description - wrapper class
    *  @name  RateCardWrapper 
    */
    global class PicklistVal{
        List<String> picklist = new List<String>();
        List<CRM_DataObjects.PicklistOption> filterPicklist = new List<CRM_DataObjects.PicklistOption>();
        
        public picklistVal(List<String> picklist,List<CRM_DataObjects.PicklistOption> filterPicklist){
            this.picklist = picklist;
            this.filterPicklist = filterPicklist;
        }
    }
      
    /**
    *  @name OpportunityWrapper 
    *  @Description Wrapper class to store the data related to the column labels
    *  @throws None
    */
    global class OpportunityWrapper{
         //3312 starts
        global String name ='';
        global String productCode='';
        global String format='';
        global Integer quantity;
        global Date streetDate=null;
        global String pricebookEntryId='';
        global String productMarket='';
        global Decimal listPrice;
        global String mpmName='';
        global String pbepRetailerId='';
        global String localTitleCategory='';
        global String pbepStartDate=''; 
        global String pbepEndDate=''; 
        global String clientAvailStatus=''; 
        global String pbepPriceTier='';
        global Decimal pbepAccountPrice=null;
        global Decimal rateCardSRP=null;
        global String productGenre='';
        global String titleTag='';
        global String productTopic='';
        global String productContentType='';
        global Boolean isDealProduct =false;
        global String productTitleAge='';
        global String mpmTalentDetails='';
        global String localTitleRating='';
        global String localTitleName='';
        global String digitalUPC='';
        
        //validation
        global boolean errorOccured = false;
        global string recrodStatus='';//us994
        global Integer rowIndex;
        global Id productId =null;
        global Id existingId =null;
        global Boolean isRowModified =false;
        global String validation='';
        global Integer numFailedRecords; 
        global List<String> setMpmNumber;
        global List<Id> setProductIds;
    } 
     /* Wrapper class to be used as javascript remoting object */
    global class FilterWrapper {
        global string searchText;
        global CRM_DataObjects.PicklistOption[] contentType;
        global CRM_DataObjects.PicklistOption[] channel;
        global CRM_DataObjects.PicklistOption[] roleFilter;
    }
    public class CRM_DigitalBibleException extends Exception {}   
}