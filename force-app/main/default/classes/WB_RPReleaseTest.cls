@isTest
public class WB_RPReleaseTest {

    @testSetup static void setup() {

        Country__c countryusa = new Country__c(
            Name = 'USA',
            Country_Code__c = 'US',
	    	Country_Code2__c = 'US'
            );
        insert countryusa;

        MRP_Costing__c physicalmrpc1 = new MRP_Costing__c(
            // Category__c = 'NR',
            SRP__c = 29.98,
  	    Retail_Cost__c = 18.47,
	    Expected_Retail__c = 19.99
            );
	    physicalmrpc1.RecordTypeId = 
	      Schema.SObjectType.MRP_Costing__c.getRecordTypeInfosByName().get('Physical').getRecordTypeId();
	    physicalmrpc1.Country__c = countryusa.id;
	    insert physicalmrpc1;

        MRP_Costing__c physicalmrpc2 = new MRP_Costing__c(
            // Category__c = 'NR',
            SRP__c = 34.98,
  	    Retail_Cost__c = 21.4,
	    Expected_Retail__c = 26.99
            );
	    physicalmrpc2.RecordTypeId = 
	      Schema.SObjectType.MRP_Costing__c.getRecordTypeInfosByName().get('Physical').getRecordTypeId();
	    physicalmrpc2.Country__c = countryusa.id;
	    insert physicalmrpc2;

        MRP_Costing__c digitalmrpc1 = new MRP_Costing__c(
            Content_Type__c = 'Episode',
            Category__c = 'Other',
            SRP__c = 4.49,
  	    	Retail_Cost__c = 3.14
            );
	    digitalmrpc1.RecordTypeId = 
	      Schema.SObjectType.MRP_Costing__c.getRecordTypeInfosByName().get('Digital').getRecordTypeId();
	    digitalmrpc1.Country__c = countryusa.id;
	    insert digitalmrpc1;

        MRP_Costing__c digitalmrpc2 = new MRP_Costing__c(
            Content_Type__c = 'Episode',
            Category__c = 'Other',
            SRP__c = 3.99,
  	    	Retail_Cost__c = 2.8
            );
	    digitalmrpc2.RecordTypeId = 
	      Schema.SObjectType.MRP_Costing__c.getRecordTypeInfosByName().get('Digital').getRecordTypeId();
	    digitalmrpc2.Country__c = countryusa.id;
	    insert digitalmrpc2;
        
        RF_Studio__c std = new RF_Studio__c();
        std.Distributor__c = 'test';
        insert std;

/*
        Account newaccount1 = new Account(
            Name = 'WB Internal'
            );
	    newaccount1.RecordTypeID = 
	      Schema.SObjectType.Account.getRecordTypeInfosByName().get('Digital Client').getRecordTypeId();			  
            insert newaccount1;

        Contact newcontact1 = new Contact(
            LastName = 'Mayne'
            );
	    newcontact1.RecordTypeID = 
	      Schema.SObjectType.Contact.getRecordTypeInfosByName().get('WBHE Contact').getRecordTypeId();	
	    newcontact1.AccountId = newaccount1.id;		  
            insert newcontact1;

        Release_Planning_Title__c RPTitle1 = new Release_Planning_Title__c(
            Name = 'Falling Skies S1',
	    Marketing_Group__c = 'WB'
            );
	    RPTitle1.WB_HE_Contact__c = newcontact1.id;		  
            insert RPTitle1;
*/

        RecordType rtus = [select id,Name from RecordType where SobjectType='Release__c' and Name='TV' Limit 1];
        RecordType rtbd = [select id,Name from RecordType where SobjectType='Release_Planning_Release__c' and Name='Blu-ray' Limit 1];
        RecordType rtdtv = [select id,Name from RecordType where SobjectType='Release_Planning_Release__c' and Name='Digital TV Store' Limit 1];
        Release__c RFRelease1 = new Release__c(
            Name = 'TV Release 1',
            Content_Type__c = 'Season',
            RecordTypeId = rtus.id,
            Country_List__c = 'USA',
            Country__c = countryusa.id,
            Premiere_Date__c = System.today(),
        	Finale_Date__c = System.today(),
            Street_Date__c = System.today(),
            RF_Studio__c =std.id,
        	Physical_Date_Status__c = 'Confirmed'
            );
//	    RPCountry1.Release_Planning_Title__c = RPTitle1.id;	
        insert RFRelease1;
        Account acc = new Account ();
        acc.Name = 'Internal';
        insert acc;
        contact con = new contact();
        con.LastName = acc.name;
        con.AccountId = acc.id;
        insert con;
        
        Release_Planning_Release__c BDRPR = new Release_Planning_Release__c(
        Category__c = 'NR',
//	    Budget_Planning_Year_and_Quarter__c = 'Q1 2019',
	    RecordTypeId = rtbd.id,
	    Release__c = RFRelease1.id,
	    SRP__c = 29.98
	    );
        insert BDRPR;
        
        Release_Planning_Release__c DTVRPR = new Release_Planning_Release__c(
        Category__c = 'Next Day Air (NDA)',
        Holdback_Logic__c = 'Next Day Air (NDA)',
//	    Budget_Planning_Year_and_Quarter__c = 'Q1 2019',
	    RecordTypeId = rtdtv.id,
	    Release__c = RFRelease1.id,
	    SD_Episode_Retail__c = 4.49,
	    SD_Season_Retail__c	= 10,
	    HD_Episode_Retail__c = 4.49,
	    HD_Season_Retail__c	= 10,
	    X4k_Episode_Retail__c = 12,
	    X4k_Season_Retail__c = 2,
        Launch_Date__c = system.today() + 180
	    );
        insert DTVRPR;   
        
        Release_Planning_Release__c DTVRPR2 = new Release_Planning_Release__c(
        Category__c = 'Day After Finale',
        Holdback_Logic__c = 'Day After Finale (DAF)',
//	    Budget_Planning_Year_and_Quarter__c = 'Q1 2019',
	    RecordTypeId = rtdtv.id,
	    Release__c = RFRelease1.id,
	    SD_Episode_Retail__c = 4.49,
	    SD_Season_Retail__c	= 10,
	    HD_Episode_Retail__c = 4.49,
	    HD_Season_Retail__c	= 10,
	    X4k_Episode_Retail__c = 12,
	    X4k_Season_Retail__c = 2,
        Launch_Date__c = system.today() + 180
	    );
        insert DTVRPR2;    
    }

