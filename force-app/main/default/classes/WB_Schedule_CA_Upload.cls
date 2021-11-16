/*******************************************************************************************************************
* File Name     :   WB_Schedule_CA_Upload
* Description   :    
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     13 JAN.2016       CTS                 Created Schedule class to schedule batch
* 2.0       
*********************************************************************************************************************/

global class WB_Schedule_CA_Upload implements Schedulable
{
    Id caUploadId;
    global WB_Schedule_CA_Upload(Id parentobjID)
    {
        caUploadId = parentobjID;
    }
   global void execute(SchedulableContext sc)
   {
      WB_Batch_CA_Upload c = new WB_Batch_CA_Upload(caUploadId);
      database.executebatch(c,10);
   }
}