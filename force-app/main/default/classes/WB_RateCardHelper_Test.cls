@isTest 
private class WB_RateCardHelper_Test{
    
    public static List<Title__c> title_List = new List<Title__c>();
    public static List<Country__c> country_List = new List<Country__c>();
    public static List<Pricing__c> price_List = new List<Pricing__c>();
    public static Playlist__c playlist123;
    public static Playlist__c playlist1;
    public static List<Client_Avail__c> listClientavails;
    static List<Country_SID_Key__c> countrySIDList = new List<Country_SID_Key__c>();
    public static List<Local_Title__c> localDataList = new List<Local_Title__c>();
    static List<Client_Avail_Price__c> clAvailPriceList = new List<Client_Avail_Price__c>();
    private static Id standardPricebookId ;
    public static Account objAccount;
    static Id rtAcDC =  [SELECT Id FROM RecordType WHERE DeveloperName = 'Digital_Client'][0].Id;
    
    static {
        if(standardPricebookId ==  null){
            standardPricebookId = System.Test.getStandardPricebookId();
        }
    }
    
    static Id rtAcc =  CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
    
    @isTest
    public Static Void getStepPrice_Test(){
        
        PriceBook2 pb = new PriceBook2();
        pb.Name = 'TestPB1';
        pb.Currency__c = 'USD';
        //pb.Distribution_Channel__c = '10';
        pb.External_Id__c = '6000-10-0012020726';
        pb.Business_Unit__c = '6000';
        Insert pb;
        
       // Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        objAccount = new Account(Name ='TestAccount ',
                        Planning_Customer__c = true,
                        Price_Book__c = standardPricebookId,
                        Games_Physical__c=True,
                        Video_Physical__c=True,
                        Status__c='N');
        objAccount.RecordTypeID = rtAcc;
        objAccount.CurrencyIsoCode = 'USD';
        objAccount.Price_Book__c = pb.Id;  
        insert objAccount;
        
