@isTest
public class WB_schedule_RequestRefreshedRights_Test {
	//Testing code compare...........
    static testmethod void TestSchedulableClass() {
        Test.StartTest();
        //ER-001628 - Remove/update references of Srinizkumar Konakanchi from metadata components (replaced srinizkumar.konakanchi@wbconsultant.com with srinivas choula)
        CAS_Global_Settings__c globalSetting = new CAS_Global_Settings__c(Name='CAS Global Settings',Global_Email__c='srinivas.choula@wbconsultant.com');
        insert globalSetting;
        //customsetting();
        Group publicGroup = new Group();
        publicGroup.Name = 'CRRT Dev Test Request Rights';
        insert publicGroup;
        
        customsetting(publicGroup.id);
        
        MPM__c mpm = TestUtil.createMPM('12345');
        insert mpm;
        system.assertNotEquals(null,mpm.id);
        
       Profile p = [SELECT Id FROM Profile WHERE Name='SAP Integration API Only']; 
       User u = new User(Alias = 'abc123', Email='test123@test.com', EmailEncodingKey='UTF-8', LastName='Testingaaaa', LanguageLocaleKey='en_US', 
       LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='test123aaaa@test.com');

 		System.runAs(u) {
            List<Rights__c> lstRights = new List<Rights__c>();
            Rights__c rights = TestUtil.initRights(mpm, 'India','EST');
            rights.Rights_End__c = System.today();
            rights.Rights_Start__c = System.today();
            rights.Source__c = 'Manual';
            rights.Last_Refresh__c = system.today();
            lstRights.add(rights);
            
            Rights__c rightsPhysical = TestUtil.initRights(mpm, 'India','Physical');
            rightsPhysical.Rights_End__c = System.today();
            rightsPhysical.Rights_Start__c = System.today();
            rightsPhysical.Source__c = 'Legal';
            lstRights.add(rightsPhysical);
            
            insert lstRights;
            system.assertEquals(2,lstRights.size()); 
      	}
  
        RequestRefreshSchedular__c RequestRefreshsetting = new RequestRefreshSchedular__c(Name ='Public Group', Value__c='CRRT Dev Test Request Rights');
        insert RequestRefreshsetting;
        
        WB_schedule_RequestRefreshedRights objScheduler = new WB_schedule_RequestRefreshedRights();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Request refresh Check', sch, objScheduler); 
        
        WB_BatchSchedule_RequestRefreshedRights requestRefresh= new WB_BatchSchedule_RequestRefreshedRights();
        database.executebatch(requestRefresh);

        Test.stopTest(); 

    }
    
    @future
    public static void customsetting(id grName){
       GroupMember GM = new GroupMember();
        GM.GroupId = grName;
        GM.UserOrGroupId = UserInfo.getUserId();
        insert GM;
    }
}