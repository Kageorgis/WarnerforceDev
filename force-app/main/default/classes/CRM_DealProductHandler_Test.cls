/**
@Author-Cognizant Technology Solutions
@name-CRM_DealProductHandler_Test
@CreateDate
@Description-The class is used to check scenarios that occur while calculating the Account Price on Deal Product
@Version-<1.0>
@reference-None
*/
@isTest
private class CRM_DealProductHandler_Test{
    static List<Account> lstAccounts, lstAccounts1, lstAccounts2;
    static List<Product_Group__c> lstProductGroups, lstProductGroups1, lstProductGroups2;
    static List<Product2> lstProducts, lstProducts1, lstProducts2;
    static List<PricebookEntry> lstPriceBookEntry, lstPriceBookEntry1, lstPriceBookEntry2,lstPriceBookEntry3;
    static List<Opportunity> lstOpportunity, lstOpportunity1, lstOpportunity2;
    static List<OpportunityLineItem> lstDealProduct, lstDealProduct1, lstDealProduct2;
    static Map<Id,OpportunityLineItem> mapDealProducts;
   
    //US#172
    static List<Id> accIds = new  List<Id>();
    static List<Account> acccIds = new  List<Account>();
    static List<Opportunity> listOpportunity;
    static List<Country__c> countries;
    static List<Pricing__c> prices;
    static List<Rate_Card__c> rateCardPrices;
    static List<Pricebook_Entry_Period__c> pbeD;
    
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
    
    public static void createData() {   
        // Create Account records
        lstAccounts = CRM_TestDataFactory.createAccounts(1, false);
        lstAccounts[0].scheduleRevenueChanged__c = false;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        lstAccounts[0].Consignment_Customer__c = true;
        lstAccounts[0].Consignment_Multiplier_Video__c = 5;
        lstAccounts[0].Consignment_Multiplier_Games__c = 10;
        insert  lstAccounts;
        
        // Create Products records
        lstProductGroups = CRM_TestDataFactory.createProductGroups(1, true);
        lstProducts = CRM_TestDataFactory.createProducts(lstProductGroups, 1, false);
        lstProducts[0].ProductCode = '1000230554';
        lstProducts[0].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        lstProducts[0].Product_Format__c = '4';
        lstProducts[0].Product_Rating__c = 'UK - Minimum 12 Ye';
        lstProducts[0].Product_Genre__c = 'ACTION';
        lstProducts[0].Release_Category__c = '23';
        lstProducts[0].Franchise_Type__c = 'X4';
        lstProducts[0].Product_Language_Code__c = 'EN';
        lstProducts[0].SAP_Dist_chain_product_Status__c = '11';
        lstProducts[0].Type__c = CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE;
        lstProducts[0].Recommended_Price__c = 150;
        lstProducts[0].SAP_Material_Type__c = CRM_AppConstants.PRODUCT_MATERIAL_TYPE_FERT;
        lstProducts[0].Product_Label__c = 'SND';
        insert lstProducts;
                
        // Get standard Pricebook and Create Pricebook entry.
        lstPriceBookEntry = CRM_TestDataFactory.createPriceBookEntries(lstProducts,1, true);      
        
        // Create Opportunity records
        lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1,true);
        
