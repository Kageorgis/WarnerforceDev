/**
   @Author Cognizant Tech.
   @name CRM_InsertPBEPOnProdListPriceScheduler 
   @CreateDate 27 September 2016
   @Description Schedulable class to schedule the CRM_InsertPBEPOnProductListPriceBatch.
   @Version <1.0>
   @reference Requirement no 562
*/
global with sharing class CRM_InsertPBEPOnProdListPriceScheduler implements Schedulable {
    global void execute(SchedulableContext contextInstance) {
        //Batch instance 
        CRM_InsertPBEPOnProductListPriceBatch batchInstance = new CRM_InsertPBEPOnProductListPriceBatch();
        //Execute Batch
        Decimal batchSize =  100;
        CRM_Batch_Size__c setting = CRM_Batch_Size__c.getInstance('Insert PBEPOnProdListPrice Batch');
        if(setting != null && setting.Batch_Size__c != null){
            batchSize = setting.Batch_Size__c;
        } 
        Database.executeBatch(batchInstance,Integer.valueOf(batchSize));
    }
}