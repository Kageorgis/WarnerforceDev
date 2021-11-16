/******* 
UploadMaterial_Test
Creation Date- 02 August 2016
Description- This class is to do code coverage for UploadMaterial_CC and UploadMaterial_Batch
Author- Walter Ynche
*******/

@isTest
private class UploadMaterial_Test{
    
    static testMethod void uploadMaterialTest(){
    	Materials_Due__c md1 = new 	Materials_Due__c();
    	md1.Name = 'January W1';
    	md1.Active__c = true;
    	md1.Drop_Dead__c = system.now().addDays(7).date();
    	md1.Materials_Due__c = system.now().date();
    	insert md1;
    	
    	Test.startTest();
        StaticResource csvFile = [select Body from StaticResource where Name = 'MaterialsDueTest'];
        UploadMaterial_CC.binFile = csvFile.Body;
        UploadMaterial_CC uploadMaterial = new UploadMaterial_CC();
		uploadMaterial.ReadFile();
        Test.stopTest();
    }
}