@isTest 
private class WB_UpdateRightInfo_Test{
    public static Account acctGoogle;
    public static Title__c title;
    public static Country__c countryUSA;
    public static Country__c countryUK;
    public static Language__c languageEnglish;
    public static Language__c languagepl;
    public static Local_Title__c localTitle;
    public static Local_Title__c localTitle1;
    public static MPM__c mpm,mpm1;
    public static Rights__c rights;
    public static Rights_Group__c rightsGroup;
    
    public static List<Title__c> titleList;
    public static List<Rights__c> rightsList;
    public static List<Commercial_Avail__c> releasePlanList;
    
    Map<String,Schema.RecordTypeInfo> RightsRecordTypeInfo = Schema.SObjectType.Rights__c.getRecordTypeInfosByName(); 
    
    static void setUpdata() {
        acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        List<MPM__c> mpmInsertList = new List<MPM__c>();
		mpm = TestUtil.createMPM('2043705');
		mpm.Name = '2043705';
		mpm.generic__c = false;
		mpmInsertList.add(mpm);
		
		mpm1 = TestUtil.createMPM('2043788');
		mpm1.Name = '2043705';
		mpm1.generic__c = true;
		mpmInsertList.add(mpm1);
        insert mpmInsertList;
		
        Map<String,Schema.RecordTypeInfo> RightsRecordTypeInfo = Schema.SObjectType.Rights__c.getRecordTypeInfosByName(); 

        titleList = new List<Title__c>();
        Title__c title1 = TestUtil.initTitle('Batman Begins', '6000025001');
        title1.MPM__c = mpm.Id;
        title1.Formats__c='SD';
        titleList.add(title1);
        
        Title__c title2 = TestUtil.initTitle('Dark Night', '6000025002');
        title2.MPM__c = mpm.Id;
        title2.Formats__c='SD';
        titleList.add(title2);
        
		Title__c title3 = TestUtil.initTitle('Game of Thrones', '6000025003');
        title3.MPM__c = mpm1.Id;
        title3.Formats__c='SD';
        titleList.add(title3);
        
        Title__c title4 = TestUtil.initTitle('Those Who Wish Me Dead', '6000025004');
        title4.MPM__c = mpm1.Id;
        title4.Formats__c='SD';
        titleList.add(title4);
        insert titleList;
        
        rightsList = new List<Rights__c>();
        Rights__c rights1 = TestUtil.initRights(mpm, 'USA', 'EST');
        rights1.Rights_Start__c = date.today() - 12;
        rights1.Rights_End__c = date.today() + 12;
        rights1.Rights_Start_2__c = System.today()+15;
        rights1.Rights_End_2__c = System.today()+20;
        rights1.Rights_Start_3__c = System.today()+25;
        rights1.Rights_End_3__c = System.today()+30;
        rights1.Rights_Start_4__c = System.today()+35;
        rights1.Rights_End_4__c = System.today()+40;
        rights1.Rights_Start_5__c = System.today()+45;
        rights1.Rights_End_5__c = System.today()+50;
        rights1.RecordTypeId = RightsRecordTypeInfo.get('MPM').getRecordTypeId();
        rights1.MPM__c = mpm.Id;
        rights1.Source__c= 'Cosmos'; 
        rights1.Status__c = 'Confirmed';
        rights1.Rights_Group__c = 'USA';
        rights1.Channel__c = 'EST';    
        rightsList.add(rights1);
        
        Rights__c rights2 = TestUtil.initRights(mpm, 'USA', 'VODi');
        rights2.RecordTypeId = RightsRecordTypeInfo.get('MPM').getRecordTypeId();
        rights2.Rights_Start__c = null;
        rights2.Rights_End__c = null;
        rights2.MPM__c = mpm.Id;
        rights2.Source__c= 'Cosmos'; 
        rights2.Status__c = 'TBA';
        rights2.Rights_Group__c = 'USA';
        rights2.Channel__c = 'VODi';
        rightsList.add(rights2);
        
        Rights__c rights3 = TestUtil.initRights(mpm, 'USA', 'EST');
        rights3.RecordTypeId = RightsRecordTypeInfo.get('VBOM').getRecordTypeId();
        rights3.MPM__c = null;
        rights3.Title__c = title3.Id;
        rights3.Rights_Start__c = date.today() - 12;
        rights3.Rights_End__c = date.today() + 12;
        rights3.Rights_Start_2__c = System.today()+15;
        rights3.Rights_End_2__c = System.today()+20;
        rights3.Rights_Start_3__c = System.today()+25;
        rights3.Rights_End_3__c = System.today()+30;
        rights3.Rights_Start_4__c = System.today()+35;
        rights3.Rights_End_4__c = System.today()+40;
        rights3.Rights_Start_5__c = System.today()+45;
        rights3.Rights_End_5__c = System.today()+50;
        rights3.Source__c= 'Cosmos'; 
        rights3.Status__c = 'Confirmed';
        rights3.Rights_Group__c = 'USA';
        rights3.Channel__c = 'EST';
        rightsList.add(rights3);
        
        Rights__c rights4 = new Rights__c();
        rights4.RecordTypeId = RightsRecordTypeInfo.get('VBOM').getRecordTypeId();
        rights4.Title__c = title3.id;
        rights4.MPM__c = null;
        rights4.Rights_Start__c = null;
        rights4.Rights_End__c = null;
        rights4.Source__c= 'Cosmos'; 
        rights4.Status__c = 'TBA';
        rights4.Rights_Group__c = 'USA';
        rights4.Channel__c = 'VODi';
        rightsList.add(rights4);
		
		Rights__c rights5 = TestUtil.initRights(mpm, 'USA', 'EST');
        rights5.RecordTypeId = RightsRecordTypeInfo.get('VBOM').getRecordTypeId();
        rights5.MPM__c = null;
        rights5.Title__c = title4.Id;
        rights5.Rights_Start__c = date.today() - 1;
        rights5.Rights_End__c = date.today() + 1;
        rights5.Source__c= 'Cosmos'; 
        rights5.Status__c = 'Confirmed';
        rights5.Rights_Group__c = 'USA';
        rights5.Channel__c = 'EST';
        rightsList.add(rights5);
        
        Rights__c rights6 = new Rights__c();
        rights6.RecordTypeId = RightsRecordTypeInfo.get('VBOM').getRecordTypeId();
        rights6.Title__c = title4.id;
        rights6.MPM__c = null;
        rights6.Rights_Start__c = date.today() - 1;
        rights6.Rights_End__c = date.today() + 1;
        rights6.Source__c= 'Cosmos'; 
        rights6.Status__c = 'Confirmed';
        rights6.Rights_Group__c = 'USA';
        rights6.Channel__c = 'VODi';
        rightsList.add(rights6);
        insert rightsList;
        
        countryUSA = TestUtil.initCountry('USA', 'US', 'USD');
        countryUSA.Channel__c = 'EST; Hotel; PPV; VODc; VODi; Physical';
        insert countryUSA;
        
        languageEnglish = TestUtil.initLanguage('English', '', 1);
        insert languageEnglish;
        
        rightsGroup = TestUtil.initRightsGroup(countryUSA, languageEnglish, 'USA');
        insert rightsGroup;
        
        releasePlanList = new List<Commercial_Avail__c>();
        Commercial_Avail__c CommercialAvail1 = new Commercial_Avail__c(title__c=title1.Id,Channel__c='EST',format__c='SD',Country_Lookup__c=countryUSA.Id,Languages__c=languageEnglish.Id, Language_Type__c='Dub');
        CommercialAvail1.Start_Date__c = date.today() - 5;
        CommercialAvail1.End_Date__c = date.today() + 5;
        CommercialAvail1.Exclusive_Date__c = date.today() - 12;
        CommercialAvail1.Rights_End__c = date.today() + 12;
        releasePlanList.add(CommercialAvail1);
        
        Commercial_Avail__c CommercialAvail2 = new Commercial_Avail__c(title__c=title1.Id,Channel__c='EST',format__c='SD',Country_Lookup__c=countryUSA.Id,Languages__c=languageEnglish.Id, Language_Type__c='Dub');
        CommercialAvail2.Start_Date__c = date.today() + 55;
        CommercialAvail2.End_Date__c = date.today() + 65;
        CommercialAvail2.Exclusive_Date__c = date.today() + 55;
        CommercialAvail2.Rights_End__c = date.today() + 65;
        releasePlanList.add(CommercialAvail2);
        
        Commercial_Avail__c CommercialAvail3 = new Commercial_Avail__c(title__c=title2.Id,Channel__c='VODi',format__c='SD',Country_Lookup__c=countryUSA.Id,Languages__c=languageEnglish.Id, Language_Type__c='Dub');
        CommercialAvail3.Start_Date__c = date.today() - 5;
        CommercialAvail3.End_Date__c = date.today() + 5;
        CommercialAvail3.Exclusive_Date__c = date.today() - 12;
        CommercialAvail3.Rights_End__c = date.today() + 12;
        releasePlanList.add(CommercialAvail3);
        
        Commercial_Avail__c CommercialAvail4 = new Commercial_Avail__c(title__c=title3.Id,Channel__c='EST',format__c='SD',Country_Lookup__c=countryUSA.Id,Languages__c=languageEnglish.Id, Language_Type__c='Dub');
        CommercialAvail4.Start_Date__c = date.today() - 5;
        CommercialAvail4.End_Date__c = date.today() + 5;
        CommercialAvail4.Exclusive_Date__c = date.today() - 12;
        CommercialAvail4.Rights_End__c = date.today() + 12;
        releasePlanList.add(CommercialAvail4);
        
        Commercial_Avail__c CommercialAvail5 = new Commercial_Avail__c(title__c=title3.Id,Channel__c='VODi',format__c='SD',Country_Lookup__c=countryUSA.Id,Languages__c=languageEnglish.Id, Language_Type__c='Dub');
        CommercialAvail5.Start_Date__c = date.today() - 5;
        CommercialAvail5.End_Date__c = date.today() + 5;
        CommercialAvail5.Exclusive_Date__c = date.today() - 12;
        CommercialAvail5.Rights_End__c = date.today() + 12;
        releasePlanList.add(CommercialAvail5);
        
        Commercial_Avail__c CommercialAvail6 = new Commercial_Avail__c(title__c=title4.Id,Channel__c='EST',format__c='SD',Country_Lookup__c=countryUSA.Id,Languages__c=languageEnglish.Id, Language_Type__c='Dub');
        CommercialAvail6.Start_Date__c = date.today() + 5;
        CommercialAvail6.End_Date__c = date.today() + 15;
        CommercialAvail6.Exclusive_Date__c = date.today() + 5;
        CommercialAvail6.Rights_End__c = date.today() + 15;
        releasePlanList.add(CommercialAvail6);
        
        Commercial_Avail__c CommercialAvail7 = new Commercial_Avail__c(title__c=title4.Id,Channel__c='VODi',format__c='SD',Country_Lookup__c=countryUSA.Id,Languages__c=languageEnglish.Id, Language_Type__c='Dub');
        CommercialAvail7.Start_Date__c = date.today() + 5;
        CommercialAvail7.End_Date__c = date.today() + 5;
        CommercialAvail7.Exclusive_Date__c = date.today() + 5;
        CommercialAvail7.Rights_End__c = date.today() + 15;
        releasePlanList.add(CommercialAvail7);
        
        TestUtil.isRunning_WB_Batch_AddWeeklyRightsCheck = true; 
        insert releasePlanList;
        TestUtil.isRunning_WB_Batch_AddWeeklyRightsCheck = false; 
    } 
    
