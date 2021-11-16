/*
Class Name   : WB_LocalTitleTriggerHandler_Test 
Description  : This class is to do code coverage for WB_LocalTitleTriggerHandler class    
Created By   : Cognizant Technology Solutions - Akash
Created On   : MARCH 2016

Change History:
-------------------------------------------------------------------------------------------------------------------------------------
Sr#              Description                                               Updated By                                     Updated On
-------------------------------------------------------------------------------------------------------------------------------------
1              [Change Type]                                 Cognizant Technology Solutions - [Developer Name]           [MM/DD/YYYY]

CH01   Added Assertion statements for the required business             Akash Dalvi                                        4/28/2016
       scenarios.                        
CH02   Values for new fields for ER-1305                            Astha Singh                                            15/01/2018
*/

@isTest
public class WB_LocalTitleTriggerHandler_Test {
    
    
     public static List<Local_Title__c> listlocaltitles;
     static List<Pricing__c> lPricing = new List<Pricing__c>();
     
    
    @isTest
     static void TestOnInsert(){
        
        Language__c languageFrench1 = new Language__c(Name='TestFrench1',Language_Order__c = 1);
        insert languageFrench1;
        
        Ratings__c csetting = new Ratings__c();
        csetting.name='cs1';
        csetting.Rating_System__c= 'ao-movies';
        csetting.Language__c=languageFrench1.id;
        csetting.Long_Local_Rating__c= 'M12';
        csetting.Short_Local_Rating__c= 'M12';
        insert csetting;        

        Account acct = TestUtil.initAccount();
        insert acct;        

        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        
        list<Country__c> countryList = new list<Country__c>();
        
        Country__c countryUSA =new Country__c(Name ='USA',Country_Code2__c ='US',Country_Code__c='USA',Default_Feature_Rating_Systems__c='ao-movies');
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='778',Country_Code__c='F88',Default_Feature_Rating_Systems__c='ao-movies');
        
        countryList.add(countryUSA);
        countryList.add(countryFrance);
        insert countryList;
        
        Language__c languageEnglish = new Language__c(Name='English',Language_Order__c = 1);
        insert languageEnglish;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;

