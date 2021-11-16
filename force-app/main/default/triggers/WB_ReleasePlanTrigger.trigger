trigger WB_ReleasePlanTrigger on Commercial_Avail__c (before Insert, before Update, After Insert, After Update, before Delete, After Undelete) 
{
    Id userId = UserInfo.getUserId();
    ByPassAutomationRules__c byPass = ByPassAutomationRules__c.getInstance(userId);
	
    if(WB_TriggerRecursionHelper.releasePlanRecursiveUpdate){       
        //Flag was set for Product update on RP. Skipping recursive execution of triger code.       
        return;     
    }
    
    if(!WB_CheckingDateOverlapController.isRunning_BatchMRMRollup){// To bypass the trigger during MRD rollup
        if(byPass != NULL && byPass.Active__c != true)
        {
            WB_ReleasePlanTriggerHandler handler = new WB_ReleasePlanTriggerHandler();
            if(trigger.isInsert)
            {
                if(trigger.isBefore)
                {  
                    WB_CalculateRPDates.recursiveUpdate = true;
                    WB_CheckingDateOverlapController.localdatacreation(trigger.new); //ER-003991
                    WB_CalculateRPDates.calculateAutomatedReleaseDates(trigger.new,Null,'Insert'); //ER-006428 - Automated Release Date Based on Theatrical Window
                    WB_CheckingDateOverlapController.Chkoverlap_afterinsert();
                    WB_CheckingDateOverlapController.setQueueToOwner(trigger.new); 
                    WB_CheckingDateOverlapController.addReleaseLocalOnRP(trigger.new); //ER-007484
                    WB_CalculateRPDates.recursiveUpdate = false;           
                }
                
                if(trigger.isAfter)
                {
                    
                    handler.CheckDupsInList(trigger.oldMap, trigger.newMap, trigger.new);  //Created For Checking Duplicates Within the List Of Records Being Inserted/Updated - Hot Fix - 21-Oct-2016
                    WB_CheckingDateOverlapController.changePlaylistValueInRelatedCAs(trigger.new,'Insert'); // ER:10   
                    
                 }
            }
            
            if(trigger.isUpdate)
            {
                if(WB_CalculateRPDates.recursiveUpdate) return;

                if(trigger.isBefore)
                {
                    //handler.langTypeChange(trigger.oldMap, trigger.new);
                    if(TestUtil.isRunning_WB_Batch_AddWeeklyRightsCheck == false)
                    {
                        WB_CalculateRPDates.recursiveUpdate = true;
                        WB_CheckingDateOverlapController.localdatacreation(trigger.oldMap, trigger.new); //ER-007425
                        WB_CalculateRPDates.calculateAutomatedReleaseDates(trigger.new,trigger.oldMap,'Update');
                        WB_CheckingDateOverlapController.Chkoverlap_beforeupdate();
                        WB_UpdateRightInfo rp = new WB_UpdateRightInfo();
                        rp.mapRightsDate(trigger.new);
                        WB_CheckingDateOverlapController.UpdateRPMPMReleaseDateKey(trigger.new, trigger.oldMap);// CRRT Phase 3   
                        WB_CalculateRPDates.recursiveUpdate = false;      
                    }            
                }
                
                if(trigger.isAfter)
                {
                    
                    handler.CheckDupsInList(trigger.oldMap, trigger.newMap, trigger.new);  //Created For Checking Duplicates Within the List Of Records Being Inserted/Updated - Hot Fix - 21-Oct-2016
                    if(TestUtil.isRunning_WB_Batch_AddWeeklyRightsCheck == false)
                    {
                        List<Client_Avail__c> updateClientAvail = new List<Client_Avail__c>();
                        set<Id> dateChangedRPIdSet = new set<Id>();
                        for(Id releasePlanID : Trigger.newMap.keySet()){
                            Commercial_Avail__c oldRP = trigger.oldMap.get(releasePlanID);
                            Commercial_Avail__c newRP = trigger.newMap.get(releasePlanID);
                            
                            if(newRP.Start_Date__c != oldRP.Start_Date__c || newRP.End_Date__c != oldRP.End_Date__c){ 
                                dateChangedRPIdSet.add(newRP.Id);
                            }
                        }
                        if(dateChangedRPIdSet != null && dateChangedRPIdSet.size() > 0){
                            List<Client_Avail__c> caList = [
                                Select Start_Date__c, End_Date__c, Commercial_Avail__c, Commercial_Avail__r.End_Date__c, Commercial_Avail__r.Start_Date__c, RP_Synch__c, Client__c
                                  From Client_Avail__c
                                 where Commercial_Avail__c IN :dateChangedRPIdSet and RP_Synch__c = true
                            ];
                            if(caList != null && caList.size() > 0){
                                for (Client_Avail__c clientAvail : caList){
                                    if(clientAvail.RP_Synch__c == true){
                                        clientAvail.Start_Date__c = clientAvail.Commercial_Avail__r.Start_Date__c;
                                        clientAvail.End_Date__c = clientAvail.Commercial_Avail__r.End_Date__c;
                                        updateClientAvail.add(clientAvail);
                                    }
                                } 
                                if(updateClientAvail != Null && updateClientAvail.size()>0){
                                    update updateClientAvail;
                                }              
                            }
                        }
                    }
                    WB_CheckingDateOverlapController.changePlaylistValueInRelatedCAs(trigger.new,'Update'); // ER:10
                }
            }
            
            if(trigger.isDelete)
            {
                if(trigger.isBefore)
                {
                    WB_Before_delete_release_plan_Controller.beforedelete_releaseplan();
                }
            }
            
            //handler call to create Product        
            /*if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){      
                System.debug('inside RP trigger -->>');
                WB_PBEP_Product_CreationHandler pbepProdHandler = new WB_PBEP_Product_CreationHandler();        
                pbepProdHandler.assignProductToReleasePlan(Trigger.new);
                pbepProdHandler.updateAssignedProductsFromRP(Trigger.new,Trigger.oldMap);        
            }*/
            
            
            if(trigger.isUndelete && trigger.isAfter)
            {
                //Setting rollup flag after undelete
                WB_Before_delete_release_plan_Controller.afterdelete_releaseplan(trigger.new);
            }
        }
    }
}