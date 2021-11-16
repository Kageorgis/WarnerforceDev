/******* 
CheckQuantitySaleDigitalProducts
Creation Date- 06 December 2016
Description- This class verifies the availability of products
Author - Martín Mori
*******/
public class CheckQuantitySaleDigitalProducts {
    public Map<Id, OpportunityLineItem> CheckOpportunityLineItem(Map<Id, OpportunityLineItem> mapOpportunityLineItem, Set<Id> setOpportunityId, Set<Id> setOpportunityLineItemId) {
        Set<Id> setOpportunityLineItemProductId = new Set<Id>();
        Map<Id, OpportunityLineItem> mapOpportunityLineItemError = new Map<Id, OpportunityLineItem>();
        
        List<OpportunityLineItem> ltsOpportunityLineItem = new List<OpportunityLineItem>();
        for(OpportunityLineItem oAllOpportunityLineItem : [SELECT Id, Product2Id, Product2.Name, Onsale_Date__c, Quantity, Impression__c, OpportunityId, Opportunity.Digital_End_Date__c, Opportunity.Digital_Start_Date__c FROM OpportunityLineItem WHERE OpportunityId IN :setOpportunityId AND (OpportunityLineItem.Opportunity.StageName='Confirmed' OR OpportunityLineItem.Opportunity.StageName='Verbal') AND OpportunityLineItem.Product2.Family='Digital' AND OpportunityLineItem.Opportunity.RecordType.Name='DC Deals']) {
            ltsOpportunityLineItem.add(oAllOpportunityLineItem);
            setOpportunityLineItemProductId.add(oAllOpportunityLineItem.Product2Id);
        }
        
        if(ltsOpportunityLineItem.size()>0) {
            // Create a Set from Product Names to Family Digital
            Set<String> setDigitalProductImpressionsName = new Set<String>();
            Set<String> setDigitalProductSocialName = new Set<String>();
            Set<String> setDigitalProductWebName = new Set<String>();
            
            setDigitalProductImpressionsName.add('DCComics.com Leaderboard (728x90)');
            setDigitalProductImpressionsName.add('DCComics.com Medium Rectangle (300x250)');
            setDigitalProductImpressionsName.add('MadMagazine.con Leaderboard (728x90)');
            setDigitalProductImpressionsName.add('MadMagazine.con Medium Rectangle (300x250)');
            setDigitalProductImpressionsName.add('Vertigocomincs.com Leaderboard (728x90)');
            setDigitalProductImpressionsName.add('Vertigocomincs.com Medium Rectangle (300x250)');
            
            setDigitalProductSocialName.add('Facebook-Aquaman');
            setDigitalProductSocialName.add('Facebook-Batman');
            setDigitalProductSocialName.add('Facebook-DC Comics');
            setDigitalProductSocialName.add('Facebook-Green Arrow');
            setDigitalProductSocialName.add('Facebook-Green Lantern');
            setDigitalProductSocialName.add('Facebook-Harley Quinn');
            setDigitalProductSocialName.add('Facebook-Superman');
            setDigitalProductSocialName.add('Facebook-The Flash');
            setDigitalProductSocialName.add('Facebook-Vertigo');
            setDigitalProductSocialName.add('Facebook-Wonder Woman');
            setDigitalProductSocialName.add('Google+ - DC Entertainment');
            setDigitalProductSocialName.add('Instagram-DC Comics');
            setDigitalProductSocialName.add('Twitter-DC Comics');
            setDigitalProductSocialName.add('Twitter-My DC Deals');
            setDigitalProductSocialName.add('Snapchat');
            setDigitalProductSocialName.add('All Access');
            
            setDigitalProductWebName.add('Site Wide Takeovers');
            setDigitalProductWebName.add('Homepage Roadblocks');
            
            // Create a Map from Product to Family Digital
            Map<Id, Product2> mapDigitalProductImpressions = new Map<Id, Product2>();
            Map<Id, Product2> mapProductsSocial = new Map<Id, Product2>();
            Map<Id, Product2> mapProductsWeb = new Map<Id, Product2>();
            
            // Fill the Map from Product to Family Digital
            for(Product2 oProduct : [SELECT Id, Name FROM Product2 WHERE Name IN :setDigitalProductImpressionsName OR Name IN :setDigitalProductSocialName OR Name IN :setDigitalProductWebName]) {
                if(setDigitalProductImpressionsName.contains(oProduct.Name)) {
                    mapDigitalProductImpressions.put(oProduct.Id, oProduct);
                }
                if(setDigitalProductSocialName.contains(oProduct.Name)) {
                    mapProductsSocial.put(oProduct.Id, oProduct);
                }
                if(setDigitalProductWebName.contains(oProduct.Name)) {
                    mapProductsWeb.put(oProduct.Id, oProduct);
                    setOpportunityLineItemProductId.add(oProduct.Id); // Id of productos web
                }
            }
            
            // Create a Map from Inventory to Products with Family Digital
            Map<String, Inventory__c> mapInventoryQuantity = new Map<String, Inventory__c>();
            for(Inventory__c oInventory : [SELECT Id, Product__c, Product_Family__c, Quantity__c, Impressions__c, Availability_Date__c, Onsale_Availability__c FROM Inventory__c WHERE Product__c IN :setOpportunityLineItemProductId AND Product_Family__c='Digital']) {
                if(mapDigitalProductImpressions.containsKey(oInventory.Product__c)) { // If the products is Impressions considered only year and month for key map
                    if(oInventory.Availability_Date__c!=null) {
                        mapInventoryQuantity.put(oInventory.Product__c+'-'+oInventory.Onsale_Availability__c+'-'+oInventory.Availability_Date__c.year()+oInventory.Availability_Date__c.month(), oInventory);
                    }
                    else {
                        mapInventoryQuantity.put(oInventory.Product__c+'-'+oInventory.Onsale_Availability__c+'-'+oInventory.Availability_Date__c, oInventory);
                    }
                }
                else {
                    mapInventoryQuantity.put(oInventory.Product__c+'-'+oInventory.Onsale_Availability__c+'-'+oInventory.Availability_Date__c, oInventory);
                }
            }
            
            // Create a Map from quantity to products sold with Family Digital
            Map<String, Decimal> mapSoldQuantityDigitalProductImpressions = new Map<String, Decimal>();
            Map<String, Decimal> mapSoldQuantityDigitalProductSocial = new Map<String, Decimal>();
            Map<String, Decimal> mapSoldQuantityDigitalProductName3 = new Map<String, Decimal>();
            
            // Create a Map from Opportunity Products
            Map<String, OpportunityLineItem> mapAllOpportunityProducts = new Map<String, OpportunityLineItem>();
            
            // Calculate sum the products sold
            for(OpportunityLineItem oAllOpportunityLineItem : [SELECT Id, Product2Id, Product2.Name, Onsale_Date__c, Quantity, Impression__c, OpportunityId, OpportunityLineItem.Opportunity.Digital_End_Date__c, OpportunityLineItem.Opportunity.Digital_Start_Date__c FROM OpportunityLineItem WHERE Id NOT IN :setOpportunityLineItemId AND Product2Id IN :setOpportunityLineItemProductId AND OpportunityLineItem.Product2.Family='Digital' AND (OpportunityLineItem.Opportunity.StageName='Confirmed' OR OpportunityLineItem.Opportunity.StageName='Verbal')]) {
                mapAllOpportunityProducts.put(oAllOpportunityLineItem.Product2Id+'-'+oAllOpportunityLineItem.OpportunityId, oAllOpportunityLineItem);
                if(setDigitalProductWebName.contains(oAllOpportunityLineItem.Product2.Name)) {
                    if(mapSoldQuantityDigitalProductName3.containsKey(String.valueOf(oAllOpportunityLineItem.Onsale_Date__c))) {
                        mapSoldQuantityDigitalProductName3.put(String.valueOf(oAllOpportunityLineItem.Onsale_Date__c), Integer.valueOf(mapSoldQuantityDigitalProductName3.get(String.valueOf(oAllOpportunityLineItem.Onsale_Date__c)))+Integer.valueOf(oAllOpportunityLineItem.Quantity));
                    }
                    else {
                        mapSoldQuantityDigitalProductName3.put(String.valueOf(oAllOpportunityLineItem.Onsale_Date__c), oAllOpportunityLineItem.Quantity);
                    }
                }
                if(setDigitalProductSocialName.contains(oAllOpportunityLineItem.Product2.Name)) {
                    if(mapSoldQuantityDigitalProductSocial.containsKey(oAllOpportunityLineItem.Product2.Name+'-'+'Daily'+'-'+oAllOpportunityLineItem.Onsale_Date__c)) {
                        Integer quantity = Integer.valueOf(mapSoldQuantityDigitalProductSocial.get(oAllOpportunityLineItem.Product2.Name+'-'+'Daily'+'-'+oAllOpportunityLineItem.Onsale_Date__c));
                        mapSoldQuantityDigitalProductSocial.put(oAllOpportunityLineItem.Product2.Name+'-'+'Daily'+'-'+oAllOpportunityLineItem.Onsale_Date__c, quantity + Integer.valueOf(oAllOpportunityLineItem.Quantity));
                    }
                    else {
                        mapSoldQuantityDigitalProductSocial.put(oAllOpportunityLineItem.Product2.Name+'-'+'Daily'+'-'+oAllOpportunityLineItem.Onsale_Date__c, oAllOpportunityLineItem.Quantity);
                    }
                }
                if(setDigitalProductImpressionsName.contains(oAllOpportunityLineItem.Product2.Name)) {
                    if(oAllOpportunityLineItem.Opportunity.Digital_Start_Date__c!=null && oAllOpportunityLineItem.Opportunity.Digital_End_Date__c!=null) {
                        if(mapSoldQuantityDigitalProductImpressions.containsKey(oAllOpportunityLineItem.Product2.Name+'-'+'Monthly'+'-'+String.valueOf(oAllOpportunityLineItem.Opportunity.Digital_Start_Date__c.year())+String.valueOf(oAllOpportunityLineItem.Opportunity.Digital_Start_Date__c.month()))) {
                            Integer quantity = Integer.valueOf(mapSoldQuantityDigitalProductImpressions.get(oAllOpportunityLineItem.Product2.Name+'-'+'Monthly'+'-'+String.valueOf(oAllOpportunityLineItem.Opportunity.Digital_Start_Date__c.year())+String.valueOf(oAllOpportunityLineItem.Opportunity.Digital_Start_Date__c.month())))+Integer.valueOf(oAllOpportunityLineItem.Impression__c);
                            mapSoldQuantityDigitalProductImpressions.put(oAllOpportunityLineItem.Product2.Name+'-'+'Monthly'+'-'+String.valueOf(oAllOpportunityLineItem.Opportunity.Digital_Start_Date__c.year())+String.valueOf(oAllOpportunityLineItem.Opportunity.Digital_Start_Date__c.month()), quantity);
                        }
                        else {
                            mapSoldQuantityDigitalProductImpressions.put(oAllOpportunityLineItem.Product2.Name+'-'+'Monthly'+'-'+String.valueOf(oAllOpportunityLineItem.Opportunity.Digital_Start_Date__c.year())+String.valueOf(oAllOpportunityLineItem.Opportunity.Digital_Start_Date__c.month()), Integer.valueOf(oAllOpportunityLineItem.Impression__c));
                        }
                    }
                }
            }
            
            for(OpportunityLineItem oOpportunityLineItem : ltsOpportunityLineItem){ 
                //if(mapAllOpportunity.containsKey(oOpportunityLineItem.OpportunityId)) {
                    //Compare the stock with the quantity entered - Products Web
                    if(mapProductsWeb.containsKey(oOpportunityLineItem.Product2Id)) {
                        if(oOpportunityLineItem.Quantity<=1) {
                            if(mapSoldQuantityDigitalProductName3.containsKey(String.valueOf(mapOpportunityLineItem.get(oOpportunityLineItem.Id).Onsale_Date__c))) {
                                if(Integer.valueOf(mapSoldQuantityDigitalProductName3.get(String.valueOf(mapOpportunityLineItem.get(oOpportunityLineItem.Id).Onsale_Date__c)))+Integer.valueOf(mapOpportunityLineItem.get(oOpportunityLineItem.Id).Quantity)<=1) {
                                    
                                }
                                else {
                                    //mapOpportunityLineItem.get(oOpportunityLineItem.Id).addError('Insufficient stock of products');
                                    mapOpportunityLineItemError.put(oOpportunityLineItem.Id, oOpportunityLineItem);
                                }
                            }
                            else {
                                
                            }
                        }
                        else {
                            //mapOpportunityLineItem.get(oOpportunityLineItem.Id).addError('Insufficient stock of products');
                            mapOpportunityLineItemError.put(oOpportunityLineItem.Id, oOpportunityLineItem);
                        }
                    }
                
                    //Compare the stock with the quantity entered - Products Social
                    if(mapProductsSocial.containsKey(oOpportunityLineItem.Product2Id)) {
                        if(mapOpportunityLineItem.containsKey(oOpportunityLineItem.Id)) {
                            Integer stock=2;
                            if(mapInventoryQuantity.containsKey(oOpportunityLineItem.Product2Id+'-One-Time Change-'+mapOpportunityLineItem.get(oOpportunityLineItem.Id).Onsale_Date__c)) {
                                stock=Integer.valueOf(mapInventoryQuantity.get(oOpportunityLineItem.Product2Id+'-One-Time Change-'+mapOpportunityLineItem.get(oOpportunityLineItem.Id).Onsale_Date__c).Quantity__c);
                            }
                            else {
                                if(mapInventoryQuantity.containsKey(oOpportunityLineItem.Product2Id+'-Daily-null')) {
                                    stock=Integer.valueOf(mapInventoryQuantity.get(oOpportunityLineItem.Product2Id+'-Daily-null').Quantity__c);
                                }
                            }
                            if(mapSoldQuantityDigitalProductSocial.containsKey(mapProductsSocial.get(oOpportunityLineItem.Product2Id).Name+'-Daily-'+mapOpportunityLineItem.get(oOpportunityLineItem.Id).Onsale_Date__c)) {
                                if(Integer.valueOf(mapSoldQuantityDigitalProductSocial.get(mapProductsSocial.get(oOpportunityLineItem.Product2Id).Name+'-'+'Daily'+'-'+mapOpportunityLineItem.get(oOpportunityLineItem.Id).Onsale_Date__c))+Integer.valueOf(mapOpportunityLineItem.get(oOpportunityLineItem.Id).Quantity)<=stock) {
                                    
                                }
                                else {
                                    //mapOpportunityLineItem.get(oOpportunityLineItem.Id).addError('Insufficient stock of products');
                                    mapOpportunityLineItemError.put(oOpportunityLineItem.Id, oOpportunityLineItem);
                                }
                            }
                            else {
                                if(oOpportunityLineItem.Quantity<=stock) {
                                    
                                }
                                else {
                                    //mapOpportunityLineItem.get(oOpportunityLineItem.Id).addError('Insufficient stock of products');
                                    mapOpportunityLineItemError.put(oOpportunityLineItem.Id, oOpportunityLineItem);
                                }
                            }
                        }
                    }
                    
                    //Compare the stock with the quantity entered - Products Impression
                    if(mapDigitalProductImpressions.containsKey(oOpportunityLineItem.Product2Id)) {
                        Integer stock=0;
                        if(mapInventoryQuantity.containsKey(oOpportunityLineItem.Product2Id+'-One-Time Change-'+oOpportunityLineItem.Opportunity.Digital_Start_Date__c.year()+oOpportunityLineItem.Opportunity.Digital_Start_Date__c.month())) {
                            stock=Integer.valueOf(mapInventoryQuantity.get(oOpportunityLineItem.Product2Id+'-One-Time Change-'+oOpportunityLineItem.Opportunity.Digital_Start_Date__c.year()+oOpportunityLineItem.Opportunity.Digital_Start_Date__c.month()).Impressions__c);
                        }
                        else {
                            if(mapInventoryQuantity.containsKey(oOpportunityLineItem.Product2Id+'-Monthly-null')) {
                                stock=Integer.valueOf(mapInventoryQuantity.get(oOpportunityLineItem.Product2Id+'-Monthly-null').Impressions__c);
                            }
                        }
                        if(Integer.valueOf(mapOpportunityLineItem.get(oOpportunityLineItem.Id).Impression__c)<=stock) {
                            for(String key : mapAllOpportunityProducts.keySet()) {
                                if(mapAllOpportunityProducts.get(key).Product2Id==oOpportunityLineItem.Product2Id && mapAllOpportunityProducts.get(key).OpportunityId!=oOpportunityLineItem.OpportunityId) {
                                    if(oOpportunityLineItem.Opportunity.Digital_Start_Date__c>mapAllOpportunityProducts.get(key).Opportunity.Digital_End_Date__c || oOpportunityLineItem.Opportunity.Digital_End_Date__c<mapAllOpportunityProducts.get(key).Opportunity.Digital_Start_Date__c) {
                                        /*Integer stock=0;
                                        if(mapInventoryQuantity.containsKey(oOpportunityLineItem.Product2Id+'-One-Time Change-'+oOpportunityLineItem.Opportunity.Digital_Start_Date__c.year()+oOpportunityLineItem.Opportunity.Digital_Start_Date__c.month())) {
                                            stock=Integer.valueOf(mapInventoryQuantity.get(oOpportunityLineItem.Product2Id+'-One-Time Change-'+oOpportunityLineItem.Opportunity.Digital_Start_Date__c.year()+oOpportunityLineItem.Opportunity.Digital_Start_Date__c.month()).Impressions__c);
                                        }
                                        else {
                                            if(mapInventoryQuantity.containsKey(oOpportunityLineItem.Product2Id+'-Monthly-null')) {
                                                stock=Integer.valueOf(mapInventoryQuantity.get(oOpportunityLineItem.Product2Id+'-Monthly-null').Impressions__c);
                                            }
                                        }*/
                                        if(mapSoldQuantityDigitalProductImpressions.containsKey(mapDigitalProductImpressions.get(oOpportunityLineItem.Product2Id).Name+'-'+'Monthly'+'-'+String.valueOf(oOpportunityLineItem.Opportunity.Digital_Start_Date__c.year())+String.valueOf(oOpportunityLineItem.Opportunity.Digital_Start_Date__c.month()))) {
                                            if(Integer.valueOf((Integer.valueOf(mapSoldQuantityDigitalProductImpressions.get(mapDigitalProductImpressions.get(oOpportunityLineItem.Product2Id).Name+'-'+'Monthly'+'-'+String.valueOf(oOpportunityLineItem.Opportunity.Digital_Start_Date__c.year())+String.valueOf(oOpportunityLineItem.Opportunity.Digital_Start_Date__c.month())))))+Integer.valueOf(mapOpportunityLineItem.get(oOpportunityLineItem.Id).Impression__c)<=stock) {
                                                
                                            }
                                            else {
                                                //mapOpportunityLineItem.get(oOpportunityLineItem.Id).addError('Insufficient stock of products');
                                                mapOpportunityLineItemError.put(oOpportunityLineItem.Id, oOpportunityLineItem);
                                            }
                                        }
                                        else {
                                            if(Integer.valueOf(mapOpportunityLineItem.get(oOpportunityLineItem.Id).Impression__c)<=stock) {
                                                
                                            }
                                            else {
                                                //mapOpportunityLineItem.get(oOpportunityLineItem.Id).addError('Insufficient stock of products');
                                                mapOpportunityLineItemError.put(oOpportunityLineItem.Id, oOpportunityLineItem);
                                            }
                                        }
                                    }
                                    else {
                                        //mapOpportunityLineItem.get(oOpportunityLineItem.Id).addError('Insufficient stock of products');
                                        mapOpportunityLineItemError.put(oOpportunityLineItem.Id, oOpportunityLineItem);
                                    }
                                }
                            }
                        }
                        else {
                            //mapOpportunityLineItem.get(oOpportunityLineItem.Id).addError('Insufficient stock of products');
                            mapOpportunityLineItemError.put(oOpportunityLineItem.Id, oOpportunityLineItem);
                        }
                    }
                //}
            }
        }
        return mapOpportunityLineItemError;
    }
    
