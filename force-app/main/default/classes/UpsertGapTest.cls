/*****************************************************************************
 * Class Name:      UpsertGapTest
 * Description:     Test Class for UpsertGap Web Service
 *
 * Author:          Date:          Description
 * Andrew Hilsher   11/19/2014      First Draft 
 * Ishwar           12/09/2014
 *****************************************************************************/
@isTest(seeAllData=false)
public class UpsertGapTest
{
    @isTest
    static void testUpsertVV2()
    {
        Test.startTest();
        
        List<Locale_Map__c> localeList = Locale_Map__c.getAll().values();
        delete localeList;
        
        Country__c country = TestUtil.createCountry('Canada', 'CA', 'CAN');
        insert country;
        Language__c lang = TestUtil.createLanguage('French', 'fr',1);
        insert lang;
        Title__c title = TestUtil.createTitle('Harry Potter', '123456789');
        insert title;
        
        UpsertGap.LocalTitleDetails localTitle = new UpsertGap.LocalTitleDetails();
        localTitle.IntegrationID = '1111111';
        localTitle.Local_Rating_Comment = 'test commetn';
        localTitle.Video_Version = '123456789';
        localTitle.Country = 'Canada';
        localTitle.Language = 'French';
        localTitle.Locale = 'fr_CA';
        localTitle.Local_Title_Name = '';
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
        
        list<UpsertGap.LocalTitleDetails> ltList = new list<UpsertGap.LocalTitleDetails>();
        ltList.add(localTitle);
        
        List<UpsertGap.ResponseMessage> responseList = UpsertGap.createGap(ltList);
        System.assertEquals(responseList[0].Message_Result, true);
    }
    
    //Brazil
    @isTest
    static void testUpsertVV3()
    {
        Test.startTest();
        
        List<Locale_Map__c> localeList = Locale_Map__c.getAll().values();
        delete localeList;
        
        Country__c country = TestUtil.createCountry('Brazil', 'BR', 'BRZ');
        insert country;
        Language__c lang = TestUtil.createLanguage('Portuguse', 'pt',1);
        insert lang;
        Title__c title = TestUtil.createTitle('Harry Potter', '123456789');
        insert title;
        
        UpsertGap.LocalTitleDetails localTitle = new UpsertGap.LocalTitleDetails();
        localTitle.IntegrationID = '1111111';
        localTitle.Local_Rating_Comment = 'test commetn';
        localTitle.Video_Version = '123456789';
        localTitle.Country = 'Brazil';
        localTitle.Language = 'Portuguse';
        localTitle.Locale = 'pt_BR';
        localTitle.Local_Title_Name = '';
        localTitle.Local_Rating_System = 'ABCD';
        localTitle.Local_Rating = 'GOOD';
        localTitle.Local_Synopsis = 'Test';
        localTitle.Local_DVD_Release_Date = '2014-02-15';
        localTitle.Status = 'Active';
        
        list<UpsertGap.LocalTitleDetails> ltList = new list<UpsertGap.LocalTitleDetails>();
        ltList.add(localTitle);
        
        List<UpsertGap.ResponseMessage> responseList = UpsertGap.createGap(ltList);
        System.assertEquals(responseList[0].Message_Result, true);
    }
    
