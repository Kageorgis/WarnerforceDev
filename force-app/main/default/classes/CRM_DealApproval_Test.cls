@isTest
private class CRM_DealApproval_Test {
    //@testsetup 
    static void allTheDataForThisTestClass(){
        //create accounts
        list<Account> accounts = CRM_TestDataFactory.createAccounts(3, true);
        
        //update accounts in order to create a relationship
        accounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_FRANCE_CODE;
        accounts[1].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        accounts[2].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        update accounts;
        
        list<Opportunity> opps = CRM_TestDataFactory.createOpportunitiesWithAccounts(accounts, 2, true);
        system.assertEquals(6,opps.size());
        
        List<Product_Group__c> pgs = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> products = CRM_TestDataFactory.createProducts(pgs, 2, true);
        system.debug('===products==='+products);
        List<PricebookEntry> pbEntries = CRM_TestDataFactory.createPriceBookEntries(products, 1, true);
        system.debug('===pbEntries==='+pbEntries);
        
        List<Pricebook_Entry_Period__c> pbeD=CRM_TestDataFactory.createPriceBookEntryPeriods(products, 1, true);
        system.assertEquals(2,pbeD.size());
        
        List<OpportunityLineItem> dealproducts = CRM_TestDataFactory.createDealProductsWithOpportunities(pbEntries, opps, 2, true);
        system.assertEquals(12,dealproducts.size());
        
        insert new CRM_UK_Approval_process_submitter__c(SetupOwnerId=UserInfo.getOrganizationId(), James_Jackson_Id__c='0050B000006q5xz');
        
    }
    
    static testMethod void unitTestPositive() {
        allTheDataForThisTestClass();
        list<Account> accounts = [select id, Sales_Organization__c from Account];
        accounts[0].Sales_Organization__c=CRM_AppConstants.TERRITORY_UK_CODE;
        update accounts;
        system.debug('===accounts==='+accounts);
        list<Opportunity> franceOpportunities = [select id, name, Start_Date__c, CloseDate, accountId, account.Sales_Organization__c,StageName 
                                           from Opportunity
                                           where accountId =: accounts[0].id];
        system.debug('=======>> France Opportunity' + franceOpportunities);
        Opportunity plannedOpportunity = franceOpportunities[0];
        //plannedOpportunity.Customer_Delivery_Date__c = Date.Today();
        //update plannedOpportunity;
        //plannedOpportunity.StageName= CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        //update plannedOpportunity;
        
        Test.startTest();
                    PageReference pageRef = Page.CRM_DealApproval;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',plannedOpportunity.id);
                    ApexPages.standardController controller = new ApexPages.standardController(plannedOpportunity);
                             
                    CRM_DealApproval pg = new CRM_DealApproval(controller); 
                    //system.assertEquals(false, pg.isEntryCriteriaFailed);
                    //system.assertEquals(false, pg.isClientUnavail);
                    //system.assertEquals(true, pg.isTerritoryGermany);
                    
                    CRM_DataObjects.ProductToEdit[] prds=CRM_DealApproval.getLineItems(plannedOpportunity.id);
                    CRM_DealApproval.DealWrapper dw = CRM_DealApproval.getOverlappingDealProducts(plannedOpportunity.id);
                    system.assertEquals(false, dw.showMessage);
                    
        Test.stopTest();
        
        //pg.goBackToDeal();
                    // ensure that the opp was submitted for approval
                    List<ProcessInstance> processInstances = [select Id, Status from ProcessInstance where TargetObjectId = :plannedOpportunity.id];
                    system.debug('====> Process Instance 1'+processInstances);
                    System.assertEquals(processInstances.size(),1);
    }
    
    static testMethod void unitTestOverlappingCondition() {
        allTheDataForThisTestClass();
        list<User> u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true AND ByPassValidationRule__c= False ];
        list<Account> accounts = [select id, Sales_Organization__c from Account];
        accounts[0].Primary_Approver__c =u[0].id;
        accounts[1].Primary_Approver__c =u[1].id;
        accounts[0].Sales_Organization__c= CRM_AppConstants.TERRITORY_UK_CODE;
        accounts[1].Sales_Organization__c= CRM_AppConstants.TERRITORY_UK_CODE;
        update accounts;
        
