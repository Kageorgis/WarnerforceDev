public with sharing class CRM_PricingSequenceController {
 
    /*public static void executeBeforeInsert(List<Pricing__c> lstNewPricingObj) {
    }
    
    public static void executeBeforeUpdate(Map<Id,Pricing__c> mapOldPricingObj, Map<Id,Pricing__c> mapNewPricingObj) {
    }
    
    public static void executeAfterInsert(Map<Id,Pricing__c> mapOldPricingObj, Map<Id,Pricing__c> mapNewPricingObj){
    }*/
    
    public static void executeAfterUpdate(Map<Id,Pricing__c> mapOldPricingObj, Map<Id,Pricing__c> mapNewPricingObj) {
         CRM_PricingHandler handlerInstance = new CRM_PricingHandler();
         handlerInstance.UpdateClientAvailOnPricingChanged(mapOldPricingObj, mapNewPricingObj);
    }  
    
    /*public static void executeAfterDelete(Map<Id,Pricing__c> mapOldPricingObj, Map<Id,Pricing__c> mapNewPricingObj) {       
    }  */
}