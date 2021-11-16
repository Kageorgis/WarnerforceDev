/**
   @Author Cognizant
   @name CRM_ConfigTrigger
   @CreateDate 8 June 2016
   @Description Trigger on Config__c object
   @Version <1.0>
*/
trigger CRM_ConfigTrigger on Config__c (before insert, after insert, after update) {
    
    if(trigger.isInsert && trigger.isBefore) {
       CRM_ConfigTgrSequenceController.beforeInsert(trigger.new);
    }
    
    if(trigger.isInsert && trigger.isAfter) {
	   CRM_ConfigTgrSequenceController.afterInsert(trigger.old, trigger.new);
    }
    
    if(trigger.isUpdate && trigger.isAfter) {
	   CRM_ConfigTgrSequenceController.afterUpdate(trigger.old, trigger.new); 
    }
}