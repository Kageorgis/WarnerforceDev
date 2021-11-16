/*------------------------------------------------------------
Author:        CAS Team
Company:       Cognizant.com
Description:   A utility class for the contact trigger
Inputs:        "Customers" - Contact objects that are being triggered
               "oldCustomers" - Contacts object values before trigger event
               "ta" - Trigger action that is occurring
Test Class:    CustomerManagement_Test
History
<Date>      <Authors Name>     <Brief Description of Change>
3-JAN-2021	Dennis Cho			ER-2897:  Email report to digital clients
------------------------------------------------------------*/

global without sharing class WB_ECAnnouncementProcess_Batch implements Database.Batchable<sObject>,Schedulable,database.stateful 
 {
     
    public Id announementId ;
    List<ECLMTriggerFields__c> lstecTriggerFields; 
    List<EC_Account_Allocation__c> lstECAllocation; 
    Public EC_Announcment__c ecAnnouncment;
    final String FULL='Full';
    final String DELTA='Delta';
    final String CHANGED='Change';
    final String FINALIZED='Finalized Only';
    final string STATUS_FINALIZED='Finalized';
    final String EC_READ_STATUS_FIELD='EC Readiness Status';
    public boolean IsFinalized= false;

    global void execute(SchedulableContext ctx) {
       WB_CreateECAnnouncements_CC wcreateAnn = new WB_CreateECAnnouncements_CC();
       wcreateAnn.selectAnnouncementType();  ////ER-00918 - ECLM: Run EC Announcements twice a day - As a part of this ER new method is invoked.
    }
    
    global WB_ECAnnouncementProcess_Batch (){ 
    }
    global WB_ECAnnouncementProcess_Batch ( Id announementId){ 
            this.announementId =announementId;
            lstecTriggerFields = ECLMTriggerFields__c.getall().values();
            lstECAllocation = new list<EC_Account_Allocation__c>();
    }

    global Database.QueryLocator start(Database.BatchableContext BC){ 
        
        ecAnnouncment = [SELECT id, 
                            Release_Type__c,
                            Name,Report_Name__c,
                            Selection_Criteria__c,
                            Sent_Date__c,
                            Chatter_Group_ID__c,ECAnnouncement_Type__c,ECAnnouncement_Type__r.name
                           FROM EC_Announcment__c
                           WHERE  Id =:announementId];
        Set<String> streleaseType = new Set<String>();
        for(String ct : ecAnnouncment.Release_Type__c.split(';')){
            streleaseType.add(ct);
        }
        String query = 'SELECT ID FROM EC_Account_Allocation__c '
                         +' WHERE Release_Type__c in :streleaseType' ;
        
        
         return Database.getQueryLocator(query);
       }

    global void execute(Database.BatchableContext BC, list<EC_Account_Allocation__c> scope){
        
        List<ECAnnouncment_Record__c> lstECAR = new List<ECAnnouncment_Record__c>();
        String parentFields = 'id ,';
        String childFields = 'id ,';
        String query;
        for(ECLMTriggerFields__c trgFields : lstecTriggerFields){
             parentFields= parentFields+ trgFields.ParentField__c + ',';
         }
        //parentFields= parentFields.substring(1, parentFields.length()); //Remove the last Comma
        for(ECLMTriggerFields__c trgFields : lstecTriggerFields){
             childFields= childFields+ trgFields.ChildField__c+ ',';
         }
        childFields= childFields.substring(0, childFields.length()-1); //Remove the last Comma
        
        Id ecAnnTypeId = ecAnnouncment.ECAnnouncement_Type__c;
        query = 'SELECT '+parentFields+' (SELECT '+childFields ;
        query = query +' FROM ECAnnouncment_ECAccount_Records__r WHERE ECAnnouncment__r.ECAnnouncement_Type__c =:ecAnnTypeId AND createddate != today ORDER BY '; //Added where condition for SINC1223217 
        query = query +'createddate DESC Limit 1) FROM EC_Account_Allocation__c  WHERE Id in :scope';
        System.debug(LoggingLevel.INFO,'query :'+query );
        lstECAllocation = Database.query(query) ;
        
        for(EC_Account_Allocation__c  ecAllocation: lstECAllocation ){
            if(ecAllocation.ECAnnouncment_ECAccount_Records__r.size() < 1 ){
                ECAnnouncment_Record__c ecAnnounceRecords = new ECAnnouncment_Record__c();
                ecAnnounceRecords.ECAnnouncment__c = ecAnnouncment.id;
                ecAnnounceRecords.EC_Account_Allocation__c= ecAllocation.id;
                ecAnnounceRecords.Change_Status__c = 'New';
                lstECAR.add(ecAnnounceRecords); 
             }else {
                if(ecAnnouncment.Selection_Criteria__c==FULL){
                    ECAnnouncment_Record__c ecAnnounceRecords = new ECAnnouncment_Record__c();
                    ecAnnounceRecords = compareLastAndFromDates(ecAllocation,ecAnnouncment);
                    lstECAR.add(ecAnnounceRecords); 
                }else if (ecAnnouncment.Selection_Criteria__c==DELTA || ecAnnouncment.Selection_Criteria__c==FINALIZED){
                    ECAnnouncment_Record__c ecAnnounceRecords = new ECAnnouncment_Record__c();
                    ecAnnounceRecords = compareLastAndFromDates(ecAllocation,ecAnnouncment);
                    if(ecAnnounceRecords.Change_Status__c==CHANGED) {
                        lstECAR.add(ecAnnounceRecords); 
                    }
                }/*else if (ecAnnouncment.Selection_Criteria__c==FINALIZED){            //Commented for ER-1615
                    ECAnnouncment_Record__c ecAnnounceRecords = new ECAnnouncment_Record__c();
                    ecAnnounceRecords = compareLastAndFromDates(ecAllocation,ecAnnouncment);
                    //Check if the change status = changed 
                    // check if the change field is a "EC Readiness Status" 
                    // check the current EC Account allocation field = Finalized 
                    // then only create a annoucemt rec.
                     if(ecAnnounceRecords.Change_Status__c==CHANGED && 
                     //ecAnnounceRecords.Changed_Fields__c.contains(EC_READ_STATUS_FIELD)       commented for ER-1615
                        ecAllocation.EC_Readiness_Status__c ==STATUS_FINALIZED )
                     {
                        lstECAR.add(ecAnnounceRecords);   
                        IsFinalized = true;
                     }
                }*/
             }
        }// End of for loop lstECAllocation
        System.debug(LoggingLevel.INFO,'ECAnnouncment_Record__c ===: ' + lstECAR.size());
        if(lstECAR != Null && lstECAR.size()>0){
            List<String> errorMessages = new List<String>();
            String errorMessageValue = '';
            Database.Saveresult[] saveResult_CActivity = Database.insert(lstECAR, false);   
            if(saveResult_CActivity != Null && saveResult_CActivity.size()>0){
                for(Database.Saveresult rec : saveResult_CActivity){
                    String errorMessage = '';
                    if(!rec.isSuccess()){
                        List<Database.Error> errors = rec.getErrors();
                        for(Database.Error er : errors){
                            errorMessage += er.getMessage();
                        }
                        errorMessages.add(errorMessage);
                    }
                }
            }
            
            if(errorMessages.size() > 0){
                for(String errorValue : errorMessages){
                    if(errorMessageValue == ''){
                        errorMessageValue += errorValue;
                   }else if(!errorMessageValue.equals(errorMessageValue)){
                        errorMessageValue += ''+errorValue;
                   }
                        
                }
                createErrorLog(null,ecAnnouncment,errorMessageValue);
            }
        }
    }
    
    private ECAnnouncment_Record__c compareLastAndFromDates(
                     EC_Account_Allocation__c ecAARec,EC_Announcment__c annID){
         ECAnnouncment_Record__c ecARRec = new ECAnnouncment_Record__c ();
         for(ECAnnouncment_Record__c annRecOnAA : ecAARec.ECAnnouncment_ECAccount_Records__r){
            ecARRec = compareChange(ecAARec,annRecOnAA,annID.Id);
            break;
         }
         return ecARRec;
    }
    
    private ECAnnouncment_Record__c compareChange(
            SObject ecAARec,SObject ecARRRec,Id annId){
         ECAnnouncment_Record__c ecARRec = new ECAnnouncment_Record__c ();
         ecARRec.Change_Status__c = '';
         ecARRec.Changed_Fields__c = '';
         for(ECLMTriggerFields__c trgFields : lstecTriggerFields){
            
             String parentVal = String.valueOf(ecAARec.get(trgFields.ParentField__c));
             String childVal = String.valueOf(ecARRRec.get(trgFields.ChildField__c));
             if(parentVal!=childVal ){
                 ecARRec.ECAnnouncment__c= annId;
                 ecARRec.EC_Account_Allocation__c = (Id)ecAARec.get('id');
                 ecARRec.Change_Status__c='Change';
                 ecARRec.Changed_Fields__c=ecARRec.Changed_Fields__c+','+trgFields.Label__c;
             }
         }
         if(ecARRec.Change_Status__c == '' || ecARRec.Change_Status__c == NULL ){
             ecARRec.ECAnnouncment__c = annId;
             ecARRec.EC_Account_Allocation__c= (Id)ecAARec.get('id');
             ecARRec.Change_Status__c = 'No Change';
         } else {
              ecARRec.Changed_Fields__c = ecARRec.Changed_Fields__c.substring
                                        (1, ecARRec.Changed_Fields__c.length());  
         }
         return ecARRec;
    }
    
    
    global void finish(Database.BatchableContext BC){
          // 3 Tasks in finish - updating status in Announcement, updating last run date in announcement Type, and post to chatter 
        try{
        
            If(ecAnnouncment != null){
                 ecAnnouncment.Job_Run_Status__c = 'Completed';
                 update ecAnnouncment;
            }
            List<EC_AnnouncementType__c> ecAnnTypeList = [Select id, 
                                                Date_Last_Run__c,
                                                Report_Template__c,
                                                Chatter_Group_ID__c,
                                                Email__c,
                                                Client__c,
                                                Job_Processing_Status__c
                                                from EC_AnnouncementType__c  
                                                where id = :  ecAnnouncment.ECAnnouncement_Type__c limit 1]; 
            system.debug(LoggingLevel.INFO,'In batch Class printing ecanntypeList --<>' +ecAnnTypeList);   
            EC_Announcment__c annNew = [SELECT Announcement_Record_Count__c,Selection_Criteria__c  FROM EC_Announcment__c where id=:ecAnnouncment.id];                                             
            If(ecAnnTypeList.size()>0 && annNew.Announcement_Record_Count__c > 0)
            {
                
                ecAnnTypeList[0].Date_Last_Run__c = date.today();
                ecAnnTypeList[0].Job_Processing_Status__c = null;
                update  ecAnnTypeList;
                
                //Post Report Link to Chatter Group
                /*Check if the AnnType=Finalized and has finalized data then onl
                post to change */
                //if(!(annNew.Selection_Criteria__c==FINALIZED && IsFinalized==false)){     //Commented for ER-1615
                    
                String reportId=ecAnnouncment.Report_Name__c;
                String ecAnnName=ecAnnouncment.Name;
                String destEmail=ecAnnTypeList[0].Email__c;
                String client=ecAnnTypeList[0].Client__c;
                Integer g = 0;
                /*--------------------ER-1615- Start------------------------*/
                if(!test.isRunningTest()){
                    Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportId);
                    Reports.ReportMetadata reportMd = describe.getReportMetadata();
                    //Reports.ReportFilter filter = reportMd.getReportFilters()[1];
                    //filter.setValue(ecAnnName);
                    List<Reports.ReportFilter> filters = reportMd.getReportFilters();
                    for (Reports.ReportFilter f:filters) {
                        //system.debug(f.getcolumn());
                        if (f.getcolumn() == 'ECAnnouncment_Record__c.ECAnnouncment__c.Name') {
                           f.setValue(ecAnnName);
                        }
                        if (f.getcolumn() == 'EC_Account_Allocation__c.Account__c.Name' && client!=null) {
                           f.setValue(client);
                        }   
                    }
                    Reports.ReportResults reportResults = Reports.ReportManager.runReport(reportId, reportMd,true);
                    Reports.ReportFactWithDetails factWithDetails = (Reports.ReportFactWithDetails) reportResults.getFactMap().get('T!T');
                    Reports.SummaryValue sumVal = factWithDetails.getAggregates()[0];
                    Decimal x=(Decimal)sumVal.getValue();
                    g=(Integer) x;
                }
                system.debug('before : '+g);
                createErrorLog(null,ecAnnouncment,('Report Count : '+string.valueOf(g)));
                if(g == 0 || g == null){
                    g = checkCountBySOQLQuery(ecAnnouncment.ECAnnouncement_Type__r.name,ecAnnName);
                }
                system.debug('after: '+g);
                
                /*--------------------ER-1615- End----------------------------*/
                if(g!=0 || test.isRunningTest()){
                    // ER-2897
                    if (destEmail!=null){
                        WB_ECAnnouncementProcess_SendEmail sendEmail = new WB_ECAnnouncementProcess_SendEmail(reportId, ecAnnName, destEmail, client);
						System.enqueueJob(sendEmail);
                    }
                    
                    if (ecAnnTypeList[0].Chatter_Group_ID__c != null){
                        FeedItem post = new FeedItem();
                        post.ParentId = ecAnnTypeList[0].Chatter_Group_ID__c;   //Chatter Group ID
                        post.title = label.EC_Announcement_Report_Link; // name of Report Link 
                        String url = System.URL.getSalesforceBaseURL().toExternalForm();
                        //post.LinkUrl =  url + '/' + ecAnnTypeList[0].Report_Template__c+'?pv1=' +ecAnnouncment.Name;
                        /*--------------------WBTINC0112695- Start----------------------------*/
                        post.LinkUrl =  url + '/lightning/r/report/' + ecAnnTypeList[0].Report_Template__c+'/view?fv1=' +ecAnnouncment.Name;
                        /*--------------------WBTINC0112695- End----------------------------*/
                        insert post;                         
                    }
                }
        //        }     //Commented for ER-1615
           }
           
          //ER - 793
         //send Job information to users via email
         BatchStatusNotification batchNotification = new BatchStatusNotification();
         AsyncApexJob jobInfo = [SELECT Status,TotalJobItems,NumberOfErrors,ExtendedStatus 
                                 FROM AsyncApexJob 
                                 WHERE Id=:BC.getJobID()];
         if(jobInfo != NULL)
            batchNotification.sendEmailToUsers(Label.Entity_CAS,'EC Announcement Process',jobInfo.Status,jobInfo.TotalJobItems,jobInfo.NumberOfErrors,jobInfo.ExtendedStatus);
            
        }catch(Exception e){
            System.debug(LOGGINGLEVEL.INFO,'Stack Trace -> '+e.getStackTraceString());
            system.debug(LoggingLevel.INFO,'Exception in working with EC Announcement Exception Reason: '+e);
            createErrorLog(e,ecAnnouncment,Null);
        }
    }
    
    public static void createErrorLog(Exception error,EC_Announcment__c ecRec,String errorMessage){
        List<WB_CAS_ErrorLogger.ErrorLog> errorLogs = new List<WB_CAS_ErrorLogger.ErrorLog>();
         WB_CAS_ErrorLogger.ErrorLog errorLogInstance = new  WB_CAS_ErrorLogger.ErrorLog();
         errorLogInstance.recordId = ecRec.Id;
         errorLogInstance.errorCategory = 'ECLM Announcement Error';
         if(error!= Null){
             errorLogInstance.errorDescription = error.getMessage().left(252);
             errorLogInstance.errorDescriptionLong = error.getStackTraceString(); 
         }else if(errorMessage != Null && errorMessage != ''){
             errorLogInstance.errorDescription = errorMessage.left(252);
             errorLogInstance.errorDescriptionLong = errorMessage; 
         }
         
         errorLogInstance.objectName = ecRec.Id.getSObjectType().getDescribe().getName();
        // errorLogInstance.account = ca.Client__c;
         errorLogs.add(errorLogInstance);
         WB_CAS_ErrorLogger.logError(errorLogs);
    }
    
    //Get the report count by query the EC Announcement Records using filer logic added in custom metadata
    public static integer checkCountBySOQLQuery(string ecATName,string ecAnnName){
        List<EC_Announcement_Report__mdt> ecReports = [Select Id,Filter_Logic__c,Change_Fields_Status_Check__c From EC_Announcement_Report__mdt Where MasterLabel = :ecATName];
        if(!ecReports.isEmpty()){
            if(ecReports[0].Change_Fields_Status_Check__c){
                Integer i = 0;
                String strQ = 'Select Id,Change_Status__c,Changed_Fields__c From ECAnnouncment_Record__c Where '+ecReports[0].Filter_Logic__c+' AND ECAnnouncment__r.Name = :ecAnnName';
                String changeFields = ecReports[0].Filter_Logic__c.containsIgnoreCase('EC_Readiness_Status__c') ? 'EC Readiness Status' : 'EC Status';
                for(ECAnnouncment_Record__c er : database.query(strQ)){
                    if(er.Change_Status__c == 'New' || er.Changed_Fields__c.containsIgnoreCase(changeFields)){
                        i++;
                        break;
                    }
                }
                return i;
            }else{
                String strQ = 'Select count() From ECAnnouncment_Record__c Where '+ecReports[0].Filter_Logic__c+' AND ECAnnouncment__r.Name = :ecAnnName';
                return Database.countQuery(strQ);
            } 
        }
        return 0;
    }
              
     
}