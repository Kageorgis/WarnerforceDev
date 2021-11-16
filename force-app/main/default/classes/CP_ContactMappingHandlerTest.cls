@IsTest
private class CP_ContactMappingHandlerTest {
    @TestSetup
    static void createTestData(){
        Id licAccRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId();
        Id retAccRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Retailer').getRecordTypeId();
        Id licContRecTypeid = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('WBCP Licensee Contact').getRecordTypeId();
        Profile profileObj = [SELECT Id FROM Profile WHERE Name ='WBCP NAM Licensee App Admin'];
        
        User userObj = (User) TestDataFactory.createSObject('User', new Map<String,Object>{
            'alias' => 'standt','email' => 'testuser@testorg.com', 'emailencodingkey' => 'UTF-8', 'lastname' => 'Testing',
            'languagelocalekey' => 'en_US', 'Territory__c' => 'USA', 'localesidkey' => 'en_US', 'timezonesidkey' => 'America/Los_Angeles', 
            'username' => 'superUser@testorg.com','WBCP_Access_Role__c' => 'Global', 'profileid' => profileObj.Id},true);
        
        Account licenceeAccount = (Account)TestDataFactory.createSObject('Account', new Map<String,Object>{
            'Name' => 'Bioworld', 'RecordTypeId' => licAccRecTypeid, 'cp_Licensee_Code__c' => '0001032499'},true);
        
        Account retailerAcc = (Account)TestDataFactory.createSObject('Account', new Map<String,Object>{
            'RecordTypeId' => retAccRecTypeid});
         List<WBCP_TerritoryData__c> wbcpTerrDataList = new List<WBCP_TerritoryData__c>();
            
            WBCP_TerritoryData__c wbcpTerrData = new WBCP_TerritoryData__c
                (Name = 'United States',Allocable_Territory_Code__c='US',Destination_Region__c='North America');
            wbcpTerrDataList.add(wbcpTerrData);
            
            WBCP_TerritoryData__c wbcpTerrData2 = new WBCP_TerritoryData__c
                (Name = 'Canada',Allocable_Territory_Code__c='CA',Destination_Region__c='North America');
            wbcpTerrDataList.add(wbcpTerrData2);
            
            WBCP_TerritoryData__c wbcpTerrData3 = new WBCP_TerritoryData__c
                (Name = 'Czech Republic',Allocable_Territory_Code__c='CS',Destination_Region__c='EMEA');
            wbcpTerrDataList.add(wbcpTerrData3);
            
            WBCP_TerritoryData__c wbcpTerrData4 = new WBCP_TerritoryData__c
                (Name = 'Egypt',Allocable_Territory_Code__c='EG',Destination_Region__c='EMEA');
            wbcpTerrDataList.add(wbcpTerrData4);
            
            WBCP_TerritoryData__c wbcpTerrData5 = new WBCP_TerritoryData__c
                (Name = 'France',Allocable_Territory_Code__c='FR',Destination_Region__c='EMEA');
            wbcpTerrDataList.add(wbcpTerrData5);
            
            WBCP_TerritoryData__c wbcpTerrData6 = new WBCP_TerritoryData__c
                (Name = 'Germany',Allocable_Territory_Code__c='DE',Destination_Region__c='EMEA');
            wbcpTerrDataList.add(wbcpTerrData6);
            
            WBCP_TerritoryData__c wbcpTerrData7 = new WBCP_TerritoryData__c
                (Name = 'Greece',Allocable_Territory_Code__c='GR',Destination_Region__c='EMEA');
            wbcpTerrDataList.add(wbcpTerrData7);
            
            WBCP_TerritoryData__c wbcpTerrData8 = new WBCP_TerritoryData__c
                (Name = 'Hungary',Allocable_Territory_Code__c='HU',Destination_Region__c='EMEA');
            wbcpTerrDataList.add(wbcpTerrData8);
            
            WBCP_TerritoryData__c wbcpTerrData9 = new WBCP_TerritoryData__c
                (Name = 'Israel',Allocable_Territory_Code__c='IL',Destination_Region__c='EMEA');
            wbcpTerrDataList.add(wbcpTerrData9);
            
            WBCP_TerritoryData__c wbcpTerrData10 = new WBCP_TerritoryData__c
                (Name = 'Italy',Allocable_Territory_Code__c='IT',Destination_Region__c='EMEA');
            wbcpTerrDataList.add(wbcpTerrData10);           
            
            
            WBCP_TerritoryData__c wbcpTerrData11 = new WBCP_TerritoryData__c
                (Name = 'Netherlands',Allocable_Territory_Code__c='NB',Destination_Region__c='EMEA');
            wbcpTerrDataList.add(wbcpTerrData11);
            
            WBCP_TerritoryData__c wbcpTerrData12 = new WBCP_TerritoryData__c
                (Name = 'Poland',Allocable_Territory_Code__c='PL',Destination_Region__c='EMEA');
            wbcpTerrDataList.add(wbcpTerrData12);
            
            WBCP_TerritoryData__c wbcpTerrData13 = new WBCP_TerritoryData__c
                (Name = 'Russia',Allocable_Territory_Code__c='RU',Destination_Region__c='EMEA');
            wbcpTerrDataList.add(wbcpTerrData13);
            
            WBCP_TerritoryData__c wbcpTerrData14 = new WBCP_TerritoryData__c
                (Name = 'Serbia',Allocable_Territory_Code__c='SER',Destination_Region__c='EMEA');
            wbcpTerrDataList.add(wbcpTerrData14);
            
            WBCP_TerritoryData__c wbcpTerrData15 = new WBCP_TerritoryData__c
                (Name = 'South Africa',Allocable_Territory_Code__c='ZA',Destination_Region__c='EMEA');
            wbcpTerrDataList.add(wbcpTerrData15);
            
            WBCP_TerritoryData__c wbcpTerrData16 = new WBCP_TerritoryData__c
                (Name = 'Spain',Allocable_Territory_Code__c='ES',Destination_Region__c='EMEA');
            wbcpTerrDataList.add(wbcpTerrData16);
            
            WBCP_TerritoryData__c wbcpTerrData17 = new WBCP_TerritoryData__c
                (Name = 'Sweden',Allocable_Territory_Code__c='SI',Destination_Region__c='EMEA');
            wbcpTerrDataList.add(wbcpTerrData17);
            
            WBCP_TerritoryData__c wbcpTerrData18 = new WBCP_TerritoryData__c
                (Name = 'Turkey',Allocable_Territory_Code__c='TR',Destination_Region__c='EMEA');
            wbcpTerrDataList.add(wbcpTerrData18);           
            
            WBCP_TerritoryData__c wbcpTerrData19 = new WBCP_TerritoryData__c
                (Name = 'United Arab Emirates',Allocable_Territory_Code__c='AE',Destination_Region__c='EMEA');
            wbcpTerrDataList.add(wbcpTerrData19);
            
            WBCP_TerritoryData__c wbcpTerrData20 = new WBCP_TerritoryData__c
                (Name = 'United Kingdom',Allocable_Territory_Code__c='UK',Destination_Region__c='EMEA');
            wbcpTerrDataList.add(wbcpTerrData20);
            
            WBCP_TerritoryData__c wbcpTerrData21 = new WBCP_TerritoryData__c
                (Name = 'Singapore',Allocable_Territory_Code__c='SP',Destination_Region__c='Asia Pacific');
            wbcpTerrDataList.add(wbcpTerrData21);
            
            WBCP_TerritoryData__c wbcpTerrData22 = new WBCP_TerritoryData__c
                (Name = 'Taiwan',Allocable_Territory_Code__c='TW',Destination_Region__c='Asia Pacific');
            wbcpTerrDataList.add(wbcpTerrData22);
            
            WBCP_TerritoryData__c wbcpTerrData23 = new WBCP_TerritoryData__c
                (Name = 'Thailand',Allocable_Territory_Code__c='TH',Destination_Region__c='Asia Pacific');
            wbcpTerrDataList.add(wbcpTerrData23);
            
            WBCP_TerritoryData__c wbcpTerrData24 = new WBCP_TerritoryData__c
                (Name = 'Vietnam',Allocable_Territory_Code__c='VN',Destination_Region__c='Asia Pacific');
            wbcpTerrDataList.add(wbcpTerrData24);
            
            WBCP_TerritoryData__c wbcpTerrData25 = new WBCP_TerritoryData__c
                (Name = 'Australia',Allocable_Territory_Code__c='AU',Destination_Region__c='Asia Pacific');
            wbcpTerrDataList.add(wbcpTerrData25);
            
            WBCP_TerritoryData__c wbcpTerrData26 = new WBCP_TerritoryData__c
                (Name = 'China',Allocable_Territory_Code__c='CN',Destination_Region__c='Asia Pacific');
            wbcpTerrDataList.add(wbcpTerrData26);
            
            WBCP_TerritoryData__c wbcpTerrData27 = new WBCP_TerritoryData__c
                (Name = 'Hong Kong',Allocable_Territory_Code__c='HK',Destination_Region__c='Asia Pacific');
            wbcpTerrDataList.add(wbcpTerrData27);
            
            WBCP_TerritoryData__c wbcpTerrData28 = new WBCP_TerritoryData__c
                (Name = 'India',Allocable_Territory_Code__c='IN',Destination_Region__c='Asia Pacific');
            wbcpTerrDataList.add(wbcpTerrData28);
            
            WBCP_TerritoryData__c wbcpTerrData29 = new WBCP_TerritoryData__c
                (Name = 'Indonesia',Allocable_Territory_Code__c='ID',Destination_Region__c='Asia Pacific');
            wbcpTerrDataList.add(wbcpTerrData29);
            
            WBCP_TerritoryData__c wbcpTerrData30 = new WBCP_TerritoryData__c
                (Name = 'Japan',Allocable_Territory_Code__c='JP',Destination_Region__c='Asia Pacific');
            wbcpTerrDataList.add(wbcpTerrData30);
            
            WBCP_TerritoryData__c wbcpTerrData31 = new WBCP_TerritoryData__c
                (Name = 'Korea (South)',Allocable_Territory_Code__c='KR',Destination_Region__c='Asia Pacific');
            wbcpTerrDataList.add(wbcpTerrData31);
            
            WBCP_TerritoryData__c wbcpTerrData32 = new WBCP_TerritoryData__c
                (Name = 'Malaysia',Allocable_Territory_Code__c='MY',Destination_Region__c='Asia Pacific');
            wbcpTerrDataList.add(wbcpTerrData32);
            
            WBCP_TerritoryData__c wbcpTerrData33 = new WBCP_TerritoryData__c
                (Name = 'New Zealand',Allocable_Territory_Code__c='NZ',Destination_Region__c='Asia Pacific');
            wbcpTerrDataList.add(wbcpTerrData33);
            
            WBCP_TerritoryData__c wbcpTerrData34 = new WBCP_TerritoryData__c
                (Name = 'Philippines',Allocable_Territory_Code__c='PH',Destination_Region__c='Asia Pacific');
            wbcpTerrDataList.add(wbcpTerrData34);
            
            WBCP_TerritoryData__c wbcpTerrData35 = new WBCP_TerritoryData__c
                (Name = 'Argentina',Allocable_Territory_Code__c='AR',Destination_Region__c='Latin America');
            wbcpTerrDataList.add(wbcpTerrData35);
            
            WBCP_TerritoryData__c wbcpTerrData36 = new WBCP_TerritoryData__c
                (Name = 'Brazil',Allocable_Territory_Code__c='BR',Destination_Region__c='Latin America');
            wbcpTerrDataList.add(wbcpTerrData36);
            
            WBCP_TerritoryData__c wbcpTerrData37 = new WBCP_TerritoryData__c
                (Name = 'Chile',Allocable_Territory_Code__c='CL',Destination_Region__c='Latin America');
            wbcpTerrDataList.add(wbcpTerrData37);
            
            WBCP_TerritoryData__c wbcpTerrData38 = new WBCP_TerritoryData__c
                (Name = 'Colombia',Allocable_Territory_Code__c='CO',Destination_Region__c='Latin America');
            wbcpTerrDataList.add(wbcpTerrData38);
            
            WBCP_TerritoryData__c wbcpTerrData39 = new WBCP_TerritoryData__c
                (Name = 'Ecuador',Allocable_Territory_Code__c='EC',Destination_Region__c='Latin America');
            wbcpTerrDataList.add(wbcpTerrData39);
            
            WBCP_TerritoryData__c wbcpTerrData40 = new WBCP_TerritoryData__c
                (Name = 'Mexico',Allocable_Territory_Code__c='MX',Destination_Region__c='Latin America');
            wbcpTerrDataList.add(wbcpTerrData40);
            
            WBCP_TerritoryData__c wbcpTerrData41 = new WBCP_TerritoryData__c
                (Name = 'Panama',Allocable_Territory_Code__c='PA',Destination_Region__c='Latin America');
            wbcpTerrDataList.add(wbcpTerrData41);
            
            WBCP_TerritoryData__c wbcpTerrData42 = new WBCP_TerritoryData__c
                (Name = 'Peru',Allocable_Territory_Code__c='PE',Destination_Region__c='Latin America');
            wbcpTerrDataList.add(wbcpTerrData42);
            
            WBCP_TerritoryData__c wbcpTerrData43 = new WBCP_TerritoryData__c
                (Name = 'Venezuela',Allocable_Territory_Code__c='VE',Destination_Region__c='Latin America');
            wbcpTerrDataList.add(wbcpTerrData43);
            
            
            insert wbcpTerrDataList;
        Contact licContact = (Contact)TestDataFactory.createSObject('Contact', new Map<String,Object>{
            'FirstName' => 'Test', 'LastName' => 'Test', 'CP_Territory__c'=> 'United States', 'RecordTypeId' => licContRecTypeid, 'Account' => licenceeAccount},true);
        
        WBCP_Country__c countryRecord = (WBCP_Country__c)TestDataFactory.createSObject('WBCP_Country__c',new Map<String,object>{
            'Name' => 'United States', 'Country_Code__c' => 'US'});
        
        Property__c propObj = (Property__c)TestDataFactory.createSObject('Property__c',new Map<String,object>{
          'Name' => 'Batman Core', 'cp_Property_Code__c' => '000046', 'IsPrimary__c' => True, 'Franchise__c'=>'Batman'}); 
        
        
        
        CP_Licensee_Contact_Mapping__c cntMappingObj = (CP_Licensee_Contact_Mapping__c)TestDataFactory.createSObject('CP_Licensee_Contact_Mapping__c', new Map<String,Object>{
            'Licensee_Account__c' => licenceeAccount.Id, 
            'Licensee_Contact_Name__c' => licContact.Id, 
            'Contact_Type__c' => 'Sales', 
            'Country__c' => countryRecord.Id,
            'Retailer__c' => retailerAcc.Id,
            'WB_POC__c' => userObj.Id,
            'CP_Licensee_Sub_Category__c' => 'Underwear - Adult',
            'Property__c' => propObj.Id},true);
    }
    
