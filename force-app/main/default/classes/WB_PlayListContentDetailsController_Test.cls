@isTest
public class WB_PlayListContentDetailsController_Test {
    
    public static testMethod void WB_PlayListContentDetailsController_Constructor() {
        test.startTest();
        setUpData();
        
        WB_PlayListContentDetailsController cntrl = new WB_PlayListContentDetailsController();   
        cntrl.getPlayListFieldSet();
        cntrl.getTitleSearchFields();
        
        test.stopTest();

    }
    
    public static testMethod void PlayListContentDetailsController_CustomSave() {
        test.startTest();
        setUpData();
        Apexpages.currentPage().getParameters().put('selectedValue_serialised','');
        WB_PlayListContentDetailsController cntrlError = new WB_PlayListContentDetailsController(); 
        cntrlError.customSaveRecord();
        Title__c TitleNew = [SELECT ID FROM Title__c WHERE Content_Type__c = 'Season' LIMIT 1];
        Apexpages.currentPage().getParameters().put('selectedValue_serialised',TitleNew.id);
        WB_PlayListContentDetailsController cntrlNew = new WB_PlayListContentDetailsController(); 
        
        Playlist__c PL = New Playlist__c();
        PL.Name = '';
        PL.Parent_Title__c = TitleNew.id;
        PL.Version_Number__c = 1;
        PL.Notes__c = 'Test Note';
        PL.Playlist_Status__c = 'Deleted';
        PL.Playlist_Type__c = 'TV Season Standard';
        cntrlNew.playListObj = PL;
        cntrlNew.customSaveRecord();
        cntrlNew.playListObj.Playlist_Status__c = 'Active';
        cntrlNew.customSaveRecord();
        system.assertNotEquals(cntrlNew.playListObj.Id, null);
        
        Apexpages.currentPage().getParameters().put('mode','c');
        Apexpages.currentPage().getParameters().put('playList',cntrlNew.playListObj.ID);
        WB_PlayListContentDetailsController cntrlClone = new WB_PlayListContentDetailsController(); 
        cntrlClone.showSelectedItems();
        cntrlClone.customSaveRecord();
        cntrlClone.backToPage();
        test.stopTest();
        
    }
    public static testMethod void PlayListContentDetailsController_CustomSaveEdit() {
        test.startTest();
        setUpData();
        Title__c TitleNew = [SELECT ID FROM Title__c WHERE Content_Type__c = 'Season' LIMIT 1];
        Apexpages.currentPage().getParameters().put('selectedValue_serialised',TitleNew.id);
        
        Playlist__c PL = New Playlist__c();
        PL.Name = 'Test Playlist';
        PL.Parent_Title__c = TitleNew.id;
        PL.Version_Number__c = 1;
        PL.Notes__c = 'Test Note';
        PL.Playlist_Status__c = 'Active';
        PL.Playlist_Type__c = 'TV Season Standard';
        Insert PL;
        
        Playlist_Content__c PC = New Playlist_Content__c();
        PC.Content_Title__c = TitleNew.Id;
        PC.Content_Status__c = 'Active';
        PC.Playlist__c = PL.Id;
        insert PC;
        
        Local_Title__c LT = [SELECT ID FROM Local_Title__c LIMIT 1];
        LT.Playlist__c = PL.Id;
        Update LT;
        Apexpages.currentPage().getParameters().put('mode','e');
        Apexpages.currentPage().getParameters().put('playList',PL.Id);
        WB_PlayListContentDetailsController cntrlEdit = new WB_PlayListContentDetailsController(); 
        
        Playlist__c PLEdit = New Playlist__c();
        PLEdit.Name = 'Test Edit Playlist';
        PLEdit.Parent_Title__c = TitleNew.id;
        PLEdit.Version_Number__c = 1;
        PLEdit.Notes__c = 'Test Note';
        PLEdit.Playlist_Status__c = 'active';
        PLEdit.Playlist_Type__c = 'TV Season Standard';
        cntrlEdit.playListObj = PLEdit;
        cntrlEdit.playListObj.Id = PL.Id;
        cntrlEdit.customSaveRecord();
        
        cntrlEdit.playListObj.Playlist_Status__c = 'Deleted';
        cntrlEdit.customSaveRecord();
        
        system.assertEquals(cntrlEdit.playListObj.Name, PLEdit.Name);
        test.stopTest();
        
    }
    
