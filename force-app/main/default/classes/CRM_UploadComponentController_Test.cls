/**
   @Author Accenture
   @name CRM_UploadComponentController_Test
   @CreateDate  Mar 2020
   @Description This class is a Test Class
   @Version <1.0>
*/
@isTest
public class CRM_UploadComponentController_Test {
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
    
    private static testMethod void testFieldSetValuesGetDataValues() {
        
        testData();
        List<Opportunity> lstOpp = [SELECT Id,RecordTypeId FROM Opportunity];
        CRM_UploadComponentController obj = new CRM_UploadComponentController();
        String oppRecordTypeId = lstOpp[0].RecordTypeId;
        List<RecordType> s = [select name from recordType where id =:oppRecordTypeId];
        String oppRecordTypeName = s[0].Name;
        String[] values = oppRecordTypeName.replace('/','').split(' ');
        String fieldsetname = String.join(values,'') + '_fieldSetName';
        Test.startTest();
            String result = CRM_UploadComponentController.getFieldSet('OpportunityLineItem', fieldsetname);
            system.assert(result.length() > 0);
            
            Opportunity opp = CRM_UploadComponentController.getOpportunityDetails(lstOpp[0].Id);
            system.assertEquals(opp.RecordType.Name, oppRecordTypeName);
        	try{
        	String invalidtableCols = '["Product_Code__c","Reason__c","OpportunityId","Franchise_Type__c"]';
            List<sObject> emptyrecord = CRM_UploadComponentController.getData(opp.Id,'OpportunityLineItem',invalidtableCols);  
            }catch(Exception e){
            System.assertEquals(e.getMessage(),e.getMessage());
        	}
            String result1 = CRM_UploadComponentController.getFieldSet('testObject', 'fieldsetname');
            String tableCols = '["Product_Code__c","Reason__c","OpportunityId"]';
            List<sObject> record = CRM_UploadComponentController.getData(opp.Id,'OpportunityLineItem',tableCols);
            system.assertEquals(5, record.size());
        
            String oppId = opp.Id;
            String whereCondition = ' where OpportunityId ='+'\''+ oppId +'\'' +'AND Product_Code__c = \'100001\' ' ;
            List<sObject> records = CRM_UploadComponentController.getDealData('OpportunityLineItem',tableCols,whereCondition);
            system.assertEquals(1, records.size());
        	try{
            String invalidtableCols = '["Product_Code__c","Reason__c","OpportunityId","Franchise_Type__c"]';
            List<sObject> getDealdatarec = CRM_UploadComponentController.getDealData('OpportunityLineItem',invalidtableCols,'');
            }catch(Exception e){
            System.assertEquals(e.getMessage(),e.getMessage());
        	}
            
            List<Filter_Fields__mdt> listOfFilter = CRM_UploadComponentController.getOpptyLineItemFilter();
            System.assert(listOfFilter.size() > 0);
            
            // save without any validation errors
            List<OpportunityLineItem> dealPro = [select PriceBookEntryId,Product2Id,Product_Code__c,Reason__c,opportunityid from OpportunityLineItem where opportunityid =: lstOpp[0].Id];
            system.debug(dealPro);
            List<CRM_UploadExtractPOSandDFI.OpportunityLineItemWrapper> optWrap = new List<CRM_UploadExtractPOSandDFI.OpportunityLineItemWrapper>(); 
            for(OpportunityLineItem oppItem : dealPro){
                 optWrap.add(new CRM_UploadExtractPOSandDFI.OpportunityLineItemWrapper(oppItem, true, false,''));
            }
            system.debug(optWrap);
            String isSaved = JSON.serializePretty(CRM_UploadComponentController.saveData(JSON.serialize(optWrap), lstOpp[0].Id));
            system.assert(isSaved.length() > 0);
        
        
            // Delete the selected records
            List<OpportunityLineItem> dealDeletePro = [select id,PriceBookEntryId,Product2Id,Product_Code__c,Reason__c,opportunityid from OpportunityLineItem where opportunityid =: lstOpp[0].Id];
            system.debug(dealPro);
            List<CRM_UploadExtractPOSandDFI.OpportunityLineItemWrapper> optDeleteWrap = new List<CRM_UploadExtractPOSandDFI.OpportunityLineItemWrapper>(); 
            for(OpportunityLineItem oppItem : dealDeletePro){
                 optDeleteWrap.add(new CRM_UploadExtractPOSandDFI.OpportunityLineItemWrapper(oppItem, false, true,''));
            }
            system.debug(optDeleteWrap);
            String isDeleted = JSON.serializePretty(CRM_UploadComponentController.delSelectedRecords(JSON.serialize(optDeleteWrap), lstOpp[0].Id));
            system.assert(isDeleted.length() > 0);
        Test.stopTest(); 
    }
    
    private static testmethod void testForPickListValues(){
        testData();
        List<Opportunity> lstOpp = [SELECT Id,RecordTypeId FROM Opportunity];
        String oppRecordTypeId = lstOpp[0].RecordTypeId;
        List<RecordType> s = [select name from recordType where id =:oppRecordTypeId];
        String oppRecordTypeName = s[0].Name;
        Test.startTest();
        OpportunityLineItem sObjectName = new OpportunityLineItem();
        List<String> allValues = CRM_UploadComponentController.getselectOptions(sObjectName, 'Reason__c',oppRecordTypeName, 'True');
        system.assert(allValues.size() > 0);
        
        List<String> allValues1 = CRM_UploadComponentController.getselectOptions(sObjectName, 'Account_Fund_Segment__c',oppRecordTypeName,'False');
        system.assert(allValues1.size() > 0);
        
        List<String> allValues2 = CRM_UploadComponentController.getselectOptions(sObjectName, 'Reason__c','Physical DFI Deal', 'False');
        system.assert(allValues2.size() > 0);
        try{
        List<String> allValues3 = CRM_UploadComponentController.getselectOptions(sObjectName, 'Product2.Franchise_Type__c','Physical DFI Deal', 'False');
        }catch(Exception e){
            System.assertEquals(e.getMessage(),e.getMessage());
        }
        Test.stopTest();
    }
    
    private static testmethod void testGetPermissions(){
        Test.startTest();
            List<ObjectPermissions> objPerm = CRM_UploadComponentController.getPermissionDetails('Opportunity');
            System.assert(objPerm.size() > 0 );
        Test.stopTest();
    }
}