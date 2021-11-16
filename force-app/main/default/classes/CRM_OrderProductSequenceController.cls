public with sharing class CRM_OrderProductSequenceController {
    
    public static void executeBeforeInsert(List<OrderItem> lstNewOrderProducts) {
        // This will calculate Cost of Product on OpportunityLineItem
        CRM_UpdateOrderProductPricing pricingCtrl = new CRM_UpdateOrderProductPricing();
        pricingCtrl.updateAccountPrice(null, lstNewOrderProducts);
        System.debug('Order Pricing Called ---');
        //FR Requirement : 455
        pricingCtrl.allowVRACConfigProduct(lstNewOrderProducts); 
    }
    
    public static void executeBeforeUpdate(Map<Id,OrderItem> mapOldOrderProducts, Map<Id,OrderItem> mapNewOrderProducts) {
        /********************************************************** Pricing Module ***************************************************/
        CRM_UpdateOrderProductPricing pricingCtrl = new CRM_UpdateOrderProductPricing();
        pricingCtrl.updateAccountPrice(mapOldOrderProducts.values(),mapNewOrderProducts.values());
    }
    
    /*public static void executeAfterInsert(Map<Id,OrderItem> mapOldDealProducts, Map<Id,OrderItem> mapNewDealProducts) {
       
    }
    
    public static void executeAfterUpdate(Map<Id,OrderItem> mapOldDealProducts, Map<Id,OrderItem> mapNewDealProducts) {
        
    }*/
    
    /**
     *  @Description - US. #476 (JAPAN): Update Quantity of parentOrder's orderProduct when childOrder is deleted.
     *  @name - updateParentOrderQuantityRollup
     *  @param - oldOrders - list of toBeDeleted Order Old values,oldOrderItems - if orderproduct is manually deleted
     *  @return - void
     **/ 
    public static void executeBeforeDelete(List<OrderItem> lstOldOrderItem){
        List<Id> lstOrderId = new List<Id>();
        for(OrderItem oi : lstOldOrderItem){
            lstOrderId.add(oi.OrderId);
        }
        List<Order> lstOrder = new List<Order>();
        if(!lstOrderId.isEmpty()){
            System.debug('lstOrder is this'+lstOrderId);
            lstOrder = [Select Id,Multi_Order__C,AccountId from Order where id in :lstOrderId and Multi_order__c !=null];
        }
        if(!lstOrder.isEmpty()){
            //Setting AccountId as null so that the Account Sequence method is not called.
            for(Order ord : lstOrder){
                ord.AccountId=null;
            }
            CRM_OrderHandler.updateParentOrderQuantityRollup(lstOrder,lstOldOrderItem);
        }
        
    }
}