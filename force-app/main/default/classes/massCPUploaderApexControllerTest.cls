@isTest
public class massCPUploaderApexControllerTest {
	@testSetup
    public static void setTestData(){
        Id licRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId();
        Id retRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Retailer').getRecordTypeId();
        //   System.debug('This is the recordTyp'+licRecTypeid);
        Account licenceeAcc = (Account)TestDataFactory.createSObject('Account', new Map<String,Object>{
                'RecordTypeId' => licRecTypeid
        },true);
        Account retailerAcc = (Account)TestDataFactory.createSObject('Account', new Map<String,Object>{
                'RecordTypeId' => retRecTypeid
        });
        WBCP_Country__c countRecord = (WBCP_Country__c)TestDataFactory.createSObject('WBCP_Country__c',new Map<String,object>{
                'Name' => 'United States'
        });

        CP_Product__c prodRec =  (CP_Product__c)TestDataFactory.createSObject('CP_Product__c', new Map<String,Object>{
                'Licensee__c' => licenceeAcc.Id,
                'GTIN__c' => '9781465483867',
                'cp_Retailer_Description__c' => retailerAcc.Id,
                'Sub_Category__c' => 'Accessories Other',
                'cp_Sub_Category__c' => 'Outdoor Toy & Sports'
        });
    }   
        
    @isTest
    static void saveRecordsApexMethodTest(){
        Account accObj = [SELECT Id,Name FROM Account WHERE RecordType.Name = 'WBCP Licensee' LIMIT 1];
        Account retObj = [SELECT Id,Name FROM Account WHERE RecordType.Name = 'WBCP Retailer' LIMIT 1];
        WBCP_Country__c cntrObj = [SELECT Id,Name FROM WBCP_Country__c WHERE Name = 'United States' LIMIT 1];

        massCPUploaderApexController.ProductWrapper productWrapperObj = new massCPUploaderApexController.ProductWrapper();
        productWrapperObj.Licensee_Name = accObj.Name;
        productWrapperObj.Country = cntrObj.Name;
        productWrapperObj.GTIN = '9781465483867';
        productWrapperObj.MPN = '9781465483867';
        productWrapperObj.Retailer = retObj.Name;
        productWrapperObj.Retailer_SKU = 'Prime';
        productWrapperObj.Licensed_Property = 'Justice League Core';
        productWrapperObj.Item_Description = 'This is test item used in test class';
        productWrapperObj.Sub_Category = 'Outdoor Toy & Sports';
        productWrapperObj.Buyer_Name = 'Test Test';
        productWrapperObj.RSP = 100;
        productWrapperObj.Gender = 'Men';
        productWrapperObj.Demo = '6-8';
        productWrapperObj.Size = '7';

        List<massCPUploaderApexController.ProductWrapper> productWrapperTableData = new List<massCPUploaderApexController.ProductWrapper>();
        productWrapperTableData.add(productWrapperObj);
        System.debug('This is the first test table data --->'+productWrapperTableData);
        massCPUploaderApexController.saveRecordsApexMethod(productWrapperTableData);
    }
     @isTest
    static void saveRecordsApexMethodTest1(){
         Account accObj = [SELECT Id,Name FROM Account WHERE RecordType.Name = 'WBCP Licensee' LIMIT 1];
        WBCP_Country__c cntrObj = [SELECT Id,Name FROM WBCP_Country__c WHERE Name = 'United States' LIMIT 1];
        
        massCPUploaderApexController.ProductWrapper productWrapperObj = new massCPUploaderApexController.ProductWrapper();
        productWrapperObj.Licensee_Name = accObj.Name;
        productWrapperObj.Country = cntrObj.Name;
        productWrapperObj.GTIN = '9781982127794';
        productWrapperObj.MPN = '9781982127794';
        productWrapperObj.Retailer = '';
        productWrapperObj.Retailer_SKU = 'Prime';
        productWrapperObj.Licensed_Property = 'Justice League Core';
        productWrapperObj.Item_Description = 'This is test item used in test class';
         productWrapperObj.Sub_Category = 'Outdoor Toy & Sports';
        productWrapperObj.Buyer_Name = 'RickRevezzo';
        productWrapperObj.RSP = 100;
        productWrapperObj.Gender = 'Men';
        productWrapperObj.Demo = '6-8';
        productWrapperObj.Size = '7';
        productWrapperObj.Set_Date = '2/18/2020';
        productWrapperObj.Retired_Date = '2/18/2020';
        productWrapperObj.Product_Status = '';
        productWrapperObj.Flow_through_Flag = '';
        productWrapperObj.Flow_through_Start_Date = '2/18/2020';
        productWrapperObj.Flow_through_End_Date = '2/18/2020';
        productWrapperObj.Promotional_Flag = '';
        productWrapperObj.Promotional_Start_Date = '2/20/2020';
        productWrapperObj.Promotional_End_Date = '2/20/2020';
        LIST<massCPUploaderApexController.ProductWrapper> productWrapperTableData = new LIST<massCPUploaderApexController.ProductWrapper>();
        productWrapperTableData.add(productWrapperObj);
        massCPUploaderApexController.saveRecordsApexMethod(productWrapperTableData);
    }
    
    @isTest
    public static void saveRecordsApexMethodTest2(){
        massCPUploaderApexController.ProductWrapper productWrapperObj = new massCPUploaderApexController.ProductWrapper();
        productWrapperObj.Licensed_Property = 'Justice League Core';
        productWrapperObj.GTIN = '9781982127794';
        LIST<massCPUploaderApexController.ProductWrapper> productWrapperTableData = new LIST<massCPUploaderApexController.ProductWrapper>();
        productWrapperTableData.add(productWrapperObj);
        massCPUploaderApexController.saveRecordsApexMethod(productWrapperTableData);
    }
    @IsTest
    public static void getLookupValuesTest1(){

        massCPUploaderApexController.getLookupValues();
    }
}