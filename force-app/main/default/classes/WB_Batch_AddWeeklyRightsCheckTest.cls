/*******************************************************************************************************************************************
* File Name     :   WB_Batch_AddWeeklyRightsCheckTest
* Description   :   Test class for batch WB_Batch_AddWeeklyRightsCheck
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     16 Feb.2016        CTS                ER-000401 : Created the class.
* 2.0     30 Nov 2016        Preeti Jha         Added required field for Rights Record and Changed DTD to EST for Channel in Rights Record.
********************************************************************************************************************************************/

@isTest
public class WB_Batch_AddWeeklyRightsCheckTest {

    public static Account acctGoogle;
    public static Title__c title;
    public static Country__c countryUSA;
    public static Country__c countryUK;
    public static Language__c languageEnglish;
    public static Language__c languagepl;
    public static Local_Title__c localTitle;
    public static Local_Title__c localTitle1;
    public static MPM__c mpm,mpm1;
    public static List<MPM__c> mpmList;
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
		mpm.generic__c = false;
		mpmInsertList.add(mpm);
		
		mpm1 = TestUtil.createMPM('2043788');
		mpm1.generic__c = true;
		mpmInsertList.add(mpm1);
        insert mpmInsertList;
		
        mpmList= new List<MPM__c>();
        mpmList.add(mpm);
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
        insert titleList;
        
        rightsList = new List<Rights__c>();
        Rights__c rights1 = TestUtil.initRights(mpm, 'USA', 'VODi');
        rights1.Rights_Start__c = date.today() - 12;
        rights1.Rights_End__c = date.today() + 12;
        rights1.RecordTypeId = RightsRecordTypeInfo.get('MPM').getRecordTypeId();
        rights1.MPM__c = mpm.Id;
        rights1.Source__c= 'Cosmos'; 
        rights1.Status__c = 'Confirmed';
        rights1.Rights_Group__c = 'USA';
        rights1.Channel__c = 'EST';    
        rightsList.add(rights1);
        
        Rights__c rights2 = TestUtil.initRights(mpm, 'USA', 'EST');
        rights2.Rights_Start__c = date.today() - 12;
        rights2.Rights_End__c = date.today() + 12;
        rights2.MPM__c = mpm.Id;
        rights2.Source__c= 'Cosmos'; 
        rights2.Status__c = 'Tentative';
        rights2.Rights_Group__c = 'USA';
        rights2.Channel__c = 'PPV';
        rightsList.add(rights2);
        
        Rights__c rights3 = TestUtil.initRights(mpm, 'USA', 'VODc');
        rights3.Rights_Start__c = date.today() - 1;
        rights3.Rights_End__c = date.today() + 1;
        rights3.Source__c= 'Cosmos'; 
        rights3.Status__c = 'Confirmed';
        rights3.Rights_Group__c = 'Bulgaria';
        rights3.Channel__c = 'EST';
        rightsList.add(rights3);
        
        Rights__c rights4 = new Rights__c();
        rights4.Title__c = title1.id;
        rights4.Rights_Start__c = date.today() - 1;
        rights4.Rights_End__c = date.today() + 1;
        rights4.Source__c= 'Cosmos'; 
        rights4.Status__c = 'Confirmed';
        rights4.Rights_Group__c = 'USA';
        rights4.Channel__c = 'Hotel';
        rights4.RecordTypeId = RightsRecordTypeInfo.get('VBOM').getRecordTypeId();
        rightsList.add(rights4);
		
		Rights__c rights5 = new Rights__c();
        rights5.Title__c = title3.id;
        rights5.Rights_Start__c = date.today() -9;
        rights5.Rights_End__c = date.today() -5;
        rights5.Source__c= 'Cosmos'; 
        rights5.Status__c = 'Confirmed';
        rights5.Rights_Group__c = 'USA';
        rights5.Channel__c = 'EST';
        rights5.RecordTypeId = RightsRecordTypeInfo.get('VBOM').getRecordTypeId();
        rightsList.add(rights5);
        insert rightsList;
        
        countryUSA = TestUtil.initCountry('USA', 'US', 'USD');
        countryUSA.Channel__c = 'EST; Hotel; PPV; VODc; VODi; Physical';
        insert countryUSA;
        
        languageEnglish = TestUtil.initLanguage('English', '', 1);
        insert languageEnglish;
        
