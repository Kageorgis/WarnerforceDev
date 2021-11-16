@isTest
private class WB_CheckingDateOverlapController_Test{
    @isTest
    public static void testMPMRollup() {
        // test mpm
        list<MPM__c> testMPMList= new list<MPM__c>();
        MPM__c mpm = new MPM__c(name='2004591',MPM_Number__c='2004591');
        MPM__c mpm1 = new MPM__c(name='2000000',MPM_Number__c='2000000',Generic__c= false);
        testMPMList.add(mpm);
        testMPMList.add(mpm1);
        insert testMPMList;
        system.assertEquals(2,testMPMList.size());
        
        //test title
        list<title__c> testTitleList= new list<title__c>();
        Title__c title = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today(),
                                      Expiration_Date__c=system.today()+365,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
                                      Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        Title__c title1 = new Title__c(Name='TestTitle', Video_Version__c='012345677868',Formats__c='HD',First_Available_Date__c=system.today(),
                                       MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
                                       
        Title__c title2 = new Title__c(Name='TestTitle1', Video_Version__c='012345677800',Formats__c='HD;SD',First_Available_Date__c=system.today(),
                                       MPM__c = mpm1.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');                               
        
        testTitleList.add(title);
        testTitleList.add(title1);
        testTitleList.add(title2);
        insert testTitleList;
        system.assertNotEquals(0,testTitleList.size());
        
        // Test Language
        List<Language__c> listLang = new List<Language__c>();
        Language__c Language = new Language__c (Name='English',Language_Order__c = 1);
        listLang.add(Language);
        //insert Language;
        
        Language__c Language1 = new Language__c (Name='TestLanguage1', Language_Order__c = 1);
        listLang.add(Language1);
        //insert Language1;
         
        Language__c Language2 = new Language__c (Name='TestLanguage3', Language_Order__c = 1);
        listLang.add(Language2);
        //insert Language2;
        insert listLang;
        system.assertNotEquals(0,listLang.size());
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=false);
        listAvailLang.add(availLangTitle2);
        Available_Languages__c availLangTitle3 = new Available_Languages__c(Language__c=Language1.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle3);
        Available_Languages__c availLangTitle4 = new Available_Languages__c(Language__c=Language1.Id ,Language_Types__c='Audio',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle4);
        Available_Languages__c availLangTitle5 = new Available_Languages__c(Language__c=Language2.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle5);
        Available_Languages__c availLangTitle6 = new Available_Languages__c(Language__c=Language2.Id ,Language_Types__c='Audio',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle6);    
        insert listAvailLang;
        system.assertNotEquals(0,listAvailLang.size());
        
        // Test country for country grp 
        country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST');
        insert con;
        system.assertNotEquals(null,con);
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
        insert langPrefTest;
        system.assertNotEquals(null,langPrefTest);
        
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Language__c=Language1.Id,Level__c='2');
        insert langPrefTest1;
        system.assertNotEquals(null,langPrefTest1);
        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Language__c=Language2.Id,Level__c='1');
        insert langPrefTest2;
        system.assertNotEquals(null,langPrefTest2);
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
        insert conGrp;
        system.assertNotEquals(null,conGrp);
        
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        system.assertNotEquals(null,conGrpCon);
        
        //test locale
        Rights_Group__c lacle = new Rights_Group__c(Name='en_US',Country__c=con.Id, Language__c=listLang[0].Id, Release_Locale__c='en_US');
        insert lacle;
        system.assertNotEquals(null,lacle);
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        
		commercial_avail__c commAvailTest7= new commercial_avail__c(); 
        commAvailTest7.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest7.Exclusive_Date__c=date.today().addDays(2); 
        commAvailTest7.Start_Date__c= date.today().addDays(4); 
        commAvailTest7.End_Date__c=date.parse( '12/31/2049');
        commAvailTest7.status__c='Confirmed';
        commAvailTest7.Country_Lookup__c = con.id;
        commAvailTest7.title__c = title2.id;
        commAvailTest7.Languages__c = Language.id;
        commAvailTest7.Channel__c = 'Hotel';
        commAvailTest7.Format__c = 'SD';
        commAvailTest7.Release_Locale__c = 'jp_CH';
        //MRD Key = 2000000_jp_CH_Hotel_SD;
        listComm.add(commAvailTest7);	
		
		commercial_avail__c commAvailTest6= new commercial_avail__c(); 
        commAvailTest6.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest6.Exclusive_Date__c=date.today().addDays(2); 
        commAvailTest6.Start_Date__c= date.today().addDays(4); 
        commAvailTest6.End_Date__c=date.parse( '12/31/2049');
        commAvailTest6.status__c='Confirmed';
        commAvailTest6.Country_Lookup__c = con.id;
        commAvailTest6.title__c = title2.id;
        commAvailTest6.Languages__c = Language.id;
        commAvailTest6.Channel__c = 'EST';
        commAvailTest6.Format__c = 'HD';
        commAvailTest6.Release_Locale__c = 'de_CH';
		//MRD Key = 2000000_de_CH_EST_HD;
        listComm.add(commAvailTest6);
		
        commercial_avail__c commAvailTest5= new commercial_avail__c(); 
        commAvailTest5.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest5.Exclusive_Date__c=date.today().addDays(8); 
        commAvailTest5.Start_Date__c= date.today().addDays(9); 
        commAvailTest5.End_Date__c=date.parse( '12/31/2049');
        commAvailTest5.status__c='Draft';
        commAvailTest5.Country_Lookup__c = con.id;
        commAvailTest5.title__c = title.id;
        commAvailTest5.Languages__c = Language.id;
        commAvailTest5.Channel__c = 'VODi';
        commAvailTest5.Format__c = 'SD';
        commAvailTest5.Release_Locale__c = 'en_US';
        listComm.add(commAvailTest5);
        
        commercial_avail__c commAvailTest4= new commercial_avail__c(); 
        commAvailTest4.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest4.Exclusive_Date__c=date.today().addDays(4); 
        commAvailTest4.Start_Date__c= date.today().addDays(6); 
        commAvailTest4.End_Date__c=date.parse( '12/31/2049');
        commAvailTest4.status__c='Not Releasing';
        commAvailTest4.Reason_Code__c='No Rights';
        commAvailTest4.Country_Lookup__c = con.id;
        commAvailTest4.title__c = title.id;
        commAvailTest4.Languages__c = Language.id;
        commAvailTest4.Channel__c = 'Physical';
        commAvailTest4.Format__c = 'BD';
        commAvailTest4.Release_Locale__c = null;
        listComm.add(commAvailTest4);
        
        commercial_avail__c commAvailTest3= new commercial_avail__c(); 
        commAvailTest3.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest3.Exclusive_Date__c=date.today().addDays(11); 
        commAvailTest3.Start_Date__c= date.today().addDays(13); 
        commAvailTest3.End_Date__c=date.parse( '12/31/2049');
        commAvailTest3.status__c='Open';
        commAvailTest3.Country_Lookup__c = con.id;
        commAvailTest3.title__c = title.id;
        commAvailTest3.Languages__c = Language.id;
        commAvailTest3.Channel__c = 'Physical';
        commAvailTest3.Format__c = 'DVD';
        commAvailTest3.Release_Locale__c = null;
        listComm.add(commAvailTest3);
             
