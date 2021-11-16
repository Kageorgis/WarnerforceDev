/**
 * Written by: Preeti Jha(CTS)
 * Description: This Batch class is used to send the daily report of request refreshed Rights data to perticular user belonging to a Group.
 * Project: CRRT (Phase 4-B) 
 * history : updated by hari 03/09/2017  for ER-001728 - Add 'Date Last Changed' field to ‘Daily Rights Refreshed’ Report
**/
public class WB_BatchSchedule_RequestRefreshedRights implements Database.Batchable<sObject>, Database.Stateful{ 

    String query = '';
    String finalstr = '';
    Integer totalRightsCount =0;
    Integer attachedRightsCount =0;
     
    
    public WB_BatchSchedule_RequestRefreshedRights(){
        finalstr = 'Date Last Changed, Record Type,VBOM Count,Source,Title/MPM Description,VV/MPM , Rights Group, Channel, Status, Reason Code, Cosmos Results, Notes, Rights Start 1, Rights  End 1, Rights Start 2, Rights End 2, Rights Start 3, Rights  End 3, Rights Start 4, Rights End 4, Rights Start 5, Rights End 5, Request Refresh, Last Refresh Requested Date, Last Refresh Requested By, Last Modified Date, Last Modified By,Rights ID \n';
    }
    
    // updated by hari 03/09/2017  for ER-001728 - Add 'Date Last Changed' field to ‘Daily Rights Refreshed’ Report
    public Database.QueryLocator start(Database.BatchableContext BC){
        query = 'Select Id,Name,VV_MPM__c,RecordType.Developername,VBOM_Count__c,Title_MPM_Description__c, Channel__c, MPM_Short_Description__c, MPM__c,MPM__r.Name, Notes__c, Rights_End__c, Rights_Group__c,'
                +' Rights_Start__c,Status__c, Key__c, Source__c, Request_Refresh__c, Last_Refresh_Requested_Date__c, Last_Refresh_Requested_By__c,Date_Last_Changed__c, LastModifiedDate, LastModifiedBy.Name,'
                +' Request_Legal_Review__c, Rights_Query_Start_Date__c, Rights_Start_2__c, Rights_End_2__c,'
                +' Rights_Start_3__c, Rights_End_3__c, Rights_Start_4__c, Rights_Start_5__c, Rights_End_5__c, Rights_End_4__c,'
                 +' Reason_Code__c,Last_Refresh__c,Cosmos_Notes__c,LastModifiedBy.Profile.Name FROM Rights__c'
                +' WHERE LastModifiedDate = Yesterday ORDER BY LastModifiedDate ';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Rights__c> scope){
        // Total Rights records Last Modified yesterday count calculation
        totalRightsCount= totalRightsCount+ scope.size();
        if(scope != null && scope.size() > 0){
            for(Rights__c ryts: scope){
                if(Limits.getHeapSize() <= 2500000){
                    finalstr = finalstr + getStringForCSV(ryts);
                    attachedRightsCount++;
                }else{
                    break;
                }    
            }
        }
    }
    
    public String getStringForCSV(Rights__c rights){
        
        String Last_Refresh_Requested_Date = rights.Last_Refresh_Requested_Date__c != null ? rights.Last_Refresh_Requested_Date__c.format() : String.ValueOf(rights.Last_Refresh_Requested_Date__c);
        String Right_Start = rights.Rights_Start__c != null ? rights.Rights_Start__c.format() : String.ValueOf(rights.Rights_Start__c);
        String Right_End = rights.Rights_End__c != null ? rights.Rights_End__c.format() : String.ValueOf(rights.Rights_End__c);
        String Right_Start2 = rights.Rights_Start_2__c != null ? rights.Rights_Start_2__c.format() : String.ValueOf(rights.Rights_Start_2__c);
        String Right_End2 = rights.Rights_End_2__c != null ? rights.Rights_End_2__c.format() : String.ValueOf(rights.Rights_End_2__c);
        String Right_Start3 = rights.Rights_Start_3__c != null ? rights.Rights_Start_3__c.format() : String.ValueOf(rights.Rights_Start_3__c);
        String Right_End3 = rights.Rights_End_3__c != null ? rights.Rights_End_3__c.format() : String.ValueOf(rights.Rights_End_3__c);
        String Right_Start4 = rights.Rights_Start_4__c != null ? rights.Rights_Start_4__c.format() : String.ValueOf(rights.Rights_Start_4__c);
        String Right_End4 = rights.Rights_End_4__c != null ? rights.Rights_End_4__c.format() : String.ValueOf(rights.Rights_End_4__c);
        String Right_Start5 = rights.Rights_Start_5__c != null ? rights.Rights_Start_5__c.format() : String.ValueOf(rights.Rights_Start_5__c);
        String Right_End5 = rights.Rights_End_5__c != null ? rights.Rights_End_5__c.format() : String.ValueOf(rights.Rights_End_5__c);
        String DateLstChg = rights.Date_Last_Changed__c != null ? rights.Date_Last_Changed__c.format() : String.ValueOf(rights.Date_Last_Changed__c);
      
        string recordString = '"'+DateLstChg+'","'  
            +rights.RecordType.Developername+'","'
            +rights.VBOM_Count__c+'","'
            +rights.Source__c+'","'
            +rights.Title_MPM_Description__c+'","'
            +rights.VV_MPM__c+'","'
            +rights.Rights_Group__c+'","'
            +rights.Channel__c+'","'
            +rights.Status__c+'","'
            +rights.Reason_Code__c+'","'             
            +rights.Cosmos_Notes__c+'","'
            +rights.Notes__c+'","'                
            +Right_Start+'","'
            +Right_End+'","'
            +Right_Start2+'","'
            +Right_End2+'","'
            +Right_Start3+'","'
            +Right_End3+'","'
            +Right_Start4+'","'
            +Right_End4+'","'
            +Right_Start5+'","'
            +Right_End5+'","'
            +rights.Request_Refresh__c+'","'
            +Last_Refresh_Requested_Date+'","'
            +rights.Last_Refresh_Requested_By__c+'","'
            +rights.LastModifiedDate+'","'
            +rights.LastModifiedBy.Name+'","'
            +rights.Name +'","'
           +'"\n';
        
        string record = recordString.replace('null', '');
        return record;
    }
    
