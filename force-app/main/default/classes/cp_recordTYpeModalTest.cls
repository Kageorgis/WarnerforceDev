/**
 * Created by XMMORENO on 3/16/2020.
 */

    @IsTest
            private class cp_recordTYpeModalTest {
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

static testMethod void test_getList(){
    cp_recordTypeModal.getListViews();



}
static testMethod void test_fetchRecordTypeValues(){
cp_recordTypeModal.fetchRecordTypeValues();
}
static testMethod void test_getRecTypeId(){
cp_recordTypeModal.getRecTypeId('WBCP Licensee');

}
static testMethod void test_createRelatedProperties(){
Account licAccount = [SELECT Id,Name,RecordType.DeveloperName  FROM Account WHERE RecordType.Name ='WBCP Licensee' LIMIT 1];
    List<Property__c> propList = [SELECT Id FROM Property__c];
    cp_recordTypeModal.createRelatedProperties(licAccount.Id,propList,licAccount.Name);


}
        static testMethod void test_createRelatedRetailers(){
            Account licAccount = [SELECT Id,Name,RecordType.DeveloperName  FROM Account WHERE RecordType.Name ='WBCP Licensee' LIMIT 1];
            List<Account> retAccount = [SELECT Id FROM Account WHERE RecordType.Name ='WBCP Retailer'];
         cp_recordTypeModal.createRelatedRetailers(licAccount.Id,retAccount,licAccount.Name);


        }
}