@isTest(SeeAllData=false) 
public class WB_ClientAvailTempPriceHelperTest {
    static List<Account> accList = new List<Account>();
    static List<Title__c> titleList = new List<Title__c>();
    static List<Country__c> cList = new List<Country__c>();
    static List<Language__c> lList = new List<Language__c>();
    static List<Local_Title__c> lTitle = new List<Local_Title__c>();
    static List<Commercial_Avail__c> cAvailList = new List<Commercial_Avail__c>();
    static List<Agreement__c> agreementList = new List<Agreement__c>();
    static List<Client_Avail__c> clAvailList = new List<Client_Avail__c>();
    static List<Client_Avail_Price__c> clAvailPriceList = new List<Client_Avail_Price__c>();
    static List<Country_SID_Key__c> countrySIDList = new List<Country_SID_Key__c>();
    static List<Product2> productList = new List<Product2>();
    static List<String> selectedClientAvailIds = new List<String>();
    static Integer count=3;   
    static List<Opportunity> dealList = new List<Opportunity>();
    static List<Client_Avail_Price__c> capList1 = new List<Client_Avail_Price__c>();
    //public static Opportunity createDeal1;
    
    public static void setupData(Boolean flag){
	 try{
        TestDataUtility tdu = new TestDataUtility();  
        accList = tdu.createAccountList(); 
        MPM__c m = tdu.createMPM();
        Title__c t = tdu.createTitle(m);
        Language__c l = tdu.createLanguage();
        Country__c c = tdu.createCountry();
        
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=l.Id ,Language_Types__c='Sub',Title__c=t.Id,Clear_To_Avail__c=true);
        insert availLangTitle1;
        
         Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = accList[0].Id,Content_Type__c = t.Content_Type__c,Country__c = c.Id,
                                           Channel__c ='DTD',Format__c ='HD',Price_Tier__c='reprice12');
        insert price1;
        
        Local_Title__c lt = tdu.createlocalTitle(c, l);
        lt.Title__c=t.id;
        update lt;
        //Test.startTest();
        Commercial_Avail__c rp = tdu.createReleasePlan(t, c, lt, l);
        rp.Exclusive_Date__c = System.today().addDays(-200);
        rp.Start_Date__c = System.today().addDays(-200);
        rp.End_Date__c = System.today().addDays(500);
        rp.Rights_End__c= System.today().addDays(500);
        update rp;
        
        String productRecTypeId = WB_PriceUtility.getRecordTypeId(Product2.getSobjectType(),'Digital Product');
        Product2 insertProd = new Product2();
        insertProd.RecordTypeId = productRecTypeId;
        insertProd.Name = 'Test Product';
        insertProd.ProductCode = 'PC001';
        insertProd.Type__c = 'Video Digital';
        insertProd.Product_Market__c ='EST';
        insertProd.Local_Title__c = lt.Id;
        insert insertProd;
        
        String oppRecTypeId = WB_PriceUtility.getRecordTypeId(Opportunity.getSobjectType(),'DC Deals');
        Opportunity createDeal = new Opportunity ();
        createDeal.RecordTypeId = oppRecTypeId;
        createDeal.Name = 'Test Deal';
        createDeal.Deal_Code__c  = 'DC001';
        createDeal.StageName = 'Planned';
        createDeal.Promo_Start_Date__c = System.today().addDays(-400);
        createDeal.Promo_End_Date__c = System.today().addDays(-200);
        createDeal.Start_Date__c = System.today().addDays(-400);
        createDeal.CloseDate = System.today().addDays(-200);
        createDeal.Account = accList[0];
        dealList.add(createDeal);
        insert dealList; 
        
       Agreement__c sf = tdu.createStorefront(c,rp, t, accList[0]);
       
