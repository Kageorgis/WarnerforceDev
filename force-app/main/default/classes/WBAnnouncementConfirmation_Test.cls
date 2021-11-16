/*****************************************************************************
 * Class Name:      WB_Announcement_Confirmation_Controller_Test
 * Description:     Test Class for WB_Announcement_Confirmation_Controller class
 *
 * Author:          Date:          Description
 * Imran          26-Feb-2014      First Draft 
 *****************************************************************************/
@isTest
public class WBAnnouncementConfirmation_Test{

    @isTest(SeeAllData='true')
    static void testARBatch_Scenario1(){
      //create Account
      Account acctGoogle = TestUtil.initAccount();
      insert acctGoogle;

      // Create account announcer
      Account_Role__c accRole =  new Account_Role__c(Account__c = acctGoogle.Id, User__c = Userinfo.getUserId(), Role__c = 'Announcer');
      insert accRole;
      //create Announcement Rule
      List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
      String reportIdFromReport = (String)reportList.get(0).get('Id');
      Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType1', Account__c=acctGoogle.Id,
                                                    Content_Type__c = 'Feature', Statuses__c='Tentative',Email_Template__c='Announcement Client Avails Activity',
                                                    Channels__c='EST',Report_Template__c='WB Standard Combined',Announcement_From_Name__c='test',
                                                    Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportIdFromReport);
      insert annRule;
     //create Announcement
     list<Announcement__c> annList = new list<Announcement__c>();
     Announcement__c announcement = new Announcement__c(Announcement_Type__c=annRule.Id,Account__c=acctGoogle.Id,Report_Name__c='Apex Test Report',
                                                        Email_Template__c='Apex Email Template',Report_Id__c='121212');

    
    insert announcement ;
    //ER-1710
    
    Contact contactRec = new Contact();
    contactRec.lastname='Test';
    contactRec.Email = 'Test@gmail.com';
    insert contactRec;
      
    Announcement_Receipient__c receipient = new Announcement_Receipient__c();
    receipient.Announcement_Type__c = annRule.Id;
    receipient.Contact__c = contactRec.Id;
    receipient.TO_CC_BCC__c = 'TO';
    insert receipient;
    //End Of ER-1710
    set<id> announcementIdList = new set<id>(); 
    announcementIdList.add(announcement.id);
     
    System.debug('Current User: ' + UserInfo.getUserName()+'UserId--'+Userinfo.getUserId()+ '---'+acctGoogle.Id); 
                                     
     ApexPages.currentPage().getParameters().put('id', annRule.Id);
     //list<announcement__c> ann = new list<announcement__c>();
     //ann.add(announcement);
     
