public with sharing class CP_ProductTriggerSequenceController{
    
    public static void executeBeforeInsert(List<CP_Product__c> lstCPProducts){        
        cp_CP_ProductTriggerHandler.checkDuplicateCPProducts(lstCPProducts, null);
        cp_CP_ProductTriggerHandler.updateAutoPopValues(lstCPProducts);
    }
    
    public static void executeBeforeUpdate(List<CP_Product__c> lstCPProducts, Map<Id,CP_Product__c> oldMapCPProducts){           
        List<CP_Product__c> lstCPProdToCheckDuplicates = new List<CP_Product__c>();
        for(CP_Product__c newRec : lstCPProducts){
                CP_Product__c oldRec = oldMapCPProducts.get(newRec.Id);
                if((newRec.CP_Product_Key__c == oldRec.CP_Product_Key__c) && ((newRec.cp_Retailer_Description__c != oldRec.cp_Retailer_Description__c) || (newRec.WBCP_Country__c != oldRec.WBCP_Country__c) || (newRec.GTIN__c != oldRec.GTIN__c) || (newRec.Retailer_SKU__c != oldRec.Retailer_SKU__c) ||
                   (newRec.Sub_Category__c != oldRec.Sub_Category__c) || (newRec.Licensee__c != oldRec.Licensee__c) || (newRec.cp_Licensed_Property__c != oldRec.cp_Licensed_Property__c))){
                       lstCPProdToCheckDuplicates.add(newRec);
               }
        }
        if(!lstCPProdToCheckDuplicates.isEmpty()){
            cp_CP_ProductTriggerHandler.checkDuplicateCPProducts(lstCPProdToCheckDuplicates, oldMapCPProducts);
        }
    }
}