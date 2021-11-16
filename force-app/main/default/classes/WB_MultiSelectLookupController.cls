public class WB_MultiSelectLookupController {
    
    @AuraEnabled
    public static List<sobject> loadRec(Id recId) {
        System.debug('recId==='+recId);
        
        Promotion__c proRec = [Select Id, Country__c from Promotion__c WHere Id = :recId limit 1];
        if(proRec.Country__c != null)
        {
            List<String> countriesName = proRec.Country__c.split(';');
            System.debug('countriesName==='+countriesName);
            List<sobject> lstCount= [Select Id, Name FROM Country__c WHERE Name IN :countriesName ORDER BY Name];
            
            System.debug('lstCount==='+lstCount);
            return lstCount;
        }
        return null;
    }
    
    @AuraEnabled
    public static List<sobject> loadCountries(Id recId) {
        System.debug('recId==='+recId);
        Set<Id> setCount = new Set<Id>();
        //Promotion__c proRec = [SELECT Id, Country__c, Account__c FROM Promotion__c WHERE Id = :recId];
        //List<Agreement__c> lstSF = [SELECT Id, Account__c , Country__c FROM Agreement__c WHERE Account__c = :proRec.Account__c AND Status__c = 'Active' AND Country__r.Status__c = 'Active'];
        //Account Logic for storefront
        /*Promotion__c proRec = [SELECT Id, Country__c, Account__c,Account_Multipicklist__c FROM Promotion__c WHERE Id = :recId];
        if(proRec.Account_Multipicklist__c != '' && proRec.Account_Multipicklist__c != null)
        {
            List<String> lstAccountNames = proRec.Account_Multipicklist__c.split(';');
            List<Agreement__c> lstSF = [SELECT Id, Account__c , Country__c FROM Agreement__c WHERE Account__r.Name IN :lstAccountNames AND Status__c = 'Active' AND Country__r.Status__c = 'Active'];
            System.debug('lstSF==='+lstSF);
            for(Agreement__c sf : lstSF)
            {
                setCount.add(sf.Country__c);
            }
        }*/
        User userDetail = [SELECT Id,Territory__c  from User where Id =: Userinfo.getUserId()];
        List<Country__c> countries = new List<Country__c>();
        //For Account Storefront
        /*if(userDetail.Territory__c == 'Home Office')
            countries = [SELECT Id, Name FROM Country__c WHERE Status__c = 'Active' AND Id IN :setCount ORDER BY name];
        else
            countries = [SELECT Id, Name FROM Country__c WHERE territory__c =: userDetail.Territory__c AND Status__c = 'Active' AND Id IN :setCount ORDER BY name];*/
        
        if(userDetail.Territory__c == 'Home Office')
            countries = [SELECT Id, Name FROM Country__c WHERE Status__c = 'Active' ORDER BY name];
        else
            countries = [SELECT Id, Name FROM Country__c WHERE territory__c =: userDetail.Territory__c AND Status__c = 'Active' ORDER BY name];

        return countries;
    }
    
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, List<sObject> ExcludeitemsList) {
        //ObjectName='Country_Group_Country__c';
        String ObjectName='Country_Groups__c';
        System.debug('ExcludeitemsList==='+ExcludeitemsList);
        System.debug('searchKeyWord==='+searchKeyWord);
        //System.debug('ExcludeitemsList Id==='+ExcludeitemsList[0].Country_Group__c);
        String searchKey = '%' + searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
        
        Set<Id> lstExcludeitems = new Set<Id>();
        if( ExcludeitemsList != null )
        for(sObject item : ExcludeitemsList ){
            lstExcludeitems.add(item.Id);
        }
        
        //List<Country_Group_Country__c> countryGroupIdLst = [SELECT Id, Country_Group__c FROM Country_Group_Country__c WHERE Id IN: lstExcludeitems];
        //Set<Id> excludeIds = new Set<Id>();
        //for(Country_Group_Country__c cgc : countryGroupIdLst)
        //{
        //    excludeIds.add(cgc.Country_Group__c);
        //}
        
        //System.debug('excludeIds==='+excludeIds);
        
        String sQuery =  'select id, Name,Country__c from ' +ObjectName + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems ORDER BY Name';
        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
     @AuraEnabled
    public static List < sObject > fetchCountryNames(String searchKeyWord, List<sObject> ExcludeitemsList,List<sObject> selectedRecords,List<sObject> availableCountries ) {
        //ObjectName='Country_Group_Country__c';
        String ObjectName='Country__c';
        System.debug('searchKeyWord==='+searchKeyWord);
        System.debug('ExcludeitemsList==='+ExcludeitemsList);
        //System.debug('ExcludeitemsList Id==='+ExcludeitemsList[0].Country_Group__c);
        String searchKey = '%' + searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
        Set < Id > availableCountriesIds = new Set < Id > ();
        
        Set<Id> lstExcludeitems = new Set<Id>();
        if( ExcludeitemsList != null )
        for(sObject item : ExcludeitemsList ){
            lstExcludeitems.add(item.Id);
        }
        
        if( selectedRecords != null )
        for(sObject item : selectedRecords ){
            lstExcludeitems.add(item.Id);
        }
        
        if( availableCountries != null)
        for(sObject item : availableCountries)
        {
            availableCountriesIds.add(item.Id);
        }
        System.debug('lstExcludeitems==='+lstExcludeitems);
        System.debug('availableCountriesIds==='+availableCountriesIds);
        String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems AND Id IN :availableCountriesIds ORDER BY Name';
        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    @AuraEnabled
    public static List < sObject > fetchCountryValues(sObject selectedRec, List<sObject> existingItems, List<sObject> availableCountries) {
        System.debug('In APEX CONTROLLER 2===');
        System.debug('existingItems==='+existingItems);
        System.debug('selectedRec==='+selectedRec.Id);
        Id recId = selectedRec.Id;
        String ObjectName='Country_Group_Country__c';
        
        Set < Id > countryIds = new Set < Id > ();
        Set < Id > availableCountriesIds = new Set < Id > ();
        List < sObject > returnList = new List < sObject > ();
        
        Set<Id> lstExistingItems = new Set<Id>();
        if( availableCountries != null)
        for(sObject item : availableCountries)
        {
            availableCountriesIds.add(item.Id);
        }
        if( existingItems != null)
        for(sObject item : existingItems ){
            lstExistingItems.add(item.Id);
        }
        
        //String sQuery =  'select id, Name, Country__r.Name,Country__c,Country_Group__r.Name from ' +ObjectName + ' where Country_Group__c =: recId AND Id NOT IN : lstExcludeitems';
        String sQuery =  'select id, Name, Country__r.Name,Country__c,Country_Group__r.Name from ' +ObjectName + ' where Country_Group__c =: recId';
        List < Country_Group_Country__c > lstOfRecords = Database.query(sQuery);
        for (Country_Group_Country__c obj: lstOfRecords)
        {
            countryIds.add(obj.Country__c);
        }
        
        countryIds.addAll(lstExistingItems);
        
        for (Country__c count: [SELECT Id,Name FROM Country__c WHERE ID IN :countryIds AND ID IN :availableCountriesIds ORDER BY Name])
        {
            returnList.add(count);
        }
        System.debug('returnList==='+returnList.size());
        return returnList;
    }
    
    @AuraEnabled
    public static List < sObject > fetchCountryValuesCountry(sObject selectedRec, List<sObject> existingItems, List<sObject> availableCountries) {
        System.debug('existingItems==='+existingItems);
        System.debug('selectedRec==='+selectedRec.Id);
        Id recId = selectedRec.Id;
        
        Set < Id > countryIds = new Set < Id > ();
        Set < Id > availableCountriesIds = new Set < Id > ();
        List < sObject > returnList = new List < sObject > ();
        
        countryIds.add(recId);
        System.debug('countryIds==='+countryIds);
        
        Set<Id> lstExistingItems = new Set<Id>();
        if( availableCountries != null)
        for(sObject item : availableCountries)
        {
            availableCountriesIds.add(item.Id);
        }
        if( existingItems != null)
        for(sObject item : existingItems ){
            lstExistingItems.add(item.Id);
        }
        
        countryIds.addAll(lstExistingItems);
        
        for (Country__c count: [SELECT Id,Name FROM Country__c WHERE ID IN :countryIds AND ID IN :availableCountriesIds ORDER BY Name])
        {
            returnList.add(count);
        }
        System.debug('returnList==='+returnList.size());
        return returnList;
    }
    
    @AuraEnabled
    public static void saveRec(Id recId, List<Country__c> countData) {
        System.debug('recId==='+recId);
        System.debug('countData==='+countData);
        System.debug('In APEX CONTROLLER 2===');
        String ObjectName='Promotion__c';
        String countryData='';
        Set<Id> setId = new Set<Id>();

        Promotion__c pro= [Select Id, Country__c from Promotion__c WHere Id = :recId];
        
        if(countData !=null && countData.size() > 0)
        {
            for(Country__c cd : countData)
            {
                countryData += cd.Name+';';
            }
            
            System.debug('countryData==='+countryData);

            pro.Country__c=countryData.removeEnd(';');
        }
        else
        {
        	pro.Country__c=null;
        }
        
		update pro;
    }
}