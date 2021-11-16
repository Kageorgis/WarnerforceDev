/**
   @Author: Harshad Bidwai
   @Name: CRM_ScheduleAccountBatchForRBA
   @CreateDate: 09 March 2017
   @Description: Schedulable class to schedule the CRM_ProcessAccountBatchForRBA. It will be set to run every 
                 1st Day of month.
   @Version <1.0>
*/
global class CRM_ScheduleAccountBatchForRBA implements Schedulable {
    //Cron Expression to schedule CRM_ScheduleAccountBatchForRBA on 1st Day of every month.
    public static String CRON_EXP = '0 0 0 1 * ?';
    public static string scheduleJobName = System.Label.CRM_Process_Account_Batch_For_RBA;

    global static void go(){
        CRM_ScheduleAccountBatchForRBA sch = new CRM_ScheduleAccountBatchForRBA();
        system.schedule(scheduleJobName, CRON_EXP, sch);
    }

    global void execute(SchedulableContext contextInstance) {
        CRM_Batch_Size__c batchSizeInstance = CRM_Batch_Size__c.getInstance(scheduleJobName);
        Integer defaultBatchSize = batchSizeInstance != null ? (Integer) batchSizeInstance.Batch_Size__c : 10;
        Database.executebatch(new CRM_ProcessAccountBatchForRBA(), defaultBatchSize);
    }
}