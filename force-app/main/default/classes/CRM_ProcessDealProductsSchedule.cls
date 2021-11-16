/**
   @Author Aditi Satpute
   @name CRM_ProcessDealProductsSchedule
   @CreateDate 28 July 2016
   @Description Schedulable class to schedule the CRM_ProcessDealProductsBatch. It will be set to run every day at 1 AM.
   @Version <1.0>
*/
global class CRM_ProcessDealProductsSchedule implements Schedulable {
    //Cron Expression to schedule CRM_ProcessDealProductsBatch at 1 am
    public static String CRON_EXP = '0 0 1 * * ?';
    public static String scheduleJobName = 'Process Deal Products Batch';

    global static void go(){
        CRM_ProcessDealProductsSchedule sch = new CRM_ProcessDealProductsSchedule();
        system.schedule(scheduleJobName, CRON_EXP, sch);
    }

    global void execute(SchedulableContext contextInstance) {
        CRM_Batch_Size__c batchSizeInstance = CRM_Batch_Size__c.getInstance('Process Deal Products Batch');
        Integer defaultBatchSize = batchSizeInstance != null ? (Integer) batchSizeInstance.Batch_Size__c : 50;
        Database.executebatch(new CRM_ProcessDealProductsBatch(), defaultBatchSize);
    }
}