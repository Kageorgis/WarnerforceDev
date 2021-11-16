@isTest
public class WB_PlaylistContentTriggerHandlerTest {
    
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
        t.Content_Type__c = 'Collection Features';
        t.Video_Version__c = '000000001';
        t.MPM__c = Mpm.id;
        t.Formats__c = 'SD';
        Insert t;
        
        Title__c Feature1 = New Title__c();
        Feature1.Name = 'Test Title Feature';
        Feature1.Digital_Planning__c = 'No';
        Feature1.Content_Type__c = 'Feature';
        Feature1.Video_Version__c = '000000002';
        Feature1.MPM__c = Mpm.id;
        Feature1.Formats__c = '';
        Feature1.ALID__C = 'idwb:2063646_000000002';
        insert Feature1;
        
        Title__c Feature2 = New Title__c();
        Feature2.Name = 'Test Title Feature1';
        Feature2.Digital_Planning__c = 'No';
        Feature2.Content_Type__c = 'Feature';
        Feature2.Video_Version__c = '000000003';
        Feature1.ALID__C = 'idwb:2063646_000000003';
        Feature2.MPM__c = Mpm.id;
        Feature2.Formats__c = '';
        insert Feature2;
        
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
    
    public static testMethod void PlayListContentDetailsController_CustomSaveEdit() {
        test.startTest();
        setUpData();
        Title__c TitleNew = [SELECT ID FROM Title__c WHERE Content_Type__c = 'Collection Features' LIMIT 1];
        Apexpages.currentPage().getParameters().put('selectedValue_serialised',TitleNew.id);
        
        Playlist__c PL = New Playlist__c();
        PL.Name = 'Test Playlist';
        PL.Parent_Title__c = TitleNew.id;
        PL.Version_Number__c = 1;
        PL.Notes__c = 'Test Note';
        PL.Playlist_Status__c = 'Active';
        PL.Playlist_Type__c = 'Collection Features';
        Insert PL;
        
        Playlist_Content__c PC = New Playlist_Content__c();
        PC.Content_Title__c = TitleNew.Id;
        PC.Content_Status__c = 'Active';
        PC.Playlist__c = PL.Id;
        insert PC;
        test.stopTest();
    }
    
     public static testMethod void PlayListContentDetailsController_reorderSequence() {
        List<Playlist_Content__c>  lstPC = new List<Playlist_Content__c>();
        test.startTest();
        setUpData();
        Title__c TitleNew = [SELECT ID FROM Title__c WHERE Content_Type__c = 'Collection Features' LIMIT 1];
        List<Title__c> featureTitle = [select id from Title__c where Content_Type__c = 'Feature'];
        Apexpages.currentPage().getParameters().put('selectedValue_serialised',TitleNew.id);
        
        Playlist__c PL = New Playlist__c();
        PL.Name = 'Test Playlist';
        PL.Parent_Title__c = TitleNew.id;
        PL.Version_Number__c = 1;
        PL.Notes__c = 'Test Note';
        PL.Playlist_Status__c = 'Active';
        PL.Playlist_Type__c = 'Collection Features';
        Insert PL;
        
        Playlist_Content__c PC = New Playlist_Content__c();
        PC.Content_Title__c = TitleNew.Id;
        PC.Content_Status__c = 'Active';
        pc.Content_Sequence__c = 1;
        pc.Content_Title__c = featureTitle[0].Id;
        PC.Playlist__c = PL.Id;
        insert PC;
        
        Playlist_Content__c PC1 = New Playlist_Content__c();
        PC1.Content_Title__c = TitleNew.Id;
        PC1.Content_Status__c = 'Active';
        pc1.Content_Sequence__c = 2;
        PC1.Playlist__c = PL.Id;
        pc1.Content_Title__c = featureTitle[1].Id;
        insert PC1;

        pc.Content_Sequence__c = 2;
        pc1.Content_Sequence__c = 1;
        lstPC.add(pc);
        lstPC.add(pc1);
        update lstPC;
        test.stopTest();
    }

    
}