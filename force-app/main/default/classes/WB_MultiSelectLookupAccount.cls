public class WB_MultiSelectLookupAccount {
    @AuraEnabled
    public static List<sobject> loadRec(Id recId) {
        System.debug('recId==='+recId);
        
        Promotion__c proRec = [Select Id, Account_Multipicklist__c from Promotion__c WHere Id = :recId limit 1];
        if(proRec.Account_Multipicklist__c != null)
        {
            List<String> accountNames = proRec.Account_Multipicklist__c.split(';');
            System.debug('accountNames==='+accountNames);
            List<sobject> lstAccount= [Select Id, Name FROM Account WHERE Name IN :accountNames AND RecordType.Name = 'Digital Client' ORDER BY Name];
            
            System.debug('lstAccount==='+lstAccount);
            return lstAccount;
        }
        return null;
    }
    
    @AuraEnabled
    public static List<sobject> searchAccounts(String searchKeyWord, List<Account> ExcludeAccounts,List<Country__c> lstCountries)
    {
        System.debug('lstCountries==='+lstCountries);
        Set<Id> setCountId = new Set<Id>();
        if(!lstCountries.isEmpty() )
        {
            for(Country__c count : lstCountries)
            {
                setCountId.add(count.Id);
            }
            List<Agreement__c> lstSF = [SELECT Id,Account__c,Account__r.Name FROM Agreement__c WHERE Country__c IN: setCountId AND Status__c = 'Active'];
            if(!lstSF.isEmpty())
            {
                List<String> lstAccountNames = new List<String>();
                for(Agreement__c sf : lstSF)
                {
                    lstAccountNames.add(sf.Account__r.Name);
                }
                String searchKey = '%' + searchKeyWord + '%';
                List<String> lstExcludeAccountNames = new List<String>();
                if(ExcludeAccounts != null && !ExcludeAccounts.isEmpty())
                {
                    for(Account acc : ExcludeAccounts)
                    {
                        lstExcludeAccountNames.add(acc.Name);
                    }
                }
                List<Account> lstAccount = [SELECT Id,Type,Name FROM Account WHERE Type IN ('Global','Local') AND RecordType.Name = 'Digital Client' AND Name NOT IN :lstExcludeAccountNames AND Name IN: lstAccountNames AND Name LIKE :searchKey ORDER BY Name];
                return lstAccount;
            }
            return new List<Account>();
        }
        return new List<Account>();
    }
    
    @AuraEnabled
    public static List < sObject > fetchAccounts(sObject selectedRec, List<sObject> existingItems) {
        System.debug('In APEX CONTROLLER 2===');
        System.debug('existingItems==='+existingItems);
        System.debug('selectedRec==='+selectedRec.Id);
        Set<Id> selectedIDs = new Set<Id>();
        selectedIDs.add(selectedRec.Id);
        if(existingItems != null && !existingItems.isEmpty())
            for(sObject acc : existingItems)
        {
            selectedIDs.add(acc.Id);
        }
        List<Account> returnList = [SELECT Id,Name FROM Account WHERE ID IN :selectedIDs ORDER BY Name];
        if(!returnList.isEmpty())
        return returnList;
        return new List<Account>();
    }
    
    @AuraEnabled
    public static void saveRec(Id recId, List<Account> lstAccount) {
        System.debug('recId==='+recId);
        System.debug('lstAccount==='+lstAccount);
        System.debug('In APEX CONTROLLER 2===');
        String ObjectName='Promotion__c';
        String accountData='';
        Set<Id> setId = new Set<Id>();
        
        Promotion__c pro= [Select Id, Account_Multipicklist__c from Promotion__c WHere Id = :recId];
        
        if(lstAccount !=null && lstAccount.size() > 0)
        {
            for(Account acc : lstAccount)
            {
                accountData += acc.Name+';';
            }
            
            System.debug('accountData==='+accountData);
            
            pro.Account_Multipicklist__c=accountData.removeEnd(';');
        }
        else
        {
            pro.Account_Multipicklist__c=null;
        }
        
        update pro;
    }
}