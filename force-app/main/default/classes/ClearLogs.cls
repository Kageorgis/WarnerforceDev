/*
* Delete failed transaction logs those are older than 6 months
* Delete passed transaction logs those are older than 7 days
*/

global class ClearLogs implements Database.Batchable<sObject>
{
    global String Query;
    global DateTime failDate;
    global DateTime passDate;
    
    
    global ClearLogs()
    {
        failDate = DateTime.now().addMonths(-6);
        passDate = DateTime.now().addDays(-7);
        Query = 'Select Id from Transaction_Log__c where';
        Query = Query + ' (Status__c = \'Failure\' and CreatedDate < ' + failDate.format('yyyy-MM-dd')+'T'+failDate.format('HH:mm')+':00.000Z)';
        Query = Query + ' OR';
        Query = Query + ' (Status__c = \'Success\' and CreatedDate < ' + passDate.format('yyyy-MM-dd')+'T'+passDate.format('HH:mm')+':00.000Z)';

        System.debug('Query : ' + query);
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC,List<sObject> scope)
    {
        list<Transaction_Log__c> transLogs = new list<Transaction_Log__c>();
        System.debug('MYDEBUG scope size : ' + scope.size());
        for(Sobject s : scope)
        {
            transLogs.add((Transaction_Log__c)s);
        }   
        if(transLogs.size() > 0)
            delete transLogs;
    }

    global void finish(Database.BatchableContext BC)
    {
         //ER - 793
         //send Job information to users via email
         BatchStatusNotification batchNotification = new BatchStatusNotification();
         AsyncApexJob jobInfo = [SELECT Status,TotalJobItems,NumberOfErrors,ExtendedStatus 
                                 FROM AsyncApexJob 
                                 WHERE Id=:BC.getJobID()];
         if(jobInfo != NULL)
            batchNotification.sendEmailToUsers(Label.Entity_CAS,'Clear Logs',jobInfo.Status,jobInfo.TotalJobItems,jobInfo.NumberOfErrors,jobInfo.ExtendedStatus);
    }
}