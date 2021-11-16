/**
   @Author Rahulkumar(Cognizant)
   @name CRMJV_AutoPhysicalNRDealBatch
   @CreateDate 15 Dec 2020
   @Description This batch class is responsible for automatic creation of JV Deals, and corresponding Deal Products associated to them for NR products created in the system.
   @Version <1.0>
   @reference Requirement no W-017644, W-017678 from JV Project
*/
public with sharing class CRMJV_AutoPhysicalNRDealBatch implements Database.Batchable<sObject>, Database.stateful{
    public String query = '';

    public Map<Id,Product2> mapProducts;
    public Map<Id,List<Target__c>> mapProductIdToTargetList = new Map<Id, List<Target__c>>();
    public Map<String,List<Pricebook_Entry_Period__c>> mapIdToPBEPList;
    public Set<Id> setProcessedProductIds = new Set<Id>();
    public List<Id> localListProductIds;
    public List<CRMJV_AutoPhysicalNRDealBatchService.CRMJV_AutoPhysicalNRDealServiceException> lstExceptions =
        new List<CRMJV_AutoPhysicalNRDealBatchService.CRMJV_AutoPhysicalNRDealServiceException>();
    List<String> listSalesJVOrgs = new List<String>(CRM_AppConstants.SALES_JV_ORGS);

    private void buildQuery(){
        if(query == null || query == ''){
            this.query ='SELECT Id,Name,Sales_Organization__c,Price_Book__c,Games_Digital__c,Video_Digital__c,Games_Physical__c, ' + 
                            'Video_Physical__c,CurrencyIsoCode,OwnerId,Status__c,Class_of_Trade__c ' +
                        'FROM Account ' +
                        'WHERE Sales_Organization__c IN (\'' + String.join(listSalesJVOrgs, '\',\'') + '\')' +
                            ' AND (RecordTypeId = \'' + CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO + '\' ' +
                                ' OR RecordTypeId = \'' + CRM_RecordTypeUtil.RT_ACCOUNT_SHIP_TO + '\') ' +
                            ' AND (Status__c = \'' + CRM_AppConstants.ACCOUNT_STATUS_ACTIVE + '\' ' +
                                ' OR Status__c = \'' + CRM_AppConstants.ACCOUNT_STATUS_BLOCKED + '\' ) ' +
                            ' AND Planning_Customer__c = true' +
                            ' AND Video_Physical__c = true' +
                            ' AND Games_Physical__c = false' +
                            ' AND Music_Physical__c = false' +
                            ' AND Video_Digital__c = false' +
                            ' AND Games_Digital__c = false' +
                            ' AND Music_Digital__c = false';
        }
        this.mapProducts= new Map<Id,Product2>(getNRProducts());
        this.mapIdToPBEPList = prepareMapWithExistingPBEP(this.mapProducts.values());
        System.debug('@@this.mapProducts-->'+this.mapProducts);
    }

    /**
    *  Start method of Batch
    *  @name start
    *  @return  Query locator  - returning the records from query string
    */
    public Database.queryLocator start(Database.BatchableContext BC){
        buildQuery();
        system.debug('@@start.query-->'+this.query);
        return Database.getQueryLocator(this.query);
    }

    /**
     * Execute method of batch to process on NR Product records and create
     * Deal or Deal Product records accordingly
     */
    public void execute(Database.BatchableContext BC, List<Account> accountList){
        System.debug('@@accountList-->'+accountList.size());
        CRM_ApplicationUtility.isJVAutoPhysicalNRBatch = true;
                
        List<Account> accountWithInnerQuery = [SELECT Id,Name,Sales_Organization__c,Price_Book__c,Games_Digital__c,Video_Digital__c,
                    Digital_Country_Code__c,Games_Physical__c,Video_Physical__c,CurrencyIsoCode,OwnerId,Status__c,Music_Digital__c,
                    Music_Physical__c,Class_of_Trade__c,Storefront__c,
                    (SELECT Id,RecordTypeId,Name,Start_Date__c,CloseDate,AccountID,Pricebook2ID,Market_Type__c,StageName,Product_Type__c,
                        NR_Deal_Unique_Key__c,CurrencyIsoCode,OwnerId,Account.OwnerId,Owner.IsActive,Admin_Status__c
                        FROM Opportunities WHERE NR_Deal_Unique_Key__c != null
                    ),
                    (SELECT Id,Account__c,Product__c,Target__c,Target_Units__c,Target_Revenue_Has_Changed__c,Product__r.RecordTypeId,
                            NR_Version__c,Account__r.Sales_Organization__c,Calc_End_Date__c,Calc_Start_Date__c,Product__r.SAP_Sales_Org__c
                        FROM Targets__r WHERE Product__c != null AND (Target__c != null OR Target_Units__c != null)
                        AND Account__r.Sales_Organization__c IN: CRM_AppConstants.SALES_JV_ORGS
                        AND Product__c IN: this.mapProducts.keySet()
                        ORDER BY LastModifiedDate DESC
                    )
                    FROM Account
                    WHERE Id IN: accountList AND Price_Book__c != null AND Sales_Organization__c != null];
        System.debug('@@accountWithInnerQuery-->'+accountWithInnerQuery);
        System.debug('@@this.productList-->'+this.mapProducts.values());
        lstExceptions.addAll(CRMJV_AutoPhysicalNRDealBatchService.processNRProductRecords(
            accountWithInnerQuery,
            this.mapProducts.values(),
            this.mapIdToPBEPList,
            this.setProcessedProductIds
        ));
    }

    /**
     * Finish method of batch process.
     */
    public void finish(Database.BatchableContext BC){
        // Process Target and Product flags to reset the values for successfully processed products
        processProductAndTargetFlags();
        // Send mail to logged in User for all the details of processed / non processed products
        sendMail(); 
    }

    /**
     * @Description - Method to send mail to logged in User for all the details of processed / non processed products
     * @name sendMail
     */
    private void sendMail(){
        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();

        //Get emailIds from Custom setting
        sendTo = BatchStatusNotification.getBatchNotificationRecipients(CRM_AppConstants.Entity_CRM);
        if(!sendTo.isEmpty()){
            mail.setToAddresses(sendTo);
        }

        // Step 3: Set who the email is sent from
        mail.setReplyTo(UserInfo.getUserEmail());
        mail.setSenderDisplayName(System.Label.CRMJV_NR_Mail_Display_Name);

        // Step 4. Set email contents - you can use variables!
        if(!this.lstExceptions.isEmpty()){
        	mail.setSubject(System.Label.CRMJV_NR_Batch_Failure_Mail_Subject);
        }else{
        	mail.setSubject(System.Label.CRMJV_NR_Batch_Success_Mail_Subject);    
        }
        
        String body = '';
        body = '<html>';
        body += '<body>';
        if(!this.lstExceptions.isEmpty()){
            body += '<table border = 1>';
            body += '<tr>';
            body += '<th>' + System.Label.CRMJV_NR_Batch_Products_Column_Name + '</th>';
            body += '<th>' + System.Label.CRM_Failure_Message_Column_Name + '</th>';
            body += '</tr>';
            //System.debug('---this.lstExceptions------>'+this.lstExceptions);
            for(CRMJV_AutoPhysicalNRDealBatchService.CRMJV_AutoPhysicalNRDealServiceException excp : this.lstExceptions) {
                //System.debug('---excp------>'+excp);
                body += '<tr>';
                if(excp.recordId != null){
                    if(this.mapProducts.containsKey(excp.recordId) && this.mapProducts.get(excp.recordId).Name != null) {
                       body += '<td rowspan=\'' + excp.lstErrors.size() + '\'><a href=' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '>' + this.mapProducts.get(excp.recordId).Name + '</a></td>';
                    }else{
                        body += '<td rowspan=\'' + excp.lstErrors.size() + '\'><a href=' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '>' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + excp.recordId + '</a></td>';
                    }
                }else{
                    body +='<td></td>';
                }
                body += '<td>' + excp.lstErrors[0] + '</td>';
                body += '</tr>';
                if(excp.lstErrors.size() > 1){
                    for(Integer i = 1; i < excp.lstErrors.size(); i++){
                        body += '<tr>';                    
                        body += '<td>' + excp.lstErrors[i] + '</td>';
                        body += '</tr>';
                    }
                }
            }
            body += '<table>';
        }else{
            body += System.Label.CRMJV_NR_Batch_Processed_Successfully_Message;
        }
        body += '</body>';
        body += '</html>';
        mail.setHtmlBody(body);

        // Step 6: Send all emails in the master list
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }

    /**
     * @Description - Method to process Target and Product flags to reset the values for successfully processed products
     * @name processProductAndTargetFlags
     */
    private void processProductAndTargetFlags(){
        List<Product2> updateProcessedProductList = new List<Product2>();
        List<Target__c> updateProcessedTargetList = new List<Target__c>();
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();

        System.debug('@@this.setProcessedProductIds-before-->'+this.setProcessedProductIds);
        for (CRMJV_AutoPhysicalNRDealBatchService.CRMJV_AutoPhysicalNRDealServiceException excp : this.lstExceptions){
            if (excp.recordId != null && this.setProcessedProductIds.contains(excp.recordId)){
                this.setProcessedProductIds.remove(excp.recordId);
            }
        }
        System.debug('@@this.setProcessedProductIds-after-->'+this.setProcessedProductIds);

        Map<Id,Product2> mapProductIdToInstanceWithUpdatedNRVersion = new Map<Id,Product2>([Select Id,NR_Version__c FROM Product2 WHERE ID IN: this.setProcessedProductIds]);
        
        for(Id productId :this.setProcessedProductIds){
            if(this.mapProducts.containsKey(productId)) {
                Product2 productInstance = this.mapProducts.get(productId);

                if(mapProductIdToInstanceWithUpdatedNRVersion.containsKey(productId)){
                    Product2 productInstanceWithUpdatedNRVersion = mapProductIdToInstanceWithUpdatedNRVersion.get(productId);
                    if(productInstance.NR_Product_Created__c || productInstance.Street_Date_Has_Changed__c || productInstance.Previous_Street_Date__c != null){
                        if(productInstance.NR_Product_Created__c){
                            productInstance.NR_Product_Created__c = false;
                        }

                        if(productInstanceWithUpdatedNRVersion.NR_Version__c == productInstance.NR_Version__c){
                            if(productInstance.Street_Date_Has_Changed__c){
                                productInstance.Street_Date_Has_Changed__c = false;
                                productInstance.NR_Version__c = 0;
                            }

                            if(productInstance.Previous_Street_Date__c != null){
                                productInstance.Previous_Street_Date__c = null;
                            }
                        }
                        updateProcessedProductList.add(productInstance);
                    }
                }
            }
        }
        listErrorLog.addAll(resetProcessedProductFlags(updateProcessedProductList,this.setProcessedProductIds));

        List<Pricebook_Entry_Period__c> updatePricebookEntryPeriodList = new List<Pricebook_Entry_Period__c>();
        for(String key : mapIdToPBEPList.keySet()){
            List<Pricebook_Entry_Period__c> pbepList = mapIdToPBEPList.get(key);
            for(Pricebook_Entry_Period__c pbep : pbepList){
                if(this.setProcessedProductIds.contains(pbep.Product__c) && pbep.Process_NR_Batch__c){
                    pbep.Process_NR_Batch__c = false;
                    updatePricebookEntryPeriodList.add(pbep);
                }
            }
        }
        listErrorLog.addAll(resetProcessedPBEPFlags(updatePricebookEntryPeriodList));

        // Inserts all errors into database
        CRM_ErrorLogger.logError(listErrorLog);
    }

    /**
     * @Description - Method to reset the Process NR Batch flag as the NR Product is processed properly for that PBEP
     * @name resetProcessedPBEPFlags
     * @return List<CRM_ErrorLogger.ErrorLog> Returns the error logs that needs to be stored in database object
     */
    @TestVisible
    private List<CRM_ErrorLogger.ErrorLog> resetProcessedPBEPFlags(List<Pricebook_Entry_Period__c> updateProcessedPBEPList){
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        if (!updateProcessedPBEPList.isEmpty()) {
            //System.debug('--updateProcessedPBEPList->'+updateProcessedPBEPList);
            Database.SaveResult[] saveResultList = Database.update(updateProcessedPBEPList,false);
            
            for(Integer i = 0; i < saveResultList.size(); i++){
                Database.SaveResult saveResultInstance = saveResultList[i];
                Pricebook_Entry_Period__c pbepInstance = updateProcessedPBEPList[i];
                //System.debug('--PBEP-pbepInstance->'+pbepInstance);
                if (!saveResultInstance.isSuccess()){
                    //System.debug('--PBEP-Error->');
                    // Add these errors in Error wrapper Class and prepare a list of same
                    // Error Handling
                    List<String> lstErrors = new List<String>();
                    //lstErrors.add('Pricebook Entry Period Record with Id "'+ +'" not processed properly due to below reasons');
                    lstErrors.add(String.format(System.Label.CRM_PBEP_Not_Processed,new String[]{pbepInstance.Id}));

                    for(Database.Error err :saveResultInstance.getErrors()){
                        lstErrors.add(err.getMessage());

                        // Save the error in database
                        CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                        errorLog.recordId = pbepInstance.Id;
                        errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_NR_PRODUCTS;
                        errorLog.errorMessage = err.getMessage().left(200);
                        listErrorLog.add(errorLog);
                    }
                    this.lstExceptions.add(new CRMJV_AutoPhysicalNRDealBatchService.CRMJV_AutoPhysicalNRDealServiceException(pbepInstance.Product__c,lstErrors));
                }
            }
        }
        return listErrorLog;
    }    

    /**
     * @Description - Method to reset the NR_Product_Created__c flag as the NR product is processed properly
     * @name resetProcessedProductFlags
     * @return List<CRM_ErrorLogger.ErrorLog> Returns the error logs that needs to be stored in database object
     */
    @TestVisible
    private List<CRM_ErrorLogger.ErrorLog> resetProcessedProductFlags(List<Product2> updateProcessedProductList,Set<Id> setProcessedProductIds){
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        if (!updateProcessedProductList.isEmpty()){
            Database.SaveResult[] saveResultList = Database.update(updateProcessedProductList,false);
            
            for(Integer i = 0; i < saveResultList.size(); i++){
                Database.SaveResult saveResultInstance = saveResultList[i];
                Product2 productInstance = updateProcessedProductList[i];
                //System.debug('--productInstance.Id-->'+productInstance.Id);
                //System.debug('--saveResultInstance.getId()-->'+saveResultInstance.getId());
                if(!saveResultInstance.isSuccess()){
                    //System.debug('--in if-product failure---->');
                    setProcessedProductIds.remove(productInstance.Id);

                    // Add these errors in Error wrapper Class and prepare a list of same
                    // Error Handling
                    List<String> lstErrors = new List<String>();
                    for(Database.Error err : saveResultInstance.getErrors()){
                        lstErrors.add(err.getMessage());

                        // Save the error in database
                        CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                        errorLog.recordId = productInstance.Id;
                        errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_NR_PRODUCTS;
                        errorLog.errorMessage = err.getMessage().left(200);
                        listErrorLog.add(errorLog);
                    }
                    this.lstExceptions.add(new CRMJV_AutoPhysicalNRDealBatchService.CRMJV_AutoPhysicalNRDealServiceException(productInstance.Id,lstErrors));
                }
            }
        }
        return listErrorLog;
    }    

    /**
     * @Description - Method to fetch all New Release products that needs to be processed for automatic Deal creation
     * @name getNRProducts 
     * @return List<Product2> List of all NR products
     */
    @TestVisible
    private List<Product2> getNRProducts(){
        List<Id> targetProductIds = new List<Id>();
        List<Id> pbepProductIds = new List<Id>();
        Set<Date> excludeInvalidDate = new Set<Date>{Date.newInstance(4000,12,31)};

        CRM_Batch_Size__c targetBatchSizeInstance = CRM_Batch_Size__c.getInstance('Target Limit In Auto NR Batch');
        Integer defaultTargetLimit = targetBatchSizeInstance != null ? (Integer) targetBatchSizeInstance.Batch_Size__c : 10000;

        for (Target__c targetInstance : [
                SELECT Id,Account__c,Product__c,Target__c,Target_Units__c,Target_Revenue_Has_Changed__c,NR_Version__c,
                    Account__r.Sales_Organization__c,Product__r.RecordTypeId,Product__r.SAP_Sales_Org__c
                FROM Target__c
                WHERE Target_Revenue_Has_Changed__c = true AND RecordTypeId =: CRM_RecordTypeUtil.RT_TARGET_PRODUCT
                    AND (Target__c != null OR Target_Units__c != null)
                    AND Product__c != null AND Product__r.RecordTypeId =: CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT
                    AND Product__r.SAP_Sales_Org__c IN: CRM_AppConstants.SALES_JV_ORGS
                    AND Product__r.Street_Date__c NOT IN: excludeInvalidDate
                    AND Account__c != null AND Account__r.Planning_Customer__c = true
                    AND Account__r.Sales_Organization__c != null 
                    AND Account__r.Sales_Organization__c IN: CRM_AppConstants.SALES_JV_ORGS
                    AND Account__r.Video_Physical__c = true 
                    AND Account__r.Games_Physical__c = false
                    AND Account__r.Music_Physical__c = false 
                    AND Account__r.Video_Digital__c = false
                    AND Account__r.Games_Digital__c = false
                    AND Account__r.Music_Digital__c = false
                LIMIT :defaultTargetLimit]){
            targetProductIds.add(targetInstance.Product__c);
        }
        System.debug('@@targetProductIds-->'+targetProductIds);

        for (Pricebook_Entry_Period__c pbepInstance : [
                SELECT Id,Product__c,Start_Date__c,Product__r.RecordTypeId,Price_Book__c,End_Date__c,List_Price__c,Account_Price__c,
                    New_Release__c,CurrencyIsoCode,Minimum_Price__c,Retail_Price__c,Material_Price_Group__c,Price_Type__c,Product__r.ProductCode
                FROM Pricebook_Entry_Period__c
                WHERE
                    Process_NR_Batch__c = true
                    AND Product__r.RecordTypeId =: CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT
                    AND Product__r.SAP_Sales_Org__c IN: CRM_AppConstants.SALES_JV_ORGS
                    AND Product__r.Street_Date__c NOT IN: excludeInvalidDate
                    ORDER BY Start_Date__c,CreatedDate ASC]){
            pbepProductIds.add(pbepInstance.Product__c);
        }
        System.debug('@@pbepProductIds-->'+pbepProductIds);

        // Process on product records whose Record Type = "Product", Type = "New Release",
        // StreeDate and Target Revenue has been updated
        String queryString = 'SELECT Id,Name,Type__c,Street_Date__c,Previous_Street_Date__c,CurrencyIsoCode,Exclusive_Customer__c, ' +
                'Street_Date_Has_Changed__c,Product_Type__c,Product_Format__c,NR_Product_Created__c,Product_Price_Group__c,IsActive, '+
                'NR_Version__c,Product_Market__c,RecordTypeId,SAP_Sales_Org__c,ProductCode, '+
                '(' +
                    'SELECT Id,Product__c,Start_Date__c,Price_Book__c,Process_NR_Batch__c,Material_Price_Group__c,End_Date__c, '+
                        'List_Price__c,Account_Price__c,New_Release__c,CurrencyIsoCode,Minimum_Price__c,Retail_Price__c,Price_Type__c,Product__r.ProductCode ' +
                    'FROM Pricebook_Entry_Periods__r ' +
                    'ORDER BY Start_Date__c DESC ' +
                ') ' +
            'FROM Product2 ' +
            'WHERE RecordTypeId = \'' + CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT + '\'' +
                ' AND Product_Type__c = \'' + CRM_AppConstants.PRODUCT_TYPE_NEW_RELEASE + '\'' +
                ' AND SAP_Sales_Org__c IN (\'' + String.join(listSalesJVOrgs, '\',\'') + '\')' +
                ' AND Type__c != null'+
                ' AND Type__c =\''+ CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE +'\''+
                ' AND IsActive = true'+
                ' AND Street_Date__c >= TODAY'+
                ' AND Street_Date__c NOT IN: excludeInvalidDate'+
                ' AND Exclusive_Customer__c = null'+
                ' AND ('+
                         'Street_Date_Has_Changed__c = true' +
                    ' OR (' +
                            'NR_Product_Created__c = true' +
                        ')';

        if(!targetProductIds.isEmpty() && targetProductIds.size() > 0){
            queryString += ' OR ( Id IN (\'' + String.join(targetProductIds, '\',\'') + '\'))';
        }
        if(!pbepProductIds.isEmpty() && pbepProductIds.size() > 0){
            queryString += ' OR ( Id IN (\'' + String.join(pbepProductIds, '\',\'') + '\'))';
        }

        CRM_Batch_Size__c batchSizeInstance = CRM_Batch_Size__c.getInstance('Product Limit In Auto NR Batch');
        Integer defaultBatchSize = batchSizeInstance != null ? (Integer) batchSizeInstance.Batch_Size__c : 500;
        queryString += ') Order by CreatedDate DESC LIMIT ' + defaultBatchSize;
        System.debug('@@product query-->'+queryString);
        return Database.query(queryString);
    }

    /**
    *  Method to fetch Valid Pricebook_Entry_Period__c For ProductCodes with COT
    *  @name getValidPBEPForProduct
    *  @param Opportunity opportunityObject,Set<String> setProductCode
    *  @return map of list of Pricebook_Entry_Period__c with unique key 
    **/ 
    private static Map<String,List<Pricebook_Entry_Period__c>> prepareMapWithExistingPBEP(List<Product2> lstProducts){
        Map<String,List<Pricebook_Entry_Period__c>> mapIdToPBEPLocalList = new Map<String, List<Pricebook_Entry_Period__c>>();
        String priceTypeStr;
        String key;
        for(Product2 productInstance : lstProducts){
            if(productInstance.Pricebook_Entry_Periods__r.size() > 0){
                for(Pricebook_Entry_Period__c pbep : productInstance.Pricebook_Entry_Periods__r){
                    priceTypeStr = pbep.Price_Type__c != null ? '-' + pbep.Price_Type__c.toUpperCase() : '';
                    key = pbep.Product__r.ProductCode + '-' + pbep.Price_Book__c + '-' + pbep.CurrencyIsoCode + priceTypeStr;
                    if(mapIdToPBEPLocalList.containsKey(key)){
                        mapIdToPBEPLocalList.get(key).add(pbep);
                    }else{
                        mapIdToPBEPLocalList.put(key, new List<Pricebook_Entry_Period__c>{pbep});
                    }
                }
            }
        }
        return mapIdToPBEPLocalList;
    }
}