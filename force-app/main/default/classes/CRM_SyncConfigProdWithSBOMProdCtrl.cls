/**
   @Author - Cognizant
   @name - CRM_SyncConfigProdWithSBOMProd
   @CreateDate - 20 September 2016
   @Description - Extension to sync config products with SBOM products.
   @Version - <1.0>
   @reference - Defect no : 3686
*/

global with sharing class CRM_SyncConfigProdWithSBOMProdCtrl{

    global CRM_SyncConfigProdWithSBOMProdCtrl(ApexPages.StandardController stdCon){}
    
    /**
     *  Method
     *  @name syncConfigProductsWithSBOMProducts- RemoteAction method to be called from CRM_SyncConfigProdWithSBOMProd VF Page
     *  @param configId- Id of Config, SBOMProductId - Id of SBOM Product available on Config
     *  @return none 
     */
    @RemoteAction 
    global static List<errorWrapper> syncConfigProductsWithSBOMProducts(Id configId,Id SBOMProductId){ 
        
        // Error Wraper List
        List<errorWrapper> errorWrapper = new List<errorWrapper>();
        
        //child config Product Map
        Map<Id,Config_Product__c> childConfigProductMap = new Map<Id,Config_Product__c>();
        
        //Config Product map use for error message
        Map<Id,String> productMap = new Map<Id,String>();
        
        //Ids of Bom Child Products 
        Set<Id> bomChildProductIds = new Set<Id>();
        
        List<Config_Product__c> insertConfigProdList = new List<Config_Product__c>();
        List<Config_Product__c> deleteConfigProdList = new List<Config_Product__c>();
        
        if(configId != null && SBOMProductId != null){
            
            //Fill childConfigProductMap (Key ==> SBOM Product Id , Value ==> Config Product)
            for(Config_Product__c configProd : [SELECT Id,Product__c,Product__r.Name,Related_BOM__c
                                                FROM Config_Product__c
                                                WHERE Config__c =: configId AND Product__c !=:SBOMProductId]){
                
                if(configProd.Product__c != null){      
                    childConfigProductMap.put(configProd.Product__c,configProd);
                }
            }
            
            // Prepare a Set of Bom child Product Ids
            // Prepare a list of config products to be inserted.                                               
            for(BOM__c bom : [SELECT Id,Child_Product__c,Parent_Product__c,Quantity__c,Child_Product__r.Name
                              FROM BOM__c
                              WHERE Parent_Product__c =: SBOMProductId]){
                                                                
                if(bom.Child_Product__c != null){
                    
                    bomChildProductIds.add(bom.Child_Product__c);
                    
                    if(!childConfigProductMap.containsKey(bom.Child_Product__c)){
                        
                        productMap.put(bom.Child_Product__c,bom.Child_Product__r.Name);
                        
                        Config_Product__c newConfigProd = new Config_Product__c (
                            Config__c = configId,
                            Product__c = bom.Child_Product__c,
                            Related_BOM__c = bom.Id,
                            Quantity__c = bom.Quantity__c
                        );
                        insertConfigProdList.add(newConfigProd);
                    }
                }
            }
            
            // Prepare a list of config products to be removed. 
            if(childConfigProductMap.size() > 0){
                
                for(Config_Product__c configProd : childConfigProductMap.values()){
                    
                    if(!bomChildProductIds.contains(configProd.Product__c)){
                        deleteConfigProdList.add(configProd);
                        productMap.put(configProd.Product__c,configProd.Product__r.Name);
                    }
                }
            }
            
            Database.SaveResult[] saveResult = new Database.SaveResult[]{};
            Database.DeleteResult[] deleteResult = new Database.DeleteResult[]{};
            
            // Insert New Config Products which are available in SBOM Products
            if(insertConfigProdList.size() > 0){
                saveResult = Database.insert(insertConfigProdList, false);
            }
            
            // Removed config Product which are not available in SBOM Products
            if(deleteConfigProdList.size() > 0){
                CRM_AppConstants.configProductDeleteFlag = false;   
                deleteResult = Database.delete(deleteConfigProdList, false);
                CRM_AppConstants.configProductDeleteFlag = true;
            }
            
            // Save Results
            for (integer i=0 ; i < saveResult.size() ; i++){
                if (!saveResult[i].isSuccess()){
                    Database.Error[] errors = saveResult[i].getErrors();
                    system.debug('errors : '+errors);
                    String productName = productMap.get(insertConfigProdList[i].Product__c);
                    errorWrapper.add(new errorWrapper(insertConfigProdList[i].Product__c,errors[0].getMessage(),productName));
                }
            }  
            
            // Delete Results
            for (integer i=0 ; i < deleteResult.size() ; i++) {
                if (!deleteResult[i].isSuccess()){
                    Database.Error[] errors = deleteResult[i].getErrors();
                    system.debug('errors : '+errors);
                    String productName = productMap.get(deleteConfigProdList[i].Product__c);
                    errorWrapper.add(new errorWrapper(deleteConfigProdList[i].Product__c,errors[0].getMessage(),productName));
                }
            }
        }
        system.debug('Error : '+errorWrapper);
        return errorWrapper;
    }
    
    global class errorWrapper{
        public String errorMsg;
        public String productName;
        public String productId;
        
        public errorWrapper(String productId,String errorMsg,String productName){
            this.productId = productId;
            this.errorMsg = errorMsg;
            this.productName = productName;
        }
    }
}