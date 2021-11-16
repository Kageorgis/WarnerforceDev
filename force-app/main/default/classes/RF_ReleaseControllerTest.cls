/*========================================================================================================
* @author: Ajit Singh
* @date: 16/10/2020
* @description: Test class for  ReleaseController class
==========================================================================================================*/
@isTest
public class RF_ReleaseControllerTest {
    
    static testmethod void createReleaseTest(){
        Id recordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Catalog').getRecordTypeId();
        RF_Studio__c std = new RF_Studio__c();
        std.Distributor__c = 'test';
        insert std;
        String releaseName='Tet Catalog';
        String countryName='USA';
        String recordTypeName='Catalog';
        Date streetDate=date.today();
        Date vodDate=date.today()+1;
        Date estDate=date.today()+2;
        MPM__c mpmObj = RF_TestUtil.mpmList('12345');
        insert mpmObj;
        Id mpmId = mpmObj.Id;
        
        Release__c releaseObj= RF_TestUtil.createReleaseList(releaseName,mpmId,countryName,recordTypeId);
        releaseObj.RF_Studio__c = std.id;
         Release__c releseobj1 = RF_TestUtil.releaseList(releaseName, mpmId);
        try{
        	RF_ReleaseController.createRelease(releaseObj.mpm__c,releaseObj.name,releaseObj.Country_List__c,recordTypeName,
                                               streetDate,vodDate,estDate,releaseObj.RF_Studio__c);
        }Catch(Exception Ex){}
        insert releaseObj;
        System.assertNotEquals(releaseObj.Id, null);
        Test.startTest();
        RF_ReleaseController.createRelease(releaseObj.mpm__c,releaseObj.name,releaseObj.Country_List__c,recordTypeName,streetDate,
                                           vodDate,estDate,releaseObj.RF_Studio__c);
        RF_ReleaseController.getCountry();
        RF_ReleaseController.getRecordType();
		Test.stopTest();        
    }
}