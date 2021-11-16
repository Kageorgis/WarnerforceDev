@isTest
public class CRM_InsertPBEPOnProductListPBatch_Test{
   public static PriceBook2 pb ;
   public static  Default_Pricing__c dp;
   public static List<Local_Title__c> lstLocalData =new List<Local_Title__c> ();
   
   @testsetup  
   public static void createTestDataForBatchNotificationStatus(){ 
        List<Batch_Notification_Recipients__c> userList  = BatchStatusNotificationTest.initUserDetails(2,'test@gmail.com','CRM');
        insert userList;
        System.assertEquals(2, [SELECT Id FROM Batch_Notification_Recipients__c ].size()); 
   }
   private static void createTestData(){
        //Create Custom setting
        createCustomSetting();
        pb = createPricebook();
        dp = createDefaultPricing();
        lstLocalData = createLocalTitledata();
    }
    static void createCustomSetting(){  
        CRM_Trigger_Switches_For_ON_OFF__c CRMTS = new CRM_Trigger_Switches_For_ON_OFF__c();
        CRMTS.Name = 'CRM_Product_PBEP_UNBW';
        CRMTS.IsActive__c = True;
        insert CRMTS;
        Product_Group__c pg1 = new Product_Group__c();
        pg1.name = 'FR Digital TV EST';
        pg1.External_Id__c = 'FR Digital TV EST';
        insert pg1; 
        system.assertEquals(1,[select count() from Product_Group__c ]); 
        CRM_Product_Group_Update__c cs1 = new CRM_Product_Group_Update__c();
        cs1.Name = 'step1';
        cs1.Content_Type__c = '';
        cs1.Country__c = 'FR';
        cs1.Franchise__c = 'TV';
        cs1.Group__c = pg1.External_Id__c;
        cs1.ID__c = pg1.Id;
        cs1.Order__c = 10;
        cs1.Type__c = 'Video Digital';
        cs1.Product_Genre__c = '';
        cs1.Product_Label__c = '';
        cs1.Product_Market__c = 'EST'; 
        insert cs1;
        system.assertEquals(1,[select count() from CRM_Product_Group_Update__c ]);
    }
    
    private static PriceBook2 createPricebook(){
        
        pb = new PriceBook2();
        pb.Name = 'TestPB1';
        pb.Currency__c = 'USD';
        //pb.Distribution_Channel__c = '10';
        pb.External_Id__c = '6000-10-0012020726';
        pb.Business_Unit__c = '6000';
        pb.IsActive = true;
        Insert pb;
        return pb;
    } 
    private static Default_Pricing__c createDefaultPricing(){
        dp = new Default_Pricing__c();
        dp.Default_Price__c = 13;
        dp.Price_Book__c = pb.id;
        dp.Format__c = '4';
        dp.Franchise_Type__c = 'TV';
        dp.currencyisocode = CRM_AppConstants.EUR_CURRENCY_CODE;
        Insert dp;
        return dp;
    }
    public static List<Local_Title__c> createLocalTitledata(){
    
        List<String> strRegion = new List<String>();    
        strRegion.add('UK');
                               
        //create country
        List<Country__c> lstCountries = CRM_TestDataFactory.createCountries(strRegion, 1, true);
        List<Language__c> lstLang = CRM_TestDataFactory.createLanguages(1, true);
                                
        //create tittle 
        Title__c tittle = new title__c();
        tittle.name = 'Tittle';
        tittle.Content_Type__c = 'Game';
        insert tittle;
        
        system.assertEquals(1,[select count() from Title__c]);
                                
        //create local data
        lstLocalData = CRM_TestDataFactory.createLocalTitles(lstCountries, lstLang, 1, false);
        lstLocalData[0].Title__c = tittle.Id;
        insert lstLocalData;
        system.assertEquals(1,[select count() from Local_Title__c]);
        
        return lstLocalData;
        
    }   
     
