/* Class covers the coverage for WB_Update_Price_Tier_Handler and WB_TriggerHandlerCountClientAvail(Errors occuers in triggers)*/

@isTest
private class WB_Update_Price_Tier_Handler_Test
{
    
   static testMethod void callService(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;

        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        Title__c title2 = new Title__c(Name = 'TestGoogle1',Video_Version__c ='6000047546',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
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
            Price_Code__c='test code'
        );
        insert lt1;        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c=lt1.id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub',Status__c='Tentative',
                                                                    Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan1;
        system.debug('******releaseplan1 : '+releaseplan1);
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                            Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        
        Pricing__c pricingRecord = new Pricing__c(Country__c=countryFrance.Id,Name='test code',Account__c=acctGoogle.id,Format__c='HD',Channel__c='DTD',Content_Type__c='Feature',Price_Tier__c='test');
        insert pricingRecord;
        for(Local_Title__c localTitle : [Select id,Price_Code__c from Local_Title__c])
        {
            localTitle.Price_code__c='test code';
            listLocalTitle.add(localTitle);
        }
        update listLocalTitle;     
        listLocalTitle.clear();   
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,Price_Tier_Text__c='test',                                                   
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
       
        test.starttest();
        WB_Update_Price_Tier_Handler.updateSingleClientAvailPriceTier(clientAvailList[0].id);
        WB_Update_Price_Tier_Handler.updateSingleClientAvailPriceTier(null);
        pricingRecord.Country__c = null;
        try
        {
            clientAvailList[0].Price_Tier_Text__c = 'test code 1234';
            update clientAvailList;
            delete [select id from Pricing__c];
            clientAvailList[0].Price_Tier_Text__c = 'test code 1234';
            update clientAvailList;
        }
        catch(Exception e)
        {
            Boolean flag = e.getmessage().contains(Label.WB_Price_Tier_Value_Not_Matching);
            //system.assertequals(true,flag);
        }
        test.stoptest();
    }
    
    static testMethod void CoverTriggerValidation1(){
        
        test.starttest();
        
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Country__c countryFrance =new Country__c(Name ='USA',Country_Code2__c ='US',Country_Code__c='USA');
        insert countryFrance;
        
        Language__c languageFrench = new Language__c(Name='English',Language_Order__c = 1);
        insert languageFrench;
        
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=languageFrench.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        insert availLangTitle1;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                        Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub',Status__c='Tentative',
                                                                        Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan1;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='US',Content_Type__c=title1.Content_Type__c,
                                                            Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        try
        {
            Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,Price_Tier_Text__c='test code123',                                                   
                                                          Client__c=acctGoogle.Id,                                                      
                                                          Status__c='Confirmed',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
            insert clientAvail1;
        }
        catch(Exception e)
        {
            system.debug('CoverTriggerValidation1 : e.getmessage() :'+e.getmessage());
            Boolean flag = e.getmessage().contains(Label.WB_Pricing_Record_Not_Available);
            system.assertequals(true,flag);
        }
        
        Test.stopTest();
    }
    
    static testMethod void CoverTriggerValidation2(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;

        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        Local_Title__c lt1 = new Local_Title__c(
            Key__c = title1.Video_Version__c,
            Local_Title__c = 'TestTitle',
            Country__c = countryFrance.Id,
            Language__c = languageFrench.Id,
            Title__c = title1.id,
            Price_Code__c='test code'
        );
        insert lt1;
        
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=languageFrench.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        insert availLangTitle1;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                        Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub',Status__c='Tentative',
                                                                        Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan1;
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                            Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        Pricing__c pricingRecord = new Pricing__c(Country__c=countryFrance.Id,Name='test code',Account__c=acctGoogle.id,Format__c='HD',Channel__c='DTD',Content_Type__c='Feature',Price_Tier__c='test Price tier');
        insert pricingRecord;
        try
        {
            Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,Local_Title__c=lt1.id, Price_Tier_Text__c='test code',                                                   
                                                          Client__c=acctGoogle.Id,                                                      
                                                          Status__c='Confirmed',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
            insert clientAvail1;
            //delete pricingRecord;
            clientAvail1.Price_Tier_Text__c = 'wrong price tier value';
            update clientAvail1; 
        }
        catch(Exception e)
        {
            system.debug('CoverTriggerValidation2 : e.getmessage() :'+e.getmessage());
            Boolean flag = e.getmessage().contains(Label.WB_Price_Tier_Value_Not_Matching);
            //system.assertequals(true,flag);
        }
    }
    
