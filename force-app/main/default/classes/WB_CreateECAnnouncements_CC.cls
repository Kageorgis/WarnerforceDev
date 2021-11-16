/*-----------------------------------------------------------------------------
Author:        Cognizant CAS Team
Company:       Cognizant.com
Description:   A Class responsible for create EC Announcement. This class will
               be called by a scheduler. This class will do the following 
               activityis.
               Read all the Announcment Type Active records
               Check the Intervals with current date. If it passed 
               it will create a Announcment records and call the batch process.
Inputs:        None
Test Class:    WB_CreateECAnnouncements_CC_Test
History
<Date>      <Authors Name>     <Brief Description of Change>
-----------------------------------------------------------------------------*/

public class WB_CreateECAnnouncements_CC 
{
    
    public List<EC_Announcment__c> lstAnnouncment;

    public void WB_CreateECAnnouncements_CC() {
        lstAnnouncment = new List<EC_Announcment__c>();
    }
    
    //ER-00918 - ECLM: Run EC Announcements twice a day - As a part of this ER new method is added.
    public void selectAnnouncementType(){
        
        Datetime dateTimeNow = System.now();
        Datetime dateTimePrevious;
        Integer intMaxRecsForBatch;
        List<EC_AnnouncementType__c> ecAnnTypeList = new List<EC_AnnouncementType__c>();
        
        if(test.isRunningTest()){ 
            dateTimePrevious = System.now();   
        }else{
            dateTimePrevious = System.now().addhours(-2);
        }
        
        List<EC_AnnouncementType__c> processingECAnnTypesList = new List<EC_AnnouncementType__c>();
        for(EC_AnnouncementType__c ecAnnTypeRec : [Select id,Job_Processing_Status__c from EC_AnnouncementType__c where Job_Processing_Status__c = 'Processing' 
                                        and LastModifiedDate <=: dateTimePrevious
                                        and Active__c = true]){
            ecAnnTypeRec.Job_Processing_Status__c = Null;
            processingECAnnTypesList.add(ecAnnTypeRec);
        }
        
        if(processingECAnnTypesList != Null && processingECAnnTypesList.size()>0){
            update processingECAnnTypesList;
        }
        
        Set<String> statusSet = new Set<String>{'Processing','Preparing','Queued','Holding'};
        Integer batchJobsCount = [Select count() FROM AsyncApexJob WHERE JobType ='BatchApex' AND Status IN:statusSet];
        
        if(batchJobsCount != integer.valueOf(System.Label.WB_Maximum_Schedule_Jobs)){ 
            intMaxRecsForBatch = integer.valueof(System.Label.WB_Maximum_Schedule_Jobs) - batchJobsCount ; 
        }else {
            intMaxRecsForBatch = 0;  
        }
        
        ecAnnTypeList = [SELECT Chatter_Group_ID__c,Date_Last_Run__c,ECAnnouncement_Type__c,Release_Type__c,Selection_Criteria__c,Report_Template__c,Id FROM EC_AnnouncementType__c
                                                    WHERE Active__c=true AND EC_Schedule_Date_And_Time__c <= : dateTimeNow AND (Job_Processing_Status__c = Null OR Job_Processing_Status__c ='') LIMIT  :intMaxRecsForBatch];
        system.debug(LoggingLevel.INFO,'ecAnnTypeList:'+ecAnnTypeList);
                                                    
        CreateECAnnouncment(ecAnnTypeList);                                                    
        
        
    }

    public void CreateECAnnouncment(List<EC_AnnouncementType__c> lstAnnType){
        lstAnnouncment = new List<EC_Announcment__c>();
        List<EC_AnnouncementType__c> lstAnnTypeToUpdate = new List<EC_AnnouncementType__c>();
        
        if(lstAnnType != Null && lstAnnType.size()>0){
            for(EC_AnnouncementType__c annType : lstAnnType){
                //if(annType.Date_Last_Run__c != NULL){
                    Date today = Date.today();
                    /*ER-00918 - As part of this ER, lofic related to Intervals Days is removed.
                    Integer  actualInterval = annType.Date_Last_Run__c.Date().daysBetween(Date.today()); 
                    System.debug('Expected : '+annType.Intervals_Days__c);
                    System.debug('Actual : '+actualInterval);       
                    if(actualInterval  > annType.Intervals_Days__c) { */
                        EC_Announcment__c announcment =  new EC_Announcment__c();
                        announcment.Chatter_Group_ID__c = annType.Chatter_Group_ID__c;
                        announcment.Report_Name__c= annType.Report_Template__c;
                    
                        announcment.ECAnnouncement_Type__c= annType.Id;
                        announcment.Selection_Criteria__c= annType.Selection_Criteria__c;
                        announcment.Release_Type__c= annType.Release_Type__c; 
                        announcment.Job_Run_Status__c='In Progress';
                        announcment.Run_Date__c = System.now();
                        String strConvertedDate = Datetime.now().format('yyyy-MM-dd');  
                        announcment.Announcement_Name__c = annType.ECAnnouncement_Type__c+ ' ' +strConvertedDate ;
                        lstAnnouncment.add(announcment);
                        annType.Date_Last_Run__c = Date.today();
                        annType.Job_Processing_Status__c = 'Processing';
                        lstAnnTypeToUpdate.add(annType);
                    //}//End of If
               // }
            }//End of for loop
            if(lstAnnouncment!=null && lstAnnouncment.size() > 0){
              saveAnnouncment(lstAnnouncment,lstAnnTypeToUpdate);
            }
        }
        
        
        //Calling the batch process to generate Announcment Records.
    
    
    }
    
    @TestVisible
    private void saveAnnouncment(List<EC_Announcment__c> lstAnnouncment,
                            List<EC_AnnouncementType__c> lstAnnTypeToUpdate){
        //Inserting the Announcement records in the database.
     
            Database.SaveResult[] srList = Database.insert(lstAnnouncment, false);
            Database.update(lstAnnTypeToUpdate,false);
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record 
                    //that was processed
                    System.debug(LoggingLevel.INFO,'Successfully inserted Announcement ID: ' 
                                                                + sr.getId());
                    
                    //Create client activity
                    Database.executeBatch(new WB_ECAnnouncementProcess_Batch(sr.getId()), 100); 
             
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(LoggingLevel.INFO,'The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug(LoggingLevel.INFO,'Announcement fields that affected r: ' 
                                                            + err.getFields());
                    }
                }
            }
        
    }
    
    public Datetime calculateDateForWeekly(Integer nextRunDay, String nextRunTime,Map<String,Integer> mapDays)
    {
        Integer currentDay = mapDays.get(DateTime.now().format('EEEE'));
        Integer nextRunTimeInt = Integer.ValueOf(nextRunTime);
        Integer countAddDays = Math.MOD((7 - currentDay + nextRunDay),7);
        if(countAddDays == 0 && system.now().hour() > nextRunTimeInt)
            countAddDays += 7;                
        Date nextRunDate = system.today()+countAddDays;
        DateTime nextRunDateTime = DateTime.newInstance(nextRunDate.year(), nextRunDate.month(), nextRunDate.day(), nextRunTimeInt, 0, 0);
        return nextRunDateTime;
    }
    
    /*
    private void startComparisonBatch(List<EC_Announcment__c> lstAnnouncment){
            
    
    }
    */
}