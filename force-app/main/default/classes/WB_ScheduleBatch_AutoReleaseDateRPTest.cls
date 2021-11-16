@isTest
public class WB_ScheduleBatch_AutoReleaseDateRPTest {
    
    public static testMethod void testschedule() {
        
        Test.StartTest();
        WB_ScheduleBatch_AutomatedReleaseDateRP schedulableTest = new WB_ScheduleBatch_AutomatedReleaseDateRP();
        
        String cronExp = '0 0 1 * * ?'; 
        String jobId = System.schedule('WBScheduleBatchAutoReleaseDateRPTest', cronExp,  schedulableTest);
        //System.schedule(jobName, cronExp, schedulable)//system.schedule('WBScheduleBatchAutoReleaseDateRPTest', sch, sh1); 
        Test.stopTest();
    }
    

}