/******* 
Inventory_Test
Creation Date- 02 August 2016
Description- This class is to do code coverage for Inventory_CC
Author- Angello Camacho
*******/

@isTest
private class Inventory_Test {
	
	static testMethod void inventoryTest() {
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
  
  		/*Inventory__c inventoryFirstRHPTeen = new Inventory__c();
  		inventoryFirstRHPTeen.Target_Cover_Rating__c = 'T - Teen';
  		inventoryFirstRHPTeen.Product__c = productFirstRHP.Id;
  		inventoryFirstRHPTeen.Onsale_Availability__c = 'Weekly';
  		inventoryFirstRHPTeen.Quantity__c = 1;
        inventoryFirstRHPTeen.External_ID__c = productFirstRHP.Name + ' ' + inventoryFirstRHPTeen.Target_Cover_Rating__c;
  		lstInventory.add(inventoryFirstRHPTeen);*/
        
        Inventory__c inventoryFirstRHPTeen = new Inventory__c();
  		inventoryFirstRHPTeen.Target_Cover_Rating__c = 'T - Teen';
  		inventoryFirstRHPTeen.Product__c = productFirstRHP.Id;
  		inventoryFirstRHPTeen.Onsale_Availability__c = 'One-Time Change';
        inventoryFirstRHPTeen.Availability_Date__c = Inventory_Test.getWednesday(4);
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
  
  		/*Inventory__c inventoryInteriorPageTeenMore = new Inventory__c();
  		inventoryInteriorPageTeenMore.Target_Cover_Rating__c = 'T+ - Teen+';
  		inventoryInteriorPageTeenMore.Product__c = productInteriorPage.Id;
  		inventoryInteriorPageTeenMore.Onsale_Availability__c = 'Weekly';
  		inventoryInteriorPageTeenMore.Quantity__c = 9;
  		inventoryInteriorPageTeenMore.External_ID__c = productInteriorPage.Name + ' ' + inventoryInteriorPageTeenMore.Target_Cover_Rating__c;
  		lstInventory.add(inventoryInteriorPageTeenMore);*/
        
        Inventory__c inventoryInteriorPageTeenMore_One_Time_Change = new Inventory__c();
  		inventoryInteriorPageTeenMore_One_Time_Change.Target_Cover_Rating__c = 'T+ - Teen+';
  		inventoryInteriorPageTeenMore_One_Time_Change.Product__c = productInteriorPage.Id;
  		inventoryInteriorPageTeenMore_One_Time_Change.Onsale_Availability__c = 'One-Time Change';
        inventoryInteriorPageTeenMore_One_Time_Change.Availability_Date__c = Inventory_Test.getWednesday(2);
  		inventoryInteriorPageTeenMore_One_Time_Change.Quantity__c = 4;
  		inventoryInteriorPageTeenMore_One_Time_Change.External_ID__c = productInteriorPage.Name + ' ' + inventoryInteriorPageTeenMore_One_Time_Change.Target_Cover_Rating__c;
  		lstInventory.add(inventoryInteriorPageTeenMore_One_Time_Change);
  
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
  
  		//add pricebook entry
  
	  	List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
  
  		Id idStandard = Test.getStandardPricebookId();
  
  		PricebookEntry pricebookEntryC2 = new PricebookEntry();
  		pricebookEntryC2.IsActive = true;
  		pricebookEntryC2.Product2Id = productC2.Id;
  		pricebookEntryC2.UnitPrice = 0;
  		pricebookEntryC2.Pricebook2Id = idStandard;
  		lstPricebookEntry.add(pricebookEntryC2);
  
  		PricebookEntry pricebookEntryC3 = new PricebookEntry();
  		pricebookEntryC3.IsActive = true;
	  	pricebookEntryC3.Product2Id = productC3.Id;
  		pricebookEntryC3.UnitPrice = 0;
  		pricebookEntryC3.Pricebook2Id = idStandard;
  		lstPricebookEntry.add(pricebookEntryC3);
  
  		PricebookEntry pricebookEntryC4 = new PricebookEntry();
  		pricebookEntryC4.IsActive = true;
  		pricebookEntryC4.Product2Id = productC4.Id;
  		pricebookEntryC4.UnitPrice = 0;
  		pricebookEntryC4.Pricebook2Id = idStandard;
  		lstPricebookEntry.add(pricebookEntryC4);
  
  		PricebookEntry pricebookEntryFirstRHP = new PricebookEntry();
  		pricebookEntryFirstRHP.IsActive = true;
  		pricebookEntryFirstRHP.Product2Id = productFirstRHP.Id;
  		pricebookEntryFirstRHP.UnitPrice = 0;
  		pricebookEntryFirstRHP.Pricebook2Id = idStandard;
  		lstPricebookEntry.add(pricebookEntryFirstRHP);
	  
  		PricebookEntry pricebookEntrySecondRHP = new PricebookEntry();
  		pricebookEntrySecondRHP.IsActive = true;
  		pricebookEntrySecondRHP.Product2Id = productSecondRHP.Id;
  		pricebookEntrySecondRHP.UnitPrice = 0;
  		pricebookEntrySecondRHP.Pricebook2Id = idStandard;
  		lstPricebookEntry.add(pricebookEntrySecondRHP);
  
  		PricebookEntry pricebookEntryFirstSpread = new PricebookEntry();
  		pricebookEntryFirstSpread.IsActive = true;
  		pricebookEntryFirstSpread.Product2Id = productFirstSpread.Id;
  		pricebookEntryFirstSpread.UnitPrice = 0;
  		pricebookEntryFirstSpread.Pricebook2Id = idStandard;
  		lstPricebookEntry.add(pricebookEntryFirstSpread);
  
  		PricebookEntry pricebookEntryCenterSpread = new PricebookEntry();
  		pricebookEntryCenterSpread.IsActive = true;
  		pricebookEntryCenterSpread.Product2Id = productCenterSpread.Id;
  		pricebookEntryCenterSpread.UnitPrice = 0;
  		pricebookEntryCenterSpread.Pricebook2Id = idStandard;
  		lstPricebookEntry.add(pricebookEntryCenterSpread);
	  
  		PricebookEntry pricebookEntryInteriorPage = new PricebookEntry();
  		pricebookEntryInteriorPage.IsActive = true;
  		pricebookEntryInteriorPage.Product2Id = productInteriorPage.Id;
  		pricebookEntryInteriorPage.UnitPrice = 0;
  		pricebookEntryInteriorPage.Pricebook2Id = idStandard;
  		lstPricebookEntry.add(pricebookEntryInteriorPage);
  		
  		insert lstPricebookEntry;
  
  		//add opportunity
  
  		List<Opportunity> lstOpportunity = new List<Opportunity>();
  		
  		Id rt = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('DC Deals').getRecordTypeId();
  		
  		//Id rt = [SELECT Id FROM RecordType WHERE Name =: 'DC Deals'].Id;
	  
  		Opportunity opportunityConfirmed = new Opportunity();
  		opportunityConfirmed.Name = 'Confirmed Opp';
  		opportunityConfirmed.CloseDate = system.now().date();
  		opportunityConfirmed.StageName = 'Scenario';
  		opportunityConfirmed.Product_Type__c = 'Print';
  		opportunityConfirmed.RecordTypeId = rt;
  		lstOpportunity.add(opportunityConfirmed);
  
  		Opportunity opportunityVerbal = new Opportunity();
  		opportunityVerbal.Name = 'Verbal Opp';
  		opportunityVerbal.CloseDate = system.now().date();
  		opportunityVerbal.StageName = 'Scenario';
  		opportunityVerbal.Product_Type__c = 'Print';
  		opportunityVerbal.RecordTypeId = rt;
  		lstOpportunity.add(opportunityVerbal);
  
  		Opportunity opportunityRevised = new Opportunity();
  		opportunityRevised.Name = 'Revised Opp';
  		opportunityRevised.CloseDate = system.now().date();
  		opportunityRevised.StageName = 'Scenario';
  		opportunityRevised.Product_Type__c = 'Print';
  		opportunityRevised.RecordTypeId = rt;
  		lstOpportunity.add(opportunityRevised);
  
  		insert lstOpportunity;
  		
  		opportunityConfirmed.StageName = 'Confirmed';
  		update opportunityConfirmed;
  		
  		opportunityVerbal.StageName = 'Verbal';
  		update opportunityVerbal;
  		
  		opportunityRevised.StageName = 'Revised';
  		update opportunityRevised;  		
  		
  		//add oppotunity line item
  
  		List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
  
  		OpportunityLineItem OpportunityLineItemC2Confirmed = new OpportunityLineItem();
  		OpportunityLineItemC2Confirmed.PricebookEntryId = pricebookEntryC2.Id;
  		OpportunityLineItemC2Confirmed.UnitPrice = 100;
  		OpportunityLineItemC2Confirmed.Quantity = 1;
  		OpportunityLineItemC2Confirmed.Target_Cover_Rating__c = 'E - Everyone';
  		OpportunityLineItemC2Confirmed.Onsale_Date__c = Inventory_Test.getWednesday(1);
  		OpportunityLineItemC2Confirmed.OpportunityId = opportunityConfirmed.Id;
  		lstOpportunityLineItem.add(OpportunityLineItemC2Confirmed);
  
  		OpportunityLineItem OpportunityLineItemC3Confirmed = new OpportunityLineItem();
  		OpportunityLineItemC3Confirmed.PricebookEntryId = pricebookEntryC3.Id;
  		OpportunityLineItemC3Confirmed.UnitPrice = 100;
  		OpportunityLineItemC3Confirmed.Quantity = 1;
  		OpportunityLineItemC3Confirmed.Target_Cover_Rating__c = 'T - Teen';
  		OpportunityLineItemC3Confirmed.Onsale_Date__c = Inventory_Test.getWednesday(4);
  		OpportunityLineItemC3Confirmed.OpportunityId = opportunityConfirmed.Id;
  		lstOpportunityLineItem.add(OpportunityLineItemC3Confirmed);
  		
  		OpportunityLineItem OpportunityLineItemC4Confirmed = new OpportunityLineItem();
  		OpportunityLineItemC4Confirmed.PricebookEntryId = pricebookEntryC4.Id;
  		OpportunityLineItemC4Confirmed.UnitPrice = 100;
  		OpportunityLineItemC4Confirmed.Quantity = 1;
  		OpportunityLineItemC4Confirmed.Target_Cover_Rating__c = 'T - Teen';
  		OpportunityLineItemC4Confirmed.Onsale_Date__c = Inventory_Test.getWednesday(3);
  		OpportunityLineItemC4Confirmed.OpportunityId = opportunityConfirmed.Id;
  		lstOpportunityLineItem.add(OpportunityLineItemC4Confirmed);
  		
  		OpportunityLineItem OpportunityLineItemFirstRHPConfirmed = new OpportunityLineItem();
  		OpportunityLineItemFirstRHPConfirmed.PricebookEntryId = pricebookEntryFirstRHP.Id;
  		OpportunityLineItemFirstRHPConfirmed.UnitPrice = 100;
  		OpportunityLineItemFirstRHPConfirmed.Quantity = 1;
  		OpportunityLineItemFirstRHPConfirmed.Target_Cover_Rating__c = 'T+ - Teen+';
  		OpportunityLineItemFirstRHPConfirmed.Onsale_Date__c = Inventory_Test.getWednesday(4);
  		OpportunityLineItemFirstRHPConfirmed.OpportunityId = opportunityConfirmed.Id;
  		lstOpportunityLineItem.add(OpportunityLineItemFirstRHPConfirmed);
  		
  		OpportunityLineItem OpportunityLineItemSecondRHPConfirmed = new OpportunityLineItem();
  		OpportunityLineItemSecondRHPConfirmed.PricebookEntryId = pricebookEntrySecondRHP.Id;
  		OpportunityLineItemSecondRHPConfirmed.UnitPrice = 100;
  		OpportunityLineItemSecondRHPConfirmed.Quantity = 1;
  		OpportunityLineItemSecondRHPConfirmed.Target_Cover_Rating__c = 'T+ - Teen+';
  		OpportunityLineItemSecondRHPConfirmed.Onsale_Date__c = Inventory_Test.getWednesday(2);
  		OpportunityLineItemSecondRHPConfirmed.OpportunityId = opportunityConfirmed.Id;
		lstOpportunityLineItem.add(OpportunityLineItemSecondRHPConfirmed);
		
		OpportunityLineItem OpportunityLineItemFirstSpreadConfirmed = new OpportunityLineItem();
  		OpportunityLineItemFirstSpreadConfirmed.PricebookEntryId = pricebookEntryFirstSpread.Id;
  		OpportunityLineItemFirstSpreadConfirmed.UnitPrice = 100;
  		OpportunityLineItemFirstSpreadConfirmed.Quantity = 1;
  		OpportunityLineItemFirstSpreadConfirmed.Target_Cover_Rating__c = 'T - Teen';
  		OpportunityLineItemFirstSpreadConfirmed.Onsale_Date__c = Inventory_Test.getWednesday(1);
  		OpportunityLineItemFirstSpreadConfirmed.OpportunityId = opportunityConfirmed.Id;
  		lstOpportunityLineItem.add(OpportunityLineItemFirstSpreadConfirmed);
  		
  		OpportunityLineItem OpportunityLineItemCenterSpreadConfirmed = new OpportunityLineItem();
  		OpportunityLineItemCenterSpreadConfirmed.PricebookEntryId = pricebookEntryCenterSpread.Id;
  		OpportunityLineItemCenterSpreadConfirmed.UnitPrice = 100;
  		OpportunityLineItemCenterSpreadConfirmed.Quantity = 1;
  		OpportunityLineItemCenterSpreadConfirmed.Target_Cover_Rating__c = 'MM - Mad';
  		OpportunityLineItemCenterSpreadConfirmed.Onsale_Date__c = Inventory_Test.getWednesday(3);
  		OpportunityLineItemCenterSpreadConfirmed.OpportunityId = opportunityConfirmed.Id;
  		lstOpportunityLineItem.add(OpportunityLineItemCenterSpreadConfirmed);
  
  		OpportunityLineItem OpportunityLineItemInteriorPageConfirmed = new OpportunityLineItem();
  		OpportunityLineItemInteriorPageConfirmed.PricebookEntryId = pricebookEntryInteriorPage.Id;
  		OpportunityLineItemInteriorPageConfirmed.UnitPrice = 100;
  		OpportunityLineItemInteriorPageConfirmed.Quantity = 9;
  		OpportunityLineItemInteriorPageConfirmed.Target_Cover_Rating__c = 'M - Mature';
  		OpportunityLineItemInteriorPageConfirmed.Onsale_Date__c = Inventory_Test.getWednesday(1);
  		OpportunityLineItemInteriorPageConfirmed.OpportunityId = opportunityConfirmed.Id;
  		lstOpportunityLineItem.add(OpportunityLineItemInteriorPageConfirmed);
	  
	  	OpportunityLineItem OpportunityLineItemC2Verbal = new OpportunityLineItem();
  		OpportunityLineItemC2Verbal.PricebookEntryId = pricebookEntryC2.Id;
  		OpportunityLineItemC2Verbal.UnitPrice = 100;
  		OpportunityLineItemC2Verbal.Quantity = 1;
  		OpportunityLineItemC2Verbal.Target_Cover_Rating__c = 'T+ - Teen+';
  		OpportunityLineItemC2Verbal.Onsale_Date__c = Inventory_Test.getWednesday(1);
  		OpportunityLineItemC2Verbal.OpportunityId = opportunityVerbal.Id;
  		lstOpportunityLineItem.add(OpportunityLineItemC2Verbal);
  
  		OpportunityLineItem OpportunityLineItemC3Verbal = new OpportunityLineItem();
  		OpportunityLineItemC3Verbal.PricebookEntryId = pricebookEntryC3.Id;
  		OpportunityLineItemC3Verbal.UnitPrice = 100;
  		OpportunityLineItemC3Verbal.Quantity = 1;
  		OpportunityLineItemC3Verbal.Target_Cover_Rating__c = 'T - Teen';
  		OpportunityLineItemC3Verbal.Onsale_Date__c = Inventory_Test.getWednesday(2);
  		OpportunityLineItemC3Verbal.OpportunityId = opportunityVerbal.Id;
  		lstOpportunityLineItem.add(OpportunityLineItemC3Verbal);
  		
  		OpportunityLineItem OpportunityLineItemC4Verbal = new OpportunityLineItem();
  		OpportunityLineItemC4Verbal.PricebookEntryId = pricebookEntryC4.Id;
  		OpportunityLineItemC4Verbal.UnitPrice = 100;
  		OpportunityLineItemC4Verbal.Quantity = 1;
  		OpportunityLineItemC4Verbal.Target_Cover_Rating__c = 'T+ - Teen+';
  		OpportunityLineItemC4Verbal.Onsale_Date__c = Inventory_Test.getWednesday(3);
  		OpportunityLineItemC4Verbal.OpportunityId = opportunityVerbal.Id;
  		lstOpportunityLineItem.add(OpportunityLineItemC4Verbal);
  		
  		OpportunityLineItem OpportunityLineItemFirstRHPVerbal = new OpportunityLineItem();
  		OpportunityLineItemFirstRHPVerbal.PricebookEntryId = pricebookEntryFirstRHP.Id;
  		OpportunityLineItemFirstRHPVerbal.UnitPrice = 100;
  		OpportunityLineItemFirstRHPVerbal.Quantity = 1;
  		OpportunityLineItemFirstRHPVerbal.Target_Cover_Rating__c = 'T - Teen';
  		OpportunityLineItemFirstRHPVerbal.Onsale_Date__c = Inventory_Test.getWednesday(3);
  		OpportunityLineItemFirstRHPVerbal.OpportunityId = opportunityVerbal.Id;
  		lstOpportunityLineItem.add(OpportunityLineItemFirstRHPVerbal);
  		
  		OpportunityLineItem OpportunityLineItemSecondRHPVerbal = new OpportunityLineItem();
  		OpportunityLineItemSecondRHPVerbal.PricebookEntryId = pricebookEntrySecondRHP.Id;
  		OpportunityLineItemSecondRHPVerbal.UnitPrice = 100;
  		OpportunityLineItemSecondRHPVerbal.Quantity = 1;
  		OpportunityLineItemSecondRHPVerbal.Target_Cover_Rating__c = 'M - Mature';
  		OpportunityLineItemSecondRHPVerbal.Onsale_Date__c = Inventory_Test.getWednesday(4);
  		OpportunityLineItemSecondRHPVerbal.OpportunityId = opportunityVerbal.Id;
		lstOpportunityLineItem.add(OpportunityLineItemSecondRHPVerbal);
		
		OpportunityLineItem OpportunityLineItemFirstSpreadVerbal = new OpportunityLineItem();
  		OpportunityLineItemFirstSpreadVerbal.PricebookEntryId = pricebookEntryFirstSpread.Id;
  		OpportunityLineItemFirstSpreadVerbal.UnitPrice = 100;
  		OpportunityLineItemFirstSpreadVerbal.Quantity = 4;
  		OpportunityLineItemFirstSpreadVerbal.Target_Cover_Rating__c = 'T - Teen';
  		OpportunityLineItemFirstSpreadVerbal.Onsale_Date__c = Inventory_Test.getWednesday(4);
  		OpportunityLineItemFirstSpreadVerbal.OpportunityId = opportunityVerbal.Id;
  		lstOpportunityLineItem.add(OpportunityLineItemFirstSpreadVerbal);
  		
  		OpportunityLineItem OpportunityLineItemCenterSpreadVerbal = new OpportunityLineItem();
  		OpportunityLineItemCenterSpreadVerbal.PricebookEntryId = pricebookEntryCenterSpread.Id;
  		OpportunityLineItemCenterSpreadVerbal.UnitPrice = 100;
  		OpportunityLineItemCenterSpreadVerbal.Quantity = 2;
  		OpportunityLineItemCenterSpreadVerbal.Target_Cover_Rating__c = 'M - Mature';
  		OpportunityLineItemCenterSpreadVerbal.Onsale_Date__c = Inventory_Test.getWednesday(3);
  		OpportunityLineItemCenterSpreadVerbal.OpportunityId = opportunityVerbal.Id;
  		lstOpportunityLineItem.add(OpportunityLineItemCenterSpreadVerbal);
  
  		OpportunityLineItem OpportunityLineItemInteriorPageVerbal = new OpportunityLineItem();
  		OpportunityLineItemInteriorPageVerbal.PricebookEntryId = pricebookEntryInteriorPage.Id;
  		OpportunityLineItemInteriorPageVerbal.UnitPrice = 100;
  		OpportunityLineItemInteriorPageVerbal.Quantity = 9;
  		OpportunityLineItemInteriorPageVerbal.Target_Cover_Rating__c = 'T+ - Teen+';
  		OpportunityLineItemInteriorPageVerbal.Onsale_Date__c = Inventory_Test.getWednesday(1);
  		OpportunityLineItemInteriorPageVerbal.OpportunityId = opportunityVerbal.Id;
  		lstOpportunityLineItem.add(OpportunityLineItemInteriorPageVerbal);
		
		OpportunityLineItem OpportunityLineItemC2Revised = new OpportunityLineItem();
  		OpportunityLineItemC2Revised.PricebookEntryId = pricebookEntryC2.Id;
  		OpportunityLineItemC2Revised.UnitPrice = 100;
  		OpportunityLineItemC2Revised.Quantity = 1;
  		OpportunityLineItemC2Revised.Target_Cover_Rating__c = 'T+ - Teen+';
  		OpportunityLineItemC2Revised.Onsale_Date__c = Inventory_Test.getWednesday(4);
  		OpportunityLineItemC2Revised.OpportunityId = opportunityRevised.Id;
  		lstOpportunityLineItem.add(OpportunityLineItemC2Revised);
  
  		OpportunityLineItem OpportunityLineItemC3Revised = new OpportunityLineItem();
  		OpportunityLineItemC3Revised.PricebookEntryId = pricebookEntryC3.Id;
  		OpportunityLineItemC3Revised.UnitPrice = 100;
  		OpportunityLineItemC3Revised.Quantity = 1;
  		OpportunityLineItemC3Revised.Target_Cover_Rating__c = 'T - Teen';
  		OpportunityLineItemC3Revised.Onsale_Date__c = Inventory_Test.getWednesday(4);
  		OpportunityLineItemC3Revised.OpportunityId = opportunityRevised.Id;
  		lstOpportunityLineItem.add(OpportunityLineItemC3Revised);
  		
  		OpportunityLineItem OpportunityLineItemC4Revised = new OpportunityLineItem();
  		OpportunityLineItemC4Revised.PricebookEntryId = pricebookEntryC4.Id;
  		OpportunityLineItemC4Revised.UnitPrice = 100;
  		OpportunityLineItemC4Revised.Quantity = 1;
  		OpportunityLineItemC4Revised.Target_Cover_Rating__c = 'M - Mature';
  		OpportunityLineItemC4Revised.Onsale_Date__c = Inventory_Test.getWednesday(3);
  		OpportunityLineItemC4Revised.OpportunityId = opportunityRevised.Id;
  		lstOpportunityLineItem.add(OpportunityLineItemC4Revised);
  		
  		OpportunityLineItem OpportunityLineItemFirstRHPRevised = new OpportunityLineItem();
  		OpportunityLineItemFirstRHPRevised.PricebookEntryId = pricebookEntryFirstRHP.Id;
  		OpportunityLineItemFirstRHPRevised.UnitPrice = 100;
  		OpportunityLineItemFirstRHPRevised.Quantity = 1;
  		OpportunityLineItemFirstRHPRevised.Target_Cover_Rating__c = 'T - Teen';
  		OpportunityLineItemFirstRHPRevised.Onsale_Date__c = Inventory_Test.getWednesday(4);
  		OpportunityLineItemFirstRHPRevised.OpportunityId = opportunityRevised.Id;
  		lstOpportunityLineItem.add(OpportunityLineItemFirstRHPRevised);
  		
  		OpportunityLineItem OpportunityLineItemSecondRHPRevised = new OpportunityLineItem();
  		OpportunityLineItemSecondRHPRevised.PricebookEntryId = pricebookEntrySecondRHP.Id;
  		OpportunityLineItemSecondRHPRevised.UnitPrice = 100;
  		OpportunityLineItemSecondRHPRevised.Quantity = 3;
  		OpportunityLineItemSecondRHPRevised.Target_Cover_Rating__c = 'M - Mature';
  		OpportunityLineItemSecondRHPRevised.Onsale_Date__c = Inventory_Test.getWednesday(4);
  		OpportunityLineItemSecondRHPRevised.OpportunityId = opportunityRevised.Id;
		lstOpportunityLineItem.add(OpportunityLineItemSecondRHPRevised);
		
		OpportunityLineItem OpportunityLineItemFirstSpreadRevised = new OpportunityLineItem();
  		OpportunityLineItemFirstSpreadRevised.PricebookEntryId = pricebookEntryFirstSpread.Id;
  		OpportunityLineItemFirstSpreadRevised.UnitPrice = 100;
  		OpportunityLineItemFirstSpreadRevised.Quantity = 1;
  		OpportunityLineItemFirstSpreadRevised.Target_Cover_Rating__c = 'T - Teen';
  		OpportunityLineItemFirstSpreadRevised.Onsale_Date__c = Inventory_Test.getWednesday(1);
  		OpportunityLineItemFirstSpreadRevised.OpportunityId = opportunityRevised.Id;
  		lstOpportunityLineItem.add(OpportunityLineItemFirstSpreadRevised);
  		
  		OpportunityLineItem OpportunityLineItemCenterSpreadRevised = new OpportunityLineItem();
  		OpportunityLineItemCenterSpreadRevised.PricebookEntryId = pricebookEntryCenterSpread.Id;
  		OpportunityLineItemCenterSpreadRevised.UnitPrice = 100;
  		OpportunityLineItemCenterSpreadRevised.Quantity = 1;
  		OpportunityLineItemCenterSpreadRevised.Target_Cover_Rating__c = 'M - Mature';
  		OpportunityLineItemCenterSpreadRevised.Onsale_Date__c = Inventory_Test.getWednesday(2);
  		OpportunityLineItemCenterSpreadRevised.OpportunityId = opportunityRevised.Id;
  		lstOpportunityLineItem.add(OpportunityLineItemCenterSpreadRevised);
  
  		OpportunityLineItem OpportunityLineItemInteriorPageRevised = new OpportunityLineItem();
  		OpportunityLineItemInteriorPageRevised.PricebookEntryId = pricebookEntryInteriorPage.Id;
  		OpportunityLineItemInteriorPageRevised.UnitPrice = 100;
  		OpportunityLineItemInteriorPageRevised.Quantity = 9;
  		OpportunityLineItemInteriorPageRevised.Target_Cover_Rating__c = 'T+ - Teen+';
  		OpportunityLineItemInteriorPageRevised.Onsale_Date__c = Inventory_Test.getWednesday(2);
  		OpportunityLineItemInteriorPageRevised.OpportunityId = opportunityRevised.Id;
  		lstOpportunityLineItem.add(OpportunityLineItemInteriorPageRevised);
		
		insert lstOpportunityLineItem;
  
		Test.startTest();
        
        PageReference pageRef = Page.Inventory;
		Test.setCurrentPage(pageRef);
        Inventory_CC inventory = new Inventory_CC();
        inventory.month = 11;
        inventory.sumMonth();
        inventory.sumMonth();
        inventory.sumMonth();
        inventory.restMonth();
        inventory.restMonth();
        
        Test.stopTest();     
     }
     
     public static Date getWednesday(Integer numberWeek){
		Integer numberDays = date.daysInMonth(system.now().year(), 12);
		Integer numberWednesdays = 0;
		Date dtWednesday;
		for(Integer iloop=1; iloop<=numberDays; iloop++){
			Datetime dt = DateTime.newinstance(date.newinstance(system.now().year(), system.now().month(), iloop), Time.newInstance(0, 0, 0, 0));
			String dayOfWeek=dt.format('EEEE');		
			if(dayOfWeek=='Wednesday'){
				numberWednesdays++;
				if(numberWednesdays == numberWeek){
					dtWednesday = dt.date();
					break;
				}
			}
		}
		return dtWednesday;
	}
}