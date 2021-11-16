/*------------------------------------------------------------
Author:        Cognizant Technology Solution
Company:       Cognizant Technology Solution
Class Name:    WB_DeleteMALARRecsTest 
Description:   This class is used test WB_DeleteMALARRecs
History:
<Date>      <Authors Name>     <Brief Description of Change>
05/10/2017    Sriniz            ER-000993 - Initial Version

*/

@isTest
private class WB_DeleteMALARRecsTest{
    
    // This class will be used to create Test Data and will be used by all Test methods created in this class.
    public static UtilityClass_Test  utilClass = new UtilityClass_Test();    
    
    testmethod static void  testMethod1(){
        list<Announcement_Rule__c> listAnnType;
        list<Announcement__c> listAnnRecs ;
        System.runAs(utilClass.getUserFromProfile('System Administrator')){        
            Id rtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(system.label.AccRecordType).getRecordTypeId();  
            List<Account> accountList = new List<Account>();
            Account acctGoogle = new Account(Name='TestGoogle',RecordTypeId = rtypeId);
            accountList.add(acctGoogle);
            
            Account acctAmazon = new Account(Name='TestAmazon',RecordTypeId = rtypeId);
            accountList.add(acctAmazon);
            insert accountList;
            
            List<Title__c> titleList = new List<Title__c>();
            Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
            Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='6000047546',Content_Type__c='Season',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
            titleList.add(title1);
            titleList.add(title2);
            insert titleList;
            
            Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF', Territory__c = 'France');
            insert countryFrance;
            Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ', Territory__c = 'Japan');
            insert countryJapan;
            
            Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
            insert languageFrench;            
            
            Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                       Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                       Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(), End_Date__c= date.today().addDays(10), Rights_End__c=date.today().addDays(11)
                                                                      );
            insert releaseplan1;
            string CommIds = releaseplan1.Id;
            
            
            //necessary to create Store Front(Agreement__c) Record otherwise we'll get Validation Error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Please check Status of the Storefront: 
            List<Agreement__c> agreementList = new List<Agreement__c>();
            Agreement__c storefrontGoogle1 = new Agreement__c(
                Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421'
            );
            agreementList.add(storefrontGoogle1);
            Agreement__c storefrontAmazon1 = new Agreement__c(
                Account__c=acctAmazon.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421'
            );
            agreementList.add(storefrontAmazon1);
            
            //insert storefrontGoogle1; 
            insert agreementList;
            
            List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
            List<Client_Avail__c> clientAvailsUpdateList = new List<Client_Avail__c>();
            
            Client_Avail__c clientAvail1 = new Client_Avail__c(
                Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Draft',
                Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.Start_Date__c.addDays(2), RP_Synch__c = true, Announce_Override__c = 'Force'
            );
            clientAvailList.add(clientAvail1);
            
            Client_Avail__c clientAvail2 = new Client_Avail__c(
                Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Draft',
                Start_Date__c=releaseplan1.Start_Date__c.addDays(3),End_Date__c=releaseplan1.Start_Date__c.addDays(5), RP_Synch__c = true
            );
            clientAvailList.add(clientAvail2);
            
            Client_Avail__c clientAvail3 = new Client_Avail__c(
                Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Draft',
                Start_Date__c=releaseplan1.Start_Date__c.addDays(6),End_Date__c=releaseplan1.Start_Date__c.addDays(8), RP_Synch__c = true
            );
            clientAvailList.add(clientAvail3);
            insert clientAvailList;
            
            Account_Role__c aRole  = (Account_Role__c)utilClass.createTestRecord(utilClass.setUpData(new Account_Role__c(), 0));
            
            listAnnType = (list<Announcement_Rule__c>)utilClass.addMultiTestRecordsinList(new Announcement_Rule__c(), 1);
            insert  listAnnType;
            listAnnType[0].Selection_Criteria__c = 'Active Full Extract';
            update listAnnType[0];
            
            //create Announcement           
            list<Announcement__c> annList = new list<Announcement__c>();
            Announcement__c announcement1 = new Announcement__c(Announcement_Type__c=listAnnType[0].Id,Account__c=accountList[0].Id,Report_Name__c='Apex Test Report',
                                                                Email_Template__c='Apex Email Template',Report_Id__c='121212',Selection_Criteria__c='Active Full Extract');
            annList.add(announcement1);

            insert annList ;
            
            set<Id> AnnIds = new set<Id>();
            For(Announcement__c ann1 : annList )
            {
                AnnIds.add(ann1.Id);
            }
            
            // Finally create announcement_Record__c records
            list<Announcement_Record__c> annRecList = new list<Announcement_Record__c>();
            
            Announcement_Record__c annRec1 =  new Announcement_Record__c(Client_Avail__c = clientAvailList[0].id, Announcement__c = annList[0].id ); 
            annRecList.add(annRec1);
            Announcement_Record__c annRec2 =  new Announcement_Record__c(Client_Avail__c = clientAvailList[1].id, Announcement__c = annList[0].id );
            annRecList.add(annRec2);
            
            insert annRecList;
            
            WB_DeleteMALARRecs wbDeleteMALARRecsBatch = new WB_DeleteMALARRecs(listAnnType[0].Id);
            database.executeBatch(wbDeleteMALARRecsBatch, 5);
        }    
    }
}