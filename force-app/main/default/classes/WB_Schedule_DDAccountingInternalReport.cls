global class WB_Schedule_DDAccountingInternalReport implements Schedulable,Database.AllowsCallouts{
    
   
    global void execute(SchedulableContext sc){
         WB_DDAccountingInternalReport.executeReport();
    
    }

}