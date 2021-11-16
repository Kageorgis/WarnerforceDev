/**
   @Author-Cognizant Technology Solutions
   @name-CRM_AccountSplitTemplateHandler
   @CreateDate- 20th July 2017
*/
public with sharing class CRM_AccountSplitTemplateHandler {
    /**
     * @US:527
     * @Description - Method is used to Restrict to update Automatically_Split_to_Ship_To__c check box on Account Split Template Record 
                      if there is already Account Splits present whose accounts have Ship To Share% greater than Zero.
     * @name preventToUpdateAccSplitTempRecords 
     * @param acc - Account instance
     * @param acctSplit - Account_Split__c instance
     * @return Account_Split__c
     */
     public static void preventToUpdateAccSplitTempRecords(Map<Id,Target_Split_Template__c> mapNewAccSplitTemps,Map<Id,Target_Split_Template__c> mapOldAccSplitTemps){
        
        Set<Id> setAccSplitTempIds = new Set<Id>();
        for(Target_Split_Template__c ast : mapNewAccSplitTemps.values()){
            if(ast.Automatically_Split_to_Ship_To__c != mapOldAccSplitTemps.get(ast.Id).Automatically_Split_to_Ship_To__c){
                if(ast.Automatically_Split_to_Ship_To__c){
                    setAccSplitTempIds.add(ast.Id);
                }
            }
        }
        
        if(!setAccSplitTempIds.isEmpty()){
            for(Account_Split__c asp : [SELECT Target_Split_Template__c,Account__r.Account_Split_Share__c From Account_Split__c WHERE Target_Split_Template__c IN :setAccSplitTempIds]){
                if(asp.Account__r.Account_Split_Share__c != null){
                    mapNewAccSplitTemps.get(asp.Target_Split_Template__c).addError(System.label.CRM_Account_Split_Template_Update_Error_Msg);
                }
            }
        }
     }
}