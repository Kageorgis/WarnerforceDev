@isTest
public class WB_CreateReleasePlan_Controller_Test2{
    public static testmethod void methodcreateRP17(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='WB - Territory Avails Planner'];
        User u = new User(Alias = 'stndt', Email='stand1211@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName='uniqueUserName@fetdg.com');

         System.runAs(u) {
          
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
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c='Country',Language__c=Language.Id,Level__c='1');
        insert langPrefTest;
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Type__c='Country',Language__c=Language2.Id,Level__c='2');
        insert langPrefTest1;        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Type__c='Country',Language__c=Language1.Id,Level__c='3');
        insert langPrefTest2;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='Australia and NZ');
        insert conGrp;
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                       end_date__c=System.Today().addYears(4),start_Date__c=System.Today().addYears(-1), Rights_End__c=System.Today().addYears(5),Exclusive_Date__c=System.Today().addYears(-2));
        //insert commTest;
               
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        
         Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
        insert childRightGroup;
        
        Rights__c rights = new Rights__c(Channel__c = 'EST',Title__c = title.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
                                        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
                                        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
                                        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19);
        insert rights; 
        //caList.add(commRec);
        con.Channel__c='';
        update con;
        
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);      // The following code runs as user 'u'
             
        
        
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
        commAvailTest.Rights_End__c=System.Today().addYears(2); 
        commAvailTest.Exclusive_Date__c=System.Today()+5; 
        commAvailTest.Start_Date__c= System.Today()+10;
        commAvailTest.End_Date__c=System.Today().addYears(2);
        commAvailTest.status__c='Draft';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = title.id;
        commAvailTest.Languages__c = Language.id;
        commAvailTest.Channel__c = 'EST';
        listComm.add(commAvailTest);
        System.debug('TEST CLASS-------------2.'+ccc.channelGridList.size());      
        
        Test.starttest();
        
        insert listComm;
                
          
        
        ccc.mapRightsDate(listComm);
        ccc.mapRightsDate(listComm);
            /*  
        
            ccc.channelGridList[0].additionalInfo.Exclusive_Date__c=null;
            ccc.channelGridList[0].additionalInfo.Start_Date__c=date.parse('12/26/2020');
            ccc.channelGridList[0].additionalInfo.End_Date__c=date.parse('12/27/2020');
            ccc.channelGridList[0].additionalInfo.Rights_End__c=date.parse('12/31/2020');
            ccc.channelGridList[0].additionalInfo.Status__c='Draft';
            
            ccc.channelGridList[1].additionalInfo.Exclusive_Date__c=date.parse('12/31/2021');
            ccc.channelGridList[1].additionalInfo.Start_Date__c=date.parse('12/28/2020');
            ccc.channelGridList[1].additionalInfo.End_Date__c=date.parse('12/31/2020');
            ccc.channelGridList[1].additionalInfo.Rights_End__c=date.parse('12/31/2020');
            ccc.channelGridList[1].additionalInfo.Status__c='Open';
            
            ccc.channelGridList[2].additionalInfo.Exclusive_Date__c=date.parse('12/31/2021');
            ccc.channelGridList[2].additionalInfo.Start_Date__c=date.parse('12/28/2020');
            ccc.channelGridList[2].additionalInfo.End_Date__c=date.parse('12/31/2020');
            ccc.channelGridList[2].additionalInfo.Rights_End__c=date.parse('12/31/2020');
            ccc.channelGridList[2].additionalInfo.Status__c='Draft';
        */
        ccc.titleList = testTitleList;
        ccc.isRightToCreateRPChk = FALSE;
        ccc.isRightToCreateRPEND= TRUE;
        ccc.ConfirmedPartialAllow = 'Yes';
        ccc.chkRightsStatus();
         System.debug('TEST CLASS-------------4.'+ccc.channelGridList.size());
        ccc.channelGridValidation();
        ccc.bulksave();
        Test.stoptest();
         }
    }
    
    public static testmethod void methodcreateRP18(){
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
         
        Language__c Language2 = new Language__c (Name='TestLanguage3', Language_Order__c = 2,Language_Code_2__c='tl2');
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
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c='Country',Language__c=Language.Id,Level__c='3');
        insert langPrefTest;
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Type__c='Country',Language__c=Language1.Id,Level__c='2');
        insert langPrefTest1;
        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Language__c=Language2.Id,Level__c='1');
        insert langPrefTest2;
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
        insert conGrp;
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title1.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Sub',
                                    end_date__c=System.Today().addYears(4),start_Date__c=System.Today().addYears(-1), Rights_End__c=System.Today().addYears(5),Exclusive_Date__c=System.Today().addYears(-2));
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
        commAvailTest4.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest4.Start_Date__c=date.parse( '12/31/2003');
        commAvailTest4.End_Date__c=date.parse( '12/31/2001');
        commAvailTest4.status__c='Draft';
        commAvailTest4.Country_Lookup__c = con.id;
        commAvailTest4.title__c = title.id;   
        commAvailTest4.Languages__c = Language.id;
        commAvailTest4.Channel__c = 'VODi';
        //listComm.add(commAvailTest4);
        Test.starttest();
        insert listComm;
        listComm.add(commAvailTest4);
        
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
    
    public static testmethod void methodcreateRP19(){
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
        Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='tl1');
        Language__c Language1 = new Language__c (Name='TestLanguage',Language_Order__c = 1,Language_Code_2__c='tl2');
        langList.add(Language);
        langList.add(Language1);
        insert langList;
        
        // Test Available language on Test Title
        Available_Languages__c availLangTitle= new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,
                                                                          Clear_to_Avail__c=TRUE);
        insert availLangTitle;
        
        // Test country for country grp
        list<country__c> conList= new  list<country__c>();
        country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST',Territory__c='testTerritory');
        country__c con1= new country__c(Name='Test1',Country_Code__c='Te1', Country_Code2__c='t1',Channel__c='DTD');
        conList.add(con);
        conList.add(con1);
        insert conList;
        
        // Test Language Preferences
        list<Language_Preference__c> langPrefList= new list<Language_Preference__c> ();
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c='Country',Language__c=Language.Id,Level__c='2');
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Type__c='Country',Language__c=Language1.Id,Level__c='1');
        langPrefList.add(langPrefTest);
        langPrefList.add(langPrefTest1);        
        insert langPrefList;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
        insert conGrp;
        
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title1.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, 
                                     Language_Type__c='Sub',end_date__c=system.today()+190,start_Date__c=system.today()+10, 
                                     Rights_End__c=system.today()+200,Exclusive_Date__c=(system.today()+2));
        insert commTest;
               
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        test.starttest();
        ApexPages.currentPage().getParameters().put('id', title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);
        ccc.countryGrpId=conGrp.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        
        ccc.findCountry();
        ccc.channelgrid();
        ccc.cancel();
        
        // test channel grid
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest.Exclusive_Date__c=date.today(); 
        commAvailTest.Start_Date__c=date.today();
        commAvailTest.End_Date__c=date.parse( '12/31/2049'); 
        commAvailTest.status__c='Planned';
        
        commercial_avail__c commAvailTest1= new commercial_avail__c(); 
        commAvailTest1.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest1.Exclusive_Date__c=date.today();
        commAvailTest1.Start_Date__c=date.today(); 
        commAvailTest1.End_Date__c=date.parse( '12/31/2049'); 
        commAvailTest1.status__c='Not Releasing';
        commAvailTest1.reason_code__c='No digital rights';
        
       
       
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper.countryChannel = 'DTD';
        channelWrapper.additionalInfo = commAvailTest;
        channelWrapper.delIndent = 1;
        channelWrapper.addIndent = 1; 
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper1 = new WB_CreateReleasePlan_Controller.channelWrapper();
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
       
                                 
        Local_Title__c localdata = new Local_Title__c(Name= 'test local data',Title__c =title.id,
        Country__c =country1.id,Language__c=Language.id,
        Status__c='Active',/*Version_EIDR__c='Version EIDR',*/Local_Rating_System__c='A',
        Local_Rating__c='A',Local_Synopsis__c='description for synopsis',Local_Label__c='label',
        Caption_Included_picklist__c='YES',Local_Run_Time__c=0123.00,
        Local_Theatrical_Release_Date__c=date.today(),Local_TV_Air_Date__c=date.today(),
        Local_DVD_Release_Date__c=date.today(),Local_BD_Release_Date__c=date.today(),
        UV_Published_Date__c=date.today(),ALID__c='alid1',CID__c='cid1');
        
       insert localdata;
       test.stoptest();
       //update localdata;
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
        Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='tl1');
        insert Language;
        
        Language__c Language1 = new Language__c (Name='TestLanguage1', Language_Order__c = 1,Language_Code_2__c='tl2');
        insert Language1;
        
        Language__c Language2 = new Language__c (Name='TestLanguage3', Language_Order__c = 1,Language_Code_2__c='tl3');
        insert Language2;
        
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
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c='Country',Language__c=Language.Id,Level__c='3');
        insert langPrefTest;
        
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Type__c='Country',Language__c=Language1.Id,Level__c='1');
        insert langPrefTest1;
        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Type__c='Country',Language__c=Language2.Id,Level__c='2');
        insert langPrefTest2;
        
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
        commAvail1.Start_Date__c = date.today();
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
        
        Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'USA',Country__c=con.id,Language__c=Language.id,Rights_Group__c = rightGroup.id);
        insert childRightGroup;
        
        Rights__c rights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id,Rights_End__c=system.today()+3, Rights_Group__c = rightGroup.Name,Rights_Start__c= system.today(),Status__c='Confirmed', Source__c ='Cosmos');
        insert rights;
        
        
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title1.Id);
        ApexPages.currentPage().getParameters().put('param', 'std');
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        Test.starttest();
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);        
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
        commAvailTest4.Exclusive_Date__c=date.parse( '12/31/2049'); 
        commAvailTest4.Start_Date__c=date.parse( '10/31/2050'); 
        commAvailTest4.End_Date__c=date.parse( '11/30/2050'); 
        commAvailTest4.title__c = title.id;
        //listComm.add(commAvailTest4);
        
        commercial_avail__c commAvailTest5= new commercial_avail__c();        
        commAvailTest5.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest5.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest5.Start_Date__c=date.parse( '11/30/2009'); 
        commAvailTest5.End_Date__c=date.parse( '12/31/2009'); 
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
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper.countryChannel = 'DTD';
        channelWrapper.additionalInfo = commAvailTest;
        channelWrapper.delIndent = 6;
        channelWrapper.addIndent = 6; 
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper1 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper1.countryChannel = 'EST';
        channelWrapper1.additionalInfo = commAvailTest3;
        channelWrapper1.delIndent = 6;
        channelWrapper1.addIndent = 6;
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper2 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper2.countryChannel = 'EST';     
        channelWrapper2.additionalInfo = commAvailTest1;
        channelWrapper2.delIndent = 6;
        channelWrapper2.addIndent = 6; 
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper3 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper3.countryChannel = 'DTD'; 
        channelWrapper3.additionalInfo = commAvailTest2;
        channelWrapper3.delIndent = 6;
        channelWrapper3.addIndent = 6;
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper4 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper4.countryChannel = 'DTD'; 
        channelWrapper4.additionalInfo = commAvailTest4;
        channelWrapper4.delIndent = 6;
        channelWrapper4.addIndent = 6;
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper5 = new WB_CreateReleasePlan_Controller.channelWrapper();
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
        ccc.viewRightsRedirect();
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
        Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='tl1');
        Language__c Language1 = new Language__c (Name='TestLanguage',Language_Order__c = 1,Language_Code_2__c='tl2');
        langList.add(Language);
        langList.add(Language1);
        insert langList;
        
        // Test Available language on Test Title
        Available_Languages__c availLangTitle= new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id,
                                                                          Clear_to_Avail__c=TRUE);
        insert availLangTitle;
        
        // Test country for country grp
        list<country__c> conList= new  list<country__c>();
        country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST',Territory__c='testTerritory');
        country__c con1= new country__c(Name='Test1',Country_Code__c='Te1', Country_Code2__c='t1',Channel__c='DTD');
        conList.add(con);
        conList.add(con1);
        insert conList;
        
        // Test Language Preferences
        list<Language_Preference__c> langPrefList= new list<Language_Preference__c> ();
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c='Country',Language__c=Language.Id,Level__c='2');
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Type__c='Country',Language__c=Language1.Id,Level__c='1');
        langPrefList.add(langPrefTest);
        langPrefList.add(langPrefTest1);        
        insert langPrefList;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
        insert conGrp;
        
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title1.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, 
                                     Language_Type__c='Sub',end_date__c=system.today()+190,start_Date__c=system.today()+10, 
                                     Rights_End__c=system.today()+200,Exclusive_Date__c=(system.today()+2));
        insert commTest;
               
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        test.starttest();
        ApexPages.currentPage().getParameters().put('id', title.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);
        ccc.countryGrpId=conGrp.Id;
        ccc.selectedCountriesRecords.add(new SelectOption(con.Id, con.Name));
        ccc.selectedFormats.add(new SelectOption('HD','HD'));
        
        ccc.findCountry();
        ccc.channelgrid();
        ccc.cancel();
        
        // test channel grid
        commercial_avail__c commAvailTest= new commercial_avail__c(); 
        commAvailTest.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest.Exclusive_Date__c=date.today(); 
        commAvailTest.Start_Date__c=date.today();
        commAvailTest.End_Date__c=date.parse( '12/31/2049'); 
        commAvailTest.status__c='Planned';
        
        commercial_avail__c commAvailTest1= new commercial_avail__c(); 
        commAvailTest1.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest1.Exclusive_Date__c=date.today();
        commAvailTest1.Start_Date__c=date.today(); 
        commAvailTest1.End_Date__c=date.parse( '12/31/2049'); 
        commAvailTest1.status__c='Not Releasing';
        commAvailTest1.reason_code__c='No digital rights';
        
       
       
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper.countryChannel = 'DTD';
        channelWrapper.additionalInfo = commAvailTest;
        channelWrapper.delIndent = 1;
        channelWrapper.addIndent = 1; 
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper1 = new WB_CreateReleasePlan_Controller.channelWrapper();
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
       
                                 
        Local_Title__c localdata = new Local_Title__c(Name= 'test local data',Title__c =title.id,
        Country__c =country1.id,Language__c=Language.id,
        Status__c='Active',/*Version_EIDR__c='Version EIDR',*/Local_Rating_System__c='A',
        Local_Rating__c='A',Local_Synopsis__c='description for synopsis',Local_Label__c='label',
        Caption_Included_picklist__c='YES',Local_Run_Time__c=0123.00,
        Local_Theatrical_Release_Date__c=date.today(),Local_TV_Air_Date__c=date.today(),
        Local_DVD_Release_Date__c=date.today(),Local_BD_Release_Date__c=date.today(),
        UV_Published_Date__c=date.today(),ALID__c='alid1',CID__c='cid1');
        
       insert localdata;
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
        
        Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='tl2');
        insert Language;
        
        Language__c Language1 = new Language__c (Name='TestLanguage1', Language_Order__c = 1,Language_Code_2__c='tl1');
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
        insert listAvailLang;
        
        Country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST');
        insert con;
        
        Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
        insert con1;
        
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
        insert conGrp;
        
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c='Country',Language__c=Language.Id,Level__c='2');
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
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);
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
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper.countryChannel = 'DTD';
        channelWrapper.additionalInfo = commAvailTest;
        ccc.channelGridList.add(channelWrapper);
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper1 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper1.countryChannel = 'DTD';
        channelWrapper1.additionalInfo = commAvailTest3; // Added on 27 Nov 
        ccc.channelGridList.add(channelWrapper1);
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper2 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper2.countryChannel = 'DTD';
        channelWrapper2.additionalInfo = commAvailTest2; // Added on 27 Nov  
        ccc.channelGridList.add(channelWrapper2);
        
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
        Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='tl1');
        insert Language;
        
        // Test Available language on Test Title
        Available_Languages__c availLangTitle= new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id);
        insert availLangTitle;
        
        // Test country for country grp 
        country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST');
        insert con;
        
        // Test Language Preferences
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c='Country',Language__c=Language.Id,Level__c='2');
        insert langPrefTest;
        
        // Test country grps
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
        insert conGrp;
        // Test Country Group Country
        Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
        insert conGrpCon;
        
        //Test commercial avail
        commercial_avail__c commTest= new commercial_avail__c(title__c=title1.Id,Channel__c='DTD',format__c='HD',Country_Lookup__c=con.Id,Languages__c=Language.Id, Language_Type__c='Dub',
                                       end_date__c=system.today()+190,start_Date__c=system.today()+10, Rights_End__c=system.today()+200,Exclusive_Date__c=(system.today()+2));
        insert commTest;
               
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Commercial_Avail__c commRec= new Commercial_Avail__c();
        commRec.Country_Group__c=conGrp.Id;
        caList.add(commRec);
        ApexPages.currentPage().getParameters().put('id', title.Id+','+title1.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);         
        WB_CreateReleasePlan_Controller.titleLangCount tempInstance = new WB_CreateReleasePlan_Controller.titleLangCount();
        tempInstance.reasonForFailure = 'Test';
        ccc.Channelgrid();
    }
    
    static testMethod void blankAvailDatesTest()
    {
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch2',RP_Batch_Id__c='2' );
        insert batchIDs;
        
        MPM__c mpm = new MPM__c(name='MPM rec',MPM_Number__c='1234');
        insert mpm;
        
        Title__c title = new Title__c(Name='New Title', Video_Version__c='0723456789',Formats__c='HD',First_Available_Date__c=system.today(),MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        insert title;
        
        List<Language__c> languages = new List<Language__c>();
        Language__c Language1 = new Language__c (Name='English',Language_Order__c = 1,Language_Code_2__c='en');
        languages.add(Language1);
        
        Language__c Language2 = new Language__c (Name='Arabic', Language_Order__c = 1,Language_Code_2__c='ar');
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
        
        Country__c con2 = new country__c(Name='United Arab Emirates',Country_Code__c='Test2', Country_Code2__c='tc',Status__c = 'Active',Channel__c='DTD;EST');
        insert con2;
        
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp',Country__c = 'United States;United Arab Emirates');
        insert conGrp;
        
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con1.Id,Type__c='Country',Language__c=Languages[0].Id,Level__c='1');
        insert langPrefTest;
        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con1.Id,Type__c='Country',Language__c=Languages[1].Id,Level__c='2');
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
        
        commercial_Avail__c commAvailTest3= new Commercial_Avail__c(); 
        commAvailTest3.Exclusive_Date__c=date.parse( '12/31/2000'); 
        commAvailTest3.Rights_End__c=date.parse( '12/31/2049'); 
        commAvailTest3.Start_Date__c=null; 
        commAvailTest3.End_Date__c=null; 
        commAvailTest3.status__c='Draft';
        
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
        cc.bulksave();
        test.stopTest();
    }
    
    static testMethod void blankAvailDatesEnglishOnlyTest()
    {
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch2',RP_Batch_Id__c='2' );
        insert batchIDs;
        
        MPM__c mpm = new MPM__c(name='MPM rec',MPM_Number__c='1234');
        insert mpm;
        
        Title__c title = new Title__c(Name='New Title', Video_Version__c='0723456789',Formats__c='HD',First_Available_Date__c=system.today(),MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        insert title;
        List<String> titleIdList = new List<String>();
        titleIdList.add(title.Id);
        
        List<Language__c> languages = new List<Language__c>();
        Language__c Language1 = new Language__c (Name='English',Language_Order__c = 1,Language_Code_2__c='en');
        languages.add(Language1);
        
        Language__c Language2 = new Language__c (Name='Arabic', Language_Order__c = 1,Language_Code_2__c='ar');
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
        
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con1.Id,Type__c='Country',Language__c=Languages[0].Id,Level__c='1');
        insert langPrefTest;
        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con1.Id,Type__c='Country',Language__c=Languages[1].Id,Level__c='2');
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
        cc.englishOnlyChk=true;
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
        test.startTest();
        cc.bulksave();
        
        test.stopTest();
    }
    
    static testMethod void blankAvailDatesLangPrefTest()
    {
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch2',RP_Batch_Id__c='2' );
        insert batchIDs;
        
        MPM__c mpm = new MPM__c(name='MPM rec',MPM_Number__c='1234');
        insert mpm;
        
        Title__c title = new Title__c(Name='New Title', Video_Version__c='0723456789',Formats__c='HD',First_Available_Date__c=system.today(),MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        insert title;
        List<String> titleIdList = new List<String>();
        titleIdList.add(title.Id);
        
        List<Language__c> languages = new List<Language__c>();
        Language__c Language1 = new Language__c (Name='English',Language_Order__c = 1,Language_Code_2__c='en');
        languages.add(Language1);
        
        Language__c Language2 = new Language__c (Name='Arabic', Language_Order__c = 1,Language_Code_2__c='ar');
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
        
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con1.Id,Type__c='Country',Language__c=Languages[0].Id,Level__c='2');
        insert langPrefTest;
        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con1.Id,Type__c='Country',Language__c=Languages[1].Id,Level__c='2');
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
        cc.englishOnlyChk=false;
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
        
        test.startTest();
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper.countryChannel = 'DTD';
        channelWrapper.additionalInfo = commAvailTest1;
        cc.channelGridList.add(channelWrapper);
        
        WB_CreateReleasePlan_Controller.channelWrapper channelWrapper2 = new WB_CreateReleasePlan_Controller.channelWrapper();
        channelWrapper2.countryChannel = 'EST';
        channelWrapper2.additionalInfo = commAvailTest2;
        cc.channelGridList.add(channelWrapper2);
        cc.bulksave();
        
        test.stopTest();
    }
    
    static testMethod void blankAvailDatesBatchTest()
    {        
        Map<String, String> mapRightsGrp = new Map<String, String>();
        List<Rights__c> lstRights = new List<Rights__c>();
        Set<String> SelectedFormatStrSet = new Set<String>();
        
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch2',RP_Batch_Id__c='2' );
        insert batchIDs;
        
        MPM__c mpm = new MPM__c(name='MPM rec',MPM_Number__c='1234');
        insert mpm;
        
        Title__c title = new Title__c(Name='New Title', Video_Version__c='0723456789',Formats__c='HD',First_Available_Date__c=system.today(),MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        Title__c title2 = new Title__c(Name='New Title2', Video_Version__c='0723456799',Formats__c='HD',First_Available_Date__c=system.today(),MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        List<Title__c> titleList =  new List<Title__c>();
        titleList.add(title);
        titleList.add(title2);
        
        insert titleList;
      
        List<String> titleIdList = new List<String>();
        for(Title__c t: titleList) //Aaditya Change
        {
            titleIdList.add(t.Id);
        }
        
        
        List<Language__c> languages = new List<Language__c>();
        Language__c Language1 = new Language__c (Name='English',Language_Order__c = 1,Language_Code_2__c='en');
        languages.add(Language1);
        
        Language__c Language2 = new Language__c (Name='Arabic', Language_Order__c = 1,Language_Code_2__c='ar');
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
        
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con1.Id,Type__c='Country',Language__c=Languages[0].Id,Level__c='1');
        insert langPrefTest;
        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con1.Id,Type__c='Country',Language__c=Languages[1].Id,Level__c='2');
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
        commAvailTest.Rights_End__c=System.Today().addYears(2);  
        commAvailTest.Exclusive_Date__c=System.Today()+5; 
        commAvailTest.Start_Date__c= System.Today()+10;
        commAvailTest.End_Date__c=System.Today().addYears(2);
        commAvailTest.status__c='Draft';
        commAvailTest.Country_Lookup__c = con2.id;
        commAvailTest.title__c = title2.id;
        commAvailTest.Languages__c = Languages[1].id;
        commAvailTest.Channel__c = 'EST';
        
        insert commAvailTest;
        
        
        
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
        
        WB_Batch_ReleasePlanWizard_New batchInstance = new WB_Batch_ReleasePlanWizard_New(titleIdList,countryIdList,cc.channelGridList,mapRightsGrp, lstRights, SelectedFormatStrSet,cc.isRightToCreateRPChk,cc.isRightToCreateRPEND,'Yes', True);
        batchInstance.englishOnlyChk = true;
        batchInstance.seperateLanguageTypeChk = false;
        database.executeBatch(batchInstance);
        cc.isRightToCreateRPEND= false;
        WB_Batch_ReleasePlanWizard_New batchInstance2 = new WB_Batch_ReleasePlanWizard_New(titleIdList,countryIdList,cc.channelGridList,mapRightsGrp, lstRights, SelectedFormatStrSet,cc.isRightToCreateRPChk,cc.isRightToCreateRPEND,'Yes',True);
        batchInstance2.englishOnlyChk = false;
        batchInstance2.seperateLanguageTypeChk = false;
        database.executeBatch(batchInstance2);
        
        test.stopTest();
    }
    
    static testMethod void blankAvailDatesBatchLangPrefTest()
    {
        Map<String, String> mapRightsGrp = new Map<String, String>();
        List<Rights__c> lstRights = new List<Rights__c>();
        Set<String> SelectedFormatStrSet = new Set<String>();
        
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch2',RP_Batch_Id__c='2' );
        insert batchIDs;
        
        MPM__c mpm = new MPM__c(name='MPM rec',MPM_Number__c='1234');
        insert mpm;
        
        Title__c title = new Title__c(Name='New Title', Video_Version__c='0723456789',Formats__c='HD',First_Available_Date__c=system.today(),
        MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        insert title;
        List<String> titleIdList = new List<String>();
        titleIdList.add(title.Id);
        
        List<Language__c> languages = new List<Language__c>();
        Language__c Language1 = new Language__c (Name='English',Language_Order__c = 1,Language_Code_2__c='en');
        languages.add(Language1);
        
        Language__c Language2 = new Language__c (Name='Arabic', Language_Order__c = 1,Language_Code_2__c='ar');
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
        
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con1.Id,Type__c='Country',Language__c=Languages[0].Id,Level__c='2');
        insert langPrefTest;
        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con1.Id,Type__c='Country',Language__c=Languages[1].Id,Level__c='2');
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
        commAvailTest3.Start_Date__c=null; 
        commAvailTest3.End_Date__c=null; 
        commAvailTest3.status__c='Draft';
        
        Test.startTest();
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
        /*
        WB_Batch_ReleasePlanWizard batchInstance = new WB_Batch_ReleasePlanWizard(titleIdList,countryIdList,cc.channelGridList,mapRightsGrp, lstRights, SelectedFormatStrSet,cc.isRightToCreateRPChk,'Yes',True);
        batchInstance.englishOnlyChk = false;
        batchInstance.seperateLanguageTypeChk = false;
        database.executeBatch(batchInstance);*/
        
        test.stopTest();
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
        Language__c Language = new Language__c (Name='English',Language_Order__c = 1);
        listLang.add(Language);
        //insert Language;
        
        Language__c Language1 = new Language__c (Name='TestLanguage1', Language_Order__c = 1,Language_Code_2__c='tl1');
        listLang.add(Language1);
        //insert Language1;
         
        Language__c Language2 = new Language__c (Name='TestLanguage3', Language_Order__c = 1,Language_Code_2__c='tl2');
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
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c='Country',Language__c=Language.Id,Level__c='3');
        insert langPrefTest;
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Type__c='Country',Language__c=Language1.Id,Level__c='2');
        insert langPrefTest1;
        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con.Id,Type__c='Country',Language__c=Language2.Id,Level__c='1');
        insert langPrefTest2;
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
        
        Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='tl2');
        insert Language;
        
        Available_Languages__c availLangTitle= new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id);
        insert availLangTitle;
        
        Country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST');
        insert con;
        
        Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
        insert con1;
        
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
        insert conGrp;
        
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c='Country',Language__c=Language.Id,Level__c='2');
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
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);
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
        
        Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='tl2');
        insert Language;
        
        //Available_Languages__c availLangTitle= new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title.Id);
        //insert availLangTitle;
        
        Country__c con= new country__c(Name='Test',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST');
        insert con;
        
        Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
        insert con1;
        
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
        insert conGrp;
        
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Type__c='Country',Language__c=Language.Id,Level__c='2');
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
        WB_CreateReleasePlan_Controller ccc = new WB_CreateReleasePlan_Controller(sc);
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
    
    //FADmap not null
    public static testmethod void methodcreateRP20(){
     Test.starttest();           
                
                map<id, date> firstAvalTitleDateMap = new map<id, date>();
                map<id, date> expirationDateTitleMap = new map<id, date>();
                Commercial_Avail__c  record = new Commercial_Avail__c();
                
                List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
                calist.add(record);
                
                MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
                insert mpm;
                list<title__c> testTitleList= new list<title__c>();
                Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today(),
                                              Expiration_Date__c=system.today()+365,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
                                              Short_Synopsis__c='short description',Digital_Planning__c='YES');       
                testTitleList.add(title1);
                insert testTitleList;
                
                firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
                expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
                String titleId =title1.id;  
                
                ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
                WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
                
                WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
                //WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller();
                objChannelGrid.additionalInfo = record;
                objChannelGrid.additionalInfo.Status__c='Draft';
                objChannelGrid.additionalInfo.Start_Date__c = null ; 
                objChannelGrid.additionalInfo.End_Date__c = null ; 
                objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
                objChannelGrid.additionalInfo.Rights_End__c = null;
                ctrinstance.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                                                                                        
                objChannelGrid.additionalInfo.Status__c='Draft';
                objChannelGrid.additionalInfo.Start_Date__c = null ; 
                objChannelGrid.additionalInfo.End_Date__c =date.parse('12/25/2018') ; 
                objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
                objChannelGrid.additionalInfo.Rights_End__c =date.parse('12/31/2018');
                ctrinstance.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
                objChannelGrid.additionalInfo.Status__c='Draft';                
                objChannelGrid.additionalInfo.Start_Date__c = null ; 
                objChannelGrid.additionalInfo.End_Date__c = null ; 
                objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
                objChannelGrid.additionalInfo.Rights_End__c = date.parse('12/31/2018');
                ctrinstance.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
                objChannelGrid.additionalInfo.Status__c='Draft';
                objChannelGrid.additionalInfo.Start_Date__c =date.parse('12/20/2018');
                objChannelGrid.additionalInfo.End_Date__c = null ; 
                objChannelGrid.additionalInfo.Exclusive_Date__c =date.parse('12/15/2018'); 
                objChannelGrid.additionalInfo.Rights_End__c = null;
                ctrinstance.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
                objChannelGrid.additionalInfo.Status__c='Draft';
                objChannelGrid.additionalInfo.Start_Date__c = null ; 
                objChannelGrid.additionalInfo.End_Date__c = null ; 
                objChannelGrid.additionalInfo.Exclusive_Date__c =date.parse('12/15/2018'); 
                objChannelGrid.additionalInfo.Rights_End__c = null;
                ctrinstance.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
                objChannelGrid.additionalInfo.Status__c='Draft';
                objChannelGrid.additionalInfo.Start_Date__c =date.parse('12/20/2018'); 
                objChannelGrid.additionalInfo.End_Date__c =date.parse('12/25/2018') ; 
                objChannelGrid.additionalInfo.Exclusive_Date__c =date.parse('12/15/2018'); 
                objChannelGrid.additionalInfo.Rights_End__c =date.parse('12/31/2018');
                ctrinstance.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
                objChannelGrid.additionalInfo.Status__c='Draft';
                objChannelGrid.additionalInfo.Start_Date__c =date.parse('12/20/2018'); 
                objChannelGrid.additionalInfo.End_Date__c =date.parse('12/25/2018') ;  
                objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
                objChannelGrid.additionalInfo.Rights_End__c = null;
                ctrinstance.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
                objChannelGrid.additionalInfo.Status__c='Draft';
                objChannelGrid.additionalInfo.Start_Date__c = null ; 
                objChannelGrid.additionalInfo.End_Date__c = null ; 
                objChannelGrid.additionalInfo.Exclusive_Date__c =date.parse('12/15/2018'); 
                objChannelGrid.additionalInfo.Rights_End__c =date.parse('12/31/2018');
                ctrinstance.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
                objChannelGrid.additionalInfo.Status__c='Draft';
                objChannelGrid.additionalInfo.Start_Date__c = null ;
                objChannelGrid.additionalInfo.End_Date__c= date.parse('12/25/2018') ; 
                objChannelGrid.additionalInfo.Exclusive_Date__c =date.parse('12/15/2018'); 
                objChannelGrid.additionalInfo.Rights_End__c =date.parse('12/31/2018');      
                ctrinstance.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
                //gridstatus=Not releasing 
                objChannelGrid.additionalInfo.Status__c='Not releasing';
                objChannelGrid.additionalInfo.Start_Date__c =date.parse('12/20/2018'); 
                objChannelGrid.additionalInfo.End_Date__c =date.parse('12/25/2018') ; 
                objChannelGrid.additionalInfo.Exclusive_Date__c =date.parse('12/15/2018'); 
                objChannelGrid.additionalInfo.Rights_End__c =date.parse('12/31/2018');
                ctrinstance.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
    Test.stoptest();
        
    }
    //FADmap is null
    public static testmethod void methodcreateRP21(){
     Test.starttest();           
                
                map<id, date> firstAvalTitleDateMap = new map<id, date>();
                map<id, date> expirationDateTitleMap = new map<id, date>();
                Commercial_Avail__c  record = new Commercial_Avail__c();
                
                List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
                calist.add(record);
                
                MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
                insert mpm;
                list<title__c> testTitleList= new list<title__c>();
                Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=null,
                                              Expiration_Date__c=null,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
                                              Short_Synopsis__c='short description',Digital_Planning__c='YES');       
                testTitleList.add(title1);
                insert testTitleList;
                
                firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
                expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
                String titleId =title1.id;  
                
                ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
                WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
                
                WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
                //WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller();
                objChannelGrid.additionalInfo = record;
                objChannelGrid.additionalInfo.Status__c='Draft';
                objChannelGrid.additionalInfo.Start_Date__c = null ; 
                objChannelGrid.additionalInfo.End_Date__c = null ; 
                objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
                objChannelGrid.additionalInfo.Rights_End__c = null;
                ctrinstance.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                                                                                        
                objChannelGrid.additionalInfo.Status__c='Draft';
                objChannelGrid.additionalInfo.Start_Date__c = null ; 
                objChannelGrid.additionalInfo.End_Date__c =date.parse('12/25/2018') ; 
                objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
                objChannelGrid.additionalInfo.Rights_End__c =date.parse('12/31/2018');
                ctrinstance.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
                objChannelGrid.additionalInfo.Status__c='Draft';                
                objChannelGrid.additionalInfo.Start_Date__c = null ; 
                objChannelGrid.additionalInfo.End_Date__c = null ; 
                objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
                objChannelGrid.additionalInfo.Rights_End__c = date.parse('12/31/2018');
                ctrinstance.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
                objChannelGrid.additionalInfo.Status__c='Draft';
                objChannelGrid.additionalInfo.Start_Date__c =date.parse('12/20/2018');
                objChannelGrid.additionalInfo.End_Date__c = null ; 
                objChannelGrid.additionalInfo.Exclusive_Date__c =date.parse('12/15/2018'); 
                objChannelGrid.additionalInfo.Rights_End__c = null;
                ctrinstance.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
                objChannelGrid.additionalInfo.Status__c='Draft';
                objChannelGrid.additionalInfo.Start_Date__c = null ; 
                objChannelGrid.additionalInfo.End_Date__c = null ; 
                objChannelGrid.additionalInfo.Exclusive_Date__c =date.parse('12/15/2018'); 
                objChannelGrid.additionalInfo.Rights_End__c = null;
                ctrinstance.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
                objChannelGrid.additionalInfo.Status__c='Draft';
                objChannelGrid.additionalInfo.Start_Date__c =date.parse('12/20/2018'); 
                objChannelGrid.additionalInfo.End_Date__c =date.parse('12/25/2018') ; 
                objChannelGrid.additionalInfo.Exclusive_Date__c =date.parse('12/15/2018'); 
                objChannelGrid.additionalInfo.Rights_End__c =date.parse('12/31/2018');
                ctrinstance.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
                objChannelGrid.additionalInfo.Status__c='Draft';
                objChannelGrid.additionalInfo.Start_Date__c =date.parse('12/20/2018'); 
                objChannelGrid.additionalInfo.End_Date__c =date.parse('12/25/2018') ;  
                objChannelGrid.additionalInfo.Exclusive_Date__c = null ; 
                objChannelGrid.additionalInfo.Rights_End__c = null;
                ctrinstance.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
                objChannelGrid.additionalInfo.Status__c='Draft';
                objChannelGrid.additionalInfo.Start_Date__c = null ; 
                objChannelGrid.additionalInfo.End_Date__c = null ; 
                objChannelGrid.additionalInfo.Exclusive_Date__c =date.parse('12/15/2018'); 
                objChannelGrid.additionalInfo.Rights_End__c =date.parse('12/31/2018');
                ctrinstance.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                 
                objChannelGrid.additionalInfo.Status__c='Draft';
                objChannelGrid.additionalInfo.Start_Date__c = null ;
                objChannelGrid.additionalInfo.End_Date__c= date.parse('12/25/2018') ; 
                objChannelGrid.additionalInfo.Exclusive_Date__c =date.parse('12/15/2018'); 
                objChannelGrid.additionalInfo.Rights_End__c =date.parse('12/31/2018');      
                ctrinstance.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
                objChannelGrid.additionalInfo.Status__c='Draft';
                objChannelGrid.additionalInfo.Start_Date__c = null ;
                objChannelGrid.additionalInfo.End_Date__c= date.parse('12/25/2018') ; 
                objChannelGrid.additionalInfo.Exclusive_Date__c =null; 
                objChannelGrid.additionalInfo.Rights_End__c =null;      
                ctrinstance.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
                
                //gridstatus=Not releasing 
                objChannelGrid.additionalInfo.Status__c='Not releasing';
                objChannelGrid.additionalInfo.Start_Date__c =date.parse('12/20/2018'); 
                objChannelGrid.additionalInfo.End_Date__c =date.parse('12/25/2018') ; 
                objChannelGrid.additionalInfo.Exclusive_Date__c =date.parse('12/15/2018'); 
                objChannelGrid.additionalInfo.Rights_End__c =date.parse('12/31/2018');
                ctrinstance.populateFromChannelGrid(objChannelGrid, firstAvalTitleDateMap, expirationDateTitleMap, titleId, record,objChannelGrid.additionalInfo.Status__c );
                
    Test.stoptest();
        
    }
    
     static testMethod void blankAvailDatesBatchTest2(){
            
        Map<String, String> mapRightsGrp = new Map<String, String>();
        List<Rights__c> lstRights = new List<Rights__c>();
        Set<String> SelectedFormatStrSet = new Set<String>();
        
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch2',RP_Batch_Id__c='2' );
        insert batchIDs;
        
        MPM__c mpm = new MPM__c(name='MPM rec',MPM_Number__c='1234');
        insert mpm;
        
        Title__c title = new Title__c(Name='New Title', Video_Version__c='0723456789',Formats__c='HD',First_Available_Date__c=system.today(),MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        Title__c title2 = new Title__c(Name='New Title2', Video_Version__c='0723456799',Formats__c='HD',First_Available_Date__c=system.today(),MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        List<Title__c> titleList =  new List<Title__c>();
        titleList.add(title);
        titleList.add(title2);
        
        insert titleList;
      
        List<String> titleIdList = new List<String>();
        for(Title__c t: titleList) //Aaditya Change
        {
            titleIdList.add(t.Id);
        }
        
        
        List<Language__c> languages = new List<Language__c>();
        Language__c Language1 = new Language__c (Name='English',Language_Order__c = 1,Language_Code_2__c='en');
        languages.add(Language1);
        
        Language__c Language2 = new Language__c (Name='Arabic', Language_Order__c = 1,Language_Code_2__c='ar');
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
        
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con1.Id,Type__c='Country',Language__c=Languages[0].Id,Level__c='1');
        insert langPrefTest;
        
        Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=con1.Id,Type__c='Country',Language__c=Languages[1].Id,Level__c='2');
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
        commAvailTest.Rights_End__c=System.Today().addYears(2);
        commAvailTest.Exclusive_Date__c=System.Today()+5; 
        commAvailTest.Start_Date__c= System.Today()+10;
        commAvailTest.End_Date__c=System.Today().addYears(2);
        commAvailTest.status__c='Draft';
        commAvailTest.Country_Lookup__c = con2.id;
        commAvailTest.title__c = title2.id;
        commAvailTest.Languages__c = Languages[1].id;
        commAvailTest.Channel__c = 'EST';
        
        insert commAvailTest;
        
        
        
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
        
        WB_Batch_ReleasePlanWizard_New batchInstance = new WB_Batch_ReleasePlanWizard_New(titleIdList,countryIdList,cc.channelGridList,mapRightsGrp, lstRights, SelectedFormatStrSet,cc.isRightToCreateRPChk,cc.isRightToCreateRPEND,'Yes', True);
        batchInstance.englishOnlyChk = true;
        batchInstance.seperateLanguageTypeChk = false;
        database.executeBatch(batchInstance);
        cc.isRightToCreateRPEND= false;
        WB_Batch_ReleasePlanWizard_New batchInstance2 = new WB_Batch_ReleasePlanWizard_New(titleIdList,countryIdList,cc.channelGridList,mapRightsGrp, lstRights, SelectedFormatStrSet,cc.isRightToCreateRPChk,cc.isRightToCreateRPEND,'Yes',True);
        batchInstance2.englishOnlyChk = false;
        batchInstance2.seperateLanguageTypeChk = false;
        database.executeBatch(batchInstance2);
        
        test.stopTest();
    } 
    
}