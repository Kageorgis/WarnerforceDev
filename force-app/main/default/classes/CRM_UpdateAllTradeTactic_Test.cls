/**
   @Author Cognizant
   @name CRM_UpdateAllTradeTactic_Test 
   @CreateDate 9 Feb 2016
   @Description Test class for CRM_UpdateAllTradeTactics
   @Version <1.0>
   @reference Requirement no 
*/ 
@isTest
private class CRM_UpdateAllTradeTactic_Test {
    public static List<Product2> products =new List<Product2>();
    
    static void testData() {
        CRM_Max_Product_Limit__c objCS = new CRM_Max_Product_Limit__c(Name = 'Muti Tactic Planning', Count__c = 50);
        insert objCS;
        
        Integer intCount = 0;
        List<Pricebook2> pricebooks = CRM_TestDataFactory.createPricebooks(3, false); 
        for(Pricebook2 pb : pricebooks) {
            pb.Country__c = intCount == 0 ? 'USA' : intCount == 1 ? 'Can' : 'Mex';
            pb.Product_Type__c = 'Physical';
            intCount++;
        }
        insert pricebooks;
        
        //create account  
        List<Account> lstAccount = CRM_TestDataFactory.createAccounts(1, false);
        lstAccount[0].AccountNumber = '2345681';
        lstAccount[0].Price_Book__c = pricebooks[0].Id;
        insert lstAccount;
        Map<String,PricebookEntry> mapOfProductCodeToPB = new Map<String,PricebookEntry>(); 
          
        intCount = 0;
        products = CRM_TestDataFactory.createProducts(5, false);
        for(Product2 prod : products) {
            prod.ProductCode = '10000' + intCount;
            prod.SAP_Dist_chain_product_Status__c =  CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ACTIVE ;
            prod.isActive = true;
            intCount++;
        } 
        insert products; 
        
        //create deal
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount, 2, false);
        for(Opportunity opp : lstOpportunity) {
            opp.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND;
            opp.Start_date__c = System.today();  
            opp.CloseDate = System.today()+15;  
            opp.Pricebook2Id = pricebooks[0].Id;
        }
        insert lstOpportunity;
        List<Opportunity> opp =[select id,RecordTypeId from Opportunity where id IN: lstOpportunity];
        system.assertEquals(CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND, opp[0].RecordTypeId);
        
        List<PricebookEntry> pricebookentries = CRM_TestDataFactory.createPriceBookEntries(products, 1, true); 
        List<PricebookEntry> pricebookentries1 = CRM_TestDataFactory.createPriceBookEntries(products, 1, false); 
        for(PricebookEntry pbe : pricebookentries1) {
            pbe.Pricebook2Id = pricebooks[0].Id;
        }
        insert pricebookentries1;
        
        System.assertEquals(5,pricebookentries.size());
        List<Pricebook_Entry_Period__c> lstpbep = CRM_TestDataFactory.createPriceBookEntryPeriods(products,1, true);
        List<OpportunityLineItem> dealProds = CRM_TestDataFactory.createDealProductsWithOpportunities(pricebookentries1, lstOpportunity, 5, false);
        
