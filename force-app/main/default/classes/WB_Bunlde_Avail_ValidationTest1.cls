@isTest
public class WB_Bunlde_Avail_ValidationTest1 {
     static List<Account> accList = new List<Account>();
     
    @isTest
    public static void validateComponentsTest1()
    {
        Account acct = TestUtil.initAccount();
        insert acct;
        //Start -- To create Client Avail 
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        
        Title__c collectionTitle = new Title__c(Name = 'Coll1',MPM__c = mpm.id,Video_Version__c ='1243355670',Content_Type__c=Label.Collection_Features,Digital_Planning__c='Yes',Clear_to_Avail__c = true, Formats__c = 'HD');
        insert collectionTitle;
        
        Title__c title1 = new Title__c(Name = 'Title1',MPM__c = mpm.id,Video_Version__c ='1243355672',Content_Type__c='Feature',Digital_Planning__c='Yes',Clear_to_Avail__c = true, Formats__c = 'HD');
        insert title1; 
        
        Playlist__c playlist = new Playlist__c(name='Standard Playlist',Parent_Title__c=collectionTitle.id,Playlist_Status__C = 'Active',Version_number__c=1);
        insert playlist;
        
        Playlist_Content__c pc = new Playlist_Content__c(Playlist__c=playlist.id,Content_Title__c=title1.id);
        insert pc;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance1',Country_Code2__c ='AA',Country_Code__c='TC');
        insert countryFrance;   
        
        Country_Groups__c countryGroup=new Country_Groups__c(Name='CountryGroup',Account__c=acct.Id,Country__c=countryFrance.Name);
        insert countryGroup;     
        Language__c languageFrench = new Language__c(Name='TestFrench1',Language_Order__c = 1);
        insert languageFrench;   
        
        Commercial_Avail__c releaseplanCollection = new Commercial_Avail__c(Title__c=collectionTitle.Id,Country_Lookup__c=countryFrance.Id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Audio',Status__c='Tentative',
                                                                    Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+20,Rights_End__c=date.today()+20,Playlist__c=playlist.id);
        insert releaseplanCollection;  
        
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acct.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c='Collection Features; Collection TV; Episode; Feature; Season',
                                                            Channel_Picklist__c = 'EST',Format__c='HD',Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        
        Test.startTest();
        
        WB_Bundle_Avail_Validation.BundleAvailInputWrapper inputWrapper = new WB_Bundle_Avail_Validation.BundleAvailInputWrapper();
        inputWrapper.releasePlans = releaseplanCollection.id;
        inputWrapper.accounts = acct.id;
        
        WB_Bundle_Avail_Validation.getRecords(inputWrapper);
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Audio',Status__c='Tentative',
                                                                    Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+20,Rights_End__c=date.today()+20);
        insert releaseplan1;  
        WB_Bundle_Avail_Validation.getRecords(inputWrapper);  
        
        Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,                                                   
                                                          Client__c=acct.Id,    Status__c='Tentative',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c );                                                        
        insert clientAvail1;
        WB_Bundle_Avail_Validation.getRecords(inputWrapper);
         		      
        Test.stopTest();
   }
   
   
 /*  @isTest
    public static void validateComponentsTest2()
    {   
        
        Account acct = TestUtil.initAccount();
        insert acct;
        //Start -- To create Client Avail 
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
       
        List<Title__c>tList = new List<Title__c>();
        Title__c collectionTitle = new Title__c(Name = 'Coll1',MPM__c = mpm.id,Video_Version__c ='1243355670',Content_Type__c=Label.Collection_Features,Digital_Planning__c='Yes',Clear_to_Avail__c = true, Formats__c = 'HD');
        tList.add(collectionTitle);
        
        Title__c title1 = new Title__c(Name = 'Title1',MPM__c = mpm.id,Video_Version__c ='1243355672',Content_Type__c='Feature',Digital_Planning__c='Yes',Clear_to_Avail__c = true, Formats__c = 'HD');
        tList.add(title1);
        
        insert tList;
        
        Playlist__c playlist = new Playlist__c(name='Standard Playlist',Parent_Title__c=collectionTitle.id,Playlist_Status__C = 'Active',Version_number__c=1);
        insert playlist;
        
        Playlist_Content__c pc = new Playlist_Content__c(Playlist__c=playlist.id,Content_Title__c=title1.id);
        insert pc;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance1',Country_Code2__c ='AA',Country_Code__c='TC');
        insert countryFrance;   
        
        Country_Groups__c countryGroup=new Country_Groups__c(Name='CountryGroup',Account__c=acct.Id,Country__c=countryFrance.Name);
        insert countryGroup;     
        Language__c languageFrench = new Language__c(Name='TestFrench1',Language_Order__c = 1);
        insert languageFrench;   
        
        Commercial_Avail__c releaseplanCollection = new Commercial_Avail__c(Title__c=collectionTitle.Id,Country_Lookup__c=countryFrance.Id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Audio',Status__c='Tentative',
                                                                    Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+20,Rights_End__c=date.today()+20,Playlist__c=playlist.id);
        insert releaseplanCollection;  
        
        Test.startTest();
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acct.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c='Collection Features; Collection TV; Episode; Feature; Season',
                                                             Channel_Picklist__c = 'EST',Format__c='HD',Status__c ='Active');
        insert storefrontGoogle1;
        
        
        
        WB_Bundle_Avail_Validation.BundleAvailInputWrapper inputWrapper = new WB_Bundle_Avail_Validation.BundleAvailInputWrapper();
        inputWrapper.releasePlans = releaseplanCollection.id;
        inputWrapper.accounts = acct.id;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Audio',Status__c='Tentative',
                                                                    Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+10,Rights_End__c=date.today()+10);
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Audio',Status__c='Draft',
                                                                    Exclusive_Date__c = date.today()-1, Start_Date__c=date.today()+12,End_Date__c= date.today()+20,Rights_End__c=date.today()+20);
        
        List<Commercial_Avail__c> rpList = new List<Commercial_Avail__c>{releaseplan1,releaseplan2};                                                                                                                        
        insert rpList;  
        WB_Bundle_Avail_Validation.getRecords(inputWrapper);
        
        releaseplan2.Start_Date__c = date.today()+11;
        update releaseplan2;
        Test.stopTest();
        WB_Bundle_Avail_Validation.getRecords(inputWrapper);  
        
        Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,                                                   
                                                          Client__c=acct.Id,    Status__c='Tentative',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c );                                                        
        
        Client_Avail__c clientAvail2 = new Client_Avail__c(Commercial_Avail__c=releaseplan2.Id,                                                   
                                                          Client__c=acct.Id,    Status__c='Draft',Start_Date__c=releaseplan2.Start_Date__c+2,End_Date__c=releaseplan2.End_Date__c );                                                        
        
        List<Client_Avail__c> availist = new List<Client_Avail__c>{clientAvail1,clientAvail2};
        insert availist;
        WB_Bundle_Avail_Validation.getRecords(inputWrapper);
                
        clientAvail2.Start_Date__c=releaseplan2.Start_Date__c;
        WB_ClientAvailPriceHandler.recursiveUpdate = true;
        update clientAvail2;
        WB_ClientAvailPriceHandler.recursiveUpdate = false;
        WB_Bundle_Avail_Validation.getRecords(inputWrapper);
        
   }
   */
   
   @isTest
    public static void validateComponentsTest3()
    {
        Account acct = TestUtil.initAccount();
        insert acct;
        //Start -- To create Client Avail 
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        
        Title__c collectionTitle = new Title__c(Name = 'Coll1',MPM__c = mpm.id,Video_Version__c ='1243355670',Content_Type__c=Label.Collection_Features,Digital_Planning__c='Yes',Clear_to_Avail__c = true, Formats__c = 'HD');
        insert collectionTitle;
        
        Title__c title1 = new Title__c(Name = 'Title1',MPM__c = mpm.id,Video_Version__c ='1243355672',Content_Type__c='Feature',Digital_Planning__c='Yes',Clear_to_Avail__c = true, Formats__c = 'HD');
        insert title1; 
        
        Playlist__c playlist = new Playlist__c(name='Standard Playlist',Parent_Title__c=collectionTitle.id,Playlist_Status__C = 'Active',Version_number__c=1);
        insert playlist;
        
        Playlist_Content__c pc = new Playlist_Content__c(Playlist__c=playlist.id,Content_Title__c=title1.id);
        insert pc;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance1',Country_Code2__c ='AA',Country_Code__c='TC');
        insert countryFrance;   
        
        Country_Groups__c countryGroup=new Country_Groups__c(Name='CountryGroup',Account__c=acct.Id,Country__c=countryFrance.Name);
        insert countryGroup;     
        Language__c languageFrench = new Language__c(Name='TestFrench1',Language_Order__c = 1);
        insert languageFrench;   
        
        Commercial_Avail__c releaseplanCollection = new Commercial_Avail__c(Title__c=collectionTitle.Id,Country_Lookup__c=countryFrance.Id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Audio',Status__c='Tentative',
                                                                    Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+20,Rights_End__c=date.today()+20,Playlist__c=playlist.id);
        insert releaseplanCollection;  
        
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acct.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c='Collection Features; Collection TV; Episode; Feature; Season',
                                                             Channel_Picklist__c = 'EST',Format__c='HD',Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        
        Test.startTest();
        
        
        PageReference pageRef = Page.WB_Bundle_Avail_Validation; 
        pageRef.getParameters().put('rpIds', releaseplanCollection.Id);
        pageRef.getParameters().put('clientIds', acct.Id);
        Test.setCurrentPage(pageRef);
        WB_Bundle_Avail_Validation validationContr = new WB_Bundle_Avail_Validation();
        
        WB_Bundle_Avail_Validation.BundleAvailInputWrapper inputWrapper = new WB_Bundle_Avail_Validation.BundleAvailInputWrapper();
        inputWrapper.releasePlans = releaseplanCollection.id;
        inputWrapper.accounts = acct.id;
        inputWrapper.startDateOverride = System.today().format();
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Audio',Status__c='Tentative',
                                                                    Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+10,Rights_End__c=date.today()+10);
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Audio',Status__c='Draft',
                                                                    Exclusive_Date__c = date.today()-1, Start_Date__c=date.today()+12,End_Date__c= date.today()+20,Rights_End__c=date.today()+20);
        
        List<Commercial_Avail__c> rpList = new List<Commercial_Avail__c>{releaseplan1,releaseplan2};                                                                                                                        
        insert rpList;  
        WB_Bundle_Avail_Validation.getRecords(inputWrapper);
        
        releaseplan2.Start_Date__c = date.today()+11;
        update releaseplan2;
        WB_Bundle_Avail_Validation.getRecords(inputWrapper);  
        
        /*
        Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,                                                   
                                                          Client__c=acct.Id,    Status__c='Tentative',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c );                                                        
        
        Client_Avail__c clientAvail2 = new Client_Avail__c(Commercial_Avail__c=releaseplan2.Id,                                                   
                                                          Client__c=acct.Id,    Status__c='Draft',Start_Date__c=releaseplan2.Start_Date__c+2,End_Date__c=releaseplan2.End_Date__c );                                                        
        
        List<Client_Avail__c> availist = new List<Client_Avail__c>{clientAvail1,clientAvail2};
        insert availist;
        WB_Bundle_Avail_Validation.getRecords(inputWrapper);
                
        clientAvail2.Start_Date__c=releaseplan2.Start_Date__c;
        WB_ClientAvailPriceHandler.recursiveUpdate = true;
        update clientAvail2;
        WB_ClientAvailPriceHandler.recursiveUpdate = false;
        WB_Bundle_Avail_Validation.getRecords(inputWrapper);
        */
        WB_Bundle_Avail_Validation.BundleComponentWrapper BundleInstance2 = new WB_Bundle_Avail_Validation.BundleComponentWrapper(); //Akash
        Test.stopTest();
   }
   
    @isTest /*Method added by Akash */
    public static void testMethodForgetRecords()
    {
       TestDataUtility tdu = new TestDataUtility();  
       accList = tdu.createAccountList();
       
       MPM__c m = tdu.createMPM();
       
       List<Title__c> titleList = new List<Title__c>();
       Title__c t = new Title__c(Name = 'Test Collection Feature'
                                        , Video_Version__c = '6000075424'
                                        , Content_Type__c = Label.Collection_Features
                                        , Digital_Planning__c = 'YES'
                                        ,Formats__c = 'HD'
                                        , Clear_to_Avail__c = true
                                        , MPM__c = m.id
                                );
       titleList.add(t);
       system.debug('-----------> Test Collection Feature' +t);
       
       Title__c t1 = new Title__c(Name = 'Test Feature'
                                        , Video_Version__c = '600001234'
                                        , Content_Type__c = 'Feature'
                                        , Digital_Planning__c = 'YES'
                                        ,Formats__c = 'HD'
                                        , Clear_to_Avail__c = true
                                        , MPM__c = m.id
                                );
       titleList.add(t1);
       insert titleList;
       
       system.debug('-----------> Test Feature' +t1);
       
       Language__c l = tdu.createLanguage();
       
       Country__c c = tdu.createCountry();
       
       Country_Groups__c countryGroup=new Country_Groups__c(Name='CountryGroup',Account__c=accList[0].Id,Country__c=c.Name);
       insert countryGroup;
       
       Country_Group_Country__c countryGC = new Country_Group_Country__c (Country_Group__c=countryGroup.Id,Country__c=c.Id);
       insert countryGC; 
       
       Local_Title__c lt = new Local_Title__c ();
       lt.Title__c = t.id;
       lt.country__c = c.id;
       lt.language__c = l.id;
       insert lt;
       
       Playlist__c playlist1 = tdu.createPlaylist(t,c);
       playlist1.Version_Number__c = 1;
       update playlist1;
       system.debug('-----------> playlist1' +playlist1);
       
       Playlist_Content__c playlistCont1 = tdu.createPlaylistContent(t1,playlist1);
       update playlistCont1;
       system.debug('-----------> playlistCont1' +playlistCont1);
       
       //Create Pricing
       Pricing__c newPrice = new Pricing__c();
       newPrice.Content_Type__c = Label.Collection_Features;
       newPrice.Account__c = accList[0].Id;
       newPrice.Country__c = c.Id;
       newPrice.Channel__c = 'EST';
       newPrice.Format__c = 'HD';
       newPrice.WS_Price__c = 120.00;
       insert newPrice;
       
       //Create New releasePlans
       List<Commercial_Avail__c> releasePlansList = new List<Commercial_Avail__c>();
       Commercial_Avail__c rp = new Commercial_Avail__c();
       rp.Title__c= t.Id;
       rp.Country_Lookup__c = c.Id;
       rp.Local_Title__c = lt.Id;
       rp.Languages__c = l.Id;
       rp.Channel__c='EST';
       rp.Format__c='HD';
       rp.Language_Type__c='Sub';
       rp.Status__c='Tentative';
       rp.Exclusive_Date__c = System.today().addDays(-5);
       rp.Start_Date__c = System.today().addDays(-5);
       rp.End_Date__c = System.today();
       rp.Rights_End__c= System.today();
       releasePlansList.add(rp);
       system.debug('-----------> Relase Plan' +rp);
       
       //Create RP1 for validateReleasePlan
       Commercial_Avail__c rp1 = new Commercial_Avail__c();
       rp1.Title__c= t.Id;
       rp1.Country_Lookup__c = c.Id;
       rp1.Local_Title__c = lt.Id;
       rp1.Languages__c = l.Id;
       rp1.Channel__c='EST';
       rp1.Format__c='HD';
       rp1.Language_Type__c='Sub';
       rp1.Status__c='Tentative';
       rp1.Exclusive_Date__c = System.today().addDays(+10);
       rp1.Start_Date__c = System.today().addDays(+10);
       rp1.End_Date__c = System.today().addDays(+30);
       rp1.Rights_End__c= System.today().addDays(+30);
       releasePlansList.add(rp1);
       
       insert releasePlansList;
       Test.startTest();
       Agreement__c sf = tdu.createStorefront(c,rp, t, accList[0]);
       
       
       
       list<Client_Avail__c> CaccListInsert = New list<Client_Avail__c>();
       Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID,Status__c='Tentative',Client__c = accList[0].Id,Title__c = t.id,Start_Date__c=System.today().addDays(-5),End_Date__c=System.today());
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].Id,Title__c = t.id,Start_Date__c=System.today().addDays(-4),End_Date__c=System.today().addDays(-4));
       Client_Avail__c ca2 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].Id,Title__c = t.id,Start_Date__c=System.today().addDays(-3),End_Date__c=System.today().addDays(-3),Announce_Override__c='Suppress'); 
       Client_Avail__c ca3 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].Id,Title__c = t.id,Start_Date__c=System.today().addDays(-2),End_Date__c=System.today().addDays(-2),APO_Date__c=Date.Today().addDays(-45));
       Client_Avail__c ca4 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].Id,Title__c = t.id,Start_Date__c=System.today().addDays(-1),End_Date__c=System.today());
      
       CaccListInsert.add(ca);
       CaccListInsert.add(ca1);
       CaccListInsert.add(ca2); 
       CaccListInsert.add(ca3);
       CaccListInsert.add(ca4);
       insert CaccListInsert;
       system.debug('--------<<< CaccListInsert ----------->>  '+CaccListInsert);
       
        WB_Bundle_Avail_Validation BundleInstance = new WB_Bundle_Avail_Validation();
        String inputDate = '2016-12-31 12:12:12';
        String rpId = rp.id;
        String accId = accList[0].id;
        
        WB_Bundle_Avail_Validation.BundleAvailInputWrapper wrapperInstance = new WB_Bundle_Avail_Validation.BundleAvailInputWrapper();
        wrapperInstance.releasePlans = rpId;
        wrapperInstance.accounts = accId;
        wrapperInstance.startDateOverride = inputDate;
        WB_Bundle_Avail_Validation.getRecords(wrapperInstance);
        
        WB_Bundle_Avail_Validation.BundleComponentWrapper BundleInstance1 = new WB_Bundle_Avail_Validation.BundleComponentWrapper(t.Video_Version__c
        ,t.Name
        ,c.Name
        ,'EST'
        ,'HD'
        ,l.Name
        ,'Sub');
        WB_Bundle_Avail_Validation.validateReleasePlan(rp1, rp, BundleInstance1);
        
        Client_Avail__c ca5 = New Client_Avail__c(Commercial_Avail__c = rp1.ID, Status__c='Draft',Client__c = accList[0].Id,Title__c = t.id,Start_Date__c=System.today().addDays(+15),End_Date__c=System.today().addDays(+20));
        insert ca5;
        WB_Bundle_Avail_Validation.validateClientAvail(rp1, ca5, BundleInstance1);
        WB_Bundle_Avail_Validation.BundleAvailOutputWrapper BundleInstance2 = new WB_Bundle_Avail_Validation.BundleAvailOutputWrapper();
        BundleInstance2.addRPError(BundleInstance1);
        BundleInstance2.addAvailError(BundleInstance1);
        BundleInstance2.sortErrors();
       Test.stopTest();
    }
    
    @isTest /* Method added by Akash*/
    public static void validateComponentsTest4()
    {
        Account acct = TestUtil.initAccount();
        insert acct;
        //Start -- To create Client Avail 
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        
        Title__c collectionTitle = new Title__c(Name = 'Coll1',MPM__c = mpm.id,Video_Version__c ='1243355670',Content_Type__c=Label.Collection_Features,Digital_Planning__c='Yes',Clear_to_Avail__c = true, Formats__c = 'HD');
        insert collectionTitle;
        
        Title__c title1 = new Title__c(Name = 'Title1',MPM__c = mpm.id,Video_Version__c ='1243355672',Content_Type__c='Feature',Digital_Planning__c='Yes',Clear_to_Avail__c = true, Formats__c = 'HD');
        insert title1; 
        
        Playlist__c playlist = new Playlist__c(name='Standard Playlist',Parent_Title__c=collectionTitle.id,Playlist_Status__C = 'Active',Version_number__c=1);
        insert playlist;
        
        Playlist_Content__c pc = new Playlist_Content__c(Playlist__c=playlist.id,Content_Title__c=title1.id);
        insert pc;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance1',Country_Code2__c ='AA',Country_Code__c='TC');
        insert countryFrance;   
        
        Country_Groups__c countryGroup=new Country_Groups__c(Name='CountryGroup',Account__c=acct.Id,Country__c=countryFrance.Name);
        insert countryGroup;     
        Language__c languageFrench = new Language__c(Name='TestFrench1',Language_Order__c = 1);
        insert languageFrench;   
        
        Commercial_Avail__c releaseplanCollection = new Commercial_Avail__c(Title__c=collectionTitle.Id,Country_Lookup__c=countryFrance.Id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Audio',Status__c='Tentative',
                                                                    Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+20,Rights_End__c=date.today()+20,Playlist__c=playlist.id);
        insert releaseplanCollection;  
        
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acct.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c='Collection Features; Collection TV; Episode; Feature; Season',
                                                             Channel_Picklist__c = 'EST',Format__c='HD',Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        
        Test.startTest();
        
        
        PageReference pageRef = Page.WB_Bundle_Avail_Validation; 
        pageRef.getParameters().put('rpIds', releaseplanCollection.Id);
        pageRef.getParameters().put('clientIds', acct.Id);
        Test.setCurrentPage(pageRef);
        WB_Bundle_Avail_Validation validationContr = new WB_Bundle_Avail_Validation();
        
        WB_Bundle_Avail_Validation.BundleAvailInputWrapper inputWrapper = new WB_Bundle_Avail_Validation.BundleAvailInputWrapper();
        inputWrapper.releasePlans = releaseplanCollection.id;
        inputWrapper.accounts = acct.id;
        inputWrapper.startDateOverride = System.today().format();
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Audio',Status__c='Tentative',
                                                                    Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+10,Rights_End__c=date.today()+10);
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Audio',Status__c='Draft',
                                                                    Exclusive_Date__c = date.today()-1, Start_Date__c=date.today()+12,End_Date__c= date.today()+20,Rights_End__c=date.today()+20);
        
        List<Commercial_Avail__c> rpList = new List<Commercial_Avail__c>{releaseplan1};                                                                                                                        
        insert rpList;  
        WB_Bundle_Avail_Validation.getRecords(inputWrapper);
        
        WB_Bundle_Avail_Validation.BundleComponentWrapper BundleInstance2 = new WB_Bundle_Avail_Validation.BundleComponentWrapper(); //Akash
        Test.stopTest();
   }
   
    @isTest /* Method added by Akash*/
    public static void validateComponentsTest5()
    {
        Account acct = TestUtil.initAccount();
        insert acct;
        //Start -- To create Client Avail 
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        
        Title__c collectionTitle = new Title__c(Name = 'Coll1',MPM__c = mpm.id,Video_Version__c ='1243355670',Content_Type__c=Label.Collection_Features,Digital_Planning__c='Yes',Clear_to_Avail__c = true, Formats__c = 'HD');
        insert collectionTitle;
        
        Title__c title1 = new Title__c(Name = 'Title1',MPM__c = mpm.id,Video_Version__c ='1243355672',Content_Type__c='Feature',Digital_Planning__c='Yes',Clear_to_Avail__c = true, Formats__c = 'HD');
        insert title1; 
        
        Playlist__c playlist = new Playlist__c(name='Standard Playlist',Parent_Title__c=collectionTitle.id,Playlist_Status__C = 'Active',Version_number__c=1);
        insert playlist;
        
        Playlist_Content__c pc = new Playlist_Content__c(Playlist__c=playlist.id,Content_Title__c=title1.id);
        insert pc;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance1',Country_Code2__c ='AA',Country_Code__c='TC');
        insert countryFrance;   
        
        Country_Groups__c countryGroup=new Country_Groups__c(Name='CountryGroup',Account__c=acct.Id,Country__c=countryFrance.Name);
        insert countryGroup;     
        Language__c languageFrench = new Language__c(Name='TestFrench1',Language_Order__c = 1);
        insert languageFrench;   
        
        Commercial_Avail__c releaseplanCollection = new Commercial_Avail__c(Title__c=collectionTitle.Id,Country_Lookup__c=countryFrance.Id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Audio',Status__c='Tentative',
                                                                    Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+10,Rights_End__c=date.today()+25,Playlist__c=playlist.id);
        insert releaseplanCollection;  
        
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acct.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c='Collection Features; Collection TV; Episode; Feature; Season',
                                                             Channel_Picklist__c = 'EST',Format__c='HD',Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        
        Test.startTest();
        
        
        PageReference pageRef = Page.WB_Bundle_Avail_Validation; 
        pageRef.getParameters().put('rpIds', releaseplanCollection.Id);
        pageRef.getParameters().put('clientIds', acct.Id);
        Test.setCurrentPage(pageRef);
        WB_Bundle_Avail_Validation validationContr = new WB_Bundle_Avail_Validation();
        
        WB_Bundle_Avail_Validation.BundleAvailInputWrapper inputWrapper = new WB_Bundle_Avail_Validation.BundleAvailInputWrapper();
        inputWrapper.releasePlans = releaseplanCollection.id;
        inputWrapper.accounts = acct.id;
        inputWrapper.startDateOverride = System.today().format();
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Audio',Status__c='Tentative',
                                                                    Exclusive_Date__c = date.today()-1, Start_Date__c=date.today()+20,End_Date__c= date.today()+50,Rights_End__c=date.today()+50);
        
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Audio',Status__c='Draft',
                                                                    Exclusive_Date__c = date.today()-1, Start_Date__c=date.today()+12,End_Date__c= date.today()+15,Rights_End__c=date.today()+200);
                                                                    
        
        List<Commercial_Avail__c> rpList = new List<Commercial_Avail__c>{releaseplan1,releaseplan2};                                                                                                                        
        insert rpList;  
        WB_Bundle_Avail_Validation.getRecords(inputWrapper);
        
        Test.stopTest();
   }
}