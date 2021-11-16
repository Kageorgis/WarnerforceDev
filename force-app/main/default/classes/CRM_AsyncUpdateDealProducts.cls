/**
   @Author Cognizant (Dilip Mistry)
   @name CRM_AsyncUpdateDealProducts
   @CreateDate 07 Mar 2017
   @Description Helper class to perform deal products update in asynchronous mode using queueable apex 
   @Version <1.0>
*/
public with sharing class CRM_AsyncUpdateDealProducts implements Queueable {
    public OpportunityLineItem[] dealProductsToUpdate;
    public OpportunityLineItem[] remainingDealProducts;
    public Integer CHUNK_SIZE;
    
    /* Constructor */
    public CRM_AsyncUpdateDealProducts(OpportunityLineItem[] allDealProductsToUpdate) {
        System.debug('allDealProductsToUpdate size--->'+ allDealProductsToUpdate.size());
        if(allDealProductsToUpdate != null && !allDealProductsToUpdate.isEmpty()) {
            
            CHUNK_SIZE = getProcessingBatchSize();
            
            // split all the deal products into two list
            // 1. Deal Products to be updated
            // 2. Deal Products to be updated in next batches (if there are more number of records)
            dealProductsToUpdate = new OpportunityLineItem[]{};
            remainingDealProducts = new OpportunityLineItem[]{};
            system.debug('lst Size : '+allDealProductsToUpdate.size());
            system.debug('CHUNK_SIZE : '+CHUNK_SIZE);
            for(Integer i=0; i < allDealProductsToUpdate.size(); i++) {
                if(i < CHUNK_SIZE) {
                    this.dealProductsToUpdate.add(allDealProductsToUpdate[i]);
                }
                else {
                    this.remainingDealProducts.add(allDealProductsToUpdate[i]);
                }
            }
        }
    }
    
    /* method to update deal products */
    public void execute(QueueableContext context) {
        system.debug('execute');
        if(!dealProductsToUpdate.isEmpty()) {
	        Database.SaveResult[] saveResults = database.update(this.dealProductsToUpdate, false);
	        
	        logUpdateErrors(saveResults, this.dealProductsToUpdate);
        }
        
        if(!remainingDealProducts.isEmpty()) {
            processNextChunk(remainingDealProducts);
        }
    }
    
    /* invoke chaining of the queueable apex for the remaining deal products */
    public void processNextChunk(OpportunityLineItem[] listDealProducts){
        // use async Queueable calls to update Deal Products 
        if(!Test.isRunningTest()) 
			System.enqueueJob(new CRM_AsyncUpdateDealProducts(listDealProducts));
    }
    
    /* method to get the batch size for deal products update */
    private Integer getProcessingBatchSize() {
        Integer DEFAULT_BATCH_SIZE = 200;
        
        CRM_Batch_Size__c batchSizeSetting = CRM_Batch_Size__c.getInstance('UpdateRelatedDealProducts_QJob');
        return (batchSizeSetting != null ?  (Integer) batchSizeSetting.Batch_Size__c : DEFAULT_BATCH_SIZE);
    }
    
    /* method to log the errors */
    public void logUpdateErrors(Database.SaveResult[] saveResults, OpportunityLineItem[] listDealProducts){
        CRM_ErrorLogger.ErrorLog[] listErrorLogs = new CRM_ErrorLogger.ErrorLog[]{};
            
        // Log the errors during update
        for(Integer i=0; i< saveResults.size(); i++) {
            Database.SaveResult  sr = saveResults[i];
            
            if (!sr.isSuccess()) {
                // Operation failed, so get all errors               
                for(Database.Error err : sr.getErrors()) {
                    CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
                    errorLogInstance.recordId = sr.getId() != null ? sr.getId() : dealProductsToUpdate[i].Id;
                    errorLogInstance.functionalModule = CRM_AppConstants.FUNCTIONAL_MODULE_DEALS;
                    errorLogInstance.className = 'CRM_AsyncUpdateDealProducts';
                    errorLogInstance.errorMessage = err.getMessage().left(250);
                       
                    listErrorLogs.add(errorLogInstance);
                }
            }
        }
        
        // log the errors occured in deal products update process
        if(!listErrorLogs.isEmpty()) {
            CRM_ErrorLogger.logError(listErrorLogs);
        }
    }
}