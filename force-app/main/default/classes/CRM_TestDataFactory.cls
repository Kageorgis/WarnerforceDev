@isTest
public class CRM_TestDataFactory {
    private static Id standardPricebookId ;
    static {
        if(standardPricebookId ==  null){
            standardPricebookId = System.Test.getStandardPricebookId();
        }
    }
    /**
     * createContributionItem(Integer, Boolean)
     *
     * This method is called to create Contribution Templates for a test class.
     *  numOfCTs = number of records to be created
     *  shouldInsert = to tell if records need to be inserted or need just instances (True => will insert records in DB).
     */
    public static List<Contribution_Item__c> createContributionItems(List<Contribution_Template__c> lstContributionTemplate, Integer numOfCIs, Boolean shouldInsert) {
        List<Contribution_Item__c> lstContributionItems = new List<Contribution_Item__c>();
        for (Integer nContriItem = 0; nContriItem < lstContributionTemplate.size(); nContriItem++){
            for(Integer nContributionItemCount = 0; nContributionItemCount < numOfCIs; nContributionItemCount ++)
                lstContributionItems.add(new Contribution_Item__c(Name ='CI' + nContributionItemCount, Contribution_Template__c = lstContributionTemplate[nContriItem].Id));            
        }
        if(shouldInsert && lstContributionItems != null && lstContributionItems.size() > 0)
            insert lstContributionItems;
        System.assertNotEquals(null,lstContributionItems);
        return lstContributionItems;
    }


    /**
     * createContributionTemplate(Integer, Boolean)
     *
     * This method is called to create Contribution Templates for a test class.
     *  numOfCTs = number of records to be created
     *  shouldInsert = to tell if records need to be inserted or need just instances (True => will insert records in DB).
     */
    public static List<Contribution_Template__c> createContributionTemplates(Integer numOfCTs, Boolean shouldInsert) {
        List<Contribution_Template__c> lstContributionTemplates = new List<Contribution_Template__c>();
        
        for(Integer nContributionTemplateCount = 0; nContributionTemplateCount < numOfCTs; nContributionTemplateCount ++) {
            Contribution_Template__c objContributionTemplate = new Contribution_Template__c(Name ='CT' + nContributionTemplateCount);
            lstContributionTemplates.add(objContributionTemplate);
        }
        
        if(shouldInsert)
            insert lstContributionTemplates;
        System.assertNotEquals(null,lstContributionTemplates);    
        return lstContributionTemplates;
    }

    /**
     * createStoreFronts(List<Account>, Boolean)
     *
     * This method is called to create Store Fronts for a test class.
     *  shouldInsert = to tell if records need to be inserted or need just instances (True => will insert records in DB).
     */
    public static List<Agreement__c> createStoreFronts(List<Account> lstAccounts, String strCurrency, String strCountry, boolean shouldInsert) {
        List<Agreement__c> lstStoreFronts = new List<Agreement__c>();
        if (lstAccounts != null && lstAccounts.size() > 0 && strCurrency != null && strCountry != null){
        
            for(Integer accCount = 0; accCount < lstAccounts.size(); accCount++){
                lstStoreFronts.add(new Agreement__c(Account__c = lstAccounts[accCount].Id, Pricing_Currency__c = strCurrency, Country__c = strCountry,  WSP_Currency__c=strCurrency,SAP_Customer_Number__c='12010421'));                            
            }
            if(lstStoreFronts != null && lstStoreFronts.size() > 0 && shouldInsert)
                insert lstStoreFronts;        
            System.assertNotEquals(null,lstStoreFronts);
        }
        
        return lstStoreFronts;
    }

    /**
     * createAccounts(Integer, Boolean)
     *
     * This method is called to create physical accounts for a test class.
     *  numAccts = number of records to be created.
     *  shouldInsert = to tell if records need to be inserted or need just instances (True => will insert records in DB).
     */
    public static List<Account> createAccounts(Integer numAccts, Boolean shouldInsert) {
        List<Account> accts = new List<Account>();
        //Id standardPricebookId = System.Test.getStandardPricebookId();
        for(Integer accCount = 0; accCount < numAccts; accCount++)
            accts.add(new Account(
                        Name ='TestAccount ' + accCount,
                        Planning_Customer__c = true,
                        Price_Book__c = standardPricebookId,
                        Games_Physical__c=True,
                        Video_Physical__c=True,
                        Status__c=CRM_AppConstants.ACCOUNT_STATUS_ACTIVE));
        
        if(accts != null && accts.size() > 0 && shouldInsert)
            insert accts;
        System.assertNotEquals(null,accts);
        return accts;
    }
    /**
     * createOpportunitiesWithAccounts(List<Account>, Integer, Boolean)
     *
     * This method is called to create opportunities for a test class.
     *  accts = list of accounts for which opporunities need to created
     *  numOppsPerAcct = number of opportunity records to be created for each account
     *  shouldInsert = to tell if records need to be inserted or need just instances (True => will insert records in DB).
     */
    public static List<Opportunity> createOpportunitiesWithAccounts(List<Account> accts, Integer numOppsPerAcct, Boolean shouldInsert) {
        List<Opportunity> opps = new List<Opportunity>();
        //Id standardPricebookId = System.Test.getStandardPricebookId();        
        for (Integer accCount = 0; accCount < accts.size(); accCount++) {

            for (Integer oppCount = 0; oppCount < numOppsPerAcct; oppCount++) {
                opps.add(new Opportunity(Name = ' Opportunity ' + Math.random() + oppCount,
                                       StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED,
                                       CloseDate = System.today() + 30,
                                       AccountId = accts[accCount].Id,
                                       Pricebook2Id = standardPricebookId,
                                       Start_Date__c = System.today() + 1,
                                       Promo_Start_Date__c = System.today() + 1,
                                       CurrencyIsoCode = 'USD',RecordTypeId=CRM_RecordTypeUtil.RT_DEAL_PHYSICAL));
            }
        }
        
        if(shouldInsert && opps != null && opps.size() > 0)
            insert opps;
            System.assertNotEquals(null,opps);
        return opps;
    }
    /**
     * createDecayCurveTemplates(Integer, Boolean)
     *
     * This method is called to create Decay Cureve templates for a test class.
     *  numTemplates = number of records to be created.
     *  shouldInsert = to tell if records need to be inserted or need just instances (True => will insert records in DB).
     */
    public static List<Decay_Curve_Template__c> createDecayCurveTemplates(Integer numTemplates, Boolean shouldInsert) {
        List<Decay_Curve_Template__c> templates = new List<Decay_Curve_Template__c>();
        for(Integer templateCount = 0; templateCount < numTemplates; templateCount++)
           templates.add(new Decay_Curve_Template__c(Name ='TestTemplate ' + templateCount,status__c = CRM_AppConstants.DECAY_CURVE_TEMPLATE_STATUS_DRAFT));

        if(templates != null && templates.size() > 0 && shouldInsert) {
            insert templates;
            System.assertNotEquals(null,templates);
        }

        return templates;
    }

