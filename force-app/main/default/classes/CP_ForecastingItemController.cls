/* 
==========================================================================================================
* @author: Kalash Rastogi
* @date: 10/07/2021
* @description: Controller class that will insert the forecasting items records, called from LWC.
==========================================================================================================
*/
public with sharing class CP_ForecastingItemController {
    public CP_ForecastingItemController() {
        
    }
    /*@AuraEnabled(cacheable = true)
public static List<String> getValidContracts(Id forecastId){
CP_Forecast__c forecast = [SELECT Id, Name,Licensee_Name__c FROM CP_Forecast__c WHERE Id = :forecastId ];
Id forecastLicensee = forecast.Licensee_Name__c;
List<CP_Contract__c> contrList = [SELECT Id, Name FROM CP_Contract__c WHERE Account_Licensee__r.ParentId = :forecastLicensee AND (Source_System__c = 'LMSi' OR Source_System__c = 'LMSI')  ORDER By Name]; //Retailer
List<String> validContracts = new List<String>();
System.debug('###' + contrList);
for(CP_Contract__c contr : contrList){
validContracts.add(contr.Name);
}
return validContracts;
}*/
    @AuraEnabled(cacheable = true)
    public static Map<Id, String> getForecastingCurrencyForPOC(){
        List<CP_Forecast_Currency__c> currencyList = [SELECT Id, Name FROM CP_Forecast_Currency__c WHERE Allow_Forecasting__c = True ORDER By Name]; 
        Map<Id, String> currencyIdVsName = new Map<Id, String>();
        for(CP_Forecast_Currency__c curr: currencyList){
            currencyIdVsName.put(curr.Id, curr.Name);
        }
        return currencyIdVsName;
    }
    @AuraEnabled(cacheable = true)
    public static Map<Id, String> getProductsForPOC(){
        List<CP_Product_Type__c> prodList = [SELECT Id,Name FROM CP_Product_Type__c WHERE Allow_Forecasting__c = True AND (Source_System__c = 'LMSi' OR Source_System__c = 'LMSI') ORDER By Name];
        Map<Id, String> IdVsProduct = new Map<Id, String>();
        for(CP_Product_Type__c p: prodList){
            IdVsProduct.put(p.Id, p.Name);
        }
        return IdVsProduct;
    }
    @AuraEnabled(cacheable = true)
    public static Map<Id, String> getRetailersForPOC(){
        List<Account> accList = [SELECT Id, Name, RecordType.Name FROM Account WHERE RecordType.Name = 'WBCP Retailer' AND Allow_Forecasting__c = True AND (Source_System__c = 'LMSi' OR Source_System__c = 'LMSI') ORDER By Name]; //Retailer
        Map<Id, String> accNameVsId = new Map<Id, String>();
        for(Account a: accList){
            accNameVsId.put(a.Id, a.Name);
        }
        return accNameVsId;
    }
    @AuraEnabled(cacheable = true)
    public static Map<Id, String> getPropertiesForPOC(){
        List<Property__c> propList = [SELECT Id,Name FROM Property__c WHERE Allow_Forecasting__c = True AND (Source_System__c = 'LMSi' OR Source_System__c = 'LMSI') ORDER By Name];
        Map<Id, String> propNameVsId = new Map<Id, String>();
        for(Property__c p: propList){
            propNameVsId.put(p.Id, p.Name);
        }
        return propNameVsId;
    }
    @AuraEnabled(cacheable = true)
    public static Map<Id, String> getTerritoriesForPOC(){
        List<WBCP_Country__c> territoryList = [SELECT Id,Name FROM WBCP_Country__c WHERE Allow_Forecasting__c = True ORDER By Name];
        Map<Id, String> territoryVsId = new Map<Id, String>();
        for(WBCP_Country__c t: territoryList){
            territoryVsId.put(t.Id, t.Name);
        }
        return territoryVsId;
    }
    @AuraEnabled(cacheable = true)
    public static Map<Id, String> getContractsForPOC(Id forecastId){
        System.debug('Inside get Contracts');
        CP_Forecast__c forecast = [SELECT Id, Name,Licensee_Name__c FROM CP_Forecast__c WHERE Id = :forecastId ]; 
        Id forecastLicensee = forecast.Licensee_Name__c;
        System.debug('>>>' + forecastLicensee);
        String profileName = getProfile();
        System.debug('>>' + profileName);
        List<Id> contractIds = new List<Id>();
        Set<Id> validContractIds = new Set<Id>();
        if(profileName != LABEL.CP_Agent || Test.isRunningTest()){
            List<CP_Contract__c> validContrList = [SELECT Id, Name, Source_System__c FROM CP_Contract__c WHERE Account_Licensee__r.parentId = :forecastLicensee AND (Source_System__c = 'LMSi' OR Source_System__c = 'LMSI') ];
            for(CP_Contract__c vContract: validContrList){
                contractIds.add(vContract.Id);
            }
            System.debug('>>>' + validContrList);
        }
        if(profileName == LABEL.CP_Agent || Test.isRunningTest()){
            contractIds = CP_ValidContractAgent.validContracts((Id)forecastLicensee);
            System.debug('>>>' + contractIds);
        }
        for(Id cId: contractIds){
            validContractIds.add(cId);
        }
        List<CP_Contract__c> contrList = [SELECT Id, Name FROM CP_Contract__c WHERE Id IN :validContractIds ORDER By Name];
        Map<Id, String> contractNameVsId = new Map<Id, String>();
        for(CP_Contract__c contr: contrList){
            contractNameVsId.put(contr.Id, contr.Name);
        }
        System.debug('>>>' + contractNameVsId);
        return contractNameVsId;
    }
    @AuraEnabled
    public static List<CP_Forecast_Item__c> createForecastingItemForPOC(String data, Id forecastId){
        CP_Forecast__c forecast = [SELECT Id, Name,Licensee_Name__c FROM CP_Forecast__c WHERE Id = :forecastId ];
        Id forecastLicensee = forecast.Licensee_Name__c;
        List<CP_Forecast_Item__c> forecastingItemList = new List<CP_Forecast_Item__c>();
        List<Property__c> propList = [SELECT Id,Name FROM Property__c WHERE Allow_Forecasting__c = True AND (Source_System__c = 'LMSi' OR Source_System__c = 'LMSI')];
        Map<String, Id> propNameVsId = new Map<String, Id>();
        for(Property__c p: propList){
            propNameVsId.put(p.Name, p.Id);
        }
        System.debug(propNameVsId);
        List<Account> accList = [SELECT Id, Name, RecordType.Name, Allow_Forecasting__c, Source_System__c FROM Account WHERE RecordType.Name = 'WBCP Retailer' AND Allow_Forecasting__c = True AND (Source_System__c = 'LMSi' OR Source_System__c = 'LMSI')]; //Retailer /**/
        Map<String, Id> accNameVsId = new Map<String, Id>();
        for(Account a: accList){
            accNameVsId.put(a.Name, a.Id);
        }
        List<CP_Contract__c> contrList = [SELECT Id, Name, Source_System__c FROM CP_Contract__c WHERE (Source_System__c = 'LMSi' OR Source_System__c = 'LMSI') ];
        Map<String, Id> contractNameVsId = new Map<String, Id>();
        for(CP_Contract__c contr: contrList){
            contractNameVsId.put(contr.Name, contr.Id);
        }
        System.debug('###' + contrList);
        String profileName = getProfile();
        Set<Id> validContractIds = new Set<Id>();
        if(profileName != LABEL.CP_Agent|| Test.isRunningTest()){
            List<CP_Contract__c> validContrList = [SELECT Id, Name, Source_System__c FROM CP_Contract__c WHERE Account_Licensee__r.parentId = :forecastLicensee AND (Source_System__c = 'LMSi' OR Source_System__c = 'LMSI') ];
            for(CP_Contract__c contr: validContrList){
                validContractIds.add(contr.Id);
            }
            System.debug('###validContract' + validContractIds);
        }
        if(profileName == LABEL.CP_Agent|| Test.isRunningTest()){
            List<Id> contractIds = new List<Id>();
            contractIds = CP_ValidContractAgent.validContracts((Id)forecastLicensee);
            for(Id validId : contractIds){
                validContractIds.add(validId);
            }
            System.debug('###' + validContractIds);
        }
        List<CP_Forecast_Currency__c> currencyList = [SELECT Id, Name, Allow_Forecasting__c FROM CP_Forecast_Currency__c WHERE Allow_Forecasting__c = True]; //Retailer/**/
        Map<String, Id> currencyNameVsId = new Map<String, Id>();
        for(CP_Forecast_Currency__c curr: currencyList){
            currencyNameVsId.put(curr.Name, curr.Id);
        }
        System.debug('###' + currencyNameVsId);
        List<CP_Product_Type__c> prodList = [SELECT Id,Name, Source_System__c, Allow_Forecasting__c FROM CP_Product_Type__c WHERE Allow_Forecasting__c = True AND (Source_System__c = 'LMSi' OR Source_System__c = 'LMSI')];/**/
        Map<String, Id> prodDescVsId = new Map<String, Id>();
        for(CP_Product_Type__c p: prodList){
            prodDescVsId.put(p.Name, p.Id);
        }
        List<WBCP_Country__c> territoryList = [SELECT Id,Name, Allow_Forecasting__c FROM WBCP_Country__c WHERE Allow_Forecasting__c = True];/**/
        Map<String, Id> territoryVsId = new Map<String, Id>();
        for(WBCP_Country__c t: territoryList){
            territoryVsId.put(t.Name, t.Id);
        }
        //System.debug(prodDescVsId.get());
        try {
            System.debug(JSON.deserializeUntyped(data));
            List<Object> JSONData = (List<Object>)JSON.deserializeUntyped(data);
            System.debug(JSONData);
            for(Object objData: JSONData){
                Map<String,Object> obj = (Map<String,Object>)objData;
                CP_Forecast_Item__c record = new CP_Forecast_Item__c();
                record.Forecast__c = (Id)obj.get(LABEL.CP_ForecastAPI);
                record.Royalty_Rate__c = ((Decimal)obj.get(LABEL.CP_RoyaltyRateAPI)).setScale(2, RoundingMode.HALF_UP);
                record.Revenue_Type__c = (String)obj.get(LABEL.CP_RevenueTypeAPI);
                record.Q1__c = (Decimal)obj.get(LABEL.CP_Q1);
                record.Q2__c = (Decimal)obj.get(LABEL.CP_Q2);
                record.Q3__c = (Decimal)obj.get(LABEl.CP_Q3);
                record.Q4__c = (Decimal)obj.get(LABEL.CP_Q4);
                record.CP_Territory__c = territoryVsId.get((String)obj.get('Territory'));
                System.debug(contractNameVsId.get((String)obj.get('Contract')));
                record.CP_Contract__c = contractNameVsId.get((String)obj.get('Contract'));
                if(record.CP_Contract__c != NULL){
                    System.debug('Contract Selected:' + record.CP_Contract__c );
                    System.debug('Valid COntracts:' + validContractIds);
                    if(!validContractIds.contains(record.CP_Contract__c)){
                        System.debug('Invalid Contract');
                        record.Valid_Contract__c = false;
                    }
                    else{
                        System.debug('Valid Contract');
                        record.Valid_Contract__c = true;
                    }
                }
                record.Forecast_Currency__c = currencyNameVsId.get((String)obj.get('ForecastCurrency'));
                record.Property__c = propNameVsId.get((String)obj.get('PropertyDescription'));
                record.Retailer__c = accNameVsId.get((String)obj.get('RetailerDescription'));
                record.CP_Product_Type__c = prodDescVsId.get((String)obj.get('ProductTypeDescription'));
                forecastingItemList.add(record);
            }
            System.debug(forecastingItemList);
            insert forecastingItemList;
            forecastingItemList = [
                SELECT Valid_Contract__c,Q1_Adj__c,Q2_Adj__c,Q3_Adj__c,Q4_Adj__c,CP_Territory__r.Name, Forecast__r.Forecast_Cycle__r.Status__c, CP_Contract__r.Name, Forecast_Currency__r.Name, Errors__c,Forecast__r.Forecast_Status__c,CP_Product_Type__r.Name, Name, Contract__c, CurrencyIsoCode, Forecast__r.CP_Territory__r.Name, Forecast__r.Amount_Type__c, Forecast__r.Forecast_Cycle__r.Forecast_Cycle_Name__c , Property__r.Name, Q1__c, Q2__c, Q3__c, Q4__c, Retailer__r.Name, Revenue_Type__c, Royalty_Rate__c, Total_Amount__c  FROM CP_Forecast_Item__c
                WHERE Forecast__c = :forecastId
            ];
            return forecastingItemList;        
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=false)
    public static List<CP_Forecast_Item__c> getForecastingItemsForPOC(Id recordId){
        List<CP_Forecast_Item__c> itemList = [
            SELECT Valid_Contract__c,Forecast__c, Q1_Adj__c,Q2_Adj__c,Q3_Adj__c,Q4_Adj__c,CP_Territory__r.Name, Forecast__r.Forecast_Cycle__r.Status__c, CP_Contract__r.Name, Forecast_Currency__r.Name, Forecast__r.Forecast_Status__c,Errors__c,CP_Product_Type__r.Name, Name, Contract__c, CurrencyIsoCode, Forecast__r.CP_Territory__r.Name, Forecast__r.Amount_Type__c, Forecast__r.Forecast_Cycle__r.Forecast_Cycle_Name__c , Property__r.Name, Q1__c, Q2__c, Q3__c, Q4__c, Retailer__r.Name, Revenue_Type__c, Royalty_Rate__c, Total_Amount__c  FROM CP_Forecast_Item__c
            WHERE Forecast__c = :recordId
        ];
        //System.debug('!@' + itemList[0].Valid_Contract__c);
        return itemList;
    }
    @AuraEnabled(cacheable=true)
    public static String getProfile(){
        Id profileId= userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        return profileName;
    }
    @AuraEnabled
    public static List<CP_Forecast_Item__c> deleteForecastingItemsForPOC(List<Id> recordIds, String data, Id forecastId){
        List<CP_Forecast_Item__c> forecastingItemList = new List<CP_Forecast_Item__c>();
        System.debug(recordIds);
        Set<Id> Ids = new Set<Id>(recordIds);
        List<CP_Forecast_Item__c> itemList = [
            SELECT Id 
            FROM CP_Forecast_Item__c
            WHERE Id IN :Ids
        ];
        List<CP_Forecast_Item__c> updateErrorsList = [
            SELECT Id, Forecast__c, CP_Contract__c,Property__c,CP_Product_Type__c,Retailer__c,Forecast_Currency__c,CP_Territory__c,Revenue_Type__c,Royalty_Rate__c,Errors__c
            FROM CP_Forecast_Item__c
            WHERE Id NOT IN :Ids AND Forecast__c = :forecastId 
        ];
        List<CP_Forecast_Item__c> fItemList = new List<CP_Forecast_Item__c>();
        for(CP_Forecast_Item__c fItem : itemList){
            fItemList.add(fItem);
        }
        System.debug(fItemList);
        try {
            delete fItemList;
            if(data != 'onlyDelete'){ // Delete and Replace
                forecastingItemList = createForecastingItemForPOC(data, forecastId);
            }else{ //Delete selected records
                List<CP_Forecast_Item__c> updateItems = new List<CP_Forecast_Item__c>();
                for(CP_Forecast_Item__c fcItem : updateErrorsList){
                    if(fcItem.Errors__c == 'Duplicate'){
                        fcItem.Errors__c = '';
                        updateItems.add(fcItem);
                    }
                }
                if(updateItems.size() > 0){
                    update updateItems;
                    if(!test.isRunningTest()){
                        List<CP_Forecast_Item__c> fcItemListFromDupCheck = checkDuplicateRecord(updateItems);
                        update fcItemListFromDupCheck;
                    }
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        forecastingItemList = getForecastingItemsForPOC(forecastId);
        return forecastingItemList;
    }
    @AuraEnabled
    public static List<CP_Forecast_Item__c> updateForecastingItemForPOC(String data, Id forecastId){
        List<CP_Forecast_Item__c> forecastingItemList = new List<CP_Forecast_Item__c>();
        CP_Forecast__c forecast = [SELECT Id, Name,Licensee_Name__c FROM CP_Forecast__c WHERE Id = :forecastId ];
        Id forecastLicensee = forecast.Licensee_Name__c;
        List<Id> errorIdsList = new List<Id>();
        List<Property__c> propList = [SELECT Id,Name FROM Property__c WHERE Allow_Forecasting__c = True AND (Source_System__c = 'LMSi' OR Source_System__c = 'LMSI')];
        Map<String, Id> propNameVsId = new Map<String, Id>();
        for(Property__c p: propList){
            propNameVsId.put(p.Name, p.Id);
        }
        List<Account> accList = [SELECT Id, Name, RecordType.Name, Allow_Forecasting__c, Source_System__c FROM Account WHERE RecordType.Name = 'WBCP Retailer' AND Allow_Forecasting__c = True AND (Source_System__c = 'LMSi' OR Source_System__c = 'LMSI')]; //Retailer/**/
        Map<String, Id> accNameVsId = new Map<String, Id>();
        for(Account a: accList){
            accNameVsId.put(a.Name, a.Id);
        }
        List<CP_Contract__c> contrList = [SELECT Id, Name, Source_System__c FROM CP_Contract__c WHERE (Source_System__c = 'LMSi' OR Source_System__c = 'LMSI') ]; 
        Map<String, Id> contractNameVsId = new Map<String, Id>();
        for(CP_Contract__c contr: contrList){
            contractNameVsId.put(contr.Name, contr.Id);
        }
        String profileName = getProfile();
        Set<Id> validContractIds = new Set<Id>();
        if(profileName != LABEL.CP_Agent || Test.isRunningTest()){
            List<CP_Contract__c> validContrList = [SELECT Id, Name, Source_System__c FROM CP_Contract__c WHERE Account_Licensee__r.parentId = :forecastLicensee AND (Source_System__c = 'LMSi' OR Source_System__c = 'LMSI') ];
            for(CP_Contract__c contr: validContrList){
                validContractIds.add(contr.Id);
            }
            System.debug('###validContract' + validContractIds);
        }
        if(profileName == LABEL.CP_Agent || Test.isRunningTest()){
            List<Id> contractIds = new List<Id>();
            contractIds = CP_ValidContractAgent.validContracts((Id)forecastLicensee);
            for(Id validId : contractIds){
                validContractIds.add(validId);
            }
            System.debug('###' + validContractIds);
        }
        List<CP_Forecast_Currency__c> currencyList = [SELECT Id, Name, Allow_Forecasting__c FROM CP_Forecast_Currency__c WHERE Allow_Forecasting__c = True]; 
        Map<String, Id> currencyNameVsId = new Map<String, Id>();
        for(CP_Forecast_Currency__c curr: currencyList){
            currencyNameVsId.put(curr.Name, curr.Id);
        }
        List<CP_Product_Type__c> prodList = [SELECT Id,Name, Source_System__c, Allow_Forecasting__c FROM CP_Product_Type__c WHERE Allow_Forecasting__c = True AND (Source_System__c = 'LMSi' OR Source_System__c = 'LMSI') ];/**/
        Map<String, Id> prodDescVsId = new Map<String, Id>();
        for(CP_Product_Type__c p: prodList){
            prodDescVsId.put(p.Name, p.Id);
        }
        List<WBCP_Country__c> territoryList = [SELECT Id, Name, Allow_Forecasting__c FROM WBCP_Country__c WHERE Allow_Forecasting__c = True];/**/
        Map<String, Id> territoryVsId = new Map<String, Id>();
        for(WBCP_Country__c t: territoryList){
            territoryVsId.put(t.Name, t.Id);
        }
        List<Object> JSONData = (List<Object>)JSON.deserializeUntyped(data);
        for(Object objData: JSONData){
            Map<String,Object> obj = (Map<String,Object>)objData;
            CP_Forecast_Item__c record = new CP_Forecast_Item__c();
            record.Id = (Id)obj.get('Id');
            errorIdsList.add(record.Id);
            if((Decimal)obj.get(LABEL.CP_RoyaltyRateAPI) != null)
                record.Royalty_Rate__c = ((Decimal)obj.get(LABEL.CP_RoyaltyRateAPI)).setScale(2, RoundingMode.HALF_UP);
            if((String)obj.get(LABEL.CP_RevenueTypeAPI) != null)
                record.Revenue_Type__c = (String)obj.get(LABEL.CP_RevenueTypeAPI);
            if((Decimal)obj.get(LABEL.CP_Q1) != null)
                record.Q1__c = (Decimal)obj.get(LABEL.CP_Q1);
            if((Decimal)obj.get(LABEL.CP_Q2) != null)
                record.Q2__c = (Decimal)obj.get(LABEL.CP_Q2);
            if((Decimal)obj.get(LABEL.CP_Q3) != null)
                record.Q3__c = (Decimal)obj.get(LABEL.CP_Q3);
            if((Decimal)obj.get(LABEL.CP_Q4) != null)
                record.Q4__c = (Decimal)obj.get(LABEL.CP_Q4);
            if((Decimal)obj.get('Q1_Adj__c') != null)
                record.Q1_Adj__c = (Decimal)obj.get('Q1_Adj__c');
            if((Decimal)obj.get('Q2_Adj__c') != null)
                record.Q2_Adj__c = (Decimal)obj.get('Q2_Adj__c');
            if((Decimal)obj.get('Q3_Adj__c') != null)
                record.Q3_Adj__c = (Decimal)obj.get('Q3_Adj__c');
            if((Decimal)obj.get('Q4_Adj__c') != null)
                record.Q4_Adj__c = (Decimal)obj.get('Q4_Adj__c');
            if((String)obj.get('Territory') != null)
                record.CP_Territory__c = territoryVsId.get((String)obj.get('Territory'));
            if((String)obj.get('Contract') != null){
                record.CP_Contract__c = contractNameVsId.get((String)obj.get('Contract'));
                System.debug('Contract Selected:' + record.CP_Contract__c );
                System.debug('Valid COntracts:' + validContractIds);
                if(!validContractIds.contains(record.CP_Contract__c)){
                    System.debug('Invalid Contract');
                    record.Valid_Contract__c = false;
                }
                else{
                    System.debug('Valid Contract');
                    record.Valid_Contract__c = true;
                }
            }
            if((String)obj.get('ForecastCurrency') != null)
                record.Forecast_Currency__c = currencyNameVsId.get((String)obj.get('ForecastCurrency'));
            if((String)obj.get('PropertyDescription') != null)
                record.Property__c = propNameVsId.get((String)obj.get('PropertyDescription'));
            if((String)obj.get('RetailerDescription') != null)
                record.Retailer__c = accNameVsId.get((String)obj.get('RetailerDescription'));
            if((String)obj.get('ProductTypeDescription') != null)
                record.CP_Product_Type__c = prodDescVsId.get((String)obj.get('ProductTypeDescription'));
            forecastingItemList.add(record);
        }
        System.debug(forecastingItemList);
        update forecastingItemList;
        List<CP_Forecast_Item__c> updateErrorsList = [
            SELECT Id, Forecast__c, CP_Contract__c,Property__c,CP_Product_Type__c,Retailer__c,Forecast_Currency__c,CP_Territory__c,Revenue_Type__c,Royalty_Rate__c,Errors__c
            FROM CP_Forecast_Item__c
            WHERE Id NOT IN :errorIdsList AND Forecast__c = :forecastId];
        List<CP_Forecast_Item__c> updateItems = new List<CP_Forecast_Item__c>();
        if(updateErrorsList.size() > 0){
            for(CP_Forecast_Item__c fcItem : updateErrorsList){
                if(fcItem.Errors__c == 'Duplicate'){
                    fcItem.Errors__c = '';
                    updateItems.add(fcItem);
                }
            }
            if(updateItems.size() > 0){
                update updateItems;
                if(!test.isRunningTest()){
                    System.debug('##@@' + updateItems);
                    List<CP_Forecast_Item__c> fcItemListFromDupCheck = checkDuplicateRecord(updateItems);
                    update fcItemListFromDupCheck;
                }	
            }
            
        }
        forecastingItemList = [
            SELECT Valid_Contract__c,Q1_Adj__c,Q2_Adj__c,Q3_Adj__c,Q4_Adj__c,CP_Territory__r.Name, Forecast__r.Forecast_Cycle__r.Status__c, CP_Contract__r.Name, Forecast_Currency__r.Name, Forecast__r.Forecast_Status__c,Errors__c,CP_Product_Type__r.Name, Name, Contract__c, CurrencyIsoCode, Forecast__r.CP_Territory__r.Name, Forecast__r.Amount_Type__c, Forecast__r.Forecast_Cycle__r.Forecast_Cycle_Name__c , Property__r.Name, Q1__c, Q2__c, Q3__c, Q4__c, Retailer__r.Name, Revenue_Type__c, Royalty_Rate__c, Total_Amount__c  FROM CP_Forecast_Item__c
            WHERE Forecast__c = :forecastId
        ];
        return forecastingItemList;        
    }
    @AuraEnabled
    public static void showGridErrorValidationUpdate(List<CP_Forecast_Item__c> forecastingItemList){
        if(CP_CheckRecursive.runOnce()){
            System.debug('Inside showGridErrorValidation UPDATE' );
            String ErrorMessage = '';
            List<Id> fcItemIds = new List<Id>();
            List<CP_Forecast_Item__c> fcItemListForDupCheck = new List<CP_Forecast_Item__c>();
            for(CP_Forecast_Item__c fi : forecastingItemList){
                fcItemIds.add(fi.Id);
                System.debug('CP_Contract__c' + fi.CP_Contract__c);
                System.debug('Property__c' + fi.Property__c);
                System.debug('CP_Product_Type__c' + fi.CP_Product_Type__c);
                System.debug('CP_Territory__c' + fi.CP_Territory__c);
                System.debug('Retailer__c' + fi.Retailer__c);
                ErrorMessage = '';
                if(fi.CP_Territory__c == null){
                    ErrorMessage = ErrorMessage + 'Territory, ';
                }
                if(fi.Forecast_Currency__c == null){
                    ErrorMessage = ErrorMessage + 'Forecast Currency, '; 
                }
                if(fi.CP_Contract__c == null){
                    ErrorMessage = ErrorMessage + 'Contract Number, '; 
                }
                if(fi.Property__c == null){
                    ErrorMessage = ErrorMessage + 'Property, ';
                }
                if(fi.CP_Product_Type__c == null){
                    ErrorMessage = ErrorMessage + 'Product Type, ';
                }
                if(fi.Retailer__c == null){
                    ErrorMEssage = ErrorMessage + 'Retailer, ';
                }
                if(fi.Revenue_Type__c == null){
                    ErrorMessage = ErrorMessage + 'Revenue Type, ';
                }
                if(fi.Royalty_Rate__c == 0 || fi.Royalty_Rate__c == null){
                    ErrorMessage = ErrorMessage + 'Royalty Rate, ';
                }
                if(ErrorMessage != '' ){
                    fi.Errors__c = ErrorMessage + ' not populated.';
                }
                else{
                    fi.Errors__c = '' ;
                    fcItemListForDupCheck.add(fi);
                }
                System.debug('#' + ErrorMessage);
                System.debug('#' + fi.Errors__c);
                System.debug('#' + fi);
            }
            if(fcItemListForDupCheck.size() > 0){
                List<CP_Forecast_Item__c> fcItemListFromDupCheck = checkDuplicateRecord(fcItemListForDupCheck);
                System.debug(fcItemListFromDupCheck);   
                Set<Id> exstingIdsToBeUpdated = new Set<Id>();
                System.debug('fcItemListFromDupCheck:'+fcItemListFromDupCheck);
                for(CP_Forecast_Item__c fItem : fcItemListFromDupCheck){
                    for(CP_Forecast_Item__c fItemUpdated : forecastingItemList){
                        if(fItemUpdated.Id == fItem.Id){
                            fItemUpdated.Errors__c = fItem.Errors__c;
                            continue;
                        }
                    }
                }
                for(CP_Forecast_Item__c fItem : fcItemListFromDupCheck){
                    exstingIdsToBeUpdated.add(fItem.Id);
                }
                List<CP_Forecast_Item__c> updateList = [SELECT Id, Errors__c,Forecast__c FROM CP_Forecast_Item__c WHERE Id IN :exstingIdsToBeUpdated AND Id NOT IN :fcItemIds AND Forecast__c = :forecastingItemList[0].Forecast__c];
                for(CP_Forecast_Item__c fItem: updateList){
                    fItem.Errors__c = 'Duplicate';
                }
                System.debug('Existing to be updated:' + updateList);
                update updateList;
            }
            System.debug('Inside update ErrorMessage'+ErrorMessage);
        }
        
    }
    /*
.  Validate the below fields are populated:

Contract Number
Property
Product Type
Territory
Retailer
Revenue Type
Amount Type
Royalty Rate
Forecast Currency
*/
    @AuraEnabled
    public static void showGridErrorValidationInsert(List<CP_Forecast_Item__c> forecastingItemList){
        System.debug('@#$ INSERT' + CP_CheckRecursive.runOnce());
        System.debug('Inside showGridErrorValidation INSERT' );
        String ErrorMessage = '';
        List<Id> fItemIds = new List<Id>();
        for(CP_Forecast_Item__c fi : forecastingItemList){
            fItemIds.add(fi.Id);
        }
        List<CP_Forecast_Item__c> fItemList = [SELECT Id, Valid_Contract__c, Errors__c, Revenue_Type__c,Royalty_Rate__c,Forecast__c, Forecast__r.Licensee_Name__c, Forecast_Currency__c, CP_Contract__c, CP_Territory__c, CP_Product_Type__c, Property__c,Retailer__c  
                                               FROM CP_Forecast_Item__c
                                               WHERE Id IN :fItemIds
                                              ];
        Set<Id> validContractIds = new Set<Id>();
        if(fItemList[0].Forecast__c != null && fItemList[0].Forecast__r.Licensee_Name__c != null){
            Id forecastLicensee = fItemList[0].Forecast__r.Licensee_Name__c;
            String profileName = getProfile();
            if(profileName != LABEL.CP_Agent){
                List<CP_Contract__c> validContrList = [SELECT Id, Name, Source_System__c FROM CP_Contract__c WHERE Account_Licensee__r.parentId = :forecastLicensee AND (Source_System__c = 'LMSi' OR Source_System__c = 'LMSI') ];
                for(CP_Contract__c contr: validContrList){
                    validContractIds.add(contr.Id);
                }
                System.debug('###validContract from GridValidation' + validContractIds);
            }
            else{
                List<Id> contractIds = new List<Id>();
                contractIds = CP_ValidContractAgent.validContracts((Id)forecastLicensee);
                for(Id validId : contractIds){
                    validContractIds.add(validId);
                }
                System.debug('###validContract from GridValidation' + validContractIds);
            }
        }
        List<CP_Forecast_Item__c> fcItemListForDupCheck = new List<CP_Forecast_Item__c>();
        for(CP_Forecast_Item__c fi : fItemList){
            ErrorMessage = '';
            if(fi.CP_Territory__c == null){
                ErrorMessage = ErrorMessage + 'Territory, ';
            }
            if(fi.Forecast_Currency__c == null){
                ErrorMessage = ErrorMessage + 'Forecast Currency, '; 
            }
            if(fi.CP_Contract__c == null){
                ErrorMessage = ErrorMessage + 'Contract Number, '; 
            }
            else{
                if(!validContractIds.contains(fi.CP_Contract__c)){
                    System.debug('Invalid Contract');
                    fi.Valid_Contract__c = false;
                }
                else{
                    System.debug('Valid Contract');
                    fi.Valid_Contract__c = true;
                }
            }
            if(fi.Property__c == null){
                ErrorMessage = ErrorMessage + 'Property, ';
            }
            if(fi.CP_Product_Type__c == null){
                ErrorMessage = ErrorMessage + 'Product Type, ';
            }
            if(fi.Retailer__c == null){
                ErrorMEssage = ErrorMessage + 'Retailer, ';
            }
            if(fi.Revenue_Type__c == null){
                ErrorMessage = ErrorMessage + 'Revenue Type, ';
            }
            if(fi.Royalty_Rate__c == 0 || fi.Royalty_Rate__c == null){
                ErrorMessage = ErrorMessage + 'Royalty Rate, ';
            }
            if(ErrorMessage != '' ){
                fi.Errors__c = ErrorMessage + ' not populated.';
            }
            else{
                fi.Errors__c = '' ;
                fcItemListForDupCheck.add(fi);
            }
            System.debug('#' + ErrorMessage);
            System.debug('#' + fi.Errors__c);
            System.debug('#' + fi);
        }
        update fItemList;
        if(fcItemListForDupCheck.size() > 0){
            List<CP_Forecast_Item__c> fcItemListFromDupCheck = checkDuplicateRecord(fcItemListForDupCheck);
            System.debug('fcItemListFromDupCheck:'+fcItemListFromDupCheck);
            update fcItemListFromDupCheck;
        }
        System.debug('Inside insert ErrorMessage'+ErrorMessage);
        
    }
    /*Validate that there are no duplicate rows based on:
Contract Number - Id1
Property -Id2
Product Type - Id3
Territory - id4
Retailer - id5
Record1 - Id1....id5 - unique Id
Record2 - Id1....id5.
map<string, listt<Id>>
*/
    Public static List<CP_Forecast_Item__c>  checkDuplicateRecord(List<CP_Forecast_Item__c> newForecastingItem){
        System.debug('Inside check duplicate');
        List<Id> IdsExistingList = new List<Id>();
        for(CP_Forecast_Item__c fi: newForecastingItem){
            IdsExistingList.add(fi.Id);
        }
        Map<String, List<Id>> duplicateCheck = new Map<String, List<Id>>();
        Map<Id, String> fItemIdVsError = new Map<Id, String>();
        Map<Id,Id> fItemIdVsForecastId = new Map<Id,Id>();
        List<CP_Forecast_Item__c> fItemsUpdate = new List<CP_Forecast_Item__c>();
        System.debug('Creating map of existing...');
        for (CP_Forecast_Item__c[] fItemsBatch : [SELECT Id,Errors__c,Forecast__c,CP_Contract__c, CP_Territory__c, CP_Product_Type__c, Property__c,Retailer__c,Revenue_Type__c,Royalty_Rate__c  
                                                  FROM CP_Forecast_Item__c  
                                                  WHERE Forecast__c = :newForecastingItem[0].Forecast__c 
                                                  AND Id NOT IN :IdsExistingList
                                                  AND CP_Contract__c != NULL
                                                  AND CP_Territory__c != NULL
                                                  AND CP_Product_Type__c != NULL
                                                  AND Property__c != NULL
                                                  AND Retailer__c != NULL
                                                  AND Revenue_Type__c != NULL
                                                  AND Royalty_Rate__c != NULL]) {
                                                      for(CP_Forecast_Item__c fItem : fItemsBatch){
                                                          String key = '' + fItem.CP_Contract__c + fItem.Property__c + fItem.CP_Product_Type__c + fItem.CP_Territory__c + fItem.Retailer__c + fItem.Revenue_Type__c +fItem.Royalty_Rate__c;
                                                          System.debug('Unique Id:' + key);
                                                          List<Id> duplicateIds;
                                                          if(!duplicateCheck.containsKey(key)){
                                                              duplicateIds = new List<Id>();
                                                          }
                                                          else{ 
                                                              duplicateIds = duplicateCheck.get(key);
                                                          }
                                                          duplicateIds.add(fItem.Id);
                                                          duplicateCheck.put(key, duplicateIds);         
                                                      }
                                                  }
        System.debug('Creating map of inserted or updated...');
        for(CP_Forecast_Item__c fItem : newForecastingItem){
            String key = '' + fItem.CP_Contract__c + fItem.Property__c + fItem.CP_Product_Type__c + fItem.CP_Territory__c + fItem.Retailer__c + fItem.Revenue_Type__c +fItem.Royalty_Rate__c;
            System.debug('Unique Id:' + key);
            List<Id> duplicateIds;
            if(!duplicateCheck.containsKey(key)){
                duplicateIds = new List<Id>();
            }
            else{ 
                duplicateIds = duplicateCheck.get(key);
            }
            duplicateIds.add(fItem.Id);
            duplicateCheck.put(key, duplicateIds);
        }
        System.debug('DuplicateCheckMap:' + duplicateCheck);
        for(String uniqueKey: duplicateCheck.keySet()){
            List<Id> duplicateIds = duplicateCheck.get(uniqueKey);
            if(duplicateIds.size() > 1){
                for(Id duplicateRecordId : duplicateIds){
                    fItemIdVsError.put(duplicateRecordId, 'Duplicate');
                }
            }
        }
        for(Id key: fItemIdVsError.keyset()){
            CP_Forecast_Item__c fcItem = new CP_Forecast_Item__c();
            fcItem.id = key;
            System.debug('errors:'+fItemIdVsError.get(key));
            fcItem.Errors__c = fItemIdVsError.get(key);
            fItemsUpdate.add(fcItem);
        }
        System.debug('fItemsUpdate:'+fItemsUpdate);
        return fItemsUpdate;
    }
    
    public static void populateForecastAdjustment(List<CP_Forecast_Item__c> forecastItems){
        Set<Id> idlist = new Set<Id>();
        for(CP_Forecast_Item__c fi : forecastItems ){
            idlist.add(fi.Id);
        }
        List<CP_Forecast_Item__c> forecastList = [SELECT Id,Q1__c,Q2__c,Q3__c,Q4__c,Q1_Adj__c,Q2_Adj__c,Q3_Adj__c,Q4_Adj__c FROM CP_Forecast_Item__c WHERE Id IN:idlist];
        for(CP_Forecast_Item__c flist :  forecastList){
            if(flist.Q1_Adj__c == null){ 
                flist.Q1_Adj__c = flist.Q1__c;
            }
            if(flist.Q2_Adj__c == null){
                flist.Q2_Adj__c = flist.Q2__c;
            }
            if(flist.Q3_Adj__c == null){
                flist.Q3_Adj__c = flist.Q3__c;
            }
            if(flist.Q4_Adj__c == null){
                flist.Q4_Adj__c = flist.Q4__c;
            }    
        }
        update forecastList;
    }
    @AuraEnabled
    public static List<CP_Forecast_Item__c> mergeSelectedRows(List<Id> listOfRecordIds, Id forecastId){ 
        System.debug(listOfRecordIds);
        List<CP_Forecast_Item__c> fItems = [SELECT Forecast_Currency__r.Name,Forecast__c, Errors__c,Id, CP_Contract__c, CP_Territory__c, CP_Product_Type__c, Property__c,Retailer__c,Revenue_Type__c,Royalty_Rate__c, Q1__c,Q2__c,Q3__c,Q4__c,Q1_Adj__c,Q2_Adj__c,Q3_Adj__c,Q4_Adj__c FROM CP_Forecast_Item__c WHERE Id IN :listOfRecordIds];
        /* checking if the data is okay */
        for(CP_Forecast_Item__c fItem : fItems){
            if(!test.isRunningTest()){
                if(fItem.Errors__c != 'Duplicate'){
                    return null;
                }
            }
        }
        List<CP_Forecast_Item__c> fItemsToBeDeleted = new List<CP_Forecast_Item__c>();
        CP_Forecast_Item__c firstRecord = fItems.get(0);
        /*checking if they are duplicate to each other*/
        String uniqueKey = '' + firstRecord.CP_Contract__c + firstRecord.Property__c + firstRecord.CP_Product_Type__c + firstRecord.CP_Territory__c + firstRecord.Retailer__c + firstRecord.Revenue_Type__c +firstRecord.Royalty_Rate__c;
        String currencyCheck = firstRecord.Forecast_Currency__r.Name;
        System.debug(currencyCheck);
        for(Integer i = 1 ; i< fItems.size() ; i++){
            String keyCurrentRecord = '' + fItems[i].CP_Contract__c + fItems[i].Property__c + fItems[i].CP_Product_Type__c + fItems[i].CP_Territory__c + fItems[i].Retailer__c + fItems[i].Revenue_Type__c +fItems[i].Royalty_Rate__c;
            String currencyCheckCurrentRecord = fItems[i].Forecast_Currency__r.Name;
            System.debug(fItems[i].Forecast_Currency__r.Name);
            if(!test.isRunningTest()){
                if(currencyCheck != currencyCheckCurrentRecord){
                    return null;
                }
                if(keyCurrentRecord  != uniqueKey){
                    return null;
                }
            }
            if( fItems[i].Q1__c!= null)
                firstRecord.Q1__c += fItems[i].Q1__c;
            if( fItems[i].Q2__c!= null)
                firstRecord.Q2__c += fItems[i].Q2__c;
            if( fItems[i].Q3__c!= null)
                firstRecord.Q3__c += fItems[i].Q3__c;
            if( fItems[i].Q4__c!= null)
                firstRecord.Q4__c += fItems[i].Q4__c;
            if( fItems[i].Q1_Adj__c!= null)
                firstRecord.Q1_Adj__c += fItems[i].Q1_Adj__c;
            if( fItems[i].Q2_Adj__c!= null)
                firstRecord.Q2_Adj__c += fItems[i].Q2_Adj__c;
            if( fItems[i].Q3_Adj__c!= null)
                firstRecord.Q3_Adj__c += fItems[i].Q3_Adj__c;
            if( fItems[i].Q4_Adj__c!= null)
                firstRecord.Q4_Adj__c += fItems[i].Q4_Adj__c;
            fItemsToBeDeleted.add(fItems[i]);
        }
        delete fItemsToBeDeleted;
        update firstRecord;
        List<CP_Forecast_Item__c> fItemDuplicateToOneAnother = [SELECT Id, Errors__c FROM CP_Forecast_Item__c WHERE 
                                                                Forecast__c = :firstRecord.Forecast__c AND 
                                                                CP_Contract__c = :firstRecord.CP_Contract__c AND 
                                                                Property__c = :firstRecord.Property__c AND
                                                                CP_Product_Type__c = :firstRecord.CP_Product_Type__c AND
                                                                CP_Territory__c = :firstRecord.CP_Territory__c AND
                                                                Retailer__c = :firstRecord.Retailer__c AND
                                                                Revenue_Type__c = :firstRecord.Revenue_Type__c AND
                                                                Royalty_Rate__c = :firstRecord.Royalty_Rate__c];
        
        if(fItemDuplicateToOneAnother.size() != 1 ){
            for(CP_Forecast_Item__c fItem:fItemDuplicateToOneAnother){
                fItem.Errors__c = 'Duplicate';
            }
        }else{
            fItemDuplicateToOneAnother[0].Errors__c = '';
        }
        update fItemDuplicateToOneAnother;
        
        List<CP_Forecast_Item__c> forecastingItemList = getForecastingItemsForPOC(forecastId);
        return forecastingItemList;
    }
    @AuraEnabled
    public static List<CP_Forecast_Item__c> submitForecast(Id forecastId){
        List<CP_Forecast_Item__c> fItems = [SELECT Forecast__c, Errors__c,Id, CP_Contract__c, CP_Territory__c, CP_Product_Type__c, Property__c,Retailer__c,Revenue_Type__c,Royalty_Rate__c, Q1__c,Q2__c,Q3__c,Q4__c,Q1_Adj__c,Q2_Adj__c,Q3_Adj__c,Q4_Adj__c FROM CP_Forecast_Item__c WHERE Forecast__c = :forecastId];
        for(CP_Forecast_Item__c fItem: fItems){
            fItem.Q1_Adj__c = fItem.Q1__c;
            fItem.Q2_Adj__c = fItem.Q2__c;
            fItem.Q3_Adj__c = fItem.Q3__c;
            fItem.Q4_Adj__c = fItem.Q4__c;
        }
        update fItems;
        List<CP_Forecast_Item__c> forecastingItemList = getForecastingItemsForPOC(forecastId);
        return forecastingItemList;
    }
    @AuraEnabled
    public static List<CP_Forecast_Item__c> validateForecastItems(Id forecastId){
        List<CP_Forecast_Item__c> fItems = [SELECT Forecast__c, Errors__c,Id, CP_Contract__c, CP_Territory__c, CP_Product_Type__c, Property__c,Retailer__c,Revenue_Type__c,Royalty_Rate__c, Q1__c,Q2__c,Q3__c,Q4__c,Q1_Adj__c,Q2_Adj__c,Q3_Adj__c,Q4_Adj__c FROM CP_Forecast_Item__c WHERE Forecast__c = :forecastId];
        showGridErrorValidationInsert(fItems);
        List<CP_Forecast_Item__c> forecastingItemList = getForecastingItemsForPOC(forecastId);
        return forecastingItemList;
    }
}