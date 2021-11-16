/**
   @Author Cognizant
   @name CRM_AddBundleProductsController_Test
   @CreateDate 15 Dec 2015
   @Description Test class for CRM_AddBundleProductsController
   @Version <1.0>
   @reference Requirement no 35
  */

@isTest 
private class CRM_AddBundleProductsController_Test{  
	static List<Product2> newProducts;
    
   /**
    *  Create Test Data. 
    *  @name createTestData
    *  @param None
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
	
    @testSetup static void createTestData() {   
    	List<Account> lstAccounts = CRM_TestDataFactory.createAccounts(1, false);   
        lstAccounts[0].RecordTypeID = [select id,Name from RecordType where SobjectType='Account' and Name='Sold To' Limit 1].ID;
		upsert lstAccounts;
		
		List<Bundle__c> bundles = CRM_TestDataFactory.createBundles(1, true);
		
		List<Product_Group__c> lstProductGroup = CRM_TestDataFactory.createProductGroups(1, true);
		System.assertNotEquals(null,lstProductGroup[0].id);
		
        List<Product2> lstProduct = CRM_TestDataFactory.createProducts(lstProductGroup, 200, false); 
        System.assertEquals(200, lstProduct.size());
        for (Product2 prod : lstProduct) {
            prod.ProductCode = '1000230554';
            prod.RecordTypeId = CRM_RecordTypeUtil.RT_PRODUCT_PHYSICAL;
            prod.Product_Format__c = '4';
            prod.Product_Rating__c = 'UK - Minimum 12 Ye';
            prod.Product_Genre__c = 'ACTION';
            prod.Release_Category__c = '23';
            prod.Franchise_Type__c = 'X4';
            prod.Product_Language_Code__c = 'SR';
            prod.SAP_Dist_chain_product_Status__c = '11';
            prod.Type__c = 'Video Physical';
            prod.Recommended_Price__c = 150;
         }
        lstProduct[0].Exclusive_Customer__c = lstAccounts[0].Id;
        insert lstProduct;
        System.assertNotEquals(null,lstProduct[0].id);
        
        newProducts = CRM_TestDataFactory.createProducts(lstProductGroup, 1, false);
        newProducts[0].Product_Format__c = 'Test'; 
        insert newProducts;
        System.assertNotEquals(null,newProducts[0].id);
        
        CRM_TestDataFactory.createPriceBookEntries(lstProduct, 1, true);
        CRM_TestDataFactory.createPriceBookEntryPeriods(lstProduct, 1, true);
        
        CRM_TestDataFactory.createBundleProducts(bundles, lstProduct, 1, true);
         // Insert max Product limit per page
        CRM_TestDataFactory.createMaxProductLimitSetting('Add_Products', 100, true);
    }
    
    /**
     *  Test 1: Test to update existing bundle product.
     *  Expected: Existing bundle products should be added
     *  @name updateDealProduct
     *  @param None
     *  @return None
     *  @throws None
     *  @see com.ac.sample.SuperObject#get
     */
    
