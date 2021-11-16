@isTest
public with sharing class WB_CalculateRPDatesTest {
    public WB_CalculateRPDatesTest() {

    }
    public static List<MPM__c> mpmList = new List<MPM__c>();
    public static List<Title__c> titleList = new List<Title__c>();
    public static List<Language__c> languageList = new List<Language__c>();
    public static List<Available_Languages__c> availableLangList = new List<Available_Languages__c>();
    public static List<Country__c> countryList = new List<Country__c>();
    public static List<Language_Preference__c> langPrefList = new List<Language_Preference__c>();
    public static List<Commercial_avail__c> rpList = new List<Commercial_avail__c>();
    public static List<Local_Title__c> localTitleList = new List<Local_Title__c>();
    
    public static testmethod void calculateRPDatesTestMethod(){
        
        MPM__c mpmRec = new MPM__c();
        mpmRec.Name ='MPM record';
        mpmRec.MPM_Number__c ='12358';
        mpmList.add(mpmRec);
        insert mpmList;

        Title__c titleRec1 = new Title__c();
        titleRec1.Name='Never Ever I Knew';
        titleRec1.Video_Version__c='0123456789';
        titleRec1.Formats__c='HD;DVD';
        titleRec1.First_Available_Date__c=system.today();
        titleRec1.Expiration_Date__c=system.today()+365;
        titleRec1.MPM__c = mpmList[0].id;
        titleRec1.Studio__c='BBC';
        titleRec1.Genre__c='ACTION';
        titleRec1.Digital_Planning__c='YES';
        titleRec1.Physical_Planning__c='YES';
        titleRec1.US_Theatrical_Release_Date_New__c = System.Today()+2;
        titleRec1.Content_Type__c = 'Feature';
        titleList.add(titleRec1);

        insert titleList;

        
        Language__c languageRec1 = new Language__c (Name='English',Language_Order__c = 1,Language_Code_2__c='en');
        languageList.add(languageRec1);
        
        insert languageList;

        Available_Languages__c availLangRec1 = new Available_Languages__c(Language__c=languageList[0].Id ,Language_Types__c='Sub',Title__c=titleList[0].Id,Clear_To_Avail__c=true);
        availableLangList.add(availLangRec1);
        Available_Languages__c availLangRec2 = new Available_Languages__c(Language__c=languageList[0].Id ,Language_Types__c='Audio',Title__c=titleList[0].Id,Clear_To_Avail__c=true);
        availableLangList.add(availLangRec2);

        insert availableLangList;

        Country__c countryRec1 = new Country__c(Name='Egypt',Country_Code__c='EGY', Country_Code2__c='eg',Channel__c='DTD;EST',EST_Offset__c=89,RP_AutoCalc_Default__c=true,VOD_Offset__c=90,Physical_Offset__c=85,VOD_Exploitation_Days__c=180);
        countryList.add(countryRec1);

        Country__c countryRec2 = new Country__c(Name='Australia',Country_Code__c='AUS', Country_Code2__c='au',Channel__c='DTD;EST',EST_Offset__c=80,RP_AutoCalc_Default__c=true,VOD_Offset__c=90,Physical_Offset__c=85,VOD_Exploitation_Days__c=180);
        countryList.add(countryRec2);

        Country__c countryRec3 = new Country__c(Name='USA',Country_Code__c='US', Country_Code2__c='us',Channel__c='DTD;EST',EST_Offset__c=80,RP_AutoCalc_Default__c=true,VOD_Offset__c=90,Physical_Offset__c=85,VOD_Exploitation_Days__c=180);
        countryList.add(countryRec3);
        insert countryList;

        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=countryList[0].Id,Type__c= 'Country',Language__c=languageList[0].Id,Level__c='1');
        langPrefList.add(langPrefTest);

        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=countryList[1].Id,Type__c= 'Country',Language__c=languageList[0].Id,Level__c='1');
        langPrefList.add(langPrefTest2);

        Language_Preference__c langPrefTest3= new Language_Preference__c(Country__c=countryList[2].Id,Type__c= 'Country',Language__c=languageList[0].Id,Level__c='1');
        langPrefList.add(langPrefTest3);
        insert langPrefList;

        Local_Title__c localTitleRec1 = new Local_Title__c();
        localTitleRec1.Title__c= titleList[0].id;
        localTitleRec1.Country__c= countryList[0].id;
        localTitleRec1.Language__c=languageList[0].id;
        localTitleRec1.Name='Never Ever I Knew';
        localTitleRec1.Local_Theatrical_Release_Date__c=System.today();
        localTitleList.add(localTitleRec1);

        Local_Title__c localTitleRec2 = new Local_Title__c();
        localTitleRec2.Title__c= titleList[0].id;
        localTitleRec2.Country__c= countryList[1].id;
        localTitleRec2.Language__c=languageList[0].id;
        localTitleRec2.Name='Never Ever I Knew';
        localTitleRec2.Local_Theatrical_Release_Date__c=System.today()-250;
        localTitleList.add(localTitleRec2);

        Local_Title__c localTitleRec3 = new Local_Title__c();
        localTitleRec3.Title__c= titleList[0].id;
        localTitleRec3.Country__c= countryList[2].id;
        localTitleRec3.Language__c=languageList[0].id;
        localTitleRec3.Name='Never Ever I Knew';
        localTitleRec2.Local_Theatrical_Release_Date__c=Null;
        localTitleList.add(localTitleRec3);
        insert localTitleList;
        
        Commercial_avail__c rpRec1= new Commercial_avail__c(); 
        rpRec1.Rights_End__c=System.today()+290; 
        rpRec1.Exclusive_Date__c=System.today()+5; 
        rpRec1.Start_Date__c= System.today()+10;
        rpRec1.End_Date__c=System.today()+290; 
        rpRec1.status__c='Draft';
        rpRec1.Country_Lookup__c = countryList[0].id;
        rpRec1.title__c = titleList[0].id;
        rpRec1.Languages__c = languageList[0].id;
        rpRec1.Channel__c = 'EST';
        rpRec1.RP_AutoCalc__c = true;
        rpRec1.Local_Title__c=localTitleList[0].id;
        rpRec1.Format__c='HD';
        rpList.add(rpRec1);

        Commercial_avail__c rpRec2= new Commercial_avail__c(); 
        rpRec2.Rights_End__c=System.today()+290; 
        rpRec2.Exclusive_Date__c=System.today()+5; 
        rpRec2.Start_Date__c= System.today()+10;
        rpRec2.End_Date__c=System.today()+290; 
        rpRec2.status__c='Draft';
        rpRec2.Country_Lookup__c = countryList[0].id;
        rpRec2.title__c = titleList[0].id;
        rpRec2.Languages__c = languageList[0].id;
        rpRec2.Channel__c = 'VODi';
        rpRec2.Format__c='HD';
        rpRec2.RP_AutoCalc__c = true;
        rpRec2.Local_Title__c=localTitleList[0].id;
        rpList.add(rpRec2);

        Commercial_avail__c rpRec3= new Commercial_avail__c(); 
        rpRec3.Rights_End__c=System.today()+290; 
        rpRec3.Exclusive_Date__c=System.today()+5; 
        rpRec3.Start_Date__c= System.today()+190;
        rpRec3.End_Date__c=System.today()+280; 
        rpRec3.status__c='Draft';
        rpRec3.Country_Lookup__c = countryList[0].id;
        rpRec3.title__c = titleList[0].id;
        rpRec3.Languages__c = languageList[0].id;
        rpRec3.Channel__c = 'Physical';
        rpRec3.Format__c='DVD';
        rpRec3.RP_AutoCalc__c = true;
        rpRec3.Local_Title__c=localTitleList[0].id;
        rpRec3.GPP_Avail_Start__c=System.today()+5;
        rpList.add(rpRec3);

        Commercial_avail__c rpRec4= new Commercial_avail__c(); 
        rpRec4.Rights_End__c=System.today()+290; 
        rpRec4.Exclusive_Date__c=System.today()+5; 
        rpRec4.Start_Date__c= System.today()+10;
        rpRec4.End_Date__c=System.today()+290; 
        rpRec4.status__c='Draft';
        rpRec4.Country_Lookup__c = countryList[1].id;
        rpRec4.title__c = titleList[0].id;
        rpRec4.Languages__c = languageList[0].id;
        rpRec4.Channel__c = 'EST';
        rpRec4.RP_AutoCalc__c = true;
        rpRec4.Local_Title__c=localTitleList[1].id;
        rpRec4.Format__c='HD';
        rpList.add(rpRec4);

        Commercial_avail__c rpRec5= new Commercial_avail__c(); 
        rpRec5.Rights_End__c=System.today()+290; 
        rpRec5.Exclusive_Date__c=System.today()+5; 
        rpRec5.Start_Date__c= System.today()+190;
        rpRec5.End_Date__c=System.today()+290; 
        rpRec5.status__c='Draft';
        rpRec5.Country_Lookup__c = countryList[2].id;
        rpRec5.title__c = titleList[0].id;
        rpRec5.Languages__c = languageList[0].id;
        rpRec5.Channel__c = 'Physical';
        rpRec5.RP_AutoCalc__c = true;
        rpRec5.Local_Title__c=localTitleList[2].id;
        rpRec5.Format__c='DVD';
       rpList.add(rpRec5);
       
        Test.startTest();
            insert rpList;

            rpList[2].RP_AutoCalc__c = false;
            update rpList[2];

            rpList[3].Start_Date__c=System.today()+8;
            rpList[3].End_Date__c=System.today()+250;
            update rpList[3];

        Test.stopTest();
        
    }
}