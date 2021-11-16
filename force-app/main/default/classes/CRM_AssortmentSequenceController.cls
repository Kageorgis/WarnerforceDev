public with sharing class CRM_AssortmentSequenceController{
 
    public static void executeBeforeInsert(list<Bundle__c> newAssrt) {
        CRM_AssortmentValidationHandler handler = new CRM_AssortmentValidationHandler();
        //Added "oldAssrt" Parameter for US : 814
        handler.updateDefaultPricingAccount(newAssrt,null);
    }
    
    public static void executeBeforeUpdate(Map<Id, Bundle__c> oldAssrt, List<Bundle__c> newAssrt) {
        CRM_AssortmentValidationHandler.validateStatusForUpdate(oldAssrt, newAssrt);
        CRM_AssortmentValidationHandler handler = new CRM_AssortmentValidationHandler();
         //Added "oldAssrt" Parameter for US : 814
        handler.updateDefaultPricingAccount(newAssrt,oldAssrt);
    }
    
    public static void executeAfterInsert(Map<Id,Bundle__c > mapOldAssortments, Map<Id,Bundle__c > mapNewAssortments){
         CRM_GenerateAssortementAccount.prepareAssortmentAccount(mapOldAssortments, mapNewAssortments);
    }
    
    public static void executeAfterUpdate(Map<Id,Bundle__c > mapOldAssortments, Map<Id,Bundle__c > mapNewAssortments) {
         CRM_GenerateAssortementAccount.prepareAssortmentAccount(mapOldAssortments, mapNewAssortments);
         //Cancel opportunities if the parent assortment status is changed to cancel
         CRM_CancelAssortementDeals.cancelAssortementOpportunity(mapOldAssortments, mapNewAssortments);
         //Publish logic on assortment approval #defect 3529
         CRM_AssortmentValidationHandler.publishAssortmentOnApproval(mapOldAssortments,mapNewAssortments.values());
    }  
    
    /*public static void executeAfterDelete(Map<Id,Country_Plan__c> mapOldCountryPlans, Map<Id,Country_Plan__c> mapNewCountryPlans) {       
    }  */
    
    public static void executeBeforeDelete(List<Bundle__c> oldAssrt) {
        // Stop user from Deleting Assortment
        CRM_AssortmentValidationHandler.deleteAssortmentError(oldAssrt);
    }
}