public class WB_Batch_dummyUpdateOnClientAvails implements Database.Batchable<sObject>,Schedulable {
    public Integer batchSize ;
    
    // Schedulable interface
    public void execute(SchedulableContext ctx)  
    {   
        WB_Batch_dummyUpdateOnClientAvails sch = new WB_Batch_dummyUpdateOnClientAvails();
        database.executebatch(sch,batchSize);
    }
    
    //Constructor
    public WB_Batch_dummyUpdateOnClientAvails(Integer size){
         batchSize = size;
    }
    
    public WB_Batch_dummyUpdateOnClientAvails(){}
    
    //Start method
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        String Query = 'Select id,isReleaseDatesChanged__c from Local_Title__c where isReleaseDatesChanged__c = true';
        return Database.getQueryLocator(query);
    }
    
    //Execute Logic
    public void execute(Database.BatchableContext BC, List<Local_Title__c> lstLocalTitle){
        
        List<CAS_Error_Log__c> lstCasErrorLog = new List<CAS_Error_Log__c>();
        
        List<Client_Avail__c> lstClienTAvail = [Select Id,Local_Title__c,Local_DVD_Release_Date__c from Client_Avail__c where Local_Title__c IN: lstLocalTitle];
        List<Local_Title__c> lstUpdateLocalData = new List<Local_Title__c>();
        
        //Clear LocalTitle Flag
        for(Local_Title__c localdata: lstLocalTitle){
                localdata.isReleaseDatesChanged__c = false;
              lstUpdateLocalData.add(localdata);
        }
        
        WB_LocalTitleTriggerHandler.recursiveUpdate = true;
        database.update(lstUpdateLocalData,false);  
        WB_LocalTitleTriggerHandler.recursiveUpdate = false;
        
        WB_ClientAvailPriceHandler.recursiveUpdate = true;
        Database.SaveResult[]  results =  Database.update(lstClienTAvail,false);
        WB_ClientAvailPriceHandler.recursiveUpdate = false;
        
        for ( Database.SaveResult sr : results)
        {
            if (!sr.isSuccess()){
                // Failed upsert and need to update response with error message and log error message - could be multiple
                for (Database.Error err : sr.getErrors()){
                    CAS_Error_Log__c CasErrorLog = new CAS_Error_Log__c(Object_Name__c = 'Client_Avail__c',
                    Error_Description__c = err.getMessage(),Error_Category__c = 'DVD Release Blank Update',
                    Record_Id__c = sr.getId());
                    /*CAS_Error_Log__c CasErrorLog = new CAS_Error_Log__c();
                    // Update response
                    CasErrorLog.Object_Name__c = 'Client_Avail__c';
                    CasErrorLog.Error_Description__c = err.getMessage();
                    CasErrorLog.Error_Category__c = 'DVD Release Blank Update';
                    CasErrorLog.Record_Id__c = sr.getId();*/
                     // Add to Error Log list
                    lstCasErrorLog.add(CasErrorLog);
                }
            }
        }
        if(lstCasErrorLog != NULL && lstCasErrorLog.size() > 0){
            try{
                insert lstCasErrorLog;
            }catch(exception e){
                system.debug('++++Following Error:'+e.getMessage());}
        }
         
        
    }
    
    public void finish(Database.BatchableContext BC){
      
    }
}