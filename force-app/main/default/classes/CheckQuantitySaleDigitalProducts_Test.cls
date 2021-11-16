/******* 
CheckQuantitySaleDigitalProducts_Test
Creation Date- 31 October 2016
Description- This class is to do code coverage for CheckQuantitySaleDigitalProducts and CheckQuantitySaleDigitalProductsOpportunity
Author- Martín Mori
*******/
@isTest
public class CheckQuantitySaleDigitalProducts_Test {
    @isTest static void CheckQuantitySaleDigitalProductsTest() {
        
        //create products
        List<Product2> lstProduct = new List<Product2>();
      
  		Product2 productGroup1 = new Product2();
  		productGroup1.Name = 'DCComics.com Leaderboard (728x90)';
		productGroup1.Family = 'Digital';
	  	productGroup1.IsActive = true;
	  	lstProduct.add(productGroup1);
  
  		Product2 productGroup2 = new Product2();
  		productGroup2.Name = 'Facebook-Aquaman';
  		productGroup2.Family = 'Digital';
  		productGroup2.IsActive = true;
  		lstProduct.add(productGroup2);
        
        Product2 productGroup3 = new Product2();
  		productGroup3.Name = 'Site Wide Takeovers';
  		productGroup3.Family = 'Digital';
  		productGroup3.IsActive = true;
  		lstProduct.add(productGroup3);
  
  		insert lstProduct;
        
        //create Inventory
  
  		List<Inventory__c> lstInventory = new List<Inventory__c>();
  
  		Inventory__c inventoryGroup1 = new Inventory__c();
  		inventoryGroup1.Product__c = productGroup1.Id;
  		inventoryGroup1.Onsale_Availability__c = 'Monthly';
  		inventoryGroup1.Quantity__c = 1;
        inventoryGroup1.Impressions__c=5000000;
  		lstInventory.add(inventoryGroup1);
        
        Inventory__c inventoryGroup2 = new Inventory__c();
  		inventoryGroup2.Product__c = productGroup2.Id;
  		inventoryGroup2.Onsale_Availability__c = 'Daily';
  		inventoryGroup2.Quantity__c = 2;
        lstInventory.add(inventoryGroup2);
        
        Inventory__c inventoryGroup3 = new Inventory__c();
  		inventoryGroup3.Product__c = productGroup3.Id;
  		inventoryGroup3.Onsale_Availability__c = 'Daily';
  		inventoryGroup3.Quantity__c = 1;
        lstInventory.add(inventoryGroup3);
        
        
        
        
  		insert lstInventory;
        
        //add pricebook entry
  
	  	List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
  
  		Id idStandard = Test.getStandardPricebookId();
  
  		PricebookEntry pricebookEntryGroup1 = new PricebookEntry();
  		pricebookEntryGroup1.IsActive = true;
  		pricebookEntryGroup1.Product2Id = productGroup1.Id;
  		pricebookEntryGroup1.UnitPrice = 0;
  		pricebookEntryGroup1.Pricebook2Id = idStandard;
  		lstPricebookEntry.add(pricebookEntryGroup1);
        
        PricebookEntry pricebookEntryGroup2 = new PricebookEntry();
  		pricebookEntryGroup2.IsActive = true;
  		pricebookEntryGroup2.Product2Id = productGroup2.Id;
  		pricebookEntryGroup2.UnitPrice = 0;
  		pricebookEntryGroup2.Pricebook2Id = idStandard;
  		lstPricebookEntry.add(pricebookEntryGroup2);
        
        PricebookEntry pricebookEntryGroup3 = new PricebookEntry();
  		pricebookEntryGroup3.IsActive = true;
  		pricebookEntryGroup3.Product2Id = productGroup3.Id;
  		pricebookEntryGroup3.UnitPrice = 0;
  		pricebookEntryGroup3.Pricebook2Id = idStandard;
  		lstPricebookEntry.add(pricebookEntryGroup3);
        
        
  		insert lstPricebookEntry;
        
       
        
        //add opportunity
        Id rt = [SELECT Id FROM RecordType WHERE Name =: 'DC Deals'].Id;
        
  		List<Opportunity> lstOpportunity = new List<Opportunity>();
  		
  		Opportunity opportunityConfirmed = new Opportunity();
  		opportunityConfirmed.Name = 'Confirmed Opp';
  		opportunityConfirmed.CloseDate = system.now().date();
  		opportunityConfirmed.StageName = 'Confirmed';
  		opportunityConfirmed.Product_Type__c = 'Digital';
        opportunityConfirmed.Digital_End_Date__c = date.newInstance(2016, 11, 5).addDays(4);
        opportunityConfirmed.Digital_Start_Date__c = date.newInstance(2016, 11, 5);
  		opportunityConfirmed.RecordTypeId = rt;
  		lstOpportunity.add(opportunityConfirmed);
  
  		Opportunity opportunityVerbal = new Opportunity();
  		opportunityVerbal.Name = 'Verbal Opp';
  		opportunityVerbal.CloseDate = system.now().date();
  		opportunityVerbal.StageName = 'Verbal';
  		opportunityVerbal.Product_Type__c = 'Digital';
        opportunityVerbal.Digital_End_Date__c = date.newInstance(2016, 11, 5).addDays(4);
        opportunityVerbal.Digital_Start_Date__c = date.newInstance(2016, 11, 5);
  		opportunityVerbal.RecordTypeId = rt;
  		lstOpportunity.add(opportunityVerbal);
  
  		Opportunity opportunityRevised = new Opportunity();
  		opportunityRevised.Name = 'Revised Opp';
  		opportunityRevised.CloseDate = system.now().date();
  		opportunityRevised.StageName = 'Scenario';
  		opportunityRevised.Product_Type__c = 'Digital';
  		opportunityRevised.RecordTypeId = rt;
  		lstOpportunity.add(opportunityRevised);
        
         
  		insert lstOpportunity;
        ApexUtil.isTriggerInvoked = false;
        
        //add oppotunity line item
  
  		List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
  
  		OpportunityLineItem OpportunityLineItemGruoup1Confirmed = new OpportunityLineItem();
  		OpportunityLineItemGruoup1Confirmed.PricebookEntryId = pricebookEntryGroup1.Id;
  		OpportunityLineItemGruoup1Confirmed.UnitPrice = 100;
  		OpportunityLineItemGruoup1Confirmed.Quantity = 1;
        OpportunityLineItemGruoup1Confirmed.Impression__c = 4000000;
  		OpportunityLineItemGruoup1Confirmed.Onsale_Date__c = date.newInstance(2016, 11, 5);
  		OpportunityLineItemGruoup1Confirmed.OpportunityId = opportunityConfirmed.Id;
  		//lstOpportunityLineItem.add(OpportunityLineItemGruoup1Confirmed);
  		
  		Test.startTest();
  		insert OpportunityLineItemGruoup1Confirmed;
        ApexUtil.isTriggerInvoked = false;
        
        OpportunityLineItem OpportunityLineItemGruoup1Verbal = new OpportunityLineItem();
  		OpportunityLineItemGruoup1Verbal.PricebookEntryId = pricebookEntryGroup1.Id;
  		OpportunityLineItemGruoup1Verbal.UnitPrice = 100;
  		OpportunityLineItemGruoup1Verbal.Quantity = 1;
        OpportunityLineItemGruoup1Verbal.Impression__c = 4000000;
  		OpportunityLineItemGruoup1Verbal.Onsale_Date__c = date.newInstance(2016, 11, 5);
  		OpportunityLineItemGruoup1Verbal.OpportunityId = opportunityVerbal.Id;
  		//lstOpportunityLineItem.add(OpportunityLineItemGruoup1Verbal);
  		try {insert OpportunityLineItemGruoup1Verbal;}
        catch(DmlException e) {}
        ApexUtil.isTriggerInvoked = false;
        
        opportunityVerbal.Digital_End_Date__c = date.newInstance(2016, 11, 5).addDays(10);
        opportunityVerbal.Digital_Start_Date__c = date.newInstance(2016, 11, 5).addDays(5);
        opportunityVerbal.StageName = 'Scenario';
        update opportunityVerbal;
        ApexUtil.isTriggerInvoked = false;
        
        try {insert OpportunityLineItemGruoup1Verbal;}
        catch(DmlException e) {}
        ApexUtil.isTriggerInvoked = false;
        
        opportunityVerbal.StageName = 'Confirmed';
        try {update opportunityVerbal;}
        catch(DmlException e) {}
        ApexUtil.isTriggerInvoked = false;
        
        OpportunityLineItem OpportunityLineItemGruoup2Revised = new OpportunityLineItem();
  		OpportunityLineItemGruoup2Revised.PricebookEntryId = pricebookEntryGroup2.Id;
  		OpportunityLineItemGruoup2Revised.UnitPrice = 100;
  		OpportunityLineItemGruoup2Revised.Quantity = 3;
        OpportunityLineItemGruoup2Revised.Onsale_Date__c = date.newInstance(2016, 11, 5);
  		OpportunityLineItemGruoup2Revised.OpportunityId = opportunityRevised.Id;
  		//lstOpportunityLineItem.add(OpportunityLineItemGruoup2Revised);
  		try {insert OpportunityLineItemGruoup2Revised;}
        catch(DmlException e) {}
        ApexUtil.isTriggerInvoked = false;
        
        opportunityRevised.StageName = 'Confirmed';
        try {update opportunityRevised;}
        catch(DmlException e) {}
        ApexUtil.isTriggerInvoked = false;
        
  		OpportunityLineItem OpportunityLineItemGruoup3Revised = new OpportunityLineItem();
  		OpportunityLineItemGruoup3Revised.PricebookEntryId = pricebookEntryGroup3.Id;
  		OpportunityLineItemGruoup3Revised.UnitPrice = 100;
  		OpportunityLineItemGruoup3Revised.Quantity = 2;
        OpportunityLineItemGruoup3Revised.Onsale_Date__c = date.newInstance(2016, 11, 5);
  		OpportunityLineItemGruoup3Revised.OpportunityId = opportunityRevised.Id;
  		//lstOpportunityLineItem.add(OpportunityLineItemGruoup2Revised);
  		try {insert OpportunityLineItemGruoup3Revised;}
        catch(DmlException e) {}
        ApexUtil.isTriggerInvoked = false;
        
        opportunityRevised.StageName = 'Confirmed';
        try {update opportunityRevised;}
        catch(DmlException e) {}
        ApexUtil.isTriggerInvoked = false;
        
        OpportunityLineItemGruoup1Verbal.Impression__c = 1000000;
  		lstOpportunityLineItem.add(OpportunityLineItemGruoup1Verbal);
        OpportunityLineItemGruoup2Revised.Quantity = 2;
        lstOpportunityLineItem.add(OpportunityLineItemGruoup2Revised);
  		OpportunityLineItemGruoup3Revised.Quantity = 1;
        lstOpportunityLineItem.add(OpportunityLineItemGruoup3Revised);
  		try {update lstOpportunityLineItem;}
        catch(DmlException e) {}
        ApexUtil.isTriggerInvoked = false;
        
  		opportunityVerbal.StageName = 'Verbal';
        opportunityRevised.StageName = 'Confirmed';
        try {update lstOpportunity;}
        catch(DmlException e) {}
        ApexUtil.isTriggerInvoked = false;
        
        OpportunityLineItemGruoup1Verbal.Impression__c = 2000000;
  		OpportunityLineItemGruoup2Revised.Quantity = 3;
        OpportunityLineItemGruoup2Revised.Onsale_Date__c=date.newInstance(2017, 11, 5);
        OpportunityLineItemGruoup3Revised.Quantity = 2;
        OpportunityLineItemGruoup3Revised.Onsale_Date__c=date.newInstance(2017, 11, 5);
        try {update lstOpportunityLineItem;}
        catch(DmlException e) {}
        ApexUtil.isTriggerInvoked = false;
        
        //insert lstOpportunityLineItem;
        Test.stopTest();
    }
}