/**
 * @Author: Cognizant
 * @Name: CRM_UpdateDealProductFormatBatch
 * @CreateDate: 1st June 2017 
 * @Description: Batch class to update Format on Deal Product
 * @Version 1.0
 */
global with sharing class CRM_UpdateDealProductFormatBatch implements Database.Batchable<SObject>,Database.Stateful {
    /**
     *  Start method of Batch
     *  @Name start
     *  @return  Query locator  - returning the records from query string
     */
    global Database.QueryLocator start(Database.BatchableContext bc){
        //Batch Size from Custom Settings
        CRM_Batch_Size__c batchSizeInstance = CRM_Batch_Size__c.getInstance('UpdateDealProductFormatBatch');
        Integer defaultBatchSize = batchSizeInstance != null ? (Integer) batchSizeInstance.Batch_Size__c : 500000;
            
        String query = 'Select Id, Format__c, Product2.Product_Format__c From OpportunityLineItem Where Format__c = null AND Product2.Product_Format__c != null Limit' + ' ' + defaultBatchSize;
        return Database.getQueryLocator(query);
    } 
    
    /**
     * Execute method of Batch
     * @name execute
     * @param scopeDealProduct- For storing the records returned from Start method
     */
    global void execute(Database.BatchableContext bc, List<OpportunityLineItem> scopeDealProduct){
        List<OpportunityLineItem> lstDealProductToUpdate = new List<OpportunityLineItem>();
        List<CRM_ErrorLogger.ErrorLog> listErrorLog = new List<CRM_ErrorLogger.ErrorLog>();
        
        System.debug('#scopeDealProduct' + scopeDealProduct);
        for(OpportunityLineItem objDealProduct: scopeDealProduct){
            objDealProduct.Format__c = objDealProduct.Product2.Product_Format__c;  
            lstDealProductToUpdate.add(objDealProduct); 
        }
       
        //Update DealProduct Format
        System.debug('#lstDealProductToUpdate' + lstDealProductToUpdate);
        if(!lstDealProductToUpdate.isEmpty()){
            Database.SaveResult[] saveResultList = Database.update(lstDealProductToUpdate, false);
            for(Integer i = 0; i < saveResultList.size(); i++) {
                Database.SaveResult saveResultInstance = saveResultList[i];
                if (!saveResultInstance.isSuccess()) {
                    for(Database.Error err : saveResultInstance.getErrors()) {
                        // Save the error in database
                        CRM_ErrorLogger.ErrorLog errorLog = new CRM_ErrorLogger.ErrorLog();
                        errorLog.recordId = lstDealProductToUpdate[i].Id;
                        errorLog.functionalModule = 'DealProduct Format Update';
                        errorLog.errorMessage = err.getMessage().left(200);
                        listErrorLog.add(errorLog);
                    }
                }
            }
            
            //Inserts all errors into database
            if(!listErrorLog.isEmpty()){
                CRM_ErrorLogger.logError(listErrorLog);     
            }
        }
    }
    
    /**
     * Finish method of batch process.
     */
    global void finish(Database.BatchableContext bc){}
}