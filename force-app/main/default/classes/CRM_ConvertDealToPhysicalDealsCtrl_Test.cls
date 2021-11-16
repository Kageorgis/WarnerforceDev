/**
   @Author Cognizant
   @name CRM_ConvertDealToPhysicalDealsCtrl_Test
   @CreateDate 16 Jan 2017
   @Description Test class for CRM_ConvertDealToPhysicalDealsCtrl
   @Version <1.0>
   @reference Requirement no 563
  */

@isTest 
private class CRM_ConvertDealToPhysicalDealsCtrl_Test {
     /**
    *  Create Test Data. 
    *  @name createTestData
    *  @param None 
    *  @return None
    *  @throws None
    */

    static void createTestData() {
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false);   
        System.assertEquals(1, lstAccounts.size());
        insert lstAccounts;
        
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,true);
        for (Opportunity opp : lstDeals) {
            opp.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_HIGH_LEVEL;
            opp.Account = lstAccounts[0];
        }
        update lstDeals;    
    }
     /**
    *  Test 1: Update Deal record Type. 
    *  @name updateDealRecordType
    *  @param None
    *  @return None
    *  @throws None
    */

    static testMethod void updateDealRecordType(){
        createTestData();
        User u = [Select Id from User where Profile.Name = 'CRM - Local Admin - BX' and isActive = true Limit 1];
        Opportunity deal = [Select ID,RecordTypeId FROM Opportunity][0];
        String recId;
        System.runAs(u) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_ConvertDealToPhysicalDeal'));
            
            ApexPages.StandardController sc = new ApexPages.StandardController(deal);
            CRM_ConvertDealToPhysicalDealsCtrl ctrl= new CRM_ConvertDealToPhysicalDealsCtrl(sc);
            
            
            CRM_ConvertDealToPhysicalDealsCtrl.convertDealToPhysical(deal.Id);
        }
        system.debug('Deal record type Id ==>'+deal.RecordTypeId);
        system.assertEquals(CRM_RecordTypeUtil.RT_DEAL_PHYSICAL,[select RecordTypeId from Opportunity limit 1].RecordTypeId);
    }
    
    static testMethod void updateDealRecordTypeInvalidUser(){
        createTestData();
        Opportunity deal = [Select ID,RecordTypeId FROM Opportunity][0];
            Test.setCurrentPageReference(new PageReference('Page.CRM_ConvertDealToPhysicalDeal'));
            
            ApexPages.StandardController sc = new ApexPages.StandardController(deal);
            CRM_ConvertDealToPhysicalDealsCtrl ctrl= new CRM_ConvertDealToPhysicalDealsCtrl(sc);
            
            try{
                CRM_ConvertDealToPhysicalDealsCtrl.convertDealToPhysical(deal.Id);
              
            }catch(exception e){
                System.assertEquals(Label.CRM_Deal_RecordType_Change_Incorrect_Profile,e.getMessage());
            }

    }
    
    static testMethod void updateDealRecordTypeSystemError(){
        createTestData();
        User u = [Select Id from User where Profile.Name = 'CRM - Local Admin - BX' and isActive = true Limit 1];
        Opportunity deal = [Select ID,RecordTypeId FROM Opportunity][0];
        String recId;
        System.runAs(u) {
            Test.setCurrentPageReference(new PageReference('Page.CRM_ConvertDealToPhysicalDeal'));
            
            ApexPages.StandardController sc = new ApexPages.StandardController(deal);
            CRM_ConvertDealToPhysicalDealsCtrl ctrl= new CRM_ConvertDealToPhysicalDealsCtrl(sc);
            
            try{
                CRM_ConvertDealToPhysicalDealsCtrl.convertDealToPhysical(null);
              
            }catch(exception e){
                System.assertNotEquals(null,e.getMessage());
            }
        }
            

    }
}