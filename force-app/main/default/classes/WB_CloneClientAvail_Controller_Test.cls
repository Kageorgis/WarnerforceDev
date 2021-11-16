/*
WB_CloneClientAvail_Controller_Test
Creation Date- 11 Nov 2014
Last Modified Date - 7th Jan
Last Modified by  - Navjyoti
Description- This class is to do code coverage WB_CloneClientAvail_Controller

*/


@isTest
private class WB_CloneClientAvail_Controller_Test
{
    static testMethod void CloneClientAvailChk() {
        
        list<Commercial_Avail__c> commercialAvailList = new List<Commercial_Avail__c>();
        list<Client_Avail__c> clientAvailListNew = new list<Client_Avail__c>();
        list<Title__c> titleList = new list<Title__c>();
        
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle', MPM__c = mpm.id,Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        //insert title1;
        titleList.add(title1);
        
        Title__c title2 = new Title__c(Name = 'TestApple', MPM__c = mpm.id,Video_Version__c ='6000047546',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        //insert title2;
        titleList.add(title2);
        insert titleList;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+6,Rights_End__c=date.today()+7);
        //insert releaseplan1;
        commercialAvailList.add(releaseplan1);
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(Title__c=title2.Id,Country_Lookup__c=countryFrance.Id,
                                                                Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+6,Rights_End__c=date.today()+7);
        //insert releaseplan2;
        commercialAvailList.add(releaseplan2);
        insert commercialAvailList;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                        Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        
        wizardRunFlag__c wzflg = new wizardRunFlag__c(name ='FlagValue',WizardFlag__c = 'False');
        insert wzflg;
        
        Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,Client__c=acctGoogle.Id,
                                                      Status__c='Draft',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=date.today()+1 );
        //insert clientAvail1;
        clientAvailListNew.add(clientAvail1);
        
        Client_Avail__c clientAvail2 = new Client_Avail__c(Commercial_Avail__c=releaseplan2.Id,                                                      
                                                      Client__c=acctGoogle.Id,                                                      
                                                      Status__c='Draft',Start_Date__c=releaseplan2.Start_Date__c,End_Date__c=date.today()+1 );
        //insert clientAvail2;
        clientAvailListNew.add(clientAvail2);
        
        Client_Avail__c clientAvail3 = new Client_Avail__c(Commercial_Avail__c=releaseplan2.Id,                                                      
                                                      Client__c=acctGoogle.Id,                                                      
                                                      Status__c='Draft',Start_Date__c=releaseplan2.Start_Date__c+3,End_Date__c=releaseplan2.Start_Date__c+4 );
        //insert clientAvail3;
        clientAvailListNew.add(clientAvail3);
        insert clientAvailListNew;
        
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        clientAvailList.add(clientAvail1);
        
        string str = clientAvail1.Id +','+clientAvail2.Id ;
        
    Test.startTest();
        PageReference pageRef = Page.WB_Clone_ClientAvail;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', str);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
        WB_CloneClientAvail_Controller controller = new WB_CloneClientAvail_Controller(sc);
        WB_CloneClientAvail_Controller.clientAvailwrapper wrap1 = new WB_CloneClientAvail_Controller.clientAvailwrapper();
        
        controller.obj.start_date__c= releaseplan1.Start_Date__c+3;
        controller.obj.end_date__c= releaseplan1.Start_Date__c+5;
        
        controller.CloneCheck();
        controller.Okbutton();
        controller.Bulkcancel();
    Test.stopTest();
    }
    
    static testmethod void deleteReleasePlan(){
        Test.startTest();
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        Title__c title1 = new Title__c(Name = 'TestGoogle', MPM__c = mpm.id,Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Draft',
                                                                Exclusive_Date__c = date.today()-1, Start_Date__c=date.today()+5,End_Date__c= date.today()+16,Rights_End__c=date.today()+17);
        insert releaseplan1;
        delete releaseplan1;
        Test.stopTest();
    }
}