        Account acctGoogle = new Account(Name ='TestGoogle ',
                        Planning_Customer__c = true,
                        Price_Book__c = standardPricebookId,
                        Games_Physical__c=True,
                        Video_Physical__c=True,
                        Status__c='N');
       acctGoogle.RecordTypeID = rtAcDC;
       acctGoogle.CurrencyIsoCode = 'USD';
       acctGoogle.Price_Book__c = pb.Id;  
       insert acctGoogle;
       
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title1);
        
        Title__c title2 = new Title__c(Name = 'HIMYM',Video_Version__c ='6000047541',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title2);
        
        Title__c title3 = new Title__c(Name = 'DDLJ',Video_Version__c ='6000047542',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        title_List.add(title3);
        
        insert title_List;
        
        Country__c countryFrance =new Country__c(Name ='France',Country_Code2__c ='FR',Country_Code__c='FRA',Generate_CRM_Product__c = true);
        country_List.add(countryFrance);
        //insert countryFrance;
        
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ');
        country_List.add(countryJapan);
        
        insert country_List;
        
        Language__c languageFrench = new Language__c(Name='English',Language_Order__c = 1,Language_Code_2__c = 'en');
        insert languageFrench;
        
        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
            Country__c = country_List[0].Id,Channel__c ='EST',Format__c ='SD',Price_Code_Status__c = 'Active',WS_Price__c = 5
        );
        price_List.add(price1);
        //insert price1;
        
        Pricing__c price2 = new Pricing__c(Name ='New Release',Account__c = acctGoogle.Id,Content_Type__c = title_List[1].Content_Type__c,
            Country__c = country_List[0].Id,Channel__c ='EST',Format__c ='SD',Price_Code_Status__c = 'Active',Price_Tier__c = '63.12'
        );
        price_List.add(price2);
        
        Pricing__c price3 = new Pricing__c(Name ='New Release1',Account__c = acctGoogle.Id,Content_Type__c = title_List[1].Content_Type__c,
            Country__c = country_List[0].Id,Channel__c ='EST',Format__c ='SD',Price_Code_Status__c = 'Active',Price_Tier__c = '56.36'
        );
        price_List.add(price3);
        
        insert price_List;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title_List[0].Id,Country__c = country_List[0].Id,
                                Language__c =languageFrench.Id,Price_Code__c =price_List[0].Name);
                                
        localDataList.add(local1);
        
        Local_Title__c local2 = new Local_Title__c(Name = 'local1',Title__c =title_List[1].Id,Country__c = country_List[0].Id,
                                Language__c =languageFrench.Id,Price_Code__c =price_List[1].Name,Local_DVD_Release_Date__c = system.today()+5);
                                
        localDataList.add(local2);
        
        Local_Title__c local3 = new Local_Title__c(Name = 'local1',Title__c =title_List[2].Id,Country__c = country_List[0].Id,
                                Language__c =languageFrench.Id,Price_Code__c =price_List[2].Name);
                                
        localDataList.add(local3);
        
        insert localDataList;
        
        Product_Creation_Batch_Setting__c pc = new Product_Creation_Batch_Setting__c();
        pc.Name = 'Default';
        pc.Generate_CRM_Product__c = true;
        pc.Last_N_Days__c = null;
        insert pc;
        
        String productRecTypeId = WB_PriceUtility.getRecordTypeId(Product2.getSobjectType(),'Digital Product');
       Product2 insertProd = new Product2();
       insertProd.RecordTypeId = productRecTypeId;
       insertProd.Name = 'Test Product';
       insertProd.ProductCode = '6000047541';
       insertProd.Type__c = 'Video Digital';
       insertProd.Product_Market__c ='EST';
       insertProd.Product_Format__c = 'SD';
       insertProd.Local_Title__c = localDataList[1].Id;
       insertProd.External_Id__c = 'FRA_en_6000047541_EST_SD';
       insert insertProd;
        
        List<Commercial_Avail__c> rpList = new List<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title_List[0].Id,Country_Lookup__c=country_List[0].Id,Local_Title__c = localDataList[0].Id,
                Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='SD',Language_Type__c='Sub & Audio',Status__c='Confirmed',
                Exclusive_Date__c = date.today()-200, Start_Date__c=date.today()-100,End_Date__c= date.today()+100,Rights_End__c=date.today()+200
                
        );
        rpList.add(releaseplan1);
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(Title__c=title_List[1].Id,Country_Lookup__c=country_List[0].Id,Local_Title__c = localDataList[1].Id,
                Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='SD',Language_Type__c='Sub & Audio',Status__c='Confirmed',
                Exclusive_Date__c = date.today()-200, Start_Date__c=date.today()-100,End_Date__c= date.today()+100,Rights_End__c=date.today()+200
                
        );
        rpList.add(releaseplan2);
        
        Commercial_Avail__c releaseplan3 = new Commercial_Avail__c(Title__c=title_List[2].Id,Country_Lookup__c=country_List[0].Id,Local_Title__c = localDataList[2].Id,
                Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='SD',Language_Type__c='Sub & Audio',Status__c='Confirmed',
                Exclusive_Date__c = date.today()-200, Start_Date__c=date.today()-100,End_Date__c= date.today()+100,Rights_End__c=date.today()+200
                
        );
        rpList.add(releaseplan3);
        
        
        insert rpList;
        
        rpList[1].Product__c = insertProd.Id;
        update rpList[1];
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=country_List[0].Id, Pricing_Currency__c='FR', Content_Type__c=title_List[0].Content_Type__c,
            Channel_Picklist__c=rpList[0].Channel__c, Format__c=rpList[0].Format__c, Status__c ='Active',CRM_Storefront__c = true,Selected_Combination__c = 'Feature_EST_SD',
            CRM_Account__c = objAccount.Id,SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1; 
        
        countrySIDList.add(new Country_SID_Key__c(Name='France', Country_Code__c='FRA',Country_Code2_c__c='FR',Locale_SID_Key__c='Europe/Lisbon',Region__c='Western Europe'));
        insert countrySIDList;
        
        
        List<Rate_Card__c> rcList = new List<Rate_Card__c>();
        
        Rate_Card__c rc = new Rate_Card__c();
        rc.Channel__c = rpList[0].Channel__c;
        rc.Country__c = country_List[0].Id;
        rc.Account__c = acctGoogle.Id;
        rc.Start_Date__c = date.today();
        rc.End_Date__c = date.today()+200;
        rc.Content_Type__c = title_List[0].Content_Type__c;
        rc.Format__c = rpList[0].Format__c;
        rc.WSP1__c = 5;
        rc.Rate_Card_Type__c = 'WSP';
        rc.Storefront__c = storefrontGoogle1.Id;
        rcList.add(rc);
        
        Rate_Card__c rc_1 = new Rate_Card__c();
        rc_1.Channel__c = rpList[0].Channel__c;
        rc_1.Country__c = country_List[0].Id;
        rc_1.Account__c = acctGoogle.Id;
        rc_1.Start_Date__c = date.today();
        rc_1.End_Date__c = date.today()+200;
        rc_1.Content_Type__c = title_List[0].Content_Type__c;
        rc_1.Format__c = rpList[0].Format__c;
        rc_1.WSP1__c = 8.0;
        rc_1.Rate_Card_Type__c = 'WSP';
        rc_1.Storefront__c = storefrontGoogle1.Id;
        rcList.add(rc_1);
        
        Rate_Card__c rc1 = new Rate_Card__c();
        rc1.Channel__c = rpList[1].Channel__c;
        rc1.Country__c = country_List[0].Id;
        rc1.Account__c = acctGoogle.Id;
        rc1.Start_Date__c = date.today();
        rc1.End_Date__c = date.today()+200;
        rc1.Content_Type__c = title_List[1].Content_Type__c;
        rc1.Format__c = rpList[1].Format__c;
        rc1.Price_Tier__c = '63.12';
        rc1.WSP1__c = 5;
        rc1.WSP2__c = 8;
        rc1.WSP3__c = 12;
        rc1.Rate_Card_Type__c = 'Step DVD 6/18';
        rc1.Storefront__c = storefrontGoogle1.Id;
        //rc1.Step_Pricing__c = true;
        rcList.add(rc1);
        
        Rate_Card__c rc_2 = new Rate_Card__c();
        rc_2.Channel__c = rpList[1].Channel__c;
        rc_2.Country__c = country_List[0].Id;
        rc_2.Account__c = acctGoogle.Id;
        rc_2.Start_Date__c = date.today();
        rc_2.End_Date__c = date.today()+200;
        rc_2.Content_Type__c = title_List[1].Content_Type__c;
        rc_2.Format__c = rpList[1].Format__c;
        rc_2.Price_Tier__c = '39.2';
        rc_2.WSP1__c = 5;
        rc_2.WSP2__c = 8;
        rc_2.WSP3__c = 12;
        rc_2.Rate_Card_Type__c = 'Step DVD 6/18';
        rc_2.Storefront__c = storefrontGoogle1.Id;
        rcList.add(rc_2);
        
        Rate_Card__c rc_3 = new Rate_Card__c();
        rc_3.Channel__c = rpList[2].Channel__c;
        rc_3.Country__c = country_List[0].Id;
        rc_3.Account__c = acctGoogle.Id;
        rc_3.Start_Date__c = date.today();
        rc_3.End_Date__c = date.today()+200;
        rc_3.Content_Type__c = title_List[2].Content_Type__c;
        rc_3.Format__c = rpList[1].Format__c;
        rc_3.Price_Tier__c = '56.36';
        rc_3.WSP1__c = 5;
        rc_3.WSP2__c = 8;
        rc_3.WSP3__c = 12;
        rc_3.Rate_Card_Type__c = 'Step DVD 6/18';
        rc_3.Storefront__c = storefrontGoogle1.Id;
        rcList.add(rc_3);
        
        insert rcList;
        
        listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(acctGoogle.Id, rpList[0], localDataList[0].Id);
        clientAvail.Start_Date__c = system.today()+2;
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Tentative';
        clientAvail.Price_Tier_Text__c = Null;
        clientAvail.Price__c = 5;
        //clientAvail.Episode_Price_Tier__c = 'reprice12';
        clientAvail.Local_Data_Category_Picklist__c = 'New Release';
        clientAvail.Storefront__c = storefrontGoogle1.Id;
        //clientAvail.Channel__c = 'VODi';
        listClientavails.add(clientAvail);
        
        //listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(acctGoogle.Id, rpList[1], localDataList[1].Id);
        clientAvail1.Start_Date__c = system.today()+2;
        clientAvail1.End_Date__c = system.today()+70;
        clientAvail1.Status__c = 'Tentative';
        clientAvail1.Price_Tier_Text__c = '63.12';
        clientAvail1.Local_Data_Category_Picklist__c = 'New Release';
        clientAvail1.Storefront__c = storefrontGoogle1.Id;
        listClientavails.add(clientAvail1);
        
        Client_Avail__c clientAvail_2 = TestUtil.initClientAvail(acctGoogle.Id, rpList[2], localDataList[2].Id);
        clientAvail_2.Start_Date__c = system.today()+2;
        clientAvail_2.End_Date__c = system.today()+70;
        clientAvail_2.Status__c = 'Tentative';
        clientAvail_2.Price_Tier_Text__c = '56.36';
        clientAvail_2.Local_Data_Category_Picklist__c = 'New Release';
        clientAvail_2.Storefront__c = storefrontGoogle1.Id;
        listClientavails.add(clientAvail_2);
        
        insert listClientavails;
        
        //List<Client_Avail__c> caList = [Select Id,Client__c,Release_Plan_Country__c,Release_Plan_Channel__c,Release_Plan_Format__c,Title_Content_Type__c,Price_Tier_Text__c,Price__c,Start_Date__c,CA_Rate_Card__c FROM Client_Avail__c];
        //system.debug(LoggingLevel.INFO,'$$$$$$$$$$$$$caList:'+caList);
        
        String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
        String tpRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME);
        
        clAvailPriceList.add(new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c = listClientavails[0].id,Effective_Date__c=system.today()+15,Expiry_Date__c=system.today()+24,Price__c=5.0,Type__c= WB_PriceUtility.FIRST,Category__c='Catalog'));
        clAvailPriceList.add(new Client_Avail_Price__c(RecordTypeId=tpRecTypeId,Client_Avail__c = listClientavails[0].id,Effective_Date__c=system.today()+25,Expiry_Date__c=system.today()+34,Price__c=8.0,Category__c='Catalog'));
        clAvailPriceList.add(new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c = listClientavails[0].id,Effective_Date__c=system.today()+35,Expiry_Date__c=listClientavails[0].End_Date__c,Price__c=90.0,Type__c= 'Reprice',Category__c='Catalog')); 
        clAvailPriceList.add(new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c = listClientavails[1].id,Effective_Date__c=system.today()+15,Expiry_Date__c=system.today()+24,Price_Tier__c='63.12',Type__c= WB_PriceUtility.FIRST,Category__c='Catalog'));
        clAvailPriceList.add(new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c = listClientavails[1].id,Effective_Date__c=system.today()+25,Expiry_Date__c=listClientavails[1].End_Date__c,Price_Tier__c='39.2',Type__c= 'Reprice',Category__c='Catalog'));
        clAvailPriceList.add(new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c = listClientavails[2].id,Effective_Date__c=system.today()+15,Expiry_Date__c=system.today()+24,Price_Tier__c='56.36',Type__c= WB_PriceUtility.FIRST,Category__c='Catalog'));
        
        test.startTest();
        insert clAvailPriceList;
        
        List<Client_Avail_Price__c> capList = [Select Id,Account__c,Country__c,CAP_Rate_Card__r.Step1_Length_Months__c,CAP_Rate_Card__r.Step_Pricing__c,CAP_Rate_Card__r.Step2_Length_Months__c,CA_Local_DVD_Rel_Date__c,Client_Avail_Channel__c,Client_Avail_Format__c,Title_Content_Type__c,Price_Tier__c,Price__c,Effective_Date__c,CAP_Rate_Card__c FROM Client_Avail_Price__c];
        
        List<Rate_Card__c> rcList1 = [Select Id,Step_Pricing__c,Price_Tier__c,WSP1__c,WSP2__c,WSP3__c,Rate_Card_Type__c,Step1_Length_Months__c,Step2_Length_Months__c FROM Rate_Card__c];
        
        WB_RateCardHelper.getStepPrice(capList[3],rcList1[2]);
        WB_RateCardHelper.getStepPrice(capList[3]);
        WB_RateCardHelper.getStepPrice(capList[4],rcList1[2]);
        WB_RateCardHelper.getStepPrice(capList[4]);
        WB_RateCardHelper.getStepPrice(capList[5]);
        WB_RateCardHelper.getStepPrice(capList[5],rcList1[4]);
        
        rcList[3].Price_Tier__c = '32.8';
        rcList[3].WSP1__c = 6;
        rcList[3].SRP__c = 3;
        update rcList[3];
        
        test.stopTest();
        
        
    }
   @isTest
    public Static Void getSeasonPrice_Test(){
        
        PriceBook2 pb = new PriceBook2();
        pb.Name = 'TestPB1';
        pb.Currency__c = 'USD';
        //pb.Distribution_Channel__c = '10';
        pb.External_Id__c = '6000-10-0012020726';
        pb.Business_Unit__c = '6000';
        Insert pb;
        
       // Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        objAccount = new Account(Name ='TestAccount ',
                        Planning_Customer__c = true,
                        Price_Book__c = standardPricebookId,
                        Games_Physical__c=True,
                        Video_Physical__c=True,
                        Status__c='N');
        objAccount.RecordTypeID = rtAcc;
        objAccount.CurrencyIsoCode = 'USD';
        objAccount.Price_Book__c = pb.Id;  
        insert objAccount;
        
        Account acctGoogle = new Account(Name ='TestGoogle ',
                        Planning_Customer__c = true,
                        Price_Book__c = standardPricebookId,
                        Games_Physical__c=True,
                        Video_Physical__c=True,
                        Status__c='N');
       acctGoogle.RecordTypeID = rtAcDC;
       acctGoogle.CurrencyIsoCode = 'USD';
       acctGoogle.Price_Book__c = pb.Id;  
       insert acctGoogle;
        Title__c title2 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='HD');
        title_List.add(title2);
      
        
        Title__c title3 = new Title__c(Name = 'Vampire',Video_Version__c ='000000002',Content_Type__c='Episode',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='HD');
        title_List.add(title3);
        
         Title__c title4 = new Title__c(Name = 'TestGoogle1',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='HD');
        title_List.add(title4);
        
        Title__c title5 = new Title__c(Name = 'Vampire1',Video_Version__c ='000000003',Content_Type__c='Episode',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='HD');
        title_List.add(title5);
        
        insert title_List;
        List<Playlist__c> playlist = new List<Playlist__c>();
        Playlist__c playlist123 = new Playlist__c();
        playlist123.name = 'test playlist';
        playlist123.Version_Number__c = 1;
        playlist123.Parent_Title__c = title2.id;
        playlist123.Playlist_Status__c = 'Active';
        playlist.add(playlist123);
    
        Playlist__c  playlist1 = new Playlist__c();
        playlist1.name = 'test playlist1';
        playlist1.Version_Number__c = 2;
        playlist1.Parent_Title__c = title4.id;
        playlist1.Playlist_Status__c = 'Active';
        playlist.add(playlist1);
        insert playlist;
        
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=title3.id;
        content.Playlist__c = playlist123.id;
        contentlist.add(content);
        
        Playlist_Content__c content2 = new Playlist_Content__c();
        content2.Content_Title__c=title5.id;
        content2.Playlist__c = playlist1.id;
        contentlist.add(content2);
        
        insert contentlist;
        
        Country__c countryFrance =new Country__c(Name ='France',Country_Code2__c ='FR',Country_Code__c='FRA',Generate_CRM_Product__c = true);
        country_List.add(countryFrance);
        
        insert country_List;
        
        Language__c languageFrench = new Language__c(Name='English',Language_Order__c = 1,Language_Code_2__c = 'en');
        insert languageFrench;
        
        Pricing__c price2 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
            Country__c = country_List[0].Id,Channel__c ='EST',Format__c ='HD',Price_Code_Status__c = 'Active',Price_Tier__c = '63.12',Episode_Price_Tier__c='89.9'
        );
        price_List.add(price2);
        
        
        Pricing__c price3 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title_List[1].Content_Type__c,
            Country__c = country_List[0].Id,Channel__c ='EST',Format__c ='HD',Price_Code_Status__c = 'Active',Price_Tier__c = '89.9'
        );
        
        price_List.add(price3);
        
        Pricing__c price4 = new Pricing__c(Name ='Pr2',Account__c = acctGoogle.Id,Content_Type__c = 'Season',
            Country__c = country_List[0].Id,Channel__c ='EST',Format__c ='HD',Price_Code_Status__c = 'Active',Price_Tier__c = '15.2',Episode_Price_Tier__c='10.9'
        );
        price_List.add(price4);
        
        Pricing__c price5 = new Pricing__c(Name ='Pr2',Account__c = acctGoogle.Id,Content_Type__c = 'Epiosde',
            Country__c = country_List[0].Id,Channel__c ='EST',Format__c ='HD',Price_Code_Status__c = 'Active',Price_Tier__c='10.9'
        );
        price_List.add(price5);
        
        
        insert price_List;
        
        Local_Title__c local2 = new Local_Title__c(Name = 'local2',Title__c =title_List[0].Id,Country__c = country_List[0].Id,
                                Language__c =languageFrench.Id,Price_Code__c =price_List[0].Name);
                    
        localDataList.add(local2);                        
        Local_Title__c local3 = new Local_Title__c(Name = 'local3',Title__c =title_List[1].Id,Country__c = country_List[0].Id,
                                Language__c =languageFrench.Id,Price_Code__c =price_List[1].Name);                        
        localDataList.add(local3);                        
        
        Local_Title__c local4 = new Local_Title__c(Name = 'local4',Title__c =title_List[2].Id,Country__c = country_List[0].Id,
                                Language__c =languageFrench.Id,Price_Code__c =price_List[2].Name);
                    
        localDataList.add(local4);    
        
         Local_Title__c local5 = new Local_Title__c(Name = 'local4',Title__c =title_List[3].Id,Country__c = country_List[0].Id,
                                Language__c =languageFrench.Id);
                    
        localDataList.add(local5);  
        
        insert localDataList;
        
        Product_Creation_Batch_Setting__c pc = new Product_Creation_Batch_Setting__c();
        pc.Name = 'Default';
        pc.Generate_CRM_Product__c = true;
        pc.Last_N_Days__c = null;
        insert pc;
        
       String productRecTypeId = WB_PriceUtility.getRecordTypeId(Product2.getSobjectType(),'Digital Product');
       Product2 insertProd = new Product2();
       insertProd.RecordTypeId = productRecTypeId;
       insertProd.Name = 'Test Product';
       insertProd.ProductCode = '6000047541';
       insertProd.Type__c = 'Video Digital';
       insertProd.Product_Market__c ='EST';
       insertProd.Product_Format__c = 'HD';
       insertProd.Local_Title__c = localDataList[0].Id;
       insertProd.External_Id__c = 'FRA_en_6000047541_EST_HD';
       insert insertProd;
       
     
        
        List<Commercial_Avail__c> rpList = new List<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title_List[0].Id,Country_Lookup__c=country_List[0].Id,Local_Title__c = localDataList[0].Id,
                Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Sub & Audio',Status__c='Confirmed',
                Exclusive_Date__c = date.today()-200, Start_Date__c=date.today()-100,End_Date__c= date.today()+100,Rights_End__c=date.today()+200
                
        );
        rpList.add(releaseplan1);
    
        Commercial_Avail__c releaseplan3 = new Commercial_Avail__c(Title__c=title_List[2].Id,Country_Lookup__c=country_List[0].Id,Local_Title__c = localDataList[2].Id,
                Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Sub & Audio',Status__c='Confirmed',
                Exclusive_Date__c = date.today()-200, Start_Date__c=date.today()-100,End_Date__c= date.today()+100,Rights_End__c=date.today()+200
                
        );
        rpList.add(releaseplan3);
    
        
        
        insert rpList;

        rpList[0].Product__c = insertProd.Id;
    
        update rpList[0];
      
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=country_List[0].Id, Pricing_Currency__c='FR', Content_Type__c='Season;Episode',
            Channel_Picklist__c=rpList[0].Channel__c, Format__c=rpList[0].Format__c, Status__c ='Active',CRM_Storefront__c = true,Selected_Combination__c = 'Season_EST_HD',
            CRM_Account__c = objAccount.Id,SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1;
        

        countrySIDList.add(new Country_SID_Key__c(Name='France', Country_Code__c='FRA',Country_Code2_c__c='FR',Locale_SID_Key__c='Europe/Lisbon',Region__c='Western Europe'));
        insert countrySIDList;
        
        List<Rate_Card__c> rcList = new List<Rate_Card__c>();
        
        Rate_Card__c rc = new Rate_Card__c();
        rc.Channel__c = rpList[0].Channel__c;
        rc.Country__c = country_List[0].Id;
        rc.Account__c = acctGoogle.Id;
        rc.Start_Date__c = date.today();
        rc.End_Date__c = date.today()+200;
        rc.Content_Type__c = title_List[0].Content_Type__c;
        rc.Format__c = rpList[0].Format__c;
        rc.Price_Tier__c = '63.12';
        //rc.WSP1__c = 5;
        rc.Rate_Card_Type__c = 'Standard';
        rc.Storefront__c = storefrontGoogle1.Id;
        rcList.add(rc);
        
        Rate_Card__c rc1 = new Rate_Card__c();
        rc1.Channel__c = rpList[0].Channel__c;
        rc1.Country__c = country_List[0].Id;
        rc1.Account__c = acctGoogle.Id;
        rc1.Start_Date__c = date.today();
        rc1.End_Date__c = date.today()+200;
        rc1.Content_Type__c ='Episode';
        rc1.Format__c = rpList[0].Format__c;
        rc.Price_Tier__c = '89.9';
        //rc.WSP1__c = 5;
        rc1.Rate_Card_Type__c = 'Standard';
        rc1.Storefront__c = storefrontGoogle1.Id;
        rcList.add(rc1);
        
        
        Rate_Card__c rc2 = new Rate_Card__c();
        rc2.Channel__c = rpList[1].Channel__c;
        rc2.Country__c = country_List[0].Id;
        rc2.Account__c = acctGoogle.Id;
        rc2.Start_Date__c = date.today();
        rc2.End_Date__c = date.today()+200;
        rc2.Content_Type__c ='Season';
        rc2.Format__c = rpList[1].Format__c;
        rc2.Price_Tier__c = '15.2';
       // rc2.WSP1__c= 10.9;
        rc2.Rate_Card_Type__c = 'Standard';
        rc2.Storefront__c = storefrontGoogle1.Id;
        rcList.add(rc2);
        
        Rate_Card__c rc3 = new Rate_Card__c();
        rc3.Channel__c = rpList[1].Channel__c;
        rc3.Country__c = country_List[0].Id;
        rc3.Account__c = acctGoogle.Id;
        rc3.Start_Date__c = date.today();
        rc3.End_Date__c = date.today()+200;
        rc3.Content_Type__c ='Episode';
        rc3.Format__c = rpList[1].Format__c;
       //rc.Price_Tier__c = '89.9';
        rc3.Price_Tier__c= '10.9';
        rc3.Rate_Card_Type__c = 'Standard';
        rc3.Storefront__c = storefrontGoogle1.Id;
        rcList.add(rc3);
        
        insert rcList;
        
        listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(acctGoogle.Id, rpList[0], localDataList[0].Id);
        clientAvail.Start_Date__c = system.today()+2;
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Confirmed';
        //clientAvail.Price_Tier_Text__c = Null;
        clientAvail.Price_Tier_Text__c = '63.12';
        clientAvail.Episode_Price_Tier__c = '89.9';
        clientAvail.Local_Data_Category_Picklist__c = 'New Release';
        clientAvail.Storefront__c = storefrontGoogle1.Id;
        //clientAvail.Channel__c = 'EST';
        clientAvail.Playlist__c = playlist123.id;
        listClientavails.add(clientAvail);
        
        
        Client_Avail__c clientAvail2 = TestUtil.initClientAvail(acctGoogle.Id, rpList[0], localDataList[1].Id);
        clientAvail2.Start_Date__c = system.today()+2;
        clientAvail2.End_Date__c = system.today()+70;
        clientAvail2.Status__c = 'Confirmed';
        //clientAvail.Price_Tier_Text__c = Null;
        clientAvail2.Price_Tier_Text__c = '89.9';
        clientAvail2.Storefront__c = storefrontGoogle1.Id;
        //clientAvail2.Parent_Client_Avail__c=listClientavails.id;
        //clientAvail.Channel__c = 'EST';
        clientAvail2.Local_Data_Category_Picklist__c = 'New Release';
       listClientavails.add(clientAvail2);
        
        
        Client_Avail__c clientAvail3 = TestUtil.initClientAvail(acctGoogle.Id, rpList[1], localDataList[2].Id);
        clientAvail3.Start_Date__c = system.today()+2;
        clientAvail3.End_Date__c = system.today()+70;
        clientAvail3.Status__c = 'Confirmed';
        //clientAvail.Price_Tier_Text__c = Null;
        clientAvail3.Price_Tier_Text__c = '15.2';
        clientAvail3.Episode_Price__c=10.9;
        //clientAvai3.Episode_Price_Tier__c = '89.9';
        clientAvail3.Local_Data_Category_Picklist__c = 'New Release';
        clientAvail3.Storefront__c = storefrontGoogle1.Id;
        //clientAvail.Channel__c = 'EST';
        clientAvail3.Playlist__c = playlist1.id;
       // listClientavails.add(clientAvail3);
        
       Client_Avail__c clientAvail4 = TestUtil.initClientAvail(acctGoogle.Id, rpList[1], localDataList[3].Id);
        clientAvail4.Start_Date__c = system.today()+2;
        clientAvail4.End_Date__c = system.today()+70;
        clientAvail4.Status__c = 'Confirmed';
        clientAvail4.Storefront__c = storefrontGoogle1.Id;
        insert listClientavails;
        
        List<Client_Avail__c> caepisiodelist=new List<Client_Avail__c>();
        
        listClientavails[1].Parent_Client_Avail__c=listClientavails[0].id;
        
        listClientavails[1].Recalculate_Playlist_Avails__c='';
        caepisiodelist.add(listClientavails[1]);
        update caepisiodelist;
    
        test.startTest();
        
        String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
        String tpRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME);
        
        clAvailPriceList.add(new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c = listClientavails[0].id,Effective_Date__c=system.today()+30,Price_Tier__c='15.2',Episode_Price_Tier__c='10.9',Type__c='Reprice',Category__c='Catalog'));
        insert clAvailPriceList;
       test.stopTest();
        
    }
    
    @isTest
    public Static Void getSeasonEpisodePrice_Test(){
        
        PriceBook2 pb = new PriceBook2();
        pb.Name = 'TestPB1';
        pb.Currency__c = 'USD';
        //pb.Distribution_Channel__c = '10';
        pb.External_Id__c = '6000-10-0012020726';
        pb.Business_Unit__c = '6000';
        Insert pb;
        
       // Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        
        objAccount = new Account(Name ='TestAccount ',
                        Planning_Customer__c = true,
                        Price_Book__c = standardPricebookId,
                        Games_Physical__c=True,
                        Video_Physical__c=True,
                        Status__c='N');
        objAccount.RecordTypeID = rtAcc;
        objAccount.CurrencyIsoCode = 'USD';
        objAccount.Price_Book__c = pb.Id;  
        insert objAccount;
        
        Account acctGoogle = new Account(Name ='TestGoogle ',
                        Planning_Customer__c = true,
                        Price_Book__c = standardPricebookId,
                        Games_Physical__c=True,
                        Video_Physical__c=True,
                        Status__c='N');
       acctGoogle.RecordTypeID = rtAcDC;
       acctGoogle.CurrencyIsoCode = 'USD';
       acctGoogle.Price_Book__c = pb.Id;  
       insert acctGoogle;
        Title__c title2 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='HD');
        title_List.add(title2);
      
        
        Title__c title3 = new Title__c(Name = 'Vampire',Video_Version__c ='000000002',Content_Type__c='Episode',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='HD');
        title_List.add(title3);
        
        insert title_List;
        List<Playlist__c> playlist = new List<Playlist__c>();
        Playlist__c playlist123 = new Playlist__c();
        playlist123.name = 'test playlist';
        playlist123.Version_Number__c = 1;
        playlist123.Parent_Title__c = title2.id;
        playlist123.Playlist_Status__c = 'Active';
        playlist.add(playlist123);
    
        insert playlist;
        
        List<Playlist_Content__c> contentlist = new List<Playlist_Content__c>();
        Playlist_Content__c content = new Playlist_Content__c();
        content.Content_Title__c=title3.id;
        content.Playlist__c = playlist123.id;
        contentlist.add(content);
        
        insert contentlist;
        
        Country__c countryFrance =new Country__c(Name ='France',Country_Code2__c ='FR',Country_Code__c='FRA',Generate_CRM_Product__c = true);
        country_List.add(countryFrance);
        
        insert country_List;
        
        Language__c languageFrench = new Language__c(Name='English',Language_Order__c = 1,Language_Code_2__c = 'en');
        insert languageFrench;
        
        Pricing__c price2 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title_List[0].Content_Type__c,
            Country__c = country_List[0].Id,Channel__c ='EST',Format__c ='HD',Price_Code_Status__c = 'Active',Price_Tier__c = '22.22',Episode_Price__c=33.33
        );
        price_List.add(price2);
        
        
        Pricing__c price3 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title_List[1].Content_Type__c,
            Country__c = country_List[0].Id,Channel__c ='EST',Format__c ='HD',Price_Code_Status__c = 'Active',Price_Tier__c = '44.44',Episode_Price__c=55.55
        );
        
        price_List.add(price3);
        
        insert price_List;
        
        Local_Title__c local2 = new Local_Title__c(Name = 'local2',Title__c =title_List[0].Id,Country__c = country_List[0].Id,
                                Language__c =languageFrench.Id,Price_Code__c =price_List[0].Name);
                    
        localDataList.add(local2);                        
        Local_Title__c local3 = new Local_Title__c(Name = 'local3',Title__c =title_List[1].Id,Country__c = country_List[0].Id,
                                Language__c =languageFrench.Id);                        
        localDataList.add(local3);                        
        
        insert localDataList;
        
        Product_Creation_Batch_Setting__c pc = new Product_Creation_Batch_Setting__c();
        pc.Name = 'Default';
        pc.Generate_CRM_Product__c = true;
        pc.Last_N_Days__c = null;
        insert pc;
        
       String productRecTypeId = WB_PriceUtility.getRecordTypeId(Product2.getSobjectType(),'Digital Product');
       Product2 insertProd = new Product2();
       insertProd.RecordTypeId = productRecTypeId;
       insertProd.Name = 'Test Product';
       insertProd.ProductCode = '6000047541';
       insertProd.Type__c = 'Video Digital';
       insertProd.Product_Market__c ='EST';
       insertProd.Product_Format__c = 'HD';
       insertProd.Local_Title__c = localDataList[0].Id;
       insertProd.External_Id__c = 'FRA_en_6000047541_EST_HD';
       insert insertProd;
       
     
        
        List<Commercial_Avail__c> rpList = new List<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title_List[0].Id,Country_Lookup__c=country_List[0].Id,Local_Title__c = localDataList[0].Id,
                Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Sub & Audio',Status__c='Confirmed',
                Exclusive_Date__c = date.today()-200, Start_Date__c=date.today()-100,End_Date__c= date.today()+100,Rights_End__c=date.today()+200
                
        );
        rpList.add(releaseplan1);
    
        insert rpList;

        rpList[0].Product__c = insertProd.Id;
    
        update rpList[0];
      
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=country_List[0].Id, Pricing_Currency__c='FR', Content_Type__c='Season;Episode',
            Channel_Picklist__c=rpList[0].Channel__c, Format__c=rpList[0].Format__c, Status__c ='Active',CRM_Storefront__c = true,Selected_Combination__c = 'Season_EST_HD',
            CRM_Account__c = objAccount.Id,SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1;
        

        countrySIDList.add(new Country_SID_Key__c(Name='France', Country_Code__c='FRA',Country_Code2_c__c='FR',Locale_SID_Key__c='Europe/Lisbon',Region__c='Western Europe'));
        insert countrySIDList;
        
        List<Rate_Card__c> rcList = new List<Rate_Card__c>();
        
        Rate_Card__c rc = new Rate_Card__c();
        rc.Channel__c = rpList[0].Channel__c;
        rc.Country__c = country_List[0].Id;
        rc.Account__c = acctGoogle.Id;
        rc.Start_Date__c = date.today();
        rc.End_Date__c = date.today()+200;
        rc.Content_Type__c = title_List[0].Content_Type__c;
        rc.Format__c = rpList[0].Format__c;
        rc.Price_Tier__c = '22.22';
        //rc.WSP1__c = 5;
        rc.Rate_Card_Type__c = 'Standard';
        rc.Storefront__c = storefrontGoogle1.Id;
        rcList.add(rc);
        
        Rate_Card__c rc1 = new Rate_Card__c();
        rc1.Channel__c = rpList[0].Channel__c;
        rc1.Country__c = country_List[0].Id;
        rc1.Account__c = acctGoogle.Id;
        rc1.Start_Date__c = date.today();
        rc1.End_Date__c = date.today()+200;
        rc1.Content_Type__c ='Episode';
        rc1.Format__c = rpList[0].Format__c;
        rc.WSP1__c = 33.33;
        //rc.WSP1__c = 5;
        rc1.Rate_Card_Type__c = 'WSP';
        rc1.Storefront__c = storefrontGoogle1.Id;
        rcList.add(rc1);
        
         Rate_Card__c rc2 = new Rate_Card__c();
        rc2.Channel__c = rpList[0].Channel__c;
        rc2.Country__c = country_List[0].Id;
        rc2.Account__c = acctGoogle.Id;
        rc2.Start_Date__c = date.today();
        rc2.End_Date__c = date.today()+200;
        rc2.Content_Type__c = 'Season';
        rc2.Format__c = rpList[0].Format__c;
        rc2.Price_Tier__c = '44.44';
        //rc.WSP1__c = 5;
        rc2.Rate_Card_Type__c = 'Standard';
        rc2.Storefront__c = storefrontGoogle1.Id;
        rcList.add(rc2);
        
        Rate_Card__c rc3 = new Rate_Card__c();
        rc3.Channel__c = rpList[0].Channel__c;
        rc3.Country__c = country_List[0].Id;
        rc3.Account__c = acctGoogle.Id;
        rc3.Start_Date__c = date.today();
        rc3.End_Date__c = date.today()+200;
        rc3.Content_Type__c ='Episode';
        rc3.Format__c = rpList[0].Format__c;
        rc3.WSP1__c = 55.55;
        //rc.WSP1__c = 5;
        rc3.Rate_Card_Type__c = 'WSP';
        rc3.Storefront__c = storefrontGoogle1.Id;
        rcList.add(rc3);
        
        
        insert rcList;
        
        listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(acctGoogle.Id, rpList[0], localDataList[0].Id);
        clientAvail.Start_Date__c = system.today()+2;
        clientAvail.End_Date__c = system.today()+70;
        clientAvail.Status__c = 'Confirmed';
        //clientAvail.Price_Tier_Text__c = Null;
        clientAvail.Price_Tier_Text__c = '22.22';
        clientAvail.Episode_Price__c = 33.33;
        clientAvail.Local_Data_Category_Picklist__c = 'New Release';
        clientAvail.Storefront__c = storefrontGoogle1.Id;
        //clientAvail.Channel__c = 'EST';
        clientAvail.Playlist__c = playlist123.id;
        listClientavails.add(clientAvail);
        
        
        Client_Avail__c clientAvail2 = TestUtil.initClientAvail(acctGoogle.Id, rpList[0], localDataList[1].Id);
        clientAvail2.Start_Date__c = system.today()+2;
        clientAvail2.End_Date__c = system.today()+70;
        clientAvail2.Status__c = 'Confirmed';
        //clientAvail.Price_Tier_Text__c = Null;
        //clientAvail2.Price__c = 33.33;
        clientAvail2.Storefront__c = storefrontGoogle1.Id;
        clientAvail2.Local_Data_Category_Picklist__c = 'New Release';
        //clientAvail2.Parent_Client_Avail__c=listClientavails.id;
        //clientAvail.Channel__c = 'EST';
       listClientavails.add(clientAvail2);
        
      
        insert listClientavails;
        test.startTest();
        List<Client_Avail__c> caepisiodelist=new List<Client_Avail__c>();
        
        listClientavails[1].Parent_Client_Avail__c=listClientavails[0].id;
        
        listClientavails[1].Recalculate_Playlist_Avails__c='';
        caepisiodelist.add(listClientavails[1]);
        
        update caepisiodelist;
    
        String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
        String tpRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME);
        
       clAvailPriceList.add(new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c = listClientavails[0].id,Effective_Date__c=system.today()+33,Price_Tier__c='44.44',Episode_Price__c=55.55,Type__c='Reprice',Category__c='Catalog'));
       insert clAvailPriceList;
       test.stopTest();
        
       
    }
}