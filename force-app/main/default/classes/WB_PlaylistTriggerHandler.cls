public class WB_PlaylistTriggerHandler {
     public void updateRelatedClientAvail(list<Playlist__c> pList){
        list<ID> playlistIDs = new list<ID>();
        Map<Id,Client_Avail__c> updateCA = New Map<Id,Client_Avail__c>();
        List<Id> caIds = new List<Id>();
        Set<String> listPossibleStatus = new Set<String>(Label.WB_Client_Avail_Status.split(','));
        Boolean callBatch = false;
        for(Playlist__c P : pList){
          Playlist__c oldPlaylistRecord = (Playlist__c)trigger.oldmap.get(P.id);
          if(oldPlaylistRecord.Total_Playlist_Content__c != p.Total_Playlist_Content__c 
            || (p.Recalculate_Sequence__c == True 
            || oldPlaylistRecord.Recalculate_Sequence__c != p.Recalculate_Sequence__c)
            || ( oldPlaylistRecord.PlaylistALIDs__c != p.PlaylistALIDs__c  && Label.WB_UpdatePlaylist == 'TRUE')) //Added for ER - 1524
            playlistIDs.add(P.id);
        }
        FOR(Client_Avail__c relatedCA : [SELECT ID,EMA_BundleALIDs__c,Recalculate_Playlist_Avails__c,Title_Content_Type__c,Playlist__r.PlaylistALIDs__c 
            FROM Client_Avail__c 
            WHERE Playlist__c IN : playlistIDs
            AND Status__c in: listPossibleStatus
            AND (Title_Content_Type__c = 'Season' OR Title_Content_Type__c = 'Collection Features')
            AND (CA_Lifecycle__c = 'Active Future' OR CA_Lifecycle__c = 'Active Current')])
        {
            if(relatedCA.Title_Content_Type__c == 'Collection Features')
            {
                
                relatedCA.EMA_BundleALIDs__c =  relatedCA.Playlist__r.PlaylistALIDs__c;
                updateCA.put(relatedCA.Id, relatedCA);
                continue;
            }
            
            relatedCA.Recalculate_Playlist_Avails__c = 'Update Playlist';
            relatedCA.Recalculation_Status__c=false;
            callBatch = true;
            updateCA.put(relatedCA.Id, relatedCA);
        }
        if(updateCA.values().size() > 0)
        {
            try{
                
                WB_ClientAvailPriceHandler.recursiveUpdate = true;//SINC1590762 
                Database.saveresult[] saveResults = database.update(updateCA.values());
                integer count = 0;
                for(Integer i=0;i<saveResults.size();i++)
                {
                   If(updateCA.get(saveResults[i].getId()).Title_Content_Type__c == 'Collection Features')
                    count++;
                }
                if(updateCA.values().size() != count)
                {
                    Datetime ScheduleTime = system.now().addSeconds(40);
                    String cronExp = ScheduleTime.second()+' '+ScheduleTime.minute()+' '+ScheduleTime.hour()+' '+ScheduleTime.day()+' '+ScheduleTime.month()+' ? '+ScheduleTime.year();
                    String SchedulerName = 'EAs:'  +system.now() + ' ' + system.now().millisecond() + ' UP';//+' '+userinfo.get();
                    Id scheduleid = System.schedule(SchedulerName, cronExp, new WB_Batch_Playlist_Mgmt_Process(SchedulerName));
                    Episode_Avails_Scheduler__c csetting = new Episode_Avails_Scheduler__c(name = SchedulerName,Scheduler_id__c=scheduleid);
                    insert csetting;
                }
                
            }
            catch(exception e)
            {
                system.debug('Error on update: '+e.getMessage());
            }
            WB_ClientAvailPriceHandler.recursiveUpdate = false;//SINC1590762
        }
        
             
    }
    
     
}