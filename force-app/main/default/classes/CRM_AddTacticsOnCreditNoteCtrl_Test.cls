/**
   @Author Cognizant
   @name CRM_AddTacticsOnCreditNoteCtrl_Test
   @CreateDate 16 Jan 2018
   @Description Test class for CRM_AddTacticsOnCreditNoteController
   @Version <1.0>
   @reference Requirement no 926
*/
  
@isTest
private class CRM_AddTacticsOnCreditNoteCtrl_Test{
    
    static List<Account> lstAccount = new List<Account>();
     
     /**
    *  Create Test Data. 
    *  @name createTestData
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static void createTestData(){
        //create account  
        lstAccount = CRM_TestDataFactory.createAccounts(1, false);
        lstAccount[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_US_CODE;
        lstAccount[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        insert lstAccount;
        
        //create deal
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount, 1, false);
        lstOpportunity[0].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND;
        lstOpportunity[0].Start_date__c = System.today();  
        lstOpportunity[0].CloseDate = System.today()+15;  
        insert lstOpportunity;
        
        List<Product2> products = CRM_TestDataFactory.createProducts(5, false);
        for(integer i=0 ; i<products.size() ; i++) {
            products[i].ProductCode = '10000' + i;
            products[i].SAP_Dist_chain_product_Status__c = CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ACTIVE;
            products[i].isActive = true;
        } 
        insert products; 
        
        List<PricebookEntry> pricebookentries = CRM_TestDataFactory.createPriceBookEntries(products, 1, true); 
        System.assertEquals(5,pricebookentries.size());
        List<OpportunityLineItem> dealProds = CRM_TestDataFactory.createDealProductsWithOpportunities(pricebookentries, lstOpportunity, 10, false);
        
        for(integer i=0;i<dealProds.size();i++) {
            dealProds[i].Comments__c = 'Test Comment';
            dealProds[i].POS_Rebate__c = 100;
            dealProds[i].POS_Forecast__c = 100;
            dealProds[i].Co_op_Requested_Amount__c = 100;
            dealProds[i].Co_op_Actual_Amount__c = 100;
            dealProds[i].Reason__c = 'Feature';
            dealProds[i].Start_date__c = System.today() + i;
            dealProds[i].End_date__c = System.today() + 15 + i; 
            dealProds[i].Customer_Reference__c = 'Test Reference';
            dealProds[i].Digital_Membership__c = 'Test Digital Membership';
            
        }
        insert dealProds;
        System.assertEquals(10,dealProds.size());
        
        system.runAs(createTestUser()){
            lstOpportunity[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            update lstOpportunity[0];
        }
    }
    
    /**
     *  Method to test the Add tactic functionality
    */
    private static testMethod void AddTacticForCreditNote_Test() {
        createTestData();   
        
        system.debug('Cpmmitted deal prodcuts :::::::::: '+[Select Id,Reason__c,Start_date__c,End_date__c From OpportunityLineItem Where Status__c = 'Committed']);
        List<Opportunity> deals = [Select Id From Opportunity];
        
        Credit_Note__c cnObj = new Credit_Note__c();
        cnObj.CurrencyIsoCode = 'USD';
        cnObj.PO_Number__c = 'CNPO Number';
        cnObj.Status__c = 'Planned'; // Status cannot be 'Ready To Pay' while creating CN
        cnObj.Amount__c = 100000;
        cnObj.account__c = lstAccount[0].id;
        cnObj.RecordTypeId = CRM_RecordTypeUtil.RT_CREDIT_NOTE_STANDARD;
        cnObj.Co_op_Reason__c = 'Display';
        insert cnObj;
        
        PageReference pageRef = Page.CRM_AddTacticsOnCreditNote;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',cnObj.id);
        ApexPages.standardController controller = new ApexPages.standardController(cnObj);
        
        CRM_AddTacticsOnCreditNoteController.DealProducSearchFiltertWrapper searchFilter = new CRM_AddTacticsOnCreditNoteController.DealProducSearchFiltertWrapper();
        
        CRM_AddTacticsOnCreditNoteController ctrl = new CRM_AddTacticsOnCreditNoteController(controller);
        List<CRM_AddTacticsOnCreditNoteController.DealProductWrapper> dpWrapList = CRM_AddTacticsOnCreditNoteController.getTactics(cnObj.Id,cnObj.account__c,cnObj.RecordTypeId,searchFilter,cnObj.Co_op_Reason__c);
        system.assertEquals(0,dpWrapList.size(),'No Records found as all tactics have coop reason Feature');
        
        cnObj.Co_op_Reason__c = 'Feature';
        update cnObj;
        dpWrapList = CRM_AddTacticsOnCreditNoteController.getTactics(cnObj.Id,cnObj.account__c,cnObj.RecordTypeId,searchFilter,cnObj.Co_op_Reason__c);
        system.assertEquals(10,dpWrapList.size(),'10 tactics found having co-op reason Feature');
        
        searchFilter.startDateFrom = system.today() + 2;
        
        dpWrapList = CRM_AddTacticsOnCreditNoteController.getTactics(cnObj.Id,cnObj.account__c,cnObj.RecordTypeId,searchFilter,cnObj.Co_op_Reason__c);
        system.assertEquals(8,dpWrapList.size(),'Added Filter For start date with Co-op reason as Feature');
        
        searchFilter.startDateFrom = system.today();
        searchFilter.endDateTo = System.today() + 15 + 3;
        
        
        dpWrapList = CRM_AddTacticsOnCreditNoteController.getTactics(cnObj.Id,cnObj.account__c,cnObj.RecordTypeId,searchFilter,cnObj.Co_op_Reason__c);
        system.assertEquals(4,dpWrapList.size(),'Added Filter For start and end date');
        
        List<OpportunityLineItem> dealProducts = new List<OpportunityLineItem>();
        for(CRM_AddTacticsOnCreditNoteController.DealProductWrapper dpw : dpWrapList){
            dpw.isSelected = true;
            dealProducts.add(dpw.dealPorduct);
        }
        
        Test.startTest();
        CRM_AddTacticsOnCreditNoteController.createCreditNoteItems(cnObj.Id,dealProducts,new List<Id>{deals[0].Id},'USD');
        Test.stopTest();
        
        Map<Id,Credit_Note_Item__c> mapOfCNI = new Map<Id,Credit_Note_Item__c>([Select Id From Credit_Note_Item__c]);
        system.assertEquals(4,mapOfCNI.size(),'Created Credit Note Items');
        system.assertEquals(4,[Select Count() From OpportunityLineItem Where Credit_Note_Item__c IN :mapOfCNI.keySet()],'Credit Note Item linked to deal products');
    }
    
