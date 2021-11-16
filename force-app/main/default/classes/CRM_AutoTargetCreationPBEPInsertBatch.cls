/**
   @Author Cognizant
   @name CRM_AutoTargetCreationPBEPInsertBatch
   @CreateDate 27 Sept 2016
   @Description This batch class is responsible for automatic creation of Account Plans and 
   account plan targets for Newly inserted PBEP for corresponding products and accounts.
   @Version <1.0>
   @reference Requirement no 369
*/

global with sharing class CRM_AutoTargetCreationPBEPInsertBatch implements Database.Batchable<sObject>, Database.stateful {

   global final String query;
   global set<Id> pbepSet = new set<Id>();

    /**
     * Batch constructor to assign query
    */
    global CRM_AutoTargetCreationPBEPInsertBatch() {
    // Query for fetching 'Sold To' Accounts with corresponding PriceBooks
     this.query = 'SELECT ' + 
                'Id, ' +
                'Name, ' +
                'Sales_Organization__c, ' +
                'Price_Book__c, ' +
                'CurrencyIsoCode, ' +
                'External_Id__c, '+
                'Product__c '+
            'FROM ' +
                'Pricebook_Entry_Period__c ' +
            'WHERE ' +
                ' Pending_Account_Plan_Creation__c = true ' +
                ' AND Price_Book__c != null';
    }
    
    /**
     * Start method of batch to fetch all PBEP records
    **/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('------this.query------>'+this.query);
        return Database.getQueryLocator(this.query);
    }
    
     /**
     * Execute method of batch to process on NR Product records and create
     * Deal or Deal Product records accordingly
     */
    global void execute(Database.BatchableContext BC, List<Pricebook_Entry_Period__c> PBEPList) {
       System.debug('--PBEPList-->'+PBEPList);
       List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
       For(Pricebook_Entry_Period__c pbep : PBEPList){
           pbepSet.add(pbep.Price_Book__c);
           pbep.Pending_Account_Plan_Creation__c = false;
       }
       if(PBEPList != null && PBEPList.size() > 0){
             Database.SaveResult[] result = Database.Update(PBEPList, false);
             Pricebook_Entry_Period__c pbep = new Pricebook_Entry_Period__c();
             for(Integer i=0; i < result.size(); i++ ){
                pbep = PBEPList[i];
                if(!result[i].isSuccess()){
                    List<CRM_ErrorLogger.ErrorLog> errorLogInstance = CRM_AutoTargetCreationHelper.logAnException(result[i].getErrors(), result[i].getId(), 'Final PBEP Update : PBEP =' + string.valueOf(pbep.Id));
                    listErrorLog.addAll(errorLogInstance);
                }
             }
         }
       CRM_ErrorLogger.logError(listErrorLog); 
       
    }
    
    /**
     * Finish method of batch process.
    */
    global void finish(Database.BatchableContext BC) {
        
        if(!pbepSet.isEmpty()){
            updateAccountFlag();
        }
         Decimal batchSize =  10;
        
        CRM_Batch_Size__c setting = CRM_Batch_Size__c.getInstance('Auto Target Account Batch');
        if(setting != null && setting.Batch_Size__c != null){
            batchSize = setting.Batch_Size__c;
        }
        BatchStatusNotification.sendBatchStatusMail(BC,'Auto Target PBEP Insert Batch');
        //Batch instance 
        CRM_AutoTargetCreationAccountInsertBatch batchInstance = new CRM_AutoTargetCreationAccountInsertBatch();
        //Execute Batch
        Database.executeBatch(batchInstance, Integer.valueOf(batchSize));
    }
    
    /**
     * @Description - Method to fetch and update all Related Accounts that needs to be processed for automatic account plan creation
     * @name updateAccountFlag 
     * @return void
    */
    
    private void updateAccountFlag(){
        
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        
        List<Account> accList = [Select Id,Pending_Account_Plan_Creation__c,Price_Book__c from Account where Price_Book__c in :pbepSet and Pending_Account_Plan_Creation__c = false];
        
        for(Account acc : accList){
                acc.Pending_Account_Plan_Creation__c = true;
        }
        
        if(accList != null && accList.size() > 0){
             Database.SaveResult[] result = Database.Update(accList, false);
             Account acc = new Account();
             for(Integer i=0; i < result.size(); i++ ){
                acc = accList[i];
                if(!result[i].isSuccess()){
                    List<CRM_ErrorLogger.ErrorLog> errorLogInstance = CRM_AutoTargetCreationHelper.logAnException(result[i].getErrors(), result[i].getId(), 'Final Acc Update : Account =' + string.valueOf(acc.Id));
                    listErrorLog.addAll(errorLogInstance);
                }
             }
         }
         CRM_ErrorLogger.logError(listErrorLog); 
    }
   
}