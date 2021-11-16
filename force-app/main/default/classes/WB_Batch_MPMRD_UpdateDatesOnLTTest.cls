@isTest
public class WB_Batch_MPMRD_UpdateDatesOnLTTest{

    public static testmethod void testBatchEST(){
        MPM__c mpm = new MPM__c(name='TestMPM',MPM_Number__c='9231');
        insert mpm;
        List<title__c> testTitleList= new List<title__c>();
        
        Title__c title1 = new Title__c(Name='TestTitle18Oct17', Video_Version__c='0123456789',
        First_Available_Date__c=null,Expiration_Date__c=system.today()+365,MPM__c = mpm.id,
        Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES',Formats__c='HD');
        
        Title__c title2 = new Title__c(Name='TestTitle', Video_Version__c='012345677868',Formats__c='HD',First_Available_Date__c=system.today(),
        MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        
        testTitleList.add(title1);
        testTitleList.add(title2);
        insert testTitleList;
        
        Country__c con= new country__c(Name='Test',Country_Code__c='Te', Country_Code2__c='te',Channel__c='DTD;EST');
        insert con;
        Language__c Language = new Language__c (Name='English', Language_Order__c = 1,Language_Code_2__c='na');
        insert Language;
        
        Language__c Language1 = new Language__c (Name='Spanish', Language_Order__c = 1);
        insert Language1;
        
        Local_Title__c localdata = new Local_Title__c(Name= 'test local data',Title__c =title1.id,
            Country__c =con.id,Language__c=Language.id,
            Status__c='Active',/*Version_EIDR__c='Version EIDR',*/Local_Rating_System__c='A',
            Local_Rating__c='A',Local_Synopsis__c='description for synopsis',Local_Label__c='label',
            Caption_Included_picklist__c='YES',Local_Run_Time__c=0123.00,
            Local_Theatrical_Release_Date__c=date.today(),Local_TV_Air_Date__c=date.today(),
            Local_DVD_Release_Date__c=date.today(),Local_BD_Release_Date__c=date.today(),
            UV_Published_Date__c=date.today(),ALID__c='alid1',CID__c='cid1',Key__c='unique'
        );
        
        insert localdata;
        //Select id,Release_Locale__c,Name from Rights_Group__c where Release_Locale__c
        Rights_Group__c testRG = new Rights_Group__c(Name='na_te',Release_Locale__c='na_te',Country__c=con.Id,Language__c=Language.Id);
        insert testRG;
        
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Audio',Title__c=title1.Id,Clear_To_Avail__c=false);
        listAvailLang.add(availLangTitle2);
        Available_Languages__c availLangTitle3 = new Available_Languages__c(Language__c=Language1.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle3);
        Available_Languages__c availLangTitle4 = new Available_Languages__c(Language__c=Language1.Id ,Language_Types__c='Audio',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle4);
        
        
                
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
            Title__c = title1.Id, Channel__c = 'EST', Format__c = 'HD', Country_Lookup__c = con.Id, Languages__c = Language.Id,
            Language_Type__c = 'Dub', end_date__c = date.parse('10/31/2024'), start_Date__c = date.parse('10/16/2019'),
            Rights_End__c=date.parse('10/31/2025'),Exclusive_Date__c=date.parse('10/15/2019')
        );
        insert commTest; 
        //lstCommAvail.add(commTest);
        
        MPM_Release_Date__c testMPMRD = new MPM_Release_Date__c(Avail_Start__c=commTest.Exclusive_Date__c,
                                        Channel__c='EST', Country__c=con.Id, EAI_Message__c='',EAI_Processing_Status__c='',
                                        EAI_Update_Date__c=null, Earliest_Release_Plan_ID__c=commTest.id ,
                                        Format__c='HD', Language__c=Language.Id, Local_Data_Roll_Down__c=true,
                                        MPM__c=mpm.id, MPM_Status__c='', Opt_Out_Date__c=null,  
                                        Opt_Out_Status__c='',
                                        Record_Status__c='', Locale__c='na_te', Release_Start__c=date.parse('10/16/2018'),  
                                        Release_Status__c='Open',  Theatrical_Release_Date__c= date.parse('10/15/2018'), 
                                        TV_Airing_Date__c=null );
        
        insert testMPMRD;
        
        Test.startTest();
        WB_Batch_MPMRD_UpdateDatesOnLocalTitle  batchInst = new WB_Batch_MPMRD_UpdateDatesOnLocalTitle();
        Database.executeBatch(batchInst,200);
        Test.stopTest();
    }
    public static testmethod void testBatchVOD(){
        MPM__c mpm = new MPM__c(name='TestMPM',MPM_Number__c='9231');
        insert mpm;
        List<title__c> testTitleList= new List<title__c>();
        
        Title__c title1 = new Title__c(Name='TestTitle18Oct17', Video_Version__c='0123456789',
        First_Available_Date__c=null,Expiration_Date__c=system.today()+365,MPM__c = mpm.id,
        Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES',Formats__c='HD');
        
        Title__c title2 = new Title__c(Name='TestTitle', Video_Version__c='012345677868',Formats__c='HD',First_Available_Date__c=system.today(),
        MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        
        testTitleList.add(title1);
        testTitleList.add(title2);
        insert testTitleList;
        
        Country__c con= new country__c(Name='Test',Country_Code__c='Te', Country_Code2__c='te',Channel__c='VODi;EST');
        insert con;
        Language__c Language = new Language__c (Name='English', Language_Order__c = 1,Language_Code_2__c='na');
        insert Language;
        
        Language__c Language1 = new Language__c (Name='Spanish', Language_Order__c = 1);
        insert Language1;
        
        Local_Title__c localdata = new Local_Title__c(Name= 'test local data',Title__c =title1.id,
            Country__c =con.id,Language__c=Language.id,
            Status__c='Active',/*Version_EIDR__c='Version EIDR',*/Local_Rating_System__c='A',
            Local_Rating__c='A',Local_Synopsis__c='description for synopsis',Local_Label__c='label',
            Caption_Included_picklist__c='YES',Local_Run_Time__c=0123.00,
            Local_Theatrical_Release_Date__c=date.today(),Local_TV_Air_Date__c=date.today(),
            Local_DVD_Release_Date__c=date.today(),Local_BD_Release_Date__c=date.today(),
            UV_Published_Date__c=date.today(),ALID__c='alid1',CID__c='cid1',Key__c='unique'
        );
        
        insert localdata;
        //Select id,Release_Locale__c,Name from Rights_Group__c where Release_Locale__c
        Rights_Group__c testRG = new Rights_Group__c(Name='na_te',Release_Locale__c='na_te',Country__c=con.Id,Language__c=Language.Id);
        insert testRG;
        
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Audio',Title__c=title1.Id,Clear_To_Avail__c=false);
        listAvailLang.add(availLangTitle2);
        Available_Languages__c availLangTitle3 = new Available_Languages__c(Language__c=Language1.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle3);
        Available_Languages__c availLangTitle4 = new Available_Languages__c(Language__c=Language1.Id ,Language_Types__c='Audio',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle4);
        
        
                
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
            Title__c = title1.Id, Channel__c = 'VODi', Format__c = 'HD', Country_Lookup__c = con.Id, Languages__c = Language.Id,
            Language_Type__c = 'Dub', end_date__c = date.parse('10/31/2024'), start_Date__c = date.parse('10/16/2019'),
            Rights_End__c=date.parse('10/31/2025'),Exclusive_Date__c=date.parse('10/15/2019')
        );
        insert commTest; 
        //lstCommAvail.add(commTest);
        
        MPM_Release_Date__c testMPMRD = new MPM_Release_Date__c(Avail_Start__c=commTest.Exclusive_Date__c,
                                        Channel__c='VODi', Country__c=con.Id, EAI_Message__c='',EAI_Processing_Status__c='',
                                        EAI_Update_Date__c=null, Earliest_Release_Plan_ID__c=commTest.id ,
                                        Format__c='HD', Language__c=Language.Id, Local_Data_Roll_Down__c=true,
                                        MPM__c=mpm.id, MPM_Status__c='', Opt_Out_Date__c=null,  
                                        Opt_Out_Status__c='',
                                        Record_Status__c='', Locale__c='na_te', Release_Start__c=date.parse('10/16/2018'),  
                                        Release_Status__c='Open',  Theatrical_Release_Date__c= date.parse('10/15/2018'), 
                                        TV_Airing_Date__c=null );
        
        insert testMPMRD;
        
        Test.startTest();
        WB_Batch_MPMRD_UpdateDatesOnLocalTitle  batchInst = new WB_Batch_MPMRD_UpdateDatesOnLocalTitle();
        Database.executeBatch(batchInst,200);
        Test.stopTest();
    }
    public static testmethod void testBatchPhysical(){
        MPM__c mpm = new MPM__c(name='TestMPM',MPM_Number__c='9231');
        insert mpm;
        List<title__c> testTitleList= new List<title__c>();
        
        Title__c title1 = new Title__c(Name='TestTitle18Oct17', Video_Version__c='0123456789',
        First_Available_Date__c=null,Expiration_Date__c=system.today()+365,MPM__c = mpm.id,
        Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES',Formats__c='HD');
        
        Title__c title2 = new Title__c(Name='TestTitle', Video_Version__c='012345677868',Formats__c='HD',First_Available_Date__c=system.today(),
        MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        
        testTitleList.add(title1);
        testTitleList.add(title2);
        insert testTitleList;
        
        Country__c con= new country__c(Name='Test',Country_Code__c='Te', Country_Code2__c='te',Channel__c='VODi;Physical');
        insert con;
        Language__c Language = new Language__c (Name='English', Language_Order__c = 1,Language_Code_2__c='na');
        insert Language;
        
        Language__c Language1 = new Language__c (Name='Spanish', Language_Order__c = 1);
        insert Language1;
        
        Local_Title__c localdata = new Local_Title__c(Name= 'test local data',Title__c =title1.id,
            Country__c =con.id,Language__c=Language.id,
            Status__c='Active',/*Version_EIDR__c='Version EIDR',*/Local_Rating_System__c='A',
            Local_Rating__c='A',Local_Synopsis__c='description for synopsis',Local_Label__c='label',
            Caption_Included_picklist__c='YES',Local_Run_Time__c=0123.00,
            Local_Theatrical_Release_Date__c=date.today(),Local_TV_Air_Date__c=date.today(),
            Local_DVD_Release_Date__c=date.today(),Local_BD_Release_Date__c=date.today(),
            UV_Published_Date__c=date.today(),ALID__c='alid1',CID__c='cid1',Key__c='unique'
        );
        
        insert localdata;
        //Select id,Release_Locale__c,Name from Rights_Group__c where Release_Locale__c
        Rights_Group__c testRG = new Rights_Group__c(Name='na_te',Release_Locale__c='na_te',Country__c=con.Id,Language__c=Language.Id);
        insert testRG;
        
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Audio',Title__c=title1.Id,Clear_To_Avail__c=false);
        listAvailLang.add(availLangTitle2);
        Available_Languages__c availLangTitle3 = new Available_Languages__c(Language__c=Language1.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle3);
        Available_Languages__c availLangTitle4 = new Available_Languages__c(Language__c=Language1.Id ,Language_Types__c='Audio',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle4);
        
        
                
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
            Title__c = title1.Id, Channel__c = 'Physical', Format__c = 'HD', Country_Lookup__c = con.Id, Languages__c = Language.Id,
            Language_Type__c = 'Dub', end_date__c = date.parse('10/31/2024'), start_Date__c = date.parse('10/16/2019'),
            Rights_End__c=date.parse('10/31/2025'),Exclusive_Date__c=date.parse('10/15/2019')
        );
        insert commTest; 
        //lstCommAvail.add(commTest);
        
        MPM_Release_Date__c testMPMRD = new MPM_Release_Date__c(Avail_Start__c=commTest.Exclusive_Date__c,
                                        Channel__c='Physical', Country__c=con.Id, EAI_Message__c='',EAI_Processing_Status__c='',
                                        EAI_Update_Date__c=null, Earliest_Release_Plan_ID__c=commTest.id ,
                                        Format__c='HD', Language__c=Language.Id, Local_Data_Roll_Down__c=true,
                                        MPM__c=mpm.id, MPM_Status__c='', Opt_Out_Date__c=null,  
                                        Opt_Out_Status__c='',
                                        Record_Status__c='', Locale__c='na_te', Release_Start__c=date.parse('10/16/2018'),  
                                        Release_Status__c='Open',  Theatrical_Release_Date__c= date.parse('10/15/2018'), 
                                        TV_Airing_Date__c=null );
        
        insert testMPMRD;
        
        Test.startTest();
        WB_Batch_MPMRD_UpdateDatesOnLocalTitle  batchInst = new WB_Batch_MPMRD_UpdateDatesOnLocalTitle();
        Database.executeBatch(batchInst,200);
        Test.stopTest();
    }
    
        public static testmethod void testBatchPhysical2(){
        MPM__c mpm = new MPM__c(name='TestMPM',MPM_Number__c='9231');
        insert mpm;
        List<title__c> testTitleList= new List<title__c>();
        
        Title__c title1 = new Title__c(Name='TestTitle18Oct17', Video_Version__c='0123456789',
        First_Available_Date__c=null,Expiration_Date__c=system.today()+365,MPM__c = mpm.id,
        Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES',Formats__c='HD');
        
        Title__c title2 = new Title__c(Name='TestTitle', Video_Version__c='012345677868',Formats__c='HD',First_Available_Date__c=system.today(),
        MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        
        testTitleList.add(title1);
        testTitleList.add(title2);
        insert testTitleList;
        
        Country__c con= new country__c(Name='Test',Country_Code__c='Te', Country_Code2__c='te',Channel__c='VODi;Physical');
        insert con;
        Language__c Language = new Language__c (Name='English', Language_Order__c = 1,Language_Code_2__c='na');
        insert Language;
        
        Language__c Language1 = new Language__c (Name='Spanish', Language_Order__c = 1);
        insert Language1;
        
        Local_Title__c localdata = new Local_Title__c(Name= 'test local data',Title__c =title1.id,
            Country__c =con.id,Language__c=Language.id,
            Status__c='Active',/*Version_EIDR__c='Version EIDR',*/Local_Rating_System__c='A',
            Local_Rating__c='A',Local_Synopsis__c='description for synopsis',Local_Label__c='label',
            Caption_Included_picklist__c='YES',Local_Run_Time__c=0123.00,
            Local_Theatrical_Release_Date__c=date.today(),Local_TV_Air_Date__c=date.today(),
            Local_DVD_Release_Date__c=date.today(),Local_BD_Release_Date__c=date.today(),
            UV_Published_Date__c=date.today(),ALID__c='alid1',CID__c='cid1',Key__c='unique'
        );
        
        insert localdata;
        //Select id,Release_Locale__c,Name from Rights_Group__c where Release_Locale__c
        Rights_Group__c testRG = new Rights_Group__c(Name='na_te',Release_Locale__c='na_te',Country__c=con.Id,Language__c=Language.Id);
        insert testRG;
        
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Audio',Title__c=title1.Id,Clear_To_Avail__c=false);
        listAvailLang.add(availLangTitle2);
        Available_Languages__c availLangTitle3 = new Available_Languages__c(Language__c=Language1.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle3);
        Available_Languages__c availLangTitle4 = new Available_Languages__c(Language__c=Language1.Id ,Language_Types__c='Audio',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle4);
        
        
                
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
            Title__c = title1.Id, Channel__c = 'Physical', Format__c = 'HD', Country_Lookup__c = con.Id, Languages__c = Language.Id,
            Language_Type__c = 'Dub', end_date__c = system.today()+65, start_Date__c = system.today()+2,
            Rights_End__c=system.today()+85,Exclusive_Date__c=system.today()+2
        );
        insert commTest; 
        //lstCommAvail.add(commTest);
        
        MPM_Release_Date__c testMPMRD = new MPM_Release_Date__c(Avail_Start__c=commTest.Exclusive_Date__c,
                                        Channel__c='Physical', Country__c=con.Id, EAI_Message__c='',EAI_Processing_Status__c='',
                                        EAI_Update_Date__c=null, Earliest_Release_Plan_ID__c=commTest.id ,
                                        Format__c='HD', Language__c=Language.Id, Local_Data_Roll_Down__c=true,
                                        MPM__c=mpm.id, MPM_Status__c='', Opt_Out_Date__c=null,  
                                        Opt_Out_Status__c='',
                                        Record_Status__c='', Locale__c='na_te', Release_Start__c=system.today()+2,  
                                        Release_Status__c='Confirmed',  Theatrical_Release_Date__c= system.today()+1, 
                                        TV_Airing_Date__c=null );
        
        insert testMPMRD;
        
        Test.startTest();
        WB_Batch_MPMRD_UpdateDatesOnLocalTitle  batchInst = new WB_Batch_MPMRD_UpdateDatesOnLocalTitle();
        Database.executeBatch(batchInst,200);
        Test.stopTest();
    }
    
    public static testmethod void testBatchPhysical3(){
        MPM__c mpm = new MPM__c(name='TestMPM',MPM_Number__c='9231');
        insert mpm;
        List<title__c> testTitleList= new List<title__c>();
        
        Title__c title1 = new Title__c(Name='TestTitle18Oct17', Video_Version__c='0123456789',
        First_Available_Date__c=null,Expiration_Date__c=system.today()+365,MPM__c = mpm.id,
        Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES',Formats__c='HD');
        
        Title__c title2 = new Title__c(Name='TestTitle', Video_Version__c='012345677868',Formats__c='HD',First_Available_Date__c=system.today(),
        MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        
        testTitleList.add(title1);
        testTitleList.add(title2);
        insert testTitleList;
        
        Country__c con= new country__c(Name='Test',Country_Code__c='Te', Country_Code2__c='te',Channel__c='VODi;Physical');
        insert con;
        Language__c Language = new Language__c (Name='English', Language_Order__c = 1,Language_Code_2__c='na');
        insert Language;
        
        Language__c Language1 = new Language__c (Name='Spanish', Language_Order__c = 1);
        insert Language1;
        
        Local_Title__c localdata = new Local_Title__c(Name= 'test local data',Title__c =title1.id,
            Country__c =con.id,Language__c=Language.id,
            Status__c='Active',/*Version_EIDR__c='Version EIDR',*/Local_Rating_System__c='A',
            Local_Rating__c='A',Local_Synopsis__c='description for synopsis',Local_Label__c='label',
            Caption_Included_picklist__c='YES',Local_Run_Time__c=0123.00,
            Local_Theatrical_Release_Date__c=date.today(),Local_TV_Air_Date__c=date.today(),
            Local_DVD_Release_Date__c=date.today(),Local_BD_Release_Date__c=date.today(),
            UV_Published_Date__c=date.today(),ALID__c='alid1',CID__c='cid1',Key__c='unique'
        );
        
        insert localdata;
        //Select id,Release_Locale__c,Name from Rights_Group__c where Release_Locale__c
        Rights_Group__c testRG = new Rights_Group__c(Name='na_te',Release_Locale__c='na_te',Country__c=con.Id,Language__c=Language.Id);
        insert testRG;
        
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Audio',Title__c=title1.Id,Clear_To_Avail__c=false);
        listAvailLang.add(availLangTitle2);
        Available_Languages__c availLangTitle3 = new Available_Languages__c(Language__c=Language1.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle3);
        Available_Languages__c availLangTitle4 = new Available_Languages__c(Language__c=Language1.Id ,Language_Types__c='Audio',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle4);
        
        
                
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
            Title__c = title1.Id, Channel__c = 'Physical', Format__c = 'HD', Country_Lookup__c = con.Id, Languages__c = Language.Id,
            Language_Type__c = 'Dub', end_date__c = system.today()+65, start_Date__c = system.today()+2,
            Rights_End__c=system.today()+85,Exclusive_Date__c=system.today()+2
        );
        insert commTest; 
        //lstCommAvail.add(commTest);
        
        MPM_Release_Date__c testMPMRD = new MPM_Release_Date__c(Avail_Start__c=commTest.Exclusive_Date__c,
                                        Channel__c='Physical', Country__c=con.Id, EAI_Message__c='',EAI_Processing_Status__c='',
                                        EAI_Update_Date__c=null, Earliest_Release_Plan_ID__c=commTest.id ,
                                        Format__c='HD', Language__c=Language.Id, Local_Data_Roll_Down__c=true,
                                        MPM__c=mpm.id, MPM_Status__c='', Opt_Out_Date__c=null,  
                                        Opt_Out_Status__c='',
                                        Record_Status__c='', Locale__c='na_te', Release_Start__c=system.today()+2,  
                                        Release_Status__c='Tentative',  Theatrical_Release_Date__c= system.today()+1, 
                                        TV_Airing_Date__c=null );
        
        insert testMPMRD;
        
        Test.startTest();
        WB_Batch_MPMRD_UpdateDatesOnLocalTitle  batchInst = new WB_Batch_MPMRD_UpdateDatesOnLocalTitle();
        Database.executeBatch(batchInst,200);
        Test.stopTest();
    }
    
    public static testmethod void testBatchPhysical4(){
        MPM__c mpm = new MPM__c(name='TestMPM',MPM_Number__c='9231');
        insert mpm;
        List<title__c> testTitleList= new List<title__c>();
        
        Title__c title1 = new Title__c(Name='TestTitle18Oct17', Video_Version__c='0123456789',
        First_Available_Date__c=null,Expiration_Date__c=system.today()+365,MPM__c = mpm.id,
        Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES',Formats__c='HD');
        
        Title__c title2 = new Title__c(Name='TestTitle', Video_Version__c='012345677868',Formats__c='HD',First_Available_Date__c=system.today(),
        MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        
        testTitleList.add(title1);
        testTitleList.add(title2);
        insert testTitleList;
        
        Country__c con= new country__c(Name='Test',Country_Code__c='Te', Country_Code2__c='te',Channel__c='VODi;Physical');
        insert con;
        Language__c Language = new Language__c (Name='English', Language_Order__c = 1,Language_Code_2__c='na');
        insert Language;
        
        Language__c Language1 = new Language__c (Name='Spanish', Language_Order__c = 1);
        insert Language1;
        
        Local_Title__c localdata = new Local_Title__c(Name= 'test local data',Title__c =title1.id,
            Country__c =con.id,Language__c=Language.id,
            Status__c='Active',/*Version_EIDR__c='Version EIDR',*/Local_Rating_System__c='A',
            Local_Rating__c='A',Local_Synopsis__c='description for synopsis',Local_Label__c='label',
            Caption_Included_picklist__c='YES',Local_Run_Time__c=0123.00,
            Local_Theatrical_Release_Date__c=date.today(),Local_TV_Air_Date__c=date.today(),
            Local_DVD_Release_Date__c=date.today(),Local_BD_Release_Date__c=date.today(),
            UV_Published_Date__c=date.today(),ALID__c='alid1',CID__c='cid1',Key__c='unique'
        );
        
        insert localdata;
        //Select id,Release_Locale__c,Name from Rights_Group__c where Release_Locale__c
        Rights_Group__c testRG = new Rights_Group__c(Name='na_te',Release_Locale__c='na_te',Country__c=con.Id,Language__c=Language.Id);
        insert testRG;
        
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Audio',Title__c=title1.Id,Clear_To_Avail__c=false);
        listAvailLang.add(availLangTitle2);
        Available_Languages__c availLangTitle3 = new Available_Languages__c(Language__c=Language1.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle3);
        Available_Languages__c availLangTitle4 = new Available_Languages__c(Language__c=Language1.Id ,Language_Types__c='Audio',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle4);
        
        
                
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
            Title__c = title1.Id, Channel__c = 'Physical', Format__c = 'HD', Country_Lookup__c = con.Id, Languages__c = Language.Id,
            Language_Type__c = 'Dub', end_date__c = system.today()+65, start_Date__c = system.today()+2,
            Rights_End__c=system.today()+85,Exclusive_Date__c=system.today()+2
        );
        insert commTest; 
        //lstCommAvail.add(commTest);
        
        MPM_Release_Date__c testMPMRD = new MPM_Release_Date__c(Avail_Start__c=commTest.Exclusive_Date__c,
                                        Channel__c='Physical', Country__c=null, EAI_Message__c='',EAI_Processing_Status__c='',
                                        EAI_Update_Date__c=null, Earliest_Release_Plan_ID__c=commTest.id ,
                                        Format__c='HD', Language__c=Language.Id, Local_Data_Roll_Down__c=true,
                                        MPM__c=mpm.id, MPM_Status__c='', Opt_Out_Date__c=null,  
                                        Opt_Out_Status__c='',
                                        Record_Status__c='', Locale__c='', Release_Start__c=system.today()+2,  
                                        Release_Status__c='Tentative',  Theatrical_Release_Date__c= system.today()+43, 
                                        TV_Airing_Date__c=null );
        
        insert testMPMRD;
        
        Test.startTest();
        WB_Batch_MPMRD_UpdateDatesOnLocalTitle  batchInst = new WB_Batch_MPMRD_UpdateDatesOnLocalTitle();
        Database.executeBatch(batchInst,200);
        Test.stopTest();
    }
    
    public static testmethod void testBatchPhysical5(){
        MPM__c mpm = new MPM__c(name='TestMPM',MPM_Number__c='9231');
        insert mpm;
        List<title__c> testTitleList= new List<title__c>();
        
        Title__c title1 = new Title__c(Name='TestTitle18Oct17', Video_Version__c='0123456789',
        First_Available_Date__c=null,Expiration_Date__c=system.today()+365,MPM__c = mpm.id,
        Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES',Formats__c='HD');
        
        Title__c title2 = new Title__c(Name='TestTitle', Video_Version__c='012345677868',Formats__c='HD',First_Available_Date__c=system.today(),
        MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='YES');
        
        
        testTitleList.add(title1);
        testTitleList.add(title2);
        insert testTitleList;
        
        Country__c con= new country__c(Name='Test',Country_Code__c='Te', Country_Code2__c='te',Channel__c='VODi;Physical');
        insert con;
        Language__c Language = new Language__c (Name='English', Language_Order__c = 1,Language_Code_2__c='na');
        insert Language;
        
        Language__c Language1 = new Language__c (Name='Spanish', Language_Order__c = 1);
        insert Language1;
        
        Local_Title__c localdata = new Local_Title__c(Name= 'test local data',Title__c =title1.id,
            Country__c =con.id,Language__c=Language.id,
            Status__c='Active',/*Version_EIDR__c='Version EIDR',*/Local_Rating_System__c='A',
            Local_Rating__c='A',Local_Synopsis__c='description for synopsis',Local_Label__c='label',
            Caption_Included_picklist__c='YES',Local_Run_Time__c=0123.00,
            Local_Theatrical_Release_Date__c=date.today(),Local_TV_Air_Date__c=date.today(),
            Local_DVD_Release_Date__c=date.today(),Local_BD_Release_Date__c=date.today(),
            UV_Published_Date__c=date.today(),ALID__c='alid1',CID__c='cid1',Key__c='unique'
        );
        
        insert localdata;
        //Select id,Release_Locale__c,Name from Rights_Group__c where Release_Locale__c
        Rights_Group__c testRG = new Rights_Group__c(Name='na_te',Release_Locale__c='na_te',Country__c=con.Id,Language__c=Language.Id);
        insert testRG;
        
        
        List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=Language.Id ,Language_Types__c='Audio',Title__c=title1.Id,Clear_To_Avail__c=false);
        listAvailLang.add(availLangTitle2);
        Available_Languages__c availLangTitle3 = new Available_Languages__c(Language__c=Language1.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle3);
        Available_Languages__c availLangTitle4 = new Available_Languages__c(Language__c=Language1.Id ,Language_Types__c='Audio',Title__c=title1.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle4);
        
        
                
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
            Title__c = title1.Id, Channel__c = 'Physical', Format__c = 'HD', Country_Lookup__c = con.Id, Languages__c = Language.Id,
            Language_Type__c = 'Dub', end_date__c = system.today()+65, start_Date__c = system.today()+2,
            Rights_End__c=system.today()+85,Exclusive_Date__c=system.today()+2
        );
        insert commTest; 
        //lstCommAvail.add(commTest);
        
        MPM_Release_Date__c testMPMRD = new MPM_Release_Date__c(Avail_Start__c=commTest.Exclusive_Date__c,
                                        Channel__c='Physical', Country__c=null, EAI_Message__c='',EAI_Processing_Status__c='',
                                        EAI_Update_Date__c=null, Earliest_Release_Plan_ID__c=null ,
                                        Format__c='HD', Language__c=null, Local_Data_Roll_Down__c=true,
                                        MPM__c=mpm.id, MPM_Status__c='', Opt_Out_Date__c=null,  
                                        Opt_Out_Status__c='',
                                        Record_Status__c='', Locale__c='', Release_Start__c=system.today()+2,  
                                        Release_Status__c='Tentative',  Theatrical_Release_Date__c= system.today()+43, 
                                        TV_Airing_Date__c=null );
        
        insert testMPMRD;
        
        Test.startTest();
        WB_Batch_MPMRD_UpdateDatesOnLocalTitle  batchInst = new WB_Batch_MPMRD_UpdateDatesOnLocalTitle();
        Database.executeBatch(batchInst,200);
        Test.stopTest();
    }
    
    
}