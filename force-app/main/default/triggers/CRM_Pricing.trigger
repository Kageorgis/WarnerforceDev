/** 
   * Author: cognizant Team
   * Description: This trigger is used to call methods from Handllers to udpate Client Avail on change of pricing fields
   * Date Created:  14 April 2016
   * Version: 1.0  
   */
trigger CRM_Pricing on Pricing__c (before Insert,after insert,after update,after delete,before update, before delete) {
       
    if(Trigger.isBefore && Trigger.isInsert) {      
        WB_PricingTriggerHandler.setQueueToOwner(trigger.new); //ER-995
    }
    
    /*if(Trigger.isBefore && Trigger.isUpdate) {
    }
    
    if(Trigger.isBefore && Trigger.isDelete) {
    }
        
    if(Trigger.isAfter && Trigger.isDelete) {        
    }
    
    if(Trigger.isAfter && Trigger.isInsert) {
    }*/
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        CRM_PricingSequenceController.executeAfterUpdate(trigger.oldMap, trigger.newMap);
    }

}