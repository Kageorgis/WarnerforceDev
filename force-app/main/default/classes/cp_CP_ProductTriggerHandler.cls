/**
* Created by XMMORENO on 3/26/2020.
*/

public without sharing class cp_CP_ProductTriggerHandler{
    
    public static void updateAutoPopValues(List<CP_Product__c> prodList) {
        Map<String,Id> mapStarLabsProducts = new Map<String,Id>();
        Map<String,Category_Dependecy__mdt> mapCategoryDependecy = new Map<String,Category_Dependecy__mdt>();
        
        //Map of Category_Dependecy__mdt used to update CP Products category related fields
        for(Category_Dependecy__mdt mdtObj: [select Category__c, Sub_Category__c, LOB__c, LOB_Type_c__c, NAM_Category__c, NAM_Sub_Category__c, NAM_LOB__c, NAM_LOB_Type__c, 
                                             Product_Category_Code__c, Type_Description_Code__c, Product_Code__c, MasterLabel FROM Category_Dependecy__mdt]){
            if(!mapCategoryDependecy.containsKey(mdtObj.Sub_Category__c)){
                mapCategoryDependecy.put(mdtObj.Sub_Category__c, mdtObj);
            }
        }        
        //Map of StarLabs Product used to update CP Products StarLabs Product Entry field
        for(StarLabs_Product__c sp: [SELECT Id, UPC__c FROM StarLabs_Product__c]){
            if(!mapStarLabsProducts.containsKey(sp.UPC__c)){
                mapStarLabsProducts.put(sp.UPC__c, sp.Id);
            }
        }        
        for(CP_Product__c prod : prodList){
            if(!mapCategoryDependecy.isEmpty() && mapCategoryDependecy.containsKey(prod.Sub_Category__c)){
                Category_Dependecy__mdt mtdObj =  mapCategoryDependecy.get(prod.Sub_Category__c);
                prod.cp_Category_NAM__c = mtdObj.NAM_Category__c;
                prod.cp_Category_STD__c = mtdObj.Category__c;
                prod.cp_Sub_Category__c = mtdObj.NAM_Sub_Category__c;
                prod.LOB__c = mtdObj.LOB__c;
                prod.LOB_Type__c = mtdObj.LOB_Type_c__c;
                prod.LOB_NAM__c = mtdObj.NAM_LOB__c;
                prod.LOB_Type_NAM__c = mtdObj.NAM_LOB_Type__c;
                prod.Product_Category_Code__c = mtdObj.Product_Category_Code__c;
                prod.Type_Description_Code__c = mtdObj.Type_Description_Code__c;
            }else{
                System.debug('No Sub Category Matches');
            }            
            if(!mapStarLabsProducts.isEmpty() && mapStarLabsProducts.containsKey(prod.GTIN__c)){
                prod.StarLabs_Product_Entry__c = mapStarLabsProducts.get(prod.GTIN__c);
            }
        }
    }
    
    /**
    *  Method to check duplicate CP Product records based on combination of Retailer+Country Code+GTIN_Padded+SKU before insert/update
    *  and validate the CP Product records.
    *  @name checkDuplicateCPProducts
    *  @param List<CP_Product__c> lstCPProducts - CP Product records for insert/update
    *  @return void
    *  @throws None
    **/
    public static void checkDuplicateCPProducts(List<CP_Product__c> lstCPProducts, Map<Id,CP_Product__c> oldMapCPProducts){
        Set<String> GTINPaddeds = new Set<String>();
        Set<Id> cpProdIds = new Set<Id>();
        Set<String> cpProdKeys = new Set<String>();
        Set<String> RetailerVal = new Set<String>();
        Set<String> CountryCodeVal = new Set<String>();
        Set<String> RetailerSKU = new Set<String>();
        
        Map<String,Integer> mapDuplicateProdCount = new Map<String,Integer>();
        Map<String,CP_Product__c> mapCPProduct = new Map<String,CP_Product__c>();
        Map<String,List<CP_Product__c>> mapMisMatchCPProducts = new Map<String,List<CP_Product__c>>();
        
        Boolean isInsert = (oldMapCPProducts == NULL ? true : false);
        CP_Product__c oldProdObj;
        
        for(CP_Product__c prodRec : lstCPProducts){
            String key = '';
            String tmpKey = '';
            if(prodRec.GTIN_Pad__c==null){
            RetailerVal.add(prodRec.cp_Retailer_Name__c);    
            CountryCodeVal.add(prodRec.cp_Country_Code__c);
            RetailerSKU.add(prodRec.Retailer_SKU__c);
                key = (prodRec.cp_Retailer_Name__c + '_' + prodRec.cp_Country_Code__c + '_' + prodRec.Retailer_SKU__c).toLowerCase();
            }else{
             key = (prodRec.cp_Retailer_Name__c + '_' + prodRec.cp_Country_Code__c + '_' + prodRec.GTIN_Padded__c + '_' + prodRec.Retailer_SKU__c).toLowerCase();
             tmpKey = prodRec.GTIN_Padded__c;   
        	}
            if(mapDuplicateProdCount.containsKey(key)){
                mapDuplicateProdCount.put(key,(mapDuplicateProdCount.get(key) + 1));
            }else{
                mapDuplicateProdCount.put(key, 1);                                            
            }
            if(tmpKey!=''){
            if(mapMisMatchCPProducts.containsKey(tmpKey)){
                List<CP_Product__c> tmpList = mapMisMatchCPProducts.get(tmpKey);
                tmpList.add(prodRec);
                mapMisMatchCPProducts.put(tmpKey, tmpList);
            }else{
                mapMisMatchCPProducts.put(tmpKey, new List<CP_Product__c> {prodRec});
            }
            GTINPaddeds.add(prodRec.GTIN_Padded__c);
            }
            cpProdKeys.add(key);
            
            if(!isInsert){
                cpProdIds.add(prodRec.Id);
            }
        }
        
        for(CP_Product__c prodRec : [SELECT Id, Name, cp_Retailer_Description__c, cp_Retailer_Name__c, cp_Country_Code__c, GTIN__c, GTIN_Padded__c, Retailer_SKU__c, 
                                     Sub_Category__c, Type_Description_Code__c, Licensee__r.Name, cp_Licensee_Code__c, cp_Licensed_Property__r.Name, cp_Property_Code__c
                                     FROM CP_Product__c WHERE GTIN_Padded__c IN : GTINPaddeds AND ID NOT IN :cpProdIds]){                                     
            String key = (prodRec.cp_Retailer_Name__c + '_' + prodRec.cp_Country_Code__c + '_' + prodRec.GTIN_Padded__c + '_' + prodRec.Retailer_SKU__c).toLowerCase();
            if(!mapCPProduct.containsKey(key) && cpProdKeys.contains(key)){
                mapCPProduct.put(key, prodRec);
            }
            key = prodRec.GTIN_Padded__c;
            if(!mapCPProduct.containsKey(key)){
                mapCPProduct.put(key, prodRec);
            }
        }
        for(CP_Product__c prodRec : [SELECT Id, Name,cp_Retailer_Name__c, cp_Country_Code__c, Retailer_SKU__c
                                     FROM CP_Product__c WHERE cp_Retailer_Name__c IN :RetailerVal and cp_Country_Code__c IN :CountryCodeVal and Retailer_SKU__c IN :RetailerSKU AND ID NOT IN :cpProdIds AND GTIN_Padded__c = '']){
			String key = (prodRec.cp_Retailer_Name__c + '_' + prodRec.cp_Country_Code__c + '_' + prodRec.Retailer_SKU__c).toLowerCase();
            if(!mapCPProduct.containsKey(key) && cpProdKeys.contains(key)){
                mapCPProduct.put(key, prodRec);
            }                             
           }
        
        for(CP_Product__c cpProdObj : lstCPProducts){
            oldProdObj = !isInsert ? oldMapCPProducts.get(cpProdObj.Id) : null;
            String error = '';
            if(isInsert || 
                (cpProdObj.cp_Retailer_Description__c != oldProdObj.cp_Retailer_Description__c || cpProdObj.WBCP_Country__c != oldProdObj.WBCP_Country__c || 
                cpProdObj.GTIN_Padded__c != oldProdObj.GTIN_Padded__c || cpProdObj.Retailer_SKU__c != oldProdObj.Retailer_SKU__c)){
                String tempKey = '';
                if(cpProdObj.GTIN_Pad__c==null){
                tempKey = cpProdObj.cp_Retailer_Name__c + '_' + cpProdObj.cp_Country_Code__c + '_' + cpProdObj.Retailer_SKU__c; 
                }else{
                tempKey = cpProdObj.cp_Retailer_Name__c + '_' + cpProdObj.cp_Country_Code__c + '_' + cpProdObj.GTIN_Padded__c + '_' + cpProdObj.Retailer_SKU__c;  
                }
                String key = tempKey.toLowerCase();
                    
                if(mapDuplicateProdCount.containsKey(key) && mapDuplicateProdCount.get(key) > 1){
                    error = String.format(System.Label.WBCP_CP_Products_Retailer_Country_GTIN_SKU_Duplicate_Found_on_Grid_Error_Msg, new String[] {tempKey});
                }
                if(!mapCPProduct.isEmpty() && mapCPProduct.containsKey(key)){
                    error += (error != '') ? ', ' : '';
                    error += String.format(system.label.WBCP_CP_Product_Duplicates_Error_Msg, new String[] {mapCPProduct.get(key).Name});
                }
                if(error != ''){
                    cpProdObj.addError(error);
                }
            }
            
            if(error == ''){
                if(isInsert || (oldProdObj != null && (cpProdObj.Sub_Category__c != oldProdObj.Sub_Category__c || cpProdObj.Licensee__c != oldProdObj.Licensee__c || 
                                cpProdObj.cp_Licensed_Property__c != oldProdObj.cp_Licensed_Property__c || cpProdObj.GTIN_Padded__c != oldProdObj.GTIN_Padded__c))){                                      
                    String key = cpProdObj.GTIN_Padded__c;
                    if(mapMisMatchCPProducts.containsKey(key) && mapMisMatchCPProducts.get(key).size() > 1){
                        for(CP_Product__c tmpObj : mapMisMatchCPProducts.get(key)){
                            if(cpProdObj.Sub_Category__c != tmpObj.Sub_Category__c || cpProdObj.cp_Licensee_Code__c != tmpObj.cp_Licensee_Code__c || cpProdObj.cp_Property_Code__c != tmpObj.cp_Property_Code__c){
                                error = String.format(System.Label.WBCP_CP_Products_Mismatch_Values_on_Grid_Error_Msg, new String[] {key});
                                break;
                            }
                        }
                	}
                    if(error == '' && !mapCPProduct.isEmpty() && mapCPProduct.containsKey(key)){
                        CP_Product__c tempProdObj = mapCPProduct.get(key);
                        List<String> mismatches = new List<String>();
                        List<String> mismatchValues = new List<String>();
                        
                        if(cpProdObj.cp_Licensee_Code__c != tempProdObj.cp_Licensee_Code__c){
                            mismatches.add('Licensee Name');
                            mismatchValues.add(String.valueOf(tempProdObj.Licensee__r.Name));
                        }
                        if(cpProdObj.cp_Property_Code__c != tempProdObj.cp_Property_Code__c){
                            mismatches.add('Licensed Property');
                            mismatchValues.add(String.valueOf(tempProdObj.cp_Licensed_Property__r.Name));
                        }
                        if(cpProdObj.Sub_Category__c != tempProdObj.Sub_Category__c){                           
                            mismatches.add('Sub-Category');
                            mismatchValues.add(String.valueOf(tempProdObj.Sub_Category__c));
                        }
                        if(!mismatches.isEmpty()){
                            mismatchValues.add(String.valueOf(tempProdObj.GTIN__c));
                            String secEle = tempProdObj.Name + '(' + String.join(mismatchValues, ',') +  ')';
                            error = String.format(System.Label.WBCP_CP_Products_Licensee_Name_Licensed_Property_Sub_Category_Mismatch_Error_Msg, new String[] {String.join(mismatches, ','), secEle});
                        }                        
                    }                                                                              
                    if(error != ''){
                    	cpProdObj.addError(error);
                    }
                }
            }
        }
    }
}