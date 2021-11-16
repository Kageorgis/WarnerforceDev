@isTest(seeAllData=false)
public class WB_DDAccountingInternalReport_Test{

static TestDataUtility tdu = new TestDataUtility();
    
    @isTest
    public static void testExecuteReport_Scheduler()
    {
        Test.startTest();
        WB_Schedule_DDAccountingInternalReport wb = new WB_Schedule_DDAccountingInternalReport();
        String str ='0 0 23 * * ?';
        system.schedule('Test',str,wb);
        Test.stopTest();
    }
    @isTest
    public static void testExecuteReport_1()
    {
       List<Account> aList = tdu.createAccountList(); 
        //Start -- To create Client Avail 
        MPM__c m = tdu.createMPM();
       Title__c t = tdu.createTitle(m);
       Language__c l = tdu.createLanguage();
       Country__c c = tdu.createCountry();
       c.name = 'USA';
       update c;
       Local_Title__c lt = tdu.createlocalTitle(c, l);

       lt.Title__c=t.id;
       update lt;
       //list<Local_Title__c> ltList= [select id, Title__c, Country__c, Language__c, Category__c from Local_Title__c where id = :lt.id];
       Commercial_Avail__c rp = tdu.createReleasePlan(t, c, lt, l);
       //Commercial_Avail__c objRP = [select Id, Title__c, Country_Lookup__c, Languages__c,Start_Date__c,End_Date__c, Local_Title__r.Category__c from Commercial_Avail__c where Id = :rp.Id];

       Agreement__c sf = tdu.createStorefront(c,rp, t, aList[0]);
      // Client_Avail__c ca = tdu.createClientAvail(rp, sf, aList[0]);
      list<Client_Avail__c> CAlistInsert = New list<Client_Avail__c>();
       Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = aList[0].id,Title__c = t.id);
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = aList[0].id,Title__c = t.id);
       Client_Avail__c ca2 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = aList[0].id,Title__c = t.id); 
       CAlistInsert.add(ca);
       CAlistInsert.add(ca1);
       CAlistInsert.add(ca2); 
       insert CAlistInsert;
        
        /*
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName Like '%Standard%'];
        EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announcement USA Standard'][0];
           
        String reportIdFromReport = (String)reportList.get(0).get('Id');
        */
        String reportIdFromReport = '00OU0000002QvWE';
        String templateId = '00XU0000000dgioMAA';        
        
        Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
        Datetime myDateTime1 = Datetime.newInstance(2014, 4, 17);
        List<Announcement_Rule__c> annRuleList = new List<Announcement_Rule__c>();
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=aList[0].Id,
                                                        Content_Type__c = 'Feature', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='DTD',Selection_Criteria__c = 'Framed Delta', 
                                                        Report_Template__c='WB Standard Combined',Email_Template_Id__c=templateId,Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                        Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportIdFromReport, Date_Last_Run__c= myDateTime,Full_Extract__c = true);
        insert annRule;
        annRuleList.add(annRule);
        
        //create Announcement
         Announcement__c announcement = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=aList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Framed Delta',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
                                                            
        insert announcement;
        //create Announcement
         Announcement__c announcement1 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=aList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Run_Date__c=myDateTime,
                                                            From_Date__c=myDateTime,
                                                            Selection_Criteria__c='Framed Delta',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
        insert announcement1;
        Announcement_Record__c annRecords = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=CAlistInsert[0].Id,Change_Status__c = 'No Change');
        Announcement_Record__c annRecords1 = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=CAlistInsert[1].Id,Change_Status__c = 'Change');
        Test.startTest();
        insert annRecords;
        insert annRecords1;
        WB_DDAccountingInternalReport.executeReport();
        Test.stopTest();
    }
    
    @isTest
    public static void testExecuteReport_2()
    {
       List<Account> aList = tdu.createAccountList(); 
        //Start -- To create Client Avail 
        MPM__c m = tdu.createMPM();
       Title__c t = tdu.createTitle(m);
       Language__c l = tdu.createLanguage();
       Country__c c = tdu.createCountry();
       c.name = 'USA';
       update c;
       Local_Title__c lt = tdu.createlocalTitle(c, l);

       lt.Title__c=t.id;
       update lt;
       //list<Local_Title__c> ltList= [select id, Title__c, Country__c, Language__c, Category__c from Local_Title__c where id = :lt.id];
       Commercial_Avail__c rp = tdu.createReleasePlan(t, c, lt, l);
       //Commercial_Avail__c objRP = [select Id, Title__c, Country_Lookup__c, Languages__c,Start_Date__c,End_Date__c, Local_Title__r.Category__c from Commercial_Avail__c where Id = :rp.Id];

       Agreement__c sf = tdu.createStorefront(c,rp, t, aList[0]);
      // Client_Avail__c ca = tdu.createClientAvail(rp, sf, aList[0]);
      list<Client_Avail__c> CAlistInsert = New list<Client_Avail__c>();
       Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = aList[0].id,Title__c = t.id);
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = aList[0].id,Title__c = t.id);
       Client_Avail__c ca2 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = aList[0].id,Title__c = t.id); 
       CAlistInsert.add(ca);
       CAlistInsert.add(ca1);
       CAlistInsert.add(ca2); 
       insert CAlistInsert;
        
        /*
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName Like '%Standard%'];
        EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announcement USA Standard'][0];
           
        String reportIdFromReport = (String)reportList.get(0).get('Id');
        */
        String reportIdFromReport = '00OU0000002QvWE';
        String templateId = '00XU0000000dgioMAA'; 
        
        Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
        Datetime myDateTime1 = Datetime.newInstance(2014, 4, 17);
        List<Announcement_Rule__c> annRuleList = new List<Announcement_Rule__c>();
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=aList[0].Id,
                                                        Content_Type__c = 'Feature', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='DTD',Selection_Criteria__c = 'Framed Delta', 
                                                        Report_Template__c='WB Standard Combined',Email_Template_Id__c=templateId,Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                        Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportIdFromReport, Date_Last_Run__c= myDateTime,Full_Extract__c = true);
        insert annRule;
        annRuleList.add(annRule);
        
        //create Announcement
         Announcement__c announcement = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=aList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Run_Date__c=myDateTime,
                                                            From_Date__c=myDateTime,                                                            
                                                            Selection_Criteria__c ='Framed Delta',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
                                                            
        insert announcement;
        
        List<Announcement_Record__c> annRecords = new List<Announcement_Record__c>();
        annRecords.add(new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=CAlistInsert[0].Id,Change_Status__c = 'New'));
        annRecords.add(new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=CAlistInsert[1].Id,Change_Status__c = 'New'));
        
        Test.startTest();
        insert annRecords;
      
        WB_DDAccountingInternalReport.executeReport();
        Test.stopTest();
    }
    
    @isTest
    public static void testExecuteReport_3()
    {
       List<Account> aList = tdu.createAccountList(); 
        //Start -- To create Client Avail 
        MPM__c m = tdu.createMPM();
       Title__c t = tdu.createTitle(m);
       Language__c l = tdu.createLanguage();
       Country__c c = tdu.createCountry();
       c.name = 'USA';
       update c;
       Local_Title__c lt = tdu.createlocalTitle(c, l);

       lt.Title__c=t.id;
       update lt;
       //list<Local_Title__c> ltList= [select id, Title__c, Country__c, Language__c, Category__c from Local_Title__c where id = :lt.id];
       Commercial_Avail__c rp = tdu.createReleasePlan(t, c, lt, l);
       //Commercial_Avail__c objRP = [select Id, Title__c, Country_Lookup__c, Languages__c,Start_Date__c,End_Date__c, Local_Title__r.Category__c from Commercial_Avail__c where Id = :rp.Id];

       Agreement__c sf = tdu.createStorefront(c,rp, t, aList[0]);
      // Client_Avail__c ca = tdu.createClientAvail(rp, sf, aList[0]);
      list<Client_Avail__c> CAlistInsert = New list<Client_Avail__c>();
       Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = aList[0].id,Title__c = t.id);
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = aList[0].id,Title__c = t.id);
       Client_Avail__c ca2 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = aList[0].id,Title__c = t.id); 
       CAlistInsert.add(ca);
       CAlistInsert.add(ca1);
       CAlistInsert.add(ca2); 
       insert CAlistInsert;
        
        /*
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName Like '%Standard%'];
        EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announcement USA Standard'][0];
           
        String reportIdFromReport = (String)reportList.get(0).get('Id');
        */
        String reportIdFromReport = '00OU0000002QvWE';
        String templateId = '00XU0000000dgioMAA'; 
        Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
        Datetime myDateTime1 = Datetime.newInstance(2014, 4, 17);
        List<Announcement_Rule__c> annRuleList = new List<Announcement_Rule__c>();
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=aList[0].Id,
                                                        Content_Type__c = 'Feature', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='DTD',Selection_Criteria__c = 'Framed Delta', 
                                                        Report_Template__c='WB Standard Combined',Email_Template_Id__c=templateId,Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                        Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportIdFromReport, Date_Last_Run__c= myDateTime,Full_Extract__c = true);
        insert annRule;
        annRuleList.add(annRule);
        
        //create Announcement
         Announcement__c announcement = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=aList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Run_Date__c=myDateTime,
                                                            From_Date__c=myDateTime,                                                            
                                                            Selection_Criteria__c ='Framed Delta',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
                                                            
        insert announcement;
        
        List<Announcement_Record__c> annRecords = new List<Announcement_Record__c>();
        annRecords.add(new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=CAlistInsert[0].Id,Change_Status__c = 'No Change'));
        annRecords.add(new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=CAlistInsert[1].Id,Change_Status__c = 'No Change'));
        
        Test.startTest();
        insert annRecords;
      
        WB_DDAccountingInternalReport.executeReport();
        Test.stopTest();
    }
}