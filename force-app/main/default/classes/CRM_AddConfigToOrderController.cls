/**
   @Author Cognizant
   @name CRM_AddConfigToOrderController
   @CreateDate 12 July 2016
   @Description visualforce controller to add one or more confis to an order
   @Version <1.0>
*/
global with sharing class CRM_AddConfigToOrderController {
    
    /* Default constructor with standardcontroller */
    public CRM_AddConfigToOrderController(ApexPages.StandardController stdCon){
    }
    /**
     * Method to fetch CRM_Max_Product_Limit__c to fetch Product limit
     */
    global Integer getMaxConfigLimit() {
        return CRM_Max_Product_Limit__c.getInstance('Order_Configs') != null ? Integer.valueOf(CRM_Max_Product_Limit__c.getInstance('Order_Configs').Count__c) : 0;
    }
    /**
    /**
     *  @Description - Method to fetch the relevant config records for an order
     *  @name - getConfigs
     *  @param - orderId - salesforce id of the order record to be used to fetch config records
     *  @return - list of configs (where Order.Account is added as an assortment account) for the selected order
     **/
    @RemoteAction 
    public static Config__c[] getConfigs(Id orderId) {
        Config__c[] listConfigs = new Config__c[]{};
        
        Order[] orders = [select Id, AccountId from Order where Id =: orderId];
        
        // Get the List of Configs which have the account added as an assortment_account 
        if(!orders.isEmpty()) {
            Set<Id> setAssortmentIds = new Set<Id>();
            
            for(Assortment_Account__c assrtAcc : [SELECT Assortment__c from Assortment_Account__c where Account__c =: orders[0].AccountId]) {
                setAssortmentIds.add(assrtAcc.Assortment__c);
            }
            
            listConfigs = [Select Id, RecordTypeId, Name, Config_Number_Txt__c, Assortment__r.Name 
                From Config__c
                Where Assortment__r.RecordTypeId = : CRM_RecordTypeUtil.RT_ASSORTMENT_CAMPAIGN AND 
                Assortment__r.Return_Date__c >= TODAY AND RecordTypeId =: CRM_RecordTypeUtil.RT_CONFIG_VRAC AND 
                Assortment__c IN :setAssortmentIds];
        }
        return listConfigs;
    }
    
    /**
     *  @Description - Method to add config products from selected configs as order-items
     *  @name - addConfig
     *  @param - orderId - Id of the order where user selected configs are required to be added 
     *  @param - configIds - Id of Config records to be added to the order
     *  @return - none
     **/
    @RemoteAction 
    public static void addConfig(Id orderId, Id[] configIds) {
        
        Order[] orders = [Select Id, Pricebook2Id, CurrencyISOCode,createdDate,Sales_Organisation__c,RecordTypeId,
                    (select Id, PricebookEntry.Product2Id from OrderItems)
                    from Order where Id =: orderId ];
        system.debug('orders---->'+orders);
        
        try {
            OrderItem[] listExistingOrderProducts = orders[0].OrderItems;
            
            Set<Id> setCurrentProductIds = new Set<Id>();
            Set<Id> setNewProductIds = new Set<Id>();
            Set<Id> setAssortmentIds = new Set<Id>();
            
            // Get the list of existing order product ids 
            for(OrderItem orderProd : listExistingOrderProducts) {
                setCurrentProductIds.add(orderProd.PricebookEntry.Product2Id);
            }
            
            Config_Product__c[] listConfigProducts = [select Id, Product__c, Config__r.Assortment__c
                        from Config_Product__c
                        where Config__c IN: configIds and Product__c NOT IN :setCurrentProductIds];
            
            for(Config_Product__c confProd : listConfigProducts ) {
                setAssortmentIds.add(confProd.Config__r.Assortment__c);
                setNewProductIds.add(confProd.Product__c);
            }
            
            Map<String,Bundle_Product__c> mapAssortmentProducts = new Map<String,Bundle_Product__c>();
            Map<Id,PricebookEntry> mapPricebookEntries = new Map<Id,PricebookEntry>();
            
            for(Bundle_Product__c assrtProd : [select Id, Bundle__c, Product__c, List_Price__c, Assortment_Price__c 
                    from Bundle_Product__c 
                    where Bundle__c IN:setAssortmentIds and Product__c IN:setNewProductIds ]) {
                
                mapAssortmentProducts.put(assrtProd.Bundle__c+'-'+assrtProd.Product__c, assrtProd);
            }
            
            for(PricebookEntry pbe : [select Id, Product2Id,Product2.Return_End_Date__c from PricebookEntry 
                    where PriceBook2Id = :orders[0].Pricebook2Id and Product2Id IN:setNewProductIds and CurrencyISOCode =: orders[0].CurrencyISOCode ]) {
                        
                mapPricebookEntries.put(pbe.Product2Id, pbe);
            }
            
            Map<Id,OrderItem> mapProductToOrderItem = new Map<Id,OrderItem>();
            
            for(Config_Product__c confProd : listConfigProducts ) {
                if(!mapProductToOrderItem.containsKey(confProd.Product__c)) {
                    PricebookEntry pbe = mapPricebookEntries.get(confProd.Product__c);
                    Bundle_Product__c assrtProd = mapAssortmentProducts.get(confProd.Config__r.Assortment__c+'-'+confProd.Product__c);
                    system.debug('pbe : '+pbe);
                    system.debug('assrtProd : '+assrtProd);
                    if(pbe != null && assrtProd != null) {  
                        if(
                            (orders[0].Sales_Organisation__c != CRM_AppConstants.TERRITORY_FRANCE_CODE) ||
                            (
                                //Req. 570 Ability to return products only until their return end date for FR
                                orders[0].Sales_Organisation__c == CRM_AppConstants.TERRITORY_FRANCE_CODE && 
                                orders[0].RecordTypeId == CRM_RecordTypeUtil.RT_ORDER_HIGH_LEVEL_RETURN && 
                                (pbe.Product2.Return_End_Date__c == null || pbe.Product2.Return_End_Date__c >= orders[0].createdDate)
                            )
                        ){

                            OrderItem newOrderItem = new OrderItem(
                                        OrderId = orders[0].Id,
                                        PricebookEntryId = pbe.Id,
                                        Quantity = 1,
                                        UnitPrice = (assrtProd.Assortment_Price__c != null ? assrtProd.Assortment_Price__c : assrtProd.List_Price__c)
                                    );
                                    
                            mapProductToOrderItem.put(confProd.Product__c, newOrderItem);
                        }
                    }
                }
            }
            
            if(!mapProductToOrderItem.isEmpty()) {
                insert mapProductToOrderItem.values();
            }
        }
        catch(System.DmlException ex) {
            // Throw custom exception with exact DML error message
            throw new CRM_CustomException(ex.getDmlMessage(0) , ex);
        }
        catch(Exception ex) {
            throw new CRM_CustomException(ex.getMessage() , ex);
        }   
    }
}