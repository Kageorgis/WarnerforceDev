@isTest(SeeAllData='true')
private class WB_Announcement_Pre_OrdersTest {
    
    public static Client_Avail__c ca;
    public static Client_Avail_Price__c cap;
    public static TestDataUtility tdu = new TestDataUtility();
    public static Announcement__c announcement;
    public static List<Announcement_Rule__c> annRuleList = new List<Announcement_Rule__c>();
    public static List<Account> aList = tdu.createAccountList(); 
    public static String reportIdFromReport;
    public static Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
    public static Datetime myDateTime1 = Datetime.newInstance(2014, 4, 17);
     static List<Country_SID_Key__c> countrySIDList = new List<Country_SID_Key__c>();
    
    public static void setUpDateBasic(){
        
       //accList = tdu.createAccountList(); 
        //Start -- To create Client Avail 
        MPM__c m = tdu.createMPM();
       Title__c t = tdu.createTitle(m);
       Language__c l = tdu.createLanguage();
       
       Country__c c = null;
       List<Country__c> countries = [Select Id,Name,Country_Code2__c,Country_Code__c From Country__c Where Country_Code__c='FRA'];
       if(countries != null && countries.size() > 0){
        c=countries[0];
       }else{
        c = new Country__c(Name ='France',Country_Code2__c ='FR',Country_Code__c='FRA');
        insert c;
       }
        
       Local_Title__c lt = new Local_Title__c(
            Num_Local_Episodes__c = 10,
            Country__c = c.Id,
            Language__c = l.Id,
            Category__c='TV Catalog',
            Title__c=t.id);
       insert lt;
       list<Local_Title__c> ltList= [select id, Title__c, Country__c, Language__c, Category__c from Local_Title__c where id = :lt.id];

       Commercial_Avail__c rp = new Commercial_Avail__c(
             Title__c= t.Id,
             Country_Lookup__c = c.Id,
             Local_Title__c = lt.Id,
             Languages__c = l.Id ,
             Channel__c='EST',
             Format__c='HD',
             Language_Type__c='Sub',
             Status__c='Tentative',
             Exclusive_Date__c = date.today()+20,
             Start_Date__c = date.today()+20,
             End_Date__c = date.today()+100,
             Rights_End__c = date.today()+100);
        insert rp;

       Agreement__c sf = tdu.createStorefront(c,rp, t, aList[0]);
       
       //countrySIDList.add(new Country_SID_Key__c(Name='France', Country_Code__c='FRA',Country_Code2_c__c='FR',Locale_SID_Key__c='Europe/Lisbon',Region__c='Western Europe'));
       // insert countrySIDList;
        
       ca = new Client_Avail__c(
            Commercial_Avail__c = rp.Id,
            Client__c = aList[0].Id,
            Status__c = 'Tentative',
            Start_Date__c = rp.Start_Date__c,
            End_Date__c = rp.End_Date__c,
            Storefront__c = sf.Id,
            APO_Date__c = system.today()+2
        );
        insert ca;
        
        Pricing__c pricing4 = TestUtil.createPricing(aList[0].Id, c.Id,null);
        pricing4.Name = 'Direct To Video Catalog 1';
        pricing4.Channel__c='EST';
        pricing4.Content_Type__c='Season';
        pricing4.WS_Price__c=36.36;
       // pricing4.Price_Tier__c ='Reprice4';
       // pricing4.Episode_Price_Tier__c='Reprice';
        pricing4.Format__c='HD';
        insert pricing4;
        
         //WB_ClientAvailPriceHandler.recursiveInsert = false;         
        
        cap = new Client_Avail_Price__c(Effective_Date__c=ca.Start_Date__c+5,
                    Client_Avail__c = ca.Id,Category__c='TV Catalog',Price__c=36.36,Type__c='First');
        insert cap;
        
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report WHERE DeveloperName like '%Standard%' limit 1];
        //EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announcement USA Standard' limit 1];
            
