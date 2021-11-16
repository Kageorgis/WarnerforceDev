global class CRM_CreateProductsBatch implements Database.Batchable<sObject>, Database.stateful {
    List<String> lstCountries = new List<String>();
    Product_Creation_Batch_Setting__c ProductCreationSetting = Product_Creation_Batch_Setting__c.getInstance('Default');
    Boolean GenerateCRMProducts = ProductCreationSetting.Generate_CRM_Product__c;
    
    global CRM_CreateProductsBatch(List<String> lCountries) {
        lstCountries = lCountries;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String strQuery ='SELECT Id, Product__c FROM Commercial_Avail__c WHERE Product__c = null AND Country_Lookup__c != null AND'+ 
            			 ' Country_Lookup__r.Generate_CRM_Product__c =: GenerateCRMProducts AND Country_Lookup__r.Country_Code__c != null AND'+
            			 ' Country_Lookup__r.Country_Code__c IN :lstCountries';
        return Database.getQuerylocator(strQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<Commercial_Avail__c> scope){
        if(scope!=null && !scope.isEmpty()){
            WB_PBEP_Product_CreationHandler wbPBEP_Prod = new WB_PBEP_Product_CreationHandler();
            wbPBEP_Prod.assignProductToReleasePlan(scope);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        CRM_Batch_Size__c batchSizeInstance = CRM_Batch_Size__c.getInstance('CreateProductAndPBEPBatch');
        Integer defaultBatchSize = batchSizeInstance != null ? (Integer) batchSizeInstance.Batch_Size__c : 200;        
        Database.executeBatch(new CRM_CreatePBEPBatch(lstCountries), defaultBatchSize);
        
        /*
        CRM_Batch_Size__c batchSizeInstance = CRM_Batch_Size__c.getInstance('Auto Digital NR Deal Creation Batch');
        Integer defaultBatchSize = batchSizeInstance != null ? (Integer) batchSizeInstance.Batch_Size__c : 25;
        BatchStatusNotification.sendBatchStatusMail(BC,'Automatic Digital Product Or PBEP Creation');
        CRM_AutoDigitalNRDealCreationBatch b = new CRM_AutoDigitalNRDealCreationBatch();
        Id batchJobId = Database.executeBatch(b, defaultBatchSize);
        */
    }
}