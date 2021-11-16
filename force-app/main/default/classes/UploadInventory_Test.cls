/******* 
UploadInventory_Test
Creation Date- 02 August 2016
Description- This class is to do code coverage for UploadInventory_CC and UploadInventory_Batch
Author- Walter Ynche
*******/

@IsTest
private class UploadInventory_Test{
    
    static testMethod void uploadInventorySuccessTest(){  
		//create products
      	List<Product2> lstProduct = new List<Product2>();
      
  		Product2 productC2 = new Product2();
  		productC2.Name = 'C2';
		productC2.Family = 'Print';
	  	productC2.IsActive = true;
	  	lstProduct.add(productC2);
  
  		Product2 productC3 = new Product2();
  		productC3.Name = 'C3';
  		productC3.Family = 'Print';
  		productC3.IsActive = true;
  		lstProduct.add(productC3);
  
  		Product2 productC4 = new Product2();
  		productC4.Name = 'C4';
  		productC4.Family = 'Print';
  		productC4.IsActive = true;
  		lstProduct.add(productC4);
  
  		Product2 productFirstRHP = new Product2();
  		productFirstRHP.Name = 'First RHP';
  		productFirstRHP.Family = 'Print';
  		productFirstRHP.IsActive = true;
  		lstProduct.add(productFirstRHP);
  
  		Product2 productSecondRHP = new Product2();
  		productSecondRHP.Name = 'Second RHP';
  		productSecondRHP.Family = 'Print';
  		productSecondRHP.IsActive = true;
  		lstProduct.add(productSecondRHP);
  
	  	Product2 productFirstSpread = new Product2();
  		productFirstSpread.Name = 'First Spread';
  		productFirstSpread.Family = 'Print';
  		productFirstSpread.IsActive = true;
  		lstProduct.add(productFirstSpread);
  
  		Product2 productCenterSpread = new Product2();
  		productCenterSpread.Name = 'Center Spread';
  		productCenterSpread.Family = 'Print';
  		productCenterSpread.IsActive = true;
  		lstProduct.add(productCenterSpread);
	  
  		Product2 productInteriorPage = new Product2();
  		productInteriorPage.Name = 'Interior Page';
  		productInteriorPage.Family = 'Print';
  		productInteriorPage.IsActive = true;
  		lstProduct.add(productInteriorPage);
  
 	 	insert lstProduct;
  
  		//create Inventory
  		List<Inventory__c> lstInventory = new List<Inventory__c>();
  
  		Inventory__c inventoryC2Everyone = new Inventory__c();
  		inventoryC2Everyone.Target_Cover_Rating__c = 'E - Everyone';
  		inventoryC2Everyone.Product__c = productC2.Id;
  		inventoryC2Everyone.Onsale_Availability__c = 'Weekly';
  		inventoryC2Everyone.Quantity__c = 1;
  		inventoryC2Everyone.External_ID__c = productC2.Name + ' ' + inventoryC2Everyone.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC2Everyone);
  
