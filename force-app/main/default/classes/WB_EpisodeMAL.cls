global class WB_EpisodeMAL implements Database.Batchable<sObject>{
    
    public Integer successCount = 0;
    public Integer failCount = 0;
    public Integer totalVVProcessed = 0;
    
    global Database.QueryLocator start(Database.BatchableContext BC){  
        
        return Database.getQueryLocator([SELECT Id, 
                                                VV__c
                                           FROM Episode_MAL__c]);
                                                  
    }
    
    global void execute(Database.BatchableContext BC, list<Episode_MAL__c> scope){
        
        Map<String, Id> vvPlaylistMap = new Map<String,Id>();
        Set<String> vvMap = new Set<String>();
        List<Local_Title__c> ldToUpdate = new List<Local_Title__c>();
        Set<String> vvInput = new Set<String>();
        
        for(Episode_MAL__c em : scope) vvInput.add(em.vv__c);
        
        
        system.debug(LoggingLevel.INFO,'vvInput:'+vvInput);
        
                                   
        for(Playlist__c pl : [SELECT Id,Parent_Title__c,Parent_Title_VV__c FROM Playlist__c 
                               WHERE Parent_Title_VV__c in :vvInput
                                 AND Version_Number__c = 1
                                 AND Playlist_Status__c = 'Active'
                                         ]){
            vvPlaylistMap.put(pl.Parent_Title_VV__c,pl.id);
            vvMap.add(pl.Parent_Title_VV__c);
            totalVVProcessed++;
        }
        Set<Id> localDataId = new Set<Id>();  
        
        
        List<Local_Title__c> localDataList = new List<Local_Title__c>();
        
        if(!Test.isRunningTest()){
            localDataList = [SELECT Id,Playlist__c,Title_VV_F__c FROM Local_Title__c WHERE Title_VV_F__c IN :vvMap AND CountryF__c IN :Label.WB_EpisodeMAL_Countries.split(',') AND LanguageF__c IN :Label.WB_EpisodeMAL_Languages.split(',') AND External_Company__c = Null];
        }else{
            
            Set<String> countryList = new Set<String>{'USA','Germany'};
            localDataList = [SELECT Id,Playlist__c,Title_VV_F__c FROM Local_Title__c WHERE Title_VV_F__c IN :vvMap 
                                                             AND CountryF__c IN : countryList
                                                             AND LanguageF__c IN :Label.WB_EpisodeMAL_Languages.split(',') AND External_Company__c = Null];
        }
        
        
        if(localDataList.size() != null && localDataList.size()>0){
            for(Local_Title__c ld : localDataList){
                ld.Playlist__c = vvPlaylistMap.get(ld.Title_VV_F__c);
                ldToUpdate.add(ld);
                localDataId.add(ld.Id);
            }
        }
        
        
        List<Client_Avail__c> caList =  new List<Client_Avail__c>();
        Map<String,List<Client_Avail__c>> caMap = new Map<String,List<Client_Avail__c>>();
        
        caList = [Select Id,Playlist__c,Title_Content_Type__c,Local_Title__c,Local_Title__r.Title__r.Video_Version__c,Client__c FROM Client_Avail__c WHERE Local_Title__c IN : localDataId AND Title_Content_Type__c =: 'Season'];
        for(Client_Avail__c caRec : caList){
            
            if(!caMap.containsKey(caRec.Local_Title__c))
                caMap.put(caRec.Local_Title__c,new List<Client_Avail__c>{caRec});
            else
                caMap.get(caRec.Local_Title__c).add(caRec);
        }
        
        Database.SaveResult[] srList = Database.update(ldToUpdate, false);
        Map<Id,String> caErrorMap = new Map<Id,String>();
        Map<Id,String> caPlaylistIDMap = new Map<Id,String>();
        List<Client_Avail__c> caErrorList =  new List<Client_Avail__c>();
         if(srList != null && srList.size()>0){
             
             for(Integer index=0;index<srList.size();index++){
                 
                 Database.SaveResult updateResult = srList[index];
                 if(updateResult.isSuccess()){
                     // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted account. Account ID: ' + updateResult.getId());
                    successCount++;
                 }else{
                     
                     String errorMessage = '';
                     Id localTitleId;
                     for(Database.Error err : updateResult.getErrors()) {
                        errorMessage += err.getMessage();
                        
                     }
                     localTitleId = ldToUpdate[index].Id;
                     
                     if(localTitleId != null && caMap.get(localTitleId).size() != null && caMap.get(localTitleId).size()>0){
                         for(Client_Avail__c caRec : caMap.get(localTitleId)){
                             caErrorList.add(caRec);
                             
                             //Error message related to CA
                              if(!caErrorMap.containsKey(caRec.Id))
                                caErrorMap.put(caRec.Id, errorMessage);
                              
                              //Playlist ID related to CA 
                              if(!caPlaylistIDMap.containsKey(caRec.Id))
                                caPlaylistIDMap.put(caRec.Id,vvPlaylistMap.get(caRec.Local_Title__r.Title__r.Video_Version__c));
                         }
                     }
                     
                      
                     
                    
                     failCount++;
                 }
             }
             
             
             
        
             if(caErrorMap.values().size() != null && caErrorMap.values().size() > 0){
                WB_PriceUtility.createErrorLog(caErrorList,caErrorMap,caPlaylistIDMap);
            }
         }

        // Iterate through each returned result
       /* for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                successCount++;
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
                failCount++;
            }
        }*/
    }

    global void finish(Database.BatchableContext BC){
        system.debug('Total VV Processed Count:'+totalVVProcessed);
        system.debug('Success Count:'+successCount);
        system.debug('Fail Count:'+failCount);
    }
    
}