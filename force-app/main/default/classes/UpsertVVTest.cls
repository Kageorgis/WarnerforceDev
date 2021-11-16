/*****************************************************************************
 * Class Name:      UpsertVVTest
 * Description:     Test Class for UpsertVV Web Service
 *
 * Author:          Date:          Description
 * Andrew Hilsher   11/19/2014      First Draft
 * Ishwar Kabra     19/12/2014      Second Draft  
 *****************************************************************************/
@isTest
public class UpsertVVTest
{
    static testMethod void testUpsertVV()
    {
        Test.startTest();
        Country__c country = TestUtil.createCountry('India', 'IN', 'IND');
        insert country;
        Language__c lang = TestUtil.createLanguage('English', 'en',1);
        insert lang;
        Title__c title = TestUtil.createTitle('Harry Potter', '123456789');
        insert title;
        
        Locale_Map__c testLocale = new Locale_Map__c();
        testLocale.Name = 'en_IL';
        testLocale.Country_Code__c = 'IL';
        testLocale.Language_Code__c = 'en';
        insert testLocale;
        
        UpsertVV.LocalTitleDetails localTitle = new UpsertVV.LocalTitleDetails();
        localTitle.IntegrationID = '1111111';
        localTitle.Local_Rating_Comment = 'test commetn';
        localTitle.Video_Version = '123456789';
        localTitle.Country = 'India';
        localTitle.Language = 'English';
        localTitle.Locale = 'en_IL';
        localTitle.Local_Title_Name = 'Mogli';
        localTitle.Local_Rating_System = 'ABCD';
        localTitle.Local_Rating = 'GOOD';
        localTitle.Local_Synopsis = 'Test';
        localTitle.Local_DVD_Release_Date = '2014-02-15';
        localTitle.Status = 'Active';
        //ER-547
        localTitle.TV_Title = 'test title';
        localTitle.Local_TV_Air_Date = '2014-02-01';
        localTitle.Local_Season = 'test season';
        localTitle.Local_Episodes = '12';
        //ER-547
        list<UpsertVV.LocalTitleDetails> ltList = new list<UpsertVV.LocalTitleDetails>();
        ltList.add(localTitle);
        
        List<UpsertVV.ResponseMessage> responseList = UpsertVV.createVV(ltList);
        System.assertEquals(responseList[0].Message_Result, false);
    }
    static testMethod void testUpsertVV1()
    {
        Test.startTest();
        Country__c country = TestUtil.createCountry('India', 'IN', 'IND');
        insert country;
        Language__c lang = TestUtil.createLanguage('English', 'EN',1);
        insert lang;
        Title__c title = TestUtil.createTitle('Harry Potter', '123456789');
        insert title;
        
        Locale_Map__c testLocale = new Locale_Map__c();
        testLocale.Name = 'en_IL';
        testLocale.Country_Code__c = 'IL';
        testLocale.Language_Code__c = 'en';
        insert testLocale;
        
        UpsertVV.LocalTitleDetails localTitle = new UpsertVV.LocalTitleDetails();
        localTitle.IntegrationID = '1111111';
        localTitle.Local_Rating_Comment = 'test commetn';
        localTitle.Video_Version = '123456789';
        localTitle.Country = 'India';
        localTitle.Language = 'English';
        localTitle.Locale = 'en_IL';
        localTitle.Local_Title_Name = '';
        localTitle.Local_Rating_System = 'ABCD';
        localTitle.Local_Rating = 'GOOD';
        localTitle.Local_Synopsis = 'Test';
        localTitle.Local_DVD_Release_Date = '2014-02-15';
        localTitle.Status = 'Active';
        
        list<UpsertVV.LocalTitleDetails> ltList = new list<UpsertVV.LocalTitleDetails>();
        ltList.add(localTitle);
        
        List<UpsertVV.ResponseMessage> responseList = UpsertVV.createVV(ltList);
        System.assertEquals(responseList[0].Message_Result, false);
    }
    
    static testMethod void testUpsertVV2()
    {
        Test.startTest();
        Country__c country = TestUtil.createCountry('India', 'CA', 'IND');
        insert country;
        Language__c lang = TestUtil.createLanguage('English', 'fr',1);
        insert lang;
        Title__c title = TestUtil.createTitle('Harry Potter', '123456789');
        insert title;
        
        UpsertVV.LocalTitleDetails localTitle = new UpsertVV.LocalTitleDetails();
        localTitle.IntegrationID = '1111111';
        localTitle.Local_Rating_Comment = 'test commetn';
        localTitle.Video_Version = '123456789';
        localTitle.Country = 'India';
        localTitle.Language = 'English';
        localTitle.Locale = 'fr_CA';
        localTitle.Local_Title_Name = '';
        localTitle.Local_Rating_System = 'ABCD';
        localTitle.Local_Rating = 'GOOD';
        localTitle.Local_Synopsis = 'Test';
        localTitle.Local_DVD_Release_Date = '2014-02-15';
        localTitle.Status = 'Active';
        
        list<UpsertVV.LocalTitleDetails> ltList = new list<UpsertVV.LocalTitleDetails>();
        ltList.add(localTitle);
        
        List<UpsertVV.ResponseMessage> responseList = UpsertVV.createVV(ltList);
        System.assertEquals(responseList[0].Message_Result, true);
            
    }
    
