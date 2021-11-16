@isTest
public class WB_Release_Plan_Split_LightningTest {
    public static Account acctGoogle;
    public static MPM__c mpm;
    public static Title__c title;
    public static Country__c countryFrance;
    public static Language__c languageFrench;
    public static Agreement__c storeFront;
    public static Local_Title__c locTitle;
    public static Available_Languages__c avl1;
    public static Available_Languages__c avl2;
	public static Commercial_Avail__c rp;
	public static Commercial_Avail__c rp2;
	public static List<Commercial_Avail__c> lstRP;
	private static void setUpData(Boolean flag){
        acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        mpm = TestUtil.createMPM('2070337');
        insert mpm;
        
        title = TestUtil.createTitle('Batman Returns','6000100174');
        title.Digital_Planning__c = 'Yes';
        title.Formats__c = 'SD';
        insert title;
        
        countryFrance = TestUtil.initCountry('TestFrance', 'TR', 'TF');
        insert countryFrance;
        
        languageFrench = TestUtil.initLanguage('TestFrench', '', 1);
        insert languageFrench;
        
        storeFront = TestUtil.initStoreFront2(acctGoogle.Id, countryFrance.Id);
        Insert storeFront;
        
        locTitle = TestUtil.createLocalData('20010', countryFrance, languageFrench, 'French', title.Id);
        Insert locTitle;
        
        avl1 = TestUtil.initAvailableLang(languageFrench.Id, 'Sub', title.Id);
        Insert avl1;
        
        avl2 = TestUtil.initAvailableLang(languageFrench.Id, 'Audio', title.Id);
        Insert avl2;
        
        rp = TestUtil.initReleasePlan(title.Id, locTitle.Id, countryFrance.Id, languageFrench.Id);
        rp.Exclusive_Date__c = date.today() - 1;
        rp.Rights_End__c = date.today() + 11;
        rp.Start_Date__c = date.today();
        rp.End_Date__c = date.today() + 10;
       
        rp2 = TestUtil.initReleasePlan(title.Id, locTitle.Id, countryFrance.Id, languageFrench.Id);
        rp2.Language_Type__c = 'Sub & Audio';
        rp2.Exclusive_Date__c = date.today() + 3;
        rp2.Rights_End__c = date.today() + 12;
        rp2.Start_Date__c = date.today() + 5;
        rp2.End_Date__c = date.today() + 10;
        lstRP = new List<Commercial_Avail__c>();
        
        lstRP.add(rp);
        lstRP.add(rp2);
        insert lstRP;
	}
	
	 private static testmethod void WB_Release_Plan_Split_LightningTest1(){
        setUpData(true);
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(lstRP[0]);
        WB_Release_Plan_Split_Lightning controller1 = new WB_Release_Plan_Split_Lightning(sc);
        controller1.forwardToListController();
        Test.setCurrentPageReference(new PageReference('Page.WB_Release_Plan_Split_Lightning_List')); 
        System.currentPageReference().getParameters().put('ID', lstRP[0].Id);
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        test.stopTest();

	  }
	  
	  private static testmethod void WB_Release_Plan_Split_LightningTest2(){
        setUpData(true);
        test.startTest();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(lstRP);
        sc.setSelected(lstRP);
        WB_Release_Plan_Split_Lightning ctrl = new WB_Release_Plan_Split_Lightning(sc);
        ctrl.forwardToListController();
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertEquals(0, pageMessages.size());
        Test.stopTest();

        
	  }
    
    
      private static testmethod void WB_Release_Plan_Split_LightningTest3(){
       setUpData(true);
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(lstRP[0]);
        WB_Release_Plan_Split_Lightning controller1 = new WB_Release_Plan_Split_Lightning(sc);
        controller1.forwardToListController();
        Test.setCurrentPageReference(new PageReference('Page.WB_Release_Plan_Split_Lightning_List')); 
        System.currentPageReference().getParameters().put('UNIQUEID', lstRP[0].Id);
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        System.currentPageReference().getParameters().put('IDs', lstRP[0].Id);
        controller1.selected_Record = 51;
         controller1.forwardToListController();
         System.assertNotEquals(0, pageMessages.size());
        test.stopTest();
        
	  }
      /*private static testmethod void WB_Release_Plan_Split_LightningTest4(){
       setUpData(true);
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(lstRP[0]);
        WB_Release_Plan_Split_Lightning controller1 = new WB_Release_Plan_Split_Lightning(sc);
        controller1.forwardToListController();
        Test.setCurrentPageReference(new PageReference('Page.WB_Release_Plan_Split_Lightning_List'));            
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
      System.currentPageReference().getParameters().put('UNIQUEID', NULL);
         System.currentPageReference().getParameters().put('ID', NULL);
        controller1.selected_Record = 51;
         controller1.Id1 = '010,020';
         controller1.forwardToListController();
         System.assertNotEquals(0, pageMessages.size());
        test.stopTest();
        
	  }
    private static testmethod void WB_Release_Plan_Split_LightningTest5(){
       setUpData(true);
        test.startTest();
        
        Test.setCurrentPageReference(new PageReference('Page.WB_Release_Plan_Split_Lightning_List'));            
        System.currentPageReference().getParameters().put('IDs', lstRP[0].Id);
         ApexPages.StandardController sc = new ApexPages.StandardController(lstRP[0]);
        WB_Release_Plan_Split_Lightning controller1 = new WB_Release_Plan_Split_Lightning(sc);    
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
       
        controller1.selected_Record = 51;
         controller1.forwardToListController();
         System.assertNotEquals(0, pageMessages.size());
        test.stopTest();
        
	  }*/
}