/*
Class Name   : WB_CreateAnnoncements 
Description  : This will be used by newly written Scheduler to call batch class and send annoucmements               
Created By   : Cognizant Technology Solutions - Manish/ Shekhar Vinayak
Created On   : Aug 2015

Change History:
-------------------------------------------------------------------------------------------------------------------------------------
Sr#              Description                                               Updated By                                     Updated On
-------------------------------------------------------------------------------------------------------------------------------------
1              [Change Type]                                 Cognizant Technology Solutions - [Developer Name]           [MM/DD/YYYY]

CH01   Added logic to update Processing to null if record             Prachi Gadewar                                       9/8/2015
       is holding processing values more than 2 houre                         
*/



global class WB_CreateAnnouncements{

    public List<Announcement_Rule__c> announcementTypeList=new List<Announcement_Rule__c>();// list of selected Announcement Types list
    public List<Announcement_Rule__c> announcementTypeFinalList=new List<Announcement_Rule__c>();
    public Set<ID> setAnnoucementTypeIds = new Set<ID>();
    public Map<Id,List<Announcement_Receipient__c>> mapAnnoucementTypeRecepeients = new Map<Id,List<Announcement_Receipient__c>>();
    integer intMaxRecsForBatch;
    
    global void selectAnnouncementRecords(){
    
     
    Set<ID> accountSet=new Set<ID>();
    
    DateTime dt=System.now();
     DateTime dt1;
    
    if(test.isRunningTest())
   
     { 
        dt1 =System.now();   
     }
    else
     {
      dt1 =System.now().addhours(-2);
         
     }
    // CH01
    List<Announcement_Rule__c> listProcessingAnnTypes = new List<Announcement_Rule__c>();
    for(Announcement_Rule__c annType : [Select id,Job_Processing_Status__c from Announcement_Rule__c where Job_Processing_Status__c = 'Processing' 
                                        and LastModifiedDate <=: dt1
                                        and Active__c = true
                                        AND Disposition__c = 'Active']) // ER-617 : Added Disposition condition on 16/9/2016
    {
        annType.Job_Processing_Status__c = null;
        listProcessingAnnTypes.add(annType);
    }
    update listProcessingAnnTypes;
    
    /* New logic : ************
    1. First find Batch processes currently in queue in stages like 'processing', 'queued' etc.
    2. We already defined maximum number  of batch process that can be processed in custom label
    3. Substract 1 from 2 to get number of annocument records that can be picked by scheduler
    
    */
    
    integer countofBatchjobs =  [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing' or status = 'Queued' or status = 'Holding' )];
    
    If(countofBatchJobs != integer.valueOf(System.Label.WB_Maximum_Schedule_Jobs)) 
    { 
       intMaxRecsForBatch = integer.valueof(System.Label.WB_Maximum_Schedule_Jobs) - countofBatchJobs ; 
        
    }
    else // in  rare scenario, if max number of batches (say 50 defined in custom label) still in queue, then current schedular will not put any additional batches
    {
      intMaxRecsForBatch = 0;  
        
    }
    system.debug('intMaxRecsForBatch*****'+intMaxRecsForBatch);
    /* announcementTypeList =[SELECT id, name,Announcement_Type__c,Selection_Criteria__c,Date_Last_Run__c,
                            Account__c,Content_Type__c,Statuses__c,Channels__c,Country_Group__c,Report_ID__c,
                            Report_Template__c,Email_Template__c,createdDate,Account__r.Name,(select id,From_Date__c,Run_Date__c from Announcements__r order by createddate desc) FROM Announcement_Rule__c WHERE Weekly_Monthly_Schedule_Days__c = '6' AND Schedule_Time__c = '22'];
            
    */
     
     // New Query -as we just need to pass announcement Id. It has also new 'where clause'; also not finding need for subquery as present in above query, so rewriting this 
     announcementTypeList =[SELECT id, name,Announcement_Type__c,Selection_Criteria__c,Date_Last_Run__c,Announcement_Price_Type__c,
                            Account__c,Content_Type__c,Statuses__c,Channels__c,Country_Group__c,Report_ID__c,File_Format__c,Full_Extract__c,Announcement_Date_Format__c,Separate_Files_By_Contract__c,
                            Report_Template__c,Email_Template__c,createdDate,Account__r.Name,Optional_Triggers__c FROM Announcement_Rule__c
                            where Schedule_Date_And_Time__c <= : system.now() and Job_Processing_Status__c = null limit  :intMaxRecsForBatch ]; //Optional_Triggers__c Field added by Akash
            
    
     
    system.debug('*****Size of Announcement types'+announcementTypeList.size());
    if(announcementTypeList!=null && announcementTypeList.size()>0){
      system.debug('PRINTANNOCUMENTRECORD'); 
      For (Announcement_Rule__c an:announcementTypeList ) 
      {
       system.debug('ANNOUCMENTRECORDFORPROCESSING=' + an.name + 'ID= ' + an.id );   
      }
      //ER-1710
       for(Announcement_Rule__c type: announcementTypeList )
            setAnnoucementTypeIds.add(type.Id);
      for(Announcement_Receipient__c receipient: [Select Id,Email__c,Announcement_Type__c 
                                                from Announcement_Receipient__c 
                                                where Announcement_Type__c IN:setAnnoucementTypeIds]) {
         if(!mapAnnoucementTypeRecepeients.containsKey(receipient.Announcement_Type__c))
             mapAnnoucementTypeRecepeients.put(receipient.Announcement_Type__c,New List<Announcement_Receipient__c>());
             mapAnnoucementTypeRecepeients.get(receipient.Announcement_Type__c).add(receipient);
      }
      //#END_OF_ER-1710
      createAnnouncementRecords(announcementTypeList);
   }

}

global void createAnnouncementRecords(List<Announcement_Rule__c> AnnouncementTypes){
   List<Announcement__c> announcementRecordsTobeCreated=new List<Announcement__c>();

   for(Announcement_Rule__c announcementRule:AnnouncementTypes){
  
          Announcement__c announcementRecord = new Announcement__c();
          String strReceipientEmail = '';
          announcementRecord.Announcement_Type__c= announcementRule.Id;
          announcementRecord.Account__c= announcementRule.Account__c;
          announcementRecord.Selection_Criteria__c=announcementRule.Selection_Criteria__c;
          announcementRecord.Announcement_Price_Type__c = announcementRule.Announcement_Price_Type__c;
          announcementRecord.Content_Type__c=announcementRule.Content_Type__c;
          announcementRecord.Status__c=announcementRule.Statuses__c;
          announcementRecord.Channels__c=announcementRule.Channels__c;
          announcementRecord.File_Format__c=announcementRule.File_Format__c;
          announcementRecord.File_Status__c='TBD';
          announcementRecord.Country_Group__c=announcementRule.Country_Group__c;
          announcementRecord.Report_Id__c=announcementRule.Report_ID__c;
          announcementRecord.Report_Name__c=announcementRule.Report_Template__c;
          announcementRecord.Email_Template__c=announcementRule.Email_Template__c;
          announcementRecord.Job_Run_Status__c='In Progress';
          announcementRecord.Full_Extract__c=announcementRule.Full_Extract__c;
          announcementRecord.Announcement_Date_Format__c=announcementRule.Announcement_Date_Format__c;
          announcementRecord.Selected_Fields__c = announcementRule.Optional_Triggers__c;    //Added by Akash
		  announcementRecord.Separate_Files_By_Contract__c = announcementRule.Separate_Files_By_Contract__c;
          dateTime dt=Datetime.now(); 
            
            if(dt != null){
                String strConvertedDate = dt.format('yyyy-MM-dd');             
                announcementRecord.Name__c   = announcementRule.Announcement_Type__c + ' ' + strConvertedDate; //-- commented by Rashmi*/
            }
            //else
               // announcementRecord.Name__c   = announcementRule.Announcement_Type__c;
               
             //ER-1710
            if(mapAnnoucementTypeRecepeients.get(announcementRule.Id) != NULL){
                
                List<Announcement_Receipient__c> lstReceipients = mapAnnoucementTypeRecepeients.get(announcementRule.Id);
                for(Announcement_Receipient__c receipient: lstReceipients){
                    if(receipient.Email__c != '' || receipient.Email__c != NULL)
                        strReceipientEmail += receipient.Email__c+';';
                }
                strReceipientEmail = strReceipientEmail.removeEnd(';');
                strReceipientEmail = strReceipientEmail.trim();
            }
            announcementRecord.Recipient_Emails__c = strReceipientEmail;
            //#END ER-1710
            announcementRecordsTobeCreated.add(announcementRecord);
            announcementRule.Job_Processing_Status__c = 'Processing';
            //ER-993 start 
            //Delete previous MAL AR records. Commented below on 03/07 as per SINC1540368
            /*if(announcementRule.Selection_Criteria__c == 'Master Avails List' || announcementRule.Selection_Criteria__c == 'MAL')
                Id batchInstanceId1 = Database.executeBatch(new WB_DeleteMALARRecs(announcementRule.Id), 200);
            */      
            //ER-993 End
     }
      

    if(announcementRecordsTobeCreated != null && announcementRecordsTobeCreated.size() > 0){
    	List<Announcement_Trigger_Field__c> annFields = [Select Id,Name,Changed_Field__c,Changed_Status__c,Destination_API__c,Destination_Object__c,Source_API__c,Source_Object__c,Trigger_Status__c,TV__c,Feature__c FROM Announcement_Trigger_Field__c];
        try{
            update AnnouncementTypes;
            Database.Saveresult[] saveResult  = Database.insert(announcementRecordsTobeCreated,false);
            
            for(Database.Saveresult annInsertedRec: saveResult)
            {
                if(annInsertedRec.isSuccess())
                    //annoucementIds.add(annInsertedRec.id); 
                    //Create client activity
                    Id batchInstanceId = Database.executeBatch(new WB_ClientActivitiesBatchProcess1 (annInsertedRec.id,AnnouncementTypes,annFields), 200); 
                     
             
            }
          
       }
       catch(DmlException dmlex){
           System.debug('The following exception has occurred: ' + dmlex.getMessage());
           System.debug('Exception has occurred at this line number ' + dmlex.getLineNumber());
       }
           
           
                         
    } // if block where checking announcementRecordCreateList list is not empty     
         

}

}