        list<title__c> titleList = new list<title__c>();
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',MPM__c=mpm.id,Video_Version__c ='555555',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,
        US_BD_Release_Date__c=date.today()-3,US_TV_Air_Date__c=date.today()-3,US_UV_Publish_Date__c=date.today()-3,US_Box_Office__c=1111.00,US_DVD_Release_Date__c=date.today()-3,
        US_Pay_TV_Start_Date__c = date.today()-3,Formats__c ='SD');
        titleList.add( title1);
        
        Title__c title2 = new Title__c(Name = 'TestApple',MPM__c=mpm.id,Video_Version__c ='555666',Content_Type__c='Episode',Physical_Planning__c='YES',Digital_Planning__c='YES',Clear_to_Avail__c = true,
        US_BD_Release_Date__c=date.today()-3,US_TV_Air_Date__c=date.today()-3,US_UV_Publish_Date__c=date.today()-3,US_Box_Office__c=1111.00,US_DVD_Release_Date__c=date.today()-3,
        US_Pay_TV_Start_Date__c = date.today()-3,Formats__c ='BD');
        titleList.add( title2);
        
        insert titleList;
        
        list<Local_Title__c> localTitleList = new list<Local_Title__c>();
        
        Local_Title__c localtitle = new Local_Title__c(Name='test Local Title',Title__c = title1.Id, Country__c = countryUSA.Id, Language__c = languageEnglish.Id,
        Local_BD_Release_Date__c=date.today(),Local_TV_Air_Date__c=date.today(),UV_Published_Date__c=date.today(),Local_Box_Office__c=1245.00,
        Local_DVD_Release_Date__c=date.today(),Local_Pay_TV_Start_Date__c=date.today(),Local_Theatrical_Release_Date__c=date.today(),
        Digital_Rating_System__c='ao-movies',Digital_Rating_Short__c='M12',
        Physical_Rating_Short__c='M12',Physical_Rating_System__c='ao-movies',Local_Rating_System__c='ao-movies',Local_Rating__c='M12');
        
        localTitleList.add(localtitle);
        
        Local_Title__c localtitle1 = new Local_Title__c(Name='testCTS Local Title',Title__c = title2.Id, Country__c = countryFrance.Id, Language__c = languageFrench.Id,
        Local_BD_Release_Date__c=date.today()+1,Local_TV_Air_Date__c=date.today(),UV_Published_Date__c=date.today(),Local_Box_Office__c=1300.00,
        Local_DVD_Release_Date__c=date.today()+1,Local_Pay_TV_Start_Date__c=date.today(),Digital_Rating_System__c='ao-movies',Digital_Rating_Short__c='M12',
        Physical_Rating_Short__c='M12',Physical_Rating_System__c='ao-movies',Local_Rating_System__c='ao-movies',Local_Rating__c='M12');
        
        localTitleList.add(localtitle1);
        
        insert localTitleList;
        
        system.debug('***Printing Local title list***' +localTitleList);
        
        Map<Id,Local_Title__c> OldLocMap = new Map<Id,Local_Title__c>();
        
        test.startTest();
        
            list<Local_Title__c> listLocalTitle = [select id,Name,Title__c,Country__c,Language__c,Local_BD_Release_Date__c,Local_TV_Air_Date__c,
            UV_Published_Date__c,Local_Box_Office__c,Local_DVD_Release_Date__c,Local_Pay_TV_Start_Date__c from Local_Title__c where id =: localtitle.id];
            
            system.debug('###Printing Local title list***' +listLocalTitle);
            
            OldLocMap.put(localtitle.id, localtitle);
            OldLocMap.put(localtitle1.id, localtitle1);
            
            system.debug('###Printing OldLocMap###' +OldLocMap);
            //system.assertEquals(OldLocMap.size(), 2);
            
            localtitle.Local_TV_Air_Date__c = date.today()+1;
            update localtitle;
            //system.assertEquals(localtitle.Local_TV_Air_Date__c,date.today()+1);
            
            list<Local_Title__c> listLocalTitleUpdated = [select id,Name,Title__c,Country__c,Language__c,Local_BD_Release_Date__c,Local_TV_Air_Date__c,UV_Published_Date__c,Local_Box_Office__c,
            Local_DVD_Release_Date__c,Local_Pay_TV_Start_Date__c from Local_Title__c where id =: localtitle.id];
            
            system.debug('<---Updated Local title list--->' +listLocalTitleUpdated);
            //system.assertEquals(listLocalTitleUpdated.size(),1);
        
        test.stopTest();
    }
     @isTest
     static void TestOnUpdate(){
         
         Language__c languageFrench1 = new Language__c(Name='TestFrench1',Language_Order__c = 1);
        insert languageFrench1;
        
        Ratings__c csetting = new Ratings__c();
        csetting.name='cs1';
        csetting.Rating_System__c= 'ao-movies';
        csetting.Language__c=languageFrench1.id;
        csetting.Long_Local_Rating__c= 'M12';
        csetting.Short_Local_Rating__c= 'M12';
        insert csetting;
        
        Account acctGoogle = new Account(Name='TestGoogle');
        insert acctGoogle;
        
        list<Country__c> countryList = new list<Country__c>();
        Country__c countryUSA =new Country__c(Name ='USA',Country_Code2__c ='US',Country_Code__c='USA',Territory__c = 'USA',Default_Feature_Rating_Systems__c='ao-movies');
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='778',Country_Code__c='F88',Territory__c = 'France',Default_Feature_Rating_Systems__c='ao-movies');
        
        countryList.add(countryUSA);
        countryList.add(countryFrance);
        insert countryList;
        
        Country__c countryIndia =new Country__c(Name ='TestIndia',Country_Code2__c ='IND',Country_Code__c='India',Territory__c = 'India',Default_Feature_Rating_Systems__c='ao-movies');
        insert countryIndia;
        
        Country_Groups__c countryGrp1 = new Country_Groups__c(Name = 'NewGrp',NameUnique__c ='UniqueNameTest');
        insert countryGrp1;
        
        Language__c languageEnglish = new Language__c(Name='English',Language_Order__c = 1);
        insert languageEnglish;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Profile p = [select id from profile where name='System Administrator'];
        
        User u = new User(alias = 'standt', email='testuser@testorg.com', 
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
        localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id,Territory__c = 'USA');     
        insert u;
        
        // create MPM 
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        
        list<title__c> titleList = new list<title__c>();
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',MPM__c=mpm.id,Video_Version__c ='555555',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,
        US_BD_Release_Date__c=date.today()-3,US_TV_Air_Date__c=date.today()-3,US_UV_Publish_Date__c=date.today()-3,US_Box_Office__c=1111.00,US_DVD_Release_Date__c=date.today()-3,
        US_Pay_TV_Start_Date__c = date.today()-3,Formats__c='SD');
        titleList.add( title1);
        
        Title__c title2 = new Title__c(Name = 'TestApple',MPM__c=mpm.id,Video_Version__c ='555666',Content_Type__c='Episode',Physical_Planning__c='YES',Digital_Planning__c='YES',Clear_to_Avail__c = true,
        US_BD_Release_Date__c=date.today()-3,US_TV_Air_Date__c=date.today()-3,US_UV_Publish_Date__c=date.today()-3,US_Box_Office__c=1111.00,US_DVD_Release_Date__c=date.today()-3,
        US_Pay_TV_Start_Date__c = date.today()-3,Formats__c='BD');
        titleList.add( title2);
        
        insert titleList;
        
        list<Local_Title__c> localTitleList = new list<Local_Title__c>();
        
        Local_Title__c localtitle = new Local_Title__c(Name='test Local Title',Title__c = title1.Id, Country__c = countryUSA.Id, Language__c = languageEnglish.Id,
        Local_BD_Release_Date__c=date.today(),Local_TV_Air_Date__c=date.today(),UV_Published_Date__c=date.today(),Local_Box_Office__c=1245.00,
        Local_DVD_Release_Date__c=date.today(),Local_Pay_TV_Start_Date__c=date.today(),Digital_Rating_System__c='ao-movies',Digital_Rating_Short__c='M12',
        Physical_Rating_Short__c='M12',Physical_Rating_System__c='ao-movies');
        
        localTitleList.add(localtitle);
        
        Local_Title__c localtitle1 = new Local_Title__c(Name='testCTS Local Title',Title__c = title2.Id, Country__c = countryUSA.Id, Language__c = languageFrench.Id,
        Local_BD_Release_Date__c=date.today()+1,Local_TV_Air_Date__c=date.today()+2,UV_Published_Date__c=date.today(),Local_Box_Office__c=1300.00,
        Local_DVD_Release_Date__c=date.today()+1,Local_Pay_TV_Start_Date__c=date.today(),Digital_Rating_System__c='ao-movies',Digital_Rating_Short__c='M12',
        Physical_Rating_Short__c='M12',Physical_Rating_System__c='ao-movies',Local_Rating_System__c='ao-movies',Local_Rating__c='M12');
        
        localTitleList.add(localtitle1);
        
        insert localTitleList;
        
        Test.startTest();
            list<Local_Title__c> locTitleListNew = new list<Local_Title__c>();
            for(Local_Title__c locTitle : localTitleList ){
                locTitle.Country__c = countryIndia.Id;
                locTitleListNew.add(locTitle);
            }
            //system.assertEquals(locTitleListNew.size(),2);
            //system.assertEquals(locTitleListNew[0].Country__c,countryIndia.Id);
            update locTitleListNew;
        Test.stopTest();
        
     }
     
     @isTest
     static void updateisReleaseDatesChangedFlag(){
         
         Language__c languageFrench1 = new Language__c(Name='TestFrench1',Language_Order__c = 1);
        insert languageFrench1;
        
        Ratings__c csetting = new Ratings__c();
        csetting.name='cs1';
        csetting.Rating_System__c= 'ao-movies';
        csetting.Language__c=languageFrench1.id;
        csetting.Long_Local_Rating__c= 'M12';
        csetting.Short_Local_Rating__c= 'M12';        insert csetting;
        
        Account acctGoogle = new Account(Name='TestGoogle');
        insert acctGoogle;
        
        list<Country__c> countryList = new list<Country__c>();
        Country__c countryUSA =new Country__c(Name ='USA',Country_Code2__c ='US',Country_Code__c='USA',Territory__c = 'USA',Default_Feature_Rating_Systems__c='ao-movies');
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='778',Country_Code__c='F88',Territory__c = 'France',Default_Feature_Rating_Systems__c='ao-movies');
        
        countryList.add(countryUSA);
        countryList.add(countryFrance);
        insert countryList;
        
        Country__c countryIndia =new Country__c(Name ='TestIndia',Country_Code2__c ='IND',Country_Code__c='India',Territory__c = 'India',Default_Feature_Rating_Systems__c='ao-movies');
        insert countryIndia;
        
        Country_Groups__c countryGrp1 = new Country_Groups__c(Name = 'NewGrp',NameUnique__c ='UniqueNameTest');
        insert countryGrp1;
        
        Language__c languageEnglish = new Language__c(Name='English',Language_Order__c = 1);
        insert languageEnglish;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Profile p = [select id from profile where name='System Administrator'];
        
        User u = new User(alias = 'standt', email='testuser@testorg.com', 
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
        localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id,Territory__c = 'USA');     
        insert u;
        
        // create MPM 
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        
        list<title__c> titleList = new list<title__c>();
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',MPM__c=mpm.id,Video_Version__c ='555555',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,
        US_BD_Release_Date__c=date.today()-3,US_TV_Air_Date__c=date.today()-3,US_UV_Publish_Date__c=date.today()-3,US_Box_Office__c=1111.00,US_DVD_Release_Date__c=date.today()-3,
        US_Pay_TV_Start_Date__c = date.today()-3,Formats__c='SD');
        titleList.add( title1);
        
        Title__c title2 = new Title__c(Name = 'TestApple',MPM__c=mpm.id,Video_Version__c ='555666',Content_Type__c='Episode',Physical_Planning__c='YES',Digital_Planning__c='YES',Clear_to_Avail__c = true,
        US_BD_Release_Date__c=date.today()-3,US_TV_Air_Date__c=date.today()-3,US_UV_Publish_Date__c=date.today()-3,US_Box_Office__c=1111.00,US_DVD_Release_Date__c=date.today()-3,
        US_Pay_TV_Start_Date__c = date.today()-3,Formats__c='BD');
        titleList.add( title2);
        
        insert titleList;
        
        list<Local_Title__c> localTitleList = new list<Local_Title__c>();
        
        Local_Title__c localtitle = new Local_Title__c(Name='test Local Title',Title__c = title1.Id, Country__c = countryUSA.Id, Language__c = languageEnglish.Id,
        Local_BD_Release_Date__c=date.today(),Local_TV_Air_Date__c=date.today(),UV_Published_Date__c=date.today(),Local_Box_Office__c=1245.00,
        Local_DVD_Release_Date__c=date.today(),Local_Pay_TV_Start_Date__c=date.today(),Digital_Rating_System__c='ao-movies',Digital_Rating_Short__c='M12',
        Physical_Rating_Short__c='M12',Physical_Rating_System__c='ao-movies');
        
        localTitleList.add(localtitle);
        
        Local_Title__c localtitle1 = new Local_Title__c(Name='testCTS Local Title',Title__c = title2.Id, Country__c = countryUSA.Id, Language__c = languageFrench.Id,
        Local_BD_Release_Date__c=date.today()+1,Local_TV_Air_Date__c=date.today()+2,UV_Published_Date__c=date.today(),Local_Box_Office__c=1300.00,
        Local_DVD_Release_Date__c=date.today()+1,Local_Pay_TV_Start_Date__c=date.today(),Digital_Rating_System__c='ao-movies',Digital_Rating_Short__c='M12',
        Physical_Rating_Short__c='M12',Physical_Rating_System__c='ao-movies',Local_Rating_System__c='ao-movies',Local_Rating__c='M12');
        
        localTitleList.add(localtitle1);
        
        insert localTitleList;
        
        Test.startTest();
            list<Local_Title__c> locTitleListNew = new list<Local_Title__c>();
            for(Local_Title__c locTitle : localTitleList ){
                locTitle.Initial_Physical_Release_Date__c = date.today(); 
                locTitleListNew.add(locTitle);
            }
            update locTitleListNew;
            locTitleListNew.clear();
            for(Local_Title__c locTitle : localTitleList ){
                locTitle.Initial_Physical_Release_Date__c = NULL; 
                localTitle.Local_DVD_Release_Date__c = date.today();
                locTitleListNew.add(locTitle);
            }
            update locTitleListNew;
            locTitleListNew.clear();
            for(Local_Title__c locTitle : localTitleList ){
                localTitle.Local_DVD_Release_Date__c = NULL;
                locTitle.Initial_VOD_Release_Date__c = date.today(); 
                locTitleListNew.add(locTitle);
            }
            update locTitleListNew;
            locTitleListNew.clear();
            for(Local_Title__c locTitle : localTitleList ){
                locTitle.Initial_VOD_Release_Date__c = NULL;
                 localTitle.Local_DVD_Release_Date__c = NULL;
                localTitle.Initial_EST_Release_Date__c = date.today(); 
                locTitleListNew.add(locTitle);
            }
            update locTitleListNew;
        Test.stopTest();
        
     }
     
     @isTest
     public static void validatePriceCodeTest(){
         
         MPM__c Mpm = new MPM__c();
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646';
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        Account objAccount = TestUtil.createAccount('Apple iTunes');
        objAccount.Customer_Focus__c = 'Active';
        objAccount.Type='Global';
        insert objAccount;
        
        Title__c title = TestUtil.initTitle('Harry Potter and the Goblet of Fire','1243355672');
        title.MPM__c = Mpm.Id;
        insert title;
        
        
        Country__c Country = New Country__c();
        Country.Name = 'INDIA';
        Country.Country_Code2__c = 'IN';
        Country.Country_Code__c = 'IND';
        Country.Status__c = 'Active';
        Country.Local_Title_Status__c = 'Pending';
        insert Country;
        
        Language__c Language = New Language__c();
        Language.Name = 'English';
        Language.Language_Order__c = 1;
        insert Language;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle2);
        
        insert listAvailLang;
        
        Pricing__c pricing1 = new Pricing__c();
        pricing1.Name = 'CheckPriceCode1';
        pricing1.Account__c = objAccount.id;
        pricing1.Country__c = Country.id;
        pricing1.Channel__c='EST';
        pricing1.Content_Type__c='Feature';       
        pricing1.Price_Tier__c ='reprice1';
        pricing1.Format__c='SD';
        lPricing.add(pricing1);
        
        Pricing__c pricing2 = new Pricing__c();
        pricing2.Name = 'CheckPriceCode2';
        pricing2.Account__c = objAccount.id;
        pricing2.Country__c = Country.id;
        pricing2.Channel__c='EST';
        pricing2.Content_Type__c='Feature';       
        pricing2.Price_Tier__c ='reprice2';
        pricing2.Format__c='SD';
        lPricing.add(pricing2);
        
        insert lPricing;
        
        
        listlocaltitles = new List<Local_Title__c>();
       
        Profile pf= [Select Id from profile where Name='WB - CAS Administrator']; 
        User u = new User(
        ProfileId = pf.id,
        LastName = 'last',
        Email = 'puser000@amamama.com',
        Username = 'puser5000@amamama.com',
        CompanyName = 'TEST',
        Title = 'title',
        Alias = 'alias',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US');
        insert u;
        
        
        system.runAs(u){
            try{
                
                WB_ClientAvailPriceHandler.recursiveUpdate = true;
                WB_LocalTitleTriggerHandler wb = new WB_LocalTitleTriggerHandler();
                Local_Title__c LT = new Local_Title__c();
                LT.Name = title.Name;
                LT.Title__c = title.Id;
                LT.Country__c = Country.Id;
                LT.Language__c = Language.Id;
                LT.Price_Code__c = 'CheckPriceCode1';
                LT.Local_Title__c = 'Harry Potter and the Goblet of Fire Part 4';
                //LT.Readiness__c = 'Pending';
                listlocaltitles.add(LT);
                insert listlocaltitles;
                
                List<Local_Title__c> ldList = [Select Id,Title_Content_Type__c,Price_Code__c,Country__c From Local_Title__c];
                    system.debug('ldList:'+ldList);
                    Map<Id,Local_Title__c> newMap = new Map<Id,Local_Title__c>();
                    Map<Id,Local_Title__c> oldMap = new Map<Id,Local_Title__c>();
                    
                    newMap.put(listlocaltitles[0].Id,listlocaltitles[0]);
                 ldList[0].Price_Code__c = 'CheckPriceCode2';
                 oldMap.put(ldList[0].Id,ldList[0]);
                 update ldList[0];
                WB_ClientAvailPriceHandler.recursiveUpdate = false;
                 wb.validatePriceCode(newMap,oldMap);
               
            }catch(Exception e){
                
            }
            
        }
        
     }
     
     @isTest
     public static void validatePriceCodeTest1(){
         
         MPM__c Mpm = new MPM__c();
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646';
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        Account objAccount = TestUtil.createAccount('Apple iTunes');
        objAccount.Customer_Focus__c = 'Active';
        objAccount.Type='Global';
        insert objAccount;
        
        Title__c title = TestUtil.initTitle('Harry Potter and the Goblet of Fire','1243355672');
        title.MPM__c = Mpm.Id;
        insert title;
        
        
        Country__c Country = New Country__c();
        Country.Name = 'INDIA';
        Country.Country_Code2__c = 'IN';
        Country.Country_Code__c = 'IND';
        Country.Status__c = 'Active';
        Country.Local_Title_Status__c = 'Pending';
        insert Country;
        
        Language__c Language = New Language__c();
        Language.Name = 'English';
        Language.Language_Order__c = 1;
        insert Language;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle2);
        
        insert listAvailLang;
        
        Pricing__c pricing1 = new Pricing__c();
        pricing1.Name = 'CheckPriceCode1';
        pricing1.Account__c = objAccount.id;
        pricing1.Country__c = Country.id;
        pricing1.Channel__c='EST';
        pricing1.Content_Type__c='Feature';       
        pricing1.Price_Tier__c ='reprice1';
        pricing1.Format__c='SD';
        lPricing.add(pricing1);
        
        Pricing__c pricing2 = new Pricing__c();
        pricing2.Name = 'CheckPriceCode2';
        pricing2.Account__c = objAccount.id;
        pricing2.Country__c = Country.id;
        pricing2.Channel__c='EST';
        pricing2.Content_Type__c='Feature';       
        pricing2.Price_Tier__c ='reprice2';
        pricing2.Format__c='SD';
        lPricing.add(pricing2);
        
        insert lPricing;
        
        
        listlocaltitles = new List<Local_Title__c>();
        
        WB_ClientAvailPriceHandler.recursiveUpdate = true;
                WB_LocalTitleTriggerHandler wb = new WB_LocalTitleTriggerHandler();
                Local_Title__c LT = new Local_Title__c();
                LT.Name = title.Name;
                LT.Title__c = title.Id;
                LT.Country__c = Country.Id;
                LT.Language__c = Language.Id;
                LT.Price_Code__c = 'CheckPriceCode1';
                LT.Local_Title__c = 'Harry Potter and the Goblet of Fire Part 4';
                //LT.Readiness__c = 'Pending';
                listlocaltitles.add(LT);
                insert listlocaltitles;
        
        
        Profile pf1= [Select Id from profile where Name='System Administrator'];
        User u1 = new User(
        ProfileId = pf1.id,
        LastName = 'last',
        Email = 'p1user000@amamama.com',
        Username = 'p1user5000@amamama.com',
        CompanyName = 'TEST1',
        Title = 'title1',
        Alias = 'alias1',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US');
        insert u1;
        
        system.runAs(u1){
            try{
                LT.Price_Code__c = 'CheckPriceCode2';
                update LT;
            }catch(Exception e){
                
            }
            
        }
        
        
        Profile pf= [Select Id from profile where Name='WB - CAS Administrator']; 
        User u = new User(
        ProfileId = pf.id,
        LastName = 'last',
        Email = 'puser000@amamama.com',
        Username = 'puser5000@amamama.com',
        CompanyName = 'TEST',
        Title = 'title',
        Alias = 'alias',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US');
        insert u;
      
        
     }
     
     @isTest
     public static void validatePriceCodeTest3(){
         
         MPM__c Mpm = new MPM__c();
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646';
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        Account objAccount = TestUtil.createAccount('Apple iTunes');
        objAccount.Customer_Focus__c = 'Active';
        objAccount.Type='Global';
        insert objAccount;
        
        Title__c title = TestUtil.initTitle('Harry Potter and the Goblet of Fire','1243355672');
        title.MPM__c = Mpm.Id;
        insert title;
        
        
        Country__c Country = New Country__c();
        Country.Name = 'INDIA';
        Country.Country_Code2__c = 'IN';
        Country.Country_Code__c = 'IND';
        Country.Status__c = 'Active';
        Country.Local_Title_Status__c = 'Pending';
        insert Country;
        
        Language__c Language = New Language__c();
        Language.Name = 'English';
        Language.Language_Order__c = 1;
        insert Language;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle2);
        
        insert listAvailLang;
        
        Pricing__c pricing1 = new Pricing__c();
        pricing1.Name = 'CheckPriceCode1';
        pricing1.Account__c = objAccount.id;
        pricing1.Country__c = Country.id;
        pricing1.Channel__c='EST';
        pricing1.Content_Type__c='Feature';       
        pricing1.Price_Tier__c ='reprice1';
        pricing1.Format__c='SD';
        lPricing.add(pricing1);
        
        Pricing__c pricing2 = new Pricing__c();
        pricing2.Name = 'CheckPriceCode2';
        pricing2.Account__c = objAccount.id;
        pricing2.Country__c = Country.id;
        pricing2.Channel__c='EST';
        pricing2.Content_Type__c='Feature';       
        pricing2.Price_Tier__c ='reprice2';
        pricing2.Format__c='SD';
        //lPricing.add(pricing2);
        
        insert lPricing;
        
        
        listlocaltitles = new List<Local_Title__c>();
        
       
        Profile pf= [Select Id from profile where Name='WB - CAS Administrator']; 
        User u = new User(
        ProfileId = pf.id,
        LastName = 'last',
        Email = 'puser000@amamama.com',
        Username = 'puser5000@amamama.com',
        CompanyName = 'TEST',
        Title = 'title',
        Alias = 'alias',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US');
        insert u;
        
        
        system.runAs(u){
            try{
                
                WB_ClientAvailPriceHandler.recursiveUpdate = true;
                WB_LocalTitleTriggerHandler wb = new WB_LocalTitleTriggerHandler();
                Local_Title__c LT = new Local_Title__c();
                LT.Name = title.Name;
                LT.Title__c = title.Id;
                LT.Country__c = Country.Id;
                LT.Language__c = Language.Id;
                LT.Price_Code__c = 'CheckPriceCode1';
                LT.Local_Title__c = 'Harry Potter and the Goblet of Fire Part 4';
                //LT.Readiness__c = 'Pending';
                listlocaltitles.add(LT);
                insert listlocaltitles;
                
                List<Local_Title__c> ldList = [Select Id,Title_Content_Type__c,Price_Code__c,Country__c From Local_Title__c];
                    system.debug('ldList:'+ldList);
                    Map<Id,Local_Title__c> newMap = new Map<Id,Local_Title__c>();
                    Map<Id,Local_Title__c> oldMap = new Map<Id,Local_Title__c>();
                    
                    newMap.put(listlocaltitles[0].Id,listlocaltitles[0]);
                 ldList[0].Price_Code__c = 'CheckPriceCode2';
                 oldMap.put(ldList[0].Id,ldList[0]);
                 update ldList[0];
                WB_ClientAvailPriceHandler.recursiveUpdate = false;
                 wb.validatePriceCode(newMap,oldMap);
               
            }catch(Exception e){
                
            }
            
        }
        
     }
     
     @isTest
     public static void validateLocalTitleLongDescriptionUpdateTest(){
         
         MPM__c Mpm = new MPM__c();
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646';
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        Account objAccount = TestUtil.createAccount('Apple iTunes');
        objAccount.Customer_Focus__c = 'Active';
        objAccount.Type='Global';
        insert objAccount;
        
        Title__c title = TestUtil.initTitle('Harry Potter and the Goblet of Fire','1243355672');
        title.MPM__c = Mpm.Id;
        insert title;
        
        
        Country__c Country = New Country__c();
        Country.Name = 'INDIA';
        Country.Country_Code2__c = 'IN';
        Country.Country_Code__c = 'IND';
        Country.Status__c = 'Active';
        Country.Local_Title_Status__c = 'Pending';
        insert Country;
        
        Language__c Language = New Language__c();
        Language.Name = 'English';
        Language.Language_Order__c = 1;
        insert Language;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle2);
        
        insert listAvailLang;
        
        Pricing__c pricing1 = new Pricing__c();
        pricing1.Name = 'CheckPriceCode1';
        pricing1.Account__c = objAccount.id;
        pricing1.Country__c = Country.id;
        pricing1.Channel__c='EST';
        pricing1.Content_Type__c='Feature';       
        pricing1.Price_Tier__c ='reprice1';
        pricing1.Format__c='SD';
        lPricing.add(pricing1);
        
        insert lPricing;
        
        listlocaltitles = new List<Local_Title__c>();
        
        Local_Title__c LT = new Local_Title__c();
        LT.Name = title.Name;
        LT.Title__c = title.Id;
        LT.Country__c = Country.Id;
        LT.Language__c = Language.Id;
        LT.Price_Code__c = 'CheckPriceCode1';
        LT.Local_Title__c = 'Harry Potter and the Goblet of Fire Part 4';
        //LT.Readiness__c = 'Pending';
        listlocaltitles.add(LT);
        insert listlocaltitles;
        
        LT.Readiness__c = 'Confirmed';
        update LT;
        
        Profile pf= [Select Id from profile where Name='SAP Integration API Only']; 
        User u = new User(
        ProfileId = pf.id,
        LastName = 'last',
        Email = 'puser000@amamama.com',
        Username = 'puser5000@amamama.com',
        CompanyName = 'TEST',
        Title = 'title',
        Alias = 'alias',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US');
        insert u;
        
        system.runAs(u){
            LT.Local_Title__c = 'Harry Potter and the Goblet of Fire Part-04';
            update LT;
            
        }
        
        Profile pf1= [Select Id from profile where Name='System Administrator'];
        User u1 = new User(
        ProfileId = pf1.id,
        LastName = 'last',
        Email = 'p1user000@amamama.com',
        Username = 'p1user5000@amamama.com',
        CompanyName = 'TEST1',
        Title = 'title1',
        Alias = 'alias1',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US');
        insert u1;
        
        system.runAs(u1){
            try{
                LT.Local_Title__c = 'Harry Potter and the Goblet of Fire Part-4';
                update LT;
            }catch(Exception e){
                
            }
            
        }
        
        
     }
}