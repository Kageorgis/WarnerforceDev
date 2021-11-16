@isTest
private class ExcelFileUploadBatch_Test {
    // @testsetup 
    public static List<Product2> products =new List<Product2>();
    public static List<OpportunityLineItem> dealProds = new List<OpportunityLineItem>();
    static void allTheDataForThisTestClass(){
        User u = CRM_TestDataFactory.createUser('System Administrator', true);
        system.runAs(u){
            // create account  
            List<Account> lstAccount = CRM_TestDataFactory.createAccounts(1, false);
            lstAccount[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_US_CODE;
            lstAccount[0].RecordTypeId = CRM_RecordTypeUTil.RT_ACCOUNT_SOLD_TO;
            lstAccount[0].Video_Physical__c = true;
            lstAccount[0].Class_of_Trade__c ='Retail Direct';
            system.debug(lstAccount);
            insert lstAccount;
            system.assertEquals(CRM_AppConstants.TERRITORY_US_CODE, lstAccount[0].Sales_Organization__c);
            Map<String,PricebookEntry> mapOfProductCodeToPB = new Map<String,PricebookEntry>(); 
            //create deal
            List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount, 2, false);
            
            system.debug(lstOpportunity);
            lstOpportunity[0].RecordTypeId = CRM_RecordTypeUtil.RT_Physical_POS_Deal;
            lstOpportunity[0].Start_date__c = System.today();  
            lstOpportunity[0].CloseDate = System.today()+15;
            lstOpportunity[0].Promo_Start_Date__c =System.today()+1;
            lstOpportunity[0].CurrencyIsoCode = 'USD';
            
            lstOpportunity[1].RecordTypeId = CRM_RecordTypeUtil.RT_Physical_Planning_Deal;
            lstOpportunity[1].Start_date__c = System.today();  
            lstOpportunity[1].CloseDate = System.today()+15;
            lstOpportunity[1].Promo_Start_Date__c =System.today()+1;
            lstOpportunity[1].Promo_End_Date__c =System.today()+20;
            lstOpportunity[1].CurrencyIsoCode = 'USD';
            
            insert lstOpportunity;
            List<Opportunity> opp =[select id,RecordTypeId from Opportunity where id IN: lstOpportunity];
            system.assertEquals(CRM_RecordTypeUtil.RT_Physical_POS_Deal, opp[0].RecordTypeId);
            
            integer intCount = 0;
            products = CRM_TestDataFactory.createProducts(5, false);
            for(Product2 prod : products) {
                prod.ProductCode = '10000' + intCount;
                prod.SAP_Dist_chain_product_Status__c =  CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ACTIVE ;
                prod.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_US_CODE;
                prod.Product_Format__c = 'DVD';
                prod.isActive = true;
                intCount++;
            } 
            insert products;
            List<PricebookEntry> pricebookentries = CRM_TestDataFactory.createPriceBookEntries(products, 1 , true); 
            System.assertEquals(5,pricebookentries.size());
            
            list<Pricebook_Entry_Period__c> pricebookentryPeriod= CRM_TestDataFactory.createPriceBookEntryPeriods(products, 1, false);
            for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod){
                pebp.Price_Type__c = 'Retail Direct';
                pebp.Start_Date__c = Date.today().addDays(-15);
                pebp.End_Date__c = Date.today().addDays(15);
            }
            insert pricebookentryPeriod;
            System.assertEquals(5,pricebookentryPeriod.size());
            
            list<Pricebook_Entry_Period__c> pricebookentryPeriod1= CRM_TestDataFactory.createPriceBookEntryPeriods(products, 1, false);
            for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod1){
                pebp.Price_Type__c = 'PROMOTION';
                pebp.Start_Date__c = Date.today().addDays(-15);
                pebp.End_Date__c = Date.today().addDays(15);
            }
            insert pricebookentryPeriod1;
            System.assertEquals(5,pricebookentryPeriod1.size());
            
