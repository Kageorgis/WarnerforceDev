/** 
   * Author: cognizant Team
   * Description: This trigger is used to call methods from Handllers on update of product
   * Date Created:  17 feb 2016
   * Version: 0.1 
   */
trigger CRM_Product on Product2 (before Insert,after insert,after update,after delete,before update, before delete) {


    CRM_Trigger_Switches_For_ON_OFF__c objCustomSettingTriggerSwitch = CRM_Trigger_Switches_For_ON_OFF__c.getInstance('CRM_Product');       
    if ( (objCustomSettingTriggerSwitch != null && !objCustomSettingTriggerSwitch.IsActive__c)  ) 
        return;

    if(Trigger.isBefore && Trigger.isInsert) {  
         CRM_ProductSequenceController.executeBeforeInsert(trigger.new);    
    }
    
    if(Trigger.isBefore && Trigger.isUpdate) {
        CRM_ProductSequenceController.executeBeforeUpdate(trigger.oldMap, trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isDelete) {
    }
    
    if(Trigger.isAfter && Trigger.isInsert) {
         CRM_ProductSequenceController.executeAfterInsert(trigger.oldMap,trigger.new);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        CRM_ProductSequenceController.executeAfterUpdate(trigger.oldMap, trigger.new);
    }
    
    if(Trigger.isAfter && Trigger.isDelete) {

    } 

}