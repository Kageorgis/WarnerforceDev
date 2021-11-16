global class WB_Schedule_NotifyInactiveUsers implements Schedulable{
global void execute(SchedulableContext sc){
         WB_NotifyInactiveUsers.getUsers();
    
    }
}