@isTest
private class WB_PriceWizardController_Test {
    
    static List<Account> accList = new List<Account>();
    static List<Title__c> titleList = new List<Title__c>();
    static List<Country__c> cList = new List<Country__c>();
    static List<Language__c> lList = new List<Language__c>();
    static List<Local_Title__c> lTitle = new List<Local_Title__c>();
    static List<Pricing__c> lPricing = new List<Pricing__c>();
    static List<Commercial_Avail__c> cAvailList = new List<Commercial_Avail__c>();
    static List<Agreement__c> aList = new List<Agreement__c>();
    static List<Client_Avail__c> clAvailList = new List<Client_Avail__c>();
    static List<Client_Avail_Price__c> clAvailPriceList = new List<Client_Avail_Price__c>();
    static List<Country_SID_Key__c> countrySIDList = new List<Country_SID_Key__c>();
    static List<String> selectedClientAvailIds = new List<String>();
    static Integer count=3;    
    static List<String> videoVersions = new List<String>();
    static List<MPM__c> mpmList = new List<MPM__c>();
    static Client_Avail_Id_Store__c uniqueIdSetting;
    
    private static void insertTestData(){
        for(Integer i = 0; i<count; i++)
        {
            Account acct = TestUtil.createAccount('Google Acc'+i);
            acct.Customer_Focus__c = 'Active';
            accList.add(acct); 
        }
        insert accList;
        
        MPM__c mpm1 = TestUtil.createMPM('112345');
        MPM__c mpm2 = TestUtil.createMPM('112346');
        MPM__c mpm3 = TestUtil.createMPM('112347');
        mpmList.add(mpm1);    
        mpmList.add(mpm2);    
        mpmList.add(mpm3);    
        
        insert mpmList;
        
        for(integer i = 0; i<count; i++)
        {
            Title__c title1 = TestUtil.initTitle('TestGoogle'+i, '600004754'+i);
            title1.Content_Type__c = 'Season';
            title1.Digital_Planning__c = 'YES';
            title1.Clear_to_Avail__c = true;
            title1.MPM__c = mpmList[i].Id;
            title1.Territory__c = 'USA';
            titleList.add(title1);
        }
        insert titleList;
        
        
        
        
        
        //for(Integer i = 0; i<count; i++)
        //{
            Country__c country1 = TestUtil.initCountry('USA', 'US', 'USA');
            country1.Territory__c = 'USA';
            Country__c country2 = TestUtil.initCountry('China', 'CN', 'CHN');
            country2.Territory__c = 'USA';
            Country__c country3 = TestUtil.initCountry('Canada', 'CA', 'CAN');
            country3.Territory__c = 'USA';
            
            cList.add(country1);
            cList.add(country2);
            cList.add(country3);
            
        //}
        insert cList;
        
        for(Integer i = 0; i<count; i++)
        {
            Language__c languageFrench = TestUtil.initLanguage('TestFrench', '', 1);
            lList.add(languageFrench);
        }
        insert lList;
        
        for(Integer i=0; i<count; i++)
        {
            Local_Title__c localTitle = TestUtil.initLocalTitle(lList[i].Id, cList[i].Id);
            localTitle.Title__c = titleList[i].id;
            lTitle.add(localTitle);
        }
        insert lTitle;
        
        for(Integer i=0; i<count; i++)
        {
            Commercial_Avail__c CommercialAvail = TestUtil.initReleasePlan(titleList[i].Id, lTitle[i].Id, cList[i].Id, lList[i].Id);
            CommercialAvail.Start_Date__c = system.today()-70;
            CommercialAvail.End_Date__c = system.today()+70;
            cAvailList.add(CommercialAvail);
        }
        insert cAvailList;
        
        for(Integer i=0; i<count; i++)
        {
            Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(accList[i].Id, cList[i].Id, cAvailList[i], titleList[i]);
            aList.add(storefrontGoogle1);
        }
        insert aList;
        
        Pricing__c pricing = TestUtil.createPricing(accList[0].Id, country1.Id,null);
        pricing.Name = 'Direct To Video Catalog';
        pricing.Channel__c='VODc';
        pricing.Content_Type__c='Season';
        //pricing.WS_Price__c=26;
        pricing.Price_Tier__c = '26';
        pricing.Episode_Price_Tier__c='31';
        pricing.Format__c='HD';
       // pricing.Episode_Price_Tier__c='Reprice';
        lPricing.add(pricing);
        
        Pricing__c episode = TestUtil.createPricing(accList[0].Id, country1.Id,null);
        episode.Name = 'Direct To Video Catalog';
        episode.Channel__c='VODc';
        episode.Content_Type__c='Episode';
        //pricing.WS_Price__c=26;
        episode.Price_Tier__c = '31';
       // episode.Episode_Price_Tier__c='31';
        episode.Format__c='HD';
       // pricing.Episode_Price_Tier__c='Reprice';
        lPricing.add(episode);
        
        Pricing__c pricing1 = TestUtil.createPricing(accList[1].Id, country2.Id,null);
        pricing1.Name = 'Direct To Video Catalog';
        pricing1.Channel__c='VODc';
        pricing1.Content_Type__c='Season';
        //pricing1.WS_Price__c=28;
        pricing1.Price_Tier__c ='28';
        pricing1.Episode_Price_Tier__c='32';
        pricing1.Format__c='HD';
        lPricing.add(pricing1);
        
         Pricing__c episode1 = TestUtil.createPricing(accList[1].Id, country2.Id,null);
        episode1.Name = 'Direct To Video Catalog';
        episode1.Channel__c='VODc';
        episode1.Content_Type__c='Episode';
        //pricing1.WS_Price__c=28;
        episode1.Price_Tier__c ='32';
       // episode1.Episode_Price_Tier__c='32';
        episode1.Format__c='HD';
        lPricing.add(episode1);
        
        Pricing__c pricing2 = TestUtil.createPricing(accList[2].Id, country3.Id,null);
        pricing2.Name = 'Direct To Video Catalog';
        pricing2.Channel__c='VODc';
        pricing2.Content_Type__c='Season';
        //pricing2.WS_Price__c=29;
        pricing2.Price_Tier__c = '29';
        pricing2.Episode_Price_Tier__c='33';
        pricing2.Format__c='HD';
        lPricing.add(pricing2);
        
         Pricing__c episode2 = TestUtil.createPricing(accList[2].Id, country3.Id,null);
        episode2.Name = 'Direct To Video Catalog';
        episode2.Channel__c='VODc';
        episode2.Content_Type__c='Episode';
        //pricing2.WS_Price__c=29;
        episode2.Price_Tier__c = '33';
        //episode2.Episode_Price_Tier__c='33';
        episode2.Format__c='HD';
        lPricing.add(episode2);
        
        Pricing__c pricing3 = TestUtil.createPricing(accList[1].Id, country2.Id,null);
        pricing3.Name = 'Direct To Video Catalog Test';
        pricing3.Channel__c='VODc';
        pricing3.Content_Type__c='Season';
        //pricing1.WS_Price__c=28;
        pricing3.Price_Tier__c ='38';
        pricing3.Episode_Price_Tier__c='35';
        pricing3.Format__c='HD';
        lPricing.add(pricing3);
        
        Pricing__c episode3 = TestUtil.createPricing(accList[1].Id, country2.Id,null);
        episode3.Name = 'Direct To Video Catalog Test';
        episode3.Channel__c='VODc';
        episode3.Content_Type__c='Episode';
        //pricing1.WS_Price__c=28;
        episode3.Price_Tier__c ='35';
       // episode3.Episode_Price_Tier__c='35';
        episode3.Format__c='HD';
        lPricing.add(episode3);
        
        insert lPricing;
        
        countrySIDList.add(new Country_SID_Key__c(Name='USA', Country_Code__c='USA',Country_Code2_c__c='US',Locale_SID_Key__c='America/Los_Angeles',Region__c='North America'));
        countrySIDList.add(new Country_SID_Key__c(Name='China', Country_Code__c='CHN',Country_Code2_c__c='CN',Locale_SID_Key__c='America/Los_Angeles',Region__c='North America'));
        countrySIDList.add(new Country_SID_Key__c(Name='Canada', Country_Code__c='CAN',Country_Code2_c__c='CA',Locale_SID_Key__c='America/Los_Angeles',Region__c='North America'));
        
        insert countrySIDList;
        
        for(Integer i=0; i<count; i++)
        {
            Client_Avail__c clientAvail = TestUtil.initClientAvail(accList[i].Id, cAvailList[i], lTitle[i].Id);
            
            clientAvail.Start_Date__c = system.today()-70;
            clientAvail.End_Date__c = system.today()+70;
            clientAvail.Price_Tier_Text__c = '29';
            
            
            
            clAvailList.add(clientAvail);
        
        }
        insert clAvailList;
        
        String IdStoreVal = '';
        for(Client_Avail__c cId : clAvailList){
          system.debug('###Client Avail ID:'+cId.ID); 
          if(IdStoreVal == '')
             IdStoreVal = IdStoreVal + cId.ID;
         else
            IdStoreVal = IdStoreVal + ','+cId.ID;
            
          system.debug('###IdStoreVal:'+IdStoreVal);  
        }
        
        Client_Avail_Id_Store__c cAvailIDStore = new Client_Avail_Id_Store__c();
        cAvailIDStore.key__c = '0050B000006vtjLQAQ1480867406455';
        cAvailIDStore.ID_Store__c = IdStoreVal;
        insert cAvailIDStore;
        
        //Price__c,Price_Tier__c='26',Episode_Price_Tier__c='31',
        
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today(),Price_Code__c= 'Direct To Video Catalog',Type__c='Reprice',Category__c = 'Catalog'));
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[1].id,Effective_Date__c=system.today()+50,Price_Code__c= 'Direct To Video Catalog',Type__c='Reprice',Category__c = 'Catalog'));
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[2].id,Effective_Date__c=system.today(),Price_Code__c= 'Direct To Video Catalog',Type__c='Reprice',Category__c = 'Catalog'));
        insert clAvailPriceList;
        
        
        
        
        
        uniqueIdSetting = new Client_Avail_Id_Store__c(ID_Store__c=clAvailList[0]+','+clAvailList[1],Key__c='test');
        insert uniqueIdSetting;
    }
    
    private static void insertTestData1(){
    	count = 1;
        for(Integer i = 0; i<count; i++)
        {
            Account acct = TestUtil.createAccount('Google Acc'+i);
            acct.Customer_Focus__c = 'Active';
            accList.add(acct); 
        }
        insert accList;
        
        MPM__c mpm1 = TestUtil.createMPM('112345');
        mpmList.add(mpm1);    
           
        
        insert mpmList;
        
        for(integer i = 0; i<count; i++)
        {
            Title__c title1 = TestUtil.initTitle('TestGoogle'+i, '600004754'+i);
            title1.Content_Type__c = 'Season';
            title1.Digital_Planning__c = 'YES';
            title1.Clear_to_Avail__c = true;
            title1.MPM__c = mpmList[i].Id;
            title1.Territory__c = 'USA';
            titleList.add(title1);
        }
        insert titleList;
        
            Country__c country1 = TestUtil.initCountry('USA', 'US', 'USA');
            country1.Territory__c = 'USA';
            Country__c country2 = TestUtil.initCountry('China', 'CN', 'CHN');
            country2.Territory__c = 'USA';
            Country__c country3 = TestUtil.initCountry('Canada', 'CA', 'CAN');
            country3.Territory__c = 'USA';
            
            cList.add(country1);
            cList.add(country2);
            cList.add(country3);
            
        
        insert cList;
        
        for(Integer i = 0; i<count; i++)
        {
            Language__c languageFrench = TestUtil.initLanguage('TestFrench', '', 1);
            lList.add(languageFrench);
        }
        insert lList;
        
        for(Integer i=0; i<count; i++)
        {
            Local_Title__c localTitle = TestUtil.initLocalTitle(lList[i].Id, cList[i].Id);
            localTitle.Title__c = titleList[i].id;
            lTitle.add(localTitle);
        }
        insert lTitle;
        
        for(Integer i=0; i<count; i++)
        {
            Commercial_Avail__c CommercialAvail = TestUtil.initReleasePlan(titleList[i].Id, lTitle[i].Id, cList[i].Id, lList[i].Id);
            CommercialAvail.Start_Date__c = system.today()-70;
            CommercialAvail.End_Date__c = system.today()+70;
            CommercialAvail.Channel__c = 'EST';
            cAvailList.add(CommercialAvail);
        }
        insert cAvailList;
        
        for(Integer i=0; i<count; i++)
        {
            Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(accList[i].Id, cList[i].Id, cAvailList[i], titleList[i]);
            aList.add(storefrontGoogle1);
        }
        insert aList;
        
        Pricing__c pricing = TestUtil.createPricing(accList[0].Id, country1.Id,null);
        pricing.Name = 'Direct To Video Catalog';
        pricing.Channel__c='EST';
        pricing.Content_Type__c='Season';
        pricing.Price_Tier__c = '26';
        pricing.Episode_Price_Tier__c='31';
        pricing.Format__c='HD';
        lPricing.add(pricing);
        
        Pricing__c episode = TestUtil.createPricing(accList[0].Id, country1.Id,null);
        episode.Name = 'Direct To Video Catalog';
        episode.Channel__c='EST';
        episode.Content_Type__c='Episode';
        episode.Price_Tier__c = '31';
        episode.Format__c='HD';
        lPricing.add(episode);
        
        insert lPricing;
        
        countrySIDList.add(new Country_SID_Key__c(Name='USA', Country_Code__c='USA',Country_Code2_c__c='US',Locale_SID_Key__c='America/Los_Angeles',Region__c='North America'));
        countrySIDList.add(new Country_SID_Key__c(Name='China', Country_Code__c='CHN',Country_Code2_c__c='CN',Locale_SID_Key__c='America/Los_Angeles',Region__c='North America'));
        countrySIDList.add(new Country_SID_Key__c(Name='Canada', Country_Code__c='CAN',Country_Code2_c__c='CA',Locale_SID_Key__c='America/Los_Angeles',Region__c='North America'));
        
        insert countrySIDList;
        
        for(Integer i=0; i<count; i++)
        {
            Client_Avail__c clientAvail = TestUtil.initClientAvail(accList[i].Id, cAvailList[i], lTitle[i].Id);
            
            clientAvail.Start_Date__c = system.today() + 20;
            clientAvail.End_Date__c = system.today()+70;
            clientAvail.APO_Date__c = system.today() - 20;
            clientAvail.Price_Tier_Text__c = '29';
            
            
            clAvailList.add(clientAvail);
        
        }
        insert clAvailList;
          String IdStoreVal = '';
        for(Client_Avail__c cId : clAvailList){
          system.debug('###Client Avail ID:'+cId.ID); 
          if(IdStoreVal == '')
             IdStoreVal = IdStoreVal + cId.ID;
         else
            IdStoreVal = IdStoreVal + ','+cId.ID;
            
          system.debug('###IdStoreVal:'+IdStoreVal);  
        }
        
        Client_Avail_Id_Store__c cAvailIDStore = new Client_Avail_Id_Store__c();
        cAvailIDStore.key__c = '0050B000006vtjLQAQ1480867406455';
        cAvailIDStore.ID_Store__c = IdStoreVal;
        insert cAvailIDStore;
        
        
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today(),Price_Code__c= 'Direct To Video Catalog',Type__c='Reprice',Category__c = 'Catalog'));
       
        insert clAvailPriceList;
        
    }
	
    private static testMethod void testMethod1() {
        insertTestData();
        WB_PriceWizardController.FilterCriteria fc = new WB_PriceWizardController.FilterCriteria();
        fc.processName = 'reprice';
        fc.selectedCountries = new List<String>{cList[0].Country_Code__c,cList[1].Country_Code__c};
        fc.selectedAccounts = new List<String>{accList[0].name,accList[1].name};
        fc.selectedChannels = new List<String>{'VODc'};
        fc.selectedFormats = new List<String>{'HD'};
        fc.selectedContentTypes = new List<String>{'Season'};
        fc.selectedCALifeCycles = new List<String>{'Active Current'};
        fc.selectedWBTerritories = new List<String>{'USA'};
        fc.selectedPriceTiers = new List<String>{'29'};
        fc.selectedLangs = new List<String>{'TestFrench'};
        fc.selectedLangTypes = new List<String>{'Sub'};
        fc.mpmNumbers = new List<String>{mpmList[0].MPM_Number__c,mpmList[1].MPM_Number__c};
        videoVersions.add(titleList[0].Video_Version__c);
        videoVersions.add(titleList[1].Video_Version__c);
        videoVersions.add(titleList[2].Video_Version__c);
        
        for(String videoVer : videoVersions){
            System.debug('####videoVersions:'+videoVer);
        }
            
        for(Client_Avail__c c: clAvailList){
            selectedClientAvailIds.add(c.Id);
        }
        
        test.startTest();
        WB_PriceWizardController pwc = new WB_PriceWizardController();
        pwc.getUserLocale();
        List<String> listCA = WB_PriceWizardController.getUniqueIDvalue('0050B000006vtjLQAQ1480867406455');
        system.debug('###listCA:'+listCA);
        
  
        
        List<String> listRecordId = WB_PriceWizardController.getRecordIDs(videoVersions,fc,'rePrice');
        system.debug('###listRecordId:'+listRecordId);
        List<WB_PriceWizardController.CAPWrapper> wrapperCAlist = WB_PriceWizardController.getRecords(listRecordId,'rePrice');
        system.debug('###wrapperCAlist:'+wrapperCAlist);
    
        
        
        List<WB_PriceWizardController.FilterWrapper> filterWrapperList = WB_PriceWizardController.getFilterData('Countries','rePrice');
        WB_PriceWizardController.getFilterData('Accounts','rePrice');
        WB_PriceWizardController.getFilterData('Channels','rePrice');
        WB_PriceWizardController.getFilterData('Formats','rePrice');
        WB_PriceWizardController.getFilterData('Languages','rePrice');
        WB_PriceWizardController.getFilterData('LanguageTypes','rePrice');
        WB_PriceWizardController.getFilterData('WBTerritories','rePrice');
        WB_PriceWizardController.getFilterData('ContentTypes','rePrice');
        WB_PriceWizardController.getFilterData('CALifeCycles','rePrice');
        List<WB_PriceWizardController.FilterWrapper> filterWrapperList2 =WB_PriceWizardController.getFilterData('PriceTiers','rePrice');
        
        test.stopTest();   
    }
    
    
    private static testMethod void testMethod2() {
        insertTestData();
        WB_PriceWizardController.FilterCriteria fc = new WB_PriceWizardController.FilterCriteria();
        fc.processName = 'priceUpdate';
        fc.selectedCountries = new List<String>{cList[0].Country_Code__c,cList[1].Country_Code__c};
        fc.selectedAccounts = new List<String>{accList[0].name,accList[1].name};
        fc.selectedChannels = new List<String>{'VODc'};
        fc.selectedFormats = new List<String>{'HD'};
        fc.selectedContentTypes = new List<String>{'Season'};
        fc.selectedCALifeCycles = new List<String>{'Active Current'};
        fc.selectedWBTerritories = new List<String>{'USA'};
        fc.selectedPriceTiers = new List<String>{'28'};
        fc.selectedLangs = new List<String>{'TestFrench'};
        fc.selectedLangTypes = new List<String>{'Sub'};
        fc.mpmNumbers = new List<String>{mpmList[0].MPM_Number__c,mpmList[1].MPM_Number__c};
        videoVersions.add(titleList[0].Video_Version__c);
        videoVersions.add(titleList[1].Video_Version__c);
        videoVersions.add(titleList[2].Video_Version__c);
        
        for(String videoVer : videoVersions){
            System.debug('####videoVersions:'+videoVer);
        }
            
        for(Client_Avail__c c: clAvailList){
            selectedClientAvailIds.add(c.Id);
        }
        
        test.startTest();
        WB_PriceWizardController pwc = new WB_PriceWizardController();
        pwc.getUserLocale();
        List<Client_Avail__c> ca = new List<Client_Avail__c>();
        ca = [Select Id,Title_Video_Version__c,Commercial_Avail__r.Country_Lookup__r.Country_Code__c,AccountF__c,Release_Plan_Channel__c,Release_Plan_Format__c,Release_Plan_Language__c,
            RP_Language_Type__c,Territory__c,Price_Tier_Text__c,Title_Content_Type__c,CA_Lifecycle__c,Local_Title__r.Title__r.MPM__r.MPM_Number__c from Client_Avail__c];
        for(Client_Avail__c ca1 : ca){
            system.debug('####Client Avail List:'+ca1.Territory__c);
        }
        
        List<Client_Avail_Price__c> cap = new List<Client_Avail_Price__c>();
        cap = [Select Id,Title_Video_Version__c,Client_Avail__r.Commercial_Avail__r.Country_Lookup__r.Country_Code__c,Account__c,Client_Avail_Channel__c,Client_Avail_Format__c,
              Client_Avail_Language__c,Client_Avail_Language_Type__c,WB_Territory__c,Price_Tier__c,Title_Content_Type__c,CA_Lifecycle__c,Client_Avail__r.Local_Title__r.Title__r.MPM__r.MPM_Number__c from Client_Avail_Price__c];
        for(Client_Avail_Price__c cap1 : cap){
            system.debug('####Client Avail Price List testMethod2 :'+cap1);
        }
        
        List<String> listRecordId_CAP = WB_PriceWizardController.getRecordIDs(videoVersions,fc,'priceUpdate');
        system.debug('###listRecordId_CAP:'+listRecordId_CAP);
        
        List<WB_PriceWizardController.CAPWrapper> wrapperCAPlist = WB_PriceWizardController.getRecords(listRecordId_CAP,'priceUpdate');
        system.debug('###wrapperCAPlist:'+wrapperCAPlist);
        
        Client_Avail__c clientAvail = [Select id,name,Title_Content_Type__c,Start_Date__c from Client_Avail__c where id=: clAvailList[1].id limit 1];
        Client_Avail_Price__c clientAvailPrice = [Select id,name,Price_Code__c,Effective_Date__c from Client_Avail_Price__c where id=: clAvailPriceList[1].id limit 1];
        System.debug('###clientAvail:'+clientAvail);
        System.debug('###clientAvailPrice:'+clientAvailPrice);
        system.debug('###Todays Date:'+system.today());
        WB_PriceWizardController.CAPWrapper caWrap = new WB_PriceWizardController.CAPWrapper();
        caWrap.videoVersion = titleList[1].Video_Version__c;
        caWrap.title = titleList[1].name;
        caWrap.account = accList[1].name;
        caWrap.country = cList[1].Country_Code__c;
        caWrap.channel = 'VODc';
        caWrap.format = 'HD';
        caWrap.language = lList[1].Name;
        caWrap.contentType ='Season';
        caWrap.isRowModified = true;
        caWrap.caName = clientAvail.Name;
        
        caWrap.caCategory = 'Catalog';
        caWrap.capName = clientAvailPrice.Name;
        caWrap.priceCode = 'Direct To Video Catalog Test';
       
        caWrap.capRecordId = clAvailPriceList[1].Id;
        caWrap.caRecordId = clAvailList[1].id;
        Date effectiveDate = clAvailPriceList[1].Effective_Date__c+10;
        String effeDate = effectiveDate.format();
        
        caWrap.effectiveDate = effeDate;
        //caWrap.effectiveDate = caWrap.effectiveDate.format('mm/dd/yyyy');
        System.debug('###caWrap.effectiveDate:'+caWrap.effectiveDate);
        
        
        List<WB_PriceWizardController.CAPWrapper> caW = new List<WB_PriceWizardController.CAPWrapper>();
        caW.add(caWrap);
        List<WB_PriceWizardController.CAPWrapper> wrapperList3 =WB_PriceWizardController.savePriceRecords(caW,'rePrice');
       
       
        
        test.stopTest(); 
    }
    
    private static testMethod void testMethod3() {
        insertTestData();
        WB_PriceWizardController.FilterCriteria fc = new WB_PriceWizardController.FilterCriteria();
        fc.processName = 'priceUpdate';
        fc.selectedCountries = new List<String>{cList[0].Country_Code__c,cList[1].Country_Code__c};
        fc.selectedAccounts = new List<String>{accList[0].name,accList[1].name};
        fc.selectedChannels = new List<String>{'VODc'};
        fc.selectedFormats = new List<String>{'HD'};
        fc.selectedContentTypes = new List<String>{'Season'};
        fc.selectedCALifeCycles = new List<String>{'Active Current'};
        fc.selectedWBTerritories = new List<String>{'USA'};
        fc.selectedPriceTiers = new List<String>{'28'};
        fc.selectedLangs = new List<String>{'TestFrench'};
        fc.selectedLangTypes = new List<String>{'Sub'};
        fc.mpmNumbers = new List<String>{mpmList[0].MPM_Number__c,mpmList[1].MPM_Number__c};
        videoVersions.add(titleList[0].Video_Version__c);
        videoVersions.add(titleList[1].Video_Version__c);
        videoVersions.add(titleList[2].Video_Version__c);
        
        for(String videoVer : videoVersions){
            System.debug('####videoVersions:'+videoVer);
        }
            
        for(Client_Avail__c c: clAvailList){
            selectedClientAvailIds.add(c.Id);
        }
        
        test.startTest();
        WB_PriceWizardController pwc = new WB_PriceWizardController();
        pwc.getUserLocale();
        List<Client_Avail__c> ca = new List<Client_Avail__c>();
        ca = [Select Id,Title_Video_Version__c,Commercial_Avail__r.Country_Lookup__r.Country_Code__c,AccountF__c,Release_Plan_Channel__c,Release_Plan_Format__c,Release_Plan_Language__c,
            RP_Language_Type__c,Territory__c,Price_Tier_Text__c,Title_Content_Type__c,CA_Lifecycle__c,Local_Title__r.Title__r.MPM__r.MPM_Number__c from Client_Avail__c];
        for(Client_Avail__c ca1 : ca){
            system.debug('####Client Avail List:'+ca1.Territory__c);
        }
        
        List<Client_Avail_Price__c> cap = new List<Client_Avail_Price__c>();
        cap = [Select Id,Title_Video_Version__c,Client_Avail__r.Commercial_Avail__r.Country_Lookup__r.Country_Code__c,Account__c,Client_Avail_Channel__c,Client_Avail_Format__c,
              Client_Avail_Language__c,Client_Avail_Language_Type__c,WB_Territory__c,Price_Tier__c,Title_Content_Type__c,CA_Lifecycle__c,Client_Avail__r.Local_Title__r.Title__r.MPM__r.MPM_Number__c from Client_Avail_Price__c];
        for(Client_Avail_Price__c cap1 : cap){
            system.debug('####Client Avail Price List testMethod2 :'+cap1);
        }
        
        List<String> listRecordId_CAP = WB_PriceWizardController.getRecordIDs(videoVersions,fc,'priceUpdate');
        system.debug('###listRecordId_CAP:'+listRecordId_CAP);
        
        List<WB_PriceWizardController.CAPWrapper> wrapperCAPlist = WB_PriceWizardController.getRecords(listRecordId_CAP,'priceUpdate');
        system.debug('###wrapperCAPlist:'+wrapperCAPlist);
        
        Client_Avail__c clientAvail = [Select id,name,Title_Content_Type__c,Start_Date__c from Client_Avail__c where id=: clAvailList[1].id limit 1];
        Client_Avail_Price__c clientAvailPrice = [Select id,name,Price_Code__c,Effective_Date__c from Client_Avail_Price__c where id=: clAvailPriceList[1].id limit 1];
        System.debug('###clientAvail:'+clientAvail);
        System.debug('###clientAvailPrice:'+clientAvailPrice);
        system.debug('###Todays Date:'+system.today());
        WB_PriceWizardController.CAPWrapper caWrap = new WB_PriceWizardController.CAPWrapper();
        caWrap.videoVersion = titleList[1].Video_Version__c;
        caWrap.title = titleList[1].name;
        caWrap.account = accList[1].name;
        caWrap.country = cList[1].Country_Code__c;
        caWrap.channel = 'VODc';
        caWrap.format = 'HD';
        caWrap.language = lList[1].Name;
        caWrap.contentType ='Season';
        caWrap.isRowModified = true;
        caWrap.caName = clientAvail.Name;
        
        caWrap.caCategory = 'Catalog';
        caWrap.capName = clientAvailPrice.Name;
        caWrap.priceCode = 'Direct To Video Catalog Test';
        //caWrap.capName = clientAvailPrice.Name;
        //caWrap.languageType =
        caWrap.capRecordId = clAvailPriceList[1].Id;
        caWrap.caRecordId = clAvailList[1].id;
        Date effectiveDate = clAvailPriceList[1].Effective_Date__c+10;
        String effeDate = effectiveDate.format();
       
        caWrap.effectiveDate = effeDate;
        //caWrap.effectiveDate = caWrap.effectiveDate.format('mm/dd/yyyy');
        System.debug('###caWrap.effectiveDate:'+caWrap.effectiveDate);
      
        
        List<WB_PriceWizardController.CAPWrapper> caW = new List<WB_PriceWizardController.CAPWrapper>();
        caW.add(caWrap);
        
        List<WB_PriceWizardController.CAPWrapper> wrapperList4 =WB_PriceWizardController.savePriceRecords(caW,'priceUpdate');
        system.debug('###wrapperList4:'+wrapperList4);
        
        
        test.stopTest(); 
    }
    
    private static testMethod void testMethod4() {
        insertTestData();
        WB_PriceWizardController.FilterCriteria fc = new WB_PriceWizardController.FilterCriteria();
        fc.processName = 'priceUpdate';
        fc.selectedCountries = new List<String>{cList[0].Country_Code__c,cList[1].Country_Code__c};
        fc.selectedAccounts = new List<String>{accList[0].name,accList[1].name};
        fc.selectedChannels = new List<String>{'VODc'};
        fc.selectedFormats = new List<String>{'HD'};
        fc.selectedContentTypes = new List<String>{'Season'};
        fc.selectedCALifeCycles = new List<String>{'Active Current'};
        fc.selectedWBTerritories = new List<String>{'USA'};
        fc.selectedPriceTiers = new List<String>{'28'};
        fc.selectedLangs = new List<String>{'TestFrench'};
        fc.selectedLangTypes = new List<String>{'Sub'};
        fc.mpmNumbers = new List<String>{mpmList[0].MPM_Number__c,mpmList[1].MPM_Number__c};
        videoVersions.add(titleList[0].Video_Version__c);
        videoVersions.add(titleList[1].Video_Version__c);
        videoVersions.add(titleList[2].Video_Version__c);
        
        for(String videoVer : videoVersions){
            System.debug('####videoVersions:'+videoVer);
        }
            
        for(Client_Avail__c c: clAvailList){
            selectedClientAvailIds.add(c.Id);
        }
        
        test.startTest();
        WB_PriceWizardController pwc = new WB_PriceWizardController();
        pwc.getUserLocale();
        List<Client_Avail__c> ca = new List<Client_Avail__c>();
        ca = [Select Id,Title_Video_Version__c,Commercial_Avail__r.Country_Lookup__r.Country_Code__c,AccountF__c,Release_Plan_Channel__c,Release_Plan_Format__c,Release_Plan_Language__c,
            RP_Language_Type__c,Territory__c,Price_Tier_Text__c,Title_Content_Type__c,CA_Lifecycle__c,Local_Title__r.Title__r.MPM__r.MPM_Number__c from Client_Avail__c];
        for(Client_Avail__c ca1 : ca){
            system.debug('####Client Avail List:'+ca1.Territory__c);
        }
        
        List<Client_Avail_Price__c> cap = new List<Client_Avail_Price__c>();
        cap = [Select Id,Title_Video_Version__c,Client_Avail__r.Commercial_Avail__r.Country_Lookup__r.Country_Code__c,Account__c,Client_Avail_Channel__c,Client_Avail_Format__c,
              Client_Avail_Language__c,Client_Avail_Language_Type__c,WB_Territory__c,Price_Tier__c,Title_Content_Type__c,CA_Lifecycle__c,Client_Avail__r.Local_Title__r.Title__r.MPM__r.MPM_Number__c from Client_Avail_Price__c];
        for(Client_Avail_Price__c cap1 : cap){
            system.debug('####Client Avail Price List testMethod2 :'+cap1);
        }
        
        List<String> listRecordId_CAP = WB_PriceWizardController.getRecordIDs(videoVersions,fc,'priceUpdate');
        system.debug('###listRecordId_CAP:'+listRecordId_CAP);
        
        List<WB_PriceWizardController.CAPWrapper> wrapperCAPlist = WB_PriceWizardController.getRecords(listRecordId_CAP,'priceUpdate');
        system.debug('###wrapperCAPlist:'+wrapperCAPlist);
        
        Client_Avail__c clientAvail = [Select id,name,Title_Content_Type__c,Start_Date__c from Client_Avail__c where id=: clAvailList[1].id limit 1];
        Client_Avail_Price__c clientAvailPrice = [Select id,name,Price_Code__c,Effective_Date__c from Client_Avail_Price__c where id=: clAvailPriceList[1].id limit 1];
        System.debug('###clientAvail:'+clientAvail);
        System.debug('###clientAvailPrice:'+clientAvailPrice);
        system.debug('###Todays Date:'+system.today());
        WB_PriceWizardController.CAPWrapper caWrap = new WB_PriceWizardController.CAPWrapper();
        caWrap.videoVersion = titleList[1].Video_Version__c;
        caWrap.title = titleList[1].name;
        caWrap.account = accList[1].name;
        caWrap.country = cList[1].Country_Code__c;
        caWrap.channel = 'VODc';
        caWrap.format = 'HD';
        caWrap.language = lList[1].Name;
        caWrap.contentType ='Season';
        caWrap.isRowModified = false;
        //caWrap.caName = clientAvail.Name;
        caWrap.caName = '';
        
        caWrap.caCategory = '';
        caWrap.capName = clientAvailPrice.Name;
        caWrap.priceCode = 'Direct To Video Catalog Test';
        
        caWrap.capRecordId = clAvailPriceList[1].Id;
        caWrap.caRecordId = clAvailList[1].id;
        Date effectiveDate = clAvailPriceList[1].Effective_Date__c+10;
        String effeDate = effectiveDate.format();
        
        caWrap.effectiveDate = effeDate;
        //caWrap.effectiveDate = caWrap.effectiveDate.format('mm/dd/yyyy');
        System.debug('###caWrap.effectiveDate:'+caWrap.effectiveDate);
       
        
        List<WB_PriceWizardController.CAPWrapper> caW = new List<WB_PriceWizardController.CAPWrapper>();
        caW.add(caWrap);
        
        List<WB_PriceWizardController.CAPWrapper> wrapperList4 =WB_PriceWizardController.savePriceRecords(caW,'priceUpdate');
        system.debug('###wrapperList4:'+wrapperList4);
        
        
        test.stopTest(); 
    }
    
    private static testMethod void rePriceTest1() {
        insertTestData();
        WB_PriceWizardController.FilterCriteria fc = new WB_PriceWizardController.FilterCriteria();
        fc.processName = 'priceUpdate';
        fc.selectedCountries = new List<String>{cList[0].Country_Code__c,cList[1].Country_Code__c};
        fc.selectedAccounts = new List<String>{accList[0].name,accList[1].name};
        fc.selectedChannels = new List<String>{'VODc'};
        fc.selectedFormats = new List<String>{'HD'};
        fc.selectedContentTypes = new List<String>{'Season'};
        fc.selectedCALifeCycles = new List<String>{'Active Current'};
        fc.selectedWBTerritories = new List<String>{'USA'};
        fc.selectedPriceTiers = new List<String>{'28'};
        fc.selectedLangs = new List<String>{'TestFrench'};
        fc.selectedLangTypes = new List<String>{'Sub'};
        fc.mpmNumbers = new List<String>{mpmList[0].MPM_Number__c,mpmList[1].MPM_Number__c};
        videoVersions.add(titleList[0].Video_Version__c);
        videoVersions.add(titleList[1].Video_Version__c);
        videoVersions.add(titleList[2].Video_Version__c);
        
        for(String videoVer : videoVersions){
            System.debug('####videoVersions:'+videoVer);
        }
            
        for(Client_Avail__c c: clAvailList){
            selectedClientAvailIds.add(c.Id);
        }
        
        test.startTest();
        
        Test.setCurrentPage(Page.WB_PriceWizard); 
		ApexPages.currentPage().getParameters().put('sfdc.tabName', 'Test');
        
        
        WB_PriceWizardController pwc = new WB_PriceWizardController();
        pwc.getUserLocale();
        List<Client_Avail__c> ca = new List<Client_Avail__c>();
        ca = [Select Id,Title_Video_Version__c,Commercial_Avail__r.Country_Lookup__r.Country_Code__c,AccountF__c,Release_Plan_Channel__c,Release_Plan_Format__c,Release_Plan_Language__c,
            RP_Language_Type__c,Territory__c,Price_Tier_Text__c,Title_Content_Type__c,CA_Lifecycle__c,Local_Title__r.Title__r.MPM__r.MPM_Number__c from Client_Avail__c];
        for(Client_Avail__c ca1 : ca){
            system.debug('####Client Avail List:'+ca1.Territory__c);
        }
        
        List<Client_Avail_Price__c> cap = new List<Client_Avail_Price__c>();
        cap = [Select Id,Title_Video_Version__c,Client_Avail__r.Commercial_Avail__r.Country_Lookup__r.Country_Code__c,Account__c,Client_Avail_Channel__c,Client_Avail_Format__c,
              Client_Avail_Language__c,Client_Avail_Language_Type__c,WB_Territory__c,Price_Tier__c,Title_Content_Type__c,CA_Lifecycle__c,Client_Avail__r.Local_Title__r.Title__r.MPM__r.MPM_Number__c from Client_Avail_Price__c];
        for(Client_Avail_Price__c cap1 : cap){
            system.debug('####Client Avail Price List testMethod2 :'+cap1);
        }
        
        List<String> listRecordId_CAP = WB_PriceWizardController.getRecordIDs(videoVersions,fc,'priceUpdate');
        system.debug('###listRecordId_CAP:'+listRecordId_CAP);
        
        List<WB_PriceWizardController.CAPWrapper> wrapperCAPlist = WB_PriceWizardController.getRecords(listRecordId_CAP,'priceUpdate');
        system.debug('###wrapperCAPlist:'+wrapperCAPlist);
        
        Client_Avail__c clientAvail = [Select id,name,Title_Content_Type__c,Start_Date__c from Client_Avail__c where id=: clAvailList[1].id limit 1];
        Client_Avail_Price__c clientAvailPrice = [Select id,name,Price_Code__c,Effective_Date__c from Client_Avail_Price__c where id=: clAvailPriceList[1].id limit 1];
        System.debug('###clientAvail:'+clientAvail);
        System.debug('###clientAvailPrice:'+clientAvailPrice);
        system.debug('###Todays Date:'+system.today());
        WB_PriceWizardController.CAPWrapper caWrap = new WB_PriceWizardController.CAPWrapper();
        caWrap.videoVersion = titleList[1].Video_Version__c;
        caWrap.title = titleList[1].name;
        caWrap.account = accList[1].name;
        caWrap.country = cList[1].Country_Code__c;
        caWrap.channel = 'VODc';
        caWrap.format = 'HD';
        caWrap.language = lList[1].Name;
        caWrap.contentType ='Season';
        caWrap.isRowModified = true;
        caWrap.caName = clientAvail.Name;
        
        caWrap.caCategory = 'Catalog';
        caWrap.capName = clientAvailPrice.Name;
        caWrap.priceCode = 'Direct To Video Catalog Test';
        caWrap.capRecordId = clAvailPriceList[1].Id;
        caWrap.caRecordId = clAvailList[1].id;
        Date effectiveDate = clAvailPriceList[1].Effective_Date__c+10;
        String effeDate = effectiveDate.format();
        caWrap.effectiveDate = effeDate;
        System.debug('###caWrap.effectiveDate:'+caWrap.effectiveDate);
        
        List<WB_PriceWizardController.CAPWrapper> caW = new List<WB_PriceWizardController.CAPWrapper>();
        caW.add(caWrap);
        
        WB_PriceWizardController.CAPWrapper caWrap1 = caWrap.clone();
        caWrap1.isRowModified = false;
        caW.add(caWrap1);
        
        WB_PriceWizardController.CAPWrapper caWrap2 = caWrap.clone();
        caWrap2.caName = 'Invalid Name';
        caW.add(caWrap2);
        
        WB_PriceWizardController.CAPWrapper caWrap3 = caWrap.clone();
        caWrap3.caCategory = 'Invalid Categor';
        caW.add(caWrap3);
        
        WB_PriceWizardController.CAPWrapper caWrap4 = caWrap.clone();
        caWrap4.announcementOverride = 'Invalid Override';
        caW.add(caWrap4);
        
        WB_PriceWizardController.CAPWrapper caWrap5 = caWrap.clone();
        caW.add(caWrap5);
        
        WB_PriceWizardController.CAPWrapper caWrap6 = caWrap.clone();
        caWrap6.effectiveDate = '11/11/2016';
        caW.add(caWrap6);
        
        List<WB_PriceWizardController.CAPWrapper> wrapperList3 =WB_PriceWizardController.savePriceRecords(caW,'rePrice');
        
        test.stopTest(); 
    }
    
    
    private static testMethod void priceUpdateTest1() {
        insertTestData();
        WB_PriceWizardController.FilterCriteria fc = new WB_PriceWizardController.FilterCriteria();
        fc.processName = 'priceUpdate';
        fc.selectedCountries = new List<String>{cList[0].Country_Code__c,cList[1].Country_Code__c};
        fc.selectedAccounts = new List<String>{accList[0].name,accList[1].name};
        fc.selectedChannels = new List<String>{'VODc'};
        fc.selectedFormats = new List<String>{'HD'};
        fc.selectedContentTypes = new List<String>{'Season'};
        fc.selectedCALifeCycles = new List<String>{'Active Current'};
        fc.selectedWBTerritories = new List<String>{'USA'};
        fc.selectedPriceTiers = new List<String>{'28'};
        fc.selectedLangs = new List<String>{'TestFrench'};
        fc.selectedLangTypes = new List<String>{'Sub'};
        fc.mpmNumbers = new List<String>{mpmList[0].MPM_Number__c,mpmList[1].MPM_Number__c};
        videoVersions.add(titleList[0].Video_Version__c);
        videoVersions.add(titleList[1].Video_Version__c);
        videoVersions.add(titleList[2].Video_Version__c);
        
        for(String videoVer : videoVersions){
            System.debug('####videoVersions:'+videoVer);
        }
            
        for(Client_Avail__c c: clAvailList){
            selectedClientAvailIds.add(c.Id);
        }
        
        test.startTest();
        WB_PriceWizardController pwc = new WB_PriceWizardController();
        pwc.getUserLocale();
        List<Client_Avail__c> ca = new List<Client_Avail__c>();
        ca = [Select Id,Title_Video_Version__c,Commercial_Avail__r.Country_Lookup__r.Country_Code__c,AccountF__c,Release_Plan_Channel__c,Release_Plan_Format__c,Release_Plan_Language__c,
            RP_Language_Type__c,Territory__c,Price_Tier_Text__c,Title_Content_Type__c,CA_Lifecycle__c,Local_Title__r.Title__r.MPM__r.MPM_Number__c from Client_Avail__c];
        for(Client_Avail__c ca1 : ca){
            system.debug('####Client Avail List:'+ca1.Territory__c);
        }
        
        List<Client_Avail_Price__c> cap = new List<Client_Avail_Price__c>();
        cap = [Select Id,Title_Video_Version__c,Client_Avail__r.Commercial_Avail__r.Country_Lookup__r.Country_Code__c,Account__c,Client_Avail_Channel__c,Client_Avail_Format__c,
              Client_Avail_Language__c,Client_Avail_Language_Type__c,WB_Territory__c,Price_Tier__c,Title_Content_Type__c,CA_Lifecycle__c,Client_Avail__r.Local_Title__r.Title__r.MPM__r.MPM_Number__c from Client_Avail_Price__c];
        for(Client_Avail_Price__c cap1 : cap){
            system.debug('####Client Avail Price List testMethod2 :'+cap1);
        }
        
        
        List<String> listRecordId_CAP = WB_PriceWizardController.getRecordIDs(videoVersions,fc,'priceUpdate');
        system.debug('###listRecordId_CAP:'+listRecordId_CAP);
        
        Client_Avail_Price__c cap1 = new Client_Avail_Price__c(Client_Avail__c = clAvailList[2].id,Effective_Date__c=system.today()+15,Price__c= 10,Type__c='Reprice',Category__c = 'Catalog');
        Client_Avail_Price__c cap2 = new Client_Avail_Price__c(Client_Avail__c = clAvailList[2].id,Effective_Date__c=system.today()+20,Price__c= 20,Type__c='Reprice',Category__c = 'Catalog');
        List<Client_Avail_Price__c> capList11 = new List<Client_Avail_Price__c>();
        capList11.add(cap1);
        capList11.add(cap2);
        Database.insert(capList11,false);
        
        listRecordId_CAP.add(cap1.Id);
        listRecordId_CAP.add(cap2.Id);
        
        List<WB_PriceWizardController.CAPWrapper> wrapperCAPlist = WB_PriceWizardController.getRecords(listRecordId_CAP,'priceUpdate');
        system.debug('###wrapperCAPlist:'+wrapperCAPlist);
        
        Client_Avail__c clientAvail = [Select id,name,Title_Content_Type__c,Start_Date__c from Client_Avail__c where id=: clAvailList[1].id limit 1];
        Client_Avail_Price__c clientAvailPrice = [Select id,name,Price_Code__c,Effective_Date__c from Client_Avail_Price__c where id=: clAvailPriceList[1].id limit 1];
        System.debug('###clientAvail:'+clientAvail);
        System.debug('###clientAvailPrice:'+clientAvailPrice);
        system.debug('###Todays Date:'+system.today());
        
        WB_PriceWizardController.CAPWrapper caWrap = new WB_PriceWizardController.CAPWrapper();
        caWrap.videoVersion = titleList[1].Video_Version__c;
        caWrap.title = titleList[1].name;
        caWrap.account = accList[1].name;
        caWrap.country = cList[1].Country_Code__c;
        caWrap.channel = 'VODc';
        caWrap.format = 'HD';
        caWrap.language = lList[1].Name;
        caWrap.contentType ='Season';
        caWrap.isRowModified = true;
        caWrap.caName = clientAvail.Name;
        
        caWrap.caCategory = 'Catalog';
        caWrap.capName = clientAvailPrice.Name;
        caWrap.priceCode = 'Direct To Video Catalog Test';
        caWrap.capRecordId = clAvailPriceList[1].Id;
        caWrap.caRecordId = clAvailList[1].id;
        Date effectiveDate = clAvailPriceList[1].Effective_Date__c+10;
        String effeDate = effectiveDate.format();
        caWrap.effectiveDate = effeDate;
        System.debug('###caWrap.effectiveDate:'+caWrap.effectiveDate);
        
        List<WB_PriceWizardController.CAPWrapper> sortList = new List<WB_PriceWizardController.CAPWrapper>();
        WB_PriceWizardController.CAPWrapper caWrapsort1 = caWrap.clone();
        caWrapsort1.priceEffectDate = cap1.Effective_Date__c;
        WB_PriceWizardController.CAPWrapper caWrapsort2 = caWrap.clone();
        caWrapsort2.priceEffectDate = cap2.Effective_Date__c;
        sortList.add(caWrapsort1);
        sortList.add(caWrapsort2);
        sortList.sort();
        
        List<WB_PriceWizardController.CAPWrapper> caW = new List<WB_PriceWizardController.CAPWrapper>();
        caW.add(caWrap);
        
        WB_PriceWizardController.CAPWrapper caWrap1 = caWrap.clone();
        caWrap1.isRowModified = false;
        caW.add(caWrap1);
        
        WB_PriceWizardController.CAPWrapper caWrap2 = caWrap.clone();
        caWrap2.capName = 'Invalid Name';
        caW.add(caWrap2);
        
        WB_PriceWizardController.CAPWrapper caWrap3 = caWrap.clone();
        caWrap3.caCategory = 'Invalid Categor';
        caW.add(caWrap3);
        
        WB_PriceWizardController.CAPWrapper caWrap4 = caWrap.clone();
        caWrap4.announcementOverride = 'Invalid Override';
        caW.add(caWrap4);
        
        
        List<WB_PriceWizardController.CAPWrapper> wrapperList4 =WB_PriceWizardController.savePriceRecords(caW,'priceUpdate');
        caW.clear();
        WB_PriceWizardController.CAPWrapper caWrap6 = caWrap.clone();
        caWrap6.caCategory = null;
        caW.add(caWrap6);
        
        caWrap6 = caWrap.clone();
        caWrap6.effectiveDate = 'sads/45/2045';
        caW.add(caWrap6);
        
        caWrap6 = caWrap.clone();
        caWrap6.price = '10';
        caWrap6.priceTier = 'Test'; 
        caW.add(caWrap6);
        
        caWrap6 = caWrap.clone();
        caWrap6.price = 'test';
        caWrap6.priceTier = 'Test'; 
        caW.add(caWrap6);
        
        caWrap6 = caWrap.clone();
        caWrap6.price = null;
        caWrap6.priceTier = null;
        caWrap6.priceCode = null;
        caW.add(caWrap6);
        
        wrapperList4 =WB_PriceWizardController.savePriceRecords(caW,'priceUpdate');
        caW.clear();
        
        caWrap6 = caWrap.clone();
        caWrap6.episodePrice = '10';
        caWrap6.episodePriceTier = 'Test'; 
        caW.add(caWrap6);
        
        caWrap6 = caWrap.clone();
        caWrap6.episodePrice = 'Test';
        caWrap6.episodePriceTier = 'Test'; 
        caW.add(caWrap6);
        
        caWrap6 = caWrap.clone();
        caWrap6.episodePrice = null;
        caWrap6.episodePriceTier = null; 
        caWrap6.priceCode = null;
        caW.add(caWrap6);
         
        caW.add(caWrap6);
                
        wrapperList4 =WB_PriceWizardController.savePriceRecords(caW,'priceUpdate');
        system.debug('###wrapperList4:'+wrapperList4);
        
        test.stopTest(); 
    }
    
    private static testMethod void priceUpdateTest2withAPODate() {
    	
    	insertTestData1();
        WB_PriceWizardController.FilterCriteria fc = new WB_PriceWizardController.FilterCriteria();
        fc.processName = 'priceUpdate';
        fc.selectedCountries = new List<String>{cList[0].Country_Code__c};
        fc.selectedAccounts = new List<String>{accList[0].name};
        fc.selectedChannels = new List<String>{'EST'};
        fc.selectedFormats = new List<String>{'HD'};
        fc.selectedContentTypes = new List<String>{'Season'};
        fc.selectedCALifeCycles = new List<String>{'Active Current'};
        fc.selectedWBTerritories = new List<String>{'USA'};
        fc.selectedPriceTiers = new List<String>{'28'};
        fc.selectedLangs = new List<String>{'TestFrench'};
        fc.selectedLangTypes = new List<String>{'Sub'};
        fc.mpmNumbers = new List<String>{mpmList[0].MPM_Number__c};
        videoVersions.add(titleList[0].Video_Version__c);
       
        
        test.startTest();
        
        Test.setCurrentPage(Page.WB_PriceWizard); 
		ApexPages.currentPage().getParameters().put('sfdc.tabName', 'Test');
        
        WB_PriceWizardController pwc = new WB_PriceWizardController();
        pwc.getUserLocale();
       
        
        List<String> listRecordId_CAP = WB_PriceWizardController.getRecordIDs(videoVersions,fc,'priceUpdate');
       // system.debug('###listRecordId_CAP:'+listRecordId_CAP);
        
        List<WB_PriceWizardController.CAPWrapper> wrapperCAPlist = WB_PriceWizardController.getRecords(listRecordId_CAP,'priceUpdate');
        //system.debug('###wrapperCAPlist:'+wrapperCAPlist);
        
        Client_Avail__c clientAvail = [Select id,name,Title_Content_Type__c,Start_Date__c from Client_Avail__c where id=: clAvailList[0].id limit 1];
        Client_Avail_Price__c clientAvailPrice = [Select id,name,Price_Code__c,Effective_Date__c from Client_Avail_Price__c where id=:clAvailPriceList[0].id limit 1];
        
        WB_PriceWizardController.CAPWrapper caWrap = new WB_PriceWizardController.CAPWrapper();
        caWrap.videoVersion = titleList[0].Video_Version__c;
        caWrap.title = titleList[0].name;
        caWrap.account = accList[0].name;
        caWrap.country = cList[0].Country_Code__c;
        caWrap.channel = 'EST';
        caWrap.format = 'HD';
        caWrap.language = lList[0].Name;
        caWrap.contentType ='Season';
        caWrap.isRowModified = true;
        caWrap.caName = clientAvail.Name;
        
        caWrap.caCategory = 'Catalog';
        caWrap.capName = clientAvailPrice.Name;
        caWrap.priceCode = 'Direct To Video Catalog Test';
        caWrap.capRecordId = clAvailPriceList[0].Id;
        caWrap.caRecordId = clAvailList[0].id;
        Date effectiveDate = clAvailPriceList[0].Effective_Date__c+10;
        String effeDate = effectiveDate.format();
        caWrap.effectiveDate = effeDate;
        System.debug('###caWrap.effectiveDate:'+caWrap.effectiveDate);
        
        List<WB_PriceWizardController.CAPWrapper> caW = new List<WB_PriceWizardController.CAPWrapper>();
        caW.add(caWrap);
        
        
        WB_PriceWizardController.CAPWrapper caWrap6 = caWrap.clone();
        caWrap6.effectiveDate = '11/11/2016';
        caW.add(caWrap6);
        
        List<WB_PriceWizardController.CAPWrapper> wrapperList3 =WB_PriceWizardController.savePriceRecords(caW,'rePrice');
        
        test.stopTest(); 
        
       
    }
    
}