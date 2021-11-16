/**
   @Author Rahulkumar(Cognizant)
   @name CRMJV_CloneDealProductsBatch
   @CreateDate 15 July 2021
   @Description This batch class is responsible for cloning deal product for given clonedDeal based on currentDeal
   @Version <1.0>
   @reference Requirement no ER-007269 from SDS and S2S Project
*/
public without sharing class CRMJV_CloneDealProductsBatch implements Database.Batchable<sObject>,Database.stateful{
    public Id clonedDealId;
    public Id currentDealId;

    public Integer dealProductTotalCount;
    public Integer chunkCount = 1;
    UploadObject__c parentUO = new UploadObject__c();
    public Boolean isPriceBookChanged = false;
    public Map<Id,Opportunity> mapDeal = new Map<Id,Opportunity>();    
    List<CRMJV_CloneDealCtrl.ProductSaveError> lstExceptions = new List<CRMJV_CloneDealCtrl.ProductSaveError>();

    /**
    *  Start method of Batch
    *  @name start
    *  @return  Query locator  - returning the records from query string
    */
    public Database.queryLocator start(Database.BatchableContext BC){
        this.isPriceBookChanged = checkforPriceBookChanged();
        this.dealProductTotalCount = Integer.valueOf(this.mapDeal.get(this.currentDealId).Count_Opportunity_Products__c);
        system.debug('@@isPriceBookChanged-->'+this.isPriceBookChanged);

        String SOQL_DEALPROD_QUERY = 'SELECT ' + String.join(CRMJV_CloneDealCtrl.getDealProductFieldsToCopy(), ', ');
        SOQL_DEALPROD_QUERY += ' FROM OpportunityLineItem';
        SOQL_DEALPROD_QUERY += ' WHERE OpportunityId =: currentDealId';
        system.debug('@@start.Query-->'+SOQL_DEALPROD_QUERY);

        //--insert parent upload object record to trace all child response--//
        this.parentUO = new UploadObject__c();
        this.parentUO.Name = System.Label.CRMJV_Clone_OpportunityLineItem_Name + '_' + String.valueOf(this.clonedDealId);
        this.parentUO.DealId__c = this.clonedDealId;
        this.parentUO.ObjectName__c = System.Label.CRMJV_Clone_OpportunityLineItem_Name;
        this.parentUO.Total_Count__c = this.dealProductTotalCount;
        this.parentUO.status__c = System.Label.CRM_InProgressLabel;
        insert this.parentUO;

        return Database.getQueryLocator(SOQL_DEALPROD_QUERY);
    }

    /**
    * Execute method of batch to process on NR Product records and create
    * Deal or Deal Product records accordingly
    */
    public void execute(Database.BatchableContext BC, List<OpportunityLineItem> dealProductList){
        System.debug('@@DPList-->'+dealProductList.size());

        List<OpportunityLineItem> dealProductListToInsert = new List<OpportunityLineItem>();
        List<String> lstProdCode = new List<String>();
        Map<String, PricebookEntry> mapPriceBookEntry = new Map<String, PricebookEntry>();
        List<CRMJV_CloneDealCtrl.ProductSaveError> lstChunkExceptions = new List<CRMJV_CloneDealCtrl.ProductSaveError>();

        Id priceBookId = this.mapDeal.get(this.clonedDealId).PriceBook2Id;
        String currencyCode = this.mapDeal.get(this.clonedDealId).CurrencyIsoCode;

        if(this.isPriceBookChanged){
            for(OpportunityLineItem dealProd: dealProductList){
                lstProdCode.add(dealProd.Product2.ProductCode);
            }
            if(!lstProdCode.isEmpty()){
                mapPriceBookEntry = CRMJV_CloneDealCtrl.fetchPriceBookEntryForProduct(lstProdCode, priceBookId, currencyCode);
            }
        }

        for(OpportunityLineItem dealProd: dealProductList){
            dealProd.Id = null;
            dealProd.OpportunityId = this.clonedDealId;
            dealProd.DFI_Status__c = CRM_AppConstants.DEAL_PRODUCT_DFI_STATUS_NONE;
            if(dealProd.Deal_Record_Type__c == CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_DFI_DEAL){
                dealProd.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_DFI;
            }
            if(this.isPriceBookChanged && mapPriceBookEntry.containsKey(priceBookId+'-'+dealProd.Product2.ProductCode+'-'+currencyCode)){
                dealProd.PriceBookEntryId = mapPriceBookEntry.get(priceBookId+'-'+dealProd.Product2.ProductCode+'-'+currencyCode).Id;
                dealProd.Product2Id = mapPriceBookEntry.get(priceBookId+'-'+dealProd.Product2.ProductCode+'-'+currencyCode).Product2Id;
            }
            dealProductListToInsert.add(dealProd);
        }

        if(!dealProductListToInsert.isEmpty()){
            Database.SaveResult[] prodInsertResults = Database.insert(dealProductListToInsert, false);
            lstChunkExceptions = CRMJV_CloneDealCtrl.getSaveErrors(prodInsertResults, dealProductListToInsert);

            Integer batchRecordSize = dealProductListToInsert.size();
            Integer batchFailedRecordSize = lstChunkExceptions.size();
            Integer batchSuccessRecordSize = batchRecordSize - batchFailedRecordSize;
            system.debug('@@BatchRecordSize--'+String.valueOf(batchRecordSize)+'--batchFailedRecordSize--'+String.valueOf(batchFailedRecordSize)+'--batchSuccessRecordSize--'+String.valueOf(batchSuccessRecordSize));

            //--insert child upload object record each for batch chunk whether chunk batch is success or has error--//
            Integer errorExceedChunkSize = Integer.valueOf(System.Label.CRMJV_Clone_DealProduct_Max_ErrorRecord_Size);
            if(batchFailedRecordSize > errorExceedChunkSize){
                Integer chunkSubCount = 1;                

                //--insert UO record for successfull inserted records--//
                if(batchSuccessRecordSize > 0){
                    saveEachBatchChunkErrorsInUploadObject(new List<CRMJV_CloneDealCtrl.ProductSaveError>(), batchSuccessRecordSize, this.chunkCount, chunkSubCount);
                    chunkSubCount++;
                }

                //--insert UO record for failed inserted records in sub chunk--//
                List<CRMJV_CloneDealCtrl.ProductSaveError> sliceListChunkExceptions = new List<CRMJV_CloneDealCtrl.ProductSaveError>();
                for(Integer i=0; i<(batchFailedRecordSize / errorExceedChunkSize)+1; i++){
                    sliceListChunkExceptions = new List<CRMJV_CloneDealCtrl.ProductSaveError>();
                    for(Integer j=(i*errorExceedChunkSize); (j<(i*errorExceedChunkSize)+errorExceedChunkSize) && j<batchFailedRecordSize; j++){
                        sliceListChunkExceptions.add(lstChunkExceptions[j]);
                    }
                    if(!sliceListChunkExceptions.isEmpty()){
                        saveEachBatchChunkErrorsInUploadObject(sliceListChunkExceptions, sliceListChunkExceptions.size(), this.chunkCount, chunkSubCount);
                    }
                    chunkSubCount++;
                }
            }else{
                saveEachBatchChunkErrorsInUploadObject(lstChunkExceptions, batchRecordSize, this.chunkCount, 0);
            }
            this.chunkCount++;
            if(!lstChunkExceptions.isEmpty()){
                this.lstExceptions.addAll(lstChunkExceptions);
            }
        }
    }

    /**
    * Finish method of batch process.
    */
    public void finish(Database.BatchableContext BC){
        resetCloneDealFlagAndUploadErrorRecords();   // reset flag on current(original) deal and upload error records in upload object
        sendMail();   // Send mail to logged in User to notify clone deal product is completed
    }

    /**
    *  This method log a records in upload object to track success/Error records
    *  @name saveEachBatchChunkErrorsInUploadObject
    *  @para lstChunkExceptions - list of error wrapper
    *  @para chunkSize - size of batch records to process
    *  @para chunkCount - counter of batch chunk
    *  @para chunkSubCount - counter of error out chunk in case of long size of error list
    *  @return  None
    *  @Exception none
    */
    public void saveEachBatchChunkErrorsInUploadObject(List<CRMJV_CloneDealCtrl.ProductSaveError> lstChunkExceptions, Integer chunkSize, Integer chunkCount, Integer chunkSubCount){
        List<String> errList = new List<String>();
        for(CRMJV_CloneDealCtrl.ProductSaveError errInst: lstChunkExceptions){
            errList.add('{"validation" : "'+ errInst.error+'", "record":'+JSON.serialize(errInst.lineitem)+'}');
        }
    
        UploadObject__c chunkUO = new UploadObject__c();
        if(chunkSubCount > 0){
            chunkUO.Name = String.valueOf(this.clonedDealId) + '_' + String.valueOf(chunkCount) + '_' + String.valueOf(chunkSubCount);
        }else{
            chunkUO.Name = String.valueOf(this.clonedDealId) + '_' + String.valueOf(chunkCount);
        }
        chunkUO.UploadObjectParent__c = this.parentUO.Id;
        if(!lstChunkExceptions.isEmpty()){
            chunkUO.Comment__c =  JSON.serializepretty(errList);
        }
        chunkUO.DealId__c = this.clonedDealId;
        chunkUO.ObjectName__c = System.Label.CRMJV_Clone_OpportunityLineItem_Name;
        chunkUO.Total_Count__c = chunkSize;
        //chunkUO.Processed_Count__c = chunkSize;
        chunkUO.Success_Count__c = chunkSize - lstChunkExceptions.size();
        chunkUO.status__c = lstChunkExceptions.size() > 0 ? System.Label.CRM_FailedLabel : System.Label.CRM_SuccessLabel;
        insert chunkUO;
    }

    /**
    *  This method is cheking for deal price book records has changed or not
    *  @name checkforPriceBookChanged
    *  @return  Boolean(true/false), return true if cloned and original deal procebook record id changed else false
    */
    @TestVisible
    private Boolean checkforPriceBookChanged(){
        System.debug('@@ClonedId-->'+this.clonedDealId+'--CurrentDealId-->'+this.currentDealId);
        Boolean isPriceBookChanged = false;
        this.mapDeal = new Map<Id,Opportunity>([Select Id,Name,PriceBook2Id,AccountId,CurrencyIsoCode,Count_Opportunity_Products__c 
                                                From Opportunity Where (Id =: this.clonedDealId OR Id =: this.currentDealId)]);
        if(!this.mapDeal.isEmpty() && this.mapDeal.get(this.clonedDealId).PriceBook2Id != this.mapDeal.get(this.currentDealId).Pricebook2Id){
            isPriceBookChanged = true;
        }
        return isPriceBookChanged;
    }

    /**
    *  This method reset clone deal flag back to false
    *  @name resetCloneDealFlag
    *  @return  None
    *  @Exception log errors in CRM Error log object, if any
    */
    @TestVisible
    private void resetCloneDealFlagAndUploadErrorRecords(){
        System.debug('@@CurrentDealId-->'+this.currentDealId);
        List<CRM_ErrorLogger.ErrorLog> listCRMErrorLog = new List<CRM_ErrorLogger.ErrorLog>();

        //--update clone deal to false in original deal--//
        CRM_ApplicationUtility.isJVDealCloneBatch = true;
        Opportunity opp = new Opportunity();
        opp.Id = this.currentDealId;
        opp.Clone_Deal__c = false;

        Database.SaveResult[] saveResultList = Database.update(new List<Opportunity>{opp},false);
        for(Integer i = 0; i < saveResultList.size(); i++){
            Database.SaveResult saveResultInstance = saveResultList[i];
            // Error Handling   // Save the error in database
            if(opp != null && !saveResultInstance.isSuccess()){
                for(Database.Error err: saveResultInstance.getErrors()){
                    CRM_ErrorLogger.ErrorLog crmErrorLog = new CRM_ErrorLogger.ErrorLog();
                    crmErrorLog.recordId = opp.Id;
                    crmErrorLog.functionalModule = System.Label.CRMJV_Clone_OpportunityLineItem_Name;
                    crmErrorLog.errorMessage = err.getMessage().left(200);
                    listCRMErrorLog.add(crmErrorLog);
                }
            }
        }

        //--update records in upload object for error deal product--//
        this.parentUO.Processed_Count__c = this.dealProductTotalCount;
        this.parentUO.Success_Count__c = this.dealProductTotalCount - this.lstExceptions.size();
        this.parentUO.status__c = this.lstExceptions.size() > 0 ? System.Label.CRM_FailedLabel : System.Label.CRM_SuccessLabel;
        update this.parentUO;

        // Inserts all errors into database
        if(!listCRMErrorLog.isEmpty()){
            CRM_ErrorLogger.logError(listCRMErrorLog);
        }
    }

    /**
    * @Description - Method to send mail to logged in User to notify clone deal product is completed
    * @name sendMail
    * @return  None
    * @Exception log errors in CRM Error log object, if any
    */
    @TestVisible
    private void sendMail(){
        System.debug('@@ClonedId-->'+this.clonedDealId);
        Opportunity opp = this.mapDeal.get(this.clonedDealId);
        String oppRecordLink = generateDealRecordLink(opp.Id);
        system.debug('@@oppRecordLink-->'+oppRecordLink);

        EmailTemplate emailTemplate = [Select Id,Name,Htmlvalue,Subject from EmailTemplate where DeveloperName =: System.Label.CRMJV_Clone_DealProduct_Batch_EmailTemplate_Name];

        String emailTempSubject = emailTemplate.Subject;
        emailTempSubject = emailTempSubject.replace('{!Opportunity.Name}', opp.Name);

        String emailTempHTMLValue = emailTemplate.Htmlvalue;
        emailTempHTMLValue = emailTempHTMLValue.replace('{!Opportunity.LastModifiedBy}', UserInfo.getName());
        emailTempHTMLValue = emailTempHTMLValue.replace('{!Opportunity.Name}', opp.Name);
        emailTempHTMLValue = emailTempHTMLValue.replace('{!Opportunity.Link}', oppRecordLink);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{UserInfo.getUserEmail()});   
        mail.setSubject(emailTempSubject);
        mail.setHtmlBody(emailTempHTMLValue);
        mail.setTemplateId(emailTemplate.id);
        mail.setSenderDisplayName(System.Label.CRMJV_Clone_DealProduct_Batch_Mail_Display_Name);
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }

    /**
    *  This method generate deal record link which populate on email template
    *  @name generateDealRecordLink
    *  @para oppId - size of batch records to process
    *  @return  String - full record link
    *  @Exception none
    */
    private String generateDealRecordLink(Id oppId){
        String oppRecordLink = URL.getSalesforceBaseURL().toExternalForm().replace('https://', '').split('\\.')[0];
        oppRecordLink = oppRecordLink.removeEnd('--c');
        return 'https://' + oppRecordLink.toLowerCase() + '.lightning.force.com/lightning/r/Opportunity/'+oppId+'/view';
    }
}