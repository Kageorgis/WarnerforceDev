/** 
   * @Author: cognizant Team
   * @Description: This trigger is used to call methods of Handlers 
   * @Date Created:  03 March 2017
   * @Version: 1.0 
   */

trigger CRM_CreditNoteTrigger on Credit_Note__c (before insert,before update, after update,before delete) {
    if(trigger.isAfter && trigger.isUpdate){
        CRM_CreditNoteSequenceController.executeAfterUpdate(trigger.New,trigger.OldMap);
    }
    if(trigger.isBefore && trigger.isInsert){
        CRM_CreditNoteSequenceController.executeBeforeInsert(trigger.New);
    }
    if(trigger.isBefore && trigger.isDelete){
        CRM_CreditNoteSequenceController.executeBeforeDelete(trigger.Old);
    }
    if(trigger.isBefore && trigger.isUpdate){
        CRM_CreditNoteSequenceController.excuteBeforeUpdate(trigger.New,trigger.OldMap);
    }
}