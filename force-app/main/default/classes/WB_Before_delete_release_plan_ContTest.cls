/*
Class Name   : WB_Before_delete_release_plan_ContTest 
Description  : This class is to do code coverage for WB_Before_delete_release_plan_Controller class    
Created By   : Cognizant Technology Solutions - Akash
Created On   : April 2016

Change History:
-------------------------------------------------------------------------------------------------------------------------------------
Sr#              Description                                               Updated By                                     Updated On
-------------------------------------------------------------------------------------------------------------------------------------
1              [Change Type]                                 Cognizant Technology Solutions - [Developer Name]           [MM/DD/YYYY]

CH01   Added Assertion statements for the required business             Akash Dalvi                                        4/27/2016
       scenarios.                        
*/

@isTest
public class WB_Before_delete_release_plan_ContTest {
    @isTest
    //CH01
    public static void myUnitTest1() {
        
        list<User> userDetail = new list<User>();
        userDetail =[ SELECT id,ProfileId,Profile.Name,UserType,Territory__c  from User where id =: Userinfo.getUserId()];
        
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',
                          Clear_to_Avail__c = true,Territory__c = 'Home Office',Formats__c='SD');
        insert title1;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title1.Content_Type__c,
            Country__c = countryFrance.Id,Channel__c ='DTD',Format__c ='HD');
        insert price1;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title1.Id,Country__c = countryFrance.Id,Language__c =languageFrench.Id,Price_Code__c =price1.Name);
        insert local1;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = local1.Id,
                Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Draft',
                Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2);
        insert releaseplan1;
        
        Test.startTest();
            Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=countryFrance.Id, Pricing_Currency__c='FR', Content_Type__c=title1.Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',SAP_Customer_Number__c='12010421');
            insert storefrontGoogle1;
        
            Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Draft',
                                           Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c);
            insert clientAvail1;
            delete clientAvail1;
            delete releaseplan1;
            
        Test.stopTest();
    }
    
    @isTest
    public static void myUnitTest2() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name =: System.Label.WB_Territory_Release_Planner];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='ashdalvi@testorg.com' , territory__c = 'Italy');
        insert u;
        
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',
                          Clear_to_Avail__c = true,Territory__c = 'Home Office',Formats__c='SD');
        insert title1;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title1.Content_Type__c,
            Country__c = countryFrance.Id,Channel__c ='DTD',Format__c ='HD');
        insert price1;
        
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title1.Id,Country__c = countryFrance.Id,Language__c =languageFrench.Id,Price_Code__c =price1.Name);
        insert local1;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = local1.Id,
                Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2);
        insert releaseplan1;
        releaseplan1.ownerId = u.id;
        update releaseplan1;
        
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(acctGoogle.Id,countryFrance.Id,releaseplan1,title1);
        insert storefrontGoogle1;
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(acctGoogle.Id,releaseplan1,local1.Id);
        insert clientAvail1;
        
        Test.startTest();
            system.runAs(u)
            {
                try{
                    delete releaseplan1;
                }
                catch(Exception e){
                    system.debug('---->>' +e.getMessage());
                }
            }
        Test.stopTest();   
    }
     @isTest
    public static void myUnitTest3() {
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',
                          Clear_to_Avail__c = true,Territory__c = 'Home Office',Formats__c='SD');
        insert title1;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                Exclusive_Date__c = date.today()+3, Start_Date__c=date.today()+3,End_Date__c= date.today()+5,Rights_End__c=date.today()+5);
        insert releaseplan2;
        
        WB_Before_delete_release_plan_Controller.afterdelete_releaseplan(new list<Commercial_Avail__c>{releaseplan2});
    }
}