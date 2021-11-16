/**
   @Author Cognizant
   @name CRM_UploadExtractTradeTactics_Test 
   @CreateDate 9 Feb 2016
   @Description Test class for CRM_UploadExtractTradeTactics
   @Version <1.0>
   @reference Requirement no 
*/
@isTest
private class CRM_UploadExtractTradeTactics_Test {
    public static List<Product2> products =new List<Product2>();
    
    static void testData() {
        //create account  
        List<Account> lstAccount = CRM_TestDataFactory.createAccounts(1, true);
        Map<String,PricebookEntry> mapOfProductCodeToPB = new Map<String,PricebookEntry>(); 
        //create deal
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount, 1, false);
        lstOpportunity[0].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND;
        lstOpportunity[0].Start_date__c = System.today();  
        lstOpportunity[0].CloseDate = System.today()+15;  
        insert lstOpportunity;
        List<Opportunity> opp =[select id,RecordTypeId from Opportunity where id IN: lstOpportunity];
        system.assertEquals(CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND, opp[0].RecordTypeId);
          
        integer intCount = 0;
        products = CRM_TestDataFactory.createProducts(5, false);
        for(Product2 prod : products) {
            prod.ProductCode = '10000' + intCount;
            prod.SAP_Dist_chain_product_Status__c =  CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ACTIVE ;
            prod.isActive = true;
            intCount++;
        } 
        insert products; 
        
        List<PricebookEntry> pricebookentries = CRM_TestDataFactory.createPriceBookEntries(products, 1, true); 
        System.assertEquals(5,pricebookentries.size());
        List<OpportunityLineItem> dealProds = CRM_TestDataFactory.createDealProductsWithOpportunities(pricebookentries, lstOpportunity, 5, false);
        
