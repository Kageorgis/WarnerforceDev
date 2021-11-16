global without sharing class WB_CopyCAToAnnouncementFields implements Database.Batchable<sObject>,Database.Stateful{
    global List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
    global Set<ID> accountIDSet;
    
    global WB_CopyCAToAnnouncementFields(Set<ID> accountIDSet1){
        accountIDSet = new Set<ID>();
        accountIDSet = accountIDSet1;
        
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
       
       Date endDate = date.newInstance(2019, 01, 01);
       String Query = 'Select Id,Title_ALID__c,Client__c FROM Client_Avail__c WHERE Client__c IN:accountIDSet AND End_Date__c >:endDate AND Title_ALID__c != Null';
       return Database.getQueryLocator(Query);
       
    }
    
  
    global void execute(Database.BatchableContext bc, List<Client_Avail__c> scope){
        
        Set<String> selectionCriteriaSet = new Set<String>{'AFE','Active Full Extract','MAL','Master Avails List'};
        
        capList = [SELECT Id,
                          Client_Avail__r.Title_ALID__c,
                          (Select Id,
                                  ALID__c,Announcement__r.Selection_Criteria__c 
                                  FROM Announcement_Records__r WHERE Announcement__r.Selection_Criteria__c NOT IN : selectionCriteriaSet ORDER BY CreatedDate DESC LIMIT 1)
                   FROM Client_Avail_Price__c WHERE Client_Avail__c IN : scope ];
                   
        
        system.debug(LoggingLevel.INFO,'###caplist size:'+caplist.size());
        
        List<Announcement_Record__c> announcementRecordList = new List<Announcement_Record__c>();
        
        for(Client_Avail_Price__c cap : capList){
            
            if(cap.Announcement_Records__r != null && cap.Announcement_Records__r.size()>0){
                Announcement_Record__c ar = cap.Announcement_Records__r[0];
                if(ar.ALID__c != cap.Client_Avail__r.Title_ALID__c){
                    ar.ALID__c = cap.Client_Avail__r.Title_ALID__c;
                }
                
                announcementRecordList.add(ar);
                
            }
           
        }
        
        if(announcementRecordList != null && announcementRecordList.size()>0){
            
            Database.update(announcementRecordList, false);
        }
        
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
}