public class WB_Schedule_MPMReleaseDateUpdate implements Schedulable {
    
   public void execute(SchedulableContext sc) {
       Integer batchSize = System.Label.MRD_Rollup_Batch_Size != null ? Integer.valueOf(System.Label.MRD_Rollup_Batch_Size) : 100;
       
     List<String> apexclassName = new List<String>{'WB_Batch_MPMRD_Rollup','WB_Batch_MPMRD_Mismatch'};
     List<ApexClass> apexclassList = [SELECT Id,Name FROM ApexClass WHERE Name in :apexclassName];
     
     String rollupClass,mismatchClass;
   
     for(ApexClass apexName : apexclassList){
      if(apexName.Name == 'WB_Batch_MPMRD_Rollup'){
        rollupClass = apexName.Id;
      }
      if(apexName.Name == 'WB_Batch_MPMRD_Mismatch'){
        mismatchClass = apexName.Id;
      }
     }
     
     integer countWB_Batch_MPMRD_Rollup_ClassId =  [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND Status IN ('Processing','Preparing','Queued','Holding') AND ApexClassID =: rollupClass];
     
     integer countWB_Batch_MPMRD_Mismatch_ClassId =  [SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND Status IN ('Processing','Preparing','Queued','Holding') AND ApexClassID =: mismatchClass];
     
     if(countWB_Batch_MPMRD_Rollup_ClassId != null && countWB_Batch_MPMRD_Rollup_ClassId == 0){
       Map<Id,Commercial_Avail__c> mapRollupRPIds = new Map<Id,Commercial_Avail__c>([SELECT Id FROM Commercial_Avail__c WHERE MPM_Release_Date_Key__c != null AND (MRD_Roll_up__c = True OR MPMRD_Mismatch__c = TRUE) LIMIT 10000]);
       Database.executeBatch(new WB_Batch_MPMRD_Rollup(mapRollupRPIds.keySet()),batchSize);
     }

       if(countWB_Batch_MPMRD_Mismatch_ClassId != null && countWB_Batch_MPMRD_Mismatch_ClassId == 0){
       Map<Id,Commercial_Avail__c> mapRollupRPIdsToCancel = new Map<Id,Commercial_Avail__c>([SELECT Id FROM Commercial_Avail__c where MPM_Release_Date_Key__c = null AND MRD_ID__c != null LIMIT 5000]);
       Database.executeBatch(new WB_Batch_MPMRD_Mismatch(mapRollupRPIdsToCancel.keySet()),10);
     }
   }
}