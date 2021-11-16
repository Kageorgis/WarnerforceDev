/**
   @Author Cognizant
   @name CRM_CloneCreditNoteCtrl_Test
   @CreateDate 21 Oct 2016
   @Description Test class for CRM_CloneCreditNoteCtrl
   @Version <1.0>
   @reference Defect#3895 (JAPAN)
*/
@isTest(seeAlldata=false)
public with sharing class CRM_CloneCreditNoteCtrl_Test {
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
    public static Credit_Note__c creditNote;
        
    public static void createTestData() {
        //Creating Account
        lstAccount = CRM_TestDataFactory.createAccounts(1, true);
        System.assertEquals(1, lstAccount.size(), 'Account Created');
        
        //Creating Opportunity
        lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount, 3, true);
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
        lstDealProductsWithOpportunities = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstOpportunity, 1, true);
        System.assertEquals(1, lstPriceBookEntries.size(), 'Deal Products Created');   
        
        //Create Coop Budget 
        Coop_Budget__c cb = new Coop_Budget__c();
        cb.Amount__c = 100;
        cb.Customer__c = lstAccount[0].Id;
        cb.Start_Date__c = system.today();
        cb.End_Date__c = system.today() + 30;
        insert cb;
        
        //create Credit Note 
        creditNote = new Credit_Note__c();
        //creditNote.Deal__c = lstOpportunity[0].Id;
        creditNote.Account__c = lstAccount[0].Id;
        creditNote.Coop_Budget__c = cb.id;
        creditNote.CurrencyIsoCode = lstAccount[0].CurrencyIsoCode;
        creditNote.Credit_Note_Header_Status__c = CRM_AppConstants.CREDIT_NOTE_HEADER_STATUS_IN_SAP;
        creditNote.SAP_Order_Number__c = 'Test123';
        creditNote.Credit_Note_Type__c = 'ZMC';
        insert creditNote;
        
        //create Deal Credit Note 
        DealCreditNote__c dealCreditNote = new DealCreditNote__c();
        dealCreditNote.Credit_Note__c = creditNote.ID;
        dealCreditNote.Opportunity__c = lstOpportunity[0].Id;
        dealCreditNote.Unique_Key__c = lstOpportunity[0].Id + '-' + creditNote.ID;
        insert dealCreditNote;
        
        //create Deal Credit Note 
        List<Credit_Note_Item__c> lstcreditNoteItem = new List<Credit_Note_Item__c>();
        Credit_Note_Item__c creditNoteItem;
        for(integer i=0 ; i < lstDealProductsWithOpportunities.size()  ; i++){
            creditNoteItem = new Credit_Note_Item__c();
            creditNoteItem.Credit_Note__c = creditNote.ID;
            creditNoteItem.Deal__c = lstOpportunity[0].Id;
            creditNoteItem.Unique_Id__c = creditNote.Id + '-' + lstOpportunity[0].Id + '-' + lstDealProductsWithOpportunities[i].Id;
            lstcreditNoteItem.add(creditNoteItem);
        }
        insert creditNoteItem;
        
        
    }
    /**
    *  Test 1: Clone creditNote
    *  @name clonecreditNoteTest
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void clonecreditNoteTest(){
        createTestData();
        system.assertEquals(1,[Select Count() From Credit_Note__c]);
        system.assertEquals(1,[Select Count() From Credit_Note_Item__c]);
        system.assertEquals(1,[Select Count() From DealCreditNote__c]);
        
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        System.runAs(u) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_CloneCreditNote'));
            ApexPages.StandardController sc = new ApexPages.StandardController(creditNote);
            CRM_CloneCreditNoteCtrl ctrl = new CRM_CloneCreditNoteCtrl(sc);
            
            Id creditNoteId = CRM_CloneCreditNoteCtrl.cloneCreditNote(creditNote.Id,creditNote.Status__c,creditNote.SAP_Order_Number__c,creditNote.Credit_Note_Header_Status__c);
            system.assertEquals(2,[Select Count() From Credit_Note__c]);
            
            List<Id> lstcreditNoteItemIds = new List<Id>();
            for(Credit_Note_Item__c creditNoteItem : [Select Id From Credit_Note_Item__c]){ 
                lstcreditNoteItemIds.add(creditNoteItem.Id);
            }
            CRM_CloneCreditNoteCtrl.cloneCreditNoteItems(creditNoteId,lstcreditNoteItemIds);
            system.assertEquals(2,[Select Count() From Credit_Note_Item__c]);
            
            //Deal Credit Note will be created when Credit Note is inserted
            system.assertEquals(2,[Select Count() From DealCreditNote__c]);
            
            ApexPages.currentPage().getParameters().put('id',creditNote.Id);
            sc = new ApexPages.StandardController(creditNote);
            ctrl = new CRM_CloneCreditNoteCtrl(sc);
            system.assertEquals(true,ctrl.aleradyRCNExist,'Already exist Reversal CN Error');
        }
    }
    /**
    *  Test 1: Clone creditNote
    *  @name clonecreditNoteTest
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void clonecreditNoteNegativeTest(){
        createTestData();
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        System.runAs(u) {
            creditNote.SAP_Order_Number__c = null;
            update creditNote;
            
            Test.setCurrentPageReference(new PageReference('Page.CRM_CloneCreditNote'));
            ApexPages.StandardController sc = new ApexPages.StandardController(creditNote);
            CRM_CloneCreditNoteCtrl ctrl = new CRM_CloneCreditNoteCtrl(sc);
            
            try{
                Id creditNoteId = CRM_CloneCreditNoteCtrl.cloneCreditNote(creditNote.Id,creditNote.Status__c,creditNote.SAP_Order_Number__c,creditNote.Credit_Note_Header_Status__c);
            }catch(system.Exception e){
                system.assertEquals(System.label.CRM_Credit_Note_Not_IN_SAP,e.getMessage());
            }
            
            creditNote.Status__c = CRM_AppConstants.CREDIT_NOTE_STATUS_REJECTED;
            update creditNote;
            
            try{
                Id creditNoteId = CRM_CloneCreditNoteCtrl.cloneCreditNote(creditNote.Id,creditNote.Status__c,creditNote.SAP_Order_Number__c,creditNote.Credit_Note_Header_Status__c);
            }catch(system.Exception e){
                system.assertEquals(System.label.CRM_Rejected_Credit_Note_Reverse_Error_Msg,e.getMessage());
            }
        }
    }
}