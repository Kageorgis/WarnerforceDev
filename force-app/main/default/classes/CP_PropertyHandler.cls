public class CP_PropertyHandler {
    public static void validateProperties(List<Property__c> lstProperties, Set<String> franchises){
        Map<String, Property__c> mapProperties = new Map<String, Property__c>();
        for(Property__c propObj : [SELECT Id, Name, Franchise__c, IsPrimary__c FROM Property__c WHERE IsPrimary__c = True AND Franchise__c IN : franchises]){
            if(!mapProperties.containsKey(propObj.Franchise__c)){
                mapProperties.put(propObj.Franchise__c, propObj);
            }
        }
        for(Property__c propObj : lstProperties){
            if(mapProperties.containsKey(propObj.Franchise__c)){
                propObj.addError(String.format(System.Label.WBCP_Primary_Property_Already_Exists_Error_Msg,new String[] {propObj.Franchise__c}));              
            }
        }
    }
}