    static testMethod void testUpsertVV3()
    {
        Test.startTest();
        Country__c country = TestUtil.createCountry('India', 'BR', 'IND');
        insert country;
        Language__c lang = TestUtil.createLanguage('English', 'pt',1);
        insert lang;
        Title__c title = TestUtil.createTitle('Harry Potter', '123456789');
        insert title;
        
        UpsertVV.LocalTitleDetails localTitle = new UpsertVV.LocalTitleDetails();
        localTitle.IntegrationID = '1111111';
        localTitle.Local_Rating_Comment = 'test commetn';
        localTitle.Video_Version = '123456789';
        localTitle.Country = 'India';
        localTitle.Language = 'English';
        localTitle.Locale = 'pt_BR';
        localTitle.Local_Title_Name = '';
        localTitle.Local_Rating_System = 'ABCD';
        localTitle.Local_Rating = 'GOOD';
        localTitle.Local_Synopsis = 'Test';
        localTitle.Local_DVD_Release_Date = '2014-02-15';
        localTitle.Status = 'Active';
        
        list<UpsertVV.LocalTitleDetails> ltList = new list<UpsertVV.LocalTitleDetails>();
        ltList.add(localTitle);
        
        List<UpsertVV.ResponseMessage> responseList = UpsertVV.createVV(ltList);
        System.assertEquals(responseList[0].Message_Result, true);
            
    }
    
    static testMethod void testUpsertVV4()
    {
        Test.startTest();
        Country__c country = TestUtil.createCountry('India', 'ES', 'IND');
        insert country;
        Language__c lang = TestUtil.createLanguage('English', 'ce',1);
        insert lang;
        Title__c title = TestUtil.createTitle('Harry Potter', '123456789');
        insert title;
        
        UpsertVV.LocalTitleDetails localTitle = new UpsertVV.LocalTitleDetails();
        localTitle.IntegrationID = '1111111';
        localTitle.Local_Rating_Comment = 'test commetn';
        localTitle.Video_Version = '123456789';
        localTitle.Country = 'Spain';
        localTitle.Language = 'Spanish';
        localTitle.Locale = 'ce_ES';
        localTitle.Local_Title_Name = '';
        localTitle.Local_Rating_System = 'ABCD';
        localTitle.Local_Rating = 'GOOD';
        localTitle.Local_Synopsis = 'Test';
        localTitle.Local_DVD_Release_Date = '2014-02-15';
        localTitle.Status = 'Active';
        
        list<UpsertVV.LocalTitleDetails> ltList = new list<UpsertVV.LocalTitleDetails>();
        ltList.add(localTitle);
        
        List<UpsertVV.ResponseMessage> responseList = UpsertVV.createVV(ltList);
        System.assertEquals(responseList[0].Message_Result, true);
            
    }
    
    static testMethod void testUpsertVV_WithoutVVLocale()
    {
        Test.startTest();
        Country__c country = TestUtil.createCountry('India', 'IN', 'IND');
        insert country;
        Language__c lang = TestUtil.createLanguage('English', 'EN',1);
        insert lang;
        Title__c title = TestUtil.createTitle('Harry Potter', '123456789');
        insert title;
        
        Locale_Map__c testLocale = new Locale_Map__c();
        testLocale.Name = 'en_IL';
        testLocale.Country_Code__c = 'IL';
        testLocale.Language_Code__c = 'en';
        insert testLocale;
        
        
        UpsertVV.LocalTitleDetails localTitle = new UpsertVV.LocalTitleDetails();
        localTitle.IntegrationID = '1111111';
        localTitle.Local_Rating_Comment = 'test commetn';
        //localTitle.Video_Version = '123456789';
        localTitle.Country = 'India';
        localTitle.Language = 'English';
        localTitle.Locale = 'en_IL';
        localTitle.Local_Title_Name = 'Mogli';
        localTitle.Local_Rating_System = 'ABCD';
        localTitle.Local_Rating = 'GOOD';
        localTitle.Local_Synopsis = 'Test';
        localTitle.Local_DVD_Release_Date = '2014-02-15';
        localTitle.Status = 'Active';
        
        list<UpsertVV.LocalTitleDetails> ltList = new list<UpsertVV.LocalTitleDetails>();
        ltList.add(localTitle);
        
        List<UpsertVV.ResponseMessage> responseList = UpsertVV.createVV(ltList);
        System.assertEquals(responseList[0].Message_Result, false);
    }
}