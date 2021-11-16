@isTest
private class WB_CreatePreOrderCAPAndMappingARTest {
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
             //Channel__c='DTD',
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
       
       countrySIDList.add(new Country_SID_Key__c(Name='France', Country_Code__c='FRA',Country_Code2_c__c='FR',Locale_SID_Key__c='Europe/Lisbon',Region__c='Western Europe'));
       insert countrySIDList;
        
       ca = new Client_Avail__c(
            Commercial_Avail__c = rp.Id,
            Client__c = aList[0].Id,
            Status__c = 'Tentative',
            Start_Date__c = rp.Start_Date__c,
            End_Date__c = rp.End_Date__c,
            Storefront__c = sf.Id
            
        );
        insert ca;
        
        WB_ClientAvailPriceHandler.recursiveUpdate = true;
        
        Client_Avail__c ca1 = new Client_Avail__c( Id = ca.Id, APO_Date__c = system.today()-2);
        update ca1;
        
        
        
        
        Pricing__c pricing4 = TestUtil.createPricing(aList[0].Id, c.Id,null);
        pricing4.Name = 'Direct To Video Catalog 1';
        pricing4.Channel__c='VODc';
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
       system.debug('alist' + aList[0]);

        
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=aList[0].Id,
                                                        Content_Type__c = 'Feature', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='DTD',Selection_Criteria__c = '90 Day Rolling', 
                                                        Report_Template__c='WB Standard Combined',Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                        Announcement_From_Email__c='test1122@test.com', Date_Last_Run__c= myDateTime);
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
        Announcement_Record__c annRecord1s = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca.Id,Sales_Channel__c='POEST',Change_Status__c = 'New');
        annRecList.add(annRecord1s);
        insert annRecList;
        set<Id> setIds = new set<Id>();
        setIds.add(annRecList[0].id);
        
        List<Client_Avail__c> capRec = [ Select Id, APO_Date__c, Start_Date__c  ,(Select Id, Effective_Date__c, type__c from Client_Avail_Prices__r) from Client_Avail__c];

        
        
        ID batchprocessid = Database.executeBatch(new WB_CreatePreOrderCAPAndMappingAR (), 200); 
        List<Client_Avail__c> caList = [Select Id from Client_Avail__c];
        
        ID batchprocessid2 = Database.executeBatch(new WB_CreatePreOrderCAPAndMappingAR (caList), 200); 
        
        test.stopTest();
    }
}