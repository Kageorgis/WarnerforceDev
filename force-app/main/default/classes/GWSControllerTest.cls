@isTest
public class GWSControllerTest {
    @testSetup
    static void setupData() {
        Account account1 = new Account(Name=Label.WB_Intake_Account_Name,Customer_Focus__c='Active');
        insert account1;
        WB_Project__c wbObj =new WB_Project__c(Submitter_First_Name__c='TestFirst',Submitter_Last_Name__c='TestLast',Submitter_Email_Id__c='testFirst@testemail.com', Service_Type__c='Workplace Support');
        insert wbObj;
    }
    
    static testmethod void checkForContactTest(){
        System.assertEquals(1, [SELECT count() FROM Contact]);
        
        //For GetValues
        WB_Project__c recRef = [SELECT Id FROM WB_Project__c LIMIT 1];
        System.assertEquals(recRef.Id,GWSController.getValues(recRef.Id).Id);
        
        //For updateRec
        GWSController.updateRec(recRef);
        
        //updatePathPicklist
        GWSController.updatePathPicklist(recRef.Id);
        
        //fetchContacts
        List<Id> lstIds = new List<Id>();
        for(Contact c : [SELECT Id FROM Contact]){
            lstIds.add(c.Id);
        }
        Test.setFixedSearchResults(lstIds);
        List<Contact> lstCont = new List<Contact>();
        lstCont= GWSController.fetchContacts('TestFirst');
        System.assertEquals(1,lstCont.size());
        lstCont= GWSController.fetchContacts('T');
        System.assertEquals(1,lstCont.size());
        
        //getselectOptions
        System.assertEquals(3,GWSController.getselectOptions(recRef,'Approval_Stage__c').size());
        
        //getDependentMap
        System.assertEquals(3,GWSController.getDependentMap(recRef,'Approval_Stage__c','Reason__c').size());
    }
    
    static testmethod void checkUserProfileTest(){
        Profile proRef = [SELECT Id FROM Profile WHERE Name = 'WBT Accessor'];
        User u = new User(LastName = 'TestL',
                          FirstName='testF',
                          Alias = 'tuser',
                          Email = 'testuserclass@testemail.com',
                          Username = 'testuserclass@testemail.com',
                          ProfileId = proRef.id,
                          TimeZoneSidKey = 'GMT',
                          LanguageLocaleKey = 'en_US',
                          EmailEncodingKey = 'UTF-8',
                          LocaleSidKey = 'en_US'
                         );
        System.runAs(u){
            System.assertEquals(false,GWSController.checkUserProfile(null));
        }
    }
    
    static testmethod void getCountriesTest(){
        List<Country__c> lstCount = new List<Country__c>();
        Country__c count = new Country__c(Name='ABC',Country_Code__c='abc',Country_Code2__c='ab',Status__c='Active');
        lstCount.add(count);
        count = new Country__c(Name='DEF',Country_Code__c='def',Country_Code2__c='de',Status__c='Active');
        lstCount.add(count);
        count = new Country__c(Name='GHI',Country_Code__c='ghi',Country_Code2__c='gh',Status__c='Inactive');
        lstCount.add(count);
        count = new Country__c(Name='JKL',Country_Code__c='jkl',Country_Code2__c='jk',Status__c='Active');
        lstCount.add(count);
        Test.startTest();
        insert lstCount;
        Test.stopTest();
        System.assertEquals(3,GWSController.getCountries().size());
    }
    
    static testmethod void insertRecTest(){
        WB_Project__c wbObj =new WB_Project__c(Submitter_First_Name__c='TestFirst2',Submitter_Last_Name__c='TestLast2',Submitter_Email_Id__c='testFirst1@testemail.com', Service_Type__c='Workplace Support');
        String recordId;
        Test.startTest();
        recordId = GWSController.insertRec(wbObj);
        Test.stopTest();
        System.assertEquals([SELECT Id FROM WB_Project__c WHERE Submitter_First_Name__c='TestFirst2'].Id,recordId);
    }
}