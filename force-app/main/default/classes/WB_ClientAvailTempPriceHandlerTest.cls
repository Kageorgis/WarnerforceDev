@isTest(SeeAllData=false)
    public class WB_ClientAvailTempPriceHandlerTest {
        static List<Account> accList = new List<Account>();
       // static List<Country_SID_Key__c> countrySIDList = new List<Country_SID_Key__c>();
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
  
   @isTest
    public static void createTempCapMethod(){
        TestDataUtility tdu = new TestDataUtility();  
        accList = tdu.createAccountList(); 
        MPM__c m = tdu.createMPM();
        Title__c t = tdu.createTitle(m);
        Language__c l = tdu.createLanguage();
        //Country__c c = tdu.createCountry();
        Country__c c = TestUtil.initCountry('Colombia', 'CO', 'COL');
        insert c;
        
        countrySIDList.add(new Country_SID_Key__c(Name='Colombia', Country_Code__c='COL',Country_Code2_c__c='CO',Locale_SID_Key__c='America/Los_Angeles',Region__c='North America'));
        insert countrySIDList;
        
         Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = accList[0].Id,Content_Type__c = t.Content_Type__c,Country__c = c.Id,
                                           Channel__c ='DTD',Format__c ='HD',Price_Tier__c='reprice12');
        insert price1;
        
        Local_Title__c lt = tdu.createlocalTitle(c, l);
        lt.Title__c=t.id;
        update lt;
        
        Available_Languages__c availLang = new Available_Languages__c(Title__c=t.id,Language__c=l.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang ;
       
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
        Test.startTest();
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
       Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID,Local_Data_Category_Picklist__c='Catalog', Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(5),End_Date__c=System.today().addDays(400));
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID,Local_Data_Category_Picklist__c='Catalog',Price_Tier_Text__c = 'reprice12', Status__c='Confirmed',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(20),End_Date__c=System.today().addDays(300));
       CaccListInsert.add(ca);
       CaccListInsert.add(ca1);
       insert CaccListInsert;
       
       
       String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
       String tpRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME);
       Client_Avail_Price__c cap1 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=ca.Start_Date__c,Expiry_Date__c=ca.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c cap2 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=ca1.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c cap3 = new Client_Avail_Price__c(RecordTypeId=tpRecTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=ca1.Start_Date__c.addDays(20),Price__c=10.99);
       //Client_Avail_Price__c cap4 = new Client_Avail_Price__c(RecordTypeId=tpRecTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c.addDays(-6),Expiry_Date__c=ca1.Start_Date__c.addDays(20),Price__c=10.99);
        List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
        capList.add(cap1);
        capList.add(cap2);
        capList.add(cap3);
        //capList.add(cap4);
       
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
        Profile p = [SELECT Id FROM Profile WHERE Name='WB - Global Title Planner'];
        User u2 = new User(Alias = 'wbUser', Email='wbuser@caporg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='wbuser@caporg.com');
         
         // Create record for WB_GPP_Pricing_Profiles__c custom setting
         WB_GPP_Pricing_Profiles__c gppProfile = new WB_GPP_Pricing_Profiles__c(Name = 'WB - Global Title Planner');
         insert gppProfile;
         
      
      System.runAs(u2) {
       WB_ClientAvailTempPriceHandler.validateTempPrice(capList,WB_PriceUtility.INSERT_OP);
       }
      
     
      WB_ClientAvailTempPriceHandler.updateClientAvailWithTempPrice(capList,new Map<Id,Client_Avail_Price__c>(),WB_PriceUtility.INSERT_OP);
      capList[2].Effective_Date__c=ca1.Start_Date__c.addDays(10);
      update capList[2];
      WB_ClientAvailTempPriceHandler.updateClientAvailWithTempPrice(capList,new Map<Id,Client_Avail_Price__c>(),WB_PriceUtility.UPDATE_OP);
      capList[2].Effective_Date__c=ca1.Start_Date__c;
      update capList[2];
      WB_ClientAvailTempPriceHandler.getPermanentPriceRecords(capList);
      Map<Id,Client_Avail_Price__c> permanentCapMap = new Map<Id,Client_Avail_Price__c>();
      permanentCapMap.put(capList[0].Id,capList[0]);
      permanentCapMap.put(capList[1].Id,capList[1]);
      WB_ClientAvailTempPriceHandler.getPermanentPriceRecords(permanentCapMap);
      Map<Id,Client_Avail_Price__c> tempCapMap = new Map<Id,Client_Avail_Price__c>();
      tempCapMap.put(capList[2].Id,capList[2]);
      WB_ClientAvailTempPriceHandler.getTempPriceRecords(tempCapMap);
       
      WB_ClientAvailTempPriceHandler.updateClientAvailWithTempPrice(capList,tempCapMap,WB_PriceUtility.DELETE_OP);
      capList =  new List<Client_Avail_Price__c>();
      capList.add(cap1);
      capList.add(cap2);
       WB_ClientAvailTempPriceHandler.updateClientAvailWithTempPrice(capList,permanentCapMap,WB_PriceUtility.INSERT_OP);
       
     Test.stopTest();
      
        
    }
    
    @isTest
    public static void announceTempCAP(){
        TestDataUtility tdu = new TestDataUtility();  
        accList = tdu.createAccountList(); 
        MPM__c m = tdu.createMPM();
        Title__c t = tdu.createTitle(m);
        Language__c l = tdu.createLanguage();
        //Country__c c = tdu.createCountry();
        Country__c c = TestUtil.initCountry('Colombia', 'CO', 'COL');
        insert c;
        
        countrySIDList.add(new Country_SID_Key__c(Name='Colombia', Country_Code__c='COL',Country_Code2_c__c='CO',Locale_SID_Key__c='America/Los_Angeles',Region__c='North America'));
        insert countrySIDList;
        
         Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = accList[0].Id,Content_Type__c = t.Content_Type__c,Country__c = c.Id,
                                           Channel__c ='DTD',Format__c ='HD',Price_Tier__c='reprice12');
        insert price1;
        
        Local_Title__c lt = tdu.createlocalTitle(c, l);
        lt.Title__c=t.id;
        update lt;
        
        Available_Languages__c availLang = new Available_Languages__c(Title__c=t.id,Language__c=l.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang ;
       
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
        Test.startTest();  
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
       Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID,Local_Data_Category_Picklist__c='Catalog', Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(5),End_Date__c=System.today().addDays(400));
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID,Local_Data_Category_Picklist__c='Catalog',Price_Tier_Text__c = 'reprice12', Status__c='Confirmed',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(20),End_Date__c=System.today().addDays(300));
       CaccListInsert.add(ca);
       CaccListInsert.add(ca1);
       insert CaccListInsert;
       
       
       String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
       String tpRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME);
       Client_Avail_Price__c cap1 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=ca.Start_Date__c,Expiry_Date__c=ca.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c cap2 = new Client_Avail_Price__c(RecordTypeId=tpRecTypeId,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=ca.Start_Date__c,Expiry_Date__c=System.today().addDays(40),Price__c=20.99);
       Client_Avail_Price__c cap3 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=System.today().addDays(119),Price__c=55.99);
       Client_Avail_Price__c cap4 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = 'Reprice',Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=System.today().addDays(120),Expiry_Date__c=ca1.End_Date__c,Price__c=18.99);
       Client_Avail_Price__c cap5 = new Client_Avail_Price__c(RecordTypeId=tpRecTypeId,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=ca1.Start_Date__c.addDays(20),Price__c=13.99);
        List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
        capList.add(cap1);
        capList.add(cap2);
        capList.add(cap3);
        capList.add(cap4);
        capList.add(cap5);
      
       WB_ClientAvailPriceHandler.recursiveInsert = false;
        Database.SaveResult[] insertResultList = Database.insert(capList,false);
        for(Integer index=0;index<insertResultList.size();index++){
            Database.SaveResult insertResult = insertResultList[index]; 
            if(!insertResult.isSuccess()){
                for(Database.Error err : insertResult.getErrors()) {
                    System.debug(LoggingLevel.INFO,'insertResult Error ->'+ err.getMessage());
                }
            }
        }
        
     
      
       
     Test.stopTest();
      
        
    }
}