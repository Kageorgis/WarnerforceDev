/*========================================================================================================================
* @author vasu A
* @date 14/07/2021
* @description:This Test is Covering  for CP_ForecastCycleTriggerHelper Apex class 
==========================================================================================================================*/
@istest
public class CP_ForecastCycleTriggerHelperTest {
    @isTest
   static void autoCreateForecastTest(){
   Map<Id, CP_Forecast_Cycle__c> newItems = new Map<Id, CP_Forecast_Cycle__c>();
   Map<Id, CP_Forecast_Cycle__c> oldItems = new Map<Id, CP_Forecast_Cycle__c>();
       list<Account> listacc = new list<Account>();
       Account acc = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId());
       acc.Name = 'test';
       acc.CP_Forecast_Required_Bottom_Up__c = true;
       listacc.add(acc);
       insert listacc;
       System.assertNotEquals(listacc.get(0).Id,null, 'Success in Insertion');
       list<CP_Forecast_Cycle__c> listcpc = new list<CP_Forecast_Cycle__c>();
       CP_Forecast_Cycle__c cpc = new CP_Forecast_Cycle__c();
       cpc.Status__c = Label.CP_FORECAST_ACTIVE;
       cpc.Cycle_Type__c = 'MFC';
      // insert cpc;
     //  update cpc;
       upsert cpc;
       List<Id> acctId = new List<Id>();
       
       CP_Forecast__c forecastObj=new CP_Forecast__c();
       forecastObj.Licensee_Name__c=acc.id;
       System.debug(acc.id);
       forecastObj.Forecast_Status__c='Open';
       System.debug(forecastObj.Forecast_Status__c);
       forecastObj.Forecast_Cycle__c = cpc.id;
        System.debug(forecastObj.Forecast_Cycle__c);
       forecastObj.Forecast_version__c = Decimal.valueOf(2);
      // newItems.put(cpc.id,cpc);
      // insert forecastObj;
      // update forecastObj;
        Account acct = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId());
        acct.Name = 'test';
        acct.CP_Forecast_Required_Bottom_Up__c = true;
        insert acct;
        CP_Forecast__c cpf = new CP_Forecast__c();
        cpf.Licensee_Name__c = acc.id;
        cpf.Forecast_Status__c =Label.CP_FORECAST_OPEN;
        cpf.Forecast_version__c = Decimal.valueOf(1);
       cpf.Amount_Type__c=Label.CP_ROYAlTY;
       insert cpf;
      // System.assertNotEquals(cpf.Id, null);
      // list<CP_Forecast_Cycle__c> listcpc = new list<CP_Forecast_Cycle__c>();
       CP_Forecast_Cycle__c cp = new CP_Forecast_Cycle__c();
       cp.Status__c = Label.CP_FORECAST_ACTIVE;
       newItems.put(cp.id, cp);
       CP_ForecastCycleTriggerHelper.autoCreateForecast(newItems, oldItems);
       System.assertNotEquals(newItems.size(), 0,'Success');
       List<CP_Forecast_Cycle__c> returnedForecastCycle = [SELECT Id,(SELECT Id,Name FROM Forecasts__r) FROM CP_Forecast_Cycle__c];
       //System.assertEquals(returnedForecast.size(),1);
       List<CP_Forecast__c> forcastList = new List<CP_Forecast__c>();
       for(CP_Forecast_Cycle__c flist : returnedForecastCycle){
           for(CP_Forecast__c forcastRecord : flist.Forecasts__r){
               forcastList.add(forcastRecord);
           }
       }
       System.assertNotEquals(forcastList.size(),1);    
    }
    @isTest
    static void autoCreateForecastOnInsertTest(){
          Map<Id, CP_Forecast_Cycle__c> newItems = new Map<Id, CP_Forecast_Cycle__c>();
          List<sObject> newRecordsList = new List<sObject>();
          Account acc = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId());
          acc.Name = 'test';
          acc.CP_Forecast_Required_Bottom_Up__c = true;
          insert acc;
          CP_Forecast_Cycle__c cpc = new CP_Forecast_Cycle__c();
          cpc.Status__c = 'Create';
          cpc.Cycle_Type__c = 'MFC';
          insert cpc;
          update cpc;
          newItems.put(cpc.Id,cpc);
          CP_ForecastCycleTriggerHelper.autoCreateForecastOnInsert(newRecordsList, newItems);
        
    }
   
}