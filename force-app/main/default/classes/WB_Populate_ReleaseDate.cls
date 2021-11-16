/*
Class Name   : WB_Populate_ReleaseDate 
Description  : This class is used to populate Local Theatrical Release Date field of Local Title records from related MPM Release Date records 
               Theatrical Release Date field when both record have same Country value and 'Theatrical Release Date' is not NULL
*/

global class WB_Populate_ReleaseDate implements Database.Batchable<sObject>, Schedulable
{
    // Schedulable interface
    Global void execute(SchedulableContext ctx) 
    {   
        WB_Populate_ReleaseDate rd = new WB_Populate_ReleaseDate();
        database.executebatch(rd,200);
    }
    
    //Batch Class Implementation
    global Database.QueryLocator start (Database.BatchableContext bc)
    {
        return Database.getQueryLocator('SELECT id,name,Country__c,Caption_Included_picklist__c,Local_Theatrical_Release_Date__c,Title__r.MPM__c FROM  Local_Title__c');
    }
    
    global void execute (Database.BatchableContext bc,List<Local_Title__c> lstlocalData)
    {
        Map<id,List<MPM_Release_Date__c>> mapMPMIdReleaseDateLst = new  Map<id,List<MPM_Release_Date__c>>();
        Set<id> setMPMids = new Set<id>();
        List<Local_Title__c> Update_LocaltitleList = new List<Local_Title__c>();
        
        for(Local_Title__c localdata:lstlocalData)
            setMPMids.add(localdata.Title__r.MPM__c);
        system.debug('setMPMids*****'+setMPMids);
        if(setMPMids.size() > 0 && setMPMids != NULL) 
        {
            List<MPM_Release_Date__c> LstmpmRelease = [SELECT id,MPM__c,Country__c,Language__c,Theatrical_Release_Date__c 
                                                   FROM MPM_Release_Date__c 
                                                   WHERE MPM__c=:setMPMids AND
                                                   Channel__c = NULL AND Format__c = NULL 
                                                   AND Country__c != NULL];
            system.debug('LstmpmRelease*****'+LstmpmRelease.size());
            for(MPM_Release_Date__c releaseDateObj : LstmpmRelease)
            {
                
                if(!mapMPMIdReleaseDateLst.containsKey(releaseDateObj.MPM__c))
                    mapMPMIdReleaseDateLst.put(releaseDateObj.MPM__c,new List<MPM_Release_Date__c>());
                mapMPMIdReleaseDateLst.get(releaseDateObj.MPM__c).add(releaseDateObj);
                
            }
            
            //Update Locale Title 'Theatrical Release Date'
            for(Local_Title__c localTitleObj : lstlocalData)
            {
                if(mapMPMIdReleaseDateLst.get(localTitleObj.Title__r.MPM__c) != NULL && mapMPMIdReleaseDateLst.get(localTitleObj.Title__r.MPM__c).size() > 0)
                {
                    for(MPM_Release_Date__c MPMObj : mapMPMIdReleaseDateLst.get(localTitleObj.Title__r.MPM__c))
                    {
                        if(localTitleObj.Country__c == MPMObj.Country__c)
                        {
                            if(localTitleObj.Local_Theatrical_Release_Date__c != MPMObj.Theatrical_Release_Date__c)
                            {
                                localTitleObj.Local_Theatrical_Release_Date__c = MPMObj.Theatrical_Release_Date__c;
                                Update_LocaltitleList.add(localTitleObj);
                            }
                        }
                        
                    }
                }
                
            }
            
            if(Update_LocaltitleList != NULL && Update_LocaltitleList.size()> 0)
            {
                Database.SaveResult[] srList = Database.update(Update_LocaltitleList,false);
                for (Database.SaveResult sr : srList) 
                {
                    if (!sr.isSuccess())
                    {
                        for(Database.Error objErr : sr.getErrors()) 
                        {
                            System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                            System.debug('Local Title oject field which are affected by the error: ' + objErr.getFields());
                        }
                    }
                }
            }
        }
        
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
         //ER - 793
         //send Job information to users via email
         BatchStatusNotification batchNotification = new BatchStatusNotification();
         AsyncApexJob jobInfo = [SELECT Status,TotalJobItems,NumberOfErrors,ExtendedStatus 
                                 FROM AsyncApexJob 
                                 WHERE Id=:BC.getJobID()];
         if(jobInfo != NULL)
            batchNotification.sendEmailToUsers(Label.Entity_CAS,'Local Data Theatrical Date Update',jobInfo.Status,jobInfo.TotalJobItems,jobInfo.NumberOfErrors,jobInfo.ExtendedStatus);
           
    }
}