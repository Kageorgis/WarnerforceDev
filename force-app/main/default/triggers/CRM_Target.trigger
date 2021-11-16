trigger CRM_Target on Target__c (before Insert,after insert,after update,after delete,before update, before delete) {
  
    /*if (CRM_ApplicationUtility.runningUser != null && CRM_ApplicationUtility.runningUser.size() > 0 && CRM_ApplicationUtility.runningUser[0].ByPassValidationRule__c){
        System.debug('#@#@#@# Bypassing the trigger.');
        return;
    }
    System.debug('#### User allowed to run through the trigger');*/


    CRM_Trigger_Switches_For_ON_OFF__c objCustomSettingTriggerSwitch = CRM_Trigger_Switches_For_ON_OFF__c.getInstance('CRM_Target');       
    if ( (objCustomSettingTriggerSwitch != null && !objCustomSettingTriggerSwitch.IsActive__c)  ) 
        return;


    if(Trigger.isBefore && Trigger.isInsert) {      
    	CRM_TargetSequenceController.executeBeforeInsert(trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate) {
    	CRM_TargetSequenceController.executeBeforeUpdate(trigger.new);		
    }
    
    if(Trigger.isBefore && Trigger.isDelete) {
    }
    
    if(Trigger.isAfter && Trigger.isInsert) {
        CRM_TargetSequenceController.executeAfterInsert(trigger.oldmap,trigger.newmap);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {
       CRM_TargetSequenceController.executeAfterUpdate(trigger.oldmap,trigger.newmap);
    }
    
    if(Trigger.isAfter && Trigger.isDelete) { 
        CRM_TargetSequenceController.executeAfterDelete(trigger.oldmap,trigger.newmap);
    } 
}