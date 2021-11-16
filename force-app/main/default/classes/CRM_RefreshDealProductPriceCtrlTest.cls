/**
   @Author Cognizant
   @name CRM_RefreshDealProductPriceCtrlTest
   @CreateDate 15 Jan 2016
   @Description - Test Class for CRM_RefreshDealProductPriceCtrl
   @Version <1.0>
   @reference Requirement#170
*/


@isTest
private with sharing class CRM_RefreshDealProductPriceCtrlTest{

/**
*Description-The method is used to create test data and verify if expected functionality is covered 
*@name-testData
*/

  static testmethod void testData(){  
    
    List<Account> lstAcc = new List<Account>();
    List<PricebookEntry> lstPriceBookEntry = new List<PricebookEntry>();
    List<Product2> lstProduct = new List<Product2>();
    List<Opportunity> lstOpportunity = new List<Opportunity>();
    List<OpportunityLineItem> lstDP = new List<OpportunityLineItem>();
    List<OpportunityLineItem> lstModifiedDP = new List<OpportunityLineItem>();
    
    //create Account 
    lstAcc = CRM_TestDataFactory.createAccounts(1,false);
    lstAcc[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
    lstAcc[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
    lstAcc[0].CurrencyISOCode = 'USD';
    lstAcc[0].Games_Physical__c = true;
    insert lstAcc;
    
    System.assertEquals(1,lstAcc.size(),'Created 1 Enteries');
    
    List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
    lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 1, false);
    lstProduct[0].CurrencyIsoCode = 'USD';
    insert lstProduct;
    
   //Create PricebookEntrys
     lstPriceBookEntry = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
     lstPriceBookEntry[0].Product2Id = lstProduct[0].Id;
     lstPriceBookEntry[0].CurrencyIsoCode = 'USD';
     insert lstPriceBookEntry;
     
     // Setting up 1 Price Book Entry Period for USD Pricebook
    List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
    CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{lstProduct[0]}, 1, false);
    lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = lstProduct[0].id;
    lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 140;
    lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 150;
    lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'USD';
    //lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 10;
    lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 100;
    lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Retail_Price__c = 100;
    lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Minimum_Price__c = 100;
    //lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Suggested_Price__c = null;
    lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Account_Price__c = 100;
    insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;
    
    CRM_Restrict_Refresh_Deal_Product_Prices__c refeshcsutomSetting = new CRM_Restrict_Refresh_Deal_Product_Prices__c(Name='Restrict Refresh prices on DP',Sales_Organisation__c='2500;2403',Digital_Country_Code__c='435; 443');
    insert refeshcsutomSetting;
    
    List<Id> DealId = new List<Id>();
    if(!lstAcc.isEmpty()){
        Id standardPricebookId = System.Test.getStandardPricebookId();
        lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAcc,1,false);
         for (Integer i=0; i < lstOpportunity.size(); i++) {
             lstOpportunity[i].Market_Type__c = '1';
             lstOpportunity[i].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
             lstOpportunity[i].Start_Date__c = System.today() + 141;
	         lstOpportunity[i].Promo_Start_Date__c = System.today() + 141;
		     lstOpportunity[i].CloseDate = System.today() + 149;
         }
         insert lstOpportunity;
         
        // for(Opportunity opp: lstOpportunity)
        System.assertEquals(1, lstOpportunity.size(), 'Created 100 Opportunities where AccountID is the Parent Account');
        
        for(Opportunity opp: lstOpportunity)
        DealId.add(opp.id);
        
        if(lstPriceBookEntry.size()>0 && lstOpportunity.size()>0){
            List<OpportunityLineItem> lstDealProductForAccounts = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, lstOpportunity , 1, false);
            for(OpportunityLineItem objDP :lstDealProductForAccounts){
                objDP.discount = 0;
              lstDP.add(objDP);
            }
        }
        insert lstDP;
    }
    
    User u = [Select Id from User where Id =: userInfo.getUserId()];
    System.runAs(u) {
    Test.setCurrentPageReference(new PageReference('Page.CRM_RefreshDealProductsPrice'));
    Opportunity deal =[Select ID, Pricebook2Id, Start_Date__c, CloseDate, CurrencyIsoCode FROM Opportunity][0];
    System.debug('deal::'+deal);
    ApexPages.StandardController sc = new ApexPages.StandardController(deal);
    CRM_RefreshDealProductPriceCtrl refctrl = new CRM_RefreshDealProductPriceCtrl(sc);

    
    System.debug('Deal Product::::'+lstDP);
    
    Test.startTest();
    if(DealId != null)
        CRM_RefreshDealProductPriceCtrl.refreshProductPrices(DealId);
    Test.stopTest();

    lstDP = [SELECT TotalPrice,Quantity,promoted_Price__c,UnitPrice,Account_Price__c,Minimum_Price__c,Customer_Retail_Price__c,ListPrice__c,Product2ID,Opportunity.Pricebook2Id FROM OpportunityLineItem WHERE id=: lstDP[0].id LIMIT 1]; 
    //lstPriceBookEntryPeriod = [SELECT List_Price__c FROM Pricebook_Entry_Period__c WHERE Product__c =:lstDP[0].Product2Id AND Price_Book__c =:lstDP[0].Opportunity.Pricebook2Id];
 
    system.debug('lstDP-----'+lstDP);
    system.debug('lstDP[0]-----'+lstDP[0]);
    system.debug('lstDP[0].UnitPrice-----'+lstDP[0].UnitPrice);
    //system.debug('lstPriceBookEntryPeriod[0]-----'+lstPriceBookEntryPeriod);
    
    System.assertEquals(100,lstDP[0].ListPrice__c); 
    System.assertEquals(100,lstDP[0].Customer_Retail_Price__c);
    System.assertEquals(100,lstDP[0].Minimum_Price__c);
    System.assertEquals(100,lstDP[0].Account_Price__c);
    //System.assertEquals(100,lstDP[0].UnitPrice);
    System.assertEquals(100,lstDP[0].promoted_Price__c);
    } 
  }
  
   // US#1004 starts
    static List<Id> accIds = new  List<Id>();
    static List<Account> acccIds = new  List<Account>();
    static List<Opportunity> listOpportunity;
    static List<Country__c> countries;
    static List<Pricing__c> prices;
    static List<Rate_Card__c> rateCardPrices;
    static List<Pricebook_Entry_Period__c> pbeD;
    static List<Account> lstAccounts, lstAccounts1, lstAccounts2;
    static List<Product_Group__c> lstProductGroups, lstProductGroups1, lstProductGroups2;
    static List<Product2> lstProducts, lstProducts1, lstProducts2;
    static List<PricebookEntry> lstPriceBookEntry, lstPriceBookEntry1, lstPriceBookEntry2,lstPriceBookEntry3;
    static List<Opportunity> lstOpportunity, lstOpportunity1, lstOpportunity2;
    static List<OpportunityLineItem> lstDealProduct, lstDealProduct1, lstDealProduct2;
    static Map<Id,OpportunityLineItem> mapDealProducts;
    static List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
    static List<Local_Title__c> lstLocaTitle = new List<Local_Title__c>();
     static List<Account> mainAccountForStoreFront = new List<Account>();
   public static User createUser() {
		List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = String.valueOf(date.today()) + 'abcCDPHT@test.com', 
            Email = 'abc@test.com',
            Alias = String.valueOf(date.today()).substring(0,8),
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles',
            IsActive = true,
            ProfileId = profiles[0].Id,
            ByPassValidationRule__c = true
        );
        insert testUser;
        return testUser;
	}
	
    //US#1004 start
    public static void createData3(){ 
        //create Storefront Account 
       
        mainAccountForStoreFront=CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, mainAccountForStoreFront.size());
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert mainAccountForStoreFront;
        
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'UK'}, 1, false);
        lstCountry[0].Country_Code2__c = 'GB';
        lstCountry[0].Country_Code__c='GBP';
        insert lstCountry;
        System.assertEquals('GB', lstCountry[0].Country_Code2__c);
        
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        lstTitles[0].Content_Type__c = 'Season';
        lstTitles[0].Video_Version__c ='6000047545';
        lstTitles[0].Digital_Planning__c='YES';
        lstTitles[0].Formats__c='HD';
        lstTitles[0].Clear_to_Avail__c = true;
        insert lstTitles;
         
        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);

        lstLocaTitle =CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        lstLocaTitle[0].Title__c = lstTitles[0].Id; 
        lstLocaTitle[0].Initial_Physical_Release_Date__c = Date.today() +460; 
        insert lstLocaTitle;
       
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=lstTitles[0].Id,Country_Lookup__c=lstCountry[0].Id,
                                                                       Languages__c=lstlanguage[0].Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                       Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(), End_Date__c= date.today().addDays(200), Rights_End__c=date.today().addDays(211)
                                                                      );
        insert releaseplan1;
        
        string CommIds = releaseplan1.Id;
        
         List<Agreement__c> storefronts = new List<Agreement__c>();
            Agreement__c storefrontGoogle1 = new Agreement__c(
                Account__c=mainAccountForStoreFront[0].Id,Country__c=lstCountry[0].Id,Pricing_Currency__c='GBP',
                Content_Type__c=lstTitles[0].Content_Type__c,CRM_Account__c=mainAccountForStoreFront[0].Id,WSP_Currency__c='GBP',
                Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421'
            );
        storefronts.add(storefrontGoogle1);
        insert storefronts;
         
		
		 List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c = mainAccountForStoreFront[0].Id,Status__c='Draft',
            Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.Start_Date__c.addDays(150), 
            RP_Synch__c = true, Announce_Override__c = 'Force' 
        );
        clientAvailList.add(clientAvail1);
        insert clientAvailList;
        	 // Create Account records
       // lstAccounts1 = CRM_TestDataFactory.createAccounts(1, false);
        mainAccountForStoreFront[0].scheduleRevenueChanged__c = false;
        mainAccountForStoreFront[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        mainAccountForStoreFront[0].Consignment_Customer__c = true;
        mainAccountForStoreFront[0].Consignment_Multiplier_Video__c = 5;
        mainAccountForStoreFront[0].Consignment_Multiplier_Games__c = 10;
        mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        mainAccountForStoreFront[0].Games_Digital__c = true;
        mainAccountForStoreFront[0].Video_Digital__c = true;
        mainAccountForStoreFront[0].Video_Physical__c = false;
        mainAccountForStoreFront[0].Games_Physical__c = false;
        mainAccountForStoreFront[0].Send_Pricing_to_CAS__c = false;
        mainAccountForStoreFront[0].Storefront__c = storefronts[0].id;
        mainAccountForStoreFront[0].CurrencyISOCode ='GBP';
        User useradmin =createUser();
        System.runAs(useradmin){
            update mainAccountForStoreFront;
        }
        accIds.add(mainAccountForStoreFront[0].id); 
       
    	WB_CreateProduct_PBEP_Test.createTestData();
        // Create Products records
        lstProductGroups1 = CRM_TestDataFactory.createProductGroups(1, true);
        lstProducts1 = CRM_TestDataFactory.createProducts(lstProductGroups1, 1, false);
        lstProducts1[0].ProductCode = '1000230554';
        lstProducts1[0].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        lstProducts1[0].Product_Format__c = '4';
        lstProducts1[0].Local_title__c = lstLocaTitle[0].id;
        lstProducts1[0].Product_Market__c ='EST';
        lstProducts1[0].Product_Rating__c = 'UK - Minimum 12 Ye';
        lstProducts1[0].Product_Genre__c = 'ACTION';
        lstProducts1[0].Release_Category__c = '23';
        lstProducts1[0].Franchise_Type__c = 'X4';
        lstProducts1[0].Product_Language_Code__c = 'EN';
        lstProducts1[0].SAP_Dist_chain_product_Status__c = '11';
        lstProducts1[0].Type__c = CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE;
        lstProducts1[0].Recommended_Price__c = 150;
        lstProducts1[0].SAP_Material_Type__c = CRM_AppConstants.PRODUCT_MATERIAL_TYPE_FERT;
        lstProducts1[0].Product_Label__c = 'SND';
        lstProducts1[0].Street_Date__c = System.today()+3;     
        lstProducts1[0].CurrencyISOCode ='GBP';
        insert lstProducts1;
        System.assertEquals(2, [Select Count() From Product2]);
        
        list<Product2> products = [select Id,name,Country_Code__c from product2 where Id IN : lstProducts1];
        System.assertEquals('GB', products[0].Country_Code__c);
        // Get standard Pricebook and Create Pricebook entry.
        lstPriceBookEntry3 = CRM_TestDataFactory.createPriceBookEntries(lstProducts1,1, false);  
        for(PriceBookEntry pbe : lstPriceBookEntry3){
            pbe.CurrencyISOCode = 'GBP';
        }
        insert lstPriceBookEntry3;
        System.assertEquals(1, [Select Count() From PriceBookEntry]); 

        prices = CRM_TestDataFactory.createPricings(1, false);
        prices[0].Country__c = lstCountry[0].id;
        prices[0].Account__c = mainAccountForStoreFront[0].id;
        prices[0].Price_Code_Status__c = 'Active';
        prices[0].Price_Tier__c = 'Tier 1';
        prices[0].List_Price__c = 11.22;
        prices[0].Channel__c = 'EST';
        prices[0].Format__c = 'HD';
        prices[0].Account_Price__c = 11;
        prices[0].Content_Type__c = 'Season'; 
        insert prices;
        
        rateCardPrices = new List<RAte_card__c>();
        rateCardPrices.add(new RAte_card__c());
        rateCardPrices.add(new RAte_card__c());
        rateCardPrices[0].Country__c = lstCountry[0].id;
        rateCardPrices[0].Account__c =  mainAccountForStoreFront[0].id;
        rateCardPrices[0].Price_Tier__c = 'Tier 1';
        rateCardPrices[0].Channel__c = 'EST';
        rateCardPrices[0].Format__c = 'HD';
        rateCardPrices[0].WSP1__c = 12;
        rateCardPrices[0].WSP2__c = 13;
        rateCardPrices[0].WSP3__c = 14;
        rateCardPrices[0].Start_Date__c = System.today();
        rateCardPrices[0].End_Date__c = System.today()+900 ;
        rateCardPrices[0].Content_Type__c = 'Season';
        rateCardPrices[1].Country__c = lstCountry[0].id;
        rateCardPrices[1].Account__c =  mainAccountForStoreFront[0].id;
        rateCardPrices[1].Price_Tier__c = 'Tier 2';
        rateCardPrices[1].Channel__c = 'EST';
        rateCardPrices[1].Format__c = 'HD';
        rateCardPrices[1].WSP1__c = 18;
        rateCardPrices[1].WSP2__c = 19;
        rateCardPrices[1].WSP3__c = 20;
        rateCardPrices[1].Start_Date__c = System.today();
        rateCardPrices[1].End_Date__c = System.today()+900 ;
        rateCardPrices[1].Content_Type__c = 'Season';
        rateCardPrices[0].Rate_Card_Type__c ='Step DVD 6/18';
        rateCardPrices[1].Rate_Card_Type__c ='Step DVD 6/18';
        insert rateCardPrices;
        
        lstProducts1[0].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
        lstProducts1[0].Type__c = CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
        lstProducts1[0].Product_Market__c = 'EST';
        lstProducts1[0].Product_Format__c = 'HD';
        lstProducts1[0].IsActive = true;
        update lstProducts1;
        
        pbeD=CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts1, 1, false);
        system.assertEquals(1,pbeD.size());
        pbeD[0].Pricing__c = prices[0].id;
        pbeD[0].Product__c = lstProducts1[0].id;
        pbeD[0].CurrencyISOCode ='GBP';
        pbeD[0].Start_Date__c = Date.today() + 1;
        pbeD[0].End_Date__c = Date.today() + 30;
        pbeD[0].Client_Avail__c = clientAvailList[0].id;
        insert pbeD; 
        
        // Create Opportunity records
        lstOpportunity1 = CRM_TestDataFactory.createOpportunitiesWithAccounts(mainAccountForStoreFront, 1,false);
          lstOpportunity1[0].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
          lstOpportunity1[0].CloseDate = System.today() + 360;
          insert lstOpportunity1;
        System.assertEquals(1, [Select Count() From Opportunity]);
    }
     @isTest
    public static void updatePriceTierOnRefreshButtonDealProduct_Update_Test1004(){
        createData3();
        User u = [Select Id from User where Id =: userInfo.getUserId()];
       
        CRM_Restrict_Refresh_Deal_Product_Prices__c refeshcsutomSetting = new CRM_Restrict_Refresh_Deal_Product_Prices__c(Name='Restrict Refresh prices on DP',Sales_Organisation__c='2500;2403',Digital_Country_Code__c='435; 443');
        insert refeshcsutomSetting;
        test.starttest();
         System.runAs(u) {
            lstDealProduct1 = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry3, lstOpportunity1, 1, false);
            lstDealProduct1[0].OpportunityId = lstOpportunity1[0].id;
            lstDealProduct1[0].Pricebook_Entry_Period__c  = pbeD[0].id;
            lstDealProduct1[0].Price_Tier__c  = 'Tier 1';
            insert lstDealProduct1; 
            List<OpportunityLineItem> oppLineItem = [Select Id,Opportunity.StageName,NR_Deal_Product_Unique_Key__c,Promoted_Price__c,Pricebook_Entry_Period__c,Account_Price__c,ListPrice__c,pricing__c,Rate_card__c,price_tier__c
            From OpportunityLineItem ];
            system.assertEquals(oppLineItem[0].Price_Tier__c,'Tier 1'); 
            system.assertEquals(oppLineItem[0].Promoted_Price__c,13); 
            
            List<Rate_Card__c> lstRateCards =[select id,wsp1__c,wsp2__c,wsp3__c,price_tier__c,Step_Pricing__c,Rate_Card_Type__c from Rate_Card__c];
           
            mainAccountForStoreFront[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
            update mainAccountForStoreFront;
	        
	        lstLocaTitle[0].Initial_Physical_Release_Date__c = Date.today() +160; 
            update lstLocaTitle; 
            // Create Deal Product records 
            pbeD =[select id,pricing__c,price_tier__c from Pricebook_Entry_Period__c where id in: pbeD];
            
            List<Rate_Card__c> lstRateCards1 =[select id,wsp1__c,wsp2__c,wsp3__c,price_tier__c,Step_Pricing__c,Rate_Card_Type__c from Rate_Card__c];
            List<Id> DealId = new List<Id>();
            List<Opportunity> deals = [Select ID,Pricebook2Id,stagename FROM Opportunity where id In: lstOpportunity1];
            Opportunity deal =deals[0];
            DealId.add(deals[0].id); 
            CRM_RefreshDealProductPriceCtrl.refreshProductPrices(DealId); 
         } 
        List<OpportunityLineItem> oppLineItem1 = [Select price_tier__c,Pricing__c,Rate_card__c,Promoted_Price__c From OpportunityLineItem where id in :lstDealProduct1 limit 1];
        system.assertEquals(oppLineItem1[0].Promoted_Price__c,null); 
        test.stoptest(); 
    }
    //US#1004 end
        
  // when deal product doesnot exist
  static testMethod void negativeCase(){
      User u = [Select Id from User where Id =: userInfo.getUserId()];
      List<Id> DealId = new List<Id>();
      
        List<Account> lstAcc = new List<Account>();
        List<PricebookEntry> lstPriceBookEntry = new List<PricebookEntry>();
        List<Product2> lstProduct = new List<Product2>();
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        List<OpportunityLineItem> lstDP = new List<OpportunityLineItem>();
        List<OpportunityLineItem> lstModifiedDP = new List<OpportunityLineItem>();
        
        lstAcc = CRM_TestDataFactory.createAccounts(1,true);
        System.assertEquals(1,lstAcc.size(),'Created 1 Enteries');
        
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 1, true); 
        
        lstPriceBookEntry = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        
        CRM_Restrict_Refresh_Deal_Product_Prices__c refeshcsutomSetting = new CRM_Restrict_Refresh_Deal_Product_Prices__c(Name='Restrict Refresh prices on DP',Sales_Organisation__c='2500;2403',Digital_Country_Code__c='435; 443');
        insert refeshcsutomSetting;
        
        if(!lstAcc.isEmpty()){
            Id standardPricebookId = System.Test.getStandardPricebookId();
            lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAcc,1,True);
            // for(Opportunity opp: lstOpportunity)
            System.assertEquals(1, lstOpportunity.size(), 'Created 100 Opportunities where AccountID is the Parent Account');
            
            for(Opportunity opp: lstOpportunity)
            DealId.add(opp.id);
        }
      System.runAs(u) {
      Test.setCurrentPageReference(new PageReference('Page.CRM_RefreshDealProductsPrice'));
        Opportunity deal = [Select ID,Pricebook2Id FROM Opportunity][0];
        ApexPages.StandardController sc = new ApexPages.StandardController(deal);
        CRM_RefreshDealProductPriceCtrl ctrl = new CRM_RefreshDealProductPriceCtrl(sc);
        
        try{
          CRM_RefreshDealProductPriceCtrl.refreshProductPrices(DealId);
          
        }catch(exception e){
         System.assertEquals(Label.CRM_RefreshProductPrice_NoDealProductsError,e.getMessage());
        
        }
      }
   }
   //US#895 -  when Deal is of Japan rental type throw validation
   static testmethod void throwExceptionForJapanRental(){  
    
    List<Account> lstAcc = new List<Account>();
    List<PricebookEntry> lstPriceBookEntry = new List<PricebookEntry>();
    List<Product2> lstProduct = new List<Product2>();
    List<Opportunity> lstOpportunity = new List<Opportunity>();
    List<OpportunityLineItem> lstDP = new List<OpportunityLineItem>();
    List<OpportunityLineItem> lstModifiedDP = new List<OpportunityLineItem>();
    
    //create Account 
    lstAcc = CRM_TestDataFactory.createAccounts(1,false);
    lstAcc[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
    lstAcc[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
    lstAcc[0].CurrencyISOCode = 'JPY';
    lstAcc[0].Games_Physical__c = true;
    insert lstAcc;
    
    System.assertEquals(1,lstAcc.size(),'Created 1 Enteries');
    
    List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
    lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 1, false);
    lstProduct[0].CurrencyIsoCode = 'JPY';
    lstProduct[0].Product_Market__c = '1';
    insert lstProduct;
    
   //Create PricebookEntrys
     lstPriceBookEntry = CRM_TestDataFactory.createPriceBookEntries(lstProduct,1,false);
     lstPriceBookEntry[0].Product2Id = lstProduct[0].Id;
     lstPriceBookEntry[0].CurrencyIsoCode = 'JPY';
     insert lstPriceBookEntry;
     
     // Setting up 1 Price Book Entry Period for USD Pricebook
    List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
    CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{lstProduct[0]}, 1, false);
    lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = lstProduct[0].id;
    lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 140;
    lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 150;
    lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'JPY';
    //lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 10;
    lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 100;
    lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Retail_Price__c = 100;
    lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Minimum_Price__c = 100;
    //lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Suggested_Price__c = null;
    lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Account_Price__c = 100;
    insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;
    
    List<Id> DealId = new List<Id>();
    if(!lstAcc.isEmpty()){
        Id standardPricebookId = System.Test.getStandardPricebookId();
        lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAcc,1,false);
         for (Integer i=0; i < lstOpportunity.size(); i++) {
             lstOpportunity[i].Market_Type__c = '1';
             lstOpportunity[i].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
             lstOpportunity[i].Start_Date__c = System.today() + 141;
	         lstOpportunity[i].Promo_Start_Date__c = System.today() + 141;
		     lstOpportunity[i].CloseDate = System.today() + 149;
		     lstOpportunity[i].CurrencyIsoCode = 'JPY';
         }
         insert lstOpportunity;
         
        // for(Opportunity opp: lstOpportunity)
        System.assertEquals(1, lstOpportunity.size(), 'Created 100 Opportunities where AccountID is the Parent Account');
        
        for(Opportunity opp: lstOpportunity)
        DealId.add(opp.id);
    }
    
    User u = [Select Id from User where Id =: userInfo.getUserId()];
    System.runAs(u) {
    Test.setCurrentPageReference(new PageReference('Page.CRM_RefreshDealProductsPrice'));
    Opportunity deal =[Select ID, Pricebook2Id, Start_Date__c, CloseDate, CurrencyIsoCode FROM Opportunity][0];
    System.debug('deal::'+deal);
    ApexPages.StandardController sc = new ApexPages.StandardController(deal);
    CRM_RefreshDealProductPriceCtrl refctrl = new CRM_RefreshDealProductPriceCtrl(sc);

    if(lstPriceBookEntry.size()>0 && lstOpportunity.size()>0){
        List<OpportunityLineItem> lstDealProductForAccounts = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, lstOpportunity , 1, false);
        for(OpportunityLineItem objDP :lstDealProductForAccounts){
            objDP.discount = 0;
            lstDP.add(objDP);
        }
          
         // system.asertEquals(![SELECT ID FROM );
    }
    System.debug('Deal Product::::'+lstDP);
    insert lstDP;
  
    Test.startTest();
        try{
          CRM_RefreshDealProductPriceCtrl.refreshProductPrices(DealId);
          
        }catch(exception e){
         System.assertEquals(Label.CRM_RefreshProductPrice_MarketTypeError,e.getMessage());
        
        }
    Test.stopTest();

    } 
  }
  
}