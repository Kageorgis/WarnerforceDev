@isTest
public class CRM_AssortmentApprovalEmilTempCtrl_Test{
     
     /**
    *  Test 1
    *  @name UnitTestData
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void UnitTestData() {
         
        //Accounts
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(2, true);   
        
        //Assortment 
        List<Bundle__c> assortmentList = CRM_TestDataFactory.createBundles(1,true);
        
        //Assortment Account
        Assortment_Account__c assortAccount1 = CRM_TestDataFactory.createAssortmentAccount(assortmentList[0],lstAccounts[0]);
        Assortment_Account__c assortAccount2 = CRM_TestDataFactory.createAssortmentAccount(assortmentList[0],lstAccounts[1]);
        List<Assortment_Account__c> accountList = new List<Assortment_Account__c>{assortAccount1,assortAccount2};
        insert accountList;
                
        //Deal with Promotional Assortment 
        List<Opportunity> lstDeals = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts, 1, false);
        lstDeals[0].Bundle__c = assortmentList[0].Id;
        lstDeals[0].Assortment_Account__c = assortAccount1.Id;
        lstDeals[0].Deal_Code__c = '123456'; 
        insert lstDeals;
        
        CRM_AssortmentApprovalEmailTemplateCtrl ctrl = new CRM_AssortmentApprovalEmailTemplateCtrl();
        ctrl.assortment = [Select Id,(Select Id,Assortment__c  From Assortment_Accounts__r) From Bundle__c Where Id =: assortmentList[0].Id Limit 1];
        Map<Id,String> accountDealCodeMap = ctrl.getAccountDealCodeMap();
        
        //Assert Map size
        system.assertEquals(accountDealCodeMap.size(),2);
     }    
}