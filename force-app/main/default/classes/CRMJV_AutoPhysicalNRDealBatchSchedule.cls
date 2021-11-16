/**
   @Author Cognizant
   @name CRMJV_AutoPhysicalNRDealBatchSchedule
   @CreateDate 22 March 2021
   @Description Schedulable class to schedule the CRMJV_AutoPhysicalNRDealBatch.
   @Version <1.0>
   @reference W-017644, W-017678 - Automatic New Release Deals - Planning, DFI, POSADV deals
*/
global class CRMJV_AutoPhysicalNRDealBatchSchedule implements Schedulable{
    public static String CRON_EXP = '0 30 6 * * ?';
    public static String scheduleJobName = 'NR batch for DFI,POS and Planning for SDS';

    global static void go(){
        CRMJV_AutoPhysicalNRDealBatchSchedule sch = new CRMJV_AutoPhysicalNRDealBatchSchedule();
        system.schedule(scheduleJobName, CRON_EXP, sch);
    }

    global void execute(SchedulableContext contextInstance){
        CRM_Batch_Size__c batchSizeInstance = CRM_Batch_Size__c.getInstance('SDSJVAutoPhysicalNRDealBatch');
        Integer defaultBatchSize = batchSizeInstance != null ? (Integer) batchSizeInstance.Batch_Size__c : 5;

        CRMJV_AutoPhysicalNRDealBatch batchInstance = new CRMJV_AutoPhysicalNRDealBatch();
        Database.executebatch(batchInstance, defaultBatchSize);
    }
}