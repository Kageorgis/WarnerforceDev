/**
   @Author Komal Mehta & Aditi Satpute
   @name CRM_MoveCountryPlanTargetsBatch
   @CreateDate 23 May 2016
   @Description This Batch class is responsible for following functionality
                1. Automatic moving Country Plan Targets to appropriate GL Calenders whenever Product Street date Changes for both Physical and Digital
                2. Auto allocate Account Plan targets based on updated GL Calender
   @Version <1.0>
   @reference Requirement no 185
*/
global with sharing class CRM_MoveCountryPlanTargetsBatch implements Database.Batchable<sObject>, Database.stateful {

    global final String query;
    global final List<CRM_MoveCountryPlanTargetsService.CRM_MoveCountryPlanTargetsServiceException> lstExceptions =
        new List<CRM_MoveCountryPlanTargetsService.CRM_MoveCountryPlanTargetsServiceException>();
    global final Set<Id> setAllProductIds = new Set<Id>();

    /**
     * Batch constructor to assign query
     */
    global CRM_MoveCountryPlanTargetsBatch() {

        // Query for fetching 'New_Release' Country Plans for which Products having Update_Country_Plan_Targets__c = true
        this.query ='SELECT ' + 
                'Id, ' +
                'NR_Product__c' +
            ' FROM ' +
                'Country_Plan__c' +
            ' WHERE' +
                ' NR_Product__c != null' +
                ' AND NR_Product__r.Update_Country_Plan_Targets__c = true' +
                ' AND Street_Date__c != null' +
                ' AND RecordTypeId = \''+ CRM_RecordTypeUtil.RT_COUNTRY_PLAN_NEW_RELEASE + '\' ';
    }

    /**
     * Start method of batch to fetch all NR Product Country Plan records
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('------this.query------>'+this.query);
        return Database.getQueryLocator(this.query);
    }

    /**
     * Execute method of batch to process on NR Product Country Plan records
     *  1. Update Country Plan Targets with appropriate GL calendar
     *  2. Auto Allocate Account Plan Targets
     */
    global void execute(Database.BatchableContext BC, List<Country_Plan__c> countryPlanList) {
        System.debug('--countryPlanList-->'+countryPlanList);
        //US-997: Added additional fields in the query
        List<Country_Plan__c> countryPlansWithInnerQuery =
            [
                SELECT
                    Id, RecordType.DeveloperName, RecordTypeId, NR_Product__c, NR_Product__r.Type__c, NR_Product__r.Local_Title__r.Country__r.Country_Code2__c, Product_Group1__c,Street_Date__c,
                    (
                        SELECT
                            Id, Name, End_Date__c, Start_Date__c, GL_Calendar__c, Stretch_Target__c, Target__c, Country_Plan__c, Country_Plan__r.NR_Product__c,
                            GL_Calendar__r.Month__c, GL_Calendar__r.Year__c
                        FROM Country_Plan_Targets__r ORDER BY Start_Date__c
                    ),
                    (
                        SELECT 
                            Id, Name, CurrencyISOCode, Share__c, Total_Target__c, Product_Group__c, Customer__c
                        From Account_Plans__r
                    )
                FROM Country_Plan__c
                WHERE Id IN: countryPlanList AND NR_Product__c != null
                ORDER BY CreatedDate
            ];
        System.debug('--countryPlansWithInnerQuery-->'+countryPlansWithInnerQuery);
        lstExceptions.addAll(CRM_MoveCountryPlanTargetsService.processCountryPlanRecords(countryPlansWithInnerQuery,setAllProductIds));
    }

    /**
     * Finish method of batch process.
     * Reset the Products flag for which GL Calendar has been updated for Country Plan Targets and send mail if any errors present
     */
    global void finish(Database.BatchableContext BC) {
        List<Product2> updateProcessedProductList = new List<Product2>();
        Set<Id> setUnProcessedProductIds = new Set<Id>();
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();

        for (CRM_MoveCountryPlanTargetsService.CRM_MoveCountryPlanTargetsServiceException excp : this.lstExceptions) {
            if (excp.recordId != null) {
                setUnProcessedProductIds.add(excp.recordId);
            }
        }

        Map<Id, Product2> mapIdToProductInstance = new Map<Id, Product2>([
                SELECT
                    Id, Update_Country_Plan_Targets__c, Name
                FROM Product2
                WHERE Update_Country_Plan_Targets__c = true
                AND Id IN: setAllProductIds
        ]);

        for (Product2 productInstance : mapIdToProductInstance.values()) {
            if (productInstance.Update_Country_Plan_Targets__c && !setUnProcessedProductIds.contains(productInstance.Id)){
                productInstance.Update_Country_Plan_Targets__c = false;
                updateProcessedProductList.add(productInstance);
            }
        }

        listErrorLog.addAll(resetProcessedProductFlags(updateProcessedProductList));

        // Inserts all errors into database
        CRM_ErrorLogger.logError(listErrorLog);

        // Send mail only if errors present
        if (!this.lstExceptions.isEmpty()){
            sendMail(mapIdToProductInstance);
        }else{ 
            BatchStatusNotification.sendBatchStatusMail(BC,'Move Country Plan Targets Batch');
        }
    }

    /**
     * @Description - Method to reset the flags on Product for which GL Calendars are updated Properly on Country Plan Targets
     * @name resetProcessedProductFlags 
     * @param updateProcessedProductList - List of NR Products to be updated
     * @return List<CRM_ErrorLogger.ErrorLog> - List of Errors occured while updating Products
     */
    @TestVisible
    private List<CRM_ErrorLogger.ErrorLog> resetProcessedProductFlags(List<Product2> updateProcessedProductList){
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        if (!updateProcessedProductList.isEmpty()) {
            Database.SaveResult[] saveResultList =
                Database.update(updateProcessedProductList, false);
            for (Integer i = 0; i < saveResultList.size(); i++) {
                Database.SaveResult saveResultInstance = saveResultList[i];
                Product2 productInstance = updateProcessedProductList[i];

                if (!saveResultInstance.isSuccess()) {
                    // Add these errors in Error wrapper Class and prepare a list of same
                    // Error Handling
                    List<String> lstErrors = new List<String>();
                    for(Database.Error err : saveResultInstance.getErrors()) {
                        lstErrors.add(err.getMessage());

                        // Save the error in database
                        CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                        errorLog.recordId = productInstance.Id;
                        errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_MOVE_GL_CALENDAR_ON_COUNTRY_PLAN;
                        errorLog.errorMessage = err.getMessage().left(200);
                        listErrorLog.add(errorLog);
                    }
                    this.lstExceptions.add(
                        new CRM_MoveCountryPlanTargetsService.CRM_MoveCountryPlanTargetsServiceException(
                            productInstance.Id,
                            lstErrors
                        )
                    );
                }
            }
        }
        return listErrorLog;
    }

    /**
     * @Description - Method to send mail to logged in User for all the details of processed / non processed Country Plans
     * @name sendMail
     */
    @TestVisible
    private void sendMail(Map<Id, Product2> mapIdToProductInstance) {

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
        mail.setSenderDisplayName(System.Label.CRM_Move_Country_Plan_Target_Batch_Display_Name);

        // Step 4. Set email contents!
        mail.setSubject(System.Label.CRM_Move_Country_Plan_Target_Batch_Subject);

        String body = '';
        body = '<html>';
        body += '<body>';
        body += '<table border = 1>';
        body += '<tr>';
        body += '<th>' + System.Label.CRM_NR_Batch_Products_Column_Name + '</th>';
        body += '<th>' + System.Label.CRM_Failure_Message_Column_Name + '</th>';
        body += '</tr>';

        for (CRM_MoveCountryPlanTargetsService.CRM_MoveCountryPlanTargetsServiceException excp : this.lstExceptions) {
            System.debug('---excp------>'+excp);
            body += '<tr>';
            if(excp.recordId != null){
                if (mapIdToProductInstance.containsKey(excp.recordId) && mapIdToProductInstance.get(excp.recordId).Name != null) {
                   body += '<td rowspan=\'' + excp.lstErrors.size() + '\'><a href=' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '>' + mapIdToProductInstance.get(excp.recordId).Name + '</a></td>';
                } else {
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
}