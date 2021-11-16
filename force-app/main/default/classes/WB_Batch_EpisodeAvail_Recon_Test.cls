@isTest 
public class WB_Batch_EpisodeAvail_Recon_Test{
   
    @isTest
    public static void myUnitTest1() {
       
       MPM__c Mpm = new MPM__c(); 
       Mpm.Name = '2063646';
       Mpm.MPM_Number__c = '2063646'; 
       Mpm.Film_Color__c = 'Color';
       insert Mpm; 
       
       Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
       
       // /* -- Title creation-- */
       Title__c t = new Title__c();
       t.Name = 'Test Title';
       t.Digital_Planning__c = 'Yes';
       t.Clear_to_Avail__c = true;
       t.Content_Type__c = 'Season';
       t.Video_Version__c = '000000001';
       t.MPM__c = Mpm.id;
       t.US_TV_Air_Date__c = system.today();
       t.Formats__c='SD';
       Insert t;
        
       Title__c episodeTitle = new Title__c();
       episodeTitle.Name = 'Episode Title1';
       episodeTitle.Digital_Planning__c = 'Yes';
       episodeTitle.Clear_to_Avail__c = true;
       episodeTitle.Content_Type__c = 'Episode';
       episodeTitle.Video_Version__c = '000000002';
       episodeTitle.Global_Category__c = 'TV Catalog';
       episodeTitle.MPM__c = Mpm.id;
       episodeTitle.Formats__c='SD';
       Insert episodeTitle;
        
       Title__c episodeTitle2 = new Title__c();
       episodeTitle2.Name = 'Episode Title1';
       episodeTitle2.Digital_Planning__c = 'Yes';
       episodeTitle2.Clear_to_Avail__c = true;
       episodeTitle2.Content_Type__c = 'Episode';
       episodeTitle2.Video_Version__c = '000000003';
       episodeTitle.Global_Category__c = 'TV Catalog';
       episodeTitle2.MPM__c = Mpm.id;
       episodeTitle2.Formats__c='SD';
       insert episodeTitle2;
       
       Playlist__c playlist = new Playlist__c();
       playlist.name = 'test playlist';
       playlist.Version_Number__c = 1;
       playlist.Parent_Title__c = t.id;
       playlist.Playlist_Status__c = 'Active';
       insert playlist;
       
       Playlist__c playlist1 = new Playlist__c();
       playlist1.name = 'test playlist1';
       playlist1.Version_Number__c = 1;
       playlist1.Parent_Title__c = t.id;
       playlist1.Playlist_Status__c = 'Active';
       insert playlist1;
        
       List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
       Playlist_Content__c content = new Playlist_Content__c();
       content.Content_Title__c=episodeTitle.id;
       content.Playlist__c = playlist.id;
       contentlist.add(content);
       
       Playlist_Content__c content2 = new Playlist_Content__c();
       content2.Content_Title__c=episodeTitle2.id;
       content2.Playlist__c = playlist1.id;
       contentlist.add(content2);
       insert contentlist;
       
       Country__c Country = New Country__c();
       Country.Name = 'India';
       Country.Country_Code2__c = 'IN';
       Country.Country_Code__c = 'IND';
       Country.Status__c = 'Active';
       Country.TV_Day_After_US_Offset__c = 2;
       Country.TV_Day_After_Local_Offset__c = 1;
       insert Country;
       
       Language__c Language = New Language__c();
       Language.Name = 'English';
       Language.Language_Order__c = 1;
       insert Language;
       
       List<Local_Title__c> listlocaltitles= new List<Local_Title__c>();
       Local_Title__c LT = New Local_Title__c();
       LT.Name = t.Name;
       LT.Title__c = t.Id;
       LT.Country__c = Country.Id;
       LT.Language__c = Language.Id;
       LT.Local_TV_Air_Date__c = date.today();
       LT.Playlist__C = playlist.id;
       listlocaltitles.add(LT);
        
       Local_Title__c episodeLT = New Local_Title__c();
       episodeLT.Name = t.Name;
       episodeLT.Title__c = episodeTitle.Id;
       episodeLT.Country__c = Country.Id;
       episodeLT.Language__c = Language.Id;
       episodeLT.Local_TV_Air_Date__c = date.today();
       episodeLT.Parent_Local_Data__c=LT.id;
       episodeLT.Category__c = 'TV Day After Local';
       listlocaltitles.add(episodeLT);
       
       Insert listlocaltitles;
       
       List<Commercial_Avail__c> listReleaseplan = new List<Commercial_Avail__c>();
       Commercial_Avail__c releasePlan1 = new Commercial_Avail__c();
       releasePlan1.Channel__c = 'VODi';
       releasePlan1.Title__c=t.id;
       releasePlan1.Languages__c = Language.id;
       releasePlan1.Country_Lookup__c = Country.id;
       releasePlan1.Format__c = 'SD';
       releasePlan1.Language_Type__c = 'Sub & Audio';
       releasePlan1.Exclusive_Date__c = date.today()-200;
       releasePlan1.Start_Date__c = date.today()-100;
       releasePlan1.End_Date__c = date.today()+100;
       releasePlan1.Rights_End__c=date.today()+200;
       releasePlan1.Status__c = 'Confirmed';
       releasePlan1.Playlist__C = playlist.id;
       listReleaseplan.add(releasePlan1);
       
       Commercial_Avail__c releasePlan2 = new Commercial_Avail__c();
       releasePlan2.Channel__c = 'VODi';
       releasePlan2.Title__c=episodeTitle.id;
       releasePlan2.Languages__c = Language.id;
       releasePlan2.Country_Lookup__c = Country.id;
       releasePlan2.Format__c = 'SD';
       releasePlan2.Language_Type__c = 'Sub & Audio';
       releasePlan2.Exclusive_Date__c = date.today()-200;
       releasePlan2.Start_Date__c = date.today()-100;
       releasePlan2.End_Date__c = date.today()+100;
       releasePlan2.Rights_End__c=date.today()+200;
       releasePlan2.Status__c = 'Confirmed';
       listReleaseplan.add(releasePlan2);
       insert listReleaseplan;
        
       Agreement__c storefrontGoogle1 = initStoreFront(acctGoogle.Id, country.Id, listReleaseplan[0], t);
       storefrontGoogle1.Formats_with_EC__c = listReleaseplan[0].Format__c;
       insert storefrontGoogle1;
       
       List<Client_Avail__c> listClientavails = new List<Client_Avail__c>();
       Client_Avail__c clientAvail = TestUtil.initClientAvail(acctGoogle.Id, listReleaseplan[0], listlocaltitles[1].Id);
       clientAvail.Playlist__c = playlist.id;
       clientAvail.Status__c = 'Confirmed';
       clientAvail.Local_Data_Category_Picklist__c = 'TV Day After Local';
       clientAvail.Lock_Pricing_Update__c = false;
       clientAvail.RP_Synch__c = false;
       listClientavails.add(clientAvail);
       test.startTest();
            insert listClientavails;
            Client_Avail__c clientAvail1 = TestUtil.initClientAvail(acctGoogle.Id, listReleaseplan[0], listlocaltitles[1].Id);
            clientAvail1.Title__c = episodeTitle.id;
            clientAvail1.Avail_Type__c = 'Automated'; 
            clientAvail1.Local_Data_Category_Picklist__c = 'TV Day After Local';
            clientAvail1.Parent_Client_Avail__c = listClientavails[0].id;
            insert clientAvail1;
        
        List<String> UsTitleCategory = new List<String>();
        UsTitleCategory.add('TV Day After US');
        UsTitleCategory.add('TV Day After Local');
        String sch = '20 30 8 10 2 ?';

        List<Client_Avail__c> finalCAList = [Select Id,Name,Local_Data_Category_Picklist__c,Start_Date__c,Status__c,Price_Tier_Text__c,Price__c,
                    Local_Title__r.Title__r.US_TV_Air_Date__c,Local_Title__r.Country__r.TV_Day_After_US_Offset__c,
                    Local_Title__r.Local_TV_Air_Date__c,Local_Title__r.Country__r.TV_Day_After_Local_Offset__c,
                    Parent_Client_Avail__r.Status__c,Parent_Client_Avail__r.Start_Date__c,Parent_Client_Avail__r.End_Date__c,
                    Parent_Client_Avail__c,Parent_Client_Avail__r.Local_Data_Category_Picklist__c
                    From Client_AVail__c Where Title_Content_Type__c =: 'Episode'
                    AND END_DATE__c > TODAY
                    AND Parent_Client_Avail__c != null 
                    AND Status__c =: 'Draft'
                    AND Parent_Client_Avail__r.Local_Data_Category_Picklist__c IN : UsTitleCategory
                    AND
                    ((Local_Data_Category_Picklist__c =: 'TV Day After Local' AND Local_Title__r.Local_TV_Air_Date__c != null) OR (Local_Data_Category_Picklist__c =: 'TV Day After US' AND Local_Title__r.Title__r.US_TV_Air_Date__c != null))
                    AND Parent_Client_Avail__r.Status__c IN ('Tentative','Confirmed')];
        
        
        
            WB_Batch_EpisodeAvail_Reconciliation batchInstance = new WB_Batch_EpisodeAvail_Reconciliation('Episode Reconciliation');
            //Database.executeBatch(batchInstance,20);
            batchInstance.start(null);
            batchInstance.execute(null,finalCAList);
            batchInstance.finish(null);
            
            WB_Batch_EpisodeAvail_Reconciliation batchInstance2 = new WB_Batch_EpisodeAvail_Reconciliation();
            String jobID = system.schedule('Episode Reconciliation', sch, batchInstance);

        test.stopTest();
    }
    public static Agreement__c initStoreFront(Id accId, Id countryId, Commercial_Avail__c objCA, Title__c objTitle)
       {
            Agreement__c objAgreement = new Agreement__c(Account__c = accId
                                                        , country__c = countryId
                                                        , Status__c = 'Active'
                                                        , Pricing_Currency__c ='FR'
                                                        , Content_Type__c = 'Season;Episode'
                                                        , Channel_Picklist__c = objCA.Channel__c
                                                        , Format__c = objCA.Format__c
                                                        ,SAP_Customer_Number__c='12010421');
            return objAgreement;
       }
}