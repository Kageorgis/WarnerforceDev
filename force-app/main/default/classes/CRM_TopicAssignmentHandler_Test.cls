/**
   @Author Tushar Mudgal
   @name - CRM_TopicAssignmentHandller_Test
   @CreateDate - 22 Dec 2015
   @Description - Test class for CRM_TopicAssignmentTriggerHandler
   @Version <1.0>
   @reference Requirement no 09
  */
@isTest
private class CRM_TopicAssignmentHandler_Test{
   
    /**
    *  This method is used to create test Data. 
    *  @name createTestData
    */
    
    @testSetup static void createTestData(){        
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'Asia1', 'Asia2'}, 2, true);
        system.assertNotEquals(null, countries[0].id);
        List<Title__c> titles = CRM_TestDataFactory.createTitles(100, true);
        system.assertNotEquals(null, titles[0].id);
        List<Language__c> languages = CRM_TestDataFactory.createLanguages(100, true);  
        system.assertNotEquals(null, languages[0].id);
        List<Local_Title__c> localTitles = CRM_TestDataFactory.createLocalTitles(countries, languages, 1, true);  
        system.assertNotEquals(null, localTitles[0].id);
        List<Topic> lstTopic =  CRM_TestDataFactory.createTopics(10, true);
        system.assertNotEquals(null, lstTopic[0].id);
    }
    
     /**
      *  This method is used for testing of Topic assignment handller trigger, with bulk insert of Topic 
      *  @name - insertTopic*/
     
    static testMethod void insertTopic(){
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true AND ByPassValidationRule__c= False Limit 1];
        system.runAs(u){
            list<TopicAssignment> lstTopicAssignment = new list<TopicAssignment>();
            for(Local_Title__c ltitle:[select id from Local_Title__c]){
                for(Topic top:[select id,Name from Topic])
                {   TopicAssignment topAssignment =  new TopicAssignment();
                    topAssignment.EntityId = ltitle.Id;
                    topAssignment.TopicId= top.Id;
                    lstTopicAssignment.add(topAssignment);
                }
            }
            insert lstTopicAssignment;
            
            system.assert([Select Topics__c from Local_Title__c Limit 1].Topics__c!= null);
            
        }
    }
     /*
      *  This method is used to to test Delete functionality of TopicAssignmentHandller. Here in this method we have called
      *  methods from TopicAssignmentHandller which we have not used and not covering in the code
      *  @name deleteTopic
      */
      
    static testMethod void deleteTopic(){
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true AND ByPassValidationRule__c= False Limit 1];
        system.runAs(u){
            list<TopicAssignment> lstTopicAssignment = new list<TopicAssignment>();
            for(Local_Title__c ltitle:[select id from Local_Title__c]){
                for(Topic top:[select id from Topic]){
                    TopicAssignment topAssignment =  new TopicAssignment();
                    topAssignment.EntityId = ltitle.Id;
                    topAssignment.TopicId= top.Id;
                    lstTopicAssignment.add(topAssignment);
                 }
            }
            insert lstTopicAssignment;
            
            delete lstTopicAssignment[0];
            system.assert([Select Topics__c from Local_Title__c limit 1].Topics__c != null);
         }
    } 
    
}