    /**
     * createItemsWithDecayCurveTemplates(List<Decay_Curve_Template__c>, Integer, Boolean)
     *
     * This method is called to create Decay Curve Items for a test class.
     *  templates = list of Decay Curve Templates for which Items need to created
     *  numItemsPerTemplate = number of Decay Curve item records to be created for each Template
     *  shouldInsert = to tell if records need to be inserted or need just instances (True => will insert records in DB).
     */
    public static List<Decay_Curve_Item__c> createItemsWithDecayCurveTemplates(List<Decay_Curve_Template__c> templates, Integer numItemsPerTemplate, Boolean shouldInsert) {
        List<Decay_Curve_Item__c> items = new List<Decay_Curve_Item__c>();
        for (Integer templateCount = 0; templateCount < templates.size(); templateCount++) {
            Integer itemValue = Integer.valueOf(100 / numItemsPerTemplate);
            Integer sumItemValue = 0;

            for (Integer itemCount = 0; itemCount < numItemsPerTemplate; itemCount++) {
                sumItemValue += itemValue;
                if (itemCount == (numItemsPerTemplate -1)) {
                    itemValue += (100 - sumItemValue);
                    System.debug('-in if->'+itemValue);
                }
                Decimal itemValueInDecimal = Decimal.valueOf(itemValue).setscale(2);
                items.add(
                    new Decay_Curve_Item__c(
                        Name = ' Test Item ' + itemCount,
                        Day_Number__c = (itemCount + 1) * 2,
                        Percent_Allocation__c = itemValueInDecimal,
                        Decay_Curve_Template__c = templates[templateCount].Id
                    )
                );
            }
        }

        if(shouldInsert && items != null && items.size() > 0) {
            insert items;
            System.assertNotEquals(null,items);
        }
        return items;
    }

    public static List<OpportunityLineItem> createDealProductsWithOpportunities(List<PricebookEntry> lstPriceBookEntry, List<Opportunity> lstOpportunity, Integer numOppsPerDealProduct, Boolean shouldInsert){
        List<OpportunityLineItem> lstDealProduct = new List<OpportunityLineItem>();
        ID idPriceBookEntry;
        if (lstPriceBookEntry != null && lstPriceBookEntry.size() > 0){
            for (Integer nDealProdCount = 0; nDealProdCount < lstOpportunity.size(); nDealProdCount ++){
                for(Integer oppCount = 0; oppCount < numOppsPerDealProduct; oppCount++){
                  
                OpportunityLineItem objDealProduct = new OpportunityLineItem();
                objDealProduct.OpportunityId = lstOpportunity[nDealProdCount].Id;

                if (lstPriceBookEntry.size() >= (oppCount + 1))
                    idPriceBookEntry = lstPriceBookEntry[oppCount].Id;
                      
                objDealProduct.PricebookEntryId = idPriceBookEntry;
                objDealProduct.Quantity = 1;
                objDealProduct.UnitPrice = 14.10;
                lstDealProduct.add(objDealProduct);
                }
            }
        }
        
        if (lstDealProduct != null && lstDealProduct.size() > 0 && shouldInsert){
            insert lstDealProduct;
            System.assertNotEquals(null,lstDealProduct);

        }
        
        return lstDealProduct;        
    }
    
    public static List<PricebookEntry> createPriceBookEntries(List<Product2> lstProduct, Integer numPBEntriesPerProduct, Boolean shouldInsert){
        List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
        //Id standardPricebookId = System.Test.getStandardPricebookId();     
        for(Integer nProductCount = 0; nProductCount < lstProduct.size(); nProductCount++){         
            if (numPBEntriesPerProduct == null)
                numPBEntriesPerProduct = 1;
                
            for (Integer oppCount = 0; oppCount < numPBEntriesPerProduct; oppCount++) {
                PricebookEntry objPriceBookEntry = new PricebookEntry();
                objPriceBookEntry.UseStandardPrice = false;
                objPriceBookEntry.UnitPrice = 10.00 * (oppCount + 1);
                objPriceBookEntry.CurrencyIsoCode = 'USD';
                objPriceBookEntry.Product2Id = lstProduct[nProductCount].Id;                
                objPriceBookEntry.IsActive = true;
                objPriceBookEntry.Pricebook2Id = standardPricebookId;
                lstPricebookEntry.add(objPriceBookEntry);
            }
        }
        if (shouldInsert && lstPricebookEntry != null && lstPricebookEntry.size() > 0)
            insert lstPricebookEntry;
            System.assertNotEquals(null,lstPricebookEntry);
        
        return lstPricebookEntry;
    }    
    
    public static List<Product2> createProducts(List<Product_Group__c> lstProductGroup, Integer numProducts, Boolean shouldInsert){

        List<Product2> lstProduct = new List<Product2>();

        if(numProducts == null)
            numProducts = 1;
        for (Product_Group__c objPG : lstProductGroup){
            for (Integer nProductPerLocalDataCount = 0; nProductPerLocalDataCount < numProducts; nProductPerLocalDataCount++){
                Product2 objProduct = new Product2();                
                objProduct.Product_Format__c = 'DVD';                
                objProduct.Name = 'PR ' + nProductPerLocalDataCount + Math.random();
                objProduct.NR_period_weeks__c = 2;                
                objProduct.Street_Date__c = System.today()-40;             
                objProduct.NR_period_weeks__c = 7;         
                objProduct.Product_Group__c = objPG.Id;  
                objProduct.Delivery_Lead_Days__c = 4;
                objProduct.IsActive = true;
                objProduct.CanUseQuantitySchedule = true;
                objProduct.SAP_Dist_chain_product_Status__c = '01';
                objProduct.CanUseRevenueSchedule = true;
                objProduct.External_Id__c = string.valueOf(math.random())+ string.ValueOf(nProductPerLocalDataCount);
                lstProduct.add(objProduct);
            }
        
        }
        if (shouldInsert && lstProduct != null && lstProduct.size() > 0)
            insert lstProduct;
             System.assertNotEquals(null,lstProduct);
        return lstProduct;
    }        
 
 
    public static List<Product_Group__c> createProductGroups(Integer numProductGroups, Boolean shouldInsert){
        
        List<Product_Group__c> lstProductGroup = new List<Product_Group__c>(); 
                
        for(Integer nPG = 0; nPG < numProductGroups; nPG++){
            Product_Group__c objProductGroup = new Product_Group__c();
            
            objProductGroup.name = 'Digital - Games - PS4';
            objProductGroup.External_Id__c = 'UK_Digital_Games_PS4_Target_Test_' + nPG;
            objProductGroup.Franchise_Type__c = 'Games';
            objProductGroup.CurrencyIsoCode = 'USD';
            lstProductGroup.add(objProductGroup);
        }
        
        if (shouldInsert && lstProductGroup != null && lstProductGroup.size() > 0)
            insert lstProductGroup;         
            System.assertNotEquals(null,lstProductGroup);
        return lstProductGroup;
    }
 
