/**
   @Author Cognizant
   @name CRM_AutoTargetProdInsertScheduler_Test
   @CreateDate 27 September 2016
   @Description Test class for CRM_AutoTargetProductInsertScheduler
   @Version <1.0>
  */
  
@isTest(SeeAllData=false)
public with sharing class CRM_AutoTargetProdInsertScheduler_Test {
     /**
    *  Test 1
    *  @name test_CRM_AutoTargetProdInsertScheduler
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void test_CRM_AutoTargetProdInsertScheduler(){
    	Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        
    	Test.startTest();
        	String jobId = System.schedule('Test AutoTargetProductInsert', CRON_EXP, new CRM_AutoTargetProductInsertScheduler() );
        Test.stopTest();
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        if(ct != null){
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
        }
    }
}