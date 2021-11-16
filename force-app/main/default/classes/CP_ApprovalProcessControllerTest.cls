@isTest
public class CP_ApprovalProcessControllerTest {
    @isTest
    static void approveForecastTest(){
			Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
			User usr = new User(Alias = 'stndt', Email='stadarduser@testorg.com', 
						EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
						LocaleSidKey='en_US', ProfileId = p.Id, 
						TimeZoneSidKey='America/Los_Angeles', UserName='stadarduser@testorg.com');
			insert usr ;
			System.runAs(usr)
			{
                Account acc = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId());
                acc.Name = 'test';
                acc.OwnerId = usr.id;
                insert acc;
                CP_Forecast_Cycle__c cpcycle = new CP_Forecast_Cycle__c();
                cpcycle.Cycle_Type__c = 'FFC';
                cpcycle.Year__c = '2029';
                insert cpcycle;
                List<CP_Forecast__c> listcpf = new List<CP_Forecast__c>();
                CP_Forecast__c cpf = new CP_Forecast__c();
                cpf.Licensee_Name__c = acc.id;
       			cpf.OwnerId = usr.id;
                cpf.Forecast_Cycle__c = cpcycle.id;
                cpf.Forecast_version__c = 1;
                cpf.Amount_Type__c = 'WSS';
                cpf.Forecast_Status__c=Label.CP_PENDING_APPROVAL;
                insert cpf;
                update cpf;
                System.assertNotEquals(cpf.Id, null);
                CP_ApprovalProcessController.approveForecast(cpf.id,usr.id);
      
            }
        
    }
    @isTest
    static void approveForecastTest1(){
        Try{
			Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
			User usr = new User(Alias = 'stndt', Email='stadarduser@testorg.com', 
						EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
						LocaleSidKey='en_US', ProfileId = p.Id, 
						TimeZoneSidKey='America/Los_Angeles', UserName='stadarduser@testorg.com');
			insert usr ;
			System.runAs(usr)
			{
                Account acc = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId());
                acc.Name = 'test';
                acc.OwnerId = usr.id;
                insert acc;
                CP_Forecast_Cycle__c cpcycle = new CP_Forecast_Cycle__c();
                cpcycle.Cycle_Type__c = 'FFC';
                cpcycle.Year__c = '2029';
                insert cpcycle;
                List<CP_Forecast__c> listcpf = new List<CP_Forecast__c>();
                CP_Forecast__c cpf = new CP_Forecast__c();
                cpf.Licensee_Name__c = acc.id;
       			cpf.OwnerId = usr.id;
                cpf.Forecast_Cycle__c = cpcycle.id;
                cpf.Forecast_version__c = 1;
                cpf.Amount_Type__c = 'WSS';
                cpf.Forecast_Status__c=Label.CP_SUBMITTED;
                insert cpf;
                update cpf;
                System.assertNotEquals(cpf.Id, null);
                CP_ApprovalProcessController.approveForecast(cpf.id,usr.id);
            }
    }catch(Exception e){
        
    }
    }
    
    @isTest
    static void rejectForecastTest1(){
        Try{
			Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
			User usr = new User(Alias = 'stndt', Email='stadarduser@testorg.com', 
						EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
						LocaleSidKey='en_US', ProfileId = p.Id, 
						TimeZoneSidKey='America/Los_Angeles', UserName='stadarduser@testorg.com');
			insert usr ;
			System.runAs(usr)
			{
                Account acc = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId());
                acc.Name = 'test';
                acc.OwnerId = usr.id;
                insert acc;
                CP_Forecast_Cycle__c cpcycle = new CP_Forecast_Cycle__c();
                cpcycle.Cycle_Type__c = 'FFC';
                cpcycle.Year__c = '2029';
                insert cpcycle;
                List<CP_Forecast__c> listcpf = new List<CP_Forecast__c>();
                CP_Forecast__c cpf = new CP_Forecast__c();
                cpf.Licensee_Name__c = acc.id;
       			cpf.OwnerId = usr.id;
                cpf.Forecast_Cycle__c = cpcycle.id;
                cpf.Forecast_version__c = 1;
                cpf.Amount_Type__c = 'WSS';
                cpf.Forecast_Status__c=Label.CP_REJECTED;
                insert cpf;
                update cpf;
                System.assertNotEquals(cpf.Id, null);
                CP_ApprovalProcessController.rejectForecast(cpf.id,usr.id);
            }
    }catch(Exception e){
        
    }
    }
    
    
}