     list<Announcement_Rule__c> ann = new list<Announcement_Rule__c>();
     ann.add(annRule);
     ApexPages.StandardSetController sc = new ApexPages.StandardSetController(ann);
     WB_Announcement_Confirmation_Controller  ccc = new WB_Announcement_Confirmation_Controller ();  
     WB_Announcement_Confirmation_Controller acController = new WB_Announcement_Confirmation_Controller (sc);
     acController.announcementCreation();
     acController.cancel();
     
     
    }
    //@isTest(SeeAllData='true')
    static void testARBatch_Scenario2(){
      //create Account
      Account acctGoogle = TestUtil.initAccount();
      insert acctGoogle;
      
      // create MPM 
      MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
      
      // to create title,local title, country, release plans, client avail
    list<title__c> titleList = new list<title__c>();
    Title__c title1 = new Title__c(Name = 'TestGoogle',MPM__c=mpm.id,Video_Version__c ='555555',Content_Type__c='Feature',Digital_Planning__c='YES',      Clear_to_Avail__c = true);
    titleList.add( title1);
    Title__c title2 = new Title__c(Name = 'TestApple',MPM__c=mpm.id,Video_Version__c ='555666',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true);
    titleList.add( title2);
    insert titleList;
    
    list<Country__c> countryList = new list<Country__c>();
    Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='T11',Country_Code__c='T98');
    Country__c countryFrance1 =new Country__c(Name ='TestFrance1',Country_Code2__c ='778',Country_Code__c='F88');
    countryList.add(countryFrance);
    countryList.add(countryFrance1);
    insert countryList;
    
    Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
    insert languageFrench;
    
    list<Local_Title__c> localTitleList = new list<Local_Title__c>();
    
    Local_Title__c localtitle = new Local_Title__c(Name='test Local Title',Title__c = title1.Id, Country__c = countryFrance.Id, Language__c = languageFrench.Id );
    localTitleList.add(localtitle);
    Local_Title__c localtitle1 = new Local_Title__c(Name='test Local Title',Title__c = title1.Id, Country__c = countryFrance1.Id, Language__c = languageFrench.Id );
    localTitleList.add(localtitle1);
    insert localTitleList;  
    
    list<Commercial_Avail__c> releasePlanList = new list<Commercial_Avail__c>();
    Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub & Audio',Status__c='Tentative',
                                                                Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+6,Rights_End__c=date.today()+7);
    releasePlanList.add(releaseplan1);
    Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(Title__c=title2.Id,Country_Lookup__c=countryFrance.Id,
                                                                Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub & Audio',Status__c='Tentative',
                                                                Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+6,Rights_End__c=date.today()+7);
    releasePlanList.add( releaseplan2);
    
    insert releasePlanList;
    
    Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                        Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active');
    insert storefrontGoogle1;
    
    Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,                                                      
                                                      Client__c=acctGoogle.Id,                                                      
                                                      Status__c='Tentative',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=date.today()+1 );
                                                      
    insert clientAvail1;
    
    // creation ended
       
      // Create account announcer
      Account_Role__c accRole =  new Account_Role__c(Account__c = acctGoogle.Id, User__c = Userinfo.getUserId(), Role__c = 'Announcer');
      insert accRole;
      //create Announcement Rule
      List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
      EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announce - Google Delta no FE'][0];
       system.debug('reportList '+reportList );              
      String reportIdFromReport = (String)reportList.get(0).get('Id');
      Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
    list<Announcement_Rule__c> annRuleList = new list<Announcement_Rule__c>();
    Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=acctGoogle.Id,
                                                    Content_Type__c = 'Feature', Statuses__c='Tentative',Channels__c='DTD',Selection_Criteria__c = 'Active Full Extract', 
                                                    Report_Template__c='WB Standard Combined',Email_Template_Id__c=templateId.id,Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                    Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportIdFromReport, Date_Last_Run__c= myDateTime);
    Announcement_Rule__c annRule2 = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType3', Account__c=acctGoogle.Id,
                                                    Content_Type__c = 'Feature', Statuses__c='Tentative',Channels__c='DTD',Selection_Criteria__c = 'Delta', 
                                                    Report_Template__c='WB Standard Combined',Email_Template_Id__c=templateId.id,Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                    Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportIdFromReport, Date_Last_Run__c= myDateTime);                                              
    annRuleList.add(annRule);
    annRuleList.add(annRule2);
    
    insert annRuleList;
    
   
    
     //create Announcement
     list<Announcement__c> annList = new list<Announcement__c>();
     Announcement__c announcement = new Announcement__c(Announcement_Type__c=annRule.Id,Account__c=acctGoogle.Id,Report_Name__c='Apex Test Report',Selection_Criteria__c = 'Active Full Extract',  
                                                        Email_Template__c='Apex Email Template',Report_Id__c=reportIdFromReport , content_type__c = 'Feature', Channels__c ='DTD',
                                                        status__c ='Tentative',From_Date__c = annRule.Date_Last_Run__c);

    annList.add(announcement);
    insert annList ;
    
    // creating announcement records
     list<Announcement_Record__c> annRecordList = new list<Announcement_Record__c>();
     Announcement_Record__c annRecord = new Announcement_Record__c(Announcement__c = announcement.id ,Client_Avail__c = clientAvail1.id);     
     
     annRecordList.add(annRecord );     
     
     insert annRecordList;
     // updating client avails and associated objects
    Client_Avail__c clientAvail2 = new Client_Avail__c();
    clientAvail2.id = clientAvail1.Id;
    clientAvail2.Price__c = 324;
    clientAvail2.Price_Tier_Text__c = '';   
    clientAvail2.Start_Date__c = releaseplan1.Start_Date__c +1;  
    clientAvail2.End_Date__c=date.today()+3;
    clientAvail2.APO_Date__c= date.today();
    clientAvail2.Announce_Date__c = date.today();
    clientAvail2.Local_Data_Category_Picklist__c = 'TV New Release';
    update clientAvail2;
    
    commercial_avail__c releaseplan3 =  new commercial_avail__c();
    releaseplan3.Id = releaseplan1.Id;
    releaseplan3.title__c = title2.Id;
    releaseplan3.Local_Title__c = localtitle1.Id;
    releaseplan3.Language_Type__c = 'Sub'; 
    update releaseplan3;
    
    local_title__c localtitle2 = new local_title__c() ;
    localtitle2.Id = localtitle1.Id;
    localtitle2.Local_Rating__c ='test';
    localtitle2.Local_Rating_System__c = 'test rating';
    localtitle2.Local_Season__c = 'test season';
    localtitle2.Num_Local_Episodes__c = 121;
    //localtitle2.Version_EIDR__c = 'test Ver';
    localtitle2.Local_DVD_Release_Date__c = date.today();
    localtitle2.Local_Theatrical_Release_Date__c = date.today();
    //localtitle2.Local_Data_Category_Picklist__c = 'TV New Release';
    update localtitle2;
    
    set<id> announcementIdList = new set<id>(); 
    announcementIdList.add(announcement.id);
     
    System.debug('Current User: ' + UserInfo.getUserName()+'UserId--'+Userinfo.getUserId()+ '---'+acctGoogle.Id); 
     string param =  annRule.Id+','+ annRule2.Id;                                 
     ApexPages.currentPage().getParameters().put('id', param);
     list<announcement__c> ann = new list<announcement__c>();
     ann.add(announcement);
     ApexPages.StandardSetController sc = new ApexPages.StandardSetController(ann);
     WB_Announcement_Confirmation_Controller  ccc = new WB_Announcement_Confirmation_Controller ();  
     WB_Announcement_Confirmation_Controller acController = new WB_Announcement_Confirmation_Controller (sc);
     acController.announcementCreation();
    //acController.cancel();
     
     
    }
    @isTest(SeeAllData='true')
    static void testARBatch_Scenario3(){
      //create Account
      Test.startTest();
      Account acctGoogle = TestUtil.initAccount();
      insert acctGoogle;

       // create MPM 
      MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
      // to create title, country, release plans, client avail
      
      Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='555555',MPM__c=mpm.id,Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
    insert title1;
    /*
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='555666',MPM__c=mpm.id,Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true);
    insert title2;
    */
    
    Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='T11',Country_Code__c='T98');
    insert countryFrance;
    
    Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
    insert languageFrench;
    
    
    Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub & Audio',Status__c='Tentative',
                                                                Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+6,Rights_End__c=date.today()+7);
    insert releaseplan1;
    /*
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(Title__c=title2.Id,Country_Lookup__c=countryFrance.Id,
                                                                Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Sub & Audio',Status__c='Tentative',
                                                                Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+6,Rights_End__c=date.today()+7);
    insert releaseplan2;
    */
    Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                        Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
    insert storefrontGoogle1;
    
    Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,                                                      
                                                      Client__c=acctGoogle.Id,                                                      
                                                      Status__c='Tentative',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=date.today()+1 );
                                                      
    insert clientAvail1;
    
    // creation ended
       
      // Create account announcer
      Account_Role__c accRole =  new Account_Role__c(Account__c = acctGoogle.Id, User__c = Userinfo.getUserId(), Role__c = 'Announcer');
      insert accRole;
      
      //create Announcement Rule
      List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
       system.debug('reportList '+reportList );              
       EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announce - Google Delta no FE'][0];
      String reportIdFromReport = (String)reportList.get(0).get('Id');
      Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
      Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=acctGoogle.Id,
                                                    Content_Type__c = 'Feature', Statuses__c='Tentative',Channels__c='DTD',Selection_Criteria__c = 'Delta', 
                                                    Report_Template__c='WB Standard Combined',Email_Template_Id__c=templateId.id,Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                    Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportIdFromReport, Date_Last_Run__c= myDateTime);
      insert annRule;
     //create Announcement
     list<Announcement__c> annList = new list<Announcement__c>();
     Announcement__c announcement = new Announcement__c(Announcement_Type__c=annRule.Id,Account__c=acctGoogle.Id,Report_Name__c='Apex Test Report',Selection_Criteria__c = 'Delta',  Email_Template__c='Apex Email Template',Report_Id__c=reportIdFromReport , content_type__c = 'Feature', Channels__c ='DTD',status__c ='Tentative',From_Date__c = annRule.Date_Last_Run__c);
    
    insert announcement ;
    
    
    set<id> announcementIdList = new set<id>(); 
    announcementIdList.add(announcement.id);
     
    System.debug('Current User: ' + UserInfo.getUserName()+'UserId--'+Userinfo.getUserId()+ '---'+acctGoogle.Id); 
                                         
     ApexPages.currentPage().getParameters().put('id', annRule.Id);
     //list<announcement__c> ann = new list<announcement__c>();
     //ann.add(announcement);
     
     list<Announcement_Rule__c> ann = new list<Announcement_Rule__c>();
     ann.add(annRule);
     ApexPages.StandardSetController sc = new ApexPages.StandardSetController(ann);
     WB_Announcement_Confirmation_Controller  ccc = new WB_Announcement_Confirmation_Controller ();  
     WB_Announcement_Confirmation_Controller acController = new WB_Announcement_Confirmation_Controller (sc);
     acController.announcementCreation();
    //acController.cancel();
     Test.stopTest();
     
    }
    
    @isTest(SeeAllData='true')
    static void testARBatch_Scenario31(){
        
      //create Account
      Account acctGoogle = TestUtil.initAccount();
      insert acctGoogle;
       // create MPM 
      MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
      // to create title, country, release plans, client avail
      
      Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='1857412',MPM__c=mpm.id,Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
    insert title1;
    
    
    Country__c countryFrance =new Country__c(Name ='Afro',Country_Code2__c ='AR1',Country_Code__c='AR');
    insert countryFrance;
    
    Language__c languageFrench = new Language__c(Name='Amerciano',Language_Order__c = 1,Language_Code_2__c='LA');
    insert languageFrench;
    
    Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(
        Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Languages__c=languageFrench.Id,Channel__c='EST',Format__c='HD',Language_Type__c='Sub & Audio',
        Status__c='Tentative',Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+6,Rights_End__c=date.today()+7
    );
    insert releaseplan1;
    
    /*Local_Title__c localtitle1 = new Local_Title__c(Name='test Local Title1212',Title__c = title1.Id, Country__c = countryFrance.Id, Language__c = languageFrench.Id,
        Key__c = 'LA_AR_1857412'
    );
    insert localtitle1;*/
    
    Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
                                                        Channel_Picklist__c = releaseplan1.Channel__c,Format__c=releaseplan1.Format__c,Status__c ='Active',SAP_Customer_Number__c='12010421');
    insert storefrontGoogle1;
    Test.startTest();
    Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,Client__c=acctGoogle.Id,
                                                      Status__c='Tentative',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=date.today()+1 );
    insert clientAvail1;
    
    // creation ended
    
    // Create account announcer
    Account_Role__c accRole =  new Account_Role__c(Account__c = acctGoogle.Id, User__c = Userinfo.getUserId(), Role__c = 'Announcer');
    insert accRole;
    //create Announcement Rule
    List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
       EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announce - Google Delta no FE'][0];
      String reportIdFromReport = (String)reportList.get(0).get('Id');
      Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
      Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=acctGoogle.Id,
                                                    Content_Type__c = 'Feature', Statuses__c='Tentative',Channels__c='EST',Selection_Criteria__c = 'Delta', 
                                                    Report_Template__c='WB Standard Combined',Email_Template_Id__c=templateId.id,Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                    Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportIdFromReport, Date_Last_Run__c= myDateTime);
      insert annRule;
     //create Announcement
     list<Announcement__c> annList = new list<Announcement__c>();
     Announcement__c announcement = new Announcement__c(Announcement_Type__c=annRule.Id,Account__c=acctGoogle.Id,Report_Name__c='Apex Test Report',Selection_Criteria__c = 'Active Full Extract',  Email_Template__c='Apex Email Template',Report_Id__c=reportIdFromReport , content_type__c = 'Feature', Channels__c ='DTD',status__c ='Tentative',From_Date__c = annRule.Date_Last_Run__c);
    
    insert announcement ;
    
    list<Announcement_Record__c> annRecordList = new list<Announcement_Record__c>();
    Announcement_Record__c annRecord = new Announcement_Record__c(Announcement__c = announcement.id ,Client_Avail__c = clientAvail1.id);     
    insert annRecordList;
    
    // updating client avails and associated objects
    Client_Avail__c clientAvail2 = new Client_Avail__c();
    clientAvail2.id = clientAvail1.Id;
    clientAvail2.Price__c = 324;
    clientAvail2.Price_Tier_Text__c = '';   
    clientAvail2.Start_Date__c = releaseplan1.Start_Date__c +1;  
    clientAvail2.End_Date__c=date.today()+3;
    clientAvail2.APO_Date__c= date.today();
    clientAvail2.Announce_Date__c = date.today();
    clientAvail2.Local_Data_Category_Picklist__c = 'TV New Release';
    update clientAvail2;
    
    commercial_avail__c releaseplan3 =  new commercial_avail__c();
    releaseplan3.Id = releaseplan1.Id;
    releaseplan3.title__c = title1.Id;
    releaseplan3.Languages__c = languageFrench.Id ;
    //releaseplan3.Local_Title__c = localtitle1.Id;
    releaseplan3.Language_Type__c = 'Sub & Audio'; 
    update releaseplan3;
    
    /*local_title__c localtitle2 = new local_title__c() ;
    localtitle2.Id = localtitle1.Id;
    localtitle2.Local_Rating__c ='test';
    localtitle2.Local_Rating_System__c = 'test rating';
    localtitle2.Local_Season__c = 'test season';
    localtitle2.Num_Local_Episodes__c = 121;
    localtitle2.Version_EIDR__c = 'test Ver';
    localtitle2.Local_DVD_Release_Date__c = date.today();
    localtitle2.Local_Theatrical_Release_Date__c = date.today();
    //localtitle2.Local_Data_Category_Picklist__c = 'TV New Release';
    update localtitle2;*/
    
    
    set<id> announcementIdList = new set<id>(); 
    announcementIdList.add(announcement.id);
     
     ApexPages.currentPage().getParameters().put('id', annRule.Id);
     //list<announcement__c> ann = new list<announcement__c>();
     //ann.add(announcement);
     
     list<Announcement_Rule__c> ann = new list<Announcement_Rule__c>();
     ann.add(annRule);
     ApexPages.StandardSetController sc = new ApexPages.StandardSetController(ann);
     WB_Announcement_Confirmation_Controller  ccc = new WB_Announcement_Confirmation_Controller ();  
     WB_Announcement_Confirmation_Controller acController = new WB_Announcement_Confirmation_Controller (sc);
     acController.announcementCreation();
    //acController.cancel();
     Test.stopTest();
     
    }
    
    @isTest(SeeAllData='true')
    static void testARBatch_Scenario4(){
        //create Account
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        // create MPM 
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        // to create title, country, release plans, client avail
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='555555',MPM__c=mpm.id,Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true, Formats__c='SD');
        insert title1;
        Title__c title2 = new Title__c(Name = 'TestApple',Video_Version__c ='555666',MPM__c=mpm.id,Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true, Formats__c='SD');
        insert title2;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='T11',Country_Code__c='T98');
        insert countryFrance;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        List<Commercial_Avail__c> releasePlanList = new List<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(
            Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',
            Language_Type__c='Sub & Audio',Status__c='Tentative',Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),
            End_Date__c= date.today()+6,Rights_End__c=date.today()+7
        );
        //insert releaseplan1;
        releasePlanList.add(releaseplan1);
        Commercial_Avail__c releaseplan2 = new Commercial_Avail__c(
            Title__c=title2.Id,Country_Lookup__c=countryFrance.Id,Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',
            Language_Type__c='Sub & Audio',Status__c='Tentative',Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),
            End_Date__c= date.today()+6,Rights_End__c=date.today()+7
        );
        //insert releaseplan2;
        releasePlanList.add(releaseplan2);
        insert releasePlanList;
        /*
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c=title1.Content_Type__c,
            Channel_Picklist__c = releasePlanList[0].Channel__c,Format__c=releasePlanList[0].Format__c,Status__c ='Active'
        );
        insert storefrontGoogle1;
        */
        TestDataUtility objTestDataUtility = new TestDataUtility();
        Agreement__c storefrontGoogle1 = objTestDataUtility.createStorefront(countryFrance,releasePlanList[0],title1,acctGoogle);
        Client_Avail__c clientAvail1 = objTestDataUtility.createClientAvail(releasePlanList[0], storefrontGoogle1, acctGoogle);
        /*
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releasePlanList[0].Id,Client__c=acctGoogle.Id,Status__c='Tentative',
            Start_Date__c=releasePlanList[0].Start_Date__c,End_Date__c=date.today()+1
        );
        insert clientAvail1;
        */
        // creation ended
        
        // Create account announcer
        Account_Role__c accRole =  new Account_Role__c(Account__c = acctGoogle.Id, User__c = Userinfo.getUserId(), Role__c = 'Announcer');
        insert accRole;
        //create Announcement Rule
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
        system.debug('reportList '+reportList ); 
        EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announce - Google Delta no FE'][0];
        String reportIdFromReport = (String)reportList.get(0).get('Id');
        Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
        
        list<Announcement_Rule__c> annRuleList = new list<Announcement_Rule__c>();
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=acctGoogle.Id,
                                                    Content_Type__c = 'Feature', Statuses__c='Tentative',Channels__c='DTD',Selection_Criteria__c = 'Active Full Extract ', 
                                                    Report_Template__c='WB Standard Combined',Email_Template_Id__c=templateId.id,Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                    Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportIdFromReport, Date_Last_Run__c= myDateTime);
        Announcement_Rule__c annRule2 = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType3', Account__c=acctGoogle.Id,
                                                    Content_Type__c = 'Feature', Statuses__c='Tentative',Channels__c='DTD',Selection_Criteria__c = 'Delta', 
                                                    Report_Template__c='WB Standard Combined',Email_Template_Id__c=templateId.id,Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                    Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportIdFromReport, Date_Last_Run__c= myDateTime);                                              
        annRuleList.add(annRule);
        annRuleList.add(annRule2);
        
        insert annRuleList;
        //create Announcement
        list<Announcement__c> annList = new list<Announcement__c>();
        Announcement__c announcement = new Announcement__c(Announcement_Type__c=annRule.Id,Account__c=acctGoogle.Id,Report_Name__c='Apex Test Report',Selection_Criteria__c = 'Active Full Extract',  Email_Template__c='Apex Email Template',Report_Id__c=reportIdFromReport , content_type__c = 'Feature', Channels__c ='DTD',status__c ='Tentative',From_Date__c = annRule.Date_Last_Run__c);

        annList.add(announcement);
        insert annList ;
        
        // creating announcement records
        list<Announcement_Record__c> annRecordList = new list<Announcement_Record__c>();
        Announcement_Record__c annRecord = new Announcement_Record__c(Announcement__c = announcement.id ,Client_Avail__c = clientAvail1.id);
        
        annRecordList.add(annRecord );
        insert annRecordList;
        System.debug('Current User: ' + UserInfo.getUserName()+'UserId--'+Userinfo.getUserId()+ '---'+acctGoogle.Id); 
        
        Test.startTest();
        string param =  annRule.Id+','+ annRule2.Id;
        ApexPages.currentPage().getParameters().put('id', annRule2.Id);
        //list<announcement__c> ann = new list<announcement__c>();
        //ann.add(announcement);
        
        list<Announcement_Rule__c> ann = new list<Announcement_Rule__c>();
        ann.add(annRule);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(ann);
        WB_Announcement_Confirmation_Controller  ccc = new WB_Announcement_Confirmation_Controller ();  
        WB_Announcement_Confirmation_Controller acController = new WB_Announcement_Confirmation_Controller (sc);
        acController.announcementCreation();
        //acController.cancel();
        Test.stopTest();
    }
    
    @isTest(SeeAllData='true')
    static void testARBatch_Scenario5(){
      //create Account
      Account acctGoogle = TestUtil.initAccount();
      insert acctGoogle;
           
      // Create account announcer
      Account_Role__c accRole =  new Account_Role__c(Account__c = acctGoogle.Id, User__c = Userinfo.getUserId(), Role__c = 'Announcer');
      insert accRole;
      //create Announcement Rule
      List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
      String reportIdFromReport = (String)reportList.get(0).get('Id');                            
      Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType1', Account__c=acctGoogle.Id,
                                                    Content_Type__c = 'Feature', Statuses__c='Tentative',Channels__c='EST',
                                                    Report_Template__c='WB Standard Combined',Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                    Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportIdFromReport);
      insert annRule;

     //create Announcement
     list<Announcement__c> annList = new list<Announcement__c>();
     Announcement__c announcement = new Announcement__c(Announcement_Type__c=annRule.Id,Account__c=acctGoogle.Id,Report_Name__c='Apex Test Report',
                                                        Email_Template__c='Apex Email Template',Report_Id__c='121212');

    
    insert announcement ;
    
    set<id> announcementIdList = new set<id>(); 
    announcementIdList.add(announcement.id);
     
    System.debug('Current User: ' + UserInfo.getUserName()+'UserId--'+Userinfo.getUserId()+ '---'+acctGoogle.Id); 
                                         
     ApexPages.currentPage().getParameters().put('id', annRule.Id);
     //list<announcement__c> ann = new list<announcement__c>();
     list<Announcement_Rule__c> ann = new list<Announcement_Rule__c>();
     ann.add(annRule);
     //ann.add(announcement);
     ApexPages.StandardSetController sc = new ApexPages.StandardSetController(ann);
     //WB_Announcement_Confirmation_Controller  ccc = new WB_Announcement_Confirmation_Controller ();  
     WB_Announcement_Confirmation_Controller acController = new WB_Announcement_Confirmation_Controller (sc);
     acController.InternalOnlyCheck = true;
     acController.announcementCreation();
     acController.cancel();
     
     
    }
}