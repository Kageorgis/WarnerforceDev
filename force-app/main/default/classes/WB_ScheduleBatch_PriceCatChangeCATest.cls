@isTest
public class WB_ScheduleBatch_PriceCatChangeCATest {
    
    public static testMethod void testschedule() {
        
        Test.StartTest();
        WB_ScheduleBatch_PriceCategoryChangeCA schedulableTest = new WB_ScheduleBatch_PriceCategoryChangeCA();
        
        String cronExp = '10 15 1 * * ? *'; 
        String jobId = System.schedule('WBScheduleBatchAutoReleaseDateRPTest', cronExp,  schedulableTest);
        //System.schedule(jobName, cronExp, schedulable)//system.schedule('WBScheduleBatchAutoReleaseDateRPTest', sch, sh1); 
        Test.stopTest();
    }
}