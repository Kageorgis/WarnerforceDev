global class WB_ScheduleBatch_AutomatedReleaseDateRP implements Schedulable{

   global void execute(Schedulablecontext sc){
       WB_Batch_AutomatedReleaseDateRP autoRP = new WB_Batch_AutomatedReleaseDateRP();
       Database.executeBatch(autoRP);
   }

}