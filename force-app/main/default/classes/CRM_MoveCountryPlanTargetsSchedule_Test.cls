/**
   @Author Komal Mehta & Aditi Satpute
   @name CRM_MoveCountryPlanTargetsSchedule_Test
   @CreateDate 26 May 2016
   @Description Test Class for CRM_MoveCountryPlanTargetsSchedule.
   @Version <1.0>
   @reference Requirement no 185
*/
@isTest
public with sharing class CRM_MoveCountryPlanTargetsSchedule_Test {

    static testmethod void testMoveCountryPlanTargetsSchedule() {
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

        Test.startTest();
        String jobId = System.schedule('Test Move Country Plan Targets1', CRON_EXP, new CRM_MoveCountryPlanTargetsSchedule() );
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
        CRM_MoveCountryPlanTargetsSchedule.CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        CRM_MoveCountryPlanTargetsSchedule.scheduleJobName = 'Test Move Country Plan Targets2';
        CRM_MoveCountryPlanTargetsSchedule.go();
        Test.stopTest();

        List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger];
        System.assert(ct.size() > 0);
    }
}