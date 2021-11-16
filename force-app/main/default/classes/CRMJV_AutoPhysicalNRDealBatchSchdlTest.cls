@isTest(SeeAllData=false) 
public with sharing class CRMJV_AutoPhysicalNRDealBatchSchdlTest{

    static testmethod void testMethod1(){
        //Creating custom setting to send email notification to user 
        Batch_Notification_Recipients__c bnr = new Batch_Notification_Recipients__c();
        bnr.Name='Rahul Kumar Chakalasiya';
        bnr.Entity__c='CRM';
        bnr.User_Email_Id__c='rahulkumar.chakalasiya@cognizant.com';
        insert bnr;  
        
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

        Test.startTest();
        String jobId = System.schedule('Test Schedule1', CRON_EXP, new CRMJV_AutoPhysicalNRDealBatchSchedule());
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        if(ct != null){
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
        }
    }

    static testmethod void testMethod2(){
        //Creating custom setting to send email notification to user 
        Batch_Notification_Recipients__c bnr = new Batch_Notification_Recipients__c();
        bnr.Name='Rahul Kumar Chakalasiya';
        bnr.Entity__c='CRM';
        bnr.User_Email_Id__c='rahulkumar.chakalasiya@cognizant.com';
        insert bnr;  
        
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        CRMJV_AutoPhysicalNRDealBatchSchedule.CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        CRMJV_AutoPhysicalNRDealBatchSchedule.scheduleJobName = 'Test Schedule2';
        CRMJV_AutoPhysicalNRDealBatchSchedule.go();
        Test.stopTest();

        List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger];
        System.assert(ct.size() > 0);
    }
}