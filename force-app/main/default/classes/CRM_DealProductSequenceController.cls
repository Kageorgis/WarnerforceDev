public with sharing class CRM_DealProductSequenceController {
    
    public static void executeBeforeInsert(List<OpportunityLineItem> lstNewDealProducts) {
        // This will calculate Cost of Product on OpportunityLineItem
        new CRM_DealProductCOPHandler().calculateCOP(lstNewDealProducts);
        
        //US#33 - Neha
        CRM_UpdateDealProductPricing pricingCtrl = new CRM_UpdateDealProductPricing();
        pricingCtrl.updateDealProductPrices(null, lstNewDealProducts);
        //US#33 - Neha
        
        //US #581: Populate Consignment Multiplier on Deal Product: Merged the logic in the same method
        //US#501 - Neha 
        CRM_DealProductHandler dealProductHandler = new CRM_DealProductHandler();
        dealProductHandler.updateRoyaltyFeesFields(lstNewDealProducts);
        //US#501 - Neha 
        
        //US#172
        dealProductHandler.updatePriceTierOnDealProduct(lstNewDealProducts,null);

        //Calculate the Total Wholesale Cost
        WBSF_CalculateTotalWholesaleCost.CalculateTotalWholesaleCost(null, lstNewDealProducts);
    }
    
    public static void executeBeforeUpdate(Map<Id,OpportunityLineItem> mapOldDealProducts, Map<Id,OpportunityLineItem> mapNewDealProducts) {
        //US#33 - Neha
        CRM_UpdateDealProductPricing pricingCtrl = new CRM_UpdateDealProductPricing();
        pricingCtrl.updateDealProductPrices(mapOldDealProducts, mapNewDealProducts.values());
        //US#33 - Neha
        
        //CRM_GenerateProductDecayCurve.deleteExistingSchedules(mapOldDealProducts, mapNewDealProducts.values());
        //US#172
        CRM_DealProductHandler dealProductHandler = new CRM_DealProductHandler();
        dealProductHandler.updatePriceTierOnDealProduct(mapNewDealProducts.values(),mapOldDealProducts);

        //Calculate the Total Wholesale Cost
        WBSF_CalculateTotalWholesaleCost.CalculateTotalWholesaleCost(mapOldDealProducts, mapNewDealProducts.values());
    }

    public static void executeAfterInsert(Map<Id,OpportunityLineItem> mapOldDealProducts, Map<Id,OpportunityLineItem> mapNewDealProducts) {
        //CRM_AutoEstablishSchedulesHelper.isrecursion = true;
        CRM_AutoEstablishSchedulesHelper.executeDealProductScheduling(mapOldDealProducts, mapNewDealProducts.values(), true);
        CRM_DealProductHandler dealProductHandler = new CRM_DealProductHandler();
        dealProductHandler.scheduleHandler(mapOldDealProducts, mapNewDealProducts);
    }

    public static void executeAfterUpdate(Map<Id,OpportunityLineItem> mapOldDealProducts, Map<Id,OpportunityLineItem> mapNewDealProducts) {
        CRM_AutoEstablishSchedulesHelper.executeDealProductScheduling(mapOldDealProducts, mapNewDealProducts.values(), false);
        CRM_DealProductHandler dealProductHandler = new CRM_DealProductHandler();
        dealProductHandler.scheduleHandler(mapOldDealProducts, mapNewDealProducts);
    }
    
    public static void executeAfterDelete(Map<Id,OpportunityLineItem> mapOldDealProducts) {
        CRM_DealProductHandler dealProductHandler = new CRM_DealProductHandler();
        dealProductHandler.markDeletedDealItems(mapOldDealProducts);
    }
    
     /** 
    *  US : 929 : US Games 
    *  @description: - This method is used to validate Deal Products before delete.
    *  @name: executeBeforeDelete
    *  @return: void
    */ 
    public static void executeBeforeDelete(Map<Id,OpportunityLineItem> mapOldDealProducts){
        CRM_DealProductHandler.restrictToDeleteDealProductsLinkedWithCNI(mapOldDealProducts);
    }
    
}