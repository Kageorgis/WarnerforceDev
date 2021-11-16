trigger MPMReleaseDateCreateUpdate on MPM_Release_Date__c (after insert, after update, before insert, before update) {

   WB_MpmRdReleaseDateRollDown handler = new WB_MpmRdReleaseDateRollDown();
   RF_MpmReleaseDateTriggerHandler rbHandler= new RF_MpmReleaseDateTriggerHandler();
    //ER-002449 - MPM RD Roll Down 
    if(trigger.isBefore){
        handler.setOldReleaseStatus(trigger.new);
    }
    if(trigger.isAfter)
    {
        if(trigger.isInsert || trigger.isUpdate){
            //ER-002734 Start
            //Snippet Added to call the createRecord function from WB_UntrackedMarketMRDCreation class whenever we have an insert or update on tracked MRD Country record
            if(!WB_TriggerRecursionHelper.mrdRecursiveUpdateTrigger && !WB_TriggerRecursionHelper.wbBatchMPMRDRollup )
            {
                WB_UntrackedMarketMRDCreation.createRecord(Trigger.new);
            }
            //ER-002734 End
            //ER-1043
            handler.updateDatesOnLocalTitles(trigger.new);
            
            if(trigger.isInsert){
                rbHandler.createReleaseRcrd(trigger.new);
            }else if(trigger.isUpdate){
                rbHandler.updateReleaseRcrd(trigger.newMap,trigger.oldMap);
            }
        }
       System.debug('WB_TriggerRecursionHelper.isBatchWB_Batch_MPMRD_Rollup BEFORE IF' + WB_TriggerRecursionHelper.isBatchWB_Batch_MPMRD_Rollup);
        
       //ER-002449 - MPM RD Roll Down 
       if(!WB_TriggerRecursionHelper.isBatchWB_Batch_MPMRD_Rollup){
           System.debug('WB_TriggerRecursionHelper.isBatchWB_Batch_MPMRD_Rollup INSIDE IF' + WB_TriggerRecursionHelper.isBatchWB_Batch_MPMRD_Rollup);
       
            handler.updateDatesOnLocalTitlesForCancel(trigger.new);
       }
	   
       /* Boolean executeLocalDataUpdate = false;
        if(trigger.isInsert || trigger.isUpdate)
        {   
             for(MPM_Release_Date__c mpmRelDt : trigger.new){
                  if(mpmRelDt.Locale__c != null && mpmRelDt.Record_Status__c == 'Active' && mpmRelDt.Format__c == 'DVD' && (mpmRelDt.Release_Status__c == 'Confirmed' || mpmRelDt.Release_Status__c == 'Tentative')){
                    executeLocalDataUpdate = true;
                    break;
                  }
              }
        }
        if(executeLocalDataUpdate){     
            if(System.isBatch())
                WB_CheckingDateOverlapController.UpdateLocalDataSync((trigger.newMap).keySet());// CRRT Phase 3 
            else
                WB_CheckingDateOverlapController.UpdateLocalDataAsyn((trigger.newMap).keySet());// CRRT Phase 3 
        } */   
   
    }
    
     // ER-001327 - MPM out status Post Production change,Fix for CAs To IPM interface.
   if(trigger.isBefore && trigger.isUpdate)
    {
         WB_CheckingDateOverlapController.UpdateReleaseStatus(trigger.oldMap,trigger.new);
    }
    /*if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        if(WB_CheckingDateOverlapController.isFirstTime)
           WB_CheckingDateOverlapController.UpdateOptOutStatus(trigger.new);
    }*/
}