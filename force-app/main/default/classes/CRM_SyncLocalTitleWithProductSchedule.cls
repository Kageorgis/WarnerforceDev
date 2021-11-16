/**
   @Author Cognizant
   @name CRM_SyncLocalTitleWithProductSchedule
   @CreateDate 13 July 2020
   @Description Schedulable class to schedule the CRM_SyncLocalTitleWithProductbatch. It will be set to run every day at 10PM.
   @Version <1.0>
   @reference Requirement no ER-003283 Incorrect digital product name
*/
global class CRM_SyncLocalTitleWithProductSchedule implements Schedulable{
    public static String CRON_EXP = '0 30 9 * * ?';
    public static String scheduleJobName = 'Sync Local Title Name With Product Name';

    global static void go(){
        CRM_SyncLocalTitleWithProductSchedule sch = new CRM_SyncLocalTitleWithProductSchedule();
        system.schedule(scheduleJobName, CRON_EXP, sch);
    }

    global void execute(SchedulableContext contextInstance){
        CRM_Batch_Size__c batchSizeInstance = CRM_Batch_Size__c.getInstance('SyncLocalTitleNameWithProductBatch');
        Integer defaultBatchSize = batchSizeInstance != null ? (Integer) batchSizeInstance.Batch_Size__c : 50;

        CRM_SyncLocalTitleWithProductBatch batchInstance = new CRM_SyncLocalTitleWithProductBatch();
        Database.executebatch(batchInstance, defaultBatchSize);
    }
}