        commercial_avail__c commAvailTest2= new commercial_avail__c(); 
        commAvailTest2.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest2.Exclusive_Date__c=date.today().addDays(1); 
        commAvailTest2.Start_Date__c= date.today().addDays(3); 
        commAvailTest2.End_Date__c=date.parse( '12/31/2049');
        commAvailTest2.status__c='Tentative';
        commAvailTest2.Country_Lookup__c = con.id;
        commAvailTest2.title__c = title.id;
        commAvailTest2.Languages__c = Language.id;
        commAvailTest2.Channel__c = 'EST';
        commAvailTest2.Format__c = 'SD';
        commAvailTest2.Release_Locale__c = null;
        listComm.add(commAvailTest2);
        
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest.Exclusive_Date__c=date.today().addDays(2); 
        commAvailTest.Start_Date__c= date.today().addDays(4); 
        commAvailTest.End_Date__c=date.parse( '12/31/2049');
        commAvailTest.status__c='Confirmed';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Channel__c = 'EST';
        commAvailTest.Format__c = 'HD';
        commAvailTest.Release_Locale__c = null;
        listComm.add(commAvailTest);

        insert listComm;
        
        system.assertEquals(7,listComm.size());
        
        //Test MPM Release date
        List<MPM_Release_Date__c> listMPMRD = new List<MPM_Release_Date__c>();
        
        MPM_Release_Date__c mpmRD = new MPM_Release_Date__c(); 
        mpmRD.Country__c = con.id;
        mpmRD.Language__c = Language.id;
        mpmRD.Locale__c = 'en_US'; 
        mpmRD.MPM__c = mpm.id;
        mpmRD.Record_Status__c ='Active'; 
        mpmRD.Channel__c = 'EST';
        mpmRD.Format__c = 'HD';
        mpmRD.Avail_Start__c=date.today(); 
        mpmRD.Release_Start__c= date.today();
        mpmRD.Release_Status__c='Confirmed';
        listMPMRD.add(mpmRD);
		
		MPM_Release_Date__c mpmRD1 = new MPM_Release_Date__c(); 
        mpmRD1.Country__c = con.id;
        mpmRD1.Language__c = Language.id;
        mpmRD1.Locale__c = 'de_CH'; 
        mpmRD1.MPM__c = mpm1.id;
        mpmRD1.Record_Status__c ='Active'; 
        mpmRD1.Channel__c = 'EST';
        mpmRD1.Format__c = 'HD';
        mpmRD1.Avail_Start__c=date.today(); 
        mpmRD1.Release_Start__c= date.today();
        mpmRD1.Release_Status__c='Confirmed';
		mpmRD1.Key__c = '2000000_de_CH_EST_HD';
        listMPMRD.add(mpmRD1);
        
        MPM_Release_Date__c mpmRD2 = new MPM_Release_Date__c(); 
        mpmRD2.Country__c = con.id;
        mpmRD2.Language__c = Language.id;
        mpmRD2.Locale__c = 'jp_CH'; 
        mpmRD2.MPM__c = mpm1.id;
        mpmRD2.Record_Status__c ='Active'; 
        mpmRD2.Channel__c = 'Hotel';
        mpmRD2.Format__c = 'SD';
        mpmRD2.Avail_Start__c=date.today(); 
        mpmRD2.Release_Start__c= date.today();
        mpmRD2.Release_Status__c='Confirmed';
		mpmRD2.Key__c = '2000000_jp_CH_Hotel_SD';
        listMPMRD.add(mpmRD2);
        //MRD Key = 2000000_jp_CH_Hotel_SD;
        
        insert listMPMRD;
        system.assertEquals(3,listMPMRD.size());
    
        map<Id,commercial_avail__c> mapOldRP = new map<Id,commercial_avail__c>();
        for(commercial_avail__c ca : listComm)
             mapOldRP.put(ca.Id, ca);
        
        WB_CheckingDateOverlapController.UpdateRPMPMReleaseDateKey(listComm, mapOldRP);
        
        List<Commercial_Avail__c> lstCommAvail  = [SELECT Id, Name, Title__c, Title__r.MPM__c, Exclusive_Date__c, Start_Date__c, Status__c,Premium_Window__c, 
                                                     MPM_Release_Date_Key__c, Languages__c, Country_Lookup__c, Channel__c, Format__c, Release_Locale__c 
                                                     FROM Commercial_Avail__c LIMIT 1000];
                                                    
        WB_CheckingDateOverlapController.UpdateMRMReleaseDate(lstCommAvail);
        
        Set<Id> setMPMRDId = new Set<Id>();
        setMPMRDId.add(listMPMRD[0].Id);

