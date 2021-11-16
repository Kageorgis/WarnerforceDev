/**
   @Author Cognizant
   @name CRM_EditAllOppProductsCtrl
   @CreateDate 12 Nov 2015
   @Description This class will be use to edit the deal products.
   @Version <1.0>
   @reference Requirement no 35
*/

global with sharing class CRM_EditAllOrderProductsCtrl{
    public Order order {get;set;}
    public Boolean IsOrderHighLevelReturn{get;set;}
    public Boolean IsSBOMConfig{get; set;}
    public Integer decimalPlaces{get; set;}
    
    public Id orderId {get; set;}
    public CRM_EditAllOrderProductsCtrl(ApexPages.Standardcontroller stdCon) {
        orderId = stdCon.getId();
        system.debug('orderId----++----'+orderId);
        orderId = ApexPages.currentPage().getParameters().get('ordId');
        system.debug('orderId--------'+orderId);
        
        
        if (orderId != null) {
            List<Order> lstOrder =
                [SELECT Id, Account.Sales_Organization__c, Account.Digital_Country_Code__c, AccountId,OrderNumber,RecordTypeId,Config__c,Config__r.RecordTypeId FROM Order WHERE Id = :orderId];
            if (!lstOrder.isEmpty()) {
                order = lstOrder[0];
                IsSBOMConfig = (Order.Config__c != null && Order.Config__r.RecordTypeId == CRM_RecordTypeUtil.RT_CONFIG_SBOM) ? true : false;
                IsOrderHighLevelReturn = (order.RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_HIGH_LEVEL_RETURN) ? true : false; 
                Boolean isJapanTerritory = (
                    (lstOrder[0].Account.Sales_Organization__c == CRM_AppConstants.TERRITORY_JAPAN_CODE)
                    ||
                    (lstOrder[0].Account.Digital_Country_Code__c == CRM_AppConstants.ACCOUNT_JP_DIGITAL_COUNTRY_CODE)
                );
                if (isJapanTerritory) {
                    decimalPlaces = 0;
                } else {
                    decimalPlaces = 2;
                }
            }
        }               
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
    }    

    /**
     * Method to get logged in uSer Locale
     */
    global String getUserLocale() {
        /*String currentUserLocale = UserInfo.getLocale();
        System.debug( '-before--UserInfo.getLocale()-->'+currentUserLocale);
        currentUserLocale = currentUserLocale.contains('_') ? currentUserLocale.replace( '_', '-') : 'en-US';
        System.debug( '-after--UserInfo.getLocale()-->'+currentUserLocale.toLowerCase());
        return currentUserLocale.toLowerCase();*/
        String currentUserLocale = UserInfo.getLocale();
        System.debug( '-before--UserInfo.getLocale()-->'+currentUserLocale);
        if (currentUserLocale.contains('_')) {
            currentUserLocale = currentUserLocale.replace( '_', '-');
        }

        /*if (currentUserLocale.contains('en-')) {
            currentUserLocale = currentUserLocale.substringBefore('-');
        }*/
        System.debug( '-after--UserInfo.getLocale()-->'+currentUserLocale);
        return currentUserLocale;
    }

    global String getUserLocaleLowerCase() {
        String currentUserLocale = UserInfo.getLocale();
        System.debug( '-before--UserInfo.getLocale()-->'+currentUserLocale);
        currentUserLocale = currentUserLocale.contains('_') ? currentUserLocale.replace( '_', '-') : 'en-US';
        System.debug( '-after--UserInfo.getLocale()-->'+currentUserLocale.toLowerCase());
        return currentUserLocale.toLowerCase();
    }

    /**
     *  Method to fetch the Order Product from OrderId which is called from EditProductsCtrl.js 
     *  @name getLineItems
     *  @param Id orderId
     *  @return CRM_DataObjects.ProductToEdit[]
     *  @throws None
     */
    
    @RemoteAction 
    global static ProductToEdit[] getLineItems(Id orderId) {
        ProductToEdit[] listProducts = new ProductToEdit[]{};
        
        for(OrderItem orderProduct : [select Id,OrderId,Order.Config__r.RecordTypeId,Order.Config__c,Order.OrderNumber,ListPrice,Quantity,UnitPrice,PricebookEntryId,Total_Quantity__c,Total_Price__c,
                                 Pricebookentry.Product2Id,Pricebookentry.Product2.Name,Pricebookentry.ProductCode,currencyISOCode,toLabel(Pricebookentry.Product2.Product_Format__c)
                                 from OrderItem where OrderId =:orderId]) {
            system.debug('orderProduct----'+orderProduct);
            ProductToEdit prod = new ProductToEdit();
            
            
            //prod.totalPrice = orderProduct.UnitPrice * orderProduct.Quantity;
            prod.totalPrice = (orderProduct.Order.Config__r.RecordTypeId == CRM_RecordTypeUtil.RT_CONFIG_SBOM && orderProduct.Order.Config__c != null) ? orderProduct.Total_Price__c: (orderProduct.UnitPrice * orderProduct.Quantity);
            
            prod.OrderName = orderProduct.Order.OrderNumber;
            system.debug('prod.OrderName-----'+prod.OrderName); 
            prod.lineItemId = orderProduct.Id;
            system.debug('prod.lineItemId----'+prod.lineItemId); 
            prod.pricebookEntryId = orderProduct.PricebookEntryId; 
            prod.productId = orderProduct.Pricebookentry.Product2.Id;
            prod.productName = orderProduct.Pricebookentry.Product2.Name;
            prod.productCode = orderProduct.Pricebookentry.ProductCode;
            prod.productFormat = orderProduct.Pricebookentry.Product2.Product_Format__c;//US#617
            prod.totalQty = (orderProduct.Order.Config__c != null && orderProduct.Order.Config__r.RecordTypeId == CRM_RecordTypeUtil.RT_CONFIG_SBOM) ? orderProduct.Total_Quantity__c : orderProduct.Quantity;
            system.debug('prod.totalQty----'+prod.totalQty); 
            prod.listPrice = orderProduct.ListPrice; // list price calculated from Pricebook Entry Period Object
            prod.UnitPrice = orderProduct.UnitPrice; 
            system.debug('prod.UnitPrice----'+prod.UnitPrice); 
            prod.currencyCode = orderProduct.currencyISOCode; 
            prod.dealOrorderId = orderProduct.OrderId;    
            
            prod.isSelected = false;
            listProducts.add(prod);
        }

        return listProducts;
    }
    
    /**
     *  Method to update the Deal Product on a Deal based on changes made on Edit All Products page
     *  @name saveLineItems
     *  @param Id opportunityId, List<CRM_DataObjects.ProductToEdit> products, Boolean quickSave
     *  @return CRM_DataObjects.ProductToEdit[]
     *  @throws None
     */
    
    @RemoteAction
    static global ProductToEdit[] saveLineItems(Id orderId, List<ProductToEdit> products, Boolean quickSave) {
    
    List<Order> orderList = [Select Id,Status,ActivatedDate From Order Where Id =:orderId];
    
    // Get all current products
    Map<Id,OrderItem> mapCurrentOrderProducts = new Map<Id,OrderItem>([SELECT Id
                              FROM OrderItem
                              WHERE OrderId =:orderId]);
                              
    // Build a map for OpportunityLineItemSchedule with PriceBookEntryId as key
    //Map<Id, List<OpportunityLineItemSchedule>> mapCurrentOrderProductsSchedule = new Map<Id, List<OpportunityLineItemSchedule>>();
    
    // Run through list of records to update and track the upsert records
    List<OrderItem> lstDealProducttoUpsert = new List<OrderItem>();
    List<OrderItem> lstDealProducttoDelete = new List<OrderItem>();
    
    System.debug('mapCurrentOrderProducts----' +mapCurrentOrderProducts);
    System.debug('products----' + products);
    
        for (ProductToEdit x : products) {
        if (mapCurrentOrderProducts.containsKey(x.lineItemid)) {
        OrderItem orderProduct = mapCurrentOrderProducts.get(x.lineItemid);
        
            //if (x.totalQty == null || x.totalQty == 0) {
            if (x.isDelete != null && x.isDelete == true) {
                lstDealProducttoDelete.add(orderProduct);
            }
    
            else{
            System.debug('in else----');

            orderProduct.Quantity = x.totalQty;
            
            lstDealProducttoUpsert.add(orderProduct);
            
                }
            }
    
        }
    // Commit changes
        Savepoint sp = Database.setSavepoint();
            try{
            System.debug('lstDealProducttoUpsert----' + lstDealProducttoUpsert);
            if(lstDealProducttoUpsert != null && !lstDealProducttoUpsert.isEmpty()){
            upsert lstDealProducttoUpsert;
                }
        
            if(lstDealProducttoDelete != null && !lstDealProducttoDelete.isEmpty()){
            System.debug('orderList----' + orderList);
                if(orderList.size() > 0 && orderList.get(0).ActivatedDate != null){
                    throw new CRM_EditProductsException(Label.CRM_Upload_Message_ActiveOrder);
                } 
                delete lstDealProducttoDelete;
            }
        
            }catch(System.DMLException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {
            Database.rollback(sp);
            // Process exception here
            throw new CRM_EditProductsException(e.getDmlMessage(i));
                }   
            }catch(Exception e){
        System.debug('in exception ----' + e.getMessage());
        Database.rollback(sp);
        throw new CRM_EditProductsException(e.getMessage());
        }
        
            if(quickSave){
                return getLineItems(OrderId);
            }else{
               return null;
            }
        }
    /**
     *  This method returns list of Order Products for particular UPC / Material Number
     *  @name addLineItems
     *  @param Id orderId, CRM_DataObjects.SearchFilters filters
     *  @return List<OpportunityLineItem>
     *  @throws None
     */
    @RemoteAction
    static global ProductToEdit[] addLineItems(Id orderId, CRM_DataObjects.SearchFilters filters) {
        // Get all current products
        List<CRM_DataObjects.ProductItem> lstProductItems = new List<CRM_DataObjects.ProductItem>();
        List<Order> lstOrders = [Select id, EffectiveDate, AccountId, CurrencyIsoCode, Account.Sales_Organization__c, Pricebook2Id, EndDate, 
                            Sales_Organisation__c, Account.Revenue_share__c, RecordTypeId, Opportunity.Market_Type__c, OpportunityId,
                            Account.Price_Book__r.Country__c,//Defect#4461 - added account.pricebook.contry field in query
                            (Select id, Quantity,UnitPrice ,Pricebookentry.Product2Id ,Pricebookentry.Product2.productCode from OrderItems) 
                            from Order 
                            where Id =:orderId limit 1];
        //Run through list of records to update and track the upsert records
        List<OrderItem> lstOrderProducttoUpsert = new List<OrderItem>();
        if(!lstOrders.isEmpty()){
            //Build a map for OpportunityLineItem with PriceBookEntryId as key
            Map<Id, OrderItem> mapCurrentOrderProducts = new Map<Id, OrderItem>();
            for (OrderItem x : lstOrders[0].OrderItems) {
                mapCurrentOrderProducts.put(x.PricebookEntryId, x);
            }
            lstProductItems = searchProductForDealorOrder(lstOrders, filters);
            if(lstProductItems.isEmpty()){
                throw new CRM_EditProductsException(Label.CRM_No_Product_found_label);
            }
            for (CRM_DataObjects.ProductItem x: lstProductItems) {
                if (mapCurrentOrderProducts.containsKey(x.pricebookEntryId)) {
                    throw new CRM_EditProductsException(Label.CRM_Product_already_found_label);
                }
                else{
                    x.listPrice = x.listPrice == null ? 0 : x.listPrice;
                    // New product to add
                    lstOrderProducttoUpsert.add(new OrderItem(
                        OrderId = orderId,
                        PricebookEntryId = x.pricebookEntryId,
                        Quantity = 1,
                        UnitPrice = x.listPrice,
                        List_Price__c = x.listPrice
                    ));
                }
            }
            // Commit changes
            Savepoint sp = Database.setSavepoint();
            try{
                if(lstOrderProducttoUpsert != null && !lstOrderProducttoUpsert.isEmpty()){
                    upsert lstOrderProducttoUpsert;
                }
            }catch(System.DMLException e){
               for (Integer i = 0; i < e.getNumDml(); i++) {
                    Database.rollback(sp);
                    // Process exception here
                    throw new CRM_EditProductsException(e.getDmlMessage(i));
                }
            }catch(Exception e){
                Database.rollback(sp);
                CRM_ErrorLogger.ErrorLog err = new CRM_ErrorLogger.ErrorLog();
                throw new CRM_EditProductsException(e.getMessage());
            }
        }
        return getLineItems(orderId);
    }
    static List<CRM_DataObjects.ProductItem> searchProductForDealorOrder(List<Order> lstOrders, CRM_DataObjects.SearchFilters filters){
       List<CRM_DataObjects.ProductItem> lstProductItemsFetched = new List<CRM_DataObjects.ProductItem>();
       CRM_DataObjects.ParentRecord dealOrOrder = new CRM_DataObjects.ParentRecord();
            dealOrOrder.currencyCode = lstOrders[0].CurrencyIsoCode;
            dealOrOrder.startDate = lstOrders[0].EffectiveDate;
            dealOrOrder.endDate = lstOrders[0].EndDate;
            dealOrOrder.accountId = lstOrders[0].AccountId;
            // DEF#4143 : Moved filtering code from controller to AddProductsHelper
            dealOrOrder.recordType = CRM_AppConstants.ORDER_OBJECT;
            dealOrOrder.orderRecord = lstOrders[0];
            filters.fullMatchMaterialNumber = true;
            lstProductItemsFetched = CRM_AddProductsHelper.searchProducts(dealOrOrder, lstOrders[0].Pricebook2Id, filters);
         return lstProductItemsFetched;
    }
    public class CRM_EditProductsException extends Exception {
    }
    global class ProductToEdit {
    
        global Boolean isSelected;
        global Boolean isDelete = false;
        global Boolean isDirtyRow;
        global Id lineItemId;
        global Id productId;
        global Id dealOrOrderId;
        global Id pricebookEntryId;
        global String productName;
        global String productCode;
        global String productFormat;//US#617
        global Double listPrice;
        global Double totalQty;
        global String currencyCode;
        global String startDate;
        global Double UnitPrice;
        global Double WeekReleaseDate; //NewFieldAdded for EditOrderProduct
        global String LineDescription; //NewFieldAdded for EditOrderProduct
        global String OrderName;  //NewFieldAdded for EditOrderProduct
        global Double totalPrice;  //NewFieldAdded for EditOrderProduct
        global Double totalCOP;   //NewFieldAdded for EditOrderProduct
        
        global Map<String, Boolean> inValidFormatMap = new Map<String, Boolean>();
        public ProductToEdit(){
        }   
    }
  
 
 
}