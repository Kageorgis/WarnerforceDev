@isTest
public class WB_CopyCAToAnnouncementFieldsTest{
    
    static List<Account> accList = new List<Account>();
    
    
    @isTest
    public static void testCopyTriggerMethod(){
        
        
       TestDataUtility tdu = new TestDataUtility();  
       accList = tdu.createAccountList(); 
        //Start -- To create Client Avail 
       MPM__c m = tdu.createMPM();
       Title__c t = tdu.createTitle(m);
       t.ALID__c = '0188045205273';
       update t;
       
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
       newPrice.Channel__c = 'DTD';
       newPrice.Format__c = 'HD';
       newPrice.WS_Price__c = 120.00;
       insert newPrice;
       
       //Create Release Plan
       Commercial_Avail__c rp = tdu.createReleasePlan(t, c, lt, l);
       rp.Exclusive_Date__c = System.today().addDays(-200);
       rp.Start_Date__c = System.today().addDays(-200);
       rp.End_Date__c = System.today().addDays(500);
       rp.Rights_End__c= System.today().addDays(500);
       rp.Country_Lookup__c = c.Id;
       update rp;

       Agreement__c sf = tdu.createStorefront(c,rp, t, accList[0]);
       list<Client_Avail__c> CaccListInsert = New list<Client_Avail__c>();
       Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID,Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(10),End_Date__c=System.today().addDays(300));
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300));
       Client_Avail__c ca2 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(20),End_Date__c=System.today().addDays(180),Announce_Override__c='Suppress'); 
       Client_Avail__c ca3 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(12),End_Date__c=System.today().addDays(300));
       Client_Avail__c ca4 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(5),End_Date__c=System.today().addDays(300));
      
       CaccListInsert.add(ca);
       CaccListInsert.add(ca1);
       CaccListInsert.add(ca2); 
       CaccListInsert.add(ca3);
       CaccListInsert.add(ca4);
       insert CaccListInsert;
       
        String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
       Client_Avail_Price__c cap1 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=ca.Start_Date__c,Expiry_Date__c=ca.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c cap2 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=ca1.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c cap3 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca2.id,Category__c='Catalog',Effective_Date__c=ca2.Start_Date__c,Expiry_Date__c=ca2.Start_Date__c.addDays(20),Price__c=10.99);
       Client_Avail_Price__c cap4 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca2.id,Category__c='Catalog',Effective_Date__c=ca2.Start_Date__c.addDays(100),Expiry_Date__c=ca2.End_Date__c,Price_Tier__c= '63.12');
       Client_Avail_Price__c cap5 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca3.id,Category__c='Catalog',Effective_Date__c=ca3.Start_Date__c,Expiry_Date__c=ca3.Start_Date__c.addDays(20),Price__c=10.99);
       Client_Avail_Price__c cap6 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca3.id,Category__c='Catalog',Effective_Date__c=ca3.Start_Date__c.addDays(21),Expiry_Date__c=ca3.End_Date__c,Price__c=9.99);
       Client_Avail_Price__c cap7 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca4.id,Category__c='Catalog',Effective_Date__c=ca4.Start_Date__c,Expiry_Date__c=ca4.Start_Date__c.addDays(20),Price__c=10.99);
       Client_Avail_Price__c cap8 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca4.id,Category__c='Catalog',Effective_Date__c=ca4.Start_Date__c.addDays(21),Expiry_Date__c=ca4.End_Date__c,Price__c=9.99);
       
       List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
        capList.add(cap1);
        capList.add(cap2);
        capList.add(cap3);
        capList.add(cap4);
        capList.add(cap5);
        capList.add(cap6);
        capList.add(cap7);
        capList.add(cap8);
        
        
        
        WB_ClientAvailPriceHandler.recursiveInsert = true;
        Database.SaveResult[] insertResultList = Database.insert(capList,false);
        for(Integer index=0;index<insertResultList.size();index++){
            Database.SaveResult insertResult = insertResultList[index]; 
            if(!insertResult.isSuccess()){
                for(Database.Error err : insertResult.getErrors()) {
                    System.debug(LoggingLevel.INFO,'insertResult Error ->'+ err.getMessage());
                }
            }
        }
        
        Test.startTest();
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
        //EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announce - Google Delta no FE'][0];
            
        String reportIdFromReport = null;//(String)reportList.get(0).get('Id');
        Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
        Datetime myDateTime1 = Datetime.newInstance(2014, 4, 17);
        List<Announcement_Rule__c> annRuleList = new List<Announcement_Rule__c>();
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=accList[0].Id,
                                                        Content_Type__c = 'Feature', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='DTD',Selection_Criteria__c = 'Framed Delta', 
                                                        Report_Template__c='WB Standard Combined',Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                        Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportIdFromReport, Date_Last_Run__c= myDateTime,Full_Extract__c = true,Optional_Triggers__c = 'ALID');
        insert annRule;
        annRuleList.add(annRule);
        
        //create Announcement
         Announcement__c announcement = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Framed Delta',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Selected_Fields__c = 'ALID',
                                                            Channels__c='DTD;EST');
                                                            
        insert announcement;
        //create Announcement
         Announcement__c announcement1 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Run_Date__c=myDateTime,
                                                            From_Date__c=myDateTime,
                                                            Selection_Criteria__c='Framed Delta',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Country_Group__c=countryGroup.Id,
                                                            Selected_Fields__c = 'ALID',
                                                            Channels__c='DTD;EST');
        insert announcement1;
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();
        
        Announcement_Record__c annRecords1 = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap1.Id,Change_Status__c='New');
        annRecList.add(annRecords1);
        
        Announcement_Record__c annRecords2 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca1.Id,Client_Avail_Price__c=cap2.Id);
        annRecList.add(annRecords2);
        Announcement_Record__c annRecords3 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca1.Id,CAP_Id__c=cap2.Id,CAP_Comment__c='CAP Deleted');
        annRecList.add(annRecords3);
                    
        Announcement_Record__c annRecords4 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca2.Id,Client_Avail_Price__c=cap3.Id);
        annRecList.add(annRecords4);
        Announcement_Record__c annRecords5 = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca2.Id,Client_Avail_Price__c=cap4.id);
        annRecList.add(annRecords5);
        
        Database.insert(annRecList);
        
        t.ALID__c = '01880452052731';
        update t;
        
        Set<Id> accountIDSet = new Set<Id>();
        for(Account acc : accList){
            accountIDSet.add(acc.Id);
        }
        
        WB_CopyCAToAnnouncementFields wb = new WB_CopyCAToAnnouncementFields(accountIDSet);
        Database.executeBatch(wb);
        
        Test.stopTest();
    }
}