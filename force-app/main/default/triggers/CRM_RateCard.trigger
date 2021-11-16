/**
   @Author-Cognizant Technology Solutions
   @name-CRM_RateCardHandler
   @CreateDate- 17 April 2018
   @Description- This class is used to call SequenceController CRM_RateCardSequenceController methods
   @Version-1.0
   @reference-None
*/
trigger CRM_RateCard on Rate_Card__c (before insert,before update,after update) {
    
    if (CRM_ApplicationUtility.runningUser != null && CRM_ApplicationUtility.runningUser.size() > 0 && CRM_ApplicationUtility.runningUser[0].ByPassValidationRule__c){
        return;
    }

    if(Trigger.isBefore && Trigger.isInsert) {
        CRM_RateCardSequenceController.executeBeforeInsert(trigger.new);
    }

    if(Trigger.isBefore && Trigger.isUpdate) {
       CRM_RateCardSequenceController.executeBeforeUpdate(trigger.oldMap,trigger.newMap);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {
       WB_RateCardHelper.updatePBEPs(trigger.newMap,trigger.oldMap);
    }
}