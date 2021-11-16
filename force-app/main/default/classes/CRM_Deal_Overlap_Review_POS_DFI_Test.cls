/**
@Author Accenture
@name CRM_Deal_Overlap_Review_POS_DFI_Test
@CreateDate 10 June 2020
@Description Test class for CRM_Deal_Overlap_Review_POS_DFI
@Version <1.0>
*/

@isTest
private class CRM_Deal_Overlap_Review_POS_DFI_Test {
    static List<Account> lstAccount = new List<Account>();
    
    /**
	*  Create Test Data. 
	*  @name createTestData
	*  @param None
	*  @return None
	*  @throws None
	*/
    static void createTestData(){
        //create account  
        lstAccount = CRM_TestDataFactory.createAccounts(1, false);
        lstAccount[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_US_CODE;
        lstAccount[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        insert lstAccount;
        
        system.runAs(createTestUser()){
            //create deal
            List<Opportunity> lstOpportunityPOS = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount, 2, false);
            for(Opportunity opp : lstOpportunityPOS){
                opp.RecordTypeId = CRM_RecordTypeUtil.RT_Physical_POS_Deal;
                opp.Start_date__c = System.today();  
                opp.CloseDate = System.today()+15;
                opp.Promo_Start_Date__c = System.today();
                opp.Promo_End_Date__c = System.today() + 30;
            }
            insert lstOpportunityPOS;
            
            List<Opportunity> lstOpportunityDFI = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount, 1, false);
            for(Opportunity opp : lstOpportunityDFI){
                opp.RecordTypeId = CRM_RecordTypeUtil.RT_Physical_DFI_Deal;
                opp.Start_date__c = System.today();  
                opp.CloseDate = System.today()+15;
                opp.Promo_Start_Date__c = System.today();
                opp.Promo_End_Date__c = System.today() + 30;
            }
            insert lstOpportunityDFI;
            
            List<Product2> products = CRM_TestDataFactory.createProducts(5, false);
            for(integer i=0 ; i<products.size() ; i++) {
                products[i].ProductCode = '10000' + i;
                products[i].SAP_Dist_chain_product_Status__c = CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ACTIVE;
                products[i].isActive = true;
                products[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_US_CODE;
            } 
            insert products; 
            
            List<PricebookEntry> pricebookentries = CRM_TestDataFactory.createPriceBookEntries(products, 1, true); 
            System.assertEquals(5,pricebookentries.size());
            
            List<OpportunityLineItem> dealProdsPOS = CRM_TestDataFactory.createDealProductsWithOpportunities(pricebookentries, lstOpportunityPOS, 10, false);
            for(integer i=0;i<dealProdsPOS.size();i++) {
                dealProdsPOS[i].Comments__c = 'Test Comment';
                dealProdsPOS[i].POS_Rebate__c = 100;
                dealProdsPOS[i].POS_Forecast__c = 100;
                dealProdsPOS[i].Co_op_Requested_Amount__c = 100;
                dealProdsPOS[i].Co_op_Actual_Amount__c = 100;
                dealProdsPOS[i].Reason__c = 'Feature';
                dealProdsPOS[i].Start_date__c = System.today() + 7;
                dealProdsPOS[i].End_date__c = System.today() + 15; 
                dealProdsPOS[i].Customer_Reference__c = 'Test Reference';
                dealProdsPOS[i].Digital_Membership__c = 'Test Digital Membership';
            }
            insert dealProdsPOS;
            System.assertEquals(20,dealProdsPOS.size());
            
            List<OpportunityLineItem> dealProdsDFI = CRM_TestDataFactory.createDealProductsWithOpportunities(pricebookentries, lstOpportunityDFI, 10, false);
            for(integer i=0;i<dealProdsDFI.size();i++) {
                dealProdsDFI[i].Comments__c = 'Test Comment';
                dealProdsDFI[i].POS_Rebate__c = 100;
                dealProdsDFI[i].POS_Forecast__c = 100;
                dealProdsDFI[i].Co_op_Requested_Amount__c = 100;
                dealProdsDFI[i].Co_op_Actual_Amount__c = 100;
                dealProdsDFI[i].Reason__c = 'Display';
                dealProdsDFI[i].Start_date__c = System.today() + 7;
                dealProdsDFI[i].End_date__c = System.today() + 15; 
                dealProdsDFI[i].Customer_Reference__c = 'Test Reference';
                dealProdsDFI[i].Digital_Membership__c = 'Test Digital Membership';
            }
            insert dealProdsDFI;
            System.assertEquals(10,dealProdsDFI.size());
        }
    }

    /**
	*  Create Test Data for JV project. 
	*  @name createTestDataForJV
	*  @param None
	*  @return None
	*  @throws None
	*/
    static void createTestDataForJV(){
        //create account  
        lstAccount = CRM_TestDataFactory.createAccounts(1, false);
        lstAccount[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
        lstAccount[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        insert lstAccount;
        
        system.runAs(createTestUser()){
            //create deal
            List<Opportunity> lstOpportunityPOS = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount, 1, false);
            for(Opportunity opp : lstOpportunityPOS){
                opp.RecordTypeId = CRM_RecordTypeUtil.RT_Physical_POS_Deal;
                opp.Start_date__c = System.today();  
                opp.CloseDate = System.today()+15;
                opp.Promo_Start_Date__c = System.today();
                opp.Promo_End_Date__c = System.today() + 30;
            }
            insert lstOpportunityPOS;
            
            List<Opportunity> lstOpportunityDFI = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount, 1, false);
            for(Opportunity opp : lstOpportunityDFI){
                opp.RecordTypeId = CRM_RecordTypeUtil.RT_Physical_DFI_Deal;
                opp.Start_date__c = System.today();  
                opp.CloseDate = System.today()+15;
                opp.Promo_Start_Date__c = System.today();
                opp.Promo_End_Date__c = System.today() + 30;
            }
            insert lstOpportunityDFI;

            List<Opportunity> lstOpportunityPlanning = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount, 2, false);
            for(integer i=0;i<lstOpportunityPlanning.size();i++) {
                lstOpportunityPlanning[i].Name = 'Test Deal '+String.valueOf(i);
                lstOpportunityPlanning[i].RecordTypeId = CRM_RecordTypeUtil.RT_Physical_Planning_Deal;
                lstOpportunityPlanning[i].Start_date__c = System.today();  
                lstOpportunityPlanning[i].CloseDate = System.today()+15;
                lstOpportunityPlanning[i].Promo_Start_Date__c = System.today();
                lstOpportunityPlanning[i].Promo_End_Date__c = System.today() + 30;
            }
            insert lstOpportunityPlanning;
            
            List<Product2> products = CRM_TestDataFactory.createProducts(5, false);
            for(integer i=0 ; i<products.size() ; i++) {
                products[i].ProductCode = '10000' + i;
                products[i].SAP_Dist_chain_product_Status__c = CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ACTIVE;
                products[i].isActive = true;
                products[i].SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
            } 
            insert products; 
            
            List<PricebookEntry> pricebookentries = CRM_TestDataFactory.createPriceBookEntries(products, 1, true); 
            System.assertEquals(5,pricebookentries.size());
            
            List<OpportunityLineItem> dealProdsPOS = CRM_TestDataFactory.createDealProductsWithOpportunities(pricebookentries, lstOpportunityPOS, 10, false);
            for(integer i=0;i<dealProdsPOS.size();i++) {
                dealProdsPOS[i].Comments__c = 'Test Comment';
                dealProdsPOS[i].POS_Rebate__c = 100;
                dealProdsPOS[i].POS_Forecast__c = 100;
                dealProdsPOS[i].Co_op_Requested_Amount__c = 100;
                dealProdsPOS[i].Co_op_Actual_Amount__c = 100;
                dealProdsPOS[i].Reason__c = 'Feature';
                dealProdsPOS[i].Start_date__c = System.today() + 7;
                dealProdsPOS[i].End_date__c = System.today() + 15; 
                dealProdsPOS[i].Customer_Reference__c = 'Test Reference';
                dealProdsPOS[i].Digital_Membership__c = 'Test Digital Membership';
            }
            insert dealProdsPOS;
            System.assertEquals(10,dealProdsPOS.size());
            
            List<OpportunityLineItem> dealProdsDFI = CRM_TestDataFactory.createDealProductsWithOpportunities(pricebookentries, lstOpportunityDFI, 10, false);
            for(integer i=0;i<dealProdsDFI.size();i++) {
                dealProdsDFI[i].Comments__c = 'Test Comment';
                dealProdsDFI[i].POS_Rebate__c = 100;
                dealProdsDFI[i].POS_Forecast__c = 100;
                dealProdsDFI[i].Co_op_Requested_Amount__c = 100;
                dealProdsDFI[i].Co_op_Actual_Amount__c = 100;
                dealProdsDFI[i].Reason__c = 'Display';
                dealProdsDFI[i].Start_date__c = System.today() + 7;
                dealProdsDFI[i].End_date__c = System.today() + 15; 
                dealProdsDFI[i].Customer_Reference__c = 'Test Reference';
                dealProdsDFI[i].Digital_Membership__c = 'Test Digital Membership';
            }
            insert dealProdsDFI;
            System.assertEquals(10,dealProdsDFI.size());

            List<OpportunityLineItem> dealProdsPlanning = CRM_TestDataFactory.createDealProductsWithOpportunities(pricebookentries, lstOpportunityPlanning, 10, false);
            for(integer i=0;i<dealProdsPlanning.size();i++) {                
                dealProdsPlanning[i].Comments__c = 'Test Comment';
                dealProdsPlanning[i].POS_Rebate__c = 100;
                dealProdsPlanning[i].POS_Forecast__c = 100;
                dealProdsPlanning[i].Co_op_Requested_Amount__c = 100;
                dealProdsPlanning[i].Co_op_Actual_Amount__c = 100;
                dealProdsPlanning[i].Start_date__c = System.today() + 7;
                dealProdsPlanning[i].End_date__c = System.today() + 15; 
                dealProdsPlanning[i].Customer_Reference__c = 'Test Reference';
                dealProdsPlanning[i].Digital_Membership__c = 'Test Digital Membership';
            }
            insert dealProdsPlanning;
            System.assertEquals(20,dealProdsPlanning.size());
        }
    }    
    