    /**
     *  Method to test the Add tactic functionality
    */
    private static testMethod void AddTacticForDebitNote_Test() {
        createTestData();   
        
        List<Opportunity> deals = [Select Id From Opportunity];
        List<OpportunityLineItem> dealProducts = [Select Id,Co_op_Actual_Amount__c From OpportunityLineItem];
        for(OpportunityLineItem oppLI : dealProducts){
            oppLI.Co_op_Actual_Amount__c = -100;
        }
        update dealProducts;
        
        Credit_Note__c cnObj = new Credit_Note__c();
        cnObj.CurrencyIsoCode = 'USD';
        cnObj.PO_Number__c = 'CNPO Number';
        cnObj.Status__c = 'Planned'; // Status cannot be 'Ready To Pay' while creating CN
        cnObj.Amount__c = 100000;
        cnObj.account__c = lstAccount[0].id;
        cnObj.RecordTypeId = CRM_RecordTypeUtil.RT_CREDIT_NOTE_REVERSE;
        cnObj.Co_op_Reason__c = 'Display';
        insert cnObj;
        
        PageReference pageRef = Page.CRM_AddTacticsOnCreditNote;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',cnObj.id);
        ApexPages.standardController controller = new ApexPages.standardController(cnObj);
        
        CRM_AddTacticsOnCreditNoteController.DealProducSearchFiltertWrapper searchFilter = new CRM_AddTacticsOnCreditNoteController.DealProducSearchFiltertWrapper();
        
        CRM_AddTacticsOnCreditNoteController ctrl = new CRM_AddTacticsOnCreditNoteController(controller);
        ctrl.getmaxTacticLimit();
        ctrl.getUserDateFormat();
        ctrl.getUserLocaleLanguage();
        ctrl.isReadOnly = false;
        
        List<CRM_AddTacticsOnCreditNoteController.DealProductWrapper> dpWrapList = CRM_AddTacticsOnCreditNoteController.getTactics(cnObj.Id,cnObj.account__c,cnObj.RecordTypeId,searchFilter,cnObj.Co_op_Reason__c);
        system.assertEquals(0,dpWrapList.size(),'No Records found as all tactics have coop reason Feature');
        
        cnObj.Co_op_Reason__c = 'Feature';
        update cnObj;
        dpWrapList = CRM_AddTacticsOnCreditNoteController.getTactics(cnObj.Id,cnObj.account__c,cnObj.RecordTypeId,searchFilter,cnObj.Co_op_Reason__c);
        system.assertEquals(10,dpWrapList.size(),'10 tactics found having co-op reason Feature');
        
        List<OpportunityLineItem> dpList = new List<OpportunityLineItem>();
        for(CRM_AddTacticsOnCreditNoteController.DealProductWrapper dpw : dpWrapList){
            dpw.isSelected = true;
            dpList.add(dpw.dealPorduct);
        }
        
        Test.startTest();
        CRM_AddTacticsOnCreditNoteController.createCreditNoteItems(cnObj.Id,dpList,new List<Id>{deals[0].Id},'USD');
        Test.stopTest();
        
        Map<Id,Credit_Note_Item__c> mapOfCNI = new Map<Id,Credit_Note_Item__c>([Select Id From Credit_Note_Item__c]);
        system.assertEquals(10,mapOfCNI.size(),'Created Credit Note Items');
        system.assertEquals(10,[Select Count() From OpportunityLineItem Where Credit_Note_Item__c IN :mapOfCNI.keySet()],'Credit Note Item linked to deal products');
        
        Credit_Note__c excn = new Credit_Note__c();
        Database.SaveResult result = Database.Update(excn, false);
        List<CRM_ErrorLogger.ErrorLog> errorLogInstanceList = CRM_AddTacticsOnCreditNoteController.logAnException(result.getErrors(),dealProducts[0]);   
    }
    
    //Method to create Test User
    static USer createTestUser(){
       List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
       System.assertEquals(1, profiles.size());

        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = String.valueOf(d) + 'abc@test.com',
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
}