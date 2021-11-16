/**
@Author Accenture
@name CRM_TrackDPFieldValueChanges_Test
@CreateDate 11 August 2020
@Description Test class for CRM_TrackDealProductFieldValueChanges
@Version <1.0>
*/

@isTest
private class CRM_TrackDPFieldValueChanges_Test {
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
        lstAccount[1].Class_of_Trade__c = CRM_AppConstants.CLASS_OF_TRADE_RETAIL_COST;
        insert lstAccount;
        
        PriceBook2 wbieUS =  new Pricebook2(Name = CRM_AppConstants.WBIE_US_PRICEBOOK_NAME, 
                                            Description = 'WBIE US Pricebook', 
                                            IsActive = true, 
                                            Business_Unit__c = CRM_AppConstants.TERRITORY_US_CODE);
        insert wbieUS;
        
        System.runAs(createTestUser()){
            //create deal
            List<Opportunity> lstOpportunityPOS = CRM_TestDataFactory.createOpportunitiesWithAccounts(new List<Account>{lstAccount[0]}, 1, false);
            for(Opportunity opp : lstOpportunityPOS){
                opp.RecordTypeId = CRM_RecordTypeUtil.RT_Physical_POS_Deal;
                opp.Start_date__c = System.today();  
                opp.CloseDate = System.today()+30;
                opp.Promo_Start_Date__c = System.today();
                opp.Promo_End_Date__c = System.today() + 30;
                opp.Pricebook2Id = wbieUS.Id;
            }
            insert lstOpportunityPOS;
            
            List<Opportunity> lstOpportunityDFI = CRM_TestDataFactory.createOpportunitiesWithAccounts(new List<Account>{lstAccount[1]}, 1, false);
            for(Opportunity opp : lstOpportunityDFI){
                opp.RecordTypeId = CRM_RecordTypeUtil.RT_Physical_DFI_Deal;
                opp.Start_date__c = System.today();  
                opp.CloseDate = System.today()+30;
                opp.Promo_Start_Date__c = System.today();
                opp.Promo_End_Date__c = System.today() + 30;
                opp.Pricebook2Id = wbieUS.Id;
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
			
			Id standardPBId = Test.getStandardPricebookId();
            List<PricebookEntry> pricebookentries = new List<PricebookEntry>();
            for(Integer i=0;i<products.size();i++){
                PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPBId, Product2Id = products[i].Id, UnitPrice = 1000, IsActive = true);
                pricebookentries.add(standardPBE);
            }
            insert pricebookentries;
            
            pricebookentries = CRM_TestDataFactory.createPriceBookEntries(products, 1, false);
            for(PricebookEntry pb : pricebookentries){
                pb.Pricebook2Id = wbieUS.Id;
                pb.UnitPrice = 1000;
            }
            insert pricebookentries;
            System.assertEquals(5,pricebookentries.size());
            
            List<Pricebook_Entry_Period__c> createPBEPList = CRM_TestDataFactory.createPriceBookEntryPeriods(products, 1, false);
            for(Pricebook_Entry_Period__c pbep : createPBEPList){
                pbep.Price_Type__c = CRM_AppConstants.PBEP_PRICE_TYPE_PROMOTION;
                pbep.Start_Date__c = System.today() + 5;
                pbep.End_Date__c = System.today() + 25;
                pbep.Price_Book__c = wbieUS.Id;
                pbep.List_Price__c = 6.19;
            }
            createPBEPList[0].Price_Type__c = (CRM_AppConstants.CLASS_OF_TRADE_RETAIL_COST).toUpperCase();
            createPBEPList[0].Price_Type__c = CRM_AppConstants.PBEP_PRICE_TYPE_DEALER;
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
                dealProdsPOS[i].End_date__c = System.today() + 20; 
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
                dealProdsDFI[i].Start_date__c = System.today() + 7;
                dealProdsDFI[i].End_date__c = System.today() + 20; 
                dealProdsDFI[i].Customer_Reference__c = 'Test Reference';
                dealProdsDFI[i].Digital_Membership__c = 'Test Digital Membership';
                dealProdsDFI[i].Reason__c = 'DFI';
                dealProdsDFI[i].Account_Fund_Segment__c = 'NAT';
            }
            insert dealProdsDFI;
            System.assertEquals(10,dealProdsDFI.size());
        }
    }
    
    /**
	*  Method to test the Track Deal Product Field Value Changes functionality
	*/
    private static testMethod void trackDealProductFieldValueChanges_TestScenario() {
        createTestData();
        
        List<Opportunity> dealList = [Select Id FROM Opportunity WHERE RecordTypeId=:CRM_RecordTypeUtil.RT_Physical_DFI_Deal LIMIT 1];
        List<OpportunityLineItem> dealProductUpdateList = new List<OpportunityLineItem>();
        List<Deal_Product_Field_History_Tracking__mdt> fieldAuditList = [SELECT Id, Deal_Product_Field_API_Name__c, Deal_Product_Field_Name__c FROM Deal_Product_Field_History_Tracking__mdt WHERE Track_Changes__c=true];
        Map<String, Schema.SObjectField> fieldDetailsMap = Schema.SObjectType.OpportunityLineItem.fields.getMap();
        
        String queryStr = '';
        queryStr = 'SELECT ';
        for(Deal_Product_Field_History_Tracking__mdt fht : fieldAuditList){
            queryStr+=fht.Deal_Product_Field_API_Name__c+',';
        }
        queryStr = queryStr.removeEnd(',');
        queryStr+=' FROM OpportunityLineItem WHERE OpportunityId='+'\''+dealList[0].Id+'\'';
        
        for(OpportunityLineItem oli : Database.query(queryStr)){
            for(Deal_Product_Field_History_Tracking__mdt fht : fieldAuditList){
                Schema.SObjectField field = fieldDetailsMap.get(fht.Deal_Product_Field_API_Name__c);
                Schema.DisplayType fieldType = field.getDescribe().getType();
                if((String.valueOf(fieldType).toUpperCase()=='CURRENCY' || String.valueOf(fieldType).toUpperCase()=='PERCENT' || String.valueOf(fieldType).toUpperCase()=='DOUBLE') && field.getDescribe().isUpdateable()){
                    oli.put(fht.Deal_Product_Field_API_Name__c, 0);
                }else if(String.valueOf(fieldType).toUpperCase()=='DATE' && field.getDescribe().isUpdateable()){
                	oli.put(fht.Deal_Product_Field_API_Name__c, (Date)(oli.get(fht.Deal_Product_Field_API_Name__c))-1);
                }else if(String.valueOf(fieldType).toUpperCase()=='DATETIME' && field.getDescribe().isUpdateable()){
                	oli.put(fht.Deal_Product_Field_API_Name__c, (DateTime)(oli.get(fht.Deal_Product_Field_API_Name__c))-1);   
                }else if((String.valueOf(fieldType).toUpperCase()=='STRING' || String.valueOf(fieldType).toUpperCase()=='TEXTAREA') && field.getDescribe().isUpdateable()){
                	oli.put(fht.Deal_Product_Field_API_Name__c, 'Test');   
                }
            }
            dealProductUpdateList.add(oli);
        }
        
        Test.startTest();
        if(!dealProductUpdateList.isEmpty()){
            update dealProductUpdateList;
        }
        Test.stopTest();
        
        List<Deal_Product_Field_History_Tracker__c> fieldHistoryTrackRecordCreateList = [Select Id, Deal__c FROM Deal_Product_Field_History_Tracker__c WHERE Deal__c=:dealList[0].Id];
        System.assert(fieldHistoryTrackRecordCreateList.size()>0);
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
            ByPassValidationRule__c = false
        );
        return testUser;
    }
}