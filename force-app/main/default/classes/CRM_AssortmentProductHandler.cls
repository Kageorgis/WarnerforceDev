/**
   @Author-Cognizant Technology Solutions
   @name-CRM_AssortmentProductHandler
   @CreateDate- 26 Apr 2016
   @Description-
   @Version-1.0
   @reference-None
*/
public with sharing class CRM_AssortmentProductHandler {
    /**
    *  @Description - Method to update Assortment Product before Insert/update         
    *  @name - updateFieldOnAssortmentProduct
    *  @return 
    */
    public void updateFieldOnAssortmentProduct(Bundle_Product__c[] newProducts){
        Set<Id> setAssortmentIds = new Set<Id>();
        for(Bundle_Product__c assortmentProduct : newProducts){
            setAssortmentIds.add(assortmentProduct.Bundle__c);
        }
        if(!setAssortmentIds.IsEmpty())
        {
            Map<Id, Bundle__c> mapBundle = new Map<Id, Bundle__c>([SELECT Id, Automatically_Add_Products__c FROM Bundle__c WHERE Id IN :setAssortmentIds]);

            for(Bundle_Product__c assortmentProduct : newProducts)
            {
                if(mapBundle.containsKey(assortmentProduct.Bundle__c))
                {
                     if (mapBundle.get(assortmentProduct.Bundle__c).Automatically_Add_Products__c) {
                        assortmentProduct.Automatically_Add_Product__c = true;
                     }else{
                        assortmentProduct.Automatically_Add_Product__c = false;
                     }
                }
            }
        }
    }
}