/**
   @Author Komal Mehta & Aditi Satpute
   @name CRM_AutoPhysicalNRDealCreationSchedule
   @CreateDate 31 Dec 2015
   @Description Schedulable class to schedule the CRM_AutoPhysicalNRDealCreationBatch. It will be set to run every day at 1 AM.
   @Version <1.0>
   @reference Requirement no 155
*/
global class CRM_AutoPhysicalNRDealCreationSchedule implements Schedulable {
    //Cron Expression to schedule Automatic NR Deal Creation Batch at 1 am
    public static String CRON_EXP = '0 0 1 * * ?';
    public static String scheduleJobName = 'Automatic Physical NR Deal Creation';
    global static void go(){
        CRM_AutoPhysicalNRDealCreationSchedule sch = new CRM_AutoPhysicalNRDealCreationSchedule();
        system.schedule(scheduleJobName, CRON_EXP, sch);
    }
    
    global void execute(SchedulableContext contextInstance) {
        CRM_Batch_Size__c batchSizeInstance = CRM_Batch_Size__c.getInstance('Auto Physical NR Deal Creation Batch');
        Integer defaultBatchSize = batchSizeInstance != null ? (Integer) batchSizeInstance.Batch_Size__c : 25;
        CRM_AutoPhysicalNRDealCreationBatch batchInstance =
               new CRM_AutoPhysicalNRDealCreationBatch();
            Database.executebatch(batchInstance, defaultBatchSize);
    }
}