public class CP_PropertySequenceController {
    public static void executeBeforeInsert(List<Property__c> lstProperties) {
        List<Property__c> lstPropertiesToValidate = new List<Property__c>();
        Set<String> franchises = new Set<String>();        
        for(Property__c newRec : lstProperties){
            if(newRec.IsPrimary__c == True){
                lstPropertiesToValidate.add(newRec);
                franchises.add(newRec.Franchise__c);
            }
        }
        CP_PropertyHandler.validateProperties(lstPropertiesToValidate, franchises);
    }
    
    public static void executeBeforeUpdate(List<Property__c> lstProperties, Map<Id,Property__c> oldMapProperties) {
        List<Property__c> lstPropertiesToValidate = new List<Property__c>();
        Set<String> franchises = new Set<String>();
        for(Property__c newRec : lstProperties){
            Property__c oldRec = oldMapProperties.get(newRec.Id);
            if(newRec.IsPrimary__c != oldRec.IsPrimary__c && newRec.IsPrimary__c == True){
                lstPropertiesToValidate.add(newRec);
                franchises.add(newRec.Franchise__c);
            }
        }
        if(!lstPropertiesToValidate.isEmpty()){
            CP_PropertyHandler.validateProperties(lstPropertiesToValidate, franchises);   
        }       
    }
}