        WB_CheckingDateOverlapController.UpdateLocalData(setMPMRDId);
    }
    
     @isTest
    public static void testMPMRollup2() {
        // test mpm
        List<MPM__c> mpmList = new  List<MPM__c>();
        MPM__c mpm = new MPM__c(name='2004592',MPM_Number__c='2004592',Generic__c = false);
		MPM__c mpmGen = new MPM__c(name='2004593',MPM_Number__c='2004593',Generic__c = true);
        mpmList.add(mpm);
		mpmList.add(mpmGen);
		insert mpmList;
        system.assertNotEquals(null,mpmList);
        
        //test title
        list<title__c> testTitleList= new list<title__c>();
        Title__c title = new Title__c(Name='TestTitle11', Video_Version__c='0123456799',Formats__c='HD;BD',First_Available_Date__c=system.today(),
                                      Expiration_Date__c=system.today()+365,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
                                      Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        Title__c titleGen = new Title__c(Name='TestTitle12', Video_Version__c='0123456790',Formats__c='HD;BD',First_Available_Date__c=system.today(),
                                      Expiration_Date__c=system.today()+365,MPM__c = mpmGen.id,Studio__c='BBC',Genre__c='ACTION',
                                      Short_Synopsis__c='short description',Digital_Planning__c='YES');
		
		testTitleList.add(title);
		testTitleList.add(titleGen);
        insert testTitleList;
        system.assertNotEquals(0,testTitleList.size());
        
        // Test Language
        List<Language__c> listLang = new List<Language__c>();
        Language__c Language = new Language__c (Name='English',Language_Order__c = 1);
        listLang.add(Language);
        //insert Language2;
        insert listLang;
        system.assertNotEquals(0,listLang.size());
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        insert listAvailLang;
        system.assertNotEquals(0,listAvailLang.size());
        
        // Test country for country grp 
        country__c con= new country__c(Name='USA',Country_Code__c='US', Country_Code2__c='US',Channel__c='EST');
        insert con;
        system.assertNotEquals(null,con);
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
        insert langPrefTest;
        system.assertNotEquals(null,langPrefTest);
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestRytGrp');
        insert conGrp;
        system.assertNotEquals(null,conGrp);
        
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        system.assertNotEquals(null,conGrpCon);
        
        //test locale
        Rights_Group__c lacle = new Rights_Group__c(Name='en_US',Country__c=con.Id, Language__c=listLang[0].Id, Release_Locale__c='en_US');
        insert lacle;
        system.assertNotEquals(null,lacle);
        
        MPM_Release_Date__c mpmRD1 = new MPM_Release_Date__c(); 
        mpmRD1.Country__c = con.id;
        mpmRD1.Language__c = Language.id;
        mpmRD1.Locale__c = 'jp_CH'; 
        mpmRD1.MPM__c = mpmGen.id;
        mpmRD1.Record_Status__c ='Active'; 
        mpmRD1.Channel__c = 'Hotel';
        mpmRD1.Format__c = 'SD';
        mpmRD1.Avail_Start__c=date.today(); 
        mpmRD1.Release_Start__c= date.today();
        mpmRD1.Release_Status__c='Confirmed';
		mpmRD1.Key__c = '2004592_jp_CH_Hotel_SD';
        insert mpmRD1;
		
		List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        
        commercial_avail__c commAvailTest4= new commercial_avail__c(); 
        commAvailTest4.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest4.Exclusive_Date__c=date.today().addDays(4); 
        commAvailTest4.Start_Date__c= date.today().addDays(6); 
        commAvailTest4.End_Date__c=date.parse( '12/31/2049');
        commAvailTest4.status__c='Tentative';
        commAvailTest4.Reason_Code__c='No Rights';
        commAvailTest4.Country_Lookup__c = con.id;
        commAvailTest4.title__c = title.id;
        commAvailTest4.Languages__c = Language.id;
        commAvailTest4.Channel__c = 'EST';
        commAvailTest4.Format__c = 'HD';
        commAvailTest4.Release_Locale__c = null;
        listComm.add(commAvailTest4);
        
		commercial_avail__c commAvailTest5= new commercial_avail__c(); 
        commAvailTest5.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest5.Exclusive_Date__c=date.today().addDays(4); 
        commAvailTest5.Start_Date__c= date.today().addDays(6); 
        commAvailTest5.End_Date__c=date.parse( '12/31/2049');
        commAvailTest5.status__c='Tentative';
        commAvailTest5.Reason_Code__c='No Rights';
        commAvailTest5.Country_Lookup__c = con.id;
        commAvailTest5.title__c = titleGen.id;
        commAvailTest5.Languages__c = Language.id;
        commAvailTest5.Channel__c = 'EST';
        commAvailTest5.Format__c = 'SD';
		commAvailTest5.MRD_ID__c = mpmRD1.id;
        commAvailTest5.Release_Locale__c = 'jp_CH';
        listComm.add(commAvailTest5);
		
		commercial_avail__c commAvailTest6= new commercial_avail__c(); 
		commAvailTest6.Rights_End__c=date.parse( '12/31/2049'); 
		commAvailTest6.Exclusive_Date__c=date.today().addDays(4); 
		commAvailTest6.Start_Date__c= date.today().addDays(6); 
		commAvailTest6.End_Date__c=date.parse( '12/31/2049');
		commAvailTest6.status__c='Confirmed';
		commAvailTest6.Reason_Code__c='No Rights';
		commAvailTest6.Country_Lookup__c = con.id;
		commAvailTest6.title__c = titleGen.id;
		commAvailTest6.Languages__c = Language.id;
		commAvailTest6.Channel__c = 'EST';
		commAvailTest6.Format__c = 'HD';
		commAvailTest6.MRD_ID__c = mpmRD1.id;
		commAvailTest6.Release_Locale__c = 'jp_CH';
		listComm.add(commAvailTest6);
		
		commercial_avail__c commAvailTest7= new commercial_avail__c(); 
		commAvailTest7.Rights_End__c=date.parse( '12/31/2050'); 
		commAvailTest7.Exclusive_Date__c=date.today().addDays(5); 
		commAvailTest7.Start_Date__c= date.today().addDays(7); 
		commAvailTest7.End_Date__c=date.parse( '12/31/2050');
		commAvailTest7.status__c='Confirmed';
		commAvailTest7.Reason_Code__c='No Rights';
		commAvailTest7.Country_Lookup__c = con.id;
		commAvailTest7.title__c = titleGen.id;
		commAvailTest7.Languages__c = Language.id;
		commAvailTest7.Channel__c = 'EST';
		commAvailTest7.Format__c = 'BD';
		commAvailTest7.MRD_ID__c = mpmRD1.id;
		commAvailTest7.Release_Locale__c = 'jp_CH';
		listComm.add(commAvailTest7);
		
		
		commercial_avail__c commAvailTest8= new commercial_avail__c(); 
		commAvailTest8.Rights_End__c=date.parse('12/31/2050'); 
		commAvailTest8.Exclusive_Date__c=date.today().addDays(5); 
		commAvailTest8.Start_Date__c= date.today().addDays(7); 
		commAvailTest8.End_Date__c=date.parse( '12/31/2050');
		commAvailTest8.status__c='Confirmed';
		commAvailTest8.Reason_Code__c='No Rights';
		commAvailTest8.Country_Lookup__c = con.id;
		commAvailTest8.title__c = title.id;
		commAvailTest8.Languages__c = Language.id;
		commAvailTest8.Channel__c = 'Hotel';
		commAvailTest8.Format__c = 'SD';
		commAvailTest8.MRD_ID__c = mpmRD1.id;   //2004592_jp_CH_Hotel_SD
		commAvailTest8.Release_Locale__c = 'jp_CH';
		listComm.add(commAvailTest8);
		
        insert listComm;
        
        system.assertEquals(5,listComm.size());
        
        map<Id,commercial_avail__c> mapOldRP = new map<Id,commercial_avail__c>();
        for(commercial_avail__c ca : listComm)
             mapOldRP.put(ca.Id, ca);
        
        WB_CheckingDateOverlapController.UpdateRPMPMReleaseDateKey(listComm, mapOldRP);
        
        List<Commercial_Avail__c> lstCommAvail  = [SELECT Id, Name, Title__c, Title__r.MPM__c, Exclusive_Date__c, Start_Date__c, Status__c,Premium_Window__c,
                                                     MPM_Release_Date_Key__c, Languages__c, Country_Lookup__c, Channel__c, Format__c, Release_Locale__c,MRD_ID__c
                                                     FROM Commercial_Avail__c LIMIT 100];
                                                 
        WB_CheckingDateOverlapController.UpdateMRMReleaseDate(lstCommAvail);
		WB_CheckingDateOverlapController.UpdateMRMReleaseDateToCancel(lstCommAvail);
		
    }
   /*ER-003468 --Overlapping*/ 
    @isTest
    public static void testChkoverlap_beforeupdate() {
        // test mpm
        List<MPM__c> mpmList = new  List<MPM__c>();
        MPM__c mpm = new MPM__c(name='2004592',MPM_Number__c='2004592',Generic__c = false);
		MPM__c mpmGen = new MPM__c(name='2004593',MPM_Number__c='2004593',Generic__c = true);
        mpmList.add(mpm);
		mpmList.add(mpmGen);
		insert mpmList;
        system.assertNotEquals(null,mpmList);
        
        //test title
        list<title__c> testTitleList= new list<title__c>();
        Title__c title = new Title__c(Name='TestTitle11', Video_Version__c='0123456799',Formats__c='HD;BD',First_Available_Date__c=system.today(),
                                      Expiration_Date__c=system.today()+365,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
                                      Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        Title__c titleGen = new Title__c(Name='TestTitle12', Video_Version__c='0123456790',Formats__c='HD;BD',First_Available_Date__c=system.today(),
                                      Expiration_Date__c=system.today()+365,MPM__c = mpmGen.id,Studio__c='BBC',Genre__c='ACTION',
                                      Short_Synopsis__c='short description',Digital_Planning__c='YES');
		
		testTitleList.add(title);
		testTitleList.add(titleGen);
        insert testTitleList;
        system.assertNotEquals(0,testTitleList.size());
        
        // Test Language
        List<Language__c> listLang = new List<Language__c>();
        Language__c Language = new Language__c (Name='English',Language_Order__c = 1);
        listLang.add(Language);
        //insert Language2;
        insert listLang;
        system.assertNotEquals(0,listLang.size());
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        insert listAvailLang;
        system.assertNotEquals(0,listAvailLang.size());
        
        // Test country for country grp 
        country__c con= new country__c(Name='USA',Country_Code__c='US', Country_Code2__c='US',Channel__c='EST');
        insert con;
        system.assertNotEquals(null,con);
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
        insert langPrefTest;
        system.assertNotEquals(null,langPrefTest);
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestRytGrp');
        insert conGrp;
        system.assertNotEquals(null,conGrp);
        
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        system.assertNotEquals(null,conGrpCon);
        
        //test locale
        Rights_Group__c lacle = new Rights_Group__c(Name='en_US',Country__c=con.Id, Language__c=listLang[0].Id, Release_Locale__c='en_US');
        insert lacle;
        system.assertNotEquals(null,lacle);
        
        MPM_Release_Date__c mpmRD1 = new MPM_Release_Date__c(); 
        mpmRD1.Country__c = con.id;
        mpmRD1.Language__c = Language.id;
        mpmRD1.Locale__c = 'jp_CH'; 
        mpmRD1.MPM__c = mpmGen.id;
        mpmRD1.Record_Status__c ='Active'; 
        mpmRD1.Channel__c = 'Hotel';
        mpmRD1.Format__c = 'SD';
        mpmRD1.Avail_Start__c=date.today(); 
        mpmRD1.Release_Start__c= date.today();
        mpmRD1.Release_Status__c='Confirmed';
		mpmRD1.Key__c = '2004592_jp_CH_Hotel_SD';
        insert mpmRD1;
		
		List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        
        commercial_avail__c commAvailTest4= new commercial_avail__c(); 
        commAvailTest4.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest4.Exclusive_Date__c=date.today().addDays(4); 
        commAvailTest4.Start_Date__c= date.today().addDays(6); 
        commAvailTest4.End_Date__c=date.parse( '12/31/2049');
        commAvailTest4.status__c='Tentative';
        commAvailTest4.Reason_Code__c='No Rights';
        commAvailTest4.Country_Lookup__c = con.id;
        commAvailTest4.title__c = title.id;
        commAvailTest4.Languages__c = Language.id;
        commAvailTest4.Channel__c = 'EST';
        commAvailTest4.Format__c = 'HD';
        commAvailTest4.Release_Locale__c = null;
        listComm.add(commAvailTest4);
        
		commercial_avail__c commAvailTest5= new commercial_avail__c(); 
        commAvailTest5.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest5.Exclusive_Date__c=date.today().addDays(4); 
        commAvailTest5.Start_Date__c= date.today().addDays(6); 
        commAvailTest5.End_Date__c=date.parse( '12/31/2049');
        commAvailTest5.status__c='Tentative';
        commAvailTest5.Reason_Code__c='No Rights';
        commAvailTest5.Country_Lookup__c = con.id;
        commAvailTest5.title__c = titleGen.id;
        commAvailTest5.Languages__c = Language.id;
        commAvailTest5.Channel__c = 'EST';
        commAvailTest5.Format__c = 'SD';
		commAvailTest5.MRD_ID__c = mpmRD1.id;
        commAvailTest5.Release_Locale__c = 'jp_CH';
        listComm.add(commAvailTest5);
		
		commercial_avail__c commAvailTest6= new commercial_avail__c(); 
		commAvailTest6.Rights_End__c=date.parse( '12/31/2049'); 
		commAvailTest6.Exclusive_Date__c=date.today().addDays(4); 
		//commAvailTest6.Start_Date__c= date.today().addDays(6); 
		//commAvailTest6.End_Date__c=date.parse( '12/31/2049');
		commAvailTest6.status__c='Draft';
		commAvailTest6.Reason_Code__c='No Rights';
		commAvailTest6.Country_Lookup__c = con.id;
		commAvailTest6.title__c = titleGen.id;
		commAvailTest6.Languages__c = Language.id;
		commAvailTest6.Channel__c = 'EST';
		commAvailTest6.Format__c = 'HD';
		commAvailTest6.MRD_ID__c = mpmRD1.id;
		commAvailTest6.Release_Locale__c = 'jp_CH';
		listComm.add(commAvailTest6);
		
		commercial_avail__c commAvailTest7= new commercial_avail__c(); 
		commAvailTest7.Rights_End__c=date.parse( '12/31/2050'); 
		commAvailTest7.Exclusive_Date__c=date.today().addDays(5); 
		commAvailTest7.Start_Date__c= date.today().addDays(7); 
		commAvailTest7.End_Date__c=date.parse( '12/31/2050');
		commAvailTest7.status__c='Confirmed';
		commAvailTest7.Reason_Code__c='No Rights';
		commAvailTest7.Country_Lookup__c = con.id;
		commAvailTest7.title__c = titleGen.id;
		commAvailTest7.Languages__c = Language.id;
		commAvailTest7.Channel__c = 'EST';
		commAvailTest7.Format__c = 'BD';
		commAvailTest7.MRD_ID__c = mpmRD1.id;
		commAvailTest7.Release_Locale__c = 'jp_CH';
		listComm.add(commAvailTest7);
		
		
		commercial_avail__c commAvailTest8= new commercial_avail__c(); 
		commAvailTest8.Rights_End__c=date.parse('12/31/2050'); 
		commAvailTest8.Exclusive_Date__c=date.today().addDays(5); 
		commAvailTest8.Start_Date__c= date.today().addDays(7); 
		commAvailTest8.End_Date__c=date.parse( '12/31/2050');
		commAvailTest8.status__c='Confirmed';
		commAvailTest8.Reason_Code__c='No Rights';
		commAvailTest8.Country_Lookup__c = con.id;
		commAvailTest8.title__c = title.id;
		commAvailTest8.Languages__c = Language.id;
		commAvailTest8.Channel__c = 'Hotel';
		commAvailTest8.Format__c = 'SD';
		commAvailTest8.MRD_ID__c = mpmRD1.id;   //2004592_jp_CH_Hotel_SD
		commAvailTest8.Release_Locale__c = 'jp_CH';
		listComm.add(commAvailTest8);
       
        insert listComm;
        
        system.assertEquals(5,listComm.size());
         List<commercial_avail__c>listCommAvail = new List<commercial_avail__c>();
        
        // check if draft can overlap or not with commAvailTest8
        commercial_avail__c commAvailTCheck9= new commercial_avail__c(); 
		commAvailTCheck9.Rights_End__c=date.parse('12/31/2050'); 
		commAvailTCheck9.Exclusive_Date__c=date.today().addDays(5); 
		//commAvailTCheck9.Start_Date__c= null;
		//commAvailTCheck9.End_Date__c=null;
		commAvailTCheck9.status__c='Draft';
		commAvailTCheck9.Reason_Code__c='No Rights';
		commAvailTCheck9.Country_Lookup__c = con.id;
		commAvailTCheck9.title__c = title.id;
		commAvailTCheck9.Languages__c = Language.id;
		commAvailTCheck9.Channel__c = 'Hotel';
		commAvailTCheck9.Format__c = 'SD';
		commAvailTCheck9.MRD_ID__c = mpmRD1.id;   //2004592_jp_CH_Hotel_SD
		commAvailTCheck9.Release_Locale__c = 'jp_CH';
		listCommAvail.add(commAvailTCheck9);
      
       
          // check if draft can overlap or not with commAvailTest7
       commercial_avail__c commAvailTest10= new commercial_avail__c(); 
		commAvailTest10.Rights_End__c=date.parse( '11/30/2050'); 
		commAvailTest10.Exclusive_Date__c=date.today().addDays(5); 
		//commAvailTest10.Start_Date__c= date.today().addDays(7); 
		//commAvailTest10.End_Date__c=date.parse( '12/31/2050');
		commAvailTest10.status__c='Open';
		commAvailTest10.Reason_Code__c='No Rights';
		commAvailTest10.Country_Lookup__c = con.id;
		commAvailTest10.title__c = titleGen.id;
		commAvailTest10.Languages__c = Language.id;
		commAvailTest10.Channel__c = 'EST';
		commAvailTest10.Format__c = 'BD';
		commAvailTest10.MRD_ID__c = mpmRD1.id;
		commAvailTest10.Release_Locale__c = 'jp_CH';
		listCommAvail.add(commAvailTest10);
        
        commercial_avail__c commAvailTest11= new commercial_avail__c(); 
		commAvailTest11.Rights_End__c=date.parse( '12/31/2051'); 
		commAvailTest11.Exclusive_Date__c=date.today().addDays(2); 
		//commAvailTest10.Start_Date__c= date.today().addDays(7); 
		//commAvailTest10.End_Date__c=date.parse( '12/31/2050');
		commAvailTest11.status__c='Confirmed';
		commAvailTest11.Reason_Code__c='No Rights';
		commAvailTest11.Country_Lookup__c = con.id;
		commAvailTest11.title__c = titleGen.id;
		commAvailTest11.Languages__c = Language.id;
		commAvailTest11.Channel__c = 'EST';
		commAvailTest11.Format__c = 'BD';
		commAvailTest11.MRD_ID__c = mpmRD1.id;
		commAvailTest11.Release_Locale__c = 'jp_CH';
		listCommAvail.add(commAvailTest11);


		// For check overallping with commAvailTest6      
        commercial_avail__c commAvailTest12= new commercial_avail__c(); 
		commAvailTest12.Rights_End__c=date.parse( '12/31/2049'); 
		commAvailTest12.Exclusive_Date__c=date.today().addDays(4); 
		commAvailTest12.Start_Date__c=  date.today().addDays(6); 
		commAvailTest12.End_Date__c= date.parse( '12/31/2049');
		commAvailTest12.status__c='Draft';
		commAvailTest12.Reason_Code__c='No Rights';
		commAvailTest12.Country_Lookup__c = con.id;
		commAvailTest12.title__c = titleGen.id;
		commAvailTest12.Languages__c = Language.id;
		commAvailTest12.Channel__c = 'EST';
		commAvailTest12.Format__c = 'HD';
		commAvailTest12.MRD_ID__c = mpmRD1.id;
		commAvailTest12.Release_Locale__c = 'jp_CH';
		listCommAvail.add(commAvailTest12);
	
        
        Database.SaveResult[] saveResultList = Database.insert(listCommAvail, false);

		for (Database.SaveResult sr : saveResultList) {
			if (sr.isSuccess()) {
				// Operation was successful, so get the ID of the record that was processed
				System.debug('__ Not OK--Because Successfully inserted Record.  ID: ' + sr.getId());
			}else {
				// Operation failed, so get all errors                
				for(Database.Error err : sr.getErrors()) {				 
					System.debug('Error StatusCode--'+err.getStatusCode() + ': Message' + err.getMessage());
					system.assert(err.getMessage().contains('Avails Overlapping'));
				}
			}
		}
    }
    /*ER-003468*/ 
	
	//ER-007484 - Map Release Locale to Release Plan on Insert Operation
    @isTest
    public static void testAddReleaseLocalOnRPInsert(){
        List<MPM__c> mpmList = new  List<MPM__c>();
        MPM__c mpm = new MPM__c(name='2004592',MPM_Number__c='2004592',Generic__c = false);
        MPM__c mpmGen = new MPM__c(name='2004593',MPM_Number__c='2004593',Generic__c = true);
        mpmList.add(mpm);
		mpmList.add(mpmGen);
		insert mpmList;
		
		//test title
        list<title__c> testTitleList= new list<title__c>();
        Title__c title = new Title__c(Name='TestTitle11', Video_Version__c='0123456799',Formats__c='HD;BD',First_Available_Date__c=system.today(),
                                      Expiration_Date__c=system.today()+365,MPM__c = mpm.id,Genre__c='ACTION',
                                      Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        Title__c titleGen = new Title__c(Name='TestTitle12', Video_Version__c='0123456790',Formats__c='HD;BD',First_Available_Date__c=system.today(),
                                      Expiration_Date__c=system.today()+365,MPM__c = mpmGen.id,Genre__c='ACTION',
                                      Short_Synopsis__c='short description',Digital_Planning__c='YES');
		
		testTitleList.add(title);
		testTitleList.add(titleGen);
        insert testTitleList;
        
        // Test Language
        Language__c Language = new Language__c (Name='English',Language_Order__c = 1);
        insert Language;
        
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        insert availLangTitle1;
        
        // Test country for country grp 
        country__c con= new country__c(Name='USA',Country_Code__c='US', Country_Code2__c='US',Channel__c='EST');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
        insert langPrefTest;
        
        //test locale
        Rights_Group__c lacle = new Rights_Group__c(Name='en_US',Country__c=con.Id, Language__c=Language.Id, Release_Locale__c='en_US');
        insert lacle;
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        
        commercial_avail__c commAvailTest4= new commercial_avail__c(); 
        commAvailTest4.Rights_End__c=date.today().addDays(10); 
        commAvailTest4.Exclusive_Date__c=date.today();
        commAvailTest4.Start_Date__c= date.today();
        commAvailTest4.End_Date__c=date.today().addDays(10); 
        commAvailTest4.status__c='Tentative';
        commAvailTest4.Reason_Code__c='No Rights';
        commAvailTest4.Country_Lookup__c = con.id;
        commAvailTest4.title__c = title.id;
        commAvailTest4.Languages__c = Language.id;
        commAvailTest4.Channel__c = 'EST';
        commAvailTest4.Format__c = 'HD';
        listComm.add(commAvailTest4);
        
		commercial_avail__c commAvailTest5= new commercial_avail__c(); 
        commAvailTest5.Rights_End__c=date.today().addDays(10); 
        commAvailTest5.Exclusive_Date__c=date.today(); 
        commAvailTest5.Start_Date__c= date.today(); 
        commAvailTest5.End_Date__c=date.today().addDays(10); 
        commAvailTest5.status__c='Tentative';
        commAvailTest5.Reason_Code__c='No Rights';
        commAvailTest5.Country_Lookup__c = con.id;
        commAvailTest5.title__c = titleGen.id;
        commAvailTest5.Languages__c = Language.id;
        commAvailTest5.Channel__c = 'EST';
        commAvailTest5.Format__c = 'SD';
	    listComm.add(commAvailTest5);
	    
	    insert listComm;
		
	    for(commercial_avail__c rp : [Select Id,Release_Locale__c From commercial_avail__c Where title__c =:title.id]){
	       System.assertEquals('en_US',rp.Release_Locale__c,'Release Local Populated on RP while creation');
	    }
	    for(commercial_avail__c rp : [Select Id,Release_Locale__c From commercial_avail__c Where title__c =:titleGen.id]){
	       System.assertEquals(null,rp.Release_Locale__c,'Release Local not Populated on RP while creation');
	    }
    }
    
     /*ER-007534 - Premium RPs Roll Up Test Case*/ 
    @isTest
    public static void testPremiumRPMPMRollup(){
        List<MPM__c> mpmList = new  List<MPM__c>();
        MPM__c mpm = new MPM__c(name='2004592',MPM_Number__c='2004592',Generic__c = false);
        MPM__c mpmGen = new MPM__c(name='2004593',MPM_Number__c='2004593',Generic__c = true);
        mpmList.add(mpm);
		mpmList.add(mpmGen);
		insert mpmList;
		
		//test title
        list<title__c> testTitleList= new list<title__c>();
        Title__c title = new Title__c(Name='TestTitle11', Video_Version__c='0123456799',Formats__c='HD;BD',First_Available_Date__c=system.today(),
                                      Expiration_Date__c=system.today()+365,MPM__c = mpm.id,Genre__c='ACTION',
                                      Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        Title__c titleGen = new Title__c(Name='TestTitle12', Video_Version__c='0123456790',Formats__c='HD;BD',First_Available_Date__c=system.today(),
                                      Expiration_Date__c=system.today()+365,MPM__c = mpmGen.id,Genre__c='ACTION',
                                      Short_Synopsis__c='short description',Digital_Planning__c='YES');
		
		testTitleList.add(title);
		testTitleList.add(titleGen);
        insert testTitleList;
        
        // Test Language
        Language__c Language = new Language__c (Name='English',Language_Order__c = 1);
        insert Language;
        
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        insert availLangTitle1;
        
        // Test country for country grp 
        country__c con= new country__c(Name='USA',Country_Code__c='US', Country_Code2__c='US',Channel__c='EST');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
        insert langPrefTest;
        
        //test locale
        Rights_Group__c lacle = new Rights_Group__c(Name='en_US',Country__c=con.Id, Language__c=Language.Id, Release_Locale__c='en_US');
        insert lacle;
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        for(Title__c titleObj : testTitleList){
            //Add Premium RPs
            for(integer i=0;i<2;i++){
                for (integer j=0;j<2;j++){
                    commercial_avail__c pRP= new commercial_avail__c(); 
                    pRP.Exclusive_Date__c=date.today();
                    pRP.Rights_End__c=date.today().addDays(10); 
                    pRP.Start_Date__c= date.today();
                    pRP.End_Date__c=date.today().addDays(10); 
                    pRP.status__c='Tentative';
                    pRP.Reason_Code__c='No Rights';
                    pRP.Country_Lookup__c = con.id;
                    pRP.title__c = titleObj.id;
                    pRP.Languages__c = Language.id;
                    pRP.Channel__c = i==0 ? 'EST' : 'VODi';
                    pRP.Format__c = j==0 ? 'HD' : 'SD';
                    listComm.add(pRP);
                }
            }
            
            //Add Non-Premium RPs
            for(integer i=0;i<2;i++){
                for (integer j=0;j<2;j++){
                    commercial_avail__c npRP= new commercial_avail__c(); 
                    npRP.Exclusive_Date__c=date.today().addDays(11); 
                    npRP.Rights_End__c=date.today().addDays(21); 
                    npRP.Start_Date__c= date.today().addDays(11); 
                    npRP.End_Date__c=date.today().addDays(21); 
                    npRP.status__c='Tentative';
                    npRP.Reason_Code__c='No Rights';
                    npRP.Country_Lookup__c = con.id;
                    npRP.title__c = titleObj.id;
                    npRP.Languages__c = Language.id;
                    npRP.Channel__c = i==0 ? 'EST' : 'VODi';
                    npRP.Format__c = j==0 ? 'HD' : 'SD';
                    listComm.add(npRP);
                }
            }
        }
        insert listComm;
        
        Test.startTest();
        
        for(commercial_avail__c rp : [Select Id,MPMRD_Mismatch__c,MPM_Release_Date_Key__c,Premium_Window__c,MRD_Roll_up__c From commercial_avail__c Where title__c =:title.id]){
            System.assertEquals(True,rp.MPMRD_Mismatch__c,'MRD Mismatch should be True Non-Premium RP');
            System.assertNotEquals(null,rp.MPM_Release_Date_Key__c,'MRD Key should not be null Non-Premium RP');
            System.assertEquals(True,rp.MRD_Roll_up__c,'MRD Rpll Up should be True for Non-Premium RP');
	       
	    }
	    for(commercial_avail__c rp : [Select Id,MPMRD_Mismatch__c,MPM_Release_Date_Key__c,MRD_Roll_up__c From commercial_avail__c Where title__c =:titleGen.id]){
	       System.assertEquals(False,rp.MPMRD_Mismatch__c,'MRD Mismatch should be False for Generic RP');
	       System.assertEquals(null,rp.MPM_Release_Date_Key__c,'MRD Key should be null for Genric RP');
	       System.assertEquals(False,rp.MRD_Roll_up__c,'MRD Rpll Up should be False for Genric RP');
	    }
	    
        List<Commercial_Avail__c> lstReleasePlan = [SELECT Id, Name, Title__c, Title__r.MPM__c, Exclusive_Date__c, Start_Date__c, Status__c,Premium_Window__c, 
                                    MPM_Release_Date_Key__c, Languages__c, Country_Lookup__c, Channel__c, Format__c, Release_Locale__c,MRD_ID__c  
                                    FROM Commercial_Avail__c Where MPM_Release_Date_Key__c != null AND (MRD_Roll_up__c = True OR MPMRD_Mismatch__c = TRUE)];
        
        WB_TriggerRecursionHelper.isBatchWB_Batch_MPMRD_Rollup= true;
        WB_CheckingDateOverlapController.UpdateMRMReleaseDate(lstReleasePlan);
        WB_TriggerRecursionHelper.isBatchWB_Batch_MPMRD_Rollup= false;
        
        for(commercial_avail__c rp : [Select Id,MPMRD_Mismatch__c,MPM_Release_Date_Key__c,MRD_Roll_up__c,Premium_Window__c,MRD_ID__c,MRD_ID__r.Release_Start__c From commercial_avail__c Where title__c =:title.id]){
            System.assertEquals(False,rp.MRD_Roll_up__c,'MRD Rpll Up should be False for after Roll-up for Non-Premium RP');
            System.assertEquals(False,rp.MPMRD_Mismatch__c,'MRD Mismatch should be False after Roll up for Non-Premium RP');
            System.assertNotEquals(null,rp.MPM_Release_Date_Key__c,'MRD Key should not be null after Roll up for  Non-Premium RP');
            System.assertNotEquals(null,rp.MRD_ID__c,'MRD ID should be not be null for Non-Premium RP');
            System.assertEquals(date.today(),rp.MRD_ID__r.Release_Start__c,'Non-Premium RP dates should be Rolled up');
        }
        
        listComm[0].Premium_Window__c = True;
        listComm[1].Premium_Window__c = True;
        listComm[2].Premium_Window__c = True;
        listComm[3].Premium_Window__c = True;
        List<commercial_avail__c> premiumRPs = new List<commercial_avail__c>();
        premiumRPs.add(listComm[0]);
        premiumRPs.add(listComm[1]);
        premiumRPs.add(listComm[2]);
        premiumRPs.add(listComm[3]);
        
        WB_CheckingDateOverlapController.isRunning_BatchMRMRollup = False;
        update premiumRPs;
        
        for(commercial_avail__c rp : [Select Id,MPMRD_Mismatch__c,MPM_Release_Date_Key__c,MRD_Roll_up__c,Premium_Window__c From commercial_avail__c Where title__c =:title.id]){
            if(rp.Premium_Window__c){
                System.assertEquals(TRUE,rp.MRD_Roll_up__c,'MRD Rpll Up should be TRUE after updating Premium Window Flag on RP');
                System.assertEquals(TRUE,rp.MPMRD_Mismatch__c,'MRD Mismatch should be TRUE after updating Premium Window Flag on RP');
                System.assertNotEquals(null,rp.MPM_Release_Date_Key__c,'MRD Key should not be null after updating Premium Window Flag on RP');
            }else{
                System.assertEquals(False,rp.MRD_Roll_up__c,'MRD Rpll Up should be False for Non-Premium RP');
                System.assertEquals(False,rp.MPMRD_Mismatch__c,'MRD Mismatch should remains False');
                System.assertNotEquals(null,rp.MPM_Release_Date_Key__c,'MRD Key should not be null for Non-Premium RP');
            }
        }
        
        lstReleasePlan = [SELECT Id, Name, Title__c, Title__r.MPM__c, Exclusive_Date__c, Start_Date__c, Status__c,Premium_Window__c, 
                                    MPM_Release_Date_Key__c, Languages__c, Country_Lookup__c, Channel__c, Format__c, Release_Locale__c,MRD_ID__c  
                                    FROM Commercial_Avail__c Where MPM_Release_Date_Key__c != null AND (MRD_Roll_up__c = True OR MPMRD_Mismatch__c = TRUE)];
        WB_TriggerRecursionHelper.isBatchWB_Batch_MPMRD_Rollup= true;
        WB_CheckingDateOverlapController.UpdateMRMReleaseDate(lstReleasePlan);
        WB_TriggerRecursionHelper.isBatchWB_Batch_MPMRD_Rollup= false;
        
        for(commercial_avail__c rp : [Select Id,MPMRD_Mismatch__c,MPM_Release_Date_Key__c,Premium_Window__c,MRD_Roll_up__c,MRD_ID__c,MRD_ID__r.Release_Start__c From commercial_avail__c Where title__c =:title.id]){
            if(rp.Premium_Window__c){
                System.assertEquals(null,rp.MRD_ID__c, 'MRD ID should be null for Premium RP after updating MPMRD Release Date');
                System.assertEquals(False,rp.MPMRD_Mismatch__c,'MRD Mismatch should be False for Premium RP after updating MPMRD Release Date');
	            System.assertEquals(null,rp.MPM_Release_Date_Key__c,'MRD Key should be null for Premium RP');
	            System.assertEquals(False,rp.MRD_Roll_up__c,'MRD Rpll Up should be False for Premium RP');
	        }else{
                System.assertEquals(False,rp.MRD_Roll_up__c,'MRD Rpll Up should be False for Non-Premium RP');
                System.assertEquals(False,rp.MPMRD_Mismatch__c,'MRD Mismatch should remains False');
                System.assertNotEquals(null,rp.MPM_Release_Date_Key__c,'MRD Key should not be null for Non-Premium RP');
                System.assertEquals(date.today().addDays(11),rp.MRD_ID__r.Release_Start__c,'Non-Premium RP dates should get updated to Non-Premium RPs earliest date');
            }
	    }
        
        Test.stopTest();
    }
    
     /*ER-007534*/ 
    @isTest
    public static void testPremiumRPMPMRollupToCancelMPMRD(){
        List<MPM__c> mpmList = new  List<MPM__c>();
        MPM__c mpm = new MPM__c(name='2004592',MPM_Number__c='2004592',Generic__c = false);
        mpmList.add(mpm);
		insert mpmList;
		
		//test title
        list<title__c> testTitleList= new list<title__c>();
        Title__c title = new Title__c(Name='TestTitle11', Video_Version__c='0123456799',Formats__c='HD;BD',First_Available_Date__c=system.today(),
                                      Expiration_Date__c=system.today()+365,MPM__c = mpm.id,Genre__c='ACTION',
                                      Short_Synopsis__c='short description',Digital_Planning__c='YES');
		
		testTitleList.add(title);
        insert testTitleList;
        
        // Test Language
        Language__c Language = new Language__c (Name='English',Language_Order__c = 1);
        insert Language;
        
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        insert availLangTitle1;
        
        // Test country for country grp 
        country__c con= new country__c(Name='USA',Country_Code__c='US', Country_Code2__c='US',Channel__c='EST');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
        insert langPrefTest;
        
        //test locale
        Rights_Group__c lacle = new Rights_Group__c(Name='en_US',Country__c=con.Id, Language__c=Language.Id, Release_Locale__c='en_US');
        insert lacle;
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        for(Title__c titleObj : testTitleList){
            //Add Premium RPs
            for(integer i=0;i<2;i++){
                for (integer j=0;j<2;j++){
                    commercial_avail__c pRP= new commercial_avail__c(); 
                    pRP.Exclusive_Date__c=date.today();
                    pRP.Rights_End__c=date.today().addDays(10); 
                    pRP.Start_Date__c= date.today();
                    pRP.End_Date__c=date.today().addDays(10); 
                    pRP.status__c='Tentative';
                    pRP.Reason_Code__c='No Rights';
                    pRP.Country_Lookup__c = con.id;
                    pRP.title__c = titleObj.id;
                    pRP.Languages__c = Language.id;
                    pRP.Channel__c = i==0 ? 'EST' : 'VODi';
                    pRP.Format__c = j==0 ? 'HD' : 'SD';
                    listComm.add(pRP);
                }
            }
        }
        insert listComm;
        
        Test.startTest();
        
        for(commercial_avail__c rp : [Select Id,MPMRD_Mismatch__c,MPM_Release_Date_Key__c,Premium_Window__c,MRD_Roll_up__c From commercial_avail__c Where title__c =:title.id]){
            System.assertEquals(True,rp.MPMRD_Mismatch__c,'MRD Mismatch should be True Non-Premium RP');
            System.assertNotEquals(null,rp.MPM_Release_Date_Key__c,'MRD Key should not be null Non-Premium RP');
            System.assertEquals(True,rp.MRD_Roll_up__c,'MRD Rpll Up should be True for Non-Premium RP');
	       
	    }
	    
	    List<Commercial_Avail__c> lstReleasePlan = [SELECT Id, Name, Title__c, Title__r.MPM__c, Exclusive_Date__c, Start_Date__c, Status__c,Premium_Window__c, 
                                    MPM_Release_Date_Key__c, Languages__c, Country_Lookup__c, Channel__c, Format__c, Release_Locale__c,MRD_ID__c  
                                    FROM Commercial_Avail__c Where MPM_Release_Date_Key__c != null AND (MRD_Roll_up__c = True OR MPMRD_Mismatch__c = TRUE)];
        
        WB_TriggerRecursionHelper.isBatchWB_Batch_MPMRD_Rollup= true;
        WB_CheckingDateOverlapController.UpdateMRMReleaseDate(lstReleasePlan);
        WB_TriggerRecursionHelper.isBatchWB_Batch_MPMRD_Rollup= false;
        
        for(commercial_avail__c rp : [Select Id,MPMRD_Mismatch__c,MPM_Release_Date_Key__c,MRD_Roll_up__c,Premium_Window__c,MRD_ID__c,MRD_ID__r.Release_Start__c From commercial_avail__c Where title__c =:title.id]){
            System.assertEquals(False,rp.MRD_Roll_up__c,'MRD Rpll Up should be False for after Roll-up for Non-Premium RP');
            System.assertEquals(False,rp.MPMRD_Mismatch__c,'MRD Mismatch should be False after Roll up for Non-Premium RP');
            System.assertNotEquals(null,rp.MPM_Release_Date_Key__c,'MRD Key should not be null after Roll up for  Non-Premium RP');
            System.assertNotEquals(null,rp.MRD_ID__c,'MRD ID should be not be null for Non-Premium RP');
            System.assertEquals(date.today(),rp.MRD_ID__r.Release_Start__c,'Non-Premium RP dates should be Rolled up');
        }
        
        listComm[0].Premium_Window__c = True;
        listComm[1].Premium_Window__c = True;
        listComm[2].Premium_Window__c = True;
        listComm[3].Premium_Window__c = True;
        List<commercial_avail__c> premiumRPs = new List<commercial_avail__c>();
        premiumRPs.add(listComm[0]);
        premiumRPs.add(listComm[1]);
        premiumRPs.add(listComm[2]);
        premiumRPs.add(listComm[3]);
        
        WB_CheckingDateOverlapController.isRunning_BatchMRMRollup = False;
        update premiumRPs;
        
        for(commercial_avail__c rp : [Select Id,MPMRD_Mismatch__c,MPM_Release_Date_Key__c,MRD_Roll_up__c,Premium_Window__c From commercial_avail__c Where title__c =:title.id]){
            if(rp.Premium_Window__c){
                System.assertEquals(TRUE,rp.MRD_Roll_up__c,'MRD Rpll Up should be TRUE after updating Premium Window Flag on RP');
                System.assertEquals(TRUE,rp.MPMRD_Mismatch__c,'MRD Mismatch should be TRUE after updating Premium Window Flag on RP');
                System.assertNotEquals(null,rp.MPM_Release_Date_Key__c,'MRD Key should not be null after updating Premium Window Flag on RP');
            }
        }
        
        lstReleasePlan = [SELECT Id, Name, Title__c, Title__r.MPM__c, Exclusive_Date__c, Start_Date__c, Status__c,Premium_Window__c, 
                                    MPM_Release_Date_Key__c, Languages__c, Country_Lookup__c, Channel__c, Format__c, Release_Locale__c,MRD_ID__c  
                                    FROM Commercial_Avail__c Where MPM_Release_Date_Key__c != null AND (MRD_Roll_up__c = True OR MPMRD_Mismatch__c = TRUE)];
        WB_TriggerRecursionHelper.isBatchWB_Batch_MPMRD_Rollup= true;
        WB_CheckingDateOverlapController.UpdateMRMReleaseDate(lstReleasePlan);
        WB_TriggerRecursionHelper.isBatchWB_Batch_MPMRD_Rollup= false;
        
        for(commercial_avail__c rp : [Select Id,MPMRD_Mismatch__c,MPM_Release_Date_Key__c,Premium_Window__c,MRD_Roll_up__c,MRD_ID__c,MRD_ID__r.Release_Start__c From commercial_avail__c Where title__c =:title.id]){
            if(rp.Premium_Window__c){
                System.assertEquals(null,rp.MRD_ID__c, 'MRD ID should be null for Premium RP after updating MPMRD Release Date');
                System.assertEquals(False,rp.MPMRD_Mismatch__c,'MRD Mismatch should be False for Premium RP after updating MPMRD Release Date');
	            System.assertEquals(null,rp.MPM_Release_Date_Key__c,'MRD Key should be null for Premium RP');
	            System.assertEquals(False,rp.MRD_Roll_up__c,'MRD Rpll Up should be False for Premium RP');
	        }
	    }
        
        for(MPM_Release_Date__c mrd : [SELECT Id, Release_Status__c FROM MPM_Release_Date__c]){
            System.assertEquals('Cancel',mrd.Release_Status__c, 'MRD status set to Cancel');
	    }
	    
        Test.stopTest();
    }
}