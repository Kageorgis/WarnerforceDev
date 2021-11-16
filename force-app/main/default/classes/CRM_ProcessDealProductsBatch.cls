/**
 * @Author: Aditi Satpute
 * @name CRM_ProcessDealProductsBatch
 * @CreateDate 27th Sept 2016
 * @Description: Batch class to recalculate Schedule Dates of following 
                - All Non NR Batch created deal products linked with NR Physical Product for which Street Date is Changed
                - All The deal whose Promo Start Date is changed
 * @Version 1.0
 */
global with sharing class CRM_ProcessDealProductsBatch implements Database.batchable<sObject>, Database.stateful {

  // AL-000371 Change : commented
    //global final Set<Id> setDealIDs = new Set<Id>();
    
    //global final Set<Id> setCommittedDealIds = new Set<Id>();
    global Opportunity currentDeal;
    Map<Id,Opportunity> mapDealsToReset = new Map<Id,Opportunity>();
    global final Set<Id> setErrorDealIds = new Set<Id>();
    global final List<CRM_ProcessDealProductsBatchException> lstExceptions = new List<CRM_ProcessDealProductsBatchException>();
    global final Set<Id> setProductIDs = new Set<Id>();
    
    /**
     *  Start method of Batch
     *  @name start
     *  @return  Query locator  - returning the records from query string
     */
    global Database.queryLocator start(Database.BatchableContext BC) {
    Set<Id> setDealRecordTypes = new Set<Id>{CRM_RecordTypeUtil.RT_DEAL_DIGITAL, CRM_RecordTypeUtil.RT_DEAL_PHYSICAL, CRM_RecordTypeUtil.RT_DEAL_HIGH_LEVEL};
    
       String query =' SELECT Id, Product2Id, Product2.Recalculateschedules__c, OpportunityId, Opportunity.Id, Opportunity.CloseDate, Opportunity.Bypass_Committed_Deals__c, Opportunity.UpdateScheduleDates__c, Opportunity.StageName,  '+
                        'Manually_Schedule__c, Product2.RecordTypeId, NR__c, NR_Deal_Product_Unique_Key__c, Opportunity.RecordTypeId, '+
                        'Is_Planned_Cut_Off_Qauntity_Updated__c, Opportunity.Digital_Country_Code__c, Opportunity.Sales_Organisation__c, '+
                        'Product2.Recalculate_Production_Cost__c,Production_Cost__c,Production_Cost_Estimated__c,Product2.Street_Date__c,'+
                        'Product2.Production_Cost__c,Product2.ProductFormatUpdated__c,Product2.Product_Format__c,Format__c,Product2.CurrencyIsoCode '+
                      ' FROM OpportunityLineItem '+
                       ' WHERE (' +
                      //' ((Opportunity.StageName != '+ '\'' + CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED + '\' '+    //Fetch all dealProducts
                      //     ' AND Opportunity.StageName != '+ '\'' + CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED + '\' '+
                         //  'opportunityid='+'\''+ '0060m000004hai4\' and'+
                           'Opportunity.UpdateScheduleDates__c = true' +
                           ' OR Product2.RecalculateSchedules__c = true' +
                          // June US#594 
                          // AL-000371 change: For production  cost do not modify the past deals
                          ' OR (Opportunity.CloseDate >= TODAY AND Product2.Recalculate_Production_Cost__c = TRUE AND Product2.Production_Cost__c !=NULL AND Product2.Production_Cost__c != 0)'+
                          //DEF#4090 Update Product Format on Deal Product
                          ' OR Product2.ProductFormatUpdated__c = TRUE )'+
                          ' AND Opportunity.RecordTypeId IN :setDealRecordTypes '+
                          //Defect 4544 - Guns added - exclude cancelled deals from Query so that user does not get failure email which is caused because of validation rule which does not let you update cancelled deals.
                          ' AND Opportunity.StageName !='+ '\'' + CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED + '\'' +
                          ' ORDER BY OpportunityId'
                          ;  
                      
        System.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }

    /**
     * Execute method of Batch
     * @name execute
     * @param scopeOpportunityLineItem- For storing the records returned from Start method
     */
    global void execute(Database.BatchableContext BC, List<OpportunityLineItem> scopeOpportunityLineItem) {
        System.debug('---------------------------------------------------------------------------');
        System.debug('setErrorDealIds.size------->'+setErrorDealIds.size());
        System.debug('lstExceptions.size----->'+lstExceptions.size());
        System.debug('setProductIDs.size------->'+setProductIDs.size());
        System.debug('------------- Heap Size'+ Limits.getHeapSize()+'---------------------------');
        
        
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        Set<Id> setDealProductIDs = new Set<Id>();
        Map<Id,Opportunity> mapDeals = new Map<Id,Opportunity>();
        Map<Id,Set<Id>> mapDealIdToDealProductId = new Map<Id,Set<Id>>();
        Set<Id> setDPIDsToUpdPlannedQty = new Set<Id>();
        Map<Id,OpportunityLineItem> mapDealProductsToUpdate = new Map<Id,OpportunityLineItem>();      
        
        mapDealsToReset = new Map<Id,Opportunity>();
        
        // add to map if currentDeal is available from last batch
        if(currentDeal != null && currentDeal.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED) {
          mapDeals.put(currentDeal.Id, currentDeal);
        }
        
        try {
            for (OpportunityLineItem objDealProduct : scopeOpportunityLineItem) {

              currentDeal = objDealProduct.Opportunity;
              
                //DEF#4090 Update Product Format on Deal Product
                if(objDealProduct.Product2.ProductFormatUpdated__c){
                    
                    //If map does not contain the Deal Product then add for the final map of Deal products to update
                    if(!mapDealProductsToUpdate.containsKey(objDealProduct.id)){
                        objDealProduct.Format__c = objDealProduct.Product2.Product_Format__c;  
                        mapDealProductsToUpdate.put(objDealProduct.id,objDealProduct);
 
                    }else{
                        //If map contains the Deal Product then update
                        mapDealProductsToUpdate.get(objDealProduct.Id).Format__c = objDealProduct.Product2.Product_Format__c; 
                    }
                    // If the Deal is in committed stage and the date has not passed then update the deal 
                    if(objDealProduct.Opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED){
                        if(!mapDeals.containsKey(objDealProduct.OpportunityId)){
                            mapDeals.put(objDealProduct.OpportunityId, objDealProduct.Opportunity);
                        }
                    }
                    //Products Id's for updating the ProductFormatUpdated__c flag to false
                    this.setProductIDs.add(objDealProduct.Product2Id);  
                } 
                
                //US#594 starts Update the Deal Products with Product's Production Cost
                if((objDealProduct.Product2.Recalculate_Production_Cost__c && objDealProduct.Opportunity.CloseDate >= System.today() )
                        && (objDealProduct.Product2.Production_Cost__c != null || objDealProduct.Product2.Production_Cost__c != 0) 
                        && ((objDealProduct.Opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED && objDealProduct.Product2.Street_Date__c <= Date.today())
                                || objDealProduct.Opportunity.StageName != CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED)){
                    //If map does not contain the Deal Product then add for the final map of Deal products to update
                    if(!mapDealProductsToUpdate.containsKey(objDealProduct.id)){
                        objDealProduct.Production_Cost__c = objDealProduct.Product2.Production_Cost__c;  
                        //If Deal Product has the Estimated Production Cost then reset the flag
                        if(objDealProduct.Production_Cost_Estimated__c){
                            objDealProduct.Production_Cost_Estimated__c = false;
                        }
                        mapDealProductsToUpdate.put(objDealProduct.id,objDealProduct); 
                    }else{
                        //If map contains the Deal Product then update
                        mapDealProductsToUpdate.get(objDealProduct.Id).Production_Cost__c = objDealProduct.Product2.Production_Cost__c; 
                        //If Deal Product has the Estimated Production Cost then reset the flag
                        if(objDealProduct.Production_Cost_Estimated__c){
                            mapDealProductsToUpdate.get(objDealProduct.Id).Production_Cost_Estimated__c = false; 
                        }
                    }
                    // If the Deal is in committed stage and the date has not passed then update the deal 
                    if(objDealProduct.Opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED && objDealProduct.Product2.Street_Date__c <= Date.today() ){
                        if(!mapDeals.containsKey(objDealProduct.OpportunityId)){
                            mapDeals.put(objDealProduct.OpportunityId, objDealProduct.Opportunity);
                        }
                    }
                    //Products Id's for updating the Recalculate_Production_Cost__c flag to false
                    this.setProductIDs.add(objDealProduct.Product2Id);
                } 
                //US#594 Ends
                
                if (objDealProduct.Product2.Recalculateschedules__c) {
                    // This set will contain all Products from all execution so that it can be used to reset the flag
                    this.setProductIDs.add(objDealProduct.Product2Id);
                    // Local set used to calculate scedules only for these
                    if (
                        !objDealProduct.Manually_Schedule__c && 
                        objDealProduct.NR_Deal_Product_Unique_Key__c == null &&
                        (
                            (objDealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL && objDealProduct.NR__c && objDealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_PHYSICAL) ||
                            (objDealProduct.Product2.RecordTypeId == CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL && objDealProduct.Opportunity.RecordTypeId == CRM_RecordTypeUtil.RT_DEAL_DIGITAL)
                        )
                    ) {
                        if(!mapDealIdToDealProductId.containsKey(objDealProduct.OpportunityId)){
                            mapDealIdToDealProductId.put(objDealProduct.OpportunityId,new Set<Id>{objDealProduct.Id});
                        }else{
                            mapDealIdToDealProductId.get(objDealProduct.OpportunityId).add(objDealProduct.Id);
                        }
                        if(objDealProduct.Opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED ||
                           objDealProduct.Opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED
                          ){    
                            //List of Deals which are Committed/Approved
                            //setCommittedDealIds.add(objDealProduct.OpportunityId);
                            if(!mapDeals.containsKey(objDealProduct.OpportunityId)){
                                mapDeals.put(objDealProduct.OpportunityId, objDealProduct.Opportunity);
                            }
                        }
                    }
                        // added below line to add those deal products where Recalculateschedules__c is true but above condition did not met, but we need to update that deal product to trigger the workflow to..
                        //..update NR_cut_off_date field 
                        if(!mapDealProductsToUpdate.containsKey(objDealProduct.Id)){
                            mapDealProductsToUpdate.put(objDealProduct.Id, objDealProduct);
                            
                            if(objDealProduct.Opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED ||
                               objDealProduct.Opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED
                              ){    
                                //List of Deals which are Committed/Approved
                                //setCommittedDealIds.add(objDealProduct.OpportunityId);
                                if(!mapDeals.containsKey(objDealProduct.OpportunityId)){
                                    mapDeals.put(objDealProduct.OpportunityId, objDealProduct.Opportunity);
                                }
                            }
                        }
                }
                if (objDealProduct.Opportunity.UpdateScheduleDates__c) {
                    
                        if(!mapDealIdToDealProductId.containsKey(objDealProduct.OpportunityId)){
                            mapDealIdToDealProductId.put(objDealProduct.OpportunityId,new Set<Id>{objDealProduct.Id});
                        }else{
                            mapDealIdToDealProductId.get(objDealProduct.OpportunityId).add(objDealProduct.Id);
                        }
                        if(objDealProduct.Opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_APPROVED ||
                            objDealProduct.Opportunity.StageName == CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED
                            ){
                                //System.debug('In IF ::::::::');
                                if(!mapDeals.containsKey(objDealProduct.OpportunityId)){
                                    mapDeals.put(objDealProduct.OpportunityId, objDealProduct.Opportunity);
                                    //List of Deals which are Committed/Approved
                                    //setCommittedDealIds.add(objDealProduct.OpportunityId);
                                }
                            }
                        // AL-000371 Change : commented
                        //this.setDealIDs.add(objDealProduct.OpportunityId);
                        mapDealsToReset.put(objDealProduct.OpportunityId, objDealProduct.Opportunity);
                        
                }
            }
            
            //AL-000371 Change: moved deal update to a module/method
            //Updating Committed deals to Revised stage
            updateDeals(mapDeals, mapDealIdToDealProductId, listErrorLog, false);
            
            if(mapDealIdToDealProductId != null && mapDealIdToDealProductId.values().size() > 0){
                for(Set<Id> dealProductId : mapDealIdToDealProductId.values()){
                    setDealProductIDs.addAll(dealProductId);
                }
            }
            
            if (setDealProductIDs != null && setDealProductIDs.size() > 0){
                
                // Following Method 'createDealProductSchedule' will set the schedule->start Date = Deal-> Promo StartDate
                CRM_AutoEstablishSchedulesHelper.createDealProductSchedule(setDealProductIDs, null);
            }
           
                        
            if(!mapDealProductsToUpdate.isEmpty()){
                  Database.SaveResult[] saveResultList =
                        Database.update(mapDealProductsToUpdate.values(), false);
                    List<OpportunityLineItem> lstUpdatedDealProds =mapDealProductsToUpdate.values();     
                    for (Integer i = 0; i < saveResultList.size(); i++) {
                        Database.SaveResult saveResultInstance = saveResultList[i];
                        OpportunityLineItem DPInsatnce = lstUpdatedDealProds[i];
                        if (!saveResultInstance.isSuccess()) {

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
            
            //AL-000371 Change: finally update/reset the deals 
            updateDeals(mapDealsToReset, mapDealIdToDealProductId, listErrorLog, true);

          // Germany US 308 - End            
        } catch (Exception e) {
            listErrorLog.addAll(logAnException(e));
        }
        
        // Inserts all errors into database
        CRM_ErrorLogger.logError(listErrorLog);
    }
  
  private void updateDeals(Map<Id,Opportunity> mapDeals, Map<Id,Set<Id>> mapDealIdToDealProductId, List<CRM_ErrorLogger.ErrorLog> listErrorLog, Boolean finalReset) {
      System.debug(' ::::::::finalReset::::'+finalReset);
            if(mapDeals != null && mapDeals.size()>0){
                for(Opportunity deal : mapDeals.values()){
                  if(!finalReset) {
                      //deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_REVISED;
                      deal.Bypass_Committed_Deals__c = System.now();
                  }
                  // Reset everything except current runnning deal whcih may continue in the next batch
                  else if(currentDeal.Id != deal.Id) {
                    deal.Bypass_Committed_Deals__c = null;
                    deal.UpdateScheduleDates__c = false;
                  }
                }
                
                Database.SaveResult[] saveResultList = Database.update(mapDeals.values(), false);
                
                for (Integer i = 0; i < saveResultList.size(); i++) {
                    Database.SaveResult saveResultInstance = saveResultList[i];
                    Opportunity dealInstance = mapDeals.values()[i];
                    if (!saveResultInstance.isSuccess()) {
                      this.setErrorDealIds.add(dealInstance.Id);
                      
                        //Remove the list of dealProducts with associated deals that failed
                        if(!finalReset && mapDealIdToDealProductId.containsKey(dealInstance.Id)){
                            mapDealIdToDealProductId.remove(dealInstance.Id);
                        }
                        // AL-000371 Change : commented
                        //this.setDealIds.remove(dealInstance.Id);
                        // remove deal and do not reset if there is any error.
                        if(!finalReset && this.mapDealsToReset.containsKey(dealInstance.Id)) {
              this.mapDealsToReset.remove(dealInstance.Id);
                        }
                            
                        // Add these errors in Error wrapper Class and prepare a list of same
                        // Error Handling
                        List<String> lstErrors = new List<String>();
                        for(Database.Error err : saveResultInstance.getErrors()) {
                            lstErrors.add(err.getMessage());

                            // Save the error in database
                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.recordId = dealInstance.Id;
                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_UPDATE_PRODUCT_FOR_SCHEDULE_DATE;
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }
                        this.lstExceptions.add(
                            new CRM_ProcessDealProductsBatchException(
                                dealInstance.Id,
                                lstErrors
                            )
                        );
                    }
                }  
            }
  }
  
    /**
     * Finish method of batch process.
     */
    global void finish(Database.BatchableContext BC) {
    
    //List<Product2> lstProduct = new  List<Product2>(); -- Commented as part of AL-000371
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
    system.debug('Final currentDeal----->'+currentDeal);
    // update the current deal
    if(currentDeal != null && currentDeal.Id != null && currentDeal != null && (currentDeal.UpdateScheduleDates__c == true || currentDeal.Bypass_Committed_Deals__c != null )) {
      currentDeal.Bypass_Committed_Deals__c = null;
        currentDeal.UpdateScheduleDates__c = false;
        
      Database.update(currentDeal, false);
    }
    
    /* -- Commented as part of AL-000371
        try{
            
            if (this.setProductIDs != null && this.setProductIDs.size() > 0) {
                
                lstProduct = [SELECT Id, RecalculateSchedules__c,Recalculate_Production_Cost__c,ProductFormatUpdated__c FROM Product2 WHERE Id IN: this.setProductIDs LIMIT 10000];
                System.debug('#$#$#$#$ lstProduct size: ' + lstProduct.size());

                if (lstProduct != null && lstProduct.size() > 0 && !lstProduct.isEmpty()){

                    for (Product2 productInstance : lstProduct) {
                        if(productInstance.RecalculateSchedules__c){
                            productInstance.RecalculateSchedules__c = false;
                    }
                        // US#594 We will uncheck the flag on Product 'RecalculateSchedules__c' 
                        if(productInstance.Recalculate_Production_Cost__c){
                            productInstance.Recalculate_Production_Cost__c = false;
                        }
                        //DEF#4090 Update Product Format on Deal Product
                        if(productInstance.ProductFormatUpdated__c){
                            productInstance.ProductFormatUpdated__c = false;
                        }
                    }

                    Database.SaveResult[] saveResultList =
                        Database.update(lstProduct, false);
                    for (Integer i = 0; i < saveResultList.size(); i++) {
                        Database.SaveResult saveResultInstance = saveResultList[i];
                        Product2 productInsatnce = lstProduct[i];
                        if (!saveResultInstance.isSuccess()) {

                            // Add these errors in Error wrapper Class and prepare a list of same
                            // Error Handling
                            List<String> lstErrors = new List<String>();
                            for(Database.Error err : saveResultInstance.getErrors()) {
                                lstErrors.add(err.getMessage());

                                // Save the error in database
                                CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                                errorLog.recordId = productInsatnce.Id;
                                errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_UPDATE_PRODUCT_FOR_SCHEDULE_DATE;
                                errorLog.errorMessage = err.getMessage().left(200);
                                listErrorLog.add(errorLog);
                            }
                            this.lstExceptions.add(
                                new CRM_ProcessDealProductsBatchException(
                                    productInsatnce.Id,
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
        */

        // Inserts all errors into database
        CRM_ErrorLogger.logError(listErrorLog);

        System.debug('--this.lstExceptions.size()-->'+this.lstExceptions.size());
        // Send mail only if errors present
        if (!this.lstExceptions.isEmpty()){
          // AL-000371 Change : Modified Query
            //List<Opportunity> lstOpportunity = [SELECT Id, Name FROM Opportunity WHERE Id IN: setDealIDs OR Id IN: setErrorDealIds LIMIT 50000];
            List<Opportunity> lstOpportunity = [SELECT Id, Name FROM Opportunity WHERE Id IN: setErrorDealIds LIMIT 30000];
            List<Product2> lstProduct = [SELECT Id, RecalculateSchedules__c,Recalculate_Production_Cost__c,ProductFormatUpdated__c FROM Product2 WHERE Id IN: this.setProductIDs LIMIT 10000];
            
            sendMail(new Map<Id, Product2>(lstProduct),new Map<Id,Opportunity>(lstOpportunity));
        }else{
            BatchStatusNotification.sendBatchStatusMail(BC, System.Label.CRM_Process_Deal_Products_Batch_Mail_Subject);
        }
        
        CRM_Batch_Size__c batchSizeInstance = CRM_Batch_Size__c.getInstance('Process Deals Batch');
        Integer defaultBatchSize = batchSizeInstance != null ? (Integer) batchSizeInstance.Batch_Size__c : 100;
        System.debug('--this.setProductIDs.size()-->'+this.setProductIDs.size());
        if ((this.setProductIDs != null && this.setProductIDs.size() > 0)) {
            CRM_ProcessDealsBatch batchInstance = new CRM_ProcessDealsBatch(this.setProductIDs);
            Database.executebatch(batchInstance, defaultBatchSize);
        }
        CRM_ProcessDealProductPlannedCutOffBatch cutOffbatch = new CRM_ProcessDealProductPlannedCutOffBatch();
        Database.executebatch(cutOffbatch, defaultBatchSize);

    } 
    
    /**
     * @Description - Method to send mail to logged in User for all the failure details of processed deals
     * @name sendMail
     */
    @TestVisible
    private void sendMail(Map<Id, Product2> mapIdToProductInstance,Map<Id,Opportunity> mapIdToDealInstance) {

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
        mail.setSubject(System.Label.CRM_Process_Deal_Products_Batch_Mail_Subject);
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
                if (mapIdToProductInstance.containsKey(excp.recordId) && mapIdToProductInstance.get(excp.recordId).Name != null) {
                    body += '<td rowspan=\'' + excp.lstErrors.size() + '\'><a href=' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '>' + mapIdToProductInstance.get(excp.recordId).Name + '</a></td>';
                }if(mapIdToDealInstance.containsKey(excp.recordId) && mapIdToDealInstance.get(excp.recordId).Name != null){
                    body += '<td rowspan=\'' + excp.lstErrors.size() + '\'><a href=' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '>' + mapIdToDealInstance.get(excp.recordId).Name + '</a></td>';
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