        system.debug('===accounts==='+accounts);
        list<Opportunity> opportunities = [select id, name, Start_Date__c, CloseDate, accountId, account.Sales_Organization__c,StageName 
                                           from Opportunity
                                           where accountId =: accounts[0].id];
        
        //set dates of opp1 and opp2 so that they overlap
        Opportunity newPlannedDeal = opportunities[0];
        system.debug('New Planned Deal'+newPlannedDeal);
        newPlannedDeal.Promo_Start_Date__c= system.today()+20;
        newPlannedDeal.Promo_End_Date__c= system.today()+30;
        newPlannedDeal.Start_Date__c= system.today()+15;
        newPlannedDeal.CloseDate= system.today()+40;
        newPlannedDeal.StageName= CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        
        Opportunity existingPlannedDeal = opportunities[1];
        system.debug('Existing Planned Deal'+existingPlannedDeal);
        existingPlannedDeal.Promo_Start_Date__c= system.today()+15;
        existingPlannedDeal.Promo_End_Date__c= system.today()+20;
        existingPlannedDeal.Start_Date__c= system.today()+10;
        existingPlannedDeal.CloseDate= system.today()+30;
        existingPlannedDeal.StageName= CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        update opportunities;
        
        list<OpportunityLineItem> oppLines = [SELECT id, OpportunityId, ListPrice__c,name, Product2.Name, CurrencyIsoCode, Promoted_Price__c,UnitPrice
                                             from OpportunityLineItem
                                             where OpportunityId =: newPlannedDeal.id];
        system.debug('===oppLines==='+oppLines);
        OpportunityLineItem oppLine1 = oppLines[0];
        OpportunityLineItem oppLine2 = oppLines[1];
        system.debug('===oppLine1==='+oppLine1);
        system.debug('===oppLine2==='+oppLine2);
        oppLine1.Promoted_Price__c=15;
        oppLine2.Promoted_Price__c=18;
        update oppLines;
        
        // get opp2 in stage = approved
        Test.startTest();
        PageReference pageRef = Page.CRM_DealApproval;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',existingPlannedDeal.id);
        ApexPages.standardController controller = new ApexPages.standardController(existingPlannedDeal);
                 
        CRM_DealApproval pg = new CRM_DealApproval(controller); 
        CRM_DealApproval.getLineItems(existingPlannedDeal.id);
        CRM_DealApproval.DealWrapper dw = CRM_DealApproval.getOverlappingDealProducts(existingPlannedDeal.id);
        // ensure that the opp is submitted for approval
        List<ProcessInstance> processInstancesSuccess = [select Id, Status from ProcessInstance where TargetObjectId = :existingPlannedDeal.id];
        //system.debug('======> Process Instance'+processInstancesSuccess);
        //System.assertEquals(processInstancesSuccess.size(),1);
        
                    ApexPages.currentPage().getParameters().put('id',newPlannedDeal.id);
                    controller = new ApexPages.standardController(newPlannedDeal);
                             
                    pg = new CRM_DealApproval(controller); 
                    CRM_DataObjects.ProductToEdit[] prds=CRM_DealApproval.getLineItems(newPlannedDeal.id);
                    dw = CRM_DealApproval.getOverlappingDealProducts(newPlannedDeal.id);
                    //system.assertEquals(true, dw.showMessage);
                     
                    //system.debug('===> This is new process Instance' + processInstances);
                    /*
                    System.assertEquals(processInstances.size(),0);
                    
                    CRM_DealApproval.saveLineItems(newPlannedDeal.id, prds);
                    // ensure that the opp is submitted for approval
                    processInstances = [select Id, Status from ProcessInstance where TargetObjectId = :newPlannedDeal.id];
                    System.assertEquals(processInstances.size(),1);
                    */
        
