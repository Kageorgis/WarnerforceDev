@isTest
private class WB_Batch_UpdateDailyRightsCheckTest {
    public static MPM__c mpm;
    public static List<MPM__c> mpmList;
    public static Rights__c rights;
    public static List<Rights__c> rightsList;
    public static boolean isRunning_WB_Batch_UpdateDailyRightsCheck = false;
    // Create MPM
    public static MPM__c createMPM(String mpmNumber)
    {
        MPM__c mpmRec = new MPM__c(
        Name = 'Test_Johny Bravo',
        MPM_Number__c = mpmNumber);
        return mpmRec;
    }
    
    // Create Rights
    // // Previoue code as on 30/11/2016
    public static List<Rights__c> initRights(Integer noOfRecs, MPM__c objMpm, String Status, Date startDate, Date endDate)
    {
        List<Rights__c> rightsLst = new List<Rights__c>();
        for(Integer i=0;i<noOfRecs;i++){
            rightsLst.add(new Rights__c(MPM__c = objMpm.Id, 
                                        Status__c=Status, 
                                        Rights_Start__c =startDate-i,
                                    	Rights_End__c = endDate-i ));
        }
        
        return rightsLst; 
    }
    // Update code as per the new rights object structure on 30/11/16 By Purushottam
    public static List<Rights__c> initRights(MPM__c objMpm, String Status, Date startDate, Date endDate, String rightsGroup, String source)
    {
        List<Rights__c> rightsLst = new List<Rights__c>();
        rightsLst.add(new Rights__c(MPM__c = objMpm.Id, 
                                    Status__c=Status, 
                                    Rights_Start__c =startDate,
                                    Rights_End__c = endDate,
                                    Rights_Group__c = rightsGroup,
                                    Source__c = source));
        return rightsLst; 
    }
    
	private static testMethod void RightsWithConfirmedStatus() {
	    String query = 'SELECT Id FROM Rights__c WHERE Rights_End__c < Today';
        mpm = createMPM('2043705');
        insert mpm;
        mpmList= new List<MPM__c>();
        mpmList.add(mpm);
        
        //rightsList = initRights(100,mpm,'Confirmed',system.Today(),system.Today());
        // update on 30/11/16 by Purushottam
        rightsList = initRights(mpm,'Confirmed',system.Today() - 5,system.Today() - 3, 'USA', 'Manual');
        rightsList[0].Channel__c = 'EST';
        insert rightsList;
        
        test.startTest();
        WB_Batch_UpdateDailyRightsCheck b = new WB_Batch_UpdateDailyRightsCheck(query);
        String schedule = '0 30 0 * * ?';
        system.schedule('Daily Schedule' , schedule, b);
        test.stopTest();
        
	}
	
	

}