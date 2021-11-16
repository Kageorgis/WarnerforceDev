public class WB_Batch_UpdateMPMReleaseDate implements Database.Batchable<sObject>{
    Set<Id> rollupRPIds = new Set<Id>();  
    public string strBatchGroup = System.Label.MRD_Rollup_Batch_Group;

   public WB_Batch_UpdateMPMReleaseDate(Set<Id> rpIds){    
       rollupRPIds = rpIds;
   }

   public Database.QueryLocator start(Database.BatchableContext BC){
       return Database.getQueryLocator([SELECT Id, Name, Title__c, Title__r.MPM__c, Exclusive_Date__c, Start_Date__c, Status__c, 
                                        MPM_Release_Date_Key__c, Languages__c, Country_Lookup__c, Channel__c, Format__c, Release_Locale__c 
                                        FROM Commercial_Avail__c 
                                        WHERE Id IN: (rollupRPIds)]);          
   }

   public void execute(Database.BatchableContext BC, List<Commercial_Avail__c> lstReleasePlan){
       WB_CheckingDateOverlapController.UpdateMRMReleaseDate(lstReleasePlan);
   }
   
   public void finish(Database.BatchableContext BC){
        AsyncApexJob apexJob = [SELECT Id, NumberOfErrors, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        List<Group> lstMembers  = new  List<Group>([SELECT(select userOrGroupId from groupMembers) FROM group WHERE name =: strBatchGroup LIMIT 1]);
        
        if(apexJob.NumberOfErrors > 0 && lstMembers.size() > 0 && (lstMembers[0].groupMembers).size() > 0){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {apexJob.CreatedBy.Email};            
            mail.setSubject('MRD Rollup Batch Failure Details');
            mail.setPlainTextBody('Records processed ' + apexJob.TotalJobItems +   'with '+ apexJob.NumberOfErrors + ' failures.');
            
            List<String> mailToAddresses = new List <String>();
            List<Id> idList = new List <Id>();
            
            for (GroupMember gm: lstMembers[0].groupMembers)
                idList.add(gm.userOrGroupId);
                
            List<User> lstUsr = [SELECT email FROM user WHERE id IN: idList];
            for (User u: lstUsr)
                mailToAddresses.add(u.email);
                
            mail.setToAddresses(mailToAddresses);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
   }
}