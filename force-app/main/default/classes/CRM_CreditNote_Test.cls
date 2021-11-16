/**
   @Author Cognizant
   @name CRM_CreditNoteApprovalCtrl_Test 
   @Description Test Class for CRM_CreditNoteApprovalCtrl
  */
@isTest
public with sharing class CRM_CreditNote_Test{
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
    public static Coop_Budget__c cb;    
    public static void createTestData(User testUser) {
        //Creating Account
        lstAccount = CRM_TestDataFactory.createAccounts(1, false);
        lstAccount[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
        insert lstAccount;
        System.assertEquals(1, lstAccount.size(), 'Account Created');
        
        //Create Coop Budget 
        cb = new Coop_Budget__c();
        cb.Amount__c = 100;
        cb.Customer__c = lstAccount[0].Id;
        cb.Start_Date__c = system.today();
        cb.End_Date__c = system.today() + 30;
        insert cb;
        
        //Creating Opportunity
        lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount, 3, false);
        for (Opportunity deal: lstOpportunity){
            deal.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
            deal.High_Level_Forecast__c = 100;
            deal.Start_Date__c = system.today();
            deal.Customer_Delivery_Date__c = system.today() + 1;
            deal.Promo_Start_Date__c = system.today() + 2;
        }
        insert lstOpportunity;
        System.assertEquals(3, lstOpportunity.size(), 'Opportunities Created');
        
        //Creating Product Group
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        System.assertEquals(1, lstProductGroup.size(), 'Product Group Created');
        
        //Creating Product
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 1, true);
        System.assertEquals(1, lstProduct.size(), 'Product Created');
        
        //Creating PricebookEntry
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        System.assertEquals(1, lstPriceBookEntries.size(), 'Pricebook Entries Created');
        CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct,1,true);
      
        //Creating Opportunity Line Item (Deal Products)*/
        lstDealProductsWithOpportunities = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstOpportunity, 1, false);
        for(OpportunityLineItem dp : lstDealProductsWithOpportunities){
            dp.Co_op_Requested_Amount__c = 50;
            dp.Co_op_Spent__c = 0;
        }
        insert lstDealProductsWithOpportunities;
        System.assertEquals(3, lstDealProductsWithOpportunities.size(), 'Deal Products Created');   
        
        System.runAs(testUser){
            for(Opportunity deal: lstOpportunity){
                deal.StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            }
            update lstOpportunity;
        }
        System.assertEquals(3, [Select Count() From Opportunity Where StageName = :CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED], 'Committed Deals');
    }
    
    @isTest
    static void createCreditNoteFromDeal_Test(){
        
        createTestData(createUser());
        Test.startTest();
            Test.setCurrentPageReference(Page.CRM_CreateCreditNote);
            ApexPages.StandardController sc = new ApexPages.StandardController(lstOpportunity[0]);
            CRM_CreateCreditNoteCtrl ctrl = new CRM_CreateCreditNoteCtrl(sc);
            Credit_Note__c cn = CRM_CreateCreditNoteCtrl.createCreditNote(lstOpportunity[0].Id,lstAccount[0].Id);
        Test.stopTest();
        System.assertEquals(1,[Select Count() From Credit_Note__c]);
        System.assertEquals(1,[Select Count() From DealCreditNote__c]);
        System.assertEquals(1,[Select Count() From Credit_Note_Item__c]);
    }
    
    
    @isTest
    static void createCreditNoteFromDeal_DeletePositiveScenarioTest(){
        
        createTestData(createUser());
        Test.startTest();
            Test.setCurrentPageReference(Page.CRM_CreateCreditNote);
            ApexPages.StandardController sc = new ApexPages.StandardController(lstOpportunity[0]);
            CRM_CreateCreditNoteCtrl ctrl = new CRM_CreateCreditNoteCtrl(sc);
            Credit_Note__c cn = CRM_CreateCreditNoteCtrl.createCreditNote(lstOpportunity[0].Id,lstAccount[0].Id);
      
        System.assertEquals(1,[Select Count() From Credit_Note__c]);
        System.assertEquals(1,[Select Count() From DealCreditNote__c]);
        System.assertEquals(1,[Select Count() From Credit_Note_Item__c]);
        List<Credit_Note__c> lstCN = new List<Credit_Note__c>([Select id,Status__c From Credit_Note__c]);
        System.assertEquals('Planned',lstCN[0].Status__c);
        delete lstCN[0];
        System.assertEquals(0,[Select Count() From Credit_Note__c]);
        System.assertEquals(0,[Select Count() From DealCreditNote__c]);
        System.assertEquals(0,[Select Count() From Credit_Note_Item__c]);
          Test.stopTest();
    }
    
     @isTest
    static void createCreditNoteFromDeal_DeleteNegativeScenarioTest(){
        
        createTestData(createUser());
        Test.startTest();
            Test.setCurrentPageReference(Page.CRM_CreateCreditNote);
            ApexPages.StandardController sc = new ApexPages.StandardController(lstOpportunity[0]);
            CRM_CreateCreditNoteCtrl ctrl = new CRM_CreateCreditNoteCtrl(sc);
            Credit_Note__c cn = CRM_CreateCreditNoteCtrl.createCreditNote(lstOpportunity[0].Id,lstAccount[0].Id);
      
        System.assertEquals(1,[Select Count() From Credit_Note__c]);
        System.assertEquals(1,[Select Count() From DealCreditNote__c]);
        System.assertEquals(1,[Select Count() From Credit_Note_Item__c]);
        List<Credit_Note__c> lstCN = new List<Credit_Note__c>([Select id,Status__c From Credit_Note__c]);
        System.assertEquals('Planned',lstCN[0].Status__c);
        lstCN[0].Status__c ='Rejected';
        update lstCN;
        List<Credit_Note__c> lstCN1 = new List<Credit_Note__c>([Select id,Status__c From Credit_Note__c]);
        System.assertEquals('Rejected',lstCN1[0].Status__c);
        
        try{
           delete lstCN1[0]; 
        }catch(System.Exception e){
            System.assert(e.getMessage().contains(System.Label.CRM_Restrict_To_Delete_CN_Error_Msg)); 
        }  
          Test.stopTest();
    }
    
    
    @isTest
    static void createCreditNoteFromDealNagative_Test(){
        createTestData(createUser());
        Test.startTest();
            lstOpportunity[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_REVISED;
            update lstOpportunity[0];
            List<OpportunityLineItem> dp = [Select Id,Co_op_Requested_Amount__c From OpportunityLineItem Where OpportunityId = :lstOpportunity[0].Id];
            dp[0].Co_op_Requested_Amount__c = 0;
            update dp;
            submitDealForApproval(lstOpportunity[0]);
            Test.setCurrentPageReference(Page.CRM_CreateCreditNote);
            ApexPages.StandardController sc = new ApexPages.StandardController(lstOpportunity[0]);
            CRM_CreateCreditNoteCtrl ctrl = new CRM_CreateCreditNoteCtrl(sc);
            try{
                Credit_Note__c cn = CRM_CreateCreditNoteCtrl.createCreditNote(lstOpportunity[0].Id,lstAccount[0].Id);
            }catch(system.Exception e){
                System.assert(e.getMessage().contains(System.Label.CRM_Create_CN_Invalid_CoopRequested_Amount));
            }
        Test.stopTest();
        System.assertEquals(0,[Select Count() From Credit_Note__c]);
    }
    
    @isTest
    static void AddDealOnCreditNote_Test(){
        createTestData(createUser());
        Test.startTest();
            Test.setCurrentPageReference(Page.CRM_CreateCreditNote);
            ApexPages.StandardController sc = new ApexPages.StandardController(lstOpportunity[0]);
            CRM_CreateCreditNoteCtrl ctrl = new CRM_CreateCreditNoteCtrl(sc);
            Credit_Note__c cn = CRM_CreateCreditNoteCtrl.createCreditNote(lstOpportunity[0].Id,lstAccount[0].Id);
            
            System.assertEquals(1,[Select Count() From Credit_Note__c]);
            System.assertEquals(1,[Select Count() From DealCreditNote__c]);
            System.assertEquals(1,[Select Count() From Credit_Note_Item__c]);
            
            Test.setCurrentPageReference(Page.CRM_AddDealsOnCreditNote);
            sc = new ApexPages.StandardController(cn);
            ApexPages.currentPage().getParameters().put('id',cn.Id);
            CRM_AddDealsOnCreditNoteController addDealCtrl = new CRM_AddDealsOnCreditNoteController(sc);
            List<CRM_AddDealsOnCreditNoteController.DealWrapper> lstWrapper = CRM_AddDealsOnCreditNoteController.getDeals(cn.Id,lstAccount[0].Id,cb.Id);
            system.assertEquals(3,lstWrapper.size());
            Set<Id> dealIds = new Set<Id>();
            for(CRM_AddDealsOnCreditNoteController.DealWrapper dw : lstWrapper){
                dealIds.add(dw.deal.Id);
                dw.isSelected = true;
            }
            CRM_AddDealsOnCreditNoteController.createCreditNoteItems(cn.Id,lstWrapper,new List<Id>(dealIds),cn.CurrencyIsoCode);
            addDealCtrl.getUserDateFormat();
        Test.stopTest();
        for(DealCreditNote__c dc : [Select Credit_Note_Amount__c From DealCreditNote__c]){
            System.assertEquals(50,dc.Credit_Note_Amount__c,'Amount Roll-up on Junction Object DealCreditNote');
        }
        System.assertEquals(3,[Select Count() From Credit_Note_Item__c]);
    }
    
    @isTest
    static void removeDeal_Test(){
        createTestData(createUser());
        Test.startTest();
            Test.setCurrentPageReference(Page.CRM_CreateCreditNote);
            ApexPages.StandardController sc = new ApexPages.StandardController(lstOpportunity[0]);
            CRM_CreateCreditNoteCtrl ctrl = new CRM_CreateCreditNoteCtrl(sc);
            Credit_Note__c cn = CRM_CreateCreditNoteCtrl.createCreditNote(lstOpportunity[0].Id,lstAccount[0].Id);
            
            System.assertEquals(1,[Select Count() From Credit_Note__c]);
            System.assertEquals(1,[Select Count() From DealCreditNote__c]);
            System.assertEquals(1,[Select Count() From Credit_Note_Item__c]);
            
            Test.setCurrentPageReference(Page.CRM_RemoveDeals);
            sc = new ApexPages.StandardController(cn);
            CRM_AddDealsOnCreditNoteController addDealCtrl = new CRM_AddDealsOnCreditNoteController(sc);
            List<CRM_AddDealsOnCreditNoteController.DealWrapper> lstWrapper = CRM_AddDealsOnCreditNoteController.getDealsForDeletion(cn.Id);
            system.assertEquals(1,lstWrapper.size());
            for(CRM_AddDealsOnCreditNoteController.DealWrapper dw : lstWrapper){
                dw.isSelected = true;
            }
            CRM_AddDealsOnCreditNoteController.removeDealsFromCreditNote(cn.Id,lstWrapper);
        Test.stopTest();
        System.assertEquals(0,[Select Count() From DealCreditNote__c]);
        System.assertEquals(0,[Select Count() From Credit_Note_Item__c]);
    }
    
    @isTest
    static void editAllCreditNoteItemsAndAutoApporveCN_Test(){
        createTestData(createUser());
        Test.startTest();
            Test.setCurrentPageReference(Page.CRM_CreateCreditNote);
            ApexPages.StandardController sc = new ApexPages.StandardController(lstOpportunity[0]);
            CRM_CreateCreditNoteCtrl ctrl = new CRM_CreateCreditNoteCtrl(sc);
            Credit_Note__c cn = CRM_CreateCreditNoteCtrl.createCreditNote(lstOpportunity[0].Id,lstAccount[0].Id);
            
            cn.PO_Number__c = 'Test123';
            update cn;
            
            System.assertEquals(1,[Select Count() From Credit_Note__c]);
            System.assertEquals(1,[Select Count() From DealCreditNote__c]);
            System.assertEquals(1,[Select Count() From Credit_Note_Item__c]);
            
            Test.setCurrentPageReference(Page.CRM_AddDealsOnCreditNote);
            sc = new ApexPages.StandardController(cn);
            CRM_AddDealsOnCreditNoteController addDealCtrl = new CRM_AddDealsOnCreditNoteController(sc);
            List<CRM_AddDealsOnCreditNoteController.DealWrapper> lstWrapper = CRM_AddDealsOnCreditNoteController.getDeals(cn.Id,lstAccount[0].Id,cb.Id);
            system.assertEquals(3,lstWrapper.size());
            Set<Id> dealIds = new Set<Id>();
            for(CRM_AddDealsOnCreditNoteController.DealWrapper dw : lstWrapper){
                dealIds.add(dw.deal.Id);
                dw.isSelected = true;
            }
            CRM_AddDealsOnCreditNoteController.createCreditNoteItems(cn.Id,lstWrapper,new List<Id>(dealIds),cn.CurrencyIsoCode);
            addDealCtrl.getUserDateFormat();
            
            System.assertEquals(3,[Select Count() From DealCreditNote__c]);
            System.assertEquals(3,[Select Count() From Credit_Note_Item__c]);
            
            Test.setCurrentPageReference(Page.CRM_EditAllCreditNoteItems);
            sc = new ApexPages.StandardController(cn);
            ApexPages.currentPage().getParameters().put('cnId',cn.Id);
            CRM_EditAllCreditNoteItemsCtrl editAllCNICtrl = new CRM_EditAllCreditNoteItemsCtrl(sc);
            CRM_EditAllCreditNoteItemsCtrl.DealCreditNoteItemWrapper dealCnWrapper = CRM_EditAllCreditNoteItemsCtrl.getCreditNoteItems(cn.Id);
            for(CRM_EditAllCreditNoteItemsCtrl.CreditNoteItemWrapper cniw : dealCnWrapper.lstCNIWrapper){
                cniw.amount = 20;
                cniw.isDirtyRow = true;
            }
            dealCnWrapper = CRM_EditAllCreditNoteItemsCtrl.saveCreditNoteItems(cn.Id,dealCnWrapper.lstCNIWrapper,true);
            for(CRM_EditAllCreditNoteItemsCtrl.CreditNoteItemWrapper cniw : dealCnWrapper.lstCNIWrapper){
                system.assertEquals(20,cniw.amount,'Updated Amount of CNI');
            }
            for(DealCreditNote__c dc : [Select Credit_Note_Amount__c From DealCreditNote__c]){
                System.assertEquals(20,dc.Credit_Note_Amount__c,'Updated CNA While Updating Amount on CNI]');
            }
            editAllCNICtrl.getMaxCreditNoteItemLimit();
            dealCnWrapper = CRM_EditAllCreditNoteItemsCtrl.saveCreditNoteItems(cn.Id,dealCnWrapper.lstCNIWrapper,false);
            
            Test.setCurrentPageReference(Page.CRM_CreditNoteApproval);
            sc = new ApexPages.StandardController(cn);
            CRM_CreditNoteApprovalCtrl aprovalCtrl = new CRM_CreditNoteApprovalCtrl(sc);
            CRM_CreditNoteApprovalCtrl.creditNoteWrapper cnw = CRM_CreditNoteApprovalCtrl.getRelatedDeals(cn.Id);
            System.assert(cnw.isValidForAutoApprove,'Approval not needed for any deals');
            
            try{
                cnw = CRM_CreditNoteApprovalCtrl.getRelatedDeals(cn.Id);
            }catch(System.Exception e){
                system.assertEquals(System.label.CRM_CN_Approval_ErrorMsg,e.getMessage(),'Invalid Status');
            }
            
            try{
                delete cn;
            }catch(System.DMLException de){
                system.assertEquals(System.label.CRM_Restrict_To_Delete_Approved_CN,de.getDMLMessage(0),'Approved CN Cannot be Deleted');
            }
            
        Test.stopTest();
        
        System.assertEquals(CRM_AppConstants.CREDIT_NOTE_STATUS_READY_TO_PAY, [SELECT Status__c FROM Credit_Note__c].Status__c);
        for(OpportunityLineItem dp : [Select Id,Co_op_Spent__c From OpportunityLineItem]){
            system.assertEquals(20,dp.Co_op_Spent__c,'Amount copied to Co-op Spect of linked Deal Product');
        }
        
        //Refresh Amount on Approved CN
        cn = [Select Id,Status__c From Credit_Note__c Where Id = :cn.Id];
        try{
            CRM_RefreshAmountOnCNIController.refreshAmountOnCNI(cn.Id,cn.Status__c);
        }catch(System.Exception e){
            system.assertEquals(System.label.CRM_Invalid_Status_To_Refresh_Amount_On_CNI,e.getMessage(),'Approved CN Cannot be Refreshed');
        }
        
        Credit_Note__c cn2 = CRM_CreateCreditNoteCtrl.createCreditNote(lstOpportunity[0].Id,lstAccount[0].Id);
        cn2.PO_Number__c = 'Test123';
        update cn2;
        
        for(Credit_Note_Item__c cni : [Select Amount__c From Credit_Note_Item__c Where Credit_Note__c = :cn2.Id AND Deal__c = :lstOpportunity[0].Id]){
            system.assertEquals(30,cni.Amount__c,'Amount populated with Co-op Balance from linked Deal Product');
        } 
        
        //Modify Amount On CN
        Test.setCurrentPageReference(Page.CRM_EditAllCreditNoteItems);
        sc = new ApexPages.StandardController(cn2);
        ApexPages.currentPage().getParameters().put('cnId',cn2.Id);
        editAllCNICtrl = new CRM_EditAllCreditNoteItemsCtrl(sc);
        dealCnWrapper = CRM_EditAllCreditNoteItemsCtrl.getCreditNoteItems(cn2.Id);
        for(CRM_EditAllCreditNoteItemsCtrl.CreditNoteItemWrapper cniw : dealCnWrapper.lstCNIWrapper){
            cniw.amount = 35;
            cniw.isDirtyRow = true;
        }
        dealCnWrapper = CRM_EditAllCreditNoteItemsCtrl.saveCreditNoteItems(cn2.Id,dealCnWrapper.lstCNIWrapper,true);
        for(CRM_EditAllCreditNoteItemsCtrl.CreditNoteItemWrapper cniw : dealCnWrapper.lstCNIWrapper){
            system.assertEquals(35,cniw.amount,'Updated Amount of CNI');
        }
        
        //Refresh Amount on CN From Lined Deal
        Test.setCurrentPageReference(Page.CRM_RefreshAmountOnCNI);
        sc = new ApexPages.StandardController(cn2);
        CRM_RefreshAmountOnCNIController rcnCtrl = new CRM_RefreshAmountOnCNIController(sc);
        CRM_RefreshAmountOnCNIController.refreshAmountOnCNI(cn2.Id,cn2.Status__c);
        
        for(Credit_Note_Item__c cni : [Select Amount__c From Credit_Note_Item__c Where Credit_Note__c = :cn2.Id AND Deal__c = :lstOpportunity[0].Id]){
            system.assertEquals(30,cni.Amount__c,'Amount refreshed with Co-op Balance from linked Deal Product');
        } 
        
        Credit_Note__c excn = new Credit_Note__c();
        Database.SaveResult result = Database.Update(excn, false);
        List<CRM_ErrorLogger.ErrorLog> errorLogInstanceList = CRM_UpdateDealProductCoopSpent.logAnException(result.getErrors(),result.getId());
    }
    
    @isTest
    static void creditNoteApproval_Test(){
        createTestData(createUser());
        Test.startTest();
            Test.setCurrentPageReference(Page.CRM_CreateCreditNote);
            ApexPages.StandardController sc = new ApexPages.StandardController(lstOpportunity[0]);
            CRM_CreateCreditNoteCtrl ctrl = new CRM_CreateCreditNoteCtrl(sc);
            Credit_Note__c cn = CRM_CreateCreditNoteCtrl.createCreditNote(lstOpportunity[0].Id,lstAccount[0].Id);
            
            Test.setCurrentPageReference(Page.CRM_EditAllCreditNoteItems);
            sc = new ApexPages.StandardController(cn);
            ApexPages.currentPage().getParameters().put('cnId',cn.Id);
            CRM_EditAllCreditNoteItemsCtrl editAllCNICtrl = new CRM_EditAllCreditNoteItemsCtrl(sc);
            CRM_EditAllCreditNoteItemsCtrl.DealCreditNoteItemWrapper dealCnWrapper = CRM_EditAllCreditNoteItemsCtrl.getCreditNoteItems(cn.Id);
            for(CRM_EditAllCreditNoteItemsCtrl.CreditNoteItemWrapper cniw : dealCnWrapper.lstCNIWrapper){
                cniw.amount = 100;
                cniw.isDirtyRow = true;
            }
            dealCnWrapper = CRM_EditAllCreditNoteItemsCtrl.saveCreditNoteItems(cn.Id,dealCnWrapper.lstCNIWrapper,true);
            for(CRM_EditAllCreditNoteItemsCtrl.CreditNoteItemWrapper cniw : dealCnWrapper.lstCNIWrapper){
                system.assertEquals(100,cniw.amount,'Updated Amount of CNI');
            }
            
            Test.setCurrentPageReference(Page.CRM_CreditNoteApproval);
            sc = new ApexPages.StandardController(cn);
            CRM_CreditNoteApprovalCtrl aprovalCtrl = new CRM_CreditNoteApprovalCtrl(sc);
            CRM_CreditNoteApprovalCtrl.creditNoteWrapper cnw;
            
            try{
                cnw = CRM_CreditNoteApprovalCtrl.getRelatedDeals(cn.Id);
            }catch(System.Exception e){
                system.assertEquals(System.label.CRM_Credit_Note_PO_Num_Not_Present,e.getMessage(),'PO Number is Blank');
            }
            
            cn.PO_Number__c = 'Test123';
            update cn;
            cnw = CRM_CreditNoteApprovalCtrl.getRelatedDeals(cn.Id);
            System.assertEquals(false,cnw.isValidForAutoApprove,'Approval needed for deals');
        Test.stopTest();
        System.assertEquals(CRM_AppConstants.CREDIT_NOTE_STATUS_AWAITING_APPROVAL, [SELECT Status__c FROM Credit_Note__c].Status__c);
    }
    
    static void submitDealForApproval(Opportunity deal){
        PageReference pageRef = Page.CRM_DealApproval;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',deal.id);
        ApexPages.standardController controller = new ApexPages.standardController(deal);
        //CRM_DealHandler.isFirstRun = true;   
        CRM_DealApproval pg = new CRM_DealApproval(controller); 
        CRM_DataObjects.ProductToEdit[] prds=CRM_DealApproval.getLineItems(deal.id);
        CRM_DealApproval.DealWrapper dw = CRM_DealApproval.getOverlappingDealProducts(deal.id);
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
    
    //Defect#4152
    @isTest
    static void updateCreditNoteStatus_Test(){
        createTestData(createUser());
        Credit_Note__c cn1 = CRM_CreateCreditNoteCtrl.createCreditNote(lstOpportunity[0].Id,lstAccount[0].Id);
        
        Test.startTest();
        cn1.Credit_Note_Header_Status__c  = CRM_AppConstants.CREDIT_NOTE_HEADER_STATUS_IN_SAP;
        cn1.Status__c = CRM_AppConstants.CREDIT_NOTE_STATUS_READY_TO_PAY;
        update cn1;
        system.assertEquals(CRM_AppConstants.CREDIT_NOTE_STATUS_PAID,[SELECT Status__c from Credit_Note__c].Status__c);
        
        cn1.Credit_Note_Header_Status__c = CRM_AppConstants.CREDIT_NOTE_HEADER_STATUS_IN_FAILED;
        cn1.Status__c = CRM_AppConstants.CREDIT_NOTE_STATUS_READY_TO_PAY;
        update cn1;
        system.assertEquals(CRM_AppConstants.CREDIT_NOTE_STATUS_FAILED,[SELECT Status__c from Credit_Note__c].Status__c);
        
        cn1.Credit_Note_Header_Status__c = CRM_AppConstants.CREDIT_NOTE_STATUS_REJECTED;
        cn1.Status__c = CRM_AppConstants.CREDIT_NOTE_STATUS_READY_TO_PAY;
        update cn1;
        system.assertEquals(CRM_AppConstants.CREDIT_NOTE_STATUS_REJECTED,[SELECT Status__c from Credit_Note__c].Status__c);
         
        Test.stopTest();
    }
    
    @isTest
    static void reviseRejectedCN_Test(){
        createTestData(createUser());
        Credit_Note__c cn = CRM_CreateCreditNoteCtrl.createCreditNote(lstOpportunity[0].Id,lstAccount[0].Id);
        
        Test.startTest();
        
        Test.setCurrentPageReference(Page.CRM_RevisedRejectedCreditNote);
        ApexPages.StandardController stdcon = new ApexPages.StandardController(cn);
        CRM_ReviseRejectedCreditNoteCtrl rcn = new CRM_ReviseRejectedCreditNoteCtrl(stdcon);
        
        try{
            CRM_ReviseRejectedCreditNoteCtrl.reviseRejectedCreditNote(cn.Id);
        }catch(System.Exception e){
            system.assertEquals(System.label.CRM_Invalid_Status_To_Revised_CN,e.getMessage(),'Status Must be Rejected To Revised CN');
        }
        
        cn.Status__c = CRM_AppConstants.CREDIT_NOTE_STATUS_REJECTED;
        update cn;
        
        CRM_ReviseRejectedCreditNoteCtrl.reviseRejectedCreditNote(cn.Id);
        System.assertEquals(1,[Select Count() From Credit_Note__c Where Status__c = :CRM_AppConstants.CREDIT_NOTE_STATUS_REVISED]);
        
        Test.stopTest();
    }
    
     @isTest
    static void failedCreditNoteFromSAP_Test(){
        User testUser = createUser();
        createTestData(testUser);
        Test.startTest();
            Test.setCurrentPageReference(Page.CRM_CreateCreditNote);
            ApexPages.StandardController sc = new ApexPages.StandardController(lstOpportunity[0]);
            CRM_CreateCreditNoteCtrl ctrl = new CRM_CreateCreditNoteCtrl(sc);
            Credit_Note__c cn = CRM_CreateCreditNoteCtrl.createCreditNote(lstOpportunity[0].Id,lstAccount[0].Id);
            
            cn.PO_Number__c = 'Test123';
            update cn;
            
            System.assertEquals(1,[Select Count() From Credit_Note__c]);
            System.assertEquals(1,[Select Count() From DealCreditNote__c]);
            System.assertEquals(1,[Select Count() From Credit_Note_Item__c]);
            
            Test.setCurrentPageReference(Page.CRM_AddDealsOnCreditNote);
            sc = new ApexPages.StandardController(cn);
            CRM_AddDealsOnCreditNoteController addDealCtrl = new CRM_AddDealsOnCreditNoteController(sc);
            List<CRM_AddDealsOnCreditNoteController.DealWrapper> lstWrapper = CRM_AddDealsOnCreditNoteController.getDeals(cn.Id,lstAccount[0].Id,cb.Id);
            system.assertEquals(3,lstWrapper.size());
            Set<Id> dealIds = new Set<Id>();
            for(CRM_AddDealsOnCreditNoteController.DealWrapper dw : lstWrapper){
                dealIds.add(dw.deal.Id);
                dw.isSelected = true;
            }
            CRM_AddDealsOnCreditNoteController.createCreditNoteItems(cn.Id,lstWrapper,new List<Id>(dealIds),cn.CurrencyIsoCode);
            addDealCtrl.getUserDateFormat();
            
            System.assertEquals(3,[Select Count() From DealCreditNote__c]);
            System.assertEquals(3,[Select Count() From Credit_Note_Item__c]);
            
            Test.setCurrentPageReference(Page.CRM_EditAllCreditNoteItems);
            sc = new ApexPages.StandardController(cn);
            ApexPages.currentPage().getParameters().put('cnId',cn.Id);
            CRM_EditAllCreditNoteItemsCtrl editAllCNICtrl = new CRM_EditAllCreditNoteItemsCtrl(sc);
            CRM_EditAllCreditNoteItemsCtrl.DealCreditNoteItemWrapper dealCnWrapper = CRM_EditAllCreditNoteItemsCtrl.getCreditNoteItems(cn.Id);
            for(CRM_EditAllCreditNoteItemsCtrl.CreditNoteItemWrapper cniw : dealCnWrapper.lstCNIWrapper){
                cniw.amount = 20;
                cniw.isDirtyRow = true;
            }
            dealCnWrapper = CRM_EditAllCreditNoteItemsCtrl.saveCreditNoteItems(cn.Id,dealCnWrapper.lstCNIWrapper,true);
            for(CRM_EditAllCreditNoteItemsCtrl.CreditNoteItemWrapper cniw : dealCnWrapper.lstCNIWrapper){
                system.assertEquals(20,cniw.amount,'Updated Amount of CNI');
            }
            for(DealCreditNote__c dc : [Select Credit_Note_Amount__c From DealCreditNote__c]){
                System.assertEquals(20,dc.Credit_Note_Amount__c,'Updated CNA While Updating Amount on CNI]');
            }
            editAllCNICtrl.getMaxCreditNoteItemLimit();
            dealCnWrapper = CRM_EditAllCreditNoteItemsCtrl.saveCreditNoteItems(cn.Id,dealCnWrapper.lstCNIWrapper,false);
            
            Test.setCurrentPageReference(Page.CRM_CreditNoteApproval);
            sc = new ApexPages.StandardController(cn);
            CRM_CreditNoteApprovalCtrl aprovalCtrl = new CRM_CreditNoteApprovalCtrl(sc);
            CRM_CreditNoteApprovalCtrl.creditNoteWrapper cnw = CRM_CreditNoteApprovalCtrl.getRelatedDeals(cn.Id);
            System.assert(cnw.isValidForAutoApprove,'Approval not needed for any deals');
            
            System.runAs(testUser){
              cn.Credit_Note_Header_Status__c = CRM_AppConstants.CREDIT_NOTE_STATUS_REJECTED;
            update cn;
            }
            
        Test.stopTest();
        
        System.assertEquals(CRM_AppConstants.CREDIT_NOTE_STATUS_REJECTED, [SELECT Status__c FROM Credit_Note__c].Status__c);
        for(OpportunityLineItem dp : [Select Id,Co_op_Spent__c From OpportunityLineItem]){
            system.assertEquals(0,dp.Co_op_Spent__c,'Amount roll back into Co-op Balance from Co-op Spent');
        }
   }
}