@isTest
public class WB_FixLanguageUtility_Test{
    static testmethod void TestFixLanguageUtility(){
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        
        Title__c title = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',
                                      First_Available_Date__c=system.today(),Expiration_Date__c=system.today()+365,MPM__c = mpm.id,
                                      Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES',Formats__c='HD');
        insert title;
        system.assertNotEquals(null,title);
        
        Country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST');
        insert con;
        system.assertNotEquals(null,con);
        
        
        List<Language__c> listLang = new List<Language__c>();
        Language__c Language = new Language__c (Name='TestLanguage', Language_Order__c = 1,Language_Code_2__c='tl');
        Language__c Language2 = new Language__c (Name='TestLanguage2', Language_Order__c = 1,Language_Code_2__c='tl1');
        Language__c Language3 = new Language__c (Name='TestLanguage3', Language_Order__c = 1,Language_Code_2__c='tl2');
        listLang.add(Language);
        listLang.add(Language2);
        listLang.add(Language3);
        insert listLang;
        system.assertNotEquals(0,listLang.size());
        
        List<Language_Preference__c> listLangPref = new List<Language_Preference__c>();
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=listLang[0].Id,Level__c='1');
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=listLang[1].Id,Level__c='2');
        Language_Preference__c langPrefTest3= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=listLang[2].Id,Level__c='3');
        listLangPref.add(langPrefTest);
        listLangPref.add(langPrefTest2);
        listLangPref.add(langPrefTest3);
        insert listLangPref;
        system.assertNotEquals(0,listLangPref.size());
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest.Exclusive_Date__c=date.today(); 
        commAvailTest.Start_Date__c= date.today();
        commAvailTest.End_Date__c=date.parse( '12/31/2049');
        commAvailTest.status__c='Open';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Language_Type__c = 'Provisional';
        commAvailTest.Channel__c = 'EST';
        listComm.add(commAvailTest);
        
        commercial_avail__c commAvailTest2= new commercial_avail__c(); 
        commAvailTest2.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest2.Exclusive_Date__c=date.today(); 
        commAvailTest2.Start_Date__c= date.today();
        commAvailTest2.End_Date__c=date.parse( '12/31/2049');
        commAvailTest2.status__c='Confirm';
        commAvailTest2.Country_Lookup__c = con.id;
        commAvailTest2.title__c = title.id;
        commAvailTest2.Languages__c = Language.id;
        commAvailTest2.Language_Type__c = 'Sub & Audio';
        commAvailTest2.Channel__c = 'EST';
        listComm.add(commAvailTest2);
        
        Test.startTest();
        insert listComm;
        system.assertNotEquals(0,listComm.size());
        
        //for language prefernce level 1
        Available_Languages__c availLangTitle = new Available_Languages__c(Language__c=listLang[0].Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);              
        insert availLangTitle;
        
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=listLang[0].Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);              
        insert availLangTitle2;
        
        WB_FixLanguageUtility.processFixLangauges(new List<String>{listComm[0].Id,listComm[1].Id});
        
        
        //for language prefernce level 2
        Available_Languages__c availLangTitle3 = new Available_Languages__c(Language__c=listLang[1].Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);              
        insert availLangTitle3;
        
        Available_Languages__c availLangTitle4 = new Available_Languages__c(Language__c=listLang[1].Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);              
        insert availLangTitle4;
        
        WB_FixLanguageUtility.processFixLangauges(new List<String>{listComm[0].Id,listComm[1].Id});
        
        //for language prefernce level 3
        Available_Languages__c availLangTitle5 = new Available_Languages__c(Language__c=listLang[2].Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);              
        insert availLangTitle5;
        
        Available_Languages__c availLangTitle6 = new Available_Languages__c(Language__c=listLang[2].Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);              
        insert availLangTitle6;
        
        WB_FixLanguageUtility.processFixLangauges(new List<String>{listComm[0].Id,listComm[1].Id});
        Test.stopTest();
    }

    static testmethod void TestProvFixLanguageUtility(){
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        
        Title__c title = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',
                                      First_Available_Date__c=system.today(),Expiration_Date__c=system.today()+365,MPM__c = mpm.id,
                                      Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES',Formats__c='HD');
        insert title;
        system.assertNotEquals(null,title);
        
        Country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST');
        insert con;
        system.assertNotEquals(null,con);
        
        
        List<Language__c> listLang = new List<Language__c>();
        Language__c Language = new Language__c (Name='TestLanguage', Language_Order__c = 1,Language_Code_2__c='tl');
        Language__c Language2 = new Language__c (Name='TestLanguage2', Language_Order__c = 1,Language_Code_2__c='tl1');
        Language__c Language3 = new Language__c (Name='TestLanguage3', Language_Order__c = 1,Language_Code_2__c='tl2');
        listLang.add(Language);
        listLang.add(Language2);
        listLang.add(Language3);
        insert listLang;
        system.assertNotEquals(0,listLang.size());
        
        List<Language_Preference__c> listLangPref = new List<Language_Preference__c>();
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=listLang[0].Id,Level__c='1');
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=listLang[1].Id,Level__c='2');
        Language_Preference__c langPrefTest3= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=listLang[2].Id,Level__c='3');
        listLangPref.add(langPrefTest);
        listLangPref.add(langPrefTest2);
        listLangPref.add(langPrefTest3);
        insert listLangPref;
        system.assertNotEquals(0,listLangPref.size());

         //for language prefernce level 1
         Available_Languages__c availLangTitle = new Available_Languages__c(Language__c=listLang[0].Id ,Language_Types__c='Audio',Title__c=title.Id,Provisional__c=true);              
         insert availLangTitle;
         
         Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=listLang[0].Id ,Language_Types__c='Sub',Title__c=title.Id,Provisional__c=true);              
         insert availLangTitle2;
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest.Exclusive_Date__c=date.today(); 
        commAvailTest.Start_Date__c= date.today();
        commAvailTest.End_Date__c=date.parse( '12/31/2049');
        commAvailTest.status__c='Open';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Language_Type__c = 'Provisional';
        commAvailTest.Channel__c = 'EST';
        listComm.add(commAvailTest);
        
        commercial_avail__c commAvailTest2= new commercial_avail__c(); 
        commAvailTest2.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest2.Exclusive_Date__c=date.today(); 
        commAvailTest2.Start_Date__c= date.today();
        commAvailTest2.End_Date__c=date.parse( '12/31/2049');
        commAvailTest2.status__c='Confirm';
        commAvailTest2.Country_Lookup__c = con.id;
        commAvailTest2.title__c = title.id;
        commAvailTest2.Languages__c = Language.id;
        commAvailTest2.Language_Type__c = 'Sub & Audio';
        commAvailTest2.Channel__c = 'EST';
        listComm.add(commAvailTest2);
        
        Test.startTest();
        insert listComm;
        system.assertNotEquals(0,listComm.size());
        
        //for language prefernce level 1
        //Available_Languages__c availLangTitle_1 = new Available_Languages__c(Language__c=listLang[0].Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);  
        availLangTitle.Clear_To_Avail__c=true;       
        update availLangTitle;
        
        //Available_Languages__c availLangTitle_2 = new Available_Languages__c(Language__c=listLang[0].Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);              
        availLangTitle2.Clear_To_Avail__c=true;       
        update availLangTitle2;
        
        WB_FixLanguageUtility.processFixLangauges(new List<String>{listComm[0].Id,listComm[1].Id});
        
        
        //for language prefernce level 2
        Available_Languages__c availLangTitle3 = new Available_Languages__c(Language__c=listLang[1].Id ,Language_Types__c='Audio',Title__c=title.Id,Provisional__c=true);              
        insert availLangTitle3;
        
        Available_Languages__c availLangTitle4 = new Available_Languages__c(Language__c=listLang[1].Id ,Language_Types__c='Sub',Title__c=title.Id,Provisional__c=true);              
        insert availLangTitle4;
        
        WB_FixLanguageUtility.processFixLangauges(new List<String>{listComm[0].Id,listComm[1].Id});
        
        //for language prefernce level 3
        Available_Languages__c availLangTitle5 = new Available_Languages__c(Language__c=listLang[2].Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);              
        insert availLangTitle5;
        
        Available_Languages__c availLangTitle6 = new Available_Languages__c(Language__c=listLang[2].Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);              
        insert availLangTitle6;
        
        WB_FixLanguageUtility.processFixLangauges(new List<String>{listComm[0].Id,listComm[1].Id});
        Test.stopTest();
    }

    static testmethod void TestProvFixLanguageUtility1(){
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        
        Title__c title = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',
                                      First_Available_Date__c=system.today(),Expiration_Date__c=system.today()+365,MPM__c = mpm.id,
                                      Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES',Formats__c='HD');
        insert title;
        system.assertNotEquals(null,title);
        
        Country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST');
        insert con;
        system.assertNotEquals(null,con);
        
        
        List<Language__c> listLang = new List<Language__c>();
        Language__c Language = new Language__c (Name='TestLanguage', Language_Order__c = 1,Language_Code_2__c='tl');
        Language__c Language2 = new Language__c (Name='TestLanguage2', Language_Order__c = 1,Language_Code_2__c='tl1');
        Language__c Language3 = new Language__c (Name='TestLanguage3', Language_Order__c = 1,Language_Code_2__c='tl2');
        listLang.add(Language);
        listLang.add(Language2);
        listLang.add(Language3);
        insert listLang;
        system.assertNotEquals(0,listLang.size());
        
        List<Language_Preference__c> listLangPref = new List<Language_Preference__c>();
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=listLang[0].Id,Level__c='1');
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=listLang[1].Id,Level__c='2');
        Language_Preference__c langPrefTest3= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=listLang[2].Id,Level__c='3');
        listLangPref.add(langPrefTest);
        listLangPref.add(langPrefTest2);
        listLangPref.add(langPrefTest3);
        insert listLangPref;
        system.assertNotEquals(0,listLangPref.size());

         //for language prefernce level 1
         Available_Languages__c availLangTitle = new Available_Languages__c(Language__c=listLang[0].Id ,Language_Types__c='Audio',Title__c=title.Id,Provisional__c=true);              
         insert availLangTitle;
         
         Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=listLang[0].Id ,Language_Types__c='Sub',Title__c=title.Id,Provisional__c=true);              
         insert availLangTitle2;
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest.Exclusive_Date__c=date.today(); 
        commAvailTest.Start_Date__c= date.today();
        commAvailTest.End_Date__c=date.parse( '12/31/2049');
        commAvailTest.status__c='Open';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Language_Type__c = 'Provisional';
        commAvailTest.Channel__c = 'EST';
        listComm.add(commAvailTest);
        
        commercial_avail__c commAvailTest2= new commercial_avail__c(); 
        commAvailTest2.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest2.Exclusive_Date__c=date.today(); 
        commAvailTest2.Start_Date__c= date.today();
        commAvailTest2.End_Date__c=date.parse( '12/31/2049');
        commAvailTest2.status__c='Confirmed';
        commAvailTest2.Country_Lookup__c = con.id;
        commAvailTest2.title__c = title.id;
        commAvailTest2.Languages__c = Language.id;
        commAvailTest2.Language_Type__c = 'Sub & Audio';
        commAvailTest2.Channel__c = 'EST';
        listComm.add(commAvailTest2);
        
        Test.startTest();
        insert listComm;
        system.assertNotEquals(0,listComm.size());
        
        //for language prefernce level 1
        //Available_Languages__c availLangTitle_1 = new Available_Languages__c(Language__c=listLang[0].Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);  
        availLangTitle.Clear_To_Avail__c=true;       
        update availLangTitle;
        
        //Available_Languages__c availLangTitle_2 = new Available_Languages__c(Language__c=listLang[0].Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);              
        availLangTitle2.Clear_To_Avail__c=true;       
        update availLangTitle2;
        
        WB_FixLanguageUtility.processFixLangauges(new List<String>{listComm[0].Id,listComm[1].Id});
        
        
        //for language prefernce level 2
        Available_Languages__c availLangTitle3 = new Available_Languages__c(Language__c=listLang[1].Id ,Language_Types__c='Audio',Title__c=title.Id,Provisional__c=true);              
        insert availLangTitle3;
        
        Available_Languages__c availLangTitle4 = new Available_Languages__c(Language__c=listLang[1].Id ,Language_Types__c='Sub',Title__c=title.Id,Provisional__c=true);              
        insert availLangTitle4;
        
        WB_FixLanguageUtility.processFixLangauges(new List<String>{listComm[0].Id,listComm[1].Id});
        
        //for language prefernce level 3
        Available_Languages__c availLangTitle5 = new Available_Languages__c(Language__c=listLang[2].Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);              
        insert availLangTitle5;
        
        Available_Languages__c availLangTitle6 = new Available_Languages__c(Language__c=listLang[2].Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);              
        insert availLangTitle6;
        
        WB_FixLanguageUtility.processFixLangauges(new List<String>{listComm[0].Id,listComm[1].Id});
        Test.stopTest();
    }
}