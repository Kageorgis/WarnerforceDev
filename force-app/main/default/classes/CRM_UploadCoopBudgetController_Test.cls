/**
   @Author Cognizant
   @name CRM_UploadCoopBudgetController_Test
   @CreateDate 4 Dec 2017
   @Description Test class for CRM_UploadCoopBudgetController
   @Version <1.0>
   @reference Requirement no 905
*/
@isTest
private class CRM_UploadCoopBudgetController_Test {
    
    /**
    *  Create Test Data. 
    *  @name allTheDataForThisTestClass
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static void allTheDataForThisTestClass() {
        Integer intCount = 0;
        
        List<Account> accounts = CRM_TestDataFactory.createAccounts(5, false);
        for(Account acc : accounts) {
            acc.AccountNumber = 'TestAccount' + intCount;
            acc.Sales_Organization__c = '2500';
            intCount++;
        }
        insert accounts;
        
        intCount = 0;
        List<Product2> products = CRM_TestDataFactory.createProducts(5, false);
        for(Product2 prod : products) {
            prod.ProductCode = '10000' + intCount;
            prod.SAP_Dist_chain_product_Status__c = (intCount == 0 || intCount == 1) 
                                                    ? CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ACTIVE 
                                                    : CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ONHOLD;
            intCount++;
        } 
        insert products; 
        
        List<PricebookEntry> pricebookentries = CRM_TestDataFactory.createPriceBookEntries(products, 1, true);
        
        CRM_Default_Configuration__c objCDC = new CRM_Default_Configuration__c();
        insert objCDC; 
    }
    
	private static testMethod void testCoOpUpload() {
	    Test.startTest();

        allTheDataForThisTestClass();
        
        CRM_UploadCoopBudgetController obj = new CRM_UploadCoopBudgetController();
        
        List<CRM_UploadCoopBudgetController.CoopBudgetWrapper> lstWrap = new List<CRM_UploadCoopBudgetController.CoopBudgetWrapper>();
        
        lstWrap.add(createWrapper(10, 'TestAccount0', '2500', '100000', '2017-10', ''));
        lstWrap.add(createWrapper(10, 'TestAccount0', '2500', '100001', '2017-10', '')); 
        lstWrap.add(createWrapper(10, 'TestAccount1', '2500', '100000', '2017-12', '')); 
        lstWrap.add(createWrapper(10, 'TestAccount1', '2500', '100001', '2017-12', '')); 
        lstWrap.add(createWrapper(10, 'TestAccount1', '2500', '100002', '2017-12', '')); 
        
        //4 Co Op budget will be created 
        CRM_UploadCoopBudgetController.upsertCoopBudgets(lstWrap);
        
        system.assertEquals(4, [SELECT Count() FROM Coop_Budget__c]);
        system.assertEquals(2, [SELECT Count() FROM Opportunity]);
        system.assertEquals(4, [SELECT Count() FROM OpportunityLineItem]);
        
        lstWrap[0].budgetAmount = 20;
        lstWrap[1].accountNumber = 'TestAccount5';
        
        //the existing Co Op budget, Opportunity and OpportunityLineItem will be updated
        CRM_UploadCoopBudgetController.upsertCoopBudgets(lstWrap);
        
        system.assertEquals(4, [SELECT Count() FROM Coop_Budget__c]);
        system.assertEquals(2, [SELECT Count() FROM Opportunity]);
        system.assertEquals(4, [SELECT Count() FROM OpportunityLineItem]);
        
        Test.stopTest();
	}
	
	private static testMethod void testValidation() {
	    Test.startTest();
	    allTheDataForThisTestClass();
	    
	    Integer count = 0;
	    List<CRM_UploadCoopBudgetController.CoopBudgetWrapper> lstWrap = new List<CRM_UploadCoopBudgetController.CoopBudgetWrapper>();
	    lstWrap.add(createWrapper(10, null, '2500', '100000', '2017-10', 'TestEvent'));
	    lstWrap.add(createWrapper(10, 'TestAccount0', null, '100001', '2017-11', 'TestEvent1'));
	    lstWrap.add(createWrapper(10, 'TestAccount1', '2500', null, '2017-11', 'TestEvent'));
	    lstWrap.add(createWrapper(10, 'TestAccount0', '2500', '100000', null, 'TestEvent1'));
	    lstWrap.add(createWrapper(10, 'TestAccount0', '2500', '100000', '201-11', 'TestEvent1'));
	    lstWrap.add(createWrapper(10, 'TestAccount0', '2500', '100000', '2017-13', 'TestEvent1'));
	    lstWrap.add(createWrapper(10, 'TestAccount1', '2500', '100001', '2017-11', 'TestEvent1'));
	    
        CRM_UploadCoopBudgetController.upsertCoopBudgets(lstWrap);
        
        //Account Number, Sales Organization, Product Code and Calendar Month validation
        system.assertEquals(lstWrap[0].validation, system.label.CRM_UploadBudget_Account_Product_CalendarMonth_validation);
        system.assertEquals(lstWrap[1].validation, system.label.CRM_UploadBudget_Account_Product_CalendarMonth_validation);
        system.assertEquals(lstWrap[2].validation, system.label.CRM_UploadBudget_Account_Product_CalendarMonth_validation);
        system.assertEquals(lstWrap[3].validation, system.label.CRM_UploadBudget_Account_Product_CalendarMonth_validation);
        
        //Calendar Month and Year validation
        system.assertEquals(lstWrap[4].validation, system.label.CRM_UploadBudget_Invalid_CalendarMonth_Format);
        system.assertEquals(lstWrap[5].validation, system.label.CRM_UploadBudge_Invalid_Calendar_Month_And_Year);
        
        //Co Op budget successfully created
        system.assertEquals(lstWrap[6].validation, system.label.CRM_Upload_Message_Created);
        
        //1 Co Op budget will be created with the Deal and Deal Product
        system.assertEquals(1, [SELECT Count() FROM Coop_Budget__c]);
        system.assertEquals(1, [SELECT Count() FROM Opportunity]);
        system.assertEquals(1, [SELECT Count() FROM OpportunityLineItem]);
       
        lstWrap = new List<CRM_UploadCoopBudgetController.CoopBudgetWrapper>();
        lstWrap.add(createWrapper(10, 'TestAccount0', '2500', '100000', '2017-11', 'TestEvent'));
        
        CRM_UploadCoopBudgetController.upsertCoopBudgets(lstWrap);
        
        //After updating the account one more Co Op budget will be created with the Deal and Deal Product
        system.assertEquals(2, [SELECT Count() FROM Coop_Budget__c]);
        system.assertEquals(2, [SELECT Count() FROM Opportunity]);
        system.assertEquals(2, [SELECT Count() FROM OpportunityLineItem]);
        
        Test.stopTest();
	}
	
	private static CRM_UploadCoopBudgetController.CoopBudgetWrapper createWrapper(Decimal budgetAmount, String accountNumber, String salesOrg, 
	                                                                              String productCode, String calendarMonth, String eventName) {
	    CRM_UploadCoopBudgetController.CoopBudgetWrapper wrap = new CRM_UploadCoopBudgetController.CoopBudgetWrapper();
	    wrap.budgetAmount = budgetAmount;
        wrap.accountNumber = accountNumber;
        wrap.salesOrg = salesOrg;
        wrap.productCode = productCode;
        wrap.calendarMonth = calendarMonth; 
        wrap.eventName = eventName;
        wrap.isRowModified = true;
        return wrap;
	}
}