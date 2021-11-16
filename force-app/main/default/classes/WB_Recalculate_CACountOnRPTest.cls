@isTest
public class WB_Recalculate_CACountOnRPTest{
    
    @isTest
    public static void calculateCACountOnRP(){
        
       TestDataUtility tdu = new TestDataUtility();
       List<Account> accList = new List<Account>();
       accList = tdu.createAccountList(); 
       MPM__c m = tdu.createMPM();
       Title__c t = tdu.createTitle(m);
       Language__c l = tdu.createLanguage();
       Country__c c = tdu.createCountry();
       Country_Groups__c countryGroup=new Country_Groups__c(Name='CountryGroup',Account__c=accList[0].Id,Country__c=c.Name);
       insert countryGroup;
       Country_Group_Country__c countryGC = new Country_Group_Country__c (Country_Group__c=countryGroup.Id,Country__c=c.Id);
       insert countryGC; 
       Local_Title__c lt = tdu.createlocalTitle(c, l);

       lt.Title__c=t.id;
       update lt;
      
       //Create Pricing
       Pricing__c newPrice = new Pricing__c();
       newPrice.Content_Type__c = 'Feature';
       newPrice.Account__c = accList[0].Id;
       newPrice.Country__c = c.Id;
       //newPrice.Channel__c = 'DTD';
       newPrice.Channel__c = 'EST';
       newPrice.Format__c = 'HD';
       newPrice.WS_Price__c = 120.00;
       insert newPrice;
       
       //Create Release Plan
       Commercial_Avail__c rp = tdu.createReleasePlan_EST(t, c, lt, l);
       rp.Exclusive_Date__c = System.today().addDays(-200);
       rp.Start_Date__c = System.today().addDays(-200);
       rp.End_Date__c = System.today().addDays(500);
       rp.Rights_End__c= System.today().addDays(500);
       rp.Country_Lookup__c = c.Id;
       update rp;
        Test.startTest();
       Agreement__c sf = tdu.createStorefront(c,rp, t, accList[0]);
       list<Client_Avail__c> CaccListInsert = New list<Client_Avail__c>();
       Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID,Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(10),End_Date__c=System.today().addDays(300));
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300));
       Client_Avail__c ca2 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(20),End_Date__c=System.today().addDays(180),Announce_Override__c='Suppress'); 
       Client_Avail__c ca3 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(12),End_Date__c=System.today().addDays(300),APO_Date__c=Date.Today().addDays(-45));
       Client_Avail__c ca4 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(5),End_Date__c=System.today().addDays(300));
      
       CaccListInsert.add(ca);
       CaccListInsert.add(ca1);
       CaccListInsert.add(ca2); 
       CaccListInsert.add(ca3);
       CaccListInsert.add(ca4);
       insert CaccListInsert;
       
       
       ID batchprocessid = Database.executeBatch(new WB_Recalculate_CACountOnRP(), 200);  
       Test.stopTest();
       
    }
}