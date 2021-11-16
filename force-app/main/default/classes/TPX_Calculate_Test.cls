/******* 
TPX_Calculate_Test
Creation Date- 18 April 2016
Description- This class is to do code coverage for TPX_Calculate
Author- Martin Mori
*******/

@IsTest
private class TPX_Calculate_Test{
    static testMethod void unitTest() {
        Id rtOpportunity = [SELECT Id FROM RecordType WHERE Name = 'TPX Integrations' AND SObjectType = 'Opportunity'].Id;
        Id rtProduct = [SELECT Id FROM RecordType WHERE Name = 'ELLEN Products' AND SObjectType = 'Product2'].Id;
        
        //Insert Opportunity
        Opportunity tpxOpportunity = new Opportunity();
        tpxOpportunity.Name='Test';
        tpxOpportunity.CloseDate=System.now().date();
        tpxOpportunity.StageName='Closed';
        tpxOpportunity.RecordTypeId=rtOpportunity;
        insert tpxOpportunity;
        
        //Insert Products
        List<Product2> lstProducts = new List<Product2>();
        
        Product2 productSponsorship = new Product2();
        productSponsorship.Name='Twitter Amplify';
        productSponsorship.Product_Category__c='On-Air';
        productSponsorship.Product_Sub_Category__c='Sponsorship';
        productSponsorship.RecordTypeId=rtProduct;
        productSponsorship.IsActive=true;
        lstProducts.add(productSponsorship);
        
        Product2 productGamesHeadsUp = new Product2();
        productGamesHeadsUp.Name='Games Heads Up';
        productGamesHeadsUp.Product_Category__c='Games';
        productGamesHeadsUp.Product_Sub_Category__c='Heads Up!';
        productGamesHeadsUp.RecordTypeId=rtProduct;
        productGamesHeadsUp.IsActive=true;
        lstProducts.add(productGamesHeadsUp);
        
        Product2 productGamesPsych = new Product2();
        productGamesPsych.Name='Games Psych';
        productGamesPsych.Product_Category__c='Games';
        productGamesPsych.Product_Sub_Category__c='Psych!';
        productGamesPsych.RecordTypeId=rtProduct;
        productGamesPsych.IsActive=true;
        lstProducts.add(productGamesPsych);
        
        Product2 productGamesHotHands = new Product2();
        productGamesHotHands.Name='Games Hot Hands';
        productGamesHotHands.Product_Category__c='Games';
        productGamesHotHands.Product_Sub_Category__c='Hot Hands';
        productGamesHotHands.RecordTypeId=rtProduct;
        productGamesHotHands.IsActive=true;
        lstProducts.add(productGamesHotHands);
        
        Product2 productGamesEmoji = new Product2();
        productGamesEmoji.Name='Games';
        productGamesEmoji.Product_Category__c='Games';
        productGamesEmoji.Product_Sub_Category__c='Game of Games';
        productGamesEmoji.RecordTypeId=rtProduct;
        productGamesEmoji.IsActive=true;
        lstProducts.add(productGamesEmoji);
        
        Product2 productEllentube = new Product2();
        productEllentube.Name='Ellentube';
        productEllentube.Product_Category__c='Ellentube';
        productEllentube.RecordTypeId=rtProduct;
        productEllentube.IsActive=true;
        lstProducts.add(productEllentube);
        
        Product2 productYoutube = new Product2();
        productYoutube.Name='Youtube';
        productYoutube.Product_Category__c='Youtube';
        productYoutube.RecordTypeId=rtProduct;
        productYoutube.IsActive=true;
        lstProducts.add(productYoutube);
        
        insert lstProducts;
        
        //Create PriceBook "ELLEN Price Book"
        Pricebook2 priceBookEllen = new Pricebook2(Name='ELLEN Price Book', isActive=true, Business_Unit__c='1234');
        insert priceBookEllen;
        
        //Insert PriceBookEntry
        List<PriceBookEntry> lstPricebookEntry = new List<PriceBookEntry>();
        Id idStandard = Test.getStandardPricebookId();
  
        PricebookEntry pricebookEntryStandardSponsorship = new PricebookEntry();
        pricebookEntryStandardSponsorship.IsActive = true;
        pricebookEntryStandardSponsorship.Product2Id = productSponsorship.Id;
        pricebookEntryStandardSponsorship.UnitPrice = 0;
        pricebookEntryStandardSponsorship.Pricebook2Id = idStandard;
        lstPricebookEntry.add(pricebookEntryStandardSponsorship);
        
        PricebookEntry pricebookEntryEllenSponsorship = new PricebookEntry();
        pricebookEntryEllenSponsorship.IsActive = true;
        pricebookEntryEllenSponsorship.Product2Id = productSponsorship.Id;
        pricebookEntryEllenSponsorship.UnitPrice = 0;
        pricebookEntryEllenSponsorship.Pricebook2Id = priceBookEllen.Id;
        lstPricebookEntry.add(pricebookEntryEllenSponsorship);
        
        PricebookEntry pricebookEntryStandardGamesHeadsUp = new PricebookEntry();
        pricebookEntryStandardGamesHeadsUp.IsActive = true;
        pricebookEntryStandardGamesHeadsUp.Product2Id = productGamesHeadsUp.Id;
        pricebookEntryStandardGamesHeadsUp.UnitPrice = 0;
        pricebookEntryStandardGamesHeadsUp.Pricebook2Id = idStandard;
        lstPricebookEntry.add(pricebookEntryStandardGamesHeadsUp);
        
        PricebookEntry pricebookEntryEllenGamesHeadsUp = new PricebookEntry();
        pricebookEntryEllenGamesHeadsUp.IsActive = true;
        pricebookEntryEllenGamesHeadsUp.Product2Id = productGamesHeadsUp.Id;
        pricebookEntryEllenGamesHeadsUp.UnitPrice = 0;
        pricebookEntryEllenGamesHeadsUp.Pricebook2Id = priceBookEllen.Id;
        lstPricebookEntry.add(pricebookEntryEllenGamesHeadsUp);
        
        PricebookEntry pricebookEntryStandardGamesPsych = new PricebookEntry();
        pricebookEntryStandardGamesPsych.IsActive = true;
        pricebookEntryStandardGamesPsych.Product2Id = productGamesPsych.Id;
        pricebookEntryStandardGamesPsych.UnitPrice = 0;
        pricebookEntryStandardGamesPsych.Pricebook2Id = idStandard;
        lstPricebookEntry.add(pricebookEntryStandardGamesPsych);
        
        PricebookEntry pricebookEntryEllenGamesPsych = new PricebookEntry();
        pricebookEntryEllenGamesPsych.IsActive = true;
        pricebookEntryEllenGamesPsych.Product2Id = productGamesPsych.Id;
        pricebookEntryEllenGamesPsych.UnitPrice = 0;
        pricebookEntryEllenGamesPsych.Pricebook2Id = priceBookEllen.Id;
        lstPricebookEntry.add(pricebookEntryEllenGamesPsych);
        
        PricebookEntry pricebookEntryStandardGamesHotHands = new PricebookEntry();
        pricebookEntryStandardGamesHotHands.IsActive = true;
        pricebookEntryStandardGamesHotHands.Product2Id = productGamesHotHands.Id;
        pricebookEntryStandardGamesHotHands.UnitPrice = 0;
        pricebookEntryStandardGamesHotHands.Pricebook2Id = idStandard;
        lstPricebookEntry.add(pricebookEntryStandardGamesHotHands);
        
        PricebookEntry pricebookEntryEllenGamesHotHands = new PricebookEntry();
        pricebookEntryEllenGamesHotHands.IsActive = true;
        pricebookEntryEllenGamesHotHands.Product2Id = productGamesHotHands.Id;
        pricebookEntryEllenGamesHotHands.UnitPrice = 0;
        pricebookEntryEllenGamesHotHands.Pricebook2Id = priceBookEllen.Id;
        lstPricebookEntry.add(pricebookEntryEllenGamesHotHands);
        
        PricebookEntry pricebookEntryStandardGamesEmoji = new PricebookEntry();
        pricebookEntryStandardGamesEmoji.IsActive = true;
        pricebookEntryStandardGamesEmoji.Product2Id = productGamesEmoji.Id;
        pricebookEntryStandardGamesEmoji.UnitPrice = 0;
        pricebookEntryStandardGamesEmoji.Pricebook2Id = idStandard;
        lstPricebookEntry.add(pricebookEntryStandardGamesEmoji);
        
        PricebookEntry pricebookEntryEllenGamesEmoji = new PricebookEntry();
        pricebookEntryEllenGamesEmoji.IsActive = true;
        pricebookEntryEllenGamesEmoji.Product2Id = productGamesEmoji.Id;
        pricebookEntryEllenGamesEmoji.UnitPrice = 0;
        pricebookEntryEllenGamesEmoji.Pricebook2Id = priceBookEllen.Id;
        lstPricebookEntry.add(pricebookEntryEllenGamesEmoji);
        
        PricebookEntry pricebookEntryStandardEllentube = new PricebookEntry();
        pricebookEntryStandardEllentube.IsActive = true;
        pricebookEntryStandardEllentube.Product2Id = productEllentube.Id;
        pricebookEntryStandardEllentube.UnitPrice = 0;
        pricebookEntryStandardEllentube.Pricebook2Id = idStandard;
        lstPricebookEntry.add(pricebookEntryStandardEllentube);
        
        PricebookEntry pricebookEntryEllenEllentube = new PricebookEntry();
        pricebookEntryEllenEllentube.IsActive = true;
        pricebookEntryEllenEllentube.Product2Id = productEllentube.Id;
        pricebookEntryEllenEllentube.UnitPrice = 0;
        pricebookEntryEllenEllentube.Pricebook2Id = priceBookEllen.Id;
        lstPricebookEntry.add(pricebookEntryEllenEllentube);
        
        PricebookEntry pricebookEntryStandardYoutube = new PricebookEntry();
        pricebookEntryStandardYoutube.IsActive = true;
        pricebookEntryStandardYoutube.Product2Id = productYoutube.Id;
        pricebookEntryStandardYoutube.UnitPrice = 0;
        pricebookEntryStandardYoutube.Pricebook2Id = idStandard;
        lstPricebookEntry.add(pricebookEntryStandardYoutube);
        
        PricebookEntry pricebookEntryEllenYoutube = new PricebookEntry();
        pricebookEntryEllenYoutube.IsActive = true;
        pricebookEntryEllenYoutube.Product2Id = productYoutube.Id;
        pricebookEntryEllenYoutube.UnitPrice = 0;
        pricebookEntryEllenYoutube.Pricebook2Id = priceBookEllen.Id;
        lstPricebookEntry.add(pricebookEntryEllenYoutube);
        
        insert lstPricebookEntry;
        
        //Insert OpportunityLineItems
        List<OpportunityLineItem> lstOpportunityLineItem = new List<OpportunityLineItem>();
  
        OpportunityLineItem OpportunityLineItemSponsorship = new OpportunityLineItem();
        OpportunityLineItemSponsorship.PricebookEntryId = pricebookEntryEllenSponsorship.Id;
        OpportunityLineItemSponsorship.UnitPrice = 100;
        OpportunityLineItemSponsorship.Quantity = 1;
        OpportunityLineItemSponsorship.OpportunityId = tpxOpportunity.Id;
        lstOpportunityLineItem.add(OpportunityLineItemSponsorship);
        
        OpportunityLineItem OpportunityLineItemGamesHeadsUp = new OpportunityLineItem();
        OpportunityLineItemGamesHeadsUp.PricebookEntryId = pricebookEntryEllenGamesHeadsUp.Id;
        OpportunityLineItemGamesHeadsUp.UnitPrice = 100;
        OpportunityLineItemGamesHeadsUp.Quantity = 1;
        //Code Added by Mayank Desai on 01/31/2019 for ER-2310 - TPX games Rollup +start
        OpportunityLineItemGamesHeadsUp.Est_Games_Cost__c=33;
        OpportunityLineItemGamesHeadsUp.Final_Games_Cost__c=50;
        //Code Added by Mayank Desai on 01/31/2019 for ER-2310 - TPX games Rollup +END
        OpportunityLineItemGamesHeadsUp.OpportunityId = tpxOpportunity.Id;
        lstOpportunityLineItem.add(OpportunityLineItemGamesHeadsUp);
        
        OpportunityLineItem OpportunityLineItemGamesPsych = new OpportunityLineItem();
        OpportunityLineItemGamesPsych.PricebookEntryId = pricebookEntryEllenGamesPsych.Id;
        OpportunityLineItemGamesPsych.UnitPrice = 100;
        OpportunityLineItemGamesPsych.Quantity = 1;
        //Code Added by Mayank Desai on 01/31/2019 for ER-2310 - TPX games Rollup +start
        OpportunityLineItemGamesPsych.Est_Games_Cost__c =33;
        OpportunityLineItemGamesPsych.Final_Games_Cost__c=50;
        //Code Added by Mayank Desai on 01/31/2019 for ER-2310 - TPX games Rollup +END
        OpportunityLineItemGamesPsych.OpportunityId = tpxOpportunity.Id;
        lstOpportunityLineItem.add(OpportunityLineItemGamesPsych);
        
        OpportunityLineItem OpportunityLineItemGamesHotHands = new OpportunityLineItem();
        OpportunityLineItemGamesHotHands.PricebookEntryId = pricebookEntryEllenGamesHotHands.Id;
        OpportunityLineItemGamesHotHands.UnitPrice = 100;
        OpportunityLineItemGamesHotHands.Quantity = 1;
        //Code Added by Mayank Desai on 01/31/2019 for ER-2310 - TPX games Rollup +start
        OpportunityLineItemGamesHotHands.Est_Games_Cost__c =33;
        OpportunityLineItemGamesHotHands.Final_Games_Cost__c=50;
        //Code Added by Mayank Desai on 01/31/2019 for ER-2310 - TPX games Rollup +END
        OpportunityLineItemGamesHotHands.OpportunityId = tpxOpportunity.Id;
        lstOpportunityLineItem.add(OpportunityLineItemGamesHotHands);
        
        OpportunityLineItem OpportunityLineItemGamesEmoji = new OpportunityLineItem();
        OpportunityLineItemGamesEmoji.PricebookEntryId = pricebookEntryEllenGamesEmoji.Id;
        OpportunityLineItemGamesEmoji.UnitPrice = 100;
        OpportunityLineItemGamesEmoji.Quantity = 1;
        //Code Added by Mayank Desai on 01/31/2019 for ER-2310 - TPX games Rollup +start
        OpportunityLineItemGamesEmoji.Est_Games_Cost__c=33;
        OpportunityLineItemGamesEmoji.Final_Games_Cost__c=50;
        //Code Added by Mayank Desai on 01/31/2019 for ER-2310 - TPX games Rollup +END
        OpportunityLineItemGamesEmoji.OpportunityId = tpxOpportunity.Id;
        lstOpportunityLineItem.add(OpportunityLineItemGamesEmoji);
        
        OpportunityLineItem OpportunityLineItemEllentube = new OpportunityLineItem();
        OpportunityLineItemEllentube.PricebookEntryId = pricebookEntryEllenEllentube.Id;
        OpportunityLineItemEllentube.UnitPrice = 100;
        OpportunityLineItemEllentube.Quantity = 1;
        OpportunityLineItemEllentube.OpportunityId = tpxOpportunity.Id;
        lstOpportunityLineItem.add(OpportunityLineItemEllentube);
        
        OpportunityLineItem OpportunityLineItemYoutube = new OpportunityLineItem();
        OpportunityLineItemYoutube.PricebookEntryId = pricebookEntryEllenYoutube.Id;
        OpportunityLineItemYoutube.UnitPrice = 100;
        OpportunityLineItemYoutube.Quantity = 1;
        OpportunityLineItemYoutube.OpportunityId = tpxOpportunity.Id;
        lstOpportunityLineItem.add(OpportunityLineItemYoutube);
        
        insert lstOpportunityLineItem;
        
        Test.startTest();
        TPX_Calculate.TPX_UpdateOpportunity(tpxOpportunity.Id);
        Test.stopTest();
        
        //Code Added by Mayank Desai on 01/31/2019 for ER-2310 - TPX games Rollup +start     
        Opportunity updatedDeal = [Select Id,Est_Games_Cost__c,Games_Fee__c,EST_Games_Net_Income__c,Final_Games_Cost__c,Final_Games_Net_Income__c From Opportunity Where Id =: tpxOpportunity.Id];
        system.assertequals(updatedDeal.Games_Fee__c, 400, 'Games_Fee__c is incorrect' + tpxOpportunity.Id);
        system.assertequals(updatedDeal.Est_Games_Cost__c, 132, 'Est_Games_Cost__c is incorrect' + tpxOpportunity.Id);
        system.assertequals(updatedDeal.EST_Games_Net_Income__c, 268, 'EST_Games_Net_Income__c is incorrect' + tpxOpportunity.Id);
        system.assertequals(updatedDeal.Final_Games_Cost__c, 200, 'Final_Games_Cost__c is incorrect' + tpxOpportunity.Id);
        system.assertequals(updatedDeal.Final_Games_Net_Income__c, 200, 'Final_Games_Net_Income__c is incorrect' + tpxOpportunity.Id);
        //Code Added by Mayank Desai on 01/31/2019 for ER-2310 - TPX games Rollup + End
    }
}