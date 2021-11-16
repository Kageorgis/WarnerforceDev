@Istest
public class CP_SendCustomNotificationTest {
    @isTest
    static void sendNotificationsToForecastOwnerTest(){
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
                cpf.Forecast_Status__c=Label.CP_PENDING_APPROVAL;
                cpf.Forecast_version__c = 1;
                cpf.Amount_Type__c ='Royalty';
                insert cpf;
                //CustomNotificationType custNotification=   [SELECT Id, CustomNotifTypeName, DeveloperName from CustomNotificationType WHERE DeveloperName ='CP_Forecast_Approval'];
               // Messaging.CustomNotification obj = new Messaging.CustomNotification();
               CustomNotificationType custNotification = new CustomNotificationType();
                custNotification.CustomNotifTypeName = 'testing';
                custNotification.DeveloperName = 'George';
                String forecastName= usr.name;
             	//String forecastStatus=ownerIdVsStatusMap.get(usr.Id);
              	//String forecastCycleName=ownerIdVsForecastCycleNameMap.get(usr.Id);
              	Id customNotificationId=custNotification.id;
              	//Decimal subTotal=ownerIdVsSubTotalMap.get(usr.Id);
              	String msgBody='Forecast Id:'+forecastName;
              	system.debug('$$$ msgBody:'+msgBody); 
              	String title=usr.Name+' '+' is requesting approval for Forecast';
               // Test.startTest();
                CP_SendCustomNotification.sendNotificationsToForecastOwner(msgBody, '', usr.Id, title, customNotificationId, new set<String>{usr.Id});
               // Integer invocation = Limits.
               // Test.stopTest();
            }
    }
    
}