  		Inventory__c inventoryC3Everyone = new Inventory__c();
  		inventoryC3Everyone.Target_Cover_Rating__c = 'E - Everyone';
  		inventoryC3Everyone.Product__c = productC3.Id;
  		inventoryC3Everyone.Onsale_Availability__c = 'Weekly';
  		inventoryC3Everyone.Quantity__c = 1;
  		inventoryC3Everyone.External_ID__c = productC3.Name + ' ' + inventoryC3Everyone.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC3Everyone);
  
  		Inventory__c inventoryC4Everyone = new Inventory__c();
  		inventoryC4Everyone.Target_Cover_Rating__c = 'E - Everyone';
  		inventoryC4Everyone.Product__c = productC4.Id;
  		inventoryC4Everyone.Onsale_Availability__c = 'Weekly';
  		inventoryC4Everyone.Quantity__c = 1;
  		inventoryC4Everyone.External_ID__c = productC4.Name + ' ' + inventoryC4Everyone.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC4Everyone);
  
  		Inventory__c inventoryFirstRHPEveryone = new Inventory__c();
  		inventoryFirstRHPEveryone.Target_Cover_Rating__c = 'E - Everyone';
  		inventoryFirstRHPEveryone.Product__c = productFirstRHP.Id;
  		inventoryFirstRHPEveryone.Onsale_Availability__c = 'Weekly';
  		inventoryFirstRHPEveryone.Quantity__c = 1;
  		inventoryFirstRHPEveryone.External_ID__c = productFirstRHP.Name + ' ' + inventoryFirstRHPEveryone.Target_Cover_Rating__c;
  		lstInventory.add(inventoryFirstRHPEveryone);
        
        Inventory__c inventoryFirstSpreadEveryone = new Inventory__c();
  		inventoryFirstSpreadEveryone.Target_Cover_Rating__c = 'E - Everyone';
  		inventoryFirstSpreadEveryone.Product__c = productFirstSpread.Id;
  		inventoryFirstSpreadEveryone.Onsale_Availability__c = 'Weekly';
  		inventoryFirstSpreadEveryone.Quantity__c = 1;
  		inventoryFirstSpreadEveryone.External_ID__c = productFirstSpread.Name + ' ' + inventoryFirstSpreadEveryone.Target_Cover_Rating__c;
  		lstInventory.add(inventoryFirstSpreadEveryone);
  
  		Inventory__c inventoryC2Teen = new Inventory__c();
  		inventoryC2Teen.Target_Cover_Rating__c = 'T - Teen';
  		inventoryC2Teen.Product__c = productC2.Id;
  		inventoryC2Teen.Onsale_Availability__c = 'Weekly';
  		inventoryC2Teen.Quantity__c = 1;
  		inventoryC2Teen.External_ID__c = productC2.Name + ' ' + inventoryC2Teen.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC2Teen);
  
  		Inventory__c inventoryC3Teen = new Inventory__c();
  		inventoryC3Teen.Target_Cover_Rating__c = 'T - Teen';
  		inventoryC3Teen.Product__c = productC3.Id;
  		inventoryC3Teen.Onsale_Availability__c = 'Weekly';
  		inventoryC3Teen.Quantity__c = 1;
  		inventoryC3Teen.External_ID__c = productC3.Name + ' ' + inventoryC3Teen.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC3Teen);
  
  		Inventory__c inventoryC4Teen = new Inventory__c();
  		inventoryC4Teen.Target_Cover_Rating__c = 'T - Teen';
  		inventoryC4Teen.Product__c = productC4.Id;
  		inventoryC4Teen.Onsale_Availability__c = 'Weekly';
  		inventoryC4Teen.Quantity__c = 1;
  		inventoryC4Teen.External_ID__c = productC4.Name + ' ' + inventoryC4Teen.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC4Teen);
  
  		Inventory__c inventoryFirstRHPTeen = new Inventory__c();
  		inventoryFirstRHPTeen.Target_Cover_Rating__c = 'T - Teen';
  		inventoryFirstRHPTeen.Product__c = productFirstRHP.Id;
  		inventoryFirstRHPTeen.Onsale_Availability__c = 'Weekly';
  		inventoryFirstRHPTeen.Quantity__c = 1;
  		inventoryFirstRHPTeen.External_ID__c = productFirstRHP.Name + ' ' + inventoryFirstRHPTeen.Target_Cover_Rating__c;
  		lstInventory.add(inventoryFirstRHPTeen);
  
  		Inventory__c inventorySecondRHPTeen = new Inventory__c();
  		inventorySecondRHPTeen.Target_Cover_Rating__c = 'T - Teen';
  		inventorySecondRHPTeen.Product__c = productSecondRHP.Id;
  		inventorySecondRHPTeen.Onsale_Availability__c = 'Weekly';
  		inventorySecondRHPTeen.Quantity__c = 1;
  		inventorySecondRHPTeen.External_ID__c = productSecondRHP.Name + ' ' + inventorySecondRHPTeen.Target_Cover_Rating__c;
  		lstInventory.add(inventorySecondRHPTeen);
  
  		Inventory__c inventoryFirstSpreadTeen = new Inventory__c();
  		inventoryFirstSpreadTeen.Target_Cover_Rating__c = 'T - Teen';
  		inventoryFirstSpreadTeen.Product__c = productFirstSpread.Id;
  		inventoryFirstSpreadTeen.Onsale_Availability__c = 'Weekly';
  		inventoryFirstSpreadTeen.Quantity__c = 1;
  		inventoryFirstSpreadTeen.External_ID__c = productFirstSpread.Name + ' ' + inventoryFirstSpreadTeen.Target_Cover_Rating__c;
  		lstInventory.add(inventoryFirstSpreadTeen);
  
  		Inventory__c inventoryCenterSpreadTeen = new Inventory__c();
  		inventoryCenterSpreadTeen.Target_Cover_Rating__c = 'T - Teen';
  		inventoryCenterSpreadTeen.Product__c = productCenterSpread.Id;
  		inventoryCenterSpreadTeen.Onsale_Availability__c = 'Weekly';
  		inventoryCenterSpreadTeen.Quantity__c = 1;
  		inventoryCenterSpreadTeen.External_ID__c = productCenterSpread.Name + ' ' + inventoryCenterSpreadTeen.Target_Cover_Rating__c;
  		lstInventory.add(inventoryCenterSpreadTeen);
  
  		Inventory__c inventoryInteriorPageTeen = new Inventory__c();
  		inventoryInteriorPageTeen.Target_Cover_Rating__c = 'T - Teen';
  		inventoryInteriorPageTeen.Product__c = productInteriorPage.Id;
  		inventoryInteriorPageTeen.Onsale_Availability__c = 'Weekly';
  		inventoryInteriorPageTeen.Quantity__c = 9;
  		inventoryInteriorPageTeen.External_ID__c = productInteriorPage.Name + ' ' + inventoryInteriorPageTeen.Target_Cover_Rating__c;
  		lstInventory.add(inventoryInteriorPageTeen);
        
        Inventory__c inventoryC2TeenMore = new Inventory__c();
  		inventoryC2TeenMore.Target_Cover_Rating__c = 'T+ - Teen+';
  		inventoryC2TeenMore.Product__c = productC2.Id;
  		inventoryC2TeenMore.Onsale_Availability__c = 'Weekly';
  		inventoryC2TeenMore.Quantity__c = 1;
  		inventoryC2TeenMore.External_ID__c = productC2.Name + ' ' + inventoryC2TeenMore.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC2TeenMore);
  
  		Inventory__c inventoryC3TeenMore = new Inventory__c();
  		inventoryC3TeenMore.Target_Cover_Rating__c = 'T+ - Teen+';
  		inventoryC3TeenMore.Product__c = productC3.Id;
  		inventoryC3TeenMore.Onsale_Availability__c = 'Weekly';
  		inventoryC3TeenMore.Quantity__c = 1;
  		inventoryC3TeenMore.External_ID__c = productC3.Name + ' ' + inventoryC3TeenMore.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC3TeenMore);
  
  		Inventory__c inventoryC4TeenMore = new Inventory__c();
  		inventoryC4TeenMore.Target_Cover_Rating__c = 'T+ - Teen+';
  		inventoryC4TeenMore.Product__c = productC4.Id;
  		inventoryC4TeenMore.Onsale_Availability__c = 'Weekly';
  		inventoryC4TeenMore.Quantity__c = 1;
  		inventoryC4TeenMore.External_ID__c = productC4.Name + ' ' + inventoryC4TeenMore.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC4TeenMore);
  
  		Inventory__c inventoryFirstRHPTeenMore = new Inventory__c();
  		inventoryFirstRHPTeenMore.Target_Cover_Rating__c = 'T+ - Teen+';
  		inventoryFirstRHPTeenMore.Product__c = productFirstRHP.Id;
  		inventoryFirstRHPTeenMore.Onsale_Availability__c = 'Weekly';
  		inventoryFirstRHPTeenMore.Quantity__c = 1;
  		inventoryFirstRHPTeenMore.External_ID__c = productFirstRHP.Name + ' ' + inventoryFirstRHPTeenMore.Target_Cover_Rating__c;
  		lstInventory.add(inventoryFirstRHPTeenMore);
  
  		Inventory__c inventorySecondRHPTeenMore = new Inventory__c();
  		inventorySecondRHPTeenMore.Target_Cover_Rating__c = 'T+ - Teen+';
  		inventorySecondRHPTeenMore.Product__c = productSecondRHP.Id;
  		inventorySecondRHPTeenMore.Onsale_Availability__c = 'Weekly';
  		inventorySecondRHPTeenMore.Quantity__c = 1;
  		inventorySecondRHPTeenMore.External_ID__c = productSecondRHP.Name + ' ' + inventorySecondRHPTeenMore.Target_Cover_Rating__c;
  		lstInventory.add(inventorySecondRHPTeenMore);
  
  		Inventory__c inventoryFirstSpreadTeenMore = new Inventory__c();
  		inventoryFirstSpreadTeenMore.Target_Cover_Rating__c = 'T+ - Teen+';
  		inventoryFirstSpreadTeenMore.Product__c = productFirstSpread.Id;
  		inventoryFirstSpreadTeenMore.Onsale_Availability__c = 'Weekly';
  		inventoryFirstSpreadTeenMore.Quantity__c = 1;
  		inventoryFirstSpreadTeenMore.External_ID__c = productFirstSpread.Name + ' ' + inventoryFirstSpreadTeenMore.Target_Cover_Rating__c;
  		lstInventory.add(inventoryFirstSpreadTeenMore);
  
  		Inventory__c inventoryCenterSpreadTeenMore = new Inventory__c();
  		inventoryCenterSpreadTeenMore.Target_Cover_Rating__c = 'T+ - Teen+';
  		inventoryCenterSpreadTeenMore.Product__c = productCenterSpread.Id;
  		inventoryCenterSpreadTeenMore.Onsale_Availability__c = 'Weekly';
  		inventoryCenterSpreadTeenMore.Quantity__c = 1;
  		inventoryCenterSpreadTeenMore.External_ID__c = productCenterSpread.Name + ' ' + inventoryCenterSpreadTeenMore.Target_Cover_Rating__c;
  		lstInventory.add(inventoryCenterSpreadTeenMore);
  
  		Inventory__c inventoryInteriorPageTeenMore = new Inventory__c();
  		inventoryInteriorPageTeenMore.Target_Cover_Rating__c = 'T+ - Teen+';
  		inventoryInteriorPageTeenMore.Product__c = productInteriorPage.Id;
  		inventoryInteriorPageTeenMore.Onsale_Availability__c = 'Weekly';
  		inventoryInteriorPageTeenMore.Quantity__c = 9;
  		inventoryInteriorPageTeenMore.External_ID__c = productInteriorPage.Name + ' ' + inventoryInteriorPageTeenMore.Target_Cover_Rating__c;
  		lstInventory.add(inventoryInteriorPageTeenMore);
  
  		Inventory__c inventoryC2Mature = new Inventory__c();
  		inventoryC2Mature.Target_Cover_Rating__c = 'M - Mature';
  		inventoryC2Mature.Product__c = productC2.Id;
  		inventoryC2Mature.Onsale_Availability__c = 'Weekly';
  		inventoryC2Mature.Quantity__c = 1;
  		inventoryC2Mature.External_ID__c = productC2.Name + ' ' + inventoryC2Mature.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC2Mature);
  
  		Inventory__c inventoryC3Mature = new Inventory__c();
  		inventoryC3Mature.Target_Cover_Rating__c = 'M - Mature';
  		inventoryC3Mature.Product__c = productC3.Id;
  		inventoryC3Mature.Onsale_Availability__c = 'Weekly';
  		inventoryC3Mature.Quantity__c = 1;
  		inventoryC3Mature.External_ID__c = productC3.Name + ' ' + inventoryC3Mature.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC3Mature);
  
  		Inventory__c inventoryC4Mature = new Inventory__c();
  		inventoryC4Mature.Target_Cover_Rating__c = 'M - Mature';
  		inventoryC4Mature.Product__c = productC4.Id;
  		inventoryC4Mature.Onsale_Availability__c = 'Weekly';
  		inventoryC4Mature.Quantity__c = 1;
  		inventoryC4Mature.External_ID__c = productC4.Name + ' ' + inventoryC4Mature.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC4Mature);
  
  		Inventory__c inventoryFirstRHPMature = new Inventory__c();
  		inventoryFirstRHPMature.Target_Cover_Rating__c = 'M - Mature';
  		inventoryFirstRHPMature.Product__c = productFirstRHP.Id;
  		inventoryFirstRHPMature.Onsale_Availability__c = 'Weekly';
  		inventoryFirstRHPMature.Quantity__c = 1;
  		inventoryFirstRHPMature.External_ID__c = productFirstRHP.Name + ' ' + inventoryFirstRHPMature.Target_Cover_Rating__c;
  		lstInventory.add(inventoryFirstRHPMature);
  
  		Inventory__c inventorySecondRHPMature = new Inventory__c();
  		inventorySecondRHPMature.Target_Cover_Rating__c = 'M - Mature';
  		inventorySecondRHPMature.Product__c = productSecondRHP.Id;
  		inventorySecondRHPMature.Onsale_Availability__c = 'Weekly';
  		inventorySecondRHPMature.Quantity__c = 1;
  		inventorySecondRHPMature.External_ID__c = productSecondRHP.Name + ' ' + inventorySecondRHPMature.Target_Cover_Rating__c;
  		lstInventory.add(inventorySecondRHPMature);
  
  		Inventory__c inventoryFirstSpreadMature = new Inventory__c();
  		inventoryFirstSpreadMature.Target_Cover_Rating__c = 'M - Mature';
  		inventoryFirstSpreadMature.Product__c = productFirstSpread.Id;
  		inventoryFirstSpreadMature.Onsale_Availability__c = 'Weekly';
  		inventoryFirstSpreadMature.Quantity__c = 1;
  		inventoryFirstSpreadMature.External_ID__c = productFirstSpread.Name + ' ' + inventoryFirstSpreadMature.Target_Cover_Rating__c;
  		lstInventory.add(inventoryFirstSpreadMature);
  
  		Inventory__c inventoryCenterSpreadMature = new Inventory__c();
  		inventoryCenterSpreadMature.Target_Cover_Rating__c = 'M - Mature';
  		inventoryCenterSpreadMature.Product__c = productCenterSpread.Id;
  		inventoryCenterSpreadMature.Onsale_Availability__c = 'Weekly';
  		inventoryCenterSpreadMature.Quantity__c = 1;
  		inventoryCenterSpreadMature.External_ID__c = productCenterSpread.Name + ' ' + inventoryCenterSpreadMature.Target_Cover_Rating__c;
  		lstInventory.add(inventoryCenterSpreadMature);
  
  		Inventory__c inventoryInteriorPageMature = new Inventory__c();
  		inventoryInteriorPageMature.Target_Cover_Rating__c = 'M - Mature';
  		inventoryInteriorPageMature.Product__c = productInteriorPage.Id;
  		inventoryInteriorPageMature.Onsale_Availability__c = 'Weekly';
  		inventoryInteriorPageMature.Quantity__c = 9;
  		inventoryInteriorPageMature.External_ID__c = productInteriorPage.Name + ' ' + inventoryInteriorPageMature.Target_Cover_Rating__c;
  		lstInventory.add(inventoryInteriorPageMature);
  
  		Inventory__c inventoryC2Mad = new Inventory__c();
  		inventoryC2Mad.Target_Cover_Rating__c = 'MM - Mad';
  		inventoryC2Mad.Product__c = productC2.Id;
  		inventoryC2Mad.Onsale_Availability__c = 'Weekly';
  		inventoryC2Mad.Quantity__c = 1;
  		inventoryC2Mad.External_ID__c = productC2.Name + ' ' + inventoryC2Mad.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC2Mad);
  
  		Inventory__c inventoryC3Mad = new Inventory__c();
  		inventoryC3Mad.Target_Cover_Rating__c = 'MM - Mad';
  		inventoryC3Mad.Product__c = productC3.Id;
  		inventoryC3Mad.Onsale_Availability__c = 'Weekly';
  		inventoryC3Mad.Quantity__c = 1;
  		inventoryC3Mad.External_ID__c = productC3.Name + ' ' + inventoryC3Mad.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC3Mad);
  
  		Inventory__c inventoryC4Mad= new Inventory__c();
  		inventoryC4Mad.Target_Cover_Rating__c = 'MM - Mad';
  		inventoryC4Mad.Product__c = productC4.Id;
  		inventoryC4Mad.Onsale_Availability__c = 'Weekly';
  		inventoryC4Mad.Quantity__c = 1;
  		inventoryC4Mad.External_ID__c = productC4.Name + ' ' + inventoryC4Mad.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC4Mad);
  
  		Inventory__c inventoryFirstRHPMad = new Inventory__c();
  		inventoryFirstRHPMad.Target_Cover_Rating__c = 'MM - Mad';
  		inventoryFirstRHPMad.Product__c = productFirstRHP.Id;
  		inventoryFirstRHPMad.Onsale_Availability__c = 'Weekly';
  		inventoryFirstRHPMad.Quantity__c = 1;
  		inventoryFirstRHPMad.External_ID__c = productFirstRHP.Name + ' ' + inventoryFirstRHPMad.Target_Cover_Rating__c;
  		lstInventory.add(inventoryFirstRHPMad);
  
  		Inventory__c inventorySecondRHPMad = new Inventory__c();
  		inventorySecondRHPMad.Target_Cover_Rating__c = 'MM - Mad';
  		inventorySecondRHPMad.Product__c = productSecondRHP.Id;
  		inventorySecondRHPMad.Onsale_Availability__c = 'Weekly';
  		inventorySecondRHPMad.Quantity__c = 1;
  		inventorySecondRHPMad.External_ID__c = productSecondRHP.Name + ' ' + inventorySecondRHPMad.Target_Cover_Rating__c;
  		lstInventory.add(inventorySecondRHPMad);
  
  		Inventory__c inventoryFirstSpreadMad = new Inventory__c();
  		inventoryFirstSpreadMad.Target_Cover_Rating__c = 'MM - Mad';
  		inventoryFirstSpreadMad.Product__c = productFirstSpread.Id;
  		inventoryFirstSpreadMad.Onsale_Availability__c = 'Weekly';
  		inventoryFirstSpreadMad.Quantity__c = 1;
  		inventoryFirstSpreadMad.External_ID__c = productFirstSpread.Name + ' ' + inventoryFirstSpreadMad.Target_Cover_Rating__c;
  		lstInventory.add(inventoryFirstSpreadMad);
  
  		Inventory__c inventoryCenterSpreadMad = new Inventory__c();
  		inventoryCenterSpreadMad.Target_Cover_Rating__c = 'MM - Mad';
  		inventoryCenterSpreadMad.Product__c = productCenterSpread.Id;
  		inventoryCenterSpreadMad.Onsale_Availability__c = 'Weekly';
  		inventoryCenterSpreadMad.Quantity__c = 1;
  		inventoryCenterSpreadMad.External_ID__c = productCenterSpread.Name + ' ' + inventoryCenterSpreadMad.Target_Cover_Rating__c;
  		lstInventory.add(inventoryCenterSpreadMad);
  
  		Inventory__c inventoryInteriorPageMad = new Inventory__c();
  		inventoryInteriorPageMad.Target_Cover_Rating__c = 'MM - Mad';
  		inventoryInteriorPageMad.Product__c = productInteriorPage.Id;
  		inventoryInteriorPageMad.Onsale_Availability__c = 'Weekly';
  		inventoryInteriorPageMad.Quantity__c = 6;
  		inventoryInteriorPageMad.External_ID__c = productInteriorPage.Name + ' ' + inventoryInteriorPageMad.Target_Cover_Rating__c;
  		lstInventory.add(inventoryInteriorPageMad);
  
  		insert lstInventory;

        Test.startTest();
        StaticResource csvFile = [select Body from StaticResource where Name = 'InventorySuccessTest'];
        UploadInventory_CC.binFile = csvFile.Body;
        UploadInventory_CC uploadInventory = new UploadInventory_CC();
		uploadInventory.ReadFile();
        Test.stopTest();
    }
    
    static testMethod void uploadInventoryFailedTest(){        
        //create products
      	List<Product2> lstProduct = new List<Product2>();
      
  		Product2 productC2 = new Product2();
  		productC2.Name = 'C2';
		productC2.Family = 'Print';
	  	productC2.IsActive = true;
	  	lstProduct.add(productC2);
  
  		Product2 productC3 = new Product2();
  		productC3.Name = 'C3';
  		productC3.Family = 'Print';
  		productC3.IsActive = true;
  		lstProduct.add(productC3);
  
  		Product2 productC4 = new Product2();
  		productC4.Name = 'C4';
  		productC4.Family = 'Print';
  		productC4.IsActive = true;
  		lstProduct.add(productC4);
  
  		Product2 productFirstRHP = new Product2();
  		productFirstRHP.Name = 'First RHP';
  		productFirstRHP.Family = 'Print';
  		productFirstRHP.IsActive = true;
  		lstProduct.add(productFirstRHP);
  
  		Product2 productSecondRHP = new Product2();
  		productSecondRHP.Name = 'Second RHP';
  		productSecondRHP.Family = 'Print';
  		productSecondRHP.IsActive = true;
  		lstProduct.add(productSecondRHP);
  
	  	Product2 productFirstSpread = new Product2();
  		productFirstSpread.Name = 'First Spread';
  		productFirstSpread.Family = 'Print';
  		productFirstSpread.IsActive = true;
  		lstProduct.add(productFirstSpread);
  
  		Product2 productCenterSpread = new Product2();
  		productCenterSpread.Name = 'Center Spread';
  		productCenterSpread.Family = 'Print';
  		productCenterSpread.IsActive = true;
  		lstProduct.add(productCenterSpread);
	  
  		Product2 productInteriorPage = new Product2();
  		productInteriorPage.Name = 'Interior Page';
  		productInteriorPage.Family = 'Print';
  		productInteriorPage.IsActive = true;
  		lstProduct.add(productInteriorPage);
  
 	 	insert lstProduct;
  
  		//create Inventory
  		List<Inventory__c> lstInventory = new List<Inventory__c>();
  
  		Inventory__c inventoryC2Everyone = new Inventory__c();
  		inventoryC2Everyone.Target_Cover_Rating__c = 'E - Everyone';
  		inventoryC2Everyone.Product__c = productC2.Id;
  		inventoryC2Everyone.Onsale_Availability__c = 'Weekly';
  		inventoryC2Everyone.Quantity__c = 1;
  		inventoryC2Everyone.External_ID__c = productC2.Name + ' ' + inventoryC2Everyone.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC2Everyone);
  
  		Inventory__c inventoryC3Everyone = new Inventory__c();
  		inventoryC3Everyone.Target_Cover_Rating__c = 'E - Everyone';
  		inventoryC3Everyone.Product__c = productC3.Id;
  		inventoryC3Everyone.Onsale_Availability__c = 'Weekly';
  		inventoryC3Everyone.Quantity__c = 1;
  		inventoryC3Everyone.External_ID__c = productC3.Name + ' ' + inventoryC3Everyone.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC3Everyone);
  
  		Inventory__c inventoryC4Everyone = new Inventory__c();
  		inventoryC4Everyone.Target_Cover_Rating__c = 'E - Everyone';
  		inventoryC4Everyone.Product__c = productC4.Id;
  		inventoryC4Everyone.Onsale_Availability__c = 'Weekly';
  		inventoryC4Everyone.Quantity__c = 1;
  		inventoryC4Everyone.External_ID__c = productC4.Name + ' ' + inventoryC4Everyone.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC4Everyone);
  
  		Inventory__c inventoryFirstRHPEveryone = new Inventory__c();
  		inventoryFirstRHPEveryone.Target_Cover_Rating__c = 'E - Everyone';
  		inventoryFirstRHPEveryone.Product__c = productFirstRHP.Id;
  		inventoryFirstRHPEveryone.Onsale_Availability__c = 'Weekly';
  		inventoryFirstRHPEveryone.Quantity__c = 1;
  		inventoryFirstRHPEveryone.External_ID__c = productFirstRHP.Name + ' ' + inventoryFirstRHPEveryone.Target_Cover_Rating__c;
  		lstInventory.add(inventoryFirstRHPEveryone);
        
        Inventory__c inventoryFirstSpreadEveryone = new Inventory__c();
  		inventoryFirstSpreadEveryone.Target_Cover_Rating__c = 'E - Everyone';
  		inventoryFirstSpreadEveryone.Product__c = productFirstSpread.Id;
  		inventoryFirstSpreadEveryone.Onsale_Availability__c = 'Weekly';
  		inventoryFirstSpreadEveryone.Quantity__c = 1;
  		inventoryFirstSpreadEveryone.External_ID__c = productFirstSpread.Name + ' ' + inventoryFirstSpreadEveryone.Target_Cover_Rating__c;
  		lstInventory.add(inventoryFirstSpreadEveryone);
  
  		Inventory__c inventoryC2Teen = new Inventory__c();
  		inventoryC2Teen.Target_Cover_Rating__c = 'T - Teen';
  		inventoryC2Teen.Product__c = productC2.Id;
  		inventoryC2Teen.Onsale_Availability__c = 'Weekly';
  		inventoryC2Teen.Quantity__c = 1;
  		inventoryC2Teen.External_ID__c = productC2.Name + ' ' + inventoryC2Teen.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC2Teen);
  
  		Inventory__c inventoryC3Teen = new Inventory__c();
  		inventoryC3Teen.Target_Cover_Rating__c = 'T - Teen';
  		inventoryC3Teen.Product__c = productC3.Id;
  		inventoryC3Teen.Onsale_Availability__c = 'Weekly';
  		inventoryC3Teen.Quantity__c = 1;
  		inventoryC3Teen.External_ID__c = productC3.Name + ' ' + inventoryC3Teen.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC3Teen);
  
  		Inventory__c inventoryC4Teen = new Inventory__c();
  		inventoryC4Teen.Target_Cover_Rating__c = 'T - Teen';
  		inventoryC4Teen.Product__c = productC4.Id;
  		inventoryC4Teen.Onsale_Availability__c = 'Weekly';
  		inventoryC4Teen.Quantity__c = 1;
  		inventoryC4Teen.External_ID__c = productC4.Name + ' ' + inventoryC4Teen.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC4Teen);
  
  		Inventory__c inventoryFirstRHPTeen = new Inventory__c();
  		inventoryFirstRHPTeen.Target_Cover_Rating__c = 'T - Teen';
  		inventoryFirstRHPTeen.Product__c = productFirstRHP.Id;
  		inventoryFirstRHPTeen.Onsale_Availability__c = 'Weekly';
  		inventoryFirstRHPTeen.Quantity__c = 1;
  		inventoryFirstRHPTeen.External_ID__c = productFirstRHP.Name + ' ' + inventoryFirstRHPTeen.Target_Cover_Rating__c;
  		lstInventory.add(inventoryFirstRHPTeen);
  
  		Inventory__c inventorySecondRHPTeen = new Inventory__c();
  		inventorySecondRHPTeen.Target_Cover_Rating__c = 'T - Teen';
  		inventorySecondRHPTeen.Product__c = productSecondRHP.Id;
  		inventorySecondRHPTeen.Onsale_Availability__c = 'Weekly';
  		inventorySecondRHPTeen.Quantity__c = 1;
  		inventorySecondRHPTeen.External_ID__c = productSecondRHP.Name + ' ' + inventorySecondRHPTeen.Target_Cover_Rating__c;
  		lstInventory.add(inventorySecondRHPTeen);
  
  		Inventory__c inventoryFirstSpreadTeen = new Inventory__c();
  		inventoryFirstSpreadTeen.Target_Cover_Rating__c = 'T - Teen';
  		inventoryFirstSpreadTeen.Product__c = productFirstSpread.Id;
  		inventoryFirstSpreadTeen.Onsale_Availability__c = 'Weekly';
  		inventoryFirstSpreadTeen.Quantity__c = 1;
  		inventoryFirstSpreadTeen.External_ID__c = productFirstSpread.Name + ' ' + inventoryFirstSpreadTeen.Target_Cover_Rating__c;
  		lstInventory.add(inventoryFirstSpreadTeen);
  
  		Inventory__c inventoryCenterSpreadTeen = new Inventory__c();
  		inventoryCenterSpreadTeen.Target_Cover_Rating__c = 'T - Teen';
  		inventoryCenterSpreadTeen.Product__c = productCenterSpread.Id;
  		inventoryCenterSpreadTeen.Onsale_Availability__c = 'Weekly';
  		inventoryCenterSpreadTeen.Quantity__c = 1;
  		inventoryCenterSpreadTeen.External_ID__c = productCenterSpread.Name + ' ' + inventoryCenterSpreadTeen.Target_Cover_Rating__c;
  		lstInventory.add(inventoryCenterSpreadTeen);
  
  		Inventory__c inventoryInteriorPageTeen = new Inventory__c();
  		inventoryInteriorPageTeen.Target_Cover_Rating__c = 'T - Teen';
  		inventoryInteriorPageTeen.Product__c = productInteriorPage.Id;
  		inventoryInteriorPageTeen.Onsale_Availability__c = 'Weekly';
  		inventoryInteriorPageTeen.Quantity__c = 9;
  		inventoryInteriorPageTeen.External_ID__c = productInteriorPage.Name + ' ' + inventoryInteriorPageTeen.Target_Cover_Rating__c;
  		lstInventory.add(inventoryInteriorPageTeen);
        
        Inventory__c inventoryC2TeenMore = new Inventory__c();
  		inventoryC2TeenMore.Target_Cover_Rating__c = 'T+ - Teen+';
  		inventoryC2TeenMore.Product__c = productC2.Id;
  		inventoryC2TeenMore.Onsale_Availability__c = 'Weekly';
  		inventoryC2TeenMore.Quantity__c = 1;
  		inventoryC2TeenMore.External_ID__c = productC2.Name + ' ' + inventoryC2TeenMore.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC2TeenMore);
  
  		Inventory__c inventoryC3TeenMore = new Inventory__c();
  		inventoryC3TeenMore.Target_Cover_Rating__c = 'T+ - Teen+';
  		inventoryC3TeenMore.Product__c = productC3.Id;
  		inventoryC3TeenMore.Onsale_Availability__c = 'Weekly';
  		inventoryC3TeenMore.Quantity__c = 1;
  		inventoryC3TeenMore.External_ID__c = productC3.Name + ' ' + inventoryC3TeenMore.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC3TeenMore);
  
  		Inventory__c inventoryC4TeenMore = new Inventory__c();
  		inventoryC4TeenMore.Target_Cover_Rating__c = 'T+ - Teen+';
  		inventoryC4TeenMore.Product__c = productC4.Id;
  		inventoryC4TeenMore.Onsale_Availability__c = 'Weekly';
  		inventoryC4TeenMore.Quantity__c = 1;
  		inventoryC4TeenMore.External_ID__c = productC4.Name + ' ' + inventoryC4TeenMore.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC4TeenMore);
  
  		Inventory__c inventoryFirstRHPTeenMore = new Inventory__c();
  		inventoryFirstRHPTeenMore.Target_Cover_Rating__c = 'T+ - Teen+';
  		inventoryFirstRHPTeenMore.Product__c = productFirstRHP.Id;
  		inventoryFirstRHPTeenMore.Onsale_Availability__c = 'Weekly';
  		inventoryFirstRHPTeenMore.Quantity__c = 1;
  		inventoryFirstRHPTeenMore.External_ID__c = productFirstRHP.Name + ' ' + inventoryFirstRHPTeenMore.Target_Cover_Rating__c;
  		lstInventory.add(inventoryFirstRHPTeenMore);
  
  		Inventory__c inventorySecondRHPTeenMore = new Inventory__c();
  		inventorySecondRHPTeenMore.Target_Cover_Rating__c = 'T+ - Teen+';
  		inventorySecondRHPTeenMore.Product__c = productSecondRHP.Id;
  		inventorySecondRHPTeenMore.Onsale_Availability__c = 'Weekly';
  		inventorySecondRHPTeenMore.Quantity__c = 1;
  		inventorySecondRHPTeenMore.External_ID__c = productSecondRHP.Name + ' ' + inventorySecondRHPTeenMore.Target_Cover_Rating__c;
  		lstInventory.add(inventorySecondRHPTeenMore);
  
  		Inventory__c inventoryFirstSpreadTeenMore = new Inventory__c();
  		inventoryFirstSpreadTeenMore.Target_Cover_Rating__c = 'T+ - Teen+';
  		inventoryFirstSpreadTeenMore.Product__c = productFirstSpread.Id;
  		inventoryFirstSpreadTeenMore.Onsale_Availability__c = 'Weekly';
  		inventoryFirstSpreadTeenMore.Quantity__c = 1;
  		inventoryFirstSpreadTeenMore.External_ID__c = productFirstSpread.Name + ' ' + inventoryFirstSpreadTeenMore.Target_Cover_Rating__c;
  		lstInventory.add(inventoryFirstSpreadTeenMore);
  
  		Inventory__c inventoryCenterSpreadTeenMore = new Inventory__c();
  		inventoryCenterSpreadTeenMore.Target_Cover_Rating__c = 'T+ - Teen+';
  		inventoryCenterSpreadTeenMore.Product__c = productCenterSpread.Id;
  		inventoryCenterSpreadTeenMore.Onsale_Availability__c = 'Weekly';
  		inventoryCenterSpreadTeenMore.Quantity__c = 1;
  		inventoryCenterSpreadTeenMore.External_ID__c = productCenterSpread.Name + ' ' + inventoryCenterSpreadTeenMore.Target_Cover_Rating__c;
  		lstInventory.add(inventoryCenterSpreadTeenMore);
  
  		Inventory__c inventoryInteriorPageTeenMore = new Inventory__c();
  		inventoryInteriorPageTeenMore.Target_Cover_Rating__c = 'T+ - Teen+';
  		inventoryInteriorPageTeenMore.Product__c = productInteriorPage.Id;
  		inventoryInteriorPageTeenMore.Onsale_Availability__c = 'Weekly';
  		inventoryInteriorPageTeenMore.Quantity__c = 9;
  		inventoryInteriorPageTeenMore.External_ID__c = productInteriorPage.Name + ' ' + inventoryInteriorPageTeenMore.Target_Cover_Rating__c;
  		lstInventory.add(inventoryInteriorPageTeenMore);
  
  		Inventory__c inventoryC2Mature = new Inventory__c();
  		inventoryC2Mature.Target_Cover_Rating__c = 'M - Mature';
  		inventoryC2Mature.Product__c = productC2.Id;
  		inventoryC2Mature.Onsale_Availability__c = 'Weekly';
  		inventoryC2Mature.Quantity__c = 1;
  		inventoryC2Mature.External_ID__c = productC2.Name + ' ' + inventoryC2Mature.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC2Mature);
  
  		Inventory__c inventoryC3Mature = new Inventory__c();
  		inventoryC3Mature.Target_Cover_Rating__c = 'M - Mature';
  		inventoryC3Mature.Product__c = productC3.Id;
  		inventoryC3Mature.Onsale_Availability__c = 'Weekly';
  		inventoryC3Mature.Quantity__c = 1;
  		inventoryC3Mature.External_ID__c = productC3.Name + ' ' + inventoryC3Mature.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC3Mature);
  
  		Inventory__c inventoryC4Mature = new Inventory__c();
  		inventoryC4Mature.Target_Cover_Rating__c = 'M - Mature';
  		inventoryC4Mature.Product__c = productC4.Id;
  		inventoryC4Mature.Onsale_Availability__c = 'Weekly';
  		inventoryC4Mature.Quantity__c = 1;
  		inventoryC4Mature.External_ID__c = productC4.Name + ' ' + inventoryC4Mature.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC4Mature);
  
  		Inventory__c inventoryFirstRHPMature = new Inventory__c();
  		inventoryFirstRHPMature.Target_Cover_Rating__c = 'M - Mature';
  		inventoryFirstRHPMature.Product__c = productFirstRHP.Id;
  		inventoryFirstRHPMature.Onsale_Availability__c = 'Weekly';
  		inventoryFirstRHPMature.Quantity__c = 1;
  		inventoryFirstRHPMature.External_ID__c = productFirstRHP.Name + ' ' + inventoryFirstRHPMature.Target_Cover_Rating__c;
  		lstInventory.add(inventoryFirstRHPMature);
  
  		Inventory__c inventorySecondRHPMature = new Inventory__c();
  		inventorySecondRHPMature.Target_Cover_Rating__c = 'M - Mature';
  		inventorySecondRHPMature.Product__c = productSecondRHP.Id;
  		inventorySecondRHPMature.Onsale_Availability__c = 'Weekly';
  		inventorySecondRHPMature.Quantity__c = 1;
  		inventorySecondRHPMature.External_ID__c = productSecondRHP.Name + ' ' + inventorySecondRHPMature.Target_Cover_Rating__c;
  		lstInventory.add(inventorySecondRHPMature);
  
  		Inventory__c inventoryFirstSpreadMature = new Inventory__c();
  		inventoryFirstSpreadMature.Target_Cover_Rating__c = 'M - Mature';
  		inventoryFirstSpreadMature.Product__c = productFirstSpread.Id;
  		inventoryFirstSpreadMature.Onsale_Availability__c = 'Weekly';
  		inventoryFirstSpreadMature.Quantity__c = 1;
  		inventoryFirstSpreadMature.External_ID__c = productFirstSpread.Name + ' ' + inventoryFirstSpreadMature.Target_Cover_Rating__c;
  		lstInventory.add(inventoryFirstSpreadMature);
  
  		Inventory__c inventoryCenterSpreadMature = new Inventory__c();
  		inventoryCenterSpreadMature.Target_Cover_Rating__c = 'M - Mature';
  		inventoryCenterSpreadMature.Product__c = productCenterSpread.Id;
  		inventoryCenterSpreadMature.Onsale_Availability__c = 'Weekly';
  		inventoryCenterSpreadMature.Quantity__c = 1;
  		inventoryCenterSpreadMature.External_ID__c = productCenterSpread.Name + ' ' + inventoryCenterSpreadMature.Target_Cover_Rating__c;
  		lstInventory.add(inventoryCenterSpreadMature);
  
  		Inventory__c inventoryInteriorPageMature = new Inventory__c();
  		inventoryInteriorPageMature.Target_Cover_Rating__c = 'M - Mature';
  		inventoryInteriorPageMature.Product__c = productInteriorPage.Id;
  		inventoryInteriorPageMature.Onsale_Availability__c = 'Weekly';
  		inventoryInteriorPageMature.Quantity__c = 9;
  		inventoryInteriorPageMature.External_ID__c = productInteriorPage.Name + ' ' + inventoryInteriorPageMature.Target_Cover_Rating__c;
  		lstInventory.add(inventoryInteriorPageMature);
  
  		Inventory__c inventoryC2Mad = new Inventory__c();
  		inventoryC2Mad.Target_Cover_Rating__c = 'MM - Mad';
  		inventoryC2Mad.Product__c = productC2.Id;
  		inventoryC2Mad.Onsale_Availability__c = 'Weekly';
  		inventoryC2Mad.Quantity__c = 1;
  		inventoryC2Mad.External_ID__c = productC2.Name + ' ' + inventoryC2Mad.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC2Mad);
  
  		Inventory__c inventoryC3Mad = new Inventory__c();
  		inventoryC3Mad.Target_Cover_Rating__c = 'MM - Mad';
  		inventoryC3Mad.Product__c = productC3.Id;
  		inventoryC3Mad.Onsale_Availability__c = 'Weekly';
  		inventoryC3Mad.Quantity__c = 1;
  		inventoryC3Mad.External_ID__c = productC3.Name + ' ' + inventoryC3Mad.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC3Mad);
  
  		Inventory__c inventoryC4Mad= new Inventory__c();
  		inventoryC4Mad.Target_Cover_Rating__c = 'MM - Mad';
  		inventoryC4Mad.Product__c = productC4.Id;
  		inventoryC4Mad.Onsale_Availability__c = 'Weekly';
  		inventoryC4Mad.Quantity__c = 1;
  		inventoryC4Mad.External_ID__c = productC4.Name + ' ' + inventoryC4Mad.Target_Cover_Rating__c;
  		lstInventory.add(inventoryC4Mad);
  
  		Inventory__c inventoryFirstRHPMad = new Inventory__c();
  		inventoryFirstRHPMad.Target_Cover_Rating__c = 'MM - Mad';
  		inventoryFirstRHPMad.Product__c = productFirstRHP.Id;
  		inventoryFirstRHPMad.Onsale_Availability__c = 'Weekly';
  		inventoryFirstRHPMad.Quantity__c = 1;
  		inventoryFirstRHPMad.External_ID__c = productFirstRHP.Name + ' ' + inventoryFirstRHPMad.Target_Cover_Rating__c;
  		lstInventory.add(inventoryFirstRHPMad);
  
  		Inventory__c inventorySecondRHPMad = new Inventory__c();
  		inventorySecondRHPMad.Target_Cover_Rating__c = 'MM - Mad';
  		inventorySecondRHPMad.Product__c = productSecondRHP.Id;
  		inventorySecondRHPMad.Onsale_Availability__c = 'Weekly';
  		inventorySecondRHPMad.Quantity__c = 1;
  		inventorySecondRHPMad.External_ID__c = productSecondRHP.Name + ' ' + inventorySecondRHPMad.Target_Cover_Rating__c;
  		lstInventory.add(inventorySecondRHPMad);
  
  		Inventory__c inventoryFirstSpreadMad = new Inventory__c();
  		inventoryFirstSpreadMad.Target_Cover_Rating__c = 'MM - Mad';
  		inventoryFirstSpreadMad.Product__c = productFirstSpread.Id;
  		inventoryFirstSpreadMad.Onsale_Availability__c = 'Weekly';
  		inventoryFirstSpreadMad.Quantity__c = 1;
  		inventoryFirstSpreadMad.External_ID__c = productFirstSpread.Name + ' ' + inventoryFirstSpreadMad.Target_Cover_Rating__c;
  		lstInventory.add(inventoryFirstSpreadMad);
  
  		Inventory__c inventoryCenterSpreadMad = new Inventory__c();
  		inventoryCenterSpreadMad.Target_Cover_Rating__c = 'MM - Mad';
  		inventoryCenterSpreadMad.Product__c = productCenterSpread.Id;
  		inventoryCenterSpreadMad.Onsale_Availability__c = 'Weekly';
  		inventoryCenterSpreadMad.Quantity__c = 1;
  		inventoryCenterSpreadMad.External_ID__c = productCenterSpread.Name + ' ' + inventoryCenterSpreadMad.Target_Cover_Rating__c;
  		lstInventory.add(inventoryCenterSpreadMad);
  
  		Inventory__c inventoryInteriorPageMad = new Inventory__c();
  		inventoryInteriorPageMad.Target_Cover_Rating__c = 'MM - Mad';
  		inventoryInteriorPageMad.Product__c = productInteriorPage.Id;
  		inventoryInteriorPageMad.Onsale_Availability__c = 'Weekly';
  		inventoryInteriorPageMad.Quantity__c = 6;
  		inventoryInteriorPageMad.External_ID__c = productInteriorPage.Name + ' ' + inventoryInteriorPageMad.Target_Cover_Rating__c;
  		lstInventory.add(inventoryInteriorPageMad);
  
  		insert lstInventory;

        Test.startTest();
        StaticResource csvFile = [select Body from StaticResource where Name = 'InventoryFailedTest'];
        UploadInventory_CC.binFile = csvFile.Body;
        UploadInventory_CC uploadInventory = new UploadInventory_CC();
		uploadInventory.ReadFile();
        Test.stopTest();
    }
}