    @isTest static void testMethod1() {
 	Test.startTest();    
//	Release_Planning_Country_Content__c RPCountry = [SELECT ID from Release_Planning_Country_Content__c WHERE 
//							Release_Planning_Title__r.Name = 'Falling Skies S1' LIMIT 1]   
    Release_Planning_Release__c BDRPR2 = [SELECT Retail_Cost__c, Expected_Retail__c from Release_Planning_Release__c where Category__c = 'NR' limit 1];
    System.assertEquals(BDRPR2.Retail_Cost__c,18.47);
    Test.stopTest();
    }    
        
    @isTest static void testMethod2() {
    Test.startTest();  
    Release_Planning_Release__c BDRPR = [SELECT ID, SRP__c, Retail_Cost__c, Expected_Retail__c from Release_Planning_Release__c where Category__c = 'NR' limit 1];
	BDRPR.SRP__c = 34.98;
	update BDRPR;
	Release_Planning_Release__c BDRPR3 = [SELECT Retail_Cost__c, Expected_Retail__c from Release_Planning_Release__c where Category__c = 'NR' limit 1];
	System.assertEquals(BDRPR3.Retail_Cost__c,21.4);
	Test.stopTest();
    }

    @isTest static void testMethod3() {
	Test.startTest();          
    Release_Planning_Release__c DTVRPR2 = [SELECT SD_Episode_Wholesale__c, SD_Season_Wholesale__c 
					       from Release_Planning_Release__c where Category__c = 'Next Day Air (NDA)' limit 1];
    System.assertEquals(DTVRPR2.SD_Episode_Wholesale__c,3.14);
	System.assertEquals(DTVRPR2.SD_Season_Wholesale__c,7);
	Test.stopTest();
    }
    
    @isTest static void testMethod4() {    
    Test.startTest(); 
    Release__c Rel = [SELECT Name, Id,Street_Date__c,Physical_Date_Status__c,EST_Date__c,Premiere_Date__c,Finale_Date__c 
                      FROM Release__c LIMIT 1]; 
//    system.debug('Release Name:  ' + rel.Name);
//    Rel.Premiere_Date__c = Date.ValueOf(System.today().addDays(2));
//    Rel.Finale_Date__c = Date.ValueOf(System.today().addDays(2));
//    Rel.Street_Date__c = Date.ValueOf(System.today().addDays(2));
//    Rel.Physical_Date_Status__c = 'Tentative';   

//    update(Rel);
        
    Release_Planning_Release__c DTVRPR = [SELECT SD_Episode_Retail__c, SD_Season_Retail__c, SD_Episode_Wholesale__c, 
                           SD_Season_Wholesale__c, HD_Episode_Retail__c, HD_Season_Retail__c, X4k_Episode_Retail__c,
                           X4k_Season_Retail__c             
					       from Release_Planning_Release__c where Category__c = 'Next Day Air (NDA)' limit 1];
    DTVRPR.SD_Episode_Retail__c = 3.99;
    DTVRPR.SD_Season_Retail__c = 12;
	DTVRPR.HD_Episode_Retail__c = 3.99;
	DTVRPR.HD_Season_Retail__c = 12;
	DTVRPR.X4k_Episode_Retail__c = 3.99;
	DTVRPR.X4k_Season_Retail__c = 13;
	update DTVRPR;
	Release_Planning_Release__c DTVRPR3 = [SELECT SD_Episode_Wholesale__c, SD_Season_Wholesale__c 
					       from Release_Planning_Release__c where ID = :DTVRPR.id];
	System.assertEquals(DTVRPR3.SD_Episode_Wholesale__c,2.8);  
    Test.stopTest();  
    }
    
    
}