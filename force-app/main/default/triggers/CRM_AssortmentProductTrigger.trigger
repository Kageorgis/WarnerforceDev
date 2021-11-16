/**
   @Author Cognizant
   @name CRM_AssortmentProductTrigger
   @CreateDate 8 June 2016
   @Description Trigger on Bundle_Product__c object
   @Version <1.0>
*/
trigger CRM_AssortmentProductTrigger on Bundle_Product__c (before insert,after insert, after delete) {
    if(trigger.isBefore && trigger.isInsert) {
        CRM_AssortmentProductTgrSequenceCtrl.beforeInsert(trigger.new);
    }
    
    if(trigger.isAfter && trigger.isInsert) {
        CRM_AssortmentProductTgrSequenceCtrl.afterInsert(trigger.new);
    }

    if(trigger.isAfter && trigger.isDelete) {
        CRM_AssortmentProductTgrSequenceCtrl.afterInsert(trigger.old);
    }
}