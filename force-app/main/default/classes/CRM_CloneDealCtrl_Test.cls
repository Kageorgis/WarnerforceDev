/**
   @Author-Cognizant Technology Solutions
   @name-CRM_CloneDealCtrl_Test
   @CreateDate-Date> 23 August 2016
   @Description-Test Class to cover different scenarios that will occur for CRM_CloneDealCtrl
   @Version-<1.0>
   @reference-None
  */
@isTest(seeAllData=false)
public class CRM_CloneDealCtrl_Test{

    static Pricebook2 pbk1;
    static Pricebook2 pbk2;
   /**
    *  Description-Test Method to create test data for different scenario's
    *  @name-CRM_CloneDealCtrl_TestData
    *  @param-None
    *  @return-None
    *  @throws exception- An unhandled fault has occurred while processing the flow.  Please contact your system administrator for more information.
    */
    static void CRM_CloneDealCtrl_TestData(){
      /*Creating Account*/  
            List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,True);
            for (Account acct : lstAccounts){
                System.assertNotEquals(null, acct.Id, 'Error while creating Accounts');
            }
      /*Creating Opportunity With Account (Deal)*/
            List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1,false);
            for (Opportunity deal: lstDeals){
                deal.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_DIGITAL;
            }
            insert lstDeals; 
            System.assertEquals(1, lstDeals.size(), 'Created Opportunities');
      /*Creating Product with Product Group and Pricebook*/
            List<Product_Group__c> listProductGroups =   CRM_TestDataFactory.createProductGroups(1,true);
            System.assertEquals(1, listProductGroups.size(), 'Created ProductGroups');
            
             List<Product2> listProduct =   CRM_TestDataFactory.createProducts(listProductGroups,1,false);
                listProduct[0].ProductCode = '123456';
                listProduct[0].Product_Language_Code__c = 'English';
                listProduct[0].Product_Market__c = 'EST';

             insert listProduct;             
             System.assertEquals(1, listProduct.size(), 'Created Products');
             
             List<PricebookEntry> listPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(listProduct,1,true);
             System.assertEquals(1, listPriceBookEntries.size(), 'Created Pricebook Entries');
             List<Pricebook_Entry_Period__c> pbeD = CRM_TestDataFactory.createPriceBookEntryPeriods(listProduct, 1, true);
      /*Creating Opportunity Line Item (Deal Products)*/
             List<OpportunityLineItem> listDealProductsWithOpportunities = CRM_TestDataFactory.createDealProductsWithOpportunities(listPriceBookEntries,lstDeals,1,true);
              System.assertEquals(1, listPriceBookEntries.size(), 'Created Deal Products');                            
    }
     /**
    *  Description-Test Method to create test data for different scenario's
    *  @name-CRM_CloneDealWithDiffAccountPriceBookCtrl_TestData
    *  @param-None
    *  @return-None
    *  @throws exception- An unhandled fault has occurred while processing the flow.  Please contact your system administrator for more information.
    */
    static void CRM_CloneDealWithDiffAccountPriceBookCtrl_TestData(){
    
        pbk1 = new Pricebook2 (Name='Standard Price Book 1',Description='Test Pricebook Entry 1', isActive=true, Business_Unit__c = '6005');
        insert pbk1; 
        
        pbk2 = new Pricebook2 (Name='Standard Price Book 2',Description='Test Pricebook Entry 1', isActive=true, Business_Unit__c = '6014');
        insert pbk2; 
        
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        lstAccounts[0].Price_Book__c = pbk1.Id;
        insert lstAccounts;
        
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1,false);
        lstDeals[0].Pricebook2Id = pbk1.Id;
        insert lstDeals;
        System.assertEquals(1, lstDeals.size(), 'Created Opportunities');
            
        List<Product_Group__c> listProductGroups =   CRM_TestDataFactory.createProductGroups(1,true);
        System.assertEquals(1, listProductGroups.size(), 'Created ProductGroups');
            
        List<Product2> listProduct =  CRM_TestDataFactory.createProducts(listProductGroups,3,false);
        listProduct[0].Product_Language_Code__c = 'English';
        listProduct[1].Product_Language_Code__c = 'German';
        listProduct[2].Product_Language_Code__c = 'Spanish';
        insert listProduct;
        System.assertEquals(3, listProduct.size(), 'Created Products');
        
        List<PricebookEntry> liststandardPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(listProduct,1,true);
        System.assertEquals(3, liststandardPriceBookEntries.size(), 'Created Standard PriceBookEntry');
         
        List<PricebookEntry> listCustomPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(listProduct,1,false);
        for(PricebookEntry pbe : listCustomPriceBookEntries){
            pbe.PriceBook2Id = pbk1.Id;
        }
        insert listCustomPriceBookEntries;
        System.assertEquals(3, listCustomPriceBookEntries.size(), 'Created Custom PriceBookEntry');
         
        List<Pricebook_Entry_Period__c> physicalPEB=CRM_TestDataFactory.createPriceBookEntryPeriods(listProduct, 1, false);
        for(Pricebook_Entry_Period__c pbep : physicalPEB){
            pbep.Price_Book__c = pbk1.Id;
        }
        insert physicalPEB;
        System.assertEquals(3, physicalPEB.size(), 'Created Pricebook Entry Periods');
         
        List<OpportunityLineItem> listDealProductsWithOpportunities = New List<OpportunityLineItem>();
        for(PricebookEntry pbe : listCustomPriceBookEntries){
            OpportunityLineItem objDealProduct = new OpportunityLineItem();
            objDealProduct.OpportunityId = lstDeals[0].Id;
            objDealProduct.PricebookEntryId = pbe.Id;
            objDealProduct.Quantity = 1;
            objDealProduct.UnitPrice = 14.10;
            listDealProductsWithOpportunities.add(objDealProduct);
        }
        insert listDealProductsWithOpportunities;
    }

    static testMethod void CRM_DealCopyMethod(){
        CRM_CloneDealCtrl_TestData();
        List<Opportunity> lstOpp = [SELECT Id, AccountId, Account.Name FROM Opportunity LIMIT 1];
        
        Test.setCurrentPageReference(Page.CRM_CloneDeal);
        ApexPages.StandardController sc = new ApexPages.StandardController(lstOpp[0]);
        CRM_CloneDealCtrl ctrl = new CRM_CloneDealCtrl(sc);
        
        CRM_CloneDealCtrl.DealWrapper dealWrapperSameAccount = new CRM_CloneDealCtrl.DealWrapper();
        dealWrapperSameAccount.dealId = lstOpp[0].id;
        dealWrapperSameAccount.accountId = lstOpp[0].AccountId;
        dealWrapperSameAccount.accountName = lstOpp[0].Account.Name;
        
        Id copiedDealID = CRM_CloneDealCtrl.cloneDeal(lstOpp[0].id, dealWrapperSameAccount);
        System.assertNotEquals(null, copiedDealID , 'Opportunity Copied Successfully');
        
        List<Account> lstNewAccounts = CRM_TestDataFactory.createAccounts(1,True);
        
        CRM_CloneDealCtrl.DealWrapper dealWrapperDiffAccount = new CRM_CloneDealCtrl.DealWrapper();
        dealWrapperDiffAccount.dealId = lstOpp[0].id;
        dealWrapperDiffAccount.accountId = lstNewAccounts[0].Id;
        dealWrapperDiffAccount.accountName = lstNewAccounts[0].Name;
        
        Id newDealID = CRM_CloneDealCtrl.cloneDeal(lstOpp[0].id, dealWrapperDiffAccount);
        System.assertEquals(lstNewAccounts[0].Id, [Select AccountId From Opportunity Where Id = :newDealID].AccountId , 'Opportunity Copied Successfully with new Account');
    }
    
    static testMethod void CRM_DealCopyWithDealProductMethod(){
        CRM_CloneDealCtrl_TestData();
        List<Opportunity> lstOpp = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
        List<OpportunityLineItem> lstDealProducts = [SELECT ID FROM OpportunityLineItem WHERE OpportunityId =:lstOpp[0].id];
        List<Id> dealProductsId = new List<Id>();
        for(OpportunityLineItem oppLineItem : lstDealProducts){
            dealProductsId.add(oppLineItem.Id);
        }
        
        CRM_CloneDealCtrl.ProductSaveError[] errors = new CRM_CloneDealCtrl.ProductSaveError[]{};
        errors = CRM_CloneDealCtrl.cloneDealProducts(lstOpp[0].id,dealProductsId,lstOpp[0].AccountId);
        System.assertNotEquals(null, errors , 'Opportunity Copied Successfully With Opportunity Product');
    }  
    
    static testMethod void updateAccountOnCloneDeal_Test(){
        CRM_CloneDealWithDiffAccountPriceBookCtrl_TestData();
        
        //Create Account Without PriceBook
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,false);
        lstAccounts[0].Price_Book__c = null;
        lstAccounts[0].Name = 'TestAccount';
        insert lstAccounts;
        
        //Get Deal and dealproductIds
        List<Opportunity> lstOpp = [SELECT Id, AccountId, Account.Name FROM Opportunity LIMIT 1];
        List<Id> dealProductsId = new List<Id>();
        for(OpportunityLineItem oppLineItem : [SELECT ID FROM OpportunityLineItem WHERE OpportunityId =:lstOpp[0].id]){
            dealProductsId.add(oppLineItem.Id);
        }
        System.debug('dealProductsId '+dealProductsId);
        Test.setCurrentPageReference(Page.CRM_CloneDeal);
        ApexPages.StandardController sc = new ApexPages.StandardController(lstOpp[0]);
        CRM_CloneDealCtrl ctrl = new CRM_CloneDealCtrl(sc);
        
        //Create Deal Wrapper With new Account 
        CRM_CloneDealCtrl.DealWrapper dealWrapperDiffAccount = new CRM_CloneDealCtrl.DealWrapper();
        dealWrapperDiffAccount.dealId = lstOpp[0].id;
        dealWrapperDiffAccount.accountId = lstAccounts[0].Id;
        dealWrapperDiffAccount.accountName = lstAccounts[0].Name;
        
        //Try to Clone deal 
        try{
            Id copiedDealID = CRM_CloneDealCtrl.cloneDeal(lstOpp[0].id, dealWrapperDiffAccount);
        }catch(system.exception e){
            //Get Error Message Whilie inserting deal with account having No PriceBook
            System.assertEquals(e.getMessage(),System.label.CRM_PriceBook_Not_Present_On_Account);
            
        }
        
        //Update PriceBook on Account
        lstAccounts[0].Price_Book__c = pbk2.Id;
        update lstAccounts;
        
        //Get All Products
        List<Product2> listProduct =  [SELECT Id From Product2 Limit 3];
        
        //Create PriceBookEntry for 2 products with New PriceBook
        List<PricebookEntry> listPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(new List<Product2>{listProduct[0],listProduct[1]},1,false);
        for(PricebookEntry pbe : listPriceBookEntries){
            pbe.PriceBook2Id = pbk2.Id;
        }
        insert listPriceBookEntries;
        
        //Create PriceBookEntryPeriod for 1 product with New PriceBook
        List<Pricebook_Entry_Period__c> physicalPEB=CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{listProduct[0],listProduct[1]}, 1, false);
        for(Pricebook_Entry_Period__c pbep : physicalPEB){
            pbep.Price_Book__c = pbk2.Id;
        }
        insert physicalPEB;
        
        //Clone Deal for New Account having different PriceBook
        Id copiedDealID = CRM_CloneDealCtrl.cloneDeal(lstOpp[0].id, dealWrapperDiffAccount);
        System.assertNotEquals(null, copiedDealID , 'Opportunity Copied Successfully');
        
        Test.startTest();
        
        CRM_CloneDealCtrl.ProductSaveError[] errors = new CRM_CloneDealCtrl.ProductSaveError[]{};
        errors = CRM_CloneDealCtrl.cloneDealProducts(copiedDealID,dealProductsId,lstAccounts[0].Id);
        system.assertEquals(2,[Select Count() From OpportunityLineItem Where OpportunityId = :copiedDealID],'Two deal products should be created with valid PBEP for New PriceBook');
        //system.assertEquals(system.label.CRM_Clone_deal_Product_Error_Msg, errors[0].error, 'PriceBookentry Not found');
        
        //Create PriceBookEntry for third product with New PriceBook
        listPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(new List<Product2>{listProduct[2]},1,false);
        for(PricebookEntry pbe : listPriceBookEntries){
            pbe.PriceBook2Id = pbk2.Id;
        }
        insert listPriceBookEntries;
        
        copiedDealID = CRM_CloneDealCtrl.cloneDeal(lstOpp[0].id, dealWrapperDiffAccount);
        errors = CRM_CloneDealCtrl.cloneDealProducts(copiedDealID,dealProductsId,lstAccounts[0].Id);
        system.assertEquals(system.label.CRM_Upload_Message_PBEP, errors[0].error, 'PriceBookentryPeriod Not found');
        
        //Create PriceBookEntryPeriod for 1 product with New PriceBook
        physicalPEB = CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{listProduct[2]}, 1, false);
        for(Pricebook_Entry_Period__c pbep : physicalPEB){
            pbep.Price_Book__c = pbk2.Id;
        }
        insert physicalPEB;
        
        copiedDealID = CRM_CloneDealCtrl.cloneDeal(lstOpp[0].id, dealWrapperDiffAccount);
        errors = CRM_CloneDealCtrl.cloneDealProducts(copiedDealID,dealProductsId,lstAccounts[0].Id);
        system.assertEquals(0, errors.size(), 'No error found');
        system.assertEquals(3,[Select Count() From OpportunityLineItem Where OpportunityId = :copiedDealID],'Three deal products should be created with valid PBEP for New PriceBook');
        
        Test.stopTest();
    }
}