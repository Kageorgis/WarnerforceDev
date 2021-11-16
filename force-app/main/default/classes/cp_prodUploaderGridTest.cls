@isTest
public class cp_prodUploaderGridTest{
    
    @testSetup
    public static void setTestData(){
        Id licRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId();
        Id retRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Retailer').getRecordTypeId();
        
        Account licenceeAcc = (Account)TestDataFactory.createSObject('Account', new Map<String,Object>{
        	'RecordTypeId' => licRecTypeid
        },true);
        
        Account retailerAcc = (Account)TestDataFactory.createSObject('Account', new Map<String,Object>{
            'RecordTypeId' => retRecTypeid
        });
        
        WBCP_Country__c countRecord = (WBCP_Country__c)TestDataFactory.createSObject('WBCP_Country__c',new Map<String,object>{
            'Name' => 'United States'
        });
        
        Property__c propRec = (Property__c)TestDataFactory.createSObject('Property__c',new Map<String,object>{
            'Name' => 'Justice League Core'
        });
    }
    
    //Chek all validations
    @isTest
    static void saveRecordsApexMethodTest(){
        Account accObj = [SELECT Id,Name FROM Account WHERE RecordType.Name = 'WBCP Licensee' LIMIT 1];
        WBCP_Country__c cntrObj = [SELECT Id,Name FROM WBCP_Country__c WHERE Name = 'United States' LIMIT 1];
        
        cp_prodUploaderGridContoller.ProductWrapper productWrapperObj = new cp_prodUploaderGridContoller.ProductWrapper();
        productWrapperObj.Licensed_Property = 'Justice League Core';
        productWrapperObj.RSP = '$10.20.00';
        productWrapperObj.Set_Date = '2/18/2020';
        productWrapperObj.Retired_Date = '2/18/2020';
        productWrapperObj.Product_Status = '';
        productWrapperObj.Flow_through_Flag = '';
        productWrapperObj.Flow_through_Start_Date = '2/18/2020';
        productWrapperObj.Flow_through_End_Date = '2/18/2020';
        productWrapperObj.Promotional_Flag = '';
        productWrapperObj.Promotional_Start_Date = '2/20/2020';
        productWrapperObj.Promotional_End_Date = '2/20/2020';
        LIST<cp_prodUploaderGridContoller.ProductWrapper> productWrapperTableData = new LIST<cp_prodUploaderGridContoller.ProductWrapper>();
        productWrapperTableData.add(productWrapperObj);
        cp_prodUploaderGridContoller.saveProducts(productWrapperTableData);        
    }
    
    //Successfully saved CP Product record    
    @isTest
    static void saveRecordsApexMethodTest1(){
        Account accObj = [SELECT Id,Name FROM Account WHERE RecordType.Name = 'WBCP Licensee' LIMIT 1];
        Account retObj = [SELECT Id,Name FROM Account WHERE RecordType.Name = 'WBCP Retailer' LIMIT 1];
        WBCP_Country__c cntrObj = [SELECT Id,Name FROM WBCP_Country__c WHERE Name = 'United States' LIMIT 1];
        
        cp_prodUploaderGridContoller.ProductWrapper productWrapperObj = new cp_prodUploaderGridContoller.ProductWrapper();
        productWrapperObj.Licensee_Name = accObj.Name;
        productWrapperObj.Country = cntrObj.Name;
        productWrapperObj.GTIN = '9781465483867';
        productWrapperObj.MPN = '9781465483867';
        productWrapperObj.MPN_Description = 'Text';
        productWrapperObj.Retailer = retObj.Name;
        productWrapperObj.Retailer_SKU = 'Prime';
        productWrapperObj.Licensed_Property = 'Justice League Core';
        productWrapperObj.Item_Description = 'This is test item used in test class';
        productWrapperObj.Sub_Category = 'Outdoor Toy & Sports';
        productWrapperObj.Buyer_Name = 'Test Test';
        productWrapperObj.RSP = '$10.20';
        productWrapperObj.Gender = 'Men';
        productWrapperObj.Demo = '6-8';
        productWrapperObj.Size = '7';        
        productWrapperObj.Set_Date = '2/18/2020';
        productWrapperObj.Retired_Date = '2/19/2020';
        productWrapperObj.Product_Status = 'Active';
        productWrapperObj.Flow_through_Flag = '';
        productWrapperObj.Flow_through_Start_Date = '2/18/2020';
        productWrapperObj.Flow_through_End_Date = '2/19/2020';
        productWrapperObj.Promotional_Flag = '';
        productWrapperObj.Promotional_Start_Date = '2/18/2020';
        productWrapperObj.Promotional_End_Date = '2/19/2020';
        
        List<cp_prodUploaderGridContoller.ProductWrapper> productWrapperTableData = new List<cp_prodUploaderGridContoller.ProductWrapper>();
        productWrapperTableData.add(productWrapperObj);
        cp_prodUploaderGridContoller.saveProducts(productWrapperTableData);   
    }

    //Check Lookup Values
    @IsTest
    public static void getLookupValuesTest(){
        cp_prodUploaderGridContoller.fetchContentDocument();
        cp_prodUploaderGridContoller.getLookupValues();
        cp_prodUploaderGridContoller.getFieldSet('CP_Product__c');
        cp_licenseeLookupController.fetchLookUpValues('Bioworld','Account');
        cp_licenseeLookupController.fetchPropertyValues('Harry','Property__c');
    }
}