        pbeD = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts, 1, false);
        system.assertEquals(1,pbeD.size());
        //pbeD[0].Pricing__c = prices[0].id;
        pbeD[0].Product__c = lstProducts[0].id;
        //pbeD[0].CurrencyISOCode ='EUR';
        pbeD[0].Start_Date__c = Date.today() + 1;
        pbeD[0].End_Date__c = Date.today() + 30;
        insert pbeD;
        
        // Create Deal Product records
        lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry, lstOpportunity, 1, true);
        
        mapDealProducts = new Map<Id,OpportunityLineItem>(lstDealProduct);
    }
    
    public static void createData1() {   
        // Create Account records
        lstAccounts1 = CRM_TestDataFactory.createAccounts(1, false);
        lstAccounts1[0].scheduleRevenueChanged__c = false;
        lstAccounts1[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccounts1[0].Consignment_Customer__c = true;
        lstAccounts1[0].Consignment_Multiplier_Video__c = 5;
        lstAccounts1[0].Consignment_Multiplier_Games__c = 10;
        insert  lstAccounts1;
        System.assertEquals(1, [Select Count() From Account]);
        
        // Create Products records
        lstProductGroups1 = CRM_TestDataFactory.createProductGroups(1, true);
        lstProducts1 = CRM_TestDataFactory.createProducts(lstProductGroups1, 1, false);
        lstProducts1[0].ProductCode = '1000230554';
        lstProducts1[0].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        lstProducts1[0].Product_Format__c = '4';
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
        insert lstProducts1;
        System.assertEquals(1, [Select Count() From Product2]);
        
        // Get standard Pricebook and Create Pricebook entry.
        lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProducts1,1, true);      
        System.assertEquals(1, [Select Count() From PriceBookEntry]);
        
        // Create Opportunity records
        lstOpportunity1 = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts1, 1,true);
        System.assertEquals(1, [Select Count() From Opportunity]);
        
        pbeD = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts1, 1, false);
        system.assertEquals(1,pbeD.size());
        //pbeD[0].Pricing__c = prices[0].id;
        pbeD[0].Product__c = lstProducts1[0].id;
        //pbeD[0].CurrencyISOCode ='GBP';
        pbeD[0].Start_Date__c = Date.today() + 1;
        pbeD[0].End_Date__c = Date.today() + 30;
        insert pbeD;
        
        // Create Deal Product records
        lstDealProduct1 = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry1, lstOpportunity1, 1, true);
        System.assertEquals(1, [Select Count() From OpportunityLineItem]);
    }
    
    public static void createData2() {   
      // Create Account records
        lstAccounts2 = CRM_TestDataFactory.createAccounts(1, false);
        lstAccounts2[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccounts2[0].Consignment_Customer__c = true;
        lstAccounts2[0].Consignment_Multiplier_Video__c = 5;
        lstAccounts2[0].Consignment_Multiplier_Games__c = 10;
        insert  lstAccounts2;
        System.assertEquals(1, [Select Count() From Account]);
        
        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'XYZ'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;
        
        // Create Products records
        lstProductGroups2 = CRM_TestDataFactory.createProductGroups(1, true);
        lstProducts2 = CRM_TestDataFactory.createProducts(lstProductGroups2, 1, false);
        lstProducts2[0].ProductCode = '1000230554';
        lstProducts2[0].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        lstProducts2[0].Product_Format__c = '4';
        lstProducts2[0].Product_Rating__c = 'UK - Minimum 12 Ye';
        lstProducts2[0].Product_Genre__c = 'ACTION';
        lstProducts2[0].Release_Category__c = '23';
        lstProducts2[0].Franchise_Type__c = 'X4';
        lstProducts2[0].Product_Language_Code__c = 'EN';
        lstProducts2[0].SAP_Dist_chain_product_Status__c = '11';
        lstProducts2[0].Type__c = CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE;
        lstProducts2[0].Recommended_Price__c = 150;
        lstProducts2[0].Local_Title__c = lstLocaTitle[0].Id;
        //lstProducts2[0].c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        lstProducts2[0].SAP_Material_Type__c = CRM_AppConstants.PRODUCT_MATERIAL_TYPE_FERT;
        lstProducts2[0].Product_Label__c = 'SND';
        insert lstProducts2;
    System.assertEquals(1, [Select Count() From Product2]);
        
        // Get standard Pricebook and Create Pricebook entry.
        lstPriceBookEntry2 = CRM_TestDataFactory.createPriceBookEntries(lstProducts2,1, true);      
        System.assertEquals(1, [Select Count() From PriceBookEntry]);
        
        pbeD = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts2, 1, false);
        system.assertEquals(1,pbeD.size());
        //pbeD[0].Pricing__c = prices[0].id;
        pbeD[0].Product__c = lstProducts2[0].id;
        //pbeD[0].CurrencyISOCode ='GBP';
        pbeD[0].Start_Date__c = Date.today() + 1;
        pbeD[0].End_Date__c = Date.today() + 30;
        insert pbeD;
        
        // Create Opportunity records
        lstOpportunity2 = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts2, 1,true);
        System.assertEquals(1, [Select Count() From Opportunity]);
        
        // Create Deal Product records
        lstDealProduct2 = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry2, lstOpportunity2, 1, true);
        System.assertEquals(1, [Select Count() From OpportunityLineItem]);
    }
    
   public static void createData3(){ //US#172
        
        //create Storefront Account 
        List<Account> mainAccountForStoreFront = CRM_TestDataFactory.createAccounts(1, false);
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

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        lstLocaTitle[0].Initial_Physical_Release_Date__c = Date.today() +60;
        insert lstLocaTitle;
       
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=lstTitles[0].Id,Country_Lookup__c=lstCountry[0].Id,
                                                                       Languages__c=lstlanguage[0].Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                       Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(), End_Date__c= date.today().addDays(10), Rights_End__c=date.today().addDays(11)
                                                                      );
        insert releaseplan1;
        
        string CommIds = releaseplan1.Id;
        
        //list<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(mainAccountForStoreFront, 'GBP', lstCountry[0].id,true);
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
            Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.Start_Date__c.addDays(2), 
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
       // clientAvailList =  [SELECT ID,Local_DVD_Release_Date__c FROM Client_Avail__c];
       // system.assertEquals(clientAvailList[0].Local_DVD_Release_Date__c, Date.today()+60);
    
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
       	
        WB_CreateProduct_PBEP_Test.createTestData();
       
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
        rateCardPrices[0].WSP1__c = 11;
        rateCardPrices[0].WSP2__c = 11;
        rateCardPrices[0].WSP3__c = 11;
        rateCardPrices[0].Start_Date__c = System.today();
        rateCardPrices[0].End_Date__c = System.today()+900 ;
        rateCardPrices[0].Content_Type__c = 'Season';
        rateCardPrices[1].Country__c = lstCountry[0].id;
        rateCardPrices[1].Account__c =  mainAccountForStoreFront[0].id;
        rateCardPrices[1].Price_Tier__c = 'Tier 2';
        rateCardPrices[1].Channel__c = 'EST';
        rateCardPrices[1].Format__c = 'HD';
        rateCardPrices[1].WSP1__c = 18;
        rateCardPrices[1].WSP2__c = 18;
        rateCardPrices[1].WSP3__c = 18;
        rateCardPrices[1].Start_Date__c = System.today();
        rateCardPrices[1].End_Date__c = System.today()+900 ;
        rateCardPrices[1].Content_Type__c = 'Season';
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
    
    static testmethod void testMeth1() {
        createData();
        
        System.assertEquals(1, mapDealProducts.values().size());
        delete mapDealProducts.values();
        System.assertEquals(0, [Select Id from OpportunityLineItem].size());
    }
    
    static testmethod void testRoyaltyFee() {
        
        Royalty_Fees__c settingsInsatnce = new Royalty_Fees__c();
        settingsInsatnce.Name = 'SND';
        settingsInsatnce.Fee__c = 100;
        settingsInsatnce.Gross_Revenue__c = true;
        settingsInsatnce.Label__c = 'SND';
        settingsInsatnce.Sales_Organisation__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        
        insert settingsInsatnce;
        
        test.starttest();
        createData();
        test.stoptest();
        
        List<OpportunityLineItem> oppLineItem = [Select Id,Royalty_Fee__c,Royalty_Fee_Applied_to_Gross_Revenue__c from OpportunityLineItem];
        System.assertEquals(100, oppLineItem[0].Royalty_Fee__c);
        System.assertEquals(true, oppLineItem[0].Royalty_Fee_Applied_to_Gross_Revenue__c);
    }
    
    @isTest
    public static void updateConsignmentMultiplierTest1(){
        createData1();
        List<OpportunityLineItem> oppLineItem = [Select Id,Consignment_Multiplier__c From OpportunityLineItem Where Id = :lstDealProduct1[0].Id];
        System.assertEquals(5, oppLineItem[0].Consignment_Multiplier__c);
    }
    
    @isTest
    public static void updateConsignmentMultiplierTest2(){
        createData2();
        List<OpportunityLineItem> oppLineItem2 = [Select Id,Consignment_Multiplier__c From OpportunityLineItem Where Id = :lstDealProduct2[0].Id];
        System.assertEquals(10, oppLineItem2[0].Consignment_Multiplier__c);
    }
    @isTest
    //US#594 
    public static void testEstimatedProductionCost() {   
        // Create Account records
        lstAccounts2 = CRM_TestDataFactory.createAccounts(1, false);
        lstAccounts2[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccounts2[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts2[0].CurrencyIsoCode ='GBP';
        insert  lstAccounts2;
        System.assertEquals(1, [Select Count() From Account]);
        
        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'GBP'}, 1, true);
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        System.assertEquals(1, lstTitles.size());
        lstTitles[0].Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert lstTitles;

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        System.assertEquals(1, lstTitles.size());
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        insert lstLocaTitle;
        
        List<CRM_Production_Cost_Estimated__c> lstCustomSett = new List<CRM_Production_Cost_Estimated__c>();
     lstCustomSett.add(new CRM_Production_Cost_Estimated__c (Name='aa',Calculation_Order__c = 10,Case_Type__c='361',Country__c = '6000',Currency__c='GBP'
        ,Estimated_Production_Cost__c =100,Format__c='4',Pack_Type__c='6')); 
     lstCustomSett.add(new CRM_Production_Cost_Estimated__c (Name ='bb',Calculation_Order__c = 20 ,Case_Type__c='361',Country__c='6000',Currency__c='GBP'
        ,Estimated_Production_Cost__c=200,Format__c='93',Pack_Type__c='6'));
        insert lstCustomSett;
        System.assertEquals(2, [SELECT Id FROM CRM_Production_Cost_Estimated__c].size());
        // Create Products records
        lstProductGroups2 = CRM_TestDataFactory.createProductGroups(1, true);
        lstProducts2 = CRM_TestDataFactory.createProducts(lstProductGroups2, 1, false);
        lstProducts2[0].ProductCode = '1000230554';
        lstProducts2[0].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        lstProducts2[0].Product_Format__c = '93';
        lstProducts2[0].Product_Rating__c = 'UK - Minimum 12 Ye';
        lstProducts2[0].Product_Genre__c = 'ACTION';
        lstProducts2[0].Release_Category__c = '23';
        lstProducts2[0].Case_Type__c = '361';
        lstProducts2[0].Pack_Type__c = '6'; 
        lstProducts2[0].Franchise_Type__c = 'X4';
        lstProducts2[0].Product_Language_Code__c = 'EN';
        lstProducts2[0].SAP_Dist_chain_product_Status__c = '11';
        lstProducts2[0].Type__c = CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE;
        lstProducts2[0].Recommended_Price__c = 150;
        lstProducts2[0].Local_Title__c = lstLocaTitle[0].Id;
        lstProducts2[0].CurrencyIsoCode = 'GBP';
        lstProducts2[0].SAP_Material_Type__c = CRM_AppConstants.PRODUCT_MATERIAL_TYPE_FERT;
        lstProducts2[0].Product_Label__c = 'SND';
        insert lstProducts2;
        System.assertEquals(1, [Select Count() From Product2]);
        
        // Get standard Pricebook and Create Pricebook entry.
        lstPriceBookEntry2 = CRM_TestDataFactory.createPriceBookEntries(lstProducts2,1, false);
        lstPriceBookEntry2[0].CurrencyIsoCode='GBP';
        insert lstPriceBookEntry2;
        System.assertEquals(1, [Select Count() From PriceBookEntry]);
        
        // Create Opportunity records
        lstOpportunity2 = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts2, 1,true);
        System.assertEquals(1, [Select Count() From Opportunity]);
        
        pbeD=CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts2, 1, false);
        system.assertEquals(1,pbeD.size());
        //pbeD[0].Pricing__c = prices[0].id;
        pbeD[0].Product__c = lstProducts2[0].id;
        pbeD[0].CurrencyISOCode ='GBP';
        pbeD[0].Start_Date__c = Date.today() + 1;
        pbeD[0].End_Date__c = Date.today() + 30;
        insert pbeD; 
        
        // Create Deal Product records
        lstDealProduct2 = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry2, lstOpportunity2, 1, true);
        OpportunityLineItem dp = [Select production_cost__C  From OpportunityLineItem];
        System.assertEquals(200, dp.production_cost__C);
        
} 
    
    @isTest
    //US#172
    public static void updatePriceTierOnDealProduct_Update_Test1(){
        createData3();
       test.starttest(); 
        pbeD =[select id,pricing__c,price_tier__c from Pricebook_Entry_Period__c where id in: pbeD];
        
         // Create Deal Product records
        lstDealProduct1 = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry3, lstOpportunity1, 1, false);
        lstDealProduct1[0].OpportunityId = lstOpportunity1[0].id;
        lstDealProduct1[0].Pricebook_Entry_Period__c  = pbeD[0].id;
        insert lstDealProduct1; 
        
        List<OpportunityLineItem> oppLineItem = [Select Id,Pricebook_Entry_Period__c,Account_Price__c,ListPrice__c,pricing__c,Rate_card__c,price_tier__c From OpportunityLineItem where id in :lstDealProduct1 limit 1];
       
        //system.assertEquals(pbeD[0].Price_Tier__c,oppLineItem[0].Price_Tier__c);
        //system.assertEquals('Tier 1',oppLineItem[0].Price_Tier__c);
       
            oppLineItem[0].Price_Tier__c = 'Tier 1 updated';
            try{
                update oppLineItem;
                system.assertEquals(null,oppLineItem[0].Price_Tier__c);
            }catch(Exception e){
                system.assertEquals(true, e.getMessage().contains('Please enter valid Price Tier'));
            }
            
            List<OpportunityLineItem> oppLineItem1 = [Select price_tier__c From OpportunityLineItem where id in :lstDealProduct1 limit 1];
        test.stoptest();      
    }
    
      @isTest
    //US#172
    public static void updatePriceTierOnDealProduct_Update_Test2(){
        createData3();
          test.starttest();
        pbeD =[select id,pricing__c,price_tier__c from Pricebook_Entry_Period__c where id in: pbeD];
         system.debug('pbeD:::::::::::::::::'+pbeD);
         // Create Deal Product records
        lstDealProduct1 = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry3, lstOpportunity1, 1, false);
        lstDealProduct1[0].OpportunityId = lstOpportunity1[0].id;
        lstDealProduct1[0].Pricebook_Entry_Period__c  = pbeD[0].id;
        insert lstDealProduct1; 
        
        List<OpportunityLineItem> oppLineItem = [Select Id,Pricebook_Entry_Period__c,Account_Price__c,ListPrice__c,pricing__c,Rate_card__c,price_tier__c From OpportunityLineItem where id in :lstDealProduct1];
       system.debug('oppLineItem:::::::::::::::::'+oppLineItem);
       system.assertEquals(oppLineItem[0].Price_Tier__c,null);
      
            oppLineItem[0].Price_Tier__c = null;
            oppLineItem[0].Promoted_Price__c = 11.11;
            update oppLineItem[0];
        test.stoptest(); 
            
        List<OpportunityLineItem> oppLineItem1 = [Select price_tier__c,Pricing__c,Rate_card__c,Promoted_Price__c From OpportunityLineItem where id in :lstDealProduct1 limit 1];
        system.debug('oppLineItem1 -----------------------------------'+oppLineItem1);
        system.assertEquals(oppLineItem1[0].Price_Tier__c,null); 
    }
    
       @isTest
    //US#172
    public static void updatePriceTierOnDealProduct_Update_Test3(){
        createData3();
        test.starttest();
        pbeD =[select id,pricing__c,price_tier__c from Pricebook_Entry_Period__c where id in: pbeD];
         system.debug('pbeD:::::::::::::::::'+pbeD);
         // Create Deal Product records
        lstDealProduct1 = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry3, lstOpportunity1, 1, false);
        lstDealProduct1[0].OpportunityId = lstOpportunity1[0].id;
        lstDealProduct1[0].Pricebook_Entry_Period__c  = pbeD[0].id;
        lstDealProduct1[0].Promoted_Price__c  = 11;
        insert lstDealProduct1; 
        
        List<OpportunityLineItem> oppLineItem = [Select Id,Pricebook_Entry_Period__c,Account_Price__c,ListPrice__c,pricing__c,Rate_card__c,price_tier__c From OpportunityLineItem where id in :lstDealProduct1];
        system.debug('oppLineItem:::::::::::::::::'+oppLineItem);
        system.assertEquals(oppLineItem[0].Price_Tier__c,'Tier 1');
            oppLineItem[0].Promoted_Price__c = 18.00; 
            update oppLineItem[0];
        test.stoptest(); 
            
        List<OpportunityLineItem> oppLineItem1 = [Select price_tier__c,Pricing__c,Rate_card__c,Promoted_Price__c From OpportunityLineItem where id in :lstDealProduct1 limit 1];
        system.debug('oppLineItem1 -----------------------------------'+oppLineItem1);
        system.assertEquals(oppLineItem1[0].Price_Tier__c,'Tier 2');
    }
    
    public static void createData4(){ //US#172
        
        //create Storefront Account 
        lstAccounts1 = CRM_TestDataFactory.createAccounts(1, false);
        System.assertEquals(1, lstAccounts1.size());
        lstAccounts1[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert lstAccounts1;
        
        List<Country__c> lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'UK'}, 1, false);
        lstCountry[0].Country_Code2__c = 'GB';
        lstCountry[0].Country_Code__c='TF';
        insert lstCountry;
        
        List<Title__c> lstTitles = CRM_TestDataFactory.createTitles(1, false);
        lstTitles[0].Content_Type__c = 'Season';
        lstTitles[0].Video_Version__c ='6000047545';
        lstTitles[0].Digital_Planning__c='YES';
        lstTitles[0].Formats__c='SD';
        lstTitles[0].Clear_to_Avail__c = true;
        insert lstTitles;
         
        List<Language__c> lstlanguage = CRM_TestDataFactory.createLanguages(1, true);
        
          // Create Products records
        lstProductGroups1 = CRM_TestDataFactory.createProductGroups(1, true);
        lstProducts1 = CRM_TestDataFactory.createProducts(lstProductGroups1, 1, false);
        lstProducts1[0].ProductCode = '1000230554';
        lstProducts1[0].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        lstProducts1[0].Product_Format__c = '4';
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
        lstProducts1[0].CurrencyISOCode = 'GBP';
        insert lstProducts1;
        System.assertEquals(1, [Select Count() From Product2]);
        
        // Get standard Pricebook and Create Pricebook entry.
        lstPriceBookEntry1 = CRM_TestDataFactory.createPriceBookEntries(lstProducts1,1, false); 
        for(PriceBookEntry pbe : lstPriceBookEntry1){
            pbe.CurrencyISOCode ='GBP';
        }
        insert lstPriceBookEntry1; 
        System.assertEquals(1, [Select Count() From PriceBookEntry]); 

     

        List<Local_Title__c> lstLocaTitle = CRM_TestDataFactory.createLocalTitles(lstCountry, lstlanguage, 1, false);
        lstLocaTitle[0].Title__c = lstTitles[0].Id;
        lstLocaTitle[0].Initial_Physical_Release_Date__c = Date.today() +60;
        insert lstLocaTitle;
        lstProducts1[0].Local_Title__c = lstLocaTitle[0].id;     
        update lstProducts1;        
        
       // List<Commercial_Avail__c> releasePlans = CRM_TestDataFactory.createReleasePlans(2, lstTitles, storefronts, lstLocaTitle, lstCountry, lstlanguage, false);
        Integer i=0;
        Commercial_Avail__c releasePlans = new Commercial_Avail__c(Title__c=lstTitles[0].Id,Country_Lookup__c=lstCountry[0].Id,
                                                                       Languages__c=lstlanguage[0].Id ,Channel__c='DTD',Format__c='HD',
                                                                       Language_Type__c='Dub',Status__c='Tentative',
                                                                       Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(), 
                                                                       End_Date__c= date.today().addDays(10),
                                                                       Rights_End__c=date.today().addDays(11)
                                                                      );
        insert releasePlans;
     
       // list<Agreement__c> storefronts = CRM_TestDataFactory.createStoreFronts(lstAccounts1, 'GBP', lstCountry[0].id,true);
         List<Agreement__c> storefronts = new List<Agreement__c>();
            Agreement__c storefrontGoogle1 = new Agreement__c(
                Account__c=lstAccounts1[0].Id,Country__c=lstCountry[0].Id,Pricing_Currency__c='GBP',
                Content_Type__c=lstTitles[0].Content_Type__c,CRM_Account__c=lstAccounts1[0].Id,WSP_Currency__c='GBP',
                Channel_Picklist__c = releaseplans.Channel__c,Format__c=releaseplans.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421'
            );
        storefronts.add(storefrontGoogle1);
        insert storefronts;
        
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplans.Id, Client__c=lstAccounts1[0].Id,Status__c='Draft',
            Start_Date__c=releaseplans.Start_Date__c,End_Date__c=releaseplans.Start_Date__c.addDays(2), 
            RP_Synch__c = true, Announce_Override__c = 'Force' 
        );
        clientAvailList.add(clientAvail1);
        insert clientAvailList;
        
        clientAvailList =  [SELECT ID,Local_DVD_Release_Date__c FROM Client_Avail__c];
        system.assertEquals(clientAvailList[0].Local_DVD_Release_Date__c, Date.today()+60);

       // Create Account records
       // lstAccounts1 = CRM_TestDataFactory.createAccounts(1, false);
        lstAccounts1[0].scheduleRevenueChanged__c = false;
        lstAccounts1[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccounts1[0].Consignment_Customer__c = true;
        lstAccounts1[0].Consignment_Multiplier_Video__c = 5;
        lstAccounts1[0].Consignment_Multiplier_Games__c = 10;
        lstAccounts1[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts1[0].Games_Digital__c = true;
        lstAccounts1[0].Video_Digital__c = true;
        lstAccounts1[0].Video_Physical__c = false;
        lstAccounts1[0].Games_Physical__c = false;
        lstAccounts1[0].Send_Pricing_to_CAS__c = false;
        lstAccounts1[0].Storefront__c = storefronts[0].id;
        lstAccounts1[0].CurrencyISOCode = 'GBP';
        User useradmin =createUser();
        system.runAs(useradmin) {
        	update  lstAccounts1;
        }
        accIds.add(lstAccounts1[0].id); 
        acccIds.add(lstAccounts1[0]);
        
        lstAccounts1[0].Storefront__c = storefronts[0].id;
        update lstAccounts1;
        
        prices = CRM_TestDataFactory.createPricings(2, false);
        prices[0].Country__c = lstCountry[0].id;
        prices[0].Account__c = lstAccounts1[0].id;
        prices[0].Price_Code_Status__c = 'Active';
        prices[0].Price_Tier__c = 'Tier 1';
        prices[0].List_Price__c = 11.22;
        prices[0].Channel__c = 'EST';
        prices[0].Format__c = 'HD';
        prices[0].Account_Price__c = 10.22;
        prices[0].Content_Type__c = 'Season';
        prices[1].Country__c = lstCountry[0].id;
        prices[1].Account__c = lstAccounts1[0].id;
        prices[1].Price_Code_Status__c = 'Active';
        prices[1].Price_Tier__c = 'Tier 2';
        prices[1].List_Price__c = 11.22;
        prices[1].Channel__c = 'EST';
        prices[1].Format__c = 'HD';
        prices[1].Account_Price__c = 18;
        prices[1].Content_Type__c = 'Season';
        insert prices;
         
        rateCardPrices = new List<RAte_card__c>();
        rateCardPrices.add(new RAte_card__c());
        rateCardPrices.add(new RAte_card__c());
        
        rateCardPrices[0].Country__c = lstCountry[0].id;
        rateCardPrices[0].Account__c = lstAccounts1[0].id;
        rateCardPrices[0].Price_Tier__c = 'Tier 1';
        rateCardPrices[0].Channel__c = 'EST';
        rateCardPrices[0].Format__c = 'HD';
        rateCardPrices[0].WSP1__c = 10.22;
        rateCardPrices[0].WSP2__c = 10.22;
        rateCardPrices[0].WSP3__c = 10.22;
        rateCardPrices[0].Content_Type__c = 'Season';
        rateCardPrices[0].Start_Date__c = System.today();
        rateCardPrices[0].End_Date__c = System.today()+900 ;
        rateCardPrices[1].Country__c = lstCountry[0].id;
        rateCardPrices[1].Account__c = lstAccounts1[0].id;
        rateCardPrices[1].Price_Tier__c = 'Tier 2';
        rateCardPrices[1].Channel__c = 'EST';
        rateCardPrices[1].Format__c = 'HD';
        rateCardPrices[1].WSP1__c = 18;
        rateCardPrices[1].WSP2__c = 18;
        rateCardPrices[1].WSP3__c = 18;
        rateCardPrices[1].Content_Type__c = 'Season';
        rateCardPrices[1].Start_Date__c = System.today();
        rateCardPrices[1].End_Date__c = System.today()+900;
        insert rateCardPrices;
        
        system.assertEquals(lstAccounts1[0].Id,prices[0].Account__c);
        system.assertEquals(lstAccounts1[0].Id,prices[1].Account__c);
        
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
        lstOpportunity1 = new List<Opportunity>();
       lstOpportunity1= CRM_TestDataFactory.createOpportunitiesWithAccounts(acccIds, 1,false);
          lstOpportunity1[0].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
          lstOpportunity1[0].CloseDate = System.today() + 360;
          insert lstOpportunity1;
        System.assertEquals(1, [Select Count() From Opportunity]);
         List<OpportunityLineItem> oppLineItem = [Select Id,opportunity.AccountId,opportunity.Storefront_Account__c,Pricebook_Entry_Period__c,Account_Price__c,ListPrice__c,pricing__c,price_tier__c From OpportunityLineItem ];
        system.debug('oppLineItem****size--3333--'+oppLineItem.size());
       
    }

    //US#663
    public static testmethod void updatePriceTierOnDealProduct_UpdatePromoPrice(){
        createData4();
         test.starttest();  
        pbeD =[select id,pricing__c,price_tier__c,Account_Price__c from Pricebook_Entry_Period__c where id in: pbeD];
        rateCardPrices=[SELECT Id, Name, Account__c, WSP1__c,WSP2__c,WSP3__c, Price_Tier__c, Country__r.Country_Code2__c, 
                                                Content_Type__c, Channel__c, Format__c
                                                FROM rate_card__c];
                                                
         // Create Deal Product records
        lstDealProduct1 = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry1, lstOpportunity1, 1, false);
        lstDealProduct1[0].OpportunityId = lstOpportunity1[0].id;
        lstDealProduct1[0].Pricebook_Entry_Period__c  = pbeD[0].id;
        insert lstDealProduct1; 
        
        List<OpportunityLineItem> oppLineItem = [Select Id,opportunity.AccountId,opportunity.Storefront_Account__c,Promoted_Price__c,Pricebook_Entry_Period__c,Account_Price__c,ListPrice__c,pricing__c,Rate_card__c,price_tier__c From OpportunityLineItem where id in :lstDealProduct1 limit 1];
        
        system.assertEquals(lstAccounts1[0].Id,oppLineItem[0].opportunity.AccountId);
            oppLineItem[0].Promoted_price__c = 18;
            update oppLineItem[0];  
             List<OpportunityLineItem> oppLineItem1 = [Select pricing__c,Rate_card__c,Promoted_Price__c,Permanent_Price_Tier__c,price_tier__c From OpportunityLineItem where id in :lstDealProduct1 limit 1];
          system.assertEquals(18,oppLineItem[0].Promoted_price__c);
          system.assertEquals('Tier 2',oppLineItem1[0].Price_Tier__c); 
            
       test.stoptest();
    }
    
     //US#985
    public static testmethod void updatePriceTierOnDealProduct_UpdatePromoPrice_StepPricing(){
        createData4();
         test.starttest();  
          rateCardPrices[0].Rate_Card_Type__c = 'Step DVD 6/18';
        rateCardPrices[1].Rate_Card_Type__c = 'Step DVD 6/18';
        update rateCardPrices;
        rateCardPrices =[SELECT Id, Name, Account__c, WSP1__c,WSP2__c,WSP3__c, Start_Date__c,End_Date__c, Price_Tier__c, Country__r.Country_Code2__c, RC_Lifecycle__c,
                                                Content_Type__c, Channel__c, Format__c,Step1_Length_Months__c,Step2_Length_Months__c,Step_Pricing__c
                                                FROM Rate_Card__c ];    
        
        system.assertEquals(TRUE,rateCardPrices[0].Step_Pricing__c); 
        system.assertEquals(TRUE,rateCardPrices[1].Step_Pricing__c); 
        pbeD =[select id,pricing__c,price_tier__c,Account_Price__c from Pricebook_Entry_Period__c where id in: pbeD];
        rateCardPrices=[SELECT Id, Name, Account__c, WSP1__c,WSP2__c,WSP3__c, Price_Tier__c, Country__r.Country_Code2__c, 
                                                Content_Type__c, Channel__c, Format__c
                                                FROM rate_card__c];
                                                
         // Create Deal Product records
        lstDealProduct1 = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry1, lstOpportunity1, 1, false);
        lstDealProduct1[0].OpportunityId = lstOpportunity1[0].id;
        lstDealProduct1[0].Pricebook_Entry_Period__c  = pbeD[0].id;
        insert lstDealProduct1; 
        
        List<OpportunityLineItem> oppLineItem = [Select Id,opportunity.AccountId,opportunity.Storefront_Account__c,Promoted_Price__c,Pricebook_Entry_Period__c,Account_Price__c,ListPrice__c,pricing__c,Rate_card__c,price_tier__c From OpportunityLineItem where id in :lstDealProduct1 limit 1];
        
        system.assertEquals(lstAccounts1[0].Id,oppLineItem[0].opportunity.AccountId);
            oppLineItem[0].Promoted_price__c = 18;
            update oppLineItem[0];  
             List<OpportunityLineItem> oppLineItem1 = [Select pricing__c,Rate_card__c,Promoted_Price__c,Permanent_Price_Tier__c,price_tier__c From OpportunityLineItem where id in :lstDealProduct1 limit 1];
          system.assertEquals(18,oppLineItem[0].Promoted_price__c);
          system.assertEquals('Tier 2',oppLineItem1[0].Price_Tier__c); 
       test.stoptest();
    }
     //US#663
    public static testmethod void updatePriceTierOnDealProduct_InsertPromoPrice_EditAll(){
        createData4();
        test.starttest();  
        rateCardPrices[0].Rate_Card_Type__c = 'Step DVD 6/18';
        rateCardPrices[1].Rate_Card_Type__c = 'Step DVD 6/18';
        update rateCardPrices;
        rateCardPrices = [SELECT Id, Name, Account__c, WSP1__c,WSP2__c,WSP3__c, Start_Date__c,End_Date__c, Price_Tier__c, Country__r.Country_Code2__c, RC_Lifecycle__c,
                                                Content_Type__c, Channel__c, Format__c,Step1_Length_Months__c,Step2_Length_Months__c,Step_Pricing__c
                                                FROM Rate_Card__c ];    
        
        system.assertEquals(TRUE,rateCardPrices[0].Step_Pricing__c); 
        system.assertEquals(TRUE,rateCardPrices[1].Step_Pricing__c); 
        lstOpportunity1 =[select id from Opportunity limit 1];
        CRM_EditAllOppProductsCtrl.getLineItems(lstOpportunity1[0].id,new set<Id>());
       test.stoptest();
    }
    

    //US#663
    public static testmethod void updatePriceTierOnDealProduct_InsertPromoPrice(){
        createData4();
        test.starttest();
        pbeD =[select id,pricing__c,price_tier__c,Account_Price__c from Pricebook_Entry_Period__c where id in: pbeD];
        rateCardPrices=[SELECT Id, Name, Account__c, WSP1__c,WSP2__c,WSP3__c, Price_Tier__c, Country__r.Country_Code2__c, 
                                                Content_Type__c, Channel__c, Format__c
                                                FROM Rate_card__c];
        system.debug('rateCardPrices:::::::::::::'+rateCardPrices);                                        
         // Create Deal Product records
        lstDealProduct1 = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry1, lstOpportunity1, 1, false);
        lstDealProduct1[0].OpportunityId = lstOpportunity1[0].id;
        lstDealProduct1[0].Pricebook_Entry_Period__c  = pbeD[0].id;
        lstDealProduct1[0].Promoted_price__c = 18;
       
        insert lstDealProduct1; 
        test.stoptest();
        List<OpportunityLineItem> oppLineItem = [Select Id,opportunity.AccountId,opportunity.Storefront_Account__c,Promoted_Price__c,Pricebook_Entry_Period__c,Account_Price__c,ListPrice__c,Rate_card__c,pricing__c,price_tier__c From OpportunityLineItem where id in :lstDealProduct1 limit 1];
       
        system.assertEquals(18,oppLineItem[0].Promoted_price__c);
        List<OpportunityLineItem> oppLineItem1 = [Select pricing__c,Rate_card__c,Permanent_Price_Tier__c,price_tier__c,Promoted_Price__c From OpportunityLineItem where id in :lstDealProduct1 limit 1];
        system.assertEquals('Tier 2',oppLineItem1[0].Price_Tier__c); 
          
    }
    
     //US#985
    public static testmethod void updatePriceTierOnDealProduct_InsertPromoPrice_StepPricing(){
        createData4();
         test.starttest();
        rateCardPrices[0].Rate_Card_Type__c = 'Step DVD 6/18';
        rateCardPrices[1].Rate_Card_Type__c = 'Step DVD 6/18';
        update rateCardPrices;
        rateCardPrices =[SELECT Id, Name, Account__c, WSP1__c,WSP2__c,WSP3__c, Start_Date__c,End_Date__c, Price_Tier__c, Country__r.Country_Code2__c, RC_Lifecycle__c,
                                                Content_Type__c, Channel__c, Format__c,Step1_Length_Months__c,Step2_Length_Months__c,Step_Pricing__c
                                                FROM Rate_Card__c ];    
        
        system.assertEquals(TRUE,rateCardPrices[0].Step_Pricing__c); 
        system.assertEquals(TRUE,rateCardPrices[1].Step_Pricing__c); 
        pbeD =[select id,pricing__c,price_tier__c,Account_Price__c from Pricebook_Entry_Period__c where id in: pbeD];
        rateCardPrices=[SELECT Id, Name, Account__c, WSP1__c,WSP2__c,WSP3__c, Price_Tier__c, Country__r.Country_Code2__c, 
                                                Content_Type__c, Channel__c, Format__c
                                                FROM Rate_card__c];
        system.debug('rateCardPrices:::::::::::::'+rateCardPrices);                                        
         // Create Deal Product records
        lstDealProduct1 = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry1, lstOpportunity1, 1, false);
        lstDealProduct1[0].OpportunityId = lstOpportunity1[0].id;
        lstDealProduct1[0].Pricebook_Entry_Period__c  = pbeD[0].id;
        lstDealProduct1[0].Promoted_price__c = 18;
      
        insert lstDealProduct1; 
        test.stoptest();
        List<OpportunityLineItem> oppLineItem = [Select Id,opportunity.AccountId,opportunity.Storefront_Account__c,Promoted_Price__c,Pricebook_Entry_Period__c,Account_Price__c,ListPrice__c,Rate_card__c,pricing__c,price_tier__c From OpportunityLineItem where id in :lstDealProduct1 limit 1];
       
        system.assertEquals(18,oppLineItem[0].Promoted_price__c);
        List<OpportunityLineItem> oppLineItem1 = [Select pricing__c,Rate_card__c,Permanent_Price_Tier__c,price_tier__c,Promoted_Price__c From OpportunityLineItem where id in :lstDealProduct1 limit 1];
        system.assertEquals('Tier 2',oppLineItem1[0].Price_Tier__c); 
          
    }
    
    //US#663
    public static testmethod void updatePriceTierOnDealProduct_InsertPriceTier(){
        createData4();
        test.starttest();
        
        pbeD =[select id,pricing__c,price_tier__c,Account_Price__c from Pricebook_Entry_Period__c where id in: pbeD];
        rateCardPrices=[SELECT Id, Name, Account__c, WSP1__c,WSP2__c,WSP3__c, Price_Tier__c, Country__r.Country_Code2__c, 
                                                Content_Type__c, Channel__c, Format__c
                                                FROM Rate_card__c];
                                                
         // Create Deal Product records
        lstDealProduct1 = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntry1, lstOpportunity1, 1, false);
        lstDealProduct1[0].OpportunityId = lstOpportunity1[0].id;
        lstDealProduct1[0].Pricebook_Entry_Period__c  = pbeD[0].id;
        lstDealProduct1[0].Price_Tier__c = 'Tier 2';
        
        insert lstDealProduct1; 
       test.stoptest();

        List<OpportunityLineItem> oppLineItem1 = [Select pricing__c,Rate_card__c,Permanent_Price_Tier__c,price_tier__c,Promoted_Price__c From OpportunityLineItem where id in :lstDealProduct1 limit 1];

        system.assertEquals(18,oppLineItem1[0].Promoted_price__c);
          
    } 
 
}