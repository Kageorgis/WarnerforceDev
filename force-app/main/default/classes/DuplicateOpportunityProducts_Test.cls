/******* 
DuplicateOpportunityProducts_Test
Creation Date- 01 January 2017
Description- This class is to do code coverage for DuplicateOpportunityProducts
Author- Martin Mori
*******/

@isTest
private class DuplicateOpportunityProducts_Test{
    
    static testMethod void duplicateOliTest(){
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
  
  		Id rt = [SELECT Id FROM RecordType WHERE Name =: 'DC Deals'].Id;
	  
  		Opportunity opportunityConfirmed = new Opportunity();
  		opportunityConfirmed.Name = 'Confirmed Opp';
  		opportunityConfirmed.CloseDate = system.now().date();
  		opportunityConfirmed.StageName = 'Scenario';
  		opportunityConfirmed.Product_Type__c = 'Print';
  		opportunityConfirmed.RecordTypeId = rt;
  		insert opportunityConfirmed;
  		
        //add oppotunity line item
  
  		OpportunityLineItem OpportunityLineItemC2Confirmed = new OpportunityLineItem();
  		OpportunityLineItemC2Confirmed.PricebookEntryId = pricebookEntryC2.Id;
  		OpportunityLineItemC2Confirmed.UnitPrice = 100;
  		OpportunityLineItemC2Confirmed.Quantity = 1;
  		OpportunityLineItemC2Confirmed.Target_Cover_Rating__c = 'E - Everyone';
  		OpportunityLineItemC2Confirmed.Onsale_Date__c = System.now().date();
  		OpportunityLineItemC2Confirmed.OpportunityId = opportunityConfirmed.Id;
        OpportunityLineItemC2Confirmed.Duplicate_Num_Week__c=3;
        //inserting the oppotunity line item
  		insert OpportunityLineItemC2Confirmed;
        OpportunityLineItemC2Confirmed.Duplicate_Num_Week__c=1;
        //updating the oppotunity line item and modifing the Duplicate_Num_Week__c field to 1
  		update OpportunityLineItemC2Confirmed;
        //updating the oppotunity line item and modifing the Duplicate_Num_Week__c field to 3
        OpportunityLineItemC2Confirmed.Duplicate_Num_Week__c=3;
  		update OpportunityLineItemC2Confirmed;
    }
    
}