    static testMethod void CoverTriggerValidation3(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;

        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        Local_Title__c lt1 = new Local_Title__c(
            Key__c = title1.Video_Version__c,
            Local_Title__c = 'TestTitle',
            Country__c = countryFrance.Id,
            Language__c = languageFrench.Id,
            Title__c = title1.id,
            Price_Code__c='test code'
        );
        insert lt1;
        
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=languageFrench.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        insert availLangTitle1;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                        Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub',Status__c='Tentative',
                                                                        Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan1;
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                            Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        try
        {
            Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,Local_Title__c=lt1.id, Price_Tier_Text__c='test code',                                                   
                                                          Client__c=acctGoogle.Id,                                                      
                                                          Status__c='Confirmed',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
            insert clientAvail1;
        }
        catch(Exception e)
        {
            system.debug('CoverTriggerValidation3 : e.getmessage() :'+e.getmessage());
            Boolean flag = e.getmessage().contains(Label.WB_Pricing_Record_Not_Available);
            system.assertequals(true,flag);
        }
    }
    
    static testMethod void CoverTriggerValidation4(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;

        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        Local_Title__c lt1 = new Local_Title__c(
            Key__c = title1.Video_Version__c,
            Local_Title__c = 'TestTitle',
            Country__c = countryFrance.Id,
            Language__c = languageFrench.Id,
            Title__c = title1.id
        );
        insert lt1;
        
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=languageFrench.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        insert availLangTitle1;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c=lt1.id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub',Status__c='Tentative',
                                                                    Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan1;
        system.debug('******releaseplan1 : '+releaseplan1);
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                            Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        
        Pricing__c pricingRecord1 = new Pricing__c(Country__c=countryFrance.Id,Name='test code1',Account__c=acctGoogle.id,Format__c='HD',Channel__c='DTD',Content_Type__c='Feature',Price_Tier__c='test1');
        insert pricingRecord1;

  
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,Price_Tier_Text__c='test',                                                   
                                                          Client__c=acctGoogle.Id,                                                      
                                                          Status__c='Confirmed',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        TRY{    
            insert clientAvail1;
        }
        catch(Exception e)
        {
            system.debug('CoverTriggerValidation4 : e.getmessage() :'+e.getmessage());
            Boolean flag = e.getmessage().contains(Label.WB_Price_Tier_Value_Not_Matching);
            system.assertequals(true,flag);
        }
    }
    
    static testMethod void CoverTriggerValidation5(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;

        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        Local_Title__c lt1 = new Local_Title__c(
            Key__c = title1.Video_Version__c,
            Local_Title__c = 'TestTitle',
            Country__c = countryFrance.Id,
            Language__c = languageFrench.Id,
            Title__c = title1.id,
            Price_Code__c='test code'
        );
        insert lt1;
        
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=languageFrench.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        insert availLangTitle1;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c=lt1.id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub',Status__c='Tentative',
                                                                    Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan1;
        system.debug('******releaseplan1 : '+releaseplan1);
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                            Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        
        Pricing__c pricingRecord1 = new Pricing__c(Country__c=countryFrance.Id,Name='test code',Account__c=acctGoogle.id,Format__c='HD',Channel__c='DTD',Content_Type__c='Feature',Price_Tier__c='test1');
        insert pricingRecord1;

  
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,Price_Tier_Text__c='test1',                                                   
                                                          Client__c=acctGoogle.Id,                                                      
                                                          Status__c='Confirmed',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        TRY{    
            insert clientAvail1;
            lt1.Price_Code__c=null;
            update lt1;
            clientAvail1.Price_tier_text__c='test2';
            update clientAvail1;
        }
        catch(Exception e)
        {
            system.debug('CoverTriggerValidation5 : e.getmessage() :'+e.getmessage());
            Boolean flag = e.getmessage().contains(Label.WB_Price_Tier_Value_Not_Matching);
            //system.assertequals(true,flag);
        }
    }
    
