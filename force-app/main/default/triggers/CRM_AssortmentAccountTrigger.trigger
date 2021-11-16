/** 
   * Author: Cognizant Team
   * Description: This Trigger is used to call methods from the handllers.
   * Date Created:  20 September 2016
   * Version: 1.0   
   */
trigger CRM_AssortmentAccountTrigger on Assortment_Account__c(before insert, before update, before delete, after insert, after update, after delete){

    if(Trigger.isBefore && Trigger.isDelete) {
        CRM_AssortmentAccountSequenceController.executeBeforeDelete(Trigger.OldMap);
    }
}