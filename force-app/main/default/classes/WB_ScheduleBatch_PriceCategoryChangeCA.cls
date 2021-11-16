global class WB_ScheduleBatch_PriceCategoryChangeCA implements Schedulable{

   global void execute(Schedulablecontext sc){
       WB_Batch_PriceCategoryChangeClientAvail wbCatalogBatch = new WB_Batch_PriceCategoryChangeClientAvail();
       Integer batchSize = WB_Populate_TRD_On_LT__c.getInstance('WB_Catalog_Reprice_Reminder_Batch_Size') != null ? Integer.valueOf(WB_Populate_TRD_On_LT__c.getInstance('WB_Catalog_Reprice_Reminder_Batch_Size').Batch_Size__c) : 200;
       Database.executebatch(wbCatalogBatch,batchSize);
    }
}