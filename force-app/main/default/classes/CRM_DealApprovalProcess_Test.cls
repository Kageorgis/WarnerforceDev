@isTest
private class CRM_DealApprovalProcess_Test {
    
    //@testsetup 
    static void dataSetUpForFeatureProductCatalog(){
        list<User> u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true AND ByPassValidationRule__c= False ];
        //create accounts
        list<Account> accounts = CRM_TestDataFactory.createAccounts(2, false);
        accounts[0].Primary_Approver__c=u[0].id;
        accounts[0].Secondary_Approver__c=u[1].id;
        accounts[0].Tertiary_Approver__c=u[1].id;
        accounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        accounts[1].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert accounts;
        
        list<Opportunity> opps = CRM_TestDataFactory.createOpportunitiesWithAccounts(accounts, 4, true);
        opps[0].accountId = accounts[0].id;
        
        List<Product_Group__c> lstProductGroups = CRM_TestDataFactory.createProductGroups(1, true);
        
        List<Product2> lstProducts = CRM_TestDataFactory.createProducts(lstProductGroups, 1, true);
        lstProducts[0].Franchise_Type__c = 'X2';
        lstProducts[0].Release_Category__c = 'CATALOG';
        update lstProducts;
        
        List<PricebookEntry> pbEntries = CRM_TestDataFactory.createPriceBookEntries(lstProducts, 1, true);
        
