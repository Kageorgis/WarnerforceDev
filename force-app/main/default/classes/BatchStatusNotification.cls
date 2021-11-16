public class BatchStatusNotification{ 
    
   /**
     * @Description - Method to fetch Mail Recipients from custom setting : BatchNotificationRecipients
     * @name getBatchNotificationRecipients
    */  
    public static List<String> getBatchNotificationRecipients(String entityRecipient){
       //Get emailIds from Custom setting
        List<String> sendTo = new List<String>();
        List<Batch_Notification_Recipients__c> userDetails = Batch_Notification_Recipients__c.getAll().values(); 
        if(userDetails.size() > 0 ){
            for(Batch_Notification_Recipients__c e:userDetails){
                if(e.Entity__c.equals(entityRecipient)) {
                    sendTo.add(e.User_Email_Id__c);    
                }
            }
        }
        return sendTo;
    }
    
    /**
     * @Description - Method to fetch batch status and send status mail to the Custom Setting Specified User from the specified Batch Class
     * @name getBatchNotificationRecipients
    */
    public static void sendBatchStatusMail(Database.BatchableContext BC,String batchDescription){ 
        String strEntity = CRM_AppConstants.Entity_CRM;
        BatchStatusNotification objBatch = new BatchStatusNotification();
        AsyncApexJob asyncApexJob = [SELECT Id, Status,MethodName,NumberOfErrors,JobType, JobItemsProcessed, TotalJobItems, 
                                            CreatedBy.Email, ExtendedStatus 
                                            FROM AsyncApexJob 
                                            WHERE Id = :BC.getJobId()];  
        if(asyncApexJob != NULL){
            objBatch.sendEmailToUsers(strEntity,batchDescription,asyncApexJob.Status,
                                asyncApexJob.TotalJobItems,asyncApexJob.NumberOfErrors,asyncApexJob.ExtendedStatus);    
        }
    }
     
   public void sendEmailToUsers(String entity,String batchJobName,String Status, Integer totalJobItems,Integer noOfErrors, String errorMessage){
        List<String> toAddresses = new List<String>() ;
        //Get emailIds from Custom setting
        List<Batch_Notification_Recipients__c> userDetails = Batch_Notification_Recipients__c.getAll().values();
        
        if(userDetails.size() > 0 ){
            for(Batch_Notification_Recipients__c e:userDetails){
                if(e.Entity__c.equals(entity)) {
                    toAddresses.add(e.User_Email_Id__c);    
                }
            }
        }
        if(toAddresses.size() > 0){
            
            if(noOfErrors != 0)
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
                mail.setToAddresses(toAddresses);       
                mail.setSubject(batchJobName+' : ' + Status);   
                mail.setPlainTextBody('The batch Apex job processed ' + totalJobItems + 
                                                ' batches with '+ noOfErrors + ' failures. Message: ' + errorMessage);  
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
            }
            else{
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
                mail.setToAddresses(toAddresses);       
                mail.setSubject(batchJobName+' : ' + Status);   
                mail.setPlainTextBody('The batch Apex job processed ' + totalJobItems + 
                                                ' batches with '+ noOfErrors + ' failures. Message: Completed ');  
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
            }

        }
        
    }
       //DEF#4524
    public static void sendPDFErrorEmailToUsers(String Stack_Trace, String Message, Id errorId,String entity){
         List<String> toAddresses = new List<String>() ;
         String body = '';
         body = '<html>';
         body += '<body>';
         body += '<p>A new &nbsp;';
         body += '<a href =' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + errorId + '>' + 'CRM error log' + '</a>';
         body += '&nbsp; record is created.</p>';
         body += '<p>Stack Trace: ' + Stack_Trace + '</p>';
         body += '<p>Error message: ' + Message + '</p>';
         body += '<p> Thank You <br/><br/> </p> </body> </html> ';
         
        //Get emailIds from Custom setting
        List<Batch_Notification_Recipients__c> userDetails = Batch_Notification_Recipients__c.getAll().values();
        
        if(userDetails.size() > 0 ){
            for(Batch_Notification_Recipients__c e:userDetails){
                if(e.Entity__c.equals(entity)) {
                    toAddresses.add(e.User_Email_Id__c);                    
                }
            }
        }
        system.debug('*********body'+body);
         if(toAddresses.size() > 0){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
            mail.setToAddresses(toAddresses);       
            mail.setHtmlBody(body);  
            mail.setSubject(Label.CRM_error_record_Order_PDF_subject);   
        system.debug('*********mail'+mail);    
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }
    }
    
}