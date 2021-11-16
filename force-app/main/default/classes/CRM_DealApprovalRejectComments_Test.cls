/**
   @Author Cognizant
   @name CRM_DealApprovalRejectComments_Test
   @CreateDate 8 DEC 2017
   @Description Test class for CRM_DealApprovalRejectComments
   @Version <1.0>
   @reference Requirement no 
*/
@isTest
public with sharing class CRM_DealApprovalRejectComments_Test {
    
    //Setup data for test class
    static void allTheDataForThisTestClass(){
    	CRM_Default_Configuration__c objCS = new CRM_Default_Configuration__c(Deal_Product_Limit_in_Email_Templates__c = 100);
		insert objCS;
    	
        //create accounts
        list<Account> accounts = CRM_TestDataFactory.createAccounts(1, false);
        
        //update accounts in order to create a relationship
        accounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_US_CODE;
        insert accounts;
        
        list<Opportunity> opps = CRM_TestDataFactory.createOpportunitiesWithAccounts(accounts, 1, false);
        opps[0].recordtypeId = CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND;
        insert opps;
        system.assertEquals(1,opps.size());
        
        List<Product_Group__c> pgs = CRM_TestDataFactory.createProductGroups(1, true);
        List<Product2> products = CRM_TestDataFactory.createProducts(pgs, 2, true);
        
        List<PricebookEntry> pbEntries = CRM_TestDataFactory.createPriceBookEntries(products, 1, true);
        
        List<Pricebook_Entry_Period__c> pbeD=CRM_TestDataFactory.createPriceBookEntryPeriods(products, 1, true);
        
        List<OpportunityLineItem> dealproducts = CRM_TestDataFactory.createDealProductsWithOpportunities(pbEntries, opps, 1, true);
    }
    
    static testMethod void unitTestPositive() {
        allTheDataForThisTestClass();
        list<Opportunity> Opportunities = [select id, name, Start_Date__c, CloseDate, accountId, account.Sales_Organization__c,StageName 
                                           from Opportunity];
        Test.startTest();
            callStandardApprovalProcess(Opportunities[0].Id);
            CRM_DealApprovalRejectComments dealCom = new CRM_DealApprovalRejectComments();
            dealCom.DealIds = Opportunities[0].Id;
            ProcessInstanceStep ps = dealCom.getApprovalSteps();
            system.assertNotEquals(ps, null);
            
        Test.stopTest();
        
    }
    
    /**
    *  @Description - method to perform approval process and then redirect control back to Deal standard detail page
    *  @name  goBackToDeal 
    */
    public static void callStandardApprovalProcess(Id dealID){
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(dealID);
            // submit the approval request for processing
            Approval.ProcessResult result = Approval.process(req);
    }
    
}