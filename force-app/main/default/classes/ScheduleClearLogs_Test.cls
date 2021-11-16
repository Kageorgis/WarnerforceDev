@isTest
private class ScheduleClearLogs_Test {

	private static testMethod void testmethod1() {
	    test.startTest();
        ScheduleClearLogs m = new ScheduleClearLogs(); 
        String sch = '0 0 8 * * ?'; 
        String jobID = system.schedule('schedule clear log', sch, m); 
        test.stopTest(); 
	}

}