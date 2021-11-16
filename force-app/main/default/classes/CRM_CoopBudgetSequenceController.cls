/**
   @Author-Cognizant Technology Solutions
   @name-CRM_CoopBudgetSequenceController 
   @CreateDate- 23 Nov 2017
   @Description- This class is used to call handler CRM_CoopBudgetHandler methods
   @Version-1.0
   @reference-None
*/
public with sharing class CRM_CoopBudgetSequenceController {
    
    public static void executeAfterInsert(Map<Id,Coop_Budget__c > mapNewCoopBudgets) {
        CRM_CoopBudgetHandler.upsertDealAndDealProducts(null,mapNewCoopBudgets);
    }
    
    public static void executeAfterUpdate(Map<Id,Coop_Budget__c > mapOldCoopBudgets, Map<Id,Coop_Budget__c > mapNewCoopBudgets) {
        CRM_CoopBudgetHandler.upsertDealAndDealProducts(mapOldCoopBudgets,mapNewCoopBudgets);
    }
}