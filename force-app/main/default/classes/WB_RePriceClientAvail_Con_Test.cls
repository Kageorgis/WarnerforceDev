@isTest(seeAllData=false)
private class WB_RePriceClientAvail_Con_Test{
    
    //Comment1 start
    
    @isTest
    static void checkReprice(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Available_Languages__c availLang = new Available_Languages__c(Title__c=title1.id,Language__c=languageFrench.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang ;
        
        Pricing__c objPricing = new Pricing__c(
            Name = 'Test',Account__c = acctGoogle.Id,Country__c = countryFrance.Id,Channel__c = 'DTD',Format__c = 'HD',
            Content_Type__c = 'Season',Effective_Date__c = date.today()-10,Episode_Price_Tier__c = '1',WS_Price__c = 215.50
        );
        insert objPricing;
        
        system.debug('objPricing ====: ' + objPricing);
        
        TestDataUtility objTestDataUtility = new TestDataUtility();
        Local_Title__c objLT = objTestDataUtility.createlocalTitle(countryFrance, languageFrench);
        objLT.Price_Code__c = '15AB';
        update objLT;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(
            Title__c=title1.Id, Country_Lookup__c=countryFrance.Id, Languages__c=languageFrench.Id, Channel__c='DTD',
            Format__c='HD', Language_Type__c='Sub',Status__c='Tentative', Exclusive_Date__c = date.today()-2,
            Start_Date__c=date.today()-1, End_Date__c= date.today()+15,Rights_End__c=date.today()+20, Local_Title__c = objLT.Id
        );
        insert releaseplan1;
        system.debug('releaseplan1 ===: ' + releaseplan1);
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
            Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1;
        
        Test.startTest();
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id, Start_Date__c=releaseplan1.Start_Date__c,
            Status__c='Draft', End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today(), Local_Title__c = objLT.Id
        );
        insert clientAvail1 ;
        system.debug('clientAvail1 ===: ' + [select Id, Local_Title__c from Client_Avail__c where Id =:clientAvail1.Id]);
        Client_Avail__c objCA = [select Id, Local_Title__c from Client_Avail__c where Id =:clientAvail1.Id];
        Local_Title__c objLocalTitle = [select Id, Price_Code__c from Local_Title__c where Id = :objCA.Local_Title__c];
        objLocalTitle.Price_Code__c = '55AB';
        update objLocalTitle;
        
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>{clientAvail1};
            
            Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'standt', email='testuser@testorg.com', emailencodingkey='UTF-8', lastname='Testing', profileid = p.Id,
            languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='superUser@testorg.com'
        );
        insert u;
        System.runAs(u){
            
            PageReference pageRef = Page.WB_RePrice_ClientAvails;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('ID', clientAvail1.Id);
            ApexPages.currentPage().getParameters().put('param', 'std');
            ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
            WB_RePriceClientAvails_Controller controller = new WB_RePriceClientAvails_Controller(sc);
            controller.obj.Effective_Price_Date__c = date.today();
            controller.obj.Price_Tier_Text__c = 'Price Tier Text';
            
            controller.datename = date.today()+5;
            controller.previousEndDate = date.today()-1;
            controller.obj.Use_Price_Codes__c = true;
            
            controller.updateprice(); 
            controller.deleteClientAvailRec(); 
            controller.Bulkcancel();
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void foundPriceCode(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Available_Languages__c availLang = new Available_Languages__c(Title__c=title1.id,Language__c=languageFrench.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang ;
        
        Pricing__c objPricing = new Pricing__c(
            Name = '55AB',Account__c = acctGoogle.Id,Country__c = countryFrance.Id,Channel__c = 'DTD',Format__c = 'HD',
            Content_Type__c = 'Season',Effective_Date__c = date.today()-10,Episode_Price_Tier__c = '1',WS_Price__c = 215.50
        );
        insert objPricing;
        
        system.debug('objPricing ====: ' + objPricing);
        
        TestDataUtility objTestDataUtility = new TestDataUtility();
        Local_Title__c objLT = objTestDataUtility.createlocalTitle(countryFrance, languageFrench);
        objLT.Price_Code__c = '55AB';
        update objLT;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(
            Title__c=title1.Id, Country_Lookup__c=countryFrance.Id, Languages__c=languageFrench.Id, Channel__c='DTD',
            Format__c='HD', Language_Type__c='Sub',Status__c='Tentative', Exclusive_Date__c = date.today()-2,
            Start_Date__c=date.today()-1, End_Date__c= date.today()+15,Rights_End__c=date.today()+20//, Local_Title__c = objLT[0].Id
        );
        insert releaseplan1;
        system.debug('releaseplan1 ===: ' + releaseplan1);
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
            Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1;
        Test.startTest();
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id, Start_Date__c=releaseplan1.Start_Date__c,
            Status__c='Draft', End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today(), Local_Title__c = objLT.Id
        );
        insert clientAvail1 ;
        
        Client_Avail__c objCA = [select Id, Local_Title__c from Client_Avail__c where Id =:clientAvail1.Id];
        system.debug('clientAvail1 ===: ' + objCA);
        
        Local_Title__c objLocalTitle = [select Id, Price_Code__c from Local_Title__c where Id = :objCA.Local_Title__c];
        objLocalTitle.Price_Code__c = '55AB';
        update objLocalTitle;
        releaseplan1.Local_Title__c = objLocalTitle.Id;
        
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>{clientAvail1};
            
            Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'standt', email='testuser@testorg.com', emailencodingkey='UTF-8', lastname='Testing', profileid = p.Id,
            languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='superUser@testorg.com'
        );
        insert u;
        System.runAs(u){
            
            PageReference pageRef = Page.WB_RePrice_ClientAvails;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('ID', clientAvail1.Id);
            ApexPages.currentPage().getParameters().put('param', 'std');
            ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
            WB_RePriceClientAvails_Controller controller = new WB_RePriceClientAvails_Controller(sc);
            controller.obj.Effective_Price_Date__c = date.today();
            controller.obj.Price_Tier_Text__c = 'Price Tier Text';
            
            controller.datename = date.today()+5;
            controller.previousEndDate = date.today()-1;
            controller.obj.Use_Price_Codes__c = true;
            
            controller.updateprice(); 
            controller.deleteClientAvailRec(); 
            controller.Bulkcancel();
            
            Test.stopTest();
        }
    }
    @isTest
    static void priceCodeNotFound(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Available_Languages__c availLang = new Available_Languages__c(Title__c=title1.id,Language__c=languageFrench.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang ;
        
        List<Pricing__c> lstPricing = new List<Pricing__c>();
        Pricing__c objPricing1 = new Pricing__c(
            Name = 'Test1',Account__c = acctGoogle.Id,Country__c = countryFrance.Id,Channel__c = 'DTD',Format__c = 'HD',
            Content_Type__c = 'Season',Effective_Date__c = date.today()-10,Episode_Price_Tier__c = '1',WS_Price__c = 215.50
        );
        //insert objPricing;
        lstPricing.add(objPricing1);
        
        Pricing__c objPricing2 = new Pricing__c(
            Name = 'Test2',Account__c = acctGoogle.Id,Country__c = countryFrance.Id,Channel__c = 'DTD',Format__c = 'HD',
            Content_Type__c = 'Season',Effective_Date__c = date.today()-10,Episode_Price_Tier__c = '1',WS_Price__c = 215.50
        );
        //insert objPricing;
        lstPricing.add(objPricing2);
        insert lstPricing;
        
        TestDataUtility objTestDataUtility = new TestDataUtility();
        Local_Title__c objLT = objTestDataUtility.createlocalTitle(countryFrance, languageFrench);
        objLT.Price_Code__c = '15AB';
        update objLT;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(
            Title__c=title1.Id, Country_Lookup__c=countryFrance.Id, Languages__c=languageFrench.Id, Channel__c='DTD',
            Format__c='HD', Language_Type__c='Sub',Status__c='Tentative', Exclusive_Date__c = date.today()-2,
            Start_Date__c=date.today()-1, End_Date__c= date.today()+15,Rights_End__c=date.today()+20, Local_Title__c = objLT.Id
        );
        insert releaseplan1;
        system.debug('releaseplan1 ===: ' + releaseplan1);
        
        Test.startTest();
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
            Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1;
        
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id, Start_Date__c=releaseplan1.Start_Date__c,
            Status__c='Draft', End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today()
        );
        insert clientAvail1 ;
        
        Client_Avail__c objCA = [select Id, Local_Title__c from Client_Avail__c where Id =:clientAvail1.Id];
        system.debug('clientAvail1 ===: ' + objCA);
        
        Local_Title__c objLocalTitle = [select Id, Price_Code__c from Local_Title__c where Id = :objCA.Local_Title__c];
        objLocalTitle.Price_Code__c = 'Test1';
        update objLocalTitle;
        //releaseplan1.Local_Title__c = objLocalTitle.Id;
        //update releaseplan1;
        
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>{clientAvail1};
            
            Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'standt', email='testuser@testorg.com', emailencodingkey='UTF-8', lastname='Testing', profileid = p.Id,
            languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='superUser@testorg.com'
        );
        insert u;
        System.runAs(u){
            
            PageReference pageRef = Page.WB_RePrice_ClientAvails;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('ID', clientAvail1.Id);
            ApexPages.currentPage().getParameters().put('param', 'std');
            ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
            WB_RePriceClientAvails_Controller controller = new WB_RePriceClientAvails_Controller(sc);
            controller.obj.Effective_Price_Date__c = date.today();
            controller.obj.Price_Tier_Text__c = 'Price Tier Text';
            
            controller.datename = date.today()+5;
            controller.previousEndDate = date.today()-1;
            controller.obj.Use_Price_Codes__c = true;
            
            controller.updateprice(); 
            controller.deleteClientAvailRec(); 
            controller.Bulkcancel();
            
        }
        Test.stopTest();
    }
    @isTest
    static void batchProcess(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Available_Languages__c availLang = new Available_Languages__c(Title__c=title1.id,Language__c=languageFrench.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang ;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(
            Title__c=title1.Id, Country_Lookup__c=countryFrance.Id, Languages__c=languageFrench.Id, Channel__c='DTD',
            Format__c='HD', Language_Type__c='Sub',Status__c='Tentative', Exclusive_Date__c = date.today()-2,
            Start_Date__c=date.today()-1, End_Date__c= date.today()+300,Rights_End__c=date.today()+300
        );
        insert releaseplan1;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
            Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1;
        
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id, Start_Date__c=releaseplan1.Start_Date__c,
            Status__c='Draft', End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today()
        );
        //insert clientAvail1 ;
        
        Test.startTest();
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();//{clientAvail1};
        
        Date startDate = releaseplan1.Start_Date__c;
        //Date End_Date = releaseplan1.End_Date__c;
        
        for(Integer i=1; i<=25; i++){
            
            Client_Avail__c objClientAvail = new Client_Avail__c(
                Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id, Status__c='Draft',
                Start_Date__c   = startDate,
                End_Date__c     = startDate.addDays(2),
                Effective_Price_Date__c=date.today()
            );
            clientAvailList.add(objClientAvail);
            startDate = startDate.addDays(4);
        }
        
        Database.saveResult[] srList = database.insert(clientAvailList);
        String ids = '';
        for(database.saveresult SR : srList){
            system.debug('*************** : ' + SR.isSuccess());
            ids = (ids == '') ? string.valueOf(SR.getId()) : (ids + ',' + string.valueOf(SR.getId()));
                }
        
        
        String uniqueId = Userinfo.getUserId() + '' + system.now().getTime();
        Client_Avail_Id_Store__c ClientAvailIdStore = new Client_Avail_Id_Store__c(
            Key__c = uniqueId,
            ID_Store__c = ids,
            Re_Price_User__c = Userinfo.getUserId()
        );
        insert ClientAvailIdStore;
        
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'standt', email='testuser@testorg.com', emailencodingkey='UTF-8', lastname='Testing', profileid = p.Id,
            languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='superUser@testorg.com'
        );
        insert u;
        System.runAs(u){
            PageReference pageRef = Page.WB_RePrice_ClientAvails;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('UNIQUEID', uniqueId);
            //ApexPages.currentPage().getParameters().put('param', 'std');
            ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
            WB_RePriceClientAvails_Controller controller = new WB_RePriceClientAvails_Controller(sc);
            controller.obj.Effective_Price_Date__c = date.today();
            controller.obj.Price_Tier_Text__c = 'Price Tier Text';
            
            controller.datename = date.today();
            controller.previousEndDate = date.today()-1;
            controller.obj.Use_Price_Codes__c = false;
            
            controller.updateprice(); 
            controller.deleteClientAvailRec(); 
            controller.Bulkcancel();
        }
        Test.stopTest();
    }
    
    @isTest
    static void outsideDateRange(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Available_Languages__c availLang = new Available_Languages__c(Title__c=title1.id,Language__c=languageFrench.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang ;
        
        Pricing__c objPricing = new Pricing__c(
            Name = 'Test',Account__c = acctGoogle.Id,Country__c = countryFrance.Id,Channel__c = 'DTD',Format__c = 'HD',
            Content_Type__c = 'Season',Effective_Date__c = date.today()-10,Episode_Price_Tier__c = '1',WS_Price__c = 215.50
        );
        insert objPricing;
        system.debug('objPricing ====: ' + objPricing);
        
        TestDataUtility objTestDataUtility = new TestDataUtility();
        Local_Title__c objLT = objTestDataUtility.createlocalTitle(countryFrance, languageFrench);
        objLT.Price_Code__c = '15AB';
        update objLT;
        
        Test.startTest();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(
            Title__c=title1.Id, Country_Lookup__c=countryFrance.Id, Languages__c=languageFrench.Id, Channel__c='DTD',
            Format__c='HD', Language_Type__c='Sub',Status__c='Tentative', Exclusive_Date__c = date.today()-2,
            Start_Date__c=date.today()-1, End_Date__c= date.today()+15,Rights_End__c=date.today()+20, Local_Title__c = objLT.Id
        );
        insert releaseplan1;
        system.debug('releaseplan1 ===: ' + releaseplan1);
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
            Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1;
        
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id, Start_Date__c=releaseplan1.Start_Date__c,
            Status__c='Draft', End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today(), Local_Title__c = objLT.Id
        );
        insert clientAvail1 ;
        system.debug('clientAvail1 ===: ' + [select Id, Local_Title__c from Client_Avail__c where Id =:clientAvail1.Id]);
        Client_Avail__c objCA = [select Id, Local_Title__c from Client_Avail__c where Id =:clientAvail1.Id];
        Local_Title__c objLocalTitle = [select Id, Price_Code__c from Local_Title__c where Id = :objCA.Local_Title__c];
        objLocalTitle.Price_Code__c = '55AB';
        update objLocalTitle;
        
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>{clientAvail1};
            
            Profile p = [select id from profile where name='System Administrator'];
        User u = new User(
            alias = 'standt', email='testuser@testorg.com', emailencodingkey='UTF-8', lastname='Testing', profileid = p.Id,
            languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles', username='superUser@testorg.com'
        );
        insert u;
        System.runAs(u){
            
            PageReference pageRef = Page.WB_RePrice_ClientAvails;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('ID', clientAvail1.Id);
            ApexPages.currentPage().getParameters().put('param', 'std');
            ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
            WB_RePriceClientAvails_Controller controller = new WB_RePriceClientAvails_Controller(sc);
            controller.obj.Effective_Price_Date__c = date.today()+22;
            controller.obj.Price_Tier_Text__c = 'Price Tier Text';
            
            controller.datename = clientAvail1.End_Date__c.addDays(10);
            controller.previousEndDate = date.today()-1;
            controller.obj.Use_Price_Codes__c = false;
            
            controller.updateprice(); 
            controller.deleteClientAvailRec(); 
            controller.Bulkcancel();
            
            Test.stopTest();
        }
    }
    @isTest
    static void checkReprice1(){
        
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        list<Client_Avail_Exception__c> lst_excepns = new list<Client_Avail_Exception__c>();  
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Available_Languages__c availLang = new Available_Languages__c(Title__c=title1.id,Language__c=languageFrench.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang ;
        
        Local_Title__c localTitle = new Local_Title__c(
            Num_Local_Episodes__c = 10,
            Country__c = countryFrance.Id,
            Language__c = languageFrench.Id,
            Category__c='Catalog',Price_Code__c = 'TestPrice1'
        );
        insert localTitle;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(
            Title__c=title1.Id,Local_Title__c =localTitle.Id,Country_Lookup__c=countryFrance.Id,
            Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub',Status__c='Tentative',
            Exclusive_Date__c = date.today()-2, Start_Date__c=date.today()-1,End_Date__c= date.today()+1,Rights_End__c=date.today()+2
        );
        insert releaseplan1;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
            Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421'
        );
        insert storefrontGoogle1;
        
        List<Pricing__c> lstPricing = new List<Pricing__c>();
        
        Pricing__c newPricerecord = new Pricing__c(
            Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Name = 'TestPrice1',Format__c='HD',
            SR_Per_Episode__c = 3456,Episode_Price_Tier__c = '2',Price_Tier__c = 'test',SR_Price__c = 2345,Channel__c='DTD'
        );
        //insert newPricerecord;
        
        lstPricing.add(newPricerecord);
        insert lstPricing;
        Test.startTest(); 
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id, Status__c='Confirmed',
            Price__c = 123, Start_Date__c=releaseplan1.Start_Date__c, Use_Price_Codes__c = true,
            End_Date__c=releaseplan1.End_Date__c, Effective_Price_Date__c=date.today()
        );
        insert clientAvail1 ;
        
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        clientAvailList.add(clientAvail1);
        
        Client_Avail_Exception__c  aval_excp1 = new Client_Avail_Exception__c (
            Name='test', Avail_End__c=date.today()+10,Avail_Start__c=date.today(),Channel__c='EST',
            Content_Type__c='Feature',Country__c='USA',Format__c='HD',Language__c='Eng', 
            Language_Type__c='Sub',Reason__c='test reason',Release_Plan_Number__c='01254',Status__c='Planned',
            Title__c='title',User_Detail__c='u.Id',Account__c='test account',Old_Price_Records__c = false
        );
        
        lst_excepns.add(aval_excp1); 
        insert aval_excp1;
        
        PageReference pageRef = Page.WB_RePrice_ClientAvails;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('ID', clientAvail1.Id);
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
        WB_RePriceClientAvails_Controller controller = new WB_RePriceClientAvails_Controller(sc);
        controller.obj = clientAvail1;
        controller.deleteClientAvailRec();    
        controller.updateprice(); 
        controller.Bulkcancel();
        Test.stopTest();
    }
    
    
    // Added below methods during ER-15.
    static testMethod void checkReprice2(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        Title__c title2 = new Title__c(Name = 'TestGoogle1',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title2;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Country__c country1 =new Country__c(Name ='TestFrance2',Country_Code2__c ='TR1',Country_Code__c='TF1');
        insert country1;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Available_Languages__c availLang = new Available_Languages__c(Title__c=title1.id,Language__c=languageFrench.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang;
        
        List<Local_Title__c> listLocalTitle=new List<Local_Title__c>();
        Local_Title__c lt1 = new Local_Title__c(
            Key__c = title2.Video_Version__c,
            Local_Title__c = 'TestTitle',
            Country__c = countryFrance.Id,
            Language__c = languageFrench.Id,
            Title__c = title2.id,
            Price_Code__c='test code'
        );
        insert lt1;        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c=lt1.id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan1;
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                          Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        
        Pricing__c pricingRecord = new Pricing__c(Country__c=countryFrance.Id,Name='test code',Account__c=acctGoogle.id,Format__c='HD',Channel__c='DTD',Content_Type__c='Season',Price_Tier__c='test Price tier');
        insert pricingRecord;
        for(Local_Title__c localTitle : [Select id,Price_Code__c from Local_Title__c])
        {
            localTitle.Price_Code__c='test code';
            listLocalTitle.add(localTitle);
        }
        update listLocalTitle;     
        listLocalTitle.clear();   
        
        Test.startTest(); 
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,Local_Title__c=lt1.id, Price_Tier_Text__c='test Price tier',                                                   
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Confirmed',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        clientAvailList.add(clientAvail1);
        Client_Avail__c clientAvail2 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,                                                    
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Tentative',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        
        
        clientAvailList.add(clientAvail2);
        Client_Avail__c clientAvail3 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id, Local_Title__c=lt1.id,                                                     
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Draft',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        
        
        clientAvailList.add(clientAvail3);
        insert clientAvailList;
        for(Local_Title__c localTitle : [Select id,Price_Code__c from Local_Title__c])
        {
            localTitle.Price_Code__c='test code';
            listLocalTitle.add(localTitle);
        }
        update listLocalTitle;
        clientAvailList[1].Price_Tier_Text__c='test Price tier';
        clientAvailList[1].Status__c='Confirmed';
        update clientAvailList;
        
        PageReference pageRef = Page.WB_RePrice_ClientAvails;
        Test.setCurrentPage(pageRef);
        String ids = clientAvailList[0].Id+','+clientAvailList[1].id+','+clientAvailList[2].id;
        ApexPages.currentPage().getParameters().put('ID',ids);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
        WB_RePriceClientAvails_Controller controller = new WB_RePriceClientAvails_Controller(sc);
        controller.obj.Effective_Price_Date__c = date.today();
        controller.obj.Price_Tier_Text__c = 'test Price tier';
        controller.updateprice(); 
        Test.stopTest();
    }
    
    //Pricing record deleted- ShekharComm1
    static testMethod void checkReprice3(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true, Formats__c='HD');
        insert title1;
        Title__c title2 = new Title__c(Name = 'TestGoogle1',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='Yes',Clear_to_Avail__c = true, Formats__c='SD');
        insert title2;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Country__c country1 =new Country__c(Name ='TestFrance2',Country_Code2__c ='TR1',Country_Code__c='TF1');
        insert country1;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Available_Languages__c availLang = new Available_Languages__c(Title__c=title1.id,Language__c=languageFrench.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang ;
        
        List<Local_Title__c> listLocalTitle=new List<Local_Title__c>();
        Local_Title__c lt1 = new Local_Title__c(
            Key__c = title2.Video_Version__c,
            Local_Title__c = 'TestTitle',
            Country__c = countryFrance.Id,
            Language__c = languageFrench.Id,
            Title__c = title2.id,
            Price_Code__c='test code'
        );
        insert lt1;        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c=lt1.id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan1;
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                          Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        
        Pricing__c pricingRecord = new Pricing__c(Country__c=countryFrance.Id,Name='test code',Account__c=acctGoogle.id,Format__c='HD',Channel__c='DTD',Content_Type__c='Season',Price_Tier__c=null);
        insert pricingRecord;
        for(Local_Title__c localTitle : [Select id,Price_Code__c from Local_Title__c])
        {
            localTitle.Price_Code__c='test code';
            listLocalTitle.add(localTitle);
        }
        update listLocalTitle;     
        listLocalTitle.clear();  
        
        Test.startTest(); 
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,Local_Title__c=lt1.id, Price_Tier_Text__c='test Price tier',                                                   
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Confirmed',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        clientAvailList.add(clientAvail1);
        Client_Avail__c clientAvail2 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,                                                    
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Tentative',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        
        
        clientAvailList.add(clientAvail2);
        Client_Avail__c clientAvail3 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id, Local_Title__c=lt1.id,                                                     
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Draft',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        
        
        clientAvailList.add(clientAvail3);
        insert clientAvailList;
        
        for(Local_Title__c localTitle : [Select id,Price_Code__c from Local_Title__c])
        {
            localTitle.Price_Code__c='test code';
            listLocalTitle.add(localTitle);
        }
        update listLocalTitle;
        clientAvailList[1].Price_Tier_Text__c='test Price tier';
        clientAvailList[1].Status__c='Confirmed';
        update clientAvailList;
        delete pricingRecord;
        
        PageReference pageRef = Page.WB_RePrice_ClientAvails;
        Test.setCurrentPage(pageRef);
        String ids = clientAvailList[0].Id+','+clientAvailList[1].id+','+clientAvailList[2].id;
        ApexPages.currentPage().getParameters().put('ID',ids);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
        WB_RePriceClientAvails_Controller controller = new WB_RePriceClientAvails_Controller(sc);
        controller.obj.Effective_Price_Date__c = date.today();
        controller.obj.Price_Tier_Text__c = 'test Price tier';
        controller.updateprice(); 
        Test.stopTest();
    }
    
    //Delete Pricing record and use Price Code is true // ShekharComm2
    static testMethod void checkReprice4(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='HD');
        insert title1;
        Title__c title2 = new Title__c(Name = 'TestGoogle1',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='Yes',Clear_to_Avail__c = true, Formats__c='SD');
        insert title2;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Country__c country1 =new Country__c(Name ='TestFrance2',Country_Code2__c ='TR1',Country_Code__c='TF1');
        insert country1;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Available_Languages__c availLang = new Available_Languages__c(Title__c=title1.id,Language__c=languageFrench.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang ;
        
        List<Local_Title__c> listLocalTitle=new List<Local_Title__c>();
        Local_Title__c lt1 = new Local_Title__c(
            Key__c = title2.Video_Version__c,
            Local_Title__c = 'TestTitle',
            Country__c = countryFrance.Id,
            Language__c = languageFrench.Id,
            Title__c = title2.id,
            Price_Code__c='test code'
        );
        insert lt1;        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c=lt1.id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan1;
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                          Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        
        Pricing__c pricingRecord = new Pricing__c(Country__c=countryFrance.Id,Name='test code',Account__c=acctGoogle.id,Format__c='HD',Channel__c='DTD',Content_Type__c='Season',Price_Tier__c='test Price tier');
        insert pricingRecord;
        for(Local_Title__c localTitle : [Select id,Price_Code__c from Local_Title__c])
        {
            localTitle.Price_Code__c='test code';
            listLocalTitle.add(localTitle);
        }
        update listLocalTitle;     
        listLocalTitle.clear();   
        
        Test.startTest(); 
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,Local_Title__c=lt1.id, Price_Tier_Text__c='test Price tier',                                                   
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Confirmed',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        clientAvailList.add(clientAvail1);
        Client_Avail__c clientAvail2 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,                                                    
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Tentative',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        
        
        clientAvailList.add(clientAvail2);
        Client_Avail__c clientAvail3 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id, Local_Title__c=lt1.id,                                                     
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Draft',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        
        
        clientAvailList.add(clientAvail3);
        insert clientAvailList;
        
        for(Local_Title__c localTitle : [Select id,Price_Code__c from Local_Title__c])
        {
            localTitle.Price_Code__c='test code';
            listLocalTitle.add(localTitle);
        }
        update listLocalTitle;
        clientAvailList[1].Price_Tier_Text__c='test Price tier';
        clientAvailList[1].Status__c='Confirmed';
        update clientAvailList;
        delete pricingRecord;
        PageReference pageRef = Page.WB_RePrice_ClientAvails;
        Test.setCurrentPage(pageRef);
        String ids = clientAvailList[0].Id+','+clientAvailList[1].id+','+clientAvailList[2].id;
        ApexPages.currentPage().getParameters().put('ID',ids);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
        WB_RePriceClientAvails_Controller controller = new WB_RePriceClientAvails_Controller(sc);
        controller.obj.Use_Price_Codes__c = true;
        controller.obj.Effective_Price_Date__c = date.today();
        controller.obj.Price_Tier_Text__c = 'test Price tier';
        controller.updateprice(); 
        Test.stopTest();
    }
    
    static testMethod void checkReprice4A(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='HD');
        insert title1;
        Title__c title2 = new Title__c(Name = 'TestGoogle1',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='Yes',Clear_to_Avail__c = true, Formats__c='SD');
        insert title2;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Country__c country1 =new Country__c(Name ='TestFrance2',Country_Code2__c ='TR1',Country_Code__c='TF1');
        insert country1;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Available_Languages__c availLang = new Available_Languages__c(Title__c=title1.id,Language__c=languageFrench.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang ;
        
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan1;
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                          Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        
        Pricing__c pricingRecord = new Pricing__c(Country__c=countryFrance.Id,Name='test code',Account__c=acctGoogle.id,Format__c='HD',Channel__c='DTD',Content_Type__c='Season',Price_Tier__c=null);
        insert pricingRecord;
        
        Test.startTest(); 
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id, Price_Tier_Text__c='test Price tier',                                                   
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Confirmed',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        clientAvailList.add(clientAvail1);
        Client_Avail__c clientAvail2 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,                                                    
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Tentative',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        
        
        clientAvailList.add(clientAvail2);
        Client_Avail__c clientAvail3 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,                                                    
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Draft',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        
        
        clientAvailList.add(clientAvail3);
        insert clientAvailList;
        
        clientAvailList[1].Price_Tier_Text__c='test Price tier';
        clientAvailList[1].Status__c='Confirmed';
        update clientAvailList;
        
        PageReference pageRef = Page.WB_RePrice_ClientAvails;
        Test.setCurrentPage(pageRef);
        String ids = clientAvailList[0].Id+','+clientAvailList[1].id+','+clientAvailList[2].id;
        ApexPages.currentPage().getParameters().put('ID',ids);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
        WB_RePriceClientAvails_Controller controller = new WB_RePriceClientAvails_Controller(sc);
        controller.obj.Use_Price_Codes__c = true;
        controller.obj.Effective_Price_Date__c = date.today();
        
        controller.updateprice(); 
        Test.stopTest();
    }
    
    static testMethod void checkReprice4B(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='HD');
        insert title1;
        Title__c title2 = new Title__c(Name = 'TestGoogle1',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='Yes',Clear_to_Avail__c = true, Formats__c='SD');
        insert title2;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Country__c country1 =new Country__c(Name ='TestFrance2',Country_Code2__c ='TR1',Country_Code__c='TF1');
        insert country1;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Available_Languages__c availLang = new Available_Languages__c(Title__c=title1.id,Language__c=languageFrench.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang ;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan1;
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                          Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        
        Pricing__c pricingRecord = new Pricing__c(Country__c=countryFrance.Id,Name='test code',Account__c=acctGoogle.id,Format__c='HD',Channel__c='DTD',Content_Type__c='Season',Price_Tier__c=null);
        insert pricingRecord;
        
        Test.startTest(); 
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id, Price_Tier_Text__c='test Price tier',                                                   
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Confirmed',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        clientAvailList.add(clientAvail1);
        Client_Avail__c clientAvail2 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,                                                    
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Tentative',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        
        
        clientAvailList.add(clientAvail2);
        Client_Avail__c clientAvail3 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,                                                    
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Draft',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        
        
        clientAvailList.add(clientAvail3);
        insert clientAvailList;
        
        clientAvailList[1].Price_Tier_Text__c='test Price tier';
        clientAvailList[1].Status__c='Confirmed';
        update clientAvailList;
        
        PageReference pageRef = Page.WB_RePrice_ClientAvails;
        Test.setCurrentPage(pageRef);
        String ids = clientAvailList[0].Id+','+clientAvailList[1].id+','+clientAvailList[2].id;
        ApexPages.currentPage().getParameters().put('ID',ids);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
        WB_RePriceClientAvails_Controller controller = new WB_RePriceClientAvails_Controller(sc);
        controller.obj.Effective_Price_Date__c = date.today();
        
        controller.updateprice(); 
        Test.stopTest();
    }
    //Comment1 end
    static testMethod void checkReprice4c(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='HD');
        insert title1;
        Title__c title2 = new Title__c(Name = 'TestGoogle1',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='Yes',Clear_to_Avail__c = true, Formats__c='SD');
        insert title2;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Country__c country1 =new Country__c(Name ='TestFrance2',Country_Code2__c ='TR1',Country_Code__c='TF1');
        insert country1;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Available_Languages__c availLang = new Available_Languages__c(Title__c=title1.id,Language__c=languageFrench.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang ;
        
        List<Local_Title__c> listLocalTitle=new List<Local_Title__c>();
        Local_Title__c lt1 = new Local_Title__c(
            Key__c = title1.Video_Version__c,
            Local_Title__c = 'TestTitle',
            Country__c = countryFrance.Id,
            Language__c = languageFrench.Id,
            Title__c = title1.id,
            Price_Code__c='55AB');
        
        listLocalTitle.add(lt1);
        
        Local_Title__c lt2 = new Local_Title__c(
            Key__c = title2.Video_Version__c,
            Local_Title__c = 'TestTitle2',
            Country__c = countryFrance.Id,
            Language__c = languageFrench.Id,
            Title__c = title2.id,
            Price_Code__c='55AB02');
        
        listLocalTitle.add(lt2);
        
        
        insert listLocalTitle;       
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = listLocalTitle[0].id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan1;
        
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = listLocalTitle[1].id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='SD',Language_Type__c='Sub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan2;
        
        
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                          Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        
        /*  List<Local_Title__c> ltlist = new list<Local_Title__c>();
For( Local_Title__c objLocalTitle : [select Id, Price_Code__c from Local_Title__c])
{ 
objLocalTitle.Price_Code__c = '55AB1';
ltlist.add(objLocalTitle);
}

update ltlist;*/
        
        Pricing__c pricingRecord = new Pricing__c(Country__c=countryFrance.Id,Name='55AB',Account__c=acctGoogle.id,Format__c='HD',Channel__c='DTD',Content_Type__c='Season',Price_Tier__c=Null);
        insert pricingRecord;
        
        Pricing__c pricingRecord1 = new Pricing__c(Country__c=countryFrance.Id,Name='55AB1',Account__c=acctGoogle.id,Format__c='SD',Channel__c='DTD',Content_Type__c='Season',Price_Tier__c=Null);
        insert pricingRecord1;
        
        Test.startTest(); 
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        Client_Avail__c clientAvail1 = new Client_Avail__c(Storefront__c = storefrontGoogle1.Id,Commercial_Avail__c=releaseplan1.Id, Price_Tier_Text__c='test Price tier',                                                   
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Confirmed',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        clientAvailList.add(clientAvail1);
        Client_Avail__c clientAvail2 = new Client_Avail__c(Storefront__c = storefrontGoogle1.Id,Commercial_Avail__c=releaseplan2.Id,                                                    
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Tentative',Start_Date__c=releaseplan2.Start_Date__c,End_Date__c=releaseplan2.End_Date__c ,Effective_Price_Date__c=date.today());
        
        
        clientAvailList.add(clientAvail2);
        /*Client_Avail__c clientAvail3 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,                                                      
Client__c=acctGoogle.Id,                                                      
Status__c='Draft',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());


clientAvailList.add(clientAvail3); */
        
        insert clientAvailList;
        
        PageReference pageRef = Page.WB_RePrice_ClientAvails;
        Test.setCurrentPage(pageRef);
        String ids = clientAvailList[0].Id+','+clientAvailList[1].id;
        ApexPages.currentPage().getParameters().put('ID',ids);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
        WB_RePriceClientAvails_Controller controller = new WB_RePriceClientAvails_Controller(sc);
        controller.obj.Use_Price_Codes__c = true;
        controller.obj.Effective_Price_Date__c = date.today();
        controller.updateprice(); 
        Test.stopTest();
    }
    
    
    //Comment2 start
    
    //Use PriceCode = true, pricing record not deleted , price code of local data different from price code in pricing record
    static testMethod void checkReprice5(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='HD');
        insert title1;
        Title__c title2 = new Title__c(Name = 'TestGoogle1',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='Yes',Clear_to_Avail__c = true, Formats__c='SD');
        insert title2;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Country__c country1 =new Country__c(Name ='TestFrance2',Country_Code2__c ='TR1',Country_Code__c='TF1');
        insert country1;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Available_Languages__c availLang = new Available_Languages__c(Title__c=title1.id,Language__c=languageFrench.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang ;
        
        List<Local_Title__c> listLocalTitle=new List<Local_Title__c>();
        Local_Title__c lt1 = new Local_Title__c(
            Key__c = title2.Video_Version__c,
            Local_Title__c = 'TestTitle',
            Country__c = countryFrance.Id,
            Language__c = languageFrench.Id,
            Title__c = title2.id,
            Price_Code__c='test code'
        );
        insert lt1;        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c=lt1.id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan1;
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                          Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        
        Pricing__c pricingRecord = new Pricing__c(Country__c=countryFrance.Id,Name='test code',Account__c=acctGoogle.id,Format__c='HD',Channel__c='DTD',Content_Type__c='Season',Price_Tier__c='test Price tier');
        insert pricingRecord;
        for(Local_Title__c localTitle : [Select id,Price_Code__c from Local_Title__c])
        {
            localTitle.Price_Code__c='test code';
            listLocalTitle.add(localTitle);
        }
        update listLocalTitle;     
        listLocalTitle.clear();   
        
        Test.startTest(); 
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,Local_Title__c=lt1.id, Price_Tier_Text__c='test Price tier',                                                   
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Confirmed',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        clientAvailList.add(clientAvail1);
        Client_Avail__c clientAvail2 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,                                                    
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Tentative',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        
        
        clientAvailList.add(clientAvail2);
        Client_Avail__c clientAvail3 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id, Local_Title__c=lt1.id,                                                     
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Draft',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        
        
        clientAvailList.add(clientAvail3);
        insert clientAvailList;
        
        for(Local_Title__c localTitle : [Select id,Price_Code__c from Local_Title__c])
        {
            localTitle.Price_Code__c='test code121232';
            listLocalTitle.add(localTitle);
        }
        update listLocalTitle;
        clientAvailList[1].Price_Tier_Text__c='test Price tier';
        clientAvailList[1].Status__c='Confirmed';
        update clientAvailList;
        update pricingRecord;
        PageReference pageRef = Page.WB_RePrice_ClientAvails;
        Test.setCurrentPage(pageRef);
        String ids = clientAvailList[0].Id+','+clientAvailList[1].id+','+clientAvailList[2].id;
        ApexPages.currentPage().getParameters().put('ID',ids);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
        WB_RePriceClientAvails_Controller controller = new WB_RePriceClientAvails_Controller(sc);
        controller.obj.Use_Price_Codes__c = true;
        controller.obj.Effective_Price_Date__c = date.today();
        controller.obj.Price_Tier_Text__c = 'test Price tier';
        controller.updateprice(); 
        Test.stopTest();
    }
    
    // 2 pricing records , one having matching price code as one present in local data and other not- shekharcomm3
    static testMethod void checkReprice6(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='HD');
        insert title1;
        Title__c title2 = new Title__c(Name = 'TestGoogle1',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='Yes',Clear_to_Avail__c = true, Formats__c='SD');
        insert title2;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Country__c country1 =new Country__c(Name ='TestFrance2',Country_Code2__c ='TR1',Country_Code__c='TF1');
        insert country1;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Available_Languages__c availLang = new Available_Languages__c(Title__c=title1.id,Language__c=languageFrench.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang ;
        
        List<Local_Title__c> listLocalTitle=new List<Local_Title__c>();
        Local_Title__c lt1 = new Local_Title__c(
            Key__c = title2.Video_Version__c,
            Local_Title__c = 'TestTitle',
            Country__c = countryFrance.Id,
            Language__c = languageFrench.Id,
            Title__c = title2.id,
            Price_Code__c='test code'
        );
        insert lt1;        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c=lt1.id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan1;
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                          Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        
        Pricing__c pricingRecord = new Pricing__c(Country__c=countryFrance.Id,Name='test code1',Account__c=acctGoogle.id,Format__c='HD',Channel__c='DTD',Content_Type__c='Season',Price_Tier__c='test Price tier');
        insert pricingRecord;
        Pricing__c pricingRecord1 = new Pricing__c(Country__c=countryFrance.Id,Name='test code',Account__c=acctGoogle.id,Format__c='SD',Channel__c='DTD',Content_Type__c='Season',Price_Tier__c='test Price tier');
        insert pricingRecord1;
        for(Local_Title__c localTitle : [Select id,Price_Code__c from Local_Title__c])
        {
            localTitle.Price_Code__c='test code';
            listLocalTitle.add(localTitle);
        }
        update listLocalTitle;     
        listLocalTitle.clear();   
        
        Test.startTest(); 
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,Local_Title__c=lt1.id, Price_Tier_Text__c='test Price tier',                                                   
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Confirmed',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        clientAvailList.add(clientAvail1);
        Client_Avail__c clientAvail2 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,                                                    
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Tentative',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        
        
        clientAvailList.add(clientAvail2);
        Client_Avail__c clientAvail3 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id, Local_Title__c=lt1.id,                                                     
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Draft',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        
        
        clientAvailList.add(clientAvail3);
        insert clientAvailList;
        
        for(Local_Title__c localTitle : [Select id,Price_Code__c from Local_Title__c])
        {
            localTitle.Price_Code__c='test code';
            listLocalTitle.add(localTitle);
        }
        update listLocalTitle;
        clientAvailList[1].Price_Tier_Text__c='test Price tier';
        clientAvailList[1].Status__c='Confirmed';
        update clientAvailList;
        PageReference pageRef = Page.WB_RePrice_ClientAvails;
        Test.setCurrentPage(pageRef);
        String ids = clientAvailList[0].Id+','+clientAvailList[1].id+','+clientAvailList[2].id;
        ApexPages.currentPage().getParameters().put('ID',ids);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
        WB_RePriceClientAvails_Controller controller = new WB_RePriceClientAvails_Controller(sc);
        controller.obj.Use_Price_Codes__c = true;
        controller.obj.Effective_Price_Date__c = date.today();
        controller.obj.Price_Tier_Text__c = 'test Price tier';
        controller.updateprice(); 
        Test.stopTest();
    }
    
    
    static testMethod void checkReprice7(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='HD');
        insert title1;
        Title__c title2 = new Title__c(Name = 'TestGoogle1',Video_Version__c ='6000047546',Content_Type__c='Feature',Digital_Planning__c='Yes',Clear_to_Avail__c = true, Formats__c='SD');
        insert title2;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Country__c country1 =new Country__c(Name ='TestFrance2',Country_Code2__c ='TR1',Country_Code__c='TF1');
        insert country1;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Available_Languages__c availLang = new Available_Languages__c(Title__c=title1.id,Language__c=languageFrench.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang ;
        
        Available_Languages__c availLang1 = new Available_Languages__c(Title__c=title2.id,Language__c=languageFrench.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang1;
        
        List<Local_Title__c> listLocalTitle=new List<Local_Title__c>();
        Local_Title__c lt1 = new Local_Title__c(
            Key__c = title1.Video_Version__c,
            Local_Title__c = 'TestTitle',
            Country__c = countryFrance.Id,
            Language__c = languageFrench.Id,
            Title__c = title1.id
            //Price_Code__c='test code'
        );
        
        listLocalTitle.add(lt1);
        Local_Title__c lt2 = new Local_Title__c(
            Key__c = title2.Video_Version__c,
            Local_Title__c = 'TestTitle',
            Country__c = countryFrance.Id,
            Language__c = languageFrench.Id,
            Title__c = title2.id,
            Price_Code__c='test code'
        );
        listLocalTitle.add(lt2);
        insert listLocalTitle;        
        
        List<Commercial_Avail__c> lisReleaseplan = new List<Commercial_Avail__c>();
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c=lt1.id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Sub',Status__c='Confirmed',
                                                                   Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        lisReleaseplan.add(releaseplan1);
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(Title__c=title2.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c=lt2.id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Sub',Status__c='Confirmed',
                                                                   Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        lisReleaseplan.add(releaseplan2);
        
        insert lisReleaseplan;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                          Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        
        List<Pricing__c> listPricing = new List<Pricing__c>();
        Pricing__c pricingRecord = new Pricing__c(Country__c=countryFrance.Id,Name='test code 1',Account__c=acctGoogle.id,Format__c='HD',Channel__c='EST',Content_Type__c='Feature',Price_Tier__c='test Price tier 1');
        listPricing.add(pricingRecord);
        Pricing__c pricingRecord1 = new Pricing__c(Country__c=countryFrance.Id,Name='test code',Account__c=acctGoogle.id,Format__c='HD',Channel__c='EST',Content_Type__c='Feature',Price_Tier__c='test Price tier 2');
        listPricing.add(pricingRecord1);
        insert listPricing;
        test.startTest();
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,Local_Title__c=lt1.id, Price_Tier_Text__c='test Price tier 1',                                                   
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Confirmed',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        clientAvailList.add(clientAvail1);
        Client_Avail__c clientAvail2 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,    Price_Tier_Text__c='test Price tier 1',                                                 
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Draft',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        
        
        clientAvailList.add(clientAvail2);
        Client_Avail__c clientAvail3 = new Client_Avail__c(Commercial_Avail__c=releaseplan2.Id, Price_Tier_Text__c='test Price tier 1',                                                    
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Tentative',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        
        
        clientAvailList.add(clientAvail3);
        insert clientAvailList;
        
        PageReference pageRef = Page.WB_RePrice_ClientAvails;
        Test.setCurrentPage(pageRef);
        String ids = clientAvailList[0].Id+','+clientAvailList[1].id+','+clientAvailList[2].id;
        ApexPages.currentPage().getParameters().put('ID',ids);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
        WB_RePriceClientAvails_Controller controller = new WB_RePriceClientAvails_Controller(sc);
        controller.obj.Use_Price_Codes__c = true;
        controller.obj.Effective_Price_Date__c = date.today();
        controller.obj.Price_Tier_Text__c = 'test Price tier 2';
        controller.updateprice(); 
        Test.stopTest();
    }
    
    
    static testMethod void checkReprice8(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='HD');
        insert title1;
        Title__c title2 = new Title__c(Name = 'TestGoogle1',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='Yes',Clear_to_Avail__c = true, Formats__c='SD');
        insert title2;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Country__c country1 =new Country__c(Name ='TestFrance2',Country_Code2__c ='TR1',Country_Code__c='TF1');
        insert country1;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Available_Languages__c availLang = new Available_Languages__c(Title__c=title1.id,Language__c=languageFrench.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang ;
        
        Available_Languages__c availLang1 = new Available_Languages__c(Title__c=title2.id,Language__c=languageFrench.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang1 ;
        
        List<Local_Title__c> listLocalTitle=new List<Local_Title__c>();
        Local_Title__c lt1 = new Local_Title__c(
            Key__c = title1.Video_Version__c,
            Local_Title__c = 'TestTitle',
            Country__c = countryFrance.Id,
            Language__c = languageFrench.Id,
            Title__c = title1.id
            //Price_Code__c='test code'
        );
        
        listLocalTitle.add(lt1);
        Local_Title__c lt2 = new Local_Title__c(
            Key__c = title2.Video_Version__c,
            Local_Title__c = 'TestTitle',
            Country__c = countryFrance.Id,
            Language__c = languageFrench.Id,
            Title__c = title2.id,
            Price_Code__c='test code'
        );
        listLocalTitle.add(lt2);
        insert listLocalTitle;        
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c=lt1.id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Sub',Status__c='Confirmed',
                                                                   Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan1;
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(Title__c=title2.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c=lt2.id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Sub',Status__c='Confirmed',
                                                                   Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan2;
        
        
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                          Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        
        Pricing__c pricingRecord = new Pricing__c(Country__c=countryFrance.Id,Name='test code 1',Account__c=acctGoogle.id,Format__c='HD',Channel__c='EST',Content_Type__c='Season',Price_Tier__c='test Price tier 1');
        insert pricingRecord;
        Pricing__c pricingRecord1 = new Pricing__c(Country__c=countryFrance.Id,Name='test code',Account__c=acctGoogle.id,Format__c='HD',Channel__c='EST',Content_Type__c='Season',Price_Tier__c='test Price tier 2');
        insert pricingRecord1;
        
        Test.startTest(); 
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,Local_Title__c=lt1.id, Price_Tier_Text__c='test Price tier 1',                                                   
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Confirmed',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        clientAvailList.add(clientAvail1);
        Client_Avail__c clientAvail2 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,    Price_Tier_Text__c='test Price tier 1',                                                 
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Draft',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        
        
        clientAvailList.add(clientAvail2);
        Client_Avail__c clientAvail3 = new Client_Avail__c(Commercial_Avail__c=releaseplan2.Id, Price_Tier_Text__c='test Price tier 1',                                                    
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Tentative',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        
        
        clientAvailList.add(clientAvail3);
        insert clientAvailList;
        
        clientAvail1.Price_Tier_Text__c='test Price tier 1';
        update clientAvail1;
        
        PageReference pageRef = Page.WB_RePrice_ClientAvails;
        Test.setCurrentPage(pageRef);
        String ids = clientAvailList[0].Id+','+clientAvailList[1].id+','+clientAvailList[2].id;
        ApexPages.currentPage().getParameters().put('ID',ids);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
        WB_RePriceClientAvails_Controller controller = new WB_RePriceClientAvails_Controller(sc);
        controller.obj.Use_Price_Codes__c = true;
        controller.obj.Effective_Price_Date__c = date.today();
        controller.obj.Price_Tier_Text__c = 'test Price tier 3';
        controller.updateprice(); 
        Test.stopTest();
    }
    
    static testMethod void checkReprice9(){
        
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='HD');
        insert title1;
        Title__c title2 = new Title__c(Name = 'TestGoogle1',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='Yes',Clear_to_Avail__c = true, Formats__c='SD');
        insert title2;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Country__c country1 =new Country__c(Name ='TestFrance2',Country_Code2__c ='TR1',Country_Code__c='TF1');
        insert country1;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Available_Languages__c availLang = new Available_Languages__c(Title__c=title1.id,Language__c=languageFrench.id,Clear_to_Avail__c=true,Language_Types__c='Sub');
        insert availLang ;
        
        List<Local_Title__c> listLocalTitle=new List<Local_Title__c>();
        Local_Title__c lt1 = new Local_Title__c(
            Key__c = title2.Video_Version__c,
            Local_Title__c = 'TestTitle',
            Country__c = countryFrance.Id,
            Language__c = languageFrench.Id,
            Title__c = title2.id,
            Price_Code__c='test code'
        );
        insert lt1;        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c=lt1.id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan1;
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                          Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        
        Pricing__c pricingRecord = new Pricing__c(Country__c=countryFrance.Id,Name='test code',Account__c=acctGoogle.id,Format__c='HD',Channel__c='DTD',Content_Type__c='Season',Price_Tier__c='test Price tier');
        insert pricingRecord;
        for(Local_Title__c localTitle : [Select id,Price_Code__c from Local_Title__c])
        {
            localTitle.Price_Code__c='test code';
            listLocalTitle.add(localTitle);
        }
        update listLocalTitle;     
        listLocalTitle.clear();   
        
        Test.startTest(); 
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,Local_Title__c=lt1.id, Price_Tier_Text__c='test Price tier',                                                   
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Confirmed',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        clientAvailList.add(clientAvail1);
        Client_Avail__c clientAvail2 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,                                                    
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Tentative',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        
        
        clientAvailList.add(clientAvail2);
        Client_Avail__c clientAvail3 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id, Local_Title__c=lt1.id,                                                     
                                                           Client__c=acctGoogle.Id,                                                      
                                                           Status__c='Draft',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        
        
        clientAvailList.add(clientAvail3);
        insert clientAvailList;
        for(Local_Title__c localTitle : [Select id,Price_Code__c from Local_Title__c])
        {
            localTitle.Price_Code__c='test code';
            listLocalTitle.add(localTitle);
        }
        update listLocalTitle;
        clientAvailList[1].Price_Tier_Text__c='test Price tier';
        clientAvailList[1].Status__c='Confirmed';
        update clientAvailList;
        
        PageReference pageRef = Page.WB_RePrice_ClientAvails;
        Test.setCurrentPage(pageRef);
        String ids = clientAvailList[0].Id+','+clientAvailList[1].id+','+clientAvailList[2].id;
        ApexPages.currentPage().getParameters().put('ID',ids);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(clientAvailList);
        WB_RePriceClientAvails_Controller controller = new WB_RePriceClientAvails_Controller(sc);
        controller.obj.Effective_Price_Date__c = date.today();
        controller.obj.Price_Tier_Text__c = 'Price Tier Text';
        controller.updateprice(); 
        controller.Bulkcancel();
        controller.obj.Effective_Price_Date__c = date.today()-1;
        controller.obj.Price_Tier_Text__c = 'Price Tier Text1';
        controller.obj.Use_Price_Codes__c = true;
        controller.updateprice(); 
        Test.stopTest();
        
    }
    // END ER-15
    
    //Comment2 end
    
}