    static testMethod void CoverTriggerValidation6(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        Title__c title2 = new Title__c(Name = 'TestGoogle1',Video_Version__c ='6000047555',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='HD');
        insert title2;
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR1',Country_Code__c='TF1',Channel__c='EST');
        insert countryFrance;
        Country__c countryFrance1 =new Country__c(Name ='TestFrance1',Country_Code2__c ='TR',Country_Code__c='TF',Channel__c='DTD');
        insert countryFrance1;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        Local_Title__c lt1 = new Local_Title__c(
            Key__c = title1.Video_Version__c,
            Local_Title__c = 'TestTitle',
            Country__c = countryFrance.Id,
            Language__c = languageFrench.Id,
            Title__c = title1.id,
            Price_Code__c='test code'
        );
        insert lt1;
        
        Local_Title__c lt2 = new Local_Title__c(
            Key__c = title2.Video_Version__c,
            Local_Title__c = 'TestTitle2',
            Country__c = countryFrance1.Id,
            Language__c = languageFrench.Id,
            Title__c = title2.id,
            Price_Code__c='test code'
        );
        insert lt2;
        
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=languageFrench.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        insert availLangTitle1;
        
        test.startTest();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c=lt1.id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub',Status__c='Tentative',
                                                                    Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan1;
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(Title__c=title2.Id,Country_Lookup__c=countryFrance1.Id,Local_Title__c=lt2.id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='SD',Language_Type__c='Sub',Status__c='Tentative',
                                                                    Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan2;
        system.debug('******releaseplan1 : '+releaseplan1);
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                            Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        
        Pricing__c pricingRecord1 = new Pricing__c(Country__c=countryFrance.Id,Name='test code',Account__c=acctGoogle.id,Format__c='HD',Channel__c='DTD',Content_Type__c='Feature',Price_Tier__c='test1');
        insert pricingRecord1;
        Pricing__c pricingRecord2 = new Pricing__c(Country__c=countryFrance.Id,Name='test code',Account__c=acctGoogle.id,Format__c='SD',Channel__c='DTD',Content_Type__c='Episode',Price_Tier__c='test1');
        insert pricingRecord2;
        Pricing__c pricingRecord3 = new Pricing__c(Country__c=countryFrance.Id,Name='test code',Account__c=acctGoogle.id,Format__c='HD',Channel__c='EST',Content_Type__c='Feature',Price_Tier__c='test1');
        insert pricingRecord3;
        Pricing__c pricingRecord4 = new Pricing__c(Country__c=countryFrance.Id,Name='test code1',Account__c=acctGoogle.id,Format__c='SD',Channel__c='DTD',Content_Type__c='Feature',Price_Tier__c='test1');
        insert pricingRecord4;

  
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        clientAvailList.add(new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,Price_Tier_Text__c='test1',                                                   
              Client__c=acctGoogle.Id,                                                      
              Status__c='Confirmed',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today()));
        clientAvailList.add(new Client_Avail__c(Commercial_Avail__c=releaseplan2.Id,Price_Tier_Text__c='test1',                                                   
              Client__c=acctGoogle.Id,                                                      
              Status__c='Confirmed',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today()));
              
        TRY{    
            insert clientAvailList;
            clientAvailList[0].Price_tier_text__c='test2';
            update clientAvailList;
        }
        catch(Exception e)
        {
            system.debug('CoverTriggerValidation6 : e.getmessage() :'+e.getmessage());
            Boolean flag = e.getmessage().contains(Label.WB_Pricing_Record_Not_Available);
            system.assertequals(false,flag);
        }
        test.stoptest();
    }
    
