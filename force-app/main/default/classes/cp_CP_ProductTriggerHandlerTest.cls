/**
* Created by XMMORENO on 3/27/2020.
**/

@IsTest
private class cp_CP_ProductTriggerHandlerTest {
    
    @TestSetup
    static void createTestData(){		
        Id licRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId();
        Id retRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Retailer').getRecordTypeId();        
        Account licenceeAcc = (Account)TestDataFactory.createSObject('Account', new Map<String,Object>{
            'Name' => 'Mattel',
        	'RecordTypeId' => licRecTypeid,
            'cp_Licensee_Code__c' => '0001011318' 
        },true);
        
        Account licenceeAccount = (Account)TestDataFactory.createSObject('Account', new Map<String,Object>{
            'Name' => 'Bioworld',
        	'RecordTypeId' => licRecTypeid,
            'cp_Licensee_Code__c' => '0001032499' 
        },true);
        
        Account retailerAcc = (Account)TestDataFactory.createSObject('Account', new Map<String,Object>{
        	'RecordTypeId' => retRecTypeid
        });
        
        WBCP_Country__c countryRecord = (WBCP_Country__c)TestDataFactory.createSObject('WBCP_Country__c',new Map<String,object>{
        	'Name' => 'United States'
        });
        
        Property__c propRec = (Property__c)TestDataFactory.createSObject('Property__c',new Map<String,object>{
        	'Name' => 'Justice League Core',
            'cp_Property_Code__c' => '000927'
        });
        
        Property__c propObj = (Property__c)TestDataFactory.createSObject('Property__c',new Map<String,object>{
        	'Name' => 'Batman Core',
            'cp_Property_Code__c' => '000046'
        });
        
        CP_Product__c prodRec =  (CP_Product__c)TestDataFactory.createSObject('CP_Product__c', new Map<String,Object>{
            'Licensee__c' => licenceeAcc.Id,
            'WBCP_Country__c' => countryRecord.Id,
            'GTIN__c' => '024054817896',
            'MPN__c' => '8875823',
            'cp_Retailer_Description__c' => retailerAcc.Id,
            'Retailer_SKU__c' => '567021036',
            'cp_Licensed_Property__c' => propRec.Id,
            'Sub_Category__c' => 'Vehicles / Remote Control'
        });
    }
    
    @IsTest
    static void test_insertCPProducts(){
        Account liceObj = [SELECT Id, Name FROM Account WHERE RecordType.Name = 'WBCP Licensee' LIMIT 1];
        Account retObj = [SELECT Id, Name FROM Account WHERE RecordType.Name = 'WBCP Retailer' LIMIT 1];
        Property__c propObj = [SELECT Id, Name FROM Property__c LIMIT 1];
        WBCP_Country__c cntrObj = [SELECT Id, Name FROM WBCP_Country__c LIMIT 1];               
        CP_Product__c cpProdObj = new CP_Product__c();
        cpProdObj.Licensee__c = liceObj.Id;
        cpProdObj.WBCP_Country__c = cntrObj.Id;
        cpProdObj.GTIN__c = '9781465483867';
        cpProdObj.MPN__c = '8875823WN';
        cpProdObj.cp_MPN_Description__c = 'Test';
        cpProdObj.cp_Retailer_Description__c = retObj.Id;
        cpProdObj.Retailer_SKU__c = '567021036';
        cpProdObj.cp_Licensed_Property__c = propObj.Id;
        cpProdObj.Item_Descrption__c = 'This is test item used in test class';
        cpProdObj.Sub_Category__c = 'Accessories Other';
        cpProdObj.Size__c = '7';
        cpProdObj.UPC_Upload_Date__c = DateTime.parse(Datetime.now().format());
        test.startTest();
        insert cpProdObj;
        test.stopTest();
    }
    
