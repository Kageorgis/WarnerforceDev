@isTest
public class WB_CreateReleasePLan_Helper_Test{
    //returnProcessedRP_case1 
    public static testmethod void method1(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=null,
		Expiration_Date__c=null,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	Rights__c mpmRights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdMPM);
    insert mpmRights;
	
	Rights__c titleRights = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdVBOM);
    insert titleRights;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	mapRights.put(titleRights.Video_Version__c+'_'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
	
	mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'_'+mpmRights.Channel__c,mpmRights);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case1(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
	
	test.Stoptest();
        
    }
    
    //returnProcessedRP_case1  right status = 'Researching'
    public static testmethod void method2(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=null,
		Expiration_Date__c=null,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	Rights__c mpmRights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Researching', Source__c ='Manual',
        /*Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,*/RecordTypeId=recordTypeIdMPM);
    insert mpmRights;
	
	Rights__c titleRights = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Researching', Source__c ='Manual',
        /*Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,*/RecordTypeId=recordTypeIdVBOM);
    insert titleRights;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	mapRights.put(titleRights.Video_Version__c+'_'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
	
	mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'_'+mpmRights.Channel__c,mpmRights);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case1(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
	
	test.Stoptest();
        
    }
    
    //helpermethod2
    public static testmethod void method3(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=null,
		Expiration_Date__c=null,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	Rights__c mpmRights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdMPM);
    insert mpmRights;
	
	Rights__c titleRights = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdVBOM);
    insert titleRights;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	mapRights.put(titleRights.Video_Version__c+'_'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
	
	mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'_'+mpmRights.Channel__c,mpmRights);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case2(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
	
	test.Stoptest();
        
    }
    
    //returnProcessedRP_case2 right status = 'Researching'
    public static testmethod void method4(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=null,
		Expiration_Date__c=null,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	Rights__c mpmRights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Researching', Source__c ='Manual',
        /*Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,*/RecordTypeId=recordTypeIdMPM);
    insert mpmRights;
	
	Rights__c titleRights = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Researching', Source__c ='Manual',
        /*Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,*/RecordTypeId=recordTypeIdVBOM);
    insert titleRights;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	mapRights.put(titleRights.Video_Version__c+'_'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
	
	mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'_'+mpmRights.Channel__c,mpmRights);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case2(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
	
	test.Stoptest();
        
    }
    
    //returnProcessedRP_case3 right status = 'Researching'
    public static testmethod void method8(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=null,
		Expiration_Date__c=null,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	Rights__c mpmRights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Researching', Source__c ='Manual',
        /*Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,*/RecordTypeId=recordTypeIdMPM);
    insert mpmRights;
	
	Rights__c titleRights = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Researching', Source__c ='Manual',
        /*Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,*/RecordTypeId=recordTypeIdVBOM);
    insert titleRights;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	mapRights.put(titleRights.Video_Version__c+'_'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
	
	mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'_'+mpmRights.Channel__c,mpmRights);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case3(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
	
	test.Stoptest();
        
    }
    
    //Release Plan not created since no rights are found in CAS. returnProcessedRP_case1
    public static testmethod void method5(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=null,
		Expiration_Date__c=null,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	Rights__c mpmRights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdMPM);
    insert mpmRights;
	
	Rights__c titleRights = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdVBOM);
    insert titleRights;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	mapRights.put(titleRights.Video_Version__c+'__'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
	
	mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'__'+mpmRights.Channel__c,mpmRights);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case1(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
	
	test.Stoptest();
        
    }
    
    //Release Plan not created since no rights are found in CAS. returnProcessedRP_case2
    public static testmethod void method6(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=null,
		Expiration_Date__c=null,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	Rights__c mpmRights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdMPM);
    insert mpmRights;
	
	Rights__c titleRights = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdVBOM);
    insert titleRights;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	mapRights.put(titleRights.Video_Version__c+'__'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
	
	mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'__'+mpmRights.Channel__c,mpmRights);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case2(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
	
	test.Stoptest();
        
    }
    
    //Release Plan not created since no rights are found in CAS. returnProcessedRP_case3
    public static testmethod void method7(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=null,
		Expiration_Date__c=null,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	Rights__c mpmRights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdMPM);
    insert mpmRights;
	
	Rights__c titleRights = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdVBOM);
    insert titleRights;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	mapRights.put(titleRights.Video_Version__c+'__'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
	
	mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'__'+mpmRights.Channel__c,mpmRights);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case3(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
	
	test.Stoptest();
        
    }
    
    //fstAvailDt > ryt.Rights_End_5__c && ryt.Rights_End_5__c != null returnProcessedRP_case1
    public static testmethod void method9(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today()+190,
		Expiration_Date__c=system.today()+390,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	Rights__c mpmRights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdMPM);
    insert mpmRights;
	
	Rights__c titleRights = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdVBOM);
    insert titleRights;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	mapRights.put(titleRights.Video_Version__c+'_'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
	
	mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'_'+mpmRights.Channel__c,mpmRights);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case1(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
	
	test.Stoptest();
        
    }
    
    //fstAvailDt > ryt.Rights_End_5__c && ryt.Rights_End_5__c != null returnProcessedRP_case2
    public static testmethod void method10(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today()+190,
		Expiration_Date__c=system.today()+390,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	Rights__c mpmRights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdMPM);
    insert mpmRights;
	
	Rights__c titleRights = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdVBOM);
    insert titleRights;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	mapRights.put(titleRights.Video_Version__c+'_'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
	
	mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'_'+mpmRights.Channel__c,mpmRights);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case2(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
	
	test.Stoptest();
        
    }
    
    //fstAvailDt > ryt.Rights_End_5__c && ryt.Rights_End_5__c != null returnProcessedRP_case3
    public static testmethod void method11(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today()+190,
		Expiration_Date__c=system.today()+390,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	Rights__c mpmRights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdMPM);
    insert mpmRights;
	
	Rights__c titleRights = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdVBOM);
    insert titleRights;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	mapRights.put(titleRights.Video_Version__c+'_'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
	
	mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'_'+mpmRights.Channel__c,mpmRights);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case3(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
	
	test.Stoptest();
        
    }
    
    //returnProcessedRP_case1 FAD=today-365 EXP = today+365
    public static testmethod void method12(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today()-365,
		Expiration_Date__c=system.today()+365,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	Rights__c mpmRights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdMPM);
    insert mpmRights;
	
	Rights__c titleRights = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdVBOM);
    insert titleRights;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	mapRights.put(titleRights.Video_Version__c+'_'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
	
	mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'_'+mpmRights.Channel__c,mpmRights);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case1(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
	
	test.Stoptest();
        
    }
    
    //returnProcessedRP_case2 FAD=today-365 EXP = today+365
    public static testmethod void method13(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today()-365,
		Expiration_Date__c=system.today()+365,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	Rights__c mpmRights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdMPM);
    insert mpmRights;
	
	Rights__c titleRights = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdVBOM);
    insert titleRights;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	mapRights.put(titleRights.Video_Version__c+'_'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
	
	mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'_'+mpmRights.Channel__c,mpmRights);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case2(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
	
	test.Stoptest();
        
    }
    
    //returnProcessedRP_case3 FAD=today-365 EXP = today+365
    public static testmethod void method14(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today()-365,
		Expiration_Date__c=system.today()+365,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	Rights__c mpmRights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdMPM);
    insert mpmRights;
	
	Rights__c titleRights = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdVBOM);
    insert titleRights;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	mapRights.put(titleRights.Video_Version__c+'_'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
	
	mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'_'+mpmRights.Channel__c,mpmRights);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case3(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
	
	test.Stoptest();
        
    }
    
    //returnProcessedRP_case1 FAD=today-365 EXP = today+365
    public static testmethod void method15(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today()-365,
		Expiration_Date__c=system.today()+365,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	Rights__c mpmRights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdMPM);
    insert mpmRights;
	
	Rights__c titleRights = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdVBOM);
    insert titleRights;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	mapRights.put(titleRights.Video_Version__c+'_'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
	
	mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'_'+mpmRights.Channel__c,mpmRights);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case1(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
	
	test.Stoptest();
        
    }
    
     public static testmethod void methodRightsCheck(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today()+4,
		Expiration_Date__c=system.today()+64,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	
        
        Rights__c mpmRights2 = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= null,Rights_End_3__c=null, Rights_Start_4__c= null,Rights_End_4__c=null,
        /*Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,*/RecordTypeId=recordTypeIdMPM);
    insert mpmRights2;
	
	Rights__c titleRights2 = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= null,Rights_End_3__c=null, Rights_Start_4__c= null,Rights_End_4__c=null,
        /*Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,*/RecordTypeId=recordTypeIdVBOM);
    insert titleRights2;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	//mapRights.put(titleRights.Video_Version__c+'_'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
    mapRights.put(titleRights2.Video_Version__c+'_'+titleRights2.Rights_Group__c+'_'+titleRights2.Channel__c,titleRights2);
	//mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'_'+mpmRights.Channel__c,mpmRights);
    mapRights.put(mpmRights2.MPM__c+'_'+mpmRights2.Rights_Group__c+'_'+mpmRights2.Channel__c,mpmRights2);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case1(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
        
	
	test.Stoptest();
        
    }
    
    public static testmethod void methodRightsCheck4(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=null,
		Expiration_Date__c=system.today()+64,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	
        
        Rights__c mpmRights2 = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= null,Rights_End_3__c=null, Rights_Start_4__c= null,Rights_End_4__c=null,
        /*Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,*/RecordTypeId=recordTypeIdMPM);
    insert mpmRights2;
	
	Rights__c titleRights2 = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= null,Rights_End_3__c=null, Rights_Start_4__c= null,Rights_End_4__c=null,
        /*Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,*/RecordTypeId=recordTypeIdVBOM);
    insert titleRights2;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	//mapRights.put(titleRights.Video_Version__c+'_'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
    mapRights.put(titleRights2.Video_Version__c+'_'+titleRights2.Rights_Group__c+'_'+titleRights2.Channel__c,titleRights2);
	//mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'_'+mpmRights.Channel__c,mpmRights);
    mapRights.put(mpmRights2.MPM__c+'_'+mpmRights2.Rights_Group__c+'_'+mpmRights2.Channel__c,mpmRights2);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case3(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
        
	
	test.Stoptest();
        
    }
    
     public static testmethod void methodRightsCheck5(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=null,
		Expiration_Date__c=system.today()+64,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	
        
        Rights__c mpmRights2 = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+7,Rights_End_3__c=system.today()+9, Rights_Start_4__c= system.today()+11,Rights_End_4__c=system.today()+13,
        /*Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,*/RecordTypeId=recordTypeIdMPM);
    insert mpmRights2;
	
	Rights__c titleRights2 = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+7,Rights_End_3__c=system.today()+9, Rights_Start_4__c= system.today()+11,Rights_End_4__c=system.today()+13,
        /*Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,*/RecordTypeId=recordTypeIdVBOM);
    insert titleRights2;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	//mapRights.put(titleRights.Video_Version__c+'_'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
    mapRights.put(titleRights2.Video_Version__c+'_'+titleRights2.Rights_Group__c+'_'+titleRights2.Channel__c,titleRights2);
	//mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'_'+mpmRights.Channel__c,mpmRights);
    mapRights.put(mpmRights2.MPM__c+'_'+mpmRights2.Rights_Group__c+'_'+mpmRights2.Channel__c,mpmRights2);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case3(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
        
	
	test.Stoptest();
        
    }
    
    public static testmethod void methodRightsCheck6(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today()+8,
		Expiration_Date__c=null,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	
        
        Rights__c mpmRights2 = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+5,
        Rights_Start_3__c= system.today()+7,Rights_End_3__c=system.today()+9, Rights_Start_4__c= system.today()+11,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdMPM);
    insert mpmRights2;
	
	Rights__c titleRights2 = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+7,Rights_End_3__c=system.today()+9, Rights_Start_4__c= system.today()+11,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdVBOM);
    insert titleRights2;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	//mapRights.put(titleRights.Video_Version__c+'_'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
    mapRights.put(titleRights2.Video_Version__c+'_'+titleRights2.Rights_Group__c+'_'+titleRights2.Channel__c,titleRights2);
	//mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'_'+mpmRights.Channel__c,mpmRights);
    mapRights.put(mpmRights2.MPM__c+'_'+mpmRights2.Rights_Group__c+'_'+mpmRights2.Channel__c,mpmRights2);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case1(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
        
	
	test.Stoptest();
        
    }
    
    public static testmethod void methodRightsCheck7(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today()+12,
		Expiration_Date__c=null,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	
        
        Rights__c mpmRights2 = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+5,
        Rights_Start_3__c= system.today()+7,Rights_End_3__c=system.today()+9, Rights_Start_4__c= system.today()+11,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdMPM);
    insert mpmRights2;
	
	Rights__c titleRights2 = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+7,Rights_End_3__c=system.today()+9, Rights_Start_4__c= system.today()+11,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdVBOM);
    insert titleRights2;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	//mapRights.put(titleRights.Video_Version__c+'_'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
    mapRights.put(titleRights2.Video_Version__c+'_'+titleRights2.Rights_Group__c+'_'+titleRights2.Channel__c,titleRights2);
	//mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'_'+mpmRights.Channel__c,mpmRights);
    mapRights.put(mpmRights2.MPM__c+'_'+mpmRights2.Rights_Group__c+'_'+mpmRights2.Channel__c,mpmRights2);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case1(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
        
	
	test.Stoptest();
        
    }
    
    
    public static testmethod void methodRightsCheck8(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today()+12,
		Expiration_Date__c=null,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	
        
        Rights__c mpmRights2 = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+5,
        Rights_Start_3__c= system.today()+7,Rights_End_3__c=system.today()+9, Rights_Start_4__c= system.today()+11,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdMPM);
    insert mpmRights2;
	
	Rights__c titleRights2 = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+7,Rights_End_3__c=system.today()+9, Rights_Start_4__c= system.today()+11,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdVBOM);
    insert titleRights2;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	//mapRights.put(titleRights.Video_Version__c+'_'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
    mapRights.put(titleRights2.Video_Version__c+'_'+titleRights2.Rights_Group__c+'_'+titleRights2.Channel__c,titleRights2);
	//mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'_'+mpmRights.Channel__c,mpmRights);
    mapRights.put(mpmRights2.MPM__c+'_'+mpmRights2.Rights_Group__c+'_'+mpmRights2.Channel__c,mpmRights2);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case3(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
        
	
	test.Stoptest();
        
    }
    
    public static testmethod void methodRightsCheck9(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today()+16,
		Expiration_Date__c=null,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	
        
        Rights__c mpmRights2 = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+5,
        Rights_Start_3__c= system.today()+7,Rights_End_3__c=system.today()+9, Rights_Start_4__c= system.today()+11,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdMPM);
    insert mpmRights2;
	
	Rights__c titleRights2 = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+7,Rights_End_3__c=system.today()+9, Rights_Start_4__c= system.today()+11,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdVBOM);
    insert titleRights2;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	//mapRights.put(titleRights.Video_Version__c+'_'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
    mapRights.put(titleRights2.Video_Version__c+'_'+titleRights2.Rights_Group__c+'_'+titleRights2.Channel__c,titleRights2);
	//mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'_'+mpmRights.Channel__c,mpmRights);
    mapRights.put(mpmRights2.MPM__c+'_'+mpmRights2.Rights_Group__c+'_'+mpmRights2.Channel__c,mpmRights2);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case1(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
        
	
	test.Stoptest();
        
    }
    
    public static testmethod void methodRightsCheck10(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today()+16,
		Expiration_Date__c=null,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	
        
        Rights__c mpmRights2 = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+5,
        Rights_Start_3__c= system.today()+7,Rights_End_3__c=system.today()+9, Rights_Start_4__c= system.today()+11,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdMPM);
    insert mpmRights2;
	
	Rights__c titleRights2 = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+7,Rights_End_3__c=system.today()+9, Rights_Start_4__c= system.today()+11,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdVBOM);
    insert titleRights2;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	//mapRights.put(titleRights.Video_Version__c+'_'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
    mapRights.put(titleRights2.Video_Version__c+'_'+titleRights2.Rights_Group__c+'_'+titleRights2.Channel__c,titleRights2);
	//mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'_'+mpmRights.Channel__c,mpmRights);
    mapRights.put(mpmRights2.MPM__c+'_'+mpmRights2.Rights_Group__c+'_'+mpmRights2.Channel__c,mpmRights2);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case3(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
        
	
	test.Stoptest();
        
    }
    
    
    public static testmethod void methodRightsCheck3(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=null,
		Expiration_Date__c=system.today()+86,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES');       
	testTitleList.add(title1);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	/*Rights__c mpmRights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdMPM);
    insert mpmRights;
	
	Rights__c titleRights = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= system.today()+5,Rights_End_3__c=system.today()+8, Rights_Start_4__c= system.today()+10,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,RecordTypeId=recordTypeIdVBOM);
    insert titleRights;	*/
        
        Rights__c mpmRights2 = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= null,Rights_End_3__c=null, Rights_Start_4__c= null,Rights_End_4__c=null,
        /*Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,*/RecordTypeId=recordTypeIdMPM);
    insert mpmRights2;
	
	Rights__c titleRights2 = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+3,
        Rights_Start_3__c= null,Rights_End_3__c=null, Rights_Start_4__c= null,Rights_End_4__c=null,
        /*Rights_Start_5__c= system.today()+15,Rights_End_5__c=system.today()+19,*/RecordTypeId=recordTypeIdVBOM);
    insert titleRights2;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
	String titleId =title1.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	//mapRights.put(titleRights.Video_Version__c+'_'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
    mapRights.put(titleRights2.Video_Version__c+'_'+titleRights2.Rights_Group__c+'_'+titleRights2.Channel__c,titleRights2);
	//mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'_'+mpmRights.Channel__c,mpmRights);
    mapRights.put(mpmRights2.MPM__c+'_'+mpmRights2.Rights_Group__c+'_'+mpmRights2.Channel__c,mpmRights2);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case1(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
	
	test.Stoptest();
        
    }
    
    
    public static testmethod void methodRightsCheck2(){
	//FAD=null
	map<id, date> firstAvalTitleDateMap = new map<id, date>();
	map<id, date> expirationDateTitleMap = new map<id, date>();
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Language__c Language = new Language__c (Name='TestLanguage2',Language_Order__c = 1,Language_Code_2__c='TL');
    insert Language;
	
	Country__c con= new country__c(Name='Australia',Country_Code__c='Aus', Country_Code2__c='te',Channel__c='DTD;EST');
    insert con;
	
	Country__c con1 = new country__c(Name='Test1',Country_Code__c='Test', Country_Code2__c='tc');//,Channel__c='DTD;EST'
    insert con1;
        
    Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
    insert conGrp;
        
    Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=con.Id,Language__c=Language.Id,Level__c='2');
    insert langPrefTest;
        
    Country_Group_Country__c conGrpCon= new Country_Group_Country__c(Country__c=con.Id,Country_Group__c=conGrp.Id);
    insert conGrpCon;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	
	//~~~~~~~~~~~~MPM and Title~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~			
	Rights_Group__c childRightGroup = new Rights_Group__c(Name = 'en_AU',Country__c=con.id,Language__c=Language.id,Rights_Group__c = 'Australia');
    insert childRightGroup;
	
	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
	insert mpm;
        
    MPM__c mpm2 = new MPM__c(name='MPM record2',MPM_Number__c='0124');
	insert mpm2;
	
	list<title__c> testTitleList= new list<title__c>();
	Title__c title1 = new Title__c(Name='TestTitle12Sep1', Video_Version__c='0123456789',Formats__c='HD',First_Available_Date__c=system.today()+2,
		Expiration_Date__c=null,MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description',Digital_Planning__c='YES'); 
    Title__c title2 = new Title__c(Name='TestTitle12Sep2', Video_Version__c='0123456799',Formats__c='HD',First_Available_Date__c=system.today()+4,
		Expiration_Date__c=null,MPM__c = mpm2.id,Studio__c='BBC',Genre__c='ACTION',
		Short_Synopsis__c='short description2',Digital_Planning__c='YES'); 
	testTitleList.add(title1);
    testTitleList.add(title2);
	insert testTitleList;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	test.StartTest();
	
	Id recordTypeIdMPM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('MPM').getRecordTypeId();
	Id recordTypeIdVBOM = Schema.SObjectType.Rights__c.getRecordTypeInfosByName().get('VBOM').getRecordTypeId();
            
	Rights__c mpmRights = new Rights__c(Channel__c = 'EST',MPM__c = mpm2.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+5,
        Rights_Start_3__c= system.today()+7,Rights_End_3__c=system.today()+9, Rights_Start_4__c= system.today()+11,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= null,Rights_End_5__c=null,RecordTypeId=recordTypeIdMPM);
    insert mpmRights;
	
	Rights__c titleRights = new Rights__c(Channel__c = 'EST',Title__c = title2.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
         Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+5,
        Rights_Start_3__c= system.today()+7,Rights_End_3__c=system.today()+9, Rights_Start_4__c= system.today()+11,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= null,Rights_End_5__c=null,RecordTypeId=recordTypeIdVBOM);
    insert titleRights;	
        
        Rights__c mpmRights2 = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+5,
        Rights_Start_3__c= system.today()+7,Rights_End_3__c=system.today()+9, Rights_Start_4__c= system.today()+11,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= null,Rights_End_5__c=null,RecordTypeId=recordTypeIdMPM);
    insert mpmRights2;
	
	Rights__c titleRights2 = new Rights__c(Channel__c = 'EST',Title__c = title1.id, Rights_Group__c = childRightGroup.Rights_Group__c,Status__c='Confirmed', Source__c ='Cosmos',
        Rights_Start__c= system.today(),Rights_End__c=system.today()+1, Rights_Start_2__c= system.today()+3,Rights_End_2__c=system.today()+5,
        Rights_Start_3__c= system.today()+7,Rights_End_3__c=system.today()+9, Rights_Start_4__c= system.today()+11,Rights_End_4__c=system.today()+13,
        Rights_Start_5__c= null,Rights_End_5__c=null,RecordTypeId=recordTypeIdVBOM);
    insert titleRights2;	
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	//~~~~~~~~~~~Release plan and list~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Commercial_Avail__c  record = new Commercial_Avail__c();
	record.Title__c=title1.id;
	record.Country_Lookup__c=con.id;
	record.Languages__c=Language.id;
	record.Language_Type__c='Sub';
	record.Channel__c='EST';
	record.Format__c='HD';	
	record.Comments__c='None whatsoever';
	record.Exclusive_Date__c=system.today();
	record.start_Date__c=system.today()+5;
	record.end_date__c=	system.today()+10;
	record.Rights_End__c=system.today()+15;
        
    Commercial_Avail__c  record2 = new Commercial_Avail__c();
	record2.Title__c=title2.id;
	record2.Country_Lookup__c=con.id;
	record2.Languages__c=Language.id;
	record2.Language_Type__c='Sub';
	record2.Channel__c='EST';
	record2.Format__c='HD';	
	record2.Comments__c='None whatsoever2';
	record2.Exclusive_Date__c=system.today();
	record2.start_Date__c=system.today()+5;
	record2.end_date__c=	system.today()+10;
	record2.Rights_End__c=system.today()+15;
	
	List<Commercial_Avail__c> calist = new List<Commercial_Avail__c>();
	//1.calist.add(record);
	List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c> ();
	commercialAvailList.add(record);
    commercialAvailList.add(record2);
	 
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
				
	firstAvalTitleDateMap.put(title1.id,title1.First_Available_Date__c);
    firstAvalTitleDateMap.put(title2.id,title2.First_Available_Date__c);
	expirationDateTitleMap.put(title1.id,title1.Expiration_Date__c);
    expirationDateTitleMap.put(title2.id,title2.Expiration_Date__c);
	String titleId =title1.id; 
    String titleId2 =title2.id; 
	
	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
    WB_CreateReleasePlan_Controller ctrinstance = new WB_CreateReleasePlan_Controller(sc);
				
	WB_CreateReleasePlan_Controller.channelWrapper objChannelGrid = new WB_CreateReleasePlan_Controller.channelWrapper();
	
	//2.
	User userDetail=  [SELECT id, ProfileId, Profile.Name, UserType, Territory__c from User where id =: Userinfo.getUserId()];
    
	//3.
	Map<Id,Title__c> titleIdMap =  new Map<Id,Title__c>();
	titleIdMap.put(title1.Id,title1);
    titleIdMap.put(title2.Id,title2);
	//4.
	Map<Id,Country__c> CountryIdMap = new Map<Id,Country__c>();
	CountryIdMap.put(con.Id,con);
	//5.
	Map<Id,Language__c> languageIdMap= new Map<Id,Language__c>();
	languageIdMap.put(Language.id,Language);
	//6
	Integer countExcpetionRec=0;
	
	//7
    String ConfirmedPartialAllow='NR';
	
	//8
	Map<String,Rights__c> mapRights = new Map<String,Rights__c>();
	mapRights.put(titleRights.Video_Version__c+'_'+titleRights.Rights_Group__c+'_'+titleRights.Channel__c,titleRights);
    mapRights.put(titleRights2.Video_Version__c+'_'+titleRights2.Rights_Group__c+'_'+titleRights2.Channel__c,titleRights2);
	mapRights.put(mpmRights.MPM__c+'_'+mpmRights.Rights_Group__c+'_'+mpmRights.Channel__c,mpmRights);
    mapRights.put(mpmRights2.MPM__c+'_'+mpmRights2.Rights_Group__c+'_'+mpmRights2.Channel__c,mpmRights2);
    System.debug('KEYSET OF MAPRIGHTS'+mapRights.keyset());
	
	
	//9
	Map<String, String> mapRightsGrp = new Map<String, String>();
	//mapRightsGrp.put(rytGrp.Name, rytGrp.Rights_Group__c);
	mapRightsGrp.put('TL_te','Australia');
	
	
	WB_CreateReleasePLan_Helper.returnProcessedRP_case1(commercialAvailList,userDetail,titleIdMap, CountryIdMap, 
	languageIdMap,countExcpetionRec,ConfirmedPartialAllow, mapRights, mapRightsGrp);
	
	test.Stoptest();
        
    }
    
    
    
    
    
    
    
    
}