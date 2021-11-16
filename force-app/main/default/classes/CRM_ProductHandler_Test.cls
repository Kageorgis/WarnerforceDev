/**
@Author-Cognizant Technology Solutions
@name-CRM_ProductPricingHandler_Test
@CreateDate
@Description-The class is used to check scenarios that occur while calculating the Account Price on Deal Product
@Version-<1.0>
@reference-None
*/
@isTest
private class CRM_ProductHandler_Test{

    static void createCustomSetting(){  
        /*List<Product_Group__c> productGroupList = new List<Product_Group__c>();
        for(integer i=0;i<5;i++){
            Product_Group__c pg = new Product_Group__c();
            pg.name = 'Test '+i;
            pg.External_Id__c = 'Test External Id '+i;
            productGroupList.add(pg);
        }
        insert productGroupList;*/
        
        Product_Group__c pg1 = new Product_Group__c();
        pg1.name = 'FR Digital TV EST';
        pg1.External_Id__c = 'FR Digital TV EST';
        //insert pg1;
        
        Product_Group__c pg2 = new Product_Group__c();
        pg2.name = 'Digital HBO';
        pg2.External_Id__c = 'UK Digital HBO';
        pg2.Country__c = 'UK';
        pg2.Type__c = 'Video Digital';

        Product_Group__c pg12 = new Product_Group__c();
        pg12.name = 'WB Partner US';
        pg12.External_Id__c = 'WB Partner US';
        pg12.Country__c = 'US';
        pg12.Type__c = 'Video Physical';
        insert new List<Product_Group__c>{pg1,pg2,pg12};
        
        system.debug('pg1.Id:::::::'+pg1.Id);
        
        system.assertEquals(3,[select count() from Product_Group__c ]);
        //List<CRM_Product_Group_Update__c> csList = new List<CRM_Product_Group_Update__c>();
        
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
        //csList.add(cs1);
        
        CRM_Product_Group_Update__c cs6 = new CRM_Product_Group_Update__c();
        cs6.Name = 'Set IE|GB 8';
        cs6.Content_Type__c = '';
        cs6.Country__c = '(IE|GB)';
        cs6.Franchise__c = '';
        cs6.Group__c = pg2.External_Id__c;
        cs6.ID__c = pg2.Id;
        cs6.Order__c = 1;
        cs6.Type__c = 'Video Digital';
        cs6.Product_Genre__c = '';
        cs6.Product_Label__c = '';
        cs6.Product_Market__c = '';
        cs6.Display_Label__c = 'HBO';
 
        CRM_Product_Group_Update__c cs12 = new CRM_Product_Group_Update__c();
        cs12.Name = 'JV12';
        cs12.Content_Type__c = '';
        cs12.Country__c = 'US';
        cs12.Format__c = '4';
        cs12.Franchise__c = '';
        cs12.Group__c = '';
        cs12.ID__c = pg12.Id;
        cs12.Order__c = 1;
        cs12.Type__c = 'Video Physical';
        cs12.Product_Genre__c = '';
        cs12.Product_Label__c = '(HBO|MGD|WWE|VIZ|BBC)';
        cs12.Product_Market__c = '';
        cs12.Product_Market_Entry__c = 'NEW RELEASE';
        cs12.Product_Owner__c = '(Warner Bros.|Universal-Warner Bros JV)';
        cs12.Sales_Org__c = '9500';
        
        /*
        CRM_Product_Group_Update__c cs4 = new CRM_Product_Group_Update__c();
        cs4.Name = 'step';
        cs4.Country__c = 'UK';
        cs4.Group__c = productGroupList.get(3).External_Id__c;
        cs4.ID__c = productGroupList.get(3).Id;
        cs4.Order__c = 2;
        cs4.Type__c = 'Games Digital';
        cs4.Franchise__c = 'X10';
        cs4.Product_Genre__c = '';
        cs4.Product_Label__c = '';
        cs4.Product_Market__c = '';
        csList.add(cs4);
        
        CRM_Product_Group_Update__c cs5 = new CRM_Product_Group_Update__c();
        cs5.Name = 'CS5';
        cs5.Country__c = 'UK';
        cs5.Group__c = productGroupList.get(4).External_Id__c;
        cs5.ID__c = productGroupList.get(4).Id;
        cs5.Order__c = 2;
        cs5.Type__c = 'Games Physical';
        cs5.Franchise__c = 'X6';
        cs5.Product_Genre__c = '';
        cs5.Product_Label__c = '';
        cs5.Product_Market__c = '';
        csList.add(cs5);
        
        CRM_Product_Group_Update__c cs3 = new CRM_Product_Group_Update__c();
        cs3.Name = 'CS3';
        cs3.Country__c = 'UK';
        cs3.Group__c = productGroupList.get(2).External_Id__c;
        cs3.ID__c = productGroupList.get(2).Id;
        cs3.Order__c = 3;
        cs3.Type__c = 'Games Physical';
        cs3.Format__c = 'DVD';
        cs3.Product_Genre__c = '';
        cs3.Product_Label__c = '';
        cs3.Product_Market__c = '';
        csList.add(cs3);
        
        CRM_Product_Group_Update__c cs2 = new CRM_Product_Group_Update__c();
        cs2.Name = 'CS2';
        cs2.Country__c = 'UK';
        cs2.Group__c = productGroupList.get(4).External_Id__c;
        cs2.ID__c = productGroupList.get(1).Id;
        cs2.Order__c = 2;
        cs2.Type__c = 'SBOM';
        cs2.Product_Genre__c = '';
        cs2.Product_Label__c = '';
        cs2.Product_Market__c = '';
        csList.add(cs2);
        */
        insert new List<CRM_Product_Group_Update__c>{cs1,cs6,cs12};
        system.assertEquals(3,[select count() from CRM_Product_Group_Update__c ]);
    }
    
    //Added by Praharsh
    
