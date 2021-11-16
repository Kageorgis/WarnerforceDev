/** 
   * Author: cognizant Team
   * Description: This trigger is used to call methods from Handllers.
   * Date Created:  08 June 2016
   * Version: 0.4   
   */
trigger CRM_Assortment on Bundle__c (before Insert,after insert,after update,after delete,before update, before delete) {

    CRM_Trigger_Switches_For_ON_OFF__c objCustomSettingTriggerSwitch = CRM_Trigger_Switches_For_ON_OFF__c.getInstance('CRM_Assortment');    
    if (objCustomSettingTriggerSwitch != null && !objCustomSettingTriggerSwitch.IsActive__c)
    return;  
    
    if(Trigger.isBefore && Trigger.isInsert) {
        CRM_AssortmentSequenceController.executeBeforeInsert(trigger.new);      
    }
    
    if(Trigger.isBefore && Trigger.isUpdate) {
        CRM_AssortmentSequenceController.executeBeforeUpdate(trigger.oldMap, trigger.new);     
    }
    
    if(Trigger.isBefore && Trigger.isDelete) {
        // Stop user from Deleting Assortment
        CRM_AssortmentSequenceController.executeBeforeDelete(trigger.old);
    }
    
    if(Trigger.isAfter && Trigger.isInsert) {
      CRM_AssortmentSequenceController.executeAfterInsert(trigger.oldMap, trigger.newMap);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {
       CRM_AssortmentSequenceController.executeAfterUpdate(trigger.oldMap, trigger.newMap);
    }
    
    if(Trigger.isAfter && Trigger.isDelete) {
      
    }
}