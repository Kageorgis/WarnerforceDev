/*------------------------------------------------------------
Author:        Cognizant Technology Solution
Company:       Cognizant Technology Solution
Class Name:    WB_UpdateAOOnCABatchProcess 
Description:   This class is responsible to reset the value of "Announce
               Overide" field on Client Avail to Blank.

Reason:        We can write the similar funtionality in WB_ClientActivityBatch
               Process. But we don't want to make the performance of that batch
               process down. That is the reason we are writing a seperate class
               which will be called after the announcment process completed.               

How its works: After the Announcement process completed. It will call this class
               with the Announcment Id. This class is responsible to fetch all
               Announcment Records and corresponding Client Avail. Then it will
               set the Announce Overide= '';
               
Test Class:    WB_UpdateAOOnCA_Test
History
<Date>      <Authors Name>     <Brief Description of Change>
02/17/2016    MD                ER-000452 - Initial Version

------------------------------------------------------------*/
global class WB_UpdateAOOnCABatchProcess implements Database.Batchable<sObject>{
    
    global set<Id> lstAnnouncementIds; //Announcement Id need to process
    
    global WB_UpdateAOOnCABatchProcess( set<Id> AnnouncementIds){
        lstAnnouncementIds = AnnouncementIds;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        //query to fetch all the client avail associated with Announcement
        String Query = 'SELECT id,Client_Avail__c,Client_Avail__r.First_Announcement_Date__c '+
                    'FROM Announcement_Record__c '+
                    'WHERE Announcement__c IN :lstAnnouncementIds';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, 
                                        List<Announcement_Record__c> scope){
        Set<Id> clientAvailId = new Set<Id>(); //store all the client avail ID
        Set<Id> caIDSetToFetchAnnouncement = new Set<Id>(); //store all the client avail ID
        Map<Id,Client_Avail__c> caAnnouncementMap = new Map<Id,Client_Avail__c>();
        
        List<Client_Avail__c> caToUpdate = new List<Client_Avail__c>();
        //below for loop to get all the client avail id from announcement records
        for(Announcement_Record__c ar :scope){
            clientAvailId.add(ar.Client_Avail__c);
            //below if condition to prepare list of ca id with first announcement date null.
            if(ar.Client_Avail__r.First_Announcement_Date__c == null){
            	caIDSetToFetchAnnouncement.add(ar.Client_Avail__c);
            }
        }
        
        
        if(caIDSetToFetchAnnouncement.size() > 0){
        	caAnnouncementMap = new Map<Id,Client_Avail__c>([SELECT Id,(Select  createddate From Announcement_Client_Avails__r Where Announcement__r.Selection_Criteria__c != 'Active Full Extract' AND Announcement__r.Selection_Criteria__c != 'AFE' AND Announcement__r.Selection_Criteria__c != 'Master Avails List' AND Announcement__r.Selection_Criteria__c != 'MAL' AND Announcement__r.Internal__c = null Order by createddate Limit 1) 
                                            FROM Client_Avail__c  WHERE id IN :caIDSetToFetchAnnouncement]);
        }
        //fetch all client Avail 
        for(List<Client_Avail__c> caList : [SELECT id,Announce_Override__c,Change_Context__c,First_Announcement_Date__c 
                                            FROM Client_Avail__c
                                            WHERE id IN :clientAvailId]){
            for(Client_Avail__c ca: caList){
            	Boolean isDateAssigned = false;
            	if(ca.First_Announcement_Date__c == null && caAnnouncementMap != null && caAnnouncementMap.get(ca.Id) != null){
            		if(caAnnouncementMap.get(ca.Id).Announcement_Client_Avails__r != null && caAnnouncementMap.get(ca.Id).Announcement_Client_Avails__r.size() > 0){
            			DateTime createdDateTime = caAnnouncementMap.get(ca.Id).Announcement_Client_Avails__r[0].createddate;
            			ca.First_Announcement_Date__c = Date.newInstance(createdDateTime.year(),createdDateTime.month(),createdDateTime.day());
            			isDateAssigned = true;
            		}
            	}
            	
                if(ca.Announce_Override__c != '' || ca.Announce_Override__c != null || ca.Change_Context__c != '' || ca.Change_Context__c != null || isDateAssigned){
                	ca.Announce_Override__c = ''; // Reset to Blank
                	ca.Change_Context__c = '';
                	caToUpdate.add(ca);
                }
            }
        } 
        Database.update(caToUpdate,false);
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('WB_UpdateAOOnCABatchProcess  is completed');
    }
    
}