/**
 * @Author: Aditi Satpute
 * @name CRM_ProcessDealsBatch
 * @CreateDate 4th Oct 2016
 * @Description: Batch class to reset UpdateScheduleDates flag on deal
 * @Version 1.0
 */
global with sharing class CRM_ProcessDealsBatch implements Database.batchable<sObject>, Database.stateful {

    global final Set<Id> setProductIDs;
    //global final Set<Id> setCommittedDealIds;
    global final List<CRM_ProcessDealsBatchException> lstExceptions = new List<CRM_ProcessDealsBatchException>();

    global CRM_ProcessDealsBatch(Set<Id> setProcessedProductIDs) {
        this.setProductIDs = setProcessedProductIDs;
        System.debug('-CRM_ProcessDealsBatch---this.setProductIDs-->'+this.setProductIDs);
    }

    /**
     *  Start method of Batch
     *  @name start
     *  @return  Query locator  - returning the records from query string
     */
    global Database.queryLocator start(Database.BatchableContext BC) {
        String query ='';
        if (this.setProductIDs != null && this.setProductIDs.size() > 0) {
            query =   ' SELECT Id, RecalculateSchedules__c,Recalculate_Production_Cost__c,ProductFormatUpdated__c'
            		+ ' FROM Product2'
                    + ' WHERE Id IN: setProductIDs';
        }
        System.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }

    /**
     * Execute method of Batch
     * @name execute
     * @param scopeOpportunityLineItem- For storing the records returned from Start method
     */
    global void execute(Database.BatchableContext BC, List<Product2> listProducts) {

        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        System.debug('-CRM_ProcessDealsBatch---listProducts.size()-->'+listProducts.size());
        List<Product2> listProductsToUpdate = new List<Product2>();
        
        try {
			if (!listProducts.isEmpty() && listProducts.size() > 0) {

                for (Product2 product : listProducts) {
                	if(product.RecalculateSchedules__c == true 
                		|| product.Recalculate_Production_Cost__c == true 
                		|| product.ProductFormatUpdated__c == true) {
                			
                		product.RecalculateSchedules__c = false;
                		product.Recalculate_Production_Cost__c = false;
                		product.ProductFormatUpdated__c = false;
                		
                		listProductsToUpdate.add(product);
                	}
                }
				if(!listProductsToUpdate.isEmpty()) {
					Database.SaveResult[] saveResultList =  Database.update(listProductsToUpdate, false);
					
	                for (Integer i = 0; i < saveResultList.size(); i++) {
	                    Database.SaveResult saveResultInstance = saveResultList[i];
	                    Product2 prodInstance = listProductsToUpdate[i];
	                    if (!saveResultInstance.isSuccess()) {
	
	                        // Add these errors in Error wrapper Class and prepare a list of same
	                        // Error Handling
	                        List<String> lstErrors = new List<String>();
	                        for(Database.Error err : saveResultInstance.getErrors()) {
	                            lstErrors.add(err.getMessage());
	
	                            // Save the error in database
	                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
	                            errorLog.recordId = prodInstance.Id;
	                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_UPDATE_PRODUCT_FOR_SCHEDULE_DATE;
	                            errorLog.errorMessage = err.getMessage().left(200);
	                            listErrorLog.add(errorLog);
	                        }
	                        this.lstExceptions.add(
	                            new CRM_ProcessDealsBatchException(
	                                prodInstance.Id,
	                                lstErrors
	                            )
	                        );
	                    }
	                }
				}
            }
        } catch (Exception e) {
            listErrorLog.addAll(logAnException(e));
        }

        // Inserts all errors into database
        CRM_ErrorLogger.logError(listErrorLog);
    }

    /**
     * Finish method of batch process.
     */
    global void finish(Database.BatchableContext BC) {
        System.debug('-CRM_ProcessDealsBatch---this.lstExceptions.size()-->'+this.lstExceptions.size());
        // Send mail only if errors present
        if (!this.lstExceptions.isEmpty()){
            List<Product2> lstAllProducts = [SELECT Id, Name FROM Product2 WHERE Id IN: setProductIDs LIMIT 50000];
            sendMail(new Map<Id, Product2>(lstAllProducts));
        }else{
            BatchStatusNotification.sendBatchStatusMail(BC, System.Label.CRM_Process_Deals_Batch_Mail_Subject);
        }
    } 
    
    /**
     * @Description - Method to send mail to logged in User for all the failure details of processed deals
     * @name sendMail
     */
    @TestVisible
    private void sendMail(Map<Id, Product2> mapIdToProduct2Instance) {

        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();
        /* Ankita: Commented the changes for Sending mail to CRM users only 
            sendTo.add(UserInfo.getUserEmail()); 
        */
        //Get emailIds from Custom setting
        sendTo = BatchStatusNotification.getBatchNotificationRecipients(CRM_AppConstants.Entity_CRM);
        if(!sendTo.isEmpty()) {
            mail.setToAddresses(sendTo);
        }

        // Step 3: Set who the email is sent from
        mail.setReplyTo(UserInfo.getUserEmail());
        mail.setSenderDisplayName(System.Label.CRM_Process_Deal_Products_Batch_Mail_Display_Name);
        //mail.setSenderDisplayName('Update Schedule Dates Batch');

        // Step 4. Set email contents!
        mail.setSubject(System.Label.CRM_Process_Deals_Batch_Mail_Subject);
        //mail.setSubject('Failure List of Deals failed to process');

        String body = '';
        body = '<html>';
        body += '<body>';
        body += '<table border = 1>';
        body += '<tr>';
        body += '<th>' + System.Label.CRM_Process_Deal_Products_Batch_Record_Column_Name + '</th>';
        // body += '<th>' + 'Record Details' + '</th>';
        body += '<th>' + System.Label.CRM_Failure_Message_Column_Name + '</th>';
        body += '</tr>';

        for (CRM_ProcessDealsBatchException excp : this.lstExceptions) {
            body += '<tr>';
            if(excp.recordId != null){
                if (mapIdToProduct2Instance.containsKey(excp.recordId) && mapIdToProduct2Instance.get(excp.recordId).Name != null) {
                    body += '<td rowspan=\'' + excp.lstErrors.size() + '\'><a href=' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '>' + mapIdToProduct2Instance.get(excp.recordId).Name + '</a></td>';
                }else {
                    body += '<td rowspan=\'' + excp.lstErrors.size() + '\'><a href=' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '>' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '</a></td>';
                }
            }else{
                body +='<td></td>';
            }
            body += '<td>' + excp.lstErrors[0] + '</td>';
            body += '</tr>';
            if (excp.lstErrors.size() > 1) {
               body += '<tr>';
               for (Integer i = 1; i < excp.lstErrors.size(); i++) {
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

    /*
    *  This method will take the exception occured as an input and forward it to the common utility class. 
    *  @name: logAnException
    *  @param: Exception ex
    *  @return: List<CRM_ErrorLogger.ErrorLog> 
    */
    @TestVisible
    private List<CRM_ErrorLogger.ErrorLog> logAnException(Exception e){
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        List<String> lstErrors = new List<String>();
        lstErrors.add(e.getMessage());

        // Save the error in database
        CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
        errorLog.lineNumber = String.valueOf(e.getLineNumber());
        errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_PROCESS_DEAL_UPDATE;
        errorLog.errorMessage = e.getMessage().left(200);
        errorLog.stackTrace = e.getStackTraceString();
        listErrorLog.add(errorLog);

        //Adding Exception
        this.lstExceptions.add(
            new CRM_ProcessDealsBatchException(
                null,
                lstErrors
            )
        );
        return listErrorLog;
    }

    /**
     * @Description - Class for Exception Handling
     * @name CRM_ProcessDealsBatchException
     */
    global class CRM_ProcessDealsBatchException extends Exception {
        public Id recordId;
        public List<String> lstErrors;
        public CRM_ProcessDealsBatchException(Id recordId, List<String> lstErrors){
            this.recordId = recordId;
            this.lstErrors = lstErrors;
        }
    }
}