     static testmethod void testDataForVedioDigitalAndGamesDigitalforFR(){   
        //Create Custom setting
        createCustomSetting();
        
        Product_Group__c pg2 = new Product_Group__c();
        pg2.name = 'Japan PG';
        pg2.External_Id__c = 'Japan PG';
        insert pg2;
        
        system.debug('pg2.Id:::::::'+pg2.Id);
        
        List<String> strRegion = new List<String>();    
        strRegion.add('FR');
                                
        //create country
        List<Country__c> lstCountries = CRM_TestDataFactory.createCountries(strRegion, 1, true);
        List<Language__c> lstLang = CRM_TestDataFactory.createLanguages(2, true);
                                
        //create tittle 
        Title__c tittle = new title__c();
        tittle.name = 'Tittle';
        tittle.Content_Type__c = null;
        /*
        Title__c tittle2 = new title__c();
        tittle2.name = 'Tittle';
        tittle2.Content_Type__c = 'Music';
        */
        List<Title__c> lstTitle = new List<Title__c>{tittle};
        insert lstTitle;
        
        system.debug('lstTitle::::::'+lstTitle);
        
        system.assertEquals(1,[select count() from Title__c]);
                                
        //create local data
        List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(lstCountries, lstLang,1, false);
        lstLocalData[0].Title__c = lstTitle[0].Id;
        insert lstLocalData;
        system.assertEquals(1,[select count() from Local_Title__c]);
        system.debug('lstLocalData:::::'+lstLocalData);
        
        PriceBook2 pb = new PriceBook2();
        pb.Name = 'WHV-FR';
        pb.Business_Unit__c = '6007';
        pb.External_Id__c = '6007-10';
        insert pb;
        
        Test.startTest();
                                
        //Create Products
        //List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,false);
        //Integer prodCountflag = 0;
        
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        /*for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCountflag ;
            objProduct.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            objProduct.Local_Title__c = lstLocalData[1].Id;  
            objProduct.Product_Format__c = ''; 
            objProduct.Product_Genre__c = '';
            objProduct.Product_Label__c  = '';
            objProduct.Product_Market__c = '';
            prodCountflag ++;
        }*/
        Product2 objProduct = new Product2();
        objProduct.Product_Format__c = ''; 
        objProduct.Franchise_Type__c = 'TV';
        objProduct.Product_Genre__c = '';
        objProduct.Product_Label__c  = '';
        objProduct.Product_Market__c = 'EST';               
        objProduct.Name = 'PR1 ';
        objProduct.NR_period_weeks__c = 2;                
        objProduct.Street_Date__c = System.today()-40;             
        objProduct.NR_period_weeks__c = 7;         
        objProduct.Product_Group__c = pg2.Id;  
        objProduct.Delivery_Lead_Days__c = 4;
        objProduct.IsActive = true;
        objProduct.CanUseQuantitySchedule = true;
        objProduct.SAP_Dist_chain_product_Status__c = '01';
        objProduct.CanUseRevenueSchedule = true;
        objProduct.External_Id__c = string.valueOf(math.random());
        objProduct.Local_Title__c = lstLocalData[0].Id;
        
        insert objProduct;
        system.assertEquals(1,[select Count() from Product2]);
        
        Product2 videoDigitalPro = [Select Id,Type__c,Product_Group__c, Local_Title__c,  Franchise_Type__c, Product_Format__c, Product_Genre__c, Product_Label__c, Product_Market__c From Product2 limit 1];
        CRM_Product_Group_Update__c csWithCT = [Select Id,ID__c, Franchise__c, Format__c, Content_Type__c, Product_Genre__c, Product_Label__c, Product_Market__c From CRM_Product_Group_Update__c Where Name = 'step1'];
        system.debug('videoDigitalPro::::'+videoDigitalPro);
        system.debug('csWithCT::::'+csWithCT);
        //Assert for Product Type eqal to Video Digital
        system.assertEquals(videoDigitalPro.Type__c,CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE);
        //Assert for Product Group updated on Product for Content Type
        system.assertEquals(csWithCT.ID__c,videoDigitalPro.Product_Group__c );
        
        //lstProduct[0].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
        //lstProduct[0].Local_Title__c = lstLocalData[0].Id; 
        //lstProduct[0].Franchise_Type__c = 'X10';
        
        //update lstProduct;
        
        //Product2 GamesDigitalPro = [Select Id,Type__c,Product_Group__c From Product2 limit 1];
        //CRM_Product_Group_Update__c csWithFranchise = [Select Id,ID__c From CRM_Product_Group_Update__c Where Franchise__c = 'X10'];
        
        //Assert for Product Type eqal to GAMES Digital
        //system.assertEquals(GamesDigitalPro.Type__c,CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE);
        //Assert for Product Group updated on Product for Franchise
        //system.assertEquals(csWithFranchise.ID__c,GamesDigitalPro.Product_Group__c );
        
        Test.stopTest();
     } 
    
    /*
    static testmethod void testDataForVedioDigitalAndGamesDigital(){   
        //Create Custom setting
        createCustomSetting();
        
        List<String> strRegion = new List<String>();    
        strRegion.add('UK');
                                
        //create country
        List<Country__c> lstCountries = CRM_TestDataFactory.createCountries(strRegion, 2, true);
        List<Language__c> lstLang = CRM_TestDataFactory.createLanguages(2, true);
                                
        //create tittle 
        Title__c tittle = new title__c();
        tittle.name = 'Tittle';
        tittle.Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        
        Title__c tittle2 = new title__c();
        tittle2.name = 'Tittle';
        tittle2.Content_Type__c = 'Music';
        
        List<Title__c> lstTitle = new List<Title__c>{tittle,tittle2};
        insert lstTitle;
        
        system.debug('lstTitle::::::'+lstTitle);
        
        system.assertEquals(2,[select count() from Title__c]);
                                
        //create local data
        List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(lstCountries, lstLang, 2, false);
        lstLocalData[0].Title__c = lstTitle[0].Id;
        lstLocalData[1].Title__c = lstTitle[1].Id;
        insert lstLocalData;
        system.assertEquals(2,[select count() from Local_Title__c]);
        
        PriceBook2 pb = new PriceBook2();
        pb.Name = 'WHV-FR';
        pb.Business_Unit__c = '6007';
        pb.External_Id__c = '6007-10';
        insert pb;
        
        Test.startTest();
                                
        //Create Products
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,false);
        Integer prodCountflag = 0;
        
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCountflag ;
            objProduct.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            objProduct.Local_Title__c = lstLocalData[1].Id;  
            objProduct.Product_Format__c = ''; 
            objProduct.Product_Genre__c = '';
            objProduct.Product_Label__c  = '';
            objProduct.Product_Market__c = '';
            prodCountflag ++;
        }
        lstProduct[0].RecordTypeId = null;
        lstProduct[0].Product_Format__c = null;
        lstProduct[0].Product_Genre__c = null;
        lstProduct[0].Product_Market__c = null;
        lstProduct[0].Product_Label__c = null;
        lstProduct[0].Type__c = 'Games Physical';
        
        insert lstProduct;
        system.assertEquals(1,[select Count() from Product2]);
        
        Product2 videoDigitalPro = [Select Id,Type__c,Product_Group__c, Local_Title__c,  Franchise_Type__c, Product_Format__c, Product_Genre__c, Product_Label__c, Product_Market__c From Product2 limit 1];
        CRM_Product_Group_Update__c csWithCT = [Select Id,ID__c, Franchise__c, Format__c, Content_Type__c, Product_Genre__c, Product_Label__c, Product_Market__c From CRM_Product_Group_Update__c Where Content_Type__c = 'Music'];
        system.debug('videoDigitalPro::::'+videoDigitalPro);
        system.debug('csWithCT::::'+csWithCT);
        //Assert for Product Type eqal to Video Digital
        system.assertEquals(videoDigitalPro.Type__c,CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE);
        //Assert for Product Group updated on Product for Content Type
        system.assertEquals(csWithCT.ID__c,videoDigitalPro.Product_Group__c );
        
        lstProduct[0].RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
        lstProduct[0].Local_Title__c = lstLocalData[0].Id; 
        lstProduct[0].Franchise_Type__c = 'X10';
        
        update lstProduct;
        
        Product2 GamesDigitalPro = [Select Id,Type__c,Product_Group__c From Product2 limit 1];
        CRM_Product_Group_Update__c csWithFranchise = [Select Id,ID__c From CRM_Product_Group_Update__c Where Franchise__c = 'X10'];
        
        //Assert for Product Type eqal to GAMES Digital
        system.assertEquals(GamesDigitalPro.Type__c,CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE);
        //Assert for Product Group updated on Product for Franchise
        system.assertEquals(csWithFranchise.ID__c,GamesDigitalPro.Product_Group__c );
        
        Test.stopTest();
     } */
    
