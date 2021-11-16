//Description - This Batch class used to do Dummy Update of Rights Record which calls process builder 
//              to update Status to 'Rights Expired'of Rights Record with ENd Date < today

public class WB_Batch_UpdateDailyRightsCheck implements Database.Batchable<sObject>, Schedulable{
    public String query ;
    //public static String status_RIGHTSExpired = 'Rights Expired';

    //constructor
    public WB_Batch_UpdateDailyRightsCheck(String q){
        this.query = q;
    }
    
    // Schedulable interface
    public void execute(SchedulableContext ctx)  
    {   
        //String query1 = 'SELECT Id FROM Rights__c WHERE Rights_End__c < Today AND Status__c != \''+String.escapeSingleQuotes(status_RIGHTSExpired)+'\' '
        WB_Batch_UpdateDailyRightsCheck CA = new WB_Batch_UpdateDailyRightsCheck(query);
        database.executebatch(CA);
    }

    
    //Start Method
    public Database.QueryLocator start(Database.BatchableContext BC){
          //  query =  ;
       
        return Database.getQueryLocator(query);
    }
    
    //Execute Method 
    public void execute (Database.BatchableContext BC , List<Rights__c> lstRights){
        if(lstRights.size() > 0){
            try{
             //update lstRights;
             Database.SaveResult[] results = Database.update(lstRights,false);
            if (results != null){
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()) {
                        Database.Error[] errs = result.getErrors();
                        for(Database.Error err : errs)
                            System.debug(err.getStatusCode() + ' - ' + err.getMessage());
                        }
                    }
                }
            }
            catch (DMLException e){
                for (Rights__c right : lstRights) {
                     System.debug('There was a problem updating the Right Record');
                }
            }
        }
    }
    
   //Finish Method
    public void finish(Database.BatchableContext BC) { 
        //ER - 793
        //send Job information to users via email
        BatchStatusNotification batchNotification = new BatchStatusNotification();
        AsyncApexJob jobInfo = [SELECT Status,TotalJobItems,NumberOfErrors,ExtendedStatus 
                             FROM AsyncApexJob 
                             WHERE Id=:BC.getJobID()];
        if(jobInfo != NULL)
            batchNotification.sendEmailToUsers(Label.Entity_CAS,'Rights Status Update - Rights Expired',jobInfo.Status,jobInfo.TotalJobItems,jobInfo.NumberOfErrors,jobInfo.ExtendedStatus);
          
    }
}