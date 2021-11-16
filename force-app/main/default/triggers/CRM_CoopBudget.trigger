/** 
* Author: cognizant Team
* Description: This trigger is used to call methods from Handllers to Upert Deal Product and Deal after creation of Budgets
* Date Created:  23 Nov 2017
* Version: 1   
*/
trigger CRM_CoopBudget on Coop_Budget__c (after insert,after update) {
     //List<User> runningUser = [SELECT ByPassValidationRule__c FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1];
    if (CRM_ApplicationUtility.runningUser != null && CRM_ApplicationUtility.runningUser.size() > 0 && CRM_ApplicationUtility.runningUser[0].ByPassValidationRule__c){
        System.debug('#@#@#@# Bypassing the trigger.');
        return;
    }

    CRM_Trigger_Switches_For_ON_OFF__c objCustomSettingTriggerSwitch = CRM_Trigger_Switches_For_ON_OFF__c.getInstance('CRM_DealProduct');       
    if ( (objCustomSettingTriggerSwitch != null && !objCustomSettingTriggerSwitch.IsActive__c)  ) 
        return;
    
    if(Trigger.isAfter && Trigger.isInsert) {
        CRM_CoopBudgetSequenceController.executeAfterInsert(trigger.newMap);
    }

    if(Trigger.isAfter && Trigger.isUpdate) {
       CRM_CoopBudgetSequenceController.executeAfterUpdate(trigger.oldMap,trigger.newMap);
    }
}