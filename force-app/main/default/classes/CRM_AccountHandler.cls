/**
   @Author Cognizant
   @name CRM_AccountHandler 
   @CreateDate 27 DEC 2016
   @Description This class will update Physical Product Flag.
   @Version <1.0>
*/
public with sharing class CRM_AccountHandler {
    public static void executeBeforeInsert(List<Account> newAccounts){
        Map<String, CRM_Account_Settings__c> mapAccountSetting = CRM_Account_Settings__c.getAll();
        for(Account acc : newAccounts){
            setNRValues(acc, mapAccountSetting);
        }
    }

    private static void setNRValues(Account accountInstance, Map<String, CRM_Account_Settings__c> mapAccountSetting) {
        if(accountInstance.Storefront__c == null) {
            if (mapAccountSetting.containsKey(accountInstance.Sales_Organization__c) && mapAccountSetting.get(accountInstance.Sales_Organization__c).Type__c == 'Physical') {
                List<String> subTypes = mapAccountSetting.get(accountInstance.Sales_Organization__c).Sub_Type__c.split(',');
                for (String subType : subTypes) {
                    accountInstance.put(subType, mapAccountSetting.get(accountInstance.Sales_Organization__c).Value__c);
                }
                /*acc.Video_Physical__c = true;

                    if(acc.Sales_Organization__c == CRM_AppConstants.TERRITORY_JAPAN_CODE)
                        acc.Music_Physical__c = true;*/
            }
        } else if (mapAccountSetting.containsKey(accountInstance.Digital_Country_Code__c) && mapAccountSetting.get(accountInstance.Digital_Country_Code__c).Type__c == 'Digital') {
            List<String> subTypes = mapAccountSetting.get(accountInstance.Digital_Country_Code__c).Sub_Type__c.split(',');
            for (String subType : subTypes) {
                accountInstance.put(subType, mapAccountSetting.get(accountInstance.Digital_Country_Code__c).Value__c);
            }
        }
    }
}