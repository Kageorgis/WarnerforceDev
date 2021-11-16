@isTest
private class CRM_MassUpdateNRDealProductCtrl_Test {
    static Opportunity deal;
    
    static void testDataMethod(){
    
        list<Account> accounts = CRM_TestDataFactory.createAccounts(2, true);
        for(Account a:accounts)
            a.Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        update accounts;
        system.assertEquals(2,accounts.size());
        
        list<Opportunity> opps = CRM_TestDataFactory.createOpportunitiesWithAccounts(accounts, 2, true);
        system.assertEquals(4,opps.size());
        
        deal = opps[0];
        List<Product_Group__c> pgs = CRM_TestDataFactory.createProductGroups(1, true);
        //List<Product2> products = CRM_TestDataFactory.createProducts(pgs, 2, true);
        List<Product2> products = CRM_AutoPhysicalNRDealCreateService_Test.createProductsForNRBatch(pgs,accounts);
        for(Integer i=0;i<products.size();i++){
            products[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_UK_CODE;
            products[i].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            products[i].street_Date__c = system.today()+30;
            products[i].ProductCode = 'PR10000'+i;
            system.debug('product values --->'+products[i]);
            system.debug('recordtype --->'+products[i].recordTypeId);
        }
        update products;    
        system.assertEquals(2,products.size());
        List<PricebookEntry> pbEntries = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryForNRBatch(products);
        system.assertEquals(2,pbEntries.size());
        List<Pricebook_Entry_Period__c> pbep = CRM_AutoPhysicalNRDealCreateService_Test.createPriceBookEntryPeriodForNRBatch(pbEntries, products);
        for(Pricebook_Entry_Period__c pb:pbep){
            pb.New_Release__c  = true;
        }
        update pbep;
        system.assertEquals(2,pbep.size());
        List<OpportunityLineItem> dealproducts = CRM_TestDataFactory.createDealProductsWithOpportunities(pbEntries, opps, 2, true);
        
        CRM_Functional_Permissions__c functionalPermission = new CRM_Functional_Permissions__c();
        functionalPermission.NRMassUpdateTerritoryCode__c ='UK';
        insert functionalPermission;
        
        CRM_Profile_Based_Country_Identification__c profileBasedIdentification = new  CRM_Profile_Based_Country_Identification__c();
        profileBasedIdentification.Country_Code__c ='UK';
        profileBasedIdentification.Name ='UK';
        profileBasedIdentification.Digital_Country_Code__c ='975,80';
        profileBasedIdentification.Sales_Orgs__c ='6000';
        profileBasedIdentification.Product_Country_Code__c ='GB,IE';
        insert profileBasedIdentification;
        
        system.assertEquals(8,dealproducts.size());
    }
      static testMethod void unitTestGetLineItems_660() {
        testDataMethod();
        
        User testUser = [Select Id ,name from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        //US660 Add Account Owner filter
        list<Account> accounts =[SELECT OWNERId,OWNER.Name,Owner_Games__c,Owner_Games__r.name FROM Account ];
        User useracc=createUser();
        
            accounts[0].OwnerId = testUser.Id ;
            accounts[0].Owner_games__c = useracc.Id ;
            accounts[1].OwnerId = useracc.Id ;
            accounts[1].Owner_games__c = useracc.Id ;
          
         update accounts;
        
        System.runAs(testUser){ 
        PageReference pageRef = Page.CRM_MassUpdateNRDealProduct;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(deal);
        CRM_MassUpdateNRDealProductCtrl ctrl = new CRM_MassUpdateNRDealProductCtrl(sc);
        
        ctrl.getUserLocale();
        
         
        List<CRM_MassUpdateNRDealProductCtrl.OpportunityLineItemWrapper> wrapperClassObj = new List<CRM_MassUpdateNRDealProductCtrl.OpportunityLineItemWrapper>();
        CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
        searchFilter.text = 'PR100001';
        searchFilter.streetDateFrom = system.today();
        searchFilter.streetDateTo = system.today()+35;
        
        List<Id> fixedSearchResults = new List<Id>();
        for(Product2 prod : [select Id from Product2]){
            fixedSearchResults.add(prod.Id);
        }

        Test.setFixedSearchResults(fixedSearchResults);
        //US660
        CRM_MassUpdateNRDealProductCtrl.FilterWrapper filter =new CRM_MassUpdateNRDealProductCtrl.FilterWrapper();
        filter.accOwnerEntered =new CRM_DataObjects.PicklistOption[]{};
        
        wrapperClassObj = CRM_MassUpdateNRDealProductCtrl.getOpportunityLineItems(searchFilter,'Product',null,filter);
        system.assertEquals(4,wrapperClassObj.size());
        
        filter.accOwnerEntered =new CRM_DataObjects.PicklistOption[]{};
        filter.accOwnerEntered.add(new CRM_DataObjects.PicklistOption('myAccount' +'','My Account'));
        wrapperClassObj = CRM_MassUpdateNRDealProductCtrl.getOpportunityLineItems(searchFilter,'Product',null,filter);
        system.assertEquals(2,wrapperClassObj.size());
        
        filter.accOwnerEntered =new CRM_DataObjects.PicklistOption[]{};
        filter.accOwnerEntered.add(new CRM_DataObjects.PicklistOption('allAccount' +'','All Accounts'));
        wrapperClassObj = CRM_MassUpdateNRDealProductCtrl.getOpportunityLineItems(searchFilter,'Product',null,filter);
        system.assertEquals(4,wrapperClassObj.size());
        system.debug('wrapper class --->'+wrapperClassObj.size());
        
        
        }
    }
    
    static testMethod void unitTestGetLineItems() {
        testDataMethod();
        
        User testUser = [Select Id ,name from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        //US660 Add Account Owner filter
       //US660 Add Account Owner filter
        list<Account> accounts =[SELECT OWNERId,OWNER.Name,Owner_Games__c,Owner_Games__r.name FROM Account ];
        for(Account a:accounts){
            a.OwnerId = testUser.id;
            a.Owner_games__c = testUser.Id;
         }
         update accounts;
        
        System.runAs(testUser){ 
        PageReference pageRef = Page.CRM_MassUpdateNRDealProduct;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(deal);
        CRM_MassUpdateNRDealProductCtrl ctrl = new CRM_MassUpdateNRDealProductCtrl(sc);
        
        ctrl.getUserLocale();
        //US660 
        CRM_MassUpdateNRDealProductCtrl.FilterWrapper filter =new CRM_MassUpdateNRDealProductCtrl.FilterWrapper();
        filter.accOwnerEntered =new CRM_DataObjects.PicklistOption[]{};
        filter.accOwnerEntered.add(new CRM_DataObjects.PicklistOption(testUser.Id +'',testUser.Name+' Games & Video'));
        
        List<CRM_MassUpdateNRDealProductCtrl.OpportunityLineItemWrapper> wrapperClassObj = new List<CRM_MassUpdateNRDealProductCtrl.OpportunityLineItemWrapper>();
        CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
        searchFilter.text = 'PR100001';
        searchFilter.streetDateFrom = system.today();
        searchFilter.streetDateTo = system.today()+35;
        
        List<Id> fixedSearchResults = new List<Id>();
        for(Product2 prod : [select Id from Product2]){
            fixedSearchResults.add(prod.Id);
        }

        Test.setFixedSearchResults(fixedSearchResults);
        
        wrapperClassObj = CRM_MassUpdateNRDealProductCtrl.getOpportunityLineItems(searchFilter,'Product',null,filter);
        system.debug('wrapper class --->'+wrapperClassObj.size());
        system.assertEquals(4,wrapperClassObj.size());
        
        }
    }
     static User createUser(){
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());
        
        Date d = System.today();
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = String.valueOf(d).substring(0,8) + 'abc@test.com',
            Email = 'abc@test.com',
            Alias = String.valueOf(d).substring(0,8),
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
    static testMethod void unitTestGetLineItemsWithStreetDateFilter() {
        testDataMethod();
        User testUser = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        //US660 Add Account Owner filter
        list<Account> accounts =[SELECT OWNERId,OWNER.Name,Owner_Games__c,Owner_Games__r.name FROM Account ];
        for(Account a:accounts){
            a.OwnerId = testUser.id;
            a.Owner_games__c = testUser.Id;
         }
         update accounts;
        System.runAs(testUser){ 
        PageReference pageRef = Page.CRM_MassUpdateNRDealProduct;
        Test.setCurrentPage(pageRef);
       
        ApexPages.StandardController sc = new ApexPages.StandardController(deal);
        CRM_MassUpdateNRDealProductCtrl ctrl = new CRM_MassUpdateNRDealProductCtrl(sc);
        
        ctrl.getUserLocale();

        List<CRM_MassUpdateNRDealProductCtrl.OpportunityLineItemWrapper> wrapperClassObj = new List<CRM_MassUpdateNRDealProductCtrl.OpportunityLineItemWrapper>();
        CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
        searchFilter.text = 'PR100001';
        searchFilter.streetDateFrom = system.today();
        searchFilter.streetDateTo = system.today()+35;
         //US660
        CRM_MassUpdateNRDealProductCtrl.FilterWrapper filter =new CRM_MassUpdateNRDealProductCtrl.FilterWrapper();
        filter.accOwnerEntered =new CRM_DataObjects.PicklistOption[]{};
        filter.accOwnerEntered.add(new CRM_DataObjects.PicklistOption(accounts[0].OwnerId +'',accounts[0].Owner.Name+' Games & Video'));
        List<Id> fixedSearchResults = new List<Id>();
        for(Product2 prod : [select Id,RecordtypeId from Product2]){
            fixedSearchResults.add(prod.Id);
            system.debug('record type of product from query --> '+prod.RecordtypeId);
        }               
        Test.setFixedSearchResults(fixedSearchResults);
            
            List<OpportunityLineItem> op = [SELECT Name,Promoted_Price__c,Account_Price__c,Material_Street_Date__c,Opportunity.RecordTypeId, Opportunity.Account.Name,Initial_Quantity__c,product2.Street_Date__c,Opportunity.Account_Number__c,Product2.External_Id__c, product2.ProductCode,Target_Quantity__c,product2.Universal_Picture_Code__c,Opportunity.AccountId, Replen_Quantity__c,Actual_Quantity__c,Product2.Name,ProductCode,Opportunity.Deal_Code__c FROM OpportunityLineItem where NR__c = true AND Product2.RecordtypeId ='012U0000000QukqIAC' AND product2.Street_Date__c >= 2017-04-06 AND product2.Street_Date__c <= 2017-05-11 AND Product2Id IN :fixedSearchResults order by Opportunity.Account.Name asc LIMIT 10000];
            system.debug('debug from test after query -->'+op);
            
        wrapperClassObj = CRM_MassUpdateNRDealProductCtrl.getOpportunityLineItems(searchFilter,'Product','Digital',filter);
        system.assertEquals(4,wrapperClassObj.size());
    } 
    } 
    static testMethod void unitTestSetLineItems() {
        testDataMethod();
        User testUser = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        //US660 Add Account Owner filter
        list<Account> accounts =[SELECT OWNERId,OWNER.Name,Owner_Games__c,Owner_Games__r.name FROM Account ];
        for(Account a:accounts){
            a.OwnerId = testUser.id;
            a.Owner_games__c = testUser.Id;
         }
         update accounts;
        System.runAs(testUser){ 
        PageReference pageRef = Page.CRM_MassUpdateNRDealProduct;
        Test.setCurrentPage(pageRef);
        
        //List<OpportunityLineItem> dealproductrecords = [select Id,NR__c,Opportunity.Sales_Organisation__c,Promoted_Price__c from OpportunityLineItem];
        
        CRM_MassUpdateNRDealProductCtrl.OpportunityLineItemWrapper wrapper = new CRM_MassUpdateNRDealProductCtrl.OpportunityLineItemWrapper();
        List<CRM_MassUpdateNRDealProductCtrl.OpportunityLineItemWrapper> wrapperClassObj = new List<CRM_MassUpdateNRDealProductCtrl.OpportunityLineItemWrapper>();
         //US660
        CRM_MassUpdateNRDealProductCtrl.FilterWrapper filter =new CRM_MassUpdateNRDealProductCtrl.FilterWrapper();
        filter.accOwnerEntered =new CRM_DataObjects.PicklistOption[]{};
        filter.accOwnerEntered.add(new CRM_DataObjects.PicklistOption(accounts[0].OwnerId +'',accounts[0].Owner.Name+' Games & Video'));
        CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
        searchFilter.text = 'PR100001';
        searchFilter.streetDateFrom = system.today();
        searchFilter.streetDateTo = system.today()+35;
         
        List<Id> fixedSearchResults = new List<Id>();
        for(Product2 prod : [select Id,recordTypeId from Product2]){
            fixedSearchResults.add(prod.Id);
            
        }

        Test.setFixedSearchResults(fixedSearchResults);
        
        wrapperClassObj = CRM_MassUpdateNRDealProductCtrl.getOpportunityLineItems(searchFilter,'Product',null,filter);
        
        wrapper.lineItemRecord = wrapperClassObj[0].lineItemRecord;
            //wrapper.lineItemRecord.Promoted_Price__c = 12.33;
            wrapper.lineItemRecord.Replen_Quantity__c = 2;
        wrapper.isRowModified=true;
        wrapperClassObj.add(wrapper);
        list<CRM_MassUpdateNRDealProductCtrl.OpportunityLineItemWrapper> savedlineItems = new list<CRM_MassUpdateNRDealProductCtrl.OpportunityLineItemWrapper>();               
        if(wrapperClassObj != null){
        savedlineItems = CRM_MassUpdateNRDealProductCtrl.setOpportunityLineItems(wrapperClassObj);
        system.debug('saved items -->'+savedlineItems);
        }
        system.assertEquals(Label.CRM_Upload_Message_Updated,savedlineItems[savedlineItems.size()-1].validation);
    } 
    } 
    static testMethod void unitTestGetLineItemsByAccount() {
        testDataMethod();
        User testUser = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        //US660 Add Account Owner filter
        list<Account> accounts =[SELECT OWNERId,OWNER.Name,Owner_Games__c,Owner_Games__r.name FROM Account ];
        for(Account a:accounts){
            a.OwnerId = testUser.id;
            a.Owner_games__c = testUser.Id;
         }
         update accounts;
        System.runAs(testUser){ 
        PageReference pageRef = Page.CRM_MassUpdateNRDealProduct;
        Test.setCurrentPage(pageRef);
        List<Opportunity> op =[select Id , Account.Name from Opportunity];
        for(Opportunity d : op)
            system.debug('Account records associated with deal--'+d.Account.Name);
        List<Account> ac = [select ID,Name from Account];
        system.debug('Accounts ------------>'+ac);
        List<OpportunityLineItem> dealproductrecords = [select Id,NR__c,Opportunity.Sales_Organisation__c,Opportunity.Account.Name from OpportunityLineItem];
        system.debug('deal product records-->'+dealproductrecords);
        ApexPages.StandardController sc = new ApexPages.StandardController(deal);
        CRM_MassUpdateNRDealProductCtrl ctrl = new CRM_MassUpdateNRDealProductCtrl(sc);
         //US660
        CRM_MassUpdateNRDealProductCtrl.FilterWrapper filter =new CRM_MassUpdateNRDealProductCtrl.FilterWrapper();
        filter.accOwnerEntered =new CRM_DataObjects.PicklistOption[]{};
        filter.accOwnerEntered.add(new CRM_DataObjects.PicklistOption(accounts[0].OwnerId +'',accounts[0].Owner.Name+' Games & Video'));
        ctrl.getUserLocale();

        List<CRM_MassUpdateNRDealProductCtrl.OpportunityLineItemWrapper> wrapperClassObj = new List<CRM_MassUpdateNRDealProductCtrl.OpportunityLineItemWrapper>();
        CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
        searchFilter.text = 'TestAccount 0';
        searchFilter.streetDateFrom = system.today();
        searchFilter.streetDateTo = system.today()+35;
        
        List<Id> fixedSearchResults = new List<Id>();
        for(Account prod : [select Id from Account]){
            fixedSearchResults.add(prod.Id);
        }

        Test.setFixedSearchResults(fixedSearchResults);
        
        wrapperClassObj = CRM_MassUpdateNRDealProductCtrl.getOpportunityLineItems(searchFilter,'Account','Physical',filter);
        system.assertEquals(2,wrapperClassObj.size());
    }
    }
    static testMethod void unitTestSetLineItemsWithZeroInitalQuantity() {
        testDataMethod();
        User testUser = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
         //US660 Add Account Owner filter
        list<Account> accounts =[SELECT OWNERId,OWNER.Name,Owner_Games__c,Owner_Games__r.name FROM Account ];
        for(Account a:accounts){
            a.OwnerId = testUser.id;
            a.Owner_games__c = testUser.Id;
         }
         update accounts;
        System.runAs(testUser){ 
        PageReference pageRef = Page.CRM_MassUpdateNRDealProduct;
        Test.setCurrentPage(pageRef);
        String validationMsg = 'Updated';
        //List<OpportunityLineItem> dealproductrecords = [select Id,NR__c,Opportunity.Sales_Organisation__c,Promoted_Price__c from OpportunityLineItem];
        
        CRM_MassUpdateNRDealProductCtrl.OpportunityLineItemWrapper wrapper = new CRM_MassUpdateNRDealProductCtrl.OpportunityLineItemWrapper();
        List<CRM_MassUpdateNRDealProductCtrl.OpportunityLineItemWrapper> wrapperClassObj = new List<CRM_MassUpdateNRDealProductCtrl.OpportunityLineItemWrapper>();
        
        CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
        searchFilter.text = 'PR100001';
        searchFilter.streetDateFrom = system.today();
        searchFilter.streetDateTo = system.today()+35;
         //US660
        CRM_MassUpdateNRDealProductCtrl.FilterWrapper filter =new CRM_MassUpdateNRDealProductCtrl.FilterWrapper();
        filter.accOwnerEntered =new CRM_DataObjects.PicklistOption[]{};
        filter.accOwnerEntered.add(new CRM_DataObjects.PicklistOption(accounts[0].OwnerId +'',accounts[0].Owner.Name+' Games & Video'));
        List<Id> fixedSearchResults = new List<Id>();
        for(Product2 prod : [select Id from Product2]){
            fixedSearchResults.add(prod.Id);
        }

        Test.setFixedSearchResults(fixedSearchResults);
        
        wrapperClassObj = CRM_MassUpdateNRDealProductCtrl.getOpportunityLineItems(searchFilter,'Product',null,filter);
        
        wrapper.lineItemRecord = wrapperClassObj[0].lineItemRecord;
        wrapper.lineItemRecord.Initial_Quantity__c  = 0;
        wrapper.isRowModified=true;
        wrapperClassObj.add(wrapper);
        list<CRM_MassUpdateNRDealProductCtrl.OpportunityLineItemWrapper> savedlineItems = new list<CRM_MassUpdateNRDealProductCtrl.OpportunityLineItemWrapper>();
        if(wrapperClassObj != null){
        savedlineItems = CRM_MassUpdateNRDealProductCtrl.setOpportunityLineItems(wrapperClassObj);
        system.debug('saved items -->'+savedlineItems);
        }
        system.assertEquals(validationMsg,savedlineItems[savedlineItems.size()-1].validation);
        } 
    } 
    static testMethod void unitTestGetLineItems_nullSearch_test(){
        testDataMethod();
        
        User testUser = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
         //US660 Add Account Owner filter
        list<Account> accounts =[SELECT OWNERId,OWNER.Name,Owner_Games__c,Owner_Games__r.name FROM Account ];
        for(Account a:accounts){
            a.OwnerId = testUser.id;
            a.Owner_games__c = testUser.Id;
         }
         update accounts;
        System.runAs(testUser){ 
        PageReference pageRef = Page.CRM_MassUpdateNRDealProduct;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(deal);
        CRM_MassUpdateNRDealProductCtrl ctrl = new CRM_MassUpdateNRDealProductCtrl(sc);
        
        ctrl.getUserLocale();
        //US660
        CRM_MassUpdateNRDealProductCtrl.FilterWrapper filter =new CRM_MassUpdateNRDealProductCtrl.FilterWrapper();
        filter.accOwnerEntered =new CRM_DataObjects.PicklistOption[]{};
        filter.accOwnerEntered.add(new CRM_DataObjects.PicklistOption(accounts[0].OwnerId +'',accounts[0].Owner.Name+' Games & Video'));
        List<CRM_MassUpdateNRDealProductCtrl.OpportunityLineItemWrapper> wrapperClassObj = new List<CRM_MassUpdateNRDealProductCtrl.OpportunityLineItemWrapper>();
        CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
        searchFilter.text = '';
        searchFilter.streetDateFrom = system.today();
        searchFilter.streetDateTo = system.today()+35;
        
        List<Id> fixedSearchResults = new List<Id>();
        for(Product2 prod : [select Id from Product2]){
            fixedSearchResults.add(prod.Id);
        }

        Test.setFixedSearchResults(fixedSearchResults);
        
        wrapperClassObj = CRM_MassUpdateNRDealProductCtrl.getOpportunityLineItems(searchFilter,'Product',null,filter);
        system.debug('wrapper class --->'+wrapperClassObj.size());
        system.assertEquals(8,wrapperClassObj.size());
        
        }
    }
    
}