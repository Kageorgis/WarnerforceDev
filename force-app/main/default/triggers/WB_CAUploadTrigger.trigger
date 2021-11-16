trigger WB_CAUploadTrigger on CA_Upload__c (after insert,after update) {
        
    if(trigger.isafter && trigger.isupdate)
    {
        WB_CAUploadTriggerHandler.DeleteAttachements(Trigger.new,Trigger.oldMap);
    }
    /*if(trigger.isafter && trigger.isinsert)
    {
        WB_CAUploadTriggerHandler.ScheduleBatch(trigger.new);
    }*/
    
}