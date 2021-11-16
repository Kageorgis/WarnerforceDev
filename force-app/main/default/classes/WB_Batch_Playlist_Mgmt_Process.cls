global class WB_Batch_Playlist_Mgmt_Process implements Database.Batchable<sObject>,Schedulable,Database.Stateful{
    global String Query;
    List<String> possibleStatus = new List<String>();
     List<Client_Avail__c> updateClientAvail = new List<Client_Avail__c>();
    set<Id> clientAvailIds;
    global String SchedulerName;
    
    global WB_Batch_Playlist_Mgmt_Process(string Scheduler){
        SchedulerName = Scheduler;
    }
    
    global void execute(SchedulableContext sc)
   {
      WB_Batch_Playlist_Mgmt_Process c = new WB_Batch_Playlist_Mgmt_Process(SchedulerName);
      database.executebatch(c,1);
   }
   
    global WB_Batch_Playlist_Mgmt_Process(){

    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        possibleStatus.add('Insert');
        possibleStatus.add('Update Playlist');
        possibleStatus.add('Update Playlist Content');
        possibleStatus.add('Update Local Data');
        possibleStatus.add('Update Episode Avails');
        
        updateClientAvail = [SELECT ID,Name,Recalculate_Playlist_Avails__c,Recalculation_Status__c,Title_Content_Type__c,Playlist__r.PlaylistALIDs__c,EMA_BundleALIDs__c FROM Client_Avail__c 
                                WHERE Recalculate_Playlist_Avails__c in: possibleStatus and 
                                Recalculation_Status__c = false];
        Boolean hasBadData = false;
        
        if(updateClientAvail != null){
            for(Client_Avail__c clientAvail : updateClientAvail){
              if(clientAvail.Title_Content_Type__c == 'Collection Features'){
                    clientAvail.EMA_BundleALIDs__c = clientAvail.Playlist__r.PlaylistALIDs__c;
                    clientAvail.Recalculate_Playlist_Avails__c = '';
              }
              
              clientAvail.Recalculation_Status__c = true;
            }
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage ();
            message.setSubject ('Failed Avails in Playlist Mgmt Batch');
            String body = 'Below avails have got failed in Playlist mgmt batch due to bad data...<br/><br/>';
            
            body += '<html><style> table { border-collapse: collapse; width: 50%;}  table, td, th { border: 1px solid black;} th {height: 30px;}</style>';
            body += '<table><tr><th>Client Avail Id</th><th>Exception error for Client Avail</th></tr>';
            
            WB_ClientAvailPriceHandler.recursiveUpdate  = true; //07/12/2017 Sriniz
            Database.saveresult[] saveResults = Database.update(updateClientAvail,false);
            WB_ClientAvailPriceHandler.recursiveUpdate  = false; //07/12/2017 Sriniz            
            Integer i=0;
            for(i=0;i<saveResults.size();i++){
                if(!saveResults[i].isSuccess()){
                    hasBadData = true;
                    body += '<tr><td>'+updateClientAvail[i].Name+'</td><td>'+saveResults[i].getErrors()+'</td></tr>';
              }
            }
            body += '</table></html>';
            
            message.sethtmlbody (body);
            message.setCcAddresses (Label.Email_Ids_for_Avail_Fails_in_Playlist_batch.split(';'));
            if(hasBadData)
                Messaging.sendEmail (new Messaging.SingleEmailMessage [] {message}); 
            
        }
        Query='SELECT ID,Playlist__c,Playlist__r.PlaylistALIDs__c,Title_Content_Type__c,Playlist__r.Recalculate_Sequence__c,Playlist__r.Episode_End_Date_Calc__c,Commercial_Avail__c,CA_CRM_Country__c,Episode_Pricing__c,Episode_Rate_Card__c,Local_Title__c,Local_Title__r.Local_Rating__c, Local_Title__r.Local_Rating_System__c,Local_Title__r.Local_Category__c,Commercial_Avail__r.Languages__c,Status__c, Commercial_Avail__r.Country_Lookup__c,Client__c,End_Date__c,Local_Data_Category_Picklist__c,Recalculation_Status__c,'+
            'Recalculate_Playlist_Avails__c,RP_Language_Type__c,Start_Date__c,Episode_Price_Tier__c,Episode_Price__c,Release_Plan_Country__c,Title__r.US_TV_Air_Date__c,(Select Id from Child_Client_Avails__r)'+
        +' FROM Client_Avail__c WHERE Recalculate_Playlist_Avails__c in: possibleStatus AND id in: updateClientAvail and Recalculation_Status__c = true'; //'And id in: clientAvailIds' 
    
        return Database.getQueryLocator(Query);
    }

    global void execute(Database.BatchableContext BC, List<Client_Avail__c> scope){
        Client_Avail__c ca = scope[0];
        List<Client_Avail__c> lstFeatureCA = new List<Client_Avail__c>();
        List<Client_Avail__c> lstSeasonCA = new List<Client_Avail__c>();
        WB_Playlist_Mgmt_Process_Handler handlerInstance = new WB_Playlist_Mgmt_Process_Handler();
        List<WB_CAS_ErrorLogger.ErrorLog> errorLogs = new List<WB_CAS_ErrorLogger.ErrorLog>();
        try{
            //ER - 1524
                handlerInstance.CreateLocalData(scope);
                handlerInstance.CreateClientAvails(scope);
            }
            
        //handlerInstance.UpdateEpisodeAvails(scope);     //ER-820: Method Addition 
        catch(Exception e){
            system.debug('Exception e:'+e);
            WB_Playlist_Mgmt_Process_Handler.createErrorLog(ca,e.getMessage(),e.getStackTraceString()); 
        }
        
        
    }

    global void finish(Database.BatchableContext BC){
        Episode_Avails_Scheduler__c csetting = Episode_Avails_Scheduler__c.getInstance(SchedulerName);
        BatchStatusNotification batchNotification = new BatchStatusNotification();
        
        if(csetting != null){
            system.debug('Aborting job 1: '+csetting.name);
            System.abortJob(csetting.Scheduler_id__c);
            delete csetting;
        }
        //ER - 793
        //send Job information to users via email
       AsyncApexJob jobInfo = [SELECT Status,TotalJobItems,NumberOfErrors,ExtendedStatus 
                                 FROM AsyncApexJob 
                                 WHERE Id=:BC.getJobID()];
        if(jobInfo != NULL && jobInfo.TotalJobItems > 0)
            batchNotification.sendEmailToUsers(Label.Entity_CAS,'Create Episodic Avails',jobInfo.Status,jobInfo.TotalJobItems,jobInfo.NumberOfErrors,jobInfo.ExtendedStatus);
           
    }
}