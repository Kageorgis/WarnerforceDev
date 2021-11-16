@isTest
public class RF_CustomCloneReleaseControllerTest {
    static testmethod void createCloneReleaseTest(){
        
        test.startTest();
        RF_Studio__c std = new RF_Studio__c();
        std.Distributor__c = 'test';
        insert std;
        Release__c rel = new Release__c();
        rel.RF_Studio__c = std.id;
        rel.Country_List__c = 'USA';
        rel.Release_Sync__c = rel.id;
        insert rel;
        System.assertNotEquals(rel, null);
        RF_CustomCloneReleaseController.createCloneRelease(rel.id,'Canada');
        RF_CustomCloneReleaseController.getCountry();
        test.stopTest();
        
    }
    

}