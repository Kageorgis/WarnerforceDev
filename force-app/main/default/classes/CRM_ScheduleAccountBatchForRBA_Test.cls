@isTest
public with sharing class CRM_ScheduleAccountBatchForRBA_Test {
    static testmethod void testProcessAccountBatchSchedule() {
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

        Test.startTest();
        String jobId = System.schedule('Test1 Process Account Batch For RBA', CRON_EXP, new CRM_ScheduleAccountBatchForRBA() );
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
        CRM_ScheduleAccountBatchForRBA.CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        CRM_ScheduleAccountBatchForRBA.scheduleJobName = 'Test2 Process Account Batch For RBA';
        CRM_ScheduleAccountBatchForRBA.go();
        Test.stopTest();
        
        List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger];
        System.assert(ct.size() > 0);
    }

}