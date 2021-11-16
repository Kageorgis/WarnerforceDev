@isTest
private class WB_ManagePlayListContentControllerTest {
    
    public static Title__c t;
    
    public static void setUpData(){
        /* -- MPM creation-- */
        MPM__c Mpm = new MPM__c();
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646';
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        /* -- Title creation-- */
        t = new Title__c();
        t.Name = 'Test Title';
        t.Digital_Planning__c = 'Yes';
        t.Content_Type__c = 'Season';
        t.Video_Version__c = '000000001';
        t.MPM__c = Mpm.id;
        t.Formats__c = 'SD';
        Insert t;
        
        Title__C episodetitle = new Title__c();
        episodetitle.Name = 'Test Title1';
        episodetitle.Digital_Planning__c = 'Yes';
        episodetitle.Content_Type__c = 'Season';
        episodetitle.Video_Version__c = '000000002';
        episodetitle.MPM__c = Mpm.id;
        episodetitle.Formats__c = 'SD';
        Insert episodetitle;
        
        /*--Title BOM Creation--*/
        Title_BOM__c TB = New Title_BOM__c();
        TB.Title__c = t.id;
        TB.MPM__c = Mpm.Id;
        TB.BOM_Type__c = 'VBOM';
        insert TB;
        
        Playlist__c pl = new Playlist__c(name='test playlist1',Version_number__c=1,Parent_Title__c=t.id,PLaylist_Status__C='Draft');
        insert pl;
        Playlist_Content__c pc = new Playlist_Content__c(Playlist__c=pl.id,Content_Title__c=episodetitle.id);
        insert pc;
        Playlist__c pl2 = new Playlist__c(name='test playlist2',Version_number__c=2,Parent_Title__c=t.id,PLaylist_Status__C='Draft');
        insert pl2;
        Playlist_Content__c pc2 = new Playlist_Content__c(Playlist__c=pl.id,Content_Title__c=episodetitle.id);
        insert pc2;
        
    }
    private static testMethod void testMethod1() {
        setUpData();
        Test.startTest();
        Apexpages.currentPage().getParameters().put('Id',t.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(t);
        WB_ManagePlayListContentController ctrl = new WB_ManagePlayListContentController(sc);
        ctrl.titlename='';
        ctrl.showcontent=true;
        ctrl.count=1;
        ctrl.selectedPlaylistIds=t.id;
        ctrl.lstTitles= new List<Title__c>();
        ctrl.showAS=true;
        ctrl.titlelistAvaliable=new List<Title__c>();
        ctrl.canCreate = 'true';
        for(WB_ManagePlayListContentController.PlaylistWrapper w : ctrl.mapPlaylistwrapper.values())
        {
            w.isselected = true;
        }
        ctrl.ComparePlaylistContent();
        ctrl.selectedplaylist = [select id from Playlist__c limit 1].id;
        ctrl.FetchContent();
        ctrl.BackToTitle();
        ctrl.CreateNewPlaylist();
        Test.stoptest();
    }

}