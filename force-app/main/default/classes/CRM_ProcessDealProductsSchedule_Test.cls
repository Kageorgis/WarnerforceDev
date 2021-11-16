@isTest
public with sharing class CRM_ProcessDealProductsSchedule_Test {
    static testmethod void testProcessDealProductsSchedule() {
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

        Test.startTest();
        String jobId = System.schedule('Test1 Process Deal Products', CRON_EXP, new CRM_ProcessDealProductsSchedule() );
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
        CRM_ProcessDealProductsSchedule.CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        CRM_ProcessDealProductsSchedule.scheduleJobName = 'Test2 Process Deal Products';
        CRM_ProcessDealProductsSchedule.go();
        Test.stopTest();
        
        List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger];
        System.assert(ct.size() > 0);
    }

}