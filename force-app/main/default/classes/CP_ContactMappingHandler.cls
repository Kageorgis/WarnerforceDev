public class CP_ContactMappingHandler {
    
    public static Map<String,Category_Dependecy__mdt> getSubCategoryMetadata() {
        Map<String,Category_Dependecy__mdt> mapSubCategoryMetadata = new Map<String,Category_Dependecy__mdt>();
        for(Category_Dependecy__mdt mdtObj : [SELECT Id, MasterLabel, Sub_Category__c, Category__c, NAM_Sub_Category__c, NAM_Category__c, LOB__c, 
                                              LOB_Type_c__c, NAM_LOB__c, NAM_LOB_Type__c, Type_Description_Code__c FROM Category_Dependecy__mdt]){
            if(!mapSubCategoryMetadata.containsKey(mdtObj.Sub_Category__c)){
                mapSubCategoryMetadata.put(mdtObj.Sub_Category__c, mdtObj);
            }
        }
        return mapSubCategoryMetadata;
    }
    
    public static void generateLicenseeContactMappingKey(List<CP_Licensee_Contact_Mapping__c> lstLicenseeContactMappings) {
        Map<String,Category_Dependecy__mdt> mapSubCategoryMetadata = getSubCategoryMetadata();
        for(CP_Licensee_Contact_Mapping__c obj : lstLicenseeContactMappings){
            if(!mapSubCategoryMetadata.isEmpty() && mapSubCategoryMetadata.containsKey(obj.CP_Licensee_Sub_Category__c)){
                String typeDescCode = mapSubCategoryMetadata.get(obj.CP_Licensee_Sub_Category__c).Type_Description_Code__c;
                String key = obj.Licensee_Account__c + '_' + obj.Licensee_Contact_Name__c + '_' + String.valueOf(obj.Contact_Type__c).toLowercase()  + '_' +
                             obj.Country_Code__c.toLowercase() + '_' + obj.Retailer__c + '_' + obj.WB_POC__c + '_' + typeDescCode + '_' + obj.Franchise__c.toLowercase();
                Obj.CP_Licensee_Contact_Mapping_Key__c = key;
            }
        }
    }
    
    public static void autoPopulateSubCategoryMetadataValues(List<CP_Licensee_Contact_Mapping__c> lstLicenseeContactMappings) {
        Map<String,Category_Dependecy__mdt> mapSubCategoryMetadata = getSubCategoryMetadata();
        for(CP_Licensee_Contact_Mapping__c obj : lstLicenseeContactMappings){
            if(!mapSubCategoryMetadata.isEmpty() && mapSubCategoryMetadata.containsKey(obj.CP_Licensee_Sub_Category__c)){
                Category_Dependecy__mdt mtdObj =  mapSubCategoryMetadata.get(obj.CP_Licensee_Sub_Category__c);
                obj.CP_Licensee_Category__c = mtdObj.Category__c;
                obj.CP_Licensee_NAM_Sub_Category__c = mtdObj.NAM_Sub_Category__c;
                obj.CP_Licensee_NAM_Category__c = mtdObj.NAM_Category__c;
                obj.CP_Licensee_LOB__c = mtdObj.LOB__c;
                obj.CP_Licensee_LOB_Type__c = mtdObj.LOB_Type_c__c;
                obj.CP_Licensee_NAM_LOB__c = mtdObj.NAM_LOB__c;
                obj.CP_Licensee_NAM_LOB_Type__c = mtdObj.NAM_LOB_Type__c;
                obj.Type_Description_Code__c = mtdObj.Type_Description_Code__c;
            }else{
                obj.addError('CP_Licensee_Sub_Category__c', System.Label.WBCP_Licensee_Contact_Mapping_Sub_Category_Not_Matching_Error_Msg);
            }
        }
    }
}