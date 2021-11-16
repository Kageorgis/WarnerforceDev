/**
   @Author Cognizant
   @name CRM_DeleteErrorLog_Test
   @CreateDate 27 April 2016
   @Description This batch class will be used to create product record in salesforce. It will run daily
   @Version <1.0>
   @reference Requirement no 153
*/
@isTest
public with sharing class CRM_DeleteErrorLog_Test{
    static testmethod void testDeleteErrorLog() {
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

        Test.startTest();
        String jobId = System.schedule('Delete Error Log', CRON_EXP, new CRM_DeleteErrorLogScheduler());
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        if(ct != null){
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
        }
    }
     static testmethod void testGo() {
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        CRM_DeleteErrorLogScheduler.CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        CRM_DeleteErrorLogScheduler.go();
        Test.stopTest();

        List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger];
        System.assert(ct.size() > 0);
    }
}