    public void finish(Database.BatchableContext BC){
        CAS_Global_Settings__c globalConfig = CAS_Global_Settings__c.getValues('CAS Global Settings');
        string OWD_EMAIL_ADDRESS =  globalConfig.Global_Email__c;
        system.debug('OWD_EMAIL_ADDRESS'+OWD_EMAIL_ADDRESS);
        List<OrgWideEmailAddress> lstOwea = new List<OrgWideEmailAddress>([SELECT Id 
                                    FROM OrgWideEmailAddress 
                                    WHERE Address=:OWD_EMAIL_ADDRESS limit 1]);
        
        OrgWideEmailAddress owea = (lstOwea != null && lstOwea.size() > 0) ? lstOwea[0] : null;
        AsyncApexJob asyncApex = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ExtendedStatus
                                    from AsyncApexJob where Id = :BC.getJobId()];
       
        DateTime dT = System.now();
        dt = dt.addDays(-1);
        // Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        string csvName = 'Rights Records Last Modified on '+String.valueOf(dt.format('MM-dd-YYYY'))+ '.csv';
        String messageBody = '<html><body>A request refresh has been requested for the records on the attached report.<p> Total count of Rights Record Modified on '+String.valueOf(dt.format('MM-dd-YYYY'))+ '='+ + totalRightsCount +'</p>';
        messageBody += '<p>Total record count on the attached report ='+attachedRightsCount+'</p>';
        messageBody +=' <Br>If the daily refresh request record size exceeds 2MB, please retrieve the complete report by clicking on the  link below.<p>'+System.Label.Refreshed_Rights_Report+'</p></body></html>';
        
        if(finalstr != '')                  
            sendEmailFunctionality(finalstr,'Rights Records Last Modified on '+String.valueOf(dt.format('MM-dd-YYYY')),messageBody,asyncApex,csvName,owea);
    
    }
    
    public List<string> getEmailAddresses(){
        List<String> mailToAddresses = new List<String>();
        list<id> idList = new List<id>();
        List<RequestRefreshSchedular__c> publicGroupName = RequestRefreshSchedular__c.getall().values();
        string publicGroup = publicGroupName[0].Value__c;
        List<Group> PGroup = new List<Group>([SELECT (select userOrGroupId from groupMembers) FROM group WHERE name =: publicGroup]);
        
        for (GroupMember gm : PGroup[0].groupMembers) {
        idList.add(gm.userOrGroupId);
        }
        User[] usr = [SELECT email FROM user WHERE id IN :idList];
        for(User u : usr) {
            mailToAddresses.add(u.email);
        }
        return mailToAddresses;
        
    }
    public void sendEmailFunctionality(string finalstr, string strSubject, string strBody, AsyncApexJob a, string csvFilename,OrgWideEmailAddress owea){        
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(finalstr);
        string csvname= csvFilename;
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        
        // Email the Batch Job's submitter that the Job is finished.
        String[] toAddresses = new String[] {a.CreatedBy.Email};
            
        String subject = strSubject;
        email.setSubject(subject);
        email.setToAddresses( getEmailAddresses());
        if(owea != null)
            email.setOrgWideEmailAddressId(owea.Id);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        email.setHtmlBody(strBody); 
        //email.setPlainTextBody(strBody);
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }   
}