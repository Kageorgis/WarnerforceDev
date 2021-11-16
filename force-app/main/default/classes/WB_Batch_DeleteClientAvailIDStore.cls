/*******************************************************************************************************************************************
* File Name     :  WB_Batch_DeleteClientAvailIDStore
* Description   :  A batch job to delete 'Client Avail Id Store' records which are no more in use.
* @author       :  CTS - Mahesh Hirugade
* Modification Log
============================================================================================================================================
* Ver.    Date              Author          Modification
--------------------------------------------------------------------------------------------------------------------------------------------
* 1.0     4 Dec.2015        CTS             ER-000256 : Created the class.
*                                           a.  Create a batch job to delete 'Client Avail Id Store' records which are no more in use.
                                                These records were created to accomplish the functionality of ER-256 to carry more records
                                                to Re-Price Wizard
********************************************************************************************************************************************/
global class WB_Batch_DeleteClientAvailIDStore implements database.batchable<sObject>{

    global database.Querylocator start(Database.batchableContext BC){
        Datetime var = system.now().addDays(-1);
        return database.getQueryLocator('select Id, LastModifiedDate from Client_Avail_Id_Store__c where LastModifiedDate < :var');
    }
    
    global void execute(Database.BatchableContext BC, List<Client_Avail_Id_Store__c>scope){
        delete scope;
    }
    
    global void finish(Database.BatchableContext BC){}
}