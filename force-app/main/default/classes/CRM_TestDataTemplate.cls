public with sharing class CRM_TestDataTemplate {
    
    public static List<Account> createAccounts(Integer numAccts,Boolean shouldInsert) {
        System.debug('##### INSIDE createAccounts');
        List<Account> lstAccounts = new List<Account>();
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sold To').getRecordTypeId();
        Id standardPricebookId = System.Test.getStandardPricebookId();
        for(Integer accCount = 0; accCount < numAccts; accCount++)
            lstAccounts.add(new Account(Name ='TestAccount ' + accCount, Price_Book__c = standardPricebookId,RecordTypeId = RecordTypeId, Status__c = 'N',Planning_Customer__c = true));
        
        System.debug('$#$#$#$#$ lstAccounts: ' + lstAccounts);
        System.debug('$%$%$%$%$%$ shouldInsert:' + shouldInsert);
        
        if(lstAccounts != null && lstAccounts.size() > 0 && shouldInsert){
            System.debug('Inserting the Account: ' + lstAccounts.size());
            insert lstAccounts;
        }
        return lstAccounts;
    }

    public static List<File_Discount__c> createFileDiscounts(List<Account> lstAccount,Date startDate,Date endDate,String fdFormat,String fdType,Double fdDiscountPercent,Integer numFileDiscountsPerAccount,Boolean shouldInsert){
        List<File_Discount__c> lstFileDiscount = new List<File_Discount__c>();
        Date dtTodayDate = Date.today();
        
        for(Account acct : lstAccount){
            for (Integer nFileDiscPerAcct = 0; nFileDiscPerAcct < numFileDiscountsPerAccount; nFileDiscPerAcct ++){
                File_Discount__c objFileDiscount = new File_Discount__c();
                objFileDiscount.Customer__c = acct.Id;
                objFileDiscount.Discount_Percent__c = 3;
                objFileDiscount.Start_Date__c = startDate;
                objFileDiscount.End_Date__c = endDate;
                objFileDiscount.Format__c = fdFormat;
                objFileDiscount.Product_Type__c = fdType;
                lstFileDiscount.add(objFileDiscount);
            }
        }
        
        if (shouldInsert && lstFileDiscount != null && lstFileDiscount.size() > 0)
            insert lstFileDiscount;
        
        return lstFileDiscount;
    }   
    
    public static List<Product_Group__c> createProductGroups(Integer numProductGroups, Boolean shouldInsert){
        
        List<Product_Group__c> lstProductGroup = new List<Product_Group__c>(); 
                
        for(Integer nPG = 0; nPG < numProductGroups; nPG++){
            Product_Group__c objProductGroup = new Product_Group__c();
            
            objProductGroup.name = 'Digital - Games - PS4';
            objProductGroup.External_Id__c = 'UK_Digital_Games_PS4_Target_Test_' + nPG;
            //objProductGroup.Type__c = 'Digital';
            //objProductGroup.Release_Category__c = 'Catalog'; 
            objProductGroup.Franchise_Type__c = 'Games';
            objProductGroup.CurrencyIsoCode = 'USD';
            lstProductGroup.add(objProductGroup);
        }
        
        if (shouldInsert && lstProductGroup != null && lstProductGroup.size() > 0)
            insert lstProductGroup;         
        
        return lstProductGroup;
    }
    
    //Create Deal Product Group
    public static List<Deal_product_group__c> createDealProductGroups(List<Opportunity> lstDeals, List<Product_Group__c> lstProductGroup,Boolean shouldInsert) {
        
        List<Deal_product_group__c> lstDealProductGroup = new List<Deal_product_group__c>();
        
        for (Opportunity deal : lstDeals){
            for(Integer index = 0; index < lstProductGroup.size(); index++){
                lstDealProductGroup.add(new Deal_product_group__c(
                    CurrencyIsoCode = 'USD',
                    Opportunity__c = deal.Id,
                    Product_Group__c = lstProductGroup[index].Id,
                    Revenue__c = 547800));
            }
        }
        if(shouldInsert){
            System.debug('@@@@@@@@@ INSERTING lstDealProductGroup');
            insert lstDealProductGroup;
        }
        return lstDealProductGroup;
        
    }
    
    public static List<Target__c> createProductGroupTargets1(List<Account> lstAccount,List<Product_Group__c> lstProductGroup,Id RecordtypeId,Boolean shouldInsert){
        
        List<Target__c> lstTargets = new List<Target__c>();
        
        /*New Changes for Account Plan*/
        Date d = system.today();
        List<Product2> lstProduct = createProducts(lstProductGroup, d , d , 1, true);
        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_TestDataFactory.createAccountPlan(lstCountryPlan, lstAccount, true);
        /*New Changes for Account Plan*/
        
        for(Account account : lstAccount){
            for (Product_Group__c productGroup : lstProductGroup){
                    lstTargets.add(new Target__c(
                                        Account__c = account.Id,
                                        RecordTypeId = CRM_RecordTypeUtil.RT_TARGET_GROUP,
                                        Product_Group__c = productGroup.Id,
                                        StartDate__c = System.Today().addMonths((Integer)(0 - TargetLimitter__c.getOrgDefaults().PeriodForEligibleTargets__c)),
                                        //StartDate__c = date.newInstance(2016,01,01),
                                        End_Date__c = date.newInstance(2025,01,01),
                                        CurrencyIsoCode = 'USD',
                                        Account_Plan_Lookup__c = lstAccountPlan[0].id));
      }
        }
        if(shouldInsert){
            insert lstTargets;
        }
        return lstTargets;
    }      
    
    public static List<Product2> createProducts(List<Product_Group__c> lstProductGroup, Date newReleaseEndDate,Date streetDate,Integer numProducts,Boolean shouldInsert){
        List<Product2> lstProduct = new List<Product2>();

        if(numProducts == null)
            numProducts = 1;
        for (Product_Group__c objPG : lstProductGroup){
            for (Integer nProductPerLocalDataCount = 0; nProductPerLocalDataCount < numProducts; nProductPerLocalDataCount++){
                Product2 objProduct = new Product2();           
                objProduct.Product_Format__c = 'VOD TV Mobile';
                //objProduct.Type ='Games Digital';            
                objProduct.Name = 'PR ' + nProductPerLocalDataCount + Math.random();
                objProduct.NR_period_weeks__c = 5;
                objProduct.Street_Date__c = streetDate;
                //objProduct.Items_in_Stock__c = 100;         
                objProduct.Product_Group__c = objPG.Id;  
                objProduct.Delivery_Lead_Days__c = 4;
                objProduct.IsActive = true;
                objProduct.recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
                objProduct.CanUseQuantitySchedule = true;
                objProduct.CanUseRevenueSchedule = true;
                //objProduct.New_Release_End_date__c=newReleaseEndDate;
                lstProduct.add(objProduct);
            }
        
        }
        if (shouldInsert && lstProduct != null && lstProduct.size() > 0)
            insert lstProduct;
            
        return lstProduct;
    } 
    
    public static List<PricebookEntry> createPriceBookEntries(List<Product2> lstProduct, Integer numPBEntriesPerProduct, Boolean shouldInsert){
        List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
        Id standardPricebookId = System.Test.getStandardPricebookId();     
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
        return lstPricebookEntry;
    }
    
        public static List<Pricebook_Entry_Period__c> createPriceBookEntryPeriods(List<Product2> lstProduct,Date startDate,Date endDate,Integer listPrice,Integer numPriceBookEntriesPerProduct, Boolean NewRelease, Boolean shouldInsert){
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = new List<Pricebook_Entry_Period__c>();
        Date dtTodayDate = Date.today();
       
        for(Product2 objProduct : lstProduct){
            for(Integer nPriceBookEntryPerProduct = 0; nPriceBookEntryPerProduct < numPriceBookEntriesPerProduct; nPriceBookEntryPerProduct++){
                Pricebook_Entry_Period__c objPriceBookEntryProduct = new Pricebook_Entry_Period__c();
                    objPriceBookEntryProduct.List_Price__c = listPrice;
                    objPriceBookEntryProduct.Start_Date__c = startDate;
                    objPriceBookEntryProduct.End_Date__c = endDate;
                    objPriceBookEntryProduct.CurrencyISOCode = 'USD';
                    objPriceBookEntryProduct.Price_Book__c = System.Test.getStandardPricebookId();
                    objPriceBookEntryProduct.Product__c =lstProduct[0].Id;
                    objPriceBookEntryProduct.New_Release__c = NewRelease;
                lstPriceBookEntryPeriod.add(objPriceBookEntryProduct);
            }           
        }
        
        if (shouldInsert && lstPriceBookEntryPeriod != null && lstPriceBookEntryPeriod.size() > 0)
            insert lstPriceBookEntryPeriod;

        return lstPriceBookEntryPeriod;
    }
    
    /**
     * createOpportunitiesWithAccounts(List<Account>, Integer, Boolean)
     *
     * This method is called to create opportunities for a test class.
     *  lstAccounts = list of accounts for which opporunities need to created
     *  numOppsPerAcct = number of opportunity records to be created for each account
     *  shouldInsert = to tell if records need to be inserted or need just instances (True => will insert records in DB).
     */
    public static List<Opportunity> createDealsWithAccounts(List<Account> lstAccounts, String ForecastCategory ,Date Startdate, Date closeDate,Id dealRecordTypeId,Integer numOppsPerAcct, Boolean shouldInsert) {
        List<Opportunity> opps = new List<Opportunity>();
        Id standardPricebookId = System.Test.getStandardPricebookId();        
        for (Integer accCount = 0; accCount < lstAccounts.size(); accCount++) {

            for (Integer oppCount = 0; oppCount < numOppsPerAcct; oppCount++) {
                opps.add(new Opportunity(Name = ' Opportunity ' + Math.random() + oppCount, CurrencyISOCode = 'USD',
                                        RecordTypeId =dealRecordTypeId,
                                        StageName = 'Planned',
                                        CloseDate = closeDate,
                                        AccountId = lstAccounts[accCount].Id,
                                        Pricebook2Id = standardPricebookId,
                                        Start_Date__c = Startdate,
                                        ForecastCategoryName = ForecastCategory));
            }
        }
        
        if(shouldInsert && opps != null && opps.size() > 0)
            insert opps;
        
        return opps;
    }
    
    /**
     * createOpportunitiesLineItems
     *
     * This method is called to create opportunities for a test class.
     *  lstAccounts = list of accounts for which opporunities need to created
     *  numOppsPerAcct = number of opportunity records to be created for each account
     *  shouldInsert = to tell if records need to be inserted or need just instances (True => will insert records in DB).
     */
    
    public static List<OpportunityLineItem> createDealProductsWithOpportunities(List<PricebookEntry> lstPriceBookEntry, List<Opportunity> lstDeals,Double Returnscost, Integer numOppsPerDealProduct, Boolean shouldInsert){
        
        List<OpportunityLineItem> lstDealProduct = new List<OpportunityLineItem>();
        ID idPriceBookEntry;
        if (lstPriceBookEntry != null && lstPriceBookEntry.size() > 0){
            for (Integer nDealProdCount = 0; nDealProdCount < lstDeals.size(); nDealProdCount ++){
                for(Integer oppCount = 0; oppCount < numOppsPerDealProduct; oppCount++){
                  
                OpportunityLineItem objDealProduct = new OpportunityLineItem();
                objDealProduct.OpportunityId = lstDeals[nDealProdCount].Id;
                    
                if (lstPriceBookEntry.size() >= (nDealProdCount + 1))
                    idPriceBookEntry = lstPriceBookEntry[nDealProdCount].Id;
                      
                objDealProduct.PricebookEntryId = idPriceBookEntry;
                objDealProduct.Quantity = 10;
                objDealProduct.UnitPrice = 14.10;
                objDealProduct.Initial_Quantity__c = 5;
                objDealProduct.Replen_Quantity__c  = 5;
                objDealProduct.Returns__c=Returnscost;
                objDealProduct.Manually_Schedule__c = true;
                lstDealProduct.add(objDealProduct);
                }
            }
        }
        
        if (lstDealProduct != null && lstDealProduct.size() > 0 && shouldInsert){
            insert lstDealProduct;
        }
        
        return lstDealProduct;        
    }
    
     public static List<OpportunityLineItemSchedule> createDealsSchedule(List<OpportunityLineItem> lstDealProducts,Integer scheduleQuantity,String scheduleType,Date scheduleDate,Double scheduleRevenue,Integer noOfRecords, Boolean shouldInsert){
        List<OpportunityLineItemSchedule> schedules = new List<OpportunityLineItemSchedule>();
        
        for (OpportunityLineItem currentDealProduct : lstDealProducts) {    
            
            for (Integer index = 0; index < noOfRecords; index++) {
                
                schedules.add(
                    new OpportunityLineItemSchedule(
                        OpportunityLineItemId = currentDealProduct.ID,
                        Quantity = scheduleQuantity,
                        ScheduleDate = scheduleDate,
                        Type = scheduleType,
                        Revenue =scheduleRevenue
                    )
                );          
            }            
        }
        
        if(shouldInsert)
            insert schedules;
        
        return schedules;
    }
    
    public static List<Bundle__c> createBundles(Integer noOfRecords, Boolean shouldInsert){
        List<Bundle__c> bundles = new List<Bundle__c>();
        
        for(Integer index = 0; index < noOfRecords; index++){
            Bundle__c currentBundle = new Bundle__c();
            currentBundle.Start_Date__c = Date.today();
            currentBundle.Price_Book__c = System.Test.getStandardPricebookId();
            currentBundle.End_Date__c = System.today() + 30;
                
            bundles.add(currentBundle);
        }        
        
        if (shouldInsert)
            insert bundles;
            
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
            
        return bundleProducts;
    } 

    public static List<Target__c> createProductTargets(List<Account> lstAccount,List<Product2> lstProduct,Id RecordtypeId,Boolean shouldInsert){                
        
        List<Target__c> lstTargets = new List<Target__c>();
        /*New Changes for Account Plan*/
        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_TestDataFactory.createAccountPlan(lstCountryPlan, lstAccount, true);
        
        System.debug('+++++ lstAccount.size(): ' + lstAccount.size());
        System.debug('+++++ lstProduct.size(): ' + lstProduct.size());
        System.debug('+++++ Already Existing: ' + [SELECT COUNT(Id) FROM Target__c].size());
        /*New Changes for Account Plan*/        
        for(Account account : lstAccount){
                for(Integer index = 0; index < lstProduct.size(); index++){
                    lstTargets.add(new Target__c(
                                        Account__c = account.Id,
                                        RecordTypeId = RecordtypeId,
                                        Product__c = lstProduct[index].Id,
                                        CurrencyIsoCode = 'USD',
                                        Account_Plan_Lookup__c = lstAccountPlan[0].id));
                }
        }
        if(shouldInsert){
            insert lstTargets;
        }
        return lstTargets;
    }
    
    public static List<Target__c> createProductGroupTargets(List<Account> lstAccount,List<Product_Group__c> lstProductGroup,Id RecordtypeId,Boolean shouldInsert){
        
        List<Target__c> lstTargets = new List<Target__c>();
        for(Account account : lstAccount){
            for (Product_Group__c productGroup : lstProductGroup){
                    lstTargets.add(new Target__c(
                                        Account__c = account.Id,
                                        RecordTypeId = RecordtypeId,
                                        Product_Group__c = productGroup.Id,
                                        StartDate__c = System.today(),
                                        End_Date__c = System.today() + 56,
                                        CurrencyIsoCode = 'USD'));
            }
        }
        if(shouldInsert){
            insert lstTargets;
        }
        return lstTargets;
    }
    
    public static List<Target__c> createBundleTargets(List<Account> lstAccount,List<Bundle__c> lstBundle,Id RecordtypeId,Boolean shouldInsert){
        
        /*New Changes for Account Plan*/
        Date d = system.today();
        List<Product_Group__c> lstProductGroup= CRM_TestDataFactory.createProductGroups(1,false);
        List<Product2> lstProduct = createProducts(lstProductGroup, d , d , 1, true);
        List<Country_Plan__c> lstCountryPlan = CRM_TestDataFactory.createCountryPlanNewRelease(1,lstProduct, true);
        List<Account_Plan__c> lstAccountPlan = CRM_TestDataFactory.createAccountPlan(lstCountryPlan, lstAccount, true);
        /*New Changes for Account Plan*/
        
        List<Target__c> lstTargets = new List<Target__c>();
        for(Account account : lstAccount){
            for (Bundle__c bundle : lstBundle){
                    lstTargets.add(new Target__c(
                                        Account__c = account.Id,
                                        RecordTypeId = RecordtypeId,
                                        Bundle__c = bundle.Id,
                                        CurrencyIsoCode = 'USD',
                                        Account_Plan_Lookup__c = lstAccountPlan[0].id));
            }
        }
        if(shouldInsert){
            insert lstTargets;
        }
        return lstTargets;
    }
    
    public static List<Agreement__c> createStoreFront(List<Account> lstAccount, List<Country__c> lstCountries, boolean shouldInsert){
        List<Agreement__c> lstStoreFront = new List<Agreement__c>();

        for (Integer nAcct = 0; nAcct < lstAccount.size(); nAcct++){
            Account acct = lstAccount[nAcct];
            //Agreement__c objStoreFront = new Agreement__c();
            //objStoreFront.Account__c = acct.Id;
            //objStoreFront.CRM_Account__c = acct.Id;
            
            
                        
            lstStoreFront.add(new Agreement__c(Account__c = acct.Id, Pricing_Currency__c = 'USD',WSP_Currency__c='USD', CRM_Account__c = acct.Id, Country__c = lstCountries[nAcct].Id));
        }
        if (lstStoreFront != null && lstStoreFront.size() > 0 && shouldInsert){
            insert lstStoreFront;
        }
        
        return lstStoreFront;
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
            
        return lstCountry;
    }    
    
    
}