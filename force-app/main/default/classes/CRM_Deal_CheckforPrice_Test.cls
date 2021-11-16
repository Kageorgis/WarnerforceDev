/**
@Author Accenture
@name CRM_Deal_CheckforPrice_Test
@CreateDate 29 June 2020
@Description Test class for CRM_Deal_CheckforPrice
@Version <1.0>
*/

@isTest
private class CRM_Deal_CheckforPrice_Test {
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
        lstAccount = CRM_TestDataFactory.createAccounts(2, false);
        lstAccount[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_US_CODE;
        lstAccount[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccount[0].Class_of_Trade__c = CRM_AppConstants.CLASS_OF_TRADE_RETAIL_COST;
        lstAccount[1].Sales_Organization__c = CRM_AppConstants.TERRITORY_US_CODE;
        lstAccount[1].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccount[1].Class_of_Trade__c = CRM_AppConstants.CLASS_OF_TRADE_RETAIL_DIRECT;
        insert lstAccount;
        
        system.runAs(createTestUser()){
            //create deal
            List<Opportunity> lstOpportunityPOS = CRM_TestDataFactory.createOpportunitiesWithAccounts(new List<Account>{lstAccount[0]}, 1, false);
            for(Opportunity opp : lstOpportunityPOS){
                opp.RecordTypeId = CRM_RecordTypeUtil.RT_Physical_POS_Deal;
                opp.Start_date__c = System.today();  
                opp.CloseDate = System.today()+15;
                opp.Promo_Start_Date__c = System.today();
                opp.Promo_End_Date__c = System.today() + 30;
            }
            insert lstOpportunityPOS;
            
            List<Opportunity> lstOpportunityDFI = CRM_TestDataFactory.createOpportunitiesWithAccounts(new List<Account>{lstAccount[1]}, 1, false);
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
            
            List<Pricebook_Entry_Period__c> createPBEPList = CRM_TestDataFactory.createPriceBookEntryPeriods(products, 1, false);
            for(Pricebook_Entry_Period__c pbep : createPBEPList){
                pbep.Price_Type__c = CRM_AppConstants.PBEP_PRICE_TYPE_PROMOTION;
                pbep.Start_Date__c = System.today() + 10;
            }
            insert createPBEPList;
            System.assertEquals(5,createPBEPList.size());
            
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
        }
    }
    
    /**
	*  Method to test the check for price functionality
	*/
    private static testMethod void checkforPrice_FuturePriceExists_TestScenario() {
        createTestData();
        String result = '';
        
        List<Opportunity> oppList = [Select Id FROM Opportunity WHERE RecordTypeId=:CRM_RecordTypeUtil.RT_Physical_POS_Deal LIMIT 1];
        Test.startTest();
        result = CRM_Deal_CheckforPrice.getNewPriceDetails(oppList[0].Id);
        Test.stopTest();
        
        CRM_Deal_CheckforPrice.NewPriceWrapper npw = (CRM_Deal_CheckforPrice.NewPriceWrapper)JSON.deserialize(result, CRM_Deal_CheckforPrice.NewPriceWrapper.class);
        System.assert(String.isBlank(npw.msgSeverity));
        System.assert(String.isBlank(npw.msgText));
    }
    
    /**
	*  Method to test the check for price functionality
	*/
    private static testMethod void checkforPrice_NoDealProducts_TestScenario() {
        createTestData();
        String result = '';
        
        List<Opportunity> oppList = [Select Id FROM Opportunity WHERE RecordTypeId=:CRM_RecordTypeUtil.RT_Physical_DFI_Deal LIMIT 1];
        List<OpportunityLineItem> dealProductList = [Select Id FROM OpportunityLineItem WHERE OpportunityId=:oppList[0].Id];
        delete dealProductList;
        
        Test.startTest();
        result = CRM_Deal_CheckforPrice.getNewPriceDetails(oppList[0].Id);
        Test.stopTest();
        
        CRM_Deal_CheckforPrice.NewPriceWrapper npw = (CRM_Deal_CheckforPrice.NewPriceWrapper)JSON.deserialize(result, CRM_Deal_CheckforPrice.NewPriceWrapper.class);
        System.assertEquals(npw.msgSeverity, 'error');
        System.assertEquals(npw.msgText, Label.CRM_Check_Reprice_No_Deal_Product);
    }
    
    /**
	*  Method to test the check for price functionality
	*/
    private static testMethod void checkforPrice_NoFuturePriceDataAvailable_TestScenario() {
        createTestData();
        String result = '';
        
        List<Opportunity> oppList = [Select Id FROM Opportunity WHERE RecordTypeId=:CRM_RecordTypeUtil.RT_Physical_DFI_Deal LIMIT 1];
        Test.startTest();
        result = CRM_Deal_CheckforPrice.getNewPriceDetails(oppList[0].Id);
        Test.stopTest();
        
        CRM_Deal_CheckforPrice.NewPriceWrapper npw = (CRM_Deal_CheckforPrice.NewPriceWrapper)JSON.deserialize(result, CRM_Deal_CheckforPrice.NewPriceWrapper.class);
        System.assertEquals(npw.msgSeverity, 'warning');
        System.assertEquals(npw.msgText, Label.CRM_Check_Reprice_No_Available_Data);
    }
    
	//Method to create Test User
    static User createTestUser(){
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());

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