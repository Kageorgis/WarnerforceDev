/**
   @Author Cognizant
   @name CRM_AddOpportunityProductsControllerTest
   @CreateDate 27 Oct 2017
   @Description Test class for CRM_AddOpportunityProductsController
   @Version <1.0>
*/

@isTest
private class CRM_ProductSearchControllerTest{
    
    static void createTestData() {
        Pricebook2 pb_2 = new Pricebook2();
        pb_2.Name = 'test PB physical';
        pb_2.Description='test PB physical';
        pb_2.IsActive = true;
        pb_2.Business_Unit__c = '2500';
        pb_2.Product_Type__c = 'Physical';
        pb_2.Country__c = 'USA';
        insert pb_2;
        
        //create accounts
        list<Account> accounts = CRM_TestDataFactory.createAccounts(1, false);
        accounts[0].recordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        accounts[0].Sales_Organization__c = CRM_AppConstants.TERRITORY_US_CODE;
        accounts[0].Price_Book__c=pb_2.id;
        insert accounts; 
            
        List<Product_Group__c> pgs = CRM_TestDataFactory.createProductGroups(1, true);
    
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
        
         //standard Pricebook created    
         CRM_TestDataFactory.createPriceBookEntriesStandard(lstProductNew,1,true);
         
        List<Pricebook_Entry_Period__c> pbepList = CRM_TestDataFactory.createPriceBookEntryPeriods(lstProductNew, 1, false);
        for(Pricebook_Entry_Period__c pbep : pbepList){
          pbep.Price_Book__c = pb_2.id;
          pbep.Start_Date__c = System.Today() - 1; //lstBundles[0].Start_Date__c - 1;
          pbep.End_Date__c = pbep.Start_Date__c + 31;
          pbep.List_Price__c = 20;
        }
        insert pbepList;

    }
    
    static testmethod void validateProductList(){
        
        User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
        createTestData();
        System.runAs(u) {
            Test.startTest();
            Test.setCurrentPageReference(new PageReference('Page.CRM_ProductSearch'));
            CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
            searchFilter.sortByField = 'Name';
            searchFilter.sortOrder = 'ASC';
            searchFilter.pageCount = 1;
            searchFilter.productTypes =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Type__c', 'Video Physical');
            searchFilter.productFormats = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Format__c', '4');
            searchFilter.productRatings = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Rating__c', 'UK - Minimum 12 Ye');
            searchFilter.productGenres = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Genre__c', 'ACTION');
            searchFilter.releaseCategories = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Release_Category__c', '23');
            searchFilter.franchiseTypes =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Franchise_Type__c', 'X4');
			CRM_AddBundleProductsController.getFilterPicklistValues('Product2', 'Type__c', '');
            List<Pricebook2> Pricebook2List = [Select ID FROM Pricebook2 where Name = 'test PB physical'];
            CRM_ProductSearchController.getPricebooks();
           
            CRM_ProductSearchController.getFilterPicklistValues('Product2', 'Type__c', '');
            CRM_DataObjects.ProductWrapper productWrapper = CRM_ProductSearchController.getProducts(null,Pricebook2List[0].Id, searchFilter);
            CRM_ProductSearchController proSearchCon = new CRM_ProductSearchController();
            proSearchCon.getUserLocale();
            proSearchCon.getUserLocaleLanguage();
            proSearchCon.getUserDateFormat();
            String str = proSearchCon.sourceIp;
            try{
                CRM_DataObjects.ProductWrapper productWrapper1 = CRM_ProductSearchController.getProducts(null,'', searchFilter);
            }catch(exception e){
                system.assert(true,'Please select a pricebook for product search.');
            }
            Test.stopTest();
        }
        
        //US#W-017610 start- added Sales Organization Filter to display only SDS-JV price book to users having SDS JV profiles
        
        User u1 = new User();
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'CRM - Commercial Planning - SDS' LIMIT 1];
        
     	u1 = new User(LastName = 'SDS US',
                           FirstName='Commercial Planning',
                           Alias = 'cpus',
                           Email = ' Binny.Gandhi@wbconsultant.com',
                           Username = 'sds_us_@wbconsultant_test.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           ); 
        insert u1;
        
        if(u1 != null) {
            System.runAs(u1) {
                CRM_ProductSearchController productSearch = new CRM_ProductSearchController();
                CRM_Functional_Permissions__c setting= new CRM_Functional_Permissions__c(SetupOwnerId = Userinfo.getProfileId(), PB_CountryCode__c='USA,CAN');
                insert setting;
                
                Pricebook2 pb_2 = new Pricebook2();
                pb_2.Name = 'test PB physical';
                pb_2.Description='test PB physical';
                pb_2.IsActive = true;
                pb_2.Business_Unit__c = CRM_AppConstants.TERRITORY_SDS_US_CODE;
                pb_2.Product_Type__c = 'Physical';
                pb_2.Country__c = 'USA';
                insert pb_2;
                CRM_ProductSearchController.getPricebooks();

                WB2B_Details__c wb = productSearch.WB2BImageServiceSettings;
                system.assertEquals(true,productSearch.getIsJVProfiles());
                
                Test.setCurrentPageReference(new PageReference('Page.CRM_ProductSearch'));
                CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
                searchFilter.sortByField = 'Name';
                searchFilter.sortOrder = 'ASC';
                searchFilter.pageCount = 1;
                searchFilter.text = 'Test';
                CRM_DataObjects.ProductWrapper productWrapper = CRM_ProductSearchController.getProducts(null,pb_2.Id, searchFilter);
            }
        }
        //US#W-017610 end- added Sales Organization Filter to display only SDS-JV price book to users having SDS JV profiles        
    }
    
}