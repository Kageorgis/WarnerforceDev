@isTest
public Class WB_PricingTriggerHandlerTest{
    @isTest static void WB_PricingTriggerHandler(){
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
       // Insert account as current user
        System.runAs (thisUser) {
        
        Group g1 = new Group(Name='ChinaQ', type='Queue');
        insert g1;
        
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Pricing__c');
        insert q1;
        
        WB_Queue_Id__c cusSetting=new WB_Queue_Id__c(Name=g1.Name,Value__c=g1.id);
        insert cusSetting;
        
        Country__c c = new Country__c (
                     Name = 'cname',
                     Country_Code2__c = 'cn',
                     Country_Code__c = 'cna',
                     Digital_Owner__c='ChinaQ'
                     );
        insert c;
                     
        Pricing__c p=new Pricing__c(
                    Name='Test Pricing',
                    Country__c=c.Id);
                    
        Test.startTest();
        insert p;
        Test.stopTest();
        
        Pricing__c p1=[SELECT Id,Owner.Name FROM Pricing__c WHERE Name ='Test Pricing'];
        String obtained=p1.Owner.Name;
        String expected=cusSetting.Name;
        System.assertEquals(expected, obtained);
        }
    }
}