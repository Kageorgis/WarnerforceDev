/**
   @Author Cognizant
   @name CRM_CreditNoteHandler_Test
   @CreateDate 9 Feb 2016
   @Description Test class for CRM_CreditNoteHandler
   @Version <1.0>
   @reference Requirement no 
*/


@isTest
public class CRM_CreditNoteHandler_Test {
    
        public static List<Account> lstAccount;
        public static List<Opportunity> lstOpportunity;
        public static List<OpportunityLineItem> lstDealProductsWithOpportunities;
        public static Coop_Budget__c cb;    
        public static void createTestData(User testUser) {
            //Creating Account
            lstAccount = CRM_TestDataFactory.createAccounts(1, false);
            lstAccount[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_US_CODE;
            insert lstAccount;
            System.assertEquals(1, lstAccount.size(), 'Account Created');
            
            //Create Coop Budget 
            cb = new Coop_Budget__c();
            cb.Amount__c = 100;
            cb.Customer__c = lstAccount[0].Id;
            cb.Start_Date__c = system.today();
            cb.End_Date__c = system.today() + 30;
            insert cb;
            
            //Creating Opportunity
            lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount, 3, false);
            for (Opportunity deal: lstOpportunity){
                deal.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_TRADE_SPEND;
                deal.High_Level_Forecast__c = 100;
                deal.Start_Date__c = system.today();
                deal.Customer_Delivery_Date__c = system.today() + 1;
                deal.Promo_Start_Date__c = system.today() + 2;
            }
            insert lstOpportunity;
            
            System.assertEquals(3, lstOpportunity.size(), 'Opportunities Created');
            
            //Creating Product Group
            List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
            System.assertEquals(1, lstProductGroup.size(), 'Product Group Created');
            
            //Creating Product
            List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 1, true);
            System.assertEquals(1, lstProduct.size(), 'Product Created');
            
            //Creating PricebookEntry
            List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
            System.assertEquals(1, lstPriceBookEntries.size(), 'Pricebook Entries Created');
            CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct,1,true);
          
            //Creating Opportunity Line Item (Deal Products)*/
            lstDealProductsWithOpportunities = CRM_TestDataFactory.createDealProductsWithOpportunities(lstPriceBookEntries, lstOpportunity, 1, false);
            for(OpportunityLineItem dp : lstDealProductsWithOpportunities){
                    dp.Co_op_Requested_Amount__c = 50;
                    dp.Co_op_Spent__c = 0;
            }
            
            insert lstDealProductsWithOpportunities;
            
            System.assertEquals(3, lstDealProductsWithOpportunities.size(), 'Deal Products Created');   
       
    }
    
    @isTest
    static void restrictToDeleteApprovedCN_test(){
        createTestData(createUser());
        test.startTest();
           
            system.debug('=='+cb);
            
            Credit_Note__c c1Test1 =  new Credit_Note__c();
            c1Test1.Coop_Budget__c = cb.id;
            c1Test1.Account__c = lstAccount[0].id;
            c1Test1.Status__c ='Planned';
            c1Test1.Credit_Note_Type__c ='ZMD';
            c1Test1.CurrencyIsoCode ='USD';
            
            insert c1Test1;
            
            c1Test1.Status__c ='Revised';
           update c1Test1;
            
            
             try{
               delete c1Test1;
            }catch(System.DMLException de){
                System.debug('==');
            }
            
        test.stopTest();
    }
    
    static User createUser(){
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        System.assertEquals(1, profiles.size());
        
        Date d = System.today();
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = String.valueOf(d).substring(0,8) + 'abc@test.com',
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