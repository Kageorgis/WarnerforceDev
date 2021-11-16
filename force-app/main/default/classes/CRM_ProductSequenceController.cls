public with sharing class CRM_ProductSequenceController {
    
    public static void executeBeforeInsert(List<Product2> lstNewProducts) 
    {
        CRM_ProductHandler.updateProdctType(null, lstNewProducts);
        
        //US# 304
        //If there are few Products to insert/update, Product Group logic will be updated through trigger, 
        //else for bulk Product upload we will process Product Group logic using Batch job,
        //for that we are making Process_Product_Group__c = true.  
        boolean triggerOnOffFlag = CRM_Trigger_Switches_For_ON_OFF__c.getInstance('CRM_UpdateProductGroupOnProductBatch') != null ? CRM_Trigger_Switches_For_ON_OFF__c.getInstance('CRM_UpdateProductGroupOnProductBatch').IsActive__c : true;
        if (triggerOnOffFlag) {
            // for few Product load
        CRM_ProductHandler.updateProductGroupOnProduct(lstNewProducts);
        }// for bulk Product load
        else{
            for(Product2 prod:lstNewProducts){
                if(!prod.Process_Product_Group__c)
                    prod.Process_Product_Group__c = true;
            }
        }
    }
        
    public static void executeBeforeUpdate(Map<Id,Product2> mapOldProducts, List<Product2> lstNewProducts) {
        CRM_ProductHandler.updateProdctType(mapOldProducts, lstNewProducts);
        
        //Req. #393 (FR): Update Product Material Type if there is a associated BOM. 
        CRM_ProductHandler.updateProdctMaterialType(mapOldProducts, lstNewProducts);
        //US# 304(UK) and US# 478(FR)
        List<Product2> lstProduct = new List<Product2>();
        boolean triggerOnOffFlag = CRM_Trigger_Switches_For_ON_OFF__c.getInstance('CRM_UpdateProductGroupOnProductBatch') != null ? CRM_Trigger_Switches_For_ON_OFF__c.getInstance('CRM_UpdateProductGroupOnProductBatch').IsActive__c : true;
        // for few Product load
        if (triggerOnOffFlag) {
        for(Product2 prod:lstNewProducts){
            if((mapOldProducts.get(prod.Id).Product_Format__c!= prod.Product_Format__c)
            ||(mapOldProducts.get(prod.Id).Franchise_Type__c != prod.Franchise_Type__c)
            ||(mapOldProducts.get(prod.Id).Local_Title__c!= prod.Local_Title__c)
            ||(mapOldProducts.get(prod.Id).Type__c!= prod.Type__c)
            ||(mapOldProducts.get(prod.Id).Product_Genre__c!= prod.Product_Genre__c)
            ||(mapOldProducts.get(prod.Id).Product_Label__c!= prod.Product_Label__c)
            ||(mapOldProducts.get(prod.Id).Product_owner__c!= prod.Product_owner__c)        //--W-017601 Added sales org to create key for JV project--//
            ||(mapOldProducts.get(prod.Id).Product_Market_Entry__c!= prod.Product_Market_Entry__c)        //--W-017601 Added sales org to create key for JV project--//
            ||(mapOldProducts.get(prod.Id).Product_Market__c!= prod.Product_Market__c)
            ||(mapOldProducts.get(prod.Id).Special_Version__c!=prod.Special_Version__c && prod.Country_Code__c == CRM_AppConstants.FRANCE_COUNTRY_CODE)
            ||(mapOldProducts.get(prod.Id).Product_Price_Group__c!=prod.Product_Price_Group__c && prod.Country_Code__c == CRM_AppConstants.JAPAN_COUNTRY_CODE)
            ||(mapOldProducts.get(prod.Id).SAP_Sales_Org__c!=prod.SAP_Sales_Org__c)        //--W-017601 Added sales org to create key for JV project--//
        ){
                    lstProduct.add(prod);
                 }
            }
            if(!lstProduct.isEmpty())
                CRM_ProductHandler.updateProductGroupOnProduct(lstProduct);
        }// for bulk Product load
        else{
            for(Product2 prod:lstNewProducts){
                if((mapOldProducts.get(prod.Id).Product_Format__c!= prod.Product_Format__c)
                ||(mapOldProducts.get(prod.Id).Franchise_Type__c != prod.Franchise_Type__c)
                ||(mapOldProducts.get(prod.Id).Local_Title__c!= prod.Local_Title__c)
                ||(mapOldProducts.get(prod.Id).Type__c!= prod.Type__c)
                ||(mapOldProducts.get(prod.Id).Product_Genre__c!= prod.Product_Genre__c)
                ||(mapOldProducts.get(prod.Id).Product_Label__c!= prod.Product_Label__c)
                ||(mapOldProducts.get(prod.Id).Product_owner__c!= prod.Product_owner__c)        //--W-017601 Added sales org to create key for JV project--//
                ||(mapOldProducts.get(prod.Id).Product_Market_Entry__c!= prod.Product_Market_Entry__c)        //--W-017601 Added sales org to create key for JV project--//
                ||(mapOldProducts.get(prod.Id).Product_Market__c!= prod.Product_Market__c)
                ||(mapOldProducts.get(prod.Id).Special_Version__c!=prod.Special_Version__c && prod.Country_Code__c == CRM_AppConstants.FRANCE_COUNTRY_CODE)
                ||(mapOldProducts.get(prod.Id).Product_Price_Group__c!=prod.Product_Price_Group__c && prod.Country_Code__c == CRM_AppConstants.JAPAN_COUNTRY_CODE)
                ||(mapOldProducts.get(prod.Id).SAP_Sales_Org__c!=prod.SAP_Sales_Org__c)        //--W-017601 Added sales org to create key for JV project--//
                ){
                    if(!prod.Process_Product_Group__c)    
                        prod.Process_Product_Group__c = true;
                 }
             }
        }
        
        //JAPAN - US : 480
        CRM_ProductHandler.restrictToModifyProductMarket(mapOldProducts, lstNewProducts);
    }
    
    
    public static void executeAfterInsert(Map<Id,Product2> mapOldProducts,List<Product2> lstNewProducts) {
        //US 450 Defect #3438 TO create pbep for unbw or sbom product.
        CRM_Trigger_Switches_For_ON_OFF__c objCustomSettingTriggerSwitch = CRM_Trigger_Switches_For_ON_OFF__c.getInstance('CRM_Product_PBEP_UNBW');       
        if (objCustomSettingTriggerSwitch != null && objCustomSettingTriggerSwitch.IsActive__c && !CRM_ProductHandler.isFuture) {
            CRM_ProductHandler.insertPBEP(mapOldProducts,lstNewProducts); 
        }
    }
    
    public static void executeAfterUpdate(Map<Id,Product2> mapOldProducts,List<Product2> lstNewProducts) {
        
        // Recalculate schedules for Products whose street Date is changed
        /*CRM_AutoEstablishSchedulesHelper genProductCurveInstance = new CRM_AutoEstablishSchedulesHelper();
        genProductCurveInstance.recalculateDealProductSchedule(mapOldProducts,lstNewProducts);*/
        //defect#3676 : To delete Products when removed when delete_product__c is set to true by informatica. 
        //CRM_ProductHandler.deleteProducts(mapOldProducts,lstNewProducts);
        
        // US 450 to create pbep for unbw or sbom product.
        CRM_Trigger_Switches_For_ON_OFF__c objCustomSettingTriggerSwitch = CRM_Trigger_Switches_For_ON_OFF__c.getInstance('CRM_Product_PBEP_UNBW');       
        if (objCustomSettingTriggerSwitch != null && objCustomSettingTriggerSwitch.IsActive__c && !CRM_ProductHandler.isFuture) {
            CRM_ProductHandler.insertPBEP(mapOldProducts,lstNewProducts); 
        }
    } 
}