    public Map<Id, Opportunity> CheckOpportunity(Map<Id, Opportunity> mapNewOpportunity, Map<Id, Opportunity> mapOldOpportunity, Set<Id> setOpportunityId) {
        Set<Id> setOpportunityLineItemProductId = new Set<Id>();
        Map<Id, Opportunity> mapOpportunityError = new Map<Id, Opportunity>();
        
    	List<OpportunityLineItem> ltsOpportunityLineItem = new List<OpportunityLineItem>();
        for(OpportunityLineItem oAllOpportunityLineItem : [SELECT Id, Product2Id, Product2.Name, Onsale_Date__c, Quantity, Impression__c, OpportunityId, Opportunity.Digital_End_Date__c, Opportunity.Digital_Start_Date__c FROM OpportunityLineItem WHERE OpportunityId IN :setOpportunityId AND OpportunityLineItem.Product2.Family='Digital' AND OpportunityLineItem.Opportunity.RecordType.Name='DC Deals']) {
            ltsOpportunityLineItem.add(oAllOpportunityLineItem);
            setOpportunityLineItemProductId.add(oAllOpportunityLineItem.Product2Id); 
        }
        
        if(ltsOpportunityLineItem.size()>0) {
            // Create a Set from Product Names to Family Digital
            Set<String> setDigitalProductImpressionsName = new Set<String>();
            Set<String> setDigitalProductSocialName = new Set<String>();
            Set<String> setDigitalProductWebName = new Set<String>();
            
            setDigitalProductImpressionsName.add('DCComics.com Leaderboard (728x90)');
            setDigitalProductImpressionsName.add('DCComics.com Medium Rectangle (300x250)');
            setDigitalProductImpressionsName.add('MadMagazine.con Leaderboard (728x90)');
            setDigitalProductImpressionsName.add('MadMagazine.con Medium Rectangle (300x250)');
            setDigitalProductImpressionsName.add('Vertigocomincs.com Leaderboard (728x90)');
            setDigitalProductImpressionsName.add('Vertigocomincs.com Medium Rectangle (300x250)');
            
            setDigitalProductSocialName.add('Facebook-Aquaman');
            setDigitalProductSocialName.add('Facebook-Batman');
            setDigitalProductSocialName.add('Facebook-DC Comics');
            setDigitalProductSocialName.add('Facebook-Green Arrow');
            setDigitalProductSocialName.add('Facebook-Green Lantern');
            setDigitalProductSocialName.add('Facebook-Harley Quinn');
            setDigitalProductSocialName.add('Facebook-Superman');
            setDigitalProductSocialName.add('Facebook-The Flash');
            setDigitalProductSocialName.add('Facebook-Vertigo');
            setDigitalProductSocialName.add('Facebook-Wonder Woman');
            setDigitalProductSocialName.add('Google+ - DC Entertainment');
            setDigitalProductSocialName.add('Instagram-DC Comics');
            setDigitalProductSocialName.add('Twitter-DC Comics');
            setDigitalProductSocialName.add('Twitter-My DC Deals');
            setDigitalProductSocialName.add('Snapchat');
            setDigitalProductSocialName.add('All Access');
            
            setDigitalProductWebName.add('Site Wide Takeovers');
            setDigitalProductWebName.add('Homepage Roadblocks');
            
            // Create a Map from Product to Family Digital
            Map<Id, Product2> mapDigitalProductImpressions = new Map<Id, Product2>();
            Map<Id, Product2> mapProductsSocial = new Map<Id, Product2>();
            Map<Id, Product2> mapProductsWeb = new Map<Id, Product2>();
            
            // Fill the Map from Product to Family Digital
            for(Product2 oProduct : [SELECT Id, Name FROM Product2 WHERE Name IN :setDigitalProductImpressionsName OR Name IN :setDigitalProductSocialName OR Name IN :setDigitalProductWebName]) {
                if(setDigitalProductImpressionsName.contains(oProduct.Name)) {
                    mapDigitalProductImpressions.put(oProduct.Id, oProduct);
                }
                if(setDigitalProductSocialName.contains(oProduct.Name)) {
                    mapProductsSocial.put(oProduct.Id, oProduct);
                }
                if(setDigitalProductWebName.contains(oProduct.Name)) {
                    mapProductsWeb.put(oProduct.Id, oProduct);
                    setOpportunityLineItemProductId.add(oProduct.Id); // Id of productos web
                }
            }
            
            // Create a Map from Inventory to Products with Family Digital
            Map<String, Inventory__c> mapInventoryQuantity = new Map<String, Inventory__c>();
            for(Inventory__c oInventory : [SELECT Id, Product__c, Product_Family__c, Quantity__c, Impressions__c, Availability_Date__c, Onsale_Availability__c FROM Inventory__c WHERE Product__c IN :setOpportunityLineItemProductId AND Product_Family__c='Digital']) {
                if(mapDigitalProductImpressions.containsKey(oInventory.Product__c)) { // If the products is Impressions considered only year and month for key map
                    if(oInventory.Availability_Date__c!=null) {
                        mapInventoryQuantity.put(oInventory.Product__c+'-'+oInventory.Onsale_Availability__c+'-'+oInventory.Availability_Date__c.year()+oInventory.Availability_Date__c.month(), oInventory);
                    }
                    else {
                        mapInventoryQuantity.put(oInventory.Product__c+'-'+oInventory.Onsale_Availability__c+'-'+oInventory.Availability_Date__c, oInventory);
                    }
                }
                else {
                    mapInventoryQuantity.put(oInventory.Product__c+'-'+oInventory.Onsale_Availability__c+'-'+oInventory.Availability_Date__c, oInventory);
                }
            }
            
            // Create a Map from quantity to products sold with Family Digital
            Map<String, Decimal> mapSoldQuantityDigitalProductImpressions = new Map<String, Decimal>();
            Map<String, Decimal> mapSoldQuantityDigitalProductSocial = new Map<String, Decimal>();
            Map<String, Decimal> mapSoldQuantityDigitalProductWeb = new Map<String, Decimal>();
            
            // Create a Map from Opportunity
            Map<Id, Opportunity> mapAllOpportunity = new Map<Id, Opportunity>();
            for(Opportunity oAllOpportunity : [SELECT Id, Name, Digital_End_Date__c, Digital_Start_Date__c FROM Opportunity WHERE Id IN :setOpportunityId]) {
                mapAllOpportunity.put(oAllOpportunity.Id, oAllOpportunity);
            }
            
            // Create a Map from Opportunity Products
            Map<String, OpportunityLineItem> mapAllOpportunityProducts = new Map<String, OpportunityLineItem>();
            
            // Calculate sum the products sold
            for(OpportunityLineItem oAllOpportunityLineItem : [SELECT Id, Product2Id, Product2.Name, Onsale_Date__c, Quantity, Impression__c, OpportunityId, OpportunityLineItem.Opportunity.Digital_End_Date__c, OpportunityLineItem.Opportunity.Digital_Start_Date__c FROM OpportunityLineItem WHERE Product2Id IN :setOpportunityLineItemProductId AND OpportunityLineItem.Product2.Family='Digital' AND (OpportunityLineItem.Opportunity.StageName='Confirmed' OR OpportunityLineItem.Opportunity.StageName='Verbal')]) {
                mapAllOpportunityProducts.put(oAllOpportunityLineItem.Product2Id+'-'+oAllOpportunityLineItem.OpportunityId, oAllOpportunityLineItem);
                if(setDigitalProductWebName.contains(oAllOpportunityLineItem.Product2.Name)) {
                    if(!mapAllOpportunity.containsKey(oAllOpportunityLineItem.OpportunityId)) {
                        if(mapSoldQuantityDigitalProductWeb.containsKey(String.valueOf(oAllOpportunityLineItem.Onsale_Date__c))) {
                            mapSoldQuantityDigitalProductWeb.put(String.valueOf(oAllOpportunityLineItem.Onsale_Date__c), Integer.valueOf(mapSoldQuantityDigitalProductWeb.get(String.valueOf(oAllOpportunityLineItem.Onsale_Date__c)))+Integer.valueOf(oAllOpportunityLineItem.Quantity));
                        }
                        else {
                            mapSoldQuantityDigitalProductWeb.put(String.valueOf(oAllOpportunityLineItem.Onsale_Date__c), oAllOpportunityLineItem.Quantity);
                        }
                    }
                }
                if(setDigitalProductSocialName.contains(oAllOpportunityLineItem.Product2.Name)) {
                    if(!mapAllOpportunity.containsKey(oAllOpportunityLineItem.OpportunityId)) {
                        if(mapSoldQuantityDigitalProductSocial.containsKey(oAllOpportunityLineItem.Product2.Name+'-'+'Daily'+'-'+oAllOpportunityLineItem.Onsale_Date__c)) {
                            Integer quantity = Integer.valueOf(mapSoldQuantityDigitalProductSocial.get(oAllOpportunityLineItem.Product2.Name+'-'+'Daily'+'-'+oAllOpportunityLineItem.Onsale_Date__c));
                            mapSoldQuantityDigitalProductSocial.put(oAllOpportunityLineItem.Product2.Name+'-'+'Daily'+'-'+oAllOpportunityLineItem.Onsale_Date__c, quantity + Integer.valueOf(oAllOpportunityLineItem.Quantity));
                        }
                        else {
                            mapSoldQuantityDigitalProductSocial.put(oAllOpportunityLineItem.Product2.Name+'-'+'Daily'+'-'+oAllOpportunityLineItem.Onsale_Date__c, oAllOpportunityLineItem.Quantity);
                        }
                    }
                }
                if(setDigitalProductImpressionsName.contains(oAllOpportunityLineItem.Product2.Name)) {
                    if(oAllOpportunityLineItem.Opportunity.Digital_Start_Date__c!=null && oAllOpportunityLineItem.Opportunity.Digital_End_Date__c!=null) {
                        if(mapSoldQuantityDigitalProductImpressions.containsKey(oAllOpportunityLineItem.Product2.Name+'-'+'Monthly'+'-'+String.valueOf(oAllOpportunityLineItem.Opportunity.Digital_Start_Date__c.year())+String.valueOf(oAllOpportunityLineItem.Opportunity.Digital_Start_Date__c.month()))) {
                            Integer quantity = Integer.valueOf(mapSoldQuantityDigitalProductImpressions.get(oAllOpportunityLineItem.Product2.Name+'-'+'Monthly'+'-'+String.valueOf(oAllOpportunityLineItem.Opportunity.Digital_Start_Date__c.year())+String.valueOf(oAllOpportunityLineItem.Opportunity.Digital_Start_Date__c.month())))+Integer.valueOf(oAllOpportunityLineItem.Impression__c);
                            mapSoldQuantityDigitalProductImpressions.put(oAllOpportunityLineItem.Product2.Name+'-'+'Monthly'+'-'+String.valueOf(oAllOpportunityLineItem.Opportunity.Digital_Start_Date__c.year())+String.valueOf(oAllOpportunityLineItem.Opportunity.Digital_Start_Date__c.month()), quantity);
                        }
                        else {
                            mapSoldQuantityDigitalProductImpressions.put(oAllOpportunityLineItem.Product2.Name+'-'+'Monthly'+'-'+String.valueOf(oAllOpportunityLineItem.Opportunity.Digital_Start_Date__c.year())+String.valueOf(oAllOpportunityLineItem.Opportunity.Digital_Start_Date__c.month()), Integer.valueOf(oAllOpportunityLineItem.Impression__c));
                        }
                    }
                }
            }
            
            for(OpportunityLineItem oOpportunityLineItem : ltsOpportunityLineItem){ 
                if(mapAllOpportunity.containsKey(oOpportunityLineItem.OpportunityId)) {
                    //Compare the stock with the quantity entered - Products Web
                    if(mapProductsWeb.containsKey(oOpportunityLineItem.Product2Id)) {
                        if(oOpportunityLineItem.Quantity<=1) {
                            if(mapSoldQuantityDigitalProductWeb.containsKey(String.valueOf(oOpportunityLineItem.Onsale_Date__c))) {
                                if(Integer.valueOf(mapSoldQuantityDigitalProductWeb.get(String.valueOf(oOpportunityLineItem.Onsale_Date__c)))+Integer.valueOf(oOpportunityLineItem.Quantity)<=1) {
                                    
                                }
                                else {
                                    //mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).addError('Insufficient stock of products');
                                    mapOpportunityError.put(mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).Id, mapNewOpportunity.get(oOpportunityLineItem.OpportunityId));
                                }
                            }
                            else {
                                
                            }
                        }
                        else {
                            //mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).addError('Insufficient stock of products');
                            mapOpportunityError.put(mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).Id, mapNewOpportunity.get(oOpportunityLineItem.OpportunityId));
                        }
                    }
                    //Compare the stock with the quantity entered - Products Social
                    if(mapProductsSocial.containsKey(oOpportunityLineItem.Product2Id)) {
                        Integer stock=2;
                        if(mapInventoryQuantity.containsKey(oOpportunityLineItem.Product2Id+'-One-Time Change-'+oOpportunityLineItem.Onsale_Date__c)) {
                            stock=Integer.valueOf(mapInventoryQuantity.get(oOpportunityLineItem.Product2Id+'-One-Time Change-'+oOpportunityLineItem.Onsale_Date__c).Quantity__c);
                        }
                        else {
                            if(mapInventoryQuantity.containsKey(oOpportunityLineItem.Product2Id+'-Daily-null')) {
                                stock=Integer.valueOf(mapInventoryQuantity.get(oOpportunityLineItem.Product2Id+'-Daily-null').Quantity__c);
                            }
                        }
                        if(mapSoldQuantityDigitalProductSocial.containsKey(mapProductsSocial.get(oOpportunityLineItem.Product2Id).Name+'-Daily-'+oOpportunityLineItem.Onsale_Date__c)) {
                            if(Integer.valueOf(mapSoldQuantityDigitalProductSocial.get(mapProductsSocial.get(oOpportunityLineItem.Product2Id).Name+'-'+'Daily'+'-'+oOpportunityLineItem.Onsale_Date__c))+Integer.valueOf(oOpportunityLineItem.Quantity)<=stock) {
                                    
                            }
                            else {
                                //mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).addError('Insufficient stock of products');
                                mapOpportunityError.put(mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).Id, mapNewOpportunity.get(oOpportunityLineItem.OpportunityId));
                            }
                        }
                        else {
                            if(oOpportunityLineItem.Quantity<=stock) {
                                
                            }
                            else {
                                //mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).addError('Insufficient stock of products');
                                mapOpportunityError.put(mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).Id, mapNewOpportunity.get(oOpportunityLineItem.OpportunityId));
                            }
                        }
                    }
                    //Compare the stock with the quantity entered - Products Impression
                    if(mapDigitalProductImpressions.containsKey(oOpportunityLineItem.Product2Id)) {
                        Integer stock=0;
                        if(mapInventoryQuantity.containsKey(oOpportunityLineItem.Product2Id+'-One-Time Change-'+mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).Digital_Start_Date__c.year()+mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).Digital_Start_Date__c.month())) {
                            stock=Integer.valueOf(mapInventoryQuantity.get(oOpportunityLineItem.Product2Id+'-One-Time Change-'+mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).Digital_Start_Date__c.year()+mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).Digital_Start_Date__c.month()).Impressions__c);
                        }
                        else {
                            if(mapInventoryQuantity.containsKey(oOpportunityLineItem.Product2Id+'-Monthly-null')) {
                                stock=Integer.valueOf(mapInventoryQuantity.get(oOpportunityLineItem.Product2Id+'-Monthly-null').Impressions__c);
                            }
                        }
                        if(Integer.valueOf(oOpportunityLineItem.Impression__c)<=stock) {
                            for(String key : mapAllOpportunityProducts.keySet()) {
                                if(mapAllOpportunityProducts.get(key).Product2Id==oOpportunityLineItem.Product2Id && mapAllOpportunityProducts.get(key).OpportunityId!=oOpportunityLineItem.OpportunityId) {
                                    if(mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).Digital_Start_Date__c>mapAllOpportunityProducts.get(key).Opportunity.Digital_End_Date__c || mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).Digital_End_Date__c<mapAllOpportunityProducts.get(key).Opportunity.Digital_Start_Date__c) {
                                        /*Integer stock=0;
                                        if(mapInventoryQuantity.containsKey(oOpportunityLineItem.Product2Id+'-One-Time Change-'+mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).Digital_Start_Date__c.year()+mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).Digital_Start_Date__c.month())) {
                                            stock=Integer.valueOf(mapInventoryQuantity.get(oOpportunityLineItem.Product2Id+'-One-Time Change-'+mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).Digital_Start_Date__c.year()+mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).Digital_Start_Date__c.month()).Impressions__c);
                                        }
                                        else {
                                            if(mapInventoryQuantity.containsKey(oOpportunityLineItem.Product2Id+'-Monthly-null')) {
                                                stock=Integer.valueOf(mapInventoryQuantity.get(oOpportunityLineItem.Product2Id+'-Monthly-null').Impressions__c);
                                            }
                                        }*/
                                        if(mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).StageName==mapOldOpportunity.get(oOpportunityLineItem.OpportunityId).StageName) {
                                            oOpportunityLineItem.Impression__c=0;
                                        }
                                        if(mapSoldQuantityDigitalProductImpressions.containsKey(mapDigitalProductImpressions.get(oOpportunityLineItem.Product2Id).Name+'-'+'Monthly'+'-'+String.valueOf(mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).Digital_Start_Date__c.year())+String.valueOf(mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).Digital_Start_Date__c.month()))) {
                                            if(Integer.valueOf((Integer.valueOf(mapSoldQuantityDigitalProductImpressions.get(mapDigitalProductImpressions.get(oOpportunityLineItem.Product2Id).Name+'-'+'Monthly'+'-'+String.valueOf(mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).Digital_Start_Date__c.year())+String.valueOf(mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).Digital_Start_Date__c.month())))))+Integer.valueOf(oOpportunityLineItem.Impression__c)<=stock) {
                                                
                                            }
                                            else {
                                                //mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).addError('Insufficient stock of products');
                                                mapOpportunityError.put(mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).Id, mapNewOpportunity.get(oOpportunityLineItem.OpportunityId));
                                            }
                                        }
                                        else {
                                            if(Integer.valueOf(oOpportunityLineItem.Impression__c)<=stock) {
                                                
                                            }
                                            else {
                                                //mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).addError('Insufficient stock of products');
                                                mapOpportunityError.put(mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).Id, mapNewOpportunity.get(oOpportunityLineItem.OpportunityId));
                                            }
                                        }
                                    }
                                    else {
                                        //mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).addError('Insufficient stock of products');
                                        mapOpportunityError.put(mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).Id, mapNewOpportunity.get(oOpportunityLineItem.OpportunityId));
                                    }
                                }
                            }
                        }
                        else {
                            //mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).addError('Insufficient stock of products');
                            mapOpportunityError.put(mapNewOpportunity.get(oOpportunityLineItem.OpportunityId).Id, mapNewOpportunity.get(oOpportunityLineItem.OpportunityId));
                        }
                    }
                }
            }
        }
    	return mapOpportunityError;
    }
}