        for(OpportunityLineItem oli : dealProds) {
            oli.Reason__c = 'Feature';
            oli.Comments__c = 'Test Comment';
            oli.POS_Forecast__c = 100;
            oli.Co_op_Requested_Amount__c = 100;
            oli.Co_op_Actual_Amount__c = 100;
            oli.Customer_Reference__c = 'Test Reference';
            oli.Digital_Membership__c = 'Test Digital Membership';
            oli.Start_date__c =Date.today().addDays(-15);
            oli.End_date__c = Date.today().addDays(15); 
        }
        insert dealProds;
        System.assertEquals(5,dealProds.size()); 
    }
    
    /**
     *  Method to test the onload tactic to be displayed
    */
    private static testMethod void testOnloadGetDataUploadExtractTradeTactics() {
        
        testData();
        List<Opportunity> lstOpp = [SELECT Id FROM Opportunity];
        Apexpages.standardController stdCtrl = new Apexpages.standardController(lstOpp[0]);
        CRM_UploadExtractTradeTactics obj = new CRM_UploadExtractTradeTactics(stdCtrl);
        List<OpportunityLineItem> listLineItem = [SELECT id,Opportunity.Account.Name,Product_Code__c,Status__c,Product2.name,Customer_Reference__c,Start_date__c,End_date__c,Reason__c,Comments__c
                                                    ,POS_Rebate__c,POS_Forecast__c,Pos_actual__c,Accruing_Tactic__c,Co_op_Requested_Amount__c,Co_op_Actual_Amount__c,Commitment_Number__c,Digital_Membership__c
                                                        FROM OpportunityLineItem
                                                        WHERE OpportunityId = :lstOpp[0].id 
                                                        AND Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND 
                                                        AND Status__c!=: CRM_AppConstants.TACTIC_STATUS_BUDGET
                                                        ORDER BY Product2.Name];
        Test.startTest();
            List<CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper> lstWrapper  = CRM_UploadExtractTradeTactics.getOpportunityLineItemTactics(lstOpp[0].Id);
            for(OpportunityLineItem lineItem :listLineItem){
                for(CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper lineItemWrapper : lstWrapper){
                    if(lineItemWrapper.existingId == lineItem.id){
                        system.assertEquals(lineItemWrapper.existingId , lineItem.id);
                        system.assertEquals(lineItemWrapper.accountName , lineItem.Opportunity.Account.Name);
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
                    }
                } 
            }
            Test.setCurrentPageReference(Page.CRM_UploadExtractTradeTactics);
            ApexPages.StandardController scc = new ApexPages.StandardController(lstOpp[0]);
            CRM_UploadExtractTradeTactics a= new CRM_UploadExtractTradeTactics(scc);
            a.getChunkSizeForTradeTactics();
        Test.stopTest();
    }
    
    /**
     *  Method to test the onload tactic to be displayed
    */
    private static testMethod void testOnloadGetDataUploadExtractTradeTacticsCons() {
        
        testData();
        List<Opportunity> lstOpp = [SELECT Id,Stagename FROM Opportunity];
        Apexpages.standardController stdCtrl = new Apexpages.standardController(lstOpp[0]);
        CRM_UploadExtractTradeTactics obj = new CRM_UploadExtractTradeTactics(stdCtrl);
        List<OpportunityLineItem> listLineItem = [SELECT id,Opportunity.Account.Name,Product_Code__c,Status__c,Product2.name,Customer_Reference__c,Start_date__c,End_date__c,Reason__c,Comments__c
                                                    ,POS_Rebate__c,POS_Forecast__c,Pos_actual__c,Accruing_Tactic__c,Co_op_Requested_Amount__c,Co_op_Actual_Amount__c,Commitment_Number__c,Digital_Membership__c
                                                        FROM OpportunityLineItem
                                                        WHERE OpportunityId = :lstOpp[0].id 
                                                        AND Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND 
                                                        AND Status__c!=: CRM_AppConstants.TACTIC_STATUS_BUDGET
                                                        ORDER BY Product2.Name];
            Test.startTest();
               System.runAs(createUser()){
                for(Opportunity deal: lstOpp){
                    deal.StageName = CRM_AppConstants.TACTIC_STATUS_BUDGET;
                }
                update lstOpp; 
            }
        
            Test.setCurrentPageReference(Page.CRM_UploadExtractTradeTactics);
            ApexPages.StandardController scc = new ApexPages.StandardController(lstOpp[0]);
            CRM_UploadExtractTradeTactics a= new CRM_UploadExtractTradeTactics(scc);
            a.getChunkSizeForTradeTactics();
        Test.stopTest();
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
        return testUser;
    }
    /**
     *  Method to test the validations for tactic to be saved
    */
    private static testMethod void testSetDataValidationsUploadExtractTradeTactics() {
        Test.startTest();
        
        testData();
        List<Opportunity> lstOpp = [SELECT Id,AccountId,StageName FROM Opportunity];
        Apexpages.standardController stdCtrl = new Apexpages.standardController(lstOpp[0]);
        CRM_UploadExtractTradeTactics obj = new CRM_UploadExtractTradeTactics(stdCtrl); 
        List<CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper> lstWrapper = new List<CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper>();
        
        Integer intCount = 4;
        for(Integer i=0; i<intCount; i++) {
            OpportunityLineItem oli =new OpportunityLineItem();
            lstWrapper.add(createStaticWrapper(lstOpp[0].AccountId,'10000'+i, i)); 
        }
        
        lstWrapper[0].isRowModified = true;
        lstWrapper[0].productCode = '847154654';
        List<CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper> lstWrapper1  = CRM_UploadExtractTradeTactics.setOpportunityLineItemTactics(lstWrapper, lstOpp[0].Id, false);
        System.assertequals(System.Label.CRM_Product_Not_Exist,lstWrapper1[0].validation);
        
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
        
        List<CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper> lstWrapper2  = CRM_UploadExtractTradeTactics.setOpportunityLineItemTactics(lstWrapper, lstOpp[0].Id, false);
        System.assertequals(System.Label.CRM_Pos_Rebate_Forecast_Man,lstWrapper2[1].validation);  
         
        lstWrapper[2].isRowModified = true;
        lstWrapper[2].posRebate = 11;
        lstWrapper[2].posForecast = null; 
        lstWrapper[2].validation = null;
        lstWrapper[2].status = 'Planned';
        system.assertEquals(lstOpp[0].stagename,'Planned');
        system.assertEquals(lstWrapper[2].status,'Planned');
        
        List<CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper> lstWrapper3  = CRM_UploadExtractTradeTactics.setOpportunityLineItemTactics(lstWrapper, lstOpp[0].Id, false);
        System.assertequals(System.Label.CRM_Non_Pos_Rebate_Error,lstWrapper3[2].validation);  
        
        products[0].SAP_Dist_chain_product_Status__c ='22';
        update products[0];
        lstWrapper[3].productCode ='100000';
        lstWrapper[3].isRowModified = true;
        lstWrapper[3].validation = null;
        List<CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper> lstWrapper4  = CRM_UploadExtractTradeTactics.setOpportunityLineItemTactics(lstWrapper, lstOpp[0].Id, false); 
        System.assertequals(System.Label.CRM_UploadBudget_Invalid_SAP_Dist_Chain_Status,lstWrapper4[3].validation);  
        Test.stopTest();
    }
    
    /**
     *  Defect#4721 - Method to test the validations for tactic to be saved
    */
    private static testMethod void testSetDataValidationsUploadExtractTradeTactics_2() {
        testData();
        List<Opportunity> lstOpp = [SELECT Id,Stagename FROM Opportunity];
        Apexpages.standardController stdCtrl = new Apexpages.standardController(lstOpp[0]);
        CRM_UploadExtractTradeTactics obj = new CRM_UploadExtractTradeTactics(stdCtrl);
        List<OpportunityLineItem> listLineItem = [SELECT Id,Opportunity.Account.Name,Product_Code__c,Status__c,Product2.name,Customer_Reference__c,Start_date__c,
                                                         End_date__c,Reason__c,Comments__c,POS_Rebate__c,POS_Forecast__c,Pos_actual__c,Accruing_Tactic__c,
                                                         Co_op_Requested_Amount__c,Co_op_Actual_Amount__c,Commitment_Number__c,Digital_Membership__c
                                                    FROM OpportunityLineItem
                                                   WHERE OpportunityId = :lstOpp[0].Id 
                                                     AND Opportunity.RecordTypeId =: CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND 
                                                ORDER BY Product2.Name];
        List<CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper> lstWrapper1 = new List<CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper>();
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
        List<CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper> lstWrapper2  = CRM_UploadExtractTradeTactics.setOpportunityLineItemTactics(lstWrapper1, lstOpp[0].Id, false);
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
        Apexpages.standardController stdCtrl = new Apexpages.standardController(lstOpp[0]);
        CRM_UploadExtractTradeTactics obj = new CRM_UploadExtractTradeTactics(stdCtrl); 
        List<CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper> lstWrapper = new List<CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper>();
        
        Integer intCount = 0;
        for(OpportunityLineItem oli : [SELECT id,Opportunity.Account.Name,Product_Code__c,Status__c,Product2.name,Customer_Reference__c,Start_date__c,End_date__c,Reason__c,Comments__c
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
        
        List<CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper> lstWrapperAfter = CRM_UploadExtractTradeTactics.setOpportunityLineItemTactics(lstWrapper, lstOpp[0].Id, false);
        System.assertequals('Updated',lstWrapperAfter[0].validation);  
        System.assertequals('Updated',lstWrapperAfter[1].validation);  
        System.assertequals('Created',lstWrapperAfter[2].validation);  
        lstWrapper[3].isRowRemoved = true;
        CRM_UploadExtractTradeTactics.setOpportunityLineItemTactics(lstWrapper, lstOpp[0].Id, false);
        
        obj.getUserLocale();
        obj.getUserDateFormat();
        CRM_UploadExtractTradeTactics.getFilterPicklistValues('OpportunityLineItem','Reason__c','Budget');
        
        Test.stopTest();
    }
    
     /**
     *  Method to test save tactics
    */
     private static testMethod void testValidation2TacticDataUploadExtractTradeTactics() {
        Test.startTest();
        
        testData();
        List<Opportunity> lstOpp = [SELECT Id FROM Opportunity];
        Apexpages.standardController stdCtrl = new Apexpages.standardController(lstOpp[0]);
        CRM_UploadExtractTradeTactics obj = new CRM_UploadExtractTradeTactics(stdCtrl); 
        List<CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper> lstWrapper = new List<CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper>();
        
        Integer intCount = 0;
        for(OpportunityLineItem oli : [SELECT id,Opportunity.Account.Name,Product_Code__c,Status__c,Product2.name,Customer_Reference__c,Start_date__c,End_date__c,Reason__c,Comments__c
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
        
        List<CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper> lstWrapperAfter = CRM_UploadExtractTradeTactics.setOpportunityLineItemTactics(lstWrapper, lstOpp[0].Id, false);
        System.assertequals( system.label.CRM_UploadExtractTactic_Coop_reason_ErrorMsg,lstWrapperAfter[0].validation);  
        System.assertequals( system.label.CRM_UploadExtractTactic_Coop_reason_ErrorMsg,lstWrapperAfter[1].validation); 
        System.assertequals( system.label.CRM_UploadExtractTactic_Coop_reason_ErrorMsg,lstWrapperAfter[3].validation); 
        System.assertequals( system.label.CRM_UploadExtractTactic_MandatoryFields_Validation,lstWrapperAfter[2].validation); 
         
        lstWrapper[3].isRowRemoved = true;
        CRM_UploadExtractTradeTactics.setOpportunityLineItemTactics(lstWrapper, lstOpp[0].Id, false); 
        
        Test.stopTest();
    }
    
     /**
     *  Method to test delete tactics
    */
     private static testMethod void testDeleteTacticDataUploadExtractTradeTactics() {
        Test.startTest();
        
        testData(); 
        List<Opportunity> lstOpp = [SELECT Id FROM Opportunity];
        Apexpages.standardController stdCtrl = new Apexpages.standardController(lstOpp[0]);
        CRM_UploadExtractTradeTactics obj = new CRM_UploadExtractTradeTactics(stdCtrl); 
        List<CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper> lstWrapper = new List<CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper>();
        
        Integer intCount = 0;
        List<OpportunityLineItem> lstItems = [SELECT id,Opportunity.Account.Name,Product_Code__c,Status__c,Product2.name,Customer_Reference__c,Start_date__c,End_date__c,Reason__c,Comments__c
                                                ,POS_Rebate__c,POS_Forecast__c,Co_op_Requested_Amount__c,Co_op_Actual_Amount__c,Commitment_Number__c,Digital_Membership__c
                                                FROM OpportunityLineItem WHERE OpportunityId =: lstOpp[0].Id];
        for(OpportunityLineItem oli : lstItems) {
            oli.Is_Canceled__c =true;
            lstWrapper.add(createWrapper(oli, intCount));
            intCount++;
        }
        update lstItems;   
        lstWrapper[0].isRowRemoved = true;
        List<CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper> lstWrapper2  = CRM_UploadExtractTradeTactics.setOpportunityLineItemTactics(lstWrapper, lstOpp[0].Id, false);
        Test.stopTest();
    }
    
    /**
     *  Method to test AddSearchProductScreen
    */
    private static testMethod void testAddSearchProductScreenUploadExtractTradeTactics() {
        Id standardPricebookId = System.Test.getStandardPricebookId();
        testData();
       
        Test.startTest(); 
        List<Opportunity> lstOpp = [SELECT Id,Account.name FROM Opportunity];
        Apexpages.standardController stdCtrl = new Apexpages.standardController(lstOpp[0]);
        CRM_UploadExtractTradeTactics obj = new CRM_UploadExtractTradeTactics(stdCtrl); 
        List<Id> fixedSearchResults = new List<Id>();
        for(Product2 prod : [select Id from Product2]){
            fixedSearchResults.add(prod.Id);
        }
        Test.setFixedSearchResults(fixedSearchResults);
        List<CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper> lstWrapper = new List<CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper>();
        List<CRM_UploadExtractTradeTactics.productSearchWrapper> wrapper1 = CRM_UploadExtractTradeTactics.getProductsForAddSearchProductScreen(standardPricebookId,'1000','USD',lstOpp[0].Account.name,System.today().format(),(System.today()+30).format());
        system.assertNotEquals(null,wrapper1.size()); 
        Test.stopTest();
    }
     
    /**
     * Method to test the Fund BU Segment on tactics
     * US:956
    */
    private static testMethod void testManageFundBUSegmentOnTactic() { 
        
        List<String> lstRegion = new List<String>{CRM_AppConstants.USA_Country, CRM_AppConstants.CANADA_Country};
        List<Country__c> countryList = CRM_TestDataFactory.createCountries(lstRegion, 2, true);
        
        List<Language__c> languageList = CRM_TestDataFactory.createLanguages(1, true);

        List<title__c> titleList = CRM_TestDataFactory.createTitles(1, false);
        for(Title__c title : titleList) {
        	title.Content_Type__c = 'Game';
        }
        insert titleList;
        
        list<Local_Title__c> localTitleList = CRM_TestDataFactory.createLocalTitles(countryList, languageList, 1, false);
        for(Local_Title__c locTitle : localTitleList) {
        	locTitle.Title__c = titleList[0].Id;
        }
        insert localTitleList;
        
        Integer intCount = 0;
        List<Account> lstAccount = CRM_TestDataFactory.createAccounts(5, false);
        for(Account acc : lstAccount) {
        	acc.Sales_Organization__c = intCount == 0 ? CRM_AppConstants.TERRITORY_US_CODE :
        								intCount == 1 ? CRM_AppConstants.TERRITORY_CANADA_CODE :
        								intCount == 2 ? CRM_AppConstants.TERRITORY_MEXICO_CODE : CRM_AppConstants.TERRITORY_GERMANY_CODE;
			intCount++;
        }
        insert lstAccount;
        System.assertEquals(5,lstAccount.size());
        
        intCount = 0;
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount, 1, false);
        for(Opportunity opp : lstOpportunity) {
	        opp.RecordTypeId = intCount == 2 ? CRM_RecordTypeUtil.RT_DEAL_PHYSICAL : CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND;
	        opp.Start_date__c = System.today() - 2;  
	        opp.CloseDate = System.today() + 15;  
	        intCount++;
        }
        insert lstOpportunity;
        System.assertEquals(5,lstOpportunity.size());
        
        intCount = 0;
        List<Product2> products = CRM_TestDataFactory.createProducts(5, false);
        for(Product2 prod : products) {
            prod.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            prod.ProductCode = '10000' + intCount;
            prod.isActive = true;
            prod.SAP_Sales_Org__c = intCount == 0 ? CRM_AppConstants.TERRITORY_US_CODE : 
            						intCount == 1 ? CRM_AppConstants.TERRITORY_CANADA_CODE : CRM_AppConstants.TERRITORY_GERMANY_CODE;
            prod.Local_Title__c = localTitleList[0].Id;
            intCount++;
        } 
        insert products; 
        System.assertEquals(5,products.size());
        
        List<PricebookEntry> pricebookentries = CRM_TestDataFactory.createPriceBookEntries(products, 1, true); 
        System.assertEquals(5,pricebookentries.size());
        
        List<Pricebook_Entry_Period__c> entryPeriodList = CRM_TestDataFactory.createPriceBookEntryPeriods(products, 1, true);
        
        Test.startTest();
        List<OpportunityLineItem> dealProds = CRM_TestDataFactory.createDealProductsWithOpportunities(pricebookentries, lstOpportunity, 3, true);
        Test.stopTest();
        
        System.assertEquals(15,dealProds.size()); 
        System.assertEquals([select count() from OpportunityLineItem where Fund_BU_Segment__c = 'Sales'], 6); 
        System.assertEquals([select count() from OpportunityLineItem where Fund_BU_Segment__c = 'Sales' and OpportunityId =: lstOpportunity[0].Id], 3); 
        System.assertEquals([select count() from OpportunityLineItem where Fund_BU_Segment__c = 'Sales' and OpportunityId =: lstOpportunity[1].Id], 3); 
        System.assertEquals([select count() from OpportunityLineItem where Fund_BU_Segment__c != 'Sales'], 9); 
    }
    
    private static CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper createStaticWrapper(Id accId,String pcode, Integer intCount) {
        CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper lineItemWrapper = new CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper();
        lineItemWrapper.existingId = null; 
        lineItemWrapper.accountName = accId;
        lineItemWrapper.productCode = pcode;
        lineItemWrapper.productName = '';
        lineItemWrapper.commitmentNum = '';
        lineItemWrapper.startDate = System.today().format();
        lineItemWrapper.endDate = (System.Today()+30).format();
        lineItemWrapper.coopReason = 'Feature'; 
        lineItemWrapper.coopComments = '';
        lineItemWrapper.posForecast = 3;
        lineItemWrapper.coopReqAmount = 3;
        lineItemWrapper.posActual= 3;
        lineItemWrapper.coopActualAmt = 3;
        lineItemWrapper.status = '';
        lineItemWrapper.custReference = 'Cust Reference'; 
        lineItemWrapper.digitalMembership ='digi';
        return lineItemWrapper;
    }
    
    private static CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper createWrapper(OpportunityLineItem lineItem, Integer intCount) {
        CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper lineItemWrapper = new CRM_UploadExtractTradeTactics.OpportunityLineItemWrapper();
        lineItemWrapper.existingId = intCount == 2 ? null : lineItem.id; 
        lineItemWrapper.accountName = lineItem.Opportunity.Account.Name;
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
        return lineItemWrapper;
    }
}