    public static testMethod void PlayListContentDetailsController_CustomSearch() {
        test.startTest();
        setUpData();
        Title__c TitleNew = [SELECT ID FROM Title__c WHERE Content_Type__c = 'Season' LIMIT 1];
        Apexpages.currentPage().getParameters().put('selectedValue_serialised',TitleNew.id);
        
        Playlist__c PL = New Playlist__c();
        PL.Name = 'Test Playlist';
        PL.Parent_Title__c = TitleNew.id;
        PL.Version_Number__c = 1;
        PL.Notes__c = 'Test Note';
        PL.Playlist_Status__c = 'Active';
        PL.Playlist_Type__c = 'TV Season Standard';
        Insert PL;
        
        Playlist_Content__c PC = New Playlist_Content__c();
        PC.Content_Title__c = TitleNew.Id;
        PC.Content_Status__c = 'Active';
        PC.Playlist__c = PL.Id;
        insert PC;
        
        Local_Title__c LT = [SELECT ID FROM Local_Title__c LIMIT 1];
        LT.Playlist__c = PL.Id;
        Update LT;
        Apexpages.currentPage().getParameters().put('mode','e');
        Apexpages.currentPage().getParameters().put('playList',PL.Id);
        WB_PlayListContentDetailsController cntrlSearch = new WB_PlayListContentDetailsController(); 
        cntrlSearch.titleSearchInstance.titleName = 'test';
        cntrlSearch.search(); 
        cntrlSearch.titleSearchInstance.titleVVNumber = '000000001';
        cntrlSearch.search(); 
        cntrlSearch.titleSearchInstance.titleName = '';
        cntrlSearch.search(); 
        cntrlSearch.titleSearchInstance.MPMName = '2063646';
        cntrlSearch.search(); 
        cntrlSearch.titleSearchInstance.titleVVNumber = '';
        cntrlSearch.search(); 
        cntrlSearch.titleSearchInstance.ContentType = 'Season';
        cntrlSearch.search(); 
        cntrlSearch.titleSearchInstance.MPMName = '';
        cntrlSearch.titleSearchInstance.ContentType = 'Season';
        cntrlSearch.search(); 
        cntrlSearch.titleSearchInstance.AbstractEIDR='test';
        cntrlSearch.search(); 
        cntrlSearch.titleSearchInstance.ContentType = '';
        cntrlSearch.search(); 
        test.stopTest();
        
    }
    
    public static testMethod void PlayListContentDetailsController_CustomSave2() {
        test.startTest();
        setUpData();
        Apexpages.currentPage().getParameters().put('selectedValue_serialised','');
        WB_PlayListContentDetailsController cntrlError = new WB_PlayListContentDetailsController(); 
        cntrlError.customSaveRecord();
        Title__c TitleNew = [SELECT ID FROM Title__c WHERE Content_Type__c = 'Season' LIMIT 1];
        Apexpages.currentPage().getParameters().put('selectedValue_serialised',TitleNew.id);
        WB_PlayListContentDetailsController cntrlNew = new WB_PlayListContentDetailsController(); 
        
        Playlist__c PL = New Playlist__c();
        PL.Name = 'test playlist 1';
        PL.Parent_Title__c = TitleNew.id;
        PL.Version_Number__c = 1;
        PL.Notes__c = 'Test Note';
        PL.Playlist_Status__c = 'Deleted';
        PL.Playlist_Type__c = 'TV Season Standard';
        cntrlNew.playListObj = PL;
        cntrlNew.customSaveRecord();
        cntrlNew.playListObj.Playlist_Status__c = 'Active';
        cntrlNew.customSaveRecord();
        system.assertNotEquals(cntrlNew.playListObj.Id, null);
        
        Apexpages.currentPage().getParameters().put('mode','c');
        Apexpages.currentPage().getParameters().put('playList',cntrlNew.playListObj.ID);
        WB_PlayListContentDetailsController cntrlClone = new WB_PlayListContentDetailsController(); 
        cntrlClone.showSelectedItems();
        cntrlClone.playListObj.name='test playlist 2';
        cntrlClone.customSaveRecord();
        cntrlClone.playListObj.Playlist_Status__c = 'Deleted';
        cntrlClone.customSaveRecord();
        test.stopTest();
        
    }
    
