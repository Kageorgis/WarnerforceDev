/*
* To schedule the batch class - ClearLogs
*/
global class ScheduleClearLogs implements Schedulable
{
   global void execute(SchedulableContext sc)
   {
      ClearLogs c = new ClearLogs();
      database.executebatch(c);
   }
}