            list<Pricebook_Entry_Period__c> pricebookentryPeriod2= CRM_TestDataFactory.createPriceBookEntryPeriods(products, 1, false);
            for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod2){
                pebp.Price_Type__c = 'DEALER';
                pebp.Start_Date__c = Date.today().addDays(-15);
                pebp.End_Date__c = Date.today().addDays(15);
            }
            insert pricebookentryPeriod2;
            System.assertEquals(5,pricebookentryPeriod2.size());

            dealProds = CRM_TestDataFactory.createDealProductsWithOpportunities(pricebookentries, lstOpportunity, 5, false);
            for(Integer nProductCount = 0; nProductCount < products.size(); nProductCount++){ 
                for(OpportunityLineItem oli : dealProds) {
                    oli.Reason__c = 'POS Rebate';
                    oli.Product2Id = products[nProductCount].Id;
                    oli.Comments__c = 'Test Comment';
                    oli.Pricebook_Entry_Period__c = pricebookentryPeriod[nProductCount].Id;
                    oli.Dollar_of_Discount__c = 3;
                    oli.Customer_Reference__c = 'Test Reference';
                    oli.Start_date__c = System.today();
                    oli.End_date__c = System.today() + 15;
                }
            }
            insert dealProds;
            System.assertEquals(10,dealProds.size());
        }
    }
    
    private static testmethod void testExcelUploadBatch(){
        allTheDataForThisTestClass();
        
        User u = [Select Id FROM User Where FirstName = 'ABC' AND LastName = 'XYZ' AND IsActive = true LIMIT 1];
        System.runAs(u){
            List<Opportunity> lstOpp = [SELECT Id,RecordTypeId,RecordType.Name FROM Opportunity];
            String uploadObjectList = '[{"ObjectName__c": "OpportunityLineItem","InputObjectData__c": "[{\\"lineItem\\":{\\"Product_Code__c\\":\\"100001\\",\\"Reason__c\\":\\"POS Rebate\\"},\\"isRowModified\\":true,\\"isError\\":false}]","DealId__c": "'+lstOpp[0].Id+'","status__c": "InProgress","Total_Count__C": 1}]';
            String parentId = ImportExcelController.uploadObjects(uploadObjectList,'OpportunityLineItem',lstOpp[0].Id,1);
            system.debug(parentId);
            
            System.assert(parentId.length() > 0);
            
            //Added for Physical Planning Deal
            String uploadObjectList2 = '[{"ObjectName__c": "OpportunityLineItem","InputObjectData__c": "[{\\"lineItem\\":{\\"Product_Code__c\\":\\"100002\\",\\"Reason__c\\":\\"Space\\"},\\"isRowModified\\":true,\\"isError\\":false}]","DealId__c": "'+lstOpp[1].Id+'","status__c": "InProgress","Total_Count__C": 1}]';
            String parentId2 = ImportExcelController.uploadObjects(uploadObjectList2,'OpportunityLineItem',lstOpp[1].Id,1);
            system.debug(parentId2);            
            System.assert(parentId2.length() > 0);
            
            Test.startTest();
            ExcelFileUploadBatch fileUpload = new ExcelFileUploadBatch();
            fileUpload.query = 'select id,status__c,ObjectName__c,InputObjectData__c,Comment__c,credit_Note_Id__c,DealId__c,DealRecordType__c,Total_Count__C, UploadObjectParent__c from UploadObject__c where UploadObjectParent__c!=null and status__c=\'InProgress\' and createddate >= LAST_N_DAYS:1 and (id=\'' + parentId + '\' or id=\'' + parentId2 + '\' ) LIMIT 50000';
            
            Database.executeBatch(fileUpload, 10);
            Test.stopTest();
        }
    }
    
    private static testmethod void testExcelUploadBatch_Error(){
        allTheDataForThisTestClass();
        
        User u = [Select Id FROM User Where FirstName = 'ABC' AND LastName = 'XYZ' AND IsActive = true LIMIT 1];
        System.runAs(u){
            List<Opportunity> lstOpp = [SELECT Id,RecordTypeId,RecordType.Name FROM Opportunity];
            String uploadObjectList = '[{"ObjectName__c": "OpportunityLineItem","InputObjectData__c": "[{\\"lineItem\\":{\\"Product_Code__c\\":\\"1001\\",\\"Reason__c\\":\\"POS\\",\\"Dollar_of_Discount__c\\":3,\\"Percentage_of_Discount__c\\":5},\\"isRowModified\\":true,\\"isError\\":false}]","DealId__c": "'+lstOpp[0].Id+'","status__c": "InProgress","Total_Count__C": 1}]';
            String parentId = ImportExcelController.uploadObjects(uploadObjectList,'OpportunityLineItem',lstOpp[0].Id,1);
            system.debug(parentId);
            
            System.assert(parentId.length() > 0);
            Test.startTest();
            ExcelFileUploadBatch fileUpload = new ExcelFileUploadBatch();
            fileUpload.query = 'select id,status__c,ObjectName__c,InputObjectData__c,Comment__c,credit_Note_Id__c,DealId__c,DealRecordType__c,Total_Count__C, UploadObjectParent__c from UploadObject__c where UploadObjectParent__c!=null and status__c=\'InProgress\' and createddate >= LAST_N_DAYS:1 and id=\''+parentId+'\' LIMIT 50000';
            Database.executeBatch(fileUpload, 10);
            Test.stopTest();
        }
    }
    
    private static testmethod void testExcelUploadBatch_RepriceSuccess(){
        allTheDataForThisTestClass();
        
        User u = [Select Id FROM User Where FirstName = 'ABC' AND LastName = 'XYZ' AND IsActive = true LIMIT 1];
        System.runAs(u){
            List<Opportunity> lstOpp = [SELECT Id,RecordTypeId,RecordType.Name FROM Opportunity];
            String uploadObjectList = '[{"ObjectName__c": "RepriceOpportunityLineItem","InputObjectData__c": "[{\\"attributes\\":{\\"type\\":\\"OpportunityLineItem\\"},\\"Id\\":\\"00k55000008sp9HAAQ\\",\\"Product_Code__c\\":\\"1000518851\\",\\"Start_Date__c\\":\\"2020-06-01\\",\\"End_Date__c\\":\\"2020-07-30\\",\\"Pricebook_Entry_Period__c\\":\\"a1v55000002n0QFAAY\\",\\"ListPrice__c\\":5.00}]","DealId__c": "'+lstOpp[0].Id+'","status__c": "InProgress","Total_Count__C": 1}]';
            String parentId = ImportExcelController.uploadObjects(uploadObjectList,'RepriceOpportunityLineItem',lstOpp[0].Id,1);
            system.debug(parentId);

            System.assert(parentId.length() > 0);
            Test.startTest();
            ExcelFileUploadBatch fileUpload = new ExcelFileUploadBatch();
            fileUpload.query = 'select id,status__c,ObjectName__c,InputObjectData__c,Comment__c,credit_Note_Id__c,DealId__c,DealRecordType__c,Total_Count__C, UploadObjectParent__c from UploadObject__c where UploadObjectParent__c!=null and status__c=\'InProgress\' and createddate >= LAST_N_DAYS:1 and id=\''+parentId+'\' LIMIT 50000';
            Database.executeBatch(fileUpload, 10);
            Test.stopTest();
        }
    }
    
    private static testmethod void catchExceptionErrors(){
        allTheDataForThisTestClass();
        
        User u = [Select Id FROM User Where FirstName = 'ABC' AND LastName = 'XYZ' AND IsActive = true LIMIT 1];
        System.runAs(u){
            ExcelFileUploadBatch fileUpload = new ExcelFileUploadBatch();
            List<Opportunity> lstOpp = [SELECT Id,RecordTypeId,RecordType.Name FROM Opportunity];
            String uploadObjectList = '[{"ObjectName__c": "OpportunityLineItem23","InputObjectData__c": "[{\\"optyLineItem\\":{\\"Product_Code__c\\":\\"100001\\",\\"Reason__c\\":\\"POS Rebate\\"},\\"isRowModified\\":true,\\"isError\\":false},{\\"optyLineItem\\":{\\"Product_Code__c\\":\\"234567\\",\\"Reason__c\\":\\"POS Rebate\\"},\\"isRowModified\\":true,\\"isError\\":false}]","DealId__c": "'+lstOpp[0].Id+'","status__c": "InProgress","Total_Count__C": 1}]';
            String parentId = ImportExcelController.uploadObjects(uploadObjectList,'OpportunityLineItem',lstOpp[0].Id,1);
            system.debug(parentId);
            fileUpload.query = 'select id,status__c,ObjectName__c,InputObjectData__c,Comment__c,credit_Note_Id__c,DealId__c,DealRecordType__c,Total_Count__C, UploadObjectParent__c from UploadObject__c where UploadObjectParent__c!=null and status__c=\'InProgress\' and createddate >= LAST_N_DAYS:1 and id=\''+parentId+'\' LIMIT 50000';
            System.assert(parentId.length() > 0);
            Test.startTest();
            Database.executeBatch(fileUpload, 10);
            Test.stopTest();
        }
    }
}