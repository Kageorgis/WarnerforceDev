/**
   @Author-Cognizant Technology Solutions
   @name-CRM_UpdateOrderProductPricing
   @CreateDate-<Date>
   @Description-The class is used to calculates the Account Price on Deal Product using applicable List Price and Discount Percentage.
   @Description-CRM_ProductPricingHandler methods are called to fetch the applicable discount percentage and list price
   @Version-1.0
   @reference-None
*/
public with sharing class CRM_UpdateOrderProductPricing{

    public void updateAccountPrice(OrderItem[] oldOrderProducts, OrderItem[] newOrderProducts) {
        OrderItem[] listImpactedOrderProducts = new OrderItem[]{};
        Map<Id,OrderItem> mapOldOrderItem = new Map<Id,OrderItem>();
        
        if(oldOrderProducts!= null && oldOrderProducts.size()>0){
            for (OrderItem oItem : oldOrderProducts){
                mapOldOrderItem.put(oItem.Id,oItem);
            }
        }
        
        for(OrderItem oItem : newOrderProducts) {
            if(oldOrderProducts== null || oldOrderProducts.size() == 0 || mapOldOrderItem.get(oItem.Id).List_Price__c  != oItem.List_Price__c){
                listImpactedOrderProducts.add(oItem);
            }
        }

        if(!listImpactedOrderProducts.isEmpty()) {  
            updateOrderProductPrices(listImpactedOrderProducts);            
        }
    }
    /**
        *  @Description - The method prepares a (map) collection of Deal Id and the Information of Deal
        *  @name - getOrders
        *  @return - return a collection of Deal Id and Deal Information
    */
    private Map<Id,Order> getOrders(OrderItem[] orderProds) {
        Map<Id,Order> mapOrder = new Map<Id,Order>();
         
        for(OrderItem oItem : orderProds) {
            if(oItem.OrderId !=Null){
                mapOrder.put(oItem.OrderId,null);
            }
        }
        
        mapOrder = new Map<Id,Order>([select Id, EffectiveDate, Pricebook2Id, CurrencyISOCode, AccountId, EndDate
                        from Order
                        where Id IN: mapOrder.keySet()]);
                        
        return mapOrder;
    }
    /**
        *  @Description - The method prepares a (map) collection of Deal Id and the Information of Deal
        *  @name - getOrderItemProduct
        *  @return - return a collection of Deal Id and Deal Information
    */
    private Map<Id,PricebookEntry> getOrderItemProduct(OrderItem[] orderProds) {
        Map<Id,PricebookEntry> mapOrderItemsProduct = new Map<Id,PricebookEntry>();
         
        for(OrderItem oItem : orderProds) {
            mapOrderItemsProduct.put(oItem.PriceBookEntryId,null);
        }
        
        mapOrderItemsProduct = new Map<Id,PricebookEntry>([Select Product2Id,Product2.Return_End_Date__c from PricebookEntry
                        where Id IN: mapOrderItemsProduct.keySet()]);
                        
        return mapOrderItemsProduct;
    }
    /**
        *  @Description - The method prepares a (map) collection of Deal Id and the Information of Deal
        *  @name - updateAccountPrice
        *  @return - sets the Account Price on Deal Product
    */
    public void updateAccountPrice(CRM_ProductPricingHandler.DealWrapper[] listOrderWrappers) {
        if(!listOrderWrappers.isEmpty()){
            CRM_ProductPricingHandler instance = new CRM_ProductPricingHandler(listOrderWrappers);
            for(CRM_ProductPricingHandler.DealWrapper dw : listOrderWrappers) {            
                dw.orderProduct.Account_Price__c = instance.getAccountPrice(dw);
                dw.orderProduct.List_Price__c  = instance.getProductDatedListPrice(dw);
               if(dw.orderProduct.UnitPrice == null){
                   dw.orderProduct.UnitPrice  =  dw.orderProduct.Account_Price__c;//instance.getProductDatedListPrice(dw);
               }
            } 
        } 
    }

    /**
    *  @Description - This method prepares data specific to Costing and invokes the related functionality.
    *  @name - CRM_OrderProductPricing
    *  @return - Method created to invoke the HandlerClasses from outside without using the trigger
    **/
    public void updateOrderProductPrices(List<OrderItem> lstOrderProduct){
        CRM_ProductPricingHandler.DealWrapper[] listOrderWrappers = new CRM_ProductPricingHandler.DealWrapper[]{};
        Map<Id,Order> mapOrders = getOrders(lstOrderProduct);
        Map<Id,PriceBookEntry> mapOrderItemsProduct = getOrderItemProduct(lstOrderProduct);
        
        for(OrderItem oItem : lstOrderProduct){
            if(oItem.OrderId !=Null){
                CRM_ProductPricingHandler.DealWrapper dw = new CRM_ProductPricingHandler.DealWrapper();
                dw.dealId = oItem.OrderId;
                dw.accountId = mapOrders.get(oItem.OrderId).AccountId;
                dw.dealCurrency = mapOrders.get(oItem.OrderId).CurrencyISOCode;
                dw.productId = mapOrderItemsProduct.get(oItem.PriceBookEntryId).Product2Id;
                dw.pricebookId = mapOrders.get(oItem.OrderId).Pricebook2Id;
                dw.dealStartDate = mapOrders.get(oItem.OrderId).EffectiveDate;
                dw.dealEndDate = mapOrders.get(oItem.OrderId).EndDate;
                dw.orderProduct = oItem;
                listOrderWrappers.add(dw);
            }               
        }
        
        if(!listOrderWrappers.isEmpty()){            
            //Call to constructor.
           updateAccountPrice(listOrderWrappers);
        }
    } 
    
   /**
        *  @FR Requirement : 455
        *  @Description - The method allows user to add Product for VRAC Configs. And allow only those products 
                          Which are present on that particular Config
        *  @name - allowVRACConfigProduct
        *  @return - nothing, but generate exception (Not allowing ant other product to get added.)
        
    */
    
    public void allowVRACConfigProduct(List<OrderItem> lstOrderProduct){
        Set<Id> orderIds = new Set<Id>();
        Set<Id> configIds = new Set<Id>();
        Map<Id,PriceBookEntry> mapOrderItemsProduct = getOrderItemProduct(lstOrderProduct);
        Map<Id,Id> mapOrdertoConfig = new Map<Id,Id>();
        System.debug('PricebookEntry Map ============>'+ mapOrderItemsProduct);
        System.debug('List of Order Product =============>'+ lstOrderProduct);
        for(OrderItem odrItem : lstOrderProduct){
          if(odrItem.OrderId!= null){
              orderIds.add(odrItem.OrderId);
          }
        }
        System.debug('Order Ids ================>'+ orderIds);
        if(null != orderIds && !orderIds.isEmpty()){
            for(Order odr: [SELECT Config__c FROM Order WHERE Id in: orderIds]){
                if(odr.Config__c != null){
                    configIds.add(odr.Config__c);
                    mapOrdertoConfig.put(odr.Id,odr.Config__c);
                }
            }
        }
        System.debug('Config Ids =====================>'+ configIds);
        
        if(null != configIds && !configIds.isEmpty()){
             //List of all the Config Products Whose Config Id is in Set.
             List<Config_Product__c > lstConfigProduct = [SELECT Config__c,Product__c FROM Config_Product__c WHERE Config__c in :configIds];
             //Map of Config Along with list of all Config Products on that Config   
             Map<String, Id> mapConfigToConfigProdList = new Map<String, Id>();
             
             if(lstConfigProduct !=null && lstConfigProduct.size()!=0){
                 for(Config_Product__c confProd : lstConfigProduct){
                     String mapUniqueKey = confProd.Config__c +'-'+ confProd.Product__c;
                     System.debug('mapUnqueKey ===============>'+mapUniqueKey );
                        mapConfigToConfigProdList.put(mapUniqueKey,confProd.Product__c);
                 }//End of For Loop
             }//End of If Condition
             
             system.debug('Config to Config Product map ==============>'+ mapConfigToConfigProdList);
            
             //Check Whether the selected Product is added on the Config or Not
         try{
             for(OrderItem odrItem : lstOrderProduct){
                 String mapUniqueKey = mapOrdertoConfig.get(odrItem.OrderId) +'-'+ mapOrderItemsProduct.get(odrItem.PriceBookEntryId).Product2Id ;
                 System.debug('mapUniqueKey Check ================>' + mapUniqueKey);
                 if(!mapConfigToConfigProdList.containsKey(mapUniqueKey )){
                     throw new MyException ();
                 }
             }//End of For loop
           }
           
         Catch (Exception e)
         {
            for(OrderItem odrItem : lstOrderProduct){
                 String mapUniqueKey = mapOrdertoConfig.get(odrItem.OrderId) +'-'+ mapOrderItemsProduct.get(odrItem.PriceBookEntryId).Product2Id ;
                 if(!mapConfigToConfigProdList.containsKey(mapUniqueKey )){
                     odrItem.addError(System.Label.CRM_OrderProductCheck);
                 }
            }//End of For loop
         }
                 
        }//End of Outer If Condition
        
    }//End of Function
    
    /*Custom Exception Class*/
    public class MyException extends Exception {}

}