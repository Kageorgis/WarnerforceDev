/*
Class Name   : WB_Generate_PBEP_Batch 
Description  : This batch class is used to generate the PBEPs for CA & CAPs
*/
global class WB_Generate_PBEP_Batch implements Database.Batchable<sObject>{
    String queryFilter;
    DateTime LastModifiedFrom;
    DateTime LastModifiedTo;
    Set<Id> clientAvailsIds;
    
    Global WB_Generate_PBEP_Batch(){}
            
    Global WB_Generate_PBEP_Batch(DateTime fromDateVar,DateTime toDateVar){
        LastModifiedFrom = fromDateVar;
        LastModifiedTo = toDateVar;
        
        String lastModifiedDateFilterCAP = ' (LastModifiedDate >= :LastModifiedFrom' + (LastModifiedTo != null ? ' AND LastModifiedDate <= :LastModifiedTo)' : ')');
        String lastModifiedDateFilterCA = ' (Client_Avail__r.LastModifiedDate >= :LastModifiedFrom' + (LastModifiedTo != null ? ' AND Client_Avail__r.LastModifiedDate <= :LastModifiedTo)' : ')');
        
        queryFilter = lastModifiedDateFilterCAP + ' OR ' +lastModifiedDateFilterCA;
        system.debug('queryStr : '+queryFilter);
    }
    
    global Database.QueryLocator start (Database.BatchableContext bc){
        createErrorLog(null,'Digital PBEP Generation','Start Method','Pricebook_Entry_Period__c',null,null);
        return Database.getQueryLocator('SELECT Id,Client_Avail__c FROM Client_Avail_Price__c WHERE '+queryFilter);
    }
    
    global void execute (Database.BatchableContext bc,List<Client_Avail_Price__c> scope){
        try{
            WB_PBEP_Product_CreationHandler pbepProdHandler = new WB_PBEP_Product_CreationHandler();
            pbepProdHandler.insertOrUpdatePriceBookEntryPeriod(scope);
        }catch(Exception e){
            createErrorLog(null,'Digital PBEP Generation','Start Method','Pricebook_Entry_Period__c',e,LastModifiedFrom);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        List<AsyncApexJob> jobInfos = [SELECT Id,Status,TotalJobItems,NumberOfErrors,ExtendedStatus 
                                 FROM AsyncApexJob 
                                 WHERE Id=:BC.getJobID()];
        if(jobInfos.size() > 0){
            createErrorLog(jobInfos[0],'Digital PBEP Generation','Finish Method','Pricebook_Entry_Period__c',null,LastModifiedFrom);
        }
    }
    
    public static void createErrorLog(AsyncApexJob apexJob,String errorCategory,String callingFrom,String objectName,Exception error,DateTime lastRunDate){
         List<WB_CAS_ErrorLogger.ErrorLog> errorLogs = new List<WB_CAS_ErrorLogger.ErrorLog>();
         WB_CAS_ErrorLogger.ErrorLog errorLogInstance = new  WB_CAS_ErrorLogger.ErrorLog();
         errorLogInstance.errorCategory = errorCategory;
         if(error != null){
             errorLogInstance.errorDescription = String.valueOf(lastRunDate)+' - '+String.valueOf(System.now())+' : '+error.getMessage().left(200);
             errorLogInstance.errorDescriptionLong = error.getStackTraceString(); 
         }else if(apexJob != Null){
             errorLogInstance.errorDescription = callingFrom+' -- '+apexJob.Status+' : '+String.valueOf(lastRunDate)+' - '+String.valueOf(System.now());
             errorLogInstance.recordId = apexJob.Id;
             errorLogInstance.errorDescriptionLong = 'Job Status : '+apexJob.Status +' || Total Job Items: '+ apexJob.TotalJobItems +' || Number Of Error : '+ apexJob.NumberOfErrors; 
         }else{
             errorLogInstance.errorDescription = callingFrom+' -- Successfull Execution';
         }
         errorLogInstance.objectName = objectName;
         errorLogs.add(errorLogInstance);
         WB_CAS_ErrorLogger.logError(errorLogs);
    }
}