/**
   @Author Cognizant
   @name CRM_CreateProductsBatch_Test
   @CreateDate 
   @Description Test class for CRM_CreateProductsBatch, CRM_CreatePBEPeriodBatch
   @Version <1.0>
   @reference Requirement no 
  */

@isTest(SeeAllData=false) 
private class CRM_CreateProductsBatch_Test{
    
    // This code runs as the System Administrator
    static Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

    static User testUser = new User(Alias = 'wbcrms', Email='wbcrmstandarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='wbcrmstandarduser@testorg.com');
    //static User testUser = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
    static Id rtAcc =  CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
    static Id rtAcDC =  [SELECT Id FROM RecordType WHERE DeveloperName = 'Digital_Client'][0].Id;
    
    
    /**
    *  Create Test Data. 
    *  @name createTestData
    *  @param None
    *  @return None
    *  @throws None
    * @testsetup
    */
       @testsetup  
       public static void createTestDataForBatchNotificationStatus(){ 
           List<Batch_Notification_Recipients__c> userList  = BatchStatusNotificationTest.initUserDetails(2,'test@gmail.com','CRM');
           insert userList;
           System.assertEquals(2, [SELECT Id FROM Batch_Notification_Recipients__c ].size());
       }
       private static void createTestData() {
         
        Product_Creation_Batch_Setting__c setting = new Product_Creation_Batch_Setting__c();
        setting.Name = 'Default';
        setting.Generate_CRM_Product__c = true;
        setting.Last_N_Days__c = 2;
        insert setting;

        List<Account> accts = new List<Account>();
        List<Account> accts1 = new List<Account>();
        
        PriceBook2 pb = new PriceBook2();
        pb.Name = 'TestPB1';
        pb.Currency__c = 'USD';
        //pb.Distribution_Channel__c = '10';
        pb.External_Id__c = '6000-10-0012020726';
        pb.Business_Unit__c = '6000';
        Insert pb;
        
        for(Account currentAccounts : CRM_TestDataFactory.createAccounts(1, false)){                   
            currentAccounts.RecordTypeID = rtAcc;
            currentAccounts.CurrencyIsoCode = 'USD';
            currentAccounts.Price_Book__c = pb.Id;  
            
            accts.add(currentAccounts);
        }
        //digital client account
        insert accts;
                for(Account currentAccounts : CRM_TestDataFactory.createAccounts(1, false)){                   
            currentAccounts.RecordTypeID = rtAcDC;
            currentAccounts.CurrencyIsoCode = 'USD';
            currentAccounts.Price_Book__c = pb.Id;  
            
            accts1.add(currentAccounts);
        }
        
        insert accts1;
        
        List<Country__c> countries = CRM_TestDataFactory.createCountries(new List<String>{'Asia1', 'Asia2'}, 1, true);
        List<Title__c> titles = CRM_TestDataFactory.createTitles(1, false);
        titles[0].Video_Version__c = '99999999';
        titles[0].Digital_Planning__c = 'Yes';
        titles[0].Name = 'TestTitle';
        insert titles;
        
        List<Agreement__c> storeFronts = CRM_TestDataFactory.createStoreFronts(accts, titles, countries, false);
        for(Integer Count = 0; Count < storeFronts.size(); Count++){
                storeFronts[count].CRM_Account__c = accts[Count].Id;      
                storeFronts[count].Status__c = 'Active';
                storeFronts[count].Account__c = accts1[Count].Id;
                storeFronts[count].SAP_Customer_Number__c='12010421';
            }
        insert storeFronts;
        
        List<Pricing__c> prices = CRM_TestDataFactory.createPricings(1, true);
        
        List<Language__c> languages = CRM_TestDataFactory.createLanguages(1, true);         
        List<Local_Title__c> localTitles = CRM_TestDataFactory.createLocalTitles(countries, languages, 1, true);                       
        test.startTest();
        List<Commercial_Avail__c> releasePlans = CRM_TestDataFactory.createReleasePlans(2, titles, storeFronts, localTitles, countries, languages, false);
        
        Integer i=0;
        //List<String> chn = new List<String>{'DTD','EST','Hotel','PPV','VODc','VODi'};
        for(Commercial_Avail__c ca: releasePlans ){
           
            ca.Start_Date__c = Date.valueOf(System.now().addMonths(i));
            ca.End_Date__c = Date.valueOf(System.now().addMonths(i).addDays(10));
            ca.Exclusive_Date__c = Date.valueOf(System.now().addMonths(i));
            ca.Rights_End__c = Date.valueOf(System.now().addMonths(i).addDays(10));     
            ca.status__c ='Confirmed';

            i++;
        }
        insert releasePlans;
        
        List<Client_Avail__c> clientAvails = CRM_TestDataFactory.createClientAvails(prices, releasePlans, localTitles, accts1, storeFronts, 1, false);
        clientAvails[0].Status__c = 'Confirmed';
        clientAvails[0].Price__c = 150;
        insert clientAvails;
        test.stopTest();
    }
    
    /**
    *  Check result for creating client avail for already existing commerical avail. 
    *  @name positiveTest
    *  @param None
    *  @return None
    *  @throws None
    */
    
    static testmethod void positiveTest(){
        createTestData();
        // Setting custom setting Value
        Product_Creation_Batch_Setting__c setting = new Product_Creation_Batch_Setting__c();            
        setting.Name = 'Default1';  //Default instead of Default 123  
        setting.Last_N_Days__c = 1;
        setting.Generate_CRM_Product__c = true;
        insert setting;
        
        System.runAs(testUser) {
        
            CRM_CreateProductsBatch objCRMCreateProductsBatch = new CRM_CreateProductsBatch(new List<String>{'Asia1','Asia2'});
            //Test.startTest();       
            Database.executeBatch(objCRMCreateProductsBatch, 2);
            //Test.stopTest();
            
            WB_CreateProduct_PBEP_Test.createTestData();
            
            System.assertEquals(2, [Select Count() FROM Product2]);
            System.assertEquals(1, [Select Count() FROM Pricebook_Entry_Period__c]);
            System.assertEquals(2, [Select Count() FROM PricebookEntry]);
            list<Commercial_Avail__c> commavail = [Select Product__c FROM Commercial_Avail__c];
            System.assertNotEquals(null, commavail[0].Product__c);
            System.assertNotEquals(null, commavail[1].Product__c);
            //System.assertEquals(true, [Select IsClientAvailProcessed__c FROM Client_Avail__c].IsClientAvailProcessed__c);
        }
    }
    
        
    /**
    *  Check result for positive scenario. 
    *  @name newClientAvail
    *  @param None
    *  @return None
    *  @throws None
    */
    
    static testmethod void newClientAvailAdded(){
        createTestData();
        /*Product_Creation_Batch_Setting__c setting = new Product_Creation_Batch_Setting__c();            
        setting.Name = 'Default1';  //Default instead of Default 123  
        setting.Last_N_Days__c = 1;
        setting.Generate_CRM_Product__c = true;
        insert setting;*/
        
        System.runAs(testUser) {
            
            CRM_CreateProductsBatch objCRMCreateProductsBatch = new CRM_CreateProductsBatch(new List<String>{'Asia1','Asia2'});
            
            //Test.startTest();
            Client_Avail__c clientAvail = [Select Id,Local_Title__c,Pricing__c,Storefront__c,Client__c FROM Client_Avail__c];
            List<Commercial_Avail__c> commercialAvail = [Select Id FROM Commercial_Avail__c];
            Client_Avail__c newclientAvail = new Client_Avail__c();
            newclientAvail.Local_Title__c = clientAvail.Local_Title__c;
            newclientAvail.Pricing__c = clientAvail.Pricing__c;
            newclientAvail.Commercial_Avail__c = commercialAvail[0].ID;
            newclientAvail.Storefront__c = clientAvail.Storefront__c;
            newclientAvail.Client__c = clientAvail.Client__c;
            newclientAvail.Status__c = 'Confirmed';
            newclientAvail.End_Date__c = Date.valueOf(System.now().addDays(6));
            newclientAvail.Start_Date__c = Date.valueOf(System.now().addDays(4));
            newclientAvail.Price__c = 150;
            insert newclientAvail;
             
            //List<Commercial_Avail__c> commAvailList = [Select IsRelatedClientAvailChanged__c FROM Commercial_Avail__c];
            
            //System.assertEquals(true, commAvailList[0].IsRelatedClientAvailChanged__c);
            
            Database.executeBatch(objCRMCreateProductsBatch, 2);
            //Test.stopTest();
            
            WB_CreateProduct_PBEP_Test.createTestData();
            
            System.assertEquals(150,[Select Account_Price__c FROM Pricebook_Entry_Period__c][0].Account_Price__c);
            Pricing__c pricingObj = [Select Id,Account_Price__c FROM Pricing__c];
            pricingObj.Account_Price__c = 151;
            update pricingObj;
            
            System.assertEquals(2, [Select Count() FROM Product2]);
            //System.assertEquals(2, [Select Count() FROM Pricebook_Entry_Period__c]);
            list<Pricebook_Entry_Period__c> ListPbep = [Select id,Account_Price__c FROM Pricebook_Entry_Period__c];
            System.assertEquals(2,ListPbep.size());
            System.assertEquals(151,ListPbep[0].Account_Price__c);
            //System.assertEquals(151,[Select Account_Price__c FROM Pricebook_Entry_Period__c][0].Account_Price__c);
        }
    }
    
     /**
    *  Check result for US#309 It will consider Price__c field first and then Pricing__r.Account_Price__c . 
    *  @name newPriceUpdates
    *  @param None
    *  @return None
    *  @throws None
    */
    static testmethod void newPriceUpdates(){
        createTestData();
        
        System.runAs(testUser) {
            
            CRM_CreateProductsBatch crmCreateProductsBatch = new CRM_CreateProductsBatch(new List<String>{'Asia1','Asia2'});
            
            //Test.startTest();       
            
            Client_Avail__c clientAvails = [Select Id,Local_Title__c,Pricing__c,Storefront__c,Client__c,Pricing__r.Account_Price__c FROM Client_Avail__c];
            List<Commercial_Avail__c> commercialAvails = [Select Id FROM Commercial_Avail__c];
            Client_Avail__c newclientAvailToInsert = new Client_Avail__c();
            newclientAvailToInsert.Local_Title__c = clientAvails.Local_Title__c;
            newclientAvailToInsert.Pricing__c = clientAvails.Pricing__c;
            newclientAvailToInsert.Commercial_Avail__c = commercialAvails[0].ID;
            newclientAvailToInsert.Storefront__c = clientAvails.Storefront__c;
            newclientAvailToInsert.Client__c = clientAvails.Client__c;
            newclientAvailToInsert.Status__c = 'Confirmed';
            newclientAvailToInsert.End_Date__c = Date.valueOf(System.now().addDays(6));
            newclientAvailToInsert.Start_Date__c = Date.valueOf(System.now().addDays(4));
            newclientAvailToInsert.Price__c = 0;
            insert newclientAvailToInsert;
    
            Database.executeBatch(crmCreateProductsBatch, 2);
            
            WB_CreateProduct_PBEP_Test.createTestData();
            //Test.stopTest();
            
            System.assertEquals(150,[Select Account_Price__c FROM Pricebook_Entry_Period__c][0].Account_Price__c);  
        }
    }

}