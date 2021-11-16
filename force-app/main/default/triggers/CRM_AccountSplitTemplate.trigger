/** 
 * Author: Cognizant
 * Description: Trigger to update Account Split Template records
 * Date Created: 20th July 2017
 * Version: 1
 */
trigger CRM_AccountSplitTemplate on Target_Split_Template__c (before update) {
	CRM_Trigger_Switches_For_ON_OFF__c objCustomSettingTriggerSwitch = CRM_Trigger_Switches_For_ON_OFF__c.getInstance('CRM_CountryPlan'); {
    if (objCustomSettingTriggerSwitch != null && !objCustomSettingTriggerSwitch.IsActive__c)
        return;
    }
    if(Trigger.isBefore && Trigger.isUpdate) {
    	CRM_AccountSplitTemplateSequenceCtrl.executeBeforeUpdate(trigger.newMap,trigger.oldMap);
    }
}