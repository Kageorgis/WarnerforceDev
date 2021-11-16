/**
   @Author Cognizant
   @name CRM_AddBundleProductsController
   @CreateDate 10 Dec 2015
   @Description This class will be use to show the bundle products to add remove it from bundle
   @Version <1.0>
   @reference Requirement no. 35
*/


global with sharing class CRM_AddBundleProductsController {
    
    /**
     *  Constructor
     *  @name CRM_AddBundleProductsController
     *  @param ApexPages.Standardcontroller stdCon
     *  @return None
     *  @throws None
     */
    public Id dealId;
    public boolean isPromotionalAssortment{get; set;} //US#788
    
    public CRM_AddBundleProductsController (ApexPages.Standardcontroller stdCon) {
        List<Bundle__c> bundles =new List<Bundle__c>();
        dealId = stdCon.getId();
        isPromotionalAssortment = false;
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
        //US#788 UNBW Products not visible for Promo Assort Type start
        if(dealId!=null){
           bundles = [SELECT id, RecordTypeId FROM Bundle__c WHERE Id =:dealId];
    }
        if(!bundles.isEmpty()){
            isPromotionalAssortment =(bundles[0].RecordTypeId == CRM_RecordTypeUtil.RT_Promotional_Assortment);
        }
        //US#788 end          
    }
    
    /* Defect # 4121 (German UAT)
     * Method to get logged in uSer Locale
     */
    global String getUserLocale() {
        String currentUserLocale = UserInfo.getLocale();
        currentUserLocale = currentUserLocale.contains('_') ? currentUserLocale.replace( '_', '-') : 'en-US';
        return currentUserLocale.toLowerCase();
    }  
    
    /* Defect # 4121 (German UAT)
    *  Method to get logged in uSer Locale Language code
    */
    global String getUserLocaleLanguage() {
        if(UserInfo.getLocale().split('_')[0] == 'en')
            return 'en-GB';
        return UserInfo.getLocale().split('_')[0];
    }
    
    /* Defect # 4121 (German UAT)
    *  name getUserDateFormat: e.g. M/d/yyyy
    *  param none
    *  return string
    *  throw none
    */  
    global String getUserDateFormat(){
        return CRM_ApplicationUtility.getLocaleToDateTimeFmtMap(UserInfo.getLocale()).substringBefore(' ');
    }
    
    /*global Boolean isUKSalesOrgDeal {
         get {
            System.debug('dealId:::::'+dealId);
            List<Opportunity> lstOpportunities = [select id, Sales_Organisation__c from Opportunity where id = :dealId];
            System.debug('lstOpportunities::'+lstOpportunities);
            if(!lstOpportunities.isEmpty()) {
                System.debug('lstOpportunities[0].Sales_Organisation__c::'+lstOpportunities[0].Sales_Organisation__c);
                System.debug('CRM_AppConstants.TERRITORY_UK_CODE::'+CRM_AppConstants.TERRITORY_UK_CODE);
                if(lstOpportunities[0].Sales_Organisation__c == CRM_AppConstants.TERRITORY_UK_CODE) {
                    return true;
                }
            }
            return false;
        }
    }*/
    //US#232
    global Boolean isTerritoryFR{
       get {
           Bundle__c op =[select Id,Price_Book__r.Business_Unit__c from Bundle__c where Id=:dealId];
           system.debug('Op value sales org'+op.Price_Book__r.Business_Unit__c);
           if(op.Price_Book__r.Business_Unit__c == CRM_AppConstants.TERRITORY_FRANCE_CODE){
                return true;
           }
           return false;
       }  
    }
    
    /**
     *  Public facing ip address for the user. Required by MARS as a basis for
     *  user authentication for asset (image) access.
     *  @name sourceIp
     *  @param None
     *  @return String clientIP
     *  @throws None
     */
    
    global String sourceIp {
        get {
            return CRM_ApplicationUtility.getClientSourrceIp();
        }
    }
    
    /**
     *  This method will return picklist values
     *  @name getFilterPicklistValues
     *  @param String object_name, String field_name, String first_val
     *  @return CRM_DataObjects.PicklistOption[]
     *  @throws None
     */
    
    @RemoteAction 
    global static CRM_DataObjects.PicklistOption[] getFilterPicklistValues(String object_name, String field_name, String first_val) {
        return CRM_AddProductsHelper.getFilterPicklistValues(object_name, field_name, first_val);
        //return CRM_AddProductsHelper.getFilterPicklistValuesWithRequestedObject(object_name, field_name, first_val,CRM_AppConstants.BUNDLE_OBJECT);
    }
    
    //Defect#4619 - added new remotye action to pre-filter the piclist values for SAP dis. and planr status
    @RemoteAction 
    global static CRM_DataObjects.PicklistOption[] getFilterPicklistValuesWithSObject(String object_name, String field_name, String first_val,string recordId) {
        //Defect #4619: Show default filter on page layout on add products page.
        //return CRM_AddProductsHelper.getFilterPicklistValues(object_name, field_name, first_val);
        system.debug('recordId -----------------'+recordId);
        Bundle__c op =[select Id,Price_Book__r.Business_Unit__c,Price_Book__r.Product_Type__c from Bundle__c where Id=:recordId];

        return CRM_AddProductsHelper.getFilterPicklistValuesWithRequestedObject(object_name, field_name, first_val,CRM_AppConstants.BUNDLE_OBJECT,op.Price_Book__r.Product_Type__c);
    }
    
    /**
     *  This method returns deal related product 
     *  @name getProducts
     *  @param Id bundleID, Id pricebookId, CRM_DataObjects.SearchFilters filters
     *  @return List<CRM_DataObjects.ProductItem>
     *  @throws None
     */    
    
    @RemoteAction 
    global static CRM_DataObjects.ProductWrapper getProducts(Id bundleID, Id pricebookId, CRM_DataObjects.SearchFilters filters) {
        CRM_DataObjects.ProductWrapper prodWrapper = new CRM_DataObjects.ProductWrapper();
        Set<String> dupCheck = new Set<String>();       
        
        List<CRM_DataObjects.ProductItem> items = new List<CRM_DataObjects.ProductItem>();
        List<CRM_DataObjects.ProductItem> filtereditems = new List<CRM_DataObjects.ProductItem>();
        
        // Fetch all Bundle products US#788
        List<Bundle__c> bundles = [SELECT id, Start_Date__c, CurrencyIsoCode, RecordTypeId,End_Date__c, Assortment_Status__c,Price_Book__r.Business_Unit__c,//added this field for US#232
                                   Price_Book__r.Country__c,//Defect#4363 added variable 'Account.Price_Book__r.Country__c' in query
                                   Price_Book__r.Product_Type__c,//US#1015:Product language column
                                   (SELECT CurrencyIsoCode, Product__c, Goal__c FROM Bundle_Products__r)  
                                   from Bundle__c where Id =:bundleID];

                            
        if(!bundles.isEmpty()) {
            // Change for FR
            CRM_Functional_Permissions__c functionalPermission = CRM_Functional_Permissions__c.getInstance();
            if(functionalPermission.Prevent_Assortment_Add_Products__c) {
                throw new CRM_CustomException(Label.CRM_Deal_Entry_NoAccessError);
            }
            else if(!bundles.isEmpty() && 
                ( bundles[0].Assortment_Status__c == CRM_AppConstants.ASSORTMENT_STATUS_AWATING_APPROVAL 
                || bundles[0].Assortment_Status__c == CRM_AppConstants.ASSORTMENT_STATUS_APPROVED 
                || bundles[0].Assortment_Status__c == CRM_AppConstants.ASSORTMENT_STATUS_CANCELLED)
            ) {
                throw new CRM_CustomException(System.Label.CRM_AddAssortmentProduct_InvalidStatusError);
            }
            
            CRM_DataObjects.ParentRecord dealOrOrder = new CRM_DataObjects.ParentRecord();
            dealOrOrder.startDate = bundles[0].Start_Date__c;
            dealOrOrder.bundleId = bundles[0].id;
            dealOrOrder.currencyCode = bundles[0].CurrencyIsoCode;
            dealOrOrder.endDate = bundles[0].End_Date__c;
            dealOrOrder.salesOrg= bundles[0].Price_Book__r.Business_Unit__c;//addded for : US#232
            dealOrOrder.recordType = 'Bundle__c';//addded for : US#232
            //Defect#4363
            dealOrOrder.bundleRecord = bundles[0];
            //US#788 UNBW products for Bundle
            dealOrOrder.bundleRecordTypeId =bundles[0].recordTypeId;
            // First grab a list of current items and quantities
            Map<Id, Bundle_Product__c> currentItems = new Map<Id, Bundle_Product__c>();
    
            for (Bundle_Product__c x : bundles[0].Bundle_Products__r) {
                currentItems.put(x.Product__c, x);
            }
            
            Date startDate = bundles[0].Start_Date__c;
            
            items = CRM_AddProductsHelper.searchProducts(dealOrOrder, pricebookId, filters);            
            
            for(CRM_DataObjects.ProductItem p: items) {
                if(!dupCheck.contains(p.productId)){
                    if (currentItems.containsKey(p.productId)) {
                        p.quantity = 1;
                    }
                    
                    filtereditems.add(p);
                    dupCheck.add(p.productId);
                }
            }
            //Start - US#1015:Product language column
            prodWrapper.isDigital = bundles[0].Price_Book__r.Product_Type__c == 'Digital' ? True : False;
            //End - US#1015:Product language column
        }

        prodWrapper.products = filtereditems;
        prodWrapper.maxPageCount = CRM_AddProductsHelper.maxPageCount;
        prodWrapper.maxLimitExceeded = CRM_AddProductsHelper.showErrorMsg;

        return prodWrapper;  
    }
    
    /**
     *  This method will save deal related product 
     *  @name saveProducts
     *  @param Id bundleID, List<CRM_DataObjects.ProductItemSave> products
     *  @return List<CRM_DataObjects.ProductItem>
     *  @throws None
     */
    
    @RemoteAction
    static global void saveProducts(Id bundleID, List<CRM_DataObjects.ProductItemSave> products) {
        // Build a map with priue book entry id as key
        Map<Id, Bundle_Product__c> currentItemsMap = new Map<Id, Bundle_Product__c>();
        
        //Get Assortment record with Id: bundleID to populate Assortment Product CurrencyIsoCode
        Bundle__c assortment = [Select Id, CurrencyIsoCode From Bundle__c where Id = :bundleID];

        for (Bundle_Product__c x : [SELECT Id, Product__c, Goal__c FROM Bundle_Product__c WHERE Bundle__c = :bundleID Limit 50000]) {
            currentItemsMap.put(x.Product__c, x);
        }

        // Run through list of records to update and track the upsert records
        List<Bundle_Product__c> toInsert = new List<Bundle_Product__c>();
        List<Bundle_Product__c> toDelete = new List<Bundle_Product__c>();

        for (CRM_DataObjects.ProductItemSave x : products) {
            if (currentItemsMap.containsKey(x.productId)) {
                Bundle_Product__c foundItem = currentItemsMap.get(x.productId);

                // Change to quantity on existing product
                if (x.quantity == null || x.quantity == 0) {
                    toDelete.add(foundItem);
                }
            }else if (x.quantity != null && x.quantity > 0){
                x.listPrice = (x.listPrice != null ? x.listPrice : 0);
                
                // New product to add
                toInsert.add(new Bundle_Product__c(
                    Bundle__c = bundleID,
                    Product__c = x.productId,
                    List_Price__c = x.listPrice,
                    Assortment_Price__c = x.listPrice,
                    CurrencyIsoCode = assortment.CurrencyIsoCode
                ));
            }
        }

        // Commit changes
        upsert toInsert;
        delete toDelete;
    }
}