    public static List<Local_Title__c> createLocalData(List<Country__c> lstCountry, Integer numLocalDataPerCountry, Boolean shouldInsert){
        List<Local_Title__c> lstLocalData = new List<Local_Title__c>();
        
        for(Integer nCountryCount = 0; nCountryCount < lstCountry.size(); nCountryCount ++){
            Country__c objCountry = lstCountry[nCountryCount];
            if (numLocalDataPerCountry == null)
                numLocalDataPerCountry = 1;
            for(Integer nLocalDataPerCountry = 0; nLocalDataPerCountry < numLocalDataPerCountry; numLocalDataPerCountry++){
                Local_Title__c objLocalData = new Local_Title__c();
                objLocalData.Country__c = objCountry.Id;
                lstLocalData.add(objLocalData);
            }       
        }   
        
        if (shouldInsert && lstLocalData != null && lstLocalData.size() > 0)
            insert lstLocalData;
            System.assertNotEquals(null,lstLocalData);
        return lstLocalData;
    }
    
    public static List<Country__c> createCountries(List<String> strRegion, Integer nCountries, Boolean shouldInsert){
        List<Country__c> lstCountry = new List<Country__c>();
        
        for(Integer nCountryCount = 0; nCountryCount < strRegion.size(); nCountryCount++){
            Country__c objCountry = new Country__c();           
            objCountry.Region__c = strRegion[nCountryCount];
            objCountry.Country_Code2__c = strRegion[nCountryCount];
            objCountry.Country_Code__c = strRegion[nCountryCount];
            objCountry.Generate_CRM_Product__c = true;
            lstCountry.add(objCountry);         
        }
        
        if (shouldInsert && lstCountry != null && lstCountry.size() > 0)
            insert lstCountry;
            System.assertNotEquals(null,lstCountry);
        return lstCountry;
    }
    
    public static List<File_Discount__c> createFileDiscounts(List<Account> lstAccount, Integer numFileDiscountsPerAccount, Boolean shouldInsert){
        List<File_Discount__c> lstFileDiscount = new List<File_Discount__c>();
        Date dtTodayDate = Date.today();
        
        for(Account acct : lstAccount){
            for (Integer nFileDiscPerAcct = 0; nFileDiscPerAcct < numFileDiscountsPerAccount; nFileDiscPerAcct ++){
                File_Discount__c objFileDiscount = new File_Discount__c();
                objFileDiscount.Customer__c = acct.Id;
                objFileDiscount.Discount_Percent__c = 3;
                objFileDiscount.Start_Date__c = dtTodayDate + 3;
                objFileDiscount.End_Date__c = dtTodayDate + 45;
                objFileDiscount.Format__c =  'DVD';
                objFileDiscount.Product_Type__c = 'New Release';
                lstFileDiscount.add(objFileDiscount);
            }
        }
        
        if (shouldInsert && lstFileDiscount != null && lstFileDiscount.size() > 0)
            insert lstFileDiscount;
            System.assertNotEquals(null,lstFileDiscount);
        return lstFileDiscount;
    }    
    
    public static List<Pricebook_Entry_Period__c> createPriceBookEntryPeriods(List<Product2> lstProduct, Integer numPriceBookEntriesPerProduct, Boolean shouldInsert){
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = new List<Pricebook_Entry_Period__c>();
        Date dtTodayDate = Date.today();
       
        for(Product2 objProduct : lstProduct){
            for(Integer nPriceBookEntryPerProduct = 0; nPriceBookEntryPerProduct < numPriceBookEntriesPerProduct; nPriceBookEntryPerProduct++){
                Pricebook_Entry_Period__c objPriceBookEntryProduct = new Pricebook_Entry_Period__c();
                    objPriceBookEntryProduct.Product__c = objProduct.Id;
                    objPriceBookEntryProduct.List_Price__c = 20;
                    objPriceBookEntryProduct.Start_Date__c = dtTodayDate;
                    objPriceBookEntryProduct.End_Date__c = dtTodayDate + 30;
                    objPriceBookEntryProduct.Price_Book__c = standardPricebookId;
                    objPriceBookEntryProduct.CurrencyISOCode ='USD';
                lstPriceBookEntryPeriod.add(objPriceBookEntryProduct);
            }           
        }
        
        if (shouldInsert && lstPriceBookEntryPeriod != null && lstPriceBookEntryPeriod.size() > 0)
            insert lstPriceBookEntryPeriod;
            System.assertNotEquals(null,lstPriceBookEntryPeriod);
        return lstPriceBookEntryPeriod;
    } 
    
    public static List<Bundle__c> createBundles(Integer noOfRecords, Boolean shouldInsert){
        List<Bundle__c> bundles = new List<Bundle__c>();
        
        for(Integer index = 0; index < noOfRecords; index++){
            Bundle__c currentBundle = new Bundle__c();
            currentBundle.Start_Date__c = Date.today();
            currentBundle.Price_Book__c = standardPricebookId;
            currentBundle.End_Date__c = System.today() + 30;
                
            bundles.add(currentBundle);
        }        
        
        if (shouldInsert)
            insert bundles;
            System.assertNotEquals(null,bundles);
        return bundles;
    } 
    
    public static List<Bundle_Product__c> createBundleProducts(List<Bundle__c> bundles, List<Product2> products, Integer noOfRecords, Boolean shouldInsert){
        List<Bundle_Product__c> bundleProducts = new List<Bundle_Product__c>();
        
        for(Bundle__c currentBundle : bundles){
            for(Product2 currentProduct : products){
                for(Integer index = 0; index < noOfRecords; index++){
                    Bundle_Product__c currentBundleProduct = new Bundle_Product__c();
                    
                    currentBundleProduct.Bundle__c = currentBundle.ID;
                    currentBundleProduct.Product__c = currentProduct.ID;
                        
                    bundleProducts.add(currentBundleProduct);
                }    
            }
        }
        
        if (shouldInsert)
            insert bundleProducts;
            System.assertNotEquals(null,bundleProducts);
        return bundleProducts;
    } 
    
    public static List<Order> createOrders(List<Account> accts, Integer noOfRecords, Boolean shouldInsert){
        List<Order> orders = new List<Order>();

        for (Integer accCount = 0; accCount < accts.size(); accCount++) {
            
            for (Integer orderCount = 0; orderCount < noOfRecords; orderCount++) {
                
                orders.add(
                        new order(
                                Name = ' Order ' + Math.random() + orderCount,
                                Status = 'Open',
                                AccountId = accts[accCount].Id,
                                PriceBook2Id = standardPricebookId,
                                EffectiveDate = System.today(),
                                EndDate = System.today()+30,
                                CurrencyIsoCode = 'USD'                                
                        )
                );
            }
        }
        
        if(shouldInsert)
            insert orders;
            System.assertNotEquals(null,orders);
        return orders;
    }
    
    public static List<OrderItem> createOrderProductWithOrder(List<PricebookEntry> lstPriceBookEntry, List<Order> lstOrder, Integer numOrderPerOrderProduct, Boolean shouldInsert){
        List<OrderItem> lstOrderProduct = new List<OrderItem>();
        ID idPriceBookEntry;
        if (lstPriceBookEntry != null && lstPriceBookEntry.size() > 0){
            for (Integer nOrderProdCount = 0; nOrderProdCount < lstOrder.size(); nOrderProdCount ++){
                  
                OrderItem objOrderProduct = new OrderItem();
                objOrderProduct.OrderId = lstOrder[nOrderProdCount].Id;
                    
                if (lstPriceBookEntry.size() >= (nOrderProdCount + 1))
                    idPriceBookEntry = lstPriceBookEntry[nOrderProdCount].Id;
                      
                objOrderProduct.PricebookEntryId = idPriceBookEntry;
                objOrderProduct.Quantity = 1;
                objOrderProduct.UnitPrice = 14.10;                
                lstOrderProduct.add(objOrderProduct);
            }
        }
        if (lstOrderProduct != null && lstOrderProduct.size() > 0 && shouldInsert){
            insert lstOrderProduct;
            System.assertNotEquals(null,lstOrderProduct);
        }
        
        return lstOrderProduct;        
    }
    
