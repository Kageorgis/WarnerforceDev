/*========================================================================================================
* @author: vasu
* @date: 14/08/2021
* @description: New version has been created when Forecast status is submitted.
==========================================================================================================*/
//CPBPP-134
public without sharing class CP_NewForecastVersionController {
    @AuraEnabled
    public static Id createForecastVersion(Id recordId){
        System.debug(recordId);
        
            CP_Forecast__c existingVersion = [SELECT Id, Licensee_Name__c, Forecast_Cycle__c, Forecast_Status__c,Amount_Type__c,Forecast_version__c
                                          FROM CP_Forecast__c 
                                          WHERE Id = :recordId 
                                          LIMIT 1];
        System.debug('existingVersion:'+ existingVersion);
        CP_Forecast__c newVersion = new CP_Forecast__c();
        newVersion.Licensee_Name__c = existingVersion.Licensee_Name__c;
        newVersion.Forecast_Cycle__c = existingVersion.Forecast_Cycle__c;
        newVersion.Amount_Type__c = existingVersion.Amount_Type__c;
        newVersion.Forecast_Status__c = 'Draft';
        newVersion.Forecast_version__c = ((existingVersion.Forecast_version__c != NULL)? existingVersion.Forecast_version__c : 0) + 1;
        System.debug('newVersion:'+ newVersion);
            insert newVersion; 
        System.debug('newVersion:'+ newVersion);  
        Id fcstId = newVersion.Id;
        String sobject_type = 'CP_Forecast_Item__c';
        Map<String, Schema.SObjectType> global_describe = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> object_fields_map = global_describe.get(sobject_type).getDescribe().fields.getMap();
        List<String> fieldNamesForecastItem =  new List<String>(object_fields_map.keySet());
        String fcItemquery =
            ' SELECT ' +
            String.join( fieldNamesForecastItem, ',' ) +
            ' FROM ' +
            sobject_type +
            ' WHERE ' +
            ' Forecast__c = :recordId ' ;
        List<CP_Forecast_Item__c> forecastItemObjList = Database.query( fcItemquery );
        System.debug('###' + forecastItemObjList.size());
        List<CP_Forecast_Item__c> fcItemList=[select id,name,Forecast__c from CP_Forecast_Item__c where Forecast__c=:recordId];
        List<CP_Forecast_Item__c> fcItemListToInsert=new  List<CP_Forecast_Item__c>();
        for(CP_Forecast_Item__c fcitem:forecastItemObjList){
            CP_Forecast_Item__c fcCopy = fcitem.clone(false,true);
            fcCopy.Forecast__c = fcstId;
            fcItemListToInsert.add(fcCopy);
        }
        insert fcItemListToInsert;
        System.debug('###' + newVersion.Id);
        return fcstId;
    }
}