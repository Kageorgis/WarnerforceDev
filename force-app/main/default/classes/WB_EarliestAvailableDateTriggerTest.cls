/*
Created Date - 2 April 2017
Created By - Cognizant Team
*/

@isTest 
public class WB_EarliestAvailableDateTriggerTest{
    
    @isTest static void setQueueToOwner(){
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
       // Insert account as current user
        System.runAs (thisUser) {
        
        Group g1 = new Group(Name='ChinaQ', type='Queue');
        insert g1;
        
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Earliest_Avail_Date__c');
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
        
        Title__c objTitle = new Title__c(Name ='title'
                                        , Video_Version__c = '123456789'
                                        , Content_Type__c = 'Feature'
                                        , Digital_Planning__c = 'YES'
                                        , Formats__c='HD'
                                        , Clear_to_Avail__c = true);
        insert objTitle;             
 
        Earliest_Avail_Date__c eDate=new Earliest_Avail_Date__c(
                                        Title__c=objTitle.Id,
                                        Country__c=c.Id,
                                        Channel__c='EST',
                                        Format__c='HD',
        								Status__c ='Unlocked');
        Test.startTest();
        insert eDate;
        Test.stopTest();
        
        Earliest_Avail_Date__c ed1=[SELECT Id,Owner.Name FROM Earliest_Avail_Date__c WHERE Title__c =: objTitle.Id AND Country__c =: c.Id AND Channel__c='EST' AND Format__c='HD'];
        String obtained=ed1.Owner.Name;
        String expected=cusSetting.Name;
        System.assertEquals(expected, obtained);
        }
    }
}