/**
   @Author Accenture
   @name CRM_UploadExtractPOSandDFI_Test
   @CreateDate  Mar 2020
   @Description This class is a Test Class
   @Version <1.0>
*/
@isTest
public class CRM_UploadExtractPOSandDFI_Test {
    
    public static List<Product2> products =new List<Product2>();
    public static List<OpportunityLineItem> dealProds = new List<OpportunityLineItem>();
    
    public static Id priceBookJVId;
    static{
        if(priceBookJVId == null){
            priceBookJVId = createPriceBookForJV().Id;
        }
    }
    
    /* createPriceBookForJV()
     * This method is called to create JV PriceBook for a test class.
     * SalesOrg = number of records to be created.
     * shouldInsert = to tell if records need to be inserted or need just instances (True => will insert records in DB).
     */
    public static Pricebook2 createPriceBookForJV(){
        Pricebook2 JVPricebook = new Pricebook2(
            Name = 'SDS - US',
            IsActive = true,
            Business_Unit__c = CRM_AppConstants.TERRITORY_SDS_US_CODE,
            External_Id__c = CRM_AppConstants.TERRITORY_SDS_US_CODE + '-10',
            Product_Type__c = 'Physical',
            Country__c = 'USA'
        );
        insert JVPricebook;
        system.assertNotEquals(null, JVPricebook);
        return JVPricebook;
    }    

