@IsTest
private class CP_FlowThroughDatesHandlerTest {
    @TestSetup
    static void createTestData(){
        Id licRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId();
        Id retAccRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Retailer').getRecordTypeId();
        Profile profileObj = [SELECT Id FROM Profile WHERE Name ='WBCP NAM Licensee App Admin'];
        
        Account licenceeAcc = (Account)TestDataFactory.createSObject('Account', new Map<String,Object>{
            'Name' => 'Mattel',
                'RecordTypeId' => licRecTypeid,
                'cp_Licensee_Code__c' => '0001011318' 
                },true);
        
        User userObj = (User) TestDataFactory.createSObject('User', new Map<String,Object>{
            'alias' => 'standt', 'email' => 'testuser@testorg.com', 'emailencodingkey' => 'UTF-8', 'lastname' => 'Testing',
                'languagelocalekey' => 'en_US', 'Territory__c' => 'USA', 'localesidkey' => 'en_US', 'timezonesidkey' => 'America/Los_Angeles', 
                'username' => 'superUser@testorg.com','WBCP_Access_Role__c' => 'Global', 'profileid' => profileObj.Id},true);
        
        Account retailerAcc = (Account)TestDataFactory.createSObject('Account', new Map<String,Object>{
            'RecordTypeId' => retAccRecTypeid});
        
        WBCP_Country__c countryRecord = (WBCP_Country__c)TestDataFactory.createSObject('WBCP_Country__c',new Map<String,object>{
            'Name' => 'United States', 'Country_Code__c' => 'US'});
        
        Property__c propObj = (Property__c)TestDataFactory.createSObject('Property__c',new Map<String,object>{
            'Name' => 'Batman Core', 'cp_Property_Code__c' => '000046', 'IsPrimary__c' => True, 'Franchise__c'=>'Batman'});   
        
        CP_Product__c prodRec =  (CP_Product__c)TestDataFactory.createSObject('CP_Product__c', new Map<String,Object>{
            'Licensee__c' => licenceeAcc.Id,
                'WBCP_Country__c' => countryRecord.Id,
                'GTIN__c' => '00887961833805',
                'MPN__c' => '8875823',
                'cp_Retailer_Description__c' => retailerAcc.Id,
                'Retailer_SKU__c' => '567021036',
                'cp_Licensed_Property__c' => propObj.Id,
                'Sub_Category__c' => 'Vehicles / Remote Control'
                });
        
        Flow_Through_Dates__c ftMappingObj = (Flow_Through_Dates__c)TestDataFactory.createSObject('Flow_Through_Dates__c', new Map<String,Object>{
            'GTIN__c' => '00887961833805',
                'Flow_Through_Start_Date__c' => Date.parse('3/06/2021'),
                'Flow_Through_End_Date__c' => Date.parse('3/13/2021'),
                'Country__c' => countryRecord.Id,
                'Retailer__c' => retailerAcc.Id,
                'Licensed_Property__c' => propObj.Id},true);
    }
    
    @IsTest
    static void test_insertCPFlowThroughDatesRec(){
        Account retObj = [SELECT Id, Name FROM Account WHERE RecordType.Name = 'WBCP Retailer' LIMIT 1];
        Property__c propObj = [SELECT Id, Name FROM Property__c LIMIT 1];
        WBCP_Country__c cntrObj = [SELECT Id, Name FROM WBCP_Country__c LIMIT 1];
        Flow_Through_Dates__c FTMappingObj = new Flow_Through_Dates__c();
        
        FTMappingObj.Country__c = cntrObj.Id;
        FTMappingObj.Retailer__c = retObj.Id;
        FTMappingObj.GTIN__c = '00887961833805';
        FTMappingObj.Flow_Through_Start_Date__c =Date.parse('5/08/2021');
        FTMappingObj.Flow_Through_End_Date__c = Date.parse('5/22/2021');
        FTMappingObj.Licensed_Property__c = propObj.Id;
        test.startTest();
        insert FTMappingObj;
        test.stopTest();
    }
    
    @IsTest
    static void test_updateCPFlowThroughDatesRec(){
        Flow_Through_Dates__c FTMappingObj = [SELECT Id, GTIN__c,Flow_Through_Start_Date__c FROM Flow_Through_Dates__c LIMIT 1];
        FTMappingObj.GTIN__c = '887961833805';
        FTMappingObj.Flow_Through_Start_Date__c =Date.parse('5/15/2021');
        FTMappingObj.Flow_Through_End_Date__c =Date.parse('5/22/2021');
        test.startTest();
        update FTMappingObj;
        test.stopTest();
    }
}