    /**
	*  Method to test the deal overlap functionality
	*/
    private static testMethod void generateOverlaps_Test1() {
        createTestData();
        
        List<Opportunity> oppList = [Select Id, Deal_Overlap_Review_Completed__c, Deal_Overlap_Exists__c FROM Opportunity 
                                     WHERE RecordTypeId=:CRM_RecordTypeUtil.RT_Physical_POS_Deal LIMIT 1];
        Test.startTest();
        CRM_Deal_Overlap_Review_POS_DFI.generateOverlaps(oppList);
        Test.stopTest();
        
        Opportunity opp = [Select Id, Deal_Overlap_Review_Completed__c, Deal_Overlap_Results_10k_Plus__c FROM Opportunity WHERE Id =: oppList[0].Id];
        System.assertEquals(opp.Deal_Overlap_Review_Completed__c, true, 'Deal Overlap Review Completed');
        System.assertEquals(opp.Deal_Overlap_Results_10k_Plus__c, false, 'Less than 10k overlap records');
        
        List<Deal_Overlap__c> dealOverlapList =  [Select Id, Current_Deal__c FROM Deal_Overlap__c WHERE Current_Deal__c=:oppList[0].Id LIMIT 9999];
        System.assertEquals(dealOverlapList.size(), 10);
    }
    
