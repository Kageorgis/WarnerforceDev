/**
@Author Cognizant
@name CRM_ActivateCreditNote_Test
@CreateDate 16 Jan 2018
@Description Test class for CRM_ActivateCreditNote_Test
@Version <1.0>
@reference Requirement no 
*/
@isTest
public class CRM_ActivateCreditNote_Test {
    
    /**
*  Create Test Data. 
*  @name createTestData
*  @param None 
*  @return None
*  @throws None
*  @see com.ac.sample.SuperObject#get
*/
    public static List<Account> lstAccount;
    public static List<Opportunity> lstOpportunity;
    public static List<OpportunityLineItem> lstDealProductsWithOpportunities;
    
    public static void createTestData(User testUser,String command) {
        //Creating Account
        lstAccount = CRM_TestDataFactory.createAccounts(1, false);
        lstAccount[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_US_CODE;
        insert lstAccount;
        System.assertEquals(1, lstAccount.size(), 'Account Created'); 
        
        PriceBook2 wbieUS =  new Pricebook2(Name = CRM_AppConstants.WBIE_US_PRICEBOOK_NAME, 
                                            Description = 'WBIE US Pricebook', 
                                            IsActive = true, 
                                            Business_Unit__c = CRM_AppConstants.TERRITORY_US_CODE);
        insert wbieUS;
        
        //Creating Opportunity
        lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount, 3, false);
        for (Opportunity deal: lstOpportunity){
            deal.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND;
            deal.Start_Date__c = system.today();
            deal.Customer_Delivery_Date__c = system.today() + 1;
            deal.Promo_Start_Date__c = system.today() + 2;
            deal.Pricebook2Id = wbieUS.Id;
        }
        insert lstOpportunity;
        System.assertEquals(3, lstOpportunity.size(), 'Opportunities Created');

        //Creating Product Group
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        System.assertEquals(1, lstProductGroup.size(), 'Product Group Created');
        
        //Creating Product
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 1, true);
        System.assertEquals(1, lstProduct.size(), 'Product Created');
        