    public static void setUpData(){
        /* -- MPM creation-- */
        MPM__c Mpm = new MPM__c();
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646';
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        /* -- Title creation-- */
        Title__c t = new Title__c();
        t.Name = 'Test Title';
        t.Digital_Planning__c = 'Yes';
        t.Content_Type__c = 'Season';
        t.Video_Version__c = '000000001';
        t.MPM__c = Mpm.id;
        t.Formats__c = 'SD';
        Insert t;
        
        Title__c TEpisode = New Title__c();
        TEpisode.Name = 'Test Title Episode';
        TEpisode.Digital_Planning__c = 'No';
        TEpisode.Content_Type__c = 'Episode';
        TEpisode.Video_Version__c = '000000002';
        TEpisode.MPM__c = Mpm.id;
        TEpisode.Formats__c = '';
        insert TEpisode;
        
        /*--Title BOM Creation--*/
        Title_BOM__c TB = New Title_BOM__c();
        TB.Title__c = t.id;
        TB.MPM__c = Mpm.Id;
        TB.BOM_Type__c = 'VBOM';
        insert TB;
        
        Country__c Country = New Country__c();
        Country.Name = 'India';
        Country.Country_Code2__c = 'IN';
        Country.Country_Code__c = 'IND';
        Country.Status__c = 'Active';
        insert Country;
        
        Language__c Language = New Language__c();
        Language.Name = 'English';
        Language.Language_Order__c = 1;
        insert Language;
        
        Local_Title__c LT = New Local_Title__c();
        LT.Name = t.Name;
        LT.Title__c = t.Id;
        LT.Country__c = Country.Id;
        LT.Language__c = Language.Id;
        Insert LT;
        
        Test.setCurrentPageReference(Page.WB_playlistContentdetails);        
        Apexpages.currentPage().getParameters().put('mode','n');
        Apexpages.currentPage().getParameters().put('title',t.id);
        Apexpages.currentPage().getParameters().put('playList','');
    }
    
    public static testMethod void PlayListContentDetailsController_NegativeScnerio() {
        test.startTest();
        setUpData();

        Title__c TitleNew = [SELECT ID FROM Title__c WHERE Content_Type__c = 'Season' LIMIT 1];
        list<Title_BOM__c> BOMRecord = [SELECT Id FROM Title_BOM__c];
        delete BOMRecord;
        Apexpages.currentPage().getParameters().put('selectedValue_serialised',TitleNew.id);
        WB_PlayListContentDetailsController cntrlNew = new WB_PlayListContentDetailsController(); 
        
        Playlist__c PL = New Playlist__c();
        PL.Name = 'Test Name';
        PL.Parent_Title__c = TitleNew.id;
        PL.Version_Number__c = 1;
        PL.Notes__c = 'Test Note';
        PL.Playlist_Status__c = 'Deleted';
        PL.Playlist_Type__c = 'TV Season Local';
        cntrlNew.playListObj = PL;
        cntrlNew.customSaveRecord();
        cntrlNew.playListObj.Playlist_Status__c = 'Active';
        cntrlNew.customSaveRecord();
        system.assertNotEquals(cntrlNew.playListObj.Id, null);

        Apexpages.currentPage().getParameters().put('mode','n');
        Apexpages.currentPage().getParameters().put('playList',cntrlNew.playListObj.ID);
        WB_PlayListContentDetailsController cntrlClone = new WB_PlayListContentDetailsController(); 
        Apexpages.currentPage().getParameters().put('selectedValue_serialised',TitleNew.id+'!#!'+TitleNew.id);
        cntrlClone.customSaveRecord();
        
        Apexpages.currentPage().getParameters().put('mode','n');
        Apexpages.currentPage().getParameters().put('playList',cntrlNew.playListObj.ID);
        Apexpages.currentPage().getParameters().put('selectedValue_serialised',TitleNew.id);
        
        Playlist__c PL1 = New Playlist__c();
        PL1.Name = 'Test Name';
        PL1.Parent_Title__c = TitleNew.id;
        PL1.Version_Number__c = 1;
        PL1.Notes__c = 'Test Note';
        PL1.Playlist_Status__c = 'Active';
        PL1.Playlist_Type__c = 'TV Season Local';

        WB_PlayListContentDetailsController cntrlErrorScn = new WB_PlayListContentDetailsController(); 
        cntrlErrorScn.playListObj = PL1;
        cntrlErrorScn.customSaveRecord();
        
        test.stopTest();
        
    }
    
