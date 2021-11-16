public with sharing class CRM_OrderSequenceController {
    
    
    
    public static void executeBeforeInsert(List<Order> lstNewOrders) {
        //Avoid a set of field from getting cloned
        CRM_OrderHandler.dontClone(lstNewOrders); 
        // set Account's pricebook as default order pricebook on insert 
        //Defect#4106 - added extra null parameter in methd call 
        CRM_OrderHandler.updatePricebookOnOrder(lstNewOrders,null);
    }
    
    public static void executeBeforeUpdate(Map<Id,Order> mapOldOrders, Map<Id,Order> mapNewOrders) {
        // set Account's pricebook as default order pricebook on insert   
        //Defect#4106 - added extra oldmap parameter in methd call
        CRM_OrderHandler.updatePricebookOnOrder(mapNewOrders.values(),mapOldOrders);
    }
    
    
    public static void executeAfterUpdate(Map<Id,Order> mapOldOrders, List<Order> lstNewOrders) {

        // Generate PDF an attach to the corresponding order
        CRM_OrderHandler.attachPDF(mapOldOrders,lstNewOrders);
        
        //Update Custom Total Price of Related Order Products for SBOM Order
        CRM_OrderHandler.updateCustomTotalPriceOfOP(mapOldOrders,lstNewOrders);
        
        //US-476(JAPAN) When Activate Parent order activate all its Child orders 
        system.debug(CRM_AppConstants.orderActivateFlag);
        if(CRM_AppConstants.orderActivateFlag){
            CRM_OrderHandler.activateAllChildOrders(mapOldOrders,lstNewOrders);
            //US#590 (JAPAN)
            CRM_OrderHandler.updateReturnApprovalStatusOfAllChildOrders(mapOldOrders,lstNewOrders);
        }
            
        //Defect#4019 (Japan US 590)
        CRM_OrderHandler.submitReturnOrMultiReturnOrderForApproval(mapOldOrders,lstNewOrders);
    }
    
    public static void executeBeforeDelete(List<Order> oldOrders){
        CRM_OrderHandler.deleteChildOrder(oldOrders);
        CRM_OrderHandler.updateParentOrderQuantityRollup(oldOrders,null);
    }
}