@isTest
public with sharing class CRM_AutoPhysicalNRDealSchedule_Test {
    static testmethod void testAutoPhysicalNRDealCreationSchedule() {

        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();

        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

        Test.startTest();
        String jobId = System.schedule('Automatic NR Deal Creation', CRON_EXP, new CRM_AutoPhysicalNRDealCreationSchedule() );
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        if(ct != null){
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
        }
    }
    static testmethod void testGo() {

        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();

        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        CRM_AutoPhysicalNRDealCreationSchedule.CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        CRM_AutoPhysicalNRDealCreationSchedule.scheduleJobName = 'Test Automatic NR Deal Creation';
        CRM_AutoPhysicalNRDealCreationSchedule.go();
        Test.stopTest();
        
        List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger];
        System.assert(ct.size() > 0);
    }

}