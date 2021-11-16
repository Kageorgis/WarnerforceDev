/** 
 * Author: Tushar
 * Description: Trigger to update Checkboxes based on Custom setting (Used in approval process)
 * Date Created: 25th Oct 2016
 * Version: 1
 */
trigger CRM_Request on Request__c (before insert, before update){
    CRM_Trigger_Switches_For_ON_OFF__c objCustomSettingTriggerSwitch = CRM_Trigger_Switches_For_ON_OFF__c.getInstance('CRM_CountryPlan'); {
    if (objCustomSettingTriggerSwitch != null && !objCustomSettingTriggerSwitch.IsActive__c)
        return;
    }

    if(Trigger.isBefore && Trigger.isInsert){
        CRM_RequestSequenceController.executeBeforeInsert(trigger.new);
    }

    if(Trigger.isBefore && Trigger.isUpdate){
        CRM_RequestSequenceController.executeBeforeUpdate(trigger.new, trigger.oldMap);
    }

    /*if(Trigger.isBefore && Trigger.isDelete) {
    }

    if(Trigger.isAfter && Trigger.isDelete) {
    }

    if(Trigger.isAfter && Trigger.isInsert) {
    }

    if(Trigger.isAfter && Trigger.isUpdate) {
    }*/
}