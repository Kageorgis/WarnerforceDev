/*
Class Name   : WB_AnnouncementFormatCont_Test 
Description  : This class is to do code coverage for WB_AnnouncementFormatController class      
Created By   : Cognizant Technology Solutions - Navjyoti Mohanta
Created On   : MARCH 2015

Change History:
-------------------------------------------------------------------------------------------------------------------------------------
Sr#              Description                                               Updated By                                     Updated On
-------------------------------------------------------------------------------------------------------------------------------------
1              [Change Type]                                 Cognizant Technology Solutions - [Developer Name]           [MM/DD/YYYY]

CH01   Added Assertion statements for the required business             Akash Dalvi                                        4/27/2016
       scenarios.                        
*/

@isTest 
private class WB_AnnouncementFormatCont_Test{

  /*
 
    static testMethod void myUnitTest1(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Country_Groups__c countryGrp1 = new Country_Groups__c(Name = 'NewGrp',NameUnique__c ='UniqueNameTest');
        insert countryGrp1;
        
        Profile p = [select id from profile where name='System Administrator']; 
        User u = new User(alias = 'standt', email='testuser@testorg.com', 
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
        localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id);     
        insert u;
        
        Announcement_Rule__c newRule = new Announcement_Rule__c (Account__c = acctGoogle.Id,Announcement_Type__c ='NewType',DesignatedApprover__c =u.Id ,Country_Group__c = countryGrp1.Id);
        insert newRule;
        
        Test.startTest(); 
        
            PageReference pageRef = Page.WB_AnnouncementFormat;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', newRule.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(newRule);
            WB_AnnouncementFormatController controller = new WB_AnnouncementFormatController(sc);
            
            controller.getSelectedEmailTemp();
            controller.getSelectedRepTemp();
            system.assertEquals(controller.eTemplateList.size(),10);
            system.assertNotEquals(controller.rTemplateList.size(),10);    
            controller.saveSelection();
            
        Test.stopTest();
    
    }
    
    */
    /*
    static testMethod void myUnitTest2(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Country_Groups__c countryGrp1 = new Country_Groups__c(Name = 'NewGrp',NameUnique__c ='UniqueNameTest');
        insert countryGrp1;
        
        Profile p = [select id from profile where name='System Administrator']; 
        User u = new User(alias = 'standt', email='testuser@testorg.com', 
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
        localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id);     
        insert u;
        
        Announcement_Rule__c newRule = new Announcement_Rule__c (Account__c = acctGoogle.Id,Announcement_Type__c ='NewType',DesignatedApprover__c =u.Id ,Country_Group__c = countryGrp1.Id,Report_ID__c = 'NewReport' );
        insert newRule;
        
        Test.startTest(); 
        
            PageReference pageRef = Page.WB_AnnouncementFormat;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', newRule.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(newRule);
            WB_AnnouncementFormatController controller = new WB_AnnouncementFormatController(sc);
            
            controller.getSelectedEmailTemp();
            controller.getSelectedRepTemp();
            try{
            system.assertEquals(controller.eTemplateList.size(),10);
            system.assertNotEquals(controller.rTemplateList.size(),10);    
            controller.saveSelection();
            }
            catch(Exception e){
            }
            
        Test.stopTest();
    
    }
    
    */
    
