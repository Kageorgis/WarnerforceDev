/*------------------------------------------------------------
Description:   Queueable class to send out email for EC Announcement.  This class is called from WB_ECAnnouncementProcess_Batch
History
<Date>      <Authors Name>     <Brief Description of Change>
3-JAN-2021	Dennis Cho			ER-2897:  Email report to digital clients
------------------------------------------------------------*/

public class WB_ECAnnouncementProcess_SendEmail implements Queueable, Database.AllowsCallouts {
    private String ReportId;
    private String ecAnnName;
    private String destEmail;
    private String client;
    
    public WB_ECAnnouncementProcess_SendEmail (String ReportId, String ecAnnName, String destEmail, String client) {
        this.ReportId = ReportId;
        this.ecAnnName = ecAnnName;
        this.destEmail = destEmail;
        this.client = client;
    }
    public void execute(QueueableContext context) {
        List<Messaging.SingleEmailMessage> lstEmail = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        List< Messaging.EmailFileAttachment> lstAttachment = new List< Messaging.EmailFileAttachment>();
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        Blob content;
        if (client==null){client='';}
        ApexPages.PageReference report = new ApexPages.PageReference('/' + ReportId + '?pv1=' + ecAnnName + '&pv6=' + client + '&excel=1&isdtp=p1');
        //System.debug('---report--'+ report);
        if(Test.isRunningTest()){
            content = blob.valueOf('Unit.Test');
        }else{
            content = report.getContent();
        }
        String cdate = String.valueOf(Datetime.now().format('yyyy-MM-dd'));
        attachment.setFileName('WB_EC_Announcement_' + cdate + '.xls');
        attachment.setBody(content);
        attachment.setContentType('application/vnd.ms-excel');    // application/vnd.ms-excel or text/csv
        //System.debug('---attachment--'+ attachment);
        lstAttachment.add(attachment);
        message.setFileAttachments(lstAttachment);
        message.setSubject('WB EC Announcement ' + cdate + ' ' + client);
        message.setPlainTextBody('Hello,' + '\n' + '\n' + 'Please see attached EC Metadata.' + '\n' + '\n' + 'Once confirmed, please place an order request with your service rep for any Extras Content needed.' + '\n' + '\n' + 'Any questions should be directed to your service rep and WBContentServicing@warnerbros.com.' + '\n' + '\n' + 'Thanks.');
        List<String> lstAddresses = destEmail.split(',');
        message.setToAddresses(lstAddresses);   
        lstEmail.add(message);
        if(!lstEmail.isEmpty() && !Test.isRunningTest()){
            Messaging.sendEmail(lstEmail);
            System.debug('Send --'+ message); 
        }               
    }
    
}