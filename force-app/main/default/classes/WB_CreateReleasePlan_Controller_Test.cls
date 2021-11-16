@isTest
public class WB_CreateReleasePlan_Controller_Test{

    public WB_CreateReleasePlan_Controller_Test(){
    }
    
    public static testmethod void methodcreateRP1(){
        // Test Batch Ids
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch1',RP_Batch_Id__c='1' );
        insert batchIDs;
        
        // Test tile
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='12358');
        insert mpm;
        
        list<title__c> testTitleList= new list<title__c>();
        Title__c title = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today(),
                                      Expiration_Date__c=system.today()+365,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
                                      Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        Title__c title1 = new Title__c(Name='TestTitle', Video_Version__c='012345677868',Formats__c='HD',First_Available_Date__c=system.today(),
                                       MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        testTitleList.add(title);
        testTitleList.add(title1);
        insert testTitleList;
        
        // Test Language
        List<Language__c> listLang = new List<Language__c>();
        Language__c Language = new Language__c (Name='English',Language_Order__c = 1,Language_Code_2__c='en');
        listLang.add(Language);
        //insert Language;
        
        Language__c Language1 = new Language__c (Name='TestLanguage1', Language_Order__c = 1,Language_Code_2__c='tl1');
        listLang.add(Language1);
        //insert Language1;
         
        Language__c Language2 = new Language__c (Name='TestLanguage3', Language_Order__c = 1,Language_Code_2__c='tl3');
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
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c= 'Country',Language__c=Language.Id,Level__c='3');
        insert langPrefTest;
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Type__c= 'Country',Language__c=Language1.Id,Level__c='2');
        insert langPrefTest1;
        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language2.Id,Level__c='1');
        insert langPrefTest2;
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
        insert conGrp;
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title1.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                       end_date__c=date.today()+40,start_Date__c=date.today()+20, Rights_End__c=date.today()+50,Exclusive_Date__c=date.today()+10);
        //insert commTest;
               
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        caList.add(commRec);
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title1.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);
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
        commAvailTest.Channel__c = null;
        //listComm.add(commAvailTest);
        
        commercial_avail__c commAvailTest1= new commercial_avail__c(); 
        commAvailTest1.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest1.Exclusive_Date__c=date.today(); 
        commAvailTest1.Start_Date__c= date.today();
        commAvailTest1.End_Date__c=date.parse( '12/31/2049');
        commAvailTest1.status__c='Open';
        commAvailTest1.Country_Lookup__c = con.id;
        commAvailTest1.title__c = title.id;
        commAvailTest1.Languages__c = Language.id;
        commAvailTest1.Channel__c = null;
        listComm.add(commAvailTest1);
        
        
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
        commAvailTest4.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest4.Start_Date__c=date.parse( '12/31/2001');
        commAvailTest4.End_Date__c=date.parse( '12/31/2002');
        commAvailTest4.status__c='Planned';
        commAvailTest4.Country_Lookup__c = con.id;
        commAvailTest4.title__c = title.id;   
        commAvailTest4.Languages__c = Language.id;
        commAvailTest4.Channel__c = 'VODi';
        //listComm.add(commAvailTest4);
        Test.starttest();
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
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper.countryChannel = 'DTD';
        channelWrapper.additionalInfo = commAvailTest;
        ccc.channelGridList.add(channelWrapper);
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper2 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper2.countryChannel = 'DTD';
        channelWrapper2.additionalInfo = commAvailTest3; // Added on 27 Nov 
        ccc.channelGridList.add(channelWrapper2);
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper3 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper3.countryChannel = 'DTD';
        channelWrapper3.additionalInfo = commAvailTest2; // Added on 27 Nov  
        ccc.channelGridList.add(channelWrapper3);
        ccc.titleList = testTitleList;
        ccc.bulksave();
        List<commercial_avail__c> listC = [Select id,Title__c,Country_Lookup__c,Channel__c,Format__c,Languages__c,Language_Type__c,Start_Date__c,End_Date__c,Exclusive_Date__c,Rights_End__c,Status__c from commercial_avail__c];
        listC[0].Start_Date__c = system.today()+5; //Aaditya Change 23 Sep
        listC[0].End_Date__c = system.today();
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
    
    public static testmethod void methodcreateRP2(){
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
        
        Title__c title2 = new Title__c(Name='TestTitle12Sep2', Video_Version__c='0123456799',Formats__c='HD',First_Available_Date__c=system.today(),
                                      Expiration_Date__c=system.today()+365,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
                                      Short_Synopsis__c='short description',Digital_Planning__c='YES'); 
        
        testTitleList.add(title);
        testTitleList.add(title2);
        insert testTitleList;
        List<String> titleIds = new List<String>();
        for(Title__c t: testTitleList)
        {
            titleIds.add(t.Id);
        }
        
        
        // Test Language
        List<Language__c> listLang = new List<Language__c>();
        Language__c Language = new Language__c (Name='English',Language_Code_2__c='en',Language_Order__c = 1);
        listLang.add(Language);
        Language__c Language1 = new Language__c (Name='Hindi',Language_Code_2__c='hi',Language_Order__c = 3);
         listLang.add(Language1);
         Language__c Language2 = new Language__c (Name='Tamil',Language_Code_2__c='ta',Language_Order__c = 3);
         listLang.add(Language2);
        insert listLang;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Audio',Title__c=title2.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        listAvailLang.add(availLangTitle2);
        
        Available_Languages__c availLangTitle3 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);
        Available_Languages__c availLangTitle4 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title2.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle3);
        listAvailLang.add(availLangTitle4);
        insert listAvailLang;
        
        // Test country for country grp 
        country__c con= new country__c(Name='Australia',Country_Code__c='AUS', Country_Code2__c='AU',Channel__c='DTD;EST');
        insert con;
        
        List<country__c> conList = [Select Id from country__c];
        List<String> conIds = new List<String>();
        for(country__c c : conList)
        {
            conIds.add(c.Id);
        }
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language.Id,Level__c='1');
        insert langPrefTest;
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language2.Id,Level__c='2');
        insert langPrefTest1;        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language1.Id,Level__c='3');
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
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);
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
               
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper.countryChannel = 'EST';
        channelWrapper.additionalInfo = commAvailTest;
        ccc.channelGridList.add(channelWrapper); 
        ccc.titleList = testTitleList;
        ccc.isRightToCreateRPChk = True;
        ccc.ConfirmedPartialAllow = 'Yes';
        ccc.chkRightsStatus();
        ccc.bulksave();
        ccc.clientList(titleIds, conIds);

        Test.stoptest();
    }

    public static testmethod void methodcreateRP_noAL(){
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
        
        Title__c title2 = new Title__c(Name='TestTitle12Sep2', Video_Version__c='0123456799',Formats__c='HD',First_Available_Date__c=system.today(),
                                      Expiration_Date__c=system.today()+365,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
                                      Short_Synopsis__c='short description',Digital_Planning__c='YES'); 
        
        testTitleList.add(title);
        testTitleList.add(title2);
        insert testTitleList;
        List<String> titleIds = new List<String>();
        for(Title__c t: testTitleList)
        {
            titleIds.add(t.Id);
        }
        
        
        // Test Language
        List<Language__c> listLang = new List<Language__c>();
        Language__c Language = new Language__c (Name='English',Language_Code_2__c='en',Language_Order__c = 1);
        listLang.add(Language);
        Language__c Language1 = new Language__c (Name='Hindi',Language_Code_2__c='hi',Language_Order__c = 3);
        listLang.add(Language1);
        Language__c Language2 = new Language__c (Name='Tamil',Language_Code_2__c='ta',Language_Order__c = 3);
        listLang.add(Language2);
        insert listLang;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Provisional__c=true);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Audio',Title__c=title2.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        //listAvailLang.add(availLangTitle2);
        
        Available_Languages__c availLangTitle3 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Audio',Title__c=title.Id,Provisional__c=true);
        Available_Languages__c availLangTitle4 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title2.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle3);
        //listAvailLang.add(availLangTitle4);
        insert listAvailLang;
        
        // Test country for country grp 
        country__c con= new country__c(Name='Australia',Country_Code__c='AUS', Country_Code2__c='AU',Channel__c='DTD;EST');
        insert con;
        
        List<country__c> conList = [Select Id from country__c];
        List<String> conIds = new List<String>();
        for(country__c c : conList)
        {
            conIds.add(c.Id);
        }
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language.Id,Level__c='1');
        insert langPrefTest;
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language2.Id,Level__c='2');
        insert langPrefTest1;        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language1.Id,Level__c='3');
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
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);
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
        commAvailTest.title__c = title2.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Channel__c = 'EST';
        commAvailTest.language_type__c='';
        listComm.add(commAvailTest);

        commercial_avail__c commAvailTest1= new commercial_avail__c(); 
        commAvailTest1.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest1.Exclusive_Date__c=date.today(); 
        commAvailTest1.Start_Date__c= date.today();
        commAvailTest1.End_Date__c=date.parse( '12/31/2049');
        commAvailTest1.status__c='Open';
        commAvailTest1.Country_Lookup__c = con.id;
        commAvailTest1.title__c = title.id;
        commAvailTest1.Languages__c = Language.id;
        commAvailTest1.Channel__c = 'EST';
        commAvailTest1.language_type__c='';
        listComm.add(commAvailTest1);
        
        Test.starttest();
        //insert listComm;
                
        Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
        insert childRightGroup;
        
        Rights__c rights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed Partial', Source__c ='Cosmos',
                                        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
                                        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
                                        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19);
        insert rights;    
        
        //ccc.mapRightsDate(listComm);
               
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper.countryChannel = 'EST';
        channelWrapper.additionalInfo = commAvailTest;
        ccc.provisionalLang = true;
        ccc.seperateLanguageTypeChk = true;
        ccc.channelGridList.add(channelWrapper); 
        ccc.selectedFormats.add(new SelectOption('VR','VR'));
        ccc.selectedFormats.add(new SelectOption('BD','BD'));
        ccc.channelgrid();  
        ccc.titleList = testTitleList;
        ccc.isRightToCreateRPChk = true;
        //ccc.provisionalLang = True;
        ccc.ConfirmedPartialAllow = 'Yes';
        ccc.chkRightsStatus();
        ccc.bulksave();
        ccc.englishOnlyChk = false;
        ccc.clientList(titleIds, conIds);

        Test.stoptest();
    }
    
    public static testmethod void methodcreateRP3(){
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
        Language__c Language1 = new Language__c (Name='Hindi',Language_Code_2__c='hi',Language_Order__c = 3);
         listLang.add(Language1);
        Language__c Language2 = new Language__c (Name='Tamil',Language_Code_2__c='ta',Language_Order__c = 3);
         listLang.add(Language2);
        insert listLang;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        insert listAvailLang;
        
        // Test country for country grp 
        country__c con= new country__c(Name='Australia',Country_Code__c='AUS', Country_Code2__c='AU',Channel__c='DTD;EST');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language.Id,Level__c='1');
        insert langPrefTest;
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language2.Id,Level__c='2');
        insert langPrefTest1;        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language1.Id,Level__c='3');
        insert langPrefTest2;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='Australia and NZ');
        insert conGrp;
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                       end_date__c=date.today()+40,start_Date__c=date.today()+20, Rights_End__c=date.today()+50,Exclusive_Date__c=date.today()+10);
        //insert commTest;
               
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        //caList.add(commRec);
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);
        //System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());      
        
        ccc.getCountryGroup();
        ccc.englishOnlyChk = true;
        ccc.countryGrpId=conGrpCon.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.obj.Country_Group__c = conGrp.Id;
        ccc.findCountry();
        ccc.channelgrid();   
        System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());
        ccc.cancel();
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        // test channel grid           
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.today()+40;
        commAvailTest.Exclusive_Date__c=date.today()+5; 
        commAvailTest.Start_Date__c= date.today()+10;
        commAvailTest.End_Date__c=date.today()+40;
        commAvailTest.status__c='Draft';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Channel__c = 'EST';
        listComm.add(commAvailTest);
        System.debug('TEST CLASS-------------2.'+ccc.channelGridList.size());      
        
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
        ccc.mapRightsDate(listComm);
        System.debug('TEST CLASS-------------3.'+ccc.channelGridList.size());      
        for(Integer j=0; j<ccc.channelGridList.size(); j++){
            System.debug('TEST CLASS Country Channel loop 1-------------'+ccc.channelGridList[j].countryChannel);
            System.debug('TEST CLASS rp------------- loop 1'+ccc.channelGridList[j].additionalInfo);
            ccc.channelGridList[j].additionalInfo.Exclusive_Date__c=date.today()+5;
            ccc.channelGridList[j].additionalInfo.Start_Date__c=date.today()+10;
            ccc.channelGridList[j].additionalInfo.End_Date__c=date.today()+40;
            ccc.channelGridList[j].additionalInfo.Rights_End__c=date.today()+40;
            System.debug('TEST CLASS Country Channel loop 1 AFTER-------------'+ccc.channelGridList[j].countryChannel);
            System.debug('TEST CLASS rp------------- loop 1 AFTER  '+ccc.channelGridList[j].additionalInfo);
        }       
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper.countryChannel = 'EST';
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper2 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper2.countryChannel = 'DTD';
        
        channelWrapper.additionalInfo = commAvailTest;
        channelWrapper2.additionalInfo = commTest;
        
        ccc.channelGridList.add(channelWrapper); 
        ccc.channelGridList.add(channelWrapper2); 
        /*
        for(WB_CreateReleasePlan_Controller.channelWrapper cr: ccc.channelGridList){
         if(cr.additionalInfo.Rights_End__c==null)
         ccc.channelGridList.remove();
        }*/
        //Integer gridsize = ccc.channelGridList.size();
        ccc.titleList = testTitleList;
        ccc.isRightToCreateRPChk = True;
        ccc.isRightToCreateRPEND= True;
        ccc.ConfirmedPartialAllow = 'Yes';
        ccc.chkRightsStatus();
         System.debug('TEST CLASS-------------4.'+ccc.channelGridList.size());
         for(Integer j=0; j<ccc.channelGridList.size(); j++){
            System.debug('TEST CLASS Country Channel-------------loop 2'+ccc.channelGridList[j].countryChannel);
            System.debug('TEST CLASS rp------------- loop 2'+ccc.channelGridList[j].additionalInfo);
            
        } 
        ccc.bulksave();
        Test.stoptest();
    }
    
    public static testmethod void methodcreateRP4(){
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
        Language__c Language1 = new Language__c (Name='Hindi',Language_Code_2__c='hi',Language_Order__c = 3);
         listLang.add(Language1);
		 Language__c Language2 = new Language__c (Name='Tamil',Language_Code_2__c='ta',Language_Order__c = 3);
         listLang.add(Language2);
        insert listLang;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        insert listAvailLang;
        
        // Test country for country grp 
        country__c con= new country__c(Name='Australia',Country_Code__c='AUS', Country_Code2__c='AU',Channel__c='DTD;EST');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language.Id,Level__c='1');
        insert langPrefTest;
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language2.Id,Level__c='2');
        insert langPrefTest1;        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language1.Id,Level__c='3');
        insert langPrefTest2;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='Australia and NZ');
        insert conGrp;
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                       end_date__c=date.today()+40,start_Date__c=date.today()+20, Rights_End__c=date.today()+50,Exclusive_Date__c=date.today()+10);
        //insert commTest;
               
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        //caList.add(commRec);
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);
        //System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());      
        
        ccc.getCountryGroup();
        ccc.englishOnlyChk = true;
        ccc.countryGrpId=conGrpCon.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.obj.Country_Group__c = conGrp.Id;
        ccc.findCountry();
        ccc.channelgrid();   
        System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());
        ccc.cancel();
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        // test channel grid           
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.today()+40;
        commAvailTest.Exclusive_Date__c=date.today()+5; 
        commAvailTest.Start_Date__c= date.today()+10;
        commAvailTest.End_Date__c=date.today()+40;
        commAvailTest.status__c='Draft';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Channel__c = 'EST';
        listComm.add(commAvailTest);
        System.debug('TEST CLASS-------------2.'+ccc.channelGridList.size());      
        
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
        ccc.mapRightsDate(listComm);
        System.debug('TEST CLASS-------------3.'+ccc.channelGridList.size());      
        for(Integer j=0; j<ccc.channelGridList.size(); j++){
            System.debug('TEST CLASS Country Channel loop 1-------------'+ccc.channelGridList[j].countryChannel);
            System.debug('TEST CLASS rp------------- loop 1'+ccc.channelGridList[j].additionalInfo);
            ccc.channelGridList[j].additionalInfo.Exclusive_Date__c=date.today()+5;
            ccc.channelGridList[j].additionalInfo.Start_Date__c=date.today()+10;
            ccc.channelGridList[j].additionalInfo.End_Date__c=date.today()+40;
            ccc.channelGridList[j].additionalInfo.Rights_End__c=date.today()+40;
            System.debug('TEST CLASS Country Channel loop 1 AFTER-------------'+ccc.channelGridList[j].countryChannel);
            System.debug('TEST CLASS rp------------- loop 1 AFTER  '+ccc.channelGridList[j].additionalInfo);
        }       
        /*WB_CreateReleasePlan_Controller.channelWrapper channelWrapper = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper.countryChannel = 'EST';
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper2 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper2.countryChannel = 'DTD';
        
        channelWrapper.additionalInfo = commAvailTest;
        channelWrapper2.additionalInfo = commTest;
        
        ccc.channelGridList.add(channelWrapper); 
        ccc.channelGridList.add(channelWrapper2); */
        /*
        for(WB_CreateReleasePlan_Controller.channelWrapper cr: ccc.channelGridList){
         if(cr.additionalInfo.Rights_End__c==null)
         ccc.channelGridList.remove();
        }*/
        //Integer gridsize = ccc.channelGridList.size();
        ccc.titleList = testTitleList;
        ccc.isRightToCreateRPChk = True;
        ccc.isRightToCreateRPEND= True;
        ccc.ConfirmedPartialAllow = 'Yes';
        ccc.chkRightsStatus();
         System.debug('TEST CLASS-------------4.'+ccc.channelGridList.size());
         for(Integer j=0; j<ccc.channelGridList.size(); j++){
            System.debug('TEST CLASS Country Channel-------------loop 2'+ccc.channelGridList[j].countryChannel);
            System.debug('TEST CLASS rp------------- loop 2'+ccc.channelGridList[j].additionalInfo);
            
        } 
        ccc.bulksave();
        Test.stoptest();
    }
    
    public static testmethod void methodcreateRP5(){
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
        Language__c Language1 = new Language__c (Name='Hindi',Language_Code_2__c='hi',Language_Order__c = 3);
         listLang.add(Language1);
		 Language__c Language2 = new Language__c (Name='Tamil',Language_Code_2__c='ta',Language_Order__c = 3);
         listLang.add(Language2);
        insert listLang;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        insert listAvailLang;
        
        // Test country for country grp 
        country__c con= new country__c(Name='Australia',Country_Code__c='AUS', Country_Code2__c='AU',Channel__c='DTD;EST');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language.Id,Level__c='1');
        insert langPrefTest;
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language2.Id,Level__c='2');
        insert langPrefTest1;        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language1.Id,Level__c='3');
        insert langPrefTest2;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='Australia and NZ');
        insert conGrp;
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                       end_date__c=date.today()+40,start_Date__c=date.today()+20, Rights_End__c=date.today()+50,Exclusive_Date__c=date.today()+10);
        //insert commTest;
               
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        //caList.add(commRec);
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);
        //System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());      
        
        ccc.getCountryGroup();
        ccc.englishOnlyChk = true;
        ccc.countryGrpId=conGrpCon.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.obj.Country_Group__c = conGrp.Id;
        ccc.findCountry();
        ccc.channelgrid();   
        System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());
        ccc.cancel();
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        // test channel grid           
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.today()+40;
        commAvailTest.Exclusive_Date__c=date.today()+5; 
        commAvailTest.Start_Date__c= date.today()+10;
        commAvailTest.End_Date__c=date.today()+40;
        commAvailTest.status__c='Draft';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Channel__c = 'EST';
        listComm.add(commAvailTest);
        System.debug('TEST CLASS-------------2.'+ccc.channelGridList.size());      
        
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
        ccc.mapRightsDate(listComm);
        System.debug('TEST CLASS-------------3.'+ccc.channelGridList.size());      
        for(Integer j=0; j<ccc.channelGridList.size(); j++){
            System.debug('TEST CLASS Country Channel loop 1-------------'+ccc.channelGridList[j].countryChannel);
            System.debug('TEST CLASS rp------------- loop 1'+ccc.channelGridList[j].additionalInfo);
            ccc.channelGridList[j].additionalInfo.Exclusive_Date__c=date.today()+5;
            ccc.channelGridList[j].additionalInfo.Start_Date__c=date.today()+10;
            ccc.channelGridList[j].additionalInfo.End_Date__c=date.today()+40;
            ccc.channelGridList[j].additionalInfo.Rights_End__c=date.today()+40;
            System.debug('TEST CLASS Country Channel loop 1 AFTER-------------'+ccc.channelGridList[j].countryChannel);
            System.debug('TEST CLASS rp------------- loop 1 AFTER  '+ccc.channelGridList[j].additionalInfo);
        }       
        
        ccc.titleList = testTitleList;
        ccc.isRightToCreateRPChk = TRUE;
        ccc.isRightToCreateRPEND= FALSE;
        ccc.ConfirmedPartialAllow = 'Yes';
        ccc.chkRightsStatus();
         System.debug('TEST CLASS-------------4.'+ccc.channelGridList.size());
         for(Integer j=0; j<ccc.channelGridList.size(); j++){
            System.debug('TEST CLASS Country Channel-------------loop 2'+ccc.channelGridList[j].countryChannel);
            System.debug('TEST CLASS rp------------- loop 2'+ccc.channelGridList[j].additionalInfo);
            
        } 
        ccc.bulksave();
        Test.stoptest();
    }
    
    public static testmethod void methodcreateRP6(){
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
        Language__c Language1 = new Language__c (Name='Hindi',Language_Code_2__c='hi',Language_Order__c = 3);
        listLang.add(Language1);
		Language__c Language2 = new Language__c (Name='Tamil',Language_Code_2__c='ta',Language_Order__c = 3);
        listLang.add(Language2);
        insert listLang;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        insert listAvailLang;
        
        // Test country for country grp 
        country__c con= new country__c(Name='Australia',Country_Code__c='AUS', Country_Code2__c='AU',Channel__c='DTD;EST');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language.Id,Level__c='1');
        insert langPrefTest;
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language2.Id,Level__c='2');
        insert langPrefTest1;        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language1.Id,Level__c='3');
        insert langPrefTest2;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='Australia and NZ');
        insert conGrp;
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                       end_date__c=date.today()+40,start_Date__c=date.today()+20, Rights_End__c=date.today()+50,Exclusive_Date__c=date.today()+10);
        //insert commTest;
               
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        //caList.add(commRec);
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);
        //System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());      
        
        ccc.getCountryGroup();
        ccc.englishOnlyChk = true;
        ccc.countryGrpId=conGrpCon.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.obj.Country_Group__c = conGrp.Id;
        ccc.findCountry();
        ccc.channelgrid();   
        System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());
        ccc.cancel();
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        // test channel grid           
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.today()+40;
        commAvailTest.Exclusive_Date__c=date.today()+5; 
        commAvailTest.Start_Date__c= date.today()+10;
        commAvailTest.End_Date__c=date.today()+40;
        commAvailTest.status__c='Draft';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Channel__c = 'EST';
        listComm.add(commAvailTest);
        System.debug('TEST CLASS-------------2.'+ccc.channelGridList.size());      
        
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
        ccc.mapRightsDate(listComm);
        System.debug('TEST CLASS-------------3.'+ccc.channelGridList.size());      
        for(Integer j=0; j<ccc.channelGridList.size(); j++){
            System.debug('TEST CLASS Country Channel loop 1-------------'+ccc.channelGridList[j].countryChannel);
            System.debug('TEST CLASS rp------------- loop 1'+ccc.channelGridList[j].additionalInfo);
            ccc.channelGridList[j].additionalInfo.Exclusive_Date__c=date.today()+5;
            ccc.channelGridList[j].additionalInfo.Start_Date__c=date.today()+10;
            ccc.channelGridList[j].additionalInfo.End_Date__c=date.today()+40;
            ccc.channelGridList[j].additionalInfo.Rights_End__c=date.today()+40;
            System.debug('TEST CLASS Country Channel loop 1 AFTER-------------'+ccc.channelGridList[j].countryChannel);
            System.debug('TEST CLASS rp------------- loop 1 AFTER  '+ccc.channelGridList[j].additionalInfo);
        }       
        
        ccc.titleList = testTitleList;
        ccc.isRightToCreateRPChk = FALSE;
        ccc.isRightToCreateRPEND= TRUE;
        ccc.ConfirmedPartialAllow = 'Yes';
        ccc.chkRightsStatus();
         System.debug('TEST CLASS-------------4.'+ccc.channelGridList.size());
         for(Integer j=0; j<ccc.channelGridList.size(); j++){
            System.debug('TEST CLASS Country Channel-------------loop 2'+ccc.channelGridList[j].countryChannel);
            System.debug('TEST CLASS rp------------- loop 2'+ccc.channelGridList[j].additionalInfo);
            
        } 
        ccc.bulksave();
        Test.stoptest();
    }
    
    public static testmethod void methodcreateRP7(){
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
        Language__c Language1 = new Language__c (Name='Hindi',Language_Code_2__c='hi',Language_Order__c = 3);
         listLang.add(Language1);
		 Language__c Language2 = new Language__c (Name='Tamil',Language_Code_2__c='ta',Language_Order__c = 3);
         listLang.add(Language2);
        insert listLang;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        insert listAvailLang;
        
        // Test country for country grp 
        country__c con= new country__c(Name='Australia',Country_Code__c='AUS', Country_Code2__c='AU',Channel__c='DTD;EST');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language.Id,Level__c='1');
        insert langPrefTest;
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language2.Id,Level__c='2');
        insert langPrefTest1;        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language1.Id,Level__c='3');
        insert langPrefTest2;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='Australia and NZ');
        insert conGrp;
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                       end_date__c=date.today()+40,start_Date__c=date.today()+20, Rights_End__c=date.today()+50,Exclusive_Date__c=date.today()+10);
        //insert commTest;
               
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        //caList.add(commRec);
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);
        //System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());      
        
        ccc.getCountryGroup();
        ccc.englishOnlyChk = true;
        ccc.countryGrpId=conGrpCon.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.obj.Country_Group__c = conGrp.Id;
        ccc.findCountry();
        ccc.channelgrid();   
        System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());
        ccc.cancel();
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        // test channel grid           
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.today()+40;
        commAvailTest.Exclusive_Date__c=date.today()+5; 
        commAvailTest.Start_Date__c= date.today()+10;
        commAvailTest.End_Date__c=date.today()+40;
        commAvailTest.status__c='Draft';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Channel__c = 'EST';
        listComm.add(commAvailTest);
        System.debug('TEST CLASS-------------2.'+ccc.channelGridList.size());      
        
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
        ccc.mapRightsDate(listComm);
        System.debug('TEST CLASS-------------3.'+ccc.channelGridList.size());      
        for(Integer j=0; j<ccc.channelGridList.size(); j++){
            System.debug('TEST CLASS Country Channel loop 1-------------'+ccc.channelGridList[j].countryChannel);
            System.debug('TEST CLASS rp------------- loop 1'+ccc.channelGridList[j].additionalInfo);
            ccc.channelGridList[j].additionalInfo.Exclusive_Date__c=date.today()+5;
            ccc.channelGridList[j].additionalInfo.Start_Date__c=date.today()+10;
            ccc.channelGridList[j].additionalInfo.End_Date__c=date.today()+40;
            ccc.channelGridList[j].additionalInfo.Rights_End__c=date.today()+40;
            System.debug('TEST CLASS Country Channel loop 1 AFTER-------------'+ccc.channelGridList[j].countryChannel);
            System.debug('TEST CLASS rp------------- loop 1 AFTER  '+ccc.channelGridList[j].additionalInfo);
        }       
        
        ccc.titleList = testTitleList;
        ccc.isRightToCreateRPChk = FALSE;
        ccc.isRightToCreateRPEND= FALSE;
        ccc.ConfirmedPartialAllow = 'Yes';
        ccc.chkRightsStatus();
         System.debug('TEST CLASS-------------4.'+ccc.channelGridList.size());
         for(Integer j=0; j<ccc.channelGridList.size(); j++){
            System.debug('TEST CLASS Country Channel-------------loop 2'+ccc.channelGridList[j].countryChannel);
            System.debug('TEST CLASS rp------------- loop 2'+ccc.channelGridList[j].additionalInfo);
            
        } 
        ccc.bulksave();
        Test.stoptest();
    }
    
    public static testmethod void methodcreateRP8(){
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
        Language__c Language1 = new Language__c (Name='Hindi',Language_Code_2__c='hi',Language_Order__c = 3);
         listLang.add(Language1);
		Language__c Language2 = new Language__c (Name='Tamil',Language_Code_2__c='ta',Language_Order__c = 3);
         listLang.add(Language2);
        insert listLang;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        insert listAvailLang;
        
        // Test country for country grp 
        country__c con= new country__c(Name='Australia',Country_Code__c='AUS', Country_Code2__c='AU',Channel__c='DTD;EST');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language.Id,Level__c='1');
        insert langPrefTest;
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language2.Id,Level__c='2');
        insert langPrefTest1;        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language1.Id,Level__c='3');
        insert langPrefTest2;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='Australia and NZ');
        insert conGrp;
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                       end_date__c=date.today()+40,start_Date__c=date.today()+20, Rights_End__c=date.today()+50,Exclusive_Date__c=date.today()+10);
        //insert commTest;
               
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        //caList.add(commRec);
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);
        //System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());      
        
        ccc.getCountryGroup();
        ccc.englishOnlyChk = true;
        ccc.countryGrpId=conGrpCon.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.obj.Country_Group__c = conGrp.Id;
        ccc.findCountry();
        ccc.channelgrid();   
        System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());
        ccc.cancel();
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        // test channel grid           
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.today()+40;
        commAvailTest.Exclusive_Date__c=date.today()+5; 
        commAvailTest.Start_Date__c= date.today()+10;
        commAvailTest.End_Date__c=date.today()+40;
        commAvailTest.status__c='Draft';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Channel__c = 'EST';
        listComm.add(commAvailTest);
        System.debug('TEST CLASS-------------2.'+ccc.channelGridList.size());      
        
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
        ccc.mapRightsDate(listComm);
        System.debug('TEST CLASS-------------3.'+ccc.channelGridList.size());      
        for(Integer j=0; j<ccc.channelGridList.size(); j++){
            System.debug('TEST CLASS Country Channel loop 1-------------'+ccc.channelGridList[j].countryChannel);
            System.debug('TEST CLASS rp------------- loop 1'+ccc.channelGridList[j].additionalInfo);
            ccc.channelGridList[j].additionalInfo.Exclusive_Date__c=date.today()+40;
            ccc.channelGridList[j].additionalInfo.Start_Date__c=date.today()+10;
            ccc.channelGridList[j].additionalInfo.End_Date__c=date.today()+40;
            ccc.channelGridList[j].additionalInfo.Rights_End__c=date.today()+36;
            System.debug('TEST CLASS Country Channel loop 1 AFTER-------------'+ccc.channelGridList[j].countryChannel);
            System.debug('TEST CLASS rp------------- loop 1 AFTER  '+ccc.channelGridList[j].additionalInfo);
        }       
        
        ccc.titleList = testTitleList;
        ccc.isRightToCreateRPChk = FALSE;
        ccc.isRightToCreateRPEND= FALSE;
        ccc.ConfirmedPartialAllow = 'Yes';
        ccc.chkRightsStatus();
         System.debug('TEST CLASS-------------4.'+ccc.channelGridList.size());
         for(Integer j=0; j<ccc.channelGridList.size(); j++){
            System.debug('TEST CLASS Country Channel-------------loop 2'+ccc.channelGridList[j].countryChannel);
            System.debug('TEST CLASS rp------------- loop 2'+ccc.channelGridList[j].additionalInfo);
            
        } 
        ccc.channelGridValidation();
        Test.stoptest();
    }
    
    public static testmethod void methodcreateRP9(){
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
        Language__c Language1 = new Language__c (Name='Hindi',Language_Code_2__c='hi',Language_Order__c = 3);
         listLang.add(Language1);
		Language__c Language2 = new Language__c (Name='Tamil',Language_Code_2__c='ta',Language_Order__c = 3);
         listLang.add(Language2);
        insert listLang;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        insert listAvailLang;
        
        // Test country for country grp 
        country__c con= new country__c(Name='Australia',Country_Code__c='AUS', Country_Code2__c='AU',Channel__c='DTD;EST');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language.Id,Level__c='1');
        insert langPrefTest;
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language2.Id,Level__c='2');
        insert langPrefTest1;        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language1.Id,Level__c='3');
        insert langPrefTest2;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='Australia and NZ');
        insert conGrp;
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                       end_date__c=date.today()+40,start_Date__c=date.today()+20, Rights_End__c=date.today()+50,Exclusive_Date__c=date.today()+10);
        //insert commTest;
               
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        //caList.add(commRec);
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);
        //System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());      
        
        ccc.getCountryGroup();
        ccc.englishOnlyChk = true;
        ccc.countryGrpId=conGrpCon.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.obj.Country_Group__c = conGrp.Id;
        ccc.findCountry();
        ccc.channelgrid();   
        System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());
        ccc.cancel();
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        // test channel grid           
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.today()+40;
        commAvailTest.Exclusive_Date__c=date.today()+5; 
        commAvailTest.Start_Date__c= date.today()+10;
        commAvailTest.End_Date__c=date.today()+40;
        commAvailTest.status__c='Draft';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Channel__c = 'EST';
        listComm.add(commAvailTest);
        System.debug('TEST CLASS-------------2.'+ccc.channelGridList.size());      
        
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
        ccc.mapRightsDate(listComm);
              
        
            ccc.channelGridList[0].additionalInfo.Exclusive_Date__c=date.today()+40;
            ccc.channelGridList[0].additionalInfo.Start_Date__c=date.today()+38;
            ccc.channelGridList[0].additionalInfo.End_Date__c=date.today()+40;
            ccc.channelGridList[0].additionalInfo.Rights_End__c=date.today()+37;
            ccc.channelGridList[1].additionalInfo.Exclusive_Date__c=date.today()+40;
            ccc.channelGridList[1].additionalInfo.Start_Date__c=date.today()+38;
            ccc.channelGridList[1].additionalInfo.End_Date__c=date.today()+40;
            ccc.channelGridList[1].additionalInfo.Rights_End__c=date.today()+37;
            
               
        
        ccc.titleList = testTitleList;
        ccc.isRightToCreateRPChk = FALSE;
        ccc.isRightToCreateRPEND= FALSE;
        ccc.ConfirmedPartialAllow = 'Yes';
        ccc.chkRightsStatus();
         System.debug('TEST CLASS-------------4.'+ccc.channelGridList.size());
        ccc.channelGridValidation();
        Test.stoptest();
    }
    //tentative
    public static testmethod void methodcreateRP10(){
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
        Language__c Language1 = new Language__c (Name='Hindi',Language_Code_2__c='hi',Language_Order__c = 3);
         listLang.add(Language1);
		 Language__c Language2 = new Language__c (Name='Tamil',Language_Code_2__c='ta',Language_Order__c = 3);
         listLang.add(Language2);
        insert listLang;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        insert listAvailLang;
        
        // Test country for country grp 
        country__c con= new country__c(Name='Australia',Country_Code__c='AUS', Country_Code2__c='AU',Channel__c='DTD;EST');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language.Id,Level__c='1');
        insert langPrefTest;
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language2.Id,Level__c='2');
        insert langPrefTest1;        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language1.Id,Level__c='3');
        insert langPrefTest2;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='Australia and NZ');
        insert conGrp;
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                       end_date__c=date.today()+40,start_Date__c=date.today()+20, Rights_End__c=date.today()+50,Exclusive_Date__c=date.today()+10);
        //insert commTest;
               
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        //caList.add(commRec);
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);
        //System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());      
        
        ccc.getCountryGroup();
        ccc.englishOnlyChk = true;
        ccc.countryGrpId=conGrpCon.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.obj.Country_Group__c = conGrp.Id;
        ccc.findCountry();
        ccc.channelgrid();   
        System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());
        ccc.cancel();
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        // test channel grid           
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.today()+40;
        commAvailTest.Exclusive_Date__c=date.today()+5; 
        commAvailTest.Start_Date__c= date.today()+10;
        commAvailTest.End_Date__c=date.today()+40;
        commAvailTest.status__c='Draft';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Channel__c = 'EST';
        listComm.add(commAvailTest);
        System.debug('TEST CLASS-------------2.'+ccc.channelGridList.size());      
        
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
        ccc.mapRightsDate(listComm);
              
        
            ccc.channelGridList[0].additionalInfo.Exclusive_Date__c=null;
            ccc.channelGridList[0].additionalInfo.Start_Date__c=date.today()+37;
            ccc.channelGridList[0].additionalInfo.End_Date__c=date.today()+40;
            ccc.channelGridList[0].additionalInfo.Rights_End__c=date.today()+36;
            ccc.channelGridList[0].additionalInfo.Status__c='Tentative';
            
            ccc.channelGridList[1].additionalInfo.Exclusive_Date__c=date.today()+40;
            ccc.channelGridList[1].additionalInfo.Start_Date__c=date.today()+36;
            ccc.channelGridList[1].additionalInfo.End_Date__c=date.today()+40;
            ccc.channelGridList[1].additionalInfo.Status__c='Tentative';
        
        ccc.titleList = testTitleList;
        ccc.isRightToCreateRPChk = FALSE;
        ccc.isRightToCreateRPEND= FALSE;
        ccc.ConfirmedPartialAllow = 'Yes';
        ccc.chkRightsStatus();
         System.debug('TEST CLASS-------------4.'+ccc.channelGridList.size());
        ccc.channelGridValidation();
        Test.stoptest();
    }
    
     //not releasing
    public static testmethod void methodcreateRP11(){
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
        Language__c Language1 = new Language__c (Name='Hindi',Language_Code_2__c='hi',Language_Order__c = 3);
         listLang.add(Language1);
		 Language__c Language2 = new Language__c (Name='Tamil',Language_Code_2__c='ta',Language_Order__c = 3);
         listLang.add(Language2);
        insert listLang;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        insert listAvailLang;
        
        // Test country for country grp 
        country__c con= new country__c(Name='Australia',Country_Code__c='AUS', Country_Code2__c='AU',Channel__c='DTD;EST');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language.Id,Level__c='1');
        insert langPrefTest;
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language2.Id,Level__c='2');
        insert langPrefTest1;        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language1.Id,Level__c='3');
        insert langPrefTest2;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='Australia and NZ');
        insert conGrp;
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                       end_date__c=date.today()+40,start_Date__c=date.today()+20, Rights_End__c=date.today()+50,Exclusive_Date__c=date.today()+10);
        //insert commTest;
               
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        //caList.add(commRec);
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);
        //System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());      
        
        ccc.getCountryGroup();
        ccc.englishOnlyChk = true;
        ccc.countryGrpId=conGrpCon.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.obj.Country_Group__c = conGrp.Id;
        ccc.findCountry();
        ccc.channelgrid();   
        System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());
        ccc.cancel();
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        // test channel grid           
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.today()+40;
        commAvailTest.Exclusive_Date__c=date.today()+5; 
        commAvailTest.Start_Date__c= date.today()+10;
        commAvailTest.End_Date__c=date.today()+40;
        commAvailTest.status__c='Draft';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Channel__c = 'EST';
        listComm.add(commAvailTest);
        System.debug('TEST CLASS-------------2.'+ccc.channelGridList.size());      
        
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
        ccc.mapRightsDate(listComm);
              
        
            ccc.channelGridList[0].additionalInfo.Exclusive_Date__c=null;
            ccc.channelGridList[0].additionalInfo.Start_Date__c=date.today()+37;
            ccc.channelGridList[0].additionalInfo.End_Date__c=date.today()+40;
            ccc.channelGridList[0].additionalInfo.Rights_End__c=date.today()+37;
            ccc.channelGridList[0].additionalInfo.Status__c='Not releasing';
            
            ccc.channelGridList[1].additionalInfo.Exclusive_Date__c=date.today()+40;
            ccc.channelGridList[1].additionalInfo.Start_Date__c=date.today()+37;
            ccc.channelGridList[1].additionalInfo.End_Date__c=date.today()+40;
            ccc.channelGridList[1].additionalInfo.Status__c='Not releasing';
        
        ccc.titleList = testTitleList;
        ccc.isRightToCreateRPChk = FALSE;
        ccc.isRightToCreateRPEND= FALSE;
        ccc.ConfirmedPartialAllow = 'Yes';
        ccc.chkRightsStatus();
         System.debug('TEST CLASS-------------4.'+ccc.channelGridList.size());
        ccc.channelGridValidation();
        Test.stoptest();
    }
    
    //open
     public static testmethod void methodcreateRP12(){
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
        Language__c Language1 = new Language__c (Name='Hindi',Language_Code_2__c='hi',Language_Order__c = 3);
         listLang.add(Language1);
		 Language__c Language2 = new Language__c (Name='Tamil',Language_Code_2__c='ta',Language_Order__c = 3);
         listLang.add(Language2);
        insert listLang;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        insert listAvailLang;
        
        // Test country for country grp 
        country__c con= new country__c(Name='Australia',Country_Code__c='AUS', Country_Code2__c='AU',Channel__c='DTD;EST');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language.Id,Level__c='1');
        insert langPrefTest;
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language2.Id,Level__c='2');
        insert langPrefTest1;        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language1.Id,Level__c='3');
        insert langPrefTest2;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='Australia and NZ');
        insert conGrp;
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                       end_date__c=date.today()+40,start_Date__c=date.today()+20, Rights_End__c=date.today()+50,Exclusive_Date__c=date.today()+10);
        //insert commTest;
               
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        //caList.add(commRec);
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);
        //System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());      
        
        ccc.getCountryGroup();
        ccc.englishOnlyChk = true;
        ccc.countryGrpId=conGrpCon.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.obj.Country_Group__c = conGrp.Id;
        ccc.findCountry();
        ccc.channelgrid();   
        System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());
        ccc.cancel();
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        // test channel grid           
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.today()+40;
        commAvailTest.Exclusive_Date__c=date.today()+5; 
        commAvailTest.Start_Date__c= date.today()+10;
        commAvailTest.End_Date__c=date.today()+40;
        commAvailTest.status__c='Draft';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Channel__c = 'EST';
        listComm.add(commAvailTest);
        System.debug('TEST CLASS-------------2.'+ccc.channelGridList.size());      
        
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
        ccc.mapRightsDate(listComm);
              
        
            ccc.channelGridList[0].additionalInfo.Exclusive_Date__c=null;
            ccc.channelGridList[0].additionalInfo.Start_Date__c=date.today()+38;
            ccc.channelGridList[0].additionalInfo.End_Date__c=date.today()+35;
            ccc.channelGridList[0].additionalInfo.Rights_End__c=date.today()+40;
            ccc.channelGridList[0].additionalInfo.Status__c='Open';
            
            ccc.channelGridList[1].additionalInfo.Exclusive_Date__c=date.today()+60;
            ccc.channelGridList[1].additionalInfo.Start_Date__c=date.today()+38;
            ccc.channelGridList[1].additionalInfo.End_Date__c=date.today()+40;
            ccc.channelGridList[0].additionalInfo.Rights_End__c=date.today()+40;
            ccc.channelGridList[1].additionalInfo.Status__c='Open';
        
        ccc.titleList = testTitleList;
        ccc.isRightToCreateRPChk = TRUE;
        ccc.isRightToCreateRPEND= FALSE;
        ccc.ConfirmedPartialAllow = 'Yes';
        ccc.chkRightsStatus();
         System.debug('TEST CLASS-------------4.'+ccc.channelGridList.size());
        ccc.channelGridValidation();
        Test.stoptest();
    }
    
    //Tentative - Start TRUE
     public static testmethod void methodcreateRP13(){
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
        Language__c Language1 = new Language__c (Name='Hindi',Language_Code_2__c='hi',Language_Order__c = 3);
         listLang.add(Language1);
		 Language__c Language2 = new Language__c (Name='Tamil',Language_Code_2__c='ta',Language_Order__c = 3);
         listLang.add(Language2);
        insert listLang;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        insert listAvailLang;
        
        // Test country for country grp 
        country__c con= new country__c(Name='Australia',Country_Code__c='AUS', Country_Code2__c='AU',Channel__c='DTD;EST');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language.Id,Level__c='1');
        insert langPrefTest;
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language2.Id,Level__c='2');
        insert langPrefTest1;        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language1.Id,Level__c='3');
        insert langPrefTest2;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='Australia and NZ');
        insert conGrp;
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                       end_date__c=date.today()+40,start_Date__c=date.today()+20, Rights_End__c=date.today()+50,Exclusive_Date__c=date.today()+10);
        //insert commTest;
               
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        //caList.add(commRec);
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);
        //System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());      
        
        ccc.getCountryGroup();
        ccc.englishOnlyChk = true;
        ccc.countryGrpId=conGrpCon.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.obj.Country_Group__c = conGrp.Id;
        ccc.findCountry();
        ccc.channelgrid();   
        System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());
        ccc.cancel();
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        // test channel grid           
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.today()+40;
        commAvailTest.Exclusive_Date__c=date.today()+5; 
        commAvailTest.Start_Date__c= date.today()+10;
        commAvailTest.End_Date__c=date.today()+40;
        commAvailTest.status__c='Draft';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Channel__c = 'EST';
        listComm.add(commAvailTest);
        System.debug('TEST CLASS-------------2.'+ccc.channelGridList.size());      
        
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
        ccc.mapRightsDate(listComm);
              
        
            ccc.channelGridList[0].additionalInfo.Exclusive_Date__c=null;
            ccc.channelGridList[0].additionalInfo.Start_Date__c=date.today()+29;
            ccc.channelGridList[0].additionalInfo.End_Date__c=date.today()+31;
            ccc.channelGridList[0].additionalInfo.Rights_End__c=date.today()+40;
            ccc.channelGridList[0].additionalInfo.Status__c='Tentative';
            
            ccc.channelGridList[1].additionalInfo.Exclusive_Date__c=date.today()+40;
            ccc.channelGridList[1].additionalInfo.Start_Date__c=date.today()+37;
            ccc.channelGridList[1].additionalInfo.End_Date__c=date.today()+40;
            ccc.channelGridList[1].additionalInfo.Rights_End__c=null;
            ccc.channelGridList[1].additionalInfo.Status__c='Tentative';
        
        ccc.titleList = testTitleList;
        ccc.isRightToCreateRPChk = TRUE;
        ccc.isRightToCreateRPEND= FALSE;
        ccc.ConfirmedPartialAllow = 'Yes';
        ccc.chkRightsStatus();
         System.debug('TEST CLASS-------------4.'+ccc.channelGridList.size());
        ccc.channelGridValidation();
        Test.stoptest();
    }
    
    //Tentative - END TRUE
     public static testmethod void methodcreateRP14(){
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
        Language__c Language1 = new Language__c (Name='Hindi',Language_Code_2__c='hi',Language_Order__c = 3);
         listLang.add(Language1);
		 Language__c Language2 = new Language__c (Name='Tamil',Language_Code_2__c='ta',Language_Order__c = 3);
         listLang.add(Language2);
        insert listLang;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        insert listAvailLang;
        
        // Test country for country grp 
        country__c con= new country__c(Name='Australia',Country_Code__c='AUS', Country_Code2__c='AU',Channel__c='DTD;EST');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language.Id,Level__c='1');
        insert langPrefTest;
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language2.Id,Level__c='2');
        insert langPrefTest1;        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language1.Id,Level__c='3');
        insert langPrefTest2;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='Australia and NZ');
        insert conGrp;
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                       end_date__c=date.today()+40,start_Date__c=date.today()+20, Rights_End__c=date.today()+50,Exclusive_Date__c=date.today()+10);
        //insert commTest;
               
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        //caList.add(commRec);
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);
        //System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());      
        
        ccc.getCountryGroup();
        ccc.englishOnlyChk = true;
        ccc.countryGrpId=conGrpCon.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.obj.Country_Group__c = conGrp.Id;
        ccc.findCountry();
        ccc.channelgrid();   
        System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());
        ccc.cancel();
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        // test channel grid           
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.today()+40;
        commAvailTest.Exclusive_Date__c=date.today()+5; 
        commAvailTest.Start_Date__c= date.today()+10;
        commAvailTest.End_Date__c=date.today()+40;
        commAvailTest.status__c='Draft';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Channel__c = 'EST';
        listComm.add(commAvailTest);
        System.debug('TEST CLASS-------------2.'+ccc.channelGridList.size());      
        
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
        ccc.mapRightsDate(listComm);
              
        
            ccc.channelGridList[0].additionalInfo.Exclusive_Date__c=null;
            ccc.channelGridList[0].additionalInfo.Start_Date__c=date.today()+30;
            ccc.channelGridList[0].additionalInfo.End_Date__c=date.today()+40;
            ccc.channelGridList[0].additionalInfo.Rights_End__c=date.today()+44;
            ccc.channelGridList[0].additionalInfo.Status__c='Tentative';
            
            ccc.channelGridList[1].additionalInfo.Exclusive_Date__c=date.today()+40;
            ccc.channelGridList[1].additionalInfo.Start_Date__c=date.today()+38;
            ccc.channelGridList[1].additionalInfo.End_Date__c=date.today()+40;
            ccc.channelGridList[1].additionalInfo.Rights_End__c=null;
            ccc.channelGridList[1].additionalInfo.Status__c='Tentative';
        
        ccc.titleList = testTitleList;
        ccc.isRightToCreateRPChk = FALSE;
        ccc.isRightToCreateRPEND= TRUE;
        ccc.ConfirmedPartialAllow = 'Yes';
        ccc.chkRightsStatus();
         System.debug('TEST CLASS-------------4.'+ccc.channelGridList.size());
        ccc.channelGridValidation();
        Test.stoptest();
    }
    public static testmethod void methodcreateRP15(){
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
        Language__c Language1 = new Language__c (Name='Hindi',Language_Code_2__c='hi',Language_Order__c = 3);
         listLang.add(Language1);
		 Language__c Language2 = new Language__c (Name='Tamil',Language_Code_2__c='ta',Language_Order__c = 3);
         listLang.add(Language2);
        insert listLang;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        insert listAvailLang;
        
        // Test country for country grp 
        country__c con= new country__c(Name='Australia',Country_Code__c='AUS', Country_Code2__c='AU',Channel__c='DTD;EST');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language.Id,Level__c='1');
        insert langPrefTest;
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language2.Id,Level__c='2');
        insert langPrefTest1;        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language1.Id,Level__c='3');
        insert langPrefTest2;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='Australia and NZ');
        insert conGrp;
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                       end_date__c=date.today()+40,start_Date__c=date.today()+20, Rights_End__c=date.today()+50,Exclusive_Date__c=date.today()+10);
        //insert commTest;
               
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        //caList.add(commRec);
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);
        //System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());      
        
        ccc.getCountryGroup();
        ccc.englishOnlyChk = true;
        ccc.countryGrpId=conGrpCon.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.obj.Country_Group__c = conGrp.Id;
        ccc.findCountry();
        ccc.channelgrid();   
        System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());
        ccc.cancel();
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        // test channel grid           
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.today()+40;
        commAvailTest.Exclusive_Date__c=date.today()+5; 
        commAvailTest.Start_Date__c= date.today()+10;
        commAvailTest.End_Date__c=date.today()+40;
        commAvailTest.status__c='Draft';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Channel__c = 'EST';
        listComm.add(commAvailTest);
        System.debug('TEST CLASS-------------2.'+ccc.channelGridList.size());      
        
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
        ccc.mapRightsDate(listComm);
              
        
            ccc.channelGridList[0].additionalInfo.Exclusive_Date__c=null;
            ccc.channelGridList[0].additionalInfo.Start_Date__c=date.today()+80;
            ccc.channelGridList[0].additionalInfo.End_Date__c=date.today()+60;
            ccc.channelGridList[0].additionalInfo.Rights_End__c=date.today()+40;
            ccc.channelGridList[0].additionalInfo.Status__c='Draft';
            
            ccc.channelGridList[1].additionalInfo.Exclusive_Date__c=date.today()+60;
            ccc.channelGridList[1].additionalInfo.Start_Date__c=date.today()+38;
            ccc.channelGridList[1].additionalInfo.End_Date__c=date.today()+40;
            ccc.channelGridList[1].additionalInfo.Rights_End__c=date.today()+40;
            ccc.channelGridList[1].additionalInfo.Status__c='Open';
        
        ccc.titleList = testTitleList;
        ccc.isRightToCreateRPChk = TRUE;
        ccc.isRightToCreateRPEND= FALSE;
        ccc.ConfirmedPartialAllow = 'Yes';
        ccc.chkRightsStatus();
         System.debug('TEST CLASS-------------4.'+ccc.channelGridList.size());
        ccc.channelGridValidation();
        Test.stoptest();
    }
    
    public static testmethod void methodcreateRP16(){
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
        Language__c Language1 = new Language__c (Name='Hindi',Language_Code_2__c='hi',Language_Order__c = 3);
         listLang.add(Language1);
		 Language__c Language2 = new Language__c (Name='Tamil',Language_Code_2__c='ta',Language_Order__c = 3);
         listLang.add(Language2);
        insert listLang;
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        insert listAvailLang;
        
        // Test country for country grp 
        country__c con= new country__c(Name='Australia',Country_Code__c='AUS', Country_Code2__c='AU',Channel__c='DTD;EST;VODi');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language.Id,Level__c='1');
        insert langPrefTest;
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language2.Id,Level__c='2');
        insert langPrefTest1;        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Type__c = 'Country',Language__c=Language1.Id,Level__c='3');
        insert langPrefTest2;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='Australia and NZ');
        insert conGrp;
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                       end_date__c=date.today()+40,start_Date__c=date.today()+20, Rights_End__c=date.today()+50,Exclusive_Date__c=date.today()+10);
        //insert commTest;
               
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        //caList.add(commRec);
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);
        //System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());      
        
        ccc.getCountryGroup();
        ccc.englishOnlyChk = true;
        ccc.countryGrpId=conGrpCon.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        ccc.obj.Country_Group__c = conGrp.Id;
        ccc.findCountry();
        ccc.channelgrid();   
        System.debug('TEST CLASS-------------1.'+ccc.channelGridList.size());
        ccc.cancel();
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        // test channel grid           
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.today()+40;
        commAvailTest.Exclusive_Date__c=date.today()+5; 
        commAvailTest.Start_Date__c= date.today()+10;
        commAvailTest.End_Date__c=date.today()+40;
        commAvailTest.status__c='Draft';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Channel__c = 'EST';
        listComm.add(commAvailTest);
        System.debug('TEST CLASS-------------2.'+ccc.channelGridList.size());      
        
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
        ccc.mapRightsDate(listComm);
              
        
            ccc.channelGridList[0].additionalInfo.Exclusive_Date__c=null;
            ccc.channelGridList[0].additionalInfo.Start_Date__c=date.today()+36;
            ccc.channelGridList[0].additionalInfo.End_Date__c=date.today()+37;
            ccc.channelGridList[0].additionalInfo.Rights_End__c=date.today()+40;
            ccc.channelGridList[0].additionalInfo.Status__c='Draft';
            
            ccc.channelGridList[1].additionalInfo.Exclusive_Date__c=date.today()+40;
            ccc.channelGridList[1].additionalInfo.Start_Date__c=date.today()+38;
            ccc.channelGridList[1].additionalInfo.End_Date__c=date.today()+40;
            ccc.channelGridList[1].additionalInfo.Rights_End__c=date.today()+40;
            ccc.channelGridList[1].additionalInfo.Status__c='Open';
            
            ccc.channelGridList[2].additionalInfo.Exclusive_Date__c=date.today()+70;
            ccc.channelGridList[2].additionalInfo.Start_Date__c=date.today()+38;
            ccc.channelGridList[2].additionalInfo.End_Date__c=date.today()+40;
            ccc.channelGridList[2].additionalInfo.Rights_End__c=date.today()+40;
            ccc.channelGridList[2].additionalInfo.Status__c='Draft';
        
        ccc.titleList = testTitleList;
        ccc.isRightToCreateRPChk = FALSE;
        ccc.isRightToCreateRPEND= TRUE;
        ccc.ConfirmedPartialAllow = 'Yes';
        ccc.chkRightsStatus();
         System.debug('TEST CLASS-------------4.'+ccc.channelGridList.size());
        ccc.channelGridValidation();
        Test.stoptest();
    }
    
    public static testmethod void methodcreateRPBacth(){
        Map<String, String> mapRightsGrp = new Map<String, String>();
        List<Rights__c> lstRights = new List<Rights__c>();
        Set<String> SelectedFormatStrSet = new Set<String>{'VR','HD+DVD','HD+BD','SD','HD','3DHD','4K UHD','BD','DVD','3DBD' ,'4KBD'};
        
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch2',RP_Batch_Id__c='2' );
        insert batchIDs;
        
        MPM__c mpm = new MPM__c(name='MPM rec',MPM_Number__c='1234');
        insert mpm;
        
        Title__c title = new Title__c(Name='New Title', Video_Version__c='0723456789',Formats__c='HD',First_Available_Date__c=system.today(),MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        insert title;
        
        Title__c title2 = new Title__c(Name='New Title', Video_Version__c='0723456799',Formats__c='DVD',First_Available_Date__c=system.today(),MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description2',Physical_Planning__c='YES');
        insert title2;
        
        List<String> titleIdList = new List<String>();
        titleIdList.add(title.Id);
        titleIdList.add(title2.Id);
        
        
        List<Language__c> languages = new List<Language__c>();
        Language__c Language1 = new Language__c (Name='English',Language_Order__c = 1,Language_Code_2__c = 'en');
        languages.add(Language1);
        
        Language__c Language2 = new Language__c (Name='Arabic', Language_Order__c = 1,Language_Code_2__c = 'ar');
        languages.add(Language2);
        
        insert languages;
        
        List<Available_Languages__c> availLangs = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Languages[0].Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        availLangs.add(availLangTitle1);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=Languages[0].Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);
        availLangs.add(availLangTitle2);
        Available_Languages__c availLangTitle3 = new Available_Languages__c(Language__c=Languages[1].Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        availLangs.add(availLangTitle3);
        Available_Languages__c availLangTitle4 = new Available_Languages__c(Language__c=Languages[1].Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);
        availLangs.add(availLangTitle4);
        Available_Languages__c availLangTitle5 = new Available_Languages__c(Language__c=Languages[1].Id ,Language_Types__c='Provisional',Title__c=title.Id,Clear_To_Avail__c=true);
        availLangs.add(availLangTitle5);
        insert availLangs;
        
        Country__c con1= new country__c(Name='United States',Country_Code__c='Test1', Country_Code2__c='te',Status__c = 'Active',Channel__c='DTD;EST;Hotel;PPV;VODi');
        insert con1;
        
        Country__c con2 = new country__c(Name='United Arab Emirates',Country_Code__c='Test2', Country_Code2__c='tc',Status__c = 'Active',Channel__c='DTD;EST;Hotel;PPV;VODi');
        insert con2;
        
        Country__c con3 = new country__c(Name='India',Country_Code__c='Test3', Country_Code2__c='tf',Status__c = 'Active',Channel__c='');
        insert con3;
        
        List<String> countryIdList = new List<String>();
        countryIdList.add(con1.Id);
        countryIdList.add(con3.Id);
        
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp',Country__c = 'United States;United Arab Emirates:India');
        insert conGrp;
        
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con1.Id,Type__c = 'Country',Language__c=Languages[0].Id,Level__c='1');
        insert langPrefTest;
        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con1.Id,Type__c = 'Country',Language__c=Languages[1].Id,Level__c='2');
        insert langPrefTest2;
        
        Language_Preference__c langPrefTest3= new Language_Preference__c(Country__c=con3.Id,Type__c = 'Country',Language__c=Languages[1].Id,Level__c='1');
        insert langPrefTest3;
        
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con1.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        Country_Group_Country__c conGrpCon2= new Country_Group_Country__c(Country__c=con2.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon2;
        
        Country_Group_Country__c conGrpCon3= new Country_Group_Country__c(Country__c=con3.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon3;
        
        commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con1.Id,Languages__c=Languages[0].Id, Language_Type__c='Sub',
                                       end_date__c=system.today()+190,start_Date__c=system.today()+10, Rights_End__c=system.today()+200,Exclusive_Date__c=(system.today()+2));
        insert commTest;
        
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c(Country_Group__c=conGrp.Id);
        caList.add(commRec);
        
        ApexPages.currentPage().getParameters().put('id', title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller cc = new WB_CreateReleasePlan_Controller(sc);
        
        cc.countryGrpId=conGrp.Id;
        //cc.englishOnlyChk=true;
        cc.selectedCountriesRecords.add(new SelectOption(con1.Id, con1.Name));
        //cc.selectedCountriesRecords.add(new SelectOption(con2.Id, con2.Name));
        cc.selectedFormats.add(new SelectOption('HD','HD'));
        cc.findCountry();
        cc.channelgrid();
        
        Commercial_Avail__c commAvailTest1 = new Commercial_Avail__c(); 
        commAvailTest1.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest1.Rights_End__c=null; 
        commAvailTest1.Start_Date__c=null; 
        commAvailTest1.End_Date__c=null; 
        commAvailTest1.status__c='Draft';
        
        Commercial_Avail__c commAvailTest2= new Commercial_Avail__c(); 
        commAvailTest2.Exclusive_Date__c=null; 
        commAvailTest2.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest2.Start_Date__c=null; 
        commAvailTest2.End_Date__c=null; 
        commAvailTest2.status__c='Draft';
        
        Commercial_Avail__c commAvailTest3= new Commercial_Avail__c(); 
        commAvailTest3.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest3.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest3.Start_Date__c=date.parse( '12/31/2000');
        commAvailTest3.End_Date__c=date.parse( '12/31/2049'); 
        commAvailTest3.status__c='Not Releasing';
        commAvailTest3.Reason_Code__c='Business Reason';
        
        Commercial_Avail__c commAvailTest4= new Commercial_Avail__c(); 
        commAvailTest4.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest4.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest4.Start_Date__c=null; 
        commAvailTest4.End_Date__c=null; 
        commAvailTest4.status__c='Draft';
        
        test.startTest();
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper.countryChannel = 'DTD';
        channelWrapper.additionalInfo = commAvailTest1;
        cc.channelGridList.add(channelWrapper);
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper2 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper2.countryChannel = 'EST';
        channelWrapper2.additionalInfo = commAvailTest2;
        cc.channelGridList.add(channelWrapper2);
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper3 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper3.countryChannel = 'EST';
        channelWrapper3.additionalInfo = commAvailTest3;
        cc.channelGridList.add(channelWrapper3);
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper4 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper4.countryChannel = 'EST';
        channelWrapper4.additionalInfo = commAvailTest4;
        cc.channelGridList.add(channelWrapper4);
        cc.isRightToCreateRPChk = true;
        cc.isRightToCreateRPEND= true;
        
        
        map<id, date> firstAvalTitleDateMap = new map<id, date>();
        map<id, date> expirationDateTitleMap = new map<id, date>();
        Commercial_Avail__c  record = new Commercial_Avail__c();
        
        //List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
        calist.add(record);
        
        WB_Batch_ReleasePlanWizard_New batchInst = new WB_Batch_ReleasePlanWizard_New(titleIdList,countryIdList,cc.channelGridList,mapRightsGrp, lstRights, SelectedFormatStrSet,cc.isRightToCreateRPChk,cc.isRightToCreateRPEND,'Yes', True);
        batchInst.englishOnlyChk =true;
        database.executeBatch(batchInst);
        Test.stoptest();
        
    }
    
    
    //FAD is not null
    public static testmethod void methodcreateRPBacth01(){
        Map<String, String> mapRightsGrp = new Map<String, String>();
        List<Rights__c> lstRights = new List<Rights__c>();
        Set<String> SelectedFormatStrSet = new Set<String>();
        
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch2',RP_Batch_Id__c='2' );
        insert batchIDs;
        
        MPM__c mpm = new MPM__c(name='MPM rec',MPM_Number__c='1234');
        insert mpm;
        
        Title__c title = new Title__c(Name='New Title', Video_Version__c='0723456789',Formats__c='HD',First_Available_Date__c=system.today(),MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        insert title;
        List<String> titleIdList = new List<String>();
        titleIdList.add(title.Id);
        
        List<Language__c> languages = new List<Language__c>();
        Language__c Language1 = new Language__c (Name='English',Language_Order__c = 1,Language_Code_2__c = 'en');
        languages.add(Language1);
        
        Language__c Language2 = new Language__c (Name='Arabic', Language_Order__c = 1,Language_Code_2__c = 'ar');
        languages.add(Language2);
        
        insert languages;
        
        List<Available_Languages__c> availLangs = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Languages[0].Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        availLangs.add(availLangTitle1);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=Languages[0].Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);
        availLangs.add(availLangTitle2);
        Available_Languages__c availLangTitle3 = new Available_Languages__c(Language__c=Languages[1].Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        availLangs.add(availLangTitle3);
        Available_Languages__c availLangTitle4 = new Available_Languages__c(Language__c=Languages[1].Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);
        availLangs.add(availLangTitle4);
        insert availLangs;
        
        Country__c con1= new country__c(Name='United States',Country_Code__c='Test1', Country_Code2__c='te',Status__c = 'Active',Channel__c='DTD;EST;Hotel;PPV;VODi');
        insert con1;
        
        Country__c con2 = new country__c(Name='United Arab Emirates',Country_Code__c='Test2', Country_Code2__c='tc',Status__c = 'Active',Channel__c='DTD;EST;Hotel;PPV;VODi');
        insert con2;
        
        List<String> countryIdList = new List<String>();
        countryIdList.add(con1.Id);
        
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp',Country__c = 'United States;United Arab Emirates');
        insert conGrp;
        
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con1.Id,Type__c = 'Country',Language__c=Languages[0].Id,Level__c='1');
        insert langPrefTest;
        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con1.Id,Type__c = 'Country',Language__c=Languages[1].Id,Level__c='2');
        insert langPrefTest2;
        
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con1.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        Country_Group_Country__c conGrpCon2= new Country_Group_Country__c(Country__c=con2.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon2;
        
        commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con1.Id,Languages__c=Languages[0].Id, Language_Type__c='Sub',
                                       end_date__c=system.today()+190,start_Date__c=system.today()+10, Rights_End__c=system.today()+200,Exclusive_Date__c=(system.today()+2));
        insert commTest;
        
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c(Country_Group__c=conGrp.Id);
        caList.add(commRec);
        
        ApexPages.currentPage().getParameters().put('id', title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller cc = new WB_CreateReleasePlan_Controller(sc);
        
        cc.countryGrpId=conGrp.Id;
        //cc.englishOnlyChk=true;
        cc.selectedCountriesRecords.add(new SelectOption(con1.Id, con1.Name));
        //cc.selectedCountriesRecords.add(new SelectOption(con2.Id, con2.Name));
        cc.selectedFormats.add(new SelectOption('HD','HD'));
        cc.findCountry();
        cc.channelgrid();
        
        Commercial_Avail__c commAvailTest1 = new Commercial_Avail__c(); 
        commAvailTest1.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest1.Rights_End__c=null; 
        commAvailTest1.Start_Date__c=null; 
        commAvailTest1.End_Date__c=null; 
        commAvailTest1.status__c='Draft';
        
        Commercial_Avail__c commAvailTest2= new Commercial_Avail__c(); 
        commAvailTest2.Exclusive_Date__c=null; 
        commAvailTest2.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest2.Start_Date__c=null; 
        commAvailTest2.End_Date__c=null; 
        commAvailTest2.status__c='Draft';
        
        Commercial_Avail__c commAvailTest3= new Commercial_Avail__c(); 
        commAvailTest3.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest3.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest3.Start_Date__c=date.parse( '12/31/2000');
        commAvailTest3.End_Date__c=date.parse( '12/31/2049'); 
        commAvailTest3.status__c='Not Releasing';
        commAvailTest3.Reason_Code__c='Business Reason';
        
        Commercial_Avail__c commAvailTest4= new Commercial_Avail__c(); 
        commAvailTest4.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest4.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest4.Start_Date__c=null; 
        commAvailTest4.End_Date__c=null; 
        commAvailTest4.status__c='Draft';
        
        test.startTest();
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper.countryChannel = 'DTD';
        channelWrapper.additionalInfo = commAvailTest1;
        cc.channelGridList.add(channelWrapper);
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper2 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper2.countryChannel = 'EST';
        channelWrapper2.additionalInfo = commAvailTest2;
        cc.channelGridList.add(channelWrapper2);
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper3 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper3.countryChannel = 'EST';
        channelWrapper3.additionalInfo = commAvailTest3;
        cc.channelGridList.add(channelWrapper3);
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper4 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper4.countryChannel = 'EST';
        channelWrapper4.additionalInfo = commAvailTest4;
        cc.channelGridList.add(channelWrapper4);
        cc.isRightToCreateRPChk = true;
        cc.isRightToCreateRPEND= true;
        
        
        
        
        map<id, date> firstAvalTitleDateMap = new map<id, date>();
        map<id, date> expirationDateTitleMap = new map<id, date>();
        Commercial_Avail__c  record = new Commercial_Avail__c();
        
        //List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
        calist.add(record);
        
        //MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        //insert mpm;
        list<title__c> testTitleList= new list<title__c>();
        Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today(),
                        Expiration_Date__c=system.today()+365,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
                        Short_Synopsis__c='short description',Digital_Planning__c='YES');       
        testTitleList.add(title1);
        insert testTitleList;
        
        firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
        expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
        String titleId =title1.id;  
        
       // ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
                //WB_CreateReleasePlan_Controller batchInst = new WB_CreateReleasePlan_Controller(sc);
     WB_Batch_ReleasePlanWizard_New batchInst = new WB_Batch_ReleasePlanWizard_New(titleIdList,countryIdList,cc.channelGridList,mapRightsGrp, lstRights, SelectedFormatStrSet,cc.isRightToCreateRPChk,cc.isRightToCreateRPEND,'Yes', True);
        
        WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
        //WB_CreateReleasePlan_Controller batchInst = new WB_CreateReleasePlan_Controller();
        objChannelGrid.additionalInfo = record;
        objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c = null ; 
        objChannelGrid.additionalInfo.End_Date__c = null ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
        objChannelGrid.additionalInfo.Rights_End__c = null;
        batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                                                                                        
        objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c = null ; 
        objChannelGrid.additionalInfo.End_Date__c =date.today()+35; 
        objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
        objChannelGrid.additionalInfo.Rights_End__c =date.today()+40;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
        objChannelGrid.additionalInfo.Status__c='Draft';        
              objChannelGrid.additionalInfo.Start_Date__c = null ; 
        objChannelGrid.additionalInfo.End_Date__c = null ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
        objChannelGrid.additionalInfo.Rights_End__c = date.today()+40;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
              objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c =date.today()+30;
        objChannelGrid.additionalInfo.End_Date__c = null ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+40; 
        objChannelGrid.additionalInfo.Rights_End__c = null;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
              objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c = null ; 
        objChannelGrid.additionalInfo.End_Date__c = null ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+25; 
        objChannelGrid.additionalInfo.Rights_End__c = null;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
            objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c =date.today()+30; 
        objChannelGrid.additionalInfo.End_Date__c =date.today()+35 ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+25; 
        objChannelGrid.additionalInfo.Rights_End__c =date.today()+40;
              batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
              objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c =date.today()+30; 
        objChannelGrid.additionalInfo.End_Date__c =date.today()+40 ;  
        objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
        objChannelGrid.additionalInfo.Rights_End__c = null;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
              objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c = null ; 
        objChannelGrid.additionalInfo.End_Date__c = null ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+25; 
        objChannelGrid.additionalInfo.Rights_End__c =date.today()+40;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
              objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c = null ;
        objChannelGrid.additionalInfo.End_Date__c= date.today()+35; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+20; 
        objChannelGrid.additionalInfo.Rights_End__c =date.today()+40;    
        batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
              //gridstatus=Not releasing 
        objChannelGrid.additionalInfo.Status__c='Not releasing';
        objChannelGrid.additionalInfo.Start_Date__c =date.today()+30; 
        objChannelGrid.additionalInfo.End_Date__c =date.today()+35 ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+25; 
        objChannelGrid.additionalInfo.Rights_End__c =date.today()+40;
              batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
        Test.stoptest();
        
       
    }
    
    //FAD=null
    public static testmethod void methodcreateRPBacth02(){
        Map<String, String> mapRightsGrp = new Map<String, String>();
        List<Rights__c> lstRights = new List<Rights__c>();
        Set<String> SelectedFormatStrSet = new Set<String>();
        
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch2',RP_Batch_Id__c='2' );
        insert batchIDs;
        
        MPM__c mpm = new MPM__c(name='MPM rec',MPM_Number__c='1234');
        insert mpm;
        
        Title__c title = new Title__c(Name='New Title', Video_Version__c='0723456789',Formats__c='HD',First_Available_Date__c=system.today(),MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        insert title;
        List<String> titleIdList = new List<String>();
        titleIdList.add(title.Id);
        
        List<Language__c> languages = new List<Language__c>();
        Language__c Language1 = new Language__c (Name='English',Language_Order__c = 1,Language_Code_2__c = 'en');
        languages.add(Language1);
        
        Language__c Language2 = new Language__c (Name='Arabic', Language_Order__c = 1,Language_Code_2__c = 'ar');
        languages.add(Language2);
        
        insert languages;
        
        List<Available_Languages__c> availLangs = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Languages[0].Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        availLangs.add(availLangTitle1);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=Languages[0].Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);
        availLangs.add(availLangTitle2);
        Available_Languages__c availLangTitle3 = new Available_Languages__c(Language__c=Languages[1].Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        availLangs.add(availLangTitle3);
        Available_Languages__c availLangTitle4 = new Available_Languages__c(Language__c=Languages[1].Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);
        availLangs.add(availLangTitle4);
        insert availLangs;
        
        Country__c con1= new country__c(Name='United States',Country_Code__c='Test1', Country_Code2__c='te',Status__c = 'Active',Channel__c='DTD;EST;Hotel;PPV;VODi');
        insert con1;
        
        Country__c con2 = new country__c(Name='United Arab Emirates',Country_Code__c='Test2', Country_Code2__c='tc',Status__c = 'Active',Channel__c='DTD;EST;Hotel;PPV;VODi');
        insert con2;
        
        List<String> countryIdList = new List<String>();
        countryIdList.add(con1.Id);
        
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp',Country__c = 'United States;United Arab Emirates');
        insert conGrp;
        
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con1.Id,Type__c = 'Country',Language__c=Languages[0].Id,Level__c='1');
        insert langPrefTest;
        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con1.Id,Type__c = 'Country',Language__c=Languages[1].Id,Level__c='2');
        insert langPrefTest2;
        
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con1.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        Country_Group_Country__c conGrpCon2= new Country_Group_Country__c(Country__c=con2.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon2;
        
        commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con1.Id,Languages__c=Languages[0].Id, Language_Type__c='Sub',
                                       end_date__c=system.today()+190,start_Date__c=system.today()+10, Rights_End__c=system.today()+200,Exclusive_Date__c=(system.today()+2));
        insert commTest;
        
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c(Country_Group__c=conGrp.Id);
        caList.add(commRec);
        
        ApexPages.currentPage().getParameters().put('id', title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller cc = new WB_CreateReleasePlan_Controller(sc);
        
        cc.countryGrpId=conGrp.Id;
        //cc.englishOnlyChk=true;
        cc.selectedCountriesRecords.add(new SelectOption(con1.Id, con1.Name));
        //cc.selectedCountriesRecords.add(new SelectOption(con2.Id, con2.Name));
        cc.selectedFormats.add(new SelectOption('HD','HD'));
        cc.findCountry();
        cc.channelgrid();
        
        Commercial_Avail__c commAvailTest1 = new Commercial_Avail__c(); 
        commAvailTest1.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest1.Rights_End__c=null; 
        commAvailTest1.Start_Date__c=null; 
        commAvailTest1.End_Date__c=null; 
        commAvailTest1.status__c='Draft';
        
        Commercial_Avail__c commAvailTest2= new Commercial_Avail__c(); 
        commAvailTest2.Exclusive_Date__c=null; 
        commAvailTest2.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest2.Start_Date__c=null; 
        commAvailTest2.End_Date__c=null; 
        commAvailTest2.status__c='Draft';
        
        Commercial_Avail__c commAvailTest3= new Commercial_Avail__c(); 
        commAvailTest3.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest3.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest3.Start_Date__c=date.parse( '12/31/2000');
        commAvailTest3.End_Date__c=date.parse( '12/31/2049'); 
        commAvailTest3.status__c='Not Releasing';
        commAvailTest3.Reason_Code__c='Business Reason';
        
        Commercial_Avail__c commAvailTest4= new Commercial_Avail__c(); 
        commAvailTest4.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest4.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest4.Start_Date__c=null; 
        commAvailTest4.End_Date__c=null; 
        commAvailTest4.status__c='Draft';
        
        test.startTest();
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper.countryChannel = 'DTD';
        channelWrapper.additionalInfo = commAvailTest1;
        cc.channelGridList.add(channelWrapper);
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper2 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper2.countryChannel = 'EST';
        channelWrapper2.additionalInfo = commAvailTest2;
        cc.channelGridList.add(channelWrapper2);
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper3 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper3.countryChannel = 'EST';
        channelWrapper3.additionalInfo = commAvailTest3;
        cc.channelGridList.add(channelWrapper3);
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper4 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper4.countryChannel = 'EST';
        channelWrapper4.additionalInfo = commAvailTest4;
        cc.channelGridList.add(channelWrapper4);
        cc.isRightToCreateRPChk = true;
        cc.isRightToCreateRPEND= true;
        
        
        
        
        map<id, date> firstAvalTitleDateMap = new map<id, date>();
        map<id, date> expirationDateTitleMap = new map<id, date>();
        Commercial_Avail__c  record = new Commercial_Avail__c();
        
        //List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
        calist.add(record);
        
        //MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        //insert mpm;
        list<title__c> testTitleList= new list<title__c>();
        Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=null,
                        Expiration_Date__c=null,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
                        Short_Synopsis__c='short description',Digital_Planning__c='YES');       
        testTitleList.add(title1);
        insert testTitleList;
        
        firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
        expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
        String titleId =title1.id;  
        
       // ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
                //WB_CreateReleasePlan_Controller batchInst = new WB_CreateReleasePlan_Controller(sc);
     WB_Batch_ReleasePlanWizard_New batchInst = new WB_Batch_ReleasePlanWizard_New(titleIdList,countryIdList,cc.channelGridList,mapRightsGrp, lstRights, SelectedFormatStrSet,cc.isRightToCreateRPChk,cc.isRightToCreateRPEND,'Yes', True);
        WB_Batch_ReleasePlanWizard_New.channelWrapper batchCR = new WB_Batch_ReleasePlanWizard_New.channelWrapper();//added
                //Configuring exceptions for batch
                Release_Plan_Exceptions__c rpExceptionRec= new Release_Plan_Exceptions__c();
                Integer countExcpetionRec= 12;
                rpExceptionRec.name= Userinfo.getUserId() + string.valueof(countExcpetionRec) ;
                rpExceptionRec.Title__c=title.name;
                rpExceptionRec.Video_Version__c=title.Video_Version__c;
                rpExceptionRec.Reason__c='Title is not available in any formats.';
                rpExceptionRec.User_Detail__c=Userinfo.getUserId(); 
                batchInst.releasePlanExceptionList.add(rpExceptionRec);
                //configuring exceptions for batch
        WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
        //WB_CreateReleasePlan_Controller batchInst = new WB_CreateReleasePlan_Controller();
        objChannelGrid.additionalInfo = record;
        objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c = null ; 
        objChannelGrid.additionalInfo.End_Date__c = null ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
        objChannelGrid.additionalInfo.Rights_End__c = null;
        batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                                                                                        
        objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c = null ; 
        objChannelGrid.additionalInfo.End_Date__c =date.today()+30 ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
        objChannelGrid.additionalInfo.Rights_End__c =date.today()+40;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
        objChannelGrid.additionalInfo.Status__c='Draft';        
              objChannelGrid.additionalInfo.Start_Date__c = null ; 
        objChannelGrid.additionalInfo.End_Date__c = null ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
        objChannelGrid.additionalInfo.Rights_End__c = date.today()+40;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
              objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c =date.today()+30;
        objChannelGrid.additionalInfo.End_Date__c = null ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+20; 
        objChannelGrid.additionalInfo.Rights_End__c = null;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
              objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c = null ; 
        objChannelGrid.additionalInfo.End_Date__c = null ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+25; 
        objChannelGrid.additionalInfo.Rights_End__c = null;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
            objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c =date.today()+20; 
        objChannelGrid.additionalInfo.End_Date__c =date.today()+35 ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+15; 
        objChannelGrid.additionalInfo.Rights_End__c =date.today()+40;
              batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
              objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c =date.today()+30; 
        objChannelGrid.additionalInfo.End_Date__c =date.today()+40 ;  
        objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
        objChannelGrid.additionalInfo.Rights_End__c = null;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
              objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c = null ; 
        objChannelGrid.additionalInfo.End_Date__c = null ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+15; 
        objChannelGrid.additionalInfo.Rights_End__c =date.today()+40;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
              objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c = null ;
        objChannelGrid.additionalInfo.End_Date__c= date.today()+35 ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+25; 
        objChannelGrid.additionalInfo.Rights_End__c =date.today()+40;    
        batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
              //gridstatus=Not releasing 
        objChannelGrid.additionalInfo.Status__c='Not releasing';
        objChannelGrid.additionalInfo.Start_Date__c =date.today()+20; 
        objChannelGrid.additionalInfo.End_Date__c =date.today()+25 ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+15; 
        objChannelGrid.additionalInfo.Rights_End__c =date.today()+40;
              batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
        Test.stoptest();
        
       
    }
    
        public static testmethod void methodcreateRPBacth03(){
        Map<String, String> mapRightsGrp = new Map<String, String>();
        List<Rights__c> lstRights = new List<Rights__c>();
        Set<String> SelectedFormatStrSet = new Set<String>();
        
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch2',RP_Batch_Id__c='2' );
        insert batchIDs;
        
        MPM__c mpm = new MPM__c(name='MPM rec',MPM_Number__c='1234');
        insert mpm;
        
        Title__c title = new Title__c(Name='New Title', Video_Version__c='0723456789',Formats__c='HD',First_Available_Date__c=system.today(),MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        insert title;
        List<String> titleIdList = new List<String>();
        titleIdList.add(title.Id);
        
        List<Language__c> languages = new List<Language__c>();
        Language__c Language1 = new Language__c (Name='English',Language_Order__c = 1,Language_Code_2__c = 'en');
        languages.add(Language1);
        
        Language__c Language2 = new Language__c (Name='Arabic', Language_Order__c = 1,Language_Code_2__c = 'ar');
        languages.add(Language2);
        
        insert languages;
        
        List<Available_Languages__c> availLangs = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Languages[0].Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        availLangs.add(availLangTitle1);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=Languages[0].Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);
        availLangs.add(availLangTitle2);
        Available_Languages__c availLangTitle3 = new Available_Languages__c(Language__c=Languages[1].Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        availLangs.add(availLangTitle3);
        Available_Languages__c availLangTitle4 = new Available_Languages__c(Language__c=Languages[1].Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);
        availLangs.add(availLangTitle4);
        insert availLangs;
        
        Country__c con1= new country__c(Name='United States',Country_Code__c='Test1', Country_Code2__c='te',Status__c = 'Active',Channel__c='DTD;EST;Hotel;PPV;VODi');
        insert con1;
        
        Country__c con2 = new country__c(Name='United Arab Emirates',Country_Code__c='Test2', Country_Code2__c='tc',Status__c = 'Active',Channel__c='DTD;EST;Hotel;PPV;VODi');
        insert con2;
        
        List<String> countryIdList = new List<String>();
        countryIdList.add(con1.Id);
        
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp',Country__c = 'United States;United Arab Emirates');
        insert conGrp;
        
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con1.Id,Type__c = 'Country',Language__c=Languages[0].Id,Level__c='2');
        insert langPrefTest;
        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con1.Id,Type__c = 'Country',Language__c=Languages[1].Id,Level__c='2');
        insert langPrefTest2;
        
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con1.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        Country_Group_Country__c conGrpCon2= new Country_Group_Country__c(Country__c=con2.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon2;
        
        commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con1.Id,Languages__c=Languages[0].Id, Language_Type__c='Sub',
                                       end_date__c=system.today()+190,start_Date__c=system.today()+10, Rights_End__c=system.today()+200,Exclusive_Date__c=(system.today()+2));
        insert commTest;
        
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c(Country_Group__c=conGrp.Id);
        caList.add(commRec);
        
        ApexPages.currentPage().getParameters().put('id', title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller cc = new WB_CreateReleasePlan_Controller(sc);
        
        cc.countryGrpId=conGrp.Id;
        //cc.englishOnlyChk=true;
        cc.selectedCountriesRecords.add(new SelectOption(con1.Id, con1.Name));
        //cc.selectedCountriesRecords.add(new SelectOption(con2.Id, con2.Name));
        cc.selectedFormats.add(new SelectOption('HD','HD'));
        cc.findCountry();
        cc.channelgrid();
        
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=system.today()+50; 
        commAvailTest.Exclusive_Date__c=system.today()+5; 
        commAvailTest.Start_Date__c= system.today()+10;
        commAvailTest.End_Date__c=system.today()+25;
        commAvailTest.status__c='Draft';
        commAvailTest.Country_Lookup__c = con1.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Languages[1].id;
        commAvailTest.Channel__c = 'EST';
        
        Commercial_Avail__c commAvailTest1 = new Commercial_Avail__c(); 
        commAvailTest1.Exclusive_Date__c=system.today()+5; 
        commAvailTest1.Rights_End__c=null; 
        commAvailTest1.Start_Date__c=null; 
        commAvailTest1.End_Date__c=null; 
        commAvailTest1.status__c='Draft';
        commAvailTest1.Country_Lookup__c = con2.id;
        commAvailTest1.title__c = title.id;
        commAvailTest1.Languages__c = Languages[1].id;
        commAvailTest1.Channel__c = 'EST';
        
        Commercial_Avail__c commAvailTest2= new Commercial_Avail__c(); 
        commAvailTest2.Exclusive_Date__c=null; 
        commAvailTest2.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest2.Start_Date__c=null; 
        commAvailTest2.End_Date__c=null; 
        commAvailTest2.status__c='Draft';
        commAvailTest2.Country_Lookup__c = con2.id;
        commAvailTest2.title__c = title.id;
        commAvailTest2.Languages__c = Languages[1].id;
        commAvailTest2.Channel__c = 'EST';
        
        Commercial_Avail__c commAvailTest3= new Commercial_Avail__c(); 
        commAvailTest3.Exclusive_Date__c=system.today()+5; 
        commAvailTest3.Rights_End__c=system.today()+25; 
        commAvailTest3.Start_Date__c=system.today();
        commAvailTest3.End_Date__c=system.today()+10; 
        commAvailTest3.status__c='Not Releasing';
        commAvailTest3.Reason_Code__c='Business Reason';
        commAvailTest3.Country_Lookup__c = con1.id;
        commAvailTest3.title__c = title.id;
        commAvailTest3.Languages__c = Languages[1].id;
        commAvailTest3.Channel__c = 'EST';
        
        Commercial_Avail__c commAvailTest4= new Commercial_Avail__c(); 
        commAvailTest4.Exclusive_Date__c=system.today()+5; 
        commAvailTest4.Rights_End__c=system.today()+25; 
        commAvailTest4.Start_Date__c=null; 
        commAvailTest4.End_Date__c=null; 
        commAvailTest4.status__c='Draft';
        commAvailTest4.Country_Lookup__c = con2.id;
        commAvailTest4.title__c = title.id;
        commAvailTest4.Languages__c = Languages[1].id;
        commAvailTest4.Channel__c = 'EST';
        
        List <Commercial_Avail__c> comAvailList = new List<Commercial_Avail__c>();
        comAvailList.add(commAvailTest);
        comAvailList.add(commAvailTest1);
        /*comAvailList.add(commAvailTest2);
        comAvailList.add(commAvailTest3);
        comAvailList.add(commAvailTest4);*/
        
        test.startTest();
        
        insert comAvailList;
        WB_Batch_ReleasePlanWizard_New batchInst = new WB_Batch_ReleasePlanWizard_New(titleIdList,countryIdList,cc.channelGridList,mapRightsGrp, lstRights, SelectedFormatStrSet,cc.isRightToCreateRPChk,cc.isRightToCreateRPEND,'Yes', True);
        
        batchInst.commAvailLstValidated(comAvailList);
        
        WB_Batch_ReleasePlanWizard_New.channelWrapper channelWrapperwbRNew = new WB_Batch_ReleasePlanWizard_New.channelWrapper();
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper.countryChannel = 'DTD';
        channelWrapper.additionalInfo = commAvailTest1;
        cc.channelGridList.add(channelWrapper);
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper2 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper2.countryChannel = 'EST';
        channelWrapper2.additionalInfo = commAvailTest2;
        cc.channelGridList.add(channelWrapper2);
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper3 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper3.countryChannel = 'EST';
        channelWrapper3.additionalInfo = commAvailTest3;
        cc.channelGridList.add(channelWrapper3);
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper4 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper4.countryChannel = 'EST';
        channelWrapper4.additionalInfo = commAvailTest4;
        cc.channelGridList.add(channelWrapper4);
        cc.isRightToCreateRPChk = true;
        cc.isRightToCreateRPEND= true;
        
        
        
        
        map<id, date> firstAvalTitleDateMap = new map<id, date>();
        map<id, date> expirationDateTitleMap = new map<id, date>();
        Commercial_Avail__c  record = new Commercial_Avail__c();
        
        //List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
        calist.add(record);
        
        //MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        //insert mpm;
        list<title__c> testTitleList= new list<title__c>();
        Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today(),
                        Expiration_Date__c=system.today()+365,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
                        Short_Synopsis__c='short description',Digital_Planning__c='YES');       
        testTitleList.add(title1);
        insert testTitleList;
        
        firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
        expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
        String titleId =title1.id;  
        
       // ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
                //WB_CreateReleasePlan_Controller batchInst = new WB_CreateReleasePlan_Controller(sc);
     //WB_Batch_ReleasePlanWizard_New batchInst = new WB_Batch_ReleasePlanWizard_New(titleIdList,countryIdList,cc.channelGridList,mapRightsGrp, lstRights, SelectedFormatStrSet,cc.isRightToCreateRPChk,cc.isRightToCreateRPEND,'Yes', True);
        
        WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
        //WB_CreateReleasePlan_Controller batchInst = new WB_CreateReleasePlan_Controller();
        objChannelGrid.additionalInfo = record;
        objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c = null ; 
        objChannelGrid.additionalInfo.End_Date__c = null ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
        objChannelGrid.additionalInfo.Rights_End__c = null;
        batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                                                                                        
        objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c = null ; 
        objChannelGrid.additionalInfo.End_Date__c =date.today()+35 ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
        objChannelGrid.additionalInfo.Rights_End__c =date.today()+40;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
        objChannelGrid.additionalInfo.Status__c='Draft';        
              objChannelGrid.additionalInfo.Start_Date__c = null ; 
        objChannelGrid.additionalInfo.End_Date__c = null ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
        objChannelGrid.additionalInfo.Rights_End__c = date.today()+40;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
              objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c =date.today()+20;
        objChannelGrid.additionalInfo.End_Date__c = null ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+15; 
        objChannelGrid.additionalInfo.Rights_End__c = null;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
              objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c = null ; 
        objChannelGrid.additionalInfo.End_Date__c = null ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+15; 
        objChannelGrid.additionalInfo.Rights_End__c = null;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
            objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c =date.today()+20; 
        objChannelGrid.additionalInfo.End_Date__c =date.today()+25 ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+15; 
        objChannelGrid.additionalInfo.Rights_End__c =date.today()+40;
              batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
              objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c =date.today()+20; 
        objChannelGrid.additionalInfo.End_Date__c =date.today()+25 ;  
        objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
        objChannelGrid.additionalInfo.Rights_End__c = null;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
              objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c = null ; 
        objChannelGrid.additionalInfo.End_Date__c = null ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+15; 
        objChannelGrid.additionalInfo.Rights_End__c =date.today()+40;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
              objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c = null ;
        objChannelGrid.additionalInfo.End_Date__c= date.today()+25 ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+15; 
        objChannelGrid.additionalInfo.Rights_End__c =date.today()+40;    
        batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
              //gridstatus=Not releasing 
        objChannelGrid.additionalInfo.Status__c='Not releasing';
        objChannelGrid.additionalInfo.Start_Date__c =date.today()+20; 
        objChannelGrid.additionalInfo.End_Date__c =date.today()+35 ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+15; 
        objChannelGrid.additionalInfo.Rights_End__c =date.today()+40;
              batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
        Test.stoptest();
        
    }
    
    public static testmethod void methodcreateRPBacth04(){
        Map<String, String> mapRightsGrp = new Map<String, String>();
        List<Rights__c> lstRights = new List<Rights__c>();
        Set<String> SelectedFormatStrSet = new Set<String>();
        
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch2',RP_Batch_Id__c='2' );
        insert batchIDs;
        
        MPM__c mpm = new MPM__c(name='MPM rec',MPM_Number__c='1234');
        insert mpm;
        
        Title__c title = new Title__c(Name='New Title', Video_Version__c='0723456789',Formats__c='HD',First_Available_Date__c=system.today(),MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        insert title;
        List<String> titleIdList = new List<String>();
        titleIdList.add(title.Id);
        
        List<Language__c> languages = new List<Language__c>();
        Language__c Language1 = new Language__c (Name='English',Language_Order__c = 1,Language_Code_2__c = 'en');
        languages.add(Language1);
        
        Language__c Language2 = new Language__c (Name='Arabic', Language_Order__c = 1,Language_Code_2__c = 'ar');
        languages.add(Language2);
        
        insert languages;
        
        List<Available_Languages__c> availLangs = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Languages[0].Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        availLangs.add(availLangTitle1);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=Languages[0].Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);
        availLangs.add(availLangTitle2);
        Available_Languages__c availLangTitle3 = new Available_Languages__c(Language__c=Languages[1].Id ,Language_Types__c='Sub',Title__c=title.Id,Clear_To_Avail__c=true);
        availLangs.add(availLangTitle3);
        Available_Languages__c availLangTitle4 = new Available_Languages__c(Language__c=Languages[1].Id ,Language_Types__c='Audio',Title__c=title.Id,Clear_To_Avail__c=true);
        availLangs.add(availLangTitle4);
        insert availLangs;
        
        Country__c con1= new country__c(Name='United States',Country_Code__c='Test1', Country_Code2__c='te',Status__c = 'Active',Channel__c='DTD;EST;Hotel;PPV;VODi');
        insert con1;
        
        Country__c con2 = new country__c(Name='United Arab Emirates',Country_Code__c='Test2', Country_Code2__c='tc',Status__c = 'Active',Channel__c='DTD;EST;Hotel;PPV;VODi');
        insert con2;
        
        List<String> countryIdList = new List<String>();
        countryIdList.add(con1.Id);
        
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp',Country__c = 'United States;United Arab Emirates');
        insert conGrp;
        
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con1.Id,Type__c = 'Country',Language__c=Languages[0].Id,Level__c='1');
        insert langPrefTest;
        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con1.Id,Type__c = 'Country',Language__c=Languages[1].Id,Level__c='2');
        insert langPrefTest2;
        
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con1.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        Country_Group_Country__c conGrpCon2= new Country_Group_Country__c(Country__c=con2.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon2;
        
        commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con1.Id,Languages__c=Languages[0].Id, Language_Type__c='Sub',
                                       end_date__c=system.today()+190,start_Date__c=system.today()+10, Rights_End__c=system.today()+200,Exclusive_Date__c=(system.today()+2));
        insert commTest;
        
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c(Country_Group__c=conGrp.Id);
        caList.add(commRec);
        
        ApexPages.currentPage().getParameters().put('id', title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller cc = new WB_CreateReleasePlan_Controller(sc);
        
        cc.countryGrpId=conGrp.Id;
        //cc.englishOnlyChk=true;
        cc.selectedCountriesRecords.add(new SelectOption(con1.Id, con1.Name));
        //cc.selectedCountriesRecords.add(new SelectOption(con2.Id, con2.Name));
        cc.selectedFormats.add(new SelectOption('HD','HD'));
        cc.findCountry();
        cc.channelgrid();
        
        Commercial_Avail__c commAvailTest1 = new Commercial_Avail__c(); 
        commAvailTest1.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest1.Rights_End__c=null; 
        commAvailTest1.Start_Date__c=null; 
        commAvailTest1.End_Date__c=null; 
        commAvailTest1.status__c='Draft';
        
        Commercial_Avail__c commAvailTest2= new Commercial_Avail__c(); 
        commAvailTest2.Exclusive_Date__c=null; 
        commAvailTest2.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest2.Start_Date__c=null; 
        commAvailTest2.End_Date__c=null; 
        commAvailTest2.status__c='Draft';
        
        Commercial_Avail__c commAvailTest3= new Commercial_Avail__c(); 
        commAvailTest3.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest3.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest3.Start_Date__c=date.parse( '12/31/2000');
        commAvailTest3.End_Date__c=date.parse( '12/31/2049'); 
        commAvailTest3.status__c='Not Releasing';
        commAvailTest3.Reason_Code__c='Business Reason';
        
        Commercial_Avail__c commAvailTest4= new Commercial_Avail__c(); 
        commAvailTest4.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest4.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest4.Start_Date__c=null; 
        commAvailTest4.End_Date__c=null; 
        commAvailTest4.status__c='Draft';
        
        test.startTest();
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper.countryChannel = 'DTD';
        channelWrapper.additionalInfo = commAvailTest1;
        cc.channelGridList.add(channelWrapper);
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper2 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper2.countryChannel = 'EST';
        channelWrapper2.additionalInfo = commAvailTest2;
        cc.channelGridList.add(channelWrapper2);
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper3 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper3.countryChannel = 'EST';
        channelWrapper3.additionalInfo = commAvailTest3;
        cc.channelGridList.add(channelWrapper3);
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper4 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper4.countryChannel = 'EST';
        channelWrapper4.additionalInfo = commAvailTest4;
        cc.channelGridList.add(channelWrapper4);
        cc.isRightToCreateRPChk = true;
        cc.isRightToCreateRPEND= true;
        
        
        
        
        map<id, date> firstAvalTitleDateMap = new map<id, date>();
        map<id, date> expirationDateTitleMap = new map<id, date>();
        Commercial_Avail__c  record = new Commercial_Avail__c();
        
        //List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
        calist.add(record);
        
        //MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        //insert mpm;
        list<title__c> testTitleList= new list<title__c>();
        Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=null,
                        Expiration_Date__c=null,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
                        Short_Synopsis__c='short description',Digital_Planning__c='YES');       
        testTitleList.add(title1);
        insert testTitleList;
        
        firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
        expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
        String titleId =title1.id;  
        
       // ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
                //WB_CreateReleasePlan_Controller batchInst = new WB_CreateReleasePlan_Controller(sc);
     WB_Batch_ReleasePlanWizard_New batchInst = new WB_Batch_ReleasePlanWizard_New(titleIdList,countryIdList,cc.channelGridList,mapRightsGrp, lstRights, SelectedFormatStrSet,cc.isRightToCreateRPChk,cc.isRightToCreateRPEND,'Yes', True);
        WB_Batch_ReleasePlanWizard_New.channelWrapper batchCR = new WB_Batch_ReleasePlanWizard_New.channelWrapper();//added
                //Configuring exceptions for batch
                Release_Plan_Exceptions__c rpExceptionRec= new Release_Plan_Exceptions__c();
                Integer countExcpetionRec= 12;
                rpExceptionRec.name= Userinfo.getUserId() + string.valueof(countExcpetionRec) ;
                rpExceptionRec.Title__c=title.name;
                rpExceptionRec.Video_Version__c=title.Video_Version__c;
                rpExceptionRec.Reason__c='Title is not available in any formats.';
                rpExceptionRec.User_Detail__c=Userinfo.getUserId(); 
                batchInst.releasePlanExceptionList.add(rpExceptionRec);
                //configuring exceptions for batch
        WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
        //WB_CreateReleasePlan_Controller batchInst = new WB_CreateReleasePlan_Controller();
        objChannelGrid.additionalInfo = record;
        objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c = null ; 
        objChannelGrid.additionalInfo.End_Date__c = null ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
        objChannelGrid.additionalInfo.Rights_End__c = null;
        batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                                                                                        
        objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c = null ; 
        objChannelGrid.additionalInfo.End_Date__c =date.today()+30; 
        objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
        objChannelGrid.additionalInfo.Rights_End__c = date.today()+40;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
        objChannelGrid.additionalInfo.Status__c='Draft';        
              objChannelGrid.additionalInfo.Start_Date__c = null ; 
        objChannelGrid.additionalInfo.End_Date__c = null ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
        objChannelGrid.additionalInfo.Rights_End__c = date.today()+40;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
              objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c =date.today()+20;
        objChannelGrid.additionalInfo.End_Date__c = null ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+25;
        objChannelGrid.additionalInfo.Rights_End__c = null;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
              objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c = null ; 
        objChannelGrid.additionalInfo.End_Date__c = null ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+15; 
        objChannelGrid.additionalInfo.Rights_End__c = null;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
            objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c =date.today()+25;
        objChannelGrid.additionalInfo.End_Date__c =date.today()+15; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+15;
        objChannelGrid.additionalInfo.Rights_End__c =date.today()+40;
              batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
              objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c =date.today()+20;
        objChannelGrid.additionalInfo.End_Date__c =date.today()+25;  
        objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
        objChannelGrid.additionalInfo.Rights_End__c = null;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
              objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c = null ; 
        objChannelGrid.additionalInfo.End_Date__c = null ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+15;
        objChannelGrid.additionalInfo.Rights_End__c =date.today()+40;
            batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
              objChannelGrid.additionalInfo.Status__c='Draft';
        objChannelGrid.additionalInfo.Start_Date__c = null ;
        objChannelGrid.additionalInfo.End_Date__c=date.today()+35; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+25; 
        objChannelGrid.additionalInfo.Rights_End__c =date.today()+40;    
        batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
              //gridstatus=Not releasing 
        objChannelGrid.additionalInfo.Status__c='Not releasing';
        objChannelGrid.additionalInfo.Start_Date__c =date.today()+30; 
        objChannelGrid.additionalInfo.End_Date__c =date.today()+35 ; 
        objChannelGrid.additionalInfo.Exclusive_Date__c =date.today()+25; 
        objChannelGrid.additionalInfo.Rights_End__c =date.today()+40;
              batchInst.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
        Test.stoptest();
       
    }
    
    
}