       //list<Client_Avail__c> CaccListInsert = New list<Client_Avail__c>();
       Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID,Local_Data_Category_Picklist__c='Catalog', Price_Tier_Text__c = 'reprice12',Status__c='Confirmed',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(-5),End_Date__c=System.today().addDays(400));
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID,Local_Data_Category_Picklist__c='Catalog',Price_Tier_Text__c = 'reprice12', Status__c='Confirmed',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(-20),End_Date__c=System.today().addDays(300));
       clAvailList.add(ca);
       clAvailList.add(ca1);
       insert clAvailList;
       
       
       String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
       Client_Avail_Price__c cap1 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=ca.Start_Date__c,Expiry_Date__c=ca.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c cap2 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=ca1.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c cap3 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=ca1.Start_Date__c.addDays(20),Price__c=10.99);

        //List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
        capList1.add(cap1);
        capList1.add(cap2);
        capList1.add(cap3);
       
       
       WB_ClientAvailPriceHandler.recursiveInsert = true;
        Database.SaveResult[] insertResultList = Database.insert(capList1,false);
        for(Integer index=0;index<insertResultList.size();index++){
            Database.SaveResult insertResult = insertResultList[index]; 
            if(!insertResult.isSuccess()){
                for(Database.Error err : insertResult.getErrors()) {
                    System.debug(LoggingLevel.INFO,'insertResult Error ->'+ err.getMessage());
                }
            }
        }
        //Test.stopTest();
		
	} catch(Exception e) {
        System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
    }
  
   @isTest
    public static void insertTestData(){
	 try{
	     
	     
        TestDataUtility tdu = new TestDataUtility();  
        accList = tdu.createAccountList(); 
        MPM__c m = tdu.createMPM();
        Title__c t = tdu.createTitle(m);
        Language__c l = tdu.createLanguage();
        Country__c c = tdu.createCountry();
        
        
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=l.Id ,Language_Types__c='Sub',Title__c=t.Id,Clear_To_Avail__c=true);
        insert availLangTitle1;
        
         Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = accList[0].Id,Content_Type__c = t.Content_Type__c,Country__c = c.Id,
                                           Channel__c ='DTD',Format__c ='HD',Price_Tier__c='reprice12');
        insert price1;
        
        Local_Title__c lt = tdu.createlocalTitle(c, l);
        lt.Title__c=t.id;
        update lt;
       
        Commercial_Avail__c rp = tdu.createReleasePlan(t, c, lt, l);
        rp.Exclusive_Date__c = System.today().addDays(-200);
        rp.Start_Date__c = System.today().addDays(-200);
        rp.End_Date__c = System.today().addDays(500);
        rp.Rights_End__c= System.today().addDays(500);
        
        Test.startTest();
        update rp;
        
        String productRecTypeId = WB_PriceUtility.getRecordTypeId(Product2.getSobjectType(),'Digital Product');
        Product2 insertProd = new Product2();
        insertProd.RecordTypeId = productRecTypeId;
        insertProd.Name = 'Test Product';
        insertProd.ProductCode = 'PC001';
        insertProd.Type__c = 'Video Digital';
        insertProd.Product_Market__c ='EST';
        insertProd.Local_Title__c = lt.Id;
        insert insertProd;
        
        String oppRecTypeId = WB_PriceUtility.getRecordTypeId(Opportunity.getSobjectType(),'DC Deals');
        Opportunity createDeal = new Opportunity ();
        createDeal.RecordTypeId = oppRecTypeId;
        createDeal.Name = 'Test Deal';
        createDeal.Deal_Code__c  = 'DC001';
        createDeal.StageName = 'Planned';
        createDeal.Promo_Start_Date__c = System.today().addDays(-400);
        createDeal.Promo_End_Date__c = System.today().addDays(-200);
        createDeal.Start_Date__c = System.today().addDays(-400);
        createDeal.CloseDate = System.today().addDays(-200);
        createDeal.Account = accList[0];
        insert createDeal; 
        
       Agreement__c sf = tdu.createStorefront(c,rp, t, accList[0]);
       
       list<Client_Avail__c> CaccListInsert = New list<Client_Avail__c>();
       Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID,Local_Data_Category_Picklist__c='Catalog', Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(-5),End_Date__c=System.today().addDays(400));
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID,Local_Data_Category_Picklist__c='Catalog',Price_Tier_Text__c = 'reprice12', Status__c='Confirmed',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(-20),End_Date__c=System.today().addDays(300));
       CaccListInsert.add(ca);
       CaccListInsert.add(ca1);
       insert CaccListInsert;
       
       
       String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
       Client_Avail_Price__c cap1 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=ca.Start_Date__c,Expiry_Date__c=ca.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c cap2 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=ca1.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c cap3 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=ca1.Start_Date__c.addDays(20),Price__c=10.99);

        List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
        capList.add(cap1);
        capList.add(cap2);
        capList.add(cap3);
       
       
       WB_ClientAvailPriceHandler.recursiveInsert = true;
        Database.SaveResult[] insertResultList = Database.insert(capList,false);
        for(Integer index=0;index<insertResultList.size();index++){
            Database.SaveResult insertResult = insertResultList[index]; 
            if(!insertResult.isSuccess()){
                for(Database.Error err : insertResult.getErrors()) {
                    System.debug(LoggingLevel.INFO,'insertResult Error ->'+ err.getMessage());
                }
            }
        }
        
        
        List<WB_ClientAvailTempPriceWrapper> wbList = new List<WB_ClientAvailTempPriceWrapper>();
        WB_ClientAvailTempPriceWrapper wb1 = new WB_ClientAvailTempPriceWrapper();
        wb1.clientAvailID = ca1.Id;
        wb1.price = 13.6;
        //wb1.episodePrice = 23.1;
        wb1.priceStartDate = System.today().addDays(25);
        wb1.priceEndDate = System.today().addDays(120);
        wb1.priceStatus = 'Active';
        wb1.category = 'TV Catalog';
        wb1.dealID = createDeal.Id;
        wb1.dealStatus = 'Committed';
        wbList.add(wb1);
        
        WB_ClientAvailTempPriceWrapper wb7 = new WB_ClientAvailTempPriceWrapper();
        wb7.clientAvailID = ca1.Id;
        wb7.price = 13.6;
        //wb7.episodePrice = 23.1;
        wb7.priceStartDate = System.today().addDays(120);
        wb7.priceEndDate = System.today().addDays(180);
        wb7.priceStatus = 'Active';
        wb7.category = 'TV Catalog';
        wb7.dealID = createDeal.Id;
        wb7.dealStatus = 'Committed';
        wbList.add(wb7);
        
         //Generate Announcement 
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
        EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announcement USA Standard'][0];
            
        String reportIdFromReport = null;//(String)reportList.get(0).get('Id');
        Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
        Datetime myDateTime1 = Datetime.newInstance(2014, 4, 17);
        
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=accList[0].Id,
                                                        Content_Type__c = 'Season; Episode', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='DTD;VODc',Selection_Criteria__c = 'Framed Delta', 
                                                        Report_Template__c='WB Standard Combined',Email_Template_Id__c=templateId.id,Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                        Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportIdFromReport, Date_Last_Run__c= myDateTime,Full_Extract__c = true,Include_Promotional_Price__c = TRUE);
        insert annRule;
        
        //create Announcement
         Announcement__c announcement = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Season; Episode', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='90 Day Rolling',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST;VODc');
                                                            
        insert announcement;
        
        String tpRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME);
        Client_Avail_Price__c tempCAP = new Client_Avail_Price__c(RecordTypeId=tpRecTypeId,Deal_ID__c =createDeal.Id,Client_Avail__c=ca1.id,Category__c='TV Catalog',Effective_Date__c=System.today().addDays(-2),Expiry_Date__c=System.today().addDays(300),Price__c=13.99);
        insert tempCAP;
         
        WB_ClientAvailTempPriceHelper wb_TPh = new WB_ClientAvailTempPriceHelper();
        wb_TPh.upsertTempPrice(wbList);
        wb_TPh.validateTempPrice(wbList);
        
        wbList = new List<WB_ClientAvailTempPriceWrapper>();
        WB_ClientAvailTempPriceWrapper wb8 = new WB_ClientAvailTempPriceWrapper();
        wb8.clientAvailID = ca1.Id;
        wb8.price = 10.6;
        //wb8.episodePrice = 25.1;
        wb8.priceStartDate = System.today().addDays(25);
        wb8.priceEndDate = System.today().addDays(120);
        wb8.priceStatus = 'Active';
        wb8.category = 'TV Catalog';
        wb8.dealID = createDeal.Id;
        wb8.dealStatus = 'Committed';
        wbList.add(wb8);
        wb_TPh.upsertTempPrice(wbList);
        wb_TPh.validateTempPrice(wbList);
        
        wbList = new List<WB_ClientAvailTempPriceWrapper>();
        WB_ClientAvailTempPriceWrapper wb10 = new WB_ClientAvailTempPriceWrapper();
        wb10.clientAvailID = ca1.Id;
        wb10.price = 10.6;
        //wb10.episodePrice = 25.1;
        wb10.priceStartDate = System.today().addDays(-2);
        wb10.priceEndDate = System.today().addDays(120);
        wb10.priceStatus = 'Active';
        wb10.category = 'TV Catalog';
        wb10.dealID = createDeal.Id;
        wb10.dealStatus = 'Committed';
        wbList.add(wb10);
        wb_TPh.upsertTempPrice(wbList);
        wb_TPh.validateTempPrice(wbList);
        
        wbList =   new List<WB_ClientAvailTempPriceWrapper>();
         WB_ClientAvailTempPriceWrapper wb3 = new WB_ClientAvailTempPriceWrapper();
        //wb2.clientAvailID = ca1.Id;
        wb3.price = 13.6;
        //wb3.episodePrice = 23.1;
        wb3.priceStartDate = System.today().addDays(25);
        wb3.priceEndDate = System.today().addDays(120);
        wb3.priceStatus = 'Active';
        wb3.category = 'TV Catalog';
        wb1.dealStatus = 'Committed';
        wb3.dealID = createDeal.Id;
        wbList.add(wb3);
        wb_TPh.validateTempPrice(wbList);
        
        wbList =   new List<WB_ClientAvailTempPriceWrapper>();
        WB_ClientAvailTempPriceWrapper wb4 = new WB_ClientAvailTempPriceWrapper();
        wb4.clientAvailID = ca1.Id;
        wb4.price = 13.6;
        //wb4.episodePrice = 23.1;
        Date startDate2 = System.today().addDays(-25);
        wb4.priceStartDate = startDate2;
        Date endDate2 = System.today().addDays(500);
        wb4.priceEndDate = endDate2;
         wb1.dealStatus = 'Committed';
        wb4.priceStatus = 'Active';
        wb4.category = 'TV Catalog';
        wb4.dealID = createDeal.Id;
        wbList.add(wb4);
        wb_TPh.validateTempPrice(wbList);
         
        wbList =   new List<WB_ClientAvailTempPriceWrapper>();
        WB_ClientAvailTempPriceWrapper wb5 = new WB_ClientAvailTempPriceWrapper();
        wb5.clientAvailID = ca1.Id;
        wb5.price = 13.6;
        //wb5.episodePrice = 23.1;
        wb5.priceStartDate = System.today().addDays(25);
        wb5.priceEndDate = System.today().addDays(120);
        wb5.priceStatus = 'Active';
        wb5.category = 'TV Catalog';
        wb5.dealID = createDeal.Id;
        wb5.dealStatus = 'Cancelled';
        wbList.add(wb5);
        wb_TPh.upsertTempPrice(wbList);
        wb_TPh.validateTempPrice(wbList);
        
        List<Client_Avail_Price__c> capRecord = new List<Client_Avail_Price__c>();
        capRecord = [SELECT Id FROM Client_Avail_Price__c WHERE Deal_ID__c =: createDeal.Id AND Client_Avail__c = :ca1.ID];
       // system.debug('capRecord>>>>>'+capRecord);
        Announcement_Record__c annRecords0 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca1.Id,Client_Start__c=system.today()+21,Client_End__c=system.today()+30,Client_Avail_Price__c=capRecord[0].Id);
        insert annRecords0;
         // system.debug('annRecords0>>>>>'+annRecords0.Client_Avail_Price__c);
          
        wbList =   new List<WB_ClientAvailTempPriceWrapper>();
        WB_ClientAvailTempPriceWrapper wb6 = new WB_ClientAvailTempPriceWrapper();
        wb6.clientAvailID = ca.Id;
        wb6.price = 13.6;
        //wb6.episodePrice = 23.1;
        wb6.priceStartDate = System.today().addDays(25);
        wb6.priceEndDate = System.today().addDays(120);
        wb6.priceStatus = 'Active';
        wb6.category = 'TV Catalog';
        wb6.dealID = createDeal.Id;
        wb6.dealStatus = 'Committed';
        wbList.add(wb6);
       // system.debug('wbList>>>>>>>'+wbList);
        wb_TPh.upsertTempPrice(wbList);
        wb_TPh.validateTempPrice(wbList);
        Client_Avail_Price__c tempCAP1 = new Client_Avail_Price__c(RecordTypeId=tpRecTypeId,Deal_ID__c =createDeal.Id,Client_Avail__c=ca.id,Category__c='TV Catalog',Effective_Date__c=System.today().addDays(-2),Expiry_Date__c=System.today().addDays(30),Price__c=1.99);
        insert tempCAP1;		
        
        wbList =   new List<WB_ClientAvailTempPriceWrapper>();
        WB_ClientAvailTempPriceWrapper wb2 = new WB_ClientAvailTempPriceWrapper();
        wb2.clientAvailID = ca1.Id;
        wb2.price = 13.6;
        //wb2.episodePrice = 23.1;
        Date startDate3 = System.today().addDays(25);
        wb2.priceStartDate = startDate3;
         wb1.dealStatus = 'Committed';
        Date endDate3 = System.today().addDays(500);
        wb2.priceEndDate = endDate3;
        wb2.priceStatus = 'Active';
        wb2.category = 'TV Catalog';
        wb2.dealID = createDeal.Id;
        wbList.add(wb2);
        
       
        
        Announcement_Record__c annRecords01 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca.Id,Client_Start__c=system.today()+21,Client_End__c=system.today()+30,Client_Avail_Price__c=tempCAP1.Id);
        insert annRecords01;
        
        WB_ClientAvailTempPriceHelper wb_h = new WB_ClientAvailTempPriceHelper();
        wb_h.upsertTempPrice(wbList);
        wb_h.validateTempPrice(wbList);
        wb_h.validatePriceData(wb2,ca1);
        
        Test.stopTest();
	  } catch(Exception e) {
        System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
    }
    
    @isTest
     public static void checkAnnouncement(){
	  try{
        //setUpData(true);
        
        TestDataUtility tdu = new TestDataUtility();  
        accList = tdu.createAccountList(); 
        MPM__c m = tdu.createMPM();
        Title__c t = tdu.createTitle(m);
        Language__c l = tdu.createLanguage();
        Country__c c = tdu.createCountry();
        
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=l.Id ,Language_Types__c='Sub',Title__c=t.Id,Clear_To_Avail__c=true);
        insert availLangTitle1;
        
         Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = accList[0].Id,Content_Type__c = t.Content_Type__c,Country__c = c.Id,
                                           Channel__c ='DTD',Format__c ='HD',Price_Tier__c='reprice12');
        insert price1;
        
        Local_Title__c lt = tdu.createlocalTitle(c, l);
        lt.Title__c=t.id;
        update lt;
        //
        Commercial_Avail__c rp = tdu.createReleasePlan(t, c, lt, l);
        rp.Exclusive_Date__c = System.today().addDays(-200);
        rp.Start_Date__c = System.today().addDays(-200);
        rp.End_Date__c = System.today().addDays(500);
        rp.Rights_End__c= System.today().addDays(500);
        
        Test.startTest();
        update rp;
        
        String productRecTypeId = WB_PriceUtility.getRecordTypeId(Product2.getSobjectType(),'Digital Product');
        Product2 insertProd = new Product2();
        insertProd.RecordTypeId = productRecTypeId;
        insertProd.Name = 'Test Product';
        insertProd.ProductCode = 'PC001';
        insertProd.Type__c = 'Video Digital';
        insertProd.Product_Market__c ='EST';
        insertProd.Local_Title__c = lt.Id;
        insert insertProd;
        
        String oppRecTypeId = WB_PriceUtility.getRecordTypeId(Opportunity.getSobjectType(),'DC Deals');
        Opportunity createDeal = new Opportunity ();
        createDeal.RecordTypeId = oppRecTypeId;
        createDeal.Name = 'Test Deal';
        createDeal.Deal_Code__c  = 'DC001';
        createDeal.StageName = 'Planned';
        createDeal.Promo_Start_Date__c = System.today().addDays(-400);
        createDeal.Promo_End_Date__c = System.today().addDays(-200);
        createDeal.Start_Date__c = System.today().addDays(-400);
        createDeal.CloseDate = System.today().addDays(-200);
        createDeal.Account = accList[0];
        dealList.add(createDeal);
        insert dealList; 
        
       Agreement__c sf = tdu.createStorefront(c,rp, t, accList[0]);
       
       //list<Client_Avail__c> CaccListInsert = New list<Client_Avail__c>();
       Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID,Local_Data_Category_Picklist__c='Catalog', Price_Tier_Text__c = 'reprice12',Status__c='Confirmed',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(-5),End_Date__c=System.today().addDays(400));
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID,Local_Data_Category_Picklist__c='Catalog',Price_Tier_Text__c = 'reprice12', Status__c='Confirmed',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(-20),End_Date__c=System.today().addDays(300));
       clAvailList.add(ca);
       clAvailList.add(ca1);
       insert clAvailList;
       
       
       String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
       Client_Avail_Price__c cap1 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=ca.Start_Date__c,Expiry_Date__c=ca.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c cap2 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=ca1.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c cap3 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=ca1.Start_Date__c.addDays(20),Price__c=10.99);

        //List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
        capList1.add(cap1);
        capList1.add(cap2);
        capList1.add(cap3);
       
       
       WB_ClientAvailPriceHandler.recursiveInsert = true;
        Database.SaveResult[] insertResultList = Database.insert(capList1,false);
        for(Integer index=0;index<insertResultList.size();index++){
            Database.SaveResult insertResult = insertResultList[index]; 
            if(!insertResult.isSuccess()){
                for(Database.Error err : insertResult.getErrors()) {
                    System.debug(LoggingLevel.INFO,'insertResult Error ->'+ err.getMessage());
                }
            }
        }
        
        Set<Id> caIdSet = new Set<Id>();
       // system.debug('Inside checkAnnouncement...');
        
        //Test.startTest();  
        List<WB_ClientAvailTempPriceWrapper> wbList = new List<WB_ClientAvailTempPriceWrapper>();
        WB_ClientAvailTempPriceWrapper wb1 = new WB_ClientAvailTempPriceWrapper();
        wb1.clientAvailID = clAvailList[0].Id;
        wb1.priceTier = '13.6';
        //wb1.episodePrice = 23.1;
        wb1.priceStartDate = System.today().addDays(-2);
        wb1.priceEndDate = System.today().addDays(120);
        wb1.priceStatus = 'Active';
        wb1.category = 'TV Catalog';
        wb1.dealID = dealList[0].Id;
        wb1.dealStatus = 'Committed';
        wbList.add(wb1);
        
        WB_ClientAvailTempPriceWrapper wb7 = new WB_ClientAvailTempPriceWrapper();
        wb7.clientAvailID = clAvailList[1].Id;
        wb7.price = 13.6;
        //wb7.episodePrice = 23.1;
        wb7.priceStartDate = System.today().addDays(-2);
        wb7.priceEndDate = System.today().addDays(180);
        wb7.priceStatus = 'Active';
        wb7.category = 'TV Catalog';
        wb7.dealID = dealList[0].Id;
        wb7.dealStatus = 'Committed';
        wbList.add(wb7);
        
        for(Client_Avail__c caId1 : clAvailList){
            caIdSet.add(caId1.Id);
        }
        WB_ClientAvailTempPriceHelper wb_TPh = new WB_ClientAvailTempPriceHelper();
        List<WB_ClientAvailTempPriceWrapper> returnList = wb_TPh.upsertTempPrice(wbList);
       // system.debug('returnList:'+returnList);
        //wb_TPh.validateTempPrice(wbList);
        
        List<Client_Avail_Price__c> capRecord = new List<Client_Avail_Price__c>();
        capRecord = [SELECT Id FROM Client_Avail_Price__c WHERE Deal_ID__c =: dealList[0].Id AND Client_Avail__c IN: caIdSet];
        system.debug('capRecord Size:'+capRecord.size());
        
         //Generate Announcement 
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
        EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announcement USA Standard'][0];
            
        String reportIdFromReport = null;//(String)reportList.get(0).get('Id');
        Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
        Datetime myDateTime1 = Datetime.newInstance(2014, 4, 17);
        
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=accList[0].Id,
                                                        Content_Type__c = 'Season; Episode', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='DTD;VODc',Selection_Criteria__c = 'Framed Delta', 
                                                        Report_Template__c='WB Standard Combined',Email_Template_Id__c=templateId.id,Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                        Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportIdFromReport, Date_Last_Run__c= myDateTime,Full_Extract__c = true,Include_Promotional_Price__c = TRUE);
        insert annRule;
        
        //create Announcement
         Announcement__c announcement = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Season; Episode', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='90 Day Rolling',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST;VODc');
                                                            
        insert announcement;
        
       
        
        String tpRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME);
        Client_Avail_Price__c tempCAP = new Client_Avail_Price__c(RecordTypeId=tpRecTypeId,Deal_ID__c =dealList[0].Id,Client_Avail__c=clAvailList[0].id,Category__c='TV Catalog',Effective_Date__c=System.today().addDays(-2),Expiry_Date__c=System.today().addDays(300),Price__c=3.99);
        insert tempCAP;
        
         Announcement_Record__c annRecords01 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=clAvailList[0].Id,Client_Start__c=system.today()-2,Client_End__c=system.today()+30,Client_Avail_Price__c=capRecord[0].Id);
        insert annRecords01;
        
        Announcement_Record__c annRecords02 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=clAvailList[1].Id,Client_Start__c=system.today()-2,Client_End__c=system.today()+30,Client_Avail_Price__c=capRecord[1].Id);
        insert annRecords02;
        
        List<Announcement_Record__c> annRec = new List<Announcement_Record__c>();
        annRec = [Select Id,Client_Avail__r.Name,Client_Avail_Price__r.Name from Announcement_Record__c];
        /*for(Announcement_Record__c ann : annRec){
            system.debug('Announcement Rec:'+ann);
        } */
        
        List<Client_Avail_Price__c> queriedCaps = [Select Id,Name,Effective_Date__c,Client_Avail__c,Price_Tier__c,Price__c,CurrencyIsoCode,CAP_Status__c,Category__c,Episode_Price__c,Episode_Price_Tier__c,(Select Id,Name,Announcement_Date__c,Client_Start__c from Announcement_Records__r Limit 1),Client_Avail__r.Start_Date__c,Client_Avail__r.End_Date__c,Client_Avail__r.Status__c,Deal_ID__c,Client_Avail__r.Local_Data_Category_Picklist__c From Client_Avail_Price__c ];
        for(Client_Avail_Price__c cap:queriedCaps){
            system.debug('cap:'+cap);
            system.debug('related Announcement Rec size:'+cap.Announcement_Records__r.size());
        }
        
        List<WB_ClientAvailTempPriceWrapper> wbList1 = new List<WB_ClientAvailTempPriceWrapper>();
        WB_ClientAvailTempPriceWrapper wb_1 = new WB_ClientAvailTempPriceWrapper();
        wb_1.clientAvailID = clAvailList[0].Id;
        wb1.priceTier = '98.3';
        wb_1.price = 13.6;
        //wb_1.episodePrice = 23.1;
        wb_1.priceStartDate = System.today().addDays(-2);
        wb_1.priceEndDate = System.today().addDays(120);
        wb_1.priceStatus = 'Active';
        wb_1.category = 'TV Catalog';
        wb_1.dealID = dealList[0].Id;
        wb_1.dealStatus = 'Committed';
        wbList1.add(wb_1);
        
        WB_ClientAvailTempPriceHelper wb_TPh1 = new WB_ClientAvailTempPriceHelper();
       
        List<WB_ClientAvailTempPriceWrapper> returnList1 = wb_TPh1.upsertTempPrice(wbList1);
       
        Test.stopTest();
        } catch(Exception e) {
        System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
        
     }
	 
	 
    
    
}