        countryUK = TestUtil.initCountry('United Kingdom', 'GB', 'GBR');
        countryUK.Channel__c = 'EST; Hotel; PPV; VODc; VODi; Physical';
        insert countryUK;
        
        languagepl = TestUtil.initLanguage('Polish', '', 1);
        insert languagepl;
        
        rightsGroup = TestUtil.initRightsGroup(countryUSA, languageEnglish, 'USA');
        insert rightsGroup;
        
        localTitle = TestUtil.initLocalTitle(languageEnglish.Id, countryUSA.Id);
        localTitle.Rights_Group__c = 'USA';
        localTitle.Country__c =countryUSA.Id;
        localTitle.Language__c = languageEnglish.Id;
        insert localTitle;
        
        localTitle1 = TestUtil.initLocalTitle(languagepl.Id, countryUK.Id);
        localTitle1.Rights_Group__c = 'Canada';
        localTitle1.Country__c =countryUK.Id;
        localTitle1.Language__c = languagepl.Id;
        insert localTitle1;
        
        releasePlanList = new List<Commercial_Avail__c>();
        Commercial_Avail__c CommercialAvail1 = TestUtil.initReleasePlan(titleList[0].Id, localTitle.Id, countryUSA.Id, languageEnglish.Id);
        CommercialAvail1.Start_Date__c = date.today() - 5;
        CommercialAvail1.End_Date__c = date.today() -3;
        CommercialAvail1.Exclusive_Date__c = date.today() - 15;
        CommercialAvail1.Rights_End__c = date.today() + 15;
        CommercialAvail1.Rights_ID__c = rightsList[0].id;
        CommercialAvail1.Channel__c = 'EST';
        releasePlanList.add(CommercialAvail1);
        Commercial_Avail__c CommercialAvail2 = TestUtil.initReleasePlan(titleList[0].Id, localTitle.Id, countryUSA.Id, languageEnglish.Id);
        CommercialAvail2.Start_Date__c = date.today() - 2;
        CommercialAvail2.End_Date__c = date.today();
        CommercialAvail1.Exclusive_Date__c = date.today() - 15;
        CommercialAvail1.Rights_End__c = date.today() + 15;
        //CommercialAvail2.Rights_ID__c = rightsList[1].id;
        CommercialAvail2.Rights_ID__c = null;

        CommercialAvail2.Channel__c = 'EST';
        releasePlanList.add(CommercialAvail2);
        Commercial_Avail__c CommercialAvail3 = TestUtil.initReleasePlan(titleList[1].Id, localTitle.Id, countryUSA.Id, languageEnglish.Id);
        CommercialAvail3.Start_Date__c = date.today();
        CommercialAvail3.End_Date__c = date.today() + 2;
        CommercialAvail1.Exclusive_Date__c = date.today() - 15;
        CommercialAvail1.Rights_End__c = date.today() + 15;
        //CommercialAvail3.Rights_ID__c = rightsList[0].id;
        CommercialAvail3.Channel__c = 'VODc';
        releasePlanList.add(CommercialAvail3);
        
        
        //Added by Milon
        Commercial_Avail__c CommercialAvail4 = TestUtil.initReleasePlan(titleList[1].Id, localTitle1.Id, countryUK.Id, languagepl.Id);
        CommercialAvail4.Start_Date__c = date.today();
        CommercialAvail4.End_Date__c = date.today() + 2;
        CommercialAvail1.Exclusive_Date__c = date.today() - 15;
        CommercialAvail1.Rights_End__c = date.today() + 15;
        //CommercialAvail3.Rights_ID__c = rightsList[0].id;
        CommercialAvail4.Channel__c = 'VODc';
		