    public static testMethod void PlayListContentDetailsController_CollectionFeatures() {
        test.startTest();
        setUpData();
        Apexpages.currentPage().getParameters().put('selectedValue_serialised','');
        WB_PlayListContentDetailsController cntrlError = new WB_PlayListContentDetailsController(); 
        cntrlError.customSaveRecord();
        Title__c TitleNew = [SELECT ID FROM Title__c WHERE Content_Type__c = 'Season' LIMIT 1];
        TitleNew.Content_Type__c = 'Collection Features';
        update TitleNew;
        Apexpages.currentPage().getParameters().put('selectedValue_serialised',TitleNew.id);
        WB_PlayListContentDetailsController cntrlNew = new WB_PlayListContentDetailsController(); 
        
        Playlist__c PL = New Playlist__c();
        PL.Name = '';
        PL.Parent_Title__c = TitleNew.id;
        PL.Version_Number__c = 1;
        PL.Notes__c = 'Test Note';
        PL.Playlist_Status__c = 'Deleted';
        PL.Playlist_Type__c = 'TV Season Standard';
        cntrlNew.playListObj = PL;
        cntrlNew.customSaveRecord();
        cntrlNew.playListObj.Playlist_Status__c = 'Active';
        cntrlNew.customSaveRecord();
        system.assertNotEquals(cntrlNew.playListObj.Id, null);
        
        Apexpages.currentPage().getParameters().put('mode','c');
        Apexpages.currentPage().getParameters().put('playList',cntrlNew.playListObj.ID);
        WB_PlayListContentDetailsController cntrlClone = new WB_PlayListContentDetailsController(); 
        cntrlClone.showSelectedItems();
        cntrlClone.customSaveRecord();
        cntrlClone.titleSearchInstance.titleName = 'test';
        cntrlClone.search();
        test.stopTest();
        
    }
    
