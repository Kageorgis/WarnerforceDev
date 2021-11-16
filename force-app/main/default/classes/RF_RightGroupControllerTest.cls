@isTest
public class RF_RightGroupControllerTest {
    public static testMethod void testRighGrpCntlr(){
      MPM__c mpmObj = RF_TestUtil.mpmList('12345');
        insert mpmObj;
        Id rigtsRecordTypeId = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
        List<Rights__c> lstRights = new List<Rights__c>();
        Rights__c rights = RF_TestUtil.getRightsRecord(mpmObj.Id, rigtsRecordTypeId, 'India','EST');
        rights.Rights_End__c = System.today();
        rights.Rights_Start__c = System.today();
        rights.Source__c = 'Legal';
        rights.Channel__c = 'EST';
        lstRights.add(rights);
        Rights__c rightsPhysical = RF_TestUtil.getRightsRecord(mpmObj.Id, rigtsRecordTypeId, 'India','Physical');
        rightsPhysical.Rights_End__c = System.today();
        rightsPhysical.Rights_Start__c = System.today();
        rightsPhysical.Source__c = 'Legal';
        rightsPhysical.Channel__c = 'Physical';
        rightsPhysical.Rights_Group__c ='USA';

        lstRights.add(rightsPhysical);
        insert lstRights;
        RF_Studio__c  std = new RF_Studio__c();
        std.Distributor__c = 'test';
        insert std;
        Id recordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Catalog').getRecordTypeId();
        Release__c releaseObj= RF_TestUtil.createReleaseList('releaseName',mpmObj.Id,'USA',recordTypeId);
        releaseObj.RF_Studio__c = std.id;
        releaseObj.Country_List__c ='USA';
        insert releaseObj;
        System.assertNotEquals(releaseObj.Id, null);
        Test.startTest();
        RF_RightGroupController.fetchRightGroup(releaseObj.Id);
        Test.stopTest();
    }
}