@isTest
public class WB_ClientActivitiesBatchProcessTest1{
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
    
    //For Framed Delta Selection Criteria 
    @isTest
    public static void testMethodForFramedDelta()
    {
       
       TestDataUtility tdu = new TestDataUtility();  
       accList = tdu.createAccountList(); 
        //Start -- To create Client Avail 
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
       
       Announcement_Trigger_Field__c WSPVal = new Announcement_Trigger_Field__c();
       WSPVal.Name = 'WSP';
       WSPVal.Changed_Field__c = 'WS Cost';
       WSPVal.Changed_Status__c = 'Price Change';
       WSPVal.Destination_API__c = 'WS_Cost__c';
       WSPVal.Destination_Object__c = 'Announcement Record';
       WSPVal.Feature__c = true;
       WSPVal.Source_API__c = 'Price__c';
       WSPVal.Source_Object__c = 'Client Avail Pricing';
       WSPVal.Trigger_Status__c = 'Core';
       WSPVal.TV__c = true;
       
       annfieldList.add(WSPVal);
       
       insert annfieldList;
      
       //Create Pricing
       Pricing__c newPrice = new Pricing__c();
       newPrice.Content_Type__c = 'Feature';
       newPrice.Account__c = accList[0].Id;
       newPrice.Country__c = c.Id;
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
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300),APO_Date__c=system.today()-7);
       Client_Avail__c ca2 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(20),End_Date__c=System.today().addDays(180),Announce_Override__c='Suppress'); 
       Client_Avail__c ca3 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(12),End_Date__c=System.today().addDays(300),APO_Date__c=Date.Today().addDays(-45));
       Client_Avail__c ca4 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(5),End_Date__c=System.today().addDays(300));
      
       CaccListInsert.add(ca);
       CaccListInsert.add(ca1);
       CaccListInsert.add(ca2); 
       CaccListInsert.add(ca3);
       CaccListInsert.add(ca4);
       insert CaccListInsert;
       
        String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
       Client_Avail_Price__c cap1 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=ca.Start_Date__c,Expiry_Date__c=ca.End_Date__c,Price__c=10.99999);
       Client_Avail_Price__c cap2 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=ca1.End_Date__c,Price__c=10.9933);
       Client_Avail_Price__c cap3 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca2.id,Category__c='Catalog',Effective_Date__c=ca2.Start_Date__c,Expiry_Date__c=ca2.Start_Date__c.addDays(20),Price__c=10.9933);
       Client_Avail_Price__c cap4 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca2.id,Category__c='Catalog',Effective_Date__c=ca2.Start_Date__c.addDays(100),Expiry_Date__c=ca2.End_Date__c,Price_Tier__c= '63.12');
       Client_Avail_Price__c cap5 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca3.id,Category__c='Catalog',Effective_Date__c=ca3.Start_Date__c,Expiry_Date__c=ca3.Start_Date__c.addDays(20),Price__c=10.9933);
       Client_Avail_Price__c cap6 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca3.id,Category__c='Catalog',Effective_Date__c=ca3.Start_Date__c.addDays(21),Expiry_Date__c=ca3.End_Date__c,Price__c=9.9933);
       Client_Avail_Price__c cap7 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca4.id,Category__c='Catalog',Effective_Date__c=ca4.Start_Date__c,Expiry_Date__c=ca4.Start_Date__c.addDays(20),Price__c=10.9933);
       Client_Avail_Price__c cap8 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca4.id,Category__c='Catalog',Effective_Date__c=ca4.Start_Date__c.addDays(21),Expiry_Date__c=ca4.End_Date__c,Price__c=9.9933);
       
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
        
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
        //EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announcement USA Standard'][0];
            
        String reportIdFromReport = null;//(String)reportList.get(0).get('Id');
        Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
        Datetime myDateTime1 = Datetime.newInstance(2014, 4, 17);
        List<Announcement_Rule__c> annRuleList = new List<Announcement_Rule__c>();
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=accList[0].Id,
                                                        Content_Type__c = 'Feature', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='DTD;EST',Selection_Criteria__c = 'Framed Delta', 
                                                        Report_Template__c='WB Standard Combined',/*Email_Template_Id__c=templateId.id,*/Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                        Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportIdFromReport, Date_Last_Run__c= myDateTime,Full_Extract__c = true,Optional_Triggers__c='ALID');
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
                                                            Country_Group__c=countryGroup.Id,
                                                            Channels__c='DTD;EST');
        insert announcement1;
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();
        
        Announcement_Record__c annRecords1 = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap1.Id,Change_Status__c='New',Changed_Fields__c='Client Avail');
        annRecList.add(annRecords1);
        
        Announcement_Record__c annRecords2 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca1.Id,Client_Avail_Price__c=cap2.Id,Change_Status__c='Price Change',Changed_Fields__c='End Date',Client_End__c=ca1.End_Date__c,WS_Cost__c = cap2.Price__c);
        annRecList.add(annRecords2);
        Announcement_Record__c annRecords3 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca1.Id,CAP_Id__c=cap2.Id,CAP_Comment__c='CAP Deleted');
        annRecList.add(annRecords3);
                    
        Announcement_Record__c annRecords4 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca2.Id,Client_Avail_Price__c=cap3.Id);
        annRecList.add(annRecords4);
        Announcement_Record__c annRecords5 = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca2.Id,Client_Avail_Price__c=cap4.id);
        annRecList.add(annRecords5);
        
        Announcement_Record__c annRecords6 = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca2.Id,Client_Avail_Price__c=cap4.id,Client_Start__c=System.today()+10);
        annRecList.add(annRecords6);
        
        Database.insert(annRecList);
        
        //Change Client Avail Start Date 
        ca.Start_Date__c=System.today().addDays(205);
        update ca;
        cap1.Effective_Date__c = System.today().addDays(205);
        //cap1.Price__c=12.99999;
        update cap1;
        
        //create Announcement
         Announcement__c announcement2 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Framed Delta',
                                                            //Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
                                                            
        insert announcement2;
        
        WB_compareLastAndFromDates1 compare = new WB_compareLastAndFromDates1(annfieldList);
        
        
        //Change Client Avail End Date 
        ca1.End_Date__c =System.today().addDays(450);
        update ca1;
        cap2.Expiry_Date__c = System.today().addDays(450);
        cap2.Price__c=12.99999;
        update cap2;
        
        //Akash Changes Start
        /*Announcement_Trigger_Field__c annTriggerRec = new Announcement_Trigger_Field__c();
        annTriggerRec.Name = 'Pre Order Date';
        annTriggerRec.Trigger_Status__c = 'Optional';
        annTriggerRec.Source_Object__c = 'Client Avail';
        insert annTriggerRec;*/
        
        Set<String> optionalFieldsSet = new Set<String>();
        optionalFieldsSet.add(annfieldList[2].Name);
        
        //Akash Changes Finish
        
        compare.compareChange (ca1,annRecList[0], announcement.Id,announcement,cap2,false,optionalFieldsSet);
        
         List<Announcement__c> annList = new List<Announcement__c>();
        announcement = new Announcement__c(Announcement_Type__c=annRuleList[0].Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='90 Day Rolling',
                                                            Channels__c='DTD;EST',
                                                            Run_Date__c = myDateTime.addDays(20));
                                                            
        annList.add(announcement);
        insert annList;
        
        set<Id> setIds = new set<Id>();
        setIds.add(annRecList[1].id);
        
        ID batchprocessid = Database.executeBatch(new WB_Announcement_Pre_Orders (annList,annRuleList,setIds), 200);  
        
        //create Announcement
         Announcement__c announcement3 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Framed Delta',
                                                            //Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
                                                            
        insert announcement3;
        
        try{
        cap4.Price__c = 120.123333;
        update cap4;
        annRecList[2].Change_Status__c = 'Change';
        update annRecList;
        
        /*lt.Local_Rating__c = '7';
        update lt;*/
        
       
       // System.debug('clientAvailRec.Local_Data__c>>>>>>>>>'+ca1.Local_Data__c);
        //System.debug('annRecOnCA.Local_Title__c>>>>>>>>>>'+annRecords2.Local_Title__c);
        compare.compareChange (ca1,annRecords2, announcement.Id,announcement,cap2,false,optionalFieldsSet);
        
        
        //Akash Changes Start
        /*Announcement_Trigger_Field__c annTriggerRec2 = new Announcement_Trigger_Field__c();
        annTriggerRec2.Name = 'Pre Order Date';
        annTriggerRec2.Trigger_Status__c = 'Optional';
        annTriggerRec2.Source_Object__c = 'Client Avail';
        insert annTriggerRec2;*/
        
        /*Set<String> optionalFieldsSet2 = new Set<String>();
        optionalFieldsSet2.add(annTriggerRec2.Name);*/
        
        compare.compareChange (ca1,annRecords2, announcement.Id,announcement,cap2,true,optionalFieldsSet);
        //Akash Changes Finish
        
        
        lt.Local_Rating__c = '7';
        lt.Local_Title__c = 'testWB';
        update lt;
        compare.compareChange (ca1,annRecords2, announcement.Id,announcement,cap2,false,optionalFieldsSet);
        
        ca2.APO_Date__c = Date.Today().addDays(-40);
        update ca2;
         compare.compareChange (ca2,annRecords2, announcement.Id,announcement,cap4,true,optionalFieldsSet);
         
        ca2.Announce_Date__c = Date.Today().addDays(+2);
        update ca2;
        compare.compareChange (ca2,annRecords2, announcement.Id,announcement,cap4,true,optionalFieldsSet);
        
        ca2.End_Date__c=System.today().addDays(200);
        update ca2;
        compare.compareChange (ca2,annRecords2, announcement.Id,announcement,cap4,true,optionalFieldsSet);
        
        lt.Local_DVD_Release_Date__c = Date.Today().addDays(+100);
        update lt;
        update ca2;
        compare.compareChange (ca2,annRecords2, announcement.Id,announcement,cap4,true,optionalFieldsSet);
        
        lt.Local_Edit_Required__c = 'Yes';
        update lt;
        compare.compareChange (ca2,annRecords2, announcement.Id,announcement,cap4,true,optionalFieldsSet);
         
        cap4.Price_Tier__c = '120';
        update cap4;
        compare.compareChange (ca2,annRecords2, announcement.Id,announcement,cap4,true,optionalFieldsSet);
        
        cap5.Price__c = 3.6666666;
        update cap5;
        compare.compareChange (ca3,annRecords2, announcement.Id,announcement,cap5,false,optionalFieldsSet);
        
        String recTypeId1 = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME); 
        Client_Avail_Price__c cap9 = new Client_Avail_Price__c(RecordTypeId=recTypeId1,Client_Avail__c=ca2.id,Category__c='Catalog',Effective_Date__c=ca2.Start_Date__c.addDays(101),Expiry_Date__c=ca2.Start_Date__c.addDays(50),Price__c=11.99);
        insert cap9;
        compare.getOrderedCAPList(ca2, true);
        
        String keyCAP = String.valueof(ca2.id)+String.valueof(cap9.id)+String.valueOf(cap9.Effective_Date__c);
        Map<String,Announcement_Record__c> mapCAANDCAPAnnRecord = new Map<String,Announcement_Record__c>();
        mapCAANDCAPAnnRecord.put(keyCAP,annRecords2);
        
        WB_ClientActivitiesBatchProcess1 batchClass1 = new WB_ClientActivitiesBatchProcess1(announcement.id,annRuleList,annfieldList);
        batchClass1.addStartChangeAnnouncementRecords(annRecList, ca2, mapCAANDCAPAnnRecord, System.today(), announcement, annRuleList, capList);
        batchClass1.addEndChangeAnnouncementRecords(annRecList, ca2, mapCAANDCAPAnnRecord, System.today(), announcement, annRuleList, cap9, capList);
        
        WB_compareLastAndFromDates1.updateAnnouncementEndDate(announcement, ca2, annRecList[0], annRecList[1]);
       compare.createARForPreOrderCAP(ca2, mapCAANDCAPAnnRecord, announcement, annRuleList, capList,annfieldList, new set<String>{'Change','Price Start','Price End','Price Change'});
       //cap4.Effective_Date__c = ca2.Start_Date__c.addDays(100);
       //update cap4;
       //compare.compareChange (ca2,annRecords2, announcement.Id,announcement,cap4,true);
       
       ca2.End_Date__c = System.today().addDays(299);
       update ca2;
        cap4.Expiry_Date__c = ca2.End_Date__c;
       update cap4;
        }catch(Exception ex){
            
        }
       Announcement_Record__c accR = compare.compareChange (ca2,annRecords2, announcement.Id,announcement,cap4,true,optionalFieldsSet);
       system.debug('Changed Fields++++++++++++++++++++++++++++++'+accR.Changed_Fields__c);
        //create Announcement
         Announcement__c announcement4 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Framed Delta',
                                                            //Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
                                                            
        insert announcement4;
        
        //annRecords4.Announcement__c = announcement4.Id;
        //annRecords4.Change_Status__c = 'Change';
       // update annRecords4;
        
        //annRecords.Status__c = 'Cancelled';
       //update annRecords;
        
        
        
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
        
       // System.debug(LoggingLevel.INFO,' allAvails are -> '+allAvails.size());                 
       /* for(Client_Avail__c caRecord:allAvails){
            System.debug(LoggingLevel.INFO,' CAP List is'+caRecord.Client_Avail_Prices__r);
          System.debug(LoggingLevel.INFO,'******* caRecord.Client__c ********'+caRecord.Client__c +' *******annRuleList[0].Account__c*****'+annRuleList[0].Account__c);
          System.debug(LoggingLevel.INFO,'******* caRecord.Title_Video_Version__c **********'+caRecord.Title_Video_Version__c +' ******* caRecord.Release_Plan_Country__c *******'+caRecord.Release_Plan_Country__c);
          System.debug(LoggingLevel.INFO,'******* caRecord.Release_Plan_Channel__c ********'+caRecord.Release_Plan_Channel__c +'## ******* caRecord.Status__c ******' +caRecord.Status__c);
          System.debug(LoggingLevel.INFO,'*******caRecord.CA_Lifecycle__c *****'+caRecord.CA_Lifecycle__c);
        } */
        try{
          WB_ClientActivitiesBatchProcess1 batchClass = new WB_ClientActivitiesBatchProcess1(announcement.id,annRuleList,annfieldList);
          Database.executeBatch(batchClass,10);
          
        }catch(Exception ex){
          
        }
        
        try{
          WB_ClientActivitiesBatchProcess1 batchClass = new WB_ClientActivitiesBatchProcess1(announcement1.id,annRuleList,annfieldList);
          Database.executeBatch(batchClass,10);
         
        }catch(Exception ex){
          
        }
        
        //For 2nd Announcement
        try{
          WB_ClientActivitiesBatchProcess1 batchClass = new WB_ClientActivitiesBatchProcess1(announcement2.id,annRuleList,annfieldList);
          Database.executeBatch(batchClass,10);
        }catch(Exception ex){
          
        }
        
        //3rd Announcement for Client End Date change
        try{
          WB_ClientActivitiesBatchProcess1 batchClass = new WB_ClientActivitiesBatchProcess1(announcement3.id,annRuleList,annfieldList);
          Database.executeBatch(batchClass,10);
        }catch(Exception ex){
          
        }
        
        //4th Announcement for Client End Date change
        try{
          WB_ClientActivitiesBatchProcess1 batchClass = new WB_ClientActivitiesBatchProcess1(announcement4.id,annRuleList,annfieldList);
          Database.executeBatch(batchClass,10);
          Test.stopTest();
        }catch(Exception ex){
          
        }
        
         
     
    }
    
    //For 90 Day Rolling
     @isTest
    public static void testMethodFor90DayRolling()
    {
       TestDataUtility tdu = new TestDataUtility();  
       accList = tdu.createAccountList(); 
        //Start -- To create Client Avail 
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
       //list<Local_Title__c> ltList= [select id, Title__c, Country__c, Language__c, Category__c from Local_Title__c where id = :lt.id];
       Commercial_Avail__c rp = tdu.createReleasePlan_EST(t, c, lt, l);
       rp.Exclusive_Date__c = System.today().addDays(-200);
       rp.Start_Date__c = System.today().addDays(-200);
       rp.End_Date__c = System.today().addDays(500);
       rp.Rights_End__c= System.today().addDays(500);
       rp.Country_Lookup__c = c.Id;
       update rp;
       
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
       Test.startTest();
       Agreement__c sf = tdu.createStorefront(c,rp, t, accList[0]);
      // Client_Avail__c ca = tdu.createClientAvail(rp, sf, accList[0]);
      list<Client_Avail__c> CaccListInsert = New list<Client_Avail__c>();
       Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID,Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id);
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300));
       Client_Avail__c ca2 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300),Announce_Override__c='Suppress'); 
       Client_Avail__c ca3 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300),APO_Date__c=Date.Today().addDays(5));
       Client_Avail__c ca4 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300),Announce_Override__c='Suppress',APO_Date__c=Date.Today().addDays(180));
      
       CaccListInsert.add(ca);
       CaccListInsert.add(ca1);
       CaccListInsert.add(ca2); 
       CaccListInsert.add(ca3);
       CaccListInsert.add(ca4);
       insert CaccListInsert;
       
       String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
       Client_Avail_Price__c cap1 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=ca.Start_Date__c,Expiry_Date__c=ca.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c cap2 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=ca1.End_Date__c,Price__c=11.99);
       Client_Avail_Price__c cap3 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca2.id,Category__c='Catalog',Effective_Date__c=Date.Today().toStartOfMonth(),Expiry_Date__c=ca2.Start_Date__c.addDays(20),Price__c=10.99);
       Client_Avail_Price__c cap4 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca2.id,Category__c='Catalog',Effective_Date__c=ca2.Start_Date__c.addDays(30),Expiry_Date__c=ca2.End_Date__c,Price__c=9.99);
       Client_Avail_Price__c cap5 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca3.id,Category__c='Catalog',Effective_Date__c=Date.Today().addDays(2),Expiry_Date__c=ca3.Start_Date__c.addDays(20),Price__c=10.99);
       Client_Avail_Price__c cap6 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca3.id,Category__c='Catalog',Effective_Date__c=ca3.Start_Date__c.addDays(21),Expiry_Date__c=ca3.End_Date__c,Price__c=9.99);
       Client_Avail_Price__c cap7 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca4.id,Category__c='Catalog',Effective_Date__c=ca4.Start_Date__c,Expiry_Date__c=ca4.Start_Date__c.addDays(20),Price__c=10.99);
       Client_Avail_Price__c cap8 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca4.id,Category__c='Catalog',Effective_Date__c=System.today().addDays(150),Expiry_Date__c=ca4.End_Date__c,Price__c=9.99);
       
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
        
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
        //EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announcement USA Standard'][0];
            
        String reportIdFromReport = null;//(String)reportList.get(0).get('Id');
        Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
        Datetime myDateTime1 = Datetime.newInstance(2014, 4, 17);
        List<Announcement_Rule__c> annRuleList = new List<Announcement_Rule__c>();
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=accList[0].Id,
                                                        Content_Type__c = 'Feature', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='DTD;EST',Selection_Criteria__c = '90 Day Rolling', 
                                                        Report_Template__c='WB Standard Combined',/*Email_Template_Id__c=templateId.id,*/Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
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
                                                            Selection_Criteria__c = '90 Day Rolling',
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
                                                            Selection_Criteria__c= '90 Day Rolling',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Country_Group__c=countryGroup.Id,
                                                            Channels__c='DTD;EST');
        insert announcement1;
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();
        
        Announcement_Record__c annRecords = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap1.Id,Change_Status__c='New');
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
        
        //System.debug(LoggingLevel.INFO,' allAvails are -> '+allAvails.size());                 
       /* for(Client_Avail__c caRecord:allAvails){
            System.debug(LoggingLevel.INFO,' CAP List is'+caRecord.Client_Avail_Prices__r);
          System.debug(LoggingLevel.INFO,'******* caRecord.Client__c ********'+caRecord.Client__c +' *******annRuleList[0].Account__c*****'+annRuleList[0].Account__c);
          System.debug(LoggingLevel.INFO,'******* caRecord.Title_Video_Version__c **********'+caRecord.Title_Video_Version__c +' ******* caRecord.Release_Plan_Country__c *******'+caRecord.Release_Plan_Country__c);
          System.debug(LoggingLevel.INFO,'******* caRecord.Release_Plan_Channel__c ********'+caRecord.Release_Plan_Channel__c +'## ******* caRecord.Status__c ******' +caRecord.Status__c);
          System.debug(LoggingLevel.INFO,'*******caRecord.CA_Lifecycle__c *****'+caRecord.CA_Lifecycle__c);
        } */
        try{
          WB_ClientActivitiesBatchProcess1 batchClass = new WB_ClientActivitiesBatchProcess1(announcement1.id,annRuleList,annfieldList);
          // ID batchprocessid = Database.executeBatch(new WB_ClientActivitiesBatchProcess1(announcement.id,annRuleList),10);   
          Database.executeBatch(batchClass,10);
          Test.stopTest();
        }catch(Exception ex){
          
        }
        

     
    }
   
   
   //For Delta Selection criteria
   
    @isTest
    public static void testMethodForDelta()
    {
       TestDataUtility tdu = new TestDataUtility();  
       accList = tdu.createAccountList(); 
        //Start -- To create Client Avail 
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
       //list<Local_Title__c> ltList= [select id, Title__c, Country__c, Language__c, Category__c from Local_Title__c where id = :lt.id];
       Commercial_Avail__c rp = tdu.createReleasePlan_EST(t, c, lt, l);
       rp.Exclusive_Date__c = System.today().addDays(-200);
       rp.Start_Date__c = System.today().addDays(-200);
       rp.End_Date__c = System.today().addDays(500);
       rp.Rights_End__c= System.today().addDays(500);
       rp.Country_Lookup__c = c.Id;
       update rp;
       
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
       Test.startTest();
       Agreement__c sf = tdu.createStorefront(c,rp, t, accList[0]);
      // Client_Avail__c ca = tdu.createClientAvail(rp, sf, accList[0]);
      list<Client_Avail__c> CaccListInsert = New list<Client_Avail__c>();
       Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID,Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Announce_Override__c = 'Force',Start_Date__c=System.today().addDays(-40),End_Date__c=System.today().addDays(300) );
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300));
       Client_Avail__c ca2 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300),Announce_Override__c='Suppress'); 
       Client_Avail__c ca3 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300),APO_Date__c=Date.Today().addDays(5));
       Client_Avail__c ca4 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300),Announce_Override__c='Suppress',APO_Date__c=Date.Today().addDays(180));
      
       CaccListInsert.add(ca);
       CaccListInsert.add(ca1);
       CaccListInsert.add(ca2); 
       CaccListInsert.add(ca3);
       CaccListInsert.add(ca4);
       insert CaccListInsert;
       
        String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
       Client_Avail_Price__c cap1 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=ca.Start_Date__c,Expiry_Date__c=ca.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c cap2 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=ca1.End_Date__c,Price__c=11.99);
       Client_Avail_Price__c cap3 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca2.id,Category__c='Catalog',Effective_Date__c=Date.Today().toStartOfMonth(),Expiry_Date__c=ca2.Start_Date__c.addDays(20),Price__c=10.99);
       Client_Avail_Price__c cap4 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca2.id,Category__c='Catalog',Effective_Date__c=ca2.Start_Date__c.addDays(30),Expiry_Date__c=ca2.End_Date__c,Price__c=9.99);
       Client_Avail_Price__c cap5 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca3.id,Category__c='Catalog',Effective_Date__c=Date.Today().addDays(2),Expiry_Date__c=ca3.Start_Date__c.addDays(20),Price__c=10.99);
       Client_Avail_Price__c cap6 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca3.id,Category__c='Catalog',Effective_Date__c=ca3.Start_Date__c.addDays(21),Expiry_Date__c=ca3.End_Date__c,Price__c=9.99);
       Client_Avail_Price__c cap7 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca4.id,Category__c='Catalog',Effective_Date__c=ca4.Start_Date__c,Expiry_Date__c=ca4.Start_Date__c.addDays(20),Price__c=10.99);
       Client_Avail_Price__c cap8 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca4.id,Category__c='Catalog',Effective_Date__c=System.today().addDays(150),Expiry_Date__c=ca4.End_Date__c,Price__c=9.99);
       
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
        
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
        //EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announcement USA Standard'][0];
            
        String reportIdFromReport = null;//(String)reportList.get(0).get('Id');
        Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
        Datetime myDateTime1 = Datetime.newInstance(2014, 4, 17);
        List<Announcement_Rule__c> annRuleList = new List<Announcement_Rule__c>();
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=accList[0].Id,
                                                        Content_Type__c = 'Feature', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='DTD;EST',Selection_Criteria__c = 'Delta', 
                                                        Report_Template__c='WB Standard Combined',/*Email_Template_Id__c=templateId.id,*/Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
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
                                                            Selection_Criteria__c ='Delta',
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
                                                            Selection_Criteria__c= 'Delta',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Country_Group__c=countryGroup.Id,
                                                            Channels__c='DTD;EST');
        insert announcement1;
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();
        
        Announcement_Record__c annRecords = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap1.Id,Change_Status__c='New');
        annRecList.add(annRecords);
        
       /* Announcement_Record__c annRecords1 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca1.Id,Client_Avail_Price__c=cap2.Id);
        annRecList.add(annRecords1);
        Announcement_Record__c annRecords11 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca1.Id,CAP_Id__c=cap2.Id,CAP_Comment__c='CAP Deleted');
        annRecList.add(annRecords11);
                    
        Announcement_Record__c annRecords2 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca2.Id,Client_Avail_Price__c=cap3.Id);
        annRecList.add(annRecords2);
        /*Announcement_Record__c annRecords3 = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca2.Id,Client_Avail_Price__c=cap3.id);
        annRecList.add(annRecords3);
        */
        Database.insert(annRecList);
        
        ca1.Announce_Override__c='Suppress';
        update ca1;
        //create Announcement
         Announcement__c announcement2 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Delta',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
                                                            
        insert announcement2;
        
        //annRecords.Status__c = 'Cancelled';
        //update annRecords;
        
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
        
       /* System.debug(LoggingLevel.INFO,' allAvails are -> '+allAvails.size());                 
        for(Client_Avail__c caRecord:allAvails){
            System.debug(LoggingLevel.INFO,' CAP List is'+caRecord.Client_Avail_Prices__r);
          System.debug(LoggingLevel.INFO,'******* caRecord.Client__c ********'+caRecord.Client__c +' *******annRuleList[0].Account__c*****'+annRuleList[0].Account__c);
          System.debug(LoggingLevel.INFO,'******* caRecord.Title_Video_Version__c **********'+caRecord.Title_Video_Version__c +' ******* caRecord.Release_Plan_Country__c *******'+caRecord.Release_Plan_Country__c);
          System.debug(LoggingLevel.INFO,'******* caRecord.Release_Plan_Channel__c ********'+caRecord.Release_Plan_Channel__c +'## ******* caRecord.Status__c ******' +caRecord.Status__c);
          System.debug(LoggingLevel.INFO,'*******caRecord.CA_Lifecycle__c *****'+caRecord.CA_Lifecycle__c);
        } */
        try{
          WB_ClientActivitiesBatchProcess1 batchClass = new WB_ClientActivitiesBatchProcess1(announcement1.id,annRuleList,annfieldList);
          // ID batchprocessid = Database.executeBatch(new WB_ClientActivitiesBatchProcess1(announcement.id,annRuleList),10);   
          Database.executeBatch(batchClass,10);
          Test.stopTest();
        }catch(Exception ex){
          
        }
       

    }
    
        //For Framed Full Selection Criteria 
    @isTest
    public static void testMethodForFramedFull()
    {
       TestDataUtility tdu = new TestDataUtility();  
       accList = tdu.createAccountList(); 
        //Start -- To create Client Avail 
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
       //list<Local_Title__c> ltList= [select id, Title__c, Country__c, Language__c, Category__c from Local_Title__c where id = :lt.id];
       Commercial_Avail__c rp = tdu.createReleasePlan_EST(t, c, lt, l);
       rp.Exclusive_Date__c = System.today().addDays(-200);
       rp.Start_Date__c = System.today().addDays(-200);
       rp.End_Date__c = System.today().addDays(500);
       rp.Rights_End__c= System.today().addDays(500);
       rp.Country_Lookup__c = c.Id;
       update rp;
       
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
       Test.startTest();
       Agreement__c sf = tdu.createStorefront(c,rp, t, accList[0]);
      // Client_Avail__c ca = tdu.createClientAvail(rp, sf, accList[0]);
      list<Client_Avail__c> CaccListInsert = New list<Client_Avail__c>();
       Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID,Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300));       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300));
       Client_Avail__c ca2 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300),Announce_Override__c='Suppress'); 
       Client_Avail__c ca3 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300),APO_Date__c=Date.Today().addDays(-45));
       Client_Avail__c ca4 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300));
      
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
       Client_Avail_Price__c cap4 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca2.id,Category__c='Catalog',Effective_Date__c=ca2.Start_Date__c.addDays(21),Expiry_Date__c=ca2.End_Date__c,Price__c=9.99);
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
        
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
        //EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announcement USA Standard'][0];
            
        String reportIdFromReport = null;//(String)reportList.get(0).get('Id');
        Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
        Datetime myDateTime1 = Datetime.newInstance(2014, 4, 17);
        List<Announcement_Rule__c> annRuleList = new List<Announcement_Rule__c>();
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=accList[0].Id,
                                                        Content_Type__c = 'Feature', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='DTD;EST',Selection_Criteria__c = 'Framed Full', 
                                                        Report_Template__c='WB Standard Combined',/*Email_Template_Id__c=templateId.id,*/Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
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
                                                            Selection_Criteria__c ='Framed Full',
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
                                                            Selection_Criteria__c='Framed Full',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Country_Group__c=countryGroup.Id,
                                                            Channels__c='DTD;EST');
        insert announcement1;
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();
        
        Announcement_Record__c annRecords = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap1.Id,Change_Status__c='New');
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
        
         //Change Client Avail Start Date 
        ca.Start_Date__c=System.today().addDays(205);
        update ca;
        cap1.Effective_Date__c = System.today().addDays(205);
        update cap1;
        
        //create Announcement
         Announcement__c announcement2 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Framed Delta',
                                                            //Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
                                                            
        insert announcement2;
        
        //Change Client Avail End Date 
        ca1.End_Date__c =System.today().addDays(450);
        update ca1;
        cap2.Expiry_Date__c = System.today().addDays(450);
        update cap2;
        
        //create Announcement
         Announcement__c announcement3 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Framed Delta',
                                                            //Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
                                                            
        insert announcement3;
        
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
        
        /* System.debug(LoggingLevel.INFO,' allAvails are -> '+allAvails.size());                 
        for(Client_Avail__c caRecord:allAvails){
            System.debug(LoggingLevel.INFO,' CAP List is'+caRecord.Client_Avail_Prices__r);
          System.debug(LoggingLevel.INFO,'******* caRecord.Client__c ********'+caRecord.Client__c +' *******annRuleList[0].Account__c*****'+annRuleList[0].Account__c);
          System.debug(LoggingLevel.INFO,'******* caRecord.Title_Video_Version__c **********'+caRecord.Title_Video_Version__c +' ******* caRecord.Release_Plan_Country__c *******'+caRecord.Release_Plan_Country__c);
          System.debug(LoggingLevel.INFO,'******* caRecord.Release_Plan_Channel__c ********'+caRecord.Release_Plan_Channel__c +'## ******* caRecord.Status__c ******' +caRecord.Status__c);
          System.debug(LoggingLevel.INFO,'*******caRecord.CA_Lifecycle__c *****'+caRecord.CA_Lifecycle__c);
        } */
        try{
          WB_ClientActivitiesBatchProcess1 batchClass = new WB_ClientActivitiesBatchProcess1(announcement1.id,annRuleList,annfieldList);
          Database.executeBatch(batchClass,10);
         
        }catch(Exception ex){
          
        }
        
        //For 2nd Announcement
        try{
          WB_ClientActivitiesBatchProcess1 batchClass = new WB_ClientActivitiesBatchProcess1(announcement2.id,annRuleList,annfieldList);
          Database.executeBatch(batchClass,10);
        }catch(Exception ex){
          
        }
     
        //For 3rd Announcement Which is for ClientAvail End date change
        try{
          WB_ClientActivitiesBatchProcess1 batchClass = new WB_ClientActivitiesBatchProcess1(announcement2.id,annRuleList,annfieldList);
          Database.executeBatch(batchClass,10);
          Test.stopTest();
        }catch(Exception ex){
          
        }
    }
    
    
        //For MAL Selection Criteria 
    @isTest
    public static void testMethodForMAL()
    {
       TestDataUtility tdu = new TestDataUtility();  
       accList = tdu.createAccountList(); 
        //Start -- To create Client Avail 
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
       //list<Local_Title__c> ltList= [select id, Title__c, Country__c, Language__c, Category__c from Local_Title__c where id = :lt.id];
       Commercial_Avail__c rp = tdu.createReleasePlan_EST(t, c, lt, l);
       rp.Exclusive_Date__c = System.today().addDays(-200);
       rp.Start_Date__c = System.today().addDays(-200);
       rp.End_Date__c = System.today().addDays(500);
       rp.Rights_End__c= System.today().addDays(500);
       rp.Country_Lookup__c = c.Id;
       update rp;
       
       
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
       Test.startTest();
       Agreement__c sf = tdu.createStorefront(c,rp, t, accList[0]);
      // Client_Avail__c ca = tdu.createClientAvail(rp, sf, accList[0]);
      list<Client_Avail__c> CaccListInsert = New list<Client_Avail__c>();
       Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID,Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id);
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300));
       Client_Avail__c ca2 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300),Announce_Override__c='Suppress'); 
       Client_Avail__c ca3 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300),APO_Date__c=Date.Today().addDays(-45));
       Client_Avail__c ca4 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300));
      
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
       Client_Avail_Price__c cap4 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca2.id,Category__c='Catalog',Effective_Date__c=ca2.Start_Date__c.addDays(21),Expiry_Date__c=ca2.End_Date__c,Price__c=9.99);
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
        
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
        //EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announcement USA Standard'][0];
            
        String reportIdFromReport = null;//(String)reportList.get(0).get('Id');
        Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
        Datetime myDateTime1 = Datetime.newInstance(2014, 4, 17);
        List<Announcement_Rule__c> annRuleList = new List<Announcement_Rule__c>();
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=accList[0].Id,
                                                        Content_Type__c = 'Feature', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='DTD;EST',Selection_Criteria__c = 'Active Full Extract', 
                                                        Report_Template__c='WB Standard Combined',/*Email_Template_Id__c=templateId.id,*/Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
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
                                                            Selection_Criteria__c ='Active Full Extract',
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
                                                            Selection_Criteria__c='Active Full Extract',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Country_Group__c=countryGroup.Id,
                                                            Channels__c='DTD;EST');
        insert announcement1;
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();
        
        Announcement_Record__c annRecords = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap1.Id,Change_Status__c='New');
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
        
        ca.Start_Date__c=System.today().addDays(60);
        update ca;
        cap1.Effective_Date__c = System.today().addDays(60);
        update cap1;
        
        //create Announcement
         Announcement__c announcement2 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Active Full Extract',
                                                            //Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
                                                            
        insert announcement2;
        
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
        
        /*System.debug(LoggingLevel.INFO,' allAvails are -> '+allAvails.size());                 
        for(Client_Avail__c caRecord:allAvails){
            System.debug(LoggingLevel.INFO,' CAP List is'+caRecord.Client_Avail_Prices__r);
          System.debug(LoggingLevel.INFO,'******* caRecord.Client__c ********'+caRecord.Client__c +' *******annRuleList[0].Account__c*****'+annRuleList[0].Account__c);
          System.debug(LoggingLevel.INFO,'******* caRecord.Title_Video_Version__c **********'+caRecord.Title_Video_Version__c +' ******* caRecord.Release_Plan_Country__c *******'+caRecord.Release_Plan_Country__c);
          System.debug(LoggingLevel.INFO,'******* caRecord.Release_Plan_Channel__c ********'+caRecord.Release_Plan_Channel__c +'## ******* caRecord.Status__c ******' +caRecord.Status__c);
          System.debug(LoggingLevel.INFO,'*******caRecord.CA_Lifecycle__c *****'+caRecord.CA_Lifecycle__c);
        } */
        try{
          WB_ClientActivitiesBatchProcess1 batchClass = new WB_ClientActivitiesBatchProcess1(announcement1.id,annRuleList,annfieldList);
          // ID batchprocessid = Database.executeBatch(new WB_ClientActivitiesBatchProcess1(announcement.id,annRuleList),10);   
          Database.executeBatch(batchClass,10);
         
        }catch(Exception ex){
          
        }
        
        //For 2nd Announcement
        try{
          WB_ClientActivitiesBatchProcess1 batchClass = new WB_ClientActivitiesBatchProcess1(announcement2.id,annRuleList,annfieldList);
          // ID batchprocessid = Database.executeBatch(new WB_ClientActivitiesBatchProcess1(announcement.id,annRuleList),10);   
          Database.executeBatch(batchClass,10);
          Test.stopTest();
        }catch(Exception ex){
          
        }
     
    }
    
    //To call WB_compareLastAndFromDates1 class
     @isTest
    public static void testMethodForWB_compare1()
    {
        //Insert Account 
         for(Integer i = 0; i<count; i++){
            Account acc = TestUtil.createAccount('WB Account'+i);
            acc.Customer_Focus__c = 'Active';
            accList.add(acc); 
         }
         insert accList;
         
         //Insert Titles
         for(integer i = 0; i<count; i++)
         {
            Title__c newTitle = TestUtil.initTitle('WBMovie'+i, '600004754'+i);
            newTitle.Content_Type__c = 'Season';
            if(i == 3)
                newTitle.Content_Type__c = 'Episode'; 
            titleList.add(newTitle);
         }
         insert titleList;
         
         //Insert Countries   
         Country__c country1 = TestUtil.initCountry('Colombia', 'CO', 'COL');
         Country__c country2 = TestUtil.initCountry('China', 'CN', 'CHN');
         Country__c country3 = TestUtil.initCountry('Canada', 'CA', 'CAN');
         cList.add(country1);
         cList.add(country2);
         cList.add(country3);
         insert cList;
         
         Country_Groups__c countryGroup=new Country_Groups__c(Name='CountryGroup',Account__c=accList[0].Id,Country__c=country1.Name);
         insert countryGroup;
         Country_Group_Country__c countryGC = new Country_Group_Country__c (Country_Group__c=countryGroup.Id,Country__c=country1.Id);
         insert countryGC;
         
         //Insert Languages
         for(Integer i = 0; i<count; i++)
         {
            Language__c newLanguage = TestUtil.initLanguage('English', '', 1);
            lList.add(newLanguage);
         }
         insert lList;
        
         //Insert Local Data
         for(Integer i=0; i<count; i++)
         {
            Local_Title__c localTitle = TestUtil.initLocalTitle(lList[i].Id, cList[i].Id);
            localTitle.Title__c = titleList[i].id;
            lTitle.add(localTitle);
         }
         insert lTitle;
         
         //Create Release Plan
         for(Integer i=0; i<count; i++)
         {
            Commercial_Avail__c CommercialAvail = TestUtil.initReleasePlan(titleList[i].Id, lTitle[i].Id, cList[i].Id, lList[i].Id);
            CommercialAvail.Channel__c = 'EST';
            CommercialAvail.Start_Date__c = system.today()-70;
            CommercialAvail.End_Date__c = system.today()+70;
            cAvailList.add(CommercialAvail);
         }
         insert cAvailList;
         
         //Create Storefront
         for(Integer i=0; i<count; i++)
         {
            Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(accList[i].Id, cList[i].Id, cAvailList[i], titleList[i]);
            agreementList.add(storefrontGoogle1);
         }
         insert agreementList;
         
         //Create Client Avail 
         for(Integer i=0; i<count; i++)
         {
            Client_Avail__c clientAvail = TestUtil.initClientAvail(accList[0].Id, cAvailList[i], lTitle[i].Id);
            clientAvail.Start_Date__c = system.today()+5;
            clientAvail.End_Date__c = system.today()+70;
            clientAvail.status__c = 'Tentative';
            clientAvail.Announce_Override__c = 'Force';
            clientAvail.APO_Date__c = system.today()+5;
            clientAvail.Storefront__c = agreementList[i].Id;
            clAvailList.add(clientAvail);
         }
         insert clAvailList;
         
         //Insert Custom Setting - Country SID Key
        countrySIDList.add(new Country_SID_Key__c(Name='Colombia', Country_Code__c='COL',Country_Code2_c__c='CO',Locale_SID_Key__c='America/Los_Angeles',Region__c='North America'));
        countrySIDList.add(new Country_SID_Key__c(Name='China', Country_Code__c='CHN',Country_Code2_c__c='CN',Locale_SID_Key__c='America/Los_Angeles',Region__c='North America'));
        countrySIDList.add(new Country_SID_Key__c(Name='Canada', Country_Code__c='CAN',Country_Code2_c__c='CA',Locale_SID_Key__c='America/Los_Angeles',Region__c='North America'));
        insert countrySIDList;
        
        //Insert Client Avail Pricing for CA
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today()+15,Price__c=10.0,Episode_Price__c=10.0,Type__c='Reprice',Category__c='Catalog'));
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[1].id,Effective_Date__c=system.today()+50,Price__c=10.0,Episode_Price__c=10.0,Type__c='Reprice',Category__c='Catalog'));
        clAvailPriceList.add(new Client_Avail_Price__c(Client_Avail__c = clAvailList[2].id,Effective_Date__c=system.today()+15,Price__c=10.0,Episode_Price__c=10.0,Type__c='Reprice',Category__c='Catalog'));
        try{
        insert clAvailPriceList;
        }catch(Exception ex){
            
        }
        
     
        Test.startTest();
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
        //EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announcement USA Standard'][0];
            
        String reportIdFromReport = null;//(String)reportList.get(0).get('Id');
        Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
        Datetime myDateTime1 = Datetime.newInstance(2014, 4, 17);
        List<Announcement_Rule__c> annRuleList = new List<Announcement_Rule__c>();
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=accList[0].Id,
                                                        Content_Type__c = 'Season; Episode', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='DTD;EST',Selection_Criteria__c = 'Framed Full', 
                                                        Report_Template__c='WB Standard Combined',/*Email_Template_Id__c=templateId.id,*/Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                        Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportIdFromReport, Date_Last_Run__c= myDateTime,Full_Extract__c = true);
        insert annRule;
        annRuleList.add(annRule);
        
        //create Announcement
         Announcement__c announcement = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Season; Episode', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Framed Full',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
                                                            
        insert announcement;
        //create Announcement
         Announcement__c announcement1 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Season; Episode', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Run_Date__c=myDateTime,
                                                            From_Date__c=myDateTime,
                                                            Selection_Criteria__c='Framed full',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Country_Group__c=countryGroup.Id,
                                                            Channels__c='DTD;EST');
        insert announcement1;
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();
        
        Announcement_Record__c annRecords1 = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=clAvailList[0].Id,Client_Avail_Price__c=clAvailPriceList[0].Id,Change_Status__c='New');
        annRecList.add(annRecords1);
        
        Announcement_Record__c annRecords2 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=clAvailList[1].Id,Client_Avail_Price__c=clAvailPriceList[1].Id);
        annRecList.add(annRecords2);
        Announcement_Record__c annRecords3 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=clAvailList[1].Id,Client_Avail_Price__c=clAvailPriceList[2].Id);
        annRecList.add(annRecords3);
                    
    /*    Announcement_Record__c annRecords4 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=clAvailList[2].Id,Client_Avail_Price__c=cap3.Id);
        annRecList.add(annRecords4);
        Announcement_Record__c annRecords5 = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=clAvailList[2].Id,Client_Avail_Price__c=cap4.id);
        annRecList.add(annRecords5); */
        
        Database.insert(annRecList);
        
        WB_compareLastAndFromDates1 compare = new WB_compareLastAndFromDates1();
        
        //create Announcement
         Announcement__c announcement3 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Season; Episode', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Framed Full',
                                                            //Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;VODi;Hotel;EST');
                                                            
        insert announcement3;
       
        titleList[1].Episode_Count__c = 4;
        update titleList[1];
        
        //Akash Changes Start
        Announcement_Trigger_Field__c annTriggerRec = new Announcement_Trigger_Field__c();
        annTriggerRec.Name = 'Pre Order Date';
        annTriggerRec.Trigger_Status__c = 'Optional';
        annTriggerRec.Source_Object__c = 'Client Avail';
        insert annTriggerRec;
        
        Set<String> optionalFieldsSet = new Set<String>();
        optionalFieldsSet.add(annTriggerRec.Name);
        
        //Akash Changes Finish
        
        compare.compareChange (clAvailList[1],annRecords2, announcement3.Id,announcement,clAvailPriceList[2],false,optionalFieldsSet);
        
    }
    
   @isTest
    public static void testMethodForWB_compare2()
    {
        //Insert Account 
         for(Integer i = 0; i<count; i++){
            Account acc = TestUtil.createAccount('WB Account'+i);
            acc.Customer_Focus__c = 'Active';
            accList.add(acc); 
         }
         insert accList;
         
         //Insert Titles
         for(integer i = 0; i<count; i++)
         {
            Title__c newTitle = TestUtil.initTitle('WBMovie'+i, '600004754'+i);
            newTitle.Content_Type__c = 'Season';
            if(i == 3)
                newTitle.Content_Type__c = 'Episode'; 
            titleList.add(newTitle);
         }
         insert titleList;
         
         //Insert Countries   
         Country__c country1 = TestUtil.initCountry('Colombia', 'CO', 'COL');
         Country__c country2 = TestUtil.initCountry('China', 'CN', 'CHN');
         Country__c country3 = TestUtil.initCountry('Canada', 'CA', 'CAN');
         cList.add(country1);
         cList.add(country2);
         cList.add(country3);
         insert cList;
         
         Country_Groups__c countryGroup=new Country_Groups__c(Name='CountryGroup',Account__c=accList[0].Id,Country__c=country1.Name);
         insert countryGroup;
         Country_Group_Country__c countryGC = new Country_Group_Country__c (Country_Group__c=countryGroup.Id,Country__c=country1.Id);
         insert countryGC;
         
         //Insert Languages
         for(Integer i = 0; i<count; i++)
         {
            Language__c newLanguage = TestUtil.initLanguage('English', '', 1);
            lList.add(newLanguage);
         }
         insert lList;
        
         //Insert Local Data
         for(Integer i=0; i<count; i++)
         {
            Local_Title__c localTitle = TestUtil.initLocalTitle(lList[i].Id, cList[i].Id);
            localTitle.Title__c = titleList[i].id;
            lTitle.add(localTitle);
         }
         insert lTitle;
         
         //Create Release Plan
         for(Integer i=0; i<count; i++)
         {
            Commercial_Avail__c CommercialAvail = TestUtil.initReleasePlan(titleList[i].Id, lTitle[i].Id, cList[i].Id, lList[i].Id);
            CommercialAvail.Start_Date__c = system.today()+5;
            CommercialAvail.Exclusive_Date__c =  system.today()+5;
            CommercialAvail.End_Date__c = system.today()+250;
            CommercialAvail.Rights_End__c =system.today()+250;
            cAvailList.add(CommercialAvail);
         }
         insert cAvailList;
         
         //Create Storefront
         for(Integer i=0; i<count; i++)
         {
            Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(accList[i].Id, cList[i].Id, cAvailList[i], titleList[i]);
            agreementList.add(storefrontGoogle1);
         }
         insert agreementList;
         
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
       
         
         //Create Client Avail 
         for(Integer i=0; i<count; i++)
         {
            Client_Avail__c clientAvail = TestUtil.initClientAvail(accList[0].Id, cAvailList[i], lTitle[i].Id);
            clientAvail.Start_Date__c = system.today()+5;
            clientAvail.End_Date__c = system.today()+250;
            clientAvail.status__c = 'confirmed';
            clientAvail.Announce_Override__c = 'Force';
            clientAvail.Storefront__c = agreementList[i].Id;
            clAvailList.add(clientAvail);
         }
         insert clAvailList;
        // system.debug('clAvailList>>>>>>>>'+clAvailList);
         List<Client_Avail_Price__c>  getCapList = new List<Client_Avail_Price__c>();
         getCapList = [select ID from Client_Avail_Price__c WHERE Client_Avail__c =: clAvailList[0].Id];
         //system.debug(LoggingLevel.INFO,'CAPLIST>>>>>>>>>>'+getCapList);
         //Insert Custom Setting - Country SID Key
        countrySIDList.add(new Country_SID_Key__c(Name='Colombia', Country_Code__c='COL',Country_Code2_c__c='CO',Locale_SID_Key__c='America/Los_Angeles',Region__c='North America'));
        countrySIDList.add(new Country_SID_Key__c(Name='China', Country_Code__c='CHN',Country_Code2_c__c='CN',Locale_SID_Key__c='America/Los_Angeles',Region__c='North America'));
        countrySIDList.add(new Country_SID_Key__c(Name='Canada', Country_Code__c='CAN',Country_Code2_c__c='CA',Locale_SID_Key__c='America/Los_Angeles',Region__c='North America'));
        insert countrySIDList;
        
        //Insert Client Avail Pricing for CA
        String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
        String tpRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME);
        clAvailPriceList.add(new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today()+15,Expiry_Date__c=system.today()+149,Price__c=10.0,Episode_Price__c=10.0,Type__c= WB_PriceUtility.FIRST,Category__c='Catalog'));
        clAvailPriceList.add(new Client_Avail_Price__c(RecordTypeId=tpRecTypeId,Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today()+25,Expiry_Date__c=system.today()+160,Price__c=8.0,Episode_Price__c=5.0,Category__c='Catalog'));
        clAvailPriceList.add(new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c = clAvailList[0].id,Effective_Date__c=system.today()+150,Expiry_Date__c=clAvailList[0].End_Date__c,Price__c=90.0,Episode_Price__c=12.0,Type__c= 'Reprice',Category__c='Catalog')); 
        clAvailPriceList.add(new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c = clAvailList[1].id,Effective_Date__c=system.today()+15,Expiry_Date__c=system.today()+170,Price__c=10.0,Episode_Price__c=10.0,Type__c= WB_PriceUtility.FIRST,Category__c='Catalog'));
        clAvailPriceList.add(new Client_Avail_Price__c(RecordTypeId=tpRecTypeId,Client_Avail__c = clAvailList[1].id,Effective_Date__c=system.today()+15,Expiry_Date__c=system.today()+180,Price__c=9.0,Episode_Price__c=5.0,Category__c='Catalog'));
        clAvailPriceList.add(new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c = clAvailList[1].id,Effective_Date__c=system.today()+171,Expiry_Date__c=clAvailList[1].End_Date__c,Price__c=12.0,Episode_Price__c=11.0,Type__c= 'Reprice',Category__c='Catalog'));
        clAvailPriceList.add(new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c = clAvailList[2].id,Effective_Date__c=system.today()+15,Expiry_Date__c= system.today()+150,Price__c=10.0,Episode_Price__c=10.0,Type__c= WB_PriceUtility.FIRST,Category__c='Catalog'));
        clAvailPriceList.add(new Client_Avail_Price__c(RecordTypeId=tpRecTypeId,Client_Avail__c = clAvailList[2].id,Effective_Date__c=system.today()+30,Expiry_Date__c=system.today()+50,Price__c=19.0,Episode_Price__c=5.0,Category__c='Catalog'));
        clAvailPriceList.add(new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c = clAvailList[2].id,Effective_Date__c=system.today()+151,Expiry_Date__c=clAvailList[2].End_Date__c,Price__c=90.0,Episode_Price__c=12.0,Type__c= 'Reprice',Category__c='Catalog')); 
        try{
        insert clAvailPriceList;
        }catch(Exception ex){
            
        }
     
        Test.startTest();
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
        //EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announcement USA Standard'][0];
            
        String reportIdFromReport = null;//(String)reportList.get(0).get('Id');
        Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
        Datetime myDateTime1 = Datetime.newInstance(2014, 4, 17);
        List<Announcement_Rule__c> annRuleList = new List<Announcement_Rule__c>();
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=accList[0].Id,
                                                        Content_Type__c = 'Season; Episode', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='DTD;VODc',Selection_Criteria__c = 'Framed Delta', 
                                                        Report_Template__c='WB Standard Combined',/*Email_Template_Id__c=templateId.id,*/Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                        Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportIdFromReport, Date_Last_Run__c= myDateTime,Full_Extract__c = true,Announcement_Price_Type__c = 'PERM;TEMP');
        insert annRule;
        annRuleList.add(annRule);
      
        //create Announcement
         Announcement__c announcement = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Season; Episode', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='90 Day Rolling',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST;VODc');
                                                            
        insert announcement;
        
        
        //create Announcement
         Announcement__c announcement1 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Season; Episode', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Run_Date__c=myDateTime,
                                                            From_Date__c=myDateTime,
                                                            Selection_Criteria__c='Framed Delta',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Country_Group__c=countryGroup.Id,
                                                            Channels__c='DTD;EST;VODc');
       insert announcement1;
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();
        
        Announcement_Record__c annRecords1 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=clAvailList[0].Id,Client_Start__c=system.today()+15,Client_End__c=system.today()+24,Client_Avail_Price__c=clAvailPriceList[0].Id,Change_Status__c='New');
        annRecList.add(annRecords1);
        
        Announcement_Record__c annRecords2 = new Announcement_Record__c(Announcement__c=announcement.Id,Change_Status__c = 'Price Change',Client_Avail__c=clAvailList[0].Id,Client_Start__c=system.today()+25,Client_End__c=system.today()+160,Client_Avail_Price__c=clAvailPriceList[1].Id);
        annRecList.add(annRecords2);
        Announcement_Record__c annRecords9 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=clAvailList[0].Id,Client_Avail_Price__c=clAvailPriceList[2].Id);
       // annRecList.add(annRecords9);
        
        Announcement_Record__c annRecords3 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=clAvailList[1].Id,Client_Avail_Price__c=clAvailPriceList[3].Id);
        annRecList.add(annRecords3);
                    
       Announcement_Record__c annRecords4 = new Announcement_Record__c(Announcement__c=announcement.Id,Change_Status__c = 'Price Change',Client_Avail__c=clAvailList[1].Id,Client_Avail_Price__c=clAvailPriceList[4].Id);
        annRecList.add(annRecords4);
        Announcement_Record__c annRecords5 = new Announcement_Record__c(Announcement__c=announcement.Id,Change_Status__c = 'Price Change',Client_Avail__c=clAvailList[1].Id,Client_Avail_Price__c=clAvailPriceList[5].Id);
        annRecList.add(annRecords5); 
        
        Announcement_Record__c annRecords6 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=clAvailList[2].Id,Client_Start__c=system.today()+15,Client_End__c=system.today()+29,Client_Avail_Price__c=clAvailPriceList[6].Id);
        annRecList.add(annRecords6);
                    
       Announcement_Record__c annRecords7 = new Announcement_Record__c(Announcement__c=announcement.Id,Change_Status__c = 'Price Change',Client_Avail__c=clAvailList[2].Id,Client_Start__c=system.today()+30,Client_End__c=system.today()+50,Client_Avail_Price__c=clAvailPriceList[7].Id);
        annRecList.add(annRecords7);
        Announcement_Record__c annRecords8 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=clAvailList[2].Id,Client_Start__c=system.today()+51,Client_End__c=system.today()+150,Client_Avail_Price__c=clAvailPriceList[8].Id);
        annRecList.add(annRecords8); 
        
        Database.insert(annRecList);
        
        WB_compareLastAndFromDates1 compare = new WB_compareLastAndFromDates1();
        
        //create Announcement
         Announcement__c announcement3 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Season; Episode', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Framed Delta',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST;VODc');
                                                            
        insert announcement3;
         WB_ClientActivitiesBatchProcess1 batchClass = new WB_ClientActivitiesBatchProcess1(announcement.id,annRuleList,annfieldList);
          Database.executeBatch(batchClass,10);
          
           //Akash Changes Start
        Announcement_Trigger_Field__c annTriggerRec = new Announcement_Trigger_Field__c();
        annTriggerRec.Name = 'Pre Order Date';
        annTriggerRec.Trigger_Status__c = 'Optional';
        annTriggerRec.Source_Object__c = 'Client Avail';
        insert annTriggerRec;
        
        Set<String> optionalFieldsSet = new Set<String>();
        optionalFieldsSet.add(annTriggerRec.Name);
        
        //Akash Changes Finish
          
        compare.compareChange (clAvailList[1],annRecords3, announcement3.Id,announcement,clAvailPriceList[2],false,optionalFieldsSet);
        
        compare.compareChange (clAvailList[0],annRecords2, announcement3.Id,announcement,clAvailPriceList[2],false,optionalFieldsSet);
        compare.getOrderedCAPList(clAvailList[0],true);
         compare.getOrderedCAPList(clAvailList[2],true);
         
          annRecList = new List<Announcement_Record__c>();
        
        Announcement_Record__c annRecords01 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=clAvailList[0].Id,Client_Start__c=system.today()+15,Client_End__c=system.today()+24,Client_Avail_Price__c=clAvailPriceList[0].Id);
        annRecList.add(annRecords01);
        
        Announcement_Record__c annRecords02 = new Announcement_Record__c(Announcement__c=announcement.Id,Change_Status__c = 'Price Change',Client_Avail__c=clAvailList[0].Id,Client_Start__c=system.today()+25,Client_End__c=system.today()+160,Client_Avail_Price__c=clAvailPriceList[1].Id);
        annRecList.add(annRecords02);
       
        Database.insert(annRecList);
        
        WB_ClientActivitiesBatchProcess1 batchClass1 = new WB_ClientActivitiesBatchProcess1(announcement.id,annRuleList,annfieldList);
          Database.executeBatch(batchClass,10);
        Test.stopTest();
    }
    
    @isTest
    public static void testMethodForTPP()
    {
       TestDataUtility tdu = new TestDataUtility();  
       accList = tdu.createAccountList(); 
        
        //Start -- To create Client Avail 
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
       //list<Local_Title__c> ltList= [select id, Title__c, Country__c, Language__c, Category__c from Local_Title__c where id = :lt.id];
       Commercial_Avail__c rp = tdu.createReleasePlan_EST(t, c, lt, l);
       rp.Exclusive_Date__c = System.today().addDays(-200);
       rp.Start_Date__c = System.today().addDays(-200);
       rp.End_Date__c = System.today().addDays(500);
       rp.Rights_End__c= System.today().addDays(500);
       rp.Country_Lookup__c = c.Id;
       update rp;
       
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
       Test.startTest();
       Agreement__c sf = tdu.createStorefront(c,rp, t, accList[0]);
      // Client_Avail__c ca = tdu.createClientAvail(rp, sf, accList[0]);
      list<Client_Avail__c> CaccListInsert = New list<Client_Avail__c>();
       Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID,Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300));       
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300));
       Client_Avail__c ca2 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300),Announce_Override__c='Suppress'); 
       Client_Avail__c ca3 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300),APO_Date__c=Date.Today().addDays(-45));
       Client_Avail__c ca4 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300));
      
       CaccListInsert.add(ca);
       CaccListInsert.add(ca1);
       CaccListInsert.add(ca2); 
       CaccListInsert.add(ca3);
       CaccListInsert.add(ca4);
       insert CaccListInsert;
       
       String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
       String recTypeIdTPP = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME); 
       Client_Avail_Price__c cap1 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=ca.Start_Date__c,Expiry_Date__c=ca.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c capTPP = new Client_Avail_Price__c(RecordTypeId=recTypeIdTPP,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=System.today().addDays(210),Expiry_Date__c=System.today().addDays(220),Price__c=10.99);
       Client_Avail_Price__c cap2 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=ca1.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c cap3 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca2.id,Category__c='Catalog',Effective_Date__c=ca2.Start_Date__c,Expiry_Date__c=ca2.Start_Date__c.addDays(20),Price__c=10.99);
       Client_Avail_Price__c cap4 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca2.id,Category__c='Catalog',Effective_Date__c=ca2.Start_Date__c.addDays(21),Expiry_Date__c=ca2.End_Date__c,Price__c=9.99);
       Client_Avail_Price__c cap5 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca3.id,Category__c='Catalog',Effective_Date__c=ca3.Start_Date__c,Expiry_Date__c=ca3.Start_Date__c.addDays(20),Price__c=10.99);
       Client_Avail_Price__c cap6 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca3.id,Category__c='Catalog',Effective_Date__c=ca3.Start_Date__c.addDays(21),Expiry_Date__c=ca3.End_Date__c,Price__c=9.99);
       Client_Avail_Price__c cap7 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca4.id,Category__c='Catalog',Effective_Date__c=ca4.Start_Date__c,Expiry_Date__c=ca4.Start_Date__c.addDays(20),Price__c=10.99);
       Client_Avail_Price__c cap8 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca4.id,Category__c='Catalog',Effective_Date__c=ca4.Start_Date__c.addDays(21),Expiry_Date__c=ca4.End_Date__c,Price__c=9.99);
       
       List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
        capList.add(cap1);
        capList.add(capTPP);
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
        
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
        //EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announcement USA Standard'][0];
            
        String reportIdFromReport = null;//(String)reportList.get(0).get('Id');
        Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
        Datetime myDateTime1 = Datetime.newInstance(2014, 4, 17);
        List<Announcement_Rule__c> annRuleList = new List<Announcement_Rule__c>();
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=accList[0].Id,
                                                        Content_Type__c = 'Feature', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='DTD;EST',Selection_Criteria__c = 'Framed Full', 
                                                        Report_Template__c='WB Standard Combined',/*Email_Template_Id__c=templateId.id,*/Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                        Announcement_Price_Type__c = 'TEMP',
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
                                                            Selection_Criteria__c ='Framed Full',
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
                                                            Selection_Criteria__c='Framed Full',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Country_Group__c=countryGroup.Id,
                                                            Channels__c='DTD;EST');
        insert announcement1;
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();
        
        Announcement_Record__c annRecords = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=capTPP.Id,Change_Status__c='New');
        annRecList.add(annRecords);
        
        /*Announcement_Record__c annRecords1 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca1.Id,Client_Avail_Price__c=cap2.Id);
        annRecList.add(annRecords1);
        Announcement_Record__c annRecords11 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca1.Id,CAP_Id__c=cap2.Id,CAP_Comment__c='CAP Deleted');
        annRecList.add(annRecords11);
                    
        Announcement_Record__c annRecords2 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca2.Id,Client_Avail_Price__c=cap3.Id);
        annRecList.add(annRecords2);
        /*Announcement_Record__c annRecords3 = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca2.Id,Client_Avail_Price__c=cap3.id);
        annRecList.add(annRecords3);
        */
        Database.insert(annRecList);
        
         //Change Client Avail Start Date 
        ca.Start_Date__c=System.today().addDays(205);
        update ca;
        cap1.Effective_Date__c = System.today().addDays(205);
        update cap1;
        
        //create Announcement
         Announcement__c announcement2 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Framed Delta',
                                                            //Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
                                                            
        insert announcement2;
        
        //Change Client Avail End Date 
        ca1.End_Date__c =System.today().addDays(450);
        update ca1;
        cap2.Expiry_Date__c = System.today().addDays(450);
        update cap2;
        
        //create Announcement
         Announcement__c announcement3 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Framed Delta',
                                                            //Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
                                                            
        insert announcement3;
        
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
        
        /* System.debug(LoggingLevel.INFO,' allAvails are -> '+allAvails.size());                 
        for(Client_Avail__c caRecord:allAvails){
            System.debug(LoggingLevel.INFO,' CAP List is'+caRecord.Client_Avail_Prices__r);
          System.debug(LoggingLevel.INFO,'******* caRecord.Client__c ********'+caRecord.Client__c +' *******annRuleList[0].Account__c*****'+annRuleList[0].Account__c);
          System.debug(LoggingLevel.INFO,'******* caRecord.Title_Video_Version__c **********'+caRecord.Title_Video_Version__c +' ******* caRecord.Release_Plan_Country__c *******'+caRecord.Release_Plan_Country__c);
          System.debug(LoggingLevel.INFO,'******* caRecord.Release_Plan_Channel__c ********'+caRecord.Release_Plan_Channel__c +'## ******* caRecord.Status__c ******' +caRecord.Status__c);
          System.debug(LoggingLevel.INFO,'*******caRecord.CA_Lifecycle__c *****'+caRecord.CA_Lifecycle__c);
        } */
        try{
          WB_ClientActivitiesBatchProcess1 batchClass = new WB_ClientActivitiesBatchProcess1(announcement1.id,annRuleList,annfieldList);
          Database.executeBatch(batchClass,10);
         
        }catch(Exception ex){
          
        }
        
        //For 2nd Announcement
        try{
          WB_ClientActivitiesBatchProcess1 batchClass = new WB_ClientActivitiesBatchProcess1(announcement2.id,annRuleList,annfieldList);
          Database.executeBatch(batchClass,10);
        }catch(Exception ex){
          
        }
     
        //For 3rd Announcement Which is for ClientAvail End date change
        try{
          WB_ClientActivitiesBatchProcess1 batchClass = new WB_ClientActivitiesBatchProcess1(announcement2.id,annRuleList,annfieldList);
          Database.executeBatch(batchClass,10);
          Test.stopTest();
        }catch(Exception ex){
          
        }
    }
    
    @isTest
    public static void testMethodForTPP1()
    {
       TestDataUtility tdu = new TestDataUtility();  
       accList = tdu.createAccountList(); 
        
        //Start -- To create Client Avail 
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
       //list<Local_Title__c> ltList= [select id, Title__c, Country__c, Language__c, Category__c from Local_Title__c where id = :lt.id];
       Commercial_Avail__c rp = tdu.createReleasePlan_EST(t, c, lt, l);
       rp.Exclusive_Date__c = System.today().addDays(-200);
       rp.Start_Date__c = System.today().addDays(-200);
       rp.End_Date__c = System.today().addDays(500);
       rp.Rights_End__c= System.today().addDays(500);
       rp.Country_Lookup__c = c.Id;
       update rp;
       
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
       
       
       Test.startTest();
       Agreement__c sf = tdu.createStorefront(c,rp, t, accList[0]);
      // Client_Avail__c ca = tdu.createClientAvail(rp, sf, accList[0]);
      list<Client_Avail__c> CaccListInsert = New list<Client_Avail__c>();
       Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID,Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(-40),End_Date__c=System.today().addDays(300));       
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300));
       Client_Avail__c ca2 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300),Announce_Override__c='Suppress'); 
       Client_Avail__c ca3 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300),APO_Date__c=Date.Today().addDays(-45));
       Client_Avail__c ca4 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300));
      
       CaccListInsert.add(ca);
       CaccListInsert.add(ca1);
       CaccListInsert.add(ca2); 
       CaccListInsert.add(ca3);
       CaccListInsert.add(ca4);
       insert CaccListInsert;
       
       String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
       String recTypeIdTPP = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME); 
       Client_Avail_Price__c cap1 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=ca.Start_Date__c,Expiry_Date__c=ca.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c capTPP = new Client_Avail_Price__c(RecordTypeId=recTypeIdTPP,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=System.today(),Expiry_Date__c=System.today().addDays(10),Price__c=10.99);
       Client_Avail_Price__c cap2 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=ca1.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c cap3 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca2.id,Category__c='Catalog',Effective_Date__c=ca2.Start_Date__c,Expiry_Date__c=ca2.Start_Date__c.addDays(20),Price__c=10.99);
       Client_Avail_Price__c cap4 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca2.id,Category__c='Catalog',Effective_Date__c=ca2.Start_Date__c.addDays(21),Expiry_Date__c=ca2.End_Date__c,Price__c=9.99);
       Client_Avail_Price__c cap5 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca3.id,Category__c='Catalog',Effective_Date__c=ca3.Start_Date__c,Expiry_Date__c=ca3.Start_Date__c.addDays(20),Price__c=10.99);
       Client_Avail_Price__c cap6 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca3.id,Category__c='Catalog',Effective_Date__c=ca3.Start_Date__c.addDays(21),Expiry_Date__c=ca3.End_Date__c,Price__c=9.99);
       Client_Avail_Price__c cap7 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca4.id,Category__c='Catalog',Effective_Date__c=ca4.Start_Date__c,Expiry_Date__c=ca4.Start_Date__c.addDays(20),Price__c=10.99);
       Client_Avail_Price__c cap8 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca4.id,Category__c='Catalog',Effective_Date__c=ca4.Start_Date__c.addDays(21),Expiry_Date__c=ca4.End_Date__c,Price__c=9.99);
       
       List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
        capList.add(cap1);
        capList.add(capTPP);
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
        
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
        //EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announcement USA Standard'][0];
            
        String reportIdFromReport = null;//(String)reportList.get(0).get('Id');
        Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
        Datetime myDateTime1 = Datetime.newInstance(2014, 4, 17);
        //File_Format__c ='CSV',
        List<Announcement_Rule__c> annRuleList = new List<Announcement_Rule__c>();
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=accList[0].Id,
                                                        Content_Type__c = 'Feature', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='DTD;EST',Selection_Criteria__c = 'Framed Full', 
                                                        Report_Template__c='WB Standard Combined',/*Email_Template_Id__c=templateId.id,*/Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                        Announcement_Price_Type__c = 'TEMP',
                                                        Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportIdFromReport, Date_Last_Run__c= myDateTime,Full_Extract__c = true);
        insert annRule;
        annRuleList.add(annRule);
        
        //create Announcement
         Announcement__c announcement = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Job_Run_Status__c = 'Pending',
                                                            //File_Format__c ='CSV',
                                                            Announcement_Price_Type__c = 'TEMP',
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Framed Full',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
                                                            
        insert announcement;
        //create Announcement
         Announcement__c announcement1 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Job_Run_Status__c = 'Pending',
                                                            //File_Format__c ='CSV',
                                                            Announcement_Price_Type__c = 'TEMP',
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Run_Date__c=myDateTime,
                                                            From_Date__c=myDateTime,
                                                            Selection_Criteria__c='Framed Full',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Country_Group__c=countryGroup.Id,
                                                            Channels__c='DTD;EST');
        insert announcement1;
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();
        
        Announcement_Record__c annRecords = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=capTPP.Id,Change_Status__c='New');
        annRecList.add(annRecords);
        
        /*Announcement_Record__c annRecords1 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca1.Id,Client_Avail_Price__c=cap2.Id);
        annRecList.add(annRecords1);
        Announcement_Record__c annRecords11 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca1.Id,CAP_Id__c=cap2.Id,CAP_Comment__c='CAP Deleted');
        annRecList.add(annRecords11);
                    
        Announcement_Record__c annRecords2 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca2.Id,Client_Avail_Price__c=cap3.Id);
        annRecList.add(annRecords2);
        /*Announcement_Record__c annRecords3 = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca2.Id,Client_Avail_Price__c=cap3.id);
        annRecList.add(annRecords3);
        */
        //Database.insert(annRecList);
        
         //Change Client Avail Start Date 
        ca.Start_Date__c=System.today().addDays(205);
        update ca;
        cap1.Effective_Date__c = System.today().addDays(205);
        update cap1;
        
        //create Announcement
         Announcement__c announcement2 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature;Season', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Framed Delta',
                                                            //Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
                                                            
        //insert announcement2;
        
        //Change Client Avail End Date 
        ca1.End_Date__c =System.today().addDays(450);
        update ca1;
        cap2.Expiry_Date__c = System.today().addDays(450);
        update cap2;
        
        //create Announcement
         Announcement__c announcement3 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature;Season', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Framed Delta',
                                                            //Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
                                                            
        //insert announcement3;
        
        //annRecords.Status__c = 'Cancelled';
        //update annRecords;
        
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
        
        /* System.debug(LoggingLevel.INFO,' allAvails are -> '+allAvails.size());                 
        for(Client_Avail__c caRecord:allAvails){
            System.debug(LoggingLevel.INFO,' CAP List is'+caRecord.Client_Avail_Prices__r);
          System.debug(LoggingLevel.INFO,'******* caRecord.Client__c ********'+caRecord.Client__c +' *******annRuleList[0].Account__c*****'+annRuleList[0].Account__c);
          System.debug(LoggingLevel.INFO,'******* caRecord.Title_Video_Version__c **********'+caRecord.Title_Video_Version__c +' ******* caRecord.Release_Plan_Country__c *******'+caRecord.Release_Plan_Country__c);
          System.debug(LoggingLevel.INFO,'******* caRecord.Release_Plan_Channel__c ********'+caRecord.Release_Plan_Channel__c +'## ******* caRecord.Status__c ******' +caRecord.Status__c);
          System.debug(LoggingLevel.INFO,'*******caRecord.CA_Lifecycle__c *****'+caRecord.CA_Lifecycle__c);
        } */
        try{
          WB_ClientActivitiesBatchProcess1 batchClass = new WB_ClientActivitiesBatchProcess1(announcement1.id,annRuleList,annfieldList);
          Database.executeBatch(batchClass,10);
         
        }catch(Exception ex){
          
        }
        
       
    }
    
     @isTest
    public static void testMethodForTPP2()
    {
       TestDataUtility tdu = new TestDataUtility();  
       accList = tdu.createAccountList(); 
        
        //Start -- To create Client Avail 
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
       //list<Local_Title__c> ltList= [select id, Title__c, Country__c, Language__c, Category__c from Local_Title__c where id = :lt.id];
       Commercial_Avail__c rp = tdu.createReleasePlan_EST(t, c, lt, l);
       rp.Exclusive_Date__c = System.today().addDays(-200);
       rp.Start_Date__c = System.today().addDays(-200);
       rp.End_Date__c = System.today().addDays(500);
       rp.Rights_End__c= System.today().addDays(500);
       rp.Country_Lookup__c = c.Id;
       update rp;
       
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
       Test.startTest();
       Agreement__c sf = tdu.createStorefront(c,rp, t, accList[0]);
      // Client_Avail__c ca = tdu.createClientAvail(rp, sf, accList[0]);
      list<Client_Avail__c> CaccListInsert = New list<Client_Avail__c>();
       Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID,Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(-40),End_Date__c=System.today().addDays(300));       
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300));
       Client_Avail__c ca2 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300),Announce_Override__c='Suppress'); 
       Client_Avail__c ca3 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300),APO_Date__c=Date.Today().addDays(-45));
       Client_Avail__c ca4 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300));
      
       CaccListInsert.add(ca);
       CaccListInsert.add(ca1);
       CaccListInsert.add(ca2); 
       CaccListInsert.add(ca3);
       CaccListInsert.add(ca4);
       insert CaccListInsert;
       
       String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
       String recTypeIdTPP = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME); 
       Client_Avail_Price__c cap1 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=ca.Start_Date__c,Expiry_Date__c=ca.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c capTPP = new Client_Avail_Price__c(RecordTypeId=recTypeIdTPP,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=System.today(),Expiry_Date__c=System.today().addDays(10),Price__c=10.99);
       Client_Avail_Price__c cap2 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=ca1.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c cap3 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca2.id,Category__c='Catalog',Effective_Date__c=ca2.Start_Date__c,Expiry_Date__c=ca2.Start_Date__c.addDays(20),Price__c=10.99);
       Client_Avail_Price__c cap4 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca2.id,Category__c='Catalog',Effective_Date__c=ca2.Start_Date__c.addDays(21),Expiry_Date__c=ca2.End_Date__c,Price__c=9.99);
       Client_Avail_Price__c cap5 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca3.id,Category__c='Catalog',Effective_Date__c=ca3.Start_Date__c,Expiry_Date__c=ca3.Start_Date__c.addDays(20),Price__c=10.99);
       Client_Avail_Price__c cap6 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca3.id,Category__c='Catalog',Effective_Date__c=ca3.Start_Date__c.addDays(21),Expiry_Date__c=ca3.End_Date__c,Price__c=9.99);
       Client_Avail_Price__c cap7 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca4.id,Category__c='Catalog',Effective_Date__c=ca4.Start_Date__c,Expiry_Date__c=ca4.Start_Date__c.addDays(20),Price__c=10.99);
       Client_Avail_Price__c cap8 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca4.id,Category__c='Catalog',Effective_Date__c=ca4.Start_Date__c.addDays(21),Expiry_Date__c=ca4.End_Date__c,Price__c=9.99);
       
       List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
        capList.add(cap1);
        capList.add(capTPP);
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
        
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
        //EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announcement USA Standard'][0];
            
        String reportIdFromReport = null;//(String)reportList.get(0).get('Id');
        Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
        Datetime myDateTime1 = Datetime.newInstance(2014, 4, 17);
        List<Announcement_Rule__c> annRuleList = new List<Announcement_Rule__c>();
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=accList[0].Id,
                                                        Content_Type__c = 'Feature', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='DTD;EST',Selection_Criteria__c = 'Framed Full', 
                                                        Report_Template__c='WB Standard Combined',/*Email_Template_Id__c=templateId.id,*/Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                        Announcement_Price_Type__c = 'TEMP',
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
                                                            Selection_Criteria__c ='Framed Full',
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
                                                            Selection_Criteria__c='Framed Full',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Country_Group__c=countryGroup.Id,
                                                            Channels__c='DTD;EST');
        insert announcement1;
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();
        
        Announcement_Record__c annRecords = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap1.Id,Change_Status__c='New');
        annRecList.add(annRecords);
        
        /*Announcement_Record__c annRecords1 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca1.Id,Client_Avail_Price__c=cap2.Id);
        annRecList.add(annRecords1);
        Announcement_Record__c annRecords11 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca1.Id,CAP_Id__c=cap2.Id,CAP_Comment__c='CAP Deleted');
        annRecList.add(annRecords11);
                    
        Announcement_Record__c annRecords2 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca2.Id,Client_Avail_Price__c=cap3.Id);
        annRecList.add(annRecords2);
        /*Announcement_Record__c annRecords3 = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca2.Id,Client_Avail_Price__c=cap3.id);
        annRecList.add(annRecords3);
        */
        Database.insert(annRecList);
        
         //Change Client Avail Start Date 
        ca.Start_Date__c=System.today().addDays(205);
        update ca;
        cap1.Effective_Date__c = System.today().addDays(205);
        update cap1;
        
        //create Announcement
         Announcement__c announcement2 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Framed Delta',
                                                            //Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
                                                            
        //insert announcement2;
        
        //Change Client Avail End Date 
        ca1.End_Date__c =System.today().addDays(450);
        update ca1;
        cap2.Expiry_Date__c = System.today().addDays(450);
        update cap2;
        
        //create Announcement
         Announcement__c announcement3 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Framed Delta',
                                                            //Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
                                                            
        //insert announcement3;
        
        //annRecords.Status__c = 'Cancelled';
        //update annRecords;
        
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
        
        /* System.debug(LoggingLevel.INFO,' allAvails are -> '+allAvails.size());                 
        for(Client_Avail__c caRecord:allAvails){
            System.debug(LoggingLevel.INFO,' CAP List is'+caRecord.Client_Avail_Prices__r);
          System.debug(LoggingLevel.INFO,'******* caRecord.Client__c ********'+caRecord.Client__c +' *******annRuleList[0].Account__c*****'+annRuleList[0].Account__c);
          System.debug(LoggingLevel.INFO,'******* caRecord.Title_Video_Version__c **********'+caRecord.Title_Video_Version__c +' ******* caRecord.Release_Plan_Country__c *******'+caRecord.Release_Plan_Country__c);
          System.debug(LoggingLevel.INFO,'******* caRecord.Release_Plan_Channel__c ********'+caRecord.Release_Plan_Channel__c +'## ******* caRecord.Status__c ******' +caRecord.Status__c);
          System.debug(LoggingLevel.INFO,'*******caRecord.CA_Lifecycle__c *****'+caRecord.CA_Lifecycle__c);
        } */
        try{
          WB_ClientActivitiesBatchProcess1 batchClass = new WB_ClientActivitiesBatchProcess1(announcement1.id,annRuleList,annfieldList);
          Database.executeBatch(batchClass,10);
         
        }catch(Exception ex){
          
        }
        
       
    }
    
     @isTest
    public static void testMethodForMAL1()
    {
       TestDataUtility tdu = new TestDataUtility();  
       accList = tdu.createAccountList(); 
        
        //Start -- To create Client Avail 
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
       //list<Local_Title__c> ltList= [select id, Title__c, Country__c, Language__c, Category__c from Local_Title__c where id = :lt.id];
       Commercial_Avail__c rp = tdu.createReleasePlan_EST(t, c, lt, l);
       rp.Exclusive_Date__c = System.today().addDays(-200);
       rp.Start_Date__c = System.today().addDays(-200);
       rp.End_Date__c = System.today().addDays(500);
       rp.Rights_End__c= System.today().addDays(500);
       rp.Country_Lookup__c = c.Id;
       update rp;
       
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
       Test.startTest();
       Agreement__c sf = tdu.createStorefront(c,rp, t, accList[0]);
      // Client_Avail__c ca = tdu.createClientAvail(rp, sf, accList[0]);
      list<Client_Avail__c> CaccListInsert = New list<Client_Avail__c>();
       Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID,Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(-40),End_Date__c=System.today().addDays(300));       
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300));
       Client_Avail__c ca2 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300),Announce_Override__c='Suppress'); 
       Client_Avail__c ca3 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300),APO_Date__c=Date.Today().addDays(-45));
       Client_Avail__c ca4 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300));
      
       CaccListInsert.add(ca);
       CaccListInsert.add(ca1);
       CaccListInsert.add(ca2); 
       CaccListInsert.add(ca3);
       CaccListInsert.add(ca4);
       insert CaccListInsert;
       
       String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
       String recTypeIdTPP = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME); 
       Client_Avail_Price__c cap1 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=ca.Start_Date__c,Expiry_Date__c=ca.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c capTPP = new Client_Avail_Price__c(RecordTypeId=recTypeIdTPP,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=System.today(),Expiry_Date__c=System.today().addDays(10),Price__c=10.99);
       Client_Avail_Price__c cap2 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=ca1.End_Date__c,Price__c=10.99);
       Client_Avail_Price__c cap3 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca2.id,Category__c='Catalog',Effective_Date__c=ca2.Start_Date__c,Expiry_Date__c=ca2.Start_Date__c.addDays(20),Price__c=10.99);
       Client_Avail_Price__c cap4 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca2.id,Category__c='Catalog',Effective_Date__c=ca2.Start_Date__c.addDays(21),Expiry_Date__c=ca2.End_Date__c,Price__c=9.99);
       Client_Avail_Price__c cap5 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca3.id,Category__c='Catalog',Effective_Date__c=ca3.Start_Date__c,Expiry_Date__c=ca3.Start_Date__c.addDays(20),Price__c=10.99);
       Client_Avail_Price__c cap6 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca3.id,Category__c='Catalog',Effective_Date__c=ca3.Start_Date__c.addDays(21),Expiry_Date__c=ca3.End_Date__c,Price__c=9.99);
       Client_Avail_Price__c cap7 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca4.id,Category__c='Catalog',Effective_Date__c=ca4.Start_Date__c,Expiry_Date__c=ca4.Start_Date__c.addDays(20),Price__c=10.99);
       Client_Avail_Price__c cap8 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca4.id,Category__c='Catalog',Effective_Date__c=ca4.Start_Date__c.addDays(21),Expiry_Date__c=ca4.End_Date__c,Price__c=9.99);
       
       List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
        capList.add(cap1);
        capList.add(capTPP);
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
        
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
        //EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announcement USA Standard'][0];
            
        String reportIdFromReport = null;//(String)reportList.get(0).get('Id');
        Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
        Datetime myDateTime1 = Datetime.newInstance(2014, 4, 17);
        List<Announcement_Rule__c> annRuleList = new List<Announcement_Rule__c>();
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=accList[0].Id,
                                                        Content_Type__c = 'Feature', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='DTD;EST',Selection_Criteria__c = 'Active Full Extract', 
                                                        Report_Template__c='WB Standard Combined',/*Email_Template_Id__c=templateId.id,*/Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportIdFromReport, Date_Last_Run__c= myDateTime,Full_Extract__c = true);
        insert annRule;
        annRuleList.add(annRule);
        
        //create Announcement
         Announcement__c announcement = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Active Full Extract',
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
                                                            Selection_Criteria__c='Active Full Extract',
                                                            Full_Extract__c = annRule.Full_Extract__c,
                                                            Country_Group__c=countryGroup.Id,
                                                            Channels__c='DTD;EST');
        insert announcement1;
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();
        
        Announcement_Record__c annRecords = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap1.Id,Change_Status__c='New');
        annRecList.add(annRecords);
        
        /*Announcement_Record__c annRecords1 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca1.Id,Client_Avail_Price__c=cap2.Id);
        annRecList.add(annRecords1);
        Announcement_Record__c annRecords11 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca1.Id,CAP_Id__c=cap2.Id,CAP_Comment__c='CAP Deleted');
        annRecList.add(annRecords11);
                    
        Announcement_Record__c annRecords2 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca2.Id,Client_Avail_Price__c=cap3.Id);
        annRecList.add(annRecords2);
        /*Announcement_Record__c annRecords3 = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca2.Id,Client_Avail_Price__c=cap3.id);
        annRecList.add(annRecords3);
        */
        Database.insert(annRecList);
        
         //Change Client Avail Start Date 
        ca.Start_Date__c=System.today().addDays(205);
        update ca;
        cap1.Effective_Date__c = System.today().addDays(205);
        update cap1;
        
        //create Announcement
         Announcement__c announcement2 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Active Full Extract',
                                                            //Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
                                                            
        //insert announcement2;
        
        //Change Client Avail End Date 
        ca1.End_Date__c =System.today().addDays(450);
        update ca1;
        cap2.Expiry_Date__c = System.today().addDays(450);
        update cap2;
        
        //create Announcement
         Announcement__c announcement3 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Active Full Extract',
                                                            //Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
                                                            
        //insert announcement3;
        
        //annRecords.Status__c = 'Cancelled';
        //update annRecords;
        
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
        
        /* System.debug(LoggingLevel.INFO,' allAvails are -> '+allAvails.size());                 
        for(Client_Avail__c caRecord:allAvails){
            System.debug(LoggingLevel.INFO,' CAP List is'+caRecord.Client_Avail_Prices__r);
          System.debug(LoggingLevel.INFO,'******* caRecord.Client__c ********'+caRecord.Client__c +' *******annRuleList[0].Account__c*****'+annRuleList[0].Account__c);
          System.debug(LoggingLevel.INFO,'******* caRecord.Title_Video_Version__c **********'+caRecord.Title_Video_Version__c +' ******* caRecord.Release_Plan_Country__c *******'+caRecord.Release_Plan_Country__c);
          System.debug(LoggingLevel.INFO,'******* caRecord.Release_Plan_Channel__c ********'+caRecord.Release_Plan_Channel__c +'## ******* caRecord.Status__c ******' +caRecord.Status__c);
          System.debug(LoggingLevel.INFO,'*******caRecord.CA_Lifecycle__c *****'+caRecord.CA_Lifecycle__c);
        } */
        try{
          WB_ClientActivitiesBatchProcess1 batchClass = new WB_ClientActivitiesBatchProcess1(announcement1.id,annRuleList,annfieldList);
          Database.executeBatch(batchClass,10);
         
        }catch(Exception ex){
          
        }
        
       
    }
    
    @isTest
    public static void framedDeltaTestMethod()
    {
     TestDataUtility tdu = new TestDataUtility();  
       accList = tdu.createAccountList(); 
       accList[0].Name = 'Apple iTunes';
       update accList[0];
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
       
       insert annfieldList;
     
     Test.startTest();
     
         Pricing__c newPrice = new Pricing__c();
           newPrice.Content_Type__c = 'Feature';
           newPrice.Account__c = accList[0].Id;
           newPrice.Country__c = c.Id;
           newPrice.Channel__c = 'DTD';
           newPrice.Format__c = 'HD';
           newPrice.WS_Price__c = 120.00;
           insert newPrice;
         
         Commercial_Avail__c rp = tdu.createReleasePlan_EST(t, c, lt, l);
           rp.Exclusive_Date__c = System.today().addDays(-200);
           rp.Start_Date__c = System.today().addDays(-200);
           rp.End_Date__c = System.today().addDays(500);
           rp.Rights_End__c= System.today().addDays(500);
           rp.Country_Lookup__c = c.Id;
           update rp;
         Agreement__c sf = tdu.createStorefront(c,rp, t, accList[0]);
         
         list<Client_Avail__c> CaccListInsert = New list<Client_Avail__c>();
           Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID,Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(-80),End_Date__c=System.today().addDays(300));
           CaccListInsert.add(ca);
         insert CaccListInsert;
         
         List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
         String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
         Client_Avail_Price__c cap1 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=ca.Start_Date__c,Expiry_Date__c=ca.Start_Date__c.addDays(21),Price__c=120.00);
           Client_Avail_Price__c cap2 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=ca.Start_Date__c.addDays(21),Expiry_Date__c=ca.End_Date__c,Price_Tier__c= '63.12');
         capList.add(cap1);
           capList.add(cap2);
         
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
        System.debug('CAP2@@@@@@@@@@@@'+capList[1].Id);
        
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                      WHERE DeveloperName = 'WB_Standard_Combined'];
        String reportIdFromReport = null;
            //EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announcement USA Standard'][0];
            Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
            Datetime myDateTime1 = Datetime.newInstance(2014, 4, 17);
            List<Announcement_Rule__c> annRuleList = new List<Announcement_Rule__c>();
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=accList[0].Id,
                                                            Content_Type__c = 'Feature', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='DTD',Selection_Criteria__c = 'Framed Delta', 
                                                            Report_Template__c='WB Standard Combined',/*Email_Template_Id__c=templateId.id,*/Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                            Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportIdFromReport, Date_Last_Run__c= myDateTime,Full_Extract__c = true);
            insert annRule;
            annRuleList.add(annRule);
        
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
                                                                Channels__c='DTD;EST');
            insert announcement1;
             Announcement__c announcement2 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                                Email_Template__c='Announcement USA Standard',
                                                                Report_Id__c=reportIdFromReport,
                                                                Account__c=accList[0].Id,
                                                                Content_type__c='Feature', 
                                                                Status__c='Tentative; Confirmed; Cancelled', 
                                                                Run_Date__c=myDateTime,
                                                                From_Date__c=myDateTime,
                                                                Selection_Criteria__c='Framed Full',
                                                                Full_Extract__c = annRule.Full_Extract__c,
                                                                Country_Group__c=countryGroup.Id,
                                                                Channels__c='DTD;EST');
            insert announcement2;
            
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();
            
            Announcement_Record__c annRecords1 = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap1.Id,Change_Status__c='New');
            annRecList.add(annRecords1);
          Announcement_Record__c annRecords2 = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap2.Id,Change_Status__c='Price Start');
            annRecList.add(annRecords2);
         Database.insert(annRecList);
         
        WB_compareLastAndFromDates1 compare = new WB_compareLastAndFromDates1();
        
            ca.APO_Date__c = Date.Today().addDays(-90);
            update ca;
            
              //Akash Changes Start
            /*Announcement_Trigger_Field__c annTriggerRec = new Announcement_Trigger_Field__c();
            annTriggerRec.Name = 'Pre Order Date';
            annTriggerRec.Trigger_Status__c = 'Optional';
            annTriggerRec.Source_Object__c = 'Client Avail';
            insert annTriggerRec;*/
            
            Set<String> optionalFieldsSet = new Set<String>();
            optionalFieldsSet.add(annfieldList[0].Name);
            
            //Akash Changes Finish
            
             compare.compareChange (ca,annRecords2, announcement1.Id,announcement1,cap2,true,optionalFieldsSet);
             compare.compareChange (ca,annRecords2, announcement2.Id,announcement2,cap2,true,optionalFieldsSet);
             
            ca.Announce_Date__c = Date.Today().addDays(+2);
            update ca;
            compare.compareChange (ca,annRecords2, announcement1.Id,announcement1,cap2,true,optionalFieldsSet); 
            compare.compareChange (ca,annRecords2, announcement2.Id,announcement2,cap2,true,optionalFieldsSet);
        ca.End_Date__c =System.today().addDays(450);
            update ca;
            capList[1].Expiry_Date__c = ca.End_Date__c;
            update capList[1];
            
           compare.compareChange (ca,annRecords2, announcement1.Id,announcement1,cap2,true,optionalFieldsSet);
           compare.compareChange (ca,annRecords2, announcement2.Id,announcement2,cap2,true,optionalFieldsSet);
        
        
        
        Announcement_Record__c accR = compare.compareChange (ca,annRecords2, announcement1.Id,announcement1,cap2,true,optionalFieldsSet);
           system.debug('Changed Fields++++++++++++++++++++++++++++++'+accR.Changed_Fields__c);
           system.debug('Change Status++++++++++++++++++++++++++++++'+accR.Change_Status__c);
          Test.stopTest(); 
           try{
              WB_ClientActivitiesBatchProcess1 batchClass = new WB_ClientActivitiesBatchProcess1(announcement1.id,annRuleList,annfieldList);
              Database.executeBatch(batchClass,10);
             
            }catch(Exception ex){
              
            }
            
            try{
              WB_ClientActivitiesBatchProcess1 batchClass = new WB_ClientActivitiesBatchProcess1(announcement2.id,annRuleList,annfieldList);
              Database.executeBatch(batchClass,10);
             
            }catch(Exception ex){
              
            }
     
    }
    
    @isTest
    public static void createARForPreOrderCAPTest(){
             TestDataUtility tdu = new TestDataUtility();  
       accList = tdu.createAccountList(); 
        //Start -- To create Client Avail 
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
      
       //Create Pricing
       Pricing__c newPrice = new Pricing__c();
       newPrice.Content_Type__c = 'Feature';
       newPrice.Account__c = accList[0].Id;
       newPrice.Country__c = c.Id;
       newPrice.Channel__c = 'EST';
       newPrice.Format__c = 'HD';
       newPrice.WS_Price__c = 120.00;
       insert newPrice;
       
       //Create Release Plan
       Commercial_Avail__c rp = tdu.createReleasePlan_EST(t, c, lt, l);
       //rp.Channel__c = 'EST';
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
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300),APO_Date__c=system.today()-7);
       Client_Avail__c ca2 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(20),End_Date__c=System.today().addDays(180),Announce_Override__c='Suppress'); 
       Client_Avail__c ca3 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(12),End_Date__c=System.today().addDays(300),APO_Date__c=Date.Today().addDays(-45));
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
        
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report
                                  WHERE DeveloperName = 'WB_Standard_Combined'];
        //EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announcement USA Standard'][0];
            
        String reportIdFromReport = null;//(String)reportList.get(0).get('Id');
        Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
        Datetime myDateTime1 = Datetime.newInstance(2014, 4, 17);
        List<Announcement_Rule__c> annRuleList = new List<Announcement_Rule__c>();
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=accList[0].Id,
                                                        Content_Type__c = 'Feature', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='EST',Selection_Criteria__c = 'Framed Delta', 
                                                        Report_Template__c='WB Standard Combined',/*Email_Template_Id__c=templateId.id,*/Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                        Announcement_From_Email__c='test1122@test.com',Report_ID__c=reportIdFromReport, Date_Last_Run__c= myDateTime,Full_Extract__c = true,Optional_Triggers__c='ALID');
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
                                                            Country_Group__c=countryGroup.Id,
                                                            Channels__c='DTD;EST');
        insert announcement1;
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();
        
        Announcement_Record__c annRecords1 = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca.Id,Client_Avail_Price__c=cap1.Id,Change_Status__c='New',Changed_Fields__c='Client Avail');
        annRecList.add(annRecords1);
        
        Announcement_Record__c annRecords2 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca1.Id,Client_Avail_Price__c=cap2.Id,Change_Status__c='Price End',Changed_Fields__c='End Date',Client_End__c=ca1.End_Date__c);
        annRecList.add(annRecords2);
        Announcement_Record__c annRecords3 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca1.Id,CAP_Id__c=cap2.Id,CAP_Comment__c='CAP Deleted');
        annRecList.add(annRecords3);
                    
        Announcement_Record__c annRecords4 = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=ca2.Id,Client_Avail_Price__c=cap3.Id);
        annRecList.add(annRecords4);
        Announcement_Record__c annRecords5 = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca2.Id,Client_Avail_Price__c=cap4.id);
        annRecList.add(annRecords5);
        
        Announcement_Record__c annRecords6 = new Announcement_Record__c(Announcement__c=announcement1.Id,Client_Avail__c=ca2.Id,Client_Avail_Price__c=cap4.id,Client_Start__c=System.today()+10);
        annRecList.add(annRecords6);
        
        Database.insert(annRecList);
        
        //Change Client Avail Start Date 
        ca.Start_Date__c=System.today().addDays(205);
        update ca;
        cap1.Effective_Date__c = System.today().addDays(205);
        update cap1;
        
        //create Announcement
         Announcement__c announcement2 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Framed Delta',
                                                            //Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
                                                            
        insert announcement2;
        
        WB_compareLastAndFromDates1 compare = new WB_compareLastAndFromDates1();
        
        //Change Client Avail End Date 
        ca1.End_Date__c =System.today().addDays(450);
        update ca1;
        cap2.Expiry_Date__c = System.today().addDays(450);
        update cap2;
        
        //Akash Changes Start
        /*Announcement_Trigger_Field__c annTriggerRec = new Announcement_Trigger_Field__c();
        annTriggerRec.Name = 'Pre Order Date';
        annTriggerRec.Trigger_Status__c = 'Optional';
        annTriggerRec.Source_Object__c = 'Client Avail';
        insert annTriggerRec;*/
        
        Set<String> optionalFieldsSet = new Set<String>();
        optionalFieldsSet.add(annfieldList[2].Name);
        
        //Akash Changes Finish
        
        compare.compareChange (ca1,annRecList[0], announcement.Id,announcement,cap2,false,optionalFieldsSet);
        
         List<Announcement__c> annList = new List<Announcement__c>();
        announcement = new Announcement__c(Announcement_Type__c=annRuleList[0].Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='90 Day Rolling',
                                                            Channels__c='DTD;EST',
                                                            Run_Date__c = myDateTime.addDays(20));
                                                            
        annList.add(announcement);
        insert annList;
        
        set<Id> setIds = new set<Id>();
        setIds.add(annRecList[1].id);
        
        ID batchprocessid = Database.executeBatch(new WB_Announcement_Pre_Orders (annList,annRuleList,setIds), 200);  
        
        //create Announcement
         Announcement__c announcement3 = new Announcement__c(Announcement_Type__c=annRule.Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Report_Id__c=reportIdFromReport,
                                                            Account__c=accList[0].Id,
                                                            Content_type__c='Feature', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='Framed Delta',
                                                            //Full_Extract__c = annRule.Full_Extract__c,
                                                            Channels__c='DTD;EST');
                                                            
        insert announcement3;
        
        
        cap4.Price__c = 120.00;
        update cap4;
        annRecList[2].Change_Status__c = ' No Change';
        update annRecList;
        
        /*lt.Local_Rating__c = '7';
        update lt;*/
        
       
       // System.debug('clientAvailRec.Local_Data__c>>>>>>>>>'+ca1.Local_Data__c);
        //System.debug('annRecOnCA.Local_Title__c>>>>>>>>>>'+annRecords2.Local_Title__c);
        compare.compareChange (ca1,annRecords2, announcement.Id,announcement,cap2,false,optionalFieldsSet);
        
        
        compare.compareChange (ca1,annRecords2, announcement.Id,announcement,cap2,true,optionalFieldsSet);
        //Akash Changes Finish
        
        
        lt.Local_Rating__c = '7';
        lt.Local_Title__c = 'testWB';
        update lt;
        compare.compareChange (ca1,annRecords2, announcement.Id,announcement,cap2,false,optionalFieldsSet);
        
        ca2.APO_Date__c = Date.Today().addDays(-40);
        update ca2;
         compare.compareChange (ca2,annRecords2, announcement.Id,announcement,cap4,true,optionalFieldsSet);
         
        ca2.Announce_Date__c = Date.Today().addDays(+2);
        update ca2;
        compare.compareChange (ca2,annRecords2, announcement.Id,announcement,cap4,true,optionalFieldsSet);
        
        ca2.End_Date__c=System.today().addDays(200);
        update ca2;
        compare.compareChange (ca2,annRecords2, announcement.Id,announcement,cap4,true,optionalFieldsSet);
        
       
         
        cap4.Price_Tier__c = '120';
        update cap4;
        compare.compareChange (ca2,annRecords2, announcement.Id,announcement,cap4,true,optionalFieldsSet);
        
        cap5.Price__c = 120;
        update cap5;
        compare.compareChange (ca3,annRecords2, announcement.Id,announcement,cap5,false,optionalFieldsSet);
        
        String recTypeId1 = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME); 
        Client_Avail_Price__c cap9 = new Client_Avail_Price__c(RecordTypeId=recTypeId1,Client_Avail__c=ca2.id,Category__c='Catalog',Effective_Date__c=ca2.Start_Date__c.addDays(-10),Expiry_Date__c=ca2.Start_Date__c.addDays(50),Price__c=11.99);
        insert cap9;
        capList.add(cap9);
        compare.getOrderedCAPList(ca2, true);
        
        String keyCAP = String.valueof(ca2.id)+String.valueof(cap9.id)+String.valueOf(cap9.Effective_Date__c);
        Map<String,Announcement_Record__c> mapCAANDCAPAnnRecord = new Map<String,Announcement_Record__c>();
        mapCAANDCAPAnnRecord.put(keyCAP,annRecords2);
       compare.createARForPreOrderCAP(ca2, mapCAANDCAPAnnRecord, announcement, annRuleList, capList,annfieldList, new set<String>{'Change','Price Start','Price End','Price Change'});
       
           
    }
}