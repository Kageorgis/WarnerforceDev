/**
   @Author Komal Mehta & Aditi Satpute
   @name CRM_AutoDigitalNRDealCreateSchedule_Test
   @CreateDate 30 March 2016
   @Description Test Class for CRM_AutoDigitalNRDealCreateSchedule.
   @Version <1.0>
   @reference Requirement no 155
*/
@isTest
public with sharing class CRM_AutoDigitalNRDealCreateSchedule_Test {
    static testmethod void testAutoDigitalNRDealCreationSchedule() {

        CRM_AutoPhysicalNRDealCreateService_Test.createBatchNotificationRecipientsCustomSettingRecord();

        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

        Test.startTest();
        String jobId = System.schedule('Automatic NR Deal Creation Digital', CRON_EXP, new CRM_AutoDigitalNRDealCreationSchedule() );
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
        CRM_AutoDigitalNRDealCreationSchedule.CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        CRM_AutoDigitalNRDealCreationSchedule.scheduleJobName = 'Test Automatic NR Digital Deal Creation';
        CRM_AutoDigitalNRDealCreationSchedule.go();
        Test.stopTest();

        List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger];
        System.assert(ct.size() > 0);
    }

}