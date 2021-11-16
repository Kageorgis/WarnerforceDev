/*******************************************************************************************************************************************
* File Name     :  WB_ScheduleDeleteClientAvailIDStore
* Description   :  Scheduler for WB_Batch_DeleteClientAvailIDStore
* @author       :  CTS - Mahesh Hirugade
* Modification Log
============================================================================================================================================
* Ver.    Date              Author          Modification
--------------------------------------------------------------------------------------------------------------------------------------------
* 1.0     4 Dec.2015        CTS             ER-000256 : Created the class.
*                                           a.  Scheduler for WB_Batch_DeleteClientAvailIDStore
********************************************************************************************************************************************/
global class WB_ScheduleDeleteClientAvailIDStore implements Schedulable{

    /*public static String sched = '0 00 00 * * ?';  //Every Day at Midnight 
    
    global static String scheduleMe() {
        WB_ScheduleDeleteClientAvailIDStore SC = new WB_ScheduleDeleteClientAvailIDStore(); 
        return System.schedule('Delete Client Avail Id Store records', sched, SC);
    }
    */

    global void execute(SchedulableContext sc) {
        WB_Batch_DeleteClientAvailIDStore objBatch = new WB_Batch_DeleteClientAvailIDStore();
        ID batchprocessid = Database.executeBatch(objBatch,200);
    }
}