    static testMethod void CoverTriggerValidation7(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        Title__c title2 = new Title__c(Name = 'TestGoogle1',Video_Version__c ='6000047555',Content_Type__c='Episode',Digital_Planning__c='Yes',Clear_to_Avail__c = true,Formats__c='HD');
        insert title2;
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR1',Country_Code__c='TF1',Channel__c='EST');
        insert countryFrance;
        Country__c countryFrance1 =new Country__c(Name ='TestFrance1',Country_Code2__c ='TR',Country_Code__c='TF',Channel__c='DTD');
        insert countryFrance1;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        Local_Title__c lt1 = new Local_Title__c(
            Key__c = title1.Video_Version__c,
            Local_Title__c = 'TestTitle',
            Country__c = countryFrance.Id,
            Language__c = languageFrench.Id,
            Title__c = title1.id,
            Price_Code__c='test code'
        );
        insert lt1;
        
        Local_Title__c lt2 = new Local_Title__c(
            Key__c = title2.Video_Version__c,
            Local_Title__c = 'TestTitle2',
            Country__c = countryFrance1.Id,
            Language__c = languageFrench.Id,
            Title__c = title2.id,
            Price_Code__c='test code'
        );
        insert lt2;
        
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=languageFrench.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        insert availLangTitle1;
        
	 test.starttest();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c=lt1.id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub',Status__c='Tentative',
                                                                    Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan1;
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(Title__c=title2.Id,Country_Lookup__c=countryFrance1.Id,Local_Title__c=lt2.id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='SD',Language_Type__c='Sub',Status__c='Tentative',
                                                                    Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan2;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                            Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
       
        Pricing__c pricingRecord1 = new Pricing__c(Country__c=countryFrance.Id,Name='test code',Account__c=acctGoogle.id,Format__c='HD',Channel__c='DTD',Content_Type__c='Feature',Price_Tier__c='test1');
        insert pricingRecord1;
        Pricing__c pricingRecord2 = new Pricing__c(Country__c=countryFrance.Id,Name='test code',Account__c=acctGoogle.id,Format__c='SD',Channel__c='DTD',Content_Type__c='Episode',Price_Tier__c='test1');
        insert pricingRecord2;
        Pricing__c pricingRecord3 = new Pricing__c(Country__c=countryFrance.Id,Name='test code',Account__c=acctGoogle.id,Format__c='HD',Channel__c='EST',Content_Type__c='Feature',Price_Tier__c='test1');
        insert pricingRecord3;
        Pricing__c pricingRecord4 = new Pricing__c(Country__c=countryFrance.Id,Name='test code1',Account__c=acctGoogle.id,Format__c='SD',Channel__c='DTD',Content_Type__c='Feature',Price_Tier__c='test1');
        insert pricingRecord4;

  
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        clientAvailList.add(new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,Price_Tier_Text__c='test1',                                                   
              Client__c=acctGoogle.Id,                                                      
              Status__c='Tentative',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today()));
        clientAvailList.add(new Client_Avail__c(Commercial_Avail__c=releaseplan2.Id,Price_Tier_Text__c='test1',                                                   
              Client__c=acctGoogle.Id,                                                      
              Status__c='Tentative',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today()));
              
        TRY{    
            insert clientAvailList;
            clientAvailList[0].Status__c='Confirmed';
            clientAvailList[1].Status__c='Confirmed';
            update clientAvailList;
        }
        catch(Exception e)
        {
            system.debug('CoverTriggerValidation7 : e.getmessage() :'+e.getmessage());
            Boolean flag = e.getmessage().contains(Label.WB_Pricing_Record_Not_Available);
            system.assertequals(false,flag);
        }
        test.stoptest();
    }
    
    static testMethod void CoverTriggerValidation8(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        Title__c title2 = new Title__c(Name = 'TestGoogle1',Video_Version__c ='6000047555',Content_Type__c='Episode',Digital_Planning__c='Yes',Clear_to_Avail__c = true,Formats__c='HD');
        insert title2;
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR1',Country_Code__c='TF1',Channel__c='EST');
        insert countryFrance;
        Country__c countryFrance1 =new Country__c(Name ='TestFrance1',Country_Code2__c ='TR',Country_Code__c='TF',Channel__c='DTD');
        insert countryFrance1;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        //Create Pricing
       Pricing__c newPrice = new Pricing__c();
       newPrice.Content_Type__c = 'Feature';
       newPrice.Account__c = acctGoogle.Id;
       newPrice.Country__c = countryFrance.Id;
       newPrice.Channel__c = 'DTD';
       newPrice.Format__c = 'HD';
       newPrice.WS_Price__c = 120.00;
       newPrice.Name = 'test code';
       //insert newPrice;
       
        Local_Title__c lt1 = new Local_Title__c(
            Key__c = title1.Video_Version__c,
            Local_Title__c = 'TestTitle',
            Country__c = countryFrance.Id,
            Language__c = languageFrench.Id,
            Title__c = title1.id,
            Price_Code__c='test code'
        );
        insert lt1;
        
        Local_Title__c lt2 = new Local_Title__c(
            Key__c = title2.Video_Version__c,
            Local_Title__c = 'TestTitle2',
            Country__c = countryFrance1.Id,
            Language__c = languageFrench.Id,
            Title__c = title2.id,
            Price_Code__c='test code'
        );
        insert lt2;
        
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=languageFrench.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        insert availLangTitle1;
        
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=languageFrench.Id ,Language_Types__c='Sub',Title__c=title2.Id,Clear_To_Avail__c=true);
        insert availLangTitle2;
		
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c=lt1.id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub',Status__c='Tentative',
                                                                    Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan1;
        test.starttest();
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(Title__c=title2.Id,Country_Lookup__c=countryFrance1.Id,Local_Title__c=lt2.id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='SD',Language_Type__c='Sub',Status__c='Tentative',
                                                                    Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan2;
       
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                            Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        Agreement__c storefrontGoogle2 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance1.Id,Pricing_Currency__c='FR',Content_Type__c=title2.Content_Type__c,
                                                            Channel_Picklist__c = releaseplan2.Channel__c,Format__c=releaseplan2.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle2;
        

        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        clientAvailList.add(new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,Price_Tier_Text__c='test1',                                                   
              Client__c=acctGoogle.Id,                                                      
              Status__c='Tentative',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today()));
        clientAvailList.add(new Client_Avail__c(Commercial_Avail__c=releaseplan2.Id,Price_Tier_Text__c='test1',                                                   
              Client__c=acctGoogle.Id,                                                      
              Status__c='Tentative',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today()));

