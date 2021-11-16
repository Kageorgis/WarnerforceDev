@isTest
private class WB_SplitReleaseplanController_Test{
    static testMethod void splitReleasPlan(){
        
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        // create MPM 
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        Title__c title1 = new Title__c(Name = 'TestGoogle',MPM__c=mpm.id,Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ');
        insert countryJapan;
        Country__c countryUsa =new Country__c(Name ='TestUsa',Country_Code2__c ='US',Country_Code__c='TH');
        insert countryUsa ;
        Country__c countryIndia =new Country__c(Name ='TestIndia1',Country_Code2__c ='IN',Country_Code__c='TI');
        insert countryIndia;   
        Country__c countryPakistan =new Country__c(Name ='TestPakistan',Country_Code2__c ='PK',Country_Code__c='PN');
        insert countryPakistan ;
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        list<Commercial_Avail__c> RPlist = new list<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, UPC__c='test23',Start_Date__c=date.today(),RP_Split_Date__c = date.today()+1,End_Date__c= date.today()+2,Rights_End__c=date.today()+3);
        //insert releaseplan1;
        RPList.add(releaseplan1);
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryJapan.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, UPC__c='test23',Start_Date__c=date.today()+2,End_Date__c= date.today()+3,Rights_End__c=date.today()+3);
        //insert releaseplan2;
        RPList.add(releaseplan2);
        Commercial_Avail__c releaseplan3 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryUsa.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-2, UPC__c='test23',Start_Date__c=date.today()-1,End_Date__c= date.today(),Rights_End__c=date.today()+3);
        //insert releaseplan3;
        RPList.add(releaseplan3);
        Commercial_Avail__c releaseplan4 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryIndia.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='SD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()+2, UPC__c='test23',Start_Date__c=date.today()+3,End_Date__c= date.today()+4,Rights_End__c=date.today()+5);
        //insert releaseplan4;
        RPList.add(releaseplan4);
        
        Commercial_Avail__c releaseplan5 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryPakistan.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1,UPC__c='test23', Start_Date__c=date.today(),End_Date__c= date.today()+2,Rights_End__c=date.today()+3);
        //insert releaseplan5;
        RPList.add(releaseplan5);
        insert RPList;
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryPakistan.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                          Channel_Picklist__c = releaseplan5.Channel__c,Format__c=releaseplan5.Format__c,Status__c = 'Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;  
        Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan5.Id,Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Draft',Start_Date__c=date.today(),End_Date__c = date.today()+2 );
        insert clientAvail1 ;
        string CommIds = releaseplan1.Id +','+releaseplan2.Id +','+releaseplan3.Id+','+releaseplan4.Id+','+releaseplan5.Id;
        
        Test.startTest(); 
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'standt', email='testuser@testorg.com', 
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                          localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id);
        
        insert u;
        Release_Plan_Exceptions__c excep1 = new Release_Plan_Exceptions__c(Name = 'XYZ',User_Detail__c = u.Id);
        insert excep1;
        Batch_Ids_Customsetting__c batch1 = new Batch_Ids_Customsetting__c(Name ='xyz',RP_Batch_Id__c ='0');
        insert batch1;
        
        system.runAs(u){            
            PageReference pageRef = Page.WB_SplitReleaseplanPage;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('ID', CommIds);
            ApexPages.StandardSetController sc = new ApexPages.StandardSetController(RPlist);
            WB_SplitReleaseplanController controller = new WB_SplitReleaseplanController (sc);
            controller.obj = releaseplan1;
            controller.splitReleasePlan();
            controller.Bulkcancel();
        }
        Test.stopTest();          
    }
    static testMethod void splitReleasPlan2(){
        
        // create MPM 
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        Title__c title1 = new Title__c(Name = 'TestGoogle',MPM__c=mpm.id,Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        Country__c countryItly =new Country__c(Name ='TestItly',Country_Code2__c ='IT',Country_Code__c='TL');
        insert countryItly ; 
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        Commercial_Avail__c releaseplan6 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryItly.Id,Reason_Code__c ='No digital rights',
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='SD',Language_Type__c='Dub',Status__c='Not Releasing',
                                                                   Start_Date__c=date.today()+3,End_Date__c= date.today()+4,RP_Split_Date__c = date.today()+1);
        insert releaseplan6;        
        
        list<Commercial_Avail__c> RPlist = new list<Commercial_Avail__c>();
        RPlist.add(releaseplan6);
        
        string CommIds = releaseplan6.Id;
        
        Test.startTest();
        PageReference pageRef = Page.WB_SplitReleaseplanPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('ID', CommIds);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(RPlist);
        WB_SplitReleaseplanController controller = new WB_SplitReleaseplanController (sc);
        
        controller.obj = releaseplan6;
        controller.splitReleasePlan();         
        Test.stopTest();
        
    }
    static testMethod void splitRedirect(){
        Test.startTest();
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'standt', email='testuser@testorg.com', 
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                          localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id);
        
        insert u;
        Release_Plan_Exceptions__c excep1 = new Release_Plan_Exceptions__c(Name = 'XYZ',User_Detail__c = u.Id,Old_RP_Records__c = true);
        insert excep1;
        Release_Plan_Exceptions__c excep2 = new Release_Plan_Exceptions__c(Name = 'XYZ',User_Detail__c = u.Id,Old_RP_Records__c = false);
        insert excep2;
        string expId = excep1.Id+','+excep2.Id ;
        
        system.runAs(u)
        {
            
            PageReference pageRef = Page.WB_SplitRP_Redirect;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('ID', expId);
            ApexPages.StandardController sc = new ApexPages.StandardController(excep1);
            WB_SplitRP_Redirect_Controller controller = new WB_SplitRP_Redirect_Controller (sc);
            controller.okbutton();         
        }
        Test.stopTest();
        
    }
    
    static testMethod void deleteRPSplitRec(){
        Test.startTest();
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(alias = 'standt', email='testuser@testorg.com', 
                          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                          localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='superUser@testorg.com',profileid = p.Id);       
        insert u;
        
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        Title__c title1 = new Title__c(Name = 'TestGoogle',MPM__c=mpm.id,Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        Country__c countryItly =new Country__c(Name ='TestItly',Country_Code2__c ='IT',Country_Code__c='TL');
        insert countryItly ; 
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        Commercial_Avail__c releaseplan = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryItly.Id,Reason_Code__c ='No digital rights',
                                                                  Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='SD',Language_Type__c='Dub',Status__c='Not Releasing',
                                                                  Start_Date__c=date.today()+3,End_Date__c= date.today()+4,RP_Split_Date__c = null);
        insert releaseplan;    
        list<Commercial_Avail__c> rplist = new list<Commercial_Avail__c>();
        rplist.add(releaseplan);
        string CommIds = releaseplan.Id;
        Release_Plan_Exceptions__c excep1 = new Release_Plan_Exceptions__c(Name = 'XYZ',User_Detail__c = u.Id,Old_RP_Records__c = true);
        insert excep1;
        system.runAs(u)
        {
            ApexPages.currentPage().getParameters().put('ID', CommIds);
            ApexPages.StandardSetController sc = new ApexPages.StandardSetController(rplist);
            WB_SplitReleaseplanController controller = new WB_SplitReleaseplanController (sc);
            controller.splitReleasePlan();
            controller.deleteRPSplitRec();         
        }
        Test.stopTest();        
    }    
}