    static testMethod void updateDealProduct() {
    	User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
    	
        System.runAs(u) {
	    	Bundle__c currentBundle = [Select ID, Price_Book__c,CurrencyIsoCode FROM Bundle__c][0];
	    	ApexPages.StandardController sc = new ApexPages.StandardController(currentBundle);    	
	    	
			CRM_AddBundleProductsController ctrl = new CRM_AddBundleProductsController(sc);
			String str = ctrl.sourceIp;
			CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
			searchFilter.sortByField = 'Name';
			searchFilter.sortOrder = 'ASC';
			searchFilter.pageCount = 1;			
			searchFilter.title= 'PR';
            searchFilter.text = 'Prod';
            searchFilter.isMarketingMaterial = true;
            searchFilter.recommendedPriceFrom = 100;
            searchFilter.recommendedPriceTo = 500;
            searchFilter.bundleProductsOnly = true;
            searchFilter.materialNumber = '1000230554';
            searchFilter.productFormats = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Format__c', '4');
            searchFilter.productRatings = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Rating__c', 'UK - Minimum 12 Ye');
            searchFilter.productGenres = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Genre__c', 'ACTION');
            searchFilter.releaseCategories = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Release_Category__c', '23');
            searchFilter.franchiseTypes =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Franchise_Type__c', 'X4');
            searchFilter.prodLanguages =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Language_Code__c', 'SR');
            searchFilter.distChainProdStatus =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'SAP_Dist_chain_product_Status__c', '11'); 
            searchFilter.productTypes =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Type__c', 'Video Physical');
            
			CRM_AddBundleProductsController.getFilterPicklistValues('Product2', 'Type__c', '');
			
			CRM_DataObjects.ProductWrapper productWrapper = CRM_AddBundleProductsController.getProducts(currentBundle.Id, currentBundle.Price_Book__c, searchFilter);
			System.assert(productWrapper.products != null, 'Product fetched successfully');
			
			List<CRM_DataObjects.ProductItemSave> lstProductToSave = new List<CRM_DataObjects.ProductItemSave>();
			Boolean isNewProduct = true;
			
			for(CRM_DataObjects.ProductItem prod : productWrapper.products){
				CRM_DataObjects.ProductItemSave productToSave = new CRM_DataObjects.ProductItemSave();
				productToSave.productId = prod.productId;
				productToSave.pricebookEntryId = prod.pricebookEntryId;
				productToSave.quantity = prod.quantity +1;
				productToSave.listPrice = prod.listPrice + 2000;
				lstProductToSave.add(productToSave);
				
				isNewProduct = false;
			}
			CRM_AddBundleProductsController.saveProducts(currentBundle.Id, lstProductToSave);
			
			System.assert(![Select ID FROM Bundle_Product__c WHERE Bundle__c =: currentBundle.ID].isEmpty(), 'Bundle product should be updated');
        }
    }
    
    /**
     *  Test 2: Test to remove existing bundle product.
     *  Expected: Existing bundle products should be removed
     *  @name removeDealProduct
     *  @param None
     *  @return None
     *  @throws None
     *  @see com.ac.sample.SuperObject#get
     */
    
    static testMethod void removeDealProduct() {
    	User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
    	
        System.runAs(u) {
	    	Bundle__c currentBundle = [Select ID, Price_Book__c,CurrencyIsoCode FROM Bundle__c][0];
	    	ApexPages.StandardController sc = new ApexPages.StandardController(currentBundle);    	
	    	
			CRM_AddBundleProductsController ctrl = new CRM_AddBundleProductsController(sc);
			CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
			searchFilter.sortByField = 'Name';
			searchFilter.sortOrder = 'ASC';
			searchFilter.pageCount = 1;
			searchFilter.title= 'PR';
            //searchFilter.text = 'Prod';
            searchFilter.isMarketingMaterial = true;
            searchFilter.recommendedPriceFrom = 100;
            searchFilter.recommendedPriceTo = 500;
            searchFilter.bundleProductsOnly = true;
            searchFilter.materialNumber = '1000230554';
            searchFilter.productFormats = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Format__c', '4');
            searchFilter.productRatings = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Rating__c', 'UK - Minimum 12 Ye');
            searchFilter.productGenres = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Genre__c', 'ACTION');
            searchFilter.releaseCategories = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Release_Category__c', '23');
            searchFilter.franchiseTypes =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Franchise_Type__c', 'X4');
            searchFilter.prodLanguages =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Language_Code__c', 'SR');
            searchFilter.distChainProdStatus =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'SAP_Dist_chain_product_Status__c', '11'); 
            searchFilter.productTypes =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Type__c', 'Video Physical');
			CRM_AddBundleProductsController.getFilterPicklistValues('Product2', 'Type__c', '');
			
			CRM_DataObjects.ProductWrapper productWrapper = CRM_AddBundleProductsController.getProducts(currentBundle.Id, currentBundle.Price_Book__c, searchFilter);
			System.assert(productWrapper.products != null, 'Product fetched successfully');
			
			List<CRM_DataObjects.ProductItemSave> lstProductToSave = new List<CRM_DataObjects.ProductItemSave>();
			Boolean isNewProduct = true;
			
			for(CRM_DataObjects.ProductItem prod : productWrapper.products){
				CRM_DataObjects.ProductItemSave productToSave = new CRM_DataObjects.ProductItemSave();
				productToSave.productId = prod.productId;
				productToSave.pricebookEntryId = prod.pricebookEntryId;
				productToSave.quantity = 0;
				productToSave.listPrice = prod.listPrice;
				lstProductToSave.add(productToSave);
				
				isNewProduct = false;
			}
			
			CRM_AddBundleProductsController.saveProducts(currentBundle.Id, lstProductToSave);
			
			//System.assert([Select ID FROM Bundle_Product__c WHERE Bundle__c =: currentBundle.ID].isEmpty(), 'Bundle product should be deleted');
        }
    }
    
    /**
     *  Test 3: Test to add new bundle product. 
     *  Expected: New bundle products should be added
     *  @name addDealProduct
     *  @param None
     *  @return None
     *  @throws None
     *  @see com.ac.sample.SuperObject#get
     */
    
    static testMethod void addDealProduct() {
    	User u = [Select Id from User where Profile.Name = 'System Administrator' and isActive = true Limit 1];
    	
        System.runAs(u) {
	    	Bundle__c currentBundle = [Select ID, Price_Book__c,CurrencyIsoCode FROM Bundle__c][0];
	    	List<Bundle_Product__c> bundleProduct = [Select ID FROM Bundle_Product__c where Bundle__c = :currentBundle.Id];
	        delete bundleProduct;
	        
	    	ApexPages.StandardController sc = new ApexPages.StandardController(currentBundle);    	
	    	
			CRM_AddBundleProductsController ctrl = new CRM_AddBundleProductsController(sc);
			CRM_DataObjects.SearchFilters searchFilter = new CRM_DataObjects.SearchFilters();
			searchFilter.sortByField = 'Name';
			searchFilter.sortOrder = 'ASC';
			searchFilter.pageCount = 1;
			searchFilter.title= 'PR';
            //searchFilter.text = 'Prod';
            //searchFilter.isMarketingMaterial = true;
            searchFilter.recommendedPriceFrom = 100;
            searchFilter.recommendedPriceTo = 500;
            //searchFilter.bundleProductsOnly = false;
            searchFilter.materialNumber = '1000230554';
            searchFilter.productFormats = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Format__c', '4');
            searchFilter.productRatings = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Rating__c', 'UK - Minimum 12 Ye');
            searchFilter.productGenres = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Genre__c', 'ACTION');
            searchFilter.releaseCategories = CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Release_Category__c', '23');
            searchFilter.franchiseTypes =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Franchise_Type__c', 'X4');
            searchFilter.prodLanguages =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Product_Language_Code__c', 'SR');
            searchFilter.distChainProdStatus =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'SAP_Dist_chain_product_Status__c', '11'); 
            searchFilter.productTypes =  CRM_AddOrderProductsController.getFilterPicklistValues('Product2', 'Type__c', 'Video Physical');
            
			CRM_AddBundleProductsController.getFilterPicklistValues('Product2', 'Type__c', '');
			
			CRM_DataObjects.ProductWrapper productWrapper = CRM_AddBundleProductsController.getProducts(currentBundle.Id, currentBundle.Price_Book__c, searchFilter);
			System.assert(productWrapper.products != null, 'Product fetched successfully');
			
			List<CRM_DataObjects.ProductItemSave> lstProductToSave = new List<CRM_DataObjects.ProductItemSave>();
			Boolean isNewProduct = true;
			
			for(CRM_DataObjects.ProductItem prod : productWrapper.products){
				CRM_DataObjects.ProductItemSave productToSave = new CRM_DataObjects.ProductItemSave();
				productToSave.productId = prod.productId;
				productToSave.pricebookEntryId = prod.pricebookEntryId;
				productToSave.quantity = 1;
				productToSave.listPrice = prod.listPrice;
				lstProductToSave.add(productToSave);
				
				isNewProduct = false;
			}
			
			CRM_AddBundleProductsController.saveProducts(currentBundle.Id, lstProductToSave);
			
			//System.assert(![Select ID FROM Bundle_Product__c WHERE Bundle__c =: currentBundle.ID].isEmpty(), 'Bundle product should be created');
        }
    }
}