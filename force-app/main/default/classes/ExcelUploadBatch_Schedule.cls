/**
   @Author Accenture
   @name ExcelUploadBatch_Schedule
   @CreateDate  Mar 2020
   @Description Schedule Class for Excel Upload
   @Version <1.0>
*/
global class ExcelUploadBatch_Schedule implements Schedulable {

/** 
    *  Method for Scheduling the Batch
    *  @name execute
    *  @param schedulable context
    *  @return none
    *  @throws none
*/ 
    global void execute(SchedulableContext sc) {
        ExcelFileUploadBatch uploadFile = new ExcelFileUploadBatch();
        Id batchId = Database.executeBatch(uploadFile, 4);
    }
}