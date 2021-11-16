/******************************************************************************************
Class Name      : WBCP_SendEmailControllerTest
Creation Date   : 18 May 2021
Description     : This is Test class for WBCP_SendEmailController
Author          : Aaditya Raj(Cognizant)
******************************************************************************************/
@isTest
public class WBCP_SendEmailControllerTest {
  
        @isTest static void WBCP_SendEmailController_Test(){
        UserRole userRole = new UserRole(DeveloperName = 'MyTestRole', Name = 'WBCP North America');
        insert userRole;
        Profile userProfile = [select id from profile where name='System Administrator'];
        User testUser = new User(ProfileId = userProfile.Id, Username = 'testUser@wbcp2.com', Email = 'testUser2@wbcp.dev',
                                  EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', 
                                  TimeZoneSidKey = 'America/Los_Angeles', Alias = 'tuser2', LastName = 'LastTest2',
                                  UserRoleId = userRole.Id, WBCP_Access_Role__c = 'Global', Country = 'United States');
        insert testUser;

        System.runAs(testUser){
            Account account = new Account(
            Name = 'Test ACCOUNT',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('WBCP_Licensee').getRecordTypeId(),
            Sharing__c = 'Studio Wide'
        );
        insert account;
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('WBCP_Licensee_Contact').getRecordTypeId(),
            AccountId = account.Id,
            Email = 'test@warnertest.com',
            CP_Territory__c='United States',
            CP_Region__c='North America'
        );
        insert contact;
            List<Contact> lstContact= new List<Contact>();
            Map<String,Object> mapContactEmailIdToSend = new MAP<String,Object>();
            
            for(Contact c :lstContact)
            {
                mapContactEmailIdToSend.put(c.Email, c);
            }
            List<String> lstattachmentIdblank = new List<String>();
            lstattachmentIdblank.add(null);
            
            WBCP_SendEmailController emailController = new WBCP_SendEmailController();
            WBCP_SendEmailController.createListEmailRecord('test@warnertest.com' ,testUser.Id,'EmailUser','BodyEmail',testUser.Id);
            //WBCP_SendEmailController.storetheAttachedFile('fileName','base64Data', 'contentType', mapContactEmailIdToSend, lstattachmentIdblank);
        }
    }

    
     @isTest static void getEmailTempaltes_Test(){
        UserRole userRole = new UserRole(DeveloperName = 'MyTestRole', Name = 'WBCP North America');
        insert userRole;
        Profile userProfile = [select id from profile where name='System Administrator'];
        User testUser = new User(ProfileId = userProfile.Id, Username = 'testUser@wbcp2.com', Email = 'testUser2@wbcp.dev',
                                  EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', 
                                  TimeZoneSidKey = 'America/Los_Angeles', Alias = 'tuser2', LastName = 'LastTest2',
                                  UserRoleId = userRole.Id, WBCP_Access_Role__c = 'Global', Country = 'United States');
        insert testUser;

        System.runAs(testUser){
            Account account = new Account(
            Name = 'Test ACCOUNT',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('WBCP_Licensee').getRecordTypeId(),
            Sharing__c = 'Studio Wide'
        );
        insert account;
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('WBCP_Licensee_Contact').getRecordTypeId(),
            AccountId = account.Id,
            Email = 'test@warnertest.com',
            CP_Territory__c='United States',
            CP_Region__c='North America'
        );
            
          Contact contact2 = new Contact(
            FirstName = 'Test2',
            LastName = 'Contact2',
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('WBCP_Licensee_Contact').getRecordTypeId(),
            AccountId = account.Id,
            Email = 'test@warnertest2.com',
            CP_Territory__c='United States',
            CP_Region__c='North America'
        );
            List<Contact> lstContact = new List<Contact>();
            lstContact.add(contact);
            lstContact.add(contact2);
        insert lstContact;
            
            String bodyStr=contact.Name + '\n' + contact.Notes__c;
            
            Attachment attach = new Attachment();
            attach.ContentType = 'text/plain';
            attach.ParentId = account.Id;
            attach.Body =Blob.valueOf(bodyStr);
            attach.Name = 'test.txt';
            insert attach;
            
            
            List<String> lstattachmentId = new List<String>();
            lstattachmentId.add(attach.Id);
            
            List<String> lstattachmentIdblank = new List<String>();
            lstattachmentIdblank.add(null);
            
            EmailTemplate emailtemp = new EmailTemplate();
            emailtemp.Name = 'WBCP Studio';
            
            
            Map<String,Object> mapContactEmailIdToSend = new MAP<String,Object>();
            
            for(Contact c :lstContact)
            {
                mapContactEmailIdToSend.put(c.Email, c);
            }
            
            Set<String> conId = new Set<String>();
            conId.add(lstContact[0].Id);
            WBCP_SendEmailController.getEmailTempaltes();
            WBCP_SendEmailController.storetheAttachedFile('fileName','base64Data', 'contentType', mapContactEmailIdToSend, lstattachmentId);
            WBCP_SendEmailController.saveTheFile('fileName','base64Data', 'contentType', conId);
        }
    }
    
    @isTest static void sendEmail_Test(){
        UserRole userRole = new UserRole(DeveloperName = 'MyTestRole', Name = 'WBCP North America');
        insert userRole;
        Profile userProfile = [select id from profile where name='System Administrator'];
        User testUser = new User(ProfileId = userProfile.Id, Username = 'testUser@wbcp2.com', Email = 'testUser2@wbcp.dev',
                                 EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', 
                                 TimeZoneSidKey = 'America/Los_Angeles', Alias = 'tuser2', LastName = 'LastTest2',
                                 UserRoleId = userRole.Id, WBCP_Access_Role__c = 'Global', Country = 'United States');
        insert testUser;
        
        System.runAs(testUser){
            Account account = new Account(
                Name = 'Test ACCOUNT',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('WBCP_Licensee').getRecordTypeId(),
                Sharing__c = 'Studio Wide'
            );
            insert account;
            Contact contact = new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('WBCP_Licensee_Contact').getRecordTypeId(),
                AccountId = account.Id,
                Email = 'test@warnertest.com',
                CP_Territory__c='United States',
                CP_Region__c='North America'
            );
            
            Contact contact2 = new Contact(
                FirstName = 'Test2',
                LastName = 'Contact2',
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('WBCP_Licensee_Contact').getRecordTypeId(),
                AccountId = account.Id,
                Email = 'test@warnertest2.com',
                CP_Territory__c='United States',
                CP_Region__c='North America'
            );
            Task_Group_Counter__c tgc = Task_Group_Counter__c.getOrgDefaults();
            tgc.Counter__c = 1;
            insert tgc;
            List<Contact> lstContact = new List<Contact>();
            lstContact.add(contact);
            lstContact.add(contact2);
            insert lstContact;
            
            Map<String,Object> mapContactEmailIdToSend = new MAP<String,Object>();
            
            for(Contact c :lstContact)
            {
                system.debug('Email='+c.Email);
                mapContactEmailIdToSend.put(c.Email, c.Id);
            }
            
            String bodyStr=contact.Name + '\n' + contact.Notes__c;
            
            Attachment attach = new Attachment();
            attach.ContentType = 'text/plain';
            attach.ParentId = lstContact[0].Id;
            attach.Body =Blob.valueOf(bodyStr);
            attach.Name = 'test.txt';
            
            
            List<Attachment> lstAttachObj = new List<Attachment>();
            lstAttachObj.add(attach);
            
            insert lstAttachObj;
            List<String> lstattachmentId = new List<String>();
            lstattachmentId.add(lstAttachObj[0].Id);
            
            
            EmailTemplate emailtemp = new EmailTemplate(developerName = 'emailTemplate_developer_test', FolderId = testUser.Id, TemplateType= 'Text', Name = 'test', isActive = true);
            insert emailtemp;
            
            //Set<String> conId = new Set<String>();
            //conId.add(lstContact[0].Id);
            //WBCP_SendEmailController.storetheAttachedFile('fileName','base64Data', 'contentType', mapContactEmailIdToSend, lstattachmentId);
            //WBCP_SendEmailController.saveTheFile('fileName','base64Data', 'contentType', conId);
            Test.startTest();
            WBCP_SendEmailController.sendEmail(emailtemp.Id,'TestSubject','TestemailBody',mapContactEmailIdToSend, lstattachmentId);
            Test.stopTest();
        }
    }
}