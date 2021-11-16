/**
   @Author Cognizant
   @name CRM_ProcessAccountTeamMembers_Test
   @CreateDate 30 May 2016
   @Description Test class for CRM_ProcessAccountTeamMembers
   @Version <1.0>
   @reference Defect no 3038
  */

@isTest(SeeAllData=false)
private class CRM_ProcessAccountTeamMembers_Test{
    /**
    *  Create Test Data. 
    *  @name createTestData
    *  @param None
    *  @return None
    *  @throws None
    */
    
    static testmethod void createTestData() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(10, false);   
        Id tempRecordType = [select id,Name from RecordType where SobjectType='Account' and Name='Sold To' Limit 1].ID;
        User testUser = new User(Alias = 'wb1crms', Email='wb1crmstandarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='wb1crmstandarduser@testorg.com');
        insert testUser;
        
        for(Account acc : lstAccounts){
            acc.RecordTypeID = tempRecordType;
            acc.Owner_Games__c = testUser.id;            
        }
        insert lstAccounts;
        
        for(Account acc : lstAccounts){
            Integer countAccnt = [SELECT count() FROM AccountTeamMember WHERE AccountId =: acc.id];
            System.assertEquals(1,countAccnt);
        }
        
        for(Account acc : lstAccounts){
            acc.Owner_Games__c = null;            
        }
        update lstAccounts;
        
        for(Account acc : lstAccounts){
            Integer countAccnt = [SELECT count() FROM AccountTeamMember WHERE AccountId =: acc.id];
            System.assertEquals(0,countAccnt);
        }
        
        User testUser1 = new User(Alias = 'wb2crms', Email='wb2crmstandarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='wb2crmstandarduser@testorg.com');
        insert testUser1;
        
        for(Account acc : lstAccounts){
            acc.Owner_Games__c = testUser1.id;            
        }
        update lstAccounts;
        
        for(Account acc : lstAccounts){
            Id userId = [SELECT UserId FROM AccountTeamMember WHERE AccountId =: acc.id].UserId;
            System.assertEquals(testUser1.id,userId);
        }
        
        CRM_ProcessAccountTeamMembers.logAnException('Error');
            
    }
   

}