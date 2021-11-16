/*
Version- 1.0
Creation Date- 23rd DEC 2016
Author- Preeti Jha
Description- This test class is for testing of Rights Trigger functionality.
*/
@isTest
public class Wb_RightsTriggerHandlerTest {
    static testMethod void validateRightsCreateUpdate(){
        
        insert new WB_Queue_Id__c(Name ='SonyIndiaQ',Value__c='');
        insert new WB_Queue_Id__c(Name ='EMEALicenseeQ',Value__c='');        
        
        Language__c lang = TestUtil.initLanguage('English','en',1);
        insert lang;
        system.assertNotEquals(null,lang.id);
        
        country__c country =TestUtil.createCountry('India','Ind','In');
        country.Channel__c='EST;Physical';
        insert country;
        
        MPM__c mpm = TestUtil.createMPM('12345');
        insert mpm;
        system.assertNotEquals(null,mpm.id);
        
        Rights_Group__c Locals = TestUtil.initRightsGroup(country,lang,'India');
        Locals.Rights_Locale__c = true;
        Locals.Digital_Rights_Owner__c = 'EMEALicenseeQ';
        Locals.Physical_Rights_Owner__c = 'SonyDADCQ';
        insert Locals;
        system.assertNotEquals(null,Locals.id); 
        
        Rights_Group__c Locals2 = TestUtil.initRightsGroup(country,lang,'India');
        Locals2.Rights_Locale__c = true;
        insert Locals2;
        system.assertNotEquals(null,Locals2.id);
        
        List<Rights__c> lstRights = new List<Rights__c>();
        Rights__c rights = TestUtil.initRights(mpm, 'India','EST');
        rights.Rights_End__c = System.today();
        rights.Rights_Start__c = System.today();
        rights.Source__c = 'Legal';
        rights.Channel__c = 'EST';
        lstRights.add(rights);
        
        Rights__c rightsPhysical = TestUtil.initRights(mpm, 'India','Physical');
        rightsPhysical.Rights_End__c = System.today();
        rightsPhysical.Rights_Start__c = System.today();
        rightsPhysical.Source__c = 'Legal';
        rightsPhysical.Channel__c = 'Physical';
        lstRights.add(rightsPhysical);
        
        insert lstRights;
        system.assertEquals(2,lstRights.size()); 
        
        WB_RightsTriggerHandler righttriggerhandler = new WB_RightsTriggerHandler();
        //righttriggerhandler.validateRightsAndSetQueueAsOwner(lstRights);
        
    }
    public static void createRightsTestData(){
        List<Rights__c> lstRights = new List<Rights__c>();
        //create Rights
        insert new WB_Queue_Id__c(Name ='SonyIndiaQ',Value__c='');
        insert new WB_Queue_Id__c(Name ='EMEALicenseeQ',Value__c='');        
        
        Language__c lang = TestUtil.initLanguage('English','en',1);
        insert lang;
        system.assertNotEquals(null,lang.id);
        
        country__c country =TestUtil.createCountry('India','Ind','In');
        country.Channel__c='EST;Physical';
        insert country;
        
        MPM__c mpm = TestUtil.createMPM('12345');
        insert mpm;
        system.assertNotEquals(null,mpm.id);
        
        Rights_Group__c Locals = TestUtil.initRightsGroup(country,lang,'India');
        Locals.Rights_Locale__c = true;
        Locals.Digital_Rights_Owner__c = 'EMEALicenseeQ';
        Locals.Physical_Rights_Owner__c = 'SonyDADCQ';
        insert Locals;
        system.assertNotEquals(null,Locals.id); 
        
        Rights_Group__c Locals2 = TestUtil.initRightsGroup(country,lang,'India');
        Locals2.Rights_Locale__c = true;
        insert Locals2;
        system.assertNotEquals(null,Locals2.id);
        
        
        Rights__c rights = TestUtil.initRights(mpm, 'India','EST');
        rights.Rights_End__c = System.today();
        rights.Rights_Start__c = System.today();
        rights.Source__c = 'Manual';
        rights.Channel__c = 'EST';
        lstRights.add(rights);
        
        Rights__c rightsPhysical = TestUtil.initRights(mpm, 'India','Physical');
        rightsPhysical.Rights_End__c = System.today();
        rightsPhysical.Rights_Start__c = System.today();
        rightsPhysical.Source__c = 'Manual';
        rightsPhysical.Channel__c = 'Physical';
        lstRights.add(rightsPhysical);
        
        system.assertEquals(2,lstRights.size());     
        
        insert lstRights;        
    }
    /**
* Added under ER-004371  Remove Deletion Permissions for WB Legal Profile on Rights Object
* Description: Restrict profiles other than Admin & Support profiles from deleting Rights object. 
* Method to test the check for restrictDeletionOfRightsRecords functionality
*/
    private static testMethod void restrictDeletionOfRightsRecords_TestScenario() {
        
        Test.startTest();
        User u = createRightsTestUser();
        system.runAs(u){
            System.debug('ProfileId of the test user' +u.ProfileId);
            createRightsTestData();
            try{
                Delete [SELECT Id FROM Rights__c];
            }catch(System.DmlException err){
                System.assert(err.getDmlMessage(0).contains(system.label.WB_Rights_Delete_Validation_Msg));
            }
        }
        System.assertEquals(2,[SELECT COUNT() FROM Rights__c]);      
        Test.stopTest();        
                
    }
    //Method to create Test User
    static User createRightsTestUser(){
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'WB - Territory Avails Planner' Limit 1];
        System.assertEquals(1, profiles.size());
        
        Date d = System.today();
        User testUser = new User(
            FirstName = 'Test_Rights',
            LastName = 'User_Rights',
            Username = String.valueOf(d) + 'abc@test.com',
            Email = 'abc@test.com',
            Alias = String.valueOf(d).substring(0,8),
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles',
            IsActive = true,
            ProfileId = profiles[0].Id,
            ByPassValidationRule__c = true
        );
        
        return testUser;
    }
}