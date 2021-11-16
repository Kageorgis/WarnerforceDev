/**
   @Author Cognizant
   @name CRM_BOMConfigProductHandler
   @CreateDate 18 June 2016
   @Description - Class to Add/Remove config products for SBOM configs when a BOM record is added/removed. 
   @Version <1.0>
*/

public with sharing class CRM_BOMConfigProductHandler {
    
    // Code Commented because of Defect No : 3686 
    //Method to insert config product record under related BOM config records
    /*public static void insertConfigProducts(Map<Id,BOM__c> mapBOMs) {
        Map<Id,List<BOM__c>> parentProductIdBomMap = new Map<Id,List<BOM__c>>();
        List<Config_Product__c> configProductInsertList = new List<Config_Product__c>();
        
        //Create Map which will contain product id as Key and BOM record as  value
        for (BOM__c bom : mapBOMs.values()) {
            if (bom.Parent_Product__c != NULL && bom.Child_Product__c != NULL) {
                if (parentProductIdBomMap.containsKey(bom.Parent_Product__c)) {
                    parentProductIdBomMap.get(bom.Parent_Product__c).add(bom);
                } else {
                    parentProductIdBomMap.put(bom.Parent_Product__c, new List<BOM__c>{bom}); 
                }
            }
            
        }
        
        //retrieve all the BOM related config records 
        List<Config__c> congigRecordList = [SELECT Id,SBOM_Product__c 
                                              FROM Config__c 
                                              WHERE SBOM_Product__c IN:parentProductIdBomMap.keySet()
                                              and RecordTypeId = : CRM_RecordTypeUtil.RT_CONFIG_SBOM ];
                                              
        //for each config record insert Config Product record 
        //depending on the mapping of Parent product to Product associated with Config                                    
        for (Config__c config : congigRecordList) {
            List<BOM__c> bomRecords = parentProductIdBomMap.get(config.SBOM_Product__c);
            for (BOM__c bom : bomRecords) {
                Config_Product__c newConfigProd = new Config_Product__c (
                    Config__c = config.Id,
                    Product__c = bom.Child_Product__c,
                    Related_BOM__c = bom.Id,
                    Quantity__c = bom.Quantity__c
                );
                
                configProductInsertList.add(newConfigProd);
            }
        }
        if (!configProductInsertList.isEmpty()) {
            insert configProductInsertList;   
        }
    }*/
    
    /**
     *  @Description - Defect. #3686 : If BOM record Quantity updated, update its related SBOM config Product Quantity 
     *  @name - updateSBOMConfigProductQuantity
     *  @param - mapBOMs - Map of BOM
     *  @return - void
     **/ 
    public static void updateSBOMConfigProductQuantity(Map<Id,BOM__c> mapNewBOMs,Map<Id,BOM__c> mapOldBOMs){
        Set<Id> modifiedBomIds= new Set<Id>();
        List<Config_Product__c> configProductUpdateList = new List<Config_Product__c>();
        
        //Modified BOMs Id Set
        for(BOM__c bom : mapNewBOMs.values()){
            if(bom.Quantity__c != mapOldBOMs.get(bom.Id).Quantity__c ){
                modifiedBomIds.add(bom.Id);
            }
        }
        
        if(modifiedBomIds.size() > 0){
            //SBOM Config Products related to Updated BOMs
            List<Config_Product__c> SBOMConfigProducts = [SELECT Id,Quantity__c,Related_BOM__c
                                                          From Config_Product__c
                                                          WHERE Related_BOM__c IN :modifiedBomIds];
            
            //Sync Config Product.Quantity with BOM.Quantity                                      
            if(SBOMConfigProducts.size() > 0){
                for(Config_Product__c configPro : SBOMConfigProducts){
                    if(mapNewBOMs.get(configPro.Related_BOM__c) != null){
                        configPro.Quantity__c = mapNewBOMs.get(configPro.Related_BOM__c).Quantity__c != null ? mapNewBOMs.get(configPro.Related_BOM__c).Quantity__c : 0;
                        configProductUpdateList.add(configPro);
                    }
                }
            }
        }
        
        if(configProductUpdateList.size() > 0){
            update configProductUpdateList;
        }
    }
    

    /* Code Commented because of Defect No : 3686 
    public static void deleteConfigProducts(Map<Id,BOM__c> mapBOMs) {
        Set<Id> childProductId = new Set<Id>();
        Config_Product__c[] configProductDeleteList = new Config_Product__c[]{};
        
        //retrieve all child product Ids from all BOM records
        for(BOM__c bom : mapBOMs.values()) {
            if (bom.Child_Product__c != null) {
                childProductId.add(bom.Child_Product__c);   
            }
        }
        
        //get all the config prodyct records related to BOM records 
        //and delete them
        if (!childProductId.isEmpty()) {
            
            configProductDeleteList = [SELECT Id 
                                       FROM Config_Product__c 
                                       WHERE Related_BOM__c IN:mapBOMs.keySet()
                                       AND Product__c IN :childProductId];
                                                 
            if (!configProductDeleteList.isEmpty()) {
                delete configProductDeleteList;
            }
        }
    }*/
    
    /**
     *  @Description - Req. #393 (FR): If BOM record is inserted with a Parent Product, update Parent Product Material Type to SBOM
     *  @name - updateProdctMaterialType
     *  @param - mapBOMs - Map of BOM
     *  @return - void
     **/ 
    public static void updateProductMaterialType(Map<Id,BOM__c> mapBOMs) {
        //Set to store BOM Parent_Product__c Id
        Set<Id> setSBOMProducts = new Set<Id>();
        Map<String, Id> mapSalesOrgPriceBook = new Map<String, Id>();
        
        for(BOM__c bomRec : mapBOMs.values()) {
            setSBOMProducts.add(bomRec.Parent_Product__c);
        }
        //Map to store Products which are to be updated. 
        Map<Id,Product2> mapProductsToUpdate = new Map<Id,Product2>();
        
        if(!setSBOMProducts.isEmpty()) {
            //Loop over all the Products where SAP_Material_Type__c has changed and Product is a Parent_Product__c on BOM
            //Defect: #3580. Product Pack Type should be Multi Pack.
            //Defect : #3660 Need to uncheck following fields on SBOM NR Products when BOM are inserted:
            //NR_Product_Created__c = false,Previous_Street_Date__c = null,Street_Date_Has_Changed__c = false

            for(Product2 product : [select Id,SAP_Sales_Org__c,SAP_Distribution_Id__c,CurrencyIsoCode,NR_Product_Created__c,Previous_Street_Date__c,Street_Date_Has_Changed__c  from Product2 
                        where SAP_Material_Type__c != :CRM_AppConstants.SBOM_SAP_MATERIAL_TYPE AND Pack_Type__c =: CRM_AppConstants.PRODUCT_PACK_TYPE_MultiPack AND Id IN: setSBOMProducts]) {        
                product.SAP_Material_Type__c = CRM_AppConstants.SBOM_SAP_MATERIAL_TYPE;
                //Defect: #3660: Make Changes to Fields:
                if(product.NR_Product_Created__c){
                    product.NR_Product_Created__c = false;
                }
                if(product.Previous_Street_Date__c!= null){
                    product.Previous_Street_Date__c = null;
                }
                if(product.Street_Date_Has_Changed__c){ 
                    product.Street_Date_Has_Changed__c = false;
                }    
                //Adding Products tto update to the MAP
                mapProductsToUpdate.put(product.Id, product);
                if(product.SAP_Sales_Org__c != null && product.SAP_Distribution_Id__c != null){
                mapSalesOrgPriceBook.put(product.SAP_Sales_Org__c+'-'+product.SAP_Distribution_Id__c, null);
                system.debug('*##***');
            }
            }
        }
        //Update Parent Product SAP Material Type
        if(!mapProductsToUpdate.isEmpty()) {
            update mapProductsToUpdate.values();
        }
        
        CRM_ProductHandler.mapInsertPBEPAndPBE(mapProductsToUpdate,mapSalesOrgPriceBook);
    }
    
    /**
        *  @Description - Method to collect the bom where 'Delete_Product__c' flag is true to delete the bom records.       
        *  @name - deleteBOMs
        *  @return nothing
        *  @defect 3676 
        */
        public static void deleteBOMs(Map<Id,BOM__c> mapOldBOMs,List<BOM__c> lstNewBOMs){
            set<Id> bomIdsToDelete = new set<Id>();
            
            for(BOM__c bom : lstNewBOMs){
                system.debug('values :-->'+bom.Delete_Record__c+'Old map value -->'+mapOldBOMs.get(bom.id).Delete_Record__c);
                if(bom.Delete_Record__c != mapOldBOMs.get(bom.id).Delete_Record__c && bom.Delete_Record__c == true){
                    system.debug('Inside block');
                    bomIdsToDelete.add(bom.id);
                }   
            }
            system.debug('size of list-->'+bomIdsToDelete.size());
            if(bomIdsToDelete.size() > 0){
                system.debug('inside method call');
                deleteFlagedBOMSFuture(bomIdsToDelete);
            }
        }
        
        /**
        *  @Description - Method to delete flaged bom from SFDC when deleted from informatica.      
        *  @name - deleteFlagedBOMSFuture
        *  @return nothing
        *  @defect 3676 
        */
        @future(callout=true)
        public static void deleteFlagedBOMSFuture(set<Id> bomIds){
            List<BOM__c> lstBomsToDelete = new List<BOM__c>();
            
            for(Id bomId : bomIds){
                BOM__c bom = new BOM__c(Id=bomId);
                lstBomsToDelete.add(bom);
            }
            
            if(lstBomsToDelete.size() > 0){
                try{
                     delete lstBomsToDelete;
                }
                catch(Exception e){
                     logAnException(e, null);
                }
            }   
        }
        /*
        *  This method will take the exception occured as an input and forward it to the common utility class. 
        *  @name: logAnException
        *  @param: Exception ex
        *  @return: void 
        */
        public static void logAnException(Exception ex, Id recordId){
            CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
            if (recordId != null)
                errorLogInstance.recordId = recordId;
            // Modules can be of type -> Deals / Targets / Demand / Orders / Co-Ops / Planning / General / Reporting / Non Functional
            errorLogInstance.functionalModule = 'CRM_BOMConfigProductHandler';
            errorLogInstance.lineNumber = String.valueof(ex.getLineNumber());
            errorLogInstance.errorMessage = ex.getMessage();
            errorLogInstance.stackTrace = ex.getStackTraceString();
    
            // Call the logError method which will insert all errors into CRM_Error_Log__c object
            CRM_ErrorLogger.logError(errorLogInstance);     
        }   
}