        Id standardPBId = Test.getStandardPricebookId();
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPBId, Product2Id = lstProduct[0].Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        
        //Creating PricebookEntry
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, false);
        lstPriceBookEntries[0].Pricebook2Id = wbieUS.Id;
        lstPriceBookEntries[0].UnitPrice = 1000;
        insert lstPriceBookEntries;
        System.assertEquals(1, lstPriceBookEntries.size(), 'Pricebook Entries Created');
        
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, false);
        lstPriceBookEntryPeriod[0].Price_Book__c = wbieUS.Id;
        insert lstPriceBookEntryPeriod;
        
        //Creating Opportunity Line Item (Deal Products)*/ 
        if(command =='Activation'){
            lstDealProductsWithOpportunities = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstOpportunity, 10, false);
            
            for(integer i=0;i<lstDealProductsWithOpportunities.size();i++) {
                lstDealProductsWithOpportunities[i].Reason__c = 'Display';
                lstDealProductsWithOpportunities[i].POS_Rebate__c = 10;
                lstDealProductsWithOpportunities[i].POS_Forecast__c = 20;
                lstDealProductsWithOpportunities[i].Co_op_Requested_Amount__c = 10;
                lstDealProductsWithOpportunities[i].Co_op_Actual_Amount__c = 10;
                lstDealProductsWithOpportunities[i].Customer_Reference__c = 'CR34378';
                lstDealProductsWithOpportunities[i].Digital_Membership__c = 'DM34535';
                lstDealProductsWithOpportunities[i].Start_date__c =lstOpportunity[0].Start_date__c;
                lstDealProductsWithOpportunities[i].Comments__c = 'Testing Testing';
                lstDealProductsWithOpportunities[i].End_date__c = lstOpportunity[0].CloseDate; 
            }
            insert lstDealProductsWithOpportunities; 
            System.assertEquals(30, lstDealProductsWithOpportunities.size(), 'Deal Products Created');   
        }
        System.runAs(testUser){
            for(Opportunity deal: lstOpportunity){
                deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            }
            update lstOpportunity;
        }
        System.assertEquals(3, [Select Count() From Opportunity Where StageName = :CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED and id in: lstOpportunity], 'Committed Deals');
        List<Credit_Note__c> lstCredits =new List<Credit_Note__c>();
        Credit_Note__c objCreditNote = new Credit_Note__c();
        objCreditNote.CurrencyIsoCode = 'USD';
        objCreditNote.RecordTypeID = CRM_RecordTypeUtil.RT_CREDIT_NOTE_STANDARD;
        objCreditNote.PO_Number__c = 'CNPO Number';
        objCreditNote.Status__c = 'Planned'; // Status cannot be 'Ready To Pay' while creating CN
        objCreditNote.Amount__c = 100000;
        objCreditNote.account__c=lstAccount[0].id;
        insert objCreditNote;
        lstCredits.add(objCreditNote);
        System.assertEquals(1, [Select Count() From Credit_Note__c Where id in:lstCredits]);
    }
    
    @isTest
    static void creditNoteActivateValidation_Test(){
        
        createTestData(createUser(),'Validation'); 
        Test.startTest();
        Test.setCurrentPageReference(Page.CRM_ActivateCreditNote);
        Credit_Note__c cnn =[select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
        System.debug('===='+cnn.Id);
        ApexPages.StandardController scc = new ApexPages.StandardController(cnn);
        CRM_AddTacticsOnCreditNoteController addtactic =new CRM_AddTacticsOnCreditNoteController(scc); 
        CRM_AddTacticsOnCreditNoteController.DealProducSearchFiltertWrapper fil =new CRM_AddTacticsOnCreditNoteController.DealProducSearchFiltertWrapper();
        CRM_AddTacticsOnCreditNoteController.DealProductWrapper[] wrap = CRM_AddTacticsOnCreditNoteController.getTactics(cnn.Id,lstAccount[0].id, cnn.recordTypeId,fil,'Display');
        List<Id> listDealIds =new List<Id>();
        List<OpportunityLineItem> dpList = new List<OpportunityLineItem>();
        for(CRM_AddTacticsOnCreditNoteController.DealProductWrapper wr : wrap){
            wr.isSelected=true;
            listDealIds.add(wr.dealPorduct.OpportunityId);
            dpList.add(wr.dealPorduct);
        }
        System.debug('222===='+listDealIds);
        CRM_AddTacticsOnCreditNoteController.createCreditNoteItems(cnn.Id,dpList,listDealIds,cnn.currencyisocode);
        CRM_ActivateCreditNote obj = new CRM_ActivateCreditNote(scc);
        try{
            CRM_ActivateCreditNote.activateCreditNoteToSendToSAP(cnn.id,cnn.status__c);
        }catch(Exception e){
            system.assertequals('Credit note cannot be activated as no Credit Note Items are present',e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void creditNoteAlreadyActivatedValidation_Test(){
        
        createTestData(createUser(),'Activation');
        Test.startTest();
        Test.setCurrentPageReference(Page.CRM_ActivateCreditNote);
        Credit_Note__c cnn =[select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
        ApexPages.StandardController scc = new ApexPages.StandardController(cnn);
        CRM_AddTacticsOnCreditNoteController addtactic =new CRM_AddTacticsOnCreditNoteController(scc); 
        CRM_AddTacticsOnCreditNoteController.DealProducSearchFiltertWrapper fil =new CRM_AddTacticsOnCreditNoteController.DealProducSearchFiltertWrapper();
        CRM_AddTacticsOnCreditNoteController.DealProductWrapper[] wrap = CRM_AddTacticsOnCreditNoteController.getTactics(cnn.Id,lstAccount[0].id, cnn.recordTypeId,fil,'Display');
        List<Id> listDealIds =new List<Id>();
        List<OpportunityLineItem> dpList = new List<OpportunityLineItem>();
        for(CRM_AddTacticsOnCreditNoteController.DealProductWrapper wr : wrap){
            wr.isSelected=true;
            listDealIds.add(wr.dealPorduct.OpportunityId);
            dpList.add(wr.dealPorduct);
        }
        CRM_AddTacticsOnCreditNoteController.createCreditNoteItems(cnn.Id,dpList,listDealIds,cnn.currencyisocode);
        CRM_ActivateCreditNote obj = new CRM_ActivateCreditNote(scc);
        CRM_ActivateCreditNote.activateCreditNoteToSendToSAP(cnn.id,cnn.status__c);
        try{
            CRM_ActivateCreditNote.activateCreditNoteToSendToSAP(cnn.id,cnn.status__c);
        }catch(Exception e){
            system.assertequals(System.label.CRM_CreditNote_Activation_Error,e.getMessage());
        }
        cnn =[select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
        system.assertEquals('Ready to pay',cnn.status__c);
        Test.stopTest();
    }
    
    @isTest
    static void creditNoteActivate_Test(){
        
        createTestData(createUser(),'Activation');
        Test.startTest();
        Test.setCurrentPageReference(Page.CRM_ActivateCreditNote);
        Credit_Note__c cnn =[select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
        ApexPages.StandardController scc = new ApexPages.StandardController(cnn);
        CRM_AddTacticsOnCreditNoteController addtactic =new CRM_AddTacticsOnCreditNoteController(scc); 
        CRM_AddTacticsOnCreditNoteController.DealProducSearchFiltertWrapper fil =new CRM_AddTacticsOnCreditNoteController.DealProducSearchFiltertWrapper();
        CRM_AddTacticsOnCreditNoteController.DealProductWrapper[] wrap = CRM_AddTacticsOnCreditNoteController.getTactics(cnn.Id,lstAccount[0].id, cnn.recordTypeId,fil,'Display');
        List<Id> listDealIds =new List<Id>();
        List<OpportunityLineItem> dpList = new List<OpportunityLineItem>();
        for(CRM_AddTacticsOnCreditNoteController.DealProductWrapper wr : wrap){
            wr.isSelected=true;
            listDealIds.add(wr.dealPorduct.OpportunityId);
            dpList.add(wr.dealPorduct);
        }
        CRM_AddTacticsOnCreditNoteController.createCreditNoteItems(cnn.Id,dpList,listDealIds,cnn.currencyisocode);
        CRM_ActivateCreditNote obj = new CRM_ActivateCreditNote(scc);
        CRM_ActivateCreditNote.activateCreditNoteToSendToSAP(cnn.id,cnn.status__c);
        cnn =[select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
        system.assertEquals('Ready to pay',cnn.status__c);
        Test.stopTest();
    }
    
    @isTest
    static void creditNote_POSDeal_MethodOfPayment_CreditMemo_Activate_Test(){
        createTestData(createUser(),'Activation');
        List<Opportunity> dealList = new List<Opportunity>();
        Id posRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_POS_DEAL).getRecordTypeId();

        System.runAs(CRM_TestDataFactory.createUser('System Administrator', true)){
            for(Opportunity opp : [Select Id, RecordTypeId, Method_of_Payment__c FROM Opportunity]){
                opp.RecordTypeId = posRecordTypeID;
                opp.Method_of_Payment__c = CRM_AppConstants.DEAL_MOP_CREDIT_MEMO;
                dealList.add(opp);
            }
            update dealList;

            Test.startTest();
            Test.setCurrentPageReference(Page.CRM_ActivateCreditNote);
            Credit_Note__c cnn = [select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            ApexPages.StandardController scc = new ApexPages.StandardController(cnn);
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal addtactic = new CRM_AddTacticsOnCreditNoteCtrl_POSDeal(scc); 
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProducSearchFiltertWrapper fil = new CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProducSearchFiltertWrapper();
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProductWrapper[] wrap = CRM_AddTacticsOnCreditNoteCtrl_POSDeal.getTactics(cnn.Id,lstAccount[0].id, cnn.recordTypeId,fil,'Display');
            List<Id> listDealIds = new List<Id>();
            List<OpportunityLineItem> dpList = new List<OpportunityLineItem>();
            for(CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProductWrapper wr : wrap){
                wr.isSelected=true;
                listDealIds.add(wr.dealPorduct.OpportunityId);
                dpList.add(wr.dealPorduct);
            }
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.createCreditNoteItems(cnn.Id,dpList,listDealIds,cnn.currencyisocode);
            CRM_ActivateCreditNote obj = new CRM_ActivateCreditNote(scc);
            CRM_ActivateCreditNote.activateCreditNoteToSendToSAP(cnn.id,cnn.status__c);
            cnn = [select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            system.assertEquals(CRM_AppConstants.CREDIT_NOTE_STATUS_READY_TO_PAY, cnn.status__c);
            Test.stopTest();
        }
    }
    
    @isTest
    static void creditNote_POSDeal_MethodOfPayment_Check_Activate_Test(){
        createTestData(createUser(),'Activation');
        List<Opportunity> dealList = new List<Opportunity>();
        Id posRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_POS_DEAL).getRecordTypeId();

        System.runAs(CRM_TestDataFactory.createUser('System Administrator', true)){
            for(Opportunity opp : [Select Id, RecordTypeId, Method_of_Payment__c, Check_Paid__c FROM Opportunity]){
                opp.RecordTypeId = posRecordTypeID;
                opp.Method_of_Payment__c = CRM_AppConstants.DEAL_MOP_CHECK;
                opp.Check_Paid__c = CRM_AppConstants.DEAL_CHECK_PAID_YES;
                dealList.add(opp);
            }
            update dealList;
            
            Test.startTest();
            Test.setCurrentPageReference(Page.CRM_ActivateCreditNote);
            Credit_Note__c cnn = [select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            ApexPages.StandardController scc = new ApexPages.StandardController(cnn);
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal addtactic = new CRM_AddTacticsOnCreditNoteCtrl_POSDeal(scc); 
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProducSearchFiltertWrapper fil = new CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProducSearchFiltertWrapper();
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProductWrapper[] wrap = CRM_AddTacticsOnCreditNoteCtrl_POSDeal.getTactics(cnn.Id,lstAccount[0].id, cnn.recordTypeId,fil,'Display');
            List<Id> listDealIds = new List<Id>();
            List<OpportunityLineItem> dpList = new List<OpportunityLineItem>();
            for(CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProductWrapper wr : wrap){
                wr.isSelected=true;
                listDealIds.add(wr.dealPorduct.OpportunityId);
                dpList.add(wr.dealPorduct);
            }
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.createCreditNoteItems(cnn.Id,dpList,listDealIds,cnn.currencyisocode);
            CRM_ActivateCreditNote obj = new CRM_ActivateCreditNote(scc);
            CRM_ActivateCreditNote.activateCreditNoteToSendToSAP(cnn.id,cnn.status__c);
            cnn = [select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            system.assertEquals(CRM_AppConstants.CREDIT_NOTE_STATUS_PAID, cnn.status__c);
            Test.stopTest();
        }
    }
    
    @isTest
    static void creditNote_POSDeal_MethodOfPayment_Check_ActivateFail_Test(){
        createTestData(createUser(),'Activation');
        List<Opportunity> dealList = new List<Opportunity>();
        Id posRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_POS_DEAL).getRecordTypeId();

        System.runAs(CRM_TestDataFactory.createUser('System Administrator', true)){
            for(Opportunity opp : [Select Id, RecordTypeId, Method_of_Payment__c, Check_Paid__c FROM Opportunity]){
                opp.RecordTypeId = posRecordTypeID;
                opp.Method_of_Payment__c = CRM_AppConstants.DEAL_MOP_CHECK;
                opp.Check_Paid__c = CRM_AppConstants.DEAL_CHECK_PAID_NO;
                dealList.add(opp);
            }
            update dealList;
            
            Test.startTest();
            Test.setCurrentPageReference(Page.CRM_ActivateCreditNote);
            Credit_Note__c cnn = [select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            ApexPages.StandardController scc = new ApexPages.StandardController(cnn);
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal addtactic = new CRM_AddTacticsOnCreditNoteCtrl_POSDeal(scc); 
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProducSearchFiltertWrapper fil = new CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProducSearchFiltertWrapper();
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProductWrapper[] wrap = CRM_AddTacticsOnCreditNoteCtrl_POSDeal.getTactics(cnn.Id,lstAccount[0].id, cnn.recordTypeId,fil,'Display');
            List<Id> listDealIds = new List<Id>();
            List<OpportunityLineItem> dpList = new List<OpportunityLineItem>();
            for(CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProductWrapper wr : wrap){
                wr.isSelected=true;
                listDealIds.add(wr.dealPorduct.OpportunityId);
                dpList.add(wr.dealPorduct);
            }
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.createCreditNoteItems(cnn.Id,dpList,listDealIds,cnn.currencyisocode);
            CRM_ActivateCreditNote obj = new CRM_ActivateCreditNote(scc);
            try{
                CRM_ActivateCreditNote.activateCreditNoteToSendToSAP(cnn.id,cnn.status__c);
            }catch(Exception e){
                system.assertequals(System.label.CRM_CreditNoteActivationError_MixedDealCheckPaid, e.getMessage());
            }
            cnn = [select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            system.assertEquals(CRM_AppConstants.CREDIT_NOTE_STATUS_PLANNED, cnn.status__c);
            Test.stopTest();
        }
    }
    
    @isTest
    static void creditNote_POSDeal_MethodOfPayment_Check_Mixed_ActivateFail_Test(){
        createTestData(createUser(),'Activation');
        List<Opportunity> dealList = new List<Opportunity>();
        Id posRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_POS_DEAL).getRecordTypeId();

        System.runAs(CRM_TestDataFactory.createUser('System Administrator', true)){
            for(Opportunity opp : [Select Id, RecordTypeId, Method_of_Payment__c, Check_Paid__c FROM Opportunity]){
                opp.RecordTypeId = posRecordTypeID;
                opp.Method_of_Payment__c = CRM_AppConstants.DEAL_MOP_CHECK;
                opp.Check_Paid__c = CRM_AppConstants.DEAL_CHECK_PAID_YES;
                dealList.add(opp);
            }
            dealList[0].Check_Paid__c = CRM_AppConstants.DEAL_CHECK_PAID_NO;
            update dealList;
            
            Test.startTest();
            Test.setCurrentPageReference(Page.CRM_ActivateCreditNote);
            Credit_Note__c cnn = [select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            ApexPages.StandardController scc = new ApexPages.StandardController(cnn);
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal addtactic = new CRM_AddTacticsOnCreditNoteCtrl_POSDeal(scc); 
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProducSearchFiltertWrapper fil = new CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProducSearchFiltertWrapper();
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProductWrapper[] wrap = CRM_AddTacticsOnCreditNoteCtrl_POSDeal.getTactics(cnn.Id,lstAccount[0].id, cnn.recordTypeId,fil,'Display');
            List<Id> listDealIds = new List<Id>();
            List<OpportunityLineItem> dpList = new List<OpportunityLineItem>();
            for(CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProductWrapper wr : wrap){
                wr.isSelected=true;
                listDealIds.add(wr.dealPorduct.OpportunityId);
                dpList.add(wr.dealPorduct);
            }
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.createCreditNoteItems(cnn.Id,dpList,listDealIds,cnn.currencyisocode);
            CRM_ActivateCreditNote obj = new CRM_ActivateCreditNote(scc);
            try{
                CRM_ActivateCreditNote.activateCreditNoteToSendToSAP(cnn.id,cnn.status__c);
            }catch(Exception e){
                system.assertequals(System.label.CRM_CreditNoteActivationError_MixedDealCheckPaid, e.getMessage());
            }
            cnn = [select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            system.assertEquals(CRM_AppConstants.CREDIT_NOTE_STATUS_PLANNED, cnn.status__c);
            Test.stopTest();
        }
    }
    
    @isTest
    static void creditNote_POSDeal_MixedMethodOfPayment_Mixed_ActivateFail_Test(){
        createTestData(createUser(),'Activation');
        List<Opportunity> dealList = new List<Opportunity>();
        Id posRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_POS_DEAL).getRecordTypeId();

        System.runAs(CRM_TestDataFactory.createUser('System Administrator', true)){
            for(Opportunity opp : [Select Id, RecordTypeId, Method_of_Payment__c, Check_Paid__c FROM Opportunity]){
                opp.RecordTypeId = posRecordTypeID;
                opp.Method_of_Payment__c = CRM_AppConstants.DEAL_MOP_CHECK;
                opp.Check_Paid__c = CRM_AppConstants.DEAL_CHECK_PAID_YES;
                dealList.add(opp);
            }
            dealList[0].Method_of_Payment__c = CRM_AppConstants.DEAL_MOP_CREDIT_MEMO;
            dealList[0].Check_Paid__c = '';
            update dealList;
            
            Test.startTest();
            Test.setCurrentPageReference(Page.CRM_ActivateCreditNote);
            Credit_Note__c cnn = [select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            ApexPages.StandardController scc = new ApexPages.StandardController(cnn);
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal addtactic = new CRM_AddTacticsOnCreditNoteCtrl_POSDeal(scc); 
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProducSearchFiltertWrapper fil = new CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProducSearchFiltertWrapper();
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProductWrapper[] wrap = CRM_AddTacticsOnCreditNoteCtrl_POSDeal.getTactics(cnn.Id,lstAccount[0].id, cnn.recordTypeId,fil,'Display');
            List<Id> listDealIds = new List<Id>();
            List<OpportunityLineItem> dpList = new List<OpportunityLineItem>();
            for(CRM_AddTacticsOnCreditNoteCtrl_POSDeal.DealProductWrapper wr : wrap){
                wr.isSelected=true;
                listDealIds.add(wr.dealPorduct.OpportunityId);
                dpList.add(wr.dealPorduct);
            }
            CRM_AddTacticsOnCreditNoteCtrl_POSDeal.createCreditNoteItems(cnn.Id,dpList,listDealIds,cnn.currencyisocode);
            CRM_ActivateCreditNote obj = new CRM_ActivateCreditNote(scc);
            try{
                CRM_ActivateCreditNote.activateCreditNoteToSendToSAP(cnn.id,cnn.status__c);
            }catch(Exception e){
                system.assertequals(System.label.CRM_CreditNoteActivationError_MixedDealMethodOfPayment, e.getMessage());
            }
            cnn = [select id,status__c,currencyisocode,recordTypeId from Credit_Note__c limit 1];
            system.assertEquals(CRM_AppConstants.CREDIT_NOTE_STATUS_PLANNED, cnn.status__c);
            Test.stopTest();
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
        return testUser;
    }
}