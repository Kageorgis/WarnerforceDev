/**
   @Author Cognizant
   @name CRM_AddConfigProductsController
   @CreateDate 7 June 2016
   @Description controller for vf to add config products on a config record
   @Version <1.0>
   @reference Requirement no US#200
*/
global with sharing class CRM_AddConfigProductsController {

    // Constructor with StandardController as parameter
    public CRM_AddConfigProductsController(ApexPages.StandardController stdCon) {}

    /**
     *  Method
     *  @name getConfigProducts
     *  @param configId - Id of the config record where products are required to be added
     *  @return ConfigProduct[] - list of Config Products to be made available for user selection
     */
    @RemoteAction
    global static ConfigProduct[] getConfigProducts(Id configId) {
        ConfigProduct[] listConfigProducts = new ConfigProduct[]{};

        Config__c[] configs = [select Id, Assortment__c from Config__c where Id= : configId ];

        Map<String, Config_Product__c> mapCurrProducts = getExistingConfigProducts(configId);

        if(configs != null && configs.size() > 0) {
            for(Bundle_Product__c asrtProd : [select Id, Product__c, Product__r.Id, Product__r.Name, Product__r.ProductCode,
                        Product__r.Universal_Picture_Code__c
                        from Bundle_Product__c
                        where Bundle__c =: configs[0].Assortment__c and Product__r.SAP_Material_Type__c = : CRM_AppConstants.PRODUCT_MATERIAL_TYPE_UNBW]) {

                Boolean configProdExists = mapCurrProducts.containsKey(configs[0].Id + '-' + asrtProd.Product__c);

                ConfigProduct configProd = new ConfigProduct();
                configProd.isSelected = configProdExists ? true : false;
                configProd.config = configs[0];
                configProd.product = asrtProd.Product__r;

                listConfigProducts.add(configProd);
            }
        }

        return listConfigProducts;
    }

    /**
     *  Method
     *  @name setConfigProducts
     *  @param configId - Id of the config record where products are required to be added
     *  @param configProducts - List of config products with selection information
     *  @return Boolean - flag to indicate the result of the process/operation
     */
    @RemoteAction
    global static Boolean setConfigProducts(Id configId, ConfigProduct[] configProducts) {
        system.debug('configProducts'+configProducts);
        Map<String, Config_Product__c> mapCurrProducts = getExistingConfigProducts(configId);

        Config_Product__c[] listProductsToAdd = new Config_Product__c[]{},
            listProductsToRemove = new Config_Product__c[]{};

        for(ConfigProduct cp : configProducts) {
            String currConfigProdKey = cp.config.Id+'-'+cp.product.Id;

            if(cp.isSelected == false && mapCurrProducts.containsKey(currConfigProdKey)) {
                listProductsToRemove.add(mapCurrProducts.get(currConfigProdKey));
            }
            else if(cp.isSelected == true && !mapCurrProducts.containsKey(currConfigProdKey)) {
                Config_Product__c confPrd = new Config_Product__c();
                confPrd.Config__c = configId;
                confPrd.Product__c = cp.product.Id;

                listProductsToAdd.add(confPrd);
            }
        }

        try {
            insert listProductsToAdd;
            delete listProductsToRemove;
        }
        catch(Exception ex){
            throw ex;
        }

        return true;
    }

    /**
     *  Method
     *  @name getExistingConfigProducts
     *  @param configId - Id of the config record for whicih existing product records to be fetched
     *  @return Map<String, Config_Product__c> - Map of the existing config_proeuct records
     */
    private static Map<String, Config_Product__c> getExistingConfigProducts(Id configId){
        Map<String, Config_Product__c> mapCurrentConfigProducts = new Map<String, Config_Product__c>();

        for(Config_Product__c configProd  : [Select Id, Config__c, Product__c
            From Config_Product__c
            where Config__c = :configId] ){

            String recordKey = configProd.Config__c + '-' +configProd.Product__c;
            mapCurrentConfigProducts.put(recordKey, configProd);
        }

        return mapCurrentConfigProducts;
    }


    /* Wrapper class to be used as javascript remoting object */
    global class ConfigProduct {
        global Boolean isSelected {get;set;}
        global Config__c config {get;set;}
        global Product2 product {get;set;}
    }
}