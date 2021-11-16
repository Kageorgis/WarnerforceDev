public class WB_MainMultiSelectController {
    
    @AuraEnabled
    public static List<sobject> mainLoadCountries(Id recId) {
        return WB_MultiSelectLookupController.loadCountries(recId);
    }
    
    @AuraEnabled
    public static Boolean saveRec(Id recId, List<Country__c> lstCountries, List<Account> lstAccount) {
        System.debug('recId==='+recId);
        System.debug('lstCountries==='+lstCountries);
        System.debug('lstAccount==='+lstAccount);
        System.debug('In APEX CONTROLLER 2===');
        String ObjectName='Promotion__c';
        String countryData='';
        String accountData='';
        Set<Id> setId = new Set<Id>();
        
        Promotion__c pro= [Select Id, Country__c,Account_Multipicklist__c,OwnerId,CreatedById from Promotion__c WHere Id = :recId];
        
        if(lstCountries !=null && lstCountries.size() > 0)
        {
            for(Country__c cd : lstCountries)
            {
                countryData += cd.Name+';';
            }
            
            System.debug('countryData==='+countryData);
            
            pro.Country__c=countryData.removeEnd(';');
            
            if(lstAccount !=null && lstAccount.size() > 0)
            {
                List<String> lstCountryName = pro.Country__c.split(';');
                List<Agreement__c> lstSF = [SELECT Id,Account__c,Account__r.Name FROM Agreement__c WHERE Country__r.Name IN: lstCountryName];
                List<String> lstAccountNames = new List<String>();
                if(!lstSF.isEmpty())
                {
                    for(Agreement__c sf : lstSF)
                    {
                        lstAccountNames.add(sf.Account__r.Name);
                    }
                }
                for(Account acc : lstAccount)
                {
                    if(!lstAccountNames.contains(acc.Name) )
                        return false;
                    accountData += acc.Name+';';
                }
                
                System.debug('accountData==='+accountData);
                
                pro.Account_Multipicklist__c=accountData.removeEnd(';');
            }
            else
            {
                pro.Account_Multipicklist__c=null;
            }
        }
        else if(lstAccount !=null && lstAccount.size() > 0)
        {
            return false;
        }
        else
        {
            pro.Country__c = null;
            pro.Account_Multipicklist__c = null;
        }
        
        
        	update pro;
        
        return true;
    }
    
    @AuraEnabled
    public static Promotion__c getPromotionRecord(Id recId) {
        return [Select Id,Name FROM Promotion__c WHERE Id = :recId];
    }
    
    @AuraEnabled
    public static  List<Decimal> getCustomSettings()
    {
        Map<String, WB_Promotion_Limits__c> promoLimits = WB_Promotion_Limits__c.getAll();
        List<Decimal> limits = new List<Decimal>();
        limits.add(promoLimits.get('MaxCountriesAllowed').Limit_Size__c);
        limits.add(promoLimits.get('MaxAccountsAllowed').Limit_Size__c);
        return limits;
    }
}