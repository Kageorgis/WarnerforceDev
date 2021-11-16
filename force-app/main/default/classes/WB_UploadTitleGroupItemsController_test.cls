@isTest(SeeAllData=false)
public class WB_UploadTitleGroupItemsController_test{
    public static List<Local_Title__c> listlocaltitles;
    
    @isTest
    public static void testMethodForWB_UploadMPMTitleGroup()
    {
        listlocaltitles= new List<Local_Title__c>();
        MPM__c Mpm = new MPM__c();
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646';
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        MPM__c Mpm1 = new MPM__c();
        Mpm1.Name = 'MPM01818';
        Mpm1.MPM_Number__c = '181800';
        Mpm1.Film_Color__c = 'Color';
        insert Mpm1;
        
        Account objAccount = TestUtil.createAccount('Apple iTunes');
        objAccount.Customer_Focus__c = 'Active';
        objAccount.Type='Global';
        insert objAccount;
        
        /* -- Title creation-- */
        TestDataUtility tdu = new TestDataUtility(); 
        Title__c t = tdu.createTitle(Mpm);
        
        Country__c Country = New Country__c();
        Country.Name = 'INDIA';
        Country.Country_Code2__c = 'IN';
        Country.Country_Code__c = 'IND';
        Country.Status__c = 'Active';
        insert Country;
        
        Language__c Language = New Language__c();
        Language.Name = 'English';
        Language.Language_Order__c = 1;
        insert Language;
        
        Local_Title__c LT = New Local_Title__c();
        LT.Name = t.Name;
        LT.Title__c = t.Id;
        LT.Country__c = Country.Id;
        LT.Local_Theatrical_Release_Date__c = date.today();
        LT.Language__c = Language.Id;
        LT.Local_TV_Air_Date__c = System.today()+2;
        LT.Price_Code__c = 'CheckPriceCode1';
        insert LT;
        
        Title__c title1 = new Title__c(
            Name = 'DID Season',
            Video_Version__c ='V01235',
            Content_Type__c='Feature',
            Digital_Planning__c='Yes',
            Clear_to_Avail__c = true,
            MPM__c = Mpm1.Id,
            Formats__c = 'SD');
            insert title1;
        
        Test.startTest(); 
        String mpmRecTypeId = WB_PriceUtility.getRecordTypeId(Title_Group__c.getSobjectType(),'MPM');        
        
        //MPM Record Type
        Title_Group__c newTitleGroup = new Title_Group__c();
        newTitleGroup.Group_Name__c = 'Test MPM Title Group';
        newTitleGroup.RecordTypeId = mpmRecTypeId;
        insert newTitleGroup;
        Title_Group_Item__c newTitleGItem = new Title_Group_Item__c();
        newTitleGItem.Title_Group__c = newTitleGroup.Id;
        newTitleGItem.MPM__c = Mpm.Id;
        newTitleGItem.Title__c = t.Id;
        insert newTitleGItem;
        Title_Group_Item__c newTitleGItem1 = new Title_Group_Item__c();
        newTitleGItem1.Title_Group__c = newTitleGroup.Id;
        newTitleGItem1.MPM__c = Mpm1.Id;
        newTitleGItem1.Title__c = title1.Id;
        insert newTitleGItem1;
        
        
        WB_UploadTitleGroupItemsController ctrlUploadGroupItem = new WB_UploadTitleGroupItemsController(new ApexPages.StandardController(newTitleGroup));
        WB_UploadTitleGroupItemsController.getRecordTypeName(newTitleGroup.Id);
        WB_UploadTitleGroupItemsController.getTitleGroupItems(newTitleGroup.Id);
        ctrlUploadGroupItem.getUserLocale();
        WB_UploadTitleGroupItemsController.TitleGroupItemWrapper lineItemWrapper = new WB_UploadTitleGroupItemsController.TitleGroupItemWrapper();
        List< WB_UploadTitleGroupItemsController.TitleGroupItemWrapper> returnWrapperList = new List< WB_UploadTitleGroupItemsController.TitleGroupItemWrapper>();
        lineItemWrapper.videoVersionOrMPM = '2063646'; 
        lineItemWrapper.isRowModified = True;
        lineItemWrapper.titleGroupItem = newTitleGItem;
        returnWrapperList.add(lineItemWrapper);
        
        WB_UploadTitleGroupItemsController.TitleGroupItemWrapper lineItemWrapper3 = new WB_UploadTitleGroupItemsController.TitleGroupItemWrapper();
        lineItemWrapper3.videoVersionOrMPM = '20611111'; 
        lineItemWrapper3.isRowModified = True;
        returnWrapperList.add(lineItemWrapper3);
        
        WB_UploadTitleGroupItemsController.TitleGroupItemWrapper lineItemWrapper1 = new WB_UploadTitleGroupItemsController.TitleGroupItemWrapper();
        lineItemWrapper1.videoVersionOrMPM = '181800';
        //lineItemWrapper1.isRowRemoved = True;
        lineItemWrapper1.isRowModified = True;
        lineItemWrapper1.existingId = newTitleGItem1.Id;
        lineItemWrapper1.titleGroupItem = newTitleGItem1;
        returnWrapperList.add(lineItemWrapper1);
        
        WB_UploadTitleGroupItemsController.TitleGroupItemWrapper lineItemWrapper2 = new WB_UploadTitleGroupItemsController.TitleGroupItemWrapper();
        lineItemWrapper2.videoVersionOrMPM = '181800';
        lineItemWrapper2.isRowRemoved = True;
       // lineItemWrapper2.isRowModified = True;
        lineItemWrapper2.existingId = newTitleGItem1.Id;
        lineItemWrapper2.titleGroupItem = newTitleGItem1;
        returnWrapperList.add(lineItemWrapper2);
        
        WB_UploadTitleGroupItemsController.saveTitleGroupItems(returnWrapperList,newTitleGroup.Id);
        
        WB_UploadTitleGroupItemsController.queryTitlesOrMPM(returnWrapperList,True,newTitleGroup.Id);
        
        Test.stopTest();
       
    }
	
