/**
   @Author Cognizant
   @name CRM_EditOpportunityControllerTest
   @CreateDate 11 May 2017
   @Description Test class for CRM_EditOpportunityController
   @Version <1.0>
   @reference US #630
  */

@isTest(SeeAllData=false)
public class CRM_EditOpportunityControllerTest {
    
    /**
    *  @name closeCoop
    *  @param None 
    *  @return None
    *  @throws None
    */
    
    static testmethod void closeCoop(){
        
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false);   
        System.assertEquals(1, lstAccounts.size());
        lstAccounts[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        insert lstAccounts;
        
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 200, false);
        for (Product2 prodInstance : lstProduct) {
            prodInstance.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        }
        insert lstProduct;
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriiod = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, true);       
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,4,true);
        
        lstAccounts[0].RecordTypeID = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_GERMANY_CODE;
        update lstAccounts;
        
        for (Opportunity opp : lstDeals) {
            opp.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
            opp.Account = lstAccounts[0];
            opp.Customer_Delivery_Date__c = opp.Promo_Start_Date__c;
            opp.Co_op_Closed__c = false;
        }
        update lstDeals;
        
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstDeals, 1, false);
        insert lstDealProduct;
        
        Test.setCurrentPageReference(Page.CRM_Close_Coop);
        Test.setCurrentPage(Page.CRM_Close_Coop); 
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT id FROM Opportunity]));
        CRM_EditOpportunityController ctrl = new CRM_EditOpportunityController(sc);
        Opportunity[] opp1 = ctrl.lstDeals;
        
        List<String> lstDealIds = new List<String>();
        
        for(Opportunity opp : lstDeals){
            lstDealIds.add(opp.Id);
        }
        
        List<CRM_EditOpportunityController.OpportunityError> oppErrorList = new List<CRM_EditOpportunityController.OpportunityError>();
        
        //Create Sys Admin User
        User usr = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'lastName',
            Email = 'xyzwb@gmail.com',
            Username = 'xyzwb@gmail.com',
            Alias = 'xyz',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ByPassValidationRule__c = true,
            isActive = true
        );
        
        //Insert User
        insert usr;
        
        System.runAs(usr) {
            lstDeals[1].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            lstDeals[2].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            lstDeals[2].Co_op_Closed__c = true;
            update lstDeals;
        }
        oppErrorList = CRM_EditOpportunityController.closeCoop(lstDealIds);
        //System.assertEquals(Label.CRM_Deal_is_not_Committed,oppErrorList[0].error,'Deal not Committed');
        System.assertEquals(Label.CRM_Deal_Co_op_is_already_Closed,oppErrorList[0].error,'Deal Co-op Closed');
        List<Opportunity> lstOppty = [SELECT Co_op_Closed__c from Opportunity Where Id =:lstDeals[1].Id];
        System.assertEquals(true, lstOppty[0].Co_Op_Closed__C,'Co-op Closed is true');
        
    }
}