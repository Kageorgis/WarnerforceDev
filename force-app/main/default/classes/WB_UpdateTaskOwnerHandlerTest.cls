/*******************************************************************************************************************************************
* File Name     :   WB_UpdateTaskOwnerHandlerTest
* Description   :   Test class for WB_UpdateTaskOwnerHandler
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     4 Dec.2015        CTS                 ER-000399 : Created the class. Language Readiness - reassigned task owners to be remembered for future tasks
* 2.0                                       
********************************************************************************************************************************************/

@isTest
private class WB_UpdateTaskOwnerHandlerTest {
    
    public static Account acctGoogle;
    public static Title__c title;
    public static Country__c countryFrance;
    public static Language__c languageFrench;
    
    static void setUpdata() {
        acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        title = TestUtil.initTitle('Dark Night Collection', '6000025000');
        title.Content_Type__c = 'Episode';
        title.Formats__c ='SD';
        insert title;
        
        countryFrance = TestUtil.initCountry('TestFrance', 'TR', 'TF');
        insert countryFrance;
        
        languageFrench = TestUtil.initLanguage('TestFrench', '', 1);
        insert languageFrench;
        
        Task_Group_Counter__c tgc = Task_Group_Counter__c.getOrgDefaults();
        tgc.Counter__c = 1;
        insert tgc;
    }
    
    static testMethod void myUnitTest1() {        
        setUpdata();
        Profile objProfile = TestUtil.initProfile('Standard User');
        User objUser = TestUtil.initUser(objProfile.Id);
        insert objUser;
        
        Test.startTest();
        
        Available_Languages__c objAL = TestUtil.initAvailableLang(languageFrench.Id, 'Audio', title.Id);
        objAL.Mastering_Reason_Code__c = 'Fixes Required';
        objAL.Clear_To_Avail__c = false;
        objAL.Mastering_Cost__c = 10;
        insert objAL;		
                
        List<Task> lstTask = [Select Id, OwnerId from Task];
        system.assertNotEquals(null, lstTask);
        system.assertNotEquals(null, lstTask[0].OwnerId);
        //system.assertEquals(UserInfo.getUserId(), lstTask[0].OwnerId);
        
        lstTask[0].OwnerId = objUser.Id;
        update lstTask[0];
        
        List<Available_Languages__c> lstAvailLang = [Select Id, Mastering_Owner__c, GPP_Owner__c from Available_Languages__c where Id =: objAL.Id];
        system.assertNotEquals(null, lstAvailLang[0].GPP_Owner__c);
        system.assertEquals(objUser.Id, lstAvailLang[0].GPP_Owner__c);
        
        objAL.Mastering_Reason_Code__c = 'Origination Required';
        Update objAL;
        
        lstTask = [Select Id, OwnerId from Task];
        system.assertNotEquals(null, lstTask);
        system.assertEquals(2, lstTask.size());
        system.assertEquals(objUser.Id, lstTask[1].OwnerId);
        system.assertEquals(objUser.Id, lstTask[0].OwnerId);
        
        Test.stopTest();
    }
    
    static testMethod void myUnitTest2() {
        
        setUpdata();
        Profile objProfile = TestUtil.initProfile('Standard User');
        User objUser = TestUtil.initUser(objProfile.Id);
        insert objUser;
        
        Test.startTest();
        
        Available_Languages__c objAL = TestUtil.initAvailableLang(languageFrench.Id, 'Audio', title.Id);
        objAL.GPP_status__c = 'Fixes Approved';
        objAL.Clear_To_Avail__c = false;
        insert objAL;		
        
        List<Task> lstTask = [Select Id, OwnerId from Task];
        system.assertNotEquals(null, lstTask);
        system.assertNotEquals(null, lstTask[0].OwnerId);
        
        lstTask[0].OwnerId = objUser.Id;
        update lstTask[0];
        
        List<Available_Languages__c> lstAvailLang = [Select Id, Mastering_Owner__c, GPP_Owner__c from Available_Languages__c where Id =: objAL.Id];
        system.assertNotEquals(null, lstAvailLang[0].Mastering_Owner__c);
        system.assertEquals(objUser.Id, lstAvailLang[0].Mastering_Owner__c);
        
        objAL.GPP_status__c = 'Origination Approved';
        Update objAL;
        
        lstTask = [Select Id, OwnerId from Task];
        system.assertNotEquals(null, lstTask);
        system.assertEquals(2, lstTask.size());
        system.assertEquals(objUser.Id, lstTask[1].OwnerId);
        system.assertEquals(objUser.Id, lstTask[0].OwnerId);
        
        Test.stopTest();
    }
}