public with sharing class CRM_TargetSequenceController {
    
    public static void executeBeforeInsert(List<Target__c> lstNewTargets) {
        CRM_TargetHandler.updateFormatOnTarget(lstNewTargets); //added to update Target format field
		CRM_TargetHandler.createTempEAD(lstNewTargets); // added for ER-003346
    }
    
    public static void executeBeforeUpdate(List<Target__c> lstNewTargets) {
        CRM_TargetHandler.updateFormatOnTarget(lstNewTargets); //added to update Target format field
    }
    
    public static void executeAfterDelete(Map<Id, Target__c> mapOldTargets, Map<Id, Target__c> mapNewTargets) {
        CRM_TargetSequenceController.updatePublishedTargetOnAccountPlan(mapOldTargets, mapNewTargets);
    }
    
    public static void executeAfterInsert(Map<Id, Target__c> mapOldTargets, Map<Id, Target__c> mapNewTargets) {
        CRM_TargetSequenceController.updatePublishedTargetOnAccountPlan(mapOldTargets, mapNewTargets);
        CRM_UpdateTargetAccountHandler.updateAccount(mapOldTargets, mapNewTargets);  //added to update scheduleRevenueChanged on Account
    }
    
    public static void executeAfterUpdate(Map<Id, Target__c> mapOldTargets, Map<Id, Target__c> mapNewTargets) {
        CRM_TargetSequenceController.updatePublishedTargetOnAccountPlan(mapOldTargets, mapNewTargets);
        CRM_UpdateTargetAccountHandler.updateAccount(mapOldTargets, mapNewTargets);   //added to update scheduleRevenueChanged on Account
    }
    
    public static void updatePublishedTargetOnAccountPlan(Map<Id, Target__c> mapOldTargets, Map<Id, Target__c> mapNewTargets){
         CRM_TargetHandler objTargetHandler = new CRM_TargetHandler();
         objTargetHandler.updateTargetAccountPlan(mapOldTargets, mapNewTargets);
    }
}