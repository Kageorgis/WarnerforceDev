@isTest(SeeAllData = false)
private class WB_NotifyInactiveUsersTest {
    static testMethod void validategetUsers() {
        String profileName='System Administrator';
        Profile testProfile=TestUtil.initProfile(profileName);
       	User testUser=TestUtil.initUser(testProfile.Id);
        insert testUser;
        List<Reminder_Settings__c> lstrsCustSet = new  List<Reminder_Settings__c>();
        Reminder_Settings__c rsCustSet1 = new Reminder_Settings__c(name='Final Reminder',Days_Since__c = 89);
        lstrsCustSet.add(rsCustSet1);
        Reminder_Settings__c rsCustSet2 = new Reminder_Settings__c(name='First Reminder',Days_Since__c = 60);
        lstrsCustSet.add(rsCustSet2);
        Reminder_Settings__c rsCustSet3 = new Reminder_Settings__c(name='Second Reminder',Days_Since__c = 83);
        lstrsCustSet.add(rsCustSet3);
        insert lstrsCustSet;
        CAS_Global_Settings__c casgs = new CAS_Global_Settings__c();
        casgs.Name = 'CAS Global Settings';
        casgs.Global_Email__c = 'wbhesalesservices@warnerbros.com';
        insert casgs;
        User u = [SELECT IsActive,UserName,FirstName,LastName,CreatedDate,Email,Id,LastLoginDate FROM User Where Id=:testUser.Id];
        Date myDate = date.today();
        myDate = myDate.addDays(-60);
        Integer d = myDate.day();
        Integer mo = myDate.month();
        Integer yr = myDate.year();
        DateTime DT = DateTime.newInstance(yr, mo, d);
        Test.setCreatedDate(u.Id, DT);         
        WB_NotifyInactiveUsers.getUsers();
    }
    
}