        TRY{    
            insert clientAvailList;
            delete clientAvailList[0]; 
            clientAvailList[1].Status__c='Confirmed';
            update clientAvailList[1];
        }
        catch(Exception e)
        {
            system.debug('CoverTriggerValidation7 : e.getmessage() :'+e.getmessage());
            System.debug('Printing Exception-->'+e.getStackTraceString());
            Boolean flag = e.getmessage().contains(Label.WB_Pricing_Record_Not_Available);
            system.assertequals(true,flag);
        }
        test.stoptest();
    }
    
        static testMethod void CoverTriggerCode(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        Local_Title__c lt1 = new Local_Title__c(
            Key__c = title1.Video_Version__c,
            Local_Title__c = 'TestTitle',
            Country__c = countryFrance.Id,
            Language__c = languageFrench.Id,
            Title__c = title1.id,
            Price_Code__c='test code'
        );
        insert lt1;
        
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=languageFrench.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        insert availLangTitle1;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                        Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub',Status__c='Tentative',
                                                                        Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan1;
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                            Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        Pricing__c pricingRecord = new Pricing__c(Country__c=countryFrance.Id,Name='test code',Account__c=acctGoogle.id,Format__c='HD',Channel__c='DTD',Content_Type__c='Feature',Price_Tier__c='test Price tier');
        insert pricingRecord;

        Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,Local_Title__c=lt1.id, Price_Tier_Text__c='test code',                                                   
                                                      Client__c=acctGoogle.Id,Validation_Failures__c='Invalid Price Tier',                                                      
                                                      Status__c='Tentative',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
        insert clientAvail1;
        clientAvail1.Price_Tier_Text__c = 'test Price tier';
        update clientAvail1; 
    }
   /* static testMethod void CoverTriggerValidation9(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;

        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF');
        insert countryFrance;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        Local_Title__c lt1 = new Local_Title__c(
            Key__c = title1.Video_Version__c,
            Local_Title__c = 'TestTitle',
            Country__c = countryFrance.Id,
            Language__c = languageFrench.Id,
            Title__c = title1.id,
            Price_Code__c='test code'
        );
        insert lt1;
        
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=languageFrench.Id ,Language_Types__c='Sub',Title__c=title1.Id,Clear_To_Avail__c=true);
        insert availLangTitle1;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                        Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub',Status__c='Tentative',
                                                                        Exclusive_Date__c = date.today()-12, Start_Date__c=date.today()-5,End_Date__c= date.today()+5,Rights_End__c=date.today()+7);
        insert releaseplan1;
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                            Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active', CRM_Storefront__c = TRUE);
        insert storefrontGoogle1;
        Pricing__c pricingRecord = new Pricing__c(Country__c=countryFrance.Id,Name='test code',Account__c=acctGoogle.id,Format__c='HD',Channel__c='DTD',Content_Type__c='Feature',Price_Tier__c='test Price tier');
        insert pricingRecord;
        try
        {
            Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,Local_Title__c=lt1.id, Price_Tier_Text__c='test code',                                                   
                                                          Client__c=acctGoogle.Id,                                                      
                                                          Status__c='Confirmed',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c ,Effective_Price_Date__c=date.today());
            insert clientAvail1;
            //delete pricingRecord;
            clientAvail1.Price_Tier_Text__c = '';
            update clientAvail1; 
        }
        catch(Exception e)
        {
            system.debug('CoverTriggerValidation2 : e.getmessage() :'+e.getmessage());
            Boolean flag = e.getmessage().contains(Label.WB_Pricing_Record_Not_Available);
            system.assertequals(true,flag);
        }
    
    } */
}