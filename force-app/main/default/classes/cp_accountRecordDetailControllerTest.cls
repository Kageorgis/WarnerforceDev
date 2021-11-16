/**
 * Created by XMMORENO on 3/16/2020.
 */

@IsTest
private class cp_accountRecordDetailControllerTest {
    @TestSetup
    static void setupTestData(){
        test.startTest();
        Id licRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId();
        Id retRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Retailer').getRecordTypeId();
     //   System.debug('This is the recordTyp'+licRecTypeid);
       Account licenceeAcc = (Account)TestDataFactory.createSObject('Account', new Map<String,Object>{
               'RecordTypeId' => licRecTypeid
       },true);
        Account retailerAcc = (Account)TestDataFactory.createSObject('Account', new Map<String,Object>{
                'RecordTypeId' => retRecTypeid
        });
        List<Property__c> propList = TestDataFactory.createSObjectList('Property__c',10);
        List<Licensee_Related_Retailer__c> relRetal =  TestDataFactory.createSObjectList('Licensee_Related_Retailer__c', new Map<String,Object>{
                'Related_Licensee__c' => licenceeAcc.Id,
                'Retailer_Description__c' => retailerAcc.Id
        },10);
        List<Licensee_Property__c> relProp =  TestDataFactory.createSObjectList('Licensee_Property__c', new Map<String,Object>{
                'Account__c' => licenceeAcc.Id,
                'Property__c' => propList[0].Id
        },10);
       /*
        String profileId = [SELECT Id, Name FROM Profile WHERE Name ='Studio Community User'].Id;
        User u = (User)TestDataFactory.createSObject('User', new Map<String,Object>{
                'ProfileId' => profileId,
                'Username' => 'test{!index}@mytestdomain.developer',
                'Contact' => conList[0]

        });

         */
        test.stopTest();
    }

    static testMethod void test_getRecordTypeId(){
        Account licAccount = [SELECT Id,Name,RecordType.DeveloperName  FROM Account WHERE RecordType.Name ='WBCP Licensee' LIMIT 1];
        Id licRecTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId();
        Id returnId = cp_accountRecordDetailController.getRecordTypeId(licAccount.Id);
        System.assert(returnId == licRecTypeid );


    }
    static testMethod void test_createProperties(){
        Account licAccount = [SELECT Id,Name,RecordType.DeveloperName  FROM Account WHERE RecordType.Name ='WBCP Licensee' LIMIT 1];
      List<Account> retAccount = [SELECT Id,Name,RecordType.DeveloperName  FROM Account WHERE RecordType.Name ='WBCP Retailer' LIMIT 1];
                List<Property__c> propList = [SELECT Id From Property__c];
      Id returnId  = cp_accountRecordDetailController.createProperties(licAccount, propList,retAccount,licAccount.RecordTypeId );
        System.assertEquals(returnId,licAccount.Id);

    }
    static testMethod void test_getCategories(){
        Account licAccount = [SELECT Id,Name,RecordType.DeveloperName  FROM Account WHERE RecordType.Name ='WBCP Licensee' LIMIT 1];


      cp_accountRecordDetailController.catSubCatWrapper returnList = cp_accountRecordDetailController.getCategories(licAccount.Id);
        System.assertEquals(returnList ==null ,false);


    }
    static testMethod void test_poplulateCategories(){
        Account licAccount = [SELECT Id,Name,RecordType.DeveloperName  FROM Account WHERE RecordType.Name ='WBCP Licensee' LIMIT 1];
        List<String> subcatValuesList = new List<String>();
        Schema.DescribeFieldResult subCatValue = Account.Sub_Category__c.getDescribe();
        List<Schema.PicklistEntry> subcat = subCatValue.getPicklistValues();for (Schema.PicklistEntry pickListVal : subcat) {
            subcatValuesList.add(pickListVal.getLabel());
            //    System.debug('Values in Rating are: ' + subcatValuesList);
        }

        Map<String,List<String>> returnList = cp_accountRecordDetailController.populateCategories(subcatValuesList);
        System.assertEquals(returnList ==null ,false);


    }
    static testMethod void test_getPageLayoutFields(){
        Account licAccount = [SELECT Id,Name,RecordType.DeveloperName, RecordTypeId  FROM Account WHERE RecordType.Name ='WBCP Licensee' LIMIT 1];
        String recTypeId = licAccount.RecordTypeId;
        List<cp_accountRecordDetailController.LayoutSection> returnList = cp_accountRecordDetailController.getPageLayoutFields(recTypeId);
        System.assertEquals(returnList ==null ,false);


    }
}