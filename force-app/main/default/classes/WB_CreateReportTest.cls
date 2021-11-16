/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class WB_CreateReportTest {
    
    static TestDataUtility tdu = new TestDataUtility();
    
    
    @isTest
    static void testPositiveGetAnnouncementRecipientEmailId() {
        //Preparing Data for Testing.
        List<Account> aList = tdu.createAccountList();
        List<Contact> contactList = tdu.createContact(aList[0]);
        Announcement_Rule__c ar = tdu.createAnnouncementType(aList[0]);
        List<Announcement_Receipient__c> aReceipietList = 
                           tdu.createAnnouncementReceipient(ar, contactList,'TO');
                        
        //Actual Testing Start
        List<String> cList = WB_CreateReport.getAnnouncementRecipientEmailId(ar.Id,'TO'); 
        System.assertEquals(cList.size(), contactList.size());
    }
    
    /*
    static testMethod void testPositiveAttachCSVFile() {
        //Preparing Data for Testing.
        List<Account> aList = tdu.createAccountList();
        List<Contact> contactList = tdu.createContact(aList[0]);
        Announcement_Rule__c ar = tdu.createAnnouncementType(aList[0]);
        Announcement__c ann = tdu.createAnnouncement(aList[0], ar);
        
        //Actual Testing Start
        String rurl = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/';
        ApexPages.PageReference report = new ApexPages.PageReference(rurl);
        Attachment a = WB_CreateReport.attachCSVFile('Test',report,ann.Id);
        System.assertNotEquals(a, null);
        if(a!= null){
            System.assertEquals(a.ParentId, ann.Id);
        }
    }*/
    
    @isTest(SeeAllData='true')
    static  void testPositiveCreateEmail() {
        //Preparing Data for Testing.
        List<Account> aList = tdu.createAccountList();
        List<Contact> contactList = tdu.createContact(aList[0]);
        Contact Tocontact = new Contact(FirstName='TO',LastName = 'TO',
                                Email = 'to@to.com',AccountId = aList[0].Id);
        Contact ccContact = new Contact(FirstName='CC',LastName = 'CC',
                                Email = 'cc@cc.com',AccountId = aList[0].Id);
        Contact bccContact = new Contact(FirstName='BCC',LastName = 'BCC',
                                Email = 'bcc@bcc.com',AccountId = aList[0].Id);
        insert Tocontact;
        insert ccContact;
        insert bccContact;
        
        Announcement_Rule__c ar = tdu.createAnnouncementType(aList[0]);
        Announcement_Receipient__c arc1 = 
            new Announcement_Receipient__c(Announcement_Type__c=ar.Id,
                                    Contact__c=Tocontact.Id,TO_CC_BCC__c='TO');
        Announcement_Receipient__c arc2 = 
            new Announcement_Receipient__c(Announcement_Type__c=ar.Id,
                                    Contact__c=ccContact.Id,TO_CC_BCC__c='CC');
        Announcement_Receipient__c arc3 = 
            new Announcement_Receipient__c(Announcement_Type__c=ar.Id,
                                    Contact__c=bccContact.Id,TO_CC_BCC__c='BCC');
        insert new List<Announcement_Receipient__c>{arc1,arc2,arc3};
    
        Announcement__c ann = tdu.createAnnouncement(aList[0], ar);
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
        String rurl = 'https://' + System.URL.getSalesforceBaseUrl().getHost() + '/'+reportList[0];
        ApexPages.PageReference report = 
                    new ApexPages.PageReference('/'+reportList[0]+'?csv=1&pv0=AN-000000000');
        CAS_Global_Settings__c casgs = new CAS_Global_Settings__c();
        //Announcement__c an = [SELECT id from Announcement__c WHERE Name='AN-000000000'];
        casgs.Name = 'TestCS';
        casgs.Global_Email__c = 'wbhesalesservices@warnerbros.com';
        //casgs.Global_Email__c = 'milon.dey@wbconsultant.com';
        insert casgs;
        CAS_Global_Settings__c globalConfig = CAS_Global_Settings__c.getValues('TestCS');
        system.debug('globalConfig'+globalConfig);
        string OWD_EMAIL_ADDRESS =  globalConfig.Global_Email__c;
        OrgWideEmailAddress owea = [SELECT Id 
                                    FROM OrgWideEmailAddress 
                                    WHERE Address=:OWD_EMAIL_ADDRESS][0];
        Folder f = [SELECT Id FROM Folder where DeveloperName='Announcement_Email_Templates'];
        /*EmailTemplate e = new EmailTemplate (developerName = 'test', 
                                FolderId = f.Id, 
                                TemplateType= 'Text', 
                                Name = 'test');*/
        //insert e;
        EmailTemplate e =[SELECT id,Subject, HtmlValue, Body, name 
                            FROM EmailTemplate 
                            WHERE name = 'Announce - Google Delta no FE'];
        ar.Email_Template_Id__c = e.Id;
       // Test.startTest();
        System.debug('REPORT ID : '+reportList[0].Id);
        //List<Attachment> a =  WB_CreateReport.attachCSVFile('a.csv',reportList[0].Id,ann.Name,ann.Id); //ChangedShekhar to below line
           Attachment a =  WB_CreateReport.attachCSVFile('a.csv',reportList[0].Id,ann.Name,ann.Id); 
           List<Attachment> attachmentList = new List<Attachment>();
           attachmentList.add(a);
        //Actual Testing Start - 1
        Messaging.SingleEmailMessage sem = 
            WB_CreateReport.createEmail('Content','Subject',null,null,null,
                                                owea,null,null,ann,null,null,attachmentList);
        System.assertNotEquals(sem, null);
        
        Test.startTest();
        //Actual Testing Start -2
        List<String> to = WB_CreateReport.getAnnouncementRecipientEmailId(ar.Id,'TO');
        List<String> cc = WB_CreateReport.getAnnouncementRecipientEmailId(ar.Id,'CC');
        List<String> bcc = WB_CreateReport.getAnnouncementRecipientEmailId(ar.Id,'BCC');
        System.assertEquals(to[0], 'to@to.com');
        System.assertEquals(cc[0], 'cc@cc.com');
        System.assertEquals(bcc[0], 'bcc@bcc.com');
        Messaging.SingleEmailMessage sem1 = 
            WB_CreateReport.createEmail(null,null,report,'a.csv',contactList[0],
                                    owea,new List<String>{'a@a.c'},ar,ann,to,cc,attachmentList);
        Test.stopTest();
        System.assertNotEquals(sem1, null);
    }
    
    @isTest
    static void testPositiveFeedAccountChatter() {
        List<Account> aList = tdu.createAccountList();
        List<Contact> contactList = tdu.createContact(aList[0]);
        Announcement_Rule__c ar = tdu.createAnnouncementType(aList[0]);
        Announcement__c ann = tdu.createAnnouncement(aList[0], ar);
        FeedItem fiTrue = WB_CreateReport.feedAccountChatter(ann,true);
        FeedItem fiFalse = WB_CreateReport.feedAccountChatter(ann,false);
        String strfiTrue = fiTrue.Body;
        String strfiFalse = fiFalse.Body;
        System.assert(strfiTrue.contains('has been sent.'));
        System.assert(strfiFalse.contains('has no entries.'));
    }
    
    @isTest(SeeAllData='true')
    static void testPositiveCreateReportEmail() {
         //Preparing Data for Testing.
        List<Account> aList = tdu.createAccountList();
        List<Contact> contactList = tdu.createContact(aList[0]);
        Announcement_Rule__c ar = tdu.createAnnouncementType(aList[0]);
        Announcement__c ann = tdu.createAnnouncement(aList[0], ar);
        EmailTemplate e =[SELECT id,Subject, HtmlValue, Body, name 
                            FROM EmailTemplate 
                            WHERE name = 'Announce - Google Delta no FE'];
        ar.Email_Template_Id__c = e.Id;
        update ar;
        String ids = ann.Id + ',';
        
        //Test for Zero records
        WB_CreateReport.createReportEmail(ids);

       //Test for > Zero records
       MPM__c m = tdu.createMPM();
       Title__c t = tdu.createTitle(m);
       Language__c l = tdu.createLanguage();
       Country__c c = tdu.createCountry();
       Local_Title__c lt = tdu.createlocalTitle(c, l);
       system.debug('Local data values inserted are ----'+lt);
       lt.Title__c=t.id;
       update lt;
       list<Local_Title__c> ltList= [select id, Title__c, Country__c, Language__c, Category__c from Local_Title__c where id = :lt.id];
       system.debug('ltList ===========> ' + ltList);
       Test.startTest();
       Commercial_Avail__c rp = tdu.createReleasePlan(t, c, ltList[0], l);
       Commercial_Avail__c objRP = [select Id, Title__c, Country_Lookup__c, Languages__c,Start_Date__c,End_Date__c, Local_Title__r.Category__c from Commercial_Avail__c where Id = :rp.Id];
       system.debug('objRP =======> ' + objRP.Local_Title__r.Category__c + ' : ' + objRP);
       
       Agreement__c sf = tdu.createStorefront(c,rp, t, aList[0]);
       Client_Avail__c ca = tdu.createClientAvail(objRP, sf, aList[0]);
       
       system.debug('Client Avail inserted is ' + ca);
       
       tdu.createAnnouncementRecord(new List<Announcement__c>{ann}, aList[0], new List<Client_Avail__c>{ca});

       WB_CreateReport.createReportEmail(ids);  
       
       
       //Test for 25000 and 75000 limit
       //As we cannot create more than 10000 DML operation we cannot create 25K
       //records. Other option is to fetch the data from system
       try {
           Announcement__c an25= [SELECT Id,Announcement_Record_Count__c 
                                   FROM Announcement__c 
                                WHERE Announcement_Record_Count__c > 25000
                                AND Announcement_Record_Count__c < 75000 LIMIT 1][0];
           WB_CreateReport.createReportEmail(an25.id+',');
       }catch (Exception e1){
            System.Debug('Their is not enough data in this system make the testcase failed');
       }
       
        //Test for 75000 limit
        try{
            Announcement__c an75= [
                SELECT Id,Announcement_Record_Count__c 
                  FROM Announcement__c 
                 WHERE Announcement_Record_Count__c > 75000 LIMIT 1][0];
            WB_CreateReport.createReportEmail(an75.id+',');
        }catch (Exception e1){
            System.Debug('Their is not enough data in this system make the testcase failed');
        }
        Test.stopTest();
    }
    
    /*
        Bulk Testing required atleast 20 Annoucement record to be send at at 
        Time. And see if the application behave as expected.
    */
    @isTest
    static void testBulkAnnouncement(){
        //Preparing Data for Testing.
        List<Account> aList = tdu.createAccountList();
        List<Contact> contactList = tdu.createContact(aList[0]);
        Announcement_Rule__c ar = tdu.createAnnouncementType(aList[0]);
        Announcement__c ann = tdu.createAnnouncement(aList[0], ar);
        EmailTemplate e =[SELECT id,Subject, HtmlValue, Body, name 
                            FROM EmailTemplate 
                            WHERE name = 'Announce - Google Delta no FE'];
        ar.Email_Template_Id__c = e.Id;
        update ar;
        MPM__c m = tdu.createMPM();
        Title__c t = tdu.createTitle(m);
        Language__c l = tdu.createLanguage();
        Country__c c = tdu.createCountry();
        Local_Title__c lt = tdu.createlocalTitle(c, l);
        system.debug('Local data values inserted are ----'+lt);
        
        lt.Title__c=t.id;
        update lt;
        
        list<Local_Title__c> ltList= [select id, Title__c, Country__c, Language__c, Category__c from Local_Title__c where id = :lt.id];
        system.debug('ltList ===========> ' + ltList);
        
        Commercial_Avail__c rp = tdu.createReleasePlan(t, c, ltList[0], l);
        Commercial_Avail__c objRP = [select Id, Title__c, Country_Lookup__c, Languages__c,Start_Date__c,End_Date__c, Local_Title__r.Category__c from Commercial_Avail__c where Id = :rp.Id];
        system.debug('objRP =======> ' + objRP.Local_Title__r.Category__c + ' : ' + objRP);
        
        Agreement__c sf = tdu.createStorefront(c,rp, t, aList[0]);
        Client_Avail__c ca = tdu.createClientAvail(objRP, sf, aList[0]);
        system.debug('Client Avail inserted is ' + ca);
        
        
    }
}