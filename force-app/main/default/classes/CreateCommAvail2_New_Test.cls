/*
 Modified by: Purushottam Gupta
 Modified On: 28th Dec 2016
 Description: Added the Required feild for Rights Object Record insert,changes Channel value from DTD to EST as DTD No longer exist on channel of Rights Object.
 */

@isTest
private class CreateCommAvail2_New_Test{
    
    @isTest
    static void CommAvail2Test() {
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch1',RP_Batch_Id__c='1' );
        insert batchIDs;
        
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        list<title__c> testTitleList= new list<title__c>();
        Title__c title = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',
                First_Available_Date__c=system.today(),Expiration_Date__c=system.today()+365,MPM__c = mpm.id,
                Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES',Formats__c='HD'
        );
        
        Title__c title1 = new Title__c(Name='TestTitle', Video_Version__c='012345677868',Formats__c='HD',First_Available_Date__c=system.today(),
                                  MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        testTitleList.add(title);
        testTitleList.add(title1);
        insert testTitleList;
        
        Language__c Language = new Language__c (Name='English', Language_Order__c = 1);
        insert Language;
        
        Language__c Language1 = new Language__c (Name='Spanish', Language_Order__c = 1);
        insert Language1;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=false);
        listAvailLang.add(availLangTitle2);
        Available_Languages__c availLangTitle3 = new Available_Languages__c(Language__c=Language1.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle3);
        Available_Languages__c availLangTitle4 = new Available_Languages__c(Language__c=Language1.Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle4);
        
        
        Country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST');
        insert con;
        
