/*------------------------------------------------------------
Author:        Cognizant Technology Solution
Company:       Cognizant Technology Solution
Class Name:    WB_DeleteMALARRecs 
Description:   This class deletes the AR records created in MAL.
Test Class:    WB_DeleteMALARRecsTest
History:
<Date>      <Authors Name>     <Brief Description of Change>
05/10/2017    Sriniz            ER-000993 - Initial Version

------------------------------------------------------------*/
global class WB_DeleteMALARRecs implements Database.Batchable<sObject>{
    
    global Id lstAnnouncementTypeId; //Announcement Id need to process
    
    global WB_DeleteMALARRecs(Id AnnouncementTypeId){
        lstAnnouncementtypeId = AnnouncementTypeId;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        //query to fetch all the ARs associated with a MAL Announcement
        String Query = 'SELECT id,Client_Avail__c '+
                         'FROM Announcement_Record__c '+
                        'WHERE Announcement__r.Announcement_Type__c = :lstAnnouncementtypeId AND Change_Status__c = null';
        return Database.getQueryLocator(query);

    }
    
    global void execute(Database.BatchableContext BC, List<Announcement_Record__c> scope){
        
        Database.delete(scope, false);
        
    }
    
    global void finish(Database.BatchableContext BC){
        System.debug('WB_DeleteMALARRecs  is completed');
    }
    
}