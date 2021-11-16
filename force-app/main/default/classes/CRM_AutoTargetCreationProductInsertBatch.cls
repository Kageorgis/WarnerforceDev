/**
   @Author Cognizant
   @name CRM_AutoTargetCreationProductInsertBatch
   @CreateDate 13 Sept 2016
   @Description This batch class is responsible for automatic creation of Country Plans, Country Plan Targets, Account Plans and 
   account plan targets for Newly inserted products and corresponding accounts.
   @Version <1.0>
   @reference Requirement no 369
*/

global with sharing class CRM_AutoTargetCreationProductInsertBatch implements Database.Batchable<sObject>, Database.stateful {

   global final String query;
   global Map<Id, Product2> mapProducts;
   global set<Id> failedProd = new set<Id>();

    /**
     * Batch constructor to assign query
    */
    global CRM_AutoTargetCreationProductInsertBatch() {
    // Query for fetching 'Sold To' Accounts with corresponding PriceBooks
        this.query = 'SELECT ' + 
                'Id, ' +
                'Name, ' +
                'Sales_Organization__c, ' +
                'Price_Book__c, ' +
                'Games_Digital__c, ' +
                'Video_Digital__c, ' +
                'Games_Physical__c, ' +
                'Video_Physical__c, ' +
                'CurrencyIsoCode, ' +
                'OwnerId, '+
                'Status__c, '+
                'External_Id__c, '+
                'Owner_Games__c '+
            'FROM ' +
                'Account ' +
            'WHERE ' +
                ' RecordTypeId = \'' + CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO + '\' ' +
                ' AND Price_Book__c != null'+
                ' AND External_Id__c != null' +
                ' AND ( Games_Digital__c = true ' +
                        ' OR Video_Digital__c = true ' +
                        ' OR Games_Physical__c = true ' +
                        ' OR Video_Physical__c = true ' +
                    ')' +
                ' AND ( Status__c = \'' + CRM_AppConstants.ACCOUNT_STATUS_ACTIVE + '\' ' +
                        ' OR Status__c = \'' + CRM_AppConstants.ACCOUNT_STATUS_BLOCKED + '\' ' +
                    ')';
        
    }
    
    /**
     * Start method of batch to fetch all NR Product records
    **/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        this.mapProducts = new Map<Id, Product2>(getNRProducts());
        System.debug('--this.mapProducts-->'+this.mapProducts);
        
        System.debug('------this.query------>'+this.query);
        return Database.getQueryLocator(this.query);
    }
    
     /**
     * Execute method of batch to process on NR Product records and create
     * Deal or Deal Product records accordingly
     */
    global void execute(Database.BatchableContext BC, List<Account> accountList) {
        System.debug('--accountList-->'+accountList);
        if(!this.mapProducts.isEmpty()){
            
            System.debug('--this.mapProducts inside-->'+this.mapProducts);
            failedProd.addAll(CRM_AutoTargetCreationHelper.helperFunctionsToBeInvokedFromProdBatch(accountList,this.mapProducts));
        }
        
    }
    
    /**
     * Finish method of batch process.
    */
    global void finish(Database.BatchableContext BC) {
        
        Decimal batchSize =  10;
        
        CRM_Batch_Size__c setting = CRM_Batch_Size__c.getInstance('Auto Target Product Batch');
        if(setting != null && setting.Batch_Size__c != null){
            batchSize = setting.Batch_Size__c;
        }
        
        if(!this.mapProducts.isEmpty()){
            System.debug('--failedProd -->'+failedProd);
            updateProductFlag();
            
            Integer prodCount = [SELECT count() FROM Product2 
                                        WHERE Id NOT IN :failedProd 
                                        AND Pending_Country_Plan_Creation__c = true 
                                        AND (Type__c =: CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE OR Type__c =: CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE 
                                                OR Type__c =: CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE OR Type__c =: CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE)];
                                    
            System.debug('--prodCount-->'+prodCount);
            if(prodCount > 0){
                CRM_AutoTargetCreationProductInsertBatch b = new CRM_AutoTargetCreationProductInsertBatch();
                b.failedProd = failedProd;
                Id batchJobId = Database.executeBatch(b, Integer.valueOf(batchSize));
            }else{
                BatchStatusNotification.sendBatchStatusMail(BC,'Auto Target Product Batch'); 
            }
        }else{
            BatchStatusNotification.sendBatchStatusMail(BC,'Auto Target Product Batch'); 
        }
    }
    
    /**
     * @Description - Method to update Products that have been processed and logs error if found while updating
     * @name updateProductFlag 
     * @return void
    */
    private void updateProductFlag(){
        
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        
        List<Product2> prodList = new List<Product2>();
        prodList = this.mapProducts.values();
        
        for(Product2 prod : prodList){
            if(!failedProd.contains(prod.Id)){
                prod.Pending_Country_Plan_Creation__c = false;
            }
        }
        
        if(prodList != null && prodList.size() > 0){
             Database.SaveResult[] result = Database.Update(prodList, false);
             Product2 prod = new Product2();
             for(Integer i=0; i < result.size(); i++ ){
                prod = prodList[i];
                if(!result[i].isSuccess()){
                    failedProd.add(prod.Id);
                    List<CRM_ErrorLogger.ErrorLog> errorLogInstance = CRM_AutoTargetCreationHelper.logAnException(result[i].getErrors(), result[i].getId(), 'Final Prod Update : Prod =' + string.valueOf(Prod.id) );
                    listErrorLog.addAll(errorLogInstance);
                }
             }
         }
         CRM_ErrorLogger.logError(listErrorLog); 
    }
    
    
    /**
     * @Description - Method to fetch all New Release products that needs to be processed for automatic country plan creation
     * @name getNRProducts 
     * @return List<Product2> List of all NR products
     */
    @TestVisible
    private List<Product2> getNRProducts() {
        
        Decimal batchSize =  10;
        
        CRM_Batch_Size__c setting = CRM_Batch_Size__c.getInstance('Product Size in Target Product Batch');
        if(setting != null && setting.Batch_Size__c != null){
            batchSize = setting.Batch_Size__c;
        }
        
        Integer batchSizeInteger = Integer.valueOf(batchSize);
        
        String queryString =
            'SELECT ' +
                'Id, ' +
                'Name, '+
                'Type__c, ' +
                'Street_Date__c, ' +
                'Previous_Street_Date__c, ' +
                'CurrencyIsoCode, ' +
                'Exclusive_Customer__c, ' +
                'Street_Date_Has_Changed__c, '+
                'Product_Type__c, ' +
                'Product_Format__c, ' +
                'NR_Product_Created__c, '+
                'Product_Price_Group__c, '+
                'Local_Title__r.Country__r.Country_Code2__c, '+
                'Local_Title__r.Country__r.currencyISOCode, '+
                'Local_Title__r.Country__r.Name, '+
                'IsActive, '+
                'NR_Version__c, '+
                'RecordTypeId, '+
                'External_Id__c, '+
                //'SAP_Sales_Org__c, '+
                '( ' +
                    'SELECT ' +
                        'Id, Product__c, Start_Date__c, Price_Book__c, ' + //Suggested_Price__c, - US#895 - removed ref. of suggested price
                        'End_Date__c, List_Price__c, Account_Price__c,New_Release__c, CurrencyIsoCode ' +
                    'FROM ' +
                        'Pricebook_Entry_Periods__r ' +
                    'WHERE' +
                        ' Product__c != null'+
                        ' AND Price_Book__c != null '+
                    'ORDER BY Start_Date__c, CreatedDate,Product__c, Price_Book__c, CurrencyISOCode' +
                ') ' +
            'FROM ' +
                'Product2 ' +
            'WHERE ' +
                'Id NOT IN :failedProd ' +
                ' AND Type__c != null'+
                ' AND Pending_Country_Plan_Creation__c = true' +
                ' AND Street_Date__c != null' +
                ' AND External_Id__c != null' +
                ' AND Local_Title__r.Country__r.Country_Code2__c != null '+
                 ' AND ( Type__c = \'' + CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE + '\' ' +
                        ' OR Type__c = \'' + CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE + '\' ' +
                        ' OR Type__c = \'' + CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE + '\' ' +
                        ' OR Type__c = \'' + CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE + '\' ' +
                    ')' +
                    'Limit : batchSizeInteger';
        
        System.debug('---queryString----->'+queryString);
        return Database.query(queryString); 
    }
}