        /**
	*  Method to test the deal overlap functionality
	*/
    private static testMethod void generateOverlaps_Test2() {
        createTestData();
        
        List<Opportunity> oppList = [Select Id, Deal_Overlap_Review_Completed__c, Deal_Overlap_Exists__c FROM Opportunity 
                                     WHERE RecordTypeId=:CRM_RecordTypeUtil.RT_Physical_DFI_Deal LIMIT 1];
        oppList[0].Deal_Overlap_Review_Completed__c = true;
        update oppList;
        
        Deal_Overlap__c dOverlap = new Deal_Overlap__c(Current_Deal__c = oppList[0].Id);
        insert dOverlap;
        
        Test.startTest();
        CRM_Deal_Overlap_Review_POS_DFI.generateOverlaps(oppList);
        Test.stopTest();
        
        Opportunity opp = [Select Id, Deal_Overlap_Review_Completed__c, Deal_Overlap_Results_10k_Plus__c FROM Opportunity WHERE Id =: oppList[0].Id];
        System.assertEquals(opp.Deal_Overlap_Review_Completed__c, true, 'Deal Overlap Review Completed');
        System.assertEquals(opp.Deal_Overlap_Results_10k_Plus__c, false, 'Less than 10k overlap records');
        
        List<Deal_Overlap__c> dealOverlapList =  [Select Id, Current_Deal__c FROM Deal_Overlap__c WHERE Current_Deal__c=:oppList[0].Id LIMIT 9999];
        System.assertEquals(dealOverlapList.size(), 0);
    }
    
