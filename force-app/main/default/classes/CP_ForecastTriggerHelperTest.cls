/*========================================================================================================================
* @author vasu A
* @date 14/07/2021
* @description:This Test is Covering  for CP_ForecastTriggerHelper Apex class 
==========================================================================================================================*/
@istest
public class CP_ForecastTriggerHelperTest { 
    @isTest
    static void preventForecastInsertTest(){
        Account acc = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId());
        acc.Name = 'test';
        acc.CP_Forecast_Required_Bottom_Up__c = true;
        insert acc;
        System.assertNotEquals(acc.Id, null ,'Account Not created');
        List<CP_Forecast__c> listcpf = new List<CP_Forecast__c>();
        CP_Forecast__c cpf = new CP_Forecast__c();
        cpf.Licensee_Name__c = acc.id;
        cpf.Forecast_Status__c = Label.CP_FORECAST_OPEN;
        cpf.Forecast_version__c = 1;
       // cpf.Amount_Type__c= Label.CP_TOP_DOWN;
        listcpf.add(cpf);
        insert listcpf;
        CP_Forecast_Cycle__c fcycle = new CP_Forecast_Cycle__c();
        fcycle.Status__c =Label.CP_FORECAST_CLOSED;
        fcycle.Cycle_Type__c = 'FFC';
        fcycle.Year__c = '2022';
        insert fcycle;
        System.assertNotEquals(fcycle.Id, null);
        CP_ForecastTriggerHelper.preventForecastInsert(listcpf);
       
        
    }
 @isTest
    static void closeForecastTest(){
        Map<Id, sObject> newvalues = new Map<Id, sObject>();
        Map<Id, sObject> oldvalues = new Map<Id, sObject>();
        try{
         Account acc = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId());
        acc.Name = 'Retailer';
        insert acc;
        System.assertNotEquals(acc.Id, null , 'Account Not Created');
        List<CP_Forecast__c> listcpf = new List<CP_Forecast__c>();
        CP_Forecast__c cpf = new CP_Forecast__c();
        cpf.Licensee_Name__c = acc.id;
        cpf.Forecast_Status__c = Label.CP_FORECAST_OPEN;
        cpf.Amount_Type__c= Label.CP_ROYAlTY;
        cpf.Forecast_version__c = 1;
         listcpf.add(cpf);
        insert listcpf;
        System.assertNotEquals(listcpf.get(0).Id, null , 'CP_Forecast Not Created');
        update listcpf;
        newvalues.put(cpf.id, cpf);
        CP_Forecast_Cycle__c fcycle = new CP_Forecast_Cycle__c();
        fcycle.Status__c =Label.CP_FORECAST_CLOSED;
        insert fcycle;
        update fcycle;
       System.assertNotEquals(fcycle.Id, null);
        CP_ForecastTriggerHelper.closeForecast(newvalues, oldvalues);
        System.assertEquals(cpf.Forecast_Cycle_Status__c, Label.CP_FORECAST_OPEN);
        } catch(Exception e){
            
        }
         
    }
    @isTest
    static void updateStatustToDraftTest(){
        Map<Id, sObject> newvalues = new Map<Id, sObject>();
        Map<Id, sObject> oldvalues = new Map<Id, sObject>();
        
        Account acct = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId(),Name = 'test1');
        insert acct;
        System.assertNotEquals(acct.Id, null);
        Account acct1 = new Account(Name = 'test2');
        insert acct1;
        System.assertNotEquals(acct1.Id, null);
        CP_Forecast_Cycle__c fcycle = new CP_Forecast_Cycle__c();
        fcycle.Status__c =Label.CP_FORECAST_CLOSED;
        fcycle.Cycle_Type__c = 'FFC';
        fcycle.Year__c = '2022';
        insert fcycle;
        
        CP_Forecast__c oldvalue = new CP_Forecast__c();
        oldvalue.Licensee_Name__c = acct.Id;
        oldvalue.Forecast_Status__c = Label.CP_FORECAST_OPEN;
        oldvalue.Amount_Type__c= Label.CP_ROYAlTY;
        oldvalue.Forecast_Cycle__c =fcycle.id;
        oldvalue.Forecast_version__c = 1;
       // insert oldvalue;
        //update oldvalue;
        oldvalues.put(oldvalue.Id,oldvalue);
        
       /* List<CP_Forecast__c> listcpf = new List<CP_Forecast__c>();
        CP_Forecast__c cpf = new CP_Forecast__c();
        cpf.Licensee_Name__c = acct.id;
        cpf.Forecast_Status__c = Label.CP_FORECAST_OPEN;
        cpf.Amount_Type__c= Label.CP_ROYAlTY;
        listcpf.add(cpf);
        insert listcpf;
        update listcpf;
        
        newvalues.put(cpf.Id,cpf);
*/
       
        CP_ForecastTriggerHelper.updateStatustToDraft(newvalues, oldvalues); 
        System.assertNotEquals(oldvalue.Forecast_Status__c, 'Draft');
    }
    
    @isTest
    static void addVersionToForecastTest(){
        List<CP_Forecast__c> forecastItems = new List<CP_Forecast__c>();
        Account acct = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId(),Name = 'Test Account 1');
        insert acct;
        CP_Forecast_Cycle__c  forecastCycle  =  new CP_Forecast_Cycle__c();
        forecastCycle.Cycle_Type__c = 'FFC';
        forecastCycle.Year__c = '2022';
        insert forecastCycle;
        CP_Forecast__c forecastRecord = new CP_Forecast__c();
        forecastRecord.Licensee_Name__c = acct.Id;
        forecastRecord.Forecast_Cycle__c = forecastCycle.Id;
        forecastRecord.Forecast_version__c = Decimal.valueOf(1);
        insert forecastRecord;
        System.assertNotEquals(forecastRecord.Id, null);
        forecastItems.add(forecastRecord);
      //  CP_ForecastTriggerHelper.addVersionToForecast(forecastItems);
        //System.assertEquals(forecastRecord.Forecast_version__c, 2);
    }
 /*   @isTest
    static void massApproveForecastTest(){
        Map<Id, sObject> newvalues = new Map<Id, sObject>();
        Map<Id, sObject> oldvalues = new Map<Id, sObject>();
        try{
         Account acc = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId());
        acc.Name = 'Retailer';
        insert acc;
        List<CP_Forecast__c> listcpf = new List<CP_Forecast__c>();
        CP_Forecast__c cpf = new CP_Forecast__c();
        cpf.Licensee_Name__c = acc.id;
        cpf.Forecast_Status__c = Label.CP_SUBMITTED;
        cpf.Amount_Type__c= Label.CP_ROYAlTY;
        cpf.Forecast_version__c = 1;
         listcpf.add(cpf);
        insert listcpf;
        update listcpf;
        newvalues.put(cpf.id, cpf);
        CP_Forecast_Cycle__c fcycle = new CP_Forecast_Cycle__c();
        fcycle.Status__c =Label.CP_FORECAST_CLOSED;
        System.assertNotEquals(cpf.Id, null);
        CP_ForecastTriggerHelper.massApproveForecast(newvalues, oldvalues);
        }catch(Exception e){
            
        }
    } */
   @isTest
    static void updateOwnerOnForecastTest(){
        Map<Id, sObject> newvalues = new Map<Id, sObject>();
        List<sObject> newRecordsLists = new List<sObject>();
        //Id user = [SELECT Id,Name FROM User WHERE Name='Sam Sung'].Id;
        Id profId = [SELECT Id,Name FROM Profile WHERE Name ='System Administrator'].Id;
        User usr = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason.liveston@asdf.com',
                           Username = profId+'jason.liveston@asdf.com',
                           ProfileId = profId,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert usr;
        System.runAs(usr){
        Account acc = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId());
        acc.Name = 'Retailer';
        acc.Forecasting_Approver__c = usr.Id;
        insert acc;
        CP_Forecast_Cycle__c  forecastCycle  =  new CP_Forecast_Cycle__c();
        forecastCycle.Cycle_Type__c = 'FFC';
        forecastCycle.Year__c = '2022';
        insert forecastCycle;
        List<CP_Forecast__c> listcpf = new List<CP_Forecast__c>();
        CP_Forecast__c cpf = new CP_Forecast__c();
        cpf.Licensee_Name__c = acc.id;
        cpf.Forecast_Cycle__c = cpf.id;
        cpf.Forecast_Status__c = Label.CP_FORECAST_OPEN;
        cpf.Amount_Type__c= Label.CP_ROYAlTY;
        cpf.Forecast_version__c = 1;
        listcpf.add(cpf);
        insert listcpf;
        update listcpf;
        newvalues.put(cpf.id, cpf);
       // insert cDe;
      // CP_ForecastTriggerHelper.updateFileOnForecast(cDe.ContentDocumentId,cDe);
      //  CP_ForecastTriggerHelper.updateFileOnForecast(newRecordLists,newvalues);
        CP_ForecastTriggerHelper.updateOwnerOnForecast(newRecordsLists, newvalues);
        }
    }
    /*@isTest
    static void updateFileOnForecastTest(){
        List<sObject> newRecordsList = new List<sObject>();
        Map<Id,sObject> newItems = new Map<Id,sObject>();
        Id profId = [SELECT Id,Name FROM Profile WHERE Name ='System Administrator'].Id;
        User usr = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason.liveston@asdf.com',
                           Username = profId+'jason.liveston@asdf.com',
                           ProfileId = profId,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert usr;
        System.runAs(usr){
            Account acc = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId());
            acc.Name = 'Retailer';
            acc.Forecasting_Approver__c = usr.Id;
            insert acc;
            CP_Forecast_Cycle__c  forecastCycle  =  new CP_Forecast_Cycle__c();
            forecastCycle.Cycle_Type__c = 'FFC';
            forecastCycle.Year__c = '2022';
            insert forecastCycle;
            CP_Forecast__c cpf = new CP_Forecast__c();
            cpf.Licensee_Name__c = acc.id;
            cpf.Forecast_Cycle__c = forecastCycle.id;
            cpf.Forecast_Status__c = Label.CP_FORECAST_OPEN;
            cpf.Amount_Type__c= Label.CP_ROYAlTY;
            cpf.Forecast_version__c = 1;
            insert cpf;
            newItems.put(cpf.Id,cpf);
            Blob bodyBlob=Blob.valueOf('Unit,Test,ContentVersion,Body,to,be,insert,in,test,class,for,testing,the'); 
            
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.csv',
                VersionData = bodyBlob, 
                origin = 'H'
            );
            insert contentVersion_1;
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                            FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = forecastCycle.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'I';
            insert contentlink;
            CP_ForecastTriggerHelper.updateFileOnForecast(newRecordsList, newItems);
        } 
    }*/
    @isTest
    static void sendEmailToForecastOwnerTest(){
        Map<Id,sObject> newRecordsMap = new Map<Id,sObject>();
        Map<Id,sObject> oldRecordsMap = new Map<Id,sObject>();
        Id profId = [SELECT Id,Name FROM Profile WHERE Name ='System Administrator'].Id;
        User usr = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason.liveston@asdf.com',
                           Username = profId+'jason.liveston@asdf.com',
                           ProfileId = profId,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert usr;
        System.runAs(usr){
            Account acc = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId());
            acc.Name = 'Retailer';
            acc.Forecasting_Approver__c = usr.Id;
            insert acc;
            CP_Forecast_Cycle__c  forecastCycle  =  new CP_Forecast_Cycle__c();
            forecastCycle.Cycle_Type__c = 'FFC';
            forecastCycle.Year__c = '2022';
            insert forecastCycle;
            CP_Forecast__c cpf = new CP_Forecast__c();
            cpf.Licensee_Name__c = acc.id;
            cpf.Forecast_Cycle__c = forecastCycle.id;
            cpf.Forecast_Status__c = 'Pending Approval';
            cpf.Amount_Type__c= Label.CP_ROYAlTY;
            cpf.Forecast_version__c = 1;
            cpf.OwnerId = usr.Id;
            insert cpf;
            newRecordsMap.put(cpf.Id,cpf);
            CP_ForecastTriggerHelper.sendEmailToForecastOwner(newRecordsMap, oldRecordsMap);
        }
    }
 /*  @isTest
    static void shareContractsWithAgentTest(){
        Map<Id,sObject> newItems = new Map<Id,sObject>();
        List<sObject> newRecordsList = new List<sObject>();
        Account acct1 = new Account();
        acct1.Name = 'Test Account';
      // 	acct1.WBCP_Licensee_Agent__c = acct1.id;
        insert acct1;  
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.WBCP_Licensee_Agent__c = acct1.id;
        insert acct;  
        Contact con = new Contact();
        con.FirstName = 'test';
        con.LastName = 'Test2';
        con.AccountId = acct.id;
        insert con;
       // update acct;
        CP_Forecast__c forecastRecord = new CP_Forecast__c();
        forecastRecord.Licensee_Name__c = acct.Id;
        forecastRecord.Forecast_Status__c = Label.CP_FORECAST_OPEN;
        //insert forecastRecord;
        Profile p = [SELECT Id FROM Profile WHERE Name='CP - Partner Community Agent']; 
        //UserRole ur = [SELECT Id FROM UserRole Where name = 'WBCP North America'];
        User usr = new User(Alias = 'test', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test@torg.com',ContactId = con.id);
        usr.UserRoleId=[select Id from UserRole where Name = 'WBCP North America'].Id;
        insert usr;
      //  CP_Contract__c ct = new CP_Contract__c();
      //  ct.Account_Licensee__c = acct.id;
        //CP_Contract__Share contractRecordToShare = new CP_Contract__Share();
        //contractRecordToShare.AccessLevel = 'Read';
        //contractRecordToShare.ParentID = acct.Id;
        //contractRecordToShare.UserOrGroupId =usr.Id;
        //insert contractRecordToShare;
       // insert ct;
        System.runAs(usr){
        newItems.put(forecastRecord.Id,forecastRecord);
        CP_ForecastTriggerHelper.shareContractsWithAgent(newRecordsList, newItems);
        }
                
    }*/
  @isTest
    static void cloneNewVersionForecastTest(){
       
		
        //CP_CheckRecursive.run = true;
       Map<Id, sObject> newvalues = new Map<Id, sObject>();
       Map<Id, sObject> oldvalues = new Map<Id, sObject>();
      
         Account acc = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId());
        acc.Name = 'Retailer';
        insert acc;
        System.assertNotEquals(acc.Id, null , 'Account Not Created');
        List<CP_Forecast__c> listcpf = new List<CP_Forecast__c>();
        CP_Forecast__c cpf = new CP_Forecast__c();
        cpf.Licensee_Name__c = acc.id;
        cpf.Forecast_Status__c = 'Rejected';
        cpf.Amount_Type__c= Label.CP_ROYAlTY;
        cpf.Forecast_version__c = 1;
         listcpf.add(cpf);
        insert listcpf;
        System.assertNotEquals(listcpf.get(0).Id, null , 'CP_Forecast Not Created');
        update listcpf;
        newvalues.put(cpf.id, cpf);
        CP_Forecast_Cycle__c fcycle = new CP_Forecast_Cycle__c();
        fcycle.Status__c =Label.CP_FORECAST_CLOSED;
        fcycle.Cycle_Type__c = 'FFC';
        fcycle.Year__c = '2022';
        insert fcycle;
        update fcycle; 
       // CP_CheckRecursive.run = true;
         DescribeSObjectResult describeResult = cpf.getSObjectType().getDescribe();
         system.debug('describeResult:'+describeResult);
			List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
          system.debug('fieldNames:'+fieldNames);
            String query =
                ' SELECT ' +
                String.join( fieldNames, ',' ) +
                ' FROM ' +
                describeResult.getName() +
                ' WHERE ' +
                ' id = :fcstId ' ;
            
         system.debug('query:'+query);
        //CP_Forecast__c forecastObj = Database.query( query );
       
        cp_forecast_item__c fcitem = new cp_forecast_item__c();
        
      	CP_ForecastTriggerHelper.cloneNewVersionForecast(newvalues,oldvalues);  
    }
    
    /*@isTest
    static void shareContractsWithAgentTest1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='CP - Partner Community Agent']; 
        //UserRole ur = [SELECT Id FROM UserRole Where name = 'WBCP North America'];
        User usr = new User(Alias = 'test', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test@torg.com');
        
        insert usr;
        System.runAs(usr){
              Map<Id,sObject> newItems = new Map<Id,sObject>();
              List<sObject> newRecordsList = new List<sObject>();
              Account acct1 = new Account();
              acct1.Name = 'Test Account'; 
       // 	  acct1.WBCP_Licensee_Agent__c = acct1.id;
              insert acct1;  
              Account acct = new Account();
              acct.Name = 'Test Account';
              acct.WBCP_Licensee_Agent__c = acct1.id;
              insert acct;  
              Contact con = new Contact();
              con.FirstName = 'test';
              con.LastName = 'Test2';
              con.AccountId = acct.id;
              insert con;
              usr.UserRoleId=[select Id from UserRole where Name = 'WBCP North America'].Id;
              usr.ContactId = con.Id;
       // update acct;
              CP_Forecast__c forecastRecord = new CP_Forecast__c();
             forecastRecord.Licensee_Name__c = acct.Id;
             forecastRecord.Forecast_Status__c = Label.CP_FORECAST_OPEN;
             insert forecastRecord;
             newItems.put(forecastRecord.Id,forecastRecord);
             CP_ForecastTriggerHelper.shareContractsWithAgent(newRecordsList, newItems);
        }
       
    }*/
   /*@isTest
    static void shareForecastRecordWithAgentTest(){
        Map<Id,sObject> newItems = new Map<Id,sObject>();
        List<sObject>  newRecordsList = new List<sObject>();
        Account LicenseeAgent = new Account();
        LicenseeAgent.Name = 'Licensee Agent';
        LicenseeAgent.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId();
        insert LicenseeAgent;
        ////////////////////////////////////////////////////
        Contract newContract = new Contract();
        newContract.AccountId = LicenseeAgent.Id;
        insert newContract;
        ///////////////////////////////////////////////////
        Contact cont = new Contact();
        cont.LastName = 'Test Contacts';
        cont.AccountId = LicenseeAgent.Id;
        insert cont;
        Account LicenseeAccount = new Account();
        LicenseeAccount.Name = 'Licensee Test Account';
        LicenseeAgent.WBCP_Licensee_Agent__c = LicenseeAgent.Id;
        LicenseeAccount.recordTypeId=LicenseeAgent.RecordTypeId;
        insert LicenseeAccount;
        CP_Forecast__c forecastRecord = new CP_Forecast__c();
        forecastRecord.Licensee_Name__c = LicenseeAccount.Id;
        forecastRecord.Forecast_Status__c = 'Open';
        insert forecastRecord;
        newItems.put(forecastRecord.Id,forecastRecord);
       // CP_ForecastTriggerHelper.shareForecastRecordWithAgent(newRecordsList, newItems);
        CP_ForecastTriggerHelper.shareContractsWithAgent(newRecordsList, newItems);
    }*/
    @isTest
    static void UnshareContractsWithAgentTest(){
        Map<Id,Account> mapOldAccounts = new Map<Id,Account>();
        Map<Id,Account> mapNewAccounts = new Map<Id,Account>();
        Account LicenseeAgent = new Account();
        LicenseeAgent.Name = 'Licensee Agent';
        LicenseeAgent.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId();
        insert LicenseeAgent;
        Account LicenseeAccount = new Account();
        LicenseeAccount.Name = 'Licensee Test Account';
        LicenseeAgent.WBCP_Licensee_Agent__c = LicenseeAgent.Id;
        LicenseeAccount.recordTypeId=LicenseeAgent.RecordTypeId;
        insert LicenseeAccount;
        Account oldAccount = new Account();
        oldAccount.Name = 'old Account Test';
        oldAccount.WBCP_Licensee_Agent__c = LicenseeAgent.Id;
        insert oldAccount;
        mapOldAccounts.put(oldAccount.Id,oldAccount);
        Account newAccount = new Account();
        newAccount.Name = 'new Account Test';
        insert newAccount;
        mapNewAccounts.put(newAccount.Id,newAccount);
        //CP_ForecastTriggerHelper.UnshareContractsWithAgent(mapOldAccounts, mapNewAccounts);
    }
   
}