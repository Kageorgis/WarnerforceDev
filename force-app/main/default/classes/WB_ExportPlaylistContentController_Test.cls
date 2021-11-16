@isTest
private class WB_ExportPlaylistContentController_Test {
    public static Title__c t;
    public static Playlist__c pl;
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
        
        pl = new Playlist__c(name='test playlist1',Version_number__c=1,Parent_Title__c=t.id,PLaylist_Status__C='Draft');
        insert pl;
        Playlist_Content__c pc = new Playlist_Content__c(Playlist__c=pl.id,Content_Title__c=episodetitle.id);
        insert pc;

        
    }
    
	private static testMethod void testmethod1() {
	    setUpData();
	    test.startTest();
	    Apexpages.currentPage().getParameters().put('pl',pl.id);
        WB_ExportPlaylistContentController ctrl = new WB_ExportPlaylistContentController();
        ctrl.exportToExcel();
        system.assertEquals(1, ctrl.listPlaylistContents.size());
        test.stopTest();
	}

}