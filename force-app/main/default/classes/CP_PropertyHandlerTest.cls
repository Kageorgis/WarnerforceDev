@IsTest
private class CP_PropertyHandlerTest {
    @TestSetup
    static void createTestData(){
        Property__c propRec = (Property__c)TestDataFactory.createSObject('Property__c',new Map<String,object>{
            'Name' => 'Batman Core', 'Franchise__c' => 'Batman', 'Brand__c' => 'DC', 
            'cp_Property_Code__c' => '000046', 'Short_Code__c' => 'DCB', 'IsPrimary__c'=>True});
        Property__c propRec1 = (Property__c)TestDataFactory.createSObject('Property__c',new Map<String,object>{
            'Name' => 'Batman (1966)', 'Franchise__c' => 'Batman', 'Brand__c' => 'DC', 
            'cp_Property_Code__c' => '001883', 'Short_Code__c' => 'BAT66'});
    }
    
    @IsTest
    static void test_insertProperties(){
        Property__c obj = new Property__c();
        obj.Name = 'Supergirl Core';
        obj.Franchise__c = 'Superman';
        obj.Brand__c = 'DC';
        obj.cp_Property_Code__c = '001023';
        obj.Short_Code__c = 'DCSG';
        insert obj;
    }
    
    @IsTest
    static void test_updateProperties(){
        Property__c obj = [SELECT Id FROM Property__c WHERE Name = 'Batman (1966)'];
        obj.Short_Code__c = 'BAT666';
        update obj;
    }
    
    @IsTest
    static void test_updatePropertiesError(){
        Property__c obj = [SELECT Id FROM Property__c WHERE Name = 'Batman (1966)'];
        obj.IsPrimary__c = True;
        try{
            update obj;    
        }catch(Exception e){
            System.debug('Exception : '+ e.getMessage());
        }
    }
}