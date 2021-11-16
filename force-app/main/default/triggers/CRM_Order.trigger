/** 
   * Author: cognizant Team
   * Description: This trigger is used to call methods from Handllers on update of ordres
   * Date Created:  22 Jul 2016
   * Version: 0.1 
   */
trigger CRM_Order on Order (before insert, before update, after update,before delete,after delete) { 

    CRM_Trigger_Switches_For_ON_OFF__c objCustomSettingTriggerSwitch = CRM_Trigger_Switches_For_ON_OFF__c.getInstance('CRM_Order');       
    
    if ( (objCustomSettingTriggerSwitch != null && !objCustomSettingTriggerSwitch.IsActive__c)  ) { 
        return;
    }

    if(trigger.isBefore && trigger.isInsert){
        CRM_OrderSequenceController.executeBeforeInsert(trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate) {
        CRM_OrderSequenceController.executeBeforeUpdate(trigger.oldMap, trigger.newMap);
    }
    
    /*Requirement 476*/
    if(Trigger.isBefore && Trigger.isDelete) {
         CRM_OrderSequenceController.executeBeforeDelete(trigger.old);
    }
    /*Requirement 476 End*/
    
    /*
    if(Trigger.isAfter && Trigger.isInsert) {
    }*/
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        CRM_OrderSequenceController.executeAfterUpdate(trigger.oldMap, trigger.new);
    }

}