    public static testMethod void PlayListContentDetailsController_CollectionTV() {
        test.startTest();
        setUpData();
        Apexpages.currentPage().getParameters().put('selectedValue_serialised','');
        WB_PlayListContentDetailsController cntrlError = new WB_PlayListContentDetailsController(); 
        cntrlError.customSaveRecord();
        Title__c TitleNew = [SELECT ID FROM Title__c WHERE Content_Type__c = 'Season' LIMIT 1];
        TitleNew.Content_Type__c = 'Collection TV';
        update TitleNew;
        Apexpages.currentPage().getParameters().put('selectedValue_serialised',TitleNew.id);
        WB_PlayListContentDetailsController cntrlNew = new WB_PlayListContentDetailsController(); 
        
        Playlist__c PL = New Playlist__c();
        PL.Name = '';
        PL.Parent_Title__c = TitleNew.id;
        PL.Version_Number__c = 1;
        PL.Notes__c = 'Test Note';
        PL.Playlist_Status__c = 'Deleted';
        PL.Playlist_Type__c = 'TV Season Standard';
        cntrlNew.playListObj = PL;
        cntrlNew.customSaveRecord();
        cntrlNew.playListObj.Playlist_Status__c = 'Active';
        cntrlNew.customSaveRecord();
        system.assertNotEquals(cntrlNew.playListObj.Id, null);
        
        Apexpages.currentPage().getParameters().put('mode','c');
        Apexpages.currentPage().getParameters().put('playList',cntrlNew.playListObj.ID);
        WB_PlayListContentDetailsController cntrlClone = new WB_PlayListContentDetailsController(); 
        cntrlClone.showSelectedItems();
        cntrlClone.customSaveRecord();
        cntrlClone.titleSearchInstance.titleName = 'test';
        cntrlClone.search(); 
        test.stopTest();
        
    }
    
    public static testMethod void WB_PlayListTriggerHandlerTestCase() {
        TestDataUtility tdu = new TestDataUtility();
        List<Title__c> listitles = new List<Title__c>();
        List<Account> aList = tdu.createAccountList(); 
        MPM__c m = tdu.createMPM();
        Title__c t = tdu.createTitle(m);
        t.content_type__c = 'Season';
        listitles.add(t);
        
        Title__c TEpisode = New Title__c();
        TEpisode.Name = 'Test Title Episode';
        TEpisode.Digital_Planning__c = 'No';
        TEpisode.Content_Type__c = 'Episode';
        TEpisode.Video_Version__c = '000000002';
        TEpisode.MPM__c = m.id;
        TEpisode.Formats__c= '';
        listitles.add(TEpisode);
        
        Title__c TEpisode1 = New Title__c();
        TEpisode1.Name = 'Test Title Episode2';
        TEpisode1.Digital_Planning__c = 'No';
        TEpisode1.Content_Type__c = 'Episode';
        TEpisode1.Video_Version__c = '000000003';
        TEpisode1.MPM__c = m.id;
        TEpisode1.Formats__c= '';
        listitles.add(TEpisode1);
        upsert listitles;
        test.startTest();
        Playlist__c playlist = new Playlist__c(Parent_Title__c = t.id,name='test 1',Playlist_Status__c='Active',Version_Number__c = 1,Playlist_Type__c = 'TV Season Local');
        insert playlist;
        Playlist_Content__c pc = new Playlist_Content__c(Content_Title__c=listitles[1].id,Playlist__c=playlist.id);
        insert pc;
        
        Language__c l = tdu.createLanguage();
        Country__c c = tdu.createCountry();
        
        Local_Title__c lt = tdu.createlocalTitle(c, l);
        lt.Title__c=t.id;
        update lt;
        
        list<Local_Title__c> ltList= [select id, Title__c, Country__c, Language__c, Category__c from Local_Title__c where id = :lt.id];
        
        Commercial_Avail__c rp = tdu.createReleasePlan(t, c, ltList[0], l);
        rp.Exclusive_Date__c = date.today()+10;
        rp.Start_Date__c = date.today()+10;
        rp.End_Date__c = date.today()+100;
        rp.Rights_End__c = date.today()+100;
        update rp;
        test.stopTest();
        
        Agreement__c sf = tdu.createStorefront(c,rp, t, aList[0]);
        Client_Avail__c objCA1 = new Client_Avail__c(
            Commercial_Avail__c = rp.Id,
            Client__c = aList[0].Id,
            Status__c = 'Tentative',
            Storefront__c = sf.Id
        );        
        objCA1.Start_Date__c = system.today()+10;
        objCA1.End_Date__c = system.today()+20;
        insert objCA1;
        
        objCA1.Recalculate_Playlist_Avails__c = '';
        update objCA1;
        
        playlist.Total_Playlist_Content__c = 2;
        update playlist;
        
    }

}