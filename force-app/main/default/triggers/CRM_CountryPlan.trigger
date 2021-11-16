/** 
 * Author: Anupama & Aditi Satpute
 * Description: Trigger to create / update Account Plan records based on Account Split Template added in Country Plan
 * Date Created: 17th March 2016
 * Version: 1
 */
trigger CRM_CountryPlan on Country_Plan__c (after insert, after update) {
    CRM_Trigger_Switches_For_ON_OFF__c objCustomSettingTriggerSwitch = CRM_Trigger_Switches_For_ON_OFF__c.getInstance('CRM_CountryPlan'); {
    if (objCustomSettingTriggerSwitch != null && !objCustomSettingTriggerSwitch.IsActive__c)
        return;
    }

    /*if(Trigger.isBefore && Trigger.isInsert) {
    }

    if(Trigger.isBefore && Trigger.isUpdate) {
    }

    if(Trigger.isBefore && Trigger.isDelete) {
    }

    if(Trigger.isAfter && Trigger.isDelete) {
    }*/

    if(Trigger.isAfter && Trigger.isInsert) {
      CRM_CountryPlanSequenceController.executeAfterInsert(trigger.oldMap, trigger.newMap);
    }

    if(Trigger.isAfter && Trigger.isUpdate) {
       CRM_CountryPlanSequenceController.executeAfterUpdate(trigger.oldMap, trigger.newMap);
    }
}