		//new code**start
        Commercial_Avail__c CommercialAvail5 = TestUtil.initReleasePlan(titleList[1].Id, localTitle1.Id, countryUK.Id, languagepl.Id);
        CommercialAvail5.Start_Date__c = date.today();
        CommercialAvail5.End_Date__c = date.today() + 2;
        CommercialAvail5.Exclusive_Date__c = date.today() - 15;
        CommercialAvail5.Rights_End__c = date.today() + 15;
        CommercialAvail5.Rights_ID__c = rights2.id;
        CommercialAvail5.Channel__c = 'PPV';
		CommercialAvail5.Title__c = title3.id;
		CommercialAvail5.Local_Title__c = localTitle.id;
		CommercialAvail5.Rights_Group__c = rightsGroup.id;
		CommercialAvail5.Country_Lookup__c =countryUSA.Id;
		CommercialAvail5.Languages__c =	languageEnglish.Id;
        releasePlanList.add(CommercialAvail5);
		
		
		Commercial_Avail__c CommercialAvail6 = TestUtil.initReleasePlan(titleList[1].Id, localTitle1.Id, countryUK.Id, languagepl.Id);
        CommercialAvail6.Start_Date__c = date.today();
        CommercialAvail6.End_Date__c = date.today() + 2;
        CommercialAvail6.Exclusive_Date__c = date.today() - 15;
        CommercialAvail6.Rights_End__c = date.today() + 15;
        CommercialAvail6.Rights_ID__c = rights4.id;
        CommercialAvail6.Channel__c = 'EST';
		CommercialAvail6.Title__c = title2.id;
		CommercialAvail6.Local_Title__c = localTitle.id;
		CommercialAvail6.Rights_Group__c = rightsGroup.id;
		CommercialAvail6.Country_Lookup__c =countryUSA.Id;
		CommercialAvail6.Languages__c =	languageEnglish.Id;//Polish 
		releasePlanList.add(CommercialAvail6);
		
		Commercial_Avail__c CommercialAvail7 = TestUtil.initReleasePlan(titleList[1].Id, localTitle1.Id, countryUK.Id, languagepl.Id);
        CommercialAvail7.Start_Date__c = date.today();
        CommercialAvail7.End_Date__c = date.today() +2;
        CommercialAvail7.Exclusive_Date__c = date.today()-15;
        CommercialAvail7.Rights_End__c = date.today()+15;
        CommercialAvail7.Rights_ID__c = rights5.id;
        CommercialAvail7.Channel__c = 'EST';
		CommercialAvail7.Title__c = title3.id;
		CommercialAvail7.Local_Title__c = localTitle.id;
		CommercialAvail7.Rights_Group__c = rightsGroup.id;
		CommercialAvail7.Country_Lookup__c =countryUSA.Id;
		CommercialAvail7.Languages__c =	languageEnglish.Id;//Polish 
		releasePlanList.add(CommercialAvail7);
       //new code**end
	   
        
        TestUtil.isRunning_WB_Batch_AddWeeklyRightsCheck = true; 
        insert releasePlanList;
        
