/** 
   * Author: cognizant Team
   * Description: This trigger is used to call methods from Handllers on update of price book entry period
   * Date Created:  11 mar 2016
   * Version: 0.1 
   */
trigger CRM_PriceBookEntryPeriod on Pricebook_Entry_Period__c (before Insert,after insert,after update,after delete,before update, before delete) {

    //List<User> runningUser = [SELECT ByPassValidationRule__c FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1];
    if (CRM_ApplicationUtility.runningUser != null && CRM_ApplicationUtility.runningUser.size() > 0 && CRM_ApplicationUtility.runningUser[0].ByPassValidationRule__c){
        System.debug('#@#@#@# Bypassing the trigger.');
        return;
    }
    System.debug('#### User allowed to run through the trigger');

    CRM_Trigger_Switches_For_ON_OFF__c objCustomSettingTriggerSwitch = CRM_Trigger_Switches_For_ON_OFF__c.getInstance('CRM_PriceBookEntryPeriod');       
    if ( (objCustomSettingTriggerSwitch != null && !objCustomSettingTriggerSwitch.IsActive__c)  ) 
        return;

    if(Trigger.isBefore && Trigger.isInsert) {
        CRM_PBEPSequenceController.executeBeforeInsert(trigger.new);
    }

    /*if(Trigger.isBefore && Trigger.isUpdate) {
    }*/

    if(Trigger.isBefore && Trigger.isDelete) {
    }

    if(Trigger.isAfter && Trigger.isInsert) {
        CRM_PBEPSequenceController.executeAfterInsert(trigger.oldMap, trigger.newMap);
    }

    if(Trigger.isAfter && Trigger.isUpdate) {
        CRM_PBEPSequenceController.executeAfterUpdate(trigger.oldMap, trigger.newMap);
    }

    if(Trigger.isAfter && Trigger.isDelete) {
    } 

}