    //Spain
    //Brazil
    @isTest
    static void testUpsertVV4()
    {
        Test.startTest();
        
        List<Locale_Map__c> localeList = Locale_Map__c.getAll().values();
        delete localeList;
        
        Country__c country = TestUtil.createCountry('Spain', 'AR', 'ESP');
        insert country;
        Language__c lang = TestUtil.createLanguage('Spanish', 'es',1);
        insert lang;
        Title__c title = TestUtil.createTitle('Harry Potter', '123456789');
        insert title;
        
        UpsertGap.LocalTitleDetails localTitle = new UpsertGap.LocalTitleDetails();
        localTitle.IntegrationID = '1111111';
        localTitle.Local_Rating_Comment = 'test commetn';
        localTitle.Video_Version = '123456789';
        localTitle.Country = 'Brazil';
        localTitle.Language = 'Portuguse';
        localTitle.Locale = 'es_AR';
        localTitle.Local_Title_Name = '';
        localTitle.Local_Rating_System = 'ABCD';
        localTitle.Local_Rating = 'GOOD';
        localTitle.Local_Synopsis = 'Test';
        localTitle.Local_DVD_Release_Date = '2014-02-15';
        localTitle.Status = 'Active';
        
        list<UpsertGap.LocalTitleDetails> ltList = new list<UpsertGap.LocalTitleDetails>();
        ltList.add(localTitle);
        
        List<UpsertGap.ResponseMessage> responseList = UpsertGap.createGap(ltList);
        System.assertEquals(responseList[0].Message_Result, true);
    }
    
   
   @isTest(seeAllData=true)
   //Create new Local Title
    static void testUpsertGap_insert()
    {
        Test.startTest();
        //Country__c country = TestUtil.createCountry('India', 'IN', 'IND');
        //insert country;
        Country__c country = [Select Name, Id From Country__c where Name = 'USA'];
        
        //Language__c lang = TestUtil.createLanguage('English', 'EN',1);
        //insert lang;
        Language__c lang = [Select Name, Language_Code_3__c, Language_Code_2__c, Id, IPM_Language_Code__c, EMA_Store_Language__c From Language__c where Name = 'English'];
        
        //Gap_Locale__c gapLocale = TestUtil.createGapLocale('en_IN', 'en_US');
        //insert gapLocale;
        GAP_Locale__c gapLocale = [Select Parent_Locale__c, Name, Locale__c, Id, GAP_Locale__c From GAP_Locale__c where Locale__c = 'en_US'];
        
        Title__c titleRec = TestUtil.createTitle('Test1234', '6085689322');
        insert titleRec;
        
        UpsertGap.LocalTitleDetails newtitle = new UpsertGap.LocalTitleDetails();
        newtitle.Local_Title_Name = 'Horrible Bosses 2';
        newtitle.Video_Version = '6000086854';
        newtitle.Locale = 'en_ph';
        newtitle.Local_Rating_System = 'ph-movies';
        newtitle.Local_Rating = 'UR, Unrated';
        newtitle.Local_Synopsis = 'TestSynopsis';
        newtitle.Local_DVD_Release_Date = ''+System.today();
        newtitle.Title_Name=titleRec.id;
        
        list<UpsertGap.LocalTitleDetails> titleList = new list<UpsertGap.LocalTitleDetails>();
        titleList.add(newTitle);
        
        List<Local_Title__c> lstLT = [Select Id, /*Version_EIDR__c,*/ Title_VV_F__c, Name, Local_Title__c, Language__c, Key__c, Country__c
                                        From Local_Title__c where Id = 'a0KU000000JMu3s'
        ];
        system.debug('==============1: ' + lstLT);
        if(lstLT.size() > 0){
            //system.debug('==============2: ' + lstLT[0].Version_EIDR__c);
        }
        
        List<UpsertGap.ResponseMessage> responseList = UpsertGap.createGap(titleList);
        System.assertEquals(responseList[0].Message_Result, false);
        
        Test.stopTest();
    }
    