	@isTest
    public static void testMethodForWB_UploadVVTitleGroup()
    {
        listlocaltitles= new List<Local_Title__c>();
        MPM__c Mpm = new MPM__c();
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646';
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        Account objAccount = TestUtil.createAccount('Apple iTunes');
        objAccount.Customer_Focus__c = 'Active';
        objAccount.Type='Global';
        insert objAccount;
        
        /* -- Title creation-- */
        TestDataUtility tdu = new TestDataUtility(); 
        Title__c t = tdu.createTitle(Mpm);
        
        Country__c Country = New Country__c();
        Country.Name = 'INDIA';
        Country.Country_Code2__c = 'IN';
        Country.Country_Code__c = 'IND';
        Country.Status__c = 'Active';
        insert Country;
        
        Language__c Language = New Language__c();
        Language.Name = 'English';
        Language.Language_Order__c = 1;
        insert Language;
        
        Local_Title__c LT = New Local_Title__c();
        LT.Name = t.Name;
        LT.Title__c = t.Id;
        LT.Country__c = Country.Id;
        LT.Local_Theatrical_Release_Date__c = date.today();
        LT.Language__c = Language.Id;
        LT.Local_TV_Air_Date__c = System.today()+2;
        LT.Price_Code__c = 'CheckPriceCode1';
        insert LT;
        
        Title__c title1 = new Title__c(
            Name = 'DID Season',
            Video_Version__c ='V01235',
            Content_Type__c='Feature',
            Digital_Planning__c='Yes',
            Clear_to_Avail__c = true,
            MPM__c = Mpm.Id,
            Formats__c = 'SD');
            insert title1;

        
        Test.startTest();        
        String vvRecTypeId = WB_PriceUtility.getRecordTypeId(Title_Group__c.getSobjectType(),'Video Version');         
       
        //VV RecordType
        Title_Group__c newTitleGroup1 = new Title_Group__c();
        newTitleGroup1.Group_Name__c = 'Test VV Title Group';
        newTitleGroup1.RecordTypeId = vvRecTypeId;
        insert newTitleGroup1;
        Title_Group_Item__c newTitleGItem1 = new Title_Group_Item__c();
        newTitleGItem1.Title_Group__c = newTitleGroup1.Id;
        newTitleGItem1.Title__c = t.Id;
        insert newTitleGItem1;
        
        WB_UploadTitleGroupItemsController ctrlUploadGroupItem = new WB_UploadTitleGroupItemsController(new ApexPages.StandardController(newTitleGroup1));
        WB_UploadTitleGroupItemsController.getRecordTypeName(newTitleGroup1.Id);
        WB_UploadTitleGroupItemsController.getTitleGroupItems(newTitleGroup1.Id);
        
        WB_UploadTitleGroupItemsController.TitleGroupItemWrapper lineItemWrapper = new WB_UploadTitleGroupItemsController.TitleGroupItemWrapper();
        List< WB_UploadTitleGroupItemsController.TitleGroupItemWrapper> returnWrapperList = new List< WB_UploadTitleGroupItemsController.TitleGroupItemWrapper>();
         lineItemWrapper.videoVersionOrMPM = 'V01235'; 
        lineItemWrapper.isRowModified = True;
        returnWrapperList.add(lineItemWrapper);
        
        WB_UploadTitleGroupItemsController.TitleGroupItemWrapper lineItemWrapper1 = new WB_UploadTitleGroupItemsController.TitleGroupItemWrapper();
        lineItemWrapper1.videoVersionOrMPM = title1.Video_Version__c;
        //lineItemWrapper1.isRowRemoved = True;
        lineItemWrapper1.isRowModified = True;
        lineItemWrapper1.existingId = newTitleGItem1.Id;
        lineItemWrapper1.titleGroupItem = newTitleGItem1;
        returnWrapperList.add(lineItemWrapper1);
        
        WB_UploadTitleGroupItemsController.TitleGroupItemWrapper lineItemWrapper2 = new WB_UploadTitleGroupItemsController.TitleGroupItemWrapper();
        lineItemWrapper2.videoVersionOrMPM = title1.Video_Version__c;
        lineItemWrapper2.isRowRemoved = True;
        lineItemWrapper2.existingId = newTitleGItem1.Id;
        lineItemWrapper2.titleGroupItem = newTitleGItem1;
        returnWrapperList.add(lineItemWrapper2);
        
        WB_UploadTitleGroupItemsController.TitleGroupItemWrapper lineItemWrapper3 = new WB_UploadTitleGroupItemsController.TitleGroupItemWrapper();
        lineItemWrapper3.videoVersionOrMPM = 'V6757'; 
        lineItemWrapper3.isRowModified = True;
        returnWrapperList.add(lineItemWrapper3);
        
        WB_UploadTitleGroupItemsController.saveTitleGroupItems(returnWrapperList,newTitleGroup1.Id);
        WB_UploadTitleGroupItemsController.queryTitlesOrMPM(returnWrapperList,True,newTitleGroup1.Id);
        
        Test.stopTest();
       
    }
	
