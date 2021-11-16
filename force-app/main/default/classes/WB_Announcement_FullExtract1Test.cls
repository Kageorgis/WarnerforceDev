@isTest
public class WB_Announcement_FullExtract1Test {
    static List<Account> accList = new List<Account>();
    static List<Title__c> titleList = new List<Title__c>();
    static List<Country__c> cList = new List<Country__c>();
    static List<Language__c> lList = new List<Language__c>();
    static List<Local_Title__c> lTitle = new List<Local_Title__c>();
    static List<Commercial_Avail__c> cAvailList = new List<Commercial_Avail__c>();
    static List<Agreement__c> agreementList = new List<Agreement__c>();
    static List<Client_Avail__c> clAvailList = new List<Client_Avail__c>();
    static List<Client_Avail_Price__c> clAvailPriceList = new List<Client_Avail_Price__c>();
    static List<Country_SID_Key__c> countrySIDList = new List<Country_SID_Key__c>();
    static List<String> selectedClientAvailIds = new List<String>();
    static Integer count=3;    
    
     @isTest
    public static void testBatchFullExtract1()
    {
       TestDataUtility tdu = new TestDataUtility();	
       accList = tdu.createAccountList(); 
        //Start -- To create Client Avail 
        MPM__c m = tdu.createMPM();
       Title__c t = tdu.createTitle(m);
       Language__c l = tdu.createLanguage();
       Country__c c = tdu.createCountry();
       Local_Title__c lt = tdu.createlocalTitle(c, l);

       lt.Title__c=t.id;
       update lt;
       //list<Local_Title__c> ltList= [select id, Title__c, Country__c, Language__c, Category__c from Local_Title__c where id = :lt.id];
       Commercial_Avail__c rp = tdu.createReleasePlan(t, c, lt, l);
       rp.Exclusive_Date__c = System.today().addDays(-200);
       rp.Start_Date__c = System.today().addDays(-200);
       rp.End_Date__c = System.today().addDays(500);
       rp.Rights_End__c= System.today().addDays(500);
       update rp;
        Test.startTest();
       List<Announcement_Trigger_Field__c> annfieldList = new List<Announcement_Trigger_Field__c>();
       Announcement_Trigger_Field__c preOrderDate = new Announcement_Trigger_Field__c();
       preOrderDate.Name = 'Pre Order Date';
       preOrderDate.Changed_Field__c = 'Pre Order Date';
       preOrderDate.Changed_Status__c = 'Change';
       preOrderDate.Destination_API__c = 'Pre_Order_Date__c';
       preOrderDate.Destination_Object__c = 'Announcement Record';
       preOrderDate.Feature__c = true;
       preOrderDate.Source_API__c = 'APO_Date__c';
       preOrderDate.Source_Object__c = 'Client Avail';
       preOrderDate.Trigger_Status__c = 'Core';
       preOrderDate.TV__c = true;
       
       annfieldList.add(preOrderDate);
       
       Announcement_Trigger_Field__c priceStart = new Announcement_Trigger_Field__c();
       priceStart.Name = 'Price Start';
       priceStart.Changed_Field__c = 'Start Date';
       priceStart.Changed_Status__c = 'Price Start';
       priceStart.Destination_API__c = 'Client_Start__c';
       priceStart.Destination_Object__c = 'Announcement Record';
       priceStart.Feature__c = true;
       priceStart.Source_API__c = 'Effective_Date__c';
       priceStart.Source_Object__c = 'Client Avail Pricing';
       priceStart.Trigger_Status__c = 'Core';
       priceStart.TV__c = true;
       
       annfieldList.add(priceStart);
       
       Announcement_Trigger_Field__c localRating = new Announcement_Trigger_Field__c();
       localRating.Name = 'Local Rating';
       localRating.Changed_Field__c = 'Rating';
       localRating.Changed_Status__c = 'Change';
       localRating.Destination_API__c = 'Local_Rating__c';
       localRating.Destination_Object__c = 'Announcement Record';
       localRating.Feature__c = true;
       localRating.Source_API__c = 'Local_Data_Rating__c';
       localRating.Source_Object__c = 'Client Avail';
       localRating.Trigger_Status__c = 'Optional';
       localRating.TV__c = true;
       
       annfieldList.add(localRating);
       
       insert annfieldList;
       
       //Commercial_Avail__c objRP = [select Id, Title__c, Country_Lookup__c, Languages__c,Start_Date__c,End_Date__c, Local_Title__r.Category__c from Commercial_Avail__c where Id = :rp.Id];

       Agreement__c sf = tdu.createStorefront(c,rp, t, accList[0]);
      // Client_Avail__c ca = tdu.createClientAvail(rp, sf, accList[0]);
      list<Client_Avail__c> CaccListInsert = New list<Client_Avail__c>();
       Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id);
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300));
       Client_Avail__c ca2 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300),Announce_Override__c='Suppress'); 
       CaccListInsert.add(ca);
       CaccListInsert.add(ca1);
       CaccListInsert.add(ca2); 
       insert CaccListInsert;
       
        String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
       Client_Avail_Price__c cap1 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=ca.Start_Date__c,Expiry_Date__c=ca.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c cap2 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=ca1.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c cap3 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca2.id,Category__c='Catalog',Effective_Date__c=ca2.Start_Date__c,Expiry_Date__c=ca2.Start_Date__c.addDays(20),Price__c=10.99);
       Client_Avail_Price__c cap4 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca2.id,Category__c='Catalog',Effective_Date__c=ca2.Start_Date__c.addDays(21),Expiry_Date__c=ca2.End_Date__c,Price__c=9.99);
       
       List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
        capList.add(cap1);
        capList.add(cap2);
        capList.add(cap3);
        capList.add(cap4);
        
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
        
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
        //EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announcement USA Standard'][0];
       
        String reportIdFromReport = null;//(String)reportList.get(0).get('Id');
        Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
        Datetime myDateTime1 = Datetime.newInstance(2014, 4, 17);
        List<Announcement_Rule__c> annRuleList = new List<Announcement_Rule__c>();
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=accList[0].Id,
                                                        Content_Type__c = 'Feature', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='DTD',Selection_Criteria__c = 'Framed Delta', 
                                                        Report_Template__c='WB Standard Combined',Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                        Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportIdFromReport, Date_Last_Run__c= myDateTime,Full_Extract__c = true);
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
                                                            Channels__c='DTD;EST');
        insert announcement1;
        
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();
        
        Announcement_Record__c annRecords = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap1.Id);
        annRecList.add(annRecords);
        
        Announcement_Record__c annRecords1 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca1.Id,Client_Avail_Price__c=cap2.Id);
        annRecList.add(annRecords1);
        Announcement_Record__c annRecords11 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca1.Id,CAP_Id__c=cap2.Id,CAP_Comment__c='CAP Deleted');
        annRecList.add(annRecords11);
                    
        Announcement_Record__c annRecords2 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca2.Id,Client_Avail_Price__c=cap3.Id);
        annRecList.add(annRecords2);
        /*Announcement_Record__c annRecords3 = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca2.Id,Client_Avail_Price__c=cap3.id);
        annRecList.add(annRecords3);
        */
        Database.insert(annRecList);
        
        annRecords.Status__c = 'Cancelled';
        update annRecords;
        
        Set<Id> firstStepAvailIds = new Set<Id>();
        List<Client_Avail__c> allAvails = [SELECT ID,Release_Plan_Title__c,Title_Video_Version__c,Release_Plan_Country__c,Client__c,Release_Plan_Channel__c,Status__c,CA_Lifecycle__c,
							(Select id,Price_Tier__c,Price__c,Episode_Price__c,Episode_Price_Tier__c,SR_Price__c,SR_Per_Episode__c,
                              Effective_Date__c,Expiry_Date__c,Pricing__c FROM Client_Avail_Prices__r
                            ),
							(SELECT Id,Announcement_Run_Date__c, Announcement__c, Title__c, Local_Title__c,Client_avail__c,Client_Avail_Price__c                                    
                                FROM Announcement_Client_Avails__r  ORDER BY createddate DESC
                             )
                         FROM Client_Avail__c 
                         Where Id NOT IN :firstStepAvailIds];
        
        System.debug(LoggingLevel.INFO,' allAvails are -> '+allAvails.size());                 
        for(Client_Avail__c caRecord:allAvails){
            System.debug(LoggingLevel.INFO,' CAP List is'+caRecord.Client_Avail_Prices__r);
        	System.debug(LoggingLevel.INFO,'******* caRecord.Client__c ********'+caRecord.Client__c +' *******annRuleList[0].Account__c*****'+annRuleList[0].Account__c);
        	System.debug(LoggingLevel.INFO,'******* caRecord.Title_Video_Version__c **********'+caRecord.Title_Video_Version__c +' ******* caRecord.Release_Plan_Country__c *******'+caRecord.Release_Plan_Country__c);
        	System.debug(LoggingLevel.INFO,'******* caRecord.Release_Plan_Channel__c ********'+caRecord.Release_Plan_Channel__c +'## ******* caRecord.Status__c ******' +caRecord.Status__c);
        	System.debug(LoggingLevel.INFO,'*******caRecord.CA_Lifecycle__c *****'+caRecord.CA_Lifecycle__c);
        }
        try{
        	WB_Announcement_Full_Extract1 batchClass = new WB_Announcement_Full_Extract1(new List<Announcement__c>{announcement1},annRuleList,new Set<Id>(),annfieldList);
        	Database.executeBatch(batchClass,10);
        	Test.stopTest();
        }catch(Exception ex){
        	
        }
        

     
    }
}