    static testMethod void testRightsMappingToRP() {
        
        setUpdata();
        
        for(Commercial_Avail__c re : [Select Id, Rights_ID__c from Commercial_Avail__c where Id IN :releasePlanList]){
            system.assertEquals(null, re.Rights_ID__c,'Initially Rigths not assigned to RPs');
        }
        
        Test.startTest();
        update releasePlanList;
        Test.stopTest();
        
        for(Commercial_Avail__c re : [Select Id, Rights_ID__c from Commercial_Avail__c where Id IN :releasePlanList]){
            system.assertNotEquals(null, re.Rights_ID__c,'Correct Rights assigned to RPs');
        }
    }
    
    static testMethod void testRightsRemoveMappingToRP() {
        
        setUpdata();
        Test.startTest();
        
        update releasePlanList;
        for(Commercial_Avail__c re : [Select Id, Rights_ID__c from Commercial_Avail__c where Id IN :releasePlanList]){
            system.assertNotEquals(null, re.Rights_ID__c,'Correct Rights assigned to RPs');
        }
        
        Set<Id> rpIDs = new Set<Id>{releasePlanList[2].Id,releasePlanList[3].ID};
        rightsList[1].Channel__c = 'Physical';
        rightsList[2].Channel__c = 'Physical';
        update rightsList;
        update releasePlanList;
        
        Test.stopTest();
        
        for(Commercial_Avail__c re : [Select Id, Rights_ID__c from Commercial_Avail__c where Id IN :rpIDs]){
            system.assertEquals(null, re.Rights_ID__c,'System has removed wrong Rights linked to RPs');
        }
    }
}