    /**
	*  Method to test the deal overlap functionality for JV
	*/
    private static testMethod void generateOverlapsForJV_Test1(){
        createTestDataForJV();
        
        List<Opportunity> oppList = [Select Id, Deal_Overlap_Review_Completed__c, Deal_Overlap_Exists__c FROM Opportunity 
                                     WHERE RecordTypeId=:CRM_RecordTypeUtil.RT_Physical_Planning_Deal LIMIT 1];
        Test.startTest();
        CRM_Deal_Overlap_Review_POS_DFI.generateOverlaps(oppList);
        Test.stopTest();
        
        Opportunity opp = [Select Id, Deal_Overlap_Review_Completed__c, Deal_Overlap_Results_10k_Plus__c FROM Opportunity WHERE Id =: oppList[0].Id];
        System.assertEquals(opp.Deal_Overlap_Review_Completed__c, true, 'Deal Overlap Review Completed');
        System.assertEquals(opp.Deal_Overlap_Results_10k_Plus__c, false, 'Less than 10k overlap records');
        
        List<Deal_Overlap__c> dealOverlapList =  [Select Id, Current_Deal__c FROM Deal_Overlap__c WHERE Current_Deal__c=:oppList[0].Id LIMIT 9999];
        System.assertEquals(dealOverlapList.size(), 30);
    }
    
    /**
	*  Method to test the deal overlap functionality for JV
	*/
    private static testMethod void generateOverlapsForJV_Test2(){
        createTestDataForJV();
        
        List<Opportunity> oppList = [Select Id, Deal_Overlap_Review_Completed__c, Deal_Overlap_Exists__c FROM Opportunity 
                                     WHERE RecordTypeId=:CRM_RecordTypeUtil.RT_Physical_Planning_Deal LIMIT 1];
        oppList[0].Deal_Overlap_Review_Completed__c = true;
        update oppList;
        
        Deal_Overlap__c dOverlap = new Deal_Overlap__c(Current_Deal__c = oppList[0].Id);
        insert dOverlap;
        
        Test.startTest();
        CRM_Deal_Overlap_Review_POS_DFI.generateOverlaps(oppList);
        Test.stopTest();
        
        Opportunity opp = [Select Id, Deal_Overlap_Review_Completed__c, Deal_Overlap_Results_10k_Plus__c FROM Opportunity WHERE Id =: oppList[0].Id];
        System.assertEquals(opp.Deal_Overlap_Review_Completed__c, true, 'Deal Overlap Review Completed');
        System.assertEquals(opp.Deal_Overlap_Results_10k_Plus__c, false, 'Less than 10k overlap records');
        
        List<Deal_Overlap__c> dealOverlapList =  [Select Id, Current_Deal__c FROM Deal_Overlap__c WHERE Current_Deal__c=:oppList[0].Id LIMIT 9999];
        System.assertEquals(dealOverlapList.size(), 30);
    }

	//Method to create Test User
    static User createTestUser(){
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());
        
        // Create Batch created deal along with Batch created Deal Product which lies in current month but Stage Changed
        Date d = System.today();
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = String.valueOf(d) + 'abc@test.com',
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