@isTest
private class ScriptForCollection_Test {
    public static List<Title__c> titleList;
    public static List<Country__c> countryList;
    public static List<Language__c> languageList;
    public static List<Local_Title__c> localTitleList;
    public static List<Commercial_Avail__c> releasePlanList;
    public static List<Client_Avail__c> clientAvailList;
	private static testMethod void test() {
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        titleList = new List<Title__c>();
        Title__c title = TestUtil.initTitle('Dark Night Collection', '6000025000');
        title.Content_Type__c = Label.Collection_Features;
        title.Formats__c = 'HD';
        insert title;
        
        Title__c title1 = TestUtil.initTitle('Batman Begins', '6000025001');
        title1.Collection_title__c = title.id;
        title1.Formats__c = 'SD';
        titleList.add(title1);
        
        Title__c title2 = TestUtil.initTitle('Dark Night', '6000025002');
        title2.Collection_title__c = title.id;
        title2.Formats__c = '3DHD';
        titleList.add(title2);
        insert titleList;
        
        List<Playlist__c> listPlaylist = new List<Playlist__c>();
        Playlist__c p1= new Playlist__c(Name='Standard',Parent_Title__c = title.id,Playlist_Status__c='Active',Playlist_Type__c='Collection Features',Version_Number__c=1);
        listPlaylist.add(p1);
        insert listPlaylist;
        
        Country__c countryFrance = TestUtil.initCountry('TestFrance', 'TR', 'TF');
        insert countryFrance;
        
        Language__c languageFrench = TestUtil.initLanguage('TestFrench', '', 1);
        insert languageFrench;
        
        Local_Title__c localTitle = TestUtil.initLocalTitle(languageFrench.Id, countryFrance.Id);
        localTitle.Title__c = title.id;
        insert localTitle;
        
        releasePlanList = new List<Commercial_Avail__c>();
        Commercial_Avail__c CommercialAvail1 = TestUtil.initReleasePlan(title.Id, localTitle.Id, countryFrance.Id, languageFrench.Id);
        CommercialAvail1.End_Date__c = date.today() + 2;
        releasePlanList.add(CommercialAvail1);

        insert releasePlanList;
        
        Agreement__c storefrontGoogle = TestUtil.initStoreFront2(acctGoogle.Id, countryFrance.Id);
        storefrontGoogle.Channel_Picklist__c = 'VODc';
        insert storefrontGoogle;
        
        /*clientAvailList = new List<Client_Avail__c>();
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(acctGoogle.Id, releasePlanList[0], localTitle.id);
        clientAvailList.add(clientAvail1);
        
        insert clientAvailList;*/
        
        test.startTest();
            Database.executebatch(new ScriptForCollection(),10);
        test.stopTest();
	}

}