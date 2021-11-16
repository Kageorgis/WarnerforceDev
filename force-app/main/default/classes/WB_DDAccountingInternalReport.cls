public class WB_DDAccountingInternalReport{
    
    @future(callout=true)
    public static void executeReport(){
        
        List<Messaging.SingleEmailMessage> theEmails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        Map<Id,List<Announcement_Record__c>> annRec = new Map<Id,List<Announcement_Record__c>>();
        List<Messaging.EmailFileAttachment> emailFileAttachment = new List<Messaging.EmailFileAttachment>();
        Boolean changeNewFlag = false;
        Boolean noChangeFlag = false;
        String bodyValue; 
        String[] emails= Label.Email_IDs.split(';');
        Date dateValue;
        //ER-750 Start
        Date dateToday = Date.today();
        String sMonth = String.valueof(dateToday.month());
        String sDay = String.valueof(dateToday.day());
        if(sMonth.length()==1){
          sMonth = '0' + sMonth;
        }
        if(sDay.length()==1){
          sDay = '0' + sDay;
        }
        String sToday = String.valueof(dateToday.year()) + '-' + sMonth + '-' + sDay;
        set<String> statusValues = new set<String>{'New','Change','Price Start','Price End','Price Change'};
        //ER-750 End
        if(!test.isRunningTest())
            dateValue = system.today().addDays(-7);
        else
            dateValue = system.today().addDays(-1);
        String dateValueReport = dateValue.format();
        Organization org = [Select id,IsSandbox from Organization ];
        if(!org.isSandbox || Test.isRunningTest()){
            List<Announcement_Record__c> scopeChange = [Select Id,Sales_Channel__c,Client_Avail__c,Client_Avail__r.Release_Plan_Country__c,Country__c,Pre_Order_Date__c,Change_Status__c,Announcement__c from Announcement_Record__c where (CreatedDate >: dateValue AND Country__c IN ('USA','Canada')) and Change_Status__c in :statusValues LIMIT 1];  
            List<Announcement_Record__c> scopeNoChange = [Select Id,Sales_Channel__c,Client_Avail__c,Client_Avail__r.Release_Plan_Country__c,Country__c,Pre_Order_Date__c,Change_Status__c,Announcement__c from Announcement_Record__c where (CreatedDate >: dateValue AND Country__c IN ('USA','Canada')) and Change_Status__c = 'No Change' LIMIT 1];  
            
            if(scopeChange.size() > 0)
                 changeNewFlag = true;
            if(scopeNoChange.size() > 0)
                noChangeFlag = true;
            /*
            for(Announcement_Record__c ann_Record : scope){
                if(ann_Record.Change_Status__c!=null ){
                    
                    if(ann_Record.Change_Status__c == 'Change' ){
                        changeNewFlag = true;
                    }else if(ann_Record.Change_Status__c == 'No Change'){
                        noChangeFlag = true;
                    }else if(ann_Record.Change_Status__c == 'New'){
                        changeNewFlag = true;
                    }
                }
            }
            */
            
            if(changeNewFlag){
                ApexPages.PageReference report = new ApexPages.PageReference('/'+Label.WB_DD_Accounting_Internal_Report_ChangeValuesID+'?pv0='+dateValueReport+'&pv1='+Label.WB_ChangeStatus+'&pv2='+Label.WB_Report_Countries+'&csv=1');
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('Announcement Records – New Change_CSV - '+sToday+'.csv');  //Rename file name for ER - 750
                if(!Test.isRunningTest()){
                    attachment.setBody(report.getContent());
                }else{
                   Blob body = Blob.valueof('Test');
                    attachment.setBody(body );
                }
                
                attachment.setContentType('text/csv');
                emailFileAttachment.add(attachment);
                       
            }
            if(noChangeFlag){
                ApexPages.PageReference report = new ApexPages.PageReference('/'+Label.WB_DD_Accounting_Internal_Report_NoChangeID+'?pv0='+dateValueReport+'&pv1='+Label.WB_NoChangeStatus+'&pv2='+Label.WB_Report_Countries+'&csv=1');
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('Announcement Records - No Change_CSV - '+sToday+'.csv');   //Rename file name for ER - 750
                if(!Test.isRunningTest()){
                    attachment.setBody(report.getContent());
                }else{
                   Blob body = Blob.valueof('Test');
                    attachment.setBody(body );
                }
                attachment.setContentType('text/csv');
                emailFileAttachment.add(attachment);
                      
            }
            
            if(emailFileAttachment!=null ){
                message.setFileAttachments(emailFileAttachment);
                message.setSubject(Label.WB_Report_Subject);
                message.setToAddresses( emails );
                if(changeNewFlag && noChangeFlag){  //Set body for Change Status = 'Change,New,No Change'
                    bodyValue = Label.WB_AllChangeValues_BodyContent;
                    system.debug('## BodyValue :'+bodyValue);
                    message.setPlainTextBody(bodyValue);
                    theEmails.add(message);
                }else if(noChangeFlag){ //Set body for Change Status = 'No Change'
                    bodyValue = Label.WB_AllChangeValues_BodyContent;
                    system.debug('## BodyValue :'+bodyValue);
                    message.setPlainTextBody(bodyValue);
                    theEmails.add(message);
                }else if(changeNewFlag){  //Set body for Change Status = 'Change,New'
                    bodyValue = Label.WB_AllChangeValues_BodyContent;
                    system.debug('## BodyValue :'+bodyValue);
                    message.setPlainTextBody(bodyValue);
                    theEmails.add(message);
                }
                    
            }
            Messaging.sendEmail( theEmails );
       }
       
   }
    
}