        //reportIdFromReport = (String)reportList.get(0).get('Id');
       
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=aList[0].Id,
                                                        Content_Type__c = 'Feature', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='DTD;EST',Selection_Criteria__c = '90 Day Rolling', 
                                                        Report_Template__c='WB Standard Combined',/*Email_Template_Id__c=templateId.id,*/Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                        Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportList[0].id, Date_Last_Run__c= myDateTime);
        insert annRule;
        annRuleList.add(annRule);
        
    }
    
    //If standard announcement was never announced - which means that the pre order was never announced - and both are being announced now
    private static testMethod void testMethod1() {
        setUpDateBasic();
        Test.startTest();
        
        //create Announcement
        List<Announcement__c> annList = new List<Announcement__c>();
         announcement = new Announcement__c(Announcement_Type__c=annRuleList[0].Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=aList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='90 Day Rolling',
                                                            Channels__c='DTD;EST',
                                                            Run_Date__c = myDateTime.addDays(20));
                                                            
        annList.add(announcement);
        insert annList;
        
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();
        Announcement_Record__c annRecords = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap.id,Sales_Channel__c='EST',Change_Status__c = 'New');
        annRecList.add(annRecords);
        insert annRecList;
        set<Id> setIds = new set<Id>();
        setIds.add(annRecList[0].id);
        
        ID batchprocessid = Database.executeBatch(new WB_Announcement_Pre_Orders (annList,annRuleList,setIds), 200);  
        
        test.stopTest();
    }
    
    //If standard announcement was issued in past but no pre order announcement, now the pre order date has been updated - requires a pre order announcement as 'new'
    private static testMethod void testMethod2() {
        setUpDateBasic();
        Test.startTest();
        List<Announcement__c> annList = new List<Announcement__c>();
        
        //create Announcement
         announcement = new Announcement__c(Announcement_Type__c=annRuleList[0].Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=aList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='90 Day Rolling',
                                                            Channels__c='DTD;EST',
                                                            Run_Date__c = myDateTime.addDays(20));
                                                            
        annList.add(announcement);
        insert annList;
        
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();
        Announcement_Record__c annRecords1 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap.id,Sales_Channel__c='EST',Change_Status__c = 'New');
        annRecList.add(annRecords1);
        Announcement_Record__c annRecords2 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap.id,Sales_Channel__c='EST',Change_Status__c = 'Change',Changed_Fields__c='Pre Order Date');
        annRecList.add(annRecords2);
        insert annRecList;
        set<Id> setIds = new set<Id>();
        setIds.add(annRecList[1].id);
        
        ID batchprocessid = Database.executeBatch(new WB_Announcement_Pre_Orders (annList,annRuleList,setIds), 200);  
        
        test.stopTest();
    }
    
    // Pre-Order date changed and Pre-Order Avail was already announced - issue a PO change announcement
    // Client Avail Start Date changed and Pre-Order Avail was already announced - issue a PO change announcement
    private static testMethod void testMethod3() {
        setUpDateBasic();
        Test.startTest();
        List<Announcement__c> annList = new List<Announcement__c>();
        
        //create Announcement
         announcement = new Announcement__c(Announcement_Type__c=annRuleList[0].Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=aList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='90 Day Rolling',
                                                            Channels__c='DTD;EST',
                                                            Run_Date__c = myDateTime.addDays(20));
                                                            
        annList.add(announcement);
        insert annList;
        
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();
        Announcement_Record__c annRecords1 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap.id,Sales_Channel__c='EST',Change_Status__c = 'New');
        annRecList.add(annRecords1);
        Announcement_Record__c annRecords2 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap.id,Sales_Channel__c='POEST',Change_Status__c = 'New');
        annRecList.add(annRecords2);
        Announcement_Record__c annRecords3 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap.id,Sales_Channel__c='EST',Change_Status__c = 'Change',Changed_Fields__c='Pre Order Date,Status');
        annRecList.add(annRecords3);
        insert annRecList;
        set<Id> setIds = new set<Id>();
        setIds.add(annRecList[2].id);
        
        ID batchprocessid = Database.executeBatch(new WB_Announcement_Pre_Orders (annList,annRuleList,setIds), 200);  
        
        test.stopTest();
    }
    
    // Pre Order has been issued in past, now the Pre Order date has been removed - need to issue the Pre Order cancellation
    private static testMethod void testMethod4() {
        setUpDateBasic();
        Test.startTest();
        List<Announcement__c> annList = new List<Announcement__c>();
        
        //create Announcement
         announcement = new Announcement__c(Announcement_Type__c=annRuleList[0].Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=aList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='90 Day Rolling',
                                                            Channels__c='DTD;EST',
                                                            Run_Date__c = myDateTime.addDays(20));
                                                            
        annList.add(announcement);
        insert annList;
        
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();
        Announcement_Record__c annRecords1 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap.id,Sales_Channel__c='EST',Change_Status__c = 'New');
        annRecList.add(annRecords1);
        Announcement_Record__c annRecords2 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap.id,Sales_Channel__c='POEST',Change_Status__c = 'New');
        annRecList.add(annRecords2);
        ca.APO_Date__c = null;
        update ca;
        Announcement_Record__c annRecords3 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap.id,Sales_Channel__c='EST',Change_Status__c = 'Change',Changed_Fields__c='Pre Order Date');
        annRecList.add(annRecords3);
        insert annRecList;
        set<Id> setIds = new set<Id>();
        setIds.add(annRecList[2].id);
        
        ID batchprocessid = Database.executeBatch(new WB_Announcement_Pre_Orders (annList,annRuleList,setIds), 200);  
        
        test.stopTest();
    }
    
    //ER-963 start - Sriniz
    //Announce pre-order always, along with regular EST and if it wasnt already included in the announcement for the reasons in above if statements - ER-963
    private static testMethod void testMethod5() {
      setUpDateBasic();
        Test.startTest();
        List<Announcement__c> annList = new List<Announcement__c>();
        
        //create Announcement
         announcement = new Announcement__c(Announcement_Type__c=annRuleList[0].Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=aList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='90 Day Rolling',
                                                            Channels__c='DTD;EST',
                                                            Run_Date__c = myDateTime.addDays(20));
                                                            
        annList.add(announcement);
        insert annList;
        
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();
        Announcement_Record__c annRecords3 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca.Id,Sales_Channel__c='EST',Change_Status__c = 'No Change',Changed_Fields__c='');
        annRecList.add(annRecords3);
        insert annRecList;
        set<Id> setIds = new set<Id>();
        setIds.add(annList[0].id);
        
        ID batchprocessid = Database.executeBatch(new WB_Announcement_Pre_Orders (annList,annRuleList,setIds), 200);  
        
        test.stopTest();
   }
  
   //Not a part of ER-963, but wrote this method to cover additional lines of code
   private static testMethod void testMethod6() {
      setUpDateBasic();
        Test.startTest();
        List<Announcement__c> annList = new List<Announcement__c>();
        
        //create Announcement
         announcement = new Announcement__c(Announcement_Type__c=annRuleList[0].Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=aList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='90 Day Rolling',
                                                            Channels__c='DTD;EST',
                                                            Run_Date__c = myDateTime.addDays(20));
                                                            
        annList.add(announcement);
        insert annList;
        
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();
        Announcement_Record__c annRecords1 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca.Id,Sales_Channel__c='EST',Change_Status__c = 'New');
        annRecList.add(annRecords1);
        Announcement_Record__c annRecords2 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca.Id,Sales_Channel__c='POEST',Change_Status__c = 'New');
        annRecList.add(annRecords2);
        Announcement_Record__c annRecords3 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca.Id,Sales_Channel__c='EST',Change_Status__c = 'No Change',Changed_Fields__c=null);
        annRecList.add(annRecords3);
        insert annRecList;
        ca.Announce_Override__c = 'Force';
        update ca;
        set<Id> setIds = new set<Id>();
        setIds.add(annList[0].id);
        
        ID batchprocessid = Database.executeBatch(new WB_Announcement_Pre_Orders (annList,annRuleList,setIds), 200);  
        
        test.stopTest();
   }
   //ER-963 end - Sriniz
   
   //Akash Changes Start
   private static testMethod void testMethod7() {
        setUpDateBasic();
        Test.startTest();
        List<Announcement__c> annList = new List<Announcement__c>();
        
        //create Announcement
         announcement = new Announcement__c(Announcement_Type__c=annRuleList[0].Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=aList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='90 Day Rolling',
                                                            Channels__c='DTD;EST',
                                                            Run_Date__c = myDateTime.addDays(20));
                                                            
        annList.add(announcement);
        insert annList;
        
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();
        Announcement_Record__c annRecords1 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap.id,Sales_Channel__c='EST',Client_Start__c=system.today()+5);
        annRecList.add(annRecords1);
        Announcement_Record__c annRecords2 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap.id,Sales_Channel__c='POEST',Change_Status__c = 'New',Client_Start__c=system.today()+15);
        annRecList.add(annRecords2);
        Announcement_Record__c annRecords3 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap.id,Sales_Channel__c='EST',Change_Status__c = 'Change',Changed_Fields__c='Pre Order Date',Client_Start__c=system.today()+25);
        annRecList.add(annRecords3);
        insert annRecList;
        set<Id> setIds = new set<Id>();
        setIds.add(annRecList[2].id);
        
        ID batchprocessid = Database.executeBatch(new WB_Announcement_Pre_Orders (annList,annRuleList,setIds), 200);  
        
        test.stopTest();
    }
   //Akash Changes Finish

}