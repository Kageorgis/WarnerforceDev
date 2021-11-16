/**
   @Author Cognizant
   @name CRM_AddOrderProductsController
   @CreateDate 24 Nov 2016
   @Description This class will be use to edit the orders.
   @Version <1.0>
   @reference Requirement no TODO
*/


global with sharing class CRM_AddOrderProductsController {
    
    /**
     *  Constructor
     *  @name CRM_AddOrderProductsController
     *  @param ApexPages.Standardcontroller stdCon
     *  @return None
     *  @throws None
     */
    public Id ordrId;
    public boolean isItaly{get; set;} //US#788
    
    public CRM_AddOrderProductsController (ApexPages.Standardcontroller stdCon) {
        List<Order> lstOrder =new List<Order>();
        ordrId = stdCon.getId();
        isItaly =false;//US#788
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
        //US#788 UNBW products visible only to Italy starts
        if(ordrId!=null){
            lstOrder = [SELECT id, EffectiveDate,Sales_Organisation__c, Account.Sales_Organization__c, EndDate,RecordTypeId
                                FROM Order WHERE Id =:ordrId LIMIT 1];
    }
        if(!lstOrder.isEmpty()){ 
            isItaly= (lstOrder[0].Sales_Organisation__c == CRM_AppConstants.TERRITORY_ITALY_CODE); 
        }                           
        //US#788 UNBW products visible only to Italy end
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
    
    /*global Boolean isUKSalesOrgOrder {
        get {
            list<Order> lstordr = [Select id, EffectiveDate, AccountId, CurrencyIsoCode, Account.Sales_Organization__c 
                          from Order 
                          where Id =:ordrId limit 1];
            if(!lstordr.isEmpty()) {
                if(lstordr[0].Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_UK_CODE) {
                    return true;
                }
            }
            return false;
        }
    }*/

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
     *  @param String object_name
     *  @param String field_name
     *  @param String first_val
     *  @return CRM_DataObjects.PicklistOption[]
     *  @throws None
     */
    
    @RemoteAction 
    global static CRM_DataObjects.PicklistOption[] getFilterPicklistValues(String object_name, String field_name, String first_val) {
      return CRM_AddProductsHelper.getFilterPicklistValues(object_name, field_name, first_val);
    }
    
    /**
     *  This method returns order related product 
     *  @name getProducts
     *  @param Id opportunityId
     *  @param Id pricebookId
     *  @param CRM_DataObjects.SearchFilters filters
     *  @return List<CRM_DataObjects.ProductItem>
     *  @throws None
     */
    
    @RemoteAction 
    global static CRM_DataObjects.ProductWrapper getProducts(Id orderId, Id pricebookId, CRM_DataObjects.SearchFilters filters) {
        // Commented - DEF#4143 : Moved filtering code from controller to AddProductsHelper
        /*//Order Products Filter Flag for "Standard" RT
        boolean orderProductFilterFlag = false;
         //Order Products Filter Flag for "Rev Share" RT
        boolean orderProductFilterForRevShareFlag = false;
        //US#570 - Order product filter for 'RETURN'RT for FR
        boolean orderProductFilterForReturnFRFlag = false;
        
        // DEF#4114
        Boolean returnOrderProductFilterFlag = false;

        // 01 =Active , 04 =On Hold & 11=Initial
        Set<String> distChainProdStatus = new Set<String>{'01','04','11'};
        
        // 04=Active , 02=Released for 3rd Party & 05=Sell-down/Sell-Off
        Set<String> sAPDistChainProductStatus = new Set<String>{'04','02','05'};
        
        // DEF#4114
        Set<String> distChainProdStatusForReturns =
            new Set<String>{
                CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_NON_RETURNABLE_Z5,
                CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_NON_RETURNABLE_05
            };
        */
        CRM_DataObjects.ProductWrapper prodWrapper = new CRM_DataObjects.ProductWrapper();
        try{
            if(CRM_Functional_Permissions__c.getInstance().Prevent_Add_Products__c) {
                throw new CRM_UploadOrderProductsController.MyCustomException(Label.CRM_Deal_Entry_NoAccessError);
            }
            //CRM_DataObjects.ProductWrapper prodWrapper = new CRM_DataObjects.ProductWrapper();
            List<CRM_DataObjects.ProductItem> items = new List<CRM_DataObjects.ProductItem>();
            // Commented - DEF#4143 : Moved filtering code from controller to AddProductsHelper
            //List<CRM_DataObjects.ProductItem> filteredItems = new List<CRM_DataObjects.ProductItem>();
             
            List<Order> lstOrder = [Select id, EffectiveDate,Config__c, AccountId, CurrencyIsoCode, Account.Sales_Organization__c, EndDate,RecordTypeId,
                                        Account.Revenue_share__c,Sales_Organisation__c,OpportunityId,Opportunity.Market_Type__c,createdDate,Account.Price_Book__r.Country__c,//Defect#4363 added variable 'Account.Price_Book__r.Country__c' in query
                                        (SELECT PricebookEntryId, Quantity FROM OrderItems) 
                                        from Order 
                                        where Id =:orderId limit 1];
            if(!lstOrder.isEmpty() && lstOrder[0].Config__c !=null){
                throw new CRM_UploadOrderProductsController.MyCustomException(Label.CRM_AddOrderProduct_ErrorMessage);
            }
            // Commented - DEF#4143 : Moved filtering code from controller to AddProductsHelper
            /*if(!lstOrder.isEmpty() ){
                if(lstOrder[0].RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_STANDARD)
                    orderProductFilterFlag = true;
                else if(lstOrder[0].Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE  
                   && lstOrder[0].Account.Revenue_share__c == true && lstOrder[0].RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_REV_SHARE
                   && (lstOrder[0].OpportunityId == NULL || (lstOrder[0].OpportunityId != NULL &&
                    lstOrder[0].Opportunity.Market_Type__c == CRM_AppConstants.DEAL_RENTAL_MARKET_TYPE))
                ) {
                    orderProductFilterForRevShareFlag = true; 
                }
                if (
                        lstOrder[0].Sales_Organisation__c == CRM_AppConstants.TERRITORY_JAPAN_CODE &&
                        (orderProductFilterFlag || orderProductFilterForRevShareFlag)
                ) {
                    sAPDistChainProductStatus.add(CRM_AppConstants.PRODUCT_PLANT_STATUS_INITIAL);
                }
                // DEF#4114
                if (lstOrder[0].RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_RETURN) {
                    returnOrderProductFilterFlag = true;

                //US#570 - flag set to true for FR orders with 'RETURN' record type.
                    if(lstOrder[0].Sales_Organisation__c == CRM_AppConstants.TERRITORY_FRANCE_CODE){
                        orderProductFilterForReturnFRFlag = true;
                }    
             }
             }*/
                
                                    
            if(!lstOrder.isEmpty()) {
                CRM_DataObjects.ParentRecord dealOrOrder = new CRM_DataObjects.ParentRecord();
                dealOrOrder.salesOrg = lstOrder[0].Account.Sales_Organization__c;
                dealOrOrder.currencyCode = lstOrder[0].CurrencyIsoCode;
                dealOrOrder.startDate = lstOrder[0].EffectiveDate;
                dealOrOrder.accountId = lstOrder[0].AccountId;
                dealOrOrder.endDate = lstOrder[0].EndDate;
                //DEF#4143 : Moved filtering code from controller to AddProductsHelper
                dealOrOrder.recordType = CRM_AppConstants.ORDER_OBJECT;
                dealOrOrder.orderRecord = lstOrder[0];

                // First grab a list of current items and quantities
                Map<Id, OrderItem> currentItems = new Map<Id, OrderItem>();
        
                for (OrderItem x : lstOrder[0].OrderItems) {
                    currentItems.put(x.PricebookEntryId, x);
                }

                Date startDate = lstOrder[0].EffectiveDate;
                items = CRM_AddProductsHelper.searchProducts(dealOrOrder, pricebookId, filters);
                
                for(CRM_DataObjects.ProductItem p: items) {
                    if (currentItems.containsKey(p.pricebookEntryId)) {
                        p.quantity = (Integer)currentItems.get(p.pricebookEntryId).Quantity;
                    }
                    // Commented - DEF#4143 : Moved filtering code from controller to AddProductsHelper
                    /*if(
                            orderProductFilterFlag && distChainProdStatus.contains(p.sAPDistChainProductStatus) && sAPDistChainProductStatus.contains(p.plantSpecificMaterialStatus)
                    ) {
                        filteredItems.add(p);
                    } else if(orderProductFilterForRevShareFlag 
                            && distChainProdStatus.contains(p.sAPDistChainProductStatus) 
                            && sAPDistChainProductStatus.contains(p.plantSpecificMaterialStatus)
                            && p.productMarket == CRM_AppConstants.PRODUCT_RENTAL_MARKET_TYPE
                    ){
                         filteredItems.add(p);
                    } 
                    //US#570 - flag for FR orders with 'REUTURN' record type.
                    // DEF#4114
                    else if(returnOrderProductFilterFlag) {
                        if(orderProductFilterForReturnFRFlag) {
                           if((p.releaseDate==null || p.releaseDate >= lstOrder[0].createdDate) && !distChainProdStatusForReturns.contains(p.sAPDistChainProductStatus)){ 
                               filteredItems.add(p);
                           }
                        } else if (!distChainProdStatusForReturns.contains(p.sAPDistChainProductStatus)) {
                            filteredItems.add(p);
                        }
                    }*/
                }
            }
            system.debug('Items: '+items.size());
            //system.debug('filteredItems : '+filteredItems.size());
            //US#570 - additional condition in the filteredItems 'orderProductFilterForReturnFRFlag'.
            // Commented - DEF#4143 : Moved filtering code from controller to AddProductsHelper
            // DEF#4114
            /*if(orderProductFilterFlag || orderProductFilterForRevShareFlag || returnOrderProductFilterFlag){ //|| orderProductFilterForReturnFRFlag
                prodWrapper.products = filteredItems;
            }else{*/
                prodWrapper.products = items;
            //}
            prodWrapper.maxPageCount = CRM_AddProductsHelper.maxPageCount;
            prodWrapper.maxLimitExceeded = CRM_AddProductsHelper.showErrorMsg;
            System.debug('prodWrapper::::'+prodWrapper);
        }catch(SearchException ex){ //SINC1370739 filter added to display error message in japanese
            if(ex.getMessage().contains('search term must be longer than one character:')){
                throw new CRM_UploadOrderProductsController.MyCustomException(Label.CRM_search_text_more_than_1); 
            }
        }  
        return prodWrapper; 
    }
    
    /**
     *  This method will save order related product 
     *  @name saveProducts
     *  @param Id opportunityId
     *  @param List<CRM_DataObjects.ProductItemSave> products
     *  @return List<CRM_DataObjects.ProductItem>
     *  @throws None
     */
    
    @RemoteAction
    static global void saveProducts(Id orderId, List<CRM_DataObjects.ProductItemSave> products) {
        // Get all current products
        List<OrderItem> currentItems = [SELECT Id, PricebookEntryId, Quantity FROM OrderItem WHERE OrderId = :orderId];

        // Build a map with priue book entry id as key
        Map<Id, OrderItem> currentItemsMap = new Map<Id, OrderItem>();

        for (OrderItem x : currentItems) {
            currentItemsMap.put(x.PricebookEntryId, x);
        }

        // Run through list of records to update and track the upsert records
        List<OrderItem> toUpsert = new List<OrderItem>();
        List<OrderItem> toDelete = new List<OrderItem>();

        for (CRM_DataObjects.ProductItemSave x : products) {
            if (currentItemsMap.containsKey(x.pricebookEntryId)) {
                OrderItem foundItem = currentItemsMap.get(x.pricebookEntryId);

                // Change to quantity on existing product
                if (x.quantity == null || x.quantity == 0) {
                    toDelete.add(foundItem);
                }else if (foundItem.Quantity != x.quantity) {
                    foundItem.Quantity = x.quantity;
                    toUpsert.add(foundItem);
                }
            }else if (x.quantity != null && x.quantity > 0){
                x.listPrice = x.listPrice == null ? 0 : x.listPrice;
                
                // New product to add
                toUpsert.add(new OrderItem(
                    OrderId = orderId,
                    PricebookEntryId = x.pricebookEntryId,
                    Quantity = x.quantity,
                    //UnitPrice = x.listPrice, Commented so that Unit Price will be set through Order Prod trigger.
                    List_Price__c = x.listPrice
                ));
            }
        }
        // Commit changes
        //Defect#4404 : Added try catch block to show error on page properly.
        try{
            upsert toUpsert;
            delete toDelete; 
        }catch(System.DmlException ex){
            throw new CRM_AddOrderProductsControllerException(ex.getDmlMessage(0));
        }
        
        //upsert toUpsert;
        //delete toDelete;
    }
    //Defect#4404 : added exception class to catch exception
    public class CRM_AddOrderProductsControllerException extends Exception {}
}