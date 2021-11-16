global without sharing class WB_CopyCAUPCToAnnouncementFields implements Database.Batchable<sObject>,Database.Stateful{
    global List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
    global Set<ID> accountIDSet ;
    global Set<String> contentTypeSet;
    
    global WB_CopyCAUPCToAnnouncementFields (Set<ID> accountIDSet1, Set<String> contentTypeSet1){
        accountIDSet = new Set<ID>();
        contentTypeSet = new Set<String>();
        accountIDSet = accountIDSet1;
        contentTypeSet = contentTypeSet1;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
       
       Date endDate = date.newInstance(2019, 01, 01);
       String Query = 'Select Id,UPC__c,Client__c FROM Client_Avail__c WHERE Client__c IN:accountIDSet AND End_Date__c >:endDate AND EMA_ReportingID_Formula__c != Null  AND Title_Content_Type__c IN:contentTypeSet';
       return Database.getQueryLocator(Query);
}
    
  
    global void execute(Database.BatchableContext bc, List<Client_Avail__c> scope){
        
        Set<String> selectionCriteriaSet = new Set<String>{'AFE','Active Full Extract','MAL','Master Avails List'};
        
        capList = [SELECT Id,
                          Client_Avail__r.EMA_ReportingID_Formula__c,
                          (Select Id,
                                  UPC__c,Announcement__r.Selection_Criteria__c 
                                  FROM Announcement_Records__r WHERE Announcement__r.Selection_Criteria__c NOT IN : selectionCriteriaSet ORDER BY CreatedDate DESC LIMIT 1)
                   FROM Client_Avail_Price__c WHERE Client_Avail__c IN : scope ];
                   
        
        system.debug(LoggingLevel.INFO,'###caplist size:'+caplist.size());
        
        List<Announcement_Record__c> announcementRecordList = new List<Announcement_Record__c>();
        
        for(Client_Avail_Price__c cap : capList){
            
            if(cap.Announcement_Records__r != null && cap.Announcement_Records__r.size()>0){
                Announcement_Record__c ar = cap.Announcement_Records__r[0];
                if(ar.UPC__c!= cap.Client_Avail__r.EMA_ReportingID_Formula__c){
                    ar.UPC__c= cap.Client_Avail__r.EMA_ReportingID_Formula__c;
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