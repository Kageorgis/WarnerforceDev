public with sharing class CRM_AssortmentProductTgrSequenceCtrl {
    //Req - 609 : System should automatically update all assortment products when changing the checkbox on assortment
    public static void beforeInsert(Bundle_Product__c[] newProducts) {
        // Update field on Assortment Product
        CRM_AssortmentProductHandler handler = new CRM_AssortmentProductHandler();
        handler.updateFieldOnAssortmentProduct(newProducts);
    }
    public static void afterInsert(Bundle_Product__c[] newProducts) {
        createRemoveConfigProducts(newProducts);

    }

    public static void afterDelete(Bundle_Product__c[] oldProducts) {
        createRemoveConfigProducts(oldProducts);
    }

    static void createRemoveConfigProducts(Bundle_Product__c[] products){
        Set<Id> setImpactedAssortments = new Set<Id>();

        for(Bundle_Product__c assrtProd : products) {
            if(assrtProd.SAP_Material_Type__c == CRM_AppConstants.PRODUCT_MATERIAL_TYPE_FERT) {
                setImpactedAssortments.add(assrtProd.Bundle__c);
            }
        }

        if(!setImpactedAssortments.isEmpty()) {
            CRM_SyncConfigProductsHelper.syncVRACProducts(setImpactedAssortments);
        }
    }
}