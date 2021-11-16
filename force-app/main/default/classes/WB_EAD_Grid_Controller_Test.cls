/**
* @author: Cognizant Technology Solutions 
* @Test Class name :WB_EAD_Grid_Controller_Test
* @discription: test class to verify the functionality of EAD create/update grid.
* @Related class: WB_EAD_Grid_Controller
* 
*/
@isTest(seeAllData=false)
public with sharing class WB_EAD_Grid_Controller_Test {
    static MPM__c mpm1;
    static Title__c title1;
    static Country__c country;
    static Local_Title__c localTitle;
    static Earliest_Avail_Date__c ead;
    static Commercial_Avail__c CommercialAvail;
    static Earliest_Avail_Date__c eadRecord;
    
    static void setupData(){
        mpm1 = TestUtil.createMPM('123456');
        mpm1.MPM_Short_Desc__c = 'Test MPM record';
        mpm1.Name = 'Test MPM';
        insert mpm1;
        system.assertEquals('123456',mpm1.MPM_Number__c);
        
        title1 = TestUtil.initTitle('Test Title','987654'); 
        title1.MPM__c = mpm1.Id;
        title1.Formats__c = 'HD';
        insert title1;
        system.assertEquals('987654',title1.Video_Version__c);
        
        country = TestUtil.initCountry('USA','US','US');
        country.Territory__c ='USA';
        insert country;
        system.assertEquals('US',country.Country_Code2__c);
        
        Language__c ctlanguage = TestUtil.initLanguage('English','En',1);
        insert ctlanguage;
        system.assertEquals('En',ctlanguage.Language_Code_2__c);
        
        localTitle = TestUtil.initLocalTitle(ctlanguage.Id,country.Id);
        insert localTitle;
        
        CommercialAvail = TestUtil.initReleasePlan(title1.id,localTitle.id,country.id,ctlanguage.id);
        insert CommercialAvail;
        system.assertEquals('HD',CommercialAvail.Format__c);
        
        eadRecord = TestUtil.createEADRecord(title1.id,country.id);
        insert eadRecord;
        system.assertEquals('HD',eadRecord.Format__c);
        
    }
    
    static testMethod void unitTestGetEADRecordDataByVideoVersion() {
        setupData();

        test.startTest();
        Earliest_Avail_Date__c eadRec = [select Id,Video_Version__c from Earliest_Avail_Date__c];
        WB_EAD_Grid_Controller gridController = new WB_EAD_Grid_Controller();
        PageReference pageRef = Page.WB_EarliestAvailDate_Grid;
        Test.setCurrentPage(pageRef);
        
        gridController.getUserDateFormat();
        gridController.getUserLocaleLowerCase();
        gridController.getChunkSizeForEADRecords();
        gridController.getUserLocaleLanguage();
        gridController.getUserLocale();
        
        WB_ObjectsWarpper.SearchFilters  wrapper = new WB_ObjectsWarpper.SearchFilters();
        list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper> searchResultWrapper = new list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper>();
        wrapper.EADVideoVersion = '987654';

        searchResultWrapper = WB_EAD_Grid_Controller.getEADRecords(wrapper);
        test.stopTest();
        system.assertEquals(eadRec.Video_Version__c, searchResultWrapper[0].videoVersion);
        
    }
    static testMethod void unitTestGetEADRecordDataByMPM() {
        setupData();

        test.startTest();
        Earliest_Avail_Date__c eadRec = [select Id,Video_Version__c,MPM__c from Earliest_Avail_Date__c];
        WB_EAD_Grid_Controller gridController = new WB_EAD_Grid_Controller();
        PageReference pageRef = Page.WB_EarliestAvailDate_Grid;
        Test.setCurrentPage(pageRef);

        WB_ObjectsWarpper.SearchFilters  wrapper = new WB_ObjectsWarpper.SearchFilters();
        list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper> searchResultWrapper = new list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper>();
        wrapper.EADMPM = 'Test MPM';

        searchResultWrapper = WB_EAD_Grid_Controller.getEADRecords(wrapper);
        test.stopTest();
        system.assertEquals(eadRec.MPM__c, searchResultWrapper[0].MPM);
        
    }
    static testMethod void unitTestGetEADRecordDataByTitle() {
        setupData();

        test.startTest();
        Earliest_Avail_Date__c eadRec = [select Id,Video_Version__c,MPM__c,Title__r.name from Earliest_Avail_Date__c];
        WB_EAD_Grid_Controller gridController = new WB_EAD_Grid_Controller();
        PageReference pageRef = Page.WB_EarliestAvailDate_Grid;
        Test.setCurrentPage(pageRef);

        WB_ObjectsWarpper.SearchFilters  wrapper = new WB_ObjectsWarpper.SearchFilters();
        list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper> searchResultWrapper = new list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper>();
        wrapper.EADTitle = 'Test Title';

        searchResultWrapper = WB_EAD_Grid_Controller.getEADRecords(wrapper);
        test.stopTest();
        system.assertEquals(eadRec.Title__r.name, searchResultWrapper[0].title);
        
    }
    
    static testMethod void unitTestGetEADRecordDataByFormat() {
        setupData();

        test.startTest();
        Earliest_Avail_Date__c eadRec = [select Id,Video_Version__c,Format__c from Earliest_Avail_Date__c];
        WB_EAD_Grid_Controller gridController = new WB_EAD_Grid_Controller();
        PageReference pageRef = Page.WB_EarliestAvailDate_Grid;
        Test.setCurrentPage(pageRef);

        WB_ObjectsWarpper.SearchFilters  wrapper = new WB_ObjectsWarpper.SearchFilters();
        list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper> searchResultWrapper = new list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper>();
        List<WB_ObjectsWarpper.PicklistOption> lstPickOpt = new List<WB_ObjectsWarpper.PicklistOption>();
        WB_ObjectsWarpper.PicklistOption pickopt = new WB_ObjectsWarpper.PicklistOption('HD','HD');
        lstPickOpt.add(pickopt);
        wrapper.EADFormats = lstPickOpt;

        searchResultWrapper = WB_EAD_Grid_Controller.getEADRecords(wrapper);
        test.stopTest();
        system.assertEquals(eadRec.Format__c, searchResultWrapper[0].format);
        
    }
    
    static testMethod void unitTestGetEADRecordDataByChannel() {
        setupData();

        test.startTest();
        Earliest_Avail_Date__c eadRec = [select Id,Video_Version__c,Channel__c from Earliest_Avail_Date__c];
        WB_EAD_Grid_Controller gridController = new WB_EAD_Grid_Controller();
        PageReference pageRef = Page.WB_EarliestAvailDate_Grid;
        Test.setCurrentPage(pageRef);

        WB_ObjectsWarpper.SearchFilters  wrapper = new WB_ObjectsWarpper.SearchFilters();
        list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper> searchResultWrapper = new list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper>();
        List<WB_ObjectsWarpper.PicklistOption> lstPickOpt = new List<WB_ObjectsWarpper.PicklistOption>();
        WB_ObjectsWarpper.PicklistOption pickopt = new WB_ObjectsWarpper.PicklistOption('EST','EST');
        lstPickOpt.add(pickopt);
        wrapper.EADChannel = lstPickOpt;

        searchResultWrapper = WB_EAD_Grid_Controller.getEADRecords(wrapper);
        test.stopTest();
        system.assertEquals(eadRec.Channel__c, searchResultWrapper[0].channel);
        
    }
    
    static testMethod void unitTestGetEADRecordDataByWBCountry() {
        setupData();

        test.startTest();
        Earliest_Avail_Date__c eadRec = [select Id,Video_Version__c,Channel__c,Country__r.Name from Earliest_Avail_Date__c];
        WB_EAD_Grid_Controller gridController = new WB_EAD_Grid_Controller();
        PageReference pageRef = Page.WB_EarliestAvailDate_Grid;
        Test.setCurrentPage(pageRef);

        WB_ObjectsWarpper.SearchFilters  wrapper = new WB_ObjectsWarpper.SearchFilters();
        list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper> searchResultWrapper = new list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper>();
        List<WB_ObjectsWarpper.PicklistOption> lstPickOpt = new List<WB_ObjectsWarpper.PicklistOption>();
        WB_ObjectsWarpper.PicklistOption pickopt = new WB_ObjectsWarpper.PicklistOption('USA','USA');
        lstPickOpt.add(pickopt);
        wrapper.WBTerritory = lstPickOpt;

        searchResultWrapper = WB_EAD_Grid_Controller.getEADRecords(wrapper);
        test.stopTest();
        system.assertEquals(eadRec.Country__r.Name, searchResultWrapper[0].WBTerritory);
        
    }

    static testMethod void unitTestSaveEADRecordData() {
        setupData();
        
        test.startTest();
        
        list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper> saveSearchResultWrapper =  new list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper>();
        list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper> searchResultWrapper = new list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper>();
        
        WB_EAD_Grid_Controller.EarliestAvailDatesWrapper wrapper = new WB_EAD_Grid_Controller.EarliestAvailDatesWrapper();
        
        Earliest_Avail_Date__c eadRec = [select Id,Video_Version__c from Earliest_Avail_Date__c];
        WB_EAD_Grid_Controller gridController = new WB_EAD_Grid_Controller();
        PageReference pageRef = Page.WB_EarliestAvailDate_Grid;
        Test.setCurrentPage(pageRef);

        wrapper.videoVersion = '987654';
        wrapper.channel = 'EST';
        wrapper.format = 'SD';
        wrapper.country = 'USA';
        wrapper.earliestAvailDate = system.today().format();
        wrapper.status = 'Unlocked';
        wrapper.isRowModified = true;
        wrapper.validation = null;
        searchResultWrapper.add(wrapper);
        
        saveSearchResultWrapper = WB_EAD_Grid_Controller.setEADRecords(searchResultWrapper);

        system.assertEquals(Label.WB_Upload_Message_Created, saveSearchResultWrapper[0].validation);
        
        test.stopTest();
 
    }
    
    static testMethod void unitTestSaveEADRecordDatawithErrorinVideoVersion() {
        setupData();
        
        test.startTest();
        
        list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper> saveSearchResultWrapper =  new list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper>();
        list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper> searchResultWrapper = new list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper>();
        
        WB_EAD_Grid_Controller.EarliestAvailDatesWrapper wrapper = new WB_EAD_Grid_Controller.EarliestAvailDatesWrapper();
        
        Earliest_Avail_Date__c eadRec = [select Id,Video_Version__c from Earliest_Avail_Date__c];
        WB_EAD_Grid_Controller gridController = new WB_EAD_Grid_Controller();
        PageReference pageRef = Page.WB_EarliestAvailDate_Grid;
        Test.setCurrentPage(pageRef);

        wrapper.videoVersion = 'Test';
        wrapper.channel = 'Physical';
        wrapper.format = 'SD';
        wrapper.country = 'USA';
        wrapper.earliestAvailDate = system.today().format();
        wrapper.status = 'Unlocked';
        wrapper.isRowModified = true;
        wrapper.validation = null;
        searchResultWrapper.add(wrapper);
        
        saveSearchResultWrapper = WB_EAD_Grid_Controller.setEADRecords(searchResultWrapper);

        system.assertEquals(Label.WB_Invalid_Video_Version_error, saveSearchResultWrapper[0].validation);
        
        test.stopTest();
 
    }
    static testMethod void unitTestSaveEADRecordDatawithErrorinChannel() {
        setupData();
        
        test.startTest();
        
        list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper> saveSearchResultWrapper =  new list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper>();
        list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper> searchResultWrapper = new list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper>();
        
        WB_EAD_Grid_Controller.EarliestAvailDatesWrapper wrapper = new WB_EAD_Grid_Controller.EarliestAvailDatesWrapper();
        
        Earliest_Avail_Date__c eadRec = [select Id,Video_Version__c from Earliest_Avail_Date__c];
        WB_EAD_Grid_Controller gridController = new WB_EAD_Grid_Controller();
        PageReference pageRef = Page.WB_EarliestAvailDate_Grid;
        Test.setCurrentPage(pageRef);

        wrapper.videoVersion = '987654';
        wrapper.channel = 'Test';
        wrapper.format = 'SD';
        wrapper.country = 'USA';
        wrapper.earliestAvailDate = system.today().format();
        wrapper.status = 'Unlocked';
        wrapper.isRowModified = true;
        wrapper.validation = null;
        searchResultWrapper.add(wrapper);
        
        saveSearchResultWrapper = WB_EAD_Grid_Controller.setEADRecords(searchResultWrapper);

        system.assertEquals(Label.WB_EAD_Invalid_Channel_Error, saveSearchResultWrapper[0].validation);
        
        test.stopTest();
 
    }
    static testMethod void unitTestSaveEADRecordDatawithErrorinCountry() {
        setupData();
        
        test.startTest();
        
        list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper> saveSearchResultWrapper =  new list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper>();
        list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper> searchResultWrapper = new list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper>();
        
        WB_EAD_Grid_Controller.EarliestAvailDatesWrapper wrapper = new WB_EAD_Grid_Controller.EarliestAvailDatesWrapper();
        
        Earliest_Avail_Date__c eadRec = [select Id,Video_Version__c from Earliest_Avail_Date__c];
        WB_EAD_Grid_Controller gridController = new WB_EAD_Grid_Controller();
        PageReference pageRef = Page.WB_EarliestAvailDate_Grid;
        Test.setCurrentPage(pageRef);

        wrapper.videoVersion = '987654';
        wrapper.channel = 'Physical';
        wrapper.format = 'SD';
        wrapper.country = 'UK';
        wrapper.earliestAvailDate = system.today().format();
        wrapper.status = 'Unlocked';
        wrapper.isRowModified = true;
        wrapper.validation = null;
        searchResultWrapper.add(wrapper);
        
        saveSearchResultWrapper = WB_EAD_Grid_Controller.setEADRecords(searchResultWrapper);

        system.assertEquals(Label.WB_Invalid_Country_error, saveSearchResultWrapper[0].validation);
        
        test.stopTest();
 
    }
    
     static testMethod void unitTestSaveEADRecordDatawithErrorinStatus() {
        setupData();
        
        test.startTest();
        
        list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper> saveSearchResultWrapper =  new list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper>();
        list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper> searchResultWrapper = new list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper>();
        
        WB_EAD_Grid_Controller.EarliestAvailDatesWrapper wrapper = new WB_EAD_Grid_Controller.EarliestAvailDatesWrapper();
        
        Earliest_Avail_Date__c eadRec = [select Id,Video_Version__c from Earliest_Avail_Date__c];
        WB_EAD_Grid_Controller gridController = new WB_EAD_Grid_Controller();
        PageReference pageRef = Page.WB_EarliestAvailDate_Grid;
        Test.setCurrentPage(pageRef);

        wrapper.videoVersion = '987654';
        wrapper.channel = 'Physical';
        wrapper.format = 'SD';
        wrapper.country = 'USA';
        wrapper.earliestAvailDate = system.today().format();
        wrapper.status = 'Invalid';
        wrapper.isRowModified = true;
        wrapper.validation = null;
        searchResultWrapper.add(wrapper);
        
        saveSearchResultWrapper = WB_EAD_Grid_Controller.setEADRecords(searchResultWrapper);

        system.assertEquals(Label.WB_EAD_Invalid_Status_Error, saveSearchResultWrapper[0].validation);
        
        test.stopTest();
 
    }
    
    static testMethod void unitTestSaveEADRecordDatawithErrorinFormat() {
        setupData();
        
        test.startTest();
        
        list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper> saveSearchResultWrapper =  new list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper>();
        list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper> searchResultWrapper = new list<WB_EAD_Grid_Controller.EarliestAvailDatesWrapper>();
        
        WB_EAD_Grid_Controller.EarliestAvailDatesWrapper wrapper = new WB_EAD_Grid_Controller.EarliestAvailDatesWrapper();
        
        Earliest_Avail_Date__c eadRec = [select Id,Video_Version__c from Earliest_Avail_Date__c];
        WB_EAD_Grid_Controller gridController = new WB_EAD_Grid_Controller();
        PageReference pageRef = Page.WB_EarliestAvailDate_Grid;
        Test.setCurrentPage(pageRef);

        wrapper.videoVersion = '987654';
        wrapper.channel = 'Physical';
        wrapper.format = 'Test';
        wrapper.country = 'USA';
        wrapper.earliestAvailDate = system.today().format();
        wrapper.status = 'Unlocked';
        wrapper.isRowModified = true;
        wrapper.validation = null;
        searchResultWrapper.add(wrapper);
        
        saveSearchResultWrapper = WB_EAD_Grid_Controller.setEADRecords(searchResultWrapper);

        system.assertEquals(Label.WB_EAD_Invalid_Format_Error, saveSearchResultWrapper[0].validation);
        
        test.stopTest();
 
    }
    
}