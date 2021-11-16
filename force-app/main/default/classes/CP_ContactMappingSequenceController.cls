public class CP_ContactMappingSequenceController {
    
    public static void executeBeforeInsert(List<CP_Licensee_Contact_Mapping__c> lstLicenseeContactMappings) {
        CP_ContactMappingHandler.generateLicenseeContactMappingKey(lstLicenseeContactMappings);
        CP_ContactMappingHandler.autoPopulateSubCategoryMetadataValues(lstLicenseeContactMappings);
    }
    
    public static void executeBeforeUpdate(List<CP_Licensee_Contact_Mapping__c> lstLicenseeContactMappings, Map<Id,CP_Licensee_Contact_Mapping__c> oldMapLicenseeContactMappings) {
        Map<Id,CP_Licensee_Contact_Mapping__c> mapRecToUpdateKeySubCate = new Map<Id,CP_Licensee_Contact_Mapping__c>();
        Map<Id,CP_Licensee_Contact_Mapping__c> mapRecToUpdateKey = new Map<Id,CP_Licensee_Contact_Mapping__c>();
        for(CP_Licensee_Contact_Mapping__c newRec : lstLicenseeContactMappings){
            CP_Licensee_Contact_Mapping__c oldRec = oldMapLicenseeContactMappings.get(newRec.Id);            
            if(newRec.CP_Licensee_Sub_Category__c != oldRec.CP_Licensee_Sub_Category__c){
                if(!mapRecToUpdateKeySubCate.containsKey(newRec.Id)){
                    mapRecToUpdateKeySubCate.put(newRec.Id, newRec);
                }
            }           
            if(newRec.Licensee_Account__c != oldRec.Licensee_Account__c || newRec.Licensee_Contact_Name__c != oldRec.Licensee_Contact_Name__c ||
               newRec.Contact_Type__c != oldRec.Contact_Type__c || newRec.Country__c != oldRec.Country__c || newRec.Retailer__c != oldRec.Retailer__c ||
               newRec.WB_POC__c != oldRec.WB_POC__c || newRec.Property__c != oldRec.Property__c){
                   if(!mapRecToUpdateKeySubCate.containsKey(newRec.Id)){
                       mapRecToUpdateKey.put(newRec.Id, newRec);
                   }
               }
        }        
        if(!mapRecToUpdateKeySubCate.isEmpty()){
            CP_ContactMappingHandler.generateLicenseeContactMappingKey(mapRecToUpdateKeySubCate.values());
            CP_ContactMappingHandler.autoPopulateSubCategoryMetadataValues(mapRecToUpdateKeySubCate.values());
        }        
        if(!mapRecToUpdateKey.isEmpty()){
            CP_ContactMappingHandler.generateLicenseeContactMappingKey(mapRecToUpdateKey.values());
        }
    }
    
}