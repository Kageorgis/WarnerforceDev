@isTest
private class CP_ForecastingItemControllerTest {
    @isTest
    static void createForecastingItemTest(){
        
        CP_ForecastingItemController obj = new CP_ForecastingItemController();
        Account acc = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId());
        acc.Name = 'Test Account';
        acc.Source_System__c = 'LMSi';                //WBCP Licensee
        acc.Allow_Forecasting__c = True;
        insert acc;
        CP_Forecast__c forecastRecord = new CP_Forecast__c(Licensee_Name__c = acc.Id,Forecast_version__c = 1);
        insert forecastRecord;
        Property__c propertyRecord = new Property__c();
        propertyRecord.Name = 'Test Property';
        propertyRecord.Allow_Forecasting__c = true;
        propertyRecord.Source_System__c = 'LMSi';
        insert propertyRecord;
        CP_Contract__c contract = new CP_Contract__c();
        contract.Name = 'Test Contract';
        contract.Source_System__c = 'LMSi';
        insert contract;
        CP_Forecast_Currency__c currencyRecord = new CP_Forecast_Currency__c();
        currencyRecord.Name = 'Test Currency';
        currencyRecord.Allow_Forecasting__c = true;
        insert currencyRecord;
        WBCP_Country__c territoryRecord = new WBCP_Country__c();
        territoryRecord.Name = 'Test Country';
        territoryrecord.Allow_Forecasting__c = true;
        insert territoryRecord;
        CP_Product_Type__c productType = new CP_Product_Type__c();
        productType.Name = 'Test Product Name';
        productType.Allow_Forecasting__c = true;
        productType.Source_System__c = 'LMSi';
        productType.Product_Type_Code__c = 'dhgfubsjhg'; 
        insert productType;
        String data = '[{"Revenue_Type__c":"1-Royalties","Royalty_Rate__c":5,"Q1__c":60000,"Q2__c":70000,"Q3__c":30000,"Q4__c":40000,"Forecast__c":"' + forecastRecord.Id + '"}]';
        List<CP_Forecast_Item__c> fItems = CP_ForecastingItemController.createForecastingItemForPOC(data, forecastRecord.Id);
        System.assertEquals(fItems.size(), 1);
        String profileName = CP_ForecastingItemController.getProfile();
        /*    Map<Id, String> ContractsMap = CP_ForecastingItemController.getContractsForPOC();
Map<Id, String> TerritoriesMap = CP_ForecastingItemController.getTerritoriesForPOC();
Map<Id, String> PropertiesMap = CP_ForecastingItemController.getPropertiesForPOC();
Map<Id, String> RetailersMap = CP_ForecastingItemController.getRetailersForPOC();
Map<Id, String> ProductsMap = CP_ForecastingItemController.getProductsForPOC();
Map<Id, String> ForecastCurrMap = CP_ForecastingItemController.getForecastingCurrencyForPOC();*/
        fItems = CP_ForecastingItemController.checkDuplicateRecord(fItems);
        list<id> ids = new list<id>();
        for(CP_Forecast_Item__c fi:fItems){
            ids.add(fi.id);
        }
        fItems = CP_ForecastingItemController.deleteForecastingItemsForPOC(ids,'onlyDelete', forecastRecord.Id);
        System.assertEquals(fItems.size(),1);
    }
    /* @isTest
static void deleteForecastingItemsForPOCExceptionCheck(){
List<Id> recordIds = new List<Id>();
String data ='onlyDelete';
Account acc = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId());
acc.Name = 'Test Account';
insert acc;
CP_Forecast__c forecastRecord = new CP_Forecast__c(Licensee_Name__c = acc.Id);
insert forecastRecord;
Id forecastingRecordId = forecastRecord.Id;
CP_ForecastingItemController.deleteForecastingItemsForPOC(recordIds,data,forecastingRecordId);

}*/
    @isTest
    static void getForecastingItemTest(){
        CP_ForecastingItemController obj = new CP_ForecastingItemController();
        Account acc = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId());
        acc.name= 'Test Account';
        acc.Source_System__c = 'LMSi';
        acc.Allow_Forecasting__c = true;
        insert acc;
        CP_Forecast__c forecastRecord = new CP_Forecast__c(Licensee_Name__c = acc.Id,Forecast_version__c=1);
        insert forecastRecord;
        List<CP_Forecast_Item__c> fItems = CP_ForecastingItemController.getForecastingItemsForPOC(forecastRecord.Id);
        //List<Map<Id, String>> lookUps = CP_ForecastingItemController.getLookUpsForPOC();
        System.assertEquals(fItems.size(),0);
        
    }
    /* @isTest
static void deleteForecastingItemTest(){
CP_ForecastingItemController obj = new CP_ForecastingItemController();
Account acc = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId());
acc.name = 'Test Account';
insert acc;
CP_Forecast__c forecastRecord = new CP_Forecast__c(Licensee_Name__c = acc.Id);
insert forecastRecord;
String data = '[{"Revenue_Type__c":"1-Royalties","Royalty_Rate__c":5,"Q1__c":60000,"Q2__c":70000,"Q3__c":30000,"Q4__c":40000,"Forecast__c":"' + forecastRecord.Id + '"}]';
CP_Forecast_Item__c fItem = new CP_Forecast_Item__c();
fItem.Forecast__c = forecastRecord.Id;
insert fItem;
List<Id> fItemIds = new List<Id>();
fItemIds.add(fItem.Id);        
List<CP_Forecast_Item__c> fItems = CP_ForecastingItemController.deleteForecastingItemsForPOC(fItemIds ,data, forecastRecord.Id);
}*/
    @isTest
    static void updateForecastingItemTest(){
        CP_ForecastingItemController obj = new CP_ForecastingItemController();
        Account acc = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId());
        acc.name = 'test Account';
        acc.Source_System__c = 'LMSi';
        acc.Allow_Forecasting__c = true;
        insert acc;
        CP_Forecast__c forecastRecord = new CP_Forecast__c(Licensee_Name__c = acc.Id,Forecast_version__c=1);
        insert forecastRecord;
        CP_Forecast_Item__c fItem1= new CP_Forecast_Item__c();
        fItem1.Revenue_Type__c = '1-Royalties';
        fItem1.Royalty_Rate__c = 6;
        fItem1.Q1__c = 3000;
       /* fItem1.Q2__c = 3000;
        fItem1.Q3__c = 3000;
        fItem1.Q4__c = 3000;*/
        fItem1.Forecast__c = forecastRecord.Id;
        insert fItem1;
        CP_Forecast_Item__c fItem2= new CP_Forecast_Item__c();
        fItem2.Revenue_Type__c = '1-Royalties';
        fItem2.Royalty_Rate__c = 3;
        fItem2.Q1__c = 7000;
       /* fItem2.Q2__c = 7000;
        fItem2.Q3__c = 7000;
        fItem2.Q4__c = 7000;*/
        fItem2.Forecast__c = forecastRecord.Id;
        insert fItem2;
        Property__c property = new Property__c();
        property.Name = 'Test Property';
        property.Allow_Forecasting__c = true;
        property.Source_System__c='LMSi';
        insert property;
        CP_Contract__c contract = new CP_Contract__c();
        contract.Name = 'Test Contract';
        contract.Source_System__c = 'LMSi';
        insert contract;
        CP_Forecast_Currency__c currencyRecord = new CP_Forecast_Currency__c();
        currencyRecord.Name = 'Test Currency';
        currencyRecord.Allow_Forecasting__c = true;
        insert currencyRecord;
        WBCP_Country__c territoryRecord = new WBCP_Country__c();
        territoryRecord.Name = 'Test Country';
        territoryrecord.Allow_Forecasting__c = true;
        insert territoryRecord;
        CP_Product_Type__c productType = new CP_Product_Type__c();
        productType.Name = 'Test Product Name';
        productType.Allow_Forecasting__c = true;
        productType.Source_System__c = 'LMSi';
        productType.Product_Type_Code__c = 'dhgfubsjhg';
        insert productType;
        String data2 = '[{"Id":"' + (String)fItem1.Id + '","Royalty_Rate__c":10,"Revenue_Type__c":"1-Royalties", "Retailer__c":"' + (String)acc.Id + '"},{"Id":"' + (String)fItem2.Id + '","Royalty_Rate__c":10}]';
        System.debug(data2);
        List<CP_Forecast_Item__c> fITemsUpdated = CP_ForecastingItemController.updateForecastingItemForPOC(data2, forecastRecord.Id);
        //  CP_ForecastingItemController.showGridErrorValidationInsert(fITemsUpdated);
        // CP_ForecastingItemController.showGridErrorValidationInsert(fITemsUpdated);
        System.assertEquals(fITemsUpdated.size(),2);
        List<Id> forecastingItemsListIds = new List<Id>();
        forecastingItemsListIds.add(fItem1.Id);
        forecastingItemsListIds.add(fItem2.Id);
        test.startTest();
        List<CP_Forecast_Item__c> returnedList = CP_ForecastingItemController.submitForecast(forecastRecord.Id); 
        List<CP_Forecast_Item__c> forecastItemList = CP_ForecastingItemController.mergeSelectedRows(forecastingItemsListIds,forecastRecord.Id);
        List<CP_Forecast_Item__c> forecastItemListValidated = CP_ForecastingItemController.validateForecastItems(forecastRecord.Id);
        test.stopTest();
    }
    @isTest
    static void showGridErrorValidationUpdateTest(){
        List<CP_Forecast_Item__c> forecastingItemList = new List<CP_Forecast_Item__c>();
        Account acc = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId());
        acc.name = 'test Account';
        acc.Source_System__c = 'LMSi';
        acc.Allow_Forecasting__c = true;
        insert acc;
        CP_Forecast__c forecastRecord = new CP_Forecast__c(Licensee_Name__c = acc.Id,Forecast_version__c = 1);
        insert forecastRecord;
        CP_Forecast_Item__c fItem1= new CP_Forecast_Item__c();
        fItem1.Revenue_Type__c = null;
        fItem1.Royalty_Rate__c = 0;
        fItem1.Q1__c = 3000;
        fItem1.Forecast__c = forecastRecord.Id;
        insert fItem1;
        CP_Forecast_Item__c fItem2= new CP_Forecast_Item__c();
        fItem2.Revenue_Type__c = null;
        fItem2.Royalty_Rate__c = 0;
        fItem2.Q1__c = 3000;
        fItem2.Forecast__c = forecastRecord.Id;
        insert fItem2;
        forecastingItemList.add(fItem1);
       // forecastingItemList.add(fItem2);
        CP_ForecastingItemController.showGridErrorValidationUpdate(forecastingItemList);
        System.assertNotEquals(fItem1.Errors__c, 'Territory, Forecast Currency, Contract Number, Property, Product Type, Retailer, not populated.');
    }
    @isTest 
    static void getProductsForPOCTest(){
        List<CP_Product_Type__c> productList = new List<CP_Product_Type__c>();
        CP_Product_Type__c productRecord = new CP_Product_Type__c();
        productRecord.Name = 'Test Product';
        productRecord.Product_Type_Code__c ='TSHGSGSGU1';
        productRecord.Allow_Forecasting__c = true;
        productRecord.Source_System__c = 'LMSi';
        productList.add(productRecord);
        insert productList;
        System.assertEquals(productList.size(),1);
        Map<Id,String> returnedMap = CP_ForecastingItemController.getProductsForPOC();
        System.assertEquals(returnedMap.size(),productList.size());
    }
    @isTest
    static void getRetailerForPOCTest(){
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Retailer').getRecordTypeId();
        Account acctrecord = new Account();
        acctrecord.Name = 'Test Account';
        acctrecord.RecordTypeId = accountRecordTypeId;
        acctrecord.Allow_Forecasting__c = true;
        acctrecord.Source_System__c = 'LMSi';
        insert acctrecord;
        System.assertNotEquals(acctrecord.Id, null, 'Account record Not Created');
         Map<Id,String> returnedMap = CP_ForecastingItemController.getRetailersForPOC();
        System.assertEquals(returnedMap.get(acctrecord.Id), 'Test Account');
    }
    @isTest
    static void getPropertiesForPOCTest(){
        Property__c property = new Property__c();
        property.Name = 'Test Property';
        property.Allow_Forecasting__c = true;
        property.Source_System__c = 'LMSi';
        insert property;
        System.assertNotEquals(property.Id, null , 'Error in Creating in Properties');
        Map<Id,String> returnedMap = CP_ForecastingItemController.getPropertiesForPOC();
        System.assertEquals(returnedMap.get(property.Id), 'Test Property');
    }
    @isTest
    static void getTerritoriesForPOCTest(){
        WBCP_Country__c countryRecord =  new WBCP_Country__c();
        countryRecord.Name = 'Test Country';
        countryRecord.Allow_Forecasting__c = true;
        insert countryRecord;
        System.assertNotEquals(countryRecord.Id, null, 'Territory record not Created');
        Map<Id,String> returnedMap = CP_ForecastingItemController.getTerritoriesForPOC();
        System.assertEquals(returnedMap.get(countryRecord.Id),'Test Country');
    }
    @isTest
    static void getContractsForPOCTest(){
        Account licenseeAccount = new Account();
        licenseeAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId();
        licenseeAccount.Name = 'LicenseeAccount';
        insert licenseeAccount;
        CP_Contract__c contractRecord = new CP_Contract__c();
        contractRecord.Name = 'Test Contract Record';
        contractRecord.Source_System__c = 'LMSi';
        contractRecord.Account_Licensee__c = licenseeAccount.Id;
        contractRecord.Source_System__c = 'LMSi';
        insert contractRecord;
        CP_Forecast__c forecastRecord = new CP_Forecast__c();
        forecastRecord.Licensee_Name__c = licenseeAccount.Id;
        insert forecastRecord;
      //  System.assertNotEquals(contractRecord.Id, null, 'Contract Record not Created');
        Map<Id,String> returnedMap = CP_ForecastingItemController.getContractsForPOC(forecastRecord.Id);          
      //  System.assertEquals(returnedMap.get(contractRecord.Id), 'Test Contract Record');
            //  
       
     
    }
    @isTest
    static void getForecastingCurrencyForPOCTest(){
        CP_Forecast_Currency__c currencyRecord = new CP_Forecast_Currency__c();
        currencyRecord.Name = 'Test Currency';
        currencyRecord.Allow_Forecasting__c = true;
        insert currencyRecord;
        System.assertNotEquals(currencyRecord.Id, null ,'No error');
        Map<Id,String> returnedMap = CP_ForecastingItemController.getForecastingCurrencyForPOC();
        System.assertEquals(returnedMap.get(currencyRecord.Id) , 'Test Currency');
    }
   // @isTest
   /* static void getContractsForPOCTest2(){
         Id profId = [SELECT Id,Name FROM Profile WHERE Name ='CP - Partner Community Agent'].Id;
        User usr = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason.liveston@asdf.com',
                           Username = profId+'jason.liveston@asdf.com',
                           ProfileId = profId,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert usr;
        System.runAs(usr){
             Account licenseeAccount = new Account();
             licenseeAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId();
             licenseeAccount.Name = 'LicenseeAccount';
             insert licenseeAccount;
             CP_Contract__c contractRecord = new CP_Contract__c();
             contractRecord.Name = 'Test Contract Record';
             contractRecord.Source_System__c = 'LMSi';
             contractRecord.Account_Licensee__c = licenseeAccount.Id;
             contractRecord.Source_System__c = 'LMSi';
             insert contractRecord;
             CP_Forecast__c forecastRecord = new CP_Forecast__c();
             forecastRecord.Licensee_Name__c = licenseeAccount.Id;
             insert forecastRecord;
        System.assertNotEquals(contractRecord.Id, null, 'Contract Record not Created');
             Map<Id,String> returnedMap = CP_ForecastingItemController.getContractsForPOC(forecastRecord.Id);      
        }
    }*/
    
   
}