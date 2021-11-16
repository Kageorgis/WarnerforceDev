@isTest
public class ImportExcelProcessor_Test {
    // @testsetup 
    public static List<Product2> products =new List<Product2>();
    public static List<OpportunityLineItem> dealProds = new List<OpportunityLineItem>();
    static void allTheDataForThisTestClass(){
        User u = CRM_TestDataFactory.createUser('System Administrator', true);
        system.runAs(u){
            // create account  
            List<Account> lstAccount = CRM_TestDataFactory.createAccounts(1, false);
            lstAccount[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_US_CODE;
            lstAccount[0].RecordTypeId = CRM_RecordTypeUTil.RT_ACCOUNT_SHIP_TO;
            system.debug(lstAccount);
            insert lstAccount;
            system.assertEquals(CRM_AppConstants.TERRITORY_US_CODE, lstAccount[0].Sales_Organization__c);
            Map<String,PricebookEntry> mapOfProductCodeToPB = new Map<String,PricebookEntry>(); 
            // create deal
            List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount, 3, false);
            
            system.debug(lstOpportunity);
            lstOpportunity[0].RecordTypeId = CRM_RecordTypeUtil.RT_Physical_POS_Deal;
            lstOpportunity[0].Start_date__c = System.today();  
            lstOpportunity[0].CloseDate = System.today()+15;
            lstOpportunity[0].Promo_Start_Date__c =System.today()+1;
            lstOpportunity[0].Promo_End_Date__c =System.today()+20;
            
            lstOpportunity[1].Start_date__c = System.today();  
            lstOpportunity[1].CloseDate = System.today()+15;
            lstOpportunity[1].Promo_Start_Date__c =System.today()+1;
            lstOpportunity[1].Promo_End_Date__c =System.today()+20;
            
            lstOpportunity[2].RecordTypeId = CRM_RecordTypeUtil.RT_Physical_Planning_Deal;
            lstOpportunity[2].Start_date__c = System.today();  
            lstOpportunity[2].CloseDate = System.today()+15;
            lstOpportunity[2].Promo_Start_Date__c =System.today()+1;
            lstOpportunity[2].Promo_End_Date__c =System.today()+20;
            
            insert lstOpportunity;
            List<Opportunity> opp =[select id,RecordTypeId from Opportunity where id IN: lstOpportunity];
            system.assertEquals(CRM_RecordTypeUtil.RT_Physical_POS_Deal, opp[0].RecordTypeId);
            
            integer intCount = 0;
            products = CRM_TestDataFactory.createProducts(2, false);
            for(Product2 prod : products) {
                prod.ProductCode = '10000' + intCount;
                prod.SAP_Dist_chain_product_Status__c =  CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ACTIVE ;
                prod.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_US_CODE;
                prod.Product_Format__c = 'DVD';
                prod.isActive = true;
                intCount++;
            } 
            insert products; 
            
            List<PricebookEntry> pricebookentries = CRM_TestDataFactory.createPriceBookEntries(products, 1, true); 
            System.assertEquals(2,pricebookentries.size());
            
            List<Pricebook_Entry_Period__c> pbeD=CRM_TestDataFactory.createPriceBookEntryPeriods(products, 1, true);
            system.assertEquals(2,pbeD.size());
            
            dealProds = CRM_TestDataFactory.createDealProductsWithOpportunities(pricebookentries, lstOpportunity, 2, false);
            for(Integer nProductCount = 0; nProductCount < products.size(); nProductCount++){ 
                for(OpportunityLineItem oli : dealProds) {
                    oli.Reason__c = 'POS Rebate';
                    oli.Product2Id = products[nProductCount].Id;
                    oli.Comments__c = 'Test Comment';
                    oli.Dollar_of_Discount__c = 3;
                    oli.Customer_Reference__c = 'Test Reference';
                }
            }
            system.debug(dealProds);
            insert dealProds;
            System.assertEquals(6,dealProds.size());
        }
    }
    private static testmethod void testGetUpdateFields(){
        allTheDataForThisTestClass();
        List<Opportunity> lstOpp = [SELECT Id,RecordTypeId,RecordType.Name FROM Opportunity];
        String uploadObjectList = '[{"ObjectName__c": "OpportunityLineItem","InputObjectData__c": "[{\\"lineItem\\":{\\"Product_Code__c\\":\\"100001\\",\\"Reason__c\\":\\"POS Rebate\\"},\\"isRowModified\\":true,\\"isError\\":false}]","DealId__c": "'+lstOpp[0].Id+'","status__c": "InProgress","Total_Count__C": 1}]';
        String parentId = ImportExcelController.uploadObjects(uploadObjectList,'OpportunityLineItem',lstOpp[0].Id,1);
        system.debug(parentId); 
        System.assert(parentId.length() > 0);
        
        //Added for Physical Planning Deal
        String uploadObjectList2 = '[{"ObjectName__c": "OpportunityLineItem","InputObjectData__c": "[{\\"lineItem\\":{\\"Product_Code__c\\":\\"100002\\",\\"Reason__c\\":\\"Space\\"},\\"isRowModified\\":true,\\"isError\\":false}]","DealId__c": "'+lstOpp[2].Id+'","status__c": "InProgress","Total_Count__C": 1}]';
        String parentId2 = ImportExcelController.uploadObjects(uploadObjectList2,'OpportunityLineItem',lstOpp[2].Id,1);
        system.debug(parentId2); 
        System.assert(parentId2.length() > 0);
        
        Test.startTest();
            ImportExcelProcessor.UpdateFields(parentId, 'Physical ADV/POS');
        	ImportExcelProcessor.UpdateFields(parentId2, 'Physical Planning Deal');
        Test.stopTest();
    }
    private static testmethod void testGetUpdateFieldsError(){
        allTheDataForThisTestClass();
        List<Opportunity> lstOpp = [SELECT Id,RecordTypeId,RecordType.Name FROM Opportunity];
        String uploadObjectList = '[{"ObjectName__c": "OpportunityLineItem","InputObjectData__c": "[{\\"lineItem\\":{\\"Product_Code__c\\":\\"234567\\",\\"Reason__c\\":\\"POS Rebate\\"},\\"isRowModified\\":true,\\"isError\\":false}]","DealId__c": "'+lstOpp[0].Id+'","status__c": "InProgress","Total_Count__C": 1}]';
        String parentId = ImportExcelController.uploadObjects(uploadObjectList,'OpportunityLineItem',lstOpp[0].Id,1);
        system.debug(parentId); 
        System.assert(parentId.length() > 0);
        Test.startTest();
            ImportExcelProcessor.UpdateFields(parentId, 'Physical ADV/POS');
        Test.stopTest();
    }
    private static testmethod void catchExceptionError(){
        allTheDataForThisTestClass();
        List<Opportunity> lstOpp = [SELECT Id,RecordTypeId,RecordType.Name FROM Opportunity];
        String uploadObjectList = '[{"ObjectName__c": "OpportunityLineItem","InputObjectData__c": "[{\\"optyLineItem\\":{\\"Product_Code__c\\":\\"100001\\",\\"Reason__c\\":\\"POS Rebate\\"},\\"isRowModified\\":true,\\"isError\\":false}]","DealId__c": "'+lstOpp[0].Id+'","status__c": "InProgress","Total_Count__C": 1}]';
        String parentId = ImportExcelController.uploadObjects(uploadObjectList,'OpportunityLineItem',lstOpp[0].Id,1);
        system.debug(parentId); 
        System.assert(parentId.length() > 0);
        Test.startTest();
            ImportExcelProcessor.UpdateFields(parentId, 'Physical ADV/POS');
        Test.stopTest();
    }
}