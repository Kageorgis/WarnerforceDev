trigger WB_ocalDataOnReleasePlanTrigger on Commercial_Avail__c (after insert, after update) {

    if(Trigger.isInsert){
        WB_CheckingDateOverlapController.localdatacreation();
        WB_CheckingDateOverlapController.changePlaylistValueInRelatedCAs(trigger.new,'Insert'); // ER:10
    }
    
    //ER-000119
    if(Trigger.isAfter && Trigger.isUpdate){
        if(TestUtil.isRunning_WB_Batch_AddWeeklyRightsCheck == false){
            List<Client_Avail__c> updateClientAvail = new List<Client_Avail__c>();
            set<Id> dateChangedRPIdSet = new set<Id>();
            for(Id releasePlanID : Trigger.newMap.keySet()){
                Commercial_Avail__c oldRP = trigger.oldMap.get(releasePlanID);
                Commercial_Avail__c newRP = trigger.newMap.get(releasePlanID);
                system.debug('oldRP ====: ' + oldRP);
                system.debug('newRP ====: ' + newRP);
                
                if(newRP.Start_Date__c != oldRP.Start_Date__c || newRP.End_Date__c != oldRP.End_Date__c){
                    dateChangedRPIdSet.add(newRP.Id);
                }
            }
            
            List<Client_Avail__c> caList = [
                Select Start_Date__c, End_Date__c, Commercial_Avail__c, Commercial_Avail__r.End_Date__c, Commercial_Avail__r.Start_Date__c, RP_Synch__c, Client__c
                  From Client_Avail__c
                 where Commercial_Avail__c IN :dateChangedRPIdSet and RP_Synch__c = true
            ];
            system.debug('caList =====> ' + caList.size());
            for (Client_Avail__c clientAvail : caList){
                if(clientAvail.RP_Synch__c == true){
                    clientAvail.Start_Date__c = clientAvail.Commercial_Avail__r.Start_Date__c;
                    clientAvail.End_Date__c = clientAvail.Commercial_Avail__r.End_Date__c;
                    updateClientAvail.add(clientAvail);
                }
            }
            system.debug('updateClientAvail =====> ' + updateClientAvail.size());
            update updateClientAvail;
        }
        WB_CheckingDateOverlapController.changePlaylistValueInRelatedCAs(trigger.new,'Update'); // ER:10
   }
}