    public static List<OpportunityLineItemSchedule> createOpportunitySchedule(List<OpportunityLineItem> dealProducts, Integer noOfRecords, Boolean shouldInsert){
        List<OpportunityLineItemSchedule> schedules = new List<OpportunityLineItemSchedule>();
        
        for (OpportunityLineItem currentDealProduct : dealProducts) {    
            
            for (Integer index = 0; index < noOfRecords; index++) {
                
                schedules.add(
                    new OpportunityLineItemSchedule(
                        OpportunityLineItemId = currentDealProduct.ID,
                        Quantity = 21 + index,
                        ScheduleDate = System.today(),
                        Type = 'Quantity'
                    )
                );          
            }            
        }
        
        if(shouldInsert)
            insert schedules;
            System.assertNotEquals(null,schedules);
        return schedules;
    }
    
    public static List<Target__c> createTargets(List<Account> lstAccount, List<Product_Group__c> lstProductGroup, List<Account_Plan__c> lstAccountPlan, Boolean shouldInsert){
        Map<Id, Account_Plan__c> mapAccountIdToAccountPlan = new Map<Id, Account_Plan__c>();
        for (Account_Plan__c accountPlan : lstAccountPlan) {
            mapAccountIdToAccountPlan.put(accountPlan.Customer__c, accountPlan);
        }

        List<Target__c> lstTargets = new List<Target__c>();
        for(Account account : lstAccount){
            for (Product_Group__c productGroup : lstProductGroup){
                    Target__c targetInstance = new Target__c(
                        Account__c = account.Id,
                        Product_Group__c = productGroup.Id,
                        StartDate__c = System.today(),
                        End_Date__c = System.today() + 56,
                        Approved__c = null,
                        Planned__c = null,
                        Confirmed__c = null,
                        Actual_Revenue__c = null,
                        High_Level__c = null,
                        CurrencyIsoCode = 'USD'
                    );
                    if (mapAccountIdToAccountPlan.containskey(account.Id)) {
                        targetInstance.Account_Plan_Lookup__c = mapAccountIdToAccountPlan.get(account.Id).Id;
                    }
 
                    lstTargets.add(targetInstance);
             }
        }
        if(shouldInsert){
            insert lstTargets;
            System.assertNotEquals(null,lstTargets);
        }
        return lstTargets;
    }
    
    public static List<Account_Product__c> createAccountProduct(List<Account> accts, List<Product2> products, Boolean shouldInsert){
        
        List<Account_Product__c> accountProducts = new List<Account_Product__c>();
        
        for(Account acc : accts) {
            for(Product2 currentProduct : products) {
                accountProducts.add(new Account_Product__c(
                                    Account__c = acc.Id,
                                    Product__c = currentProduct.ID,
                                    Stock_Level__c = 12));
            }
        }
        
        if(shouldInsert){
            insert accountProducts;
            System.assertNotEquals(null,accountProducts);
        }
        
        return accountProducts;
    }
    
    public static List<Agreement__c> createStoreFronts(List<Account> accts, List<Title__c> titles, List<Country__c> countries, Boolean shouldInsert){
        
        List<Agreement__c> storeFronts = new List<Agreement__c>();
        Integer index = 0;
        
        for(Account acc : accts) {
            storeFronts.add(new Agreement__c(
                    Account__c = acc.Id,
                    Active__c = true,
                    Content_Type__c = titles.size() > index ? titles[index].Content_Type__c : titles[0].Content_Type__c,
                    Pricing_Currency__c = 'USD',
                    WSP_Currency__c = 'USD',
                    Format__c = 'TestFormat' + index,
                    Status__c = 'Active', 
                    Effective_Date__c = Date.valueOf(System.now().addDays(2)),
                    Channel_Picklist__c = 'EST' + index,
                    Country__c = countries.size() > index ? countries[index].ID : countries[0].ID,
                    SAP_Customer_Number__c='12010421'
            ));
            index++;            
        }
        
        if(shouldInsert){
            insert storeFronts;
            System.assertNotEquals(null,storeFronts);
        }
        
        return storeFronts;
    }
    
    public static List<Commercial_Avail__c> createReleasePlans(
                                                    Integer noOfPlans, List<Title__c> titles, List<Agreement__c> storeFronts, 
                                                    List<Local_Title__c> localTitles, List<Country__c> countries, List<Language__c> languages, Boolean shouldInsert){
        
        List<Commercial_Avail__c> releasePlans = new List<Commercial_Avail__c>();
        
        for(Agreement__c currentStoreFronts : storeFronts) {
            for(Integer index = 0 ; index < noOfPlans ; index++){           
                releasePlans.add(new Commercial_Avail__c(
                        Country_Lookup__c = countries.size() > index ? countries[index].ID : countries[0].ID,
                        Local_Title__c = localTitles.size() > index ? localTitles[index].ID : localTitles[0].ID,
                        Channel__c = currentStoreFronts.Channel_Picklist__c,
                        Format__c = currentStoreFronts.Format__c,
                        Title__c = titles.size() > index ? titles[index].ID : titles[0].ID,
                        End_Date__c = Date.valueOf(System.now().addDays(4)),
                        Start_Date__c = Date.valueOf(System.now().addDays(2)),
                        Languages__c = languages[0].Id,
                        Status__c = 'Confirmed',
                        Rights_End__c = Date.valueOf(System.now().addDays(4)),
                        Exclusive_Date__c = Date.valueOf(System.now().addDays(2))
                    )
                );
            }           
        }
        
        
        if(shouldInsert){
            insert releasePlans;
            System.assertNotEquals(null,releasePlans);
        }
        
        return releasePlans;
    }
    
    public static List<Title__c> createTitles(Integer noOfTitles, Boolean shouldInsert){
        
        List<Title__c> titles = new List<Title__c>();
        
        for(Integer index = 0 ; index < noOfTitles ; index++){              
            titles.add(new Title__c(
                    Name = 'TestTitle-' + index,
                    Video_Version__c = 'TestVersion-' + index,
                    Content_Type__c = 'Feature',
                    Clear_to_Avail__c = true,
                    Formats__c = '3DHD',
                    Digital_Planning__c = 'Yes'
                    
                )
            );
        }
        
        if(shouldInsert){
            insert titles;
            System.assertNotEquals(null,titles);
        }
        
        return titles;
    }
    
    public static List<Pricing__c> createPricings(Integer noOfPrices, Boolean shouldInsert){
        
        List<Pricing__c> prices = new List<Pricing__c>();
        
        for(Integer index = 0 ; index < noOfPrices ; index++){          
            prices.add(new Pricing__c(
                    Minimum_Price__c = 100,
                    Account_Price__c = 150//,
                    //Suggested_Price__c = 150
                )
            );
        }           
        
        
        if(shouldInsert){
            insert prices;
            System.assertNotEquals(null,prices);
        }
        
        return prices;
    }
    
