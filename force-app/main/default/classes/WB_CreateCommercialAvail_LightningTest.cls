/*
   @Author Cognizant 
   @name WB_CreateCommercialAvail_Lightning.
   @CreateDate 23 Jan 2018
   @Description - Test class for Release Plan (Detail and List) button on Title
   @Version <1.0>
   @Requirement ER-1660
*/


@isTest
private class WB_CreateCommercialAvail_LightningTest {
    public static Title__c title;
    public static List<Title__c> lstTitle = new List<Title__c>();
    public static List<Title__c> emptylstTitle = new List<Title__c>();
    public static List<Title__c> largelstTitle = new List<Title__c>();
    
    public static list<Title__c> createTitleRecord(){
        List<Title__c> lstTitle = new List<Title__c>();
        for(Integer i=0;i<52;i++){
            Title__c titleRec = new Title__c();
            titleRec = TestUtil.createTitle('Batman Returns'+i,'111'+i);
            titleRec.Digital_Planning__c = 'Yes';
            titleRec.Formats__c = 'SD';
            lstTitle.add(titleRec);
        }
        return lstTitle;
       
    }
	private static testMethod void setUpData() {
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        MPM__c mpm = TestUtil.createMPM('2070337');
        insert mpm;
        
        title = TestUtil.createTitle('Batman Returns','6000100174');
        title.Digital_Planning__c = 'Yes';
        title.Formats__c = 'SD';
        insert title;
        lstTitle.add(title);
        
        Country__c countryFrance = TestUtil.initCountry('TestFrance', 'TR', 'TF');
        insert countryFrance;
        
        Language__c languageFrench = TestUtil.initLanguage('TestFrench', '', 1);
        insert languageFrench;
        
        Agreement__c storeFront = TestUtil.initStoreFront2(acctGoogle.Id, countryFrance.Id);
        Insert storeFront;
        
        Local_Title__c locTitle = TestUtil.createLocalData('20010', countryFrance, languageFrench, 'French', title.Id);
        Insert locTitle;
        
        Available_Languages__c avl1 = TestUtil.initAvailableLang(languageFrench.Id, 'Sub', title.Id);
        Insert avl1;
        
        Available_Languages__c avl2 = TestUtil.initAvailableLang(languageFrench.Id, 'Audio', title.Id);
        Insert avl2;
     }
    
     private static testMethod void testMethod1(){
        setUpData();
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(title);
        WB_CreateCommercialAvail_Lightning ctrl = new WB_CreateCommercialAvail_Lightning(sc);
        ctrl.forwardToListController();
        Test.stopTest();
    }
     private static testMethod void testMethod2(){
        setUpData();
        Test.startTest();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(lstTitle);
        sc.setSelected(lstTitle);
        WB_CreateCommercialAvail_Lightning ctrl = new WB_CreateCommercialAvail_Lightning(sc);
        ctrl.forwardToListController();
        Test.stopTest();
    }
     private static testMethod void testMethod3(){
        Test.startTest();
        largelstTitle = createTitleRecord();
        insert largelstTitle;
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(largelstTitle);
        sc.setSelected(largelstTitle); 
        WB_CreateCommercialAvail_Lightning ctrl = new WB_CreateCommercialAvail_Lightning(sc);
        ctrl.forwardToListController();
        Test.stopTest();
    }
    private static testMethod void testMethod4(){
        Test.startTest();
        largelstTitle = createTitleRecord();
        insert largelstTitle;
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(emptylstTitle);
        sc.setSelected(emptylstTitle); 
        WB_CreateCommercialAvail_Lightning ctrl = new WB_CreateCommercialAvail_Lightning(sc);
        ctrl.forwardToListController();
        Test.stopTest();
    }
}