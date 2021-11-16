/** 
   * @Author: cognizant Team
   * @Description: This trigger is used to call methods of Handlers 
   * @Date Created:  03 March 2017
   * @Version: 1.0 
   */

trigger CRM_CreditNoteItemTrigger on Credit_Note_Item__c (before insert, after insert, before update, after update) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        CRM_CreditNoteItemSequenceController.executeBeforeInsert(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isInsert){
        CRM_CreditNoteItemSequenceController.executeAfterInsert(Trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        CRM_CreditNoteItemSequenceController.executeBeforeUpdate(Trigger.new);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate ){
        CRM_CreditNoteItemSequenceController.executeAfterUpdate(Trigger.new);
    }
}