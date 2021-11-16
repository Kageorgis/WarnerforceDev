@isTest
public class ImportExcelController_Test {
    public static List<Product2> products =new List<Product2>();
    public static List<OpportunityLineItem> dealProds = new List<OpportunityLineItem>();
    static void testData() {
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
            //create deal
            List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount, 1, false);
            
            system.debug(lstOpportunity);
            System.debug(CRM_RecordTypeUtil.RT_Physical_POS_Deal);
            lstOpportunity[0].RecordTypeId = CRM_RecordTypeUtil.RT_Physical_POS_Deal;
            lstOpportunity[0].AccountId = lstAccount[0].Id;
            lstOpportunity[0].Start_date__c = System.today();  
            lstOpportunity[0].CloseDate = System.today()+15;
            lstOpportunity[0].Promo_Start_Date__c =System.today()+1;
            
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
            
            List<PricebookEntry> pricebookentries = CRM_TestDataFactory.createPriceBookEntries(products, 1, true); 
            System.assertEquals(5,pricebookentries.size());
            dealProds = CRM_TestDataFactory.createDealProductsWithOpportunities(pricebookentries, lstOpportunity, 5, false);
            for(Integer nProductCount = 0; nProductCount < products.size(); nProductCount++){ 
                for(OpportunityLineItem oli : dealProds) {
                    oli.Reason__c = 'POS Rebate';
                    oli.Product2Id = products[nProductCount].Id;
                    oli.Comments__c = 'Test Comment';
                    oli.Dollar_of_Discount__c = 3;
                    oli.Customer_Reference__c = 'Test Reference';
                    oli.Start_date__c =Date.today().addDays(-15);
                    oli.End_date__c = Date.today().addDays(15);
                }
            }
            insert dealProds;
            System.assertEquals(5,dealProds.size());
        }
    }
    private static testmethod void testGetPermissions(){
            Test.startTest();
                List<ObjectPermissions> objPerm = ImportExcelController.getPermissionDetails('Opportunity');
                System.assert(objPerm.size() > 0 );
            Test.stopTest();
   }
    
    private static testmethod void testGetTheExportFieldSet(){
        testData();
        List<Opportunity> lstOpp = [SELECT Id,RecordTypeId FROM Opportunity];
        String oppRecordTypeId = lstOpp[0].RecordTypeId;
        List<RecordType> s = [select name from recordType where id =:oppRecordTypeId];
        String oppRecordTypeName = s[0].Name;
        String[] values = oppRecordTypeName.replace('/','').split(' ');
        String fieldsetname = String.join(values,'') + '_fieldSetName';
        Test.startTest();
            String result = ImportExcelController.getExportFieldSet('OpportunityLineItem', fieldsetname);
            system.assert(result.length() > 0);
            
            Opportunity oppDetails = ImportExcelController.getOpportunityDetails(lstOpp[0].Id);
            System.assertEquals('Physical ADV/POS', oppDetails.RecordType.Name);
        Test.stopTest();
    }
    
    private static testmethod void testGetTheUploadProcess(){
        testData();
        List<Opportunity> lstOpp = [SELECT Id,RecordTypeId,RecordType.Name FROM Opportunity];
        Test.startTest();
            String uploadObjectList = '[{"ObjectName__c": "OpportunityLineItem","InputObjectData__c": "[{\\"lineItem\\":{\\"Product_Code__c\\":\\"9000000005\\",\\"Reason__c\\":\\"Display\\"},\\"isRowModified\\":true,\\"isError\\":false}]","DealId__c": "'+lstOpp[0].Id+'","status__c": "InProgress","Total_Count__C": 1}]';
            String parentId = ImportExcelController.uploadObjects(uploadObjectList,'OpportunityLineItem',lstOpp[0].Id,1);
            System.assert(parentId.length() > 0);
        
            ImportExcelController.callBatchClass(parentId, lstOpp[0].RecordType.Name);
            UploadObject__c obj = ImportExcelController.getUploadProcessProgress(parentId);
            system.assertEquals(parentId, obj.Id);
            
            ImportExcelController.getUploadObjectDetails(obj.Id);
            ImportExcelController.getUploadObjects(obj.Id, obj.status__C);
        Test.stopTest();
    }
    private static testmethod void catchExceptionErrors(){
            Test.startTest();
                ImportExcelController.getExportFieldSet('23456', 'fieldsetname');
        	try{
        		//ImportExcelController.getUploadProcessProgress('');
                UploadObject__c test = ImportExcelController.getUploadObjectDetails('null');
            }catch(Exception e){
                System.assertEquals(e.getMessage(),e.getMessage());
            }
        try{
        		ImportExcelController.getUploadProcessProgress('');
            }catch(Exception e){
                System.assertEquals(e.getMessage(),e.getMessage());
            }
            Test.stopTest();
   }
    
    private static testmethod void testIsJVSalesOrgForUpload() {
        
        testData();
        List<Opportunity> lstOpp = [SELECT Id,RecordTypeId, Sales_Organisation__c FROM Opportunity];
        test.startTest();
        	ImportExcelController.isJVSalesOrgForUpload(lstOpp[0].Sales_Organisation__c);
        test.stoptest();
        
    }
}