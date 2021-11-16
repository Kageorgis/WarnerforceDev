@isTest
public class CRM_CancelAssortementDeals_Test {
    
    static testMethod void updateBundle() {
        List<Bundle__c> bundles = new List<Bundle__c>();
        Bundle__c[] assortments = CRM_TestDataFactory.createBundles(4, true);
        for(Bundle__c bundle :assortments){
            bundle.recordTypeId=CRM_RecordTypeUtil.RT_ASSORTMENT_CAMPAIGN;
            bundles.add(bundle);
        }
        Update assortments ;
        
        Account[] accounts = CRM_TestDataFactory.createAccounts(1,true);
        Opportunity[] opportunityList = CRM_TestDataFactory.createOpportunitiesWithAccounts(accounts,3,false);
        
        Integer i = 0;
        for (Opportunity op : opportunityList) {
            op.Last_Published_Date__c = Date.today();
            op.Bundle__c =  assortments[i].Id;
            i++;
        }
        opportunityList.add(new Opportunity(Name = ' TestOpportunity ',
                                       StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED,
                                       CloseDate = System.today() + 30,
                                       AccountId = accounts[0].Id,
                                       Pricebook2Id = System.Test.getStandardPricebookId(),
                                       Start_Date__c = System.today() + 1,
                                       Promo_Start_Date__c = System.today() + 1,
                                       CurrencyIsoCode = 'USD',RecordTypeId=CRM_RecordTypeUtil.RT_DEAL_PHYSICAL,
                                       Bundle__c =  assortments[3].Id
                                       ));
       insert opportunityList;
       
       test.startTest();
       
       Set<Id> assortmentIdSet = new Set<Id>();
       for (Bundle__c assortment : assortments) {
        assortment.Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_CANCELLED; 
        assortmentIdSet.add(assortment.Id); 
       }
       update assortments;
       
       Opportunity[] opportunityTestList = [SELECT StageName,Bundle__c FROM Opportunity
                                            WHERE Bundle__c IN:assortmentIdSet
                                             AND StageName = 'Cancelled'];
       system.assertEquals(3, opportunityTestList.size());
       
       test.stopTest();
        
        
    }
}