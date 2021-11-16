/*
Created Date - 25th April'2017
Created By - Cognizant Team
Description - Update Digital Owner field on Country object to assign the queue as an owner of respective country’s EAD record
*/

trigger WB_EarliestAvailableDateTrigger on Earliest_Avail_Date__c (before insert,before update) {
    if(Trigger.isbefore) {
        if(Trigger.isInsert) {
            WB_EarliestAvailableDateTriggerHandler.setQueueToOwner();
        }
        //ER-002250 : update source of EAD to manual if record is updated by any business user.
        if(Trigger.isInsert || Trigger.isUpdate){
            WB_EarliestAvailableDateTriggerHandler.updateEADSource(trigger.new);
        }
    }
        
}