    @isTest(seeAllData=true)
    //Create new Local title when Title name and Local Title Name is missing
    static void testUpsertGap_InsertWithoutLocalTitleandTitle()
    {
        Test.startTest();
        //Country__c country = TestUtil.createCountry('India', 'IN', 'IND');
        //insert country;
        Country__c country = [Select Name, Id From Country__c where Name = 'USA'];
        
        //Language__c lang = TestUtil.createLanguage('English', 'EN',1);
        //insert lang;
        Language__c lang = [Select Name, Language_Code_3__c, Language_Code_2__c, Id, IPM_Language_Code__c, EMA_Store_Language__c From Language__c where Name = 'English'];
        
        //Gap_Locale__c gapLocale = TestUtil.createGapLocale('en_IN', 'en_US');
        //insert gapLocale;
        GAP_Locale__c gapLocale = [Select Parent_Locale__c, Name, Locale__c, Id, GAP_Locale__c From GAP_Locale__c where Locale__c = 'en_US'];
        
        Title__c titleRec = TestUtil.createTitle('Test1234', '6085689322');
        insert titleRec;
        
        UpsertGap.LocalTitleDetails newtitle = new UpsertGap.LocalTitleDetails();
        newtitle.Local_Title_Name = null;
        newtitle.Video_Version = '6000086853';
        newtitle.Locale = 'en_ph';
        newtitle.Local_Rating_System = 'ph-movies';
        newtitle.Local_Rating = 'UR, Unrated';
        newtitle.Local_Synopsis = 'TestSynopsis';
        newtitle.Local_DVD_Release_Date = ''+System.today();
        newtitle.Title_Name=null;
        
        list<UpsertGap.LocalTitleDetails> titleList = new list<UpsertGap.LocalTitleDetails>();
        titleList.add(newTitle);
        
        List<Local_Title__c> lstLT = [Select Id, /*Version_EIDR__c,*/ Title__c,Title_VV_F__c, Name, Local_Title__c, Language__c, Key__c, Country__c
                                        From Local_Title__c where Id = 'a0KU000000JMu3s'
        ];
        system.debug('==============1: ' + lstLT);
        if(lstLT.size() > 0){
            //system.debug('==============2: ' + lstLT[0].Version_EIDR__c);
        }
        
        try{
            List<UpsertGap.ResponseMessage> responseList = UpsertGap.createGap(titleList);
            System.assertEquals(responseList[0].Message_Result, true);
        }
        catch(Exception ex){
            system.debug('The following exception occurs : ' +ex.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest(seeAllData=true)
    //Update Local Title    
    static void testUpsertGap_update()
    {
        Test.startTest();
        //insert country
        Country__c country = [Select Name, Id From Country__c where Name = 'USA'];
        //insert lang;
        Language__c lang = [Select Name, Language_Code_3__c, Language_Code_2__c, Id, IPM_Language_Code__c, EMA_Store_Language__c From Language__c where Name = 'English'];
        //insert gapLocale;
        GAP_Locale__c gapLocale = [Select Parent_Locale__c, Name, Locale__c, Id, GAP_Locale__c From GAP_Locale__c where Locale__c = 'en_US'];
        
        Title__c title = TestUtil.createTitle('Harry Potter', '12345678900');
        insert title;
        Local_Title__c localData = TestUtil.createLocalData('12345678900', country, lang, gapLocale.Parent_Locale__c, title.Id);
        localData.ALID__c = 'abcd:efgh:ijkl:mnop';
        localdata.CID__c = 'abcd:efgh:ijkl:mnop';
        localData.Price_Code__c = 'USD';
        localData.Local_TV_Air_Date__c = Date.today();
        localData.Local_Theatrical_Release_Date__c = Date.today();
        localData.Caption_Exclusion_Reason__c = 'test';
        localData.Caption_Included_picklist__c = 'YES';
        localData.Caption_Required__c = 'YES';
        localData.Category__c = 'Undefined';
        localData.Local_BD_Release_Date__c = Date.today();
        localData.Local_Box_Office__c = 100;
        localData.Local_Episodes__c = 1;
        localData.Num_Local_Episodes__c = 12;
        localData.Local_Label__c = 'test';
        localData.Local_Licensor__c = 'test';
        localData.Local_Pay_TV_Start_Date__c = Date.today();
        localData.Local_Run_Time__c = 30;
        localData.Local_Season__c = 'test';
        localData.Readiness__c = 'Complete';
        //localData.Territory__c = 'USA';
        localData.UV_Published_Date__c = Date.today();
        //localData.Version_EIDR__c = 'bcd:efgh:ijk';
        insert localData;
                
        UpsertGap.LocalTitleDetails newtitle = new UpsertGap.LocalTitleDetails();
        newtitle.Local_Title_Name = 'Test Harry Potter';
        newtitle.Video_Version = '12345678900';
        newtitle.Locale = gapLocale.Locale__c;
        newtitle.Local_Rating_System = 'TestSystem';
        newtitle.Local_Rating = 'UA';
        newtitle.Local_Synopsis = 'TestSynopsis';
        newtitle.Local_DVD_Release_Date = ''+System.today();
        newTitle.Status = 'Active';
        
        list<UpsertGap.LocalTitleDetails> titleList = new list<UpsertGap.LocalTitleDetails>();
        titleList.add(newTitle);

        List<UpsertGap.ResponseMessage> responseList = UpsertGap.createGap(titleList);
        System.assertEquals(responseList[0].Message_Result, true);
        Test.stopTest();
    }
    @isTest(seeAllData=true)
    //Video Version missing
    static void testUpsertGap_withoutVVLocale() 
    {
        Test.startTest();
        //insert country
        Country__c country = [Select Name, Id From Country__c where Name = 'USA'];
        //insert language
        Language__c lang = [Select Name, Language_Code_3__c, Language_Code_2__c, Id, IPM_Language_Code__c, EMA_Store_Language__c From Language__c where Name = 'English'];
       //insert gapLocale;
        GAP_Locale__c gapLocale = [Select Parent_Locale__c, Name, Locale__c, Id, GAP_Locale__c From GAP_Locale__c where Locale__c = 'en_US'];
        
        UpsertGap.LocalTitleDetails newtitle = new UpsertGap.LocalTitleDetails();
        newtitle.Local_Title_Name = 'Test Harry Potter';
        //newtitle.Video_Version = '123456';
        //newtitle.Locale = gapLocale.Locale__c;
        newtitle.Local_Rating_System = 'TestSystem';
        newtitle.Local_Rating = 'UA';
        newtitle.Local_Synopsis = 'TestSynopsis';
        newtitle.Local_DVD_Release_Date = ''+System.today();
        
        list<UpsertGap.LocalTitleDetails> titleList = new list<UpsertGap.LocalTitleDetails>();
        titleList.add(newTitle);
        List<UpsertGap.ResponseMessage> responseList = UpsertGap.createGap(titleList);
        System.assertEquals(responseList[0].Message_Result, false);
        Test.stopTest();
    }
    
    //Akash Start
     @isTest
     static void testMapDataValues()
    {
        Test.startTest();
        
        Country__c country = TestUtil.initCountry('USA','US','USA');
        insert country;
        Language__c lang = TestUtil.initLanguage('English','en',1);
        insert lang;
        GAP_Locale__c gapLocale = TestUtil.createGapLocale('en_EG','en_US');
        insert gapLocale;
        Title__c title = TestUtil.createTitle('Harry Potter', '12345678900');
        insert title;
        
        Local_Title__c localData = TestUtil.createLocalData('12345678900', country, lang, gapLocale.Parent_Locale__c, title.Id);
        localData.ALID__c = 'abcd:efgh:ijkl:mnop';
        localdata.status__c = 'Active';
        localdata.Title__c = title.id;
        localdata.CID__c = 'abcd:efgh:ijkl:mnop';
        localData.Price_Code__c = 'USD';
        localData.Local_TV_Air_Date__c = Date.today();
        localData.Local_Theatrical_Release_Date__c = Date.today();
        localData.Caption_Exclusion_Reason__c = 'test';
        localData.Caption_Included_picklist__c = 'YES';
        localData.Caption_Required__c = 'YES';
        localData.Category__c = 'Undefined';
        localData.Local_BD_Release_Date__c = Date.today();
        localData.Local_Box_Office__c = 100;
        localData.Local_Episodes__c = 1;
        localData.Num_Local_Episodes__c = 12;
        localData.Local_Label__c = 'test';
        localData.Local_Licensor__c = 'test';
        localData.Local_Pay_TV_Start_Date__c = Date.today();
        localData.Local_Run_Time__c = 30;
        localData.Local_Season__c = 'test';
        localData.Readiness__c = 'Complete';
        //localData.Territory__c = 'USA';
        localData.UV_Published_Date__c = Date.today();
        //localData.Version_EIDR__c = 'bcd:efgh:ijk';
        localData.Local_Title__c = 'Harry Potter Series';
        localData.Local_Rating_System__c = 'ph-movies';
        localData.Rating_Reason__c = 'Hollywood';
        localData.Local_Rating__c = 'R-16';
        localData.Local_Synopsis__c = 'Fed up with answering to higher-ups, Nick, Dale and Kurt decide to become their own bosses by launching their own business in “Horrible Bosses 2.” But a slick investor soon pulls the rug out from under them';
        localData.TV_Title__c = 'Tv Title';
        //localData.Key__c = '000086853_en_US';
        localData.Country__c = country.Id;
        localData.Language__c = lang.Id;
        insert localData;
        
        system.debug('Test class local data rec key --->' +localData.Key__c);
        
        UpsertGap.LocalTitleDetails newtitle = new UpsertGap.LocalTitleDetails();
        newtitle.Local_Title_Name = 'Test Harry Potter';
        newtitle.Video_Version = '12345678900';
        newtitle.Locale = gapLocale.Locale__c;
        newtitle.Local_Rating_System = 'TestSystem';
        newtitle.Local_Rating = 'UA';
        newtitle.Local_Synopsis = 'TestSynopsis';
        newtitle.Local_DVD_Release_Date = ''+System.today();
        newTitle.Status = 'Active';
        newTitle.Local_Rating_Comment = 'testComment';
        newTitle.Country = country.Id;
        newTitle.Language = lang.Id;
        newTitle.TV_Title = 'Tv title';
        newTitle.Local_TV_Air_Date = '2017-05-31T21:36:44.000Z';
        newTitle.Local_Season = 'TestSeason';
        //newTitle.Local_Episodes = 14;
        list<UpsertGap.LocalTitleDetails> titleList = new list<UpsertGap.LocalTitleDetails>();
        titleList.add(newTitle);

        List<UpsertGap.ResponseMessage> responseList = UpsertGap.createGap(titleList);
        System.assertEquals(responseList[0].Message_Result, false);
        Test.stopTest();
    }
    //Akash Finish

}