    @isTest(SeeAllData=true)   
    static void  myUnitTest3(){
        List<Report> ReportTemp = [SELECT id,Name FROM Report Where Name = 'WB Standard Combined'];
            
        
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        Account_Role__c accRole = new Account_Role__c (Account__c = acctGoogle.id, role__c = 'Announcer', User__c = system.userinfo.getuserid());
        insert accRole;
        /*Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;*/
        
        Country_Groups__c countryGrp1 = new Country_Groups__c(Name = 'NewGrp',NameUnique__c ='UniqueNameTest');
        insert countryGrp1;
        
        Profile p = [select id from profile where name='System Administrator']; 
        User u = new User(alias = 'standt', email='testuser@testorg.com', 
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
        localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id);     
        insert u;
        
        Announcement_Rule__c newRule = new Announcement_Rule__c (Account__c = acctGoogle.Id,Announcement_Type__c ='NewType',DesignatedApprover__c =u.Id ,Country_Group__c = countryGrp1.Id, Report_ID__c = ReportTemp[0].Id, report_Template__c='ReportName', 
                                                                 Optional_Triggers__c = 'Abstract EIDR;Episode Number;EC Available Flag;Edit EIDR', Schedule_Type__c = 'Monthly', Weekly_Monthly_Schedule_Days__c = '3', Schedule_Time__c = '1', Active__c = true);
        insert newRule;
        
        Test.startTest(); 
         
            PageReference pageRef = Page.WB_AnnouncementFormat;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', newRule.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(newRule);
            WB_AnnouncementFormatController controller = new WB_AnnouncementFormatController(sc);
        Test.stopTest();
            //system.assert(false, controller.getSelectedEmailTemp());
            controller.getSelectedEmailTemp();
            controller.getSelectedRepTemp();
            //system.assert(false, controller.rTemplateList);
        
            list<selectOption> oplist = controller.rTemplateList;
        	Controller.selectedRepTemplate =  Oplist[0].getvalue();
            //system.assertNotEquals('None', Oplist[0].getvalue());
            //system.assertEquals('NewReport',Oplist[0].getvalue());    
            controller.saveSelection();
            try{
            controller.defaultTemp();
            }catch(exception e){}
            WB_AnnouncementFormatController controller1 = new WB_AnnouncementFormatController();
        
        
        
    }
    @isTest(SeeAllData=true)   
    static void  myUnitTestforMultipleReportId(){
        List<Report> ReportTemp = [SELECT id,Name FROM Report Where Name = 'EMA Features v1.7.2'];
            
        
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        Account_Role__c accRole = new Account_Role__c (Account__c = acctGoogle.id, role__c = 'Announcer', User__c = system.userinfo.getuserid());
        insert accRole;
        /*Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;*/
        
        Country_Groups__c countryGrp1 = new Country_Groups__c(Name = 'NewGrp',NameUnique__c ='UniqueNameTest');
        insert countryGrp1;
        
        Profile p = [select id from profile where name='System Administrator']; 
        User u = new User(alias = 'standt', email='testuser@testorg.com', 
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
        localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id);     
        insert u;
        
        Announcement_Rule__c newRule = new Announcement_Rule__c (Account__c = acctGoogle.Id,Announcement_Type__c ='NewType',DesignatedApprover__c =u.Id ,Country_Group__c = countryGrp1.Id, Report_ID__c = ReportTemp[0].Id, report_Template__c='ReportName', 
                                                                 Optional_Triggers__c = 'Abstract EIDR;Episode Number;EC Available Flag;Edit EIDR;Global Title', Schedule_Type__c = 'Monthly', Weekly_Monthly_Schedule_Days__c = '3', Schedule_Time__c = '1', Active__c = true);
        insert newRule;
        
        Test.startTest(); 
         
            PageReference pageRef = Page.WB_AnnouncementFormat;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', newRule.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(newRule);
            WB_AnnouncementFormatController controller = new WB_AnnouncementFormatController(sc);
        Test.stopTest();
            //system.assert(false, controller.getSelectedEmailTemp());
            controller.getSelectedEmailTemp();
            controller.getSelectedRepTemp();
            //system.assert(false, controller.rTemplateList);
        
            list<selectOption> oplist = controller.rTemplateList;
        	Controller.selectedRepTemplate =  Oplist[0].getvalue();
            //system.assertNotEquals('None', Oplist[0].getvalue());
            //system.assertEquals('NewReport',Oplist[0].getvalue());    
            controller.saveSelection();
            try{
            controller.defaultTemp();
            }catch(exception e){}
            WB_AnnouncementFormatController controller1 = new WB_AnnouncementFormatController();
        
        
        
    }
    
    @isTest(SeeAllData=true)   
    static void  announcementTypeforWeekly(){
        List<Report> ReportTemp = [SELECT id,Name FROM Report Where Name = 'WB Standard Combined' ];
            
        
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        Account_Role__c accRole = new Account_Role__c (Account__c = acctGoogle.id, role__c = 'Announcer', User__c = system.userinfo.getuserid());
        insert accRole;
        /*Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;*/
        
        Country_Groups__c countryGrp1 = new Country_Groups__c(Name = 'NewGrp',NameUnique__c ='UniqueNameTest');
        insert countryGrp1;
        
        Profile p = [select id from profile where name='System Administrator']; 
        User u = new User(alias = 'standt', email='testuser@testorg.com', 
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
        localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id);     
        insert u;
        
        Announcement_Rule__c newRule = new Announcement_Rule__c (Account__c = acctGoogle.Id,Announcement_Type__c ='NewType',DesignatedApprover__c =u.Id ,Country_Group__c = countryGrp1.Id, Report_ID__c = ReportTemp[0].Id, report_Template__c='ReportName', 
                                                                 Optional_Triggers__c = 'Abstract EIDR;Episode Number;EC Available Flag', Schedule_Type__c = 'Weekly', Weekly_Monthly_Schedule_Days__c = 'Monday', Schedule_Time__c = '1', Active__c = true);
        insert newRule;
        
        Test.startTest(); 
         
            PageReference pageRef = Page.WB_AnnouncementFormat;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', newRule.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(newRule);
            WB_AnnouncementFormatController controller = new WB_AnnouncementFormatController(sc);
        Test.stopTest();
            //system.assert(false, controller.getSelectedEmailTemp());
            controller.getSelectedEmailTemp();
            controller.getSelectedRepTemp();
            //system.assert(false, controller.rTemplateList);
        
            list<selectOption> oplist = controller.rTemplateList;
        	Controller.selectedRepTemplate =  Oplist[0].getvalue();
            //system.assertNotEquals('None', Oplist[0].getvalue());
            //system.assertEquals('NewReport',Oplist[0].getvalue());    
            controller.saveSelection();
            try{
            controller.defaultTemp();
            }catch(exception e){}
            WB_AnnouncementFormatController controller1 = new WB_AnnouncementFormatController();
        
        
        
    }
    
    
   //CH01
   
   
    /*@isTest(SeeAllData=true)
    static void myUnitTest4(){
        
        Test.startTest(); 
            
            WB_AnnouncementFormatController controller = new WB_AnnouncementFormatController();
            //system.assertEquals(controller.eTemplateList.size(),10);
            //system.assertNotEquals(controller.rTemplateList.size(),10);    
            controller.saveSelection();
            controller.defaultTemp();
        
        Test.stopTest(); 
     } */
     
     
    
}