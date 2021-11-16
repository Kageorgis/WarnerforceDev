/**
   @Author-Cognizant Technology Solutions
   @name-CRM_StorefrontSequenceController
   @CreateDate- 4 May 2018
   @Description- This class is used to call handler CRM_RateCardHandler methods to set Invalid Capability Flag on RC
   @Version-1.0
   @reference-None
*/
public with sharing class CRM_StorefrontSequenceController{
    
    public static void executeBeforeUpdate(Map<Id,Agreement__c> mapOldSFs, Map<Id,Agreement__c> mapNewSFs) {
     
        Set<Id> storefrontIds = new Set<Id>();
        for(Agreement__c sf : mapNewSFs.values()){
            if(sf.Selected_Combination__c != mapOldSFs.get(sf.Id).Selected_Combination__c){
                storefrontIds.add(sf.Id);
            }
        }
        List<Rate_Card__c> newRCLists = [Select Id,Storefront__c,Content_Type__c,Channel__c,Format__c,Invalid_Capability__c From Rate_Card__c WHERE Storefront__c IN :storefrontIds];
        if(!newRCLists.isEmpty()){
            CRM_RateCardHandler.setInvalidCapabilityFlag(mapNewSFs,newRCLists); 
            update newRCLists;
        }
    }
}