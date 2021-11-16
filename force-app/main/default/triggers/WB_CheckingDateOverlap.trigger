trigger WB_CheckingDateOverlap on Commercial_Avail__c (before update, before insert, after insert, after update) {

    WB_ReleasePlanTriggerHandler handler = new WB_ReleasePlanTriggerHandler();
    if(Trigger.isUpdate && Trigger.isBefore)
    {    
        handler.langTypeChange(trigger.oldMap, trigger.new);
        //Added by shalini
        // map the appropriate right date and record if the release plan record date changes.
        if(TestUtil.isRunning_WB_Batch_AddWeeklyRightsCheck == false)
        {
            WB_CheckingDateOverlapController.Chkoverlap_beforeupdate();
            WB_UpdateRightInfo rp = new WB_UpdateRightInfo();
            rp.mapRightsDate(trigger.new);
            
        }
    }
    
    if(Trigger.isInsert && Trigger.isBefore) {
        WB_CheckingDateOverlapController.Chkoverlap_afterinsert();
    }
    
    if(Trigger.isAfter)
        handler.CheckDupsInList(trigger.oldMap, trigger.newMap, trigger.new);  //Created For Checking Duplicates Within the List Of Records Being Inserted/Updated - Hot Fix - 21-Oct-2016
    

}