    @IsTest
    static void test_insertDuplicateCPProducts(){
        Account liceObj = [SELECT Id, Name FROM Account WHERE RecordType.Name = 'WBCP Licensee' LIMIT 1];
        Account retObj = [SELECT Id, Name FROM Account WHERE RecordType.Name = 'WBCP Retailer' LIMIT 1];
        Property__c propObj = [SELECT Id, Name FROM Property__c LIMIT 1];
        WBCP_Country__c cntrObj = [SELECT Id, Name FROM WBCP_Country__c LIMIT 1];
        List<CP_Product__c> lstProducts = new List<CP_Product__c>();         
        for(Integer i=0; i<2; i++){
            CP_Product__c cpProdObj = new CP_Product__c();
            cpProdObj.Licensee__c = liceObj.Id;
            cpProdObj.WBCP_Country__c = cntrObj.Id;
            cpProdObj.GTIN__c = '024054817896';
            cpProdObj.MPN__c = '8875823';
            cpProdObj.cp_MPN_Description__c = 'Test';
            cpProdObj.cp_Retailer_Description__c = retObj.Id;
            cpProdObj.Retailer_SKU__c = '567021036';
            cpProdObj.cp_Licensed_Property__c = propObj.Id;
            cpProdObj.Item_Descrption__c = 'This is test item used in test class';
            cpProdObj.Sub_Category__c = 'Accessories Other';
            cpProdObj.Size__c = '7';
            cpProdObj.UPC_Upload_Date__c = DateTime.parse(Datetime.now().format());
            lstProducts.add(cpProdObj);
        }
        test.startTest();
        try{
            if(!lstProducts.isEmpty()){
                insert lstProducts;
            }
        }catch(Exception ex){
            Boolean exceptionThrown =  ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
            System.AssertEquals(exceptionThrown, true);
        }
        test.stopTest();
    }
    
    @IsTest
    static void test_insertMisMatchCPProducts(){
        Account liceObj = [SELECT Id, Name FROM Account WHERE RecordType.Name = 'WBCP Licensee' AND Name = 'Bioworld' LIMIT 1];
        Account retObj = [SELECT Id, Name FROM Account WHERE RecordType.Name = 'WBCP Retailer' LIMIT 1];
        Property__c propObj = [SELECT Id, Name FROM Property__c WHERE Name = 'Batman Core' LIMIT 1];
        WBCP_Country__c cntrObj = [SELECT Id, Name FROM WBCP_Country__c LIMIT 1];
        List<CP_Product__c> lstProducts = new List<CP_Product__c>();         
        for(Integer i=0; i<2; i++){
            CP_Product__c cpProdObj = new CP_Product__c();
            cpProdObj.Licensee__c = liceObj.Id;
            cpProdObj.WBCP_Country__c = cntrObj.Id;
            cpProdObj.GTIN__c = '024054817896';
            cpProdObj.MPN__c = '88758231';
            cpProdObj.cp_MPN_Description__c = 'Test';
            cpProdObj.cp_Retailer_Description__c = retObj.Id;
            cpProdObj.Retailer_SKU__c = '567021036' + i;
            cpProdObj.cp_Licensed_Property__c = propObj.Id;
            cpProdObj.Item_Descrption__c = 'This is test item used in test class';
            cpProdObj.Sub_Category__c = 'Preschool Toys';
            cpProdObj.Size__c = '7';
            cpProdObj.UPC_Upload_Date__c = DateTime.parse(Datetime.now().format());
            lstProducts.add(cpProdObj);
        }
        test.startTest();
        try{
            if(!lstProducts.isEmpty()){
                insert lstProducts;
            }
        }catch(Exception ex){
            Boolean exceptionThrown =  ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') ? true : false;
            System.AssertEquals(exceptionThrown, true);
        }
        test.stopTest();
    }
    
    @IsTest
    static void test_updateCPProducts(){
        test.startTest();
        CP_Product__c cpProd = [SELECT Id, Retailer_SKU__c FROM CP_Product__c WHERE MPN__c = '8875823' LIMIT 1];
        cpProd.Retailer_SKU__c = '5670210360';        
        update cpProd;
        test.stopTest();
    }
}