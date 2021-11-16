public with sharing class CRM_AssortmentApprovalEmailTemplateCtrl{
    
    //Assortment record 
    public Bundle__c assortment{ get; set; }
    
    //Get AccountDealCode Map (Key ==> Assortment Account Id , Value ==> Deal Code)
    public Map<Id,String> getAccountDealCodeMap(){
        
        //AccountDealCode Map (Key ==> Assortment Account Id , Value ==> Deal Code)
        Map<Id,String> accountDealCodeMap = new Map<Id,String>();
        
        if(assortment != null){
        
            String assortId = assortment.Id;
            
            //Fill accountDealCodeMap Map
            for(Opportunity deal : [SELECT Id,Deal_Code__c,Assortment_Account__c 
                                   FROM Opportunity 
                                   Where Bundle__c =: assortId]){
                                 
                if(deal.Deal_Code__c != null && deal.Assortment_Account__c != null){
                    accountDealCodeMap.put(deal.Assortment_Account__c ,deal.Deal_Code__c);
                }                   
            }
            
            //Fill remaining Assortment Account Ids into accountDealCodeMap 
            if(assortment.Assortment_Accounts__r != null && assortment.Assortment_Accounts__r.size() > 0){
                for(Assortment_Account__c assAcc : assortment.Assortment_Accounts__r){
                    if(!accountDealCodeMap.containsKey(assAcc.Id)){
                        accountDealCodeMap.put(assAcc.Id,'');
                    }
                }
            }
        }
        system.debug('******accountDealCodeMap'+accountDealCodeMap);
        return accountDealCodeMap;
    }
    
    //Get Assortment Products
    public List<Bundle_Product__c> getAssortmentProducts(){
        List<Bundle_Product__c> lstAssortmentProducts = new List<Bundle_Product__c>();
        
        if(assortment != null){
            String assortId = assortment.Id;
            lstAssortmentProducts = [Select Id, Product_Code__c, Product__r.Name From Bundle_Product__c Where Bundle__c =: assortId AND SAP_Material_Type__c = 'UNBW'];
        }
        
        System.debug('#lstAssortmentProducts' + lstAssortmentProducts);
        return lstAssortmentProducts;
    }
}