    public static List<Client_Avail__c> createClientAvails(List<Pricing__c> prices, List<Commercial_Avail__c> releasePlans, 
            List<Local_Title__c> localTitles, List<Account> accts, List<Agreement__c> storeFronts, Integer noOfRecords, Boolean shouldInsert){
        
        List<Client_Avail__c> clientAvails = new List<Client_Avail__c>();
        
        for(Pricing__c currentPrice : prices) {
            for(Integer index = 0 ; index < noOfRecords ; index++){         
                clientAvails.add(new Client_Avail__c(
                        Local_Title__c = localTitles.size() > index ? localTitles[index].ID : localTitles[0].ID,
                        Pricing__c = currentPrice.ID,
                        Commercial_Avail__c = releasePlans.size() > index ? releasePlans[index].ID : releasePlans[0].ID,
                        Storefront__c = storeFronts.size() > index ? storeFronts[index].ID : storeFronts[0].ID,
                        Client__c = accts.size() > index ? accts[index].ID : accts[0].ID,
                        Status__c = 'Draft', 
                        End_Date__c = Date.valueOf(System.now().addDays(4)),
                        Start_Date__c = Date.valueOf(System.now().addDays(2))
                    )
                );      
            }
        }
        
        if(shouldInsert){
            insert clientAvails;
            System.assertNotEquals(null,clientAvails);
        }
        
        return clientAvails;
    }
    
    public static List<Language__c> createLanguages(Integer noOfRecords, Boolean shouldInsert){
        
        List<Language__c> languages = new List<Language__c>();

        for(Integer index = 0 ; index < noOfRecords ; index++){         
            languages.add(new Language__c(
                    Name = 'Test Language ' + index,
                    Language_Code_2__c = 'TL' + index,
                    Language_Code_3__c = 'TL' + index,
                    Language_Order__c = index,
                    EMA_Store_Language__c = 'TL' + index
                )
            );      
        }
        
        
        if(shouldInsert){
            insert languages;
            System.assertNotEquals(null,languages);
        }
        
        return languages;
    }
    
    public static List<Local_Title__c> createLocalTitles(List<Country__c> countries, List<Language__c> languages, Integer noOfRecords, Boolean shouldInsert){
        
        List<Local_Title__c> localTitles = new List<Local_Title__c>();
        
        for(Country__c currentCountry : countries){  
            
            for(Integer index = 0 ; index < noOfRecords ; index++){    
                Local_Title__c objLocalData = new Local_Title__c();
                objLocalData.Name = 'Test ' + currentCountry.Name;
                objLocalData.Country__c = currentCountry.Id;
                objLocalData.Language__c = languages[index].ID;
                
                localTitles.add(objLocalData);
            } 
        }
        
        if(shouldInsert){
            insert localTitles;
            System.assertNotEquals(null,localTitles);
        }
        
        return localTitles;
    }
     
    /**
     * createTopics(Integer, Boolean)
     *
     * This method is called to create Topics for a test class.
     *  numtopics = number of records to be created.
     *  shouldInsert = to tell if records need to be inserted or need just instances (True => will insert records in DB).
    */      
    public static List<Topic> createTopics(Integer numtopics, Boolean shouldInsert) {
        List<Topic> topics = new List<Topic>();

        for(Integer topiccount = 0; topiccount < numtopics; topiccount++)
            topics.add(new Topic(Name ='Cognizant234' + topiccount));
        
        if(topics!= null && topics.size() > 0 && shouldInsert)
            insert topics;
            System.assertNotEquals(null,topics); 
        return topics;
    }   
    
    /**
     * createCountryPlanCatalog(list<Product_Group__c>)
     * This method is called to create country plan for a test class.
    */      
    public static Country_Plan__c createCountryPlanCatalog(list<Product_Group__c> lstProductGroup) {
        
        Country_Plan__c countryPlan = new Country_Plan__c();
        countryPlan.Name = 'CountryPlanCatalogTest'+ Math.random() + system.now();
        countryPlan.Country__c = 'United Kingdom';
        countryPlan.Year__c = '2016';
        countryPlan.Product_Group1__c = lstProductGroup[0].Id;
        countryPlan.CurrencyIsoCode = 'USD';
        countryPlan.Stretch_Target__c = 10;
        countryPlan.External_id__c = '123'+string.ValueOf(math.random());
        countryPlan.RecordTypeID = [select id,Name from RecordType where SobjectType='Country_Plan__c' and DeveloperName='Catalog' Limit 1].ID;
        insert countryPlan;
        System.assertNotEquals(null,countryPlan); 
        return countryPlan;
    } 
    
    public static Country_Plan__c createCountryPlanCatalogInstance(list<Product_Group__c> lstProductGroup) {
        
        Country_Plan__c countryPlan = new Country_Plan__c();
        countryPlan.Name = 'CountryPlanCatalogTest'+ Math.random() + system.now();
        countryPlan.Country__c = 'United Kingdom';
        countryPlan.Year__c = '2016';
        countryPlan.Product_Group1__c = lstProductGroup[0].Id;
        countryPlan.CurrencyIsoCode = 'USD';
        countryPlan.Stretch_Target__c = 10;
        countryPlan.External_id__c = '123'+string.ValueOf(math.random());
        countryPlan.RecordTypeID = [select id,Name from RecordType where SobjectType='Country_Plan__c' and DeveloperName='Catalog' Limit 1].ID;
       // insert countryPlan;
        System.assertNotEquals(null,countryPlan); 
        return countryPlan;
    }   

    /**
     * createCountryPlanNewRelease(list<Product2>)
     * This method is called to create country plan for a test class.
    */      
    public static Country_Plan__c createCountryPlanNewRelease(list<Product2> lstProduct) {
        
        Country_Plan__c countryPlan = new Country_Plan__c();
        countryPlan.Name = 'CountryPlanNewReleaseTest';
        countryPlan.NR_Product__c = lstProduct[0].Id;
        countryPlan.Country__c = 'United Kingdom';
        countryPlan.Year__c = '2016';
        countryPlan.CurrencyIsoCode = 'USD';
        countryPlan.Stretch_Target__c = 10;
        countryPlan.External_id__c = '124'+string.ValueOf(math.random());
        countryPlan.RecordTypeID = CRM_RecordTypeUtil.RT_COUNTRY_PLAN_NEW_RELEASE; //[select id,Name from RecordType where SobjectType='Country_Plan__c' and DeveloperName='New_Release' Limit 1].ID;
        insert countryPlan;
        System.assertNotEquals(null,countryPlan);
        return countryPlan;
    }
    