    private static void createPBEntries( List<Product2> lstProduct ){
        List<PricebookEntry> lstPriceBookEntries = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 2, false);
        lstPriceBookEntries[0].CurrencyISOCode = CRM_AppConstants.EUR_CURRENCY_CODE;
        lstPriceBookEntries[0].UnitPrice = 4;
        lstPriceBookEntries[1].CurrencyISOCode = CRM_AppConstants.GBP_CURRENCY_CODE;
        lstPriceBookEntries[1].UnitPrice = 5;
        insert lstPriceBookEntries ; 
    }
    
    static testmethod void testDataForVideoPhysicalBothPrices(){
        createTestData(); 
        //Create Products
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,false);
        Integer prodCountflag = 0;
        
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCountflag ;
            objProduct.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
            objProduct.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            objProduct.Franchise_Type__c = 'TV';
            objProduct.SAP_Sales_Org__c = '6000';
            objProduct.Product_Format__c = '4';
            objProduct.street_date__c = System.today()+1;
            prodCountflag ++;
        }
        insert lstProduct;
        system.assertEquals(1,[select Count() from Product2]);
        Product2 videoDigitalPro = [Select Id,Type__c,International_Product__c,International_Reporting__c,Product_Group__c From Product2 limit 1];
        system.assertEquals(videoDigitalPro.International_Product__c,false); 
        system.assertEquals(videoDigitalPro.International_Reporting__c,false);  
         //Assert for Product Type eqal to Video Physical
        system.assertEquals(videoDigitalPro.Type__c,CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE); 
        
        createPBEntries(lstProduct); 
        Integer pbeCounter = [Select count() FROM PricebookEntry]; 
        System.assertEquals(2,pbeCounter);
        
        // Create Account records
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(2, false);
        lstAccounts[0].scheduleRevenueChanged__c = false;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccounts[0].Price_Book__c = pb.Id;
        lstAccounts[0].currencyisocode = CRM_AppConstants.EUR_CURRENCY_CODE;
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].Video_Physical__c = true;
        lstAccounts[1].scheduleRevenueChanged__c = false;
        lstAccounts[1].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccounts[1].Price_Book__c = pb.Id;
        lstAccounts[1].currencyisocode = CRM_AppConstants.GBP_CURRENCY_CODE;
        lstAccounts[1].Games_Physical__c = true;
        lstAccounts[1].Video_Physical__c = true;
        insert  lstAccounts; 
        
        Test.startTest();
        CRM_InsertPBEPOnProductListPriceBatch a = new CRM_InsertPBEPOnProductListPriceBatch();
        database.executebatch(a,10);
        Test.stopTest();
        
        List<Pricebook_Entry_Period__c> pbepList = [Select Account_Price__c,Id,CurrencyIsoCode FROM Pricebook_Entry_Period__c]; 
        System.assertEquals(2,pbepList.size());
        
        for(Pricebook_Entry_Period__c pbe : pbepList){
            if(pbe.CurrencyIsoCode == CRM_AppConstants.GBP_CURRENCY_CODE){
                System.assertEquals(null,pbe.Account_Price__c);   
            }
             if(pbe.CurrencyIsoCode == CRM_AppConstants.EUR_CURRENCY_CODE){
                System.assertEquals(13,pbe.Account_Price__c);   
            }
        } 
    } 
    static testmethod void testDataForVideoPhysicalBothPricesSecond(){
        createTestData(); 
        
        //Create Products
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,false);
        Integer prodCountflag = 0;
        
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCountflag ;
            objProduct.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
            //objProduct.Local_Title__c = lstLocalData[0].Id;
            objProduct.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            objProduct.Franchise_Type__c = 'TV';
            objProduct.SAP_Sales_Org__c = '6000';
            objProduct.Product_Format__c = '4';
            objProduct.street_date__c = System.today()+1;
            //objProduct.currencyisocode = 'EUR';
            prodCountflag ++;
        }
        insert lstProduct;
        system.assertEquals(1,[select Count() from Product2]);
        Product2 videoDigitalPro = [Select Id,Type__c,International_Product__c,International_Reporting__c,Product_Group__c From Product2 limit 1];
        system.assertEquals(videoDigitalPro.International_Product__c,false); 
        system.assertEquals(videoDigitalPro.International_Reporting__c,false);  
        //Assert for Product Type equal to Vedio Physical
        system.assertEquals(videoDigitalPro.Type__c,CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE);
        
        createPBEntries(lstProduct);
        
        // Create Account records
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(2, false);
        lstAccounts[0].scheduleRevenueChanged__c = false;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccounts[0].Price_Book__c = pb.Id;
        lstAccounts[0].currencyisocode = CRM_AppConstants.EUR_CURRENCY_CODE;
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].Video_Physical__c = true;
        lstAccounts[1].scheduleRevenueChanged__c = false;
        lstAccounts[1].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccounts[1].Price_Book__c = pb.Id;
        lstAccounts[1].currencyisocode = CRM_AppConstants.GBP_CURRENCY_CODE;
        lstAccounts[1].Games_Physical__c = true;
        lstAccounts[1].Video_Physical__c = true;
        insert  lstAccounts; 
        
        Test.startTest();
        CRM_InsertPBEPOnProductListPriceBatch a =new CRM_InsertPBEPOnProductListPriceBatch();
        database.executebatch(a,10);
        Test.stopTest();
        
        Integer pbeCounter = [Select count() FROM PricebookEntry]; 
       // System.assertEquals(4,pbeCounter);
        List<Pricebook_Entry_Period__c> pbepList = [Select Account_Price__c,Id,CurrencyIsoCode FROM Pricebook_Entry_Period__c]; 
        System.assertEquals(2,pbepList.size());
        for(Pricebook_Entry_Period__c pbe : pbepList){
            if(pbe.CurrencyIsoCode == CRM_AppConstants.GBP_CURRENCY_CODE){
                System.assertEquals(null,pbe.Account_Price__c);   
            }
             if(pbe.CurrencyIsoCode == CRM_AppConstants.EUR_CURRENCY_CODE){
                System.assertEquals(13,pbe.Account_Price__c);   
            }
        } 
        try{
            Integer i = 10/0;
        }
        catch(Exception e){
            List<Database.Error> errors = new List<Database.Error>();
            CRM_ProductHandler.logAnException(e,null);
            CRM_ProductHandler.logAnException(errors, null, 'Test');
        } 
    } 
    
    //Update
      static testmethod void testDataForGamesPhysicalBothPricesUpdate(){
        createTestData();  
        //Create Products
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,false);
        Integer prodCountflag = 0;
        
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCountflag ;
            objProduct.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
            objProduct.Local_Title__c = lstLocalData[0].Id;
            objProduct.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            objProduct.Franchise_Type__c = 'TV';
            objProduct.SAP_Sales_Org__c = '6000';
            objProduct.Product_Format__c = '4';
            objProduct.street_date__c = System.today()+1;
            //objProduct.currencyisocode = 'EUR';
            prodCountflag ++;
        }
        insert lstProduct; 
        createPBEntries(lstProduct); 
        // Create Account records
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(2, false);
        lstAccounts[0].scheduleRevenueChanged__c = false;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccounts[0].Price_Book__c = pb.Id;
        lstAccounts[0].currencyisocode = CRM_AppConstants.EUR_CURRENCY_CODE;
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].Video_Physical__c = true;
        lstAccounts[1].scheduleRevenueChanged__c = false;
        lstAccounts[1].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccounts[1].Price_Book__c = pb.Id;
        lstAccounts[1].currencyisocode = CRM_AppConstants.GBP_CURRENCY_CODE;
        lstAccounts[1].Games_Physical__c = true;
        lstAccounts[1].Video_Physical__c = true;
        insert  lstAccounts; 
        
        
        system.assertEquals(1,[select Count() from Product2]);
        
        Product2 videoDigitalPro = [Select Id,Type__c,International_Product__c,International_Reporting__c,Product_Group__c From Product2 limit 1];
        system.assertEquals(videoDigitalPro.International_Product__c,false); 
        system.assertEquals(videoDigitalPro.International_Reporting__c,false);  
        //Assert for Product Type equal to Vedio Physical
        system.assertEquals(videoDigitalPro.Type__c,CRM_AppConstants.Games_PHYSICAL_PRODUCT_TYPE); 
        
        Test.startTest();
        CRM_InsertPBEPOnProductListPriceBatch a =new CRM_InsertPBEPOnProductListPriceBatch();
        database.executebatch(a,10);
        Test.stopTest();  
        Integer pbeCounter = [Select count() FROM PricebookEntry]; 
      //  System.assertEquals(4,pbeCounter);
        List<Pricebook_Entry_Period__c> pbepList = [Select Account_Price__c,Id,CurrencyIsoCode FROM Pricebook_Entry_Period__c]; 
        System.assertEquals(2,pbepList.size());
        
        for(Pricebook_Entry_Period__c pbe : pbepList){
            if(pbe.CurrencyIsoCode == CRM_AppConstants.GBP_CURRENCY_CODE){
                System.assertEquals(null,pbe.Account_Price__c);   
            }
             if(pbe.CurrencyIsoCode == CRM_AppConstants.EUR_CURRENCY_CODE){
                System.assertEquals(13,pbe.Account_Price__c);   
            }
        }  
    } 
   
    static testmethod void testDataForGamesPhysicalBothPricesUpdateSecond(){
        createTestData();  
        //Create Products
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,false);
        Integer prodCountflag = 0;
        
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCountflag ;
            objProduct.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
            objProduct.Local_Title__c = lstLocalData[0].Id;
            objProduct.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            objProduct.Franchise_Type__c = 'TV';
            objProduct.SAP_Sales_Org__c = '6000';
            objProduct.Product_Format__c = '4';
            objProduct.street_date__c = System.today()+1;
            //objProduct.currencyisocode = 'EUR';
            prodCountflag ++;
        }
        insert lstProduct;
        createPBEntries(lstProduct);
        // Create Account records
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(2, false);
        lstAccounts[0].scheduleRevenueChanged__c = false;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccounts[0].Price_Book__c = pb.Id;
        lstAccounts[0].currencyisocode = CRM_AppConstants.EUR_CURRENCY_CODE;
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].Video_Physical__c = true;
        lstAccounts[1].scheduleRevenueChanged__c = false;
        lstAccounts[1].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccounts[1].Price_Book__c = pb.Id;
        lstAccounts[1].currencyisocode = CRM_AppConstants.GBP_CURRENCY_CODE;
        lstAccounts[1].Games_Physical__c = true;
        lstAccounts[1].Video_Physical__c = true;
        insert  lstAccounts;
         
        system.assertEquals(1,[select Count() from Product2]);
        
         Product2 videoDigitalPro = [Select Id,Type__c,International_Product__c,International_Reporting__c,Product_Group__c From Product2 limit 1];
        system.assertEquals(videoDigitalPro.International_Product__c,false); 
        system.assertEquals(videoDigitalPro.International_Reporting__c,false);  
        
        //Assert for Product Type eqal to Vedio Physical
        system.assertEquals(videoDigitalPro.Type__c,CRM_AppConstants.Games_PHYSICAL_PRODUCT_TYPE);
        
        Test.startTest();
        CRM_InsertPBEPOnProductListPriceBatch a =new CRM_InsertPBEPOnProductListPriceBatch();
        database.executebatch(a,10);
        Test.stopTest(); 
        Integer pbeCounter = [Select count() FROM PricebookEntry]; 
       // System.assertEquals(4,pbeCounter);
        List<Pricebook_Entry_Period__c> pbepList = [Select Account_Price__c,Id,CurrencyIsoCode FROM Pricebook_Entry_Period__c]; 
        System.assertEquals(2,pbepList.size());
        for(Pricebook_Entry_Period__c pbe : pbepList){
            if(pbe.CurrencyIsoCode == CRM_AppConstants.GBP_CURRENCY_CODE){
                System.assertEquals(null,pbe.Account_Price__c);   
            }
            if(pbe.CurrencyIsoCode == CRM_AppConstants.EUR_CURRENCY_CODE){
                System.assertEquals(13,pbe.Account_Price__c);   
            }
        } 
    }
    
    static testmethod void testBulkDataForGamesPhysicalBothPricesUpdateSecond(){
        createTestData(); 
        
        //Create Products
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),200,false);
        Integer prodCountflag = 0;
        
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCountflag ;
            objProduct.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
            objProduct.Local_Title__c = lstLocalData[0].Id;
            objProduct.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            objProduct.Franchise_Type__c = 'TV';
            objProduct.SAP_Sales_Org__c = '6000';
            objProduct.Product_Format__c = '4';
            objProduct.street_date__c = System.today()+1;
            prodCountflag ++;
        }
        insert lstProduct;
            
        List<PricebookEntry> lstPriceBookEntriesEUR = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, false);
        for(PricebookEntry pberec : lstPriceBookEntriesEUR){
            pberec.CurrencyISOCode = CRM_AppConstants.EUR_CURRENCY_CODE;
            pberec.UnitPrice = 4;
        }
        insert lstPriceBookEntriesEUR ;
        
        List<PricebookEntry> lstPriceBookEntriesGBP = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, false);
        for(PricebookEntry pberec : lstPriceBookEntriesGBP){
            pberec.CurrencyISOCode = CRM_AppConstants.GBP_CURRENCY_CODE;
            pberec.UnitPrice = 5;
        } 
        insert lstPriceBookEntriesGBP ;
        Integer pbeCounter = [Select count() FROM PricebookEntry]; 
        System.assertEquals(400,pbeCounter);
        
        // Create Account records
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(2, false);
        lstAccounts[0].scheduleRevenueChanged__c = false;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccounts[0].Price_Book__c = pb.Id;
        lstAccounts[0].currencyisocode = CRM_AppConstants.EUR_CURRENCY_CODE;
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].Video_Physical__c = true;
        lstAccounts[1].scheduleRevenueChanged__c = false;
        lstAccounts[1].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccounts[1].Price_Book__c = pb.Id;
        lstAccounts[1].currencyisocode = CRM_AppConstants.GBP_CURRENCY_CODE;
        lstAccounts[1].Games_Physical__c = true;
        lstAccounts[1].Video_Physical__c = true;
        insert  lstAccounts;
         
        system.assertEquals(200,[select Count() from Product2]);
        
        List<Product2> videoDigitalPro = [Select Id,Type__c,UK_List_Price_EUR__c,International_Product__c,International_Reporting__c,UK_List_Price_GBP__c,Product_Group__c From Product2 limit 500]; 
         
        //Assert for Product Type eqal to Vedio Physical
        for(Product2 pro : videoDigitalPro){
            system.assertEquals(pro.Type__c,CRM_AppConstants.Games_PHYSICAL_PRODUCT_TYPE);
            system.assertEquals(pro.International_Product__c,false); 
            system.assertEquals(pro.International_Reporting__c,false); 
        }
        
        Test.startTest();
        CRM_InsertPBEPOnProductListPriceBatch a =new CRM_InsertPBEPOnProductListPriceBatch();
        database.executebatch(a,400);
        Test.stopTest(); 
       
        List<Pricebook_Entry_Period__c> pbepList = [Select Account_Price__c,Id,CurrencyIsoCode FROM Pricebook_Entry_Period__c]; 
        System.assertEquals(400,pbepList.size());
        for(Pricebook_Entry_Period__c pbe : pbepList){
            if(pbe.CurrencyIsoCode == CRM_AppConstants.GBP_CURRENCY_CODE){
                System.assertEquals(null,pbe.Account_Price__c);   
            }
            if(pbe.CurrencyIsoCode == CRM_AppConstants.EUR_CURRENCY_CODE){
                System.assertEquals(13,pbe.Account_Price__c);   
            }
        } 
    }
    static testmethod void testBulkDataForGamesPhysicalBothPricesUpdateSecond_International(){
        createTestData(); 
        pb.International__c=true;
        update pb;
        
        Pricebook2 pb2 = new PriceBook2();
        pb2.Name = 'TestUK - ROE';
        pb2.Currency__c = 'USD';
        pb2.External_Id__c = 'UK - ROE';
        pb2.Business_Unit__c = '6000';
        pb2.IsActive = true;
        Insert pb2;
        
        //Create Products
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),200,false);
        Integer prodCountflag = 0;
        
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCountflag ;
            objProduct.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
            objProduct.Local_Title__c = lstLocalData[0].Id;
            objProduct.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            objProduct.Franchise_Type__c = 'TV';
            objProduct.SAP_Sales_Org__c = '6000';
            objProduct.Product_Format__c = '4';
            objProduct.International_Reporting__c=true; 
            objProduct.street_date__c = System.today()+1;
            prodCountflag ++;
        }
        insert lstProduct;
        
        system.assertEquals(200,[select Count() from Product2]);
        
        List<Product2> videoDigitalPro = [Select Id,Type__c,UK_List_Price_EUR__c,International_Product__c,International_Reporting__c,UK_List_Price_GBP__c,Product_Group__c From Product2 limit 200]; 
         
        //Assert for Product Type equal to Video Physical
        for(Product2 pro : videoDigitalPro){
            system.assertEquals(pro.Type__c,CRM_AppConstants.Games_PHYSICAL_PRODUCT_TYPE);
            system.assertEquals(pro.International_Product__c,true); 
            system.assertEquals(pro.International_Reporting__c,true); 
        }
        
        List<PricebookEntry> lstPriceBookEntriesEUR = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, false);
        for(PricebookEntry pberec : lstPriceBookEntriesEUR){
            pberec.CurrencyISOCode = CRM_AppConstants.EUR_CURRENCY_CODE;
            pberec.UnitPrice = 4;
        }
        insert lstPriceBookEntriesEUR ;
        
        List<PricebookEntry> lstPriceBookEntriesGBP = CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, false);
        for(PricebookEntry pberec : lstPriceBookEntriesGBP){
            pberec.CurrencyISOCode = CRM_AppConstants.GBP_CURRENCY_CODE;
            pberec.UnitPrice = 5;
        } 
        insert lstPriceBookEntriesGBP ;
        Integer pbeCounter = [Select count() FROM PricebookEntry]; 
        System.assertEquals(400,pbeCounter);
        
        // Create Account records
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(2, false);
        lstAccounts[0].scheduleRevenueChanged__c = false;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccounts[0].Price_Book__c = pb.Id;
        lstAccounts[0].currencyisocode = CRM_AppConstants.EUR_CURRENCY_CODE;
        lstAccounts[0].Games_Physical__c = true;
        lstAccounts[0].Video_Physical__c = true;
        lstAccounts[1].scheduleRevenueChanged__c = false;
        lstAccounts[1].Sales_Organization__c = CRM_AppConstants.TERRITORY_UK_CODE;
        lstAccounts[1].Price_Book__c = pb2.Id;
        lstAccounts[1].currencyisocode = CRM_AppConstants.GBP_CURRENCY_CODE;
        lstAccounts[1].Games_Physical__c = true;
        lstAccounts[1].Video_Physical__c = true;
        insert  lstAccounts; 
        
        Test.startTest();
        CRM_InsertPBEPOnProductListPriceBatch a =new CRM_InsertPBEPOnProductListPriceBatch();
        database.executebatch(a,400);
        Test.stopTest(); 
       
        List<Pricebook_Entry_Period__c> pbepList = [Select Account_Price__c,Id,CurrencyIsoCode FROM Pricebook_Entry_Period__c]; 
        System.assertEquals(200,pbepList.size());
        for(Pricebook_Entry_Period__c pbe : pbepList){
            if(pbe.CurrencyIsoCode == CRM_AppConstants.GBP_CURRENCY_CODE){
                System.assertEquals(null,pbe.Account_Price__c);   
            }
            if(pbe.CurrencyIsoCode == CRM_AppConstants.EUR_CURRENCY_CODE){
                System.assertEquals(13,pbe.Account_Price__c);   
            }
        } 
    }
    static testMethod void test_CRM_CRM_InsertPBEPOnProdListPriceScheduler(){
      Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        
      Test.startTest();
          String jobId = System.schedule('Test AutoTargetProductInsert', CRON_EXP, new CRM_InsertPBEPOnProdListPriceScheduler () );
        Test.stopTest();
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        if(ct != null){
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
        }
    }
}