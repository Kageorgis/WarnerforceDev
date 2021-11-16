/**
 * Written by: Preeti Jha(CTS)
 * Description: This Schedular is used to start a Batch job which will send the Refreshed Rights Report to user via mail. 
 * Project: CRRT (Phase 4-B) 
**/
public class WB_schedule_RequestRefreshedRights implements Schedulable{

    public void execute(SchedulableContext ctx) 
    {   
        WB_BatchSchedule_RequestRefreshedRights requestRefresh= new WB_BatchSchedule_RequestRefreshedRights();
        database.executebatch(requestRefresh,100);
       
    }
}