    /**
     * createCountryPlanNewRelease(list<Product2>)
     * This method is called to create country plan for a test class.
    */      
    public static Country_Plan__c createCountryPlanNewReleaseInstance(list<Product2> lstProduct) {
        
        Country_Plan__c countryPlan = new Country_Plan__c();
        countryPlan.Name = 'CountryPlanNewReleaseTest';
        countryPlan.NR_Product__c = lstProduct[0].Id;
        countryPlan.Country__c = 'United Kingdom';
        countryPlan.Year__c = '2016';
        countryPlan.CurrencyIsoCode = 'USD';
        countryPlan.Stretch_Target__c = 10;
        countryPlan.External_id__c = '124'+string.ValueOf(math.random());
        countryPlan.RecordTypeID = CRM_RecordTypeUtil.RT_COUNTRY_PLAN_NEW_RELEASE; //[select id,Name from RecordType where SobjectType='Country_Plan__c' and DeveloperName='New_Release' Limit 1].ID;
        //insert countryPlan;
        System.assertNotEquals(null,countryPlan);
        return countryPlan;
    }
    
    /**
     * createCountryPlanTarget(Country_Plan__c,List<GL_Calendar__c>)
     * This method is called to create country plan target for a test class.
    */      
    public static list<Country_Plan_Target__c> createCountryPlanTarget(Country_Plan__c countryPlan,List<GL_Calendar__c> glclist) {
        
        Country_Plan_Target__c countryPlanTarget;
        list<Country_Plan_Target__c> countryPlanTargetList = new list<Country_Plan_Target__c>();
        for(GL_Calendar__c glc : glclist){
        countryPlanTarget  = new Country_Plan_Target__c();
        countryPlanTarget.Country_Plan__c = countryPlan.Id;
        countryPlanTarget.GL_Calendar__c = glc.Id;
        countryPlanTarget.Target__c = 100;
        countryPlanTarget.CurrencyIsoCode = 'USD';
        countryPlanTarget.Returns_Target__c = 10;
        countryPlanTarget.Billing_Adjustment_Target__c = 20;
        countryPlanTarget.Returns_Forecast__c = 30;
        countryPlanTarget.Billing_Adjustment_Forecast__c = 40;
        //countryPlanTarget.external_Id__c = glc.month__c;
        countryPlanTargetList.add(countryPlanTarget);
        }
        //system.debug('test*******' + countryPlanTargetList);
        insert countryPlanTargetList;
        System.assertNotEquals(null,countryPlanTargetList);    
        return countryPlanTargetList;
    } 
    /**
     * createAccountPlan(Integer,Country_Plan__c,GL_Calendar__c)
     * This method is called to create account plan for a test class.
    */      
    public static list<Account_Plan__c> createAccountPlan(Integer numAccountPlan,Country_Plan__c countryPlan,Account account) {
        
        Account_Plan__c accountPlan ;
        list<Account_Plan__c> accountPlanList = new list<Account_Plan__c>();
        for(integer i=0 ; i<numAccountPlan ; i++){
        accountPlan = new Account_Plan__c();
        accountPlan.Country_Plan__c = countryPlan.Id;
        accountPlan.Customer__c = account.Id;
        accountPlan.Share__c = 10;
        accountPlan.CurrencyIsoCode = 'USD';
        accountPlan.Returns_Share__c = 15;
        accountPlan.Billing_Adjustment_Share__c = 12;
        accountPlanList.add(accountPlan);
        }
        insert accountPlanList;
        System.assertNotEquals(null,accountPlanList);     
        return accountPlanList;
    }

    /**
     * createCountryPlanNewRelease(list<Product2>)
     * This method is called to create country plan for a test class.
    */      
    public static List<Country_Plan__c> createCountryPlanNewRelease(Integer numCountryPlan, list<Product2> lstProduct, Boolean shouldInsert) {
        List<Country_Plan__c> lstCountryPlan = new List<Country_Plan__c>();
        for (Product2 prod : lstProduct) {
            for (Integer i=0 ; i<numCountryPlan; i++) {
                Country_Plan__c countryPlan = new Country_Plan__c();
                countryPlan.Name = 'CountryPlanNewReleaseTest';
                countryPlan.Country__c = 'United Kingdom';
                countryPlan.Year__c = '2016';
                countryPlan.NR_Product__c = prod.Id;
                countryPlan.CurrencyIsoCode = 'USD';
                countryPlan.Stretch_Target__c = 10;
                countryPlan.External_Id__c = string.valueOf(math.random())+string.valueOf(i);
                countryPlan.RecordTypeID = CRM_RecordTypeUtil.RT_COUNTRY_PLAN_NEW_RELEASE; // [select id,Name from RecordType where SobjectType='Country_Plan__c' and DeveloperName='New_Release' Limit 1].ID;
                lstCountryPlan.add(countryPlan);
            }
        }
        if(lstCountryPlan!= null && lstCountryPlan.size() > 0 && shouldInsert)
            insert lstCountryPlan;
            System.assertNotEquals(null,lstCountryPlan);
        return lstCountryPlan;
    }

    /**
     * createAccountPlan(Integer,List<Country_Plan__c>,List<Account>)
     * This method is called to create account plan for a test class.
    */      
    public static list<Account_Plan__c> createAccountPlan(List<Country_Plan__c> lstCountryPlan,List<Account> lstAccount, Boolean shouldInsert) {
        List<Account_Plan__c> accountPlanList = new List<Account_Plan__c>();
        for (Integer i=0; i<lstCountryPlan.size(); i++) {
            for (Integer j=0; j < lstAccount.size(); j++) {
                Account_Plan__c accountPlan = new Account_Plan__c();
                accountPlan.Country_Plan__c = lstCountryPlan[i].Id;
                accountPlan.Customer__c = lstAccount[j].Id;
                accountPlan.CurrencyIsoCode = 'USD';
                accountPlan.Share__c = 10;
                accountPlanList.add(accountPlan);
            }
        }
        if(accountPlanList!= null && accountPlanList.size() > 0 && shouldInsert)
            insert accountPlanList;
            System.assertNotEquals(null,accountPlanList);
        return accountPlanList;
    }
    
    /**
     * createCoopBudget(Integer numCoopBudget, Boolean shouldInsert)
     * This method is called to create Coop_Budget__c for test class.
    */  
    public static List<Coop_Budget__c> createCoopBudget(Integer numCoopBudget, Boolean shouldInsert) {
        List<Coop_Budget__c> lstCoopBudget = new List<Coop_Budget__c>();
        
        for (Integer i = 0; i < numCoopBudget; i++) {
            Coop_Budget__c objCoopBudget = new Coop_Budget__c();
            objCoopBudget.Name = 'Test Co-op Budget';
            objCoopBudget.CurrencyIsoCode = 'USD';
            objCoopBudget.Amount__c = 1000;
            objCoopBudget.Start_Date__c = System.today() - 30;
            objCoopBudget.End_Date__c = System.today() + 30;
            lstCoopBudget.add(objCoopBudget);
        }       
    
        if (shouldInsert && !lstCoopBudget.isEmpty()){
            insert lstCoopBudget;
        }
    
        return lstCoopBudget;
    }