    static testmethod void testDataForGamesDigitalWithZESTSapMaterial(){
        //Create Custom setting
        createCustomSetting();
        
        List<String> strRegion = new List<String>();    
        strRegion.add('UK');
                                
        //create country
        List<Country__c> lstCountries = CRM_TestDataFactory.createCountries(strRegion, 1, true);
        List<Language__c> lstLang = CRM_TestDataFactory.createLanguages(1, true);
                                
        //create tittle 
        Title__c tittle = new title__c();
        tittle.name = 'Tittle';
        tittle.Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert tittle;
        system.assertEquals(1,[select count() from Title__c]);
        
        Test.startTest();
                                
        //create local data
        List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(lstCountries, lstLang, 1, false);
        lstLocalData[0].Title__c = tittle.Id;
        insert lstLocalData;
        system.assertEquals(1,[select count() from Local_Title__c]);
        
        //Create Products
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,false);
        Integer prodCountflag = 0;
        
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCountflag ;
            objProduct.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
            objProduct.Local_Title__c = lstLocalData[0].Id;
            objProduct.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
            prodCountflag ++;
        }
        
        insert lstProduct;
        system.assertEquals(1,[select Count() from Product2]);
        
        Product2 gamesDigitalPro = [Select Id,Type__c,Product_Group__c From Product2 limit 1];
       
        //Assert for Product Type eqal to Games Digital
        system.assertEquals(gamesDigitalPro.Type__c,CRM_AppConstants.GAMES_DIGITAL_PRODUCT_TYPE);
        
        Test.stopTest();
        
    }
    /*
    static testmethod void testDataForGamesDigitalWithFERTSapMaterial(){
        //Create Custom setting
        createCustomSetting();
        
        List<String> strRegion = new List<String>();    
        strRegion.add('UK');
                                
        //create country
        List<Country__c> lstCountries = CRM_TestDataFactory.createCountries(strRegion, 1, true);
        List<Language__c> lstLang = CRM_TestDataFactory.createLanguages(1, true);
                                
        //create tittle 
        Title__c tittle = new title__c();
        tittle.name = 'Tittle';
        tittle.Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert tittle;
        
        system.assertEquals(1,[select count() from Title__c]);
                                
        //create local data
        List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(lstCountries, lstLang, 1, false);
        lstLocalData[0].Title__c = tittle.Id;
        insert lstLocalData;
        system.assertEquals(1,[select count() from Local_Title__c]);
        
        Test.startTest();
        
        //Create Products
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,false);
        Integer prodCountflag = 0;
        
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCountflag ;
            objProduct.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
            objProduct.Local_Title__c = lstLocalData[0].Id;
            objProduct.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            objProduct.Product_Format__c = 'DVD';
            prodCountflag ++;
        }
        
        insert lstProduct;
        system.assertEquals(1,[select Count() from Product2]);
        
        Product2 videoDigitalPro = [Select Id,Type__c,Product_Group__c From Product2 limit 1];
        CRM_Product_Group_Update__c csWithFormat = [Select Id,ID__c From CRM_Product_Group_Update__c Where Format__c = 'DVD'];
        
        //Assert for Product Type eqal to Games Digital
        system.assertEquals(videoDigitalPro.Type__c,CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE );
        //Assert for Product Group updated on Product for Formate
        system.assertEquals(csWithFormat.ID__c,videoDigitalPro.Product_Group__c );
        
        Test.stopTest();
    } */
    
    static testmethod void testDataForVedioPhysicallWithFERTSapMaterial(){
        //Create Custom setting
        createCustomSetting();
        
        List<String> strRegion = new List<String>();    
        strRegion.add('UK');
                                
        //create country
        List<Country__c> lstCountries = CRM_TestDataFactory.createCountries(strRegion, 1, true);
        List<Language__c> lstLang = CRM_TestDataFactory.createLanguages(1, true);
                                
        //create tittle 
        Title__c tittle = new title__c();
        tittle.name = 'Tittle';
        tittle.Content_Type__c = 'Music';
        insert tittle;
        
        system.assertEquals(1,[select count() from Title__c]);
                                
        //create local data
        List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(lstCountries, lstLang, 1, false);
        lstLocalData[0].Title__c = tittle.Id;
        insert lstLocalData;
        system.assertEquals(1,[select count() from Local_Title__c]);
        
        Test.startTest();
        
        //Create Products
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,false);
        Integer prodCountflag = 0;
        
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCountflag ;
            objProduct.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
            objProduct.Local_Title__c = lstLocalData[0].Id;
            objProduct.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            prodCountflag ++;
        }
        
        insert lstProduct;
        system.assertEquals(1,[select Count() from Product2]);
        
        Product2 videoDigitalPro = [Select Id,Type__c,Product_Group__c From Product2 limit 1];
        
        //Assert for Product Type eqal to Vedio Physical
        system.assertEquals(videoDigitalPro.Type__c,CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE);
        
        Test.stopTest();
        
    } 

    /*
    static testmethod void testDataForSBOMProductWithSBOMSapMaterial(){
        //Create Custom setting
        createCustomSetting();
        
        List<String> strRegion = new List<String>();    
        strRegion.add('UK');
                                
        //create country
        List<Country__c> lstCountries = CRM_TestDataFactory.createCountries(strRegion, 1, true);
        List<Language__c> lstLang = CRM_TestDataFactory.createLanguages(1, true);
                                
        //create tittle 
        Title__c tittle = new title__c();
        tittle.name = 'Tittle';
        tittle.Content_Type__c = 'Music';
        insert tittle;
        
        system.assertEquals(1,[select count() from Title__c]);
                                
        //create local data
        List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(lstCountries, lstLang, 1, false);
        lstLocalData[0].Title__c = tittle.Id;
        insert lstLocalData;
        system.assertEquals(1,[select count() from Local_Title__c]);
        
        Test.startTest();
        
        //Create Products
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,false);
        Integer prodCountflag = 0;
        
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCountflag ;
            objProduct.Local_Title__c = lstLocalData[0].Id;
            objProduct.SAP_Material_Type__c = CRM_AppConstants.SBOM_SAP_MATERIAL_TYPE;
            prodCountflag ++;
        }
        
        insert lstProduct;
        system.assertEquals(1,[select Count() from Product2]);
        
        Product2 SBOMPro = [Select Id,Type__c,Product_Group__c  From Product2 limit 1];
        CRM_Product_Group_Update__c csWithNullValues = [Select Id,ID__c From CRM_Product_Group_Update__c Where Format__c = null AND Franchise__c = null AND Content_Type__c = null];
        
        //Assert for Product Type eqal to SBOM Product
        system.assertEquals(SBOMPro.Type__c,CRM_AppConstants.SBOM_PRODUCT_TYPE);
        //Assert for Product Group updated on Product for Null Values of Format,Franchise and Content Type
        system.assertEquals(csWithNullValues.ID__c,SBOMPro.Product_Group__c);
        
        Test.stopTest();
        
    } */
    
    static testmethod void testDataForUNBWProductWithUNBWSapMaterial(){
        
        //Creating Custom Setting records
        CRM_Trigger_Switches_For_ON_OFF__c CRMTS = new CRM_Trigger_Switches_For_ON_OFF__c();
        CRMTS.Name = 'CRM_Product_PBEP_UNBW';
        CRMTS.IsActive__c = True;
        insert CRMTS;
        
        createCustomSetting();
        
        List<String> strRegion = new List<String>();    
        strRegion.add('UK');
                                
        //create country
        List<Country__c> lstCountries = CRM_TestDataFactory.createCountries(strRegion, 1, true);
        List<Language__c> lstLang = CRM_TestDataFactory.createLanguages(1, true);
                                
        //create tittle 
        Title__c tittle = new title__c();
        tittle.name = 'Tittle';
        tittle.Content_Type__c = 'Music';
        insert tittle;
        
        system.assertEquals(1,[select count() from Title__c]);
                                
        //create local data
        List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(lstCountries, lstLang, 1, false);
        lstLocalData[0].Title__c = tittle.Id;
        insert lstLocalData;
        system.assertEquals(1,[select count() from Local_Title__c]);
        
        PriceBook2 pb = new PriceBook2();
        pb.Name = 'WHV-FR';
        pb.Business_Unit__c = '6007';
        pb.External_Id__c = '6007-10';
        insert pb;
        
        Test.startTest(); 
         
        //Create Products
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,false);
        Integer prodCountflag = 0;
        
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCountflag ;
            objProduct.Local_Title__c = lstLocalData[0].Id;
            objProduct.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            objProduct.SAP_Material_Type__c = CRM_AppConstants.UNBW_SAP_MATERIAL_TYPE;
            objProduct.SAP_Sales_Org__c = '6007';
            objProduct.SAP_Distribution_Id__c = '10';
            prodCountflag ++;
        }
        
        insert lstProduct;
        system.assertEquals(1,[select Count() from Product2]);
        
        BOM__c bom = new BOM__c(
            Parent_Product__c = lstProduct[0].Id,
            Quantity__c = 1
        );
        insert bom;
        
        Product2 UNBWPro = [Select Id,Type__c From Product2 limit 1];
        
        //Assert for Product Type eqal to SBOM Product
        system.assertEquals(UNBWPro.Type__c,CRM_AppConstants.UNBW_PRODUCT_TYPE);
        
        //system.debug('**lstmodifiedProduct**'+lstmodifiedProduct);
        //for games physical
        Integer countPBEP = [Select count() from Pricebook_Entry_Period__c];
        system.assertEquals(prodCountflag ,countPBEP);
        Integer countPBE = [Select count() from PricebookEntry];
        system.assertEquals(2*prodCountflag ,countPBE);
        
        lstProduct[0].SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
        lstProduct[0].Pack_Type__c = CRM_AppConstants.PRODUCT_PACK_TYPE_MultiPack;
        
        update lstProduct;
        
        Product2 updateSapMaterial = [Select Id,SAP_Material_Type__c From Product2 limit 1];
        
        //Assert for Product SAP Material Type eqal to SBOM Type
        system.assertEquals(updateSapMaterial.SAP_Material_Type__c , CRM_AppConstants.SBOM_SAP_MATERIAL_TYPE);
        
        Test.stopTest(); 
    } 
    
     /**
    *  @name test_RestrictToModifyProductMarket
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testmethod void test_RestrictToModifyProductMarket() {
        // Insert Account
        List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false);
        lstAccounts[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        lstAccounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_JAPAN_CODE;
        lstAccounts[0].CurrencyISOCode = 'JPY';
        lstAccounts[0].Games_Physical__c = true;
        insert lstAccounts;
        
        // Create Product Group 
        List<Product_Group__c> lstProductGroups = CRM_TestDataFactory.createProductGroups(1, true);
        // Create Products 
        List<Product2> lstProducts = CRM_TestDataFactory.createProducts(lstProductGroups,2, false);
        
        //update all 5 product records
         for (Integer i=0; i < lstProducts.size(); i++) {
             lstProducts[i].Product_Market__c = '1';
             lstProducts[i].CurrencyIsoCode = 'JPY';
         }
         insert lstProducts;
          Product2 productRecord = lstProducts[0];
          
         //Create PricebookEntrys
         List<PricebookEntry> lstPriceBookEntry = CRM_TestDataFactory.createPriceBookEntries(lstProducts,1,false);
         lstPriceBookEntry[0].Product2Id = productRecord.Id;
         lstPriceBookEntry[0].CurrencyIsoCode = 'JPY';
         insert lstPriceBookEntry;
        
        // Setting up 1 Price Book Entry Period for USD Pricebook
        List<Pricebook_Entry_Period__c>  lstPriceBookEntryPeriodNewlyInsertedPBEP1 =
        CRM_TestDataFactory.createPriceBookEntryPeriods(new List<Product2>{productRecord}, 1, false);
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Product__c = productRecord.id;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Start_Date__c = System.today() + 140;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].End_Date__c = System.today() + 150;
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].CurrencyIsoCode = 'JPY';
        lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].List_Price__c = 10;
        insert lstPriceBookEntryPeriodNewlyInsertedPBEP1;
         
         //Create Deal
         List<Opportunity> lstOppotunity = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccounts,1,false);
         for (Integer i=0; i < lstOppotunity.size(); i++) {
             lstOppotunity[i].Market_Type__c = '1';
             lstOppotunity[i].RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
             lstOppotunity[i].Start_Date__c = System.today() + 141;
             lstOppotunity[i].Promo_Start_Date__c = System.today() + 141;
             lstOppotunity[i].CloseDate = System.today() + 149;
         }
         insert lstOppotunity;
         
         //Create Deal Products
         List<OpportunityLineItem> lstDealProducts = CRM_TestDataFactory.createDealProductsWithOpportunities([SELECT Id FROM PricebookEntry WHERE CurrencyISOCode = 'JPY'],lstOppotunity,1,false);
         lstDealProducts[0].Pricebook_Entry_Period__c = lstPriceBookEntryPeriodNewlyInsertedPBEP1[0].Id;
         insert lstDealProducts;
         
         
         try{
            lstProducts[0].Product_Market__c = '2';
            update lstProducts[0];
         }Catch(System.DmlException ex){
            Boolean expectedExceptionThrown =  (ex.getDmlMessage(0).contains('Product Market can not be change once Product assigned to Deal')) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
         }
    }

    //US JAPAN 561
    static testmethod void testDataForMusicPhysicalWithFERTSapMaterial(){
        
        List<String> strRegion = new List<String>();    
        strRegion.add('JP');
                                
        //create country
        List<Country__c> lstCountries = CRM_TestDataFactory.createCountries(strRegion, 1, false);
        lstCountries[0].Country_Code2__c = CRM_AppConstants.JAPAN_COUNTRY_CODE;
        insert lstCountries;
        List<Language__c> lstLang = CRM_TestDataFactory.createLanguages(1, true);
                                
        //create tittle 
        Title__c tittle = new title__c();
        tittle.name = 'Tittle';
        tittle.Content_Type__c = 'Music';
        insert tittle;
        
        system.assertEquals(1,[select count() from Title__c]);
                                
        //create local data
        List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(lstCountries, lstLang, 1, false);
        lstLocalData[0].Title__c = tittle.Id;
        insert lstLocalData;
        system.assertEquals(1,[select count() from Local_Title__c]);
        
        Test.startTest();
        
        //Create Products
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,false);
        Integer prodCountflag = 0;
        
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCountflag ;
            objProduct.Local_Title__c = lstLocalData[0].Id;
            objProduct.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            prodCountflag ++;
        }
        
        insert lstProduct;
        
        Product2 MusicPhysicalPro = [Select Id,Type__c,Product_Group__c From Product2 limit 1];
        
        //Assert for Product Type eqal to Vedio Physical
        system.assertEquals(MusicPhysicalPro.Type__c,CRM_AppConstants.MUSIC_PHYSICAL_PRODUCT_TYPE);
        
        Test.stopTest();
        
    } 
    
    //US JAPAN 561
    static testmethod void testDataForMusicDigitalWithZESTSapMaterial(){
        
        List<String> strRegion = new List<String>();    
        strRegion.add('JP');
                                
        //create country
        List<Country__c> lstCountries = CRM_TestDataFactory.createCountries(strRegion, 1,false);
        lstCountries[0].Country_Code2__c = CRM_AppConstants.JAPAN_COUNTRY_CODE;
        insert lstCountries;
        List<Language__c> lstLang = CRM_TestDataFactory.createLanguages(1, true);
                                
        //create tittle 
        Title__c tittle = new title__c();
        tittle.name = 'Tittle';
        tittle.Content_Type__c = 'Music';
        insert tittle;
        
        system.assertEquals(1,[select count() from Title__c]);
                                
        //create local data
        List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(lstCountries, lstLang, 1, false);
        lstLocalData[0].Title__c = tittle.Id;
        insert lstLocalData;
        system.assertEquals(1,[select count() from Local_Title__c]);
        
        Test.startTest();
        
        //Create Products
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),2,false);
        Integer prodCountflag = 0;
        
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCountflag ;
            objProduct.Local_Title__c = lstLocalData[0].Id;
            if(prodCountflag == 0)
                objProduct.SAP_Material_Type__c = CRM_AppConstants.ZEST_SAP_MATERIAL_TYPE;
            prodCountflag ++;
        }
        
        insert lstProduct;
        
        for(Product2 MusicDigitalPro : [Select Id,Type__c,Product_Group__c From Product2]){
            //Assert for Product Type eqal to Vedio Physical
            system.assertEquals(MusicDigitalPro.Type__c,CRM_AppConstants.MUSIC_DIGITAL_PRODUCT_TYPE);
        }
        
        Test.stopTest();
        
    } 
    
    //JAPAN US 515
    static testmethod void testDataForProductGroupUpdateForJAPAN(){
        
        Product_Group__c pg1 = new Product_Group__c();
        pg1.name = 'JP Product Group';
        pg1.External_Id__c = 'JP Product Group';
        insert pg1; 
        
        CRM_Product_Group_Update__c cs1 = new CRM_Product_Group_Update__c();
        cs1.Name = 'step1';
        cs1.Content_Type__c = '';
        cs1.Country__c = CRM_AppConstants.JAPAN_COUNTRY_CODE;
        cs1.Franchise__c = '';
        cs1.Format__c = '20';
        cs1.Group__c = pg1.External_Id__c;
        cs1.ID__c = pg1.Id;
        cs1.Order__c = 10;
        cs1.Type__c = 'Video Physical';
        cs1.Product_Genre__c = '';
        cs1.Product_Label__c = '';
        cs1.Product_Market__c = '';
        cs1.Product_Price_Group__c = 'C2';
        insert cs1;
        
        List<String> strRegion = new List<String>();    
        strRegion.add('JP');
                                
        //create country
        List<Country__c> lstCountries = CRM_TestDataFactory.createCountries(strRegion, 1,false);
        lstCountries[0].Country_Code2__c = CRM_AppConstants.JAPAN_COUNTRY_CODE;
        insert lstCountries;
        List<Language__c> lstLang = CRM_TestDataFactory.createLanguages(1, true);
                                
        //create tittle 
        Title__c tittle = new title__c();
        tittle.name = 'Tittle';
        insert tittle;
        
        system.assertEquals(1,[select count() from Title__c]);
                                
        //create local data
        List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(lstCountries, lstLang, 1, false);
        lstLocalData[0].Title__c = tittle.Id;
        insert lstLocalData;
        system.assertEquals(1,[select count() from Local_Title__c]);
        
        Test.startTest();
        
        //Create Products
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,false);
        Integer prodCountflag = 0;
        
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCountflag ;
            objProduct.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
            objProduct.Local_Title__c = lstLocalData[0].Id;
            objProduct.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            objProduct.Product_Format__c = '20';
            objProduct.Product_Price_Group__c = 'C2';
            prodCountflag ++;
        }
        
        insert lstProduct;
        system.assertEquals(1,[select Count() from Product2]);
        
        Product2 videoPhysicalPro = [Select Id,Type__c,Product_Group__c From Product2 limit 1];
        
        //Assert for Product Type eqal to Vedio Physical
        system.assertEquals(videoPhysicalPro.Type__c,CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE);
        
        //Assert for Product Group
        system.assertEquals(videoPhysicalPro.Product_Group__c,cs1.ID__c);
        
        Test.stopTest();
        
    } 

    // REQ#478 : Test method for FR Custom Setting Records 
    static testmethod void testDataForProductGroupUpdateForFR(){
        
        Product_Group__c pg1 = new Product_Group__c();
        pg1.name = 'FR Product Group 1';
        pg1.External_Id__c = 'FR Product Group 1';
        insert pg1; 
        
        CRM_Product_Group_Update__c cs1 = new CRM_Product_Group_Update__c();
        cs1.Name = 'step1';
        cs1.Country__c = 'FR';
        cs1.Franchise__c = 'TV';
        cs1.Group__c = pg1.External_Id__c;
        cs1.ID__c = pg1.Id;
        cs1.Order__c = 10;
        cs1.Type__c = 'Video Digital';
        cs1.Product_Market__c = 'EST';
        insert cs1;
        
        Product_Group__c pg2 = new Product_Group__c();
        pg2.name = 'FR Product Group 2';
        pg2.External_Id__c = 'FR Product Group 2';
        insert pg2; 
        
        CRM_Product_Group_Update__c cs2 = new CRM_Product_Group_Update__c();
        cs2.Name = 'step2';
        cs2.Country__c = 'FR';
        
        cs2.Group__c = pg1.External_Id__c;
        cs2.ID__c = pg1.Id;
        cs2.Order__c = 10;
        cs2.Type__c = 'Games Physical';
        cs2.Special_Version__c = '69';
        insert cs2;
        
        List<String> strRegion = new List<String>();    
        strRegion.add('FR');
                                
        //create country
        List<Country__c> lstCountries = CRM_TestDataFactory.createCountries(strRegion, 1,false);
        lstCountries[0].Country_Code2__c = 'FR';
        insert lstCountries;
        List<Language__c> lstLang = CRM_TestDataFactory.createLanguages(1, true);
                                
        //create tittle 
        Title__c tittle = new title__c();
        tittle.name = 'Tittle';
        tittle.Content_Type__c = 'Season';
        insert tittle;
        
        system.assertEquals(1,[select count() from Title__c]);
                                
        //create local data
        List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(lstCountries, lstLang, 1, false);
        lstLocalData[0].Title__c = tittle.Id;
        insert lstLocalData;
        system.assertEquals(1,[select count() from Local_Title__c]);
        
        Test.startTest();
        
        //Create Products
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,false);
        Integer prodCountflag = 0;
        
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCountflag ;
            objProduct.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
            objProduct.Local_Title__c = lstLocalData[0].Id;
            objProduct.Franchise_Type__c = 'TV';
            objProduct.Product_Market__c = 'EST';
            objProduct.Product_Format__c = null;
            prodCountflag ++;
        }
        
        insert lstProduct;
        system.assertEquals(1,[select Count() from Product2]);
        
        Product2 videoDigitalPro = [Select Id,Type__c,Product_Group__c From Product2 limit 1];
        
        //Assert for Product Type eqal to Vedio Physical
        system.assertEquals(videoDigitalPro.Type__c,CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE);
        
        //Assert for Product Group
        system.assertEquals(videoDigitalPro.Product_Group__c,cs1.ID__c);
        
        //Update Title Content Type
        tittle.Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        update tittle;
        
        //Update Product
        videoDigitalPro.Franchise_Type__c = null;
        videoDigitalPro.Product_Market__c = null;
        videoDigitalPro.Special_Version__c = '69';
        videoDigitalPro.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
        update videoDigitalPro;
        
        Product2 GamePhysicalPro = [Select Id,Type__c,Product_Group__c From Product2 limit 1];
        
        //Assert for Product Type eqal to Game Physical
        system.assertEquals(CRM_AppConstants.GAMES_PHYSICAL_PRODUCT_TYPE,GamePhysicalPro.Type__c);
        
        //Assert for Product Group
        system.assertEquals(cs2.ID__c,GamePhysicalPro.Product_Group__c);
        
        Test.stopTest();
        
    } 

    /**
    *  @name test_DeletePrductsMethod
    *  @param None
    *  @return None
    *  @throws None  
    */
    /*static testmethod void test_DeletePrductsMethod() {
    
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),3,false);
        Integer prodCountflag = 0;
        
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCountflag ;
            objProduct.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            objProduct.Delete_Product__c = false;
            prodCountflag ++;
        }
        
        insert lstProduct;
        system.assertEquals(3,[select Count() from Product2]);
        
        Test.StartTest();
        lstProduct[0].Delete_Product__c = true;
        update lstProduct[0];
        Test.StopTest();
        
        system.assertEquals(2,[select Count() from Product2]);
        
    }*/    
   
    static testmethod void testDataForVedioPhysicalBothPrices(){
        //Create Custom setting
        createCustomSetting();
        
        CRM_Trigger_Switches_For_ON_OFF__c CRMTS = new CRM_Trigger_Switches_For_ON_OFF__c();
        CRMTS.Name = 'CRM_Product_PBEP_UNBW';
        CRMTS.IsActive__c = True;
        insert CRMTS;
        
        PriceBook2 pb = new PriceBook2();
        pb.Name = 'TestPB1';
        pb.Currency__c = 'USD';
        //pb.Distribution_Channel__c = '10';
        pb.External_Id__c = '6000-10-0012020726';
        pb.Business_Unit__c = '6000';
        pb.IsActive = true;
        Insert pb;
        
        Default_Pricing__c dp = new Default_Pricing__c();
        dp.Default_Price__c = 13;
        dp.Price_Book__c = pb.id;
        dp.Format__c = '4';
        dp.Franchise_Type__c = 'TV';
        dp.currencyisocode = CRM_AppConstants.GBP_CURRENCY_CODE;
        Insert dp;
        
        List<String> strRegion = new List<String>();    
        strRegion.add('UK');
                                
        //create country
        List<Country__c> lstCountries = CRM_TestDataFactory.createCountries(strRegion, 1, true);
        List<Language__c> lstLang = CRM_TestDataFactory.createLanguages(1, true);
                                
        //create tittle 
        Title__c tittle = new title__c();
        tittle.name = 'Tittle';
        tittle.Content_Type__c = 'Music';
        insert tittle;
        
        system.assertEquals(1,[select count() from Title__c]);
                                
        //create local data
        List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(lstCountries, lstLang, 1, false);
        lstLocalData[0].Title__c = tittle.Id;
        insert lstLocalData;
        system.assertEquals(1,[select count() from Local_Title__c]);
        
        //Create Products
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,false);
        Integer prodCountflag = 0;
        
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCountflag ;
            objProduct.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
            objProduct.Local_Title__c = lstLocalData[0].Id;
            objProduct.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            objProduct.UK_List_Price_EUR__c = 10;
            objProduct.UK_List_Price_GBP__c = 11;
            objProduct.Franchise_Type__c = 'TV';
            objProduct.SAP_Sales_Org__c = '6000';
            objProduct.Product_Format__c = '4';
            //objProduct.currencyisocode = 'EUR';
            prodCountflag ++;
        }
        
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
        
        insert lstProduct;
        system.assertEquals(1,[select Count() from Product2]);
        
        Product2 videoDigitalPro = [Select Id,Type__c,Product_Group__c From Product2 limit 1];
        
        //Assert for Product Type eqal to Vedio Physical
        system.assertEquals(videoDigitalPro.Type__c,CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE);
        
        Test.stopTest();
        
        Integer pbeCounter = [Select count() FROM PricebookEntry]; 
        System.assertEquals(4,pbeCounter);
        List<Pricebook_Entry_Period__c> pbepList = [Select Account_Price__c,Id,CurrencyIsoCode FROM Pricebook_Entry_Period__c]; 
        System.assertEquals(2,pbepList.size());
        for(Pricebook_Entry_Period__c pbe : pbepList){
            if(pbe.CurrencyIsoCode == CRM_AppConstants.GBP_CURRENCY_CODE){
                System.assertEquals(13,pbe.Account_Price__c);   
            }
             if(pbe.CurrencyIsoCode == CRM_AppConstants.EUR_CURRENCY_CODE){
                System.assertEquals(null,pbe.Account_Price__c);   
            }
        }
        
        
    } 
    
    static testmethod void testDataForVedioPhysicalBothPricesSecond(){
        //Create Custom setting
        createCustomSetting();
        
        CRM_Trigger_Switches_For_ON_OFF__c CRMTS = new CRM_Trigger_Switches_For_ON_OFF__c();
        CRMTS.Name = 'CRM_Product_PBEP_UNBW';
        CRMTS.IsActive__c = True;
        insert CRMTS;
        
        PriceBook2 pb = new PriceBook2();
        pb.Name = 'TestPB1';
        pb.Currency__c = 'USD';
        //pb.Distribution_Channel__c = '10';
        pb.External_Id__c = '6000-10-0012020726';
        pb.Business_Unit__c = '6000';
        pb.IsActive = true;
        Insert pb;
        
        Default_Pricing__c dp = new Default_Pricing__c();
        dp.Default_Price__c = 13;
        dp.Price_Book__c = pb.id;
        dp.Format__c = '4';
        dp.Franchise_Type__c = 'TV';
        dp.currencyisocode = CRM_AppConstants.EUR_CURRENCY_CODE;
        Insert dp;
        
        List<String> strRegion = new List<String>();    
        strRegion.add('UK');
                                
        //create country
        List<Country__c> lstCountries = CRM_TestDataFactory.createCountries(strRegion, 1, true);
        List<Language__c> lstLang = CRM_TestDataFactory.createLanguages(1, true);
                                
        //create tittle 
        Title__c tittle = new title__c();
        tittle.name = 'Tittle';
        tittle.Content_Type__c = 'Music';
        insert tittle;
        
        system.assertEquals(1,[select count() from Title__c]);
                                
        //create local data
        List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(lstCountries, lstLang, 1, false);
        lstLocalData[0].Title__c = tittle.Id;
        insert lstLocalData;
        system.assertEquals(1,[select count() from Local_Title__c]);
        
        //Create Products
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,false);
        Integer prodCountflag = 0;
        
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCountflag ;
            objProduct.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
            objProduct.Local_Title__c = lstLocalData[0].Id;
            objProduct.SAP_Material_Type__c = CRM_AppConstants.FERT_SAP_MATERIAL_TYPE;
            objProduct.UK_List_Price_EUR__c = 10;
            objProduct.UK_List_Price_GBP__c = 11;
            objProduct.Franchise_Type__c = 'TV';
            objProduct.SAP_Sales_Org__c = '6000';
            objProduct.Product_Format__c = '4';
            //objProduct.currencyisocode = 'EUR';
            prodCountflag ++;
        }
        
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
        
        insert lstProduct;
        system.assertEquals(1,[select Count() from Product2]);
        
        Product2 videoDigitalPro = [Select Id,Type__c,Product_Group__c From Product2 limit 1];
        
        //Assert for Product Type eqal to Vedio Physical
        system.assertEquals(videoDigitalPro.Type__c,CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE);
        
        Test.stopTest();
        
        Integer pbeCounter = [Select count() FROM PricebookEntry]; 
        System.assertEquals(4,pbeCounter);
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
        //Create Custom setting
        createCustomSetting();
        
        CRM_Trigger_Switches_For_ON_OFF__c CRMTS = new CRM_Trigger_Switches_For_ON_OFF__c();
        CRMTS.Name = 'CRM_Product_PBEP_UNBW';
        CRMTS.IsActive__c = True;
        insert CRMTS;
        
        PriceBook2 pb = new PriceBook2();
        pb.Name = 'TestPB1';
        pb.Currency__c = 'USD';
        //pb.Distribution_Channel__c = '10';
        pb.External_Id__c = '6000-10-0012020726';
        pb.Business_Unit__c = '6000';
        pb.IsActive = true;
        Insert pb;
        
        Default_Pricing__c dp = new Default_Pricing__c();
        dp.Default_Price__c = 13;
        dp.Price_Book__c = pb.id;
        dp.Format__c = '4';
        dp.Franchise_Type__c = 'TV';
        dp.currencyisocode = CRM_AppConstants.GBP_CURRENCY_CODE;
        Insert dp;
        
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
        List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(lstCountries, lstLang, 1, false);
        lstLocalData[0].Title__c = tittle.Id;
        insert lstLocalData;
        system.assertEquals(1,[select count() from Local_Title__c]);
        
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
            //objProduct.currencyisocode = 'EUR';
            prodCountflag ++;
        }
        
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
        
        
        
        insert lstProduct;
        system.assertEquals(1,[select Count() from Product2]);
        
        Product2 videoDigitalPro = [Select Id,Type__c,UK_List_Price_EUR__c,UK_List_Price_GBP__c,Product_Group__c From Product2 limit 1];
        
        //Assert for Product Type eqal to Vedio Physical
        system.assertEquals(videoDigitalPro.Type__c,CRM_AppConstants.Games_PHYSICAL_PRODUCT_TYPE);
        
        Test.startTest();
        
        videoDigitalPro.UK_List_Price_EUR__c = 10;
        videoDigitalPro.UK_List_Price_GBP__c = 11;
        update videoDigitalPro;
        
        Test.stopTest();
        
        Integer pbeCounter = [Select count() FROM PricebookEntry]; 
        System.assertEquals(4,pbeCounter);
        List<Pricebook_Entry_Period__c> pbepList = [Select Account_Price__c,Id,CurrencyIsoCode FROM Pricebook_Entry_Period__c]; 
        System.assertEquals(2,pbepList.size());
        
        for(Pricebook_Entry_Period__c pbe : pbepList){
            if(pbe.CurrencyIsoCode == CRM_AppConstants.GBP_CURRENCY_CODE){
                System.assertEquals(13,pbe.Account_Price__c);   
            }
             if(pbe.CurrencyIsoCode == CRM_AppConstants.EUR_CURRENCY_CODE){
                System.assertEquals(null,pbe.Account_Price__c);   
            }
        }
        
        
    } 
    
    static testmethod void testDataForGamesPhysicalBothPricesUpdateSecond(){
        //Create Custom setting
        createCustomSetting();
        
        CRM_Trigger_Switches_For_ON_OFF__c CRMTS = new CRM_Trigger_Switches_For_ON_OFF__c();
        CRMTS.Name = 'CRM_Product_PBEP_UNBW';
        CRMTS.IsActive__c = True;
        insert CRMTS;
        
        PriceBook2 pb = new PriceBook2();
        pb.Name = 'TestPB1';
        pb.Currency__c = 'USD';
        //pb.Distribution_Channel__c = '10';
        pb.External_Id__c = '6000-10-0012020726';
        pb.Business_Unit__c = '6000';
        pb.IsActive = true;
        Insert pb;
        
        Default_Pricing__c dp = new Default_Pricing__c();
        dp.Default_Price__c = 13;
        dp.Price_Book__c = pb.id;
        dp.Format__c = '4';
        dp.Franchise_Type__c = 'TV';
        dp.currencyisocode = CRM_AppConstants.EUR_CURRENCY_CODE;
        Insert dp;
        
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
        List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(lstCountries, lstLang, 1, false);
        lstLocalData[0].Title__c = tittle.Id;
        insert lstLocalData;
        system.assertEquals(1,[select count() from Local_Title__c]);
        
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
            //objProduct.currencyisocode = 'EUR';
            prodCountflag ++;
        }
        
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
        
        
        
        insert lstProduct;
        system.assertEquals(1,[select Count() from Product2]);
        
        Product2 videoDigitalPro = [Select Id,Type__c,UK_List_Price_EUR__c,UK_List_Price_GBP__c,Product_Group__c From Product2 limit 1];
        
        //Assert for Product Type eqal to Vedio Physical
        system.assertEquals(videoDigitalPro.Type__c,CRM_AppConstants.Games_PHYSICAL_PRODUCT_TYPE);
        
        Test.startTest();
        
        videoDigitalPro.UK_List_Price_EUR__c = 10;
        videoDigitalPro.UK_List_Price_GBP__c = 11;
        update videoDigitalPro;
        
        Test.stopTest();
        
        Integer pbeCounter = [Select count() FROM PricebookEntry]; 
        System.assertEquals(4,pbeCounter);
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
    
    //--ER-003627--//
    static testmethod void testDataForVideoDigitalHBOProductForUK(){
        //Create Custom setting
        createCustomSetting();
        
        List<String> strRegion = new List<String>();    
        strRegion.add('GB');

        //create country
        List<Country__c> lstCountries = CRM_TestDataFactory.createCountries(strRegion, 1, true);
        List<Language__c> lstLang = CRM_TestDataFactory.createLanguages(1, true);
                                
        //create tittle 
        Title__c tittle = new title__c();
        tittle.name = 'Tittle';
        //tittle.Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE;
        insert tittle;
        system.assertEquals(1,[select count() from Title__c]);
        
        Test.startTest();
                                
        //create local data
        List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(lstCountries, lstLang, 1, false);
        lstLocalData[0].Title__c = tittle.Id;
        lstLocalData[0].LT_DisplayStudio_Value__c = 'HBO';
        lstLocalData[0].DisplayStudioOverride__c = 'HBO';
        insert lstLocalData;
        system.assertEquals(1,[select count() from Local_Title__c]);
        
        //Create Products
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(CRM_TestDataFactory.createProductGroups(1,true),1,false);
        Integer prodCountflag = 0;
        
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCountflag ;
            objProduct.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL;
            objProduct.Local_Title__c = lstLocalData[0].Id;
            objProduct.Product_Group__c = null;
            objProduct.Type__c = CRM_AppConstants.VIDEO_DIGITAL_PRODUCT_TYPE;
            prodCountflag ++;
        }
        insert lstProduct;
        
        system.assertEquals(1,[select Count() from Product2]);
        Product2 videoDigitalHBOPro = [Select Id,Type__c,Country_Code__c,Display_Studio__c,Product_Group__c,Product_Group__r.Name From Product2 limit 1];
        system.debug('@@videoDigitalHBOPro-->'+videoDigitalHBOPro);
        system.assertEquals('Digital HBO',videoDigitalHBOPro.Product_Group__r.Name);
        
        Test.stopTest();
    }

    //--for JV Products--//
    static testmethod void testDataForJVVideoPhysicalProductForUS(){
        //Create Custom setting
        createCustomSetting();
        
        List<String> strRegion = new List<String>();    
        strRegion.add('US');

        //create country
        List<Country__c> lstCountries = CRM_TestDataFactory.createCountries(strRegion, 1, true);
        List<Language__c> lstLang = CRM_TestDataFactory.createLanguages(1, true);
                                
        //create tittle 
        Title__c tittle = new title__c();
        tittle.name = 'Tittle';
        insert tittle;
        system.assertEquals(1,[select count() from Title__c]);
        
        Test.startTest();
        //fetch Product Group
        List<Product_Group__c> pg = [Select Id,Name,Type__c,Country__c,External_Id__c From Product_Group__c Where Name = 'WB Partner US'];
        system.assertEquals('WB Partner US',pg[0].Name);

        //create local data
        List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(lstCountries, lstLang, 1, false);
        lstLocalData[0].Title__c = tittle.Id;
        insert lstLocalData;
        system.assertEquals(1,[select count() from Local_Title__c]);
        
        //Create Products
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(pg,1,false);
        Integer prodCountflag = 0;
        
        //Loops over Product list and modifies parameter so that it does not match with the File Discounts
        for (Product2 objProduct : lstProduct){
            objProduct.Name = 'Product '+ prodCountflag ;
            objProduct.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PRODUCT;
            objProduct.Local_Title__c = lstLocalData[0].Id;
            objProduct.Product_Group__c = null;
            objProduct.Type__c = CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE;
            objProduct.Product_Format__c = '4';
            objProduct.Product_Label__c = 'ABC BBC';
            objProduct.Product_Market__c = '';
            objProduct.Product_Market_Entry__c = 'NEW TO FORMAT';
            objProduct.Product_Owner__c = 'Warner Bros.';
            objProduct.SAP_Sales_Org__c = '9500';
            prodCountflag ++;
        }
        insert lstProduct;

        lstProduct[0].Type__c = CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE;
        lstProduct[0].Product_Market_Entry__c = 'NEW RELEASE';
        update lstProduct;
        
        system.assertEquals(1,[select Count() from Product2]);
        Product2 retJVProd = [Select Product_Group__r.Name From Product2 limit 1];
        system.assertEquals('WB Partner US',retJVProd.Product_Group__r.Name);

        lstProduct[0].Product_Label__c = 'VIZ BBC';
        update lstProduct;
        Product2 retJVProd1 = [Select Product_Group__r.Name From Product2 limit 1];
        system.assertEquals('WB Partner US',retJVProd1.Product_Group__r.Name);       
        
        Test.stopTest();
    }    
}