@isTest(seeAllData = false)
public class WB_EpisodeMAL_Test{
    static List<Account> accList = new List<Account>();
    static List<Commercial_Avail__c> cAvailList = new List<Commercial_Avail__c>();
    public static Language__c l;
    public static Country__c c; 
    public static Country__c c1;
    public static Playlist__c playlist123;
    public static List<Country__c> countryList = new List<Country__c>();
    
    @isTest
    public static void testMethodForEpisodeMAL_Test()
    {
       
       TestDataUtility tdu = new TestDataUtility();  
       accList = tdu.createAccountList(); 
        //Start -- To create Client Avail 
        MPM__c m = tdu.createMPM();
       Title__c t = tdu.createTitle(m);
       
       t.Content_Type__c='Season';
       update t;
       
       
        playlist123 = new Playlist__c();
        playlist123.name = 'test playlist';
        playlist123.Version_Number__c = 1;
        playlist123.Parent_Title__c = t.id;
        playlist123.Playlist_Status__c = 'Active';
        //insert playlist123;
       
        l = New Language__c();
        l.Name = 'English';
        l.Language_Order__c = 1;
        insert l;
        
        Available_Languages__c availLang = new Available_Languages__c(Title__c=t.id,Language__c=l.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang ;
       
       
        c = New Country__c();
        c.Name = 'USA';
        c.Country_Code2__c = 'IA';
        c.Country_Code__c = 'IA';
        c.Status__c = 'Active';
        c.TV_Day_After_US_Offset__c = 2;
        c.TV_Day_After_Local_Offset__c = 1;
        countryList.add(c);
       // insert c;
        
        c1 = New Country__c();
        c1.Name = 'Germany';
        c1.Country_Code2__c = 'GA';
        c1.Country_Code__c = 'GA';
        c1.Status__c = 'Active';
        c1.TV_Day_After_US_Offset__c = 2;
        c1.TV_Day_After_Local_Offset__c = 1;
        countryList.add(c1);
        
        insert countryList;
        
       Country_Groups__c countryGroup=new Country_Groups__c(Name='CountryGroup',Account__c=accList[0].Id,Country__c=countryList[0].Name);
       insert countryGroup;
       Country_Group_Country__c countryGC = new Country_Group_Country__c (Country_Group__c=countryGroup.Id,Country__c=countryList[0].Id);
       insert countryGC; 
       Local_Title__c lt = tdu.createlocalTitle(countryList[0], l);

       lt.Title__c=t.id;
      
       
       update lt;
      
       //Create Pricing
       Pricing__c newPrice = new Pricing__c();
       newPrice.Content_Type__c = 'Season';
       newPrice.Account__c = accList[0].Id;
       newPrice.Country__c = countryList[0].Id;
       newPrice.Channel__c = 'DTD';
       newPrice.Format__c = 'HD';
       newPrice.WS_Price__c = 120.00;
       insert newPrice;
       
       
       /*
       Commercial_Avail__c rp = tdu.createReleasePlan(t, c, lt, l);
       rp.Exclusive_Date__c = System.today().addDays(-200);
       rp.Start_Date__c = System.today().addDays(-200);
       rp.End_Date__c = System.today().addDays(500);
       rp.Rights_End__c= System.today().addDays(500);
       rp.Country_Lookup__c = c.Id;
       cAvailList.add(rp);
       */
        /*
       Commercial_Avail__c rp1 = tdu.createReleasePlan(t, c1, lt, l);
       rp1.Exclusive_Date__c = System.today().addDays(-200);
       rp1.Start_Date__c = System.today().addDays(-200);
       rp1.End_Date__c = System.today().addDays(500);
       rp1.Rights_End__c= System.today().addDays(500);
       rp1.Country_Lookup__c = c1.Id;
       cAvailList.add(rp1);
       */
       
       
       //update cAvailList;
       Commercial_Avail__c rp = new Commercial_Avail__c(
                Title__c = t.Id, Channel__c = 'EST', Format__c = 'HD', Country_Lookup__c = countryList[0].Id, Languages__c = l.Id,Local_Title__c = lt.id,
                Language_Type__c = 'Dub', end_date__c = System.today().addDays(500), start_Date__c = System.today().addDays(-200),
                Rights_End__c=System.today().addDays(500),Exclusive_Date__c=System.today().addDays(-200)
            );
       cAvailList.add(rp);
       
       Commercial_Avail__c rp1 = new Commercial_Avail__c(
                Title__c = t.Id, Channel__c = 'DTD', Format__c = 'HD', Country_Lookup__c = countryList[1].Id, Languages__c = l.Id,Local_Title__c = lt.id,
                Language_Type__c = 'Dub', end_date__c = System.today().addDays(500), start_Date__c = System.today().addDays(-200),
                Rights_End__c=System.today().addDays(500),Exclusive_Date__c=System.today().addDays(-200)
            );
       cAvailList.add(rp1);
       Test.startTest(); 
       insert cAvailList;
       
       
       
       Agreement__c sf = tdu.createStorefront(countryList[0],rp, t, accList[0]);
        //Test.startTest(); 
       list<Client_Avail__c> CaccListInsert = New list<Client_Avail__c>();
       Client_Avail__c ca = New Client_Avail__c(Storefront__c=sf.Id,Commercial_Avail__c = rp.ID,Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(10),End_Date__c=System.today().addDays(300));
       Client_Avail__c ca1 = New Client_Avail__c(Storefront__c=sf.Id,Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300));
       Client_Avail__c ca2 = New Client_Avail__c(Storefront__c=sf.Id,Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(20),End_Date__c=System.today().addDays(180),Announce_Override__c='Suppress'); 
       Client_Avail__c ca3 = New Client_Avail__c(Storefront__c=sf.Id,Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(12),End_Date__c=System.today().addDays(300),APO_Date__c=Date.Today().addDays(-45));
       Client_Avail__c ca4 = New Client_Avail__c(Storefront__c=sf.Id,Commercial_Avail__c = rp1.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(5),End_Date__c=System.today().addDays(300));
      
       CaccListInsert.add(ca);
       CaccListInsert.add(ca1);
       CaccListInsert.add(ca2); 
       CaccListInsert.add(ca3);
       CaccListInsert.add(ca4);
       
        WB_PriceUtility.SKIP_EPISODE_PROCESS = false;
       WB_ClientAvailPriceHandler.recursiveInsert = true;
       insert CaccListInsert;
       WB_ClientAvailPriceHandler.recursiveInsert = true;
       WB_PriceUtility.SKIP_EPISODE_PROCESS = true;
       
       ca1.Status__c = 'Confirmed';
       ca1.Episode_Price_Tier__c = 'TBD';
       ca1.Price_Tier_Text__c = 'TBD';
       update ca1;
       
       insert playlist123;
       Episode_MAL__c em = new Episode_MAL__c();
       em.vv__c = t.Video_Version__c;
       insert em;
       
       
        
       WB_EpisodeMAL c2 = new WB_EpisodeMAL();
       
       ID batchID = database.executebatch(c2,1);
        
       Test.stopTest();
       
    }
}