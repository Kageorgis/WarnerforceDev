/**
   @Author Cognizant
   @name CRM_SyncLocalTitleWithProductBatch
   @CreateDate 09 July 2020
   @Description batch class to update product name with local title and product market and product format.
   @Version <1.0>
   @reference Requirement no ER-003283 Incorrect digital product name
*/
global class CRM_SyncLocalTitleWithProductBatch implements Database.batchable<sObject>, Database.stateful{
    
    global String query = '';
    global final List<CRM_SyncLocalTitleWithProductBatchException> lstExceptions = new List<CRM_SyncLocalTitleWithProductBatchException>();
    global final Set<Id> setErrorProductIds = new Set<Id>();
    
    /**
    *  Start method of Batch
    *  @name start
    *  @return  Query locator  - returning the records from query string
    */
    global Database.queryLocator start(Database.BatchableContext BC){
        
        if(query == null || query == ''){
            query = 'SELECT Id,Name,ProductCode,Type__c,Release_Plan__c,Product_Market__c, Product_Format__c, Local_Title__c,'+
                        'Local_Title__r.Name,Is_Product_Name_change_required__c '+
                    'From Product2 '+
                    'Where Is_Product_Name_change_required__c = true';
        }
        System.debug('@@query-->'+query);
        return Database.getQueryLocator(query);
    }

    /**
    * Execute method of Batch
    * @name execute
    * @param products- For storing the records returned from Start method
    */
    global void execute(Database.BatchableContext BC, List<Product2> products){
        system.debug('@@products count-->'+products.size());
        
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        Map<Id,Product2> mapProductToUpdate = new Map<Id,Product2>();

        for(Product2 objProd : products){
            if(String.isNotEmpty(objProd.Product_Market__c) && String.isNotEmpty(objProd.Product_Format__c)){
                objProd.Name = objProd.Local_Title__r.Name +'('+ objProd.Product_Market__c + '/' + objProd.Product_Format__c + ')';
                if(!mapProductToUpdate.containsKey(objProd.Id)){
                    mapProductToUpdate.put(objProd.Id, objProd);
                }
            }else{
                this.setErrorProductIds.add(objProd.Id);
                
                CRM_ErrorLogger.ErrorLog errorLogBlankValue = new CRM_ErrorLogger.ErrorLog();
                errorLogBlankValue.recordId = objProd.Id;
                errorLogBlankValue.functionalModule = 'Sync Local Title Name with Product Name';
                errorLogBlankValue.errorMessage = System.Label.CRM_SyncLocalTitleWithProductNameBatch_BlankValue_ErrMsg;
                listErrorLog.add(errorLogBlankValue);
                
                this.lstExceptions.add(new CRM_SyncLocalTitleWithProductBatchException(objProd.Id,new List<String>{System.Label.CRM_SyncLocalTitleWithProductNameBatch_BlankValue_ErrMsg}));
            }
        }
        if(!mapProductToUpdate.isEmpty()){
            Database.SaveResult[] saveResultList = Database.update(mapProductToUpdate.values(), false);
            List<Product2> lstUpdatedProducts = mapProductToUpdate.values();     
            for(Integer i = 0; i < saveResultList.size(); i++){
                Database.SaveResult saveResultInstance = saveResultList[i];
                if(!saveResultInstance.isSuccess()){
                    Product2 prd = lstUpdatedProducts[i];
                    this.setErrorProductIds.add(prd.Id);
                    // Add these errors in Error wrapper Class and prepare a list of same
                    // Error Handling
                    List<String> lstErrors = new List<String>();
                    CRM_ErrorLogger.ErrorLog errorLog;
                    for(Database.Error err : saveResultInstance.getErrors()){
                        lstErrors.add(err.getMessage());

                        // Save the error in database
                        errorLog = new CRM_ErrorLogger.ErrorLog();
                        errorLog.recordId = prd.Id;
                        errorLog.functionalModule = 'Sync Local Title Name with Product Name';
                        errorLog.errorMessage = err.getMessage().left(200);
                        listErrorLog.add(errorLog);
                    }
                    this.lstExceptions.add(new CRM_SyncLocalTitleWithProductBatchException(prd.Id,lstErrors));
                }
            }
        }        
        
        // Inserts all errors into database
        CRM_ErrorLogger.logError(listErrorLog);
    }
    
    /**
    * Finish method of batch process.
    */
    global void finish(Database.BatchableContext BC){
        // Send mail only if errors present
        if(!this.lstExceptions.isEmpty()){
            map<Id,Product2> mapProductError = new map<Id,Product2>([SELECT Id, Name FROM Product2 WHERE Id IN: setErrorProductIds LIMIT 50000]);
            sendMail(mapProductError);
        }else{
            BatchStatusNotification.sendBatchStatusMail(BC, System.Label.CRM_SyncLocalTitleWithProductNameBatch_Success_Mail_Subject);
        }
    }
    
    /**
     * @Description - Method to send mail to logged in User for all the failure details of processed deals
     * @name sendMail
     */
    @TestVisible
    private void sendMail(map<Id,Product2> mapIdToProductInstance){
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
        mail.setSenderDisplayName(System.Label.CRM_SyncLocalTitleWithProductNameBatch_Mail_Display_Name);

        // Step 4. Set email contents!
        mail.setSubject(System.Label.CRM_SyncLocalTitleWithProductNameBatch_Failure_Mail_Subject);
        
        String body = '';
        body = '<html>';
        body += '<body>';
        body += '<table border = 1>';
        body += '<tr>';
        body += '<th>' + System.Label.CRM_NR_Batch_Products_Column_Name + '</th>';
        body += '<th>' + System.Label.CRM_Failure_Message_Column_Name + '</th>';
        body += '</tr>';

        for(CRM_SyncLocalTitleWithProductBatchException excp : this.lstExceptions){
            body += '<tr>';
            if(excp.recordId != null){
                if(mapIdToProductInstance.containsKey(excp.recordId) && mapIdToProductInstance.get(excp.recordId).Name != null){
                    body += '<td rowspan=\'' + excp.lstErrors.size() + '\'><a href=' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '>' + mapIdToProductInstance.get(excp.recordId).Name + '</a></td>';
                }else{
                    body += '<td rowspan=\'' + excp.lstErrors.size() + '\'><a href=' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '>' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '</a></td>';
                }
            }else{
                body +='<td></td>';
            }
            body += '<td>' + excp.lstErrors[0] + '</td>';
            body += '</tr>';
            if(excp.lstErrors.size() > 1){
                body += '<tr>';
                for(Integer i = 1; i < excp.lstErrors.size(); i++){
                    body += '<td>' + excp.lstErrors[i] + '</td>';
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

    /**
     * @Description - Class for Exception Handling
     * @name CRM_SyncLocalTitleWithProductBatchException
     */
    public class CRM_SyncLocalTitleWithProductBatchException extends Exception{
        public Id recordId;
        public List<String> lstErrors;
        public CRM_SyncLocalTitleWithProductBatchException(Id recordId, List<String> lstErrors){
            this.recordId = recordId;
            this.lstErrors = lstErrors;
        }
    }    
}