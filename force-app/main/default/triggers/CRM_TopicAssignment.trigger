/** 
   * Author: cognizant Team
   * Description: This trigger is used to call methods from Handllers to udpate Topics__c field on Local Data object
   * Date Created: 24 Nov 2015
   * Version: 0.2   
   */
trigger CRM_TopicAssignment on TopicAssignment (after insert, after update, after delete) {

    //List<User> runningUser = [SELECT ByPassValidationRule__c FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1];
    if (CRM_ApplicationUtility.runningUser != null && CRM_ApplicationUtility.runningUser.size() > 0 && CRM_ApplicationUtility.runningUser[0].ByPassValidationRule__c){
        System.debug('#@#@#@# Bypassing the trigger.');
        return;
    }
    System.debug('#### User allowed to run through the trigger');

     CRM_Trigger_Switches_For_ON_OFF__c objCustomSettingTriggerSwitch = CRM_Trigger_Switches_For_ON_OFF__c.getInstance('CRM_TopicAssignment');    
  if (objCustomSettingTriggerSwitch != null && !objCustomSettingTriggerSwitch.IsActive__c)
    return;             
    
    if(Trigger.isBefore && Trigger.isInsert) {      
    }
    
    if(Trigger.isBefore && Trigger.isUpdate) {
    }
    
    if(Trigger.isBefore && Trigger.isDelete) {
    }
    
    if(Trigger.isAfter && Trigger.isInsert) {
      CRM_TopicAssignmentSequenceController.executeAfterInsert(trigger.oldMap, trigger.newMap);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {
    }
    
    if(Trigger.isAfter && Trigger.isDelete) {
      CRM_TopicAssignmentSequenceController.executeAfterDelete(trigger.oldMap, trigger.newMap);
    }
}