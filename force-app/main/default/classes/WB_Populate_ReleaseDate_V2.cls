/*
Class Name   : WB_Populate_ReleaseDate_V2 
Description  : This class is used to populate Local Theatrical Release Date field of Local Title records from related MPM Release Date records 
               Theatrical Release Date field when both record have same Country value and 'Theatrical Release Date' is not NULL
*/
global class WB_Populate_ReleaseDate_V2 implements Database.Batchable<sObject>, Schedulable, Database.Stateful{
    String dateFilter;
    DateTime lastRunDate;
    DateTime LastModifiedFrom;
    DateTime LastModifiedTo;
    Set<Id> LTIds = new Set<Id>();
    Set<Id> expLTIds = new Set<Id>();
    
    // Schedulable interface
    Global void execute(SchedulableContext ctx){   
        
        system.debug('lastRunDate : '+lastRunDate);
        WB_Populate_ReleaseDate_V2 rd = new WB_Populate_ReleaseDate_V2(lastRunDate,null);
        lastRunDate = system.now();
        
        Integer batchSize = WB_Populate_TRD_On_LT__c.getInstance('WB_Populate_ReleaseDate') != null ? Integer.valueOf(WB_Populate_TRD_On_LT__c.getInstance('WB_Populate_ReleaseDate').Batch_Size__c) : 200;
        database.executebatch(rd,batchSize);
    }
    
    Global WB_Populate_ReleaseDate_V2(){}
    Global WB_Populate_ReleaseDate_V2(DateTime fromDateVar,DateTime toDateVar){
        system.debug('Before batch class constructor lastRunDate : '+fromDateVar+'-----'+toDateVar);
        LastModifiedFrom = (fromDateVar != null) ? fromDateVar.addMinutes(-1) : system.now().addDays(-1);
        LastModifiedTo = (toDateVar != null) ? toDateVar : null;
        system.debug('After batch class constructor lastRunDate : '+LastModifiedFrom+'-----'+LastModifiedTo);
        dateFilter = ' AND LastModifiedDate >= :LastModifiedFrom'; 
        if(LastModifiedTo != null){
            dateFilter += ' AND LastModifiedDate <= :LastModifiedTo';
        }
    }
    
    Global WB_Populate_ReleaseDate_V2(Set<Id> LTIds){
        this.LTIds = LTIds;
    }
    
    //Batch Class Implementation
    global Database.QueryLocator start (Database.BatchableContext bc){
        
        String queryStr = 'SELECT Id,Country__c,Title__r.MPM__c,Local_Theatrical_Release_Date__c,Country__r.name,Language__r.name,Title_VV_F__c,Title_MPM_F__c FROM Local_Title__c WHERE External_Company__c = Null AND ';
        if(LTIds.size() > 0){
            queryStr += 'Id IN :LTIds';
        }else{
            system.debug('batch class start lastRunDate : '+LastModifiedFrom+'-----'+LastModifiedTo);
            Set<String> countryMPMIds = new Set<String>();
            for(Country__c c : Database.query('Select Id From Country__c Where Id IN (Select Country__c From MPM_Release_Date__c  WHERE Channel__c = NULL AND Format__c = NULL AND Country__c != NULL'+dateFilter+')')){
            	countryMPMIds.add(c.Id);
            }
            for(MPM__c m : Database.query('Select Name From MPM__c Where Id IN (Select MPM__C From MPM_Release_Date__c  WHERE Channel__c = NULL AND Format__c = NULL AND Country__c != NULL'+dateFilter+')')){
            	countryMPMIds.add(m.Name);
            }
            queryStr += 'Country__c IN :countryMPMIds AND Title__r.MPM__r.name IN :countryMPMIds';
        }
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute (Database.BatchableContext bc,List<Local_Title__c> lstLTRecords){
        Set<Id> MPMs = new Set<Id>();
        Set<Id> countryIds = new Set<Id>();
        Map<String,List<MPM_Release_Date__c>> mapOfMRDRecords = new Map<String,List<MPM_Release_Date__c>>();
        
        List<Local_Title__c> lstOfLTNTProcess = new List<Local_Title__c>();
        if(LTIds.size() > 0){
            lstOfLTNTProcess = lstLTRecords;
        }else{
            Map<Id,Integer> mapOfLTToCACount = new Map<Id,Integer>();
            for(AggregateResult a : [SELECT Count(id),Local_Title__c FROM Client_Avail__c Where Local_Title__c IN :lstLTRecords Group By Local_Title__c]){
                mapOfLTToCACount.put((Id)a.get('Local_Title__c'),(Integer)a.get('expr0'));
            }
            
            Integer caLimit = WB_Populate_TRD_On_LT__c.getInstance('WB_Client_Avail_Limit_On_LT') != null ? Integer.valueOf(WB_Populate_TRD_On_LT__c.getInstance('WB_Client_Avail_Limit_On_LT').Batch_Size__c) : 50;
            for(Local_Title__c lt : lstLTRecords){
                if(mapOfLTToCACount.containsKey(lt.Id) && mapOfLTToCACount.get(lt.Id) > caLimit){
                    expLTIds.add(lt.Id);
                }else{
                    lstOfLTNTProcess.add(lt);
                }
            }
        }
        
        for(Local_Title__c lt : lstOfLTNTProcess){
            MPMs.add(lt.Title__r.MPM__c);
            countryIds.add(lt.Country__c);
        }
        
        if(MPMs.size() > 0 && countryIds.size() > 0){
            for(MPM_Release_Date__c mrd : [SELECT id,MPM__c,Country__c,Theatrical_Release_Date__c FROM MPM_Release_Date__c WHERE Channel__c = NULL AND Format__c = NULL AND Country__c != NULL AND MPM__c IN :MPMs AND Country__c IN :countryIds]){
                String key = mrd.MPM__c+'_'+mrd.Country__c;
                if(!mapOfMRDRecords.containsKey(key)){
                    mapOfMRDRecords.put(key, new List<MPM_Release_Date__c>{mrd});
                }
                mapOfMRDRecords.get(key).add(mrd);
            }
        
            List<Local_Title__c> Update_LocaltitleList = new List<Local_Title__c>();
            for(Local_Title__c  lt : lstOfLTNTProcess){
                
                String key = lt.Title__r.MPM__c+'_'+lt.Country__c;
                if(mapOfMRDRecords.containsKey(key)){
                    for(MPM_Release_Date__c mrd : mapOfMRDRecords.get(key)){
                        if(lt.Local_Theatrical_Release_Date__c != mrd.Theatrical_Release_Date__c){
                            lt.Local_Theatrical_Release_Date__c = mrd.Theatrical_Release_Date__c;
                            Update_LocaltitleList.add(lt);
                        }
                    }
                }
            }
                
            if(!Update_LocaltitleList.isEmpty()){
                Database.SaveResult[] srList = Database.update(Update_LocaltitleList,false);
                List<CAS_Error_Log__c> errorLogs = new List<CAS_Error_Log__c>();
                for (integer i=0;i<srList.size();i++){
                    Database.SaveResult sr = srList[i];
                    Local_Title__c lt = Update_LocaltitleList[i];
                    if (!sr.isSuccess()){
                        
                        system.debug('Local Title Info : '+lt.Id+'  ::  '+lt.Country__r.name+'  ::  '+lt.Language__r.name+'  ::  '+lt.Title_MPM_F__c);
                        
                        CAS_Error_Log__c CASErrorLog = new CAS_Error_Log__c();
                        CASErrorLog.Country__c = lt.Country__r.name;
                        CASErrorLog.Language__c = lt.Language__r.name;
                        CASErrorLog.Object_Name__c = 'Local_Title__c';
                        CASErrorLog.Record_Id__c = lt.Id;
                        CASErrorLog.Video_Version__c = lt.Title_VV_F__c;
                        CASErrorLog.Error_Category__c = 'Populate TRD On LT';
                        CASErrorLog.Error_Description__c = 'Error For LT MPM : '+lt.Title_MPM_F__c+' & Status Code : '+sr.getErrors()[0].getStatusCode();
                        CASErrorLog.Error_Description_Long__c =  sr.getErrors()[0].getMessage()+' ;; '+sr.getErrors()[0].getFields();
                        errorLogs.add(CASErrorLog);
                    }
                }
                
                if(errorLogs.size() > 0){
                    insert errorLogs;
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
         
         if(!Test.isRunningTest() && expLTIds.size() > 0){
             WB_Populate_ReleaseDate_V2 rd = new WB_Populate_ReleaseDate_V2(expLTIds);
             database.executebatch(rd,1);
         }
         
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