/**
   @Author Cognizant
   @name CRM_BOMTriggerSequenceController
   @CreateDate 18 June 2016
   @Description - class to manage the sequence for various DML events on BOM__c object
   @Version <1.0>
*/

public with sharing class CRM_BOMTriggerSequenceController {
    public static void executeAfterInsert(Map<Id,BOM__c> mapNewBOMs) {
        //if BOM record inserted, insert Config Product record under related Config object
        //CRM_BOMConfigProductHandler.insertConfigProducts(mapNewBOMs);
        
        //Req. #393 (FR)
        //If BOM record is inserted with a Parent Product, update Parent Product Material Type to SBOM
        CRM_BOMConfigProductHandler.updateProductMaterialType(mapNewBOMs);
    }
    
    public static void executeAfterUpdate(Map<Id,BOM__c> mapNewBOMs,Map<Id,BOM__c> mapOldBOMs){
        //Defect : 3686
        // If BOM record Quantity updated, update its related SBOM config Product Quantity 
        CRM_BOMConfigProductHandler.updateSBOMConfigProductQuantity(mapNewBOMs,mapOldBOMs);
        CRM_BOMConfigProductHandler.deleteBOMs(mapOldBOMs,mapNewBOMs.values());
    }
    
    public static void executeBeforeDelete(Map<Id,BOM__c> mapOldBOMs) {
        //if BOM record deleted, delete all the related config product rec
        //CRM_BOMConfigProductHandler.deleteConfigProducts(mapOldBOMs);
    }
}