    /**
     * createCreditNotes(List<Opportunity> lstDeals, Boolean shouldInsert)
     * This method is called to create Credit Note for test class.
    */  
    public static List<Credit_Note__c> createCreditNotes(List<Opportunity> lstDeals, Boolean shouldInsert) {
        List<Credit_Note__c> lstCreditNote = new List<Credit_Note__c>();
        
        for (Opportunity objDeal: lstDeals){
            Credit_Note__c objCreditNote = new Credit_Note__c();
            objCreditNote.CurrencyIsoCode = 'USD';
            objCreditNote.PO_Number__c = 'CNPO Number';
            objCreditNote.Credit_Note_Type__c = 'Credit Memo';
            //objCreditNote.Deal__c = objDeal.Id;
            objCreditNote.Status__c = 'Planned'; // Status cannot be 'Ready To Pay' while creating CN
            List<Coop_Budget__c> lstCoopBudget = createCoopBudget(1, true);
            objCreditNote.Coop_Budget__c = lstCoopBudget[0].Id;
            //objCreditNote.Account__c = '';
            objCreditNote.Amount__c = 100000;
            lstCreditNote.add(objCreditNote);
        }       
    
        if (shouldInsert){
            insert lstCreditNote;
            System.assertNotEquals(null,lstCreditNote);
        }
    
        return lstCreditNote;
    }    

    /**
     * createMaxProductLimitSetting(Integer maxCount, Boolean shouldInsert)
     * This method is called to create maximum Product count per page in test class
     */
    public static CRM_Max_Product_Limit__c createMaxProductLimitSetting(String name, Integer maxCount, Boolean shouldInsert) {
        CRM_Max_Product_Limit__c settingsInsatnce = new CRM_Max_Product_Limit__c();
        settingsInsatnce.Name = name;
        settingsInsatnce.Count__c = maxCount;

        if (shouldInsert){
            insert settingsInsatnce;
            System.assertNotEquals(null,settingsInsatnce);
        }
        return settingsInsatnce;
    }
    /**
     * createFunctionalPermissionSetting(Integer maxCount, Boolean shouldInsert)
     * This method is called to set flag to hide La Moulinette functionality in test class
     */
    public static CRM_Functional_Permissions__c createFunctionalPermissionSetting(Boolean bHideLaMoulinette, Boolean shouldInsert) {
        CRM_Functional_Permissions__c settingsInsatnce = new CRM_Functional_Permissions__c();
        settingsInsatnce.ShowLaMoulinette__c = true;
        if (shouldInsert){
            insert settingsInsatnce;
            System.assertNotEquals(null,settingsInsatnce);
        }
        return settingsInsatnce;
    }
    
    public static Assortment_Account__c createAssortmentAccount(Bundle__c assortment, Account account) {
        Assortment_Account__c assortmentAccount = new Assortment_Account__c();
        assortmentAccount.Account__c = account.Id;
        assortmentAccount.Assortment__c = assortment.Id;
        assortmentAccount.Share__c = 10;
        return assortmentAccount;
    }
    
    public static POS_Forecast__c createPOSForecast(Bundle__c assortment) {
        POS_Forecast__c posForecast = new POS_Forecast__c();
        posForecast.Assortment__c = assortment.Id;
        posForecast.Case_Type_Code__c = 'Test Type Code';
        posForecast.POS_Type__c = 'POS Material';
        return posForecast;
    }
    public static Config__c createConfig(Bundle__c assortment){
        Config__c config = new Config__c();
        config.RecordTypeId = CRM_RecordTypeUtil.RT_CONFIG_SBOM;
        config.Assortment__c = assortment.Id;
        return config;
    }
    
    /**
     * createTargetSplitTemplate(Integer,Boolean)
     *
     * This method is called to create Target Split Templates for a test class.
     *  shouldInsert = to tell if records need to be inserted or need just instances (True => will insert records in DB).
     */
    public static List<Target_Split_Template__c> createTargetSplitTemplate(Integer numberOfRecords, boolean shouldInsert) {
        List<Target_Split_Template__c> lstTargetSplitTemplate = new List<Target_Split_Template__c>();
        for(Integer i = 0; i < numberOfRecords; i++){
            lstTargetSplitTemplate.add(new Target_Split_Template__c(Name = 'Test Target Split template' + i));
        }
        if(lstTargetSplitTemplate != null && lstTargetSplitTemplate.size() > 0 && shouldInsert)
            insert lstTargetSplitTemplate;        
        System.assertNotEquals(null,lstTargetSplitTemplate);
        return lstTargetSplitTemplate;
    }

    /**
     * createAccountSplit(List<Account>,List<Target_Split_Template__c>,Boolean)
     *
     * This method is called to create Account Splits for a test class.
     *  shouldInsert = to tell if records need to be inserted or need just instances (True => will insert records in DB).
     */
    public static List<Account_Split__c> createAccountSplit(List<Account> lstAccount, List<Target_Split_Template__c> lstTargetSplitTemplate, Integer numberOfSplitsPerTarget, boolean shouldInsert) {
        List<Account_Split__c> lstAccountSplits = new List<Account_Split__c>();
        if (numberOfSplitsPerTarget > lstAccount.size()) {
            return null;
        }
        for (Integer j = 0; j < lstTargetSplitTemplate.size(); j++) {
            for(Integer i = 0; i < numberOfSplitsPerTarget; i++){
                lstAccountSplits.add(new Account_Split__c(Account__c = lstAccount[i].Id, Target_Split_Template__c = lstTargetSplitTemplate[j].Id, Share__c = 10));
            }
        }
        if(lstAccountSplits != null && lstAccountSplits.size() > 0 && shouldInsert)
            insert lstAccountSplits;        
        System.assertNotEquals(null,lstAccountSplits);
        return lstAccountSplits;
    }
    
