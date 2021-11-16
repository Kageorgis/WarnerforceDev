/**
   @Author-Cognizant Technology Solutions
   @name-CRM_CloneDealWithProducts_Test
   @CreateDate-Date>
   @Description-Test Class to cover different scenarios that will occur for CRM_CloneFlowController
   @Version-<1.0>
   @reference-None
  */
@isTest
private class CRM_CloneDealNDealProdGrpController_Test{
/**
    *  Description-Test Method to pass the Deal Id to Flow parameter and test different scenario's 
    *  @name-myUnitTest()
    *  @param-None
    *  @return-None
    *  @throws exception- An unhandled fault has occurred while processing the flow.  Please contact your system administrator for more information.
    */
    static testMethod void CRM_CloneDealNDealProductGrpControllerTestDataMethod(){
        List<Opportunity> lstDeals;
        List<Opportunity> lstUpdatedDeals = new List<Opportunity>();
        ApexPages.StandardController sc;
        CRM_CloneDealNDealProductGrpController testDeal;
        
        User u = [Select Id from User where Id =: userInfo.getUserId()];
        System.runAs(u) {
            //Creating accounts to pass as parameter while creating opportunities
            List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1,True);
            for (Account acct : lstAccounts)
            System.assertNotEquals(null, acct.Id, 'Error while creating Accounts');
            
            // Create Opportunity objects
            lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1,false);
            for (Opportunity deal: lstDeals){
                deal.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_HIGH_LEVEL;
                lstUpdatedDeals.add(deal);
            }
            insert lstUpdatedDeals; 
            System.assertEquals(1, lstUpdatedDeals.size(), 'Created Opportunities');
            
            Test.StartTest();

            sc = new ApexPages.StandardController(lstDeals[0]);
            testDeal = new CRM_CloneDealNDealProductGrpController(sc);
            testDeal.startFlow();
            
            PageReference pageRef = Page.CRM_CloneDealNDealProductGroup;
            Test.setCurrentPage(pageRef);
            
            try{
                sc = new ApexPages.StandardController(lstDeals[0]);
                testDeal = new CRM_CloneDealNDealProductGrpController(sc);
                testDeal.params = null;
                testDeal.startFlow();
                
            }
            catch(Exception e){
                System.AssertEquals(true,e.getMessage().contains(null));
                
            }
            
            Test.StopTest();
            
            delete lstDeals;
        }
    }
}