        intCount = 0;
        for(OpportunityLineItem oli : dealProds) {
            oli.Reason__c = intCount < 5 ? 'Feature' : intCount > 4 && intCount < 8 ? 'Display' : 'Cost Markdown Rebate';
            oli.Comments__c = 'Test Comment';
            oli.POS_Forecast__c = 100;
            oli.Co_op_Requested_Amount__c = 100;
            oli.Co_op_Actual_Amount__c = 100;
            oli.Customer_Reference__c = '1000';
            oli.Digital_Membership__c = 'Test Digital Membership';
            oli.Start_date__c =Date.today().addDays(-15);
            oli.End_date__c = Date.today().addDays(15); 
            intCount++;
        }
        insert dealProds;
        System.assertEquals(10,dealProds.size()); 
    }
    
    /**
     *  Method to test the onload tactic to be displayed
    */
    private static testMethod void testSearchTacticsByDate() {
        
        testData();
        List<Opportunity> lstOpp = [SELECT Id FROM Opportunity];
        CRM_UpdateAllTradeTactics obj = new CRM_UpdateAllTradeTactics();
        obj.getUserLocaleLanguage();
        obj.getUserLocaleLowerCase();
        List<OpportunityLineItem> listLineItem = [SELECT id,Opportunity.Id,Opportunity.AccountId,Opportunity.StageName, Opportunity.Pricebook2Id,Opportunity.CurrencyISOCode,Opportunity.Account.Name,Product_Code__c,Status__c,Product2.name,Customer_Reference__c,Start_date__c,End_date__c,Reason__c,Comments__c
                                                    ,POS_Rebate__c,POS_Forecast__c,Pos_actual__c,Accruing_Tactic__c,Co_op_Requested_Amount__c,Co_op_Actual_Amount__c,Commitment_Number__c,Digital_Membership__c
                                                        FROM OpportunityLineItem
                                                        WHERE OpportunityId IN:lstOpp
                                                        AND Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND 
                                                        AND Status__c!=: CRM_AppConstants.TACTIC_STATUS_BUDGET
                                                        ORDER BY Product2.Name];
        system.assertEquals(listLineItem.size(), 10);
        CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
        searchFilter.text = '1000';
        searchFilter.streetDateFrom = system.today()-20;
        searchFilter.streetDateTo = system.today()+20;
        
        Test.startTest();
            CRM_UpdateAllTradeTactics.FinalWrapper lstWrapper  = CRM_UpdateAllTradeTactics.getOpportunityLineItemTactics(searchFilter,'Feature');
            system.assertEquals(5, lstWrapper.dealProdWrap.size());
            checkMappings(lstWrapper, listLineItem);
            searchFilter.streetDateFrom = system.today()-10;
            searchFilter.streetDateTo = system.today()+10;
            CRM_UpdateAllTradeTactics.FinalWrapper lstWrapper1  = CRM_UpdateAllTradeTactics.getOpportunityLineItemTactics(searchFilter,'Feature');
            Test.setCurrentPageReference(Page.CRM_UpdateAllTradeTactics);
            CRM_UpdateAllTradeTactics a= new CRM_UpdateAllTradeTactics();
            a.getChunkSizeForTradeTactics();
        Test.stopTest();
    }
    
    /**
     *  Method to test the onload tactic to be displayed
    */
    private static testMethod void testSearchTacticsByReason() {
        
        testData();
        List<Opportunity> lstOpp = [SELECT Id FROM Opportunity];
        CRM_UpdateAllTradeTactics obj = new CRM_UpdateAllTradeTactics();
        obj.getUserLocaleLanguage();
        obj.getUserLocaleLowerCase();
        List<OpportunityLineItem> listLineItem = [SELECT id,Opportunity.Id,Opportunity.AccountId,Opportunity.StageName, Opportunity.Pricebook2Id,Opportunity.CurrencyISOCode,Opportunity.Account.Name,Product_Code__c,Status__c,Product2.name,Customer_Reference__c,Start_date__c,End_date__c,Reason__c,Comments__c
                                                    ,POS_Rebate__c,POS_Forecast__c,Pos_actual__c,Accruing_Tactic__c,Co_op_Requested_Amount__c,Co_op_Actual_Amount__c,Commitment_Number__c,Digital_Membership__c
                                                        FROM OpportunityLineItem
                                                        WHERE OpportunityId IN:lstOpp
                                                        AND Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND 
                                                        AND Status__c!=: CRM_AppConstants.TACTIC_STATUS_BUDGET
                                                        ORDER BY Product2.Name];
        system.assertEquals(listLineItem.size(), 10);
        CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
        
        Test.startTest();
            CRM_UpdateAllTradeTactics.FinalWrapper lstWrapper  = CRM_UpdateAllTradeTactics.getOpportunityLineItemTactics(searchFilter,'Display');
            system.assertEquals(3, lstWrapper.dealProdWrap.size());
            checkMappings(lstWrapper, listLineItem);
            Test.setCurrentPageReference(Page.CRM_UpdateAllTradeTactics);
            CRM_UpdateAllTradeTactics a= new CRM_UpdateAllTradeTactics();
            a.getChunkSizeForTradeTactics();
        Test.stopTest();
    }
    
    /**
     *  Method to test the onload tactic to be displayed
    */
    private static testMethod void testSearchTacticsByQuickSearchText() {
        
        testData();
        List<Opportunity> lstOpp = [SELECT Id FROM Opportunity];
        CRM_UpdateAllTradeTactics obj = new CRM_UpdateAllTradeTactics();
        obj.getUserLocaleLanguage();
        obj.getUserLocaleLowerCase();
        List<OpportunityLineItem> listLineItem = [SELECT id,Opportunity.Id,Opportunity.AccountId,Opportunity.StageName, Opportunity.Pricebook2Id,Opportunity.CurrencyISOCode,Opportunity.Account.Name,Product_Code__c,Status__c,Product2.name,Customer_Reference__c,Start_date__c,End_date__c,Reason__c,Comments__c
                                                    ,POS_Rebate__c,POS_Forecast__c,Pos_actual__c,Accruing_Tactic__c,Co_op_Requested_Amount__c,Co_op_Actual_Amount__c,Commitment_Number__c,Digital_Membership__c
                                                        FROM OpportunityLineItem
                                                        WHERE OpportunityId IN:lstOpp
                                                        AND Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND 
                                                        AND Status__c!=: CRM_AppConstants.TACTIC_STATUS_BUDGET
                                                        ORDER BY Product2.Name];
        
        system.assertEquals(listLineItem.size(), 10);
        CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
        searchFilter.text = '100001';
        
        List<Id> fixedSearchResults = new List<Id>();
        for(Product2 prod : [select Id from Product2]){
            fixedSearchResults.add(prod.Id);
        }
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.startTest();
            CRM_UpdateAllTradeTactics.FinalWrapper lstWrapper  = CRM_UpdateAllTradeTactics.getOpportunityLineItemTactics(searchFilter,'');
            system.assertEquals(2, lstWrapper.dealProdWrap.size());
            checkMappings(lstWrapper, listLineItem);
        Test.stopTest();
    }
    
    /**
     *  Method to test the onload tactic to be displayed
    */
    private static testMethod void testSearchTacticsByAccountNumber() {
        
        testData();
        List<Opportunity> lstOpp = [SELECT Id FROM Opportunity];
        CRM_UpdateAllTradeTactics obj = new CRM_UpdateAllTradeTactics();
        obj.getUserLocaleLanguage();
        obj.getUserLocaleLowerCase();
        List<OpportunityLineItem> listLineItem = [SELECT id,Opportunity.Id,Opportunity.AccountId, Opportunity.Account.AccountNumber,Opportunity.StageName, Opportunity.Pricebook2Id,Opportunity.CurrencyISOCode,Opportunity.Account.Name,Product_Code__c,Status__c,Product2.name,Customer_Reference__c,Start_date__c,End_date__c,Reason__c,Comments__c
                                                    ,POS_Rebate__c,POS_Forecast__c,Pos_actual__c,Accruing_Tactic__c,Co_op_Requested_Amount__c,Co_op_Actual_Amount__c,Commitment_Number__c,Digital_Membership__c
                                                        FROM OpportunityLineItem
                                                        WHERE OpportunityId IN:lstOpp
                                                        AND Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND 
                                                        AND Status__c!=: CRM_AppConstants.TACTIC_STATUS_BUDGET
                                                        ORDER BY Product2.Name];
        system.assertEquals(listLineItem.size(), 10);
        CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
        searchFilter.text = '2345681';
        
        List<Id> fixedSearchResults = new List<Id>();
        for(Account prod : [select Id, AccountNumber from Account]){
            fixedSearchResults.add(prod.Id);
        }
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.startTest();
            CRM_UpdateAllTradeTactics.FinalWrapper lstWrapper  = CRM_UpdateAllTradeTactics.getOpportunityLineItemTactics(searchFilter,'');
            system.assertEquals(10, lstWrapper.dealProdWrap.size());
            checkMappings(lstWrapper, listLineItem);
        Test.stopTest();
    }
    
    /**
     *  Method to test the onload tactic to be displayed
    */
    private static testMethod void testBudgetTactics() {
        
        testData();
        List<Opportunity> lstOpp = [SELECT Id FROM Opportunity];
        CRM_UpdateAllTradeTactics obj = new CRM_UpdateAllTradeTactics();
        obj.getUserLocaleLanguage();
        obj.getUserLocaleLowerCase();
        List<OpportunityLineItem> listLineItem = [SELECT id,Opportunity.Id,Opportunity.AccountId, Opportunity.Account.AccountNumber,Opportunity.StageName, Opportunity.Pricebook2Id,Opportunity.CurrencyISOCode,Opportunity.Account.Name,Product_Code__c,Status__c,Product2.name,Customer_Reference__c,Start_date__c,End_date__c,Reason__c,Comments__c
                                                    ,POS_Rebate__c,POS_Forecast__c,Pos_actual__c,Accruing_Tactic__c,Co_op_Requested_Amount__c,Co_op_Actual_Amount__c,Commitment_Number__c,Digital_Membership__c
                                                        FROM OpportunityLineItem
                                                        WHERE OpportunityId IN:lstOpp
                                                        AND Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND 
                                                        AND Status__c!=: CRM_AppConstants.TACTIC_STATUS_BUDGET
                                                        ORDER BY Product2.Name];
        listLineItem[0].Reason__c = 'Budget';
        listLineItem[0].Co_op_Budget__c = 12345;
        update listLineItem[0];
        system.assertEquals(listLineItem.size(), 10);
        CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
        searchFilter.text = '2345681';
        
        List<Id> fixedSearchResults = new List<Id>();
        for(Account prod : [select Id, AccountNumber from Account]){
            fixedSearchResults.add(prod.Id);
        }
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.startTest();
            CRM_UpdateAllTradeTactics.FinalWrapper lstWrapper  = CRM_UpdateAllTradeTactics.getOpportunityLineItemTactics(searchFilter,'');
            system.assertEquals(9, lstWrapper.dealProdWrap.size());
            checkMappings(lstWrapper, listLineItem);
        Test.stopTest();
    }
    
    public static void checkMappings(CRM_UpdateAllTradeTactics.FinalWrapper lstWrapper, List<OpportunityLineItem> listLineItem) {
        for(OpportunityLineItem lineItem :listLineItem) {
            for(CRM_UpdateAllTradeTactics.OpportunityLineItemWrapper lineItemWrapper : lstWrapper.dealProdWrap){
                if(lineItemWrapper.existingId == lineItem.id){
                    system.assertEquals(lineItemWrapper.existingId , lineItem.id);
                    system.assertEquals(lineItemWrapper.productCode , lineItem.Product_Code__c);
                    system.assertEquals(lineItemWrapper.productName , lineItem.Product2.name);
                    system.assertEquals(lineItemWrapper.commitmentNum , lineItem.Commitment_Number__c);
                    system.assertEquals(lineItemWrapper.startDate , String.valueOf(lineItem.Start_date__c));
                    system.assertEquals(lineItemWrapper.endDate , String.valueOf(lineItem.End_date__c));
                    system.assertEquals(lineItemWrapper.coopReason , lineItem.Reason__c );
                    system.assertEquals(lineItemWrapper.coopComments , lineItem.Comments__c);
                    system.assertEquals(lineItemWrapper.posRebate , lineItem.POS_Rebate__c);
                    system.assertEquals(lineItemWrapper.posForecast , lineItem.POS_Forecast__c );
                    system.assertEquals(lineItemWrapper.coopReqAmount , lineItem.Co_op_Requested_Amount__c);
                    system.assertEquals(lineItemWrapper.posActual, lineItem.Pos_actual__c);
                    system.assertEquals(lineItemWrapper.coopActualAmt , lineItem.Co_op_Actual_Amount__c);
                    system.assertEquals(lineItemWrapper.status , lineItem.Status__c);
                    system.assertEquals(lineItemWrapper.custReference , lineItem.Customer_Reference__c); 
                    system.assertEquals(lineItemWrapper.digitalMembership , lineItem.Digital_Membership__c);
                    system.assertEquals(lineItemWrapper.accruingTactic , lineItem.Accruing_Tactic__c); 
                    system.assertEquals(lineItemWrapper.accruingTactic , lineItem.Accruing_Tactic__c); 
                }
            } 
        }
    }
    
    /**
     *  Method to test the validations for tactic to be saved
    */
    private static testMethod void testSetDataValidationsUploadExtractTradeTactics() {
        Test.startTest();
        
        testData();
        List<Opportunity> lstOpp = [SELECT Id,AccountId,StageName FROM Opportunity];
        CRM_UpdateAllTradeTactics obj = new CRM_UpdateAllTradeTactics(); 
        CRM_UpdateAllTradeTactics.FinalWrapper finalWrapper = new CRM_UpdateAllTradeTactics.FinalWrapper();
        List<CRM_UpdateAllTradeTactics.OpportunityLineItemWrapper> lstWrapper = new List<CRM_UpdateAllTradeTactics.OpportunityLineItemWrapper>();
        
        List<OpportunityLineItem> listLineItem = [SELECT Id,Opportunity.Id,Opportunity.AccountId,Opportunity.StageName, Opportunity.Pricebook2Id,Opportunity.CurrencyISOCode,Opportunity.Account.Name,Product_Code__c,Status__c,Product2.name,Customer_Reference__c,Start_date__c,
                                                         End_date__c,Reason__c,Comments__c,POS_Rebate__c,POS_Forecast__c,Pos_actual__c,Accruing_Tactic__c,
                                                         Co_op_Requested_Amount__c,Co_op_Actual_Amount__c,Commitment_Number__c,Digital_Membership__c
                                                    FROM OpportunityLineItem
                                                  WHERE OpportunityId = :lstOpp[0].Id 
                                                     AND Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND 
                                                ORDER BY Product2.Name];
        Integer intCount = 0;
        for(OpportunityLineItem oli : listLineItem) {
            lstWrapper.add(createWrapper(oli, intCount));
            intCount++;
        }
        
        lstWrapper[1].isRowModified = true;
        lstWrapper[1].coopReason = 'POS Rebate';
        lstWrapper[1].posRebate = 11;
        lstWrapper[1].posForecast = null; 
        lstWrapper[1].coopReqAmount=12;
        lstWrapper[1].coopActualAmt=12;
        lstWrapper[1].validation = null;
        lstWrapper[1].status = 'Planned';
        
        system.assertEquals(lstOpp[0].stagename,'Planned');
        system.assertEquals(lstWrapper[1].coopReqAmount, lstWrapper[1].coopActualAmt);
        system.assertEquals(lstWrapper[1].coopReason,CRM_AppConstants.REASON_POS_REBATE );
        system.assertEquals(lstWrapper[1].status,'Planned');
        
        List<CRM_UpdateAllTradeTactics.OpportunityLineItemWrapper> lstWrapper2  = CRM_UpdateAllTradeTactics.setOpportunityLineItemTactics(lstWrapper, false);
        System.assertequals(System.Label.CRM_Pos_Rebate_Forecast_Man,lstWrapper2[1].validation);  
         
        lstWrapper[2].isRowModified = true;
        lstWrapper[2].posRebate = 11;
        lstWrapper[2].posForecast = null; 
        lstWrapper[2].validation = null;
        lstWrapper[2].status = 'Planned';
        system.assertEquals(lstOpp[0].stagename,'Planned');
        system.assertEquals(lstWrapper[2].status,'Planned');
        
        List<CRM_UpdateAllTradeTactics.OpportunityLineItemWrapper> lstWrapper3  = CRM_UpdateAllTradeTactics.setOpportunityLineItemTactics(lstWrapper, false);
        System.assertequals(System.Label.CRM_Non_Pos_Rebate_Error,lstWrapper3[2].validation);  
      
        Test.stopTest();
    }
    
    /**
     *  Defect#4721 - Method to test the validations for tactic to be saved
    */
    private static testMethod void testSetDataValidationsUploadExtractTradeTactics_2() {
        testData();
        List<Opportunity> lstOpp = [SELECT Id,Stagename FROM Opportunity];
        CRM_UpdateAllTradeTactics obj = new CRM_UpdateAllTradeTactics();
        List<OpportunityLineItem> listLineItem = [SELECT Id,Opportunity.Id,Opportunity.AccountId,Opportunity.StageName, Opportunity.Pricebook2Id,Opportunity.CurrencyISOCode,Opportunity.Account.Name,Product_Code__c,Status__c,Product2.name,Customer_Reference__c,Start_date__c,
                                                         End_date__c,Reason__c,Comments__c,POS_Rebate__c,POS_Forecast__c,Pos_actual__c,Accruing_Tactic__c,
                                                         Co_op_Requested_Amount__c,Co_op_Actual_Amount__c,Commitment_Number__c,Digital_Membership__c
                                                    FROM OpportunityLineItem
                                                  WHERE OpportunityId = :lstOpp[0].Id 
                                                     AND Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND 
                                                ORDER BY Product2.Name];
        List<CRM_UpdateAllTradeTactics.OpportunityLineItemWrapper> lstWrapper1 = new List<CRM_UpdateAllTradeTactics.OpportunityLineItemWrapper>();
        Integer intCount = 0;
        for(OpportunityLineItem oli : listLineItem) {
            lstWrapper1.add(createWrapper(oli, intCount));
            intCount++;
        }
        products[1].SAP_Dist_chain_product_Status__c ='04';
        update products[0];
        
        lstWrapper1[1].isRowModified = true;
        lstWrapper1[1].coopComments = 'My Comment1';
        lstWrapper1[3].isRowModified = true;
        lstWrapper1[3].coopComments = 'My Comment2';
        system.assertEquals('Test Comment', listLineItem[1].Comments__c);
        system.assertEquals('Test Comment', listLineItem[3].Comments__c);
        
        Test.startTest();
        List<CRM_UpdateAllTradeTactics.OpportunityLineItemWrapper> lstWrapper2  = CRM_UpdateAllTradeTactics.setOpportunityLineItemTactics(lstWrapper1,  false);
        Test.stopTest();
        
        system.assertEquals('Updated', lstWrapper2[1].validation);
        system.assertEquals('Updated', lstWrapper2[3].validation);
        List<OpportunityLineItem> listLineItem1 = [SELECT Id, Comments__c FROM OpportunityLineItem WHERE OpportunityId = :lstOpp[0].Id ORDER BY Product2.Name];
        system.assertEquals('My Comment1', listLineItem1[1].Comments__c);
        system.assertEquals('My Comment2', listLineItem1[3].Comments__c);
    }
    
    /**
     *  Method to test save tactics
    */
     private static testMethod void testSaveTacticDataUploadExtractTradeTactics() {
        Test.startTest();
        
        testData();
        List<Opportunity> lstOpp = [SELECT Id FROM Opportunity];
        CRM_UpdateAllTradeTactics obj = new CRM_UpdateAllTradeTactics(); 
        List<CRM_UpdateAllTradeTactics.OpportunityLineItemWrapper> lstWrapper = new List<CRM_UpdateAllTradeTactics.OpportunityLineItemWrapper>();
        
        Integer intCount = 0;
        for(OpportunityLineItem oli : [SELECT id,Opportunity.Id,Opportunity.AccountId,Opportunity.StageName, Opportunity.Pricebook2Id,Opportunity.CurrencyISOCode,Opportunity.Account.Name,Product_Code__c,Status__c,Product2.name,Customer_Reference__c,Start_date__c,End_date__c,Reason__c,Comments__c
                                ,POS_Rebate__c,POS_Forecast__c,Co_op_Requested_Amount__c,Accruing_Tactic__c,Co_op_Actual_Amount__c,Commitment_Number__c,Digital_Membership__c
                                FROM OpportunityLineItem WHERE OpportunityId =: lstOpp[0].Id]) {
            lstWrapper.add(createWrapper(oli, intCount));
            intCount++;
        }
       
        for(Integer i=0; i<intCount; i++) {
            lstWrapper[i].isRowModified = true;
            lstWrapper[i].validation = null;
            lstWrapper[i].coopReason = 'Feature'; 
            lstWrapper[i].posRebate =null;
            lstWrapper[i].posForecast=null;
            lstWrapper[i].startDate = System.today().format();
            lstWrapper[i].endDate = (System.Today()+31).format();
            system.assertEquals(lstWrapper[i].accruingTactic, true);  
        }
        
        List<CRM_UpdateAllTradeTactics.OpportunityLineItemWrapper> lstWrapperAfter = CRM_UpdateAllTradeTactics.setOpportunityLineItemTactics(lstWrapper, false);
        System.assertequals('Updated',lstWrapperAfter[0].validation);  
        System.assertequals('Updated',lstWrapperAfter[1].validation);  
        lstWrapper[3].isRowRemoved = true;
        CRM_UpdateAllTradeTactics.setOpportunityLineItemTactics(lstWrapper, false);
        
        obj.getUserLocale();
        obj.getUserDateFormat();
        CRM_UpdateAllTradeTactics.getFilterPicklistValues('OpportunityLineItem','Reason__c','Budget');
        
        Test.stopTest();
    }
    
     /**
     *  Method to test save tactics
    */
     private static testMethod void testValidation2TacticDataUploadExtractTradeTactics() {
        Test.startTest();
        
        testData();
        List<Opportunity> lstOpp = [SELECT Id FROM Opportunity];
        CRM_UpdateAllTradeTactics obj = new CRM_UpdateAllTradeTactics(); 
        List<CRM_UpdateAllTradeTactics.OpportunityLineItemWrapper> lstWrapper = new List<CRM_UpdateAllTradeTactics.OpportunityLineItemWrapper>();
        
        Integer intCount = 0;
        for(OpportunityLineItem oli : [SELECT id,Opportunity.Id,Opportunity.AccountId,Opportunity.StageName, Opportunity.Pricebook2Id,Opportunity.CurrencyISOCode,Opportunity.Account.Name,Product_Code__c,Status__c,Product2.name,Customer_Reference__c,Start_date__c,End_date__c,Reason__c,Comments__c
                                ,POS_Rebate__c,POS_Forecast__c,Co_op_Requested_Amount__c,Co_op_Actual_Amount__c,Accruing_Tactic__c, Commitment_Number__c,Digital_Membership__c
                                FROM OpportunityLineItem WHERE OpportunityId =: lstOpp[0].Id]) {
            lstWrapper.add(createWrapper(oli, intCount));
            intCount++;
        }
         
        for(Integer i=0; i<intCount; i++) {
            lstWrapper[i].isRowModified = true;
            lstWrapper[i].validation = null;
            lstWrapper[i].coopReason = 'Feature'; 
            lstWrapper[i].posRebate =null;
            lstWrapper[i].posForecast=null;
            lstWrapper[i].startDate = System.today().format();
            lstWrapper[i].endDate = (System.Today()+31).format(); 
            lstWrapper[i].accruingTactic=false;
        }
        
        //for test scenario validation: (!CRM_AppConstants.NON_ACCRUING_TACTIC_REASONS.contains(tacticWrapper.coopReason) && !CRM_AppConstants.ACCRUING_TACTIC_REASONS.contains(tacticWrapper.coopReason)){
        lstWrapper[1].coopReason='Digital Media Spend';
        lstWrapper[1].accruingTactic =true;
        //check mandatory fields        
        lstWrapper[2].productCode = '';
        
        lstWrapper[3].productCode =lstWrapper[0].productCode; 
        lstWrapper[3].startDate = System.today().format();
        lstWrapper[3].endDate = (System.Today()+31).format(); 
        lstWrapper[3].coopReason='abc';
        lstWrapper[3].accruingTactic =true;
        
        List<CRM_UpdateAllTradeTactics.OpportunityLineItemWrapper> lstWrapperAfter = CRM_UpdateAllTradeTactics.setOpportunityLineItemTactics(lstWrapper, false);
        System.assertequals( system.label.CRM_UploadExtractTactic_Coop_reason_ErrorMsg,lstWrapperAfter[0].validation);  
        System.assertequals( system.label.CRM_UploadExtractTactic_Coop_reason_ErrorMsg,lstWrapperAfter[1].validation); 
        System.assertequals( system.label.CRM_UploadExtractTactic_Coop_reason_ErrorMsg,lstWrapperAfter[3].validation); 
        System.assertequals( system.label.CRM_UploadExtractTactic_MandatoryFields_Validation,lstWrapperAfter[2].validation); 
        Test.stopTest();
    }
    
    private static CRM_UpdateAllTradeTactics.OpportunityLineItemWrapper createWrapper(OpportunityLineItem lineItem, Integer intCount) {
        CRM_UpdateAllTradeTactics.OpportunityLineItemWrapper lineItemWrapper = new CRM_UpdateAllTradeTactics.OpportunityLineItemWrapper();
        lineItemWrapper.existingId = intCount == 2 ? null : lineItem.id; 
        // lineItemWrapper.accountName = lineItem.Opportunity.Account.Name;
        lineItemWrapper.productCode = lineItem.Product_Code__c;
        lineItemWrapper.productName = lineItem.Product2.name;
        lineItemWrapper.commitmentNum = lineItem.Commitment_Number__c;
        lineItemWrapper.startDate = intCount == 0 ? '' : lineItem.Start_date__c.format();
        lineItemWrapper.endDate = intCount == 0 ? '' : lineItem.End_date__c.format();
        lineItemWrapper.coopReason = lineItem.Reason__c ;
        lineItemWrapper.coopComments = lineItem.Comments__c;
        lineItemWrapper.posRebate = lineItem.POS_Rebate__c;
        lineItemWrapper.posForecast = lineItem.POS_Forecast__c ;
        lineItemWrapper.coopReqAmount = lineItem.Co_op_Requested_Amount__c;
        lineItemWrapper.posActual= lineItem.Co_op_Actual_Amount__c;
        lineItemWrapper.coopActualAmt = lineItem.Co_op_Actual_Amount__c;
        lineItemWrapper.status = lineItem.Status__c;
        lineItemWrapper.custReference = lineItem.Customer_Reference__c; 
        lineItemWrapper.digitalMembership =lineItem.Digital_Membership__c;
        lineItemWrapper.accruingTactic = lineItem.Accruing_Tactic__c;
        lineItemWrapper.deal = lineItem.Opportunity;
        return lineItemWrapper;
    }
}