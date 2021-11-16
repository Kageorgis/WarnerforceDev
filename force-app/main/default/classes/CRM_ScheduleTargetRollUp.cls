global class CRM_ScheduleTargetRollUp implements Schedulable {
    global void execute(SchedulableContext sc) {
        CRM_BatchTargetRollUp_V2 batchTarget = new CRM_BatchTargetRollUp_V2();
        CRM_Batch_Size__c objBatchSize = CRM_Batch_Size__c.getInstance('Target_Rollup_Batch-Products');
        Integer nBatchSize = Integer.Valueof((objBatchSize != null && objBatchSize.Batch_Size__c != null)? objBatchSize.Batch_Size__c : 1);
        Database.executeBatch(batchTarget, nBatchSize);
    }
}