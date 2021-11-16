global with sharing class CRM_DatabaseErrorHandlerForRBA {
  
   /*
    *  This method will take the exception occured as an input and forward it to the common utility class. 
    *  @name: logAnException
    *  @param: Exception ex
    *  @return: List<CRM_ErrorLogger.ErrorLog> 
    */
    @TestVisible
    public static List<CRM_ErrorLogger.ErrorLog> 
        logAnException(Exception e){
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        // Save the error in database
        CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
        errorLog.lineNumber = String.valueOf(e.getLineNumber());
        errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_PROCESS_DEAL_UPDATE;
        errorLog.errorMessage = e.getMessage().left(200);
        errorLog.stackTrace = e.getStackTraceString();
        listErrorLog.add(errorLog);
        return listErrorLog;
    }  
    
   /**
     * @Description - Method to send mail to logged in User for all the failure details of processed deals
     * @name sendMail
     */
    @TestVisible
    public static void sendMail(List<CRM_ProcessAccountBatchForRBA.CRM_ProcessAccountsBatchForRBAException> lstExceptions) {
         // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();

        //Get emailIds from Custom setting
        sendTo = BatchStatusNotification.getBatchNotificationRecipients(CRM_AppConstants.Entity_CRM);
        if(!sendTo.isEmpty()) {
        mail.setToAddresses(sendTo);
        }

        // Step 3: Set who the email is sent from
        mail.setReplyTo(UserInfo.getUserEmail());
        mail.setSenderDisplayName(System.Label.CRM_Process_Accounts_For_RBA);
        //mail.setSenderDisplayName('RBA Deal Creation Batch');

        // Step 4. Set email contents!
        mail.setSubject(System.Label.CRM_Process_Accounts_For_RBA_Mail_Subject);
        //mail.setSubject('Failure List of Accounts failed to process');

        String body = '';
        body = '<html>';
        body += '<body>';
        body += '<table border = 1>';
        body += '<tr>';
        body += '<th>' + System.Label.CRM_Process_Accounts_For_RBA_Mail_Subject+ '</th>';
        // body += '<th>' + 'Record Details' + '</th>';
        body += '<th>' + System.Label.CRM_Failure_Message_Column_Name + '</th>';
        body += '</tr>';

        for (CRM_ProcessAccountBatchForRBA.CRM_ProcessAccountsBatchForRBAException excp : lstExceptions) {
            body += '<tr>';
            if(excp.recordId != null){
               
                    body += '<td rowspan=\'' + excp.lstErrors.size() + '\'><a href=' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '>' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '</a></td>';
                }
             else{
                body +='<td></td>';
            }
            body += '<td>' + excp.lstErrors[0] + '</td>';
            body += '</tr>';
            if (excp.lstErrors.size() > 1) {
               body += '<tr>';
               for (Integer excpError = 1; excpError < excp.lstErrors.size(); excpError++) {
                    body += '<td>' + excp.lstErrors[excpError] + '</td>';
               }
               body += '</tr>';
            }
        }
        body += '<table>';
        body += '</body>';
        body += '</html>';
        mail.setHtmlBody(body);

        // Step 6: Send all emails in the master list
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }  
}