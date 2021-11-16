/**
   @Author Cognizant
   @name CRM_SyncConfigProductsHelper
   @CreateDate 8 June 2016
   @Description Helper class to create/delete Config products for a VRAC config whenever
                1. a new VRAC config is created
                2. a new assortment product (bundle product) is created for the same assortment(bundle)
   @Version <1.0>
   @reference Requirement no US#200
*/
public with sharing class CRM_SyncConfigProductsHelper {
    
    // MAP where Key -> Bundle Id | Value -> Mapof Bundle Products (Id->Product Id, Value-> Bundle Product)
    private static Map<Id,Map<Id,Bundle_Product__c>> mapAssortmentProducts = new Map<Id,Map<Id,Bundle_Product__c>>();

    // MAP where Key -> Bundle Id | Value -> Map of Configs
    private static Map<Id,Map<Id,Config__c>> mapAssortmentConfigsVRAC = new Map<Id,Map<Id,Config__c>>();
    private static Map<Id,Map<Id,Config__c>> mapAssortmentConfigsSBOM = new Map<Id,Map<Id,Config__c>>();

    // MAP where Key -> Config Id | Value -> Map (Id->ProductId, value-> Config product) of Config Products
    private static Map<Id,Map<Id,Config_Product__c>> mapConfigProducts = new Map<Id,Map<Id,Config_Product__c>>();


    /**
     *  Method
     *  @name syncSBOMConfigProducts - Base method to be called from other classes to sync (Insert/Delete) SBOM config products
     *  @param setAssortmentIds - Set of Assortment Ids where config products need to be sync-ed
     *  @return None
     */
    public static void syncSBOMConfigProducts(Config__c[] configs) {
        Set<Id> setSBOMProductIds = new Set<Id>();
        Set<Id> setConfigIds = new Set<Id>();
        Map<Id,Config__c> mapConfigError = new Map<Id,Config__c >();
        
        for(Config__c conf : configs) {
            setConfigIds.add(conf.Id);
            setSBOMProductIds.add(conf.SBOM_Product__c);
            mapConfigError.put(conf.Id,conf);
        }
        
        Map<Id,BOM__c[]> mapSBOMChildProducts = new Map<Id,BOM__c[]>();
        
        for(BOM__c bom : [select Id, Parent_Product__c, Child_Product__c, Quantity__c
                    from BOM__c
                    where Parent_Product__c IN: setSBOMProductIds ]) {
            
            if(!mapSBOMChildProducts.containsKey(bom.Parent_Product__c)) {
                mapSBOMChildProducts.put(bom.Parent_Product__c, new BOM__c[]{});
            }
            mapSBOMChildProducts.get(bom.Parent_Product__c).add(bom);
        }
        
        system.debug('mapSBOMChildProducts-->'+mapSBOMChildProducts);
        
        /*  */
        
        Config_Product__c[] listConfigProductsToAdd = new Config_Product__c[]{};
        
        for(Config__c conf : configs) {
            if(conf.SBOM_Product__c != null) {
                BOM__c[] childBOMs = mapSBOMChildProducts.get(conf.SBOM_Product__c);
                
                if(childBOMs != null && !childBOMs.isEmpty()) {
                    // Add config products for SBOM parent product
                    Config_Product__c parentConfProd = new Config_Product__c();
                    parentConfProd.Related_BOM__c = childBOMs[0].Id;
                    parentConfProd.Config__c = conf.Id;
                    parentConfProd.Product__c = conf.SBOM_Product__c;
                    parentConfProd.Quantity__c = 1;
                    
                    system.debug('Parent : '+conf.SBOM_Product__c);
                    
                    listConfigProductsToAdd.add(parentConfProd);
                    
                    // Add config products for SBOM child products
                    for(BOM__c bom : childBOMs) {
                        Config_Product__c newConfProd = new Config_Product__c();
                        newConfProd.Related_BOM__c = bom.Id;
                        newConfProd.Config__c = conf.Id;
                        newConfProd.Product__c = bom.Child_Product__c;
                        newConfProd.Quantity__c = bom.Quantity__c;
                        system.debug('Child : '+bom.Child_Product__c);
                        listConfigProductsToAdd.add(newConfProd);
                    }
                }
            }
        }
        
        // Prepare a list of config products to be removed.
        Config_Product__c[] listConfigProductsToRemove = new Config_Product__c[]{}; 
        
        for(Config_Product__c cp : [Select Id, Config__r.SBOM_Product__c, Related_BOM__r.Parent_Product__c
                    from Config_Product__c
                    where Config__c IN: setConfigIds and Related_BOM__c <> null ]) {
                        
            if(cp.Config__r.SBOM_Product__c !=  cp.Related_BOM__r.Parent_Product__c) {
                listConfigProductsToRemove.add(cp);
            }
        }
        
        // Insert the list of new config products
        if(!listConfigProductsToAdd.isEmpty()) {
            try{
                insert listConfigProductsToAdd;
            }catch(System.dmlexception de){
                String errorMessage = de.getDmlMessage(0);
                if(mapConfigError.get(listConfigProductsToAdd.get(de.getDmlIndex(0)).Config__c) != null){
                    mapConfigError.get(listConfigProductsToAdd.get(de.getDmlIndex(0)).Config__c).addError(errorMessage);
                }
                
            }
        }
        
        // Delete the list of old config products
        if(!listConfigProductsToRemove.isEmpty()) {
            CRM_AppConstants.configProductDeleteFlag = false;
            delete listConfigProductsToRemove;
            CRM_AppConstants.configProductDeleteFlag = true;
        }
    }
    
    /**
     *  Method
     *  @name syncVRACProducts - Method to sync (Insert/Delete) config products with assortment products for the given assortments
     *  @param setAssortmentIds - Set of Assortment Ids where config products need to be sync-ed
     *  @return None
     */
    public static void syncVRACProducts(Set<Id> setAssortmentIds){
        // prepare the maps of data to optimize processings 
        prapareAssortmentData(setAssortmentIds);
        
        // Create list of config products to add and remove
        Config_Product__c[] listConfigProductsToAdd = new Config_Product__c[]{};
        Config_Product__c[] listConfigProductsToRemove = new Config_Product__c[]{};
    
        // loop through each of the assortments
        for(Id assrtId : setAssortmentIds) {
            Map<Id,Bundle_Product__c> mapProductIdToAssrtProducts = mapAssortmentProducts.get(assrtId);
            Set<Id> setAssrtProductIds = mapProductIdToAssrtProducts != null ? mapProductIdToAssrtProducts.keySet() : new Set<Id>();

            Map<Id,Config__c> mapAssrtConfigs = mapAssortmentConfigsVRAC.get(assrtId);
            mapAssrtConfigs = mapAssrtConfigs == null ? new Map<Id,Config__c>() : mapAssrtConfigs;

            for(Id configId : mapAssrtConfigs.keySet()){
                Set<Id> setConfigAssrtProductIds = new Set<Id>{};
                Map<Id,Config_Product__c> mapCurrConfigProds = mapConfigProducts.get(configId);

                if(mapCurrConfigProds != null){
                    setConfigAssrtProductIds = mapCurrConfigProds.keySet();
                }

                // Products to be added
                Set<Id> setNewProducts = setAssrtProductIds.clone();
                setNewProducts.removeAll(setConfigAssrtProductIds);
                
                // Create new config products if they are not already in the VRAC config
                for(Id prodId : setNewProducts ){
                    system.debug('To be Added --->'+prodId);
                    Config_Product__c newConfigProd = new Config_Product__c();
                    newConfigProd.Config__c = configId;
                    newConfigProd.Product__c = prodId;
                    
                    listConfigProductsToAdd.add(newConfigProd);
                }
                 
                // Products to be removed (should be of FERT type)
                Set<Id> setRemovedAssrtProducts = new Set<Id>();
                for(Id prodId : setConfigAssrtProductIds) {
                    if(CRM_AppConstants.PRODUCT_MATERIAL_TYPE_FERT == mapCurrConfigProds.get(prodId).Product__r.SAP_Material_Type__c) {
                        setRemovedAssrtProducts.add(prodId);
                    }
                }
                // Remove Assortment Products from existing Config Products to get subset of products to be removed
                // SET_C = SET_A - SET_B where 
                // (SET_C = Extra config Products to be deleted, SET_A = Existing Config_Products, SET_B = All Assortment Products)
                
                system.debug('setRemovedAssrtProducts--->'+setRemovedAssrtProducts);
                system.debug('setAssrtProductIds--->'+setAssrtProductIds);
                setRemovedAssrtProducts.removeAll(setAssrtProductIds);

                for(Id assrtProdId : setRemovedAssrtProducts){
                    system.debug('To be Removed --->'+assrtProdId);

                    Config_Product__c confProdToRemove = mapConfigProducts.get(configId).get(assrtProdId);
                    listConfigProductsToRemove.add(confProdToRemove);
                }
            }
        }
        
        /* Insert the list of new config products */
        if(!listConfigProductsToAdd.isEmpty()){
            insert listConfigProductsToAdd;
        }
        
        /* Delete the list of config products which have been removed from assortment products */
        if(!listConfigProductsToRemove.isEmpty()) {
            CRM_AppConstants.configProductDeleteFlag = false;
            delete listConfigProductsToRemove;
            CRM_AppConstants.configProductDeleteFlag = true;
        }
    }
    
    /**
     *  Method
     *  @name prapareAssortmentData - Prapare the maps/data to be used for further processing of config products
     *  @param setAssortmentIds - Set of Assortment Ids where config products need to be sync-ed
     *  @return None
     */
    public static void prapareAssortmentData(Set<Id> setAssortmentIds){
        mapAssortmentProducts = new Map<Id,Map<Id,Bundle_Product__c>>();
        mapAssortmentConfigsVRAC = new Map<Id,Map<Id,Config__c>>();
        mapAssortmentConfigsSBOM = new Map<Id,Map<Id,Config__c>>();
        mapConfigProducts = new Map<Id,Map<Id,Config_Product__c>>();
    
        if(setAssortmentIds == null || setAssortmentIds.isEmpty()) {
            return;
        }
        
        /* QUERY Assortment products and populate a map of assortment with all its assortment_products with FERT material type */
        for(Bundle_Product__c assrtProd : [SELECT Id, Bundle__c, Product__c, Product__r.SAP_Material_Type__c
                    FROM Bundle_Product__c
                    WHERE Bundle__c IN : setAssortmentIds AND Product__r.SAP_Material_Type__c = :CRM_AppConstants.PRODUCT_MATERIAL_TYPE_FERT ]){

            if(!mapAssortmentProducts.containsKey(assrtProd.Bundle__c)){
                mapAssortmentProducts.put(assrtProd.Bundle__c, new Map<Id,Bundle_Product__c>());
            }

            mapAssortmentProducts.get(assrtProd.Bundle__c).put(assrtProd.Product__c, assrtProd);
        }
        
        
        Config__c[] existingConfigs = [SELECT Id, Assortment__c, RecordTypeId,
                    (select Id, Product__c, Product__r.SAP_Material_Type__c, Related_BOM__c from Config_Products__r )
                    FROM Config__c
                    WHERE Assortment__c IN: setAssortmentIds ];
        
        /* Query on all config records and fill the maps */
        for(Config__c conf : existingConfigs){
            
            /* FILL VRAC CONFIGS MAP */
            if(conf.RecordTypeId == CRM_RecordTypeUtil.RT_CONFIG_VRAC) {
                /* Fill map of config with assortments config */
                if(!mapAssortmentConfigsVRAC.containsKey(conf.Assortment__c)){
                    mapAssortmentConfigsVRAC.put(conf.Assortment__c, new Map<Id,Config__c>());
                }
    
                mapAssortmentConfigsVRAC.get(conf.Assortment__c).put(conf.Id, conf);
            }
            
            
            /* FILL SBOM CONFIGS MAP */
            if(conf.RecordTypeId == CRM_RecordTypeUtil.RT_CONFIG_SBOM) {
                /* Fill map of config with assortments config */
                if(!mapAssortmentConfigsSBOM.containsKey(conf.Assortment__c)){
                    mapAssortmentConfigsSBOM.put(conf.Assortment__c, new Map<Id,Config__c>());
                }
    
                mapAssortmentConfigsSBOM.get(conf.Assortment__c).put(conf.Id, conf);
            }
            
            /* Fill map of config with config products */
            for(Config_Product__c cnfProd : (Config_Product__c[]) conf.Config_Products__r){
                if(!mapConfigProducts.containsKey(conf.Id)) {
                    mapConfigProducts.put(conf.Id, new Map<Id,Config_Product__c>());
                }

                mapConfigProducts.get(conf.Id).put(cnfProd.Product__c, cnfProd);
            }
        }
    }
}