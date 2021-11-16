/*******************************************************************************************************************************************
* File Name     :   WB_ScheduleDeleteClientAvailIDStoreTest
* Description   :   Test class for A scheduler job to kick off the batch job 'WB_ScheduleDeleteClientAvailIDStore' //at 8am PST.
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     1 Mar.2016        CTS                 Created the class.
* 2.0       
********************************************************************************************************************************************/

@isTest
private class WB_ScheduleDeleteClientAvailIDStoreTest {

    public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    static testmethod void TestSchedulableClass() {
        
        Test.startTest();
    
        // Schedule the test job 
        String jobId = System.schedule('Delete Client Avail Id Store records', CRON_EXP, new WB_ScheduleDeleteClientAvailIDStore());
        
        // Get the information from the CronTrigger API object 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
    
        // Verify the expressions are the same 
        System.assertEquals(CRON_EXP, ct.CronExpression);
    
        // Verify the job has not run 
        System.assertEquals(0, ct.TimesTriggered);
    
        // Verify the next time the job will run 
        System.assertEquals('2022-03-15 00:00:00',  String.valueOf(ct.NextFireTime));
          
        Test.stopTest();
    }
}