public class WB_Batch_MPMRD_Mismatch implements Database.Batchable<sObject>{
Set<Id> rollupRPIds = new Set<Id>(); 
public string strBatchGroup = System.Label.MRD_Rollup_Batch_Group; 
    public WB_Batch_MPMRD_Mismatch(Set<Id> rpIds){    
           rollupRPIds = rpIds;
    }   
    
    public Database.QueryLocator start(Database.BatchableContext BC){
       return Database.getQueryLocator([SELECT Id, Name, Title__c, Title__r.MPM__c,Status__c, 
                                        MPM_Release_Date_Key__c,MRD_ID__c,Title__r.MPM__r.Generic__c,Title__r.MPM__r.id,MRD_ID__r.Key__c  
                                        FROM Commercial_Avail__c 
                                        WHERE Id IN: (rollupRPIds)]);          
   }

    public void execute(Database.BatchableContext BC, List<Commercial_Avail__c> lstReleasePlan){
        WB_CheckingDateOverlapController.UpdateMRMReleaseDateToCancel(lstReleasePlan);       
        //WB_CheckingDateOverlapController_clone.UpdateMRMReleaseDateToCancel(lstReleasePlan);
    }

    public void finish(Database.BatchableContext BC){
        AsyncApexJob apexJob = [SELECT Id, NumberOfErrors, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        List<Group> lstMembers  = new  List<Group>([SELECT(select userOrGroupId from groupMembers) FROM group WHERE name =: strBatchGroup LIMIT 1]);
        system.debug('^^^^inside finish');
        
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         String[] toAddresses = new String[] {apexJob.CreatedBy.Email};            
         mail.setSubject('MRD Rollup Batch To Update Cancel Status Failure Details ');
         
         List<String> mailToAddresses = new List <String>();
            List<Id> idList = new List <Id>();
            
            for (GroupMember gm: lstMembers[0].groupMembers)
                idList.add(gm.userOrGroupId);
                
            List<User> lstUsr = [SELECT email FROM user WHERE id IN: idList];
            for (User u: lstUsr)
                mailToAddresses.add(u.email);
                
            mail.setToAddresses(mailToAddresses);
        
        if(apexJob.NumberOfErrors > 0 && lstMembers.size() > 0 && (lstMembers[0].groupMembers).size() > 0){  
            mail.setPlainTextBody('Records processed ' + apexJob.TotalJobItems +   'with '+ apexJob.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}