        List<Pricebook_Entry_Period__c> pbeD = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts, 1, true);
        
        List<OpportunityLineItem> lstDealproducts = CRM_TestDataFactory.createDealProductsWithOpportunities(pbEntries, opps, 1, true);
        lstDealproducts[0].Minimum_Contribution__c= 1500;
        update lstDealproducts;
        
        List<Product2> productsL = [Select Id, Release_Category__c, Franchise_Type__c From Product2];
        for(Product2 objProd:productsL){
        System.debug('Products Release_Category__c===> ' + objProd.Release_Category__c);
        System.debug('Products Franchise_Type__c===> ' + objProd.Franchise_Type__c);
    }
    
    insert new CRM_UK_Approval_process_submitter__c(SetupOwnerId=UserInfo.getOrganizationId(), James_Jackson_Id__c='0050B000006q5xz');
    
    }
    
    //@testsetup 
    static void dataSetUpForFeatureProductNR(){
        //create accounts
        list<Account> accounts = CRM_TestDataFactory.createAccounts(1, false);
        accounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        insert accounts;
        system.debug('This is Account data=====> '+accounts);
        list<Opportunity> opps = CRM_TestDataFactory.createOpportunitiesWithAccounts(accounts, 1, true);
        
        List<Product_Group__c> lstProductGroups = CRM_TestDataFactory.createProductGroups(1, true);
        
        List<Product2> lstProducts = new List<Product2>();
        Product2 objProduct = new Product2();
        objProduct.Franchise_Type__c = 'X2';
        objProduct.Release_Category__c = 'NEW RELEASE';
        objProduct.Street_Date__c = System.today();
        objProduct.Product_Group__c = lstProductGroups[0].Id;
        objProduct.IsActive = true;
        objProduct.Name = 'PR ' + Math.random();
        objProduct.Product_Format__c = 'DVD';
        objProduct.CanUseQuantitySchedule = true;
        objProduct.CanUseRevenueSchedule = true;
        objProduct.NR_period_weeks__c =8;
        lstProducts.add(objProduct);
        insert lstProducts;
        
        List<PricebookEntry> pbEntries = CRM_TestDataFactory.createPriceBookEntries(lstProducts, 1, true);
        
        List<Pricebook_Entry_Period__c> pbeD = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts, 1, true);
        
        List<OpportunityLineItem> lstDealproducts = CRM_TestDataFactory.createDealProductsWithOpportunities(pbEntries, opps, 1, true);
        lstDealproducts[0].Minimum_Contribution__c= 1500;
        update lstDealproducts;
        List<Product2> productsL = [Select Id, Release_Category__c, Franchise_Type__c From Product2];
        for(Product2 objProd:productsL){
          System.debug('Products Release_Category__c===> ' + objProd.Release_Category__c);
          System.debug('Products Franchise_Type__c===> ' + objProd.Franchise_Type__c);
     }
     
     insert new CRM_UK_Approval_process_submitter__c(SetupOwnerId=UserInfo.getOrganizationId(), James_Jackson_Id__c='0050B000006q5xz');
    }
    
    //@testsetup 
    static void dataSetUpForMinContributionProductCatalog(){
        //create accounts
        list<Account> accounts = CRM_TestDataFactory.createAccounts(1, false);
        
        list<Opportunity> opps = CRM_TestDataFactory.createOpportunitiesWithAccounts(accounts, 1, true);
        
        List<Product_Group__c> lstProductGroups = CRM_TestDataFactory.createProductGroups(1, true);
        
        List<Product2> lstProducts = CRM_TestDataFactory.createProducts(lstProductGroups, 1, true);
        update lstProducts;
        
        List<PricebookEntry> pbEntries = CRM_TestDataFactory.createPriceBookEntries(lstProducts, 1, true);
        
        List<Pricebook_Entry_Period__c> pbeD = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts, 1, true);
        
        List<OpportunityLineItem> lstDealproducts = CRM_TestDataFactory.createDealProductsWithOpportunities(pbEntries, opps, 1, true);
        lstDealproducts[0].Minimum_Contribution__c= 1500;
        update lstDealproducts;
    }
    
    static testMethod void unitTestForFeatureNR() {
        System.debug('Inside method 1');
        dataSetUpForFeatureProductNR();
        list<Opportunity> lstOpportunity = [select id, name, Start_Date__c, CloseDate, accountId, StageName from Opportunity];
        system.debug('This is Oppotunity data' + lstOpportunity);
        list<OpportunityLineItem> lstOpportunityProduct = [select id, Price_is_Minimum__c, NR__c from OpportunityLineItem];
        System.debug('unitTestForFeatureNR: ' + 'Price_is_Minimum__c===> ' + lstOpportunityProduct[0].Price_is_Minimum__c + 'NR===> ' + lstOpportunityProduct[0].NR__c);
        
        Opportunity plannedOpportunity = lstOpportunity[0];
        system.debug('This is Oppotunity data 000' + lstOpportunity[0]);
        Test.startTest();
                    PageReference pageRef = Page.CRM_DealApproval;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',plannedOpportunity.id);
                    ApexPages.standardController controller = new ApexPages.standardController(plannedOpportunity);
                             
                    CRM_DealApproval pg = new CRM_DealApproval(controller); 
                    CRM_DealApproval.callStandardApprovalProcess(plannedOpportunity.id);
                    //List<ProcessInstanceWorkItem> workItemList = [Select ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstanceId, OriginalActor.Name, OriginalActorId, Id, ActorId From ProcessInstanceWorkitem];
                    //system.debug('This is Work Item List --->>++>>'+workItemList );
                    //system.debug('OriginalActorId===> ' + workItemList[0].OriginalActorId);
                    
                    list<Opportunity> Opportunity = [select id, name, Start_Date__c, CloseDate, accountId, StageName from Opportunity];
                    system.debug('Test This Log---->>> '+Opportunity);
                    //system.assertEquals('Awaiting Approval', Opportunity[0].StageName);
                    //system.assertNotEquals('Dilip', workItemList[0].OriginalActor.Name);
        Test.stopTest();
    }
    
    static testMethod void unitTestForcatlogProduct(){
        dataSetUpForFeatureProductCatalog();
        list<Opportunity> lstOpportunity = [select id, name, Start_Date__c, CloseDate, accountId, StageName from Opportunity];
        list<OpportunityLineItem> lstOpportunityProduct = [select id, Price_is_Minimum__c, NR__c from OpportunityLineItem];
        System.debug('unitTestForFeatureNR: ' + 'Price_is_Minimum__c===> ' + lstOpportunityProduct[0].Price_is_Minimum__c + 'NR===> ' + lstOpportunityProduct[0].NR__c);
        
        Opportunity plannedOpportunity = lstOpportunity[0];
        Test.startTest();
                    PageReference pageRef = Page.CRM_DealApproval;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',plannedOpportunity.id);
                    ApexPages.standardController controller = new ApexPages.standardController(plannedOpportunity);
                             
                    CRM_DealApproval pg = new CRM_DealApproval(controller); 
                    CRM_DealApproval.callStandardApprovalProcess(plannedOpportunity.id);
                    //List<ProcessInstanceWorkItem> workItemList = [Select ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstanceId, OriginalActor.Name, OriginalActorId, Id, ActorId From ProcessInstanceWorkitem];
                    //System.debug('OriginalActorId===> ' + workItemList[0].OriginalActorId);
                    
                    list<Opportunity> Opportunity = [select id, name, Start_Date__c, CloseDate, accountId, StageName from Opportunity];
                    //system.assertEquals('Awaiting Approval', Opportunity[0].StageName);
                    //system.assertNotEquals('Dilip', workItemList[0].OriginalActor.Name);
        Test.stopTest();
    }
    
    //@testsetup 
    /*static void dataSetUpForTVProductCatalog(){
        //create accounts
        list<Account> accounts = CRM_TestDataFactory.createAccounts(1, true);
        
        list<Opportunity> opps = CRM_TestDataFactory.createOpportunitiesWithAccounts(accounts, 1, true);
        
        List<Product_Group__c> lstProductGroups = CRM_TestDataFactory.createProductGroups(1, true);
        
        List<Product2> lstProducts = CRM_TestDataFactory.createProducts(lstProductGroups, 1, true);
        lstProducts[0].Franchise_Type__c = 'TV';
        lstProducts[0].Release_Category__c = 'CATALOG';
        update lstProducts;
        
        List<PricebookEntry> pbEntries = CRM_TestDataFactory.createPriceBookEntries(lstProducts, 1, true);
        
        List<Pricebook_Entry_Period__c> pbeD = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts, 1, true);
        
        List<OpportunityLineItem> lstDealproducts = CRM_TestDataFactory.createDealProductsWithOpportunities(pbEntries, opps, 1, true);
        lstDealproducts[0].Minimum_Price__c = 500;
        update lstDealproducts;
    }*/
    
    //@testsetup 
    /*static void dataSetUpForkidProductCatalog(){
        //create accounts
        list<Account> accounts = CRM_TestDataFactory.createAccounts(1, true);
        
        list<Opportunity> opps = CRM_TestDataFactory.createOpportunitiesWithAccounts(accounts, 1, true);
        
        List<Product_Group__c> lstProductGroups = CRM_TestDataFactory.createProductGroups(1, true);
        
        List<Product2> lstProducts = CRM_TestDataFactory.createProducts(lstProductGroups, 1, true);
        lstProducts[0].Franchise_Type__c = 'X3';
        lstProducts[0].Release_Category__c = 'CATALOG';
        update lstProducts;
        
        List<PricebookEntry> pbEntries = CRM_TestDataFactory.createPriceBookEntries(lstProducts, 1, true);
        
        List<Pricebook_Entry_Period__c> pbeD = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts, 1, true);
        
        List<OpportunityLineItem> lstDealproducts = CRM_TestDataFactory.createDealProductsWithOpportunities(pbEntries, opps, 1, true);
        lstDealproducts[0].Minimum_Price__c = 500;
        update lstDealproducts;
    }*/
    
    //@testsetup 
    /*static void dataSetUpForHBOProductCatalog(){
        list<Account> accounts = CRM_TestDataFactory.createAccounts(1, true);
        
        list<Opportunity> opps = CRM_TestDataFactory.createOpportunitiesWithAccounts(accounts, 1, true);
        
        List<Product_Group__c> lstProductGroups = CRM_TestDataFactory.createProductGroups(1, true);
        
        List<Product2> lstProducts = CRM_TestDataFactory.createProducts(lstProductGroups, 1, true);
        lstProducts[0].Franchise_Type__c = 'X10';
        lstProducts[0].Release_Category__c = 'CATALOG';
        update lstProducts[0];
        
        List<PricebookEntry> pbEntries = CRM_TestDataFactory.createPriceBookEntries(lstProducts, 1, true);
        
        List<Pricebook_Entry_Period__c> pbeD = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts, 1, true);
        
        List<OpportunityLineItem> lstDealproducts = CRM_TestDataFactory.createDealProductsWithOpportunities(pbEntries, opps, 1, true);
        lstDealproducts[0].Minimum_Price__c = 500;
        update lstDealproducts;
    }*/
   /* 
    //@testsetup 
    static void dataSetUpForGamesProductCatalog(){
        //create accounts
        list<Account> accounts = CRM_TestDataFactory.createAccounts(1, true);
        
        list<Opportunity> opps = CRM_TestDataFactory.createOpportunitiesWithAccounts(accounts, 1, true);
        
        List<Product_Group__c> lstProductGroups = CRM_TestDataFactory.createProductGroups(1, true);
        
        List<Product2> lstProducts = CRM_TestDataFactory.createProducts(lstProductGroups, 1, true);
        lstProducts[0].Franchise_Type__c = 'X6';
        lstProducts[0].Release_Category__c = 'CATALOG';
        update lstProducts;
        
        List<PricebookEntry> pbEntries = CRM_TestDataFactory.createPriceBookEntries(lstProducts, 1, true);
        
        List<Pricebook_Entry_Period__c> pbeD = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts, 1, true);
        
        List<OpportunityLineItem> lstDealproducts = CRM_TestDataFactory.createDealProductsWithOpportunities(pbEntries, opps, 1, true);
        lstDealproducts[0].Minimum_Price__c = 500;
        update lstDealproducts;
    }*/
   /* 
    //@testsetup 
    static void dataSetUpForOtherProductCatalog(){
        //create accounts
        list<Account> accounts = CRM_TestDataFactory.createAccounts(1, true);
        
        list<Opportunity> opps = CRM_TestDataFactory.createOpportunitiesWithAccounts(accounts, 1, true);
        
        List<Product_Group__c> lstProductGroups = CRM_TestDataFactory.createProductGroups(1, true);
        
        List<Product2> lstProducts = CRM_TestDataFactory.createProducts(lstProductGroups, 1, true);
        lstProducts[0].Franchise_Type__c = 'X4';
        lstProducts[0].Release_Category__c = 'CATALOG';
        update lstProducts;
        
        List<PricebookEntry> pbEntries = CRM_TestDataFactory.createPriceBookEntries(lstProducts, 1, true);
        
        List<Pricebook_Entry_Period__c> pbeD = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProducts, 1, true);
        
        List<OpportunityLineItem> lstDealproducts = CRM_TestDataFactory.createDealProductsWithOpportunities(pbEntries, opps, 1, true);
        lstDealproducts[0].Minimum_Price__c = 500;
        update lstDealproducts;
    }*/
    
    
    
    
    /*
    static testMethod void unitTestForFeatureCatalog() {
    System.debug('Inside method 2');
        dataSetUpForFeatureProductCatalog();
        list<Opportunity> lstOpportunity = [select id, name, Start_Date__c, CloseDate, accountId, StageName from Opportunity];
        list<OpportunityLineItem> lstOpportunityProduct = [select id, Price_is_Minimum__c, NR__c from OpportunityLineItem];
        System.debug('unitTestForFeatureCatalog: ' + 'Price_is_Minimum__c===> ' + lstOpportunityProduct[0].Price_is_Minimum__c + 'NR===> ' + lstOpportunityProduct[0].NR__c);
        
        Opportunity plannedOpportunity = lstOpportunity[0];
        Test.startTest();
                    PageReference pageRef = Page.CRM_DealApproval;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',plannedOpportunity.id);
                    ApexPages.standardController controller = new ApexPages.standardController(plannedOpportunity);
                             
                    CRM_DealApproval pg = new CRM_DealApproval(controller); 
                    CRM_DealApproval.callStandardApprovalProcess(plannedOpportunity.id);
                    
                    List<ProcessInstanceWorkItem> workItemList = [Select ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstanceId, OriginalActor.Name, OriginalActorId, Id, ActorId From ProcessInstanceWorkitem];
          System.debug('OriginalActorId===> ' + workItemList[0].OriginalActorId);
          
                    list<Opportunity> Opportunity = [select id, name, Start_Date__c, CloseDate, accountId, StageName from Opportunity];
                    system.assertEquals('Awaiting Approval', Opportunity[0].StageName);
                    system.assertNotEquals('Dilip', workItemList[0].OriginalActor.Name);
        Test.stopTest();
    }
    
    
    static testMethod void unitTestForTVCatalog() {
    System.debug('Inside method 3');
        dataSetUpForTVProductCatalog();
        list<Opportunity> lstOpportunity = [select id, name, Start_Date__c, CloseDate, accountId, StageName from Opportunity];
        list<OpportunityLineItem> lstOpportunityProduct = [select id, Price_is_Minimum__c, NR__c from OpportunityLineItem];
        System.debug('unitTestForTVCatalog: ' + 'Price_is_Minimum__c===> ' + lstOpportunityProduct[0].Price_is_Minimum__c + 'NR===> ' + lstOpportunityProduct[0].NR__c);
        
        Opportunity plannedOpportunity = lstOpportunity[0];
        Test.startTest();
                    PageReference pageRef = Page.CRM_DealApproval;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',plannedOpportunity.id);
                    ApexPages.standardController controller = new ApexPages.standardController(plannedOpportunity);
                             
                    CRM_DealApproval pg = new CRM_DealApproval(controller); 
                    CRM_DealApproval.callStandardApprovalProcess(plannedOpportunity.id);
                     
                    List<ProcessInstanceWorkItem> workItemList = [Select ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstanceId, OriginalActor.Name, OriginalActorId, Id, ActorId From ProcessInstanceWorkitem];
                    if(!workItemList.isEmpty()){
                    System.debug('OriginalActorId===> ' + workItemList[0].OriginalActorId);
                    }
                    list<Opportunity> Opportunity = [select id, name, Start_Date__c, CloseDate, accountId, StageName from Opportunity];
                    system.assertEquals('Awaiting Approval', Opportunity[0].StageName);
                    system.assertNotEquals('Dilip', workItemList[0].OriginalActor.Name);
        Test.stopTest();
    }
    
    static testMethod void unitTestForKIDCatalog() {
    System.debug('Inside method 4');
        dataSetUpForkidProductCatalog();
    
        list<Opportunity> lstOpportunity = [select id, name, Start_Date__c, CloseDate, accountId, StageName from Opportunity];
        list<OpportunityLineItem> lstOpportunityProduct = [select id, Price_is_Minimum__c, NR__c from OpportunityLineItem];
        System.debug('unitTestForKIDCatalog: ' + 'Price_is_Minimum__c===> ' + lstOpportunityProduct[0].Price_is_Minimum__c + 'NR===> ' + lstOpportunityProduct[0].NR__c);
        
        Opportunity plannedOpportunity = lstOpportunity[0];
        Test.startTest();
                    PageReference pageRef = Page.CRM_DealApproval;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',plannedOpportunity.id);
                    ApexPages.standardController controller = new ApexPages.standardController(plannedOpportunity);
                             
                    CRM_DealApproval pg = new CRM_DealApproval(controller); 
                    CRM_DealApproval.callStandardApprovalProcess(plannedOpportunity.id);
                     
                    List<ProcessInstanceWorkItem> workItemList = [Select ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstanceId, OriginalActor.Name, OriginalActorId, Id, ActorId From ProcessInstanceWorkitem];
          System.debug('OriginalActorId===> ' + workItemList[0].OriginalActorId);
          
                    list<Opportunity> Opportunity = [select id, name, Start_Date__c, CloseDate, accountId, StageName from Opportunity];
                    system.assertEquals('Awaiting Approval', Opportunity[0].StageName);
                    system.assertNotEquals('Dilip', workItemList[0].OriginalActor.Name);
        Test.stopTest();
    }
    
    static testMethod void unitTestForHBOCatalog() {
    System.debug('Inside method 5');
        dataSetUpForHBOProductCatalog();
        list<Opportunity> lstOpportunity = [select id, name, Start_Date__c, CloseDate, accountId, StageName from Opportunity];
        list<OpportunityLineItem> lstOpportunityProduct = [select id, Price_is_Minimum__c, NR__c from OpportunityLineItem];
        System.debug('unitTestForHBOCatalog: ' + 'Price_is_Minimum__c===> ' + lstOpportunityProduct[0].Price_is_Minimum__c + 'NR===> ' + lstOpportunityProduct[0].NR__c);
        
        Opportunity plannedOpportunity = lstOpportunity[0];
        Test.startTest();
                    PageReference pageRef = Page.CRM_DealApproval;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',plannedOpportunity.id);
                    ApexPages.standardController controller = new ApexPages.standardController(plannedOpportunity);
                             
                    CRM_DealApproval pg = new CRM_DealApproval(controller); 
                    CRM_DealApproval.callStandardApprovalProcess(plannedOpportunity.id);
                     
                    List<ProcessInstanceWorkItem> workItemList = [Select ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstanceId, OriginalActor.Name, OriginalActorId, Id, ActorId From ProcessInstanceWorkitem];
          System.debug('OriginalActorId===> ' + workItemList[0].OriginalActorId);
          
                    list<Opportunity> Opportunity = [select id, name, Start_Date__c, CloseDate, accountId, StageName from Opportunity];
                    system.assertEquals('Awaiting Approval', Opportunity[0].StageName);
                    system.assertNotEquals('Dilip', workItemList[0].OriginalActor.Name);
        Test.stopTest();
    }
    
    static testMethod void unitTestForGAMESCatalog() {
    System.debug('Inside method 6');
        dataSetUpForGamesProductCatalog();
        list<Opportunity> lstOpportunity = [select id, name, Start_Date__c, CloseDate, accountId, StageName from Opportunity];
        list<OpportunityLineItem> lstOpportunityProduct = [select id, Price_is_Minimum__c, NR__c from OpportunityLineItem];
        System.debug('unitTestForGAMESCatalog: ' + 'Price_is_Minimum__c===> ' + lstOpportunityProduct[0].Price_is_Minimum__c + 'NR===> ' + lstOpportunityProduct[0].NR__c);
        
        Opportunity plannedOpportunity = lstOpportunity[0];
        Test.startTest();
                    PageReference pageRef = Page.CRM_DealApproval;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',plannedOpportunity.id);
                    ApexPages.standardController controller = new ApexPages.standardController(plannedOpportunity);
                             
                    CRM_DealApproval pg = new CRM_DealApproval(controller); 
                    CRM_DealApproval.callStandardApprovalProcess(plannedOpportunity.id);
                     
                    List<ProcessInstanceWorkItem> workItemList = [Select ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstanceId, OriginalActor.Name, OriginalActorId, Id, ActorId From ProcessInstanceWorkitem];
          System.debug('OriginalActorId===> ' + workItemList[0].OriginalActorId);
          System.debug('OriginalActorName===> ' + workItemList[0].OriginalActor.Name);
          
                    list<Opportunity> Opportunity = [select id, name, Start_Date__c, CloseDate, accountId, StageName from Opportunity];
                    system.assertEquals('Awaiting Approval', Opportunity[0].StageName);
                    system.assertNotEquals('Dilip', workItemList[0].OriginalActor.Name);
        Test.stopTest();
    }
    
    static testMethod void unitTestForOtherCatalog() {
    System.debug('Inside method 7');
        dataSetUpForOtherProductCatalog();
        list<Opportunity> lstOpportunity = [select id, name, Start_Date__c, CloseDate, accountId, StageName from Opportunity];
        list<OpportunityLineItem> lstOpportunityProduct = [select id, Price_is_Minimum__c, NR__c from OpportunityLineItem];
        System.debug('unitTestForOtherCatalog: ' + 'Price_is_Minimum__c===> ' + lstOpportunityProduct[0].Price_is_Minimum__c + 'NR===> ' + lstOpportunityProduct[0].NR__c);
        
        Opportunity plannedOpportunity = lstOpportunity[0];
        Test.startTest();
                    PageReference pageRef = Page.CRM_DealApproval;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',plannedOpportunity.id);
                    ApexPages.standardController controller = new ApexPages.standardController(plannedOpportunity);
                             
                    CRM_DealApproval pg = new CRM_DealApproval(controller); 
                    CRM_DealApproval.callStandardApprovalProcess(plannedOpportunity.id);
                     
                    List<ProcessInstanceWorkItem> workItemList = [Select ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstanceId, OriginalActor.Name, OriginalActorId, Id, ActorId From ProcessInstanceWorkitem];
          System.debug('OriginalActorId===> ' + workItemList[0].OriginalActorId);
          
                    list<Opportunity> Opportunity = [select id, name, Start_Date__c, CloseDate, accountId, StageName from Opportunity];
                    system.assertEquals('Awaiting Approval', Opportunity[0].StageName);
                    system.assertNotEquals('Dilip', workItemList[0].OriginalActor.Name);
        Test.stopTest();
    }
    
    
    static testMethod void unitTestForMinContributionProductCatalog() {
    dataSetUpForMinContributionProductCatalog();
        list<Opportunity> lstOpportunity = [select id, name, Start_Date__c, CloseDate, accountId, StageName from Opportunity];
        list<OpportunityLineItem> lstOpportunityProduct = [select id, Price_is_Minimum__c, NR__c from OpportunityLineItem];
        
        Opportunity plannedOpportunity = lstOpportunity[0];
        Test.startTest();
                    PageReference pageRef = Page.CRM_DealApproval;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',plannedOpportunity.id);
                    ApexPages.standardController controller = new ApexPages.standardController(plannedOpportunity);
                             
                    CRM_DealApproval pg = new CRM_DealApproval(controller); 
                    CRM_DealApproval.callStandardApprovalProcess(plannedOpportunity.id);
                     
                    List<ProcessInstanceWorkItem> workItemList = [Select ProcessInstance.Status, ProcessInstance.TargetObjectId, ProcessInstanceId, OriginalActor.Name,OriginalActorId, Id, ActorId From ProcessInstanceWorkitem];
          System.debug('OriginalActorId===> ' + workItemList[0].OriginalActorId);
          
                    list<Opportunity> Opportunity = [select id, name, Start_Date__c, CloseDate, accountId, StageName from Opportunity];
                    system.assertEquals('Awaiting Approval', Opportunity[0].StageName);
                    system.assertNotEquals('Dilip', workItemList[0].OriginalActor.Name);
        Test.stopTest();
    }*/
}