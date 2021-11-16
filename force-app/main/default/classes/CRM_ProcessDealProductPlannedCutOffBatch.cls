global with sharing class CRM_ProcessDealProductPlannedCutOffBatch implements Database.batchable<sObject>, Database.stateful {
    
    global final List<CRM_ProcessDealProductsBatchException> lstExceptions = new List<CRM_ProcessDealProductsBatchException>();
    global final Set<Id> setErrorDealPIds = new Set<Id>();
    /**
     *  Start method of Batch
     *  @name start
     *  @return  Query locator  - returning the records from query string
     */
    global Database.queryLocator start(Database.BatchableContext BC) {
        Set<Id> setDealRecordTypes = new Set<Id>{CRM_RecordTypeUtil.RT_DEAL_DIGITAL, CRM_RecordTypeUtil.RT_DEAL_PHYSICAL, CRM_RecordTypeUtil.RT_DEAL_HIGH_LEVEL};
        
        String query =' SELECT Id,NR_Cut_Off_Date__c,Is_Planned_Cut_Off_Qauntity_Updated__c,Planned_Quantity_at_Cut_Off_Date__c,Quantity,Opportunity.StageName'+
                      ' FROM OpportunityLineItem '+
                       ' WHERE Opportunity.StageName !='+ '\'' + CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED + '\''+
                       ' AND Opportunity.StageName !='+ '\'' + CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED + '\' AND Opportunity.RecordTypeId IN :setDealRecordTypes AND(' +
                          // Germany US 308 - Start                      
                           '(Is_Planned_Cut_Off_Qauntity_Updated__c = false AND NR_Cut_Off_Date__c <= Today ) OR (Is_Planned_Cut_Off_Qauntity_Updated__c = true AND NR_Cut_Off_Date__c > Today))'+
                           ' AND Product2.Street_Date__c > LAST_N_WEEKS:52';

                      
        System.debug('query-->'+query); 
        
        return Database.getQueryLocator(query);
        
        /*return Database.getQueryLocator([SELECT Id,NR_Cut_Off_Date__c,Is_Planned_Cut_Off_Qauntity_Updated__c,Planned_Quantity_at_Cut_Off_Date__c,Quantity,Opportunity.StageName 
              FROM OpportunityLineItem WHERE Opportunity.StageName != :CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED 
              AND Opportunity.StageName != :CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED AND((Is_Planned_Cut_Off_Qauntity_Updated__c = false AND NR_Cut_Off_Date__c <= Today ) OR (Is_Planned_Cut_Off_Qauntity_Updated__c = true AND NR_Cut_Off_Date__c > Today) OR 
              (Is_Planned_Cut_Off_Qauntity_Updated__c = false AND NR_Cut_Off_Date__c > Today) OR
              (Is_Planned_Cut_Off_Qauntity_Updated__c = true AND NR_Cut_Off_Date__c <= Today))]);*/
    }

    /**
     * Execute method of Batch
     * @name execute
     * @param OpLineItem- For storing the records returned from Start method
     */
    global void execute(Database.BatchableContext BC, List<OpportunityLineItem> OpLineItem) {
      
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        Map<Id,OpportunityLineItem> mapDealProductsToUpdate = new Map<Id,OpportunityLineItem>();      
                
        try {
            // Germany US 308 - Start            
            for (OpportunityLineItem objDealProd : OpLineItem){
                if(!objDealProd.Is_Planned_Cut_Off_Qauntity_Updated__c && objDealProd.NR_Cut_Off_Date__c <= System.today()){
                    objDealProd.Planned_Quantity_at_Cut_Off_Date__c = objDealProd.Quantity;
                    objDealProd.Is_Planned_Cut_Off_Qauntity_Updated__c = true;                   
                    if(!mapDealProductsToUpdate.containsKey(objDealProd.id)){
                        mapDealProductsToUpdate.put(objDealProd.Id,objDealProd); 
                    }
                }
                if (objDealProd.Is_Planned_Cut_Off_Qauntity_Updated__c && objDealProd.NR_Cut_Off_Date__c > System.today()){    
                    objDealProd.Is_Planned_Cut_Off_Qauntity_Updated__c = false;
                    if(!mapDealProductsToUpdate.containsKey(objDealProd.id)){
                         mapDealProductsToUpdate.put(objDealProd.Id,objDealProd); 
                    }
                }
            }
            if(!mapDealProductsToUpdate.isEmpty()){
                Database.SaveResult[] saveResultList = Database.update(mapDealProductsToUpdate.values(), false);
                List<OpportunityLineItem> lstUpdatedDealProds =mapDealProductsToUpdate.values();     
                for (Integer i = 0; i < saveResultList.size(); i++) {
                    Database.SaveResult saveResultInstance = saveResultList[i];
                    OpportunityLineItem DPInsatnce = lstUpdatedDealProds[i];
                    if (!saveResultInstance.isSuccess()) {
                        this.setErrorDealPIds.add(DPInsatnce.Id);
                        // Add these errors in Error wrapper Class and prepare a list of same
                        // Error Handling
                        List<String> lstErrors = new List<String>();
                        for(Database.Error err : saveResultInstance.getErrors()) {
                            lstErrors.add(err.getMessage());

                            // Save the error in database
                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.recordId = DPInsatnce.Id;
                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_UPDATE_PRODUCT_FOR_SCHEDULE_DATE;
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }
                        this.lstExceptions.add(
                            new CRM_ProcessDealProductsBatchException(
                                DPInsatnce.Id,
                                lstErrors
                            )
                        );
                    }
                }           
            }
          // Germany US 308 - End            
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
        
        //List<Product2> lstProduct = new  List<Product2>(); -- Commented as part of AL-000371
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        
        // Inserts all errors into database
        CRM_ErrorLogger.logError(listErrorLog);

        // Send mail only if errors present
        if (!this.lstExceptions.isEmpty()){
            map<Id,OpportunityLineItem> opLineitemMap = new map<Id,OpportunityLineItem>([SELECT Id, Name FROM OpportunityLineItem WHERE Id IN: setErrorDealPIds LIMIT 50000]);
            sendMail(opLineitemMap);
        }else{
            BatchStatusNotification.sendBatchStatusMail(BC, System.Label.CRM_Process_Deal_Planned_Qty_CutOff_Batch_Mail_Subject);
        }
    } 
    
    /**
     * @Description - Method to send mail to logged in User for all the failure details of processed deals
     * @name sendMail
     */
    @TestVisible
    private void sendMail(map<Id,OpportunityLineItem> mapIdToDealPInstance) {

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
        mail.setSubject(System.Label.CRM_Process_Deal_Planned_Qty_CutOff_Batch_Mail_Subject);
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

        for (CRM_ProcessDealProductsBatchException excp : this.lstExceptions) {
            body += '<tr>';
            if(excp.recordId != null){
                if(mapIdToDealPInstance.containsKey(excp.recordId) && mapIdToDealPInstance.get(excp.recordId).Name != null){
                    body += '<td rowspan=\'' + excp.lstErrors.size() + '\'><a href=' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '>' + mapIdToDealPInstance.get(excp.recordId).Name + '</a></td>';
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
        errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_PROCESS_DEAL_PRODUCT_UPDATE;
        errorLog.errorMessage = e.getMessage().left(200);
        errorLog.stackTrace = e.getStackTraceString();
        listErrorLog.add(errorLog);

        //Adding Exception
        this.lstExceptions.add(
            new CRM_ProcessDealProductsBatchException(
                null,
                lstErrors
            )
        );
        return listErrorLog;
    }

    /**
     * @Description - Class for Exception Handling
     * @name CRM_ProcessDealProductsBatchException
     */
    public class CRM_ProcessDealProductsBatchException extends Exception {
        public Id recordId;
        public List<String> lstErrors;
        public CRM_ProcessDealProductsBatchException(Id recordId, List<String> lstErrors){
            this.recordId = recordId;
            this.lstErrors = lstErrors;
        }
    }

    
}