/******************************************************************************************
Class Name      : CPProductApexSharingHandlerTest
Creation Date   : 18 May 2021
Description     : This is Test class for CPProductApexSharingHandler
Author          : Aaditya Raj(Cognizant)
******************************************************************************************/
@isTest(SeeAllData=false)
public class CPProductApexSharingHandlerTest {
    
    @isTest
    private static void shareCPRecordsTest()
    {
        UserRole userRole = new UserRole(DeveloperName = 'MyTestRole', Name = 'WBCP Local Regional Role');
        insert userRole;
        
        Profile userProfile = [select id from profile where name='System Administrator'];
        Profile userProfile1 = [select id from profile where name=: CP_ProductUtility.WBCP_ADMIN_LICENSEE_PROFILE];
        
        Country__c country1 = TestUtil.initCountry('USA', 'US', 'USA');
        country1.Territory__c = 'USA';
        
        User loginUser = new User(ProfileId = userProfile.Id, Username = 'testloginUser@wbcp.com', Email = 'testloginUser@wbcp.dev',
                                  EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', 
                                  TimeZoneSidKey = 'America/Los_Angeles', Alias = 'tuser', LastName = 'LastLoginTest', Country = 'United States');
        
        User testUser1 = new User(ProfileId = userProfile1.Id, Username = 'testUser@wbcp.com', Email = 'testUser@wbcp.dev',
                                  EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', 
                                  TimeZoneSidKey = 'America/Los_Angeles', Alias = 'tuser', LastName = 'LastTest',
                                  UserRoleId = userRole.Id, WBCP_Access_Role__c = 'Local', Country = 'United States');
        
        User testUser2 = new User(ProfileId = userProfile1.Id, Username = 'testUser@wbcp2.com', Email = 'testUser2@wbcp.dev',
                                  EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', 
                                  TimeZoneSidKey = 'America/Los_Angeles', Alias = 'tuser2', LastName = 'LastTest2',
                                  UserRoleId = userRole.Id, WBCP_Access_Role__c = 'Global', Country = 'United States');
        
        User testUser3 = new User(ProfileId = userProfile1.Id, Username = 'testUser@wbcp3.com', Email = 'testUser3@wbcp.dev',
                                  EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', 
                                  TimeZoneSidKey = 'America/Los_Angeles', Alias = 'tuser3', LastName = 'LastTest3',
                                  UserRoleId = userRole.Id, WBCP_Access_Role__c = 'Regional', Country = 'United States');
        
        List<User> userList = new List<User>();
        userList.add(testUser1);
        userList.add(testUser2);
        userList.add(testUser3);
        userList.add(loginUser);
        insert userList;
        System.runAs(loginUser)
        {
            Id licRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId();
            Id retRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Retailer').getRecordTypeId();
            
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
          
            Account licenceeAcc = new Account(Name ='Mattel',RecordTypeId =licRecTypeid, cp_Licensee_Code__c = '0001011318');
            insert licenceeAcc;
            
            Account licenceeAccount = new Account(Name ='Bioworld',RecordTypeId =licRecTypeid, cp_Licensee_Code__c = '0001032499');
            insert licenceeAccount;
            
            Account retailerAcc = new Account(Name ='testretailAcc',RecordTypeId =retRecTypeid);
            insert retailerAcc;
            
            Contact licenceeCon = new Contact(AccountId=licenceeAccount.Id,LastName='test Lastname1',CP_Territory__c='United States');
            licenceeCon.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('WBCP Licensee Contact').getRecordTypeId();
            insert licenceeCon;
            
            WBCP_Country__c countryRecord = new WBCP_Country__c(Name ='United States', Territory__c = 'United States', Country_Code__c='US', 
                                                                Allocated_Territory_Name__c='US');
            insert countryRecord;
            
            Property__c propRec = new Property__c(Name ='Justice League Core',cp_Property_Code__c ='000927');
            insert propRec;
            
            Property__c propObj = new Property__c(Name ='Batman Core',cp_Property_Code__c ='000046');
            insert propObj;
            
            Datetime uploadDate = System.now()+1;
            
            CP_Product__c cpprodRec1 = new CP_Product__c(Licensee__c=licenceeAcc.Id, WBCP_Country__c =countryRecord.Id,GTIN__c ='024054817896',
                                                         MPN__c = '8875823', cp_Retailer_Description__c = retailerAcc.Id, Retailer_SKU__c='567021036',
                                                         cp_Licensed_Property__c = propRec.Id,Item_Descrption__c='Test CP ProdRec1',Size__c = '8',
                                                         UPC_Upload_Date__c = uploadDate, Sub_Category__c='Vehicles / Remote Control');
            
            
            List<CP_Product__c> cpRpodList = new List<CP_Product__c>();
           
            cpRpodList.add(cpprodRec1);
            
            Test.startTest();
            List<User> userListData = new List<User>();
            userListData = [SELECT Id,User_License_Type__c,WBCP_Access_Role__c,UserRoleId,UserRole.Name, Country FROM User WHERE User_License_Type__c =: 'Salesforce Platform' AND isActive = True];
            system.debug(LoggingLevel.INFO,userListData);
            insert cpRpodList;
            CPProductApexSharingHandler.shareCPRecords(cpRpodList,userList,CP_ProductUtility.WBCP_BATCH);
            CPProductApexSharingHandler.shareCPRecords(cpRpodList,userList,CP_ProductUtility.WBCP_TRIGGER);
           
            List<CP_Product__Share> cpshare = new List<CP_Product__Share>([Select Id,ParentId from CP_Product__Share]);
            
            System.assertEquals(cpprodRec1.Id, cpshare[0].ParentId);
            Test.stopTest();
        }
        
    }
}