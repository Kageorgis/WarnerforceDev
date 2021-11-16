/**
   @Author Komal Mehta & Aditi Satpute
   @name CRM_MoveCountryPlanTargetsSchedule
   @CreateDate 26 May 2016
   @Description Schedulable class to schedule the CRM_MoveCountryPlanTargetsbatch. It will be set to run every day at 10PM.
   @Version <1.0>
   @reference Requirement no 185
*/
global class CRM_MoveCountryPlanTargetsSchedule implements Schedulable {

    public static String CRON_EXP = '0 0 22 * * ?';
    public static String scheduleJobName = 'Move Country Plan Targets';

    global static void go() {
        CRM_MoveCountryPlanTargetsSchedule sch = new CRM_MoveCountryPlanTargetsSchedule();
        system.schedule(scheduleJobName, CRON_EXP, sch);
    }

    global void execute(SchedulableContext contextInstance) {
        CRM_MoveCountryPlanTargetsBatch batchInstance =
           new CRM_MoveCountryPlanTargetsBatch();
        Database.executebatch(batchInstance, 100);
    }
}