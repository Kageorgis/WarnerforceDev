/*******************************************************************************************************************************************
* File Name     :   WB_checkAPOflagHandler
* Description   :   Handler to check if any one of the storefront has APO flag set to Yes then only its Accounts APO flag can be set to Yes.
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     10 Dec.2015        CTS                ER-000008 : Created the class.
* 2.0       
********************************************************************************************************************************************/

public class WB_checkAPOflagHandler {
    public static void checkStoreFrontAPO(List<Account> newList)
    {
        set<Id> SetAccountId = new set<Id>();
        
        for(Account objAcc : newList) {
            if(objAcc.APO__c == 'Yes') {
                SetAccountId.add(objAcc.Id);
            }
        }
        
        if(SetAccountId.size() > 0) {
            List<Agreement__c> storefrontList = [Select Id, Account__c, APO__c, Status__c from Agreement__c 
                                                where Status__c =: 'Active' and Account__c IN: SetAccountId];
            
            map<Id, List<Agreement__c>> mapAccountIdToStorefronts = new map<Id, List<Agreement__c>>();
            for(Agreement__c objSF : storefrontList) {
                List<Agreement__c> lstSF = new List<Agreement__c>();
                if(mapAccountIdToStorefronts.containsKey(objSF.Account__c)) {
                    lstSF = mapAccountIdToStorefronts.get(objSF.Account__c);
                    lstSF.add(objSF);
                } else {
                    lstSF.add(objSF);
                }
                mapAccountIdToStorefronts.put(objSF.Account__c, lstSF);
            }
            system.debug('------mapAccountIdToStorefronts------'+mapAccountIdToStorefronts);
            
            for(Account objAccount : newList) {
                Boolean isAPO = false;
                if(mapAccountIdToStorefronts.containsKey(objAccount.Id)) {
                    List<Agreement__c> lstSF = mapAccountIdToStorefronts.get(objAccount.Id);
                    for(Agreement__c objSF : lstSF) {
                        if(objSF.APO__c == 'Yes') {
                            isAPO = true;
                        }
                    }
                }
                if(isAPO == false) {
                    objAccount.addError(Label.WB_Account_Storefront_APO_Flag);
                }
            }
        }
    }
}