	@isTest
    public static void testMethodForWB_UploadEEIDRTitleGroup()
    {
        listlocaltitles= new List<Local_Title__c>();
        MPM__c Mpm = new MPM__c();
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646';
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
        
        Account objAccount = TestUtil.createAccount('Apple iTunes');
        objAccount.Customer_Focus__c = 'Active';
        objAccount.Type='Global';
        insert objAccount;
        
        /* -- Title creation-- */
        TestDataUtility tdu = new TestDataUtility(); 
        Title__c t = tdu.createTitle(Mpm);
        
        Country__c Country = New Country__c();
        Country.Name = 'INDIA';
        Country.Country_Code2__c = 'IN';
        Country.Country_Code__c = 'IND';
        Country.Status__c = 'Active';
        insert Country;
        
        Language__c Language = New Language__c();
        Language.Name = 'English';
        Language.Language_Order__c = 1;
        insert Language;
        
        Local_Title__c LT = New Local_Title__c();
        LT.Name = t.Name;
        LT.Title__c = t.Id;
        LT.Country__c = Country.Id;
        LT.Local_Theatrical_Release_Date__c = date.today();
        LT.Language__c = Language.Id;
        LT.Local_TV_Air_Date__c = System.today()+2;
        LT.Price_Code__c = 'CheckPriceCode1';
        LT.Edit_EIDR_2D__c = '1234';
        //LT.Version_EIDR__c = 'EDIT EIDR Check';
        insert LT;
        
        Title__c title1 = new Title__c(
            Name = 'DID Season',
            Video_Version__c ='V01235',
            Content_Type__c='Feature',
            Digital_Planning__c='Yes',
            Clear_to_Avail__c = true,
            MPM__c = Mpm.Id,
            Formats__c = 'SD');
            insert title1;
        
        Test.startTest(); 
        String mpmRecTypeId = WB_PriceUtility.getRecordTypeId(Title_Group__c.getSobjectType(),'MPM'); 
        String vvRecTypeId = WB_PriceUtility.getRecordTypeId(Title_Group__c.getSobjectType(),'Video Version'); 
        String editEIDRRecTypeId = WB_PriceUtility.getRecordTypeId(Title_Group__c.getSobjectType(),'Edit EIDR'); 
        
        //MPM Record Type
        Title_Group__c newTitleGroup = new Title_Group__c();
        newTitleGroup.Group_Name__c = 'Test MPM Title Group';
        newTitleGroup.RecordTypeId = mpmRecTypeId;
        insert newTitleGroup;
        Title_Group_Item__c newTitleGItem = new Title_Group_Item__c();
        newTitleGItem.Title_Group__c = newTitleGroup.Id;
        newTitleGItem.MPM__c = Mpm.Id;
        newTitleGItem.Title__c = t.Id;
        insert newTitleGItem;
        
        //VV RecordType
        Title_Group__c newTitleGroup1 = new Title_Group__c();
        newTitleGroup1.Group_Name__c = 'Test VV Title Group';
        newTitleGroup1.RecordTypeId = vvRecTypeId;
        insert newTitleGroup1;
        Title_Group_Item__c newTitleGItem1 = new Title_Group_Item__c();
        newTitleGItem1.Title_Group__c = newTitleGroup1.Id;
        newTitleGItem1.Title__c = t.Id;
        insert newTitleGItem1;
        
        //EditEIDR RecordType
        Title_Group__c newTitleGroup2 = new Title_Group__c();
        newTitleGroup2.Group_Name__c = 'Test EditEIDR Title Group';
        newTitleGroup2.RecordTypeId = editEIDRRecTypeId;
        insert newTitleGroup2;
        Title_Group_Item__c newTitleGItem2 = new Title_Group_Item__c();
        newTitleGItem2.Title_Group__c = newTitleGroup2.Id;
        newTitleGItem2.Local_Title__c = LT.Id;
        newTitleGItem2.Title__c = t.Id;
        insert newTitleGItem2;
        
        WB_UploadTitleGroupItemsController ctrlUploadGroupItem = new WB_UploadTitleGroupItemsController(new ApexPages.StandardController(newTitleGroup2));
        WB_UploadTitleGroupItemsController.getRecordTypeName(newTitleGroup2.Id);
        WB_UploadTitleGroupItemsController.getTitleGroupItems(newTitleGroup2.Id);
        
        WB_UploadTitleGroupItemsController.TitleGroupItemWrapper lineItemWrapper = new WB_UploadTitleGroupItemsController.TitleGroupItemWrapper();
        List< WB_UploadTitleGroupItemsController.TitleGroupItemWrapper> returnWrapperList = new List< WB_UploadTitleGroupItemsController.TitleGroupItemWrapper>();
        lineItemWrapper.videoVersionOrMPM = '1234'; 
        lineItemWrapper.isRowModified = True;
        returnWrapperList.add(lineItemWrapper);
        
        WB_UploadTitleGroupItemsController.TitleGroupItemWrapper lineItemWrapper3 = new WB_UploadTitleGroupItemsController.TitleGroupItemWrapper();
        lineItemWrapper3.videoVersionOrMPM = '20611111'; 
        lineItemWrapper3.isRowModified = True;
        returnWrapperList.add(lineItemWrapper3);
        
        WB_UploadTitleGroupItemsController.saveTitleGroupItems(returnWrapperList,newTitleGroup2.Id);
        WB_UploadTitleGroupItemsController.queryTitlesOrMPM(returnWrapperList,false,newTitleGroup2.Id);
        
        Test.stopTest();
       
    }

}