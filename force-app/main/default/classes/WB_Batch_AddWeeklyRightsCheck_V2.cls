/*******************************************************************************************************************************************
* File Name     :   WB_Batch_AddWeeklyRightsCheck_V2
* Description   :   Batch class to link Rights to the release plan Version 2
* @author       :   CTS
* Modification Log
===================================================================================================------------------
* Ver.    Date              Author              Modification
------------------------------------------------------------------------------------------------------------------
* 1.0     07 July 2021      Ketan (CTS)          Enhance the batch class logic by changing the scope from Title to Release Plan ER-007509
********************************************************************************************************************************************/
public class WB_Batch_AddWeeklyRightsCheck_V2 implements Database.Batchable<sObject>,Database.Stateful,Schedulable {
    
    String query = '';
    Integer batchSize = Integer.valueOf(System.label.WB_AddWeeklyRightsCheck_BatchSize);
   
    // Schedulable interface
    public void execute(SchedulableContext ctx)  
    {   
        WB_Batch_AddWeeklyRightsCheck_V2 CA = new WB_Batch_AddWeeklyRightsCheck_V2();
        database.executebatch(CA,batchSize);
    }
    
    // Constructor
    public WB_Batch_AddWeeklyRightsCheck_V2() {}
    
    // Start Method
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String rightsCheckClause = System.Label.WB_Batch_RP_RightsCheckOK.equalsIgnoreCase('true') ? 'Rights_Check__c=\'OK\'' : 'Rights_Check__c!=\'OK\'';
        query = 'SELECT Id,Name,Title_Generic_MPM_Number__c,Title_Video_Version__c,Channel__c,Rights_GroupF__c,Exclusive_Date__c,Rights_End__c,Rights_ID__c'
                 +' FROM Commercial_Avail__c'
                 +' WHERE Channel__c != null AND Exclusive_Date__c != null AND Rights_End__c != null  AND Rights_GroupF__c != null AND ('+rightsCheckClause +'OR Rights_Mismatch__c = true)';//Changed condition for rightsCheckClause - country ARUBA 
             
        return Database.getQueryLocator(query);
    }
    
    // Execute Logic
    public void execute(Database.BatchableContext BC, List<Commercial_Avail__c> scope){
        
        WB_UpdateRightInfo handler = new WB_UpdateRightInfo();
        handler.mapRightsDate(scope);
        
        if(scope != null && scope.size() > 0) {
            // Static variable used to avoid trigger invoke
            TestUtil.isRunning_WB_Batch_AddWeeklyRightsCheck = true;             
            Database.Saveresult[] saveResult_RP  = Database.update(scope, false);
            TestUtil.isRunning_WB_Batch_AddWeeklyRightsCheck = false;
        }
    }//end of execute method
     
    public void finish(Database.BatchableContext BC) {
        //ER - 793
         //send Job information to users via email
         BatchStatusNotification batchNotification = new BatchStatusNotification();
         AsyncApexJob jobInfo = [SELECT Status,TotalJobItems,NumberOfErrors,ExtendedStatus 
                                 FROM AsyncApexJob 
                                 WHERE Id=:BC.getJobID()];
         if(jobInfo != NULL)
            batchNotification.sendEmailToUsers(Label.Entity_CAS,'Daily Rights Check',jobInfo.Status,jobInfo.TotalJobItems,jobInfo.NumberOfErrors,jobInfo.ExtendedStatus);
    } 
}