        Language_Preference__c langPrefTest3= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='3');
        insert langPrefTest3;
        
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
        insert langPrefTest;
        
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Language__c=Language1.Id,Level__c='1');
        insert langPrefTest1;
        
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
        insert conGrp;
        
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        List<Commercial_Avail__c> lstCommAvail = new List<Commercial_Avail__c>();
        Commercial_Avail__c commTest = new Commercial_Avail__c(
            Title__c = title1.Id, Channel__c = 'DTD', Format__c = 'HD', Country_Lookup__c = con.Id, Languages__c = Language.Id,
            Language_Type__c = 'Dub', end_date__c = system.today()+190, start_Date__c = system.today()+10,
            Rights_End__c=system.today()+200,Exclusive_Date__c=(system.today()+2)
        );
        lstCommAvail.add(commTest);
        
        Commercial_Avail__c commTest1 = new Commercial_Avail__c(
            Title__c = title1.Id, Channel__c = 'DTD', Format__c = 'HD', Country_Lookup__c = con.Id, Languages__c = Language.Id,
            Language_Type__c = 'Sub', end_date__c = system.today()+190, start_Date__c = system.today()+10,
            Rights_End__c=system.today()+200,Exclusive_Date__c=(system.today()+2)
        );
        //lstCommAvail.add(commTest1);
        insert lstCommAvail;
        
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        caList.add(new Commercial_Avail__c(Country_Group__c=conGrp.Id));
        
        ApexPages.currentPage().getParameters().put('id', title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        
        WB_CreateCommercialAvail_Controller ccc = new WB_CreateCommercialAvail_Controller(sc);
        
        ccc.countryGrpId = conGrp.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.findCountry();
        ccc.channelgrid();
        
        list<Commercial_Avail__c> commercialAvailList = new list<Commercial_Avail__c>();
        
        Commercial_Avail__c commAvailTest = new Commercial_Avail__c(); 
        commAvailTest.Title__c = title1.Id;
        commAvailTest.Country_Lookup__c = con.Id;
        commAvailTest.Channel__c = 'DTD';
        commAvailTest.Format__c = 'HD';
        commAvailTest.Languages__c = Language.Id;
        
        commAvailTest.Rights_End__c = date.parse( '12/31/2049'); 
        commAvailTest.Exclusive_Date__c = date.parse( '12/31/2000'); 
        commAvailTest.Start_Date__c = system.today().addDays(15);
        commAvailTest.End_Date__c = system.today().addDays(2); 
        commAvailTest.status__c = 'Open';
        commercialAvailList.add(commAvailTest);
        
        Commercial_Avail__c commAvailTest2 = new Commercial_Avail__c(); 
        commAvailTest.Title__c = title1.Id;
        commAvailTest.Country_Lookup__c = con.Id;
        commAvailTest.Channel__c = 'DTD';
        commAvailTest.Format__c = 'HD';
        commAvailTest.Languages__c = Language.Id;
        
        commAvailTest2.Rights_End__c = null; 
        commAvailTest2.Exclusive_Date__c = null; 
        commAvailTest2.Start_Date__c = null; 
        commAvailTest2.End_Date__c = null; 
        commAvailTest2.status__c = 'Open';
        commercialAvailList.add(commAvailTest2);
        
        Commercial_Avail__c commAvailTest3 = new Commercial_Avail__c(); 
        commAvailTest3.Rights_End__c = null; 
        commAvailTest3.Exclusive_Date__c = null; 
        commAvailTest3.Start_Date__c = date.parse( '12/31/2009'); 
        commAvailTest3.End_Date__c = date.parse( '12/31/2014'); 
        commAvailTest3.status__c = null;
        commercialAvailList.add(commAvailTest3);
        
        ccc.commAvailLstValidated(commercialAvailList);
        ccc.clearList();
    }
    
    @isTest
    static void createCommercialAvail() {
        // Test Batch Ids
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch1',RP_Batch_Id__c='1' );
        insert batchIDs;
        // Test tile
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        list<title__c> testTitleList= new list<title__c>();
        Title__c title = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='',First_Available_Date__c=system.today(),
                                      Expiration_Date__c=system.today()+365,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
                                      Short_Synopsis__c='short description',Digital_Planning__c='No');
        
        Title__c title1 = new Title__c(Name='TestTitle', Video_Version__c='012345677868',Formats__c='HD',First_Available_Date__c=system.today(),
                                  MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        testTitleList.add(title);
        testTitleList.add(title1);
        insert testTitleList;
        
        // Test Language
        List<Language__c> listLang = new List<Language__c>();
        Language__c Language = new Language__c (Name='TestLanguage2', Language_Order__c = 1);
        listLang.add(Language);
        //insert Language;
        
        Language__c Language1 = new Language__c (Name='TestLanguage1', Language_Order__c = 1);
        listLang.add(Language1);
        //insert Language1;
        
        Language__c Language2 = new Language__c (Name='TestLanguage3', Language_Order__c = 1);
        listLang.add(Language2);
        //insert Language2;
        insert listLang;
        
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
        
        // Test country for country grp 
        country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST');
        insert con;
        
        // Test Language Preferences
        List<Language_Preference__c> langPrefList  = new List<Language_Preference__c>();
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='3');
        langPrefList.add(langPrefTest);
        //insert langPrefTest;
        
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Language__c=Language1.Id,Level__c='2');
        langPrefList.add(langPrefTest1);
        //insert langPrefTest1;
        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Language__c=Language2.Id,Level__c='1');
        langPrefList.add(langPrefTest2);
        
        Language_Preference__c langPrefTest3= new Language_Preference__c(Country__c=con.Id,Language__c=Language2.Id,Level__c='1');
        langPrefList.add(langPrefTest3);
        //insert langPrefTest2;
        insert langPrefList;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
        insert conGrp;
        
        //Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title1.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                       end_date__c=system.today()+190,start_Date__c=system.today()+10, Rights_End__c=system.today()+200,Exclusive_Date__c=(system.today()+2));
        insert commTest;
        Test.startTest();       
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        caList.add(commRec);
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title1.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateCommercialAvail_Controller ccc = new WB_CreateCommercialAvail_Controller(sc);
        ccc.countryGrpId=conGrpCon.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.obj.Country_Group__c = conGrp.Id;
        ccc.findCountry();
        ccc.channelgrid();
        ccc.cancel();
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        // test channel grid           
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest.Exclusive_Date__c=date.today();
        commAvailTest.Start_Date__c=date.today();
        commAvailTest.End_Date__c=date.parse( '12/31/2049'); 
        commAvailTest.status__c='Open';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Channel__c = null;
        listComm.add(commAvailTest);
        
        // test channel grid-2 on 27 Nov
        commercial_avail__c commAvailTest2= new commercial_avail__c();
        commAvailTest2.Rights_End__c=null;
        commAvailTest2.Exclusive_Date__c=null;
        commAvailTest2.Start_Date__c=null;
        commAvailTest2.End_Date__c=null;
        commAvailTest2.status__c='Open';
        commAvailTest2.Country_Lookup__c = con.id;
        commAvailTest2.title__c = title.id;
        commAvailTest2.Languages__c = Language.id;
        commAvailTest2.Channel__c = null;
        listComm.add(commAvailTest2);
        
        // test channel grid-3 on 27 Nov 
        commercial_avail__c commAvailTest3= new commercial_avail__c();
        commAvailTest3.Rights_End__c=null;
        commAvailTest3.Exclusive_Date__c=null;
        commAvailTest3.Start_Date__c=system.today();
        commAvailTest3.End_Date__c=system.today()+20;
        commAvailTest3.Reason_Code__c='Business Reason';
        commAvailTest3.status__c='Draft';
        commAvailTest3.Country_Lookup__c = con.id;
        commAvailTest3.title__c = title.id;
        commAvailTest3.Languages__c = Language.id;
        commAvailTest3.Channel__c = 'VODi';
        listComm.add(commAvailTest3);
        
        commercial_avail__c commAvailTest4= new commercial_avail__c();
        commAvailTest4.Rights_End__c=date.parse('12/31/2050');
        commAvailTest4.Exclusive_Date__c=date.parse('01/01/2050');
        commAvailTest4.Start_Date__c=date.parse('01/01/2050');
        commAvailTest4.End_Date__c=date.parse('12/31/2050');
        commAvailTest4.status__c='Not Releasing';
        commAvailTest4.Country_Lookup__c = con.id;
        commAvailTest4.title__c = title.id;
        commAvailTest4.Languages__c = Language.id;
        commAvailTest4.Channel__c = 'VODi';
        commAvailTest4.Reason_Code__c = 'Music is not cleared';
        listComm.add(commAvailTest4);
        insert listComm;
        
        Rights_Group__c rightGroup = new Rights_Group__c(Name = 'Australia',Country__c=con.id,Language__c=Language.id);
        insert rightGroup;
        
        Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'Test',Country__c=con.id,Language__c=Language.id,Rights_Group__c = rightGroup.id);
        insert childRightGroup;
        
        Rights__c rights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id,Rights_End__c=system.today()+3, Rights_Group__c = rightGroup.name,Rights_Start__c= system.today(),Status__c='Confirmed',Source__c = 'cosmos');
        insert rights;
        
        ccc.mapRightsDate(listComm);
        
        Release_Plan_Exceptions__c RPExep = new Release_Plan_Exceptions__c(
            Name = UserInfo.getUserId() + '1',
            Avails_Start__c = date.today(),
            Avails_End__c = date.today(),
            Channel__c = 'VODi',
            Country__c = 'Albania',
            Format__c = 'SD',
            Language__c = 'English',
            Reason__c = 'Following overlapping periods have been found with-RP-000356020',
            Release_End_Date__c = date.today(),
            Release_Start_Date__c = date.today(),
            Status__c = 'Draft',
            Title__c = 'Focus (2015)',
            User_Detail__c = UserInfo.getUserId()
        );
        insert RPExep;
        
        
        WB_CreateCommercialAvail_Controller.channelWrapper channelWrapper = new WB_CreateCommercialAvail_Controller.channelWrapper();
        channelWrapper.countryChannel = 'DTD';
        channelWrapper.additionalInfo = commAvailTest;
        ccc.channelGridList.add(channelWrapper);
        WB_CreateCommercialAvail_Controller.channelWrapper channelWrapper2 = new WB_CreateCommercialAvail_Controller.channelWrapper();
        channelWrapper2.countryChannel = 'DTD';
        channelWrapper2.additionalInfo = commAvailTest3; // Added on 27 Nov
        ccc.channelGridList.add(channelWrapper2);  
        WB_CreateCommercialAvail_Controller.channelWrapper channelWrapper3 = new WB_CreateCommercialAvail_Controller.channelWrapper();
        channelWrapper3.countryChannel = 'DTD';
        channelWrapper3.additionalInfo = commAvailTest2; // Added on 27 Nov
        ccc.channelGridList.add(channelWrapper3);
        WB_CreateCommercialAvail_Controller.channelWrapper channelWrapper4 = new WB_CreateCommercialAvail_Controller.channelWrapper();
        channelWrapper3.countryChannel = 'DTD';
        channelWrapper3.additionalInfo = commAvailTest4; 
        ccc.channelGridList.add(channelWrapper4);
        ccc.titleList = testTitleList;
        ccc.bulksave();
        List<commercial_avail__c> listC = [Select id,Title__c,Country_Lookup__c,Channel__c,Format__c,Languages__c,Language_Type__c,Start_Date__c,End_Date__c,Exclusive_Date__c,Rights_End__c,Status__c from commercial_avail__c];
        ccc.commAvailLstValidated(listC);
        ccc.channelGridList[0].additionalInfo.Start_Date__c = system.Today() + 5;
        ccc.channelGridList[1].additionalInfo.Exclusive_Date__c = system.Today() + 5;
        ccc.channelGridList[0].additionalInfo.End_Date__c = system.Today() + 1;
        ccc.channelGridList[1].additionalInfo.Rights_End__c = system.Today() + 1;
        ccc.channelGridList[2].additionalInfo.Status__c = 'Tentative';
        ccc.channelGridList[2].additionalInfo.Start_Date__c = null;
        ccc.channelGridList[2].additionalInfo.End_Date__c = null;
        ccc.channelGridValidation();
        ccc.clearList();
        
        Test.stoptest();
        //ccc.proceedAnyway();
    }
    
    @isTest
    static void createCommercialAvailScen2() {
        // Test Batch Ids
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch1',RP_Batch_Id__c='1' );
        insert batchIDs;
        // Test tile
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        list<title__c> testTitleList= new list<title__c>();
        Title__c title = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today(),
                                  MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        Title__c title1 = new Title__c(Name='TestTitle', Video_Version__c='012345677868',Formats__c='HD',First_Available_Date__c=system.today(),
                                  MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        Title__c title2 = new Title__c(Name='TestTitle', Video_Version__c='012345677865',Formats__c=null,First_Available_Date__c=system.today(),
                                  MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='NO');  
        
        testTitleList.add(title);
        testTitleList.add(title1);
        testTitleList.add(title2);
        insert testTitleList;
        
        // Test Language
        Language__c Language = new Language__c (Name='TestLanguage2', Language_Order__c = 1);
        insert Language;
        
        Language__c Language1 = new Language__c (Name='TestLanguage1', Language_Order__c = 1);
        insert Language1;
        
        Language__c Language2 = new Language__c (Name='TestLanguage3', Language_Order__c = 1);
        insert Language2;
        
        Language__c Language3 = new Language__c (Name='TestLanguage4', Language_Order__c = 1);
        insert Language3;
        
        
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
        Available_Languages__c availLangTitle7 = new Available_Languages__c(Language__c=Language3.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=false);
        listAvailLang.add(availLangTitle7);
        Available_Languages__c availLangTitle8 = new Available_Languages__c(Language__c=Language3.Id ,Language_Types__c='Audio',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle8);
        insert listAvailLang;
        
        // Test country for country grp 
        country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
        insert langPrefTest;
        
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Language__c=Language1.Id,Level__c='1');
        insert langPrefTest1;
        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Language__c=Language2.Id,Level__c='2');
        insert langPrefTest2;
        
        Language_Preference__c langPrefTest3= new Language_Preference__c(Country__c=con.Id,Language__c=Language2.Id,Level__c='3');
        insert langPrefTest3;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
        insert conGrp;
        
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title1.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                       end_date__c=system.today()+190,start_Date__c=system.today()+10, Rights_End__c=system.today()+200,Exclusive_Date__c=(system.today()+2));
        insert commTest;
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        // test channel grid           
        commercial_avail__c commAvail1= new commercial_avail__c(); 
        commAvail1.Rights_End__c=date.parse( '12/31/2049');  
        commAvail1.Exclusive_Date__c=date.today();
        commAvail1.Start_Date__c=date.today();
        commAvail1.End_Date__c=date.parse( '12/31/2049');  
        commAvail1.status__c='Open';
        commAvail1.Country_Lookup__c = con.id;
        commAvail1.title__c = title.id;
        commAvail1.Languages__c = Language.id;
        commAvail1.Channel__c = 'DTD';
        listComm.add(commAvail1);
        
        // test channel grid-2 on 27 Nov
        commercial_avail__c commAvail2= new commercial_avail__c(); 
        commAvail2.Rights_End__c=null; 
        commAvail2.Exclusive_Date__c=null; 
        commAvail2.Start_Date__c=null; 
        commAvail2.End_Date__c=null; 
        commAvail2.status__c='Open';
        commAvail2.Country_Lookup__c = con.id;
        commAvail2.title__c = title.id;
        commAvail2.Languages__c = Language.id;
        commAvail2.Channel__c = 'DTD';
        listComm.add(commAvail2);
        Rights_Group__c rightGroup = new Rights_Group__c(Name = 'Australia',Country__c=con.id,Language__c=Language.id);
        insert rightGroup;
        
        Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'Test',Country__c=con.id,Language__c=Language.id,Rights_Group__c = rightGroup.id);
        insert childRightGroup;
        
        Rights__c rights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id,Rights_End__c=system.today()+3, Rights_Group__c = rightGroup.Name,Rights_Start__c= system.today(),Status__c='Confirmed', Source__c = 'Cosmos');
        insert rights;
        
        
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title1.Id+','+title2.Id);
        ApexPages.currentPage().getParameters().put('param', 'std');
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        Test.starttest();
        WB_CreateCommercialAvail_Controller ccc = new WB_CreateCommercialAvail_Controller(sc);
        ccc.countryGrpId=conGrp.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.findCountry();
        ccc.channelgrid();
        ccc.cancel();
        
        
        // test channel grid
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest.Start_Date__c=date.parse( '12/31/2009'); 
        commAvailTest.End_Date__c=date.parse( '12/31/2014'); 
        commAvailTest.status__c='Not Releasing';
        commAvailTest.reason_code__c='No digital rights';
        
        commercial_avail__c commAvailTest1= new commercial_avail__c();
        commAvailTest1.Start_Date__c=date.parse( '12/31/2009'); 
        commAvailTest1.End_Date__c=date.parse( '12/31/2014'); 
        
        commercial_avail__c commAvailTest2= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest.Exclusive_Date__c=date.parse( '12/31/2000'); 
        //commAvailTest.Start_Date__c=date.parse( '12/31/2009'); 
        //commAvailTest.End_Date__c=date.parse( '12/31/2014'); 
        commAvailTest.status__c='Open';
                
        commercial_avail__c commAvailTest4= new commercial_avail__c();
        commAvailTest4.Rights_End__c=date.parse( '12/31/2050'); 
        commAvailTest4.Exclusive_Date__c=date.today();
        commAvailTest4.Start_Date__c=date.today();
        commAvailTest4.End_Date__c=date.parse( '11/30/2050'); 
        commAvailTest4.title__c = title.id;
        //listComm.add(commAvailTest4);
        
        commercial_avail__c commAvailTest5= new commercial_avail__c();
        commAvailTest5.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest5.Exclusive_Date__c=date.today();
        commAvailTest5.Start_Date__c=date.today();
        commAvailTest5.End_Date__c=date.parse( '12/31/2049');
        commAvailTest5.status__c='Planned';
        commAvailTest5.title__c = title.id;
        //listComm.add(commAvailTest5);
        
        // test channel grid-3 on 27 Nov 
        commercial_avail__c commAvailTest3= new commercial_avail__c(); 
        commAvailTest3.Rights_End__c=null; 
        commAvailTest3.Exclusive_Date__c=null; 
        commAvailTest3.Start_Date__c=system.today(); 
        commAvailTest3.End_Date__c=system.today()+20; 
        commAvailTest3.Reason_Code__c='Business Reason';
        commAvailTest3.status__c='Draft';
        commAvailTest3.Country_Lookup__c = con.id;
        commAvailTest3.title__c = title.id;
        commAvailTest3.Languages__c = Language.id;
        commAvailTest3.Channel__c = 'VODi';
        listComm.add(commAvailTest3);
        
        insert listComm;
        ccc.mapRightsDate(listComm);
        
        WB_CreateCommercialAvail_Controller.channelWrapper channelWrapper = new WB_CreateCommercialAvail_Controller.channelWrapper();
        channelWrapper.countryChannel = 'DTD';
        channelWrapper.additionalInfo = commAvailTest;
        channelWrapper.delIndent = 6;
        channelWrapper.addIndent = 6; 
        
        WB_CreateCommercialAvail_Controller.channelWrapper channelWrapper1 = new WB_CreateCommercialAvail_Controller.channelWrapper();
        channelWrapper1.countryChannel = 'EST';
        channelWrapper1.additionalInfo = commAvailTest3;
        channelWrapper1.delIndent = 6;
        channelWrapper1.addIndent = 6;
        
        WB_CreateCommercialAvail_Controller.channelWrapper channelWrapper2 = new WB_CreateCommercialAvail_Controller.channelWrapper();
        channelWrapper2.countryChannel = 'EST';
        channelWrapper2.additionalInfo = commAvailTest1;
        channelWrapper2.delIndent = 6;
        channelWrapper2.addIndent = 6; 
        
        WB_CreateCommercialAvail_Controller.channelWrapper channelWrapper3 = new WB_CreateCommercialAvail_Controller.channelWrapper();
        channelWrapper3.countryChannel = 'DTD'; 
        channelWrapper3.additionalInfo = commAvailTest2;
        channelWrapper3.delIndent = 6;
        channelWrapper3.addIndent = 6;
        
        WB_CreateCommercialAvail_Controller.channelWrapper channelWrapper4 = new WB_CreateCommercialAvail_Controller.channelWrapper();
        channelWrapper4.countryChannel = 'DTD'; 
        channelWrapper4.additionalInfo = commAvailTest4;
        channelWrapper4.delIndent = 6;
        channelWrapper4.addIndent = 6;
        
        WB_CreateCommercialAvail_Controller.channelWrapper channelWrapper5 = new WB_CreateCommercialAvail_Controller.channelWrapper();
        channelWrapper4.countryChannel = 'DTD'; 
        channelWrapper4.additionalInfo = commAvailTest5;
        channelWrapper4.delIndent = 6;
        channelWrapper4.addIndent = 6;
        
        ccc.channelGridList.add(channelWrapper);
        ccc.channelGridList.add(channelWrapper1);
        ccc.channelGridList.add(channelWrapper2);
        ccc.channelGridList.add(channelWrapper3);
        ccc.channelGridList.add(channelWrapper4);
        ccc.channelGridList.add(channelWrapper5);
        
        ccc.bulksave();
        //ccc.proceedAnyway();
        ccc.addWrapper();
        ccc.grpCountriesFoundMsg = 'Test';
        ccc.NoCountryFoundMsg = 'Test';
        ccc.titleMessage = 'Test';
       // ccc.viewRightsRedirect();
        ccc.channelGridList[0].additionalInfo.Status__c = 'Confirmed';
        ccc.channelGridList[0].additionalInfo.Start_Date__c = null;
        ccc.channelGridList[0].additionalInfo.Exclusive_Date__c = null;
        ccc.channelGridList[0].additionalInfo.End_Date__c = null;
        ccc.channelGridList[0].additionalInfo.Rights_End__c = null;
        ccc.channelGridList[1].additionalInfo.Status__c = 'Draft';
        ccc.channelGridList[1].additionalInfo.Start_Date__c = null;
        ccc.channelGridList[1].additionalInfo.End_Date__c = null;
        ccc.channelGridList[1].additionalInfo.Status__c = 'Not Releasing';
        ccc.channelGridList[1].additionalInfo.Start_Date__c = null;
        ccc.channelGridList[1].additionalInfo.End_Date__c = null;
        
        ccc.channelGridValidation();
        test.stoptest();
    }
    
    @isTest
    static void createCommAvailScen3() {
        // Test Batch Ids
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch1',RP_Batch_Id__c='1' );
        insert batchIDs;
        // Test tile
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        list<title__c> testTitleList= new list<title__c>();
        Title__c title = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today(),
                                  MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        Title__c title1 = new Title__c(Name='TestTitle', Video_Version__c='012345677868',Formats__c='HD',First_Available_Date__c=system.today(),
                                  MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        testTitleList.add(title);
        testTitleList.add(title1);
        insert testTitleList;
        
        // Test Language
        list<Language__c> langList= new list<Language__c>();
        Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1);
        Language__c Language1 = new Language__c (Name='TestLanguage',Language_Order__c = 1);
        Language__c Language2 = new Language__c (Name='TestLanguage',Language_Order__c = 1);
        langList.add(Language);
        langList.add(Language1);
        langList.add(Language2);
        insert langList;
        
        // Test Available language on Test Title
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle= new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id, Clear_to_Avail__c = TRUE);
        listAvailLang.add(availLangTitle);
        Available_Languages__c availLangTitle1= new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Audio',Title__c=title.Id);
        listAvailLang.add(availLangTitle1);
        Available_Languages__c availLangTitle2= new Available_Languages__c(Language__c=Language2.Id ,Language_Types__c='Audio',Title__c=title.Id);
        listAvailLang.add(availLangTitle2);

        insert listAvailLang;
        
        // Test country for country grp
        list<country__c> conList= new  list<country__c>();
        country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST',Territory__c='testTerritory');
        country__c con1= new country__c(Name='Test1',Country_Code__c='Te1', Country_Code2__c='t1',Channel__c='DTD');
        conList.add(con);
        conList.add(con1);
        insert conList;
        
        // Test Language Preferences
        list<Language_Preference__c> langPrefList= new list<Language_Preference__c> ();
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Language__c=Language1.Id,Level__c='1');
        Language_Preference__c langPrefTest3= new Language_Preference__c(Country__c=con1.Id,Language__c=Language1.Id,Level__c='3');
        langPrefList.add(langPrefTest);
        langPrefList.add(langPrefTest1);
         langPrefList.add(langPrefTest3);
        insert langPrefList;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
        insert conGrp;
        
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title1.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                       end_date__c=system.today()+190,start_Date__c=system.today()+10, Rights_End__c=system.today()+200,Exclusive_Date__c=(system.today()+2));
        insert commTest;
               
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        
        ApexPages.currentPage().getParameters().put('id', title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateCommercialAvail_Controller ccc = new WB_CreateCommercialAvail_Controller(sc);
        ccc.countryGrpId=conGrp.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.findCountry();
        ccc.channelgrid();
        ccc.cancel();
        
        // test channel grid
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest.Start_Date__c=date.parse( '12/31/2009'); 
        commAvailTest.End_Date__c=date.parse( '12/31/2014'); 
        commAvailTest.status__c='Planned';
        
        commercial_avail__c commAvailTest1= new commercial_avail__c(); 
        commAvailTest1.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest1.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest1.Start_Date__c=date.parse( '12/31/2009'); 
        commAvailTest1.End_Date__c=date.parse( '12/31/2014'); 
        commAvailTest1.status__c='Not Releasing';
        commAvailTest1.reason_code__c='No digital rights';
        
        WB_CreateCommercialAvail_Controller.channelWrapper channelWrapper = new WB_CreateCommercialAvail_Controller.channelWrapper();
        channelWrapper.countryChannel = 'DTD';
        channelWrapper.additionalInfo = commAvailTest;
        channelWrapper.delIndent = 1;
        channelWrapper.addIndent = 1; 
        test.starttest();
        WB_CreateCommercialAvail_Controller.channelWrapper channelWrapper1 = new WB_CreateCommercialAvail_Controller.channelWrapper();
        channelWrapper1.countryChannel = 'DTD';
        channelWrapper1.additionalInfo = commAvailTest1;
        channelWrapper1.delIndent = 1;
        channelWrapper1.addIndent = 1; 
        ccc.channelGridList.add(channelWrapper);
        ccc.channelGridList.add(channelWrapper1);
        
        ccc.bulksave();
        //ccc.proceedAnyway();
        ccc.delWrapper();
        ccc.addWrapper();
        
        //create local data
        Profile p = [select Id,name from Profile where Name= 'WB - Territory Avails Planner' limit 1];
        country__c country1= new country__c(Name='Testconntry1',Country_Code__c='AA', Country_Code2__c='AA',Channel__c='DTD;EST',
                                      Territory__c='testTerritory');
        insert country1;
       
        /*Local_Title__c localdata = new Local_Title__c(Name= 'test local data',Title__c =title.id,
            Country__c =con.id,Language__c=Language.id,
            Status__c='Active',Version_EIDR__c='Version EIDR',Local_Rating_System__c='A',
            Local_Rating__c='A',Local_Synopsis__c='description for synopsis',Local_Label__c='label',
            Caption_Included_picklist__c='YES',Local_Run_Time__c=0123.00,
            Local_Theatrical_Release_Date__c=date.today(),Local_TV_Air_Date__c=date.today(),
            Local_DVD_Release_Date__c=date.today(),Local_BD_Release_Date__c=date.today(),
            UV_Published_Date__c=date.today(),ALID__c='alid1',CID__c='cid1',Key__c='unique'
        );
        
        insert localdata;*/
        test.stoptest();
       //update localdata;
    }
    
    @isTest
    static void countryWithoutChannel() {
        
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch1',RP_Batch_Id__c='1' );
        insert batchIDs;
        
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        
        list<title__c> testTitleList= new list<title__c>();
        Title__c title = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today(),
                                  MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        Title__c title1 = new Title__c(Name='TestTitle', Video_Version__c='012345677868',Formats__c='HD',First_Available_Date__c=system.today(),
                                  MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        testTitleList.add(title);
        testTitleList.add(title1);
        insert testTitleList;
        
        // Test Language
        Language__c Language = new Language__c (Name='TestLanguage2', Language_Order__c = 1);
        insert Language;
        
        Language__c Language1 = new Language__c (Name='TestLanguage1', Language_Order__c = 1);
        insert Language1;
        
        Language__c Language2 = new Language__c (Name='TestLanguage3', Language_Order__c = 1);
        insert Language2;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=false);
        listAvailLang.add(availLangTitle2);
        Available_Languages__c availLangTitle3 = new Available_Languages__c(Language__c=Language1.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle3);
        Available_Languages__c availLangTitle4 = new Available_Languages__c(Language__c=Language1.Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle4);
        Available_Languages__c availLangTitle5 = new Available_Languages__c(Language__c=Language2.Id ,Language_Types__c='sub',Title__c=title.Id,Clear_To_Avail__c=false);
        listAvailLang.add(availLangTitle5);
        insert listAvailLang;
        // Test country for country grp 
        country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
        insert langPrefTest;
        
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Language__c=Language1.Id,Level__c='1');
        insert langPrefTest1;
        
        Language_Preference__c langPrefTest3= new Language_Preference__c(Country__c=con.Id,Language__c=Language1.Id,Level__c='3');
        insert langPrefTest3;
        
        
        Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
        insert con1;
        
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
        insert conGrp;
        
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        Commercial_Avail__c releasePlan = new Commercial_Avail__c(
                title__c=title1.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id,Language_Type__c='Sub',
                Start_Date__c = system.today()+10, End_Date__c = system.today()+190,
                Exclusive_Date__c=(system.today()+2), Rights_End__c=system.today()+200
        );
        insert releasePlan;
        
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        caList.add(commRec);
        
        ApexPages.currentPage().getParameters().put('id', title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateCommercialAvail_Controller ccc = new WB_CreateCommercialAvail_Controller(sc);
        ccc.countryGrpId=conGrp.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.findCountry();
        ccc.channelgrid();
        ccc.cancel();
        
        // test channel grid
        Commercial_Avail__c commAvailTest = new Commercial_Avail__c(); 
        commAvailTest.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest.Start_Date__c=date.parse( '12/31/2009'); 
        commAvailTest.End_Date__c=date.parse( '12/31/2014'); 
        commAvailTest.status__c='Open';
        
        // test channel grid-2 on 27 Nov          
        Commercial_Avail__c commAvailTest2= new Commercial_Avail__c(); 
        commAvailTest2.Exclusive_Date__c=null; 
        commAvailTest2.Rights_End__c=null; 
        commAvailTest2.Start_Date__c=null; 
        commAvailTest2.End_Date__c=null; 
        commAvailTest2.status__c='Open';
        
        Commercial_Avail__c commAvailTest4= new Commercial_Avail__c(); 
        commAvailTest4.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest4.Rights_End__c=date.parse( '12/31/2049');
        commAvailTest4.Start_Date__c=date.parse( '12/31/2001');
        commAvailTest4.End_Date__c=date.parse( '12/31/2002');
        commAvailTest4.status__c='Planned';
        
        // test channel grid-3 on 27 Nov 
        Commercial_Avail__c commAvailTest3= new Commercial_Avail__c(); 
        commAvailTest3.Exclusive_Date__c=null; 
        commAvailTest3.Rights_End__c=null; 
        commAvailTest3.Start_Date__c= system.today().addYears(3);
        commAvailTest3.End_Date__c = system.today().addYears(2);
        commAvailTest3.status__c=null;
        
        Release_Plan_Exceptions__c RPExep = new Release_Plan_Exceptions__c(
            Name = UserInfo.getUserId() + '1', Avails_Start__c = date.today(), Avails_End__c = date.today(), Channel__c = 'VODi', Country__c = 'Albania',
            Format__c = 'SD', Language__c = 'English', Reason__c = 'Following overlapping periods have been found with-RP-000356020', Status__c = 'Draft',
            Release_End_Date__c = date.today(), Release_Start_Date__c = date.today(), Title__c = 'Focus (2015)', User_Detail__c = UserInfo.getUserId()
        );
        insert RPExep;
        
        WB_CreateCommercialAvail_Controller.channelWrapper channelWrapper = new WB_CreateCommercialAvail_Controller.channelWrapper();
        channelWrapper.countryChannel = 'DTD';
        channelWrapper.additionalInfo = commAvailTest;
        ccc.channelGridList.add(channelWrapper);
        
        WB_CreateCommercialAvail_Controller.channelWrapper channelWrapper2 = new WB_CreateCommercialAvail_Controller.channelWrapper();
        channelWrapper2.countryChannel = 'DTD';
        channelWrapper2.additionalInfo = commAvailTest3; // Added on 27 Nov 
        ccc.channelGridList.add(channelWrapper2);
        
        WB_CreateCommercialAvail_Controller.channelWrapper channelWrapper3 = new WB_CreateCommercialAvail_Controller.channelWrapper();
        channelWrapper3.countryChannel = 'DTD';
        channelWrapper3.additionalInfo = commAvailTest2; // Added on 27 Nov  
        ccc.channelGridList.add(channelWrapper3);
        
        ccc.selectedCountriesRecords = new list<SelectOption>();
        ccc.selectedCountriesRecords.add(new SelectOption(con1.Id, con1.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));

        
        ccc.bulksave();
        //ccc.proceedAnyway();
    }
    
    @isTest
    static void ChannelGridTest() {
        // Test Batch Ids
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch1',RP_Batch_Id__c='1' );
        insert batchIDs;
        // Test tile
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        list<title__c> testTitleList= new list<title__c>();
        Title__c title = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today(),
                                  MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        Title__c title1 = new Title__c(Name='TestTitle', Video_Version__c='012345677868',Formats__c='HD',First_Available_Date__c=system.today(),
                                  MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        testTitleList.add(title);
        testTitleList.add(title1);
        insert testTitleList;
        
        // Test Language
        Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1);
        insert Language;
        
        // Test Available language on Test Title
        Available_Languages__c availLangTitle= new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id);
        insert availLangTitle;
        
        // Test country for country grp 
        country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='3');
        insert langPrefTest;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
        insert conGrp;
        
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title1.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                       end_date__c=system.today()+190,start_Date__c=system.today()+10, Rights_End__c=system.today()+200,Exclusive_Date__c=(system.today()+2));
        insert commTest;
        
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        caList.add(commRec);
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title1.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateCommercialAvail_Controller ccc = new WB_CreateCommercialAvail_Controller(sc);
        WB_CreateCommercialAvail_Controller.titleLangCount tempInstance = new WB_CreateCommercialAvail_Controller.titleLangCount();
        tempInstance.reasonForFailure = 'Test';
        ccc.Channelgrid();
    }
    
    @isTest
    static void createCommercialAvailBatchTest() {
        // Test Batch Ids
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch1',RP_Batch_Id__c='1' );
        insert batchIDs;
        // Test tile
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        list<title__c> testTitleList= new list<title__c>();
        Title__c title = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='SD; HD; 3DHD; 4K UHD',First_Available_Date__c=system.today(),Expiration_Date__c=system.today()+365,
                                  MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        Title__c title1 = new Title__c(Name='TestTitle', Video_Version__c='012345677868',Formats__c='SD; HD; 3DHD; 4K UHD',First_Available_Date__c=system.today(),
                                  MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        Title__c title2 = new Title__c(Name='TestTitle2', Video_Version__c='012345677867',Formats__c='SD; HD; 3DHD; 4K UHD',First_Available_Date__c=system.today(),
                                  MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        Title__c title3 = new Title__c(Name='TestTitle2', Video_Version__c='012345677866',Formats__c='SD; HD; 3DHD; 4K UHD',First_Available_Date__c=system.today(),
                                  MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        Title__c title4 = new Title__c(Name='TestTitle2', Video_Version__c='012345677865',Formats__c='SD; HD; 3DHD; 4K UHD',First_Available_Date__c=system.today(),
                                  MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        Title__c title5 = new Title__c(Name='TestTitle2', Video_Version__c='012345677864',Formats__c='SD; HD; 3DHD; 4K UHD',First_Available_Date__c=system.today(),
                                  MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        testTitleList.add(title);
        testTitleList.add(title1);
        testTitleList.add(title2);
        testTitleList.add(title3);
        testTitleList.add(title4);
        testTitleList.add(title5);
        insert testTitleList;
        
        // Test Language
        Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1);
        insert Language;
        Language__c Language1 = new Language__c (Name='TestLanguage1',Language_Order__c = 2);
        insert Language1;
        Language__c Language2 = new Language__c (Name='TestLanguage3',Language_Order__c = 2);
        insert Language2;
        
        // Test Available language on Test Title
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1= new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_to_avail__c=true);
        listAvailLang.add(availLangTitle1);        
        Available_Languages__c availLangTitle2= new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_to_avail__c=true);
        listAvailLang.add(availLangTitle2);
        Available_Languages__c availLangTitle3= new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_to_avail__c=false);
        listAvailLang.add(availLangTitle3);        
        Available_Languages__c availLangTitle4= new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title2.Id,Clear_to_avail__c=true);
        listAvailLang.add(availLangTitle4);
        Available_Languages__c availLangTitle5= new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title3.Id,Clear_to_avail__c=false);
        listAvailLang.add(availLangTitle5);        
        Available_Languages__c availLangTitle6= new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title4.Id,Clear_to_avail__c=true);
        listAvailLang.add(availLangTitle6);
        Available_Languages__c availLangTitle7= new Available_Languages__c(Language__c=Language2.Id ,Language_Types__c='Sub',Title__c=title4.Id,Clear_to_avail__c=true);
        listAvailLang.add(availLangTitle7);
        insert listAvailLang;
        
        // Test country for country grp 
        country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;VODi;EST;Hotel;PPV;VODc');
        insert con;
        
        country__c con1= new country__c(Name='Test',Country_Code__c='Ted', Country_Code2__c='tr',Channel__c='DTD;VODi;EST;Hotel;PPV;VODc');
        insert con1;
        
        country__c con2= new country__c(Name='Test',Country_Code__c='Tef', Country_Code2__c='tp',Channel__c='DTD;VODi;EST;Hotel;PPV;VODc');
        insert con2;
        
        country__c con3= new country__c(Name='Test',Country_Code__c='Teg', Country_Code2__c='tg',Channel__c='DTD;VODi;EST;Hotel;PPV;VODc');
        insert con3;
        
        country__c con4= new country__c(Name='Test',Country_Code__c='Tej', Country_Code2__c='tj',Channel__c='DTD;VODi;EST;Hotel;PPV;VODc');
        insert con4;
        
        country__c con5= new country__c(Name='Test',Country_Code__c='Tel', Country_Code2__c='tl',Channel__c='DTD;VODi;EST;Hotel;PPV;VODc');
        insert con5;
        
        country__c con6= new country__c(Name='Test',Country_Code__c='Tev', Country_Code2__c='tv',Channel__c='DTD;VODi;EST;Hotel;PPV;VODc');
        insert con6;
        
        country__c con7= new country__c(Name='Test',Country_Code__c='Tek', Country_Code2__c='tk',Channel__c='DTD;VODi;EST;Hotel;PPV;VODc');
        insert con7;
        
        country__c con8= new country__c(Name='Test',Country_Code__c='Ten', Country_Code2__c='tn',Channel__c='DTD;VODi;EST;Hotel;PPV;VODc');
        insert con8;
        
        country__c con9= new country__c(Name='Test',Country_Code__c='Tem', Country_Code2__c='tm',Channel__c=' ');
        insert con9;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
        insert langPrefTest;
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Language__c=Language1.Id,Level__c='1');
        insert langPrefTest1;
        
        Language_Preference__c langPrefTest3= new Language_Preference__c(Country__c=con1.Id,Language__c=Language1.Id,Level__c='3');
        insert langPrefTest3;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
        insert conGrp;
        
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title1.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,
                                      Languages__c=Language.Id, Language_Type__c='Sub',
                                      end_date__c=date.parse('10/31/2025'),start_Date__c=date.today(), 
                                      Rights_End__c=date.parse('10/31/2025'),Exclusive_Date__c=date.today());
        insert commTest;
        Test.starttest();       
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        
        caList.add(commRec);
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title1.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateCommercialAvail_Controller ccc = new WB_CreateCommercialAvail_Controller(sc);
        ccc.countryGrpId=conGrp.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedCountriesRecords.add(new SelectOption(con1.Id, con1.Name));
        ccc.selectedCountriesRecords.add(new SelectOption(con2.Id, con2.Name));
        ccc.selectedCountriesRecords.add(new SelectOption(con3.Id, con3.Name));
        ccc.selectedCountriesRecords.add(new SelectOption(con4.Id, con4.Name));
        ccc.selectedCountriesRecords.add(new SelectOption(con5.Id, con5.Name));
        ccc.selectedCountriesRecords.add(new SelectOption(con6.Id, con6.Name));
        ccc.selectedCountriesRecords.add(new SelectOption(con7.Id, con7.Name));
        ccc.selectedCountriesRecords.add(new SelectOption(con8.Id, con8.Name));
        ccc.selectedCountriesRecords.add(new SelectOption(con9.Id, con9.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        
        ccc.obj.Country_Group__c = conGrp.Id;
        ccc.findCountry();
        ccc.channelgrid();
        ccc.cancel();
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        // test channel grid           
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest.Exclusive_Date__c=date.today();
        commAvailTest.Start_Date__c=date.today();
        commAvailTest.End_Date__c=date.parse( '12/31/2049'); 
        commAvailTest.status__c='Open';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Channel__c = null;
        listComm.add(commAvailTest);
        
        // test channel grid-2 on 27 Nov
        commercial_avail__c commAvailTest2= new commercial_avail__c(); 
        commAvailTest2.Rights_End__c=null; 
        commAvailTest2.Exclusive_Date__c=null; 
        commAvailTest2.Start_Date__c=null; 
        commAvailTest2.End_Date__c=null; 
        commAvailTest2.status__c='Open';
        commAvailTest2.Country_Lookup__c = con.id;
        commAvailTest2.title__c = title.id;
        commAvailTest2.Languages__c = Language.id;
        commAvailTest2.Channel__c = null;
        listComm.add(commAvailTest2);
        
        // test channel grid-3 on 27 Nov 
        commercial_avail__c commAvailTest3= new commercial_avail__c(); 
        commAvailTest3.Rights_End__c=null; 
        commAvailTest3.Exclusive_Date__c=null; 
        commAvailTest3.Start_Date__c=system.today(); 
        commAvailTest3.End_Date__c=system.today()+20; 
        commAvailTest3.Reason_Code__c='Business Reason';
        commAvailTest3.status__c='Draft';
        commAvailTest3.Country_Lookup__c = con.id;
        commAvailTest3.title__c = title.id;
        commAvailTest3.Languages__c = Language.id;
        commAvailTest3.Channel__c = 'VODi';
        listComm.add(commAvailTest3);
        
        commercial_avail__c commAvailTest4= new commercial_avail__c(); 
        commAvailTest4.Rights_End__c=date.parse( '12/31/2049');
        commAvailTest4.Exclusive_Date__c=date.today();
        commAvailTest4.Start_Date__c=date.today();
        commAvailTest4.End_Date__c=date.parse( '12/31/2049');
        commAvailTest4.status__c='Planned';
        commAvailTest4.Country_Lookup__c = con.id;
        commAvailTest4.title__c = title.id;   
        commAvailTest4.Languages__c = Language.id;
        commAvailTest4.Channel__c = 'VODi';
        //listComm.add(commAvailTest4);
        insert listComm;
        
        Rights_Group__c rightGroup = new Rights_Group__c(Name = 'Australia',Country__c=con.id,Language__c=Language.id);
        insert rightGroup;
        
        Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'Test',Country__c=con.id,Language__c=Language.id,Rights_Group__c = rightGroup.id);
        insert childRightGroup;
        
        Rights__c rights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id,Rights_End__c=system.today()+3, Rights_Group__c = rightGroup.Name,Rights_Start__c= system.today(),Status__c='Confirmed', Source__c ='Cosmos');
        insert rights;
        
        ccc.mapRightsDate(listComm);
        
        Release_Plan_Exceptions__c RPExep = new Release_Plan_Exceptions__c(
            Name = UserInfo.getUserId() + '1',
            Avails_Start__c = date.today(),
            Avails_End__c = date.today(),
            Channel__c = 'VODi',
            Country__c = 'Albania',
            Format__c = 'SD',
            Language__c = 'English',
            Reason__c = 'Following overlapping periods have been found with-RP-000356020',
            Release_End_Date__c = date.today(),
            Release_Start_Date__c = date.today(),
            Status__c = 'Draft',
            Title__c = 'Focus (2015)',
            User_Detail__c = UserInfo.getUserId()
        );
        insert RPExep;
        
        
        WB_CreateCommercialAvail_Controller.channelWrapper channelWrapper = new WB_CreateCommercialAvail_Controller.channelWrapper();
        channelWrapper.countryChannel = 'DTD';
        channelWrapper.additionalInfo = commAvailTest;
        ccc.channelGridList.add(channelWrapper);
        WB_CreateCommercialAvail_Controller.channelWrapper channelWrapper2 = new WB_CreateCommercialAvail_Controller.channelWrapper();
        channelWrapper2.countryChannel = 'DTD';
        channelWrapper2.additionalInfo = commAvailTest3; // Added on 27 Nov 
        ccc.channelGridList.add(channelWrapper2);  
        WB_CreateCommercialAvail_Controller.channelWrapper channelWrapper3 = new WB_CreateCommercialAvail_Controller.channelWrapper();
        channelWrapper3.countryChannel = 'DTD';
        channelWrapper3.additionalInfo = commAvailTest2; // Added on 27 Nov  
        ccc.channelGridList.add(channelWrapper3);
        ccc.titleList = testTitleList;
        ccc.bulksave();
        List<commercial_avail__c> listC = [Select id,Title__c,Country_Lookup__c,Channel__c,Format__c,Languages__c,Language_Type__c,Start_Date__c,End_Date__c,Exclusive_Date__c,Rights_End__c,Status__c from commercial_avail__c];
        ccc.commAvailLstValidated(listC);
        ccc.channelGridList[0].additionalInfo.Start_Date__c = system.Today() + 5;
        ccc.channelGridList[1].additionalInfo.Exclusive_Date__c = system.Today() + 5;
        ccc.channelGridList[0].additionalInfo.End_Date__c = system.Today() + 1;
        ccc.channelGridList[1].additionalInfo.Rights_End__c = system.Today() + 1;
        ccc.channelGridList[2].additionalInfo.Status__c = 'Tentative';
        ccc.channelGridList[2].additionalInfo.Start_Date__c = null;
        ccc.channelGridList[2].additionalInfo.End_Date__c = null;
        ccc.channelGridValidation();
        ccc.clearList();
        
        Test.stoptest();
        //ccc.proceedAnyway();
    }
    
    @isTest
    static void titleWithoutFormat() {
        
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch1',RP_Batch_Id__c='1' );
        insert batchIDs;
        
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        
        list<title__c> testTitleList= new list<title__c>();
        Title__c title = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today(),
                                  MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        Title__c title1 = new Title__c(Name='TestTitle', Video_Version__c='012345677868',Formats__c='HD',First_Available_Date__c=system.today(),
                                  MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        testTitleList.add(title);
        testTitleList.add(title1);
        insert testTitleList;
        
        Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1);
        insert Language;
        
        Available_Languages__c availLangTitle= new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id);
        insert availLangTitle;
        
        Country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST');
        insert con;
        
        Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
        insert con1;
        
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
        insert conGrp;
        
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
        insert langPrefTest;
        
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        Commercial_Avail__c releasePlan = new Commercial_Avail__c(
                title__c=title1.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id,Language_Type__c='Sub',
                Start_Date__c = system.today()+10, End_Date__c = system.today()+190,
                Exclusive_Date__c=(system.today()+2), Rights_End__c=system.today()+200
        );
        insert releasePlan;
        
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        caList.add(commRec);
       
        
        ApexPages.currentPage().getParameters().put('id', title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateCommercialAvail_Controller ccc = new WB_CreateCommercialAvail_Controller(sc);
        ccc.countryGrpId=conGrp.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.findCountry();
        ccc.channelgrid();
        ccc.cancel();
        
        
        // test channel grid
        Commercial_Avail__c commAvailTest = new Commercial_Avail__c(); 
        commAvailTest.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest.Start_Date__c=date.parse( '12/31/2009'); 
        commAvailTest.End_Date__c=date.parse( '12/31/2014'); 
        commAvailTest.status__c='Open';
        
        // test channel grid-2 on 27 Nov          
        Commercial_Avail__c commAvailTest2= new Commercial_Avail__c(); 
        commAvailTest2.Exclusive_Date__c=null; 
        commAvailTest2.Rights_End__c=null; 
        commAvailTest2.Start_Date__c=null; 
        commAvailTest2.End_Date__c=null; 
        commAvailTest2.status__c='Open';
        
        Commercial_Avail__c commAvailTest4= new Commercial_Avail__c(); 
        commAvailTest4.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest4.Rights_End__c=date.parse( '12/31/2049');
        commAvailTest4.Start_Date__c=date.parse( '12/31/2001');
        commAvailTest4.End_Date__c=date.parse( '12/31/2002');
        commAvailTest4.status__c='Planned';
        
        // test channel grid-3 on 27 Nov 
        Commercial_Avail__c commAvailTest3= new Commercial_Avail__c(); 
        commAvailTest3.Exclusive_Date__c=null; 
        commAvailTest3.Rights_End__c=null; 
        commAvailTest3.Start_Date__c= system.today().addYears(3);
        commAvailTest3.End_Date__c = system.today().addYears(2);
        commAvailTest3.status__c=null;
        
        Release_Plan_Exceptions__c RPExep = new Release_Plan_Exceptions__c(
            Name = UserInfo.getUserId() + '1', Avails_Start__c = date.today(), Avails_End__c = date.today(), Channel__c = 'VODi', Country__c = 'Albania',
            Format__c = 'SD', Language__c = 'English', Reason__c = 'Following overlapping periods have been found with-RP-000356020', Status__c = 'Draft',
            Release_End_Date__c = date.today(), Release_Start_Date__c = date.today(), Title__c = 'Focus (2015)', User_Detail__c = UserInfo.getUserId()
        );
        insert RPExep;
        
        Test.setCurrentPage(Page.WB_Create_CommercialAvail);
        List<Apexpages.Message> msgs = ApexPages.getMessages();

        boolean isErrorMessage = false;

        for(Apexpages.Message msg : msgs){
            if(msg.getDetail().contains('No Available Formats found for all selected titles.Please update selected titles with Format values') )
                isErrorMessage  = true;
        }
        //Assert that the Page Message was Properly Displayed
        //system.assert(isErrorMessage );
    }
    
    @isTest
    static void titleWithoutAvailablelanguage() {
        
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch1',RP_Batch_Id__c='1' );
        insert batchIDs;
        
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        
        list<title__c> testTitleList= new list<title__c>();
        Title__c title = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today(),
                                  MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        Title__c title1 = new Title__c(Name='TestTitle', Video_Version__c='012345677868',Formats__c='HD',First_Available_Date__c=system.today(),
                                  MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        testTitleList.add(title);
        testTitleList.add(title1);
        insert testTitleList;
        
        Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1);
        insert Language;
        
        //Available_Languages__c availLangTitle= new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id);
        //insert availLangTitle;
        
        Country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST');
        insert con;
        
        Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
        insert con1;
        
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
        insert conGrp;
        
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
        insert langPrefTest;
        
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        Commercial_Avail__c releasePlan = new Commercial_Avail__c(
                title__c=title1.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id,Language_Type__c='Sub',
                Start_Date__c = system.today()+10, End_Date__c = system.today()+190,
                Exclusive_Date__c=(system.today()+2), Rights_End__c=system.today()+200
        );
        insert releasePlan;
        
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        caList.add(commRec);
        
        ApexPages.currentPage().getParameters().put('id', title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateCommercialAvail_Controller ccc = new WB_CreateCommercialAvail_Controller(sc);
        ccc.countryGrpId=conGrp.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.findCountry();
        ccc.channelgrid();
        ccc.cancel();
        
        // test channel grid
        Commercial_Avail__c commAvailTest = new Commercial_Avail__c(); 
        commAvailTest.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest.Start_Date__c=date.parse( '12/31/2009'); 
        commAvailTest.End_Date__c=date.parse( '12/31/2014'); 
        commAvailTest.status__c='Open';
        
        // test channel grid-2 on 27 Nov
        Commercial_Avail__c commAvailTest2= new Commercial_Avail__c(); 
        commAvailTest2.Exclusive_Date__c=null; 
        commAvailTest2.Rights_End__c=null; 
        commAvailTest2.Start_Date__c=null; 
        commAvailTest2.End_Date__c=null; 
        commAvailTest2.status__c='Open';
        
        Commercial_Avail__c commAvailTest4= new Commercial_Avail__c(); 
        commAvailTest4.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest4.Rights_End__c=date.parse( '12/31/2049');
        commAvailTest4.Start_Date__c=date.parse( '12/31/2001');
        commAvailTest4.End_Date__c=date.parse( '12/31/2002');
        commAvailTest4.status__c='Planned';
        
        // test channel grid-3 on 27 Nov 
        Commercial_Avail__c commAvailTest3= new Commercial_Avail__c(); 
        commAvailTest3.Exclusive_Date__c=null; 
        commAvailTest3.Rights_End__c=null; 
        commAvailTest3.Start_Date__c= system.today().addYears(3);
        commAvailTest3.End_Date__c = system.today().addYears(2);
        commAvailTest3.status__c=null;
        
        Release_Plan_Exceptions__c RPExep = new Release_Plan_Exceptions__c(
            Name = UserInfo.getUserId() + '1', Avails_Start__c = date.today(), Avails_End__c = date.today(), Channel__c = 'VODi', Country__c = 'Albania',
            Format__c = 'SD', Language__c = 'English', Reason__c = 'Following overlapping periods have been found with-RP-000356020', Status__c = 'Draft',
            Release_End_Date__c = date.today(), Release_Start_Date__c = date.today(), Title__c = 'Focus (2015)', User_Detail__c = UserInfo.getUserId()
        );
        insert RPExep;
        
        Test.setCurrentPage(Page.WB_Create_CommercialAvail);
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean isErrorMessage = false;

        for(Apexpages.Message msg : msgs){
            if (msg.getDetail().contains('No Available Languages found for all selected titles.Please update selected titles with Languages') )
                isErrorMessage  = true;
        }
        //Assert that the Page Message was Properly Displayed
        //system.assert(isErrorMessage );
    }
    
    
    
    
    
     //As per CRRT Phase2 requirement
       @isTest
    static void createCommAvailRytChk1() {
        // Test Batch Ids
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch1',RP_Batch_Id__c='1' );
        insert batchIDs;
        // Test tile
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        list<title__c> testTitleList= new list<title__c>();
        Title__c title = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today(),
                                      Expiration_Date__c=system.today()+365,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
                                      Short_Synopsis__c='short description',Digital_Planning__c='YES');       
        
        testTitleList.add(title);
        insert testTitleList;
        
        // Test Language
        List<Language__c> listLang = new List<Language__c>();
        Language__c Language = new Language__c (Name='English',Language_Code_2__c='en',Language_Order__c = 1);
        listLang.add(Language);
        Language__c Language1 = new Language__c (Name='Hindi',Language_Code_2__c='en',Language_Order__c = 3);
         listLang.add(Language1);
        insert listLang;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        insert listAvailLang;
        
        // Test country for country grp 
        country__c con= new country__c(Name='Australia',Country_Code__c='AUS', Country_Code2__c='AU',Channel__c='DTD;EST');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='1');
        insert langPrefTest;
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
        insert langPrefTest1;        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Language__c=Language1.Id,Level__c='3');
        insert langPrefTest2;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='Australia and NZ');
        insert conGrp;
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                       end_date__c=system.today()+190,start_Date__c=system.today()+10, Rights_End__c=system.today()+200,Exclusive_Date__c=(system.today()+2));
        insert commTest;
               
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        caList.add(commRec);
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateCommercialAvail_Controller ccc = new WB_CreateCommercialAvail_Controller(sc);
        ccc.getCountryGroup();
        ccc.englishOnlyChk = true;
        ccc.countryGrpId=conGrpCon.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.obj.Country_Group__c = conGrp.Id;
        ccc.findCountry();
        ccc.channelgrid();        
        ccc.cancel();
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        // test channel grid           
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest.Exclusive_Date__c=date.today(); 
        commAvailTest.Start_Date__c= date.today();
        commAvailTest.End_Date__c=date.parse( '12/31/2049');
        commAvailTest.status__c='Open';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Channel__c = 'EST';
        listComm.add(commAvailTest);
        
        Test.starttest();
        insert listComm;
                
        Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
        insert childRightGroup;
        
        Rights__c rights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
                                        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
                                        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
                                        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19);
        insert rights;    
        
        ccc.mapRightsDate(listComm);
               
        WB_CreateCommercialAvail_Controller.channelWrapper channelWrapper = new WB_CreateCommercialAvail_Controller.channelWrapper();
        channelWrapper.countryChannel = 'EST';
        channelWrapper.additionalInfo = commAvailTest;
        ccc.channelGridList.add(channelWrapper); 
        ccc.titleList = testTitleList;
        ccc.isRightToCreateRPChk = True;
        ccc.ConfirmedPartialAllow = 'Yes';
        ccc.chkRightsStatus();
        ccc.bulksave();
        Test.stoptest();
    } 
     @isTest
    static void createCommAvailRytChk2() {
        // Test Batch Ids
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch1',RP_Batch_Id__c='1' );
        insert batchIDs;
        // Test tile
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        list<title__c> testTitleList= new list<title__c>();
        Title__c title = new Title__c(Name='TestTitle12Sep2', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=null,
                                      Expiration_Date__c=system.today()+365,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
                                      Short_Synopsis__c='short description',Digital_Planning__c='YES');       
        
        testTitleList.add(title);
        insert testTitleList;
        
        // Test Language
        List<Language__c> listLang = new List<Language__c>();
        Language__c Language = new Language__c (Name='English',Language_Code_2__c='en',Language_Order__c = 1);
        listLang.add(Language);      
        insert listLang;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        insert listAvailLang;
        
        // Test country for country grp 
        country__c con= new country__c(Name='Australia',Country_Code__c='AUS', Country_Code2__c='AU',Channel__c='DTD;EST');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='1');
        insert langPrefTest;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='Australia and NZ');
        insert conGrp;
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                       end_date__c=date.parse('10/31/2024'),start_Date__c=date.parse('10/16/2019'), Rights_End__c=date.parse('10/31/2025'),Exclusive_Date__c=date.parse('10/16/2018'));
        insert commTest;
               
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        caList.add(commRec);
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateCommercialAvail_Controller ccc = new WB_CreateCommercialAvail_Controller(sc);
        ccc.englishOnlyChk = true;
        ccc.countryGrpId=conGrpCon.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.obj.Country_Group__c = conGrp.Id;
        ccc.findCountry();
        ccc.channelgrid();        
        ccc.cancel();
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        // test channel grid           
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest.Exclusive_Date__c=date.today(); 
        commAvailTest.Start_Date__c= date.today();
        commAvailTest.End_Date__c=date.parse( '12/31/2049');
        commAvailTest.status__c='Open';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Channel__c = 'EST';
        listComm.add(commAvailTest);

        Test.starttest();
        insert listComm;
                
        Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
        insert childRightGroup;
        
        Rights__c rights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
                                        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
                                        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
                                        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19);
        insert rights;
        
        ccc.mapRightsDate(listComm);
        
        WB_CreateCommercialAvail_Controller.channelWrapper channelWrapper = new WB_CreateCommercialAvail_Controller.channelWrapper();
        channelWrapper.countryChannel = 'EST';
        channelWrapper.additionalInfo = commAvailTest;
        ccc.channelGridList.add(channelWrapper); 
        ccc.titleList = testTitleList;
        ccc.isRightToCreateRPChk = True;
        ccc.ConfirmedPartialAllow = 'Yes';
        ccc.chkRightsStatus();
        ccc.bulksave();        
        Test.stoptest();
    }  
    @isTest
    static void createCommAvailRytChk3() {
        // Test Batch Ids
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch1',RP_Batch_Id__c='1' );
        insert batchIDs;
        // Test tile
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        list<title__c> testTitleList= new list<title__c>();
        Title__c title = new Title__c(Name='TestTitle12Sep3', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today(),
                                      Expiration_Date__c=system.today()+365,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
                                      Short_Synopsis__c='short description',Digital_Planning__c='YES');       
        
        testTitleList.add(title);
        insert testTitleList;
        
        // Test Language
        List<Language__c> listLang = new List<Language__c>();
        Language__c Language = new Language__c (Name='English',Language_Code_2__c='en',Language_Order__c = 1);
        listLang.add(Language);      
        insert listLang;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        insert listAvailLang;
        
        // Test country for country grp 
        country__c con= new country__c(Name='Australia',Country_Code__c='AUS', Country_Code2__c='AU',Channel__c='Physical;EST');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='3');
        insert langPrefTest;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='Australia and NZ');
        insert conGrp;
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='Physical',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                       end_date__c=system.today()+190,start_Date__c=system.today()+10, Rights_End__c=system.today()+200,Exclusive_Date__c=(system.today()+2));
        insert commTest;
               
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        caList.add(commRec);
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateCommercialAvail_Controller ccc = new WB_CreateCommercialAvail_Controller(sc);
        ccc.englishOnlyChk = true;
        ccc.countryGrpId=conGrpCon.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.obj.Country_Group__c = conGrp.Id;
        ccc.findCountry();
        ccc.channelgrid();        
        ccc.cancel();
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        // test channel grid           
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest.Exclusive_Date__c=date.today(); 
        commAvailTest.Start_Date__c= date.today();
        commAvailTest.End_Date__c=date.parse( '12/31/2049');
        commAvailTest.status__c='Open';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Channel__c = 'EST';
        listComm.add(commAvailTest);

        Test.starttest();
        insert listComm;
                
        Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
        insert childRightGroup;
        
        Rights__c rights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='TBA', Source__c ='Cosmos');
        insert rights;
        
        ccc.mapRightsDate(listComm);
        
        WB_CreateCommercialAvail_Controller.channelWrapper channelWrapper = new WB_CreateCommercialAvail_Controller.channelWrapper();
        channelWrapper.countryChannel = 'EST';
        channelWrapper.additionalInfo = commAvailTest;
        ccc.channelGridList.add(channelWrapper); 
        ccc.titleList = testTitleList;
        ccc.isRightToCreateRPChk = True;
        ccc.ConfirmedPartialAllow = 'Yes';
        ccc.chkRightsStatus();
        ccc.bulksave();        
        Test.stoptest();
    }
         //The below testMethod added for SINC0793202
    @isTest
    static void checkUserTerritorywithTitle() {
        
        Profile p = [select id from profile where id = '00eU0000000ZrIe' LIMIT 1];
        User u = new User(
                alias = 'standt', email='testuser@testorg.com', emailencodingkey='UTF-8',
                   lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',Territory__c = 'France',
                    timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id
                );
        insert u;
        System.runAs(u){
            MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
            insert mpm;
            
            Title__c title = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='SD; HD; 3DHD; 4K UHD',First_Available_Date__c=system.today(),Expiration_Date__c=system.today()+365,
                                      MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES',Territory__c = 'France');
            insert title;
             
            country__c con= new country__c(Name='Chile',Country_Code__c='CHL', Country_Code2__c='CL',Channel__c='EST;PPV;VODi',Territory__c='Mexico');
            insert con;
            
            Language__c Language = new Language__c (Name='English',Language_Order__c = 1);
            insert Language;
            
            commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                           end_date__c=date.parse('10/31/2025'),start_Date__c=date.today(),
                                           Rights_End__c=date.parse('10/31/2025'),Exclusive_Date__c=date.today(),OwnerId=u.id);
        
            
            
            Test.startTest();
                
            insert commTest;
        
            
        }
        Test.stopTest();
        
    }
   
}