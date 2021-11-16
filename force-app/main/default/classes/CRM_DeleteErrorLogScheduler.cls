/**
   @name CRM_DeleteErrorLog
   @CreateDate 27 April 2016
   @Description Schedulable class to schedule the CRM_DeleteErrorLog.
   @Version <1.0>
*/
global class CRM_DeleteErrorLogScheduler implements Schedulable {

    public static String CRON_EXP = '0 10 * * * ?';
    global static void go(){
        CRM_DeleteErrorLogScheduler sch = new CRM_DeleteErrorLogScheduler();
        system.schedule('CRM_DeleteErrorLog', CRON_EXP, sch);
    }
    
    global void execute(SchedulableContext contextInstance) {
        CRM_DeleteErrorLog batchInstance =
           new CRM_DeleteErrorLog();
        Database.executebatch(batchInstance);
    }
}