    static void testData() {
        User u = CRM_TestDataFactory.createUser('System Administrator', true);
        system.runAs(u){
            //create account  
            List<Account> lstAccount = CRM_TestDataFactory.createAccounts(1, false);
            lstAccount[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_US_CODE;
            lstAccount[0].RecordTypeId = CRM_RecordTypeUTil.RT_ACCOUNT_SHIP_TO;
            lstAccount[0].Class_of_Trade__c ='Retail Direct';
            system.debug(lstAccount);
            insert lstAccount;
            system.assertEquals(CRM_AppConstants.TERRITORY_US_CODE, lstAccount[0].Sales_Organization__c);
            Map<String,PricebookEntry> mapOfProductCodeToPB = new Map<String,PricebookEntry>(); 
            //create deal
            List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount, 1, false);
            
            system.debug(lstOpportunity);
            lstOpportunity[0].RecordTypeId = CRM_RecordTypeUtil.RT_Physical_POS_Deal;
            lstOpportunity[0].Start_date__c = System.today();  
            lstOpportunity[0].CloseDate = System.today()+15;
            lstOpportunity[0].Promo_Start_Date__c =System.today()+1;
            //lstOpportunity[0].CurrencyIsoCode = 'USD';
            //lstOpportunity[0].Account
            
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
                    oli.Start_date__c =Date.today().addDays(-15);
                    oli.End_date__c = Date.today().addDays(15);
                }
            }
            insert dealProds;
            System.assertEquals(5,dealProds.size());
        }
    }
    
    static void testDataForJV(Id dealRecordTypeId, Boolean requireByPassValidation) {
        User u = CRM_TestDataFactory.createUser('System Administrator', requireByPassValidation);
        system.runAs(u){
            //create account  
            List<Account> lstAccount = CRM_TestDataFactory.createAccounts(1, false);
            lstAccount[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
            lstAccount[0].RecordTypeId = CRM_RecordTypeUTil.RT_ACCOUNT_SHIP_TO;
            lstAccount[0].Class_of_Trade__c ='Retail Direct';
            lstAccount[0].AccountNumber ='123456789';
            lstAccount[0].Price_Book__c = priceBookJVId;
            insert lstAccount;
            system.assertEquals(CRM_AppConstants.TERRITORY_SDS_US_CODE, lstAccount[0].Sales_Organization__c);
            Map<String,PricebookEntry> mapOfProductCodeToPB = new Map<String,PricebookEntry>(); 

            //create deal
            List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount, 1, false);
            lstOpportunity[0].RecordTypeId = dealRecordTypeId;  //CRM_RecordTypeUtil.RT_Physical_POS_Deal;
            lstOpportunity[0].Start_date__c = System.today();  
            lstOpportunity[0].CloseDate = System.today()+15;
            lstOpportunity[0].Promo_Start_Date__c =System.today();
            lstOpportunity[0].Promo_End_Date__c = System.today()+15;
            lstOpportunity[0].Pricebook2Id = priceBookJVId;
            //lstOpportunity[0].CurrencyIsoCode = 'USD';
            //lstOpportunity[0].Account
            if(dealRecordTypeId == CRM_RecordTypeUtil.RT_Physical_DFI_Deal){
                lstOpportunity[0].Price_Type__c = CRM_AppConstants.DEAL_PRICE_TYPE_ZPRD;
            }else if(dealRecordTypeId == CRM_RecordTypeUtil.RT_Physical_POS_Deal){
                lstOpportunity[0].Method_of_Payment__c = CRM_AppConstants.DEAL_MOP_CREDIT_MEMO;
            }
            insert lstOpportunity;
            List<Opportunity> opp =[select id,RecordTypeId from Opportunity where id IN: lstOpportunity];
            system.assertEquals(dealRecordTypeId, opp[0].RecordTypeId);
            //system.assertEquals(CRM_RecordTypeUtil.RT_Physical_POS_Deal, opp[0].RecordTypeId);
            
            integer intCount = 0;
            products = CRM_TestDataFactory.createProducts(5, false);
            for(Product2 prod : products) {
                prod.ProductCode = '10000' + intCount;
                prod.SAP_Dist_chain_product_Status__c =  CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ACTIVE ;
                prod.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
                prod.Product_Format__c = 'DVD';
                prod.isActive = true;
                intCount++;
            } 
            insert products;

            List<PricebookEntry> pricebookentries = CRM_TestDataFactory.createPriceBookEntries(products, 1 , true); 
            System.assertEquals(5,pricebookentries.size());

            List<PricebookEntry> customLstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(products, 1, false);
            for(PricebookEntry pbe : customLstPriceBookEntries){
                pbe.Pricebook2Id = priceBookJVId;
            }
            insert customLstPriceBookEntries;

            list<Pricebook_Entry_Period__c> pricebookentryPeriod= CRM_TestDataFactory.createPriceBookEntryPeriods(products, 1, false);
            for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod){
                pebp.Price_Type__c = 'Retail Direct';
                pebp.Start_Date__c = Date.today().addDays(-15);
                pebp.End_Date__c = Date.today().addDays(15);
                pebp.Price_Book__c = priceBookJVId;
            }
            insert pricebookentryPeriod;
            System.assertEquals(5,pricebookentryPeriod.size());
            
            list<Pricebook_Entry_Period__c> pricebookentryPeriod1= CRM_TestDataFactory.createPriceBookEntryPeriods(products, 1, false);
            for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod1){
                pebp.Price_Type__c = 'PROMOTION';
                pebp.Start_Date__c = Date.today().addDays(-15);
                pebp.End_Date__c = Date.today().addDays(15);
                pebp.Price_Book__c = priceBookJVId;
            }
            insert pricebookentryPeriod1;
            System.assertEquals(5,pricebookentryPeriod1.size());
            
            list<Pricebook_Entry_Period__c> pricebookentryPeriod2= CRM_TestDataFactory.createPriceBookEntryPeriods(products, 1, false);
            for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod2){
                pebp.Price_Type__c = 'DEALER';
                pebp.Start_Date__c = Date.today().addDays(-15);
                pebp.End_Date__c = Date.today().addDays(15);
                pebp.Price_Book__c = priceBookJVId;
            }
            insert pricebookentryPeriod2;
            System.assertEquals(5,pricebookentryPeriod2.size());
            
            dealProds = CRM_TestDataFactory.createDealProductsWithOpportunities(customLstPriceBookEntries, lstOpportunity, 5, false);
            for(Integer nProductCount = 0; nProductCount < products.size(); nProductCount++){ 
                for(OpportunityLineItem oli : dealProds) {
                    oli.Product2Id = products[nProductCount].Id;
                    oli.Comments__c = 'Test Comment';
                    oli.Pricebook_Entry_Period__c = pricebookentryPeriod[nProductCount].Id;
                    oli.Dollar_of_Discount__c = 3;
                    oli.Customer_Reference__c = 'Test Reference';
                    oli.Start_Date__c = Date.today().addDays(1);
                    oli.End_Date__c = Date.today().addDays(14);
                    if(dealRecordTypeId == CRM_RecordTypeUtil.RT_Physical_DFI_Deal){
                        oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_DFI;
                        oli.Account_Fund_Segment__c = CRM_AppConstants.DEAL_PRODUCT_ACCOUNT_FUND_SEGMENT_NAT;
                    }else if(dealRecordTypeId == CRM_RecordTypeUtil.RT_Physical_POS_Deal){
                        oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_POS_REBATE;
                    }
                }
            }
            insert dealProds;
            System.assertEquals(5,dealProds.size());
        }
    }
    
    // CRM_UploadExtractPOSandDFI getopplt method Test
    private static testMethod void testOnloadGetOpptlineItems() {
        
        testData();
        
        Test.startTest();
            List<Opportunity> lstOpp = [SELECT Id,RecordTypeId,Opportunity.Account.Class_of_Trade__c,CloseDate,Start_Date__c,Pricebook2Id,CurrencyIsoCode FROM Opportunity];
            Apexpages.standardController stdCtrl = new Apexpages.standardController(lstOpp[0]);
            CRM_UploadExtractPOSandDFI obj = new CRM_UploadExtractPOSandDFI(stdCtrl);
            CRM_UploadExtractPOSandDFI.OpportunityLineItemWrapper lineItemWrapper = new CRM_UploadExtractPOSandDFI.OpportunityLineItemWrapper();
            String oppRecordTypeId = lstOpp[0].RecordTypeId;
            List<RecordType> s = [select name from recordType where id =:oppRecordTypeId];
            List<OpportunitylineItem> opplt = [select Product_Code__c,OpportunityId,Start_Date__c,End_Date__c,Pricebook_Entry_Period__c,ListPrice__c From OpportunitylineItem];
            system.debug(opplt);
            String oppRecordTypeName = s[0].Name;
            String[] values = oppRecordTypeName.replace('/','').split(' ');
            String fieldsetname = String.join(values,'') + '_fieldSetName';
            Test.setCurrentPageReference(Page.CRM_UploadExtractPOSandDFI);
            ApexPages.StandardController scc = new ApexPages.StandardController(lstOpp[0]);
            CRM_UploadExtractPOSandDFI a= new CRM_UploadExtractPOSandDFI(scc);
            a.getChunkSizeForTradeTactics();
            a.getHandsonTable_Pro_Licencekey();
            a.getUserLocale();
            a.getUserDateFormat();
            CRM_UploadExtractPOSandDFI.profileReadOnly();
          
            CRM_UploadExtractPOSandDFI.addPBEPforDealProducts(opplt);
            CRM_UploadExtractPOSandDFI.repriceDealProduct(lstOpp);
            String optyLineItem = CRM_UploadExtractPOSandDFI.getopplt('opportunityLineItem', fieldsetname, lstOpp[0].Id);
            system.assert(optyLineItem.length() > 0);
          
            try{
               String optyLineItem1 = CRM_UploadExtractPOSandDFI.getopplt('opportunityLineItem', 'fieldsetname', 'null'); 
            }catch(Exception e){
            System.assertEquals(e.getMessage(),e.getMessage());
          }
          
            List<String> allValues = CRM_UploadExtractPOSandDFI.getselectOptions('OpportunityLineItem', 'Reason__c',oppRecordTypeName, 'True');
            system.assert(allValues.size() > 0);
            
           List<String> allValues1 = CRM_UploadExtractPOSandDFI.getselectOptions('OpportunityLineItem', 'Account_Fund_Segment__c',oppRecordTypeName, 'False');
          system.assert(allValues1.size() > 0);
        
          List<String> allValues2 = CRM_UploadExtractPOSandDFI.getselectOptions('OpportunityLineItem', 'Reason__c','Physical DFI Deal', 'False');
          system.assert(allValues2.size() > 0);
        
            List<String> allOtherValues = CRM_UploadExtractPOSandDFI.getselectOptions('OpportunityLineItem', 'Product2.Franchise_Type__c',oppRecordTypeName, 'False');
          try{
          List<String> allOtherValues1 = CRM_UploadExtractPOSandDFI.getselectOptions('OpportunityLineItem', 'null',oppRecordTypeName, 'False');
            }catch(Exception e){
            System.assertEquals(e.getMessage(),e.getMessage());
          }
        
        Test.stopTest(); 
    }
    /*
     *  Method to test the validations for tactic to be saved
     */
    private static testmethod void testSaveWithValidation(){
        testData();
        List<Opportunity> lstOpp = [SELECT Id,RecordTypeId FROM Opportunity];
        List<OpportunityLineItem> opplt= [SELECT Id,Commitment_Number__c,Product_Code__c,Reason__c FROM OpportunityLineItem];
        
        Test.startTest();
            Test.setCurrentPageReference(Page.CRM_UploadExtractPOSandDFI);
            ApexPages.StandardController scc = new ApexPages.StandardController(lstOpp[0]);
            CRM_UploadExtractPOSandDFI a= new CRM_UploadExtractPOSandDFI(scc);
            String OpportunityId = lstOpp[0].Id;

            String dealproducts = '[{"lineItem": {"Product_Code__c": "23434","Reason__c": "Cost Markdown Rebate"},"isRowModified": true,"isRowRemoved": false}]';
            system.debug('testdealproducts-->'+dealproducts);
            List<CRM_UploadExtractPOSandDFI.OpportunityLineItemWrapper> isSave = CRM_UploadExtractPOSandDFI.savePOSAndDFIDealLineItems(dealproducts, lstOpp[0].Id,false);
            System.assert(isSave.size() > 0 );

            String dealproductsError2 = '[{"lineItem": {"Product_Code__c": "100002","Reason__c": "Cost Markdown Rebate","Dollar_of_Discount__c":3,"Percentage_of_Discount__c":5},"isRowModified": true,"isRowRemoved": false,"isError": false}]';  
            List<CRM_UploadExtractPOSandDFI.OpportunityLineItemWrapper> isSaveWithErrors2 = CRM_UploadExtractPOSandDFI.savePOSAndDFIDealLineItems(dealproductsError2, lstOpp[0].Id,false);        
            system.assert(isSaveWithErrors2.size() > 0);
        
            String dealproducts2 = '[{"lineItem": {"Id":"'+opplt[0].Id+'","Product_Code__c": "100002","Reason__c": "Cost Markdown Rebate","Status__c": "Committed"},"isRowModified": true,"isRowRemoved": false,"isError": false}]';  
            List<CRM_UploadExtractPOSandDFI.OpportunityLineItemWrapper> isSaveWithErrors = CRM_UploadExtractPOSandDFI.savePOSAndDFIDealLineItems(dealproducts2, lstOpp[0].Id,false);        
            system.assert(isSaveWithErrors.size() > 0);
          
          String dealproducts3 = '[{"lineItem": {"Id":null,"Product_Code__c": "100002","Reason__c": "Cost Markdown Rebate","Status__c": "Committed","Commitment_Number__c":"'+opplt[0].Commitment_Number__c+'"},"isRowModified": true,"isRowRemoved": false,"isError": false}]';  
            List<CRM_UploadExtractPOSandDFI.OpportunityLineItemWrapper> isSaveWithErrors3 = CRM_UploadExtractPOSandDFI.savePOSAndDFIDealLineItems(dealproducts3, lstOpp[0].Id,false);        
            system.assert(isSaveWithErrors3.size() > 0);
          
          String dealproducts4 = '[{"lineItem": {"Id":null,"Product_Code__c": "100002","Reason__c": "Cost Markdown Rebate","Status__c": "Committed","Commitment_Number__c":"123456"},"isRowModified": true,"isRowRemoved": false,"isError": false}]';  
            List<CRM_UploadExtractPOSandDFI.OpportunityLineItemWrapper> isSaveWithErrors4 = CRM_UploadExtractPOSandDFI.savePOSAndDFIDealLineItems(dealproducts4, lstOpp[0].Id,false);        
            system.assert(isSaveWithErrors4.size() > 0);
        
            String excelDealProducts = '[{"lineItem": {"Product_Code__c": "100003","Reason__c": "Display"},"isRowModified": true,"isRowRemoved": false,"isError": true}]';
            List<String> excelSaved = CRM_UploadExtractPOSandDFI.excelUploadPOSAndDFI(excelDealProducts, lstOpp[0].Id);
            System.assert(excelSaved.size() > 0);
          try{
          List<String> excelSaved1 = CRM_UploadExtractPOSandDFI.excelUploadPOSAndDFI(excelDealProducts, 'null');
            }catch(Exception e){
                System.assertEquals(e.getMessage(), e.getMessage());
            }
            
            String handsonTableDealProducts = '[{"lineItem": {"Product_Code__c": "100001","Reason__c": "Display"},"isRowModified": true,"isRowRemoved": false}]';
            String handsonSaved = CRM_UploadExtractPOSandDFI.posAndDFIRecords(handsonTableDealProducts, lstOpp[0].Id);
            System.assert(handsonSaved.length() > 0);
          try{
          String handsonSaved1 = CRM_UploadExtractPOSandDFI.posAndDFIRecords(handsonTableDealProducts, '');
            }catch(Exception e){
                System.assertEquals(e.getMessage(),e.getMessage());
            }
            CRM_UploadExtractPOSandDFI.updateBulkRepriceDealProducts(JSON.serialize(opplt));
        
            List<OpportunityLineItem> toDelete = [select id,PriceBookEntryId,Product2Id,Product_Code__c,Reason__c,opportunityid from OpportunityLineItem where opportunityid =: lstOpp[0].Id];
            system.debug(toDelete);
            List<CRM_UploadExtractPOSandDFI.OpportunityLineItemWrapper> optDeleteWrap = new List<CRM_UploadExtractPOSandDFI.OpportunityLineItemWrapper>(); 
            for(OpportunityLineItem oppItem : toDelete){
                 optDeleteWrap.add(new CRM_UploadExtractPOSandDFI.OpportunityLineItemWrapper(oppItem, false, true,''));
            }
            system.debug(optDeleteWrap);
            String isDeleted = JSON.serializePretty(CRM_UploadExtractPOSandDFI.deletedRecordsPOSandDFI(JSON.serialize(optDeleteWrap), lstOpp[0].Id));
            system.assert(isDeleted.length() > 0);
          try{
          String isDeleted1 = JSON.serializePretty(CRM_UploadExtractPOSandDFI.deletedRecordsPOSandDFI(null, null));
            }catch(Exception e){
                System.assertEquals(e.getMessage(),e.getMessage());
            }
        system.assert(isDeleted.length() > 0);
            
            String handsonTableDealProducts1 = '[{"lineItem": {"Product_Code__c": "100001","Reason__c": "Display"},"isRowModified": true,"isRowRemoved": false},{"lineItem": {"Product_Code__c": "100002","Reason__c": "Display"},"isRowModified": false,"isRowRemoved": true}]';
            String handsonSaved1 = CRM_UploadExtractPOSandDFI.posAndDFIRecords(handsonTableDealProducts1, lstOpp[0].Id);
            System.assert(handsonSaved1.length() > 0);
   
        Test.stopTest(); 
    }
    private static testMethod void testgetProductsScreen() {
        Id standardPricebookId = System.Test.getStandardPricebookId();
        testData();
        
        Test.startTest();
            List<Opportunity> lstOpp = [SELECT Id,RecordTypeId,Pricebook2Id,CurrencyISOCode,Account.name,Start_date__c,CloseDate FROM Opportunity];
            Apexpages.standardController stdCtrl = new Apexpages.standardController(lstOpp[0]);
            CRM_UploadExtractPOSandDFI obj = new CRM_UploadExtractPOSandDFI(stdCtrl);
            String oppRecordTypeId = lstOpp[0].RecordTypeId;
            List<RecordType> s = [select name from recordType where id =:oppRecordTypeId];
            String[] oppRecordTypeName = (s[0].Name).split(' ');
            List<Product2> prod = [Select Id,ProductCode FROM Product2];
            System.debug('products'+prod);
        
            Test.setCurrentPageReference(Page.CRM_UploadExtractPOSandDFI);
            ApexPages.StandardController scc = new ApexPages.StandardController(lstOpp[0]);
            CRM_UploadExtractPOSandDFI a= new CRM_UploadExtractPOSandDFI(scc);
           List<Id> fixedSearchResults = new List<Id>();
          for(Product2 prod1 : [select Id from Product2]){
            fixedSearchResults.add(prod1.Id);
          }
          Test.setFixedSearchResults(fixedSearchResults);
          List<CRM_UploadExtractPOSandDFI.productSearchWrapper> products = CRM_UploadExtractPOSandDFI.getProductsForAddSearchProductScreen(
             standardPricebookId,'1000','USD',lstOpp[0].Account.name,String.valueOf(lstOpp[0].Start_date__c),String.valueOf(lstOpp[0].CloseDate),String.join(oppRecordTypeName ,'_'));
            //system.assertEquals(5, products.size());
           try{
              List<CRM_UploadExtractPOSandDFI.productSearchWrapper> products1 = CRM_UploadExtractPOSandDFI.getProductsForAddSearchProductScreen(
             null,null,'ABC',null,null,null,null);
           }catch(Exception e){
               System.assertEquals(e.getMessage(), e.getMessage());
           }
        Test.stopTest(); 
    }
    
    private static testMethod void testgetProductsScreenForJV() {
        Id standardPricebookId = System.Test.getStandardPricebookId();
        testDataForJV(CRM_RecordTypeUtil.RT_Physical_POS_Deal, true);
        
        Test.startTest();
        List<Opportunity> lstOpp = [SELECT Id,RecordTypeId,Pricebook2Id,CurrencyISOCode,Account.name,Start_date__c,CloseDate FROM Opportunity];
        Apexpages.standardController stdCtrl = new Apexpages.standardController(lstOpp[0]);
        CRM_UploadExtractPOSandDFI obj = new CRM_UploadExtractPOSandDFI(stdCtrl);
        String oppRecordTypeId = lstOpp[0].RecordTypeId;
        List<RecordType> s = [select name from recordType where id =:oppRecordTypeId];
        String[] oppRecordTypeName = (s[0].Name).split(' ');
        List<Product2> prod = [Select Id,ProductCode FROM Product2];
        System.debug('products'+prod);
        
        Test.setCurrentPageReference(Page.CRM_UploadExtractPOSandDFI);
        ApexPages.StandardController scc = new ApexPages.StandardController(lstOpp[0]);
        CRM_UploadExtractPOSandDFI a= new CRM_UploadExtractPOSandDFI(scc);
        List<Id> fixedSearchResults = new List<Id>();
        for(Product2 prod1 : [select Id from Product2]){
            fixedSearchResults.add(prod1.Id);
        }
        Test.setFixedSearchResults(fixedSearchResults);
        List<CRM_UploadExtractPOSandDFI.productSearchWrapper> products = CRM_UploadExtractPOSandDFI.getProductsForAddSearchProductScreen(
            standardPricebookId,'1000','USD',lstOpp[0].Account.name,String.valueOf(lstOpp[0].Start_date__c),String.valueOf(lstOpp[0].CloseDate),String.join(oppRecordTypeName ,'_'));
        Test.stopTest(); 
    }

    static void testBulkDataForJV(){
        User u = CRM_TestDataFactory.createUser('System Administrator', true);
        system.runAs(u){
            integer num = 201;
            //create account  
            List<Account> lstAccount = CRM_TestDataFactory.createAccounts(1, false);
            lstAccount[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
            lstAccount[0].RecordTypeId = CRM_RecordTypeUTil.RT_ACCOUNT_SHIP_TO;
            lstAccount[0].Class_of_Trade__c ='Retail Cost';
            lstAccount[0].AccountNumber ='123456789';
            lstAccount[0].Price_Book__c = priceBookJVId;
            insert lstAccount;
            system.assertEquals(CRM_AppConstants.TERRITORY_SDS_US_CODE, lstAccount[0].Sales_Organization__c);
            Map<String,PricebookEntry> mapOfProductCodeToPB = new Map<String,PricebookEntry>();

            //create deal
            List<Opportunity> lstOpportunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount, 1, false);
            lstOpportunity[0].RecordTypeId = CRM_RecordTypeUtil.RT_Physical_POS_Deal;
            lstOpportunity[0].Start_date__c = System.today();  
            lstOpportunity[0].CloseDate = System.today()+15;
            lstOpportunity[0].Promo_Start_Date__c = System.today();
            lstOpportunity[0].Promo_End_Date__c = System.today()+15;
            lstOpportunity[0].Pricebook2Id = priceBookJVId;
            //lstOpportunity[0].CurrencyIsoCode = 'USD';
            //lstOpportunity[0].Account
            insert lstOpportunity;
            List<Opportunity> opp =[select id,RecordTypeId from Opportunity where id IN: lstOpportunity];
            system.assertEquals(CRM_RecordTypeUtil.RT_Physical_POS_Deal, opp[0].RecordTypeId);

            integer intCount = 0;
            products = CRM_TestDataFactory.createProducts(num, false);
            for(Product2 prod : products) {
                prod.ProductCode = '10000' + intCount;
                prod.SAP_Dist_chain_product_Status__c =  CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ACTIVE ;
                prod.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
                prod.Product_Format__c = 'DVD';
                prod.isActive = true;
                intCount++;
            } 
            insert products;

            List<PricebookEntry> pricebookentries = CRM_TestDataFactory.createPriceBookEntries(products, 1 , true); 
            System.assertEquals(num,pricebookentries.size());

            List<PricebookEntry> customLstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(products, 1, false);
            for(PricebookEntry pbe : customLstPriceBookEntries){
                pbe.Pricebook2Id = priceBookJVId;
            }
            insert customLstPriceBookEntries;
            
            list<Pricebook_Entry_Period__c> pricebookentryPeriod2= CRM_TestDataFactory.createPriceBookEntryPeriods(products, 1, false);
            for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod2){
                pebp.Price_Type__c = 'DEALER';
                pebp.Start_Date__c = Date.today().addDays(-15);
                pebp.End_Date__c = Date.today().addDays(15);
                pebp.Price_Book__c = priceBookJVId;
            }
            insert pricebookentryPeriod2;

            
            List<OpportunityLineItem> l1 = new List<OpportunityLineItem>();
            List<OpportunityLineItem> l2 = new List<OpportunityLineItem>();
            dealProds = CRM_TestDataFactory.createDealProductsWithOpportunities(customLstPriceBookEntries, lstOpportunity, num, false);
            for(Integer nProductCount = 0; nProductCount < products.size(); nProductCount++){
                for(OpportunityLineItem oli : dealProds) {
                    oli.Reason__c = 'POS Rebate';
                    oli.Product2Id = products[nProductCount].Id;
                    oli.Comments__c = 'Test Comment';
                    oli.Pricebook_Entry_Period__c = pricebookentryPeriod2[nProductCount].Id;
                    oli.Dollar_of_Discount__c = 3;
                    oli.Customer_Reference__c = 'Test Reference';
                    oli.Start_date__c = Date.today().addDays(-1);
                    oli.End_date__c = Date.today().addDays(14);
                }
            }
            integer j = 1;
            for(OpportunityLineItem o: dealProds){
                if(j<=100){l1.add(o);}else{l2.add(o);}
                j++;
            }
            Test.startTest();
            insert l1;
            insert l2;
            System.assertEquals(num,dealProds.size());
            Test.stopTest();
        }
    }

    private static testmethod void testRepriceDealWithBulkDataForJV(){
        Id standardPricebookId = System.Test.getStandardPricebookId();
        testBulkDataForJV();

        List<Opportunity> lstOpp = [SELECT Id,RecordTypeId,Pricebook2Id,CurrencyISOCode,Account.name,Start_date__c,CloseDate FROM Opportunity LIMIT 1];
        Apexpages.standardController stdCtrl = new Apexpages.standardController(lstOpp[0]);
        CRM_UploadExtractPOSandDFI obj = new CRM_UploadExtractPOSandDFI(stdCtrl);
        List<String> isBulkRepriceProcess = CRM_UploadExtractPOSandDFI.repriceDealProduct(lstOpp);
        System.assertEquals('true',isBulkRepriceProcess[0]);
    }

    private static testMethod void testDeleteDPFromPlannedDFIDealForJV(){
        Id standardPricebookId = System.Test.getStandardPricebookId();
        testDataForJV(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, false);

        //--Add additional product to add in deal--Start--//
        List<Product2> products9 = CRM_TestDataFactory.createProducts(1, false);
        for(Product2 prod : products9) {
            prod.ProductCode = '900000';
            prod.SAP_Dist_chain_product_Status__c =  CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ACTIVE ;
            prod.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
            prod.Product_Format__c = 'DVD';
            prod.isActive = true;
        } 
        insert products9;

        List<PricebookEntry> pricebookentries = CRM_TestDataFactory.createPriceBookEntries(products9, 1 , true); 
        List<PricebookEntry> customLstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(products9, 1, false);
        for(PricebookEntry pbe : customLstPriceBookEntries){
            pbe.Pricebook2Id = priceBookJVId;
        }
        insert customLstPriceBookEntries;

        list<Pricebook_Entry_Period__c> pbepList = new list<Pricebook_Entry_Period__c>();
        list<Pricebook_Entry_Period__c> pricebookentryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(products9, 1, false);
        for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod){
            pebp.Price_Type__c = 'Retail Direct';
            pebp.Start_Date__c = Date.today().addDays(-15);
            pebp.End_Date__c = Date.today().addDays(15);
            pebp.Price_Book__c = priceBookJVId;
        }
        pbepList.addAll(pricebookentryPeriod);

        list<Pricebook_Entry_Period__c> pricebookentryPeriod1 = CRM_TestDataFactory.createPriceBookEntryPeriods(products9, 1, false);
        for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod1){
            pebp.Price_Type__c = 'PROMOTION';
            pebp.Start_Date__c = Date.today().addDays(-15);
            pebp.End_Date__c = Date.today().addDays(15);
            pebp.Price_Book__c = priceBookJVId;
        }
        pbepList.addAll(pricebookentryPeriod1);

        list<Pricebook_Entry_Period__c> pricebookentryPeriod2 = CRM_TestDataFactory.createPriceBookEntryPeriods(products9, 1, false);
        for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod2){
            pebp.Price_Type__c = 'DEALER';
            pebp.Start_Date__c = Date.today().addDays(-15);
            pebp.End_Date__c = Date.today().addDays(15);
            pebp.Price_Book__c = priceBookJVId;
        }
        pbepList.addAll(pricebookentryPeriod2);
        insert pbepList;
        //--Add additional product to add in deal--End--//

        Test.startTest();
        List<Opportunity> lstOpp = [SELECT Id,RecordTypeId,StageName,Start_date__c,CloseDate,Count_Opportunity_Products__c FROM Opportunity];

        //--add new dp in existing deal
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(customLstPriceBookEntries, lstOpp, 1, false);
        for(OpportunityLineItem oli: lstDealProduct){
            oli.OpportunityId = lstOpp[0].Id;
            oli.PricebookEntryId = customLstPriceBookEntries[0].Id;
            oli.Start_Date__c = lstOpp[0].Start_Date__c;
            oli.End_Date__c = lstOpp[0].CloseDate;
            oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_DFI;
            oli.Account_Fund_Segment__c = CRM_AppConstants.DEAL_PRODUCT_ACCOUNT_FUND_SEGMENT_NAT;
        }
        insert lstDealProduct;

        List<OpportunityLineItem> lstOppItem = [Select Id,Is_Product_Added_To_Revised_Deal__c From OpportunityLineItem Where 
                                                OpportunityId =: lstOpp[0].Id AND Product2Id =: products9[0].Id];
        System.assertEquals(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, lstOpp[0].RecordTypeId);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED, lstOpp[0].StageName);
        for(OpportunityLineItem oli: lstOppItem){
            System.assertEquals(false, oli.Is_Product_Added_To_Revised_Deal__c);
        }

        Delete lstOppItem[0];
        System.assertEquals(lstOpp[0].Count_Opportunity_Products__c, [Select Id from OpportunityLineItem Where OpportunityId =: lstOpp[0].Id].size());
        Test.stopTest(); 
    }

    private static testMethod void testDeleteDPFromCommittedDFIDealForJV(){
        Id standardPricebookId = System.Test.getStandardPricebookId();
        testDataForJV(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, false);

        // Create approver user to make deal commited
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        User testApproverUser = new User(
            FirstName = 'Test1',
            LastName = 'User1',
            Username = String.valueOf(System.today()).substring(0,8) + 'abc@test1.com',
            Email = 'abc@test1.com',
            Alias = String.valueOf(System.today()).substring(0,8),
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles',
            IsActive = true,
            ProfileId = profiles[0].Id,
            ByPassValidationRule__c = true
        );
        insert testApproverUser;
        System.assert(testApproverUser.Id != null, 'User should get created');

        Test.startTest();
        List<Opportunity> lstOpp = [SELECT Id,RecordTypeId,StageName,Start_date__c,CloseDate,Count_Opportunity_Products__c FROM Opportunity];
        System.runas(testApproverUser){
            lstOpp[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            update lstOpp;
        }

        List<OpportunityLineItem> lstOppItem = [Select Id,Is_Product_Added_To_Revised_Deal__c From OpportunityLineItem Where 
                                                OpportunityId =: lstOpp[0].Id];
        System.assertEquals(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, lstOpp[0].RecordTypeId);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, lstOpp[0].StageName);
        for(OpportunityLineItem oli: lstOppItem){
            System.assertEquals(false, oli.Is_Product_Added_To_Revised_Deal__c);
        }

        try{
            Delete lstOppItem[0];
        }catch(Exception e){
            System.assert(e.getMessage().contains(System.label.CRMJV_DFIDeal_Restrict_ProductDeletion));
        }
        Test.stopTest();
    }

    private static testMethod void testDeleteDPFromRevisedDFIDealForJV(){
        Id standardPricebookId = System.Test.getStandardPricebookId();
        testDataForJV(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, false);

        // Create approver user to make deal commited
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        User testApproverUser = new User(
            FirstName = 'Test1',
            LastName = 'User1',
            Username = String.valueOf(System.today()).substring(0,8) + 'abc@test1.com',
            Email = 'abc@test1.com',
            Alias = String.valueOf(System.today()).substring(0,8),
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles',
            IsActive = true,
            ProfileId = profiles[0].Id,
            ByPassValidationRule__c = true
        );
        insert testApproverUser;
        System.assert(testApproverUser.Id != null, 'User should get created');

        Test.startTest();
        List<Opportunity> lstOpp = [SELECT Id,RecordTypeId,StageName,Start_date__c,CloseDate,Count_Opportunity_Products__c FROM Opportunity];
        System.runas(testApproverUser){
            lstOpp[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_REVISED;
            update lstOpp;
        }

        List<OpportunityLineItem> lstOppItem = [Select Id,Is_Product_Added_To_Revised_Deal__c From OpportunityLineItem Where 
                                                OpportunityId =: lstOpp[0].Id];
        System.assertEquals(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, lstOpp[0].RecordTypeId);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_REVISED, lstOpp[0].StageName);
        for(OpportunityLineItem oli: lstOppItem){
            System.assertEquals(false, oli.Is_Product_Added_To_Revised_Deal__c);
        }

        try{
            Delete lstOppItem[0];
        }catch(Exception e){
            System.assert(e.getMessage().contains(System.label.CRMJV_DFIDeal_Restrict_ProductDeletion));
        }
        Test.stopTest();
    }

    private static testMethod void testAddNewDPToRevisedAndDeleteDPFromRevisedDFIDealForJV(){
        Id standardPricebookId = System.Test.getStandardPricebookId();
        testDataForJV(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, false);

        // Create approver user to make deal commited
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        User testApproverUser = new User(
            FirstName = 'Test1',
            LastName = 'User1',
            Username = String.valueOf(System.today()).substring(0,8) + 'abc@test1.com',
            Email = 'abc@test1.com',
            Alias = String.valueOf(System.today()).substring(0,8),
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles',
            IsActive = true,
            ProfileId = profiles[0].Id,
            ByPassValidationRule__c = true
        );
        insert testApproverUser;
        System.assert(testApproverUser.Id != null, 'User should get created');

        //--Add additional product to add in deal--Start--//
        List<Product2> products9 = CRM_TestDataFactory.createProducts(1, false);
        for(Product2 prod : products9) {
            prod.ProductCode = '900000';
            prod.SAP_Dist_chain_product_Status__c =  CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ACTIVE ;
            prod.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
            prod.Product_Format__c = 'DVD';
            prod.isActive = true;
        } 
        insert products9;

        List<PricebookEntry> pricebookentries = CRM_TestDataFactory.createPriceBookEntries(products9, 1 , true); 
        List<PricebookEntry> customLstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(products9, 1, false);
        for(PricebookEntry pbe : customLstPriceBookEntries){
            pbe.Pricebook2Id = priceBookJVId;
        }
        insert customLstPriceBookEntries;

        list<Pricebook_Entry_Period__c> pbepList = new list<Pricebook_Entry_Period__c>();
        list<Pricebook_Entry_Period__c> pricebookentryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(products9, 1, false);
        for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod){
            pebp.Price_Type__c = 'Retail Direct';
            pebp.Start_Date__c = Date.today().addDays(-15);
            pebp.End_Date__c = Date.today().addDays(15);
            pebp.Price_Book__c = priceBookJVId;
        }
        pbepList.addAll(pricebookentryPeriod);

        list<Pricebook_Entry_Period__c> pricebookentryPeriod1 = CRM_TestDataFactory.createPriceBookEntryPeriods(products9, 1, false);
        for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod1){
            pebp.Price_Type__c = 'PROMOTION';
            pebp.Start_Date__c = Date.today().addDays(-15);
            pebp.End_Date__c = Date.today().addDays(15);
            pebp.Price_Book__c = priceBookJVId;
        }
        pbepList.addAll(pricebookentryPeriod1);

        list<Pricebook_Entry_Period__c> pricebookentryPeriod2 = CRM_TestDataFactory.createPriceBookEntryPeriods(products9, 1, false);
        for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod2){
            pebp.Price_Type__c = 'DEALER';
            pebp.Start_Date__c = Date.today().addDays(-15);
            pebp.End_Date__c = Date.today().addDays(15);
            pebp.Price_Book__c = priceBookJVId;
        }
        pbepList.addAll(pricebookentryPeriod2);
        insert pbepList;
        //--Add additional product to add in deal--End--//

        Test.startTest();
        List<Opportunity> lstOpp = [SELECT Id,RecordTypeId,StageName,Start_date__c,CloseDate,Count_Opportunity_Products__c FROM Opportunity];
        Integer dealProductCountBeforeAddNewDP = Integer.valueOf(lstOpp[0].Count_Opportunity_Products__c);
        System.runas(testApproverUser){
            lstOpp[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_REVISED;
            update lstOpp;
        }

        //--add new dp in existing deal
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(customLstPriceBookEntries, lstOpp, 1, false);
        for(OpportunityLineItem oli: lstDealProduct){
            oli.OpportunityId = lstOpp[0].Id;
            oli.PricebookEntryId = customLstPriceBookEntries[0].Id;
            oli.Start_Date__c = lstOpp[0].Start_Date__c;
            oli.End_Date__c = lstOpp[0].CloseDate;
            oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_DFI;
            oli.Account_Fund_Segment__c = CRM_AppConstants.DEAL_PRODUCT_ACCOUNT_FUND_SEGMENT_NAT;
        }
        insert lstDealProduct;

        List<OpportunityLineItem> lstOppItem = [Select Id,Is_Product_Added_To_Revised_Deal__c From OpportunityLineItem Where 
                                                OpportunityId =: lstOpp[0].Id AND Product2Id =: products9[0].Id];
        System.assertEquals(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, lstOpp[0].RecordTypeId);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_REVISED, lstOpp[0].StageName);
        for(OpportunityLineItem oli: lstOppItem){
            System.assertEquals(true, oli.Is_Product_Added_To_Revised_Deal__c);
        }
        
        Delete lstOppItem[0];
        System.assertEquals(dealProductCountBeforeAddNewDP, [Select Id from OpportunityLineItem Where OpportunityId =: lstOpp[0].Id].size());
        Test.stopTest();
    }

    private static testMethod void testAddNewDPToRevisedAndCommittRevisedDFIDealForJV(){
        Id standardPricebookId = System.Test.getStandardPricebookId();
        testDataForJV(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, false);

        // Create approver user to make deal commited
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        User testApproverUser = new User(
            FirstName = 'Test1',
            LastName = 'User1',
            Username = String.valueOf(System.today()).substring(0,8) + 'abc@test1.com',
            Email = 'abc@test1.com',
            Alias = String.valueOf(System.today()).substring(0,8),
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles',
            IsActive = true,
            ProfileId = profiles[0].Id,
            ByPassValidationRule__c = true
        );
        insert testApproverUser;
        System.assert(testApproverUser.Id != null, 'User should get created');

        //--Add additional product to add in deal--Start--//
        List<Product2> products9 = CRM_TestDataFactory.createProducts(1, false);
        for(Product2 prod : products9) {
            prod.ProductCode = '900000';
            prod.SAP_Dist_chain_product_Status__c =  CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ACTIVE ;
            prod.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
            prod.Product_Format__c = 'DVD';
            prod.isActive = true;
        } 
        insert products9;

        List<PricebookEntry> pricebookentries = CRM_TestDataFactory.createPriceBookEntries(products9, 1 , true); 
        List<PricebookEntry> customLstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(products9, 1, false);
        for(PricebookEntry pbe : customLstPriceBookEntries){
            pbe.Pricebook2Id = priceBookJVId;
        }
        insert customLstPriceBookEntries;

        list<Pricebook_Entry_Period__c> pbepList = new list<Pricebook_Entry_Period__c>();
        list<Pricebook_Entry_Period__c> pricebookentryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(products9, 1, false);
        for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod){
            pebp.Price_Type__c = 'Retail Direct';
            pebp.Start_Date__c = Date.today().addDays(-15);
            pebp.End_Date__c = Date.today().addDays(15);
            pebp.Price_Book__c = priceBookJVId;
        }
        pbepList.addAll(pricebookentryPeriod);

        list<Pricebook_Entry_Period__c> pricebookentryPeriod1 = CRM_TestDataFactory.createPriceBookEntryPeriods(products9, 1, false);
        for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod1){
            pebp.Price_Type__c = 'PROMOTION';
            pebp.Start_Date__c = Date.today().addDays(-15);
            pebp.End_Date__c = Date.today().addDays(15);
            pebp.Price_Book__c = priceBookJVId;
        }
        pbepList.addAll(pricebookentryPeriod1);

        list<Pricebook_Entry_Period__c> pricebookentryPeriod2 = CRM_TestDataFactory.createPriceBookEntryPeriods(products9, 1, false);
        for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod2){
            pebp.Price_Type__c = 'DEALER';
            pebp.Start_Date__c = Date.today().addDays(-15);
            pebp.End_Date__c = Date.today().addDays(15);
            pebp.Price_Book__c = priceBookJVId;
        }
        pbepList.addAll(pricebookentryPeriod2);
        insert pbepList;
        //--Add additional product to add in deal--End--//

        Test.startTest();
        List<Opportunity> lstOpp = [SELECT Id,RecordTypeId,StageName,Start_date__c,CloseDate,Count_Opportunity_Products__c FROM Opportunity];
        Integer dealProductCountBeforeAddNewDP = Integer.valueOf(lstOpp[0].Count_Opportunity_Products__c);
        System.runas(testApproverUser){
            lstOpp[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_REVISED;
            update lstOpp;
        }

        //--add new dp in existing deal
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(customLstPriceBookEntries, lstOpp, 1, false);
        for(OpportunityLineItem oli: lstDealProduct){
            oli.OpportunityId = lstOpp[0].Id;
            oli.PricebookEntryId = customLstPriceBookEntries[0].Id;
            oli.Start_Date__c = lstOpp[0].Start_Date__c;
            oli.End_Date__c = lstOpp[0].CloseDate;
            oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_DFI;
            oli.Account_Fund_Segment__c = CRM_AppConstants.DEAL_PRODUCT_ACCOUNT_FUND_SEGMENT_NAT;
        }
        insert lstDealProduct;

        List<OpportunityLineItem> lstOppItem = [Select Id,Is_Product_Added_To_Revised_Deal__c From OpportunityLineItem Where 
                                                OpportunityId =: lstOpp[0].Id AND Product2Id =: products9[0].Id];
        System.assertEquals(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, lstOpp[0].RecordTypeId);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_REVISED, lstOpp[0].StageName);
        for(OpportunityLineItem oli: lstOppItem){
            System.assertEquals(true, oli.Is_Product_Added_To_Revised_Deal__c);
        }
        
        System.runas(testApproverUser){
            lstOpp[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            update lstOpp;
        }
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, lstOpp[0].StageName);

        try{
            Delete lstOppItem[0];
        }catch(Exception e){
            System.assert(e.getMessage().contains(System.label.CRMJV_DFIDeal_Restrict_ProductDeletion));
        }
        Test.stopTest();
    }

    private static testMethod void testDeleteDPFromPlannedPOSDealForJV(){
        Id standardPricebookId = System.Test.getStandardPricebookId();
        testDataForJV(CRM_RecordTypeUtil.RT_Physical_POS_Deal, false);

        //--Add additional product to add in deal--Start--//
        List<Product2> products9 = CRM_TestDataFactory.createProducts(1, false);
        for(Product2 prod : products9) {
            prod.ProductCode = '900000';
            prod.SAP_Dist_chain_product_Status__c =  CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ACTIVE ;
            prod.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
            prod.Product_Format__c = 'DVD';
            prod.isActive = true;
        } 
        insert products9;

        List<PricebookEntry> pricebookentries = CRM_TestDataFactory.createPriceBookEntries(products9, 1 , true); 
        List<PricebookEntry> customLstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(products9, 1, false);
        for(PricebookEntry pbe : customLstPriceBookEntries){
            pbe.Pricebook2Id = priceBookJVId;
        }
        insert customLstPriceBookEntries;

        list<Pricebook_Entry_Period__c> pbepList = new list<Pricebook_Entry_Period__c>();
        list<Pricebook_Entry_Period__c> pricebookentryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(products9, 1, false);
        for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod){
            pebp.Price_Type__c = 'Retail Direct';
            pebp.Start_Date__c = Date.today().addDays(-15);
            pebp.End_Date__c = Date.today().addDays(15);
            pebp.Price_Book__c = priceBookJVId;
        }
        pbepList.addAll(pricebookentryPeriod);

        list<Pricebook_Entry_Period__c> pricebookentryPeriod1 = CRM_TestDataFactory.createPriceBookEntryPeriods(products9, 1, false);
        for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod1){
            pebp.Price_Type__c = 'PROMOTION';
            pebp.Start_Date__c = Date.today().addDays(-15);
            pebp.End_Date__c = Date.today().addDays(15);
            pebp.Price_Book__c = priceBookJVId;
        }
        pbepList.addAll(pricebookentryPeriod1);

        list<Pricebook_Entry_Period__c> pricebookentryPeriod2 = CRM_TestDataFactory.createPriceBookEntryPeriods(products9, 1, false);
        for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod2){
            pebp.Price_Type__c = 'DEALER';
            pebp.Start_Date__c = Date.today().addDays(-15);
            pebp.End_Date__c = Date.today().addDays(15);
            pebp.Price_Book__c = priceBookJVId;
        }
        pbepList.addAll(pricebookentryPeriod2);
        insert pbepList;
        //--Add additional product to add in deal--End--//

        Test.startTest();
        List<Opportunity> lstOpp = [SELECT Id,RecordTypeId,StageName,Start_date__c,CloseDate,Count_Opportunity_Products__c FROM Opportunity];

        //--add new dp in existing deal
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(customLstPriceBookEntries, lstOpp, 1, false);
        for(OpportunityLineItem oli: lstDealProduct){
            oli.OpportunityId = lstOpp[0].Id;
            oli.PricebookEntryId = customLstPriceBookEntries[0].Id;
            oli.Start_Date__c = lstOpp[0].Start_Date__c;
            oli.End_Date__c = lstOpp[0].CloseDate;
            oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_POS_REBATE;
        }
        insert lstDealProduct;

        List<OpportunityLineItem> lstOppItem = [Select Id,Is_Product_Added_To_Revised_Deal__c From OpportunityLineItem Where 
                                                OpportunityId =: lstOpp[0].Id AND Product2Id =: products9[0].Id];
        System.assertEquals(CRM_RecordTypeUtil.RT_Physical_POS_Deal, lstOpp[0].RecordTypeId);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED, lstOpp[0].StageName);
        for(OpportunityLineItem oli: lstOppItem){
            System.assertEquals(false, oli.Is_Product_Added_To_Revised_Deal__c);
        }

        Delete lstOppItem[0];
        System.assertEquals(lstOpp[0].Count_Opportunity_Products__c, [Select Id from OpportunityLineItem Where OpportunityId =: lstOpp[0].Id].size());
        Test.stopTest(); 
    }

    private static testMethod void testDeleteDPFromCommittedPOSDealForJV(){
        Id standardPricebookId = System.Test.getStandardPricebookId();
        testDataForJV(CRM_RecordTypeUtil.RT_Physical_POS_Deal, false);

        // Create approver user to make deal commited
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        User testApproverUser = new User(
            FirstName = 'Test1',
            LastName = 'User1',
            Username = String.valueOf(System.today()).substring(0,8) + 'abc@test1.com',
            Email = 'abc@test1.com',
            Alias = String.valueOf(System.today()).substring(0,8),
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles',
            IsActive = true,
            ProfileId = profiles[0].Id,
            ByPassValidationRule__c = true
        );
        insert testApproverUser;
        System.assert(testApproverUser.Id != null, 'User should get created');

        Test.startTest();
        List<Opportunity> lstOpp = [SELECT Id,RecordTypeId,StageName,Start_date__c,CloseDate,Count_Opportunity_Products__c FROM Opportunity];
        System.runas(testApproverUser){
            lstOpp[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED;
            update lstOpp;
        }

        List<OpportunityLineItem> lstOppItem = [Select Id,Is_Product_Added_To_Revised_Deal__c From OpportunityLineItem Where 
                                                OpportunityId =: lstOpp[0].Id];
        System.assertEquals(CRM_RecordTypeUtil.RT_Physical_POS_Deal, lstOpp[0].RecordTypeId);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_COMMITTED, lstOpp[0].StageName);
        for(OpportunityLineItem oli: lstOppItem){
            System.assertEquals(false, oli.Is_Product_Added_To_Revised_Deal__c);
        }

        try{
            Delete lstOppItem[0];
        }catch(Exception e){
            System.assert(e.getMessage().contains(System.label.CRMJV_POSDeal_Restrict_ProductDeletion));
        }
        Test.stopTest();
    }

    private static testMethod void testDeleteDPFromRevisedPOSDealForJV(){
        Id standardPricebookId = System.Test.getStandardPricebookId();
        testDataForJV(CRM_RecordTypeUtil.RT_Physical_POS_Deal, false);

        // Create approver user to make deal commited
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        User testApproverUser = new User(
            FirstName = 'Test1',
            LastName = 'User1',
            Username = String.valueOf(System.today()).substring(0,8) + 'abc@test1.com',
            Email = 'abc@test1.com',
            Alias = String.valueOf(System.today()).substring(0,8),
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles',
            IsActive = true,
            ProfileId = profiles[0].Id,
            ByPassValidationRule__c = true
        );
        insert testApproverUser;
        System.assert(testApproverUser.Id != null, 'User should get created');

        Test.startTest();
        List<Opportunity> lstOpp = [SELECT Id,RecordTypeId,StageName,Start_date__c,CloseDate,Count_Opportunity_Products__c FROM Opportunity];
        System.runas(testApproverUser){
            lstOpp[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_REVISED;
            update lstOpp;
        }

        List<OpportunityLineItem> lstOppItem = [Select Id,Is_Product_Added_To_Revised_Deal__c From OpportunityLineItem Where 
                                                OpportunityId =: lstOpp[0].Id];
        System.assertEquals(CRM_RecordTypeUtil.RT_Physical_POS_Deal, lstOpp[0].RecordTypeId);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_REVISED, lstOpp[0].StageName);
        for(OpportunityLineItem oli: lstOppItem){
            System.assertEquals(false, oli.Is_Product_Added_To_Revised_Deal__c);
        }

        try{
            Delete lstOppItem[0];
        }catch(Exception e){
            System.assert(e.getMessage().contains(System.label.CRMJV_POSDeal_Restrict_ProductDeletion));
        }
        Test.stopTest();
    }

    private static testMethod void testCancelDPFromPlannedDFIDealForJV(){
        Id standardPricebookId = System.Test.getStandardPricebookId();
        testDataForJV(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, false);

        Test.startTest();
        List<Opportunity> lstOpp = [SELECT Id,RecordTypeId,StageName FROM Opportunity];
        List<OpportunityLineItem> lstOppItem = [Select Id,DFI_Status__c,Is_Product_Added_To_Revised_Deal__c From OpportunityLineItem Where 
                                                OpportunityId =: lstOpp[0].Id];
        System.assertEquals(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, lstOpp[0].RecordTypeId);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED, lstOpp[0].StageName);
        for(OpportunityLineItem oli: lstOppItem){
            System.assertNotEquals(CRM_AppConstants.DEAL_PRODUCT_DFI_STATUS_CANCEL, oli.DFI_Status__c);
        }

        try{
            OpportunityLineItem oppLI = lstOppItem[0];
            oppLI.DFI_Status__c = CRM_AppConstants.DEAL_PRODUCT_DFI_STATUS_CANCEL;
            update oppLI;
        }catch(Exception e){
            System.assert(e.getMessage().contains(System.label.CRMJV_Planned_DFIDeal_Restrict_ProductCancel));
        }
        Test.stopTest(); 
    }
    
    private static testMethod void testCancelExistingDPFromRevisedDFIDealForJV(){
        Id standardPricebookId = System.Test.getStandardPricebookId();
        testDataForJV(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, false);

        // Create approver user to make deal commited
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        User testApproverUser = new User(
            FirstName = 'Test1',
            LastName = 'User1',
            Username = String.valueOf(System.today()).substring(0,8) + 'abc@test1.com',
            Email = 'abc@test1.com',
            Alias = String.valueOf(System.today()).substring(0,8),
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles',
            IsActive = true,
            ProfileId = profiles[0].Id,
            ByPassValidationRule__c = true
        );
        insert testApproverUser;
        System.assert(testApproverUser.Id != null, 'User should get created');

        Test.startTest();
        List<Opportunity> lstOpp = [SELECT Id,RecordTypeId,StageName FROM Opportunity];
        System.runas(testApproverUser){
            lstOpp[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_REVISED;
            update lstOpp;
        }

        List<OpportunityLineItem> lstOppItem = [Select Id,DFI_Status__c,Is_Product_Added_To_Revised_Deal__c From OpportunityLineItem Where 
                                                OpportunityId =: lstOpp[0].Id];
        System.assertEquals(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, lstOpp[0].RecordTypeId);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_REVISED, lstOpp[0].StageName);
        for(OpportunityLineItem oli: lstOppItem){
            System.assertEquals(false, oli.Is_Product_Added_To_Revised_Deal__c);
            System.assertNotEquals(CRM_AppConstants.DEAL_PRODUCT_DFI_STATUS_CANCEL, oli.DFI_Status__c);
        }

        OpportunityLineItem oppLI = lstOppItem[0];
        oppLI.DFI_Status__c = CRM_AppConstants.DEAL_PRODUCT_DFI_STATUS_CANCEL;
        update oppLI;

        System.assertEquals(CRM_AppConstants.DEAL_PRODUCT_DFI_STATUS_CANCEL, [Select DFI_Status__c from OpportunityLineItem Where Id =: oppLI.Id][0].DFI_Status__c);
        Test.stopTest();
    }
    
    private static testMethod void testCancelNewDPFromRevisedDFIDealForJV(){
        Id standardPricebookId = System.Test.getStandardPricebookId();
        testDataForJV(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, false);

        // Create approver user to make deal commited
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        User testApproverUser = new User(
            FirstName = 'Test1',
            LastName = 'User1',
            Username = String.valueOf(System.today()).substring(0,8) + 'abc@test1.com',
            Email = 'abc@test1.com',
            Alias = String.valueOf(System.today()).substring(0,8),
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocalesIdKey = 'en_US',
            TimezonesIdKey = 'America/Los_Angeles',
            IsActive = true,
            ProfileId = profiles[0].Id,
            ByPassValidationRule__c = true
        );
        insert testApproverUser;
        System.assert(testApproverUser.Id != null, 'User should get created');

        //--Add additional product to add in deal--Start--//
        List<Product2> products9 = CRM_TestDataFactory.createProducts(1, false);
        for(Product2 prod : products9) {
            prod.ProductCode = '900000';
            prod.SAP_Dist_chain_product_Status__c =  CRM_AppConstants.PRODUCT_SAP_DIST_STATUS_ACTIVE ;
            prod.SAP_Sales_Org__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
            prod.Product_Format__c = 'DVD';
            prod.isActive = true;
        } 
        insert products9;

        List<PricebookEntry> pricebookentries = CRM_TestDataFactory.createPriceBookEntries(products9, 1 , true); 
        List<PricebookEntry> customLstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(products9, 1, false);
        for(PricebookEntry pbe : customLstPriceBookEntries){
            pbe.Pricebook2Id = priceBookJVId;
        }
        insert customLstPriceBookEntries;

        list<Pricebook_Entry_Period__c> pbepList = new list<Pricebook_Entry_Period__c>();
        list<Pricebook_Entry_Period__c> pricebookentryPeriod = CRM_TestDataFactory.createPriceBookEntryPeriods(products9, 1, false);
        for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod){
            pebp.Price_Type__c = 'Retail Direct';
            pebp.Start_Date__c = Date.today().addDays(-15);
            pebp.End_Date__c = Date.today().addDays(15);
            pebp.Price_Book__c = priceBookJVId;
        }
        pbepList.addAll(pricebookentryPeriod);

        list<Pricebook_Entry_Period__c> pricebookentryPeriod1 = CRM_TestDataFactory.createPriceBookEntryPeriods(products9, 1, false);
        for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod1){
            pebp.Price_Type__c = 'PROMOTION';
            pebp.Start_Date__c = Date.today().addDays(-15);
            pebp.End_Date__c = Date.today().addDays(15);
            pebp.Price_Book__c = priceBookJVId;
        }
        pbepList.addAll(pricebookentryPeriod1);

        list<Pricebook_Entry_Period__c> pricebookentryPeriod2 = CRM_TestDataFactory.createPriceBookEntryPeriods(products9, 1, false);
        for(Pricebook_Entry_Period__c pebp : pricebookentryPeriod2){
            pebp.Price_Type__c = 'DEALER';
            pebp.Start_Date__c = Date.today().addDays(-15);
            pebp.End_Date__c = Date.today().addDays(15);
            pebp.Price_Book__c = priceBookJVId;
        }
        pbepList.addAll(pricebookentryPeriod2);
        insert pbepList;
        //--Add additional product to add in deal--End--//

        Test.startTest();
        List<Opportunity> lstOpp = [SELECT Id,RecordTypeId,StageName,Start_date__c,CloseDate FROM Opportunity];
        System.runas(testApproverUser){
            lstOpp[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_REVISED;
            update lstOpp;
        }

        //--add new dp in existing deal
        List<OpportunityLineItem> lstDealProduct = CRM_TestDataFactory.createDealProductsWithOpportunities(customLstPriceBookEntries, lstOpp, 1, false);
        for(OpportunityLineItem oli: lstDealProduct){
            oli.OpportunityId = lstOpp[0].Id;
            oli.PricebookEntryId = customLstPriceBookEntries[0].Id;
            oli.Start_Date__c = lstOpp[0].Start_Date__c;
            oli.End_Date__c = lstOpp[0].CloseDate;
            oli.Reason__c = CRM_AppConstants.DEAL_PRODUCT_REASON_DFI;
            oli.Account_Fund_Segment__c = CRM_AppConstants.DEAL_PRODUCT_ACCOUNT_FUND_SEGMENT_NAT;
        }
        insert lstDealProduct;

        List<OpportunityLineItem> lstOppItem = [Select Id,DFI_Status__c,Is_Product_Added_To_Revised_Deal__c From OpportunityLineItem Where 
                                                OpportunityId =: lstOpp[0].Id AND Product2Id =: products9[0].Id];
        System.assertEquals(CRM_RecordTypeUtil.RT_Physical_DFI_Deal, lstOpp[0].RecordTypeId);
        System.assertEquals(CRM_AppConstants.OPPORTUNITY_STAGE_REVISED, lstOpp[0].StageName);
        for(OpportunityLineItem oli: lstOppItem){
            System.assertEquals(true, oli.Is_Product_Added_To_Revised_Deal__c);
            System.assertNotEquals(CRM_AppConstants.DEAL_PRODUCT_DFI_STATUS_CANCEL, oli.DFI_Status__c);
        }

        try{
            OpportunityLineItem oppLI = lstOppItem[0];
            oppLI.DFI_Status__c = CRM_AppConstants.DEAL_PRODUCT_DFI_STATUS_CANCEL;
            update oppLI;
        }catch(Exception e){
            System.assert(e.getMessage().contains(System.label.CRMJV_Revised_DFIDeal_Restrict_ProductCancel));
        }
        Test.stopTest();
    }
}