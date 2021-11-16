/*
Class Name   : WB_Batch_Generate_Product
Description  : This class is used to create product and siisgin product reference on corresponding Release Plan
*/
global class WB_Batch_Generate_Product implements Database.Batchable<sObject>, Schedulable{
    String dateFilter;
    DateTime lastRunDate;
    DateTime LastModifiedFrom;
    DateTime LastModifiedTo;
    
    // Schedulable interface
    Global void execute(SchedulableContext ctx){   
        system.debug('lastRunDate : '+lastRunDate);
        WB_Batch_Generate_Product rd = new WB_Batch_Generate_Product(lastRunDate,null);
        lastRunDate = system.now();
        
        Integer batchSize = WB_Populate_TRD_On_LT__c.getInstance('WB_Product_And_PBEP_Generation') != null ? Integer.valueOf(WB_Populate_TRD_On_LT__c.getInstance('WB_Product_And_PBEP_Generation').Batch_Size__c) : 100;
        database.executebatch(rd,batchSize);
    }
    
    Global WB_Batch_Generate_Product(){}
    Global WB_Batch_Generate_Product(DateTime fromDateVar,DateTime toDateVar){
        system.debug('Before batch class constructor lastRunDate : '+fromDateVar+'-----'+toDateVar);
        LastModifiedFrom = (fromDateVar != null) ? fromDateVar.addMinutes(-1) : system.now().addDays(-1);
        LastModifiedTo = (toDateVar != null) ? toDateVar : null;
        system.debug('After batch class constructor lastRunDate : '+LastModifiedFrom+'-----'+LastModifiedTo);
        dateFilter = ' LastModifiedDate >= :LastModifiedFrom' + (LastModifiedTo != null ? ' AND LastModifiedDate <= :LastModifiedTo)' : '');
        
    }
    
    //Batch Class Implementation
    global Database.QueryLocator start (Database.BatchableContext bc){
        WB_Generate_PBEP_Batch.createErrorLog(null,'Digital Product Generation','Start Method','Product',null,null);
        return Database.getQueryLocator('SELECT Id,Name,Product__c FROM Commercial_Avail__c WHERE '+dateFilter);
    }
    
    global void execute (Database.BatchableContext bc,List<Commercial_Avail__c> listRPRecords){
        try{
            WB_PBEP_Product_CreationHandler pbepProdHandler = new WB_PBEP_Product_CreationHandler();        
            pbepProdHandler.assignProductToReleasePlan(listRPRecords);
            pbepProdHandler.updateAssignedProductsFromRP(listRPRecords,null); 
        }catch(Exception e){
            WB_Generate_PBEP_Batch.createErrorLog(null,'Digital Product Generation','Start Method','Product',e,LastModifiedFrom);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
        if(!Test.isRunningTest()){ 
            Integer batchSize = WB_Populate_TRD_On_LT__c.getInstance('WB_Product_And_PBEP_Generation') != null ? Integer.valueOf(WB_Populate_TRD_On_LT__c.getInstance('WB_Product_And_PBEP_Generation').Batch_Size__c) : 100;
            Database.executeBatch(new WB_Generate_PBEP_Batch(LastModifiedFrom,LastModifiedTo),batchSize);
        }
        //Add an entry in CAS CRM error log for tracking batch execution
        List<AsyncApexJob> jobInfos = [SELECT Id,Status,TotalJobItems,NumberOfErrors,ExtendedStatus 
                                        FROM AsyncApexJob 
                                        WHERE Id=:BC.getJobID()];
        if(jobInfos.size() > 0){
            WB_Generate_PBEP_Batch.createErrorLog(jobInfos[0],'Digital Product Generation','Finish Method','Product',null,LastModifiedFrom);
        }  
    }
}