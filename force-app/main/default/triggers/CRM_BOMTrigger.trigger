/**
   @Author Cognizant
   @name CRM_BOMTrigger
   @CreateDate 18 June 2016
   @Description Trigger on BOM__c object
   @Version <1.0>
*/
trigger CRM_BOMTrigger on BOM__c (after insert, after update, before delete) {
    if (trigger.isAfter && trigger.isInsert) {
       CRM_BOMTriggerSequenceController.executeAfterInsert(trigger.newMap);
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        CRM_BOMTriggerSequenceController.executeAfterUpdate(trigger.newMap,trigger.oldMap);
    }
    
    if (trigger.isBefore && trigger.isDelete) {
         CRM_BOMTriggerSequenceController.executeBeforeDelete(trigger.oldMap);   
    }
    
}