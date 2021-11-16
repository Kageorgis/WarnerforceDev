/**
   @Author-Cognizant Technology Solutions
   @name-CRM_RateCardSequenceController 
   @CreateDate- 17 April 2018
   @Description- This class is used to call handler CRM_RateCardHandler methods
   @Version-1.0
   @reference-None
*/
public with sharing class CRM_RateCardSequenceController {
    
    public static void executeBeforeInsert(List<Rate_Card__c> newRCLists) {
        CRM_RateCardHandler.ValidateOverlapping(null,newRCLists);
    }
    
    public static void executeBeforeUpdate(Map<Id,Rate_Card__c > mapOldRCs, Map<Id,Rate_Card__c > mapNewRCs) {
        CRM_RateCardHandler.ValidateOverlapping(mapOldRCs,mapNewRCs.values());
    }
}