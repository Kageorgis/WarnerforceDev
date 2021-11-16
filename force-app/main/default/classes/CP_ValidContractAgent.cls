public without sharing class CP_ValidContractAgent {
    @AuraEnabled
    public static List<Id> validContracts(Id forecastLicensee){
        List<Id> validContractIds = new List<Id>();
        List<CP_Contract__c> validContrList = [SELECT Id, Name, Source_System__c FROM CP_Contract__c WHERE Account_Licensee__r.parentId = :forecastLicensee AND (Source_System__c = 'LMSi' OR Source_System__c = 'LMSI')];
        for(CP_Contract__c con : validContrList){
            validContractIds.add(con.Id);
        }
        System.debug('###' + validContrList);
        return validContractIds;
    }
}