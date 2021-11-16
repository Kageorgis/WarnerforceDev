/**
 * @Author: Cognizant
 * @Name: CRM_UpdateDealProductFormatBatch_Test
 * @CreateDate: 1st June 2017 
 * @Description: Test class for CRM_UpdateDealProductFormatBatch
 * @Version 1.0
 */
@isTest
public class CRM_UpdateDealProductFormatBatch_Test {
    
    @testsetup  
    public static void createTestDataForBatchNotificationStatus(){ 
        List<Batch_Notification_Recipients__c> userList  = BatchStatusNotificationTest.initUserDetails(2,'test@gmail.com','CRM');
        insert userList;
        System.assertEquals(2, [SELECT Id FROM Batch_Notification_Recipients__c ].size());
    }
    
    public static void testData(){
        //Create Account  
        List<Account> lstAccount = CRM_TestDataFactory.createAccounts(1, false);
        lstAccount[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccount[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccount[0].CurrencyISOCode = 'USD';
        lstAccount[0].Games_Physical__c = true;
        insert lstAccount;
        
        //Create Product Group 
        List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
        
        //Create Product
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 1, false);
        lstProduct[0].CurrencyIsoCode = 'USD';
        insert lstProduct;
        
        //Create PricebookEntry
        List<PricebookEntry> lstPricebookEntry = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, false);
        lstPricebookEntry[0].Product2Id = lstProduct[0].id;
        lstPricebookEntry[0].CurrencyIsoCode = 'USD';
        insert lstPricebookEntry;
        
        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriod =
        CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{lstProduct[0]}, 1, false);
        lstPriceBookEntryPeriod[0].Product__c =lstProduct[0].id;
        lstPriceBookEntryPeriod[0].Start_Date__c = System.today() + 140;
        lstPriceBookEntryPeriod[0].End_Date__c = System.today() + 150;
        lstPriceBookEntryPeriod[0].CurrencyIsoCode = 'USD';
        lstPriceBookEntryPeriod[0].List_Price__c = 10;
        insert lstPriceBookEntryPeriod;
        
        //Create Opportunity
        List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount, 1, false);
         for (Integer i=0; i < lstOpportunity.size(); i++) {
             lstOpportunity[i].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
             lstOpportunity[i].Start_Date__c = System.today() + 141;
             lstOpportunity[i].Promo_Start_Date__c = System.today() + 141;
             lstOpportunity[i].CloseDate = System.today() + 149;
         }
         insert lstOpportunity;
        
        //Create Deal Product
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPricebookEntry, lstOpportunity, 1, false);
        lstDealProduct[0].Initial_Quantity__c = 10;
        lstDealProduct[0].Replen_Quantity__c = 10;
        insert lstDealProduct;
    } 
    
    public static testMethod void updateProductFormat_Test(){
        testData();
        
        List<OpportunityLineItem> lstDealProduct = [Select Id, Format__c, Product_Format__c from OpportunityLineItem];
        lstDealProduct[0].Format__c = '';
        update lstDealProduct;
        
        System.debug('#Format' + [Select Id, Format__c, Product_Format__c from OpportunityLineItem].Format__c);
        System.assertEquals(null, [Select Id, Format__c, Product_Format__c from OpportunityLineItem].Format__c);
        
        Test.startTest();
        
        CRM_UpdateDealProductFormatBatch batch = new CRM_UpdateDealProductFormatBatch();
        Database.executeBatch(batch);
        
        Test.stopTest();
        
        System.debug('#Format' + [Select Id, Format__c, Product_Format__c from OpportunityLineItem].Format__c);
        System.assertEquals([Select Id, Format__c, Product_Format__c from OpportunityLineItem].Product_Format__c, [Select Id, Format__c, Product_Format__c from OpportunityLineItem].Format__c);
    }
    
    public static testMethod void updateProductFormatCommittedDeal_Test(){
        testData();
        
        User usr = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
             LastName = 'lastName',
             Email = 'rky@wb.com',
             Username = 'rky@wb.com',
             Alias = 'lastName',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US',
             IsActive = true,
             ByPassValidationRule__c = true
        );
        
        //Insert User
        insert usr;
        
        List<User> lstUser = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true and ByPassValidationRule__c = true Limit 1];
        if(!lstUser.isEmpty()){
            System.runAs(lstUser[0]) {
                
                List<Opportunity> lstDeal = [Select Id, StageName from Opportunity];
                lstDeal[0].StageName = 'Committed';
                update lstDeal;
            
                List<OpportunityLineItem> lstDealProduct = [Select Id, Format__c, Product_Format__c from OpportunityLineItem];
                lstDealProduct[0].Format__c = '';
                update lstDealProduct;
            }
        }
        System.debug('#Format' + [Select Id, Format__c, Product_Format__c from OpportunityLineItem].Format__c);
        System.assertEquals(null, [Select Id, Format__c, Product_Format__c from OpportunityLineItem].Format__c);
        
        Test.startTest();
        
        CRM_UpdateDealProductFormatBatch batch = new CRM_UpdateDealProductFormatBatch();
        Database.executeBatch(batch);
        
        Test.stopTest();
        
        System.debug('#Format' + [Select Id, Format__c, Product_Format__c from OpportunityLineItem].Format__c);
        System.assertNotEquals([Select Id, Format__c, Product_Format__c from OpportunityLineItem].Product_Format__c, [Select Id, Format__c, Product_Format__c from OpportunityLineItem].Format__c);
    }
}