    /**
     * createCustSettingForAccount()
     * This method is called to create custom setting data for CRM_Account_Settings__c.
     */
    public static void createCustSettingForAccount(){
      List<CRM_Account_Settings__c> lstAccountSetting = new List<CRM_Account_Settings__c>();
        
        CRM_Account_Settings__c accountSetting0 = new CRM_Account_Settings__c();
        accountSetting0.Name = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        accountSetting0.Type__c = 'Physical';   
        accountSetting0.Sub_Type__c = 'Video_Physical__c,Games_Physical__c';
        accountSetting0.Value__c = true;
        lstAccountSetting.add(accountSetting0);

        CRM_Account_Settings__c accountSetting1 = new CRM_Account_Settings__c();
        accountSetting1.Name = CRM_AppConstants.TERRITORY_NETHERLAND_CODE;
        accountSetting1.Type__c = 'Physical';
        accountSetting1.Sub_Type__c = 'Video_Physical__c,Games_Physical__c';
        accountSetting1.Value__c = true;
        lstAccountSetting.add(accountSetting1);
        
        CRM_Account_Settings__c accountSetting2 = new CRM_Account_Settings__c();
        accountSetting2.Name = CRM_AppConstants.TERRITORY_BELGIUM_CODE;
        accountSetting2.Type__c = 'Physical';
        accountSetting2.Sub_Type__c = 'Video_Physical__c,Games_Physical__c';
        accountSetting2.Value__c = true;
        lstAccountSetting.add(accountSetting2); 
        
        CRM_Account_Settings__c accountSetting3 = new CRM_Account_Settings__c();
        accountSetting3.Name = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        accountSetting3.Type__c = 'Physical';
        accountSetting3.Sub_Type__c = 'Games_Physical__c,Music_Physical__c,Video_Physical__c';
        accountSetting3.Value__c = true;
        lstAccountSetting.add(accountSetting3);               
        
        CRM_Account_Settings__c accountSetting4 = new CRM_Account_Settings__c();
        accountSetting4.Name = CRM_AppConstants.TERRITORY_GERMANY_CODE;
        accountSetting4.Type__c = 'Physical';
        accountSetting4.Sub_Type__c = 'Games_Physical__c,Video_Physical__c';
        accountSetting4.Value__c = true;
        lstAccountSetting.add(accountSetting4);
        
        CRM_Account_Settings__c accountSetting5 = new CRM_Account_Settings__c();
        accountSetting5.Name = CRM_AppConstants.TERRITORY_ITALY_CODE;
        accountSetting5.Type__c = 'Physical';
        accountSetting5.Sub_Type__c = 'Games_Physical__c,Video_Physical__c';
        accountSetting5.Value__c = true;
        lstAccountSetting.add(accountSetting5);

        CRM_Account_Settings__c accountSetting6 = new CRM_Account_Settings__c();
        accountSetting6.Name = CRM_AppConstants.TERRITORY_SPAIN_CODE;
        accountSetting6.Type__c = 'Physical';
        accountSetting6.Sub_Type__c = 'Games_Physical__c,Video_Physical__c';
        accountSetting6.Value__c = true;
        lstAccountSetting.add(accountSetting6);

        CRM_Account_Settings__c accountSetting7 = new CRM_Account_Settings__c();
        accountSetting7.Name = CRM_AppConstants.TERRITORY_FINLAND_CODE;
        accountSetting7.Type__c = 'Physical';
        accountSetting7.Sub_Type__c = 'Games_Physical__c,Video_Physical__c';
        accountSetting7.Value__c = true;
        lstAccountSetting.add(accountSetting7);

        if(!lstAccountSetting.isEmpty()){
            insert lstAccountSetting;
        }
      }    

    public static List<Target__c> createProductTargets(List<Account> lstAccount, List<Product2> lstProduct, Boolean shouldInsert){

        List<Target__c> lstTargets = new List<Target__c>();
        for(Account account : lstAccount){
            for (Product2 product : lstProduct){
                    Target__c targetInstance = new Target__c(
                        Account__c = account.Id,
                        Product__c = product.Id,
                        StartDate__c = System.today(),
                        End_Date__c = System.today() + 56,
                        Approved__c = null,
                        Planned__c = null,
                        Confirmed__c = null,
                        Actual_Revenue__c = null,
                        High_Level__c = null,
                        Target__c = 50,
                        CurrencyIsoCode = 'USD',
                        RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_PRODUCT
                    );
 
                    lstTargets.add(targetInstance);
             }
        }
        if(shouldInsert){
            insert lstTargets;
            System.assertNotEquals(null,lstTargets);
        }
        return lstTargets;
    }
    
    public static List<Product2> createProducts(Integer numProducts, Boolean shouldInsert){
          List<Product2> lstProduct = new List<Product2>();
            for (Integer index = 0; index < numProducts; index++){
                Product2 objProduct = new Product2();                
                objProduct.Name = 'Product ' + (index + 1);                
        objProduct.IsActive = True;
        objProduct.CurrencyIsoCode = 'USD';
        objProduct.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
        objProduct.nr_period_weeks__c = 8;
        objProduct.product_format__c = 'SD';
        objProduct.product_genre__c = 'Action';
        objProduct.product_language_code__c = 'EN';
        objProduct.product_market__c = 'EST';
        objProduct.street_date__c = System.today()-40;
                lstProduct.add(objProduct);
            }
        
        if (shouldInsert && lstProduct != null && lstProduct.size() > 0) 
            insert lstProduct;
        return lstProduct;
    }
    
    public static List<Pricebook2> createPricebooks(Integer numPBs, Boolean shouldInsert) {
      List <Pricebook2> lstPB  = new List <Pricebook2>();
      for(Integer index = 0; index < numPBs; index++){                         
                Pricebook2  pb = new Pricebook2();
        pb.Name = 'PB'+(index + 1);
                pb.Business_Unit__c = '2500';
        pb.Country__c = '435';
        pb.CurrencyIsoCode = 'USD';
        pb.Description = 'Price book';
        pb.External_Id__c = pb.Name;
        pb.IsActive = True;
        pb.Product_Type__c = 'Digital';
        
        lstPB.add(pb);
            }
        
        if (shouldInsert && lstPB != null && lstPB.size() > 0) 
            insert lstPB;
        return lstPB;
    } 
    
    public static List<Pricebook_Entry_Period__c> createPriceBookEntryPeriods(List<Product2> lstProduct, Pricebook2 pricebook, Date startDate, Date endDate, Double price){
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = new List<Pricebook_Entry_Period__c>();
        Date dtTodayDate = Date.today();
        
        for(Product2 objProduct : lstProduct){
          Pricebook_Entry_Period__c objPriceBookEntryProduct = new Pricebook_Entry_Period__c();
      objPriceBookEntryProduct.Product__c = objProduct.Id;
            objPriceBookEntryProduct.Price_Book__c = pricebook.Id;
            objPriceBookEntryProduct.Start_Date__c = startDate;
            objPriceBookEntryProduct.End_Date__c = endDate;
            objPriceBookEntryProduct.Account_Price__c = price;
            objPriceBookEntryProduct.CurrencyISOCode ='USD';
            lstPriceBookEntryPeriod.add(objPriceBookEntryProduct);
        }
        return lstPriceBookEntryPeriod;
    } 
    
     public static List<PricebookEntry> createPriceBookEntriesStandard(List<Product2> lstProduct, Integer numPBEntriesPerProduct, Boolean shouldInsert){
        List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
        //Id standardPricebookId = System.Test.getStandardPricebookId();     
        
        for(Integer nProductCount = 0; nProductCount < lstProduct.size(); nProductCount++){         
            if (numPBEntriesPerProduct == null)
                numPBEntriesPerProduct = 1;
                
            for (Integer oppCount = 0; oppCount < numPBEntriesPerProduct; oppCount++) {
                PricebookEntry objPriceBookEntry = new PricebookEntry();
                //objPriceBookEntry.UseStandardPrice = false;
                objPriceBookEntry.UnitPrice = 10.00 * (oppCount + 1);
                objPriceBookEntry.CurrencyIsoCode = lstProduct[nProductCount].CurrencyIsoCode;
                objPriceBookEntry.Product2Id = lstProduct[nProductCount].Id;                
                objPriceBookEntry.IsActive = true;
                objPriceBookEntry.Pricebook2Id = standardPricebookId;
                lstPricebookEntry.add(objPriceBookEntry);
            }
        }

        if (shouldInsert && lstPricebookEntry != null && lstPricebookEntry.size() > 0)
            insert lstPricebookEntry;
            System.assertNotEquals(null,lstPricebookEntry);
        
        return lstPricebookEntry;
    }
    
    public static User createUser(String profileName, Boolean bypassValRules){
        Profile pf= [Select Id from profile where Name=:profileName]; 
        
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id, 
                         ByPassValidationRule__c = bypassValRules);
        return uu;
    }
}