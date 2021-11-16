/**
   @Author Cognizant
   @name CRM_AddOpportunityProductsController
   @CreateDate 10 Dec 2015
   @Description This class will be use to show the bundle products to add remove it from bundle
   @Version <1.0>
   @reference Requirement no 09
*/

global with sharing class CRM_AddOpportunityProductsController {
    
    /**
     *  Constructor
     *  @name CRM_AddOpportunityProductsController
     *  @param ApexPages.Standardcontroller stdCon
     *  @return None
     *  @throws None
     */
    public boolean isGerman{get; set;}
    public Id dealId;
    public Opportunity deal;
    //Germany US#253
    global static Map<String,Integer> mapDealPriority = new Map<String,Integer>{'High' => 3, 'Normal' => 2, 'Low' => 1};
    
    /**
     *  Public fetching DE profiles to hide the side panel filter for DE profiles --For German Requirement - 289.
     *  @name hideSideBarFilters
     *  @param None
     *  @throws None
     */
    
    /*
    global boolean hideSideBarFilters {
        get {
            return (CRM_Functional_Permissions__c.getInstance().Hide_Sidebar_Filters__c == true ? true:false);
        }
    }
    */
    
    /* US#317 (Japan)
     * Method to get logged in uSer Locale
     */
    global String getUserLocale() {
        String currentUserLocale = UserInfo.getLocale();
        currentUserLocale = currentUserLocale.contains('_') ? currentUserLocale.replace( '_', '-') : 'en-US';
        return currentUserLocale.toLowerCase();
    }  
    
    /* US#317 (Japan)
    *  Method to get logged in uSer Locale Language code
    */
    global String getUserLocaleLanguage() {
        if(UserInfo.getLocale().split('_')[0] == 'en')
            return 'en-GB';
        return UserInfo.getLocale().split('_')[0];
    }
    
    /* US#317 (Japan)
    *  name getUserDateFormat: e.g. M/d/yyyy
    *  param none
    *  return string
    *  throw none
    */  
    global String getUserDateFormat(){
        return CRM_ApplicationUtility.getLocaleToDateTimeFmtMap(UserInfo.getLocale()).substringBefore(' ');
    }
    
    public CRM_AddOpportunityProductsController(ApexPages.Standardcontroller stdCon) {
        dealId = stdCon.getId();
         if (stdCon.getId() != null) {
            List<Opportunity> lstOpportunity =[SELECT Id, stageName, Sales_Organisation__c, RecordTypeId, AccountId, Account.Digital_Country_Code__c, Account.Consignment_Customer__c, Market_Type__c, Last_Published_Date__c, RecordType.DeveloperName,
                    Account.Sales_Organization__c, Bundle__c, Bundle__r.RecordTypeId, High_Level_Forecast__c, High_Level_Target__c, TotalOpportunityQuantity,
                    Account.Revenue_Share__c,Co_op_Requested_Amount__c,Estimated_Customer_Revenue__c/*Commenting for  US#954 US Games,Coop_Budget__r.Co_op_Balance__c*/,Amount
                FROM Opportunity WHERE Id = :dealId ];
                
            if (!lstOpportunity.isEmpty()) {
                deal = lstOpportunity[0];
                isGerman = (
                        (lstOpportunity[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && (lstOpportunity[0].Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_GERMANY_CODE || lstOpportunity[0].Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_SWITZERLAND_CODE ))
                        ||
                        (lstOpportunity[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL && CRM_AppConstants.GERMANY_DIGITAL_COUNTRY_CODES.contains(lstOpportunity[0].Account.Digital_Country_Code__c))
                    );
                }
         }
          Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
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
     *  REST Image Service URL for url to display images.
     *  @name WB2BImageServiceUrl
     *  @param None
     *  @return String WB2BImageService__c
     *  @throws None
     */
    global WB2B_Details__c WB2BImageServiceSettings {
        get {
            // Fetch all the settings item in the custom setting for making request to B2B Images service
            WB2B_Details__c b2bSettings = WB2B_Details__c.getValues('WB2B');
            return b2bSettings;
        }
    }
            

    
    /*global Boolean isUKSalesOrgDeal {
        get {
            Opportunity opp = [select id, Sales_Organisation__c from Opportunity where id = :dealId];
            if(opp.Sales_Organisation__c == CRM_AppConstants.TERRITORY_UK_CODE) {
                return true;
            }
            return false;
        }
    }*/

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
    }

    /**
     *  This method returns deal related product 
     *  @name getProducts
     *  @param Id opportunityId, Id pricebookId, CRM_DataObjects.SearchFilters filters
     *  @return List<CRM_DataObjects.ProductItem>
     *  @throws None
     */
    
    @RemoteAction 
    global static CRM_DataObjects.ProductWrapper getProducts(Id opportunityId, Id pricebookId, CRM_DataObjects.SearchFilters filters) {
        // Commented - DEF#4143 : Moved filtering code from controller to AddProductsHelper
        //JAPAN-US:480 Deal Products Filter Flag 
        //boolean dealProductFilterFlag = false;
        //Germany US 289
        Boolean isGermanDeal = false;
        //Germany US#253 starts 
        Set<Id> productIds = new Set<Id>(); 
        //US#253 ends
        CRM_DataObjects.ProductWrapper prodWrapper = new CRM_DataObjects.ProductWrapper();
        List<CRM_DataObjects.ProductItem> items = new List<CRM_DataObjects.ProductItem>();
        
        // Commented - DEF#4143 : Moved filtering code from controller to AddProductsHelper
        //JAPAN-US:480 filteredItems of ProductItem
        //List<CRM_DataObjects.ProductItem> filteredItems = new List<CRM_DataObjects.ProductItem>();
        //BENELUX : #462. Query Modified two new fields added Bundle__r.RecordTypeId,Sales_Organisation__c
        List<Opportunity> deals = [Select id, Start_Date__c, AccountId,Account.Digital_Country_Code__c, Market_Type__c,RecordTypeId, CurrencyIsoCode, StageName, Account.Sales_Organization__c, Bundle__c, CloseDate,
                            Sales_Organisation__c,Bundle__r.RecordTypeId,Pricebook2Id,Account.Price_Book__r.Country__c,//Defect#4363 added variable 'Account.Price_Book__r.Country__c' in query
                            (SELECT PricebookEntryId, Quantity FROM OpportunityLineItems) 
                            from Opportunity 
                            where Id =:opportunityId limit 1]; //Pricebook2Id added for no price book on deal error

        if(!deals.isEmpty()) {
            /*
            if(deals[0].Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_JAPAN_CODE && (deals[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL)){
                dealProductFilterFlag = true;
            }*/
            //Germany US 289
            isGermanDeal = (
                    (deals[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL && (deals[0].Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_GERMANY_CODE || deals[0].Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_SWITZERLAND_CODE ))
                    ||
                    (deals[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL && CRM_AppConstants.GERMANY_DIGITAL_COUNTRY_CODES.contains(deals[0].Account.Digital_Country_Code__c))
                );
                
            if(CRM_AddProductsHelper.getPreventAddProductsFlag()) {
                throw new CRM_AddOpportunityProductsException(Label.CRM_Deal_Entry_NoAccessError);
            }
            else if(!deals.isEmpty() && (deals[0].StageName == CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED || deals[0].StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED)){
                throw new CRM_AddOpportunityProductsException(Label.CRM_RefreshProductPrice_DealStageError);
            }else if(!deals.isEmpty() && deals[0].Pricebook2Id == null){ //added for no price book on deal error
                throw new CRM_AddOpportunityProductsException(Label.CRM_Deal_with_NoPriceBookError);
            }

            /*if(
                !deals.isEmpty() &&
                (
                    deals[0].Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_JAPAN_CODE &&
                    deals[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL &&
                    deals[0].Market_Type__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE
                )
            ) {
                throw new CRM_AddOpportunityProductsException(Label.CRM_Cannot_Add_Rental_Products_Manually);
            }*/

            CRM_DataObjects.ParentRecord dealOrOrder = new CRM_DataObjects.ParentRecord();
            dealOrOrder.salesOrg = deals[0].Account.Sales_Organization__c;
            dealOrOrder.currencyCode = deals[0].CurrencyIsoCode;
            dealOrOrder.startDate = deals[0].Start_Date__c;
            dealOrOrder.bundleId = deals[0].Bundle__c;
            dealOrOrder.accountId = deals[0].AccountId;
            dealOrOrder.endDate = deals[0].CloseDate;
            // DEF#4143 : Moved filtering code from controller to AddProductsHelper
            dealOrOrder.recordType = CRM_AppConstants.OPPORTUNITY_OBJECT;
            dealOrOrder.dealRecord = deals[0];

            // First grab a list of current items and quantities
            Map<Id, OpportunityLineItem> currentItems = new Map<Id, OpportunityLineItem>();
    
            for (OpportunityLineItem x : deals[0].OpportunityLineItems) {
                currentItems.put(x.PricebookEntryId, x);
            }
            
            Date startDate = deals[0].Start_Date__c;
            
            items = CRM_AddProductsHelper.searchProducts(dealOrOrder, pricebookId, filters);
           
        //<===========  BENELUX : #462. Start of Code   ============>
            if(
                    deals[0].Sales_Organisation__c == CRM_AppConstants.TERRITORY_BELGIUM_CODE ||
                    deals[0].Sales_Organisation__c == CRM_AppConstants.TERRITORY_NETHERLAND_CODE ||
                    CRM_AppConstants.GERMANY_SALES_ORGS.contains(deals[0].Sales_Organisation__c) ||
                    CRM_AppConstants.IT_SP_NO_SALES_ORGS.contains(deals[0].Sales_Organisation__c) || 
                    deals[0].Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE
            ){
                if((deals[0].Bundle__c !=null) && (deals[0].Bundle__r.RecordTypeId == CRM_RecordTypeUtil.RT_Promotional_Assortment)){
                    
                     for(CRM_DataObjects.ProductItem prod : items){
                        productIds.add(prod.productId);
                    }
                    
                    Map<Id, Decimal> mapProdIdtoAssortPrice = new Map<Id, Decimal>();
                    for(Bundle_Product__c bProd : [SELECT id,Product__c,Assortment_Price__c FROM Bundle_Product__c WHERE Bundle__c =: deals[0].Bundle__c AND Product__c IN : productIds]){
                        mapProdIdtoAssortPrice.put(bProd.Product__c, bProd.Assortment_Price__c);
                    }//End of For Loop
                    
                    if(mapProdIdtoAssortPrice.size() > 0 && mapProdIdtoAssortPrice!=null){
                        for(CRM_DataObjects.ProductItem prod : items){
                            if(mapProdIdtoAssortPrice.get(prod.productId) != null){
                                //Assigning Assortment Price to List Price
                                prod.listPrice = mapProdIdtoAssortPrice.get(prod.productId);
                            }
                        }//End of For Loop  
                    }//End of IF
                    
                }//End of Inner If
            }//End of Outer If     
      
       //<===========   BENELUX : #462. End of Code  ===========>
        
            for(CRM_DataObjects.ProductItem p: items) {
                if (currentItems.containsKey(p.pricebookEntryId)) {
                    p.quantity = (Integer)currentItems.get(p.pricebookEntryId).Quantity;
                }
                if(isGermanDeal){
                    p.stockWarning = false;
                    //Germany US#253 starts
                    productIds.add(p.productId); 
                    //US#253 ends
                }
                
                // Commented - DEF#4143 : Moved filtering code from controller to AddProductsHelper
                //JAPAN-US:480 Prepare collection of filtered items base on deal's 'Market Type' and product's 'Product Market'.
                /*if(dealProductFilterFlag && deals[0].Market_Type__c == p.productMarket) {
                    // Japan : Commented as we need to allow Manual NR deal products for Rental Deals - DEF#3977
                    //if (p.productType == CRM_AppConstants.PRODUCT_TYPE_NEW_RELEASE && p.productMarket == CRM_AppConstants.PRODUCT_RENTAL_MARKET_TYPE) {
                    //    continue;
                    //} else {
                        filteredItems.add(p);
                    //}
                }*/
            }
            //Start - US#1015:Product language column
			prodWrapper.isDigital = deals[0].RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL ? True : False;
			//End - US#1015:Product language column
        }
        system.debug('Items: '+items);
        //system.debug('filteredItems : '+filteredItems.size());
        // Commented - DEF#4143 : Moved filtering code from controller to AddProductsHelper
        prodWrapper.products = items; //dealProductFilterFlag ? filteredItems : items;
        //prodWrapper.products = items;
        prodWrapper.maxPageCount = CRM_AddProductsHelper.maxPageCount;
        prodWrapper.maxLimitExceeded = CRM_AddProductsHelper.showErrorMsg;
        if(isGermanDeal){
            //Germany US#253 starts
            prodWrapper.setProductIds=productIds; 
            //US#253 ends
        }
        System.debug('prodWrapper::::'+prodWrapper);
        return prodWrapper; 
    }
   //Germany US#253 starts
     /**
     *  This method returns wrapper with ThreeMonthOrderHistory, LastPromotedPrice wrt Product
     *  @name displayDealProdMoreInformation
     *  @param Id opportunityId,Lst of Product Ids :lstProductIds
     *  @return List<CRM_DataObjects.ProductWrapper>
     *  @throws None
     */
    @RemoteAction
    global static CRM_DataObjects.ProductWrapper displayDealProdMoreInformation(Id opportunityId, List<Id> lstProductIds) {  
         CRM_DataObjects.ProductWrapper prodWrapper = new CRM_DataObjects.ProductWrapper();
         List<CRM_DataObjects.ProductItem> items = new List<CRM_DataObjects.ProductItem>();
         Map<Id,Decimal> mapProdIdPromoPrice =new map<Id,Decimal>(); 
         Map<id,list<DealProdWrapper>> mapProdIdLstDealProd = new Map<id,list<DealProdWrapper>>();
         System.debug('displayDealProdMoreInformation::'+opportunityId+'*******'+lstProductIds);
         
         try {
                List<Opportunity> lstOpportunity =[SELECT Id, stageName, Sales_Organisation__c, RecordTypeId, AccountId,Account.Level_1_Account__c, 
                                                            Account.Level_2_Account__c,Account.Level_3_Account__c,Account.Level_4_Account__c
                                                            FROM Opportunity 
                                                            WHERE Id = :opportunityId ];
                if(!lstOpportunity.isEmpty()){
                    Date promoEndDate = date.newInstance(system.today().year(), system.today().month() - 3, 1);
                    //Aggregate result to get ThreeMonthOrderHistory for every product 
                    Map<ID, AggregateResult> mapThreeMonthOrderHistory = 
                                new Map<id,AggregateResult>([SELECT Product2.id ,sum(quantity) quantityDealProduct
                                                                    FROM OpportunityLineItem 
                                                                    WHERE Product2id!=null
                                                                    AND Opportunity.AccountId =: lstOpportunity[0].AccountId
                                                                    AND Product2Id  IN: lstProductIds
                                                                    AND Opportunity.StageName =: CRM_AppConstants.OPPORTUNITY_STAGE_POS_Actuals 
                                                                    AND Opportunity.Promo_End_Date__c >: promoEndDate
                                                                    GROUP BY Product2.id ]);
                    //Get all Deal Products for calculating Last promoted price.
                    List<OpportunityLineItem> lstDealProduct =[SELECT Product2Id,Promoted_Price__c,
                                                                      Opportunity.Deal_Priority__c,
                                                                      Opportunity.Overlapping_Deal_Counter__c,
                                                                      Opportunity.Start_Date__c,Opportunity.CloseDate
                                                                      FROM OpportunityLineItem 
                                                                      WHERE (Opportunity.Accountid =: lstOpportunity[0].AccountId OR  
                                                                             Opportunity.Accountid =: lstOpportunity[0].Account.Level_1_Account__c OR  
                                                                             Opportunity.Accountid =: lstOpportunity[0].Account.Level_2_Account__c OR  
                                                                             Opportunity.Accountid =: lstOpportunity[0].Account.Level_3_Account__c OR  
                                                                             Opportunity.Accountid =: lstOpportunity[0].Account.Level_4_Account__c)
                                                                      AND Product2Id IN: lstProductIds
                                                                      AND Opportunity.Start_Date__c <=: System.today()];
                    //Create a map of Product to List of Deal Product Wrapper
                    for(OpportunityLineItem dealPro :lstDealProduct){
                        if(mapProdIdLstDealProd.containsKey(dealPro.Product2Id)){
                            mapProdIdLstDealProd.get(dealPro.Product2Id).add(new DealProdWrapper(dealPro));
                        }else{
                            DealProdWrapper dealProdWrap = new DealProdWrapper(dealPro);
                            List<DealProdWrapper> tempDealProdWraps = new List<DealProdWrapper>();
                            tempDealProdWraps.add(dealProdWrap);
                            
                            mapProdIdLstDealProd.put(dealPro.Product2Id, tempDealProdWraps);
                        }  
                    }
                    //Assign Promoted Price of Deal Product to the Last Promoted Price for the product.
                    //Use sort method to compare the scenarios for Last Promoted price
                    for(ID productId :mapProdIdLstDealProd.keySet()){
                        DealProdWrapper[] listDealProductWraps = mapProdIdLstDealProd.get(productId);
                        listDealProductWraps.sort();
                        
                        if(!listDealProductWraps.isEmpty()) {
                            mapProdIdPromoPrice.put(productId, listDealProductWraps[0].dealProd.Promoted_Price__c);
                        }
                    } 
                    
                    for (ID productId : lstProductIds) {
                        
                        CRM_DataObjects.ProductItem  dealPro =new CRM_DataObjects.ProductItem();
                        dealPro.productId =productId;
                        if(!mapThreeMonthOrderHistory.isEmpty() && mapThreeMonthOrderHistory.containskey(productId) && mapThreeMonthOrderHistory.get(productId) != null){
                            AggregateResult ag= mapThreeMonthOrderHistory.get(productId);
                            dealPro.threeMonthOrderHistory = (Decimal)ag.get('quantityDealProduct'); 
                        } 
                        if(!mapProdIdPromoPrice.isEmpty() && mapProdIdPromoPrice.containskey(productId)){
                            dealPro.lastPromotedPrice =mapProdIdPromoPrice.get(productId);
                            
                        }  
                        items.add(dealPro);
                    }
                }//end if
                prodWrapper.products =  items;
                prodWrapper.maxLimitExceeded = CRM_AddProductsHelper.showErrorMsg;
          }catch(Exception ex) {
            // Error Logging
            system.debug('Exception ::::::::::::'+ex);
            CRM_ErrorLogger.ErrorLog errlog = new CRM_ErrorLogger.ErrorLog();
            //errlog.recordId = dealIds[0];
            errlog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_ADD_PRODUCTS; // 
            errlog.lineNumber =  String.valueOf(ex.getLineNumber());
            errlog.errorMessage = ex.getMessage();
            errlog.stackTrace = ex.getStackTraceString();
            CRM_ErrorLogger.logError(errlog); 
            throw new CRM_AddOpportunityProductsException(ex.getMessage());
        }  
        system.debug('prodWrapper:::::::::::::::::::'+prodWrapper);
        return prodWrapper; 
    }
    //US#253 ends 
    
    /**
     *  This method will save deal related product 
     *  @name saveProducts
     *  @param Id opportunityId, List<CRM_DataObjects.ProductItemSave> products
     *  @return List<CRM_DataObjects.ProductItem>
     *  @throws None
     */
    
    @RemoteAction
    static global void saveProducts(Id opportunityId, List<CRM_DataObjects.ProductItemSave> products) {
        try {
            // Get all current products
            List<OpportunityLineItem> currentItems = [SELECT Id, PricebookEntryId, Quantity
                                                      FROM OpportunityLineItem
                                                      WHERE OpportunityId = :opportunityId];

            // Build a map with priue book entry id as key
            Map<Id, OpportunityLineItem> currentItemsMap = new Map<Id, OpportunityLineItem>();
            System.debug('currentItemsMap::'+currentItemsMap);
            for (OpportunityLineItem x : currentItems) {
                currentItemsMap.put(x.PricebookEntryId, x);
            }

            // Run through list of records to update and track the upsert records
            List<OpportunityLineItem> toUpsert = new List<OpportunityLineItem>();
            List<OpportunityLineItem> toDelete = new List<OpportunityLineItem>();

            for (CRM_DataObjects.ProductItemSave x : products) {
                System.debug('x::'+x);
                if (currentItemsMap.containsKey(x.pricebookEntryId)) {
                    OpportunityLineItem foundItem = currentItemsMap.get(x.pricebookEntryId);
                    System.debug('foundItem::'+foundItem);
                    // Change to quantity on existing product
                    if (x.quantity == null || x.quantity == 0) {
                        toDelete.add(foundItem);
                    }
                    else if (foundItem.Quantity != x.quantity) {
                        foundItem.Quantity = x.quantity;
                        toUpsert.add(foundItem);
                    }
                }
                else if (x.quantity != null && x.quantity > 0)
                {
                    x.listPrice = x.listPrice == null ? 0 : x.listPrice;
                    // New product to add
                    toUpsert.add(new OpportunityLineItem(
                        OpportunityId = opportunityId,
                        PricebookEntryId = x.pricebookEntryId,
                        Quantity = x.quantity,
                        UnitPrice = x.listPrice,
                        listPrice__c = x.listPrice,
                        discount = 0
                    ));
                }
            }
            System.debug('toUpsert Size::'+toUpsert.size());
            System.debug('toUpsert::'+toUpsert);
            // Commit changes
            upsert toUpsert;
            delete toDelete;
        }catch(System.DMLException e){
           for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                throw new CRM_AddOpportunityProductsException(e.getDmlMessage(i));
            }
        }catch(Exception ex) {
            // Error Logging
            CRM_ErrorLogger.ErrorLog errlog = new CRM_ErrorLogger.ErrorLog();
            //errlog.recordId = dealIds[0];
            errlog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_ADD_PRODUCTS; // 
            errlog.lineNumber =  String.valueOf(ex.getLineNumber());
            errlog.errorMessage = ex.getMessage();
            errlog.stackTrace = ex.getStackTraceString();
            CRM_ErrorLogger.logError(errlog);
            
            throw new CRM_AddOpportunityProductsException(ex.getMessage());
        }
    }
    
       
    global class DealProdWrapper implements Comparable {
        global OpportunityLineItem dealProd; 
        
        global DealProdWrapper(OpportunityLineItem dealProd) {
            this.dealProd = dealProd;
        }
        
        global Integer compareTo(Object compareToSobj) {
            DealProdWrapper compareTo = (DealProdWrapper) compareToSobj;
             // put on top as larger object 
            if( this.dealProd.Opportunity.CloseDate > compareTo.dealProd.Opportunity.CloseDate
                || (this.dealProd.Opportunity.CloseDate == compareTo.dealProd.Opportunity.CloseDate 
                && CRM_AddOpportunityProductsController.mapDealPriority.get(this.dealProd.Opportunity.Deal_Priority__c)> CRM_AddOpportunityProductsController.mapDealPriority.get(compareTo.dealProd.Opportunity.Deal_Priority__c))
                    || (this.dealProd.Opportunity.CloseDate == compareTo.dealProd.Opportunity.CloseDate 
                    && mapDealPriority.get(this.dealProd.Opportunity.Deal_Priority__c) == mapDealPriority.get(compareTo.dealProd.Opportunity.Deal_Priority__c)
                    && this.dealProd.Opportunity.Overlapping_Deal_Counter__c > compareTo.dealProd.Opportunity.Overlapping_Deal_Counter__c))
            {
                return -1;  // Descending Sort
            } 
            
            return 1;
        } 
    }
    
     global class CRM_AddOpportunityProductsException extends Exception {}
}