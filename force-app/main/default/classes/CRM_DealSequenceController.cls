public with sharing class CRM_DealSequenceController {
    
    public static void executeBeforeInsert(Opportunity[] lstNewDeals) {

        // update deal code
        CRM_DealHandler handler = new CRM_DealHandler();
        handler.clearDealCode(lstNewDeals);
        handler.updateDealFromAccount(lstNewDeals);
        //Germany Credit Not Req
        handler.UpdateDealBudget(null,lstNewDeals);
        //Update Owner Department Field
        WBSF_FillOwnerDepartment.UpdateOwnerDepartment(null, lstNewDeals);
    }
    
    public static void executeBeforeDelete(Map<Id, Opportunity> mapOldDeals) {
        CRM_DealHandler handlerInstance = new CRM_DealHandler();
        handlerInstance.deleteDealError(mapOldDeals);
    }
    
    public static void executeBeforeUpdate(Map<Id,Opportunity> mapOldDeals,Map<Id,Opportunity> mapNewDeals) {
        CRM_DealHandler handlerInstance = new CRM_DealHandler();
        // US#490 - Method call to update Deal Product group of deal.
        handlerInstance.UpdateDealProductGroupOnDeal(mapOldDeals,mapNewDeals);
        //Germany Credit Not Req
        handlerInstance.UpdateDealBudget(mapOldDeals,mapNewDeals.values());
        //Update Owner Department Field
        WBSF_FillOwnerDepartment.UpdateOwnerDepartment(mapOldDeals, mapNewDeals.values());
    }
    
    public static void executeAfterInsert(List<Opportunity> newlstOpty) {
      // FR_US#277 Shange Starts: Auto add owner as deal follower
      CRM_DealHandler.autoCreateRecordFollower(null, newlstOpty);    
      // FR_US#277 Shange Ends
    }
    
    public static void executeAfterUpdate(Map<Id,Opportunity> mapOldDeals,Map<Id,Opportunity> mapNewDeals) {

        CRM_DealHandler dealHandlerInstance = new CRM_DealHandler();
        
        // update line items for committed deals
        dealHandlerInstance.updateLineItemsForCommittedDeals(mapOldDeals,mapNewDeals);
        
        dealHandlerInstance.updateDealProducts(mapOldDeals,mapNewDeals);

        // FR_US#277 Shange Starts: Auto add owner as deal follower
        CRM_DealHandler.autoCreateRecordFollower(mapOldDeals, mapNewDeals.values());
        // FR_US#277 Shange Ends  
    }
}