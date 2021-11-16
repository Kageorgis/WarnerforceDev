/**
 * @Author: Harshad Bidwai
 * @name CRM_ProcessAccountBatchForRBA
 * @CreateDate 19th Feb 2017
 * @Description: Batch class to create RBA deals for active UK retailer account
 * @Version 1.0
 */
 
 global with sharing class CRM_ProcessAccountBatchForRBA implements Database.batchable<sObject>, Database.stateful {
    global List<CRM_ProcessAccountsBatchForRBAException> lstExceptions = new List<CRM_ProcessAccountsBatchForRBAException>();    
    /**
     *  Start method of Batch
     *  @name start
     *  @return  Query locator  - returning the records from query string
     */
    global Database.queryLocator start(Database.BatchableContext BC) { 
              return Database.getQueryLocator([SELECT Id, Name, OwnerId, CurrencyIsoCode FROM Account 
              WHERE Sales_Organization__c = :CRM_AppConstants.TERRITORY_UK_CODE AND (Games_Physical__c = true OR Video_Physical__c = true) 
              AND Status__c = :CRM_AppConstants.ACCOUNT_STATUS_ACTIVE AND RecordTypeId = :CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO]);
       }       
    /**
     * Execute method of Batch
     * @name execute
     * @param scopeAccountList - For storing the records returned from Start method
     */
    global void execute(Database.BatchableContext BC, List<Account> scopeAccountList) {
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        Map<String, Opportunity> dealMap = new Map<String, Opportunity>();
        List<String> lstDealName = new List<String>();
        String dealMapKey;
        
        try{
            // Create deal for each account in scope
            if (!scopeAccountList.isEmpty() && scopeAccountList.size() > 0) {
                for (Integer accIndex = 0; accIndex < scopeAccountList.size(); accIndex++) { 
                    Account objAccount = scopeAccountList[accIndex];
                    String AccountName = objAccount.Name.length() > Integer.valueOf(System.Label.CRM_Max_Chars_for_AccountName) ? 
                            objAccount.Name.subString(0,Integer.valueOf(System.Label.CRM_Max_Chars_for_AccountName)) : objAccount.Name;
                    for (Integer dealIndex = 0; dealIndex <= Integer.valueOf(System.Label.CRM_Number_Of_Months_For_RBA_Deal)-1; dealIndex++ ) {
                        String dealName = System.Label.CRM_RBA_Deal_Creation + ' ' +AccountName + ' ' +System.now().addMonths(dealIndex).format('MMM') + '-' 
                        + System.now().addMonths(dealIndex).format('YY');
                    
                        Opportunity rbaDeal = new Opportunity(Name = dealName, RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_RBA, 
                          AccountId = objAccount.Id, 
                          OwnerId = objAccount.OwnerId, 
                          CurrencyIsoCode = objAccount.CurrencyIsoCode, 
                          StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED,
                          Start_Date__c = Date.today().addMonths(dealIndex).toStartofMonth(),
                          CloseDate = Date.today().addMonths(dealIndex+1).toStartofMonth().addDays(-1),
                          Promo_Start_Date__c = Date.today().addMonths(dealIndex).toStartofMonth(), 
                          Promo_End_Date__c = Date.today().addMonths(dealIndex+1).toStartofMonth().addDays(-1));
                          dealMapKey = dealName +'-'+ objAccount.Id;
                          
                        dealMap.put(dealMapKey, rbaDeal);
                        
                        lstDealName.add(dealName);
                      }                                                            
                }

                List<Opportunity> lstExistingDeals = [select name,AccountId from Opportunity where name in :lstDealName AND RecordTypeId = :CRM_RecordTypeUtil.RT_DEAL_RBA];
                for(Opportunity deal : lstExistingDeals){
                	String key = deal.Name+'-'+deal.AccountId;
                	if(dealMap.containsKey(key))
	                	dealMap.remove(key);                	
                }                
 
                Database.SaveResult[] saveResultList = Database.insert(dealmap.values(), false);
               // listErrorLog = CRM_DatabaseErrorHandlerForRBA.handleDatabaseInsert(saveResultList, dealmap, listErrorLog);
                
                for (Integer saveResultIndex = 0; saveResultIndex < saveResultList.size(); saveResultIndex++) {
                    Database.SaveResult saveResultInstance = saveResultList[saveResultIndex];
                    if (!saveResultInstance.isSuccess()) {
                        // Add these errors in Error wrapper Class and prepare a list of same
                        // Error Handling
                        List<String> lstErrors = new List<String>();
                        for(Database.Error err : saveResultInstance.getErrors()) {
                            lstErrors.add(err.getMessage());
                            CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                            errorLog.recordId = dealmap.values()[saveResultIndex].AccountId;
                            errorLog.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_UPDATE_PRODUCT_FOR_SCHEDULE_DATE;
                            errorLog.errorMessage = err.getMessage().left(200);
                            listErrorLog.add(errorLog);
                        }
                        this.lstExceptions.add(
                            new CRM_ProcessAccountsBatchForRBAException(
                                dealmap.values()[saveResultIndex].AccountId,
                                lstErrors
                            )
                        );
                    }
                }  
            }
        }
        catch(Exception e){
         listErrorLog = CRM_DatabaseErrorHandlerForRBA.logAnException(e);
         
         List<String> lstErrors = new List<String>();
           lstErrors.add(e.getMessage());
           
         //Adding Exception
         this.lstExceptions.add(
            new CRM_ProcessAccountsBatchForRBAException(
                null,
                lstErrors
            )
        );   
      
      }
        // Inserts all errors into database
        CRM_ErrorLogger.logError(listErrorLog);
    }
      
   /**
     * Finish method of batch process.
     */
    global void finish(Database.BatchableContext BC) {
        // Send mail only if errors present
        if (!this.lstExceptions.isEmpty()){
             CRM_DatabaseErrorHandlerForRBA.sendMail(this.lstExceptions);
        }else{
            BatchStatusNotification.sendBatchStatusMail(BC,'Process Account Batch For RBA');
        }
    }
   /**
     * @Description - Class for Exception Handling
     * @name CRM_ProcessAccountsBatchForRBAException
     */
    public class CRM_ProcessAccountsBatchForRBAException extends Exception {
        public Id recordId;
        public List<String> lstErrors;
        public CRM_ProcessAccountsBatchForRBAException(Id recordId, List<String> lstErrors){
            this.recordId = recordId;
            this.lstErrors = lstErrors;
        }
    }
 }