    @IsTest
    static void test_insertCPLicenseeContactMappingRec(){
        Account liceObj = [SELECT Id, Name FROM Account WHERE RecordType.Name = 'WBCP Licensee' LIMIT 1];
        Account retObj = [SELECT Id, Name FROM Account WHERE RecordType.Name = 'WBCP Retailer' LIMIT 1];
        Contact cntObj = [SELECT Id, OwnerId FROM Contact WHERE RecordType.Name = 'WBCP Licensee Contact' LIMIT 1];
        Property__c propObj = [SELECT Id, Name FROM Property__c LIMIT 1];
        WBCP_Country__c cntrObj = [SELECT Id, Name FROM WBCP_Country__c LIMIT 1];
        
        CP_Licensee_Contact_Mapping__c CntMappingObj = new CP_Licensee_Contact_Mapping__c();
        CntMappingObj.Licensee_Account__c = liceObj.Id;
        CntMappingObj.Licensee_Contact_Name__c = cntObj.Id;
        CntMappingObj.Contact_Type__c = 'Sales';
        CntMappingObj.Country__c = cntrObj.Id;
        CntMappingObj.Retailer__c = retObj.Id;
        CntMappingObj.WB_POC__c = cntObj.OwnerId;
        CntMappingObj.CP_Licensee_Sub_Category__c = 'Underwear - Adult';
        CntMappingObj.Property__c = propObj.Id;
        test.startTest();
        insert CntMappingObj;
        test.stopTest();
    }
    
    @IsTest
    static void test_updateLicenseeContactMappingRecSubCategory(){
        CP_Licensee_Contact_Mapping__c CntMappingObj = [SELECT Id, CP_Licensee_Sub_Category__c FROM CP_Licensee_Contact_Mapping__c LIMIT 1];
        CntMappingObj.CP_Licensee_Sub_Category__c = 'Sleepwear - Adult';
        test.startTest();
        update CntMappingObj;
        test.stopTest();
    }
    
    @IsTest
    static void test_updateLicenseeContactMappingRecContactType(){
        CP_Licensee_Contact_Mapping__c CntMappingObj = [SELECT Id, Contact_Type__c FROM CP_Licensee_Contact_Mapping__c LIMIT 1];
        CntMappingObj.Contact_Type__c = 'Ops';
        test.startTest();
        update CntMappingObj;
        test.stopTest();
    }
}