        List<Commercial_Avail__c> lstReleasePlan1 = [Select Id, Rights_ID__c, Start_Date__c, End_Date__c, Channel__c, Country_Lookup__c, Languages__c from Commercial_Avail__c];
        system.debug('------lstReleasePlan1-------'+lstReleasePlan1);
    }
    
    
    static testMethod void testRightsWithChannel() {
        
        setUpdata();
        Test.startTest();
        WB_Batch_AddWeeklyRightsCheck b = new WB_Batch_AddWeeklyRightsCheck();
        database.executeBatch(b,10);
        /*Database.BatchableContext bc;
        b.start(bc);
        b.execute(bc,mpmList);
        b.finish(bc);
        Test.stopTest();*/
        
        List<Commercial_Avail__c> lstReleasePlan = [Select Id, Rights_ID__c from Commercial_Avail__c where Id =: releasePlanList[0].Id];
        system.assertNotEquals(null, lstReleasePlan[0].Rights_ID__c);
    }

    static testMethod void testRightsWithoutChannel() {
        
        setUpdata();
        List<Rights__c> lstRight = [Select Id, Channel__c from Rights__c];
        lstRight[0].Channel__c = 'EST';
        update lstRight[0];
        
        Test.startTest();
        WB_Batch_AddWeeklyRightsCheck b = new WB_Batch_AddWeeklyRightsCheck();
        database.executeBatch(b,10);
        /*Database.BatchableContext bc;
        b.start(bc);
        b.execute(bc,mpmList);
        b.finish(bc);
        Test.stopTest();*/
        
        List<Commercial_Avail__c> lstReleasePlan = [Select Id, Rights_ID__c from Commercial_Avail__c where Id =: releasePlanList[0].Id];
       // system.assertNotEquals(null, lstReleasePlan[0].Rights_ID__c);
    }
    
    static testMethod void testRightsWithoutRightsGroup() {
        
        setUpdata();
        List<Rights__c> lstRight = [Select Id, Rights_Group__c, Channel__c from Rights__c];
        lstRight[0].Rights_Group__c = 'USA';
        lstRight[1].Rights_Group__c = 'USA';
        lstRight[1].Rights_Start__c = date.today() - 25;
        update lstRight;
        
        Test.startTest();
        WB_Batch_AddWeeklyRightsCheck b = new WB_Batch_AddWeeklyRightsCheck();
        database.executeBatch(b,10);
        /*Database.BatchableContext bc;
        b.start(bc);
        b.execute(bc,mpmList);
        b.finish(bc);
        Test.stopTest();*/
        
        List<Commercial_Avail__c> lstReleasePlan = [Select Id, Rights_ID__c from Commercial_Avail__c where Id =: releasePlanList[0].Id];
        //system.assertNotEquals(null, lstReleasePlan[0].Rights_ID__c);
    }
    
    static testMethod void testRightsWithoutRightsGroupAndChannel() {
        
        setUpdata();
        List<Rights__c> lstRight = [Select Id, Rights_Group__c, Channel__c from Rights__c];
        lstRight[0].Rights_Group__c = 'USA';
        lstRight[0].Channel__c = 'EST';
        lstRight[1].Rights_Group__c ='USA';
        lstRight[1].Channel__c = 'PPV';
        lstRight[1].Rights_Start__c = date.today() - 25;
        update lstRight;
        
        Test.startTest();
        WB_Batch_AddWeeklyRightsCheck b = new WB_Batch_AddWeeklyRightsCheck();
        database.executeBatch(b,10);
        /*Database.BatchableContext bc;
        b.start(bc);
        b.execute(bc,mpmList);
        b.finish(bc);
        Test.stopTest();*/
        
        List<Commercial_Avail__c> lstReleasePlan = [Select Id, Rights_ID__c from Commercial_Avail__c where Id =: releasePlanList[0].Id];
        //system.assertNotEquals(null, lstReleasePlan[0].Rights_ID__c);
    }
    
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    static testmethod void TestSchedulableClass() {
        
        Test.startTest();
    
        // Schedule the test job 
        String jobId = System.schedule('Test Add Weekly Check', CRON_EXP, new WB_Batch_AddWeeklyRightsCheck());
        
        // Get the information from the CronTrigger API object 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
    
        // Verify the expressions are the same 
        System.assertEquals(CRON_EXP, ct.CronExpression);
    
        // Verify the job has not run 
        System.assertEquals(0, ct.TimesTriggered);
    
        // Verify the next time the job will run 
        System.assertEquals('2022-03-15 00:00:00',  String.valueOf(ct.NextFireTime));
          
        Test.stopTest();
    }
    
    static testMethod void testRightsBatch1() {
        
        setUpdata();
        Test.startTest();
        releasePlanList[0].Exclusive_Date__c = date.today() + 12;
        releasePlanList[0].Rights_End__c = date.today() - 11;
        releasePlanList[1].Exclusive_Date__c = date.today() + 12;
        releasePlanList[1].Rights_End__c = date.today() - 11;
        releasePlanList[2].Exclusive_Date__c = date.today() + 2;
        releasePlanList[2].Rights_End__c = date.today() - 2;
        update releasePlanList;
        WB_Batch_AddWeeklyRightsCheck b = new WB_Batch_AddWeeklyRightsCheck();
        database.executeBatch(b,10);
        /*
        Database.BatchableContext bc;
        b.start(bc);
        b.execute(bc,mpmList);
        b.finish(bc);
        Test.stopTest();
        */
        List<Commercial_Avail__c> lstReleasePlan = [Select Id, Rights_ID__c from Commercial_Avail__c where Id =: releasePlanList[0].Id];
        system.assertNotEquals(null, lstReleasePlan[0].Rights_ID__c);
    }
    
    static testMethod void testRightsBatch2() {
        
        setUpdata();
        Test.startTest();
        WB_Batch_AddWeeklyRightsCheck b = new WB_Batch_AddWeeklyRightsCheck();
        database.executeBatch(b,10);
        /*Database.BatchableContext bc;
        b.start(bc);
        b.execute(bc,mpmList);
        b.finish(bc);
        Test.stopTest();*/
        
        List<Commercial_Avail__c> lstReleasePlan = [Select Id, Rights_ID__c from Commercial_Avail__c where Id =: releasePlanList[0].Id];
        system.assertNotEquals(null, lstReleasePlan[0].Rights_ID__c);
    }
    
}