         List<ProcessInstance> processInstances = [select Id, Status from ProcessInstance where TargetObjectId = :newPlannedDeal.id];
                  
    } 
    
    static testMethod void unitTestEntryCriteriaFailed() {
              allTheDataForThisTestClass();
              CRM_Functional_Permissions__c functionalPermission = new CRM_Functional_Permissions__c();
              functionalPermission.Delete_Deal_Permission__c = true;
              insert functionalPermission;
               
              List<Opportunity> dealToUpdateList = [select id, name, Start_Date__c, CloseDate, accountId, account.Sales_Organization__c,StageName 
                                                   from Opportunity];
              delete dealToUpdateList;
              List<Account> accounts = [SELECT Id FROM Account];
              list<Opportunity> opps = CRM_TestDataFactory.createOpportunitiesWithAccounts(accounts, 3, false);
              for (Opportunity deal : opps) {
                  deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_NR_DEFAULT;
              }
              insert opps;
  
              list<Opportunity> opportunities = [select id, name, Start_Date__c, CloseDate, accountId, account.Sales_Organization__c,StageName 
                                                   from Opportunity
                                                   where StageName != :CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED and StageName != :CRM_AppConstants.OPPORTUNITY_STAGE_REVISED];
              Opportunity nrDefaultOpportunity = opportunities[0];
              Test.startTest();
                            PageReference pageRef = Page.CRM_DealApproval;
                            Test.setCurrentPage(pageRef);
                
                            ApexPages.currentPage().getParameters().put('id',nrDefaultOpportunity.id);
                            ApexPages.standardController controller = new ApexPages.standardController(nrDefaultOpportunity);
                                     
                            CRM_DealApproval pg = new CRM_DealApproval(controller); 
                            //system.assertEquals(true, pg.isEntryCriteriaFailed);
              Test.stopTest();
    }
    
    static testMethod void unitTestClientUnAvail() {
        allTheDataForThisTestClass();
        list<Opportunity> opportunities = [select id, name, Start_Date__c, CloseDate, accountId, account.Sales_Organization__c,StageName 
                                           from Opportunity];
        Opportunity newPlannedDeal = opportunities[0];
        newPlannedDeal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        update newPlannedDeal;
        
        system.debug('===opportunities==='+opportunities);
        list<OpportunityLineItem> oppLines = [SELECT id, OpportunityId, ListPrice__c,name,Product2Id, Product2.Name, CurrencyIsoCode,Promoted_Price__c, UnitPrice
                                             from OpportunityLineItem
                                             where OpportunityId =: newPlannedDeal.id];
        system.debug('===oppLines==='+oppLines);   
        
        // listprice of opp1 product which is different from opp2 product
        oppLines[0].ListPrice__c = 0;
        oppLines[0].Last_Published_Date__c = system.now();
        update oppLines;
        
        Product2 product = [select id,Type__c from Product2 where id=:oppLines[0].Product2Id];
        product.Type__c = CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
        product.recordtypeId= CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
        //product.Marketing_Material__c = false;
        update product;
        
        system.debug('===product==='+product);
        // now opp1 is in planned stage and will find opp2 as existing overlapping opp
        Test.startTest();
                    
                    ApexPages.currentPage().getParameters().put('id',newPlannedDeal.id);
                    ApexPages.standardController controller = new ApexPages.standardController(newPlannedDeal);
                             
                    CRM_DealApproval pg = new CRM_DealApproval(controller); 
                    //system.assertEquals(true, pg.isClientUnavail);
        Test.stopTest();
    }
    
    static testMethod void unitTestException() {
        allTheDataForThisTestClass();
        list<Account> accounts = [select id, Sales_Organization__c from Account];
        system.debug('===accounts==='+accounts);
        list<Opportunity> franceOpportunities = [select id, name, Start_Date__c, CloseDate, accountId, account.Sales_Organization__c,StageName 
                                           from Opportunity
                                           where accountId =: accounts[0].id];
        Opportunity newPlannedDeal = franceOpportunities[0];
        newPlannedDeal.StageName= CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        update newPlannedDeal;
        
        Test.startTest();
                    PageReference pageRef = Page.CRM_DealApproval;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',newPlannedDeal.id);
                    ApexPages.standardController controller = new ApexPages.standardController(newPlannedDeal);
                             
                    CRM_DealApproval pg = new CRM_DealApproval(controller); 
                    CRM_DataObjects.ProductToEdit[] prds=CRM_DealApproval.getLineItems(newPlannedDeal.id);
                    
                    try {
                        CRM_DealApproval.DealWrapper dw = CRM_DealApproval.getOverlappingDealProducts(null);
                    }
                    catch(Exception e) {
                        system.debug('e.getMessage() : '+e);
                        //system.assertEquals(true, e.getMessage().contains('null'));
                        system.assertEquals(true, e.getMessage().contains('List index out of bounds: 0'));
                    }
                    
        Test.stopTest();
    }
    
     static testMethod void unitTestBelgium() {
        allTheDataForThisTestClass();
        list<Account> accounts = [select id, Sales_Organization__c from Account];
        accounts[0].Sales_Organization__c=CRM_AppConstants.TERRITORY_BELGIUM_CODE;
        update accounts;
        
        list<Opportunity> belgiumOpportunities = [select id, name, Couponing_Discount__c ,Start_Date__c, CloseDate, accountId, account.Sales_Organization__c,StageName,
        (SELECT id,name,Quantity, Contribution__c,TotalPrice,Est_Contribution__c,Couponing_Forecast__c  FROM OpportunityLineItems)
                                           from Opportunity
                                           where accountId =: accounts[0].id];
        
        Opportunity plannedOpportunity = belgiumOpportunities[0];
        list<OpportunityLineItem> opplineitem = belgiumOpportunities[0].OpportunityLineItems;
        
        opplineitem[1].UnitPrice = 15000;
        //opplineitem[1].Returns__c = 1;
        opplineitem[1].Coop__c = 1;
        opplineitem[1].Merchandising__c = 1;
        opplineitem[1].Distribution_Cost__c = 1;
        opplineitem[1].Production_Cost__c = 1;
        opplineitem[1].Master_Negative__c = 1;
        
        update opplineitem;
        
        Test.startTest();
                    PageReference pageRef = Page.CRM_DealApproval;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',plannedOpportunity.id);
                    ApexPages.standardController controller = new ApexPages.standardController(plannedOpportunity);
                             
                    CRM_DealApproval pg = new CRM_DealApproval(controller); 
                    
                    CRM_DataObjects.ProductToEdit[] prds=CRM_DealApproval.getLineItems(plannedOpportunity.id);
                    CRM_DealApproval.DealWrapper dw = CRM_DealApproval.getOverlappingDealProducts(plannedOpportunity.id);
                    system.assertEquals(false, dw.showMessage);
                    
                    // ensure that the opp was submitted for approval
                    List<ProcessInstance> processInstances = [select Id, Status from ProcessInstance where TargetObjectId = :plannedOpportunity.id];
                    system.debug('====> Process Instance 1'+processInstances);
                    //System.assertEquals(processInstances.size(),1);
                    
        Test.stopTest();
        
        belgiumOpportunities = [select id, name, Start_Date__c, CloseDate, accountId,Minimum_Contribution__c, account.Sales_Organization__c,StageName,
        (SELECT id,name,Quantity ,UnitPrice , Contribution__c,Minimum_Contribution__c FROM OpportunityLineItems)
                                           from Opportunity
                                           where accountId =: accounts[0].id];
        opplineitem = [Select Id,Contribution__c From OpportunityLineItem Where OpportunityId = :belgiumOpportunities[0].Id ORDER By Contribution__c ASC];
        System.assertEquals(opplineitem[0].Contribution__c,belgiumOpportunities[0].Minimum_Contribution__c);
    }
    
    static testMethod void unitTestOverlappingConditionGermany() {
        allTheDataForThisTestClass();
        list<User> u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true AND ByPassValidationRule__c= False];
        list<Account> accounts = [select id, Sales_Organization__c from Account];
        accounts[0].Sales_Organization__c=CRM_AppConstants.TERRITORY_GERMANY_CODE;
        update accounts;
        //accounts[3].Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
        list<Opportunity> germanyOpportunities = [select id, name, Start_Date__c, CloseDate, accountId, account.Sales_Organization__c,StageName from Opportunity where accountId =: accounts[0].id];
        Set<Id> DealIds = new Set<Id>();
                                           
        Opportunity firstOpportunity = germanyOpportunities[0];
        firstOpportunity.Promo_Start_Date__c= system.today()+20;
        firstOpportunity.Promo_End_Date__c= system.today()+30;
        firstOpportunity.Start_Date__c= system.today()+15;
        firstOpportunity.CloseDate= system.today()+40;
        firstOpportunity.StageName= CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        //firstOpportunity.Customer_Delivery_Date__c= system.today()+15;
        firstOpportunity.No_Demand__c = true;
        DealIds.add(firstOpportunity.id);
        
        Opportunity secondOpportunity = germanyOpportunities[1];
        secondOpportunity.Promo_Start_Date__c= system.today()+20;
        secondOpportunity.Promo_End_Date__c= system.today()+30;
        secondOpportunity.Start_Date__c= system.today()+15;
        secondOpportunity.CloseDate= system.today()+40;
        secondOpportunity.StageName= CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        //secondOpportunity.Customer_Delivery_Date__c= system.today()+15;
        secondOpportunity.No_Demand__c = true;
        DealIds.add(secondOpportunity.id);
        
        update germanyOpportunities;
        
        list<OpportunityLineItem> oppLines = [SELECT id,OpportunityId, ListPrice__c,name,Product2.Name,CurrencyIsoCode, Promoted_Price__c,UnitPrice from OpportunityLineItem where OpportunityId IN :DealIds];
        list<OpportunityLineItem> UpdateoppLines = new list<OpportunityLineItem>();
        
        for(OpportunityLineItem oppProduct :oppLines){
            if(oppProduct.OpportunityId == firstOpportunity.id){
                oppProduct.Promoted_Price__c = 15;
            }else if(oppProduct.OpportunityId == secondOpportunity.id){
                oppProduct.Promoted_Price__c = 150;
            }
            UpdateoppLines.add(oppProduct);
        }
        
        Test.startTest();
            update UpdateoppLines;
            PageReference pageRef = Page.CRM_DealApproval;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',firstOpportunity.id);
            ApexPages.standardController controller = new ApexPages.standardController(firstOpportunity);
                     
            CRM_DealApproval pg = new CRM_DealApproval(controller); 
            CRM_DataObjects.ProductToEdit[] prds=CRM_DealApproval.getLineItems(firstOpportunity.id);
            CRM_DealApproval.DealWrapper dw = CRM_DealApproval.getOverlappingDealProducts(firstOpportunity.id);
            system.assertEquals(false, dw.showMessage);
            
            ApexPages.currentPage().getParameters().put('id',secondOpportunity.id);
            controller = new ApexPages.standardController(secondOpportunity);
            pg = new CRM_DealApproval(controller); 
            CRM_DataObjects.ProductToEdit[] prds1=CRM_DealApproval.getLineItems(secondOpportunity.id);
            dw = CRM_DealApproval.getOverlappingDealProducts(secondOpportunity.id);
            //system.assertEquals(true, dw.showMessage);
                    
        Test.stopTest();
    } 
    
    static testMethod void unitTestOverlappingConditionGermanyDiffPromoPrice() {
        allTheDataForThisTestClass();
        list<User> u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true AND ByPassValidationRule__c= False];
        list<Account> accounts = [select id, Sales_Organization__c from Account];
        accounts[0].Sales_Organization__c=CRM_AppConstants.TERRITORY_GERMANY_CODE;
        update accounts;
        //accounts[3].Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
        list<Opportunity> germanyOpportunities = [select id, name, Start_Date__c, CloseDate, accountId, account.Sales_Organization__c,StageName from Opportunity where accountId =: accounts[0].id];
        Set<Id> dealIDs = new Set<Id>();
                                           
        Opportunity firstOpportunity = germanyOpportunities[0];
        firstOpportunity.Promo_Start_Date__c= system.today()+20;
        firstOpportunity.Promo_End_Date__c= system.today()+30;
        firstOpportunity.Start_Date__c= system.today()+15;
        firstOpportunity.CloseDate= system.today()+40;
        firstOpportunity.StageName= CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        //firstOpportunity.Customer_Delivery_Date__c= system.today()+15;
        firstOpportunity.No_Demand__c = true;
        dealIDs.add(firstOpportunity.id);
        
        Opportunity secondOpportunity = germanyOpportunities[1];
        secondOpportunity.Promo_Start_Date__c= system.today()+20;
        secondOpportunity.Promo_End_Date__c= system.today()+30;
        secondOpportunity.Start_Date__c= system.today()+15;
        secondOpportunity.CloseDate= system.today()+40;
        secondOpportunity.StageName= CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        //secondOpportunity.Customer_Delivery_Date__c= system.today()+15;
        secondOpportunity.No_Demand__c = true;
        dealIDs.add(secondOpportunity.id);
        
        update germanyOpportunities;
        
       /* list<OpportunityLineItem> oppLines1 = [SELECT id, OpportunityId, ListPrice__c,name, Product2.Name, CurrencyIsoCode, Promoted_Price__c,UnitPrice
                                             from OpportunityLineItem
                                             where OpportunityId =: firstOpportunity.id];
        oppLines1[0].Promoted_Price__c=15;
        oppLines1[1].Promoted_Price__c=18;
        update oppLines1;
        
        list<OpportunityLineItem> oppLines2 = [SELECT id, OpportunityId, ListPrice__c,name, Product2.Name, CurrencyIsoCode, Promoted_Price__c,UnitPrice
                                             from OpportunityLineItem
                                             where OpportunityId =: secondOpportunity.id];
        oppLines2[0].Promoted_Price__c=150;
        oppLines2[1].Promoted_Price__c=180;
        update oppLines2; */
        
        list<OpportunityLineItem> oppLines = [SELECT id, OpportunityId, ListPrice__c,name, Product2.Name, CurrencyIsoCode, Promoted_Price__c,UnitPrice
                                             from OpportunityLineItem
                                             where OpportunityId IN: dealIDs];
        
        oppLines[0].Promoted_Price__c=15;
        oppLines[1].Promoted_Price__c=18;
        oppLines[2].Promoted_Price__c=150;
        oppLines[3].Promoted_Price__c=180;
        
        Test.startTest();
            update oppLines;
            PageReference pageRef = Page.CRM_DealApproval;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',firstOpportunity.id);
            ApexPages.standardController controller = new ApexPages.standardController(firstOpportunity);
                     
            CRM_DealApproval pg = new CRM_DealApproval(controller); 
            CRM_DataObjects.ProductToEdit[] prds=CRM_DealApproval.getLineItems(firstOpportunity.id);
            CRM_DealApproval.DealWrapper dw = CRM_DealApproval.getOverlappingDealProducts(firstOpportunity.id);
            system.assertEquals(false, dw.showMessage);
            
            ApexPages.currentPage().getParameters().put('id',secondOpportunity.id);
            controller = new ApexPages.standardController(secondOpportunity);
            pg = new CRM_DealApproval(controller); 
            CRM_DataObjects.ProductToEdit[] prds1=CRM_DealApproval.getLineItems(secondOpportunity.id);
            dw = CRM_DealApproval.getOverlappingDealProducts(secondOpportunity.id);
            //system.assertEquals(true, dw.showMessage);
                    
        Test.stopTest();
    } 
    static testMethod void unitTestPBEPMissMatchFunctionality() {
         allTheDataForThisTestClass();        
        list<Account> accounts = [select id, Sales_Organization__c from Account];
        accounts[0].Sales_Organization__c= CRM_AppConstants.TERRITORY_UK_CODE;
        update accounts;
        
        system.debug('===accounts==='+accounts);
        list<Opportunity> opportunities = [select id, name, Start_Date__c, CloseDate, accountId, account.Sales_Organization__c,StageName 
                                           from Opportunity
                                           where accountId =: accounts[0].id];
        
        //set dates of opp1 and opp2 so that they overlap
        Opportunity newPlannedDeal = opportunities[0];
        newPlannedDeal.Start_Date__c= system.today()-15;
        newPlannedDeal.CloseDate= system.today()+40;
        newPlannedDeal.StageName= CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        update opportunities;
        
        PageReference pageRef = Page.CRM_DealApproval;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',newPlannedDeal.id);
        ApexPages.standardController controller = new ApexPages.standardController(newPlannedDeal);
                 
        CRM_DealApproval pg = new CRM_DealApproval(controller); 
        CRM_DealApproval.getLineItems(newPlannedDeal.id);
       
        Test.startTest();
            CRM_DealApproval.DealWrapper dw = CRM_DealApproval.getPBEPMissMatchDealProducts(newPlannedDeal.id);                    
        Test.stopTest();
        system.assertEquals(true,CRM_DealApproval.PBEPDatesMissmatchAlert);
    }
    
    static testMethod void updateMincontributionSalesFinanceOnDeal_Test() {
        //create accounts
        list<Account> accounts = CRM_TestDataFactory.createAccounts(1, false);
        accounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
        insert accounts;
        
        list<Opportunity> opps = CRM_TestDataFactory.createOpportunitiesWithAccounts(accounts, 1, false);
        opps[0].Start_Date__c = System.today() + 1;
        opps[0].Customer_Delivery_Date__c = System.today() + 2;
        opps[0].Promo_Start_Date__c = System.today() + 3;
        insert opps;
        system.assertEquals(1,opps.size());
        
        List<Product_Group__c> pgs = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> products = CRM_TestDataFactory.createProducts(pgs, 3, true);
        List<PricebookEntry> pbEntries = CRM_TestDataFactory.createPriceBookEntries(products, 1, true);
        
        List<Pricebook_Entry_Period__c> pbeD=CRM_TestDataFactory.createPriceBookEntryPeriods(products, 1, true);
        system.assertEquals(3,pbeD.size());
        
        List<OpportunityLineItem> dealproducts = new List<OpportunityLineItem>();
        integer i = 1;
        for(PricebookEntry pbe : pbEntries){
            OpportunityLineItem objDealProduct = new OpportunityLineItem();
            objDealProduct.OpportunityId = opps[0].Id;
            objDealProduct.PricebookEntryId = pbe.Id;
            objDealProduct.Quantity = 1;
            objDealProduct.UnitPrice = 14.10;
            objDealProduct.Min_Contribution_Finance__c = i*10;
            objDealProduct.Min_Contribution_Sales__c = i*20;
            dealproducts.add(objDealProduct);
            i++;
        }
        insert dealproducts;
        system.assertEquals(3,dealproducts.size());
        Test.startTest();
                    PageReference pageRef = Page.CRM_DealApproval;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',opps[0].id);
                    ApexPages.standardController controller = new ApexPages.standardController(opps[0]);
                             
                    CRM_DealApproval pg = new CRM_DealApproval(controller); 
                    
                    CRM_DataObjects.ProductToEdit[] prds=CRM_DealApproval.getLineItems(opps[0].id);
                    CRM_DealApproval.DealWrapper dw = CRM_DealApproval.getOverlappingDealProducts(opps[0].id);
                    system.assertEquals(false, dw.showMessage);
                    
        Test.stopTest();
                    // ensure that the opp was submitted for approval
                    List<ProcessInstance> processInstances = [select Id, Status from ProcessInstance where TargetObjectId = :opps[0].id];
                    system.debug('====> Process Instance 1'+processInstances);
                    system.assertEquals(processInstances.size(),1);
                    
        
        List<Opportunity> germanDeals = [Select Id,Minimum_Contribution_Finance__c,Minimum_Contribution_Sales__c From Opportunity Where Id IN :opps Limit 1];
        system.assertEquals(10,germanDeals[0].Minimum_Contribution_Finance__c,'Minimum value of Finance contribution from Deal Products');
        system.assertEquals(20,germanDeals[0].Minimum_Contribution_Sales__c,'Minimum value of Sales contribution from Deal Products');
    }
    
        static testmethod void DealPricingValidation_Positive_Test(){ //US#207
        
        allTheDataForThisTestClass();
        Test.startTest();
        
        List<Account> accounts = [select id, Sales_Organization__c from Account];
        accounts[0].Send_Pricing_to_CAS__c = true;
        update accounts;
        
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'Asia1', 'Asia2'}, 2, true);
        system.assertEquals(2,countries.size());    
        
        List<Title__c> titles = CRM_TestDataFactory.createTitles(1, false);
        titles[0].Video_Version__c = '99999999999999';
        titles[0].Digital_Planning__c = 'Yes';
        titles[0].Name = 'TestTitle';
        insert titles;
        system.assertEquals(1,titles.size());
        
        List<Agreement__c> storeFronts = CRM_TestDataFactory.createStoreFronts(accounts, titles, countries, true);
        system.assertEquals(3,storeFronts.size());
        
        List<Pricing__c> prices = CRM_TestDataFactory.createPricings(2, true);
        system.assertEquals(2,prices.size());
        
        List<Language__c> languages = CRM_TestDataFactory.createLanguages(1, true); 
        system.assertEquals(1,languages.size());
        
        List<Local_Title__c> localTitles = CRM_TestDataFactory.createLocalTitles(countries, languages, 1, true); 
        system.assertEquals(2,localTitles.size());
        
         List<Commercial_Avail__c> releasePlans = CRM_TestDataFactory.createReleasePlans(2, titles, storeFronts, localTitles, countries, languages, false);
        
        Integer i=0;
        //List<String> chn = new List<String>{'DTD','EST','Hotel','PPV','VODc','VODi'};
        for(Commercial_Avail__c ca: releasePlans ){
           
            ca.Start_Date__c = Date.valueOf(System.now().addMonths(i));
            ca.End_Date__c = Date.valueOf(System.now().addMonths(i).addDays(10));
            ca.Exclusive_Date__c = Date.valueOf(System.now().addMonths(i));
            ca.Rights_End__c = Date.valueOf(System.now().addMonths(i).addDays(10));     
            ca.status__c ='Confirmed';

            i++;
        }
        insert releasePlans;
        
        List<Client_Avail__c> clientAvails = CRM_TestDataFactory.createClientAvails(prices, releasePlans, localTitles,accounts, storeFronts, 1, false);
        clientAvails[0].Status__c = 'Confirmed';
        clientAvails[0].Price__c = 150;
        insert clientAvails; 
                                             
        List<Opportunity> oppList = [SELECT ID,Name, Start_Date__c, CloseDate, accountId, account.Sales_Organization__c,StageName,account.Send_Pricing_to_CAS__c,RecordTypeId,CurrencyIsoCode,Promo_Start_Date__c,Promo_End_Date__c FROM Opportunity Where AccountId =: accounts[0].id LIMIT 1];
        oppList[0].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
        update oppList;
        Opportunity deal = oppList[0];
        
        List<Pricebook_Entry_Period__c> pbe = [SELECT ID,Price_Book__c,Product__c,Client_Avail__c FROM Pricebook_Entry_Period__c LIMIT 1];
        //system.assertEquals(2,pbe.size());
        pbe[0].Client_Avail__c = clientAvails[0].id;
        update pbe;
        
        List<OpportunityLineItem> oppLines = [SELECT id, OpportunityId, ListPrice__c,name, Product2.Name, CurrencyIsoCode, Promoted_Price__c,UnitPrice,Pricebook_Entry_Period__c,Price_Tier__c,Quantity
                                             from OpportunityLineItem
                                             where OpportunityId =: deal.id];
                                             
         
         
        system.assertEquals(2,oppLines.size());  
        OpportunityLineItem dealPro1 =  oppLines[0];
        dealPro1.Pricebook_Entry_Period__c = pbe[0].id;
        //dealPro1.Price_Tier__c = '100';
        //dealPro1.Promoted_Price__c=15;
        //dealPro1.Quantity = 1;
        //dealPro1.UnitPrice = 14.10;
        //update oppLines;
        
        Test.stopTest();
        
        PageReference pageRef = Page.CRM_DealApproval;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',deal.Id);
        ApexPages.standardController controller = new ApexPages.standardController(oppList[0]);
        CRM_DealApproval pg = new CRM_DealApproval(controller);
        CRM_DealApproval.DealWrapper dw = CRM_DealApproval.getOverlappingDealProducts(oppList[0].id);
        //CRM_DealApproval.getDealPricingValidated(dw,oppLines);
        system.assertEquals(false, dw.showMessage);
                       
        List<ProcessInstance> processInstances = [select Id, Status from ProcessInstance where TargetObjectId = :oppList[0].id];  //ensure that the opp was submitted for approval
        System.assertEquals(processInstances.size(),0); 
        
            
        //Test.stopTest();

    }
}