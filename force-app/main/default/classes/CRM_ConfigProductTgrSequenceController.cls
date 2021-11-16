/**
   @Author Cognizant
   @name CRM_ConfigProductTgrSequenceController
   @CreateDate 18 July 2016
   @Description class to be used as a sequence controller for various trigger operations
   @Version <1.0>
*/
public with sharing class CRM_ConfigProductTgrSequenceController {

    static Map<Id,Bundle_Product__c[]> mapAssortmentProducts = new Map<Id,Bundle_Product__c[]>();

  /* auto-actions to be performed for all after insert events on Config_Product__c record */
  public static void beforeInsert(Config_Product__c[] newConfigProducts){
      validateConfigProducts(newConfigProducts);
  }
  
  /* auto-actions to be performed for all before delete events on Config_Product__c record */
  public static void beforeDelete(Config_Product__c[] oldConfigProducts){
      validateConfigProductsBeforeDelete(oldConfigProducts);
  } 
  
  /**************** HANDLER METHODS ****************/
  static void validateConfigProducts(Config_Product__c[] newConfigProducts) {
      Set<Id> setAssortmentIDs = new Set<Id>();
      
      for(Config_Product__c cp: newConfigProducts){
          if(!mapAssortmentProducts.containsKey(cp.AssortmentId__c)) {
            setAssortmentIDs.add(cp.AssortmentId__c);
          }
      }
      
      if(!setAssortmentIDs.isEmpty()) {
          for(Bundle_Product__c assrtProd : [SELECT Product__c,Name,Bundle__c 
                FROM Bundle_Product__c 
                WHERE Bundle__c in: setAssortmentIDs and Bundle__c <> null ]) {
                
                if(!mapAssortmentProducts.containsKey(assrtProd.Bundle__c)) {
                    mapAssortmentProducts.put(assrtProd.Bundle__c, new Bundle_Product__c[]{});
                }
                mapAssortmentProducts.get(assrtProd.Bundle__c).add(assrtProd);
          }
      }
      
      
      Set<String> setAssortProductsKey = new Set<String>();
      
      for(Bundle_Product__c[] listBundleProducts: mapAssortmentProducts.values()){
          for(Bundle_Product__c bundleProd: listBundleProducts) {
            String UniqueKey = bundleProd.Bundle__c +'-'+ bundleProd.Product__c;
            setAssortProductsKey.add(UniqueKey);
          }
      }      
            
      for(Config_Product__c cp: newConfigProducts){
        String ConfigProfKey = cp.AssortmentId__c +'-'+ cp.Product__c;
        System.debug('ConfigProfKey -->'+ConfigProfKey);
        System.debug('setAssortProductsKey.size() -->'+setAssortProductsKey.size());
        if((!setAssortProductsKey.contains(ConfigProfKey))&&(cp.SAP_Material_Type__c!= CRM_AppConstants.SBOM_SAP_MATERIAL_TYPE)){
            cp.addError(System.Label.CRM_Config_Product_not_available_in_assortment);
        } 
      }
   } 
   
   //Method to prevent Config Products of type SBOM or FERT before delete,
   static void validateConfigProductsBeforeDelete(Config_Product__c[] oldConfigProducts){
      
       CRM_Functional_Permissions__c CRMFP = CRM_Functional_Permissions__c.getInstance(userinfo.getProfileId());
       
       for(Config_Product__c configProduct : oldConfigProducts){
           if(configProduct.SAP_Material_Type__c == 'FERT' || configProduct.SAP_Material_Type__c == 'SBOM'){
               if(!CRMFP.Delete_Config_Product_Permission__c)
                   configProduct.addError('You can not delete Config Products of type SBOM or FERT');
           }
       }
   }//End of Function
   
}//End of Controller