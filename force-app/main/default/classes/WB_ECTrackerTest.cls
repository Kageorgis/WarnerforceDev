@isTest
public class WB_ECTrackerTest {

    @testSetup static void setup() {
        MPM__c unexplodedmpmRec = new MPM__c(
            Name = '2013446',
            MPM_Number__c = '2013446',
	    MPM_Short_Desc__c = 'WB Unexploded',
            Status__c = 'Released/Del'
            );
	insert unexplodedmpmRec;

        MPM__c filmmpmRec = new MPM__c(
            Name = '2013447',
            MPM_Number__c = '2013447',
	    MPM_Short_Desc__c = 'Film MPM',
            Status__c = 'Released/Del'
            );
        insert filmmpmRec;
	
        MPM__c tvmpmRec = new MPM__c(
            Name = '2013448',
            MPM_Number__c = '2013448',
	    MPM_Short_Desc__c = 'TV MPM',
            Status__c = 'Released/Del'
            );
        insert tvmpmRec;

        Title__c filmTitleRec = new Title__c(
            Name = 'Film Title',
            Video_Version__c = '6000010001',
	    Content_Type__c = 'Feature',
            MPM__c = filmmpmRec.id,
	    Digital_Planning__c = 'Yes',
        Formats__c = 'SD',
	    Synopsis__c = 'Long Synopsis Film Title',
	    Short_Synopsis__c = 'Short Synopsis Film Title'
            );
        insert filmTitleRec;

        Title__c TVTitleRec = new Title__c(
            Name = 'TV Title',
            Video_Version__c = '6000010002',
	    Content_Type__c = 'Season',
            MPM__c = tvmpmRec.id,
	    Digital_Planning__c = 'Yes',
        Formats__c = 'SD',
	    Synopsis__c = 'Long Synopsis TV Title',
	    Short_Synopsis__c = 'Short Synopsis TV Title'
            );
        insert TVTitleRec;

	Country__c ctry = new Country__c(
	    Name = 'USA',
	    Country_Code__c = 'USA',
	    Country_Code2__c = 'US'
	    );
	insert ctry;

	Language__c lang = new Language__c(
	    Name = 'English',
	    Language_Order__c = 1
	    );
	    insert lang;

        Local_Title__c filmLDRec = new Local_Title__c(
            Name = 'Film Local Data',
	    Title__c = filmTitleRec.id,
            Country__c = ctry.id,
	    Language__c = lang.id
            );
            insert filmLDRec;

        Local_Title__c TVLDRec = new Local_Title__c(
            Name = 'TV Local Data',
	    Title__c = TVTitleRec.id,
            Country__c = ctry.id,
	    Language__c = lang.id
            );
            insert TVLDRec;
    }

    @isTest static void testMethod1() {
	MPM__c filmmpmRec = [SELECT ID from MPM__c WHERE MPM_Number__c = '2013447' LIMIT 1];
	MPM__c tvmpmRec = [SELECT ID from MPM__c WHERE MPM_Number__c = '2013448' LIMIT 1];
    RecordType rtfilm = [select id,Name from RecordType where SobjectType='EC_Tracker__c' and Name='TNR TCAT Record Type' Limit 1];
	RecordType rttv = [select id,Name from RecordType where SobjectType='EC_Tracker__c' and Name='Franchise Record Type' Limit 1];
	EC_Tracker__c filmtracker = new EC_Tracker__c(
        Name = 'Film EC Tracker',
	    RecordTypeId = rtfilm.id,
	    MPM__c = filmmpmRec.id,
	    Release_Type__c = 'TNR'
	    );
        insert filmtracker;   
        EC_Tracker__c filmtracker2 = [SELECT Title__c, Local_Data__c, Title__r.Video_Version__c, Release_Type__c from EC_Tracker__c where ID = :filmtracker.id];
        System.assertEquals(filmtracker2.Title__r.Video_Version__c,'6000010001');
	EC_Tracker__c tvtracker = new EC_Tracker__c(
        Name = 'TV EC Tracker',
	    RecordTypeId = rttv.id,
	    MPM__c = tvmpmRec.id,
	    Release_Type__c = 'Franchise - TV'
	    );
        insert tvtracker;    
        EC_Tracker__c tvtracker2 = [SELECT Title__c, Local_Data__c, Title__r.Video_Version__c, Release_Type__c from EC_Tracker__c where ID = :tvtracker.id];
        System.assertEquals(tvtracker2.Title__r.Video_Version__c,'6000010002');
        tvtracker.Title__c = filmtracker2.Title__c;
        update tvtracker;
        EC_Tracker__c tvtracker3 = [SELECT Title__c, Local_Data__c, Title__r.Video_Version__c, Release_Type__c from EC_Tracker__c where ID = :tvtracker.id];
        System.assertNotEquals(tvtracker3.Local_Data__c,null);
    }
}