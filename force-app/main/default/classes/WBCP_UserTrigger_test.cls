@isTest(SeeAllData=false)
public class WBCP_UserTrigger_test {
    static testMethod void userTest()
    {
        Profile pf= [Select Id from profile where Name=:Label.WBCP_NAM_Licensee_App_Admin];
        UserRole userRole = new UserRole(DeveloperName = 'MyTestRole', Name = 'WBCP Local Regional Role');
        insert userRole;
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        
        User user=new User(firstname = 'ABC', 
                           lastName = 'WBCPUser_exception', 
                           email = uniqueName + '@test' + orgId + '.org', 
                           Username = uniqueName + '@test' + orgId + '.org', 
                           EmailEncodingKey = 'ISO-8859-1', 
                           Alias = uniqueName.substring(18, 23), 
                           TimeZoneSidKey = 'America/Los_Angeles', 
                           LocaleSidKey = 'en_US', 
                           LanguageLocaleKey = 'en_US', 
                           ProfileId = pf.Id,
                           IsActive =true,
                           UserRoleId = userRole.Id,
                           WBCP_Access_Role__c='Local'
                          );
        Test.startTest();
        insert user;
        Test.stopTest(); 
        
    }
   
    static testMethod void userCreationTest()
    {
        Profile pf= [Select Id from profile where Name=:Label.WBCP_NAM_Licensee_App_Admin]; 
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        UserRole userRole = new UserRole(DeveloperName = 'MyTestRole', Name = 'WBCP Local Regional Role');
        insert userRole;
        
        User user=new User(firstname = 'ABC', 
                           lastName = 'XYZ', 
                           email = uniqueName + '@test' + orgId + '.org', 
                           Username = uniqueName + '@test' + orgId + '.org', 
                           EmailEncodingKey = 'ISO-8859-1', 
                           Alias = uniqueName.substring(18, 23), 
                           TimeZoneSidKey = 'America/Los_Angeles', 
                           LocaleSidKey = 'en_US', 
                           LanguageLocaleKey = 'en_US', 
                           ProfileId = pf.Id,
                           country='United States',
                           IsActive =true,
                           UserRoleId = userRole.Id,
                           WBCP_Access_Role__c='Local'
                          ); 
        Test.startTest();
        insert user;
        Test.stopTest(); 
    }
    
    static testMethod void updateUserTest()
    {
        Profile pf= [Select Id from profile where Name=:Label.WBCP_NAM_Licensee_App_Admin];
        UserRole userRole = new UserRole(DeveloperName = 'MyTestRole', Name = 'WBCP Local Regional Role');
        insert userRole;
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User user=new User(firstname = 'ABC', 
                           lastName = 'XYZ', 
                           email = uniqueName + '@test' + orgId + '.org', 
                           Username = uniqueName + '@test' + orgId + '.org', 
                           EmailEncodingKey = 'ISO-8859-1', 
                           Alias = uniqueName.substring(18, 23), 
                           TimeZoneSidKey = 'America/Los_Angeles', 
                           LocaleSidKey = 'en_US', 
                           LanguageLocaleKey = 'en_US', 
                           ProfileId = pf.Id,
                           UserRoleId = userRole.Id,
                           country='United States',
                           WBCP_Access_Role__c='Regional',
                           IsActive =true
                          ); 
        Test.startTest();
        insert user;
        user updateUser = [Select id,WBCP_Access_Role__c from user where id =:user.id];
        updateUser.WBCP_Access_Role__c='Local';
        update updateUser;
        Test.stopTest(); 
    }
}