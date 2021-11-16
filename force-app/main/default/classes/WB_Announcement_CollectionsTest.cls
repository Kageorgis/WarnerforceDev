@isTest
private class WB_Announcement_CollectionsTest {
	public static Announcement__c announcement;
    public static List<Announcement_Rule__c> annRuleList = new List<Announcement_Rule__c>();
    public static Datetime myDateTime = Datetime.newInstance(2014, 2, 17);
    public static List<Announcement_Trigger_Field__c> annfieldList = new List<Announcement_Trigger_Field__c>();
    
    static testMethod void myUnitTest() {
         Account acct = TestUtil.initAccount();
        insert acct;
        //Start -- To create Client Avail 
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        
        Title__c collectionTitle = new Title__c(Name = 'Coll1',MPM__c = mpm.id,Video_Version__c ='1243355670',Content_Type__c=Label.Collection_Features,Digital_Planning__c='Yes',Clear_to_Avail__c = true, Formats__c = 'HD');
        insert collectionTitle;
        
        Title__c title1 = new Title__c(Name = 'Title1',MPM__c = mpm.id,Video_Version__c ='1243355672',Content_Type__c='Feature',Digital_Planning__c='Yes',Clear_to_Avail__c = true, Formats__c = 'HD');
        insert title1; 
        
        Playlist__c playlist = new Playlist__c(name='Standard Playlist',Parent_Title__c=collectionTitle.id,Playlist_Status__C = 'Active',Version_number__c=1);
        insert playlist;
        
        Playlist_Content__c pc = new Playlist_Content__c(Playlist__c=playlist.id,Content_Title__c=title1.id);
        insert pc;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance1',Country_Code2__c ='AA',Country_Code__c='TC');
        insert countryFrance;   
        
        Country_Groups__c countryGroup=new Country_Groups__c(Name='CountryGroup',Account__c=acct.Id,Country__c=countryFrance.Name);
        insert countryGroup;     
        Language__c languageFrench = new Language__c(Name='TestFrench1',Language_Order__c = 1);
        insert languageFrench;   
        
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=languageFrench.Id ,Language_Types__c='Audio',Title__c=collectionTitle.Id,Clear_To_Avail__c=true);
        insert availLangTitle1;
        
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=languageFrench.Id ,Language_Types__c='Audio',Title__c=title1.Id,Clear_To_Avail__c=true);
        insert availLangTitle2;
       
        
        Commercial_Avail__c releaseplanCollection = new Commercial_Avail__c(Title__c=collectionTitle.Id,Country_Lookup__c=countryFrance.Id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Audio',Status__c='Tentative',
                                                                    Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+200,Rights_End__c=date.today()+200,Playlist__c=playlist.id);
       // insert releaseplanCollection;  
        
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acct.Id,Country__c=countryFrance.Id,Pricing_Currency__c='FR',Content_Type__c='Collection Features; Collection TV; Episode; Feature; Season',
                                                            Channel_Picklist__c = 'EST',Format__c='HD',Status__c ='Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,
                                                                    Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Audio',Status__c='Tentative',
                                                                    Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+20,Rights_End__c=date.today()+20);
        //insert  releaseplan1; 
        
        
        List<Commercial_Avail__c> releasePlanList = new List<Commercial_Avail__c>{releaseplanCollection, releaseplan1};
        insert releasePlanList;
        
         
        Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,                                                   
                                                          Client__c=acct.Id,    Status__c='Tentative',Start_Date__c=releaseplan1.Start_Date__c,End_Date__c=releaseplan1.End_Date__c );                                                        
        
        Client_Avail__c clientAvail2 = new Client_Avail__c(Commercial_Avail__c=releaseplanCollection.Id,                                                   
                                                          Client__c=acct.Id,    Status__c='Confirmed',Start_Date__c=releaseplanCollection.Start_Date__c+2,End_Date__c=releaseplanCollection.End_Date__c, Price__c = 10.0 );                                                        
        
        List<Client_Avail__c> availist = new List<Client_Avail__c>{clientAvail1,clientAvail2};
        insert availist;
        
        //system.assert(false,[Select Id, Playlist__c from Client_Avail__c]);
        
        Test.startTest();
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report WHERE DeveloperName like '%Standard%' limit 1];
        //EmailTemplate templateId = [select id,Subject, HtmlValue, Body, name from EmailTemplate where name = 'Announcement USA Standard' limit 1];
            
        //reportIdFromReport = (String)reportList.get(0).get('Id');
       	List<Announcement_Rule__c> annRuleList = new List<Announcement_Rule__c>();
        Announcement_Rule__c annRule = new Announcement_Rule__c(Announcement_Type__c='ApexTestAnnocementType2', Account__c=acct.Id,
                                                        Content_Type__c = 'Collection Features', Statuses__c='Tentative; Confirmed; Cancelled',Channels__c='DTD',Selection_Criteria__c = 'Delta', 
                                                        Report_Template__c='WB Standard Combined',/*Email_Template_Id__c=templateId.id,*/Email_Template__c='Announcement Client Avails Activity',Announcement_From_Name__c='test',
                                                        Announcement_From_Email__c='test1122@test.com', Date_Last_Run__c= myDateTime);
        insert annRule;
        annRuleList.add(annRule);
        
        
        
        
      
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
       
       
       //create Announcement
        List<Announcement__c> annList = new List<Announcement__c>();
         announcement = new Announcement__c(Announcement_Type__c=annRuleList[0].Id,Report_Name__c='WB_Standard_Combined',
                                                            Email_Template__c='Announcement USA Standard',
                                                            Account__c=acct.Id,
                                                            Content_type__c='Collection Features', 
                                                            Status__c='Tentative; Confirmed; Cancelled', 
                                                            Selection_Criteria__c ='90 Day Rolling',
                                                            Channels__c='DTD;EST',
                                                            Run_Date__c = myDateTime.addDays(20));
                                                            
        annList.add(announcement);
        insert annList;
        
        List<Announcement_Record__c> annRecList = new List<Announcement_Record__c>();
        Announcement_Record__c annRecords = new Announcement_Record__c(Announcement__c=announcement.Id,Client_Avail__c=availist[1].Id,Sales_Channel__c='EST',Change_Status__c = 'New',  Playlist__c = playlist.Id);
        annRecList.add(annRecords);
        insert annRecList;
        set<Id> setIds = new set<Id>();
        setIds.add(annRecList[0].id);
        
        List<Announcement_Record__c> accneList = [SELECT Id, Announcement__c, Client_Avail__c, Client_Avail__r.Client__c, Client_Avail__r.Id, Client_Avail__r.Title_Video_Version__c, Client_Avail__r.Release_Plan_Country__c, Status__c, Playlist__c FROM Announcement_Record__c];
        
        //system.assert(false, accneList);
        ID batchprocessid = Database.executeBatch(new WB_Announcement_Collections (annList,annRuleList,setIds, annfieldList), 200);                 
        
        Test.stopTest();
        
        
        
        
        
    }
}