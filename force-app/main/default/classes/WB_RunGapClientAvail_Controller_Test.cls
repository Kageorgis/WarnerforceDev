/******* 
WB_RunGapClientAvail_ControllerTest
Creation Date- 7 Nov 2014
Last Modified Date - 7th Jan
Last Modified by  - Navjyoti
Description- This class is to do code coverage WB_RunGapClientAvail_Controller
Author- Imran Hussain
*******/

@isTest 
private class WB_RunGapClientAvail_Controller_Test{
    
    static testMethod void RunGapClientAvailChk() {
        
        List<Account> accountList = new List<Account>();
        List<Title__c> titleList = new List<Title__c>();
        List<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c>();
        Id rtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(system.label.AccRecordType).getRecordTypeId();
        
        Account acctGoogle = new Account(Name='TestGoogle',RecordTypeId = rtypeId);
        accountList.add(acctGoogle);
        
        Account acctApple = new Account(Name='TestApple',RecordTypeId = rtypeId);
        accountList.add(acctApple);
        
        insert accountList;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c =true,Formats__c='SD');
        titleList.add(title1);
        
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='6000047546',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c =true,Formats__c='SD');
        titleList.add(title2);
        
        insert titleList;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c =1);
        insert languageFrench;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2);
        commercialAvailList.add(releaseplan1);
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(Title__c=title2.Id,Country_Lookup__c=countryFrance.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2);
        commercialAvailList.add(releaseplan2);
        
        insert commercialAvailList;
        
        List<Agreement__c> storefrontList = new List<Agreement__c>();
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                          Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        storefrontList.add(storefrontGoogle1);
        
        Agreement__c storefrontApple1 = new Agreement__c(Account__c=acctApple.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                         Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        storefrontList.add(storefrontApple1);
        insert storefrontList;
        
        wizardRunFlag__c wizflag = new wizardRunFlag__c(name = 'FlagValue',WizardFlag__c = 'false'); 
        insert wizflag;
        
        List<Client_Avail__c> clientAvailListNew = new List<Client_Avail__c>();
        
        Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,
                                                           Client__c=acctGoogle.Id,
                                                           Status__c='Draft',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c );
        clientAvailListNew.add(clientAvail1);
        
        Client_Avail__c clientAvail2 = new Client_Avail__c(Commercial_Avail__c=releaseplan2.Id,
                                                           Client__c=acctGoogle.Id,
                                                           Status__c='Draft',Start_Date__c=releaseplan2.Start_Date__c,End_Date__c=releaseplan2.End_Date__c );
        clientAvailListNew.add(clientAvail2);
        
        Client_Avail__c clientAvail3 = new Client_Avail__c(Commercial_Avail__c=releaseplan2.Id,
                                                           Client__c=acctApple.Id,
                                                           Status__c='Draft',Start_Date__c=releaseplan2.Start_Date__c,End_Date__c=releaseplan2.End_Date__c );
        clientAvailListNew.add(clientAvail3);
        insert clientAvailListNew;
        
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        clientAvailList.add(clientAvail1);
        clientAvailList.add(clientAvail2);
        
        string str = clientAvail1.Id +','+clientAvail2.Id ;
        
        Test.startTest();
        Profile p = [select id from profile where name='System Administrator']; 
        User u = new User(alias = 'standt', email='testuser@testorg.com', 
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                          localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id);     
        insert u;
        Id uid = u.Id;
        
        System.runAs(u){
            PageReference pageRef = Page.WB_RunGapAnalysis_ClientAvail;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',str);
            ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
            WB_RunGapClientAvail_Controller controller = new WB_RunGapClientAvail_Controller(sc);
            WB_RunGapClientAvail_Controller.clientAvailwrapper wrap1 = new WB_RunGapClientAvail_Controller.clientAvailwrapper();
            wrap1.clientAvail = clientAvail1;
            controller.obj.Client__c = acctApple.Id;
            controller.GapAnalysis();
            controller.Okbutton();
            controller.Bulkcancel();
        }
        Test.stopTest();
    }
}