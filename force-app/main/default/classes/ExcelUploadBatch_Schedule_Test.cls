@isTest
private class ExcelUploadBatch_Schedule_Test {
    private static testMethod void testschedule() {
        Test.StartTest();
        ExcelUploadBatch_Schedule testsche = new ExcelUploadBatch_Schedule();
        String sch = '0 00 * * * ?';
        system.schedule('Excel Upload Batch Schedule', sch, testsche );
        Test.stopTest();
    }
}