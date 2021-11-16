@isTest(SeeAllData=false) 
public with sharing class CRM_SyncLocalTitleWithProductSchdlTest{

    static testmethod void testMethod1() {
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

        Test.startTest();
        String jobId = System.schedule('Test Sync Local Title Product1', CRON_EXP, new CRM_SyncLocalTitleWithProductSchedule() );
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        if(ct != null){
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
        }
    }

    static testmethod void testMethod2() {

        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        CRM_SyncLocalTitleWithProductSchedule.CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        CRM_SyncLocalTitleWithProductSchedule.scheduleJobName = 'Test Sync Local Title Product2';
        CRM_SyncLocalTitleWithProductSchedule.go();
        Test.stopTest();

        List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger];
        System.assert(ct.size() > 0);
    }
}