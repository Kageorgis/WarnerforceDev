/**
   @Author Cognizant
   @name v
   @CreateDate 9 Feb 2016
   @Description Test class for CRM_UploadAssortmentProductsController
   @Version <1.0>
   @reference Requirement no 392
*/
@isTest
private class CRM_UploadAssortmentProducts_Test {
   
    /**
    *  Create Test Data. 
    *  @name allTheDataForThisTestClass
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    
    static void allTheDataForThisTestClass(){
            Id soldToRecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
            
            //create accounts
            list<Account> accounts = CRM_TestDataFactory.createAccounts(1, false);
            accounts[0].recordTypeId = soldToRecordTypeId;
            insert accounts;
            
            //create bundle
            List<Bundle__c> lstBundles = CRM_TestDataFactory.createBundles(2, false);
            lstBundles[0].CurrencyIsoCode = 'USD';
            lstBundles[1].CurrencyIsoCode = 'USD';
            lstBundles[0].End_Date__c = system.today()+30;
            lstBundles[1].End_Date__c = system.today()+30;
            insert lstBundles;
            
            system.assertEquals(2,lstBundles.size());
            //create products and associate with Bundle
            List<Product_Group__c> pgs = CRM_TestDataFactory.createProductGroups(1, true);
            List<Product2> products = CRM_TestDataFactory.createProducts(pgs, 3, false);
            products[0].productCode= 'code1';
            products[0].Universal_Picture_Code__c ='upc1';
            products[1].productCode='code2';
            products[1].Universal_Picture_Code__c='upc2';
            products[2].productCode='code3';
            products[2].Universal_Picture_Code__c='upc3';
            insert products;
            
            List<PricebookEntry> pbEntries = CRM_TestDataFactory.createPriceBookEntries(products, 1, true);
            
            List<Pricebook_Entry_Period__c> pbe=CRM_TestDataFactory.createPriceBookEntryPeriods(new list<product2>{products[0],products[1]}, 1, true);
            
            List<Bundle_Product__c> lstBundlesProduct  = CRM_TestDataFactory.createBundleProducts(lstBundles, products, 1, true);
            system.assertEquals(6,lstBundlesProduct.size());
    }
    /**
    *  Test 1: Test to insert new record Bundle Products with improper information
    *  Expected: record should not be inserted and should throw exception
    *  @name unitTestException
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void unitTestException() {    
       allTheDataForThisTestClass();
       list<Bundle__c> lstBundles = [Select id,Price_Book__c,Pricing_Account__c,Start_Date__c,End_Date__c,CurrencyISOCode from Bundle__c];
       Test.startTest();
                    PageReference pageRef = Page.CRM_UploadAssortmentProducts;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',lstBundles[0].id);
                    ApexPages.standardController controller = new ApexPages.standardController(lstBundles[0]);
                    CRM_UploadAssortmentProductsController pg = new CRM_UploadAssortmentProductsController(controller); 
                    list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> lineItems = CRM_UploadAssortmentProductsController.getAssortmentLineItems(lstBundles[0].id);
                    /*************************************prepare data start***********************************************/
                    //insert new Record
                    CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper wrapper = new CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper();
                    wrapper.lineItemRecord=lineItems[0].lineItemRecord.clone(false);
                    wrapper.lineItemRecord.Product__r.productCode ='code1';
                    wrapper.isRowModified=null;
                    wrapper.existingId=null;
                    lineItems.add(wrapper);
                    /*************************************prepare data end***********************************************/
                    try {
                        list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> savedlineItems = CRM_UploadAssortmentProductsController.setAssortmentLineItems(lineItems,lstBundles[0].id,false);
                    }
                    catch(Exception e){
                        /*************************************asserts***********************************************/
                        system.assertEquals(true, e.getMessage().contains('null'));
                    }
                    
        Test.stopTest();
    }
    /**
    *  Test 3: Test to insert new bundle product record and update existing bundle product record of bundle with improper information
    *  Expected: record should not be created/updated and should throw validation messages
    *  @name unitTestValidationFailed
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void unitTestValidationFailed() {
        allTheDataForThisTestClass();
        list<Bundle__c> lstBundles = [Select id,Price_Book__c,Pricing_Account__c,Start_Date__c,End_Date__c,CurrencyISOCode from Bundle__c];
        Test.startTest();
                    PageReference pageRef = Page.CRM_UploadAssortmentProducts;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',lstBundles[0].id);
                    ApexPages.standardController controller = new ApexPages.standardController(lstBundles[0]);
                    CRM_UploadAssortmentProductsController pg = new CRM_UploadAssortmentProductsController(controller); 
                    list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> lineItems = CRM_UploadAssortmentProductsController.getAssortmentLineItems(lstBundles[0].id);
                    /*************************************prepare data start***********************************************/
                    //insert new Record
                    CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper wrapper = new CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper();
                    wrapper.lineItemRecord=lineItems[0].lineItemRecord.clone(false);
                    wrapper.lineItemRecord.Product__r.productCode ='codeABC';
                    wrapper.isRowModified=true;
                    wrapper.existingId=null;
                    lineItems.add(wrapper);
                    
                    //update existing record
                    lineItems[0].lineItemRecord.Goal__c = 0;
                    lineItems[0].isRowModified = true;
                    /*************************************prepare data end***********************************************/
                    list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> savedlineItems = CRM_UploadAssortmentProductsController.setAssortmentLineItems(lineItems,lstBundles[0].id,false);
                    
                    /*************************************asserts***********************************************/
                    for(CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper wrp: savedlineItems) {
                        if(wrp.lineItemRecord.Product__r.productCode =='codeABC') {
                            system.assertEquals(Label.CRM_Upload_Message_NotFound, wrp.validation);
                        }
                    }
        Test.stopTest();
    }
    /**
    *  Test 3: Test to insert new bundle product record and update existing bundle product record of bundle with improper information
    *  Expected: record should not be created/updated and should throw validation messages
    *  @name unitTestValidationFailed
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void unitTestValidationForInactiveProduct() {
        allTheDataForThisTestClass();
        list<Bundle__c> lstBundles = [Select id,Price_Book__c,Pricing_Account__c,Start_Date__c,End_Date__c,CurrencyISOCode from Bundle__c];
        List<Product2> products = [select id,productCode,isActive from Product2];        
        for(Product2 p :products){
            if(p.productCode == 'code2'){
                p.Universal_Picture_Code__c='upc2';
                p.SAP_Dist_chain_product_Status__c = '02';
                p.IsActive = false;
            }
        }
        update products;
        List<PriceBookEntry> lstPbe = [Select Id, IsActive from PriceBookEntry where Product2Id IN: products];
        for(PriceBookEntry pbe : lstPbe){
            pbe.IsActive = true;
        }
        update lstPbe;
        Test.startTest();
                    PageReference pageRef = Page.CRM_UploadAssortmentProducts;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',lstBundles[0].id);
                    ApexPages.standardController controller = new ApexPages.standardController(lstBundles[0]);
                    CRM_UploadAssortmentProductsController pg = new CRM_UploadAssortmentProductsController(controller); 
                    list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> lineItems = CRM_UploadAssortmentProductsController.getAssortmentLineItems(lstBundles[0].id);
                    /*************************************prepare data start***********************************************/
                    //insert new Record
                    CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper wrapper = new CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper();
                    wrapper.lineItemRecord=lineItems[0].lineItemRecord.clone(false);
                    wrapper.lineItemRecord.Product__r.productCode ='code2';
                    wrapper.lineItemRecord.Product__r.Universal_Picture_Code__c='upc2';
                    wrapper.existingId=null;
                    wrapper.isRowModified=true;
                    lineItems.add(wrapper);
                    
                    //update existing record
                    lineItems[0].lineItemRecord.Goal__c = 0;
                    lineItems[0].isRowModified = true;
                    /*************************************prepare data end***********************************************/
                    list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> savedlineItems = CRM_UploadAssortmentProductsController.setAssortmentLineItems(lineItems,lstBundles[0].id,false);
                    
                    /*************************************asserts***********************************************/
                    for(CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper wrp: savedlineItems) {
                        if(wrp.lineItemRecord.Product__r.productCode == 'code2'){
                            if(wrapper.existingId != null){
                                system.assertEquals(Label.CRM_Upload_Message_Product_Not_Active, wrp.validation);
                            }
                        }
                    }
        Test.stopTest();
    }
     /**
    *  Test 4: Test to insert new bundle product record and update existing bundle product record of bundle with improper information
    *  Expected: record should not be created/updated and should throw validation messages
    *  @name unitTestValidationFailed
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testMethod void unitTestValidationFailed2() {
        allTheDataForThisTestClass();
        list<Bundle__c> lstBundles = [Select id,Price_Book__c,Pricing_Account__c,Start_Date__c,End_Date__c,CurrencyISOCode from Bundle__c];
               Test.startTest();
                    PageReference pageRef = Page.CRM_UploadAssortmentProducts;
                    Test.setCurrentPage(pageRef);
                    ApexPages.currentPage().getParameters().put('id',lstBundles[0].id);
                    ApexPages.standardController controller = new ApexPages.standardController(lstBundles[0]);
                    CRM_UploadAssortmentProductsController pg = new CRM_UploadAssortmentProductsController(controller); 
                    list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> lineItems = CRM_UploadAssortmentProductsController.getAssortmentLineItems(lstBundles[0].id);
                    /*************************************prepare data start***********************************************/
                    
                    
                    //insert new Record
                    CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper wrapper = new CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper();
                    wrapper.lineItemRecord=lineItems[0].lineItemRecord.clone(false);
                    wrapper.lineItemRecord.Product__r.productCode ='code1';
                    wrapper.lineItemRecord.Product__r.Universal_Picture_Code__c='upc1';
                    if(lineItems[0].lineItemRecord.Product__r.productCode =='code1') {
                        wrapper.lineItemRecord.Product__r.productCode ='code2';
                        wrapper.lineItemRecord.Product__r.Universal_Picture_Code__c='upc2';
                    }
                    wrapper.isRowModified=true;
                    wrapper.existingId=null;
                    wrapper.lineItemRecord.Assortment_Price__c = null;
                    lineItems.add(wrapper);
                    
                    Pricebook_Entry_Period__c pbep = [select id, Start_Date__c, End_Date__c,Product__r.External_Id__c from Pricebook_Entry_Period__c where Product__r.productCode= : wrapper.lineItemRecord.Product__r.productCode limit 1];
                    pbep.Start_Date__c = lstBundles[0].End_Date__c + 1;
                    pbep.End_Date__c = pbep.Start_Date__c + 30;
                    update pbep;
                    //system.debug('=======pbep======='+pbep);
                    
                    /*************************************prepare data end***********************************************/
                    list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> savedlineItems = CRM_UploadAssortmentProductsController.setAssortmentLineItems(lineItems,lstBundles[0].id,false);
                    
                    /*************************************asserts***********************************************/
                    for(CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper wrp: savedlineItems) {
                        if(wrp.lineItemRecord.id==null) {
                            //system.assertEquals(Label.CRM_Upload_Message_Dates, wrp.validation);
                            system.assertEquals(Label.CRM_Upload_Message_PBEP, wrp.validation);
                        }
                    }
        Test.stopTest();
    }
	
	/*static void dataForUploadExtract_Test(String productType){

        //create accounts
        list<Account> accounts = CRM_TestDataFactory.createAccounts(1, false);
        accounts[0].recordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        insert accounts;
        
        //create bundle
		List<Bundle__c> lstBundles = CRM_TestDataFactory.createBundles(2, false);
		lstBundles[0].CurrencyIsoCode = 'USD';
		lstBundles[0].Start_Date__c = system.today();
		lstBundles[0].End_Date__c = system.today()+30;
		insert lstBundles;

        List<Product_Group__c> pgs = CRM_TestDataFactory.createProductGroups(1, true);
        //Pricebook2 pb = new Pricebook2();
        
        if(productType == 'digital'){
            
            system.debug('Inside digital ------------------->');
            List<String> strRegion = new List<String>();    strRegion.add('USA');
            List<Country__c> lstCountries = CRM_TestDataFactory.createCountries(strRegion, 2, true); //create country
            List<Language__c> lstLang = CRM_TestDataFactory.createLanguages(2, true);
           
            List<Title__c> titleList = new List<Title__c>();
			Title__c title = new title__c(name = 'title test',Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE,Video_Version__c = 'digitalCode');
            titleList.add(title);
			Title__c title1 = new title__c(name = 'title test1',Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE,Video_Version__c = 'digitalCode1');
			titleList.add(title1);
			insert titleList;
            
            List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(lstCountries, lstLang, 2, false);
            lstLocalData[0].Title__c = title.Id;
            lstLocalData[1].Title__c = title1.Id;
            insert lstLocalData;

            List<Product2> lstProductNew = CRM_TestDataFactory.createProducts(pgs, 2, false);
                
			lstProductNew[0].productCode= 'digitalCode';
			lstProductNew[0].Product_Format__c = 'HD';
			lstProductNew[0].Product_Market__c = 'EST';
			lstProductNew[0].SAP_Material_Type__c = 'FERT';
			lstProductNew[0].recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL; //Digital Product
			lstProductNew[0].External_Id__c = 'USA_en_digitalCode_EST_HD'; //language_videoVersion_channel_format 
			lstProductNew[0].Type__c = 'Video Digital';
			lstProductNew[0].IsActive= true;
			lstProductNew[0].Local_Title__c = lstLocalData[0].id;
			
			lstProductNew[1].productCode= 'digitalCode1';
			lstProductNew[1].Product_Format__c = 'SD';
			lstProductNew[1].Product_Market__c = 'EST';
			lstProductNew[1].SAP_Material_Type__c = 'FERT';
			lstProductNew[1].recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL; //Digital Product
			lstProductNew[1].External_Id__c = 'USA_en_digitalCode1_EST_SD'; //language_videoVersion_channel_format 
			lstProductNew[1].Type__c = 'Video Digital';
			lstProductNew[1].IsActive= true;
			lstProductNew[1].Local_Title__c = lstLocalData[1].id;

            insert lstProductNew;
            
            CRM_TestDataFactory.createPriceBookEntriesStandard(lstProductNew,1,true); //standard price book
            
			Pricebook2 pb_1 = new Pricebook2();
            pb_1.Name = 'test PB digital';
            pb_1.Description='test PB digital';
            pb_1.IsActive = true;
            pb_1.Business_Unit__c = '2500';
            pb_1.Product_Type__c = 'Digital';
            pb_1.Country__c = 'USA';
            insert pb_1;

            PricebookEntry pbEntry = new PricebookEntry();
            pbEntry.UnitPrice = 10.00;
            pbEntry.CurrencyIsoCode = lstProductNew[0].CurrencyIsoCode;
            pbEntry.Product2Id = lstProductNew[0].Id;                
            pbEntry.IsActive = true;
            pbEntry.Pricebook2Id = pb_1.id;
            insert pbEntry;
            
            PricebookEntry pbEntry1 = new PricebookEntry();
            pbEntry1.UnitPrice = 11.00;
            pbEntry1.CurrencyIsoCode = lstProductNew[1].CurrencyIsoCode;
            pbEntry1.Product2Id = lstProductNew[1].Id;                
            pbEntry1.IsActive = true;
            pbEntry1.Pricebook2Id = pb_1.id;
            insert pbEntry1;

            List<Pricebook_Entry_Period__c> pbepList = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProductNew, 1, false);
            for(Pricebook_Entry_Period__c pbep : pbepList){
                pbep.Price_Book__c = pb_1.id;
                pbep.Start_Date__c = lstBundles[0].Start_Date__c - 1;
                pbep.End_Date__c = pbep.Start_Date__c + 31;
                pbep.List_Price__c = 20;
			}
            insert pbepList;
           
        }else if(productType == 'physical'){
        
            List<Product2> lstProductNew = CRM_TestDataFactory.createProducts(pgs, 2, false);
            lstProductNew[0].productCode= 'physicalcode';
            lstProductNew[0].Universal_Picture_Code__c ='upc';
            lstProductNew[0].SAP_Material_Type__c = 'FERT';
            lstProductNew[0].recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL ; //Physical Product
            lstProductNew[0].External_Id__c = '2500-10-physicalCode'; //SAP_Sales_Org__c-10-productCode
            lstProductNew[0].Type__c = 'Video Physical';
            lstProductNew[0].SAP_Sales_Org__c = '2500';
            lstProductNew[0].IsActive= true;

            lstProductNew[1].productCode= 'physicalcode1';
            lstProductNew[1].Universal_Picture_Code__c ='upc1';
            lstProductNew[1].SAP_Material_Type__c = 'FERT';
            lstProductNew[1].recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL ; //Physical Product
            lstProductNew[1].External_Id__c = '2500-10-physicalCode1'; //SAP_Sales_Org__c-10-productCode
            lstProductNew[1].Type__c = 'Video Physical';
            lstProductNew[1].SAP_Sales_Org__c = '2500';
            lstProductNew[1].IsActive= true;
            insert lstProductNew;
            
            //insert product with pricebookEntry and no PBEP
            Product2 productRecord = new Product2();
            List<Product2> lstProduct_noPBEP = CRM_TestDataFactory.createProducts(pgs, 1, false);
            lstProduct_noPBEP[0].productCode= 'physicalcode2';
            lstProduct_noPBEP[0].Universal_Picture_Code__c ='upc2';
            lstProduct_noPBEP[0].SAP_Material_Type__c = 'FERT';
            lstProduct_noPBEP[0].recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL ; //Physical Product
            lstProduct_noPBEP[0].External_Id__c = '2500-10-physicalCode2'; //SAP_Sales_Org__c-10-productCode
            lstProduct_noPBEP[0].Type__c = 'Video Physical';
            lstProduct_noPBEP[0].SAP_Sales_Org__c = '2500';
            lstProduct_noPBEP[0].IsActive= true;
            insert lstProduct_noPBEP;
			
			Pricebook2 pb_2 = new Pricebook2();
            pb_2.Name = 'test PB physical';
            pb_2.Description='test PB physical';
            pb_2.IsActive = true;
            pb_2.Business_Unit__c = '2500';
            pb_2.Product_Type__c = 'Physical';
            pb_2.Country__c = 'USA';
            insert pb_2;
            
           //standard Pricebook created    
           CRM_TestDataFactory.createPriceBookEntriesStandard(lstProductNew,1,true);
           CRM_TestDataFactory.createPriceBookEntriesStandard(lstProduct_noPBEP,1,true);

           PricebookEntry pbEntry = new PricebookEntry();
		   pbEntry.UseStandardPrice = false;
		   pbEntry.UnitPrice = 10.00;
		   pbEntry.CurrencyIsoCode = lstProductNew[0].CurrencyIsoCode;
		   pbEntry.Product2Id = lstProductNew[0].Id;                
		   pbEntry.IsActive = true;
		   pbEntry.Pricebook2Id = pb_2.id;
		   insert pbEntry;
		   
		   PricebookEntry pbEntry1 = new PricebookEntry();
		   pbEntry1.UseStandardPrice = false;
		   pbEntry1.UnitPrice = 11.00;
		   pbEntry1.CurrencyIsoCode = lstProductNew[1].CurrencyIsoCode;
		   pbEntry1.Product2Id = lstProductNew[1].Id;                
		   pbEntry1.IsActive = true;
		   pbEntry1.Pricebook2Id = pb_2.id;
		   insert pbEntry1;
		   
		   PricebookEntry pbEntry2 = new PricebookEntry();
		   pbEntry2.UseStandardPrice = false;
		   pbEntry2.UnitPrice = 12.00;
		   pbEntry2.CurrencyIsoCode = lstProduct_noPBEP[0].CurrencyIsoCode;
		   pbEntry2.Product2Id = lstProduct_noPBEP[0].Id;                
		   pbEntry2.IsActive = true;
		   pbEntry2.Pricebook2Id = pb_2.id;
		   insert pbEntry2;
            
            List<Pricebook_Entry_Period__c> pbepList = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProductNew, 1, false);
            for(Pricebook_Entry_Period__c pbep : pbepList){
                pbep.Price_Book__c = pb_2.id;
                pbep.Start_Date__c = lstBundles[0].Start_Date__c - 1;
                pbep.End_Date__c = pbep.Start_Date__c + 31;
                pbep.List_Price__c = 20;
            }
            insert pbepList;

        }
    }*/

	static void dataForUploadExtract_Digital_Test(){
    
    	Pricebook2 pb_1 = new Pricebook2();
        pb_1.Name = 'test PB digital';
        pb_1.Description='test PB digital';
        pb_1.IsActive = true;
        pb_1.Business_Unit__c = '2500';
        pb_1.Product_Type__c = 'Digital';
        pb_1.Country__c = 'USA';
        insert pb_1;

        //create accounts
        list<Account> accounts = CRM_TestDataFactory.createAccounts(1, false);
        accounts[0].recordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
		accounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_US_CODE;
	  	accounts[0].Price_Book__c =pb_1.id;
	    insert accounts;
        
        //create bundle
		List<Bundle__c> lstBundles = CRM_TestDataFactory.createBundles(2, false);
		lstBundles[0].CurrencyIsoCode = 'USD';
		lstBundles[0].Start_Date__c = system.today();
		lstBundles[0].End_Date__c = system.today()+30;
		insert lstBundles;

        List<Product_Group__c> pgs = CRM_TestDataFactory.createProductGroups(1, true);
        //Pricebook2 pb = new Pricebook2();
            
            List<String> strRegion = new List<String>();    strRegion.add('USA');
            List<Country__c> lstCountries = CRM_TestDataFactory.createCountries(strRegion, 2, true); //create country
            List<Language__c> lstLang = CRM_TestDataFactory.createLanguages(2, true);
           
            List<Title__c> titleList = new List<Title__c>();
			Title__c title = new title__c(name = 'title test',Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE,Video_Version__c = 'digitalCode');
            titleList.add(title);
			Title__c title1 = new title__c(name = 'title test1',Content_Type__c = CRM_AppConstants.GAMES_TITTLE_CONTENT_TYPE,Video_Version__c = 'digitalCode1');
			titleList.add(title1);
			insert titleList;
            
            List<Local_Title__c> lstLocalData = CRM_TestDataFactory.createLocalTitles(lstCountries, lstLang, 2, false);
            lstLocalData[0].Title__c = title.Id;
            lstLocalData[1].Title__c = title1.Id;
            insert lstLocalData;

            List<Product2> lstProductNew = CRM_TestDataFactory.createProducts(pgs, 2, false);
                
			lstProductNew[0].productCode= 'digitalCode';
			lstProductNew[0].Product_Format__c = 'HD';
			lstProductNew[0].Product_Market__c = 'EST';
			lstProductNew[0].SAP_Material_Type__c = 'FERT';
			lstProductNew[0].recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL; //Digital Product
			lstProductNew[0].External_Id__c = 'USA_en_digitalCode_EST_HD'; //language_videoVersion_channel_format 
			lstProductNew[0].Type__c = 'Video Digital';
			lstProductNew[0].IsActive= true;
			lstProductNew[0].CurrencyIsoCode= 'USD';
			lstProductNew[0].Local_Title__c = lstLocalData[0].id;
			
			lstProductNew[1].productCode= 'digitalCode1';
			lstProductNew[1].Product_Format__c = 'SD';
			lstProductNew[1].Product_Market__c = 'EST';
			lstProductNew[1].SAP_Material_Type__c = 'FERT';
			lstProductNew[1].recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_DIGITAL; //Digital Product
			lstProductNew[1].External_Id__c = 'USA_en_digitalCode1_EST_SD'; //language_videoVersion_channel_format 
			lstProductNew[1].Type__c = 'Video Digital';
			lstProductNew[1].IsActive= true;
			lstProductNew[1].CurrencyIsoCode= 'USD';
			lstProductNew[1].Local_Title__c = lstLocalData[1].id;

            insert lstProductNew;
			system.assertEquals('Video Digital',lstProductNew[0].Type__c );
			system.assertEquals('Video Digital',lstProductNew[1].Type__c );
            
           // 

            PricebookEntry pbEntry = new PricebookEntry();
            pbEntry.UnitPrice = 10.00;
            pbEntry.CurrencyIsoCode = lstProductNew[0].CurrencyIsoCode;
            pbEntry.Product2Id = lstProductNew[0].Id;                
            pbEntry.IsActive = true;
            pbEntry.Pricebook2Id = pb_1.id;
           
           // insert pbEntry;
            
            PricebookEntry pbEntry1 = new PricebookEntry();
            pbEntry1.UnitPrice = 11.00;
            pbEntry1.CurrencyIsoCode = lstProductNew[1].CurrencyIsoCode;
            pbEntry1.Product2Id = lstProductNew[1].Id;                
            pbEntry1.IsActive = true;
            pbEntry1.Pricebook2Id = pb_1.id;
            
           // insert pbEntry1;
			CRM_TestDataFactory.createPriceBookEntriesStandard(lstProductNew,1,true); //standard price book	
			List<PricebookEntry> cc= [select id from PricebookEntry];
			List<PricebookEntry> PricebookEntryList = new List<PricebookEntry>();
			PricebookEntryList.add(pbEntry);
			PricebookEntryList.add(pbEntry1);
			//insert PricebookEntryList;
		
		   // CRM_TestDataFactory.createPriceBookEntriesStandard(lstProductNew,1,true); //standard price book	
            List<Pricebook_Entry_Period__c> pbepList = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProductNew, 1, false);
            for(Pricebook_Entry_Period__c pbep : pbepList){
                pbep.Price_Book__c = pb_1.id;
                pbep.Start_Date__c = lstBundles[0].Start_Date__c - 1;
                pbep.End_Date__c = pbep.Start_Date__c + 31;
                pbep.List_Price__c = 20;
			}
            insert pbepList;
            
    }
	
	static void dataForUploadExtract_Physical_Test(){
	    
	    Pricebook2 pb_2 = new Pricebook2();
		pb_2.Name = 'test PB physical';
		pb_2.Description='test PB physical';
		pb_2.IsActive = true;
		pb_2.Business_Unit__c = '2500';
		pb_2.Product_Type__c = 'Physical';
		pb_2.Country__c = 'USA';
		insert pb_2;
		
		//create accounts
        list<Account> accounts = CRM_TestDataFactory.createAccounts(2, false);
        accounts[0].recordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
		accounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_US_CODE;
		accounts[0].Price_Book__c=pb_2.id;
        insert accounts; 
        
        //create bundle
		List<Bundle__c> lstBundles = CRM_TestDataFactory.createBundles(2, false);
		lstBundles[0].CurrencyIsoCode = 'USD';
		lstBundles[0].Start_Date__c = system.today();
		lstBundles[0].End_Date__c = system.today()+30;
		insert lstBundles;
        
        List<Product_Group__c> pgs = CRM_TestDataFactory.createProductGroups(1, true);
        //Pricebook2 pb = new Pricebook2();
        
		List<Product2> lstProductNew = CRM_TestDataFactory.createProducts(pgs, 2, false);
		lstProductNew[0].productCode= 'physicalcode';
		lstProductNew[0].Universal_Picture_Code__c ='upc';
		lstProductNew[0].recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL ; //Physical Product
		lstProductNew[0].External_Id__c = '2500-10-physicalCode'; //SAP_Sales_Org__c-10-productCode
		lstProductNew[0].SAP_Sales_Org__c = '2500';
		lstProductNew[0].IsActive= true;
		lstProductNew[0].CurrencyIsoCode= 'USD';
		lstProductNew[0].Product_Format__c = '4';
        lstProductNew[0].Product_Rating__c = 'UK - Minimum 12 Ye';
        lstProductNew[0].Product_Genre__c = 'ACTION';
        lstProductNew[0].Release_Category__c = '23';
        lstProductNew[0].Franchise_Type__c = 'X4';
        lstProductNew[0].Product_Language_Code__c = 'EN';
        lstProductNew[0].SAP_Dist_chain_product_Status__c = '11';
        lstProductNew[0].Type__c = CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE;
        lstProductNew[0].Recommended_Price__c = 150;
        lstProductNew[0].SAP_Material_Type__c = CRM_AppConstants.PRODUCT_MATERIAL_TYPE_FERT;

		lstProductNew[1].productCode= 'physicalcode1';
		lstProductNew[1].Universal_Picture_Code__c ='upc1';
		lstProductNew[1].recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL ; //Physical Product
		lstProductNew[1].External_Id__c = '2500-10-physicalCode1'; //SAP_Sales_Org__c-10-productCode
		lstProductNew[1].SAP_Sales_Org__c = '2500';
		lstProductNew[1].IsActive= true;
		lstProductNew[1].CurrencyIsoCode= 'USD';
		lstProductNew[1].Product_Format__c = '4';
        lstProductNew[1].Product_Rating__c = 'UK - Minimum 12 Ye';
        lstProductNew[1].Product_Genre__c = 'ACTION';
        lstProductNew[1].Release_Category__c = '23';
        lstProductNew[1].Franchise_Type__c = 'X4';
        lstProductNew[1].Product_Language_Code__c = 'EN';
        lstProductNew[1].SAP_Dist_chain_product_Status__c = '11';
        lstProductNew[1].Type__c = CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE;
        lstProductNew[1].Recommended_Price__c = 150;
        lstProductNew[1].SAP_Material_Type__c = CRM_AppConstants.PRODUCT_MATERIAL_TYPE_FERT;
		insert lstProductNew;
		
		//insert product with pricebookEntry and no PBEP
		Product2 productRecord = new Product2();
		List<Product2> lstProduct_noPBEP = CRM_TestDataFactory.createProducts(pgs, 1, false);
		lstProduct_noPBEP[0].productCode= 'physicalcode2';
		lstProduct_noPBEP[0].Universal_Picture_Code__c ='upc2';
		lstProduct_noPBEP[0].recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL ; //Physical Product
		lstProduct_noPBEP[0].External_Id__c = '2500-10-physicalCode2'; //SAP_Sales_Org__c-10-productCode
		lstProduct_noPBEP[0].SAP_Sales_Org__c = '2500';
		lstProduct_noPBEP[0].IsActive= true;
	    lstProduct_noPBEP[0].CurrencyIsoCode= 'USD';
		lstProduct_noPBEP[0].Product_Format__c = '4';
        lstProduct_noPBEP[0].Product_Rating__c = 'UK - Minimum 12 Ye';
        lstProduct_noPBEP[0].Product_Genre__c = 'ACTION';
        lstProduct_noPBEP[0].Release_Category__c = '23';
        lstProduct_noPBEP[0].Franchise_Type__c = 'X4';
        lstProduct_noPBEP[0].Product_Language_Code__c = 'EN';
        lstProduct_noPBEP[0].SAP_Dist_chain_product_Status__c = '11';
        lstProduct_noPBEP[0].Type__c = CRM_AppConstants.VIDEO_PHYSICAL_PRODUCT_TYPE;
        lstProduct_noPBEP[0].Recommended_Price__c = 150;
        lstProduct_noPBEP[0].SAP_Material_Type__c = CRM_AppConstants.PRODUCT_MATERIAL_TYPE_FERT;
		insert lstProduct_noPBEP;
		
	
		
	   //standard Pricebook created    
	   CRM_TestDataFactory.createPriceBookEntriesStandard(lstProductNew,1,true);
	   CRM_TestDataFactory.createPriceBookEntriesStandard(lstProduct_noPBEP,1,true);

	   PricebookEntry pbEntry = new PricebookEntry();
	   pbEntry.UseStandardPrice = false;
	   pbEntry.UnitPrice = 10.00;
	   pbEntry.CurrencyIsoCode = lstProductNew[0].CurrencyIsoCode;
	   pbEntry.Product2Id = lstProductNew[0].Id;                
	   pbEntry.IsActive = true;
	   pbEntry.Pricebook2Id = pb_2.id;
	   //insert pbEntry;
	   
	   PricebookEntry pbEntry1 = new PricebookEntry();
	   pbEntry1.UseStandardPrice = false;
	   pbEntry1.UnitPrice = 11.00;
	   pbEntry1.CurrencyIsoCode = lstProductNew[1].CurrencyIsoCode;
	   pbEntry1.Product2Id = lstProductNew[1].Id;                
	   pbEntry1.IsActive = true;
	   pbEntry1.Pricebook2Id = pb_2.id;
	  // insert pbEntry1;
	   
	   PricebookEntry pbEntry2 = new PricebookEntry();
	   pbEntry2.UseStandardPrice = false;
	   pbEntry2.UnitPrice = 12.00;
	   pbEntry2.CurrencyIsoCode = lstProduct_noPBEP[0].CurrencyIsoCode;
	   pbEntry2.Product2Id = lstProduct_noPBEP[0].Id;                
	   pbEntry2.IsActive = true;
	   pbEntry2.Pricebook2Id = pb_2.id;
	   //insert pbEntry2;
	
		List<Pricebook_Entry_Period__c> pbepList = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProductNew, 1, false);
		for(Pricebook_Entry_Period__c pbep : pbepList){
			pbep.Price_Book__c = pb_2.id;
			pbep.Start_Date__c = lstBundles[0].Start_Date__c - 1;
			pbep.End_Date__c = pbep.Start_Date__c + 31;
			pbep.List_Price__c = 20;
		}
		insert pbepList;
		
		
	}
    /**
    *  Test 1: Req#808 Test to insert new lineItems and update existing record 
    *  Expected: new record should get inserted and existing should get updated
    *  @name testPromotionalAssortment
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testmethod void testPromotionalAssortment_digital(){
        
        //dataForUploadExtract_Test('digital');
		dataForUploadExtract_Digital_Test();
        
        List<Pricebook2> priceBookList = [Select Id,Name from Pricebook2 Where Name = 'test PB digital' limit 1];
		system.assertEquals(1,priceBookList.size());
        List<Product2> productList = [Select id,productCode,External_Id__c from Product2 where productCode = 'digitalCode'];
        list<Account> lstAccount = [Select id,Price_Book__c from Account limit 1];
        lstAccount[0].Price_Book__c = priceBookList[0].Id;
        update lstAccount;
        
        list<Bundle__c> lstAssortment = [Select id,Price_Book__c,Pricing_Account__c,Start_Date__c,End_Date__c,CurrencyISOCode from Bundle__c LIMIT 1];
        lstAssortment[0].recordTypeId=CRM_RecordTypeUtil.RT_Promotional_Assortment;
        lstAssortment[0].Price_Book__c = priceBookList[0].Id;
        update lstAssortment;
        
        Assortment_Account__c AssrtmntAccount = CRM_TestDataFactory.createAssortmentAccount(lstAssortment[0],lstAccount[0]);
        insert AssrtmntAccount;

        List<Bundle_Product__c> lstBundlesProduct  = CRM_TestDataFactory.createBundleProducts(lstAssortment, productList, 1, true);
        system.assertEquals(1,lstBundlesProduct.size());

        Test.startTest();
            PageReference pageRef = Page.CRM_UploadAssortmentProducts;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',lstAssortment[0].id);
            ApexPages.standardController controller = new ApexPages.standardController(lstAssortment[0]);
                     
            CRM_UploadAssortmentProductsController pg = new CRM_UploadAssortmentProductsController(controller);
            pg.getUserLocale();
            pg.getDigitalDeal();
            list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> lineItems = CRM_UploadAssortmentProductsController.getAssortmentLineItems(lstAssortment[0].id);
            
			//insert new Record
            CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper wrapper = new CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper();
            CRM_UploadAssortmentProductsController.DigitalDealWrapper digitalWrap = new CRM_UploadAssortmentProductsController.DigitalDealWrapper();
            wrapper.lineItemRecord=lineItems[0].lineItemRecord.clone(false);
            digitalWrap.videoVersion = 'digitalCode1';
            digitalWrap.channel = 'EST';
            digitalWrap.format = 'SD';
            digitalWrap.language = 'en';
            wrapper.digital = digitalWrap;
            wrapper.isRowModified=true;
            wrapper.existingId = null;
            lineItems.add(wrapper);
            list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> savedlineItems = CRM_UploadAssortmentProductsController.setAssortmentLineItems(lineItems,lstAssortment[0].id,true);// method
            system.assertEquals(Label.CRM_Upload_Message_Created, savedlineItems[1].validation);
			
			//update existing record
			lineItems[0].lineItemRecord.Assortment_Price__c = 12;
			lineItems[0].isRowModified = true;
			list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> savedlineItems_1 = CRM_UploadAssortmentProductsController.setAssortmentLineItems(lineItems,lstAssortment[0].id,true);
			system.assertEquals(Label.CRM_Upload_Message_Updated, savedlineItems_1[0].validation);
			
			//delete new Record
			lineItems[0].isRowRemoved = true;
			list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> dellineItems = CRM_UploadAssortmentProductsController.setAssortmentLineItems(lineItems,lstAssortment[0].id,true);
			system.assertEquals(savedlineItems.size()-1, dellineItems.size());
        
        Test.stopTest();
    }
    
    /**
    *  Test 2: Req#808 Test to insert new dealproducts and update existing record 
    *  Expected: new record should get inserted and existing should get updated
    *  @name testCampaignAssortment
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testmethod void testCampaignAssortment_digital(){
		//dataForUploadExtract_Test('digital');
		dataForUploadExtract_Digital_Test();
        
        List<Pricebook2> priceBookList = [Select Id,Name from Pricebook2 Where Name = 'test PB digital' limit 1];
        List<Product2> productList = [Select id,productCode,External_Id__c from Product2 where productCode = 'digitalCode'];
        list<Account> lstAccount = [Select id,Price_Book__c from Account limit 1];
        lstAccount[0].Price_Book__c = priceBookList[0].Id;
        update lstAccount;
        
		list<Bundle__c> lstAssortment = [Select id,Price_Book__c,Pricing_Account__c,Start_Date__c,End_Date__c,CurrencyISOCode from Bundle__c LIMIT 1];
        lstAssortment[0].recordTypeId=CRM_RecordTypeUtil.RT_ASSORTMENT_CAMPAIGN;
        lstAssortment[0].Price_Book__c = priceBookList[0].Id;
        lstAssortment[0].Campaign_Type__c = 'Trade Promotion';
        lstAssortment[0].High_Level_Target__c = 10;
        lstAssortment[0].Average_Price__c = 5;
        update lstAssortment;
		
        Assortment_Account__c AssrtmntAccount = CRM_TestDataFactory.createAssortmentAccount(lstAssortment[0],lstAccount[0]);
        insert AssrtmntAccount;

        List<Bundle_Product__c> lstBundlesProduct  = CRM_TestDataFactory.createBundleProducts(lstAssortment, productList, 1, true);
        system.assertEquals(1,lstBundlesProduct.size());

        Test.startTest();
            PageReference pageRef = Page.CRM_UploadAssortmentProducts;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',lstAssortment[0].id);
            ApexPages.standardController controller = new ApexPages.standardController(lstAssortment[0]);
                     
            CRM_UploadAssortmentProductsController pg = new CRM_UploadAssortmentProductsController(controller);
            pg.getUserLocale();
            pg.getDigitalDeal();
            list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> lineItems = CRM_UploadAssortmentProductsController.getAssortmentLineItems(lstAssortment[0].id);
            
			//insert new Record
            CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper wrapper = new CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper();
            CRM_UploadAssortmentProductsController.DigitalDealWrapper digitalWrap = new CRM_UploadAssortmentProductsController.DigitalDealWrapper();
            wrapper.lineItemRecord=lineItems[0].lineItemRecord.clone(false);
            digitalWrap.videoVersion = 'digitalCode1';
            digitalWrap.channel = 'EST';
            digitalWrap.format = 'SD';
            digitalWrap.language = 'en';
            wrapper.digital = digitalWrap;
            wrapper.isRowModified=true;
            wrapper.existingId = null;
            lineItems.add(wrapper);
            list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> savedlineItems = CRM_UploadAssortmentProductsController.setAssortmentLineItems(lineItems,lstAssortment[0].id,true);// method
            system.assertEquals(Label.CRM_Upload_Message_Created, savedlineItems[1].validation);
		 Test.stopTest();
    }
	/**
    *  Test 3: Req#808 Test to insert new dealproducts and update existing record 
    *  Expected: new record should get inserted and existing should get updated
    *  @name testPromotionalAssortment
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testmethod void testPromotionalAssortment_physical(){
        //dataForUploadExtract_Test('physical');
		dataForUploadExtract_Physical_Test();

		List<Pricebook2> priceBookList = [Select Id,Name from Pricebook2 Where Name = 'test PB physical' limit 1];
        List<Product2> productList = [Select id,productCode,External_Id__c,Universal_Picture_Code__c from Product2 where productCode = 'physicalCode'];
        list<Account> lstAccount = [Select id,Price_Book__c from Account limit 1];
        lstAccount[0].Price_Book__c = priceBookList[0].Id;
        update lstAccount;
		
		list<Bundle__c> lstAssortment = [Select id,Price_Book__c,Pricing_Account__c,Start_Date__c,End_Date__c,CurrencyISOCode from Bundle__c LIMIT 1];
        lstAssortment[0].recordTypeId=CRM_RecordTypeUtil.RT_Promotional_Assortment;
        lstAssortment[0].Price_Book__c = priceBookList[0].Id;
        update lstAssortment;
        
        Assortment_Account__c AssrtmntAccount = CRM_TestDataFactory.createAssortmentAccount(lstAssortment[0],lstAccount[0]);
        insert AssrtmntAccount;

        List<Bundle_Product__c> lstBundlesProduct  = CRM_TestDataFactory.createBundleProducts(lstAssortment, productList, 1, true);
        system.assertEquals(1,lstBundlesProduct.size());

        Test.startTest();
            PageReference pageRef = Page.CRM_UploadAssortmentProducts;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',lstAssortment[0].id);
            ApexPages.standardController controller = new ApexPages.standardController(lstAssortment[0]);
                     
            CRM_UploadAssortmentProductsController pg = new CRM_UploadAssortmentProductsController(controller);
			list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> lineItems = CRM_UploadAssortmentProductsController.getAssortmentLineItems(lstAssortment[0].id);

		    //insert new Record
            CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper wrapper = new CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper();
            wrapper.lineItemRecord=lineItems[0].lineItemRecord.clone(false);
			wrapper.lineItemRecord.Product__r.productCode ='physicalCode1';
            wrapper.lineItemRecord.Product__r.Universal_Picture_Code__c='upc1';
            wrapper.isRowModified=true;
            wrapper.existingId = null;
            lineItems.add(wrapper);
            list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> savedlineItems = CRM_UploadAssortmentProductsController.setAssortmentLineItems(lineItems,lstAssortment[0].id,false);// method
            system.assertEquals(Label.CRM_Upload_Message_Created, savedlineItems[1].validation);
			
        Test.stopTest();
    }
    /**
    *  Test 4: Req#808 Negative testing 1
    *  Expected: new record should get inserted and existing should get updated
    *  @name testPromotionalAssortment
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testmethod void testPromotionalAssortment_digital_negativeTest_1(){
        //dataForUploadExtract_Test('digital');
		dataForUploadExtract_Digital_Test();
        
        List<Pricebook2> priceBookList = [Select Id,Name from Pricebook2 Where Name = 'test PB digital' limit 1];
        List<Product2> productList = [Select id,productCode,External_Id__c from Product2 where productCode = 'digitalCode'];
        list<Account> lstAccount = [Select id,Price_Book__c from Account limit 1];
        lstAccount[0].Price_Book__c = priceBookList[0].Id;
        update lstAccount;
        
        list<Bundle__c> lstAssortment = [Select id,Price_Book__c,Pricing_Account__c,Start_Date__c,End_Date__c,CurrencyISOCode from Bundle__c LIMIT 1];
        lstAssortment[0].recordTypeId=CRM_RecordTypeUtil.RT_Promotional_Assortment;
        lstAssortment[0].Price_Book__c = priceBookList[0].Id;
        update lstAssortment;
        
        Assortment_Account__c AssrtmntAccount = CRM_TestDataFactory.createAssortmentAccount(lstAssortment[0],lstAccount[0]);
        insert AssrtmntAccount;

        List<Bundle_Product__c> lstBundlesProduct  = CRM_TestDataFactory.createBundleProducts(lstAssortment, productList, 1, true);
        system.assertEquals(1,lstBundlesProduct.size());

        Test.startTest();
            PageReference pageRef = Page.CRM_UploadAssortmentProducts;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',lstAssortment[0].id);
            ApexPages.standardController controller = new ApexPages.standardController(lstAssortment[0]);
                     
            CRM_UploadAssortmentProductsController pg = new CRM_UploadAssortmentProductsController(controller);
            pg.getUserLocale();
            pg.getDigitalDeal();
            list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> lineItems = CRM_UploadAssortmentProductsController.getAssortmentLineItems(lstAssortment[0].id);
            
			//insert new Record
            CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper wrapper = new CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper();
            CRM_UploadAssortmentProductsController.DigitalDealWrapper digitalWrap = new CRM_UploadAssortmentProductsController.DigitalDealWrapper();
            wrapper.lineItemRecord=lineItems[0].lineItemRecord.clone(false);
            digitalWrap.videoVersion = '';
            digitalWrap.channel = 'EST';
            digitalWrap.format = 'SD';
            digitalWrap.language = 'en';
            wrapper.digital = digitalWrap;
            wrapper.isRowModified=true;
            wrapper.existingId = null;
            lineItems.add(wrapper);
            list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> savedlineItems = CRM_UploadAssortmentProductsController.setAssortmentLineItems(lineItems,lstAssortment[0].id,true);
            system.assertEquals(Label.CRM_digital_product_error, savedlineItems[0].validation);

         Test.stopTest();    
    }
     /**
    *  Test 5: Req#808 Negative testing 2
    *  Expected: new record should get inserted and existing should get updated
    *  @name testPromotionalAssortment
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testmethod void testPromotionalAssortment_digital_negativeTest_2(){
        //dataForUploadExtract_Test('digital');
		dataForUploadExtract_Digital_Test();
        
        List<Pricebook2> priceBookList = [Select Id,Name from Pricebook2 Where Name = 'test PB digital' limit 1];
        List<Product2> productList = [Select id,productCode,External_Id__c,IsActive from Product2 where productCode = 'digitalCode' LIMIT 1];
        productList[0].recordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
        //productList[0].IsActive = false;
        update productList;
        
        list<Account> lstAccount = [Select id,Price_Book__c from Account limit 1];
        lstAccount[0].Price_Book__c = priceBookList[0].Id;
        update lstAccount;
        
        list<Bundle__c> lstAssortment = [Select id,Price_Book__c,Pricing_Account__c,Start_Date__c,End_Date__c,CurrencyISOCode from Bundle__c LIMIT 1];
        lstAssortment[0].recordTypeId=CRM_RecordTypeUtil.RT_Promotional_Assortment;
        lstAssortment[0].Price_Book__c = priceBookList[0].Id;
        update lstAssortment;
        
        Assortment_Account__c AssrtmntAccount = CRM_TestDataFactory.createAssortmentAccount(lstAssortment[0],lstAccount[0]);
        insert AssrtmntAccount;

        List<Bundle_Product__c> lstBundlesProduct  = CRM_TestDataFactory.createBundleProducts(lstAssortment, productList, 1, true);
        system.assertEquals(1,lstBundlesProduct.size());

        Test.startTest();
            PageReference pageRef = Page.CRM_UploadAssortmentProducts;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',lstAssortment[0].id);
            ApexPages.standardController controller = new ApexPages.standardController(lstAssortment[0]);
                     
            CRM_UploadAssortmentProductsController pg = new CRM_UploadAssortmentProductsController(controller);
            pg.getUserLocale();
            pg.getDigitalDeal();
            list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> lineItems = CRM_UploadAssortmentProductsController.getAssortmentLineItems(lstAssortment[0].id);
            
			//insert new Record
            CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper wrapper = new CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper();
            CRM_UploadAssortmentProductsController.DigitalDealWrapper digitalWrap = new CRM_UploadAssortmentProductsController.DigitalDealWrapper();
            wrapper.lineItemRecord=lineItems[0].lineItemRecord.clone(false);
            digitalWrap.videoVersion = 'digitalCode';
            digitalWrap.channel = 'EST';
            digitalWrap.format = 'HD';
            digitalWrap.language = 'en';
            wrapper.digital = digitalWrap;
            wrapper.isRowModified=true;
            wrapper.existingId = null;
            lineItems.add(wrapper);
            list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> savedlineItems = CRM_UploadAssortmentProductsController.setAssortmentLineItems(lineItems,lstAssortment[0].id,true);
            system.assertEquals(Label.CRM_Upload_Message_Type_Mismatch, savedlineItems[0].validation);

         Test.stopTest();    
    }
     /**
    *  Test 6: Req#808 Negative testing 3
    *  Expected: new record should get inserted and existing should get updated
    *  @name testPromotionalAssortment
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testmethod void testPromotionalAssortment_physical_negativeTest_3(){
        //dataForUploadExtract_Test('physical');
		dataForUploadExtract_Physical_Test();
        
        List<Pricebook2> priceBookList = [Select Id,Name from Pricebook2 Where Name = 'test PB physical' limit 1];
        List<Product2> productList = [Select id,productCode,External_Id__c,Universal_Picture_Code__c from Product2 where productCode = 'physicalCode'];
        list<Account> lstAccount = [Select id,Price_Book__c from Account limit 1];
        lstAccount[0].Price_Book__c = priceBookList[0].Id;
        update lstAccount;
        
        list<Bundle__c> lstAssortment = [Select id,Price_Book__c,Pricing_Account__c,Start_Date__c,End_Date__c,CurrencyISOCode from Bundle__c LIMIT 1];
        lstAssortment[0].recordTypeId=CRM_RecordTypeUtil.RT_Promotional_Assortment;
        lstAssortment[0].Price_Book__c = priceBookList[0].Id;
        update lstAssortment;
        
        Assortment_Account__c AssrtmntAccount = CRM_TestDataFactory.createAssortmentAccount(lstAssortment[0],lstAccount[0]);
        insert AssrtmntAccount;

        List<Bundle_Product__c> lstBundlesProduct  = CRM_TestDataFactory.createBundleProducts(lstAssortment, productList, 1, true);
        system.assertEquals(1,lstBundlesProduct.size());

        Test.startTest();
            PageReference pageRef = Page.CRM_UploadAssortmentProducts;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',lstAssortment[0].id);
            ApexPages.standardController controller = new ApexPages.standardController(lstAssortment[0]);
                     
            CRM_UploadAssortmentProductsController pg = new CRM_UploadAssortmentProductsController(controller);
            pg.getUserLocale();
            pg.getDigitalDeal();
            list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> lineItems = CRM_UploadAssortmentProductsController.getAssortmentLineItems(lstAssortment[0].id);
            
			//insert new physical lineItem Record
            CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper wrapper = new CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper();
            wrapper.lineItemRecord=lineItems[0].lineItemRecord.clone(false);
            wrapper.lineItemRecord.Product__r.productCode ='physicalCode3';
            wrapper.lineItemRecord.Product__r.Universal_Picture_Code__c='upc3';
            wrapper.isRowModified=true;
            wrapper.existingId = null;
            lineItems.add(wrapper);
            list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> savedlineItems = CRM_UploadAssortmentProductsController.setAssortmentLineItems(lineItems,lstAssortment[0].id,false);
            system.assertEquals(Label.CRM_Upload_Message_NotFound, savedlineItems[0].validation);
         Test.stopTest();    
    }
     /**
    *  Test 7: Req#808 Negative testing 4
    *  Expected: new record should get inserted and existing should get updated
    *  @name testPromotionalAssortment
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testmethod void testPromotionalAssortment_physical_negativeTest_4(){
        //dataForUploadExtract_Test('physical');
		dataForUploadExtract_Physical_Test();
        
        List<Pricebook2> priceBookList = [Select Id,Name from Pricebook2 Where Name = 'test PB physical' limit 1];
        List<Product2> productList = [Select id,productCode,External_Id__c,Universal_Picture_Code__c from Product2 where productCode = 'physicalCode'];
        list<Account> lstAccount = [Select id,Price_Book__c from Account limit 1];
        lstAccount[0].Price_Book__c = priceBookList[0].Id;
        update lstAccount;
        
        /*List<Pricebook_Entry_Period__c> pbepList1 = [SELECT Id,Price_Book__c,Start_Date__c,Product__c,End_Date__c from Pricebook_Entry_Period__c where Product__c !=:productList[0].id ];
        pbepList1[0].Start_Date__c =  system.today() + 10;
        pbepList1[0].End_Date__c = pbepList1[0].Start_Date__c + 10;
      
      pbep.Start_Date__c = lstBundles[0].Start_Date__c - 1;
        pbep.End_Date__c = pbep.Start_Date__c + 31;
        lstBundles[0].Start_Date__c = system.today();
		lstBundles[0].End_Date__c = system.today()+30;
        pbep.Start_Date__c <= dw.dealEndDate && pbep.End_Date__c >= dw.dealStartDate 
        update pbepList1;       */
        
        list<Bundle__c> lstAssortment = [Select id,Price_Book__c,Pricing_Account__c,Start_Date__c,End_Date__c,CurrencyISOCode from Bundle__c LIMIT 1];
        lstAssortment[0].recordTypeId=CRM_RecordTypeUtil.RT_Promotional_Assortment;
        lstAssortment[0].Price_Book__c = priceBookList[0].Id;
        update lstAssortment;
        
        Assortment_Account__c AssrtmntAccount = CRM_TestDataFactory.createAssortmentAccount(lstAssortment[0],lstAccount[0]);
        insert AssrtmntAccount;

        List<Bundle_Product__c> lstBundlesProduct  = CRM_TestDataFactory.createBundleProducts(lstAssortment, productList, 1, true);
        system.assertEquals(1,lstBundlesProduct.size());

        Test.startTest();
            PageReference pageRef = Page.CRM_UploadAssortmentProducts;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',lstAssortment[0].id);
            ApexPages.standardController controller = new ApexPages.standardController(lstAssortment[0]);
                     
            CRM_UploadAssortmentProductsController pg = new CRM_UploadAssortmentProductsController(controller);
            pg.getUserLocale();
            pg.getDigitalDeal();
            list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> lineItems = CRM_UploadAssortmentProductsController.getAssortmentLineItems(lstAssortment[0].id);
            
			//insert new physical lineItem Record
            CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper wrapper = new CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper();
            wrapper.lineItemRecord=lineItems[0].lineItemRecord.clone(false);
            wrapper.lineItemRecord.Product__r.productCode ='physicalCode2';
            wrapper.lineItemRecord.Product__r.Universal_Picture_Code__c='upc2';
            wrapper.isRowModified=true;
            wrapper.existingId = null;
            lineItems.add(wrapper);
            list<CRM_UploadAssortmentProductsController.AssortmentLineItemWrapper> savedlineItems = CRM_UploadAssortmentProductsController.setAssortmentLineItems(lineItems,lstAssortment[0].id,false);
            system.assertEquals(Label.CRM_Upload_Message_NotFound, savedlineItems[0].validation);
            
            try{
                Product2 p = new Product2();
                update p;
            }catch(system.Exception e){
                CRM_UploadAssortmentProductsController.logException(lstAccount[0].Id,e);
            }
         Test.stopTest();    
    }
    
    /**
    *  Test 1: Req#936 
    *  Expected: High level deal should be created  
    *  @name testManageAssortmentSellInForecast_Test1
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testmethod void testManageAssortmentSellInForecast_Test1() {
		dataForUploadExtract_Physical_Test();
		
		List<Pricebook2> priceBookList = [Select Id,Name from Pricebook2 Where Name = 'test PB physical' limit 1];
        List<Product2> productList = [Select id,productCode,External_Id__c,Universal_Picture_Code__c from Product2 where productCode = 'physicalCode'];
        list<Account> lstAccount = [Select id,Price_Book__c from Account limit 2];
        lstAccount[0].Price_Book__c = priceBookList[0].Id;
        update lstAccount;
        
        list<Bundle__c> lstAssortment = [Select id,Price_Book__c,Pricing_Account__c,Start_Date__c,End_Date__c,CurrencyISOCode from Bundle__c LIMIT 1];
        lstAssortment[0].recordTypeId=CRM_RecordTypeUtil.RT_Promotional_Assortment;
        lstAssortment[0].Price_Book__c = priceBookList[0].Id;
        lstAssortment[0].Pricing_Account__c = lstAccount[0].Id;
        update lstAssortment;
        
        Assortment_Account__c AssrtmntAccount = CRM_TestDataFactory.createAssortmentAccount(lstAssortment[0],lstAccount[0]);
        insert AssrtmntAccount;
        
        Assortment_Account__c AssrtmntAccount1 = CRM_TestDataFactory.createAssortmentAccount(lstAssortment[0],lstAccount[1]);
        insert AssrtmntAccount1;
        
        Test.startTest();
        CRM_PublishAssortmentsController.publishAssortment(lstAssortment[0].Id);
        Test.stopTest();
        System.assertEquals([SELECT Count() FROM Opportunity WHERE Recordtype.DeveloperName = 'High_Level'], 2);
        System.assertEquals([SELECT Count() FROM OpportunityLineItem], 0);
    }
    
    /**
    *  Test 2: Req#936 
    *  Expected: physical deal should be created with Products 
    *  @name testManageAssortmentSellInForecast_Test2
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testmethod void testManageAssortmentSellInForecast_Test2() {
		dataForUploadExtract_Physical_Test();
		
		List<Pricebook2> priceBookList = [Select Id,Name from Pricebook2 Where Name = 'test PB physical' limit 1];
        List<Product2> productList = [Select id,productCode,External_Id__c,Universal_Picture_Code__c from Product2 where productCode in ('physicalCode', 'physicalCode1')];
        list<Account> lstAccount = [Select id,Price_Book__c from Account limit 2];
        lstAccount[0].Price_Book__c = priceBookList[0].Id;
        update lstAccount;
        
        list<Bundle__c> lstAssortment = [Select id,Price_Book__c,Pricing_Account__c,Start_Date__c,End_Date__c,CurrencyISOCode from Bundle__c LIMIT 1];
        lstAssortment[0].recordTypeId=CRM_RecordTypeUtil.RT_Promotional_Assortment;
        lstAssortment[0].Price_Book__c = priceBookList[0].Id;
        lstAssortment[0].Pricing_Account__c = lstAccount[0].Id;
        update lstAssortment;
        
        List<Bundle_Product__c> lstBundlesProduct  = CRM_TestDataFactory.createBundleProducts(lstAssortment, productList, 1, true);
        lstBundlesProduct[0].Automatically_Add_Product__c = true;
        update lstBundlesProduct;
        system.assertEquals(2,lstBundlesProduct.size());
        
        Assortment_Account__c AssrtmntAccount = CRM_TestDataFactory.createAssortmentAccount(lstAssortment[0],lstAccount[0]);
        insert AssrtmntAccount;
        
        Assortment_Account__c AssrtmntAccount1 = CRM_TestDataFactory.createAssortmentAccount(lstAssortment[0],lstAccount[1]);
        insert AssrtmntAccount1;
        
        Test.startTest();
        CRM_PublishAssortmentsController.publishAssortment(lstAssortment[0].Id);
        Test.stopTest();
        System.assertEquals([SELECT Count() FROM Opportunity WHERE Recordtype.DeveloperName =: CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_DEAL], 2);
        System.assertEquals([SELECT Count() FROM OpportunityLineItem], 2);
    }
    
    /**
    *  Test 3: Req#936 
    *  Expected: physical deal should be created with all Products as Automatically_Add_Products__c flag is true on Assortment 
    *  @name testManageAssortmentSellInForecast_Test3
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testmethod void testManageAssortmentSellInForecast_Test3() {
		dataForUploadExtract_Physical_Test();
		
		List<Pricebook2> priceBookList = [Select Id,Name from Pricebook2 Where Name = 'test PB physical' limit 1];
        List<Product2> productList = [Select id,productCode,External_Id__c,Universal_Picture_Code__c from Product2 where productCode in ('physicalCode', 'physicalCode1')];
        list<Account> lstAccount = [Select id,Price_Book__c from Account limit 2];
        lstAccount[0].Price_Book__c = priceBookList[0].Id;
        update lstAccount;
        
        list<Bundle__c> lstAssortment = [Select id,Price_Book__c,Pricing_Account__c,Start_Date__c,End_Date__c,CurrencyISOCode from Bundle__c LIMIT 1];
        lstAssortment[0].recordTypeId=CRM_RecordTypeUtil.RT_Promotional_Assortment;
        lstAssortment[0].Price_Book__c = priceBookList[0].Id;
        lstAssortment[0].Pricing_Account__c = lstAccount[0].Id;
        lstAssortment[0].Automatically_Add_Products__c = true;
        update lstAssortment;
        
        List<Bundle_Product__c> lstBundlesProduct  = CRM_TestDataFactory.createBundleProducts(lstAssortment, productList, 1, true);
        system.assertEquals(2,lstBundlesProduct.size());
        
        Assortment_Account__c AssrtmntAccount = CRM_TestDataFactory.createAssortmentAccount(lstAssortment[0],lstAccount[0]);
        insert AssrtmntAccount;
        
        Assortment_Account__c AssrtmntAccount1 = CRM_TestDataFactory.createAssortmentAccount(lstAssortment[0],lstAccount[1]);
        insert AssrtmntAccount1;
        
        System.assertEquals([SELECT Count() FROM Opportunity WHERE Recordtype.DeveloperName =: CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_DEAL], 0);
        System.assertEquals([SELECT Count() FROM OpportunityLineItem], 0);
        
        Test.startTest();
        CRM_PublishAssortmentsController.publishAssortment(lstAssortment[0].Id);
        Test.stopTest();
        
        System.assertEquals([SELECT Count() FROM Opportunity WHERE Recordtype.DeveloperName =: CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_DEAL], 2);
        System.assertEquals([SELECT Count() FROM OpportunityLineItem], 4);
    }
    
    /**
    *  Test 4: Req#936 
    *  Expected: High level deal should be converted to physical deal
    *  @name testManageAssortmentSellInForecast_Test4
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testmethod void testManageAssortmentSellInForecast_Test4() {
		dataForUploadExtract_Physical_Test();
		
		List<Pricebook2> priceBookList = [Select Id,Name from Pricebook2 Where Name = 'test PB physical' limit 1];
        List<Product2> productList = [Select id,productCode,External_Id__c,Universal_Picture_Code__c from Product2 where productCode = 'physicalCode'];
        list<Account> lstAccount = [Select id,Price_Book__c from Account limit 1]; 
        lstAccount[0].Price_Book__c = priceBookList[0].Id;
        update lstAccount;
        
        list<Bundle__c> lstAssortment = [Select id,Price_Book__c,Pricing_Account__c,Start_Date__c,End_Date__c,CurrencyISOCode from Bundle__c LIMIT 1];
        lstAssortment[0].recordTypeId=CRM_RecordTypeUtil.RT_Promotional_Assortment;
        lstAssortment[0].Price_Book__c = priceBookList[0].Id;
        lstAssortment[0].Pricing_Account__c = lstAccount[0].Id;
        lstAssortment[0].Automatically_Add_Products__c = true;
        update lstAssortment;
        
        List<Bundle_Product__c> lstBundlesProduct  = CRM_TestDataFactory.createBundleProducts(lstAssortment, productList, 1, true);
        system.assertEquals(1,lstBundlesProduct.size());
        
        Assortment_Account__c AssrtmntAccount = CRM_TestDataFactory.createAssortmentAccount(lstAssortment[0],lstAccount[0]);
        insert AssrtmntAccount;
        
        List<Opportunity> opps = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount,1, false);
        opps[0].recordTypeId = CRM_RecordTypeUtil.RT_DEAL_HIGH_LEVEL;
        opps[0].Account = lstAccount[0];
        opps[0].Bundle__c = lstAssortment[0].Id;
        opps[0].UniquePublishKey__c = lstAssortment[0].Id +'-'+ lstAccount[0].Id;
        insert opps;
        
        System.assertEquals([SELECT Count() FROM Opportunity], 1);
        System.assertEquals([SELECT Count() FROM Opportunity WHERE Recordtype.DeveloperName =: CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_HIGH_LEVEL_DEAL], 1);
        
        Test.startTest();
        CRM_PublishAssortmentsController.publishAssortment(lstAssortment[0].Id);
        Test.stopTest();
        
        System.assertEquals([SELECT Count() FROM Opportunity], 1);
        System.assertEquals([SELECT Count() FROM Opportunity WHERE Recordtype.DeveloperName =: CRM_AppConstants.OPPORTUNITY_RECORDTYPE_DEVELOPERNAME_PHYSICAL_DEAL], 1);
        System.assertEquals([SELECT Count() FROM OpportunityLineItem], 1);
        CRM_PublishAssortmentsController.publishAssortment(lstAssortment[0].Id);
        priceBookList[0].Product_Type__c = CRM_AppConstants.DIGITAL_INITIALS;
        update priceBookList[0];
        
        lstAssortment = [Select Id, CurrencyISOCode, (Select Id, Product__c from Bundle_Products__r) from Bundle__c LIMIT 1];
        opps = [Select Id, Pricebook2Id from Opportunity];
        CRM_PublishAssortmentHelper.getPricebookEntries(lstAssortment, opps);
    }
    
    /**
    *  Test 5: Req#936 
    *  Expected: Deal stage should be Cancelled if related Assortment status is Cancelled
    *  @name testManageAssortmentSellInForecast_Test5
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    static testmethod void testManageAssortmentSellInForecast_Test5() {
    	dataForUploadExtract_Physical_Test();
		
		List<Pricebook2> priceBookList = [Select Id,Name from Pricebook2 Where Name = 'test PB physical' limit 1];
        List<Product2> productList = [Select id,productCode,External_Id__c,Universal_Picture_Code__c from Product2 where productCode = 'physicalCode'];
        list<Account> lstAccount = [Select id,Price_Book__c from Account limit 1]; 
        lstAccount[0].Price_Book__c = priceBookList[0].Id;
        update lstAccount;
        
        list<Bundle__c> lstAssortment = [Select id,Price_Book__c,Pricing_Account__c,Start_Date__c,End_Date__c,CurrencyISOCode from Bundle__c LIMIT 1];
        lstAssortment[0].recordTypeId=CRM_RecordTypeUtil.RT_Promotional_Assortment;
        lstAssortment[0].Price_Book__c = priceBookList[0].Id;
        lstAssortment[0].Pricing_Account__c = lstAccount[0].Id;
        lstAssortment[0].Automatically_Add_Products__c = true;
        update lstAssortment;
        
        List<Bundle_Product__c> lstBundlesProduct  = CRM_TestDataFactory.createBundleProducts(lstAssortment, productList, 1, true);
        system.assertEquals(1,lstBundlesProduct.size());
        
        Assortment_Account__c AssrtmntAccount = CRM_TestDataFactory.createAssortmentAccount(lstAssortment[0],lstAccount[0]);
        insert AssrtmntAccount;
        
        List<Opportunity> opps = CRM_TestDataFactory.createOpportunitiesWithAccounts(lstAccount,1, false);
        opps[0].recordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
        opps[0].Account = lstAccount[0];
        opps[0].Bundle__c = lstAssortment[0].Id;
        opps[0].UniquePublishKey__c = lstAssortment[0].Id +'-'+ lstAccount[0].Id;
        opps[0].Last_Published_Date__c = System.today();
        insert opps;
        
        Test.startTest();
        lstAssortment[0].Assortment_Status__c = CRM_AppConstants.ASSORTMENT_STATUS_CANCELLED;
        update lstAssortment[0];
        Apexpages.standardController std = new Apexpages.standardController(lstAssortment[0]);
        CRM_UploadAssortmentProductsController obj = new CRM_UploadAssortmentProductsController(std);
        CRM_UploadAssortmentProductsController.exportCSVFile(new List<String>{'Product Code', 'Product Name'});
        Test.stopTest();
        
        System.assertEquals([SELECT Count() FROM Opportunity WHERE StageName =: CRM_AppConstants.OPPORTUNITY_STAGE_CANCELLED], 1);
        
        opps = [SELECT Id, StageName FROM Opportunity];
        opps[0].StageName = CRM_AppConstants.OPPORTUNITY_STAGE_PLANNED;
        try {
        	update opps[0];
        } catch(Exception ex) {
        	//throws exception becuase cancelled deal is not editable
        }
    }
}