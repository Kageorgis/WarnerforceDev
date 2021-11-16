/**
   @Author Cognizant
   @name CRM_UploadOrderProductsController
   @CreateDate 10 Feb 2016
   @Description This class is used to upload (update/insert) the deal products.
   @Version <1.0>
   @reference Requirement no 83
*/
global with sharing class CRM_UploadOrderProductsController {
    
    public Id orderId;
    public static Integer counter=0;
    public static Integer totalFailedRecords;
    public boolean totalQuantityFlag{get; set;}
    public static ApexPages.StandardController theController;
    global static string sort_By{get; set;}
        
    //public static boolean isDigitalDeal=false;
    /**
    *  @Description - constructor
    *  @name  CRM_UploadOrderProductsController 
    */
    global CRM_UploadOrderProductsController(ApexPages.StandardController stdController) {
        orderId = stdController.getId();
        theController = stdController;
        
        totalQuantityFlag = false;
        sort_By = 'Pricebookentry.Product2.Name ASC';
        List<Order> orderList = [Select Id,Config__r.RecordTypeId,Opportunity.NR_Deal_Unique_Key__c From Order where Id =:orderId Limit 1];  //req#791 added Opportunity.NR_Deal_Unique_Key__c
        if(orderList .size() > 0 && orderList.get(0).Config__r.RecordTypeId == CRM_RecordTypeUtil.RT_CONFIG_SBOM ){
            totalQuantityFlag = true;
        }
        if(orderList.size() > 0 && orderList.get(0).Opportunity.NR_Deal_Unique_Key__c != null){ //req#791
            sort_By = 'Pricebookentry.Product2.Street_Date__c DESC';
        }
    }
    
    /**
    *  @Description - wrapper class
    *  @name  OrderLineItemWrapper 
    */
    global class OrderLineItemWrapper implements Comparable{
        public OrderItem lineItemRecord;
        public String validation='';
        public Id existingId;
        public boolean isRowModified=false;
        public boolean isRowRemoved=false;
        public boolean previouslySelectedForRemoval=false;
        public Integer numFailedRecords;
        public string StreetDate; //req#791
        
        //US : 994 
        public string recrodStatus='';
        
        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
            OrderLineItemWrapper compareToOl = (OrderLineItemWrapper)compareTo;
            if (existingId == compareToOl.existingId) return 0;
            if (existingId > compareToOl.existingId) return 1;
            return -1;        
        }
    }

    /**
     * Method to get logged in uSer Locale
     */
    global String getUserLocale() {
        String currentUserLocale = UserInfo.getLocale();
        System.debug( '-before--UserInfo.getLocale()-->'+currentUserLocale);
        if (currentUserLocale.contains('_')) {
            currentUserLocale = currentUserLocale.replace( '_', '-');
        }

        /*
        currentUserLocale = currentUserLocale.contains('_') ? currentUserLocale.replace( '_', '-') : 'en-US';
        if (currentUserLocale.contains('en-')) {
            currentUserLocale = currentUserLocale.substringBefore('-');
        }*/
        System.debug( '-after--UserInfo.getLocale()-->'+currentUserLocale);
        return currentUserLocale;
    }

    /**
     *  Method to fetch the Order Product from orderId  
     *  @name getOrderLineItems
     *  @param Id orderId
     *  @return CRM_UploadOrderProductsController.OrderLineItemWrapper[]
     *  @throws None
     */
    @RemoteAction
    global static list<OrderLineItemWrapper> getOrderLineItems(Id orderId, String sort_By) {
           
        if(CRM_Functional_Permissions__c.getInstance().Prevent_Add_Products__c) {
                    throw new MyCustomException(Label.CRM_Deal_Entry_NoAccessError);
        }
        // Construct a list of Order Line Items
        List<OrderLineItemWrapper> returnWrapperList = new List<OrderLineItemWrapper>();
        //Defect #3554: Set to hold status
        // 01 =Active , 04 =On Hold & 11=Initial
        //Set<String> distChainProdStatus = new Set<String>{'1', '01','4','04','11'};
        // Find what products are in the Order
        try{
                String OrderItemQuery = 'SELECT order.ActivatedDate,PricebookentryId,Pricebookentry.Product2.Universal_Picture_Code__c,Pricebookentry.Product2.SAP_Sales_Org__c,Pricebookentry.Product2.Type__c,unitprice,Pricebookentry.product2.Street_Date__c,Pricebookentry.Product2.Name,Total_Quantity__c,quantity,order.Pricebook2Id,order.status, order.CurrencyISOCode,order.Name,Pricebookentry.Product2.ProductCode,orderId,id,Order.Opportunity.NR_Deal_Unique_Key__c,Pricebookentry.Product2.SAP_Dist_chain_product_Status__c FROM OrderItem WHERE orderId = :orderId ORDER BY ' + sort_By;
                List<OrderItem> OrderItemList = Database.query(OrderItemQuery);
                for(OrderItem lineItem : OrderItemList){
                            OrderLineItemWrapper lineItemWrapper = new OrderLineItemWrapper();
                            lineItemWrapper.existingId = lineItem.id;
                            lineItemWrapper.lineItemRecord = lineItem;
                            lineItemWrapper.validation = '';
                            lineItemWrapper.recrodStatus = ''; //US : 994
                            returnWrapperList.add(lineItemWrapper);
                }
                returnWrapperList.sort();
        }
        catch(Exception e) {
                logException(orderId,e);
                throw e;
        }
        return returnWrapperList;
    }
    
    public static void logException(Id orderId,Exception e){
                    CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                    errorLog.recordId = orderId;
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
    global static map<String,PricebookEntry> getPricebookEntries(Id pbId,String currencyISOCode, list<String> combination1List,list<String> combination2List) {
            map<String,PricebookEntry> pricebookEntryMap = new map<String,PricebookEntry>();
            String soqlString = 'Select id, UnitPrice,PriceBook2.name,product2.Universal_Picture_Code__c,product2.Street_Date__c,Pricebook2Id,currencyISOCode,'+
                                ' product2.name,product2.External_Id__c,Pricebookentry.Product2.SAP_Sales_Org__c,product2.Return_End_Date__c,  product2.Type__c,product2.productCode, IsActive, product2.IsActive, Product2.SAP_Dist_chain_product_Status__c, Product2.Plant_Specific_Material_Status__c'+
                                ' From PricebookEntry'+
                                ' where Pricebook2Id =: pbId'+
                                ' AND currencyISOCode =:currencyISOCode'+
                                ' AND isActive = true';
            soqlString+=' AND (product2.productCode IN: combination1List OR product2.Universal_Picture_Code__c IN: combination2List)';
            system.debug('====soqlString================'+soqlString);
            system.debug('====pbId================'+pbId);
            system.debug('====currencyISOCode================'+currencyISOCode);
            system.debug('====combination1List================'+combination1List);
            system.debug('====combination2List================'+combination2List);
            list<PricebookEntry> pbEntries = database.query(soqlString);
            for(PricebookEntry pbEntry : pbEntries) {
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
                    system.debug('====pricebookEntryMap=========dd======='+pricebookEntryMap);
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
     
    global static list<OrderLineItemWrapper> showResult(list<Database.SaveResult> results, list<OrderItem> dmlList,String successResultString) {
            list<OrderLineItemWrapper> returnWrapperList = new List<OrderLineItemWrapper>();
            set<Id> recordIdSet = new set<Id>();
            system.debug('===============dmlList================'+dmlList);
            for(Integer i=0;i<results.size();i++){
                    OrderLineItemWrapper lineItemWrapper = new OrderLineItemWrapper();
                    lineItemWrapper.lineItemRecord = dmlList.get(i);
                    lineItemWrapper.isRowModified =false;       
                    
                    if (results.get(i).isSuccess()){
                        lineItemWrapper.existingId = results.get(i).getId();
                        recordIdSet.add(lineItemWrapper.existingId);
                        lineItemWrapper.validation = successResultString;
                        lineItemWrapper.recrodStatus = CRM_AppConstants.SUCCESS_MSG; //US : 994
                    }
                    else if (!results.get(i).isSuccess()){
                        // DML operation failed
                        Database.Error error = results.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();
                        dmlList.get(i);//failed record from the list
                        system.debug('Failed ID'+dmlList.get(i).Id);
                        lineItemWrapper.lineItemRecord = dmlList.get(i);
                        lineItemWrapper.existingId = dmlList.get(i).Id;
                        //if(lineItemWrapper.existingId!=null)recordIdSet.add(lineItemWrapper.existingId); //Comment this line to persist value when error occurred
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
            map<Id,OrderItem> lineItems = 
            new map<Id,OrderItem>([SELECT Pricebookentry.product2.Universal_Picture_Code__c,unitprice, quantity, Pricebookentry.product2.Street_Date__c,order.Pricebook2Id, 
                                   order.CurrencyISOCode, order.Name, Pricebookentry.product2.ProductCode,
                                   Pricebookentry.Product2.Name,orderId,id
                                   FROM OrderItem
                                   WHERE Id IN: recordIdSet
                                   ORDER BY Pricebookentry.Product2.Name]);
            for(OrderLineItemWrapper wrapper:returnWrapperList) {
                if(lineItems.containsKey(wrapper.existingId)) {
                    wrapper.lineItemRecord = lineItems.get(wrapper.existingId);
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
    global static list<OrderLineItemWrapper> setOrderLineItems(List<OrderLineItemWrapper> lineItemWrapperList,Id orderId) {
        totalFailedRecords = 0;
         //Order Products Filter Flag for "Standard" RT
        boolean orderProductFilterFlag = false;
        Boolean orderProductFilterForRevShareFlag = false;

        // DEF#4219
        Boolean orderProductFilterForReturnEndDateFlag = false;

        // DEF#4114
        Boolean returnOrderProductFilterFlag = false;
        Set<String> distChainProdStatusForReturns =
            new Set<String>{
                CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_NON_RETURNABLE_Z5,
                CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_NON_RETURNABLE_05,
                    CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_INITIAL
            };

        // 01 =Active , 04 =On Hold & 11=Initial & 05 ,Z5 for Non-Returnable all territory
        Set<String> distChainProdStatus = new Set<String>{'01','04','11','05','Z5'};
        
        // 04=Active , 02=Released for 3rd Party & 05=Sell-down/Sell-Off
        Set<String> sAPDistChainProductStatus = new Set<String>{'04','02','05'};
        
        if(CRM_Functional_Permissions__c.getInstance().Prevent_Add_Products__c) {
                    throw new MyCustomException(Label.CRM_Deal_Entry_NoAccessError);
        }
        // Commit the targets to Account_Product__c 
        List<OrderItem> updateList = new List<OrderItem>();
        List<OrderItem> insertList = new List<OrderItem>();
        List<OrderLineItemWrapper> deleteList = new List<OrderLineItemWrapper>();
        List<OrderLineItemWrapper> returnList = new List<OrderLineItemWrapper>();
         
        List<String> productCodeList = new List<String>();
        List<String> productUPCList = new List<String>();
        
        set<id> productIds = new set<id>();
        
        map<String,PricebookEntry> pricebookEntryMap = new map<String,PricebookEntry>();
        CRM_ProductPricingHandler pricingHandler;
        list<CRM_ProductPricingHandler.DealWrapper> pricingHandlerOrderWrpList = new list<CRM_ProductPricingHandler.DealWrapper>();
        
        try{
                Order order = [select id,CreatedDate,Sales_Organisation__c,Account.Revenue_share__c,OpportunityId,Opportunity.Market_Type__c,Pricebook2Id,AccountId,EffectiveDate,EndDate,CurrencyISOCode,RecordTypeId from Order where Id =: orderId];
                
                if(order != null && order.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_STANDARD) {
                    orderProductFilterFlag = true;
                } else if(order.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE  
                    && order.Account.Revenue_share__c == true && order.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_REV_SHARE
                    && (order.OpportunityId == null || (order.OpportunityId != null &&
                    order.Opportunity.Market_Type__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE))
                ) {
                    orderProductFilterForRevShareFlag = true; 
                } else if (order.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_RETURN) {
                    returnOrderProductFilterFlag = true;
                    if (
                        order.Sales_Organisation__c == CRM_AppConstants.TERRITORY_GERMANY_CODE ||
                        order.Sales_Organisation__c == CRM_AppConstants.TERRITORY_SWITZERLAND_CODE ||
                        order.Sales_Organisation__c == CRM_AppConstants.TERRITORY_FRANCE_CODE
                    ) {
                        orderProductFilterForReturnEndDateFlag = true;
                    }
                }

                if (
                    order.Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE &&
                    (orderProductFilterFlag || orderProductFilterForRevShareFlag)
                ) {
                    sAPDistChainProductStatus.add(CRM_AppConstants.PRODUCT_PLANT_STATUS_INITIAL);
                }

                if (order.Sales_Organisation__c != CRM_AppConstants.TERRITORY_ITALY_CODE) {
                    distChainProdStatusForReturns.add(CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_LOST_RIGHTS);
                }

                // Set Dist Chain Status not allowed in error message dynamically
                Map<String,String> setDistChainStatusMap = new Map<String,String>();
                Schema.DescribeFieldResult fieldResult = Product2.SAP_Dist_chain_product_Status__c.getDescribe();
                List<Schema.PicklistEntry> distChainStatus = fieldResult.getPicklistValues();
        
                for (Schema.PicklistEntry status: distChainStatus){
                    setDistChainStatusMap.put(status.getValue(), status.getLabel());
                }

                String sapDistChainAllowedValues = '';
                Integer countRecords = 0;
                Set<String> removeDuplicateValues = new Set<String>();
                for (String distChainStatusCode : distChainProdStatusForReturns) {
                    if (setDistChainStatusMap.containsKey(distChainStatusCode)) {
                        String distChainStatusValue = setDistChainStatusMap.get(distChainStatusCode);
                        if (!removeDuplicateValues.contains(distChainStatusValue)) {
                            removeDuplicateValues.add(distChainStatusValue);
                            sapDistChainAllowedValues += distChainStatusValue;
                            if (countRecords < distChainProdStatusForReturns.size()-1) {
                                sapDistChainAllowedValues += ' / ';
                            }
                        }
                    }
                    countRecords++;
                }
                system.debug('===============sapDistChainAllowedValues================'+sapDistChainAllowedValues);
                system.debug('===============order================'+order);
                // Commit the targets to Account_Product__c
                OrderItem objLineItem = new OrderItem();
                 for (OrderLineItemWrapper wrapper : lineItemWrapperList) {
                        if(wrapper.isRowRemoved!=null && wrapper.isRowRemoved){
                                deleteList.add(wrapper);
                        }
                        else if(wrapper.isRowModified) {
                                if (wrapper.lineItemRecord.Id != null ) { 
                                    updateList.add(wrapper.lineItemRecord);
                                }        
                                else { // new row
                                    insertList.add(wrapper.lineItemRecord);
                                    if(wrapper.lineItemRecord.Pricebookentry.Product2.ProductCode!=null)productCodeList.add(wrapper.lineItemRecord.Pricebookentry.Product2.ProductCode);
                                    if(wrapper.lineItemRecord.Pricebookentry.product2.Universal_Picture_Code__c!=null)productUPCList.add(wrapper.lineItemRecord.Pricebookentry.product2.Universal_Picture_Code__c);
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
                        pricebookEntryMap = getPricebookEntries(order.Pricebook2Id,order.CurrencyISOCode,productCodeList,productUPCList);
                        
                        // prepare list of DealWrappers to get the pricebook entry period details
                        for(PricebookEntry pbEntry:pricebookEntryMap.values()) {
                                     CRM_ProductPricingHandler.DealWrapper pricingHandlerOrderWrp = new CRM_ProductPricingHandler.DealWrapper();
                                     pricingHandlerOrderWrp.dealId = orderId;
                                     pricingHandlerOrderWrp.accountId = order.AccountId;
                                     pricingHandlerOrderWrp.dealCurrency = order.currencyISOCode;
                                     pricingHandlerOrderWrp.productId = pbEntry.product2Id;
                                     pricingHandlerOrderWrp.pricebookId = order.pricebook2Id;
                                     pricingHandlerOrderWrp.dealStartDate = order.EffectiveDate;
                                     pricingHandlerOrderWrp.dealEndDate  = order.EndDate;
                                     pricingHandlerOrderWrpList.add(pricingHandlerOrderWrp);
                                     productIds.add(pbEntry.product2Id);
                        }
                        if(pricingHandlerOrderWrpList.size()>0) {
                            pricingHandler = new CRM_ProductPricingHandler(pricingHandlerOrderWrpList);
                        }
                        
                        insertList.clear();
                        for (OrderLineItemWrapper wrapper : lineItemWrapperList) {
                                    //wrapper.lineItemRecord.Quantity = 1; // defaults quantity to 1 for physical deal
                                combination = wrapper.lineItemRecord.Pricebookentry.product2.productCode+'_'+wrapper.lineItemRecord.Pricebookentry.product2.Universal_Picture_Code__c;
                                combination = order.Pricebook2Id+'_'+order.currencyISOCode+'_'+combination.tolowercase();
                                if(wrapper.isRowModified && wrapper.lineItemRecord.Id == null) {
                                            wrapper.lineItemRecord.order = null;
                                            wrapper.validation = '';
                                            wrapper.recrodStatus = ''; //US : 994
                                            if(pricebookEntryMap!=null && pricebookEntryMap.containsKey(combination)) {
                                                wrapper.lineItemRecord.PriceBookEntryId = pricebookEntryMap.get(combination).id;
                                                wrapper.lineItemRecord.PriceBookEntry.Product2 = pricebookEntryMap.get(combination).Product2;
                                                wrapper.lineItemRecord.PriceBookEntry.Product2.ProductCode = pricebookEntryMap.get(combination).Product2.ProductCode;
                                                wrapper.lineItemRecord.PriceBookEntry.Product2.Universal_Picture_Code__c = pricebookEntryMap.get(combination).Product2.Universal_Picture_Code__c;
                                                wrapper.lineItemRecord.PriceBookEntry.Product2.Street_Date__c = pricebookEntryMap.get(combination).Product2.Street_Date__c;
                                                wrapper.lineItemRecord.PriceBookEntry = pricebookEntryMap.get(combination);
                                                CRM_ProductPricingHandler.DealWrapper pricingHandlerDealWrp = new CRM_ProductPricingHandler.DealWrapper();
                                                pricingHandlerDealWrp.dealId = orderId;
                                                pricingHandlerDealWrp.accountId = order.AccountId;
                                                pricingHandlerDealWrp.dealCurrency = order.currencyISOCode;
                                                pricingHandlerDealWrp.productId = pricebookEntryMap.get(combination).Product2Id;
                                                pricingHandlerDealWrp.pricebookId = order.pricebook2Id;
                                                pricingHandlerDealWrp.dealStartDate = order.EffectiveDate;
                                                pricingHandlerDealWrp.dealEndDate  = order.EndDate;
                                                
                                                // Requirement: #3239
                                                if (pricebookEntryMap != null && pricebookEntryMap.containsKey(combination) && pricebookEntryMap.get(combination) != null && pricebookEntryMap.get(combination).product2 != null && pricebookEntryMap.get(combination).product2.IsActive == false){
                                                    wrapper.validation = Label.CRM_Upload_Message_Product_Not_Active;
                                                    wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                    returnList.add(wrapper);
                                                    totalFailedRecords++;
                                                    continue;
                                                }
                                                     //US#788 start
                                                    if( pricebookEntryMap.get(combination).Product2.Type__c ==CRM_AppConstants.UNBW_PRODUCT_TYPE //US#788 start
                                                        && pricebookEntryMap.get(combination).Product2.SAP_Sales_Org__c == CRM_AppConstants.TERRITORY_FRANCE_CODE ){
                                                            wrapper.validation = Label.CRM_UNBW_Products_Error;
                                                            wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                            returnList.add(wrapper);
                                                            totalFailedRecords++;
                                                            continue;
                                                    }
                                                     //US#788 end
                                                //Validation for 'Standard' and 'Return' RT of Order
                                                if (
                                                        pricebookEntryMap != null && pricebookEntryMap.containsKey(combination) && 
                                                        pricebookEntryMap.get(combination) != null && pricebookEntryMap.get(combination).product2 != null &&
                                                        pricebookEntryMap.get(combination).product2.SAP_Dist_chain_product_Status__c != null
                                                ){
                                                    String dChainStatus = pricebookEntryMap.get(combination).product2.SAP_Dist_chain_product_Status__c;
                                                    if ((orderProductFilterFlag || orderProductFilterForRevShareFlag) && pricebookEntryMap.get(combination).product2.Plant_Specific_Material_Status__c != null){
                                                        String pSMStatus = pricebookEntryMap.get(combination).product2.Plant_Specific_Material_Status__c;
                                                            //US#788 UNBW changes
                                                            if(!distChainProdStatus.contains(dChainStatus) && pricebookEntryMap.get(combination).Product2.Type__c != CRM_AppConstants.UNBW_PRODUCT_TYPE ){
                                                                wrapper.validation = Label.CRM_SAP_Dist_chain_product_Status_Not_Valid;
                                                                wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                            returnList.add(wrapper);
                                                            totalFailedRecords++;
                                                            continue;
                                                        }
                                                            //US#788 UNBW changes
                                                            if(!sAPDistChainProductStatus.contains(pSMStatus) && pricebookEntryMap.get(combination).Product2.Type__c != CRM_AppConstants.UNBW_PRODUCT_TYPE ){
                                                                system.debug('IN Error Block');
                                                            wrapper.validation = Label.CRM_Plant_Specific_Material_Status_Not_Valid;
                                                            wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG;  //US : 994
                                                            returnList.add(wrapper);
                                                            totalFailedRecords++;
                                                            continue;
                                                        }
                                                    } 
                                                    // DEF#4114
                                                    else if (returnOrderProductFilterFlag) {
                                                        //US#788 UNBW changes
                                                        if(distChainProdStatusForReturns.contains(dChainStatus) && pricebookEntryMap.get(combination).Product2.Type__c != CRM_AppConstants.UNBW_PRODUCT_TYPE){
                                                            wrapper.validation = String.format(System.Label.CRM_SAP_Dist_chain_product_Status_Not_Valid_For_Returns, new String[]{ sapDistChainAllowedValues });
                                                            wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                            returnList.add(wrapper);
                                                            totalFailedRecords++;
                                                            continue;
                                                        }

                                                        // DEF#4219
                                                        if (orderProductFilterForReturnEndDateFlag) {

                                                            if (wrapper.lineItemRecord.PriceBookEntry.Product2.Return_End_Date__c != null && wrapper.lineItemRecord.PriceBookEntry.Product2.Return_End_Date__c < order.CreatedDate) {
                                                                wrapper.validation = System.Label.CRM_Valid_Product_Return_End_Date;
                                                                wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                                returnList.add(wrapper);
                                                                totalFailedRecords++;
                                                                continue;
                                                            }
                                                        }
                                                    }
                                                    
                                                    /*if( !distChainProdStatus.contains(dChainStatus) || !sAPDistChainProductStatus.contains(pSMStatus)){
                                                        wrapper.validation = Label.CRM_Upload_Message_Product_Not_Active;
                                                        returnList.add(wrapper);
                                                        totalFailedRecords++;
                                                        continue;
                                                    }*/
                                                }
                                                if(pricingHandler == null) {
                                                        wrapper.validation = Label.CRM_Upload_Message_NotFound;
                                                        wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                        returnList.add(wrapper);
                                                        totalFailedRecords++;
                                                        continue;
                                                }
                                                Pricebook_Entry_Period__c pbep = pricingHandler.getProductDatedPricebookEntryPeriod(pricingHandlerDealWrp);
                                                           
                                                //if no pbep exists then throw error
                                                //if product PBEP Start Date does not lie in deal dates, then throw error
                                                if(pbep == null) {
                                                        wrapper.validation = Label.CRM_Upload_Message_PBEP;
                                                        wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                        returnList.add(wrapper);
                                                        totalFailedRecords++;
                                                        continue;
                                                }
                                                //wrapper.lineItemRecord.PriceBookEntry = null;
                                                wrapper.lineItemRecord.orderId = orderId;
                                            
                                                if(wrapper.lineItemRecord.unitprice==null) { // if user has not provided unit price then get it from pricebook entry period
                                                           wrapper.lineItemRecord.unitprice = pricingHandler.getProductDatedListPrice(pricingHandlerDealWrp);
                                                               if(wrapper.lineItemRecord.unitprice == 0 
                                                                        && !(wrapper.lineItemRecord.Pricebookentry.Product2.Type__c == CRM_AppConstants.UNBW_PRODUCT_TYPE //US#788 UNBW changes
                                                                            && wrapper.lineItemRecord.Pricebookentry.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL
                                                                            && wrapper.lineItemRecord.Pricebookentry.Product2.SAP_Sales_Org__c == CRM_AppConstants.TERRITORY_ITALY_CODE)) {
                                                                 wrapper.validation =Label.CRM_Upload_Message_Not_Valid_Price;
                                                                 wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                                 returnList.add(wrapper);
                                                                 totalFailedRecords++;
                                                                 continue;
                                                           }
                                                           else {
                                                                insertList.add(wrapper.lineItemRecord);
                                                           }
                                                }
                                                else 
                                                    insertList.add(wrapper.lineItemRecord);
                                            }
                                            else {
                                                 wrapper.validation = Label.CRM_Upload_Message_NotFound;
                                                 wrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                                //defect#4393 changes - start
                                                 totalFailedRecords++;
                                                //defect#4393 changes - Ends
                                                returnList.add(wrapper);
                                            }
                                            
                                }
                        }
                        system.debug('===============insertList================'+insertList);
                        list<Database.SaveResult> insertResults = Database.insert(insertList,false);
                        returnList.addAll(showResult(insertResults,insertList,Label.CRM_Upload_Message_Created));
                }
                if(deleteList.size()>0) {
                   list<OrderLineItemWrapper> listDeleted=deleteOrderLineItems(deleteList); 
                   system.debug('===============listDeleted================'+listDeleted);
                   if(listDeleted.size()>0) {
                        returnList.addAll(listDeleted);
                   }
                }
                system.debug('===============returnList================'+returnList);
                returnList.sort();
        }
        catch(Exception e) {
                logException(orderId,e);
                throw e;
        }
        if(!returnList.isEmpty()){
          returnList[0].numFailedRecords = totalFailedRecords;
        }
        return returnList;
    }
    
    /**
     *  Method to fetch user input and perform delete operation on existing records  
     *  @name deleteOrderLineItems
     *  @param CRM_UploadOrderProductsController.OrderLineItemWrapper[] and order Id
     *  @return sorted CRM_UploadOrderProductsController.OrderLineItemWrapper[]
     *  @throws None
     */
     
    //@RemoteAction
    global static list<OrderLineItemWrapper> deleteOrderLineItems(List<OrderLineItemWrapper> toDeletelineItemWrapperList) {
        // Commit the targets to Account_Product__c 
        List<OrderItem> removeList = new List<OrderItem>();
        List<OrderLineItemWrapper> returnList = new List<OrderLineItemWrapper>();
        
        Id orderId;
        String orderStatus;
        DateTime activatedDate;
        if(toDeletelineItemWrapperList!=null)
        for (OrderLineItemWrapper wrapper : toDeletelineItemWrapperList) {
                if (wrapper.existingId != null ) { // row is updated
                    orderId = wrapper.lineItemRecord.orderId;
                    orderStatus = wrapper.lineItemRecord.Order.Status;
                    activatedDate = wrapper.lineItemRecord.Order.ActivatedDate;
                    wrapper.isRowRemoved =false;
                    wrapper.isRowModified =false;
                    removeList.add(wrapper.lineItemRecord);
                }        
        }
         //system.debug('====removeList===========toDeletelineItemWrapperList================'+toDeletelineItemWrapperList);
        system.debug('====removeList===========lineItemWrapperList================'+removeList);
        try {
                system.debug('====orderStatus===========lineItemWrapperList================'+orderStatus);
                //if(orderStatus==CRM_AppConstants.ORDER_STAGE_SUBMITTED) {
                if(ActivatedDate != null){
                    returnList.addAll(toDeletelineItemWrapperList);
                    throw new MyCustomException(Label.CRM_Upload_Message_ActiveOrder);
                }
                else {
                    list<Database.DeleteResult> removeListResults = Database.delete(removeList,false);
                    system.debug('====removeListResults===========lineItems================'+removeListResults);
                    for(Integer i=0;i<removeListResults.size();i++){
                                OrderLineItemWrapper lineItemWrapper = new OrderLineItemWrapper();
                                lineItemWrapper.lineItemRecord = removeList.get(i);
                                lineItemWrapper.isRowModified =false;
                                lineItemWrapper.isRowRemoved =false;
                                
                                if (!removeListResults.get(i).isSuccess()){
                                    // DML operation failed
                                    Database.Error error = removeListResults.get(i).getErrors().get(0);
                                    String failedDML = error.getMessage();
                                    system.debug('Failed ID remove -'+removeList.get(i).Id);
                                    lineItemWrapper.existingId = removeList.get(i).Id;
                                    lineItemWrapper.validation = failedDML;
                                    lineItemWrapper.recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                                    returnList.add(lineItemWrapper);
                                    totalFailedRecords++;
                                }
                                
                    }
                }
                //If(lineItemWrapperList!=null)returnList.addAll(lineItemWrapperList);
                returnList.sort();
        }
        catch(Exception e) {
                system.debug('====exception occurred===========lineItems================'+e);
                logException(orderId,e);
                for(Integer i=0;i<returnList.size();i++){
                        returnList[i].validation = e.getMessage();
                        returnList[i].recrodStatus = CRM_AppConstants.ERROR_MSG; //US : 994
                }
                returnList.sort();
                //throw e;
        }
        system.debug('====removeList===========returnList================'+returnList);
        return returnList;
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
    
    //US : 989
    public string getHandsonTable_Pro_Licencekey (){
        return CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c != null ? CRM_Default_Configuration__c.getOrgDefaults().HansonTable_Pro_LicenseKey__c : '';
    } 
    
    public class MyCustomException extends Exception{}
}