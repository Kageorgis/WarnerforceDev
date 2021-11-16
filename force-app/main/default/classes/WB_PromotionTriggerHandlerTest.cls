@isTest
public class WB_PromotionTriggerHandlerTest {

    private static testMethod void updatePromotionOwnerTest(){
        //insert Account
        Id rtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(system.label.AccRecordType).getRecordTypeId();
        Account objAccount1 = new Account(Name='TestAccount1',Customer_Focus__c='Active', recordtypeId = rtypeId);
        objAccount1.Type='Global';
        insert objAccount1;
        
        //insert Country
        Country__c Country_1 = New Country__c();
        Country_1.Name = 'India';
        Country_1.Country_Code2__c = 'IN';
        Country_1.Country_Code__c = 'IND';
        Country_1.Status__c = 'Active';
        Country_1.TV_Day_After_US_Offset__c = 2;
        Country_1.TV_Day_After_Local_Offset__c = 1;
        insert Country_1;
        
        //insert Promotion
        Promotion__c promo = new Promotion__c(Name='TestPromotion',Start_Date__c=date.today(), End_Date__c=date.today()+100,Account_Multipicklist__c='TestAccount1',Country__c='India');
        insert promo;
        
        promo.Country__c = null;
        update promo;
        System.assertEquals(null, [SELECT Id,Country__c FROM Promotion__c LIMIT 1].Country__c);
        promo.Country__c = 'India';
        update promo;
        System.assertEquals(1, [SELECT Count() FROM Promotion__c]);
    }
    
    private static testMethod void updatePromotionOwnerCustomSettingTest(){
        //insert Account
        Id rtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(system.label.AccRecordType).getRecordTypeId();
        Account objAccount1 = new Account(Name='TestAccount1',Customer_Focus__c='Active', recordtypeId = rtypeId);
        objAccount1.Type='Global';
        insert objAccount1;
        
        //insert Country
        Country__c Country_1 = New Country__c();
        Country_1.Name = 'India';
        Country_1.Country_Code2__c = 'IN';
        Country_1.Country_Code__c = 'IND';
        Country_1.Status__c = 'Active';
        Country_1.TV_Day_After_US_Offset__c = 2;
        Country_1.TV_Day_After_Local_Offset__c = 1;
        Country_1.HBO_Override__c = 'EMEALicenseeQ';
        Country_1.Turner_Override__c = 'EMEALicenseeQ';
        insert Country_1;
        
        //insert Promotion
        Promotion__c promo = new Promotion__c(Name='TestPromotion',Start_Date__c=date.today(), End_Date__c=date.today()+100,Account_Multipicklist__c='TestAccount1');
        insert promo;
        
        //Insert Custom Setting Records WB_HBO_TURNER_Countries__c
        WB_HBO_TURNER_Countries__c recCount = new WB_HBO_TURNER_Countries__c(Name = 'India');
        insert recCount;
        //Insert Custom Setting Records WB_HBO_TURNER_Accounts__c
        WB_HBO_TURNER_Accounts__c recAcc = new WB_HBO_TURNER_Accounts__c(Name = 'HBO_Override__c', Studio_Names__c = 'HBO');
        insert recAcc;
        recAcc = new WB_HBO_TURNER_Accounts__c(Name = 'Turner_Override__c', Studio_Names__c = 'Warner Bros.');
        insert recAcc;
        //Insert Custom Setting Records WB_Queue_Id__c
        WB_Queue_Id__c queueRec = new WB_Queue_Id__c(Name = 'EMEALicenseeQ', Value__c = [SELECT Id FROM Group WHERE Name = 'EMEALicenseeQ'].Id);
        insert queueRec;

		//Data Creation Start
        MPM__c mpmRec = new MPM__c(); 
        mpmRec.Name = '2063646';
        mpmRec.MPM_Number__c = '2063646'; 
        mpmRec.Film_Color__c = 'Color';
        insert mpmRec;

        Title__c t1 = new Title__c();
        t1.Name = 'Test Season';
        t1.Digital_Planning__c = 'Yes';
        t1.Clear_to_Avail__c = true;
        t1.Content_Type__c = 'Season';
        t1.Video_Version__c = '999999999';
        t1.MPM__c = mpmRec.id;
        t1.US_TV_Air_Date__c = system.today();
        t1.Formats__c = 'SD;HD';
        t1.DisplayStudio__c = 'Warner Bros.';
        Insert t1;
        
        Language__c lanRec = new Language__c();
        lanRec.Name = 'English';
        lanRec.Language_Code_2__c = 'en';
        lanRec.Language_Code_3__c = 'ENG';
        lanRec.EMA_Store_Language__c  = 'en';
        lanRec.Language_Order__c  = 1;
        insert lanRec;
        
        Local_Title__c localTitleRec = new Local_Title__c();
        localTitleRec.Title__c = t1.Id;
        localTitleRec.Country__c = Country_1.Id;
        localTitleRec.Language__c = lanRec.Id;
        insert localTitleRec;
        
        //Data Creation END
        
        WB_UploadPromotionTitlesController controller = new WB_UploadPromotionTitlesController();
        
        //No Data inserted in PT
        WB_UploadPromotionTitlesController.FilterWrapper filterWrapperObj= new WB_UploadPromotionTitlesController.FilterWrapper();
        filterWrapperObj.channel = new  List<CRM_DataObjects.PicklistOption>();
        filterWrapperObj.format = new  List<CRM_DataObjects.PicklistOption>();
        filterWrapperObj.vvText = new  List<String>();
        System.assertEquals(0,WB_UploadPromotionTitlesController.getPromotionTitleRecords(promo.Id,filterWrapperObj).size());
        
        List<WB_UploadPromotionTitlesController.PromotionTitleWrapper> lstPTW = new List<WB_UploadPromotionTitlesController.PromotionTitleWrapper>();
        WB_UploadPromotionTitlesController.PromotionTitleWrapper ptwObj;
        List<WB_UploadPromotionTitlesController.PromotionTitleWrapper> returnLstPTW = new List<WB_UploadPromotionTitlesController.PromotionTitleWrapper>();
        
        //Data With Playlist Content Entry and PT Records
         ptwObj = new WB_UploadPromotionTitlesController.PromotionTitleWrapper();
        ptwObj.videoVersion = '999999999';
        ptwObj.channel = 'EST';
        ptwObj.format = 'SD';
        ptwObj.WSP = 5;
        ptwObj.wspCurrency = 'AED';
        ptwObj.isRowModified = true;
        lstPTW.add(ptwObj);
        
        returnLstPTW = WB_UploadPromotionTitlesController.savePromotionTitleRecords(lstPTW,promo.Id);
        
        System.assertEquals(1,returnLstPTW.size());
        System.assertEquals(1,WB_UploadPromotionTitlesController.getPromotionTitleRecords(promo.Id,filterWrapperObj).size());//assert
        
        //Promotion Assert
        promo.Country__c = 'India';
        update promo;
        System.assertEquals(1, [SELECT Count() FROM Promotion__c]);
    }
    
    private static testMethod void updatePromotionOwnerCustomSettingTest1(){
        //insert Account
        Id rtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(system.label.AccRecordType).getRecordTypeId();
        Account objAccount1 = new Account(Name='TestAccount1',Customer_Focus__c='Active', recordtypeId = rtypeId);
        objAccount1.Type='Global';
        insert objAccount1;
        
        //insert Country
        Country__c Country_1 = New Country__c();
        Country_1.Name = 'India';
        Country_1.Country_Code2__c = 'IN';
        Country_1.Country_Code__c = 'IND';
        Country_1.Status__c = 'Active';
        Country_1.TV_Day_After_US_Offset__c = 2;
        Country_1.TV_Day_After_Local_Offset__c = 1;
        Country_1.HBO_Override__c = 'EMEALicenseeQ';
        Country_1.Turner_Override__c = 'EMEALicenseeQ';
        insert Country_1;
        
        //insert Promotion
        Promotion__c promo = new Promotion__c(Name='TestPromotion',Start_Date__c=date.today(), End_Date__c=date.today()+100,Account_Multipicklist__c='TestAccount1');
        insert promo;
        
        //Insert Custom Setting Records WB_HBO_TURNER_Countries__c
        WB_HBO_TURNER_Countries__c recCount = new WB_HBO_TURNER_Countries__c(Name = 'India');
        insert recCount;
        //Insert Custom Setting Records WB_HBO_TURNER_Accounts__c
        WB_HBO_TURNER_Accounts__c recAcc = new WB_HBO_TURNER_Accounts__c(Name = 'HBO_Override__c', Studio_Names__c = 'HBO');
        insert recAcc;
        recAcc = new WB_HBO_TURNER_Accounts__c(Name = 'Turner_Override__c', Studio_Names__c = 'Warner Bros.');
        insert recAcc;
        //Insert Custom Setting Records WB_Queue_Id__c
        WB_Queue_Id__c queueRec = new WB_Queue_Id__c(Name = 'EMEALicenseeQ', Value__c = [SELECT Id FROM Group WHERE Name = 'EMEALicenseeQ'].Id);
        insert queueRec;

		//Data Creation Start
        MPM__c mpmRec = new MPM__c(); 
        mpmRec.Name = '2063646';
        mpmRec.MPM_Number__c = '2063646'; 
        mpmRec.Film_Color__c = 'Color';
        insert mpmRec;

        Title__c t1 = new Title__c();
        t1.Name = 'Test Season';
        t1.Digital_Planning__c = 'Yes';
        t1.Clear_to_Avail__c = true;
        t1.Content_Type__c = 'Season';
        t1.Video_Version__c = '999999999';
        t1.MPM__c = mpmRec.id;
        t1.US_TV_Air_Date__c = system.today();
        t1.Formats__c = 'SD;HD';
        t1.DisplayStudio__c = 'HBO';
        Insert t1;
        
        Language__c lanRec = new Language__c();
        lanRec.Name = 'English';
        lanRec.Language_Code_2__c = 'en';
        lanRec.Language_Code_3__c = 'ENG';
        lanRec.EMA_Store_Language__c  = 'en';
        lanRec.Language_Order__c  = 1;
        insert lanRec;
        
        Local_Title__c localTitleRec = new Local_Title__c();
        localTitleRec.Title__c = t1.Id;
        localTitleRec.Country__c = Country_1.Id;
        localTitleRec.Language__c = lanRec.Id;
        insert localTitleRec;
        
        //Data Creation END
        
        WB_UploadPromotionTitlesController controller = new WB_UploadPromotionTitlesController();
        
        //No Data inserted in PT
        WB_UploadPromotionTitlesController.FilterWrapper filterWrapperObj= new WB_UploadPromotionTitlesController.FilterWrapper();
        filterWrapperObj.channel = new  List<CRM_DataObjects.PicklistOption>();
        filterWrapperObj.format = new  List<CRM_DataObjects.PicklistOption>();
        filterWrapperObj.vvText = new  List<String>();
        System.assertEquals(0,WB_UploadPromotionTitlesController.getPromotionTitleRecords(promo.Id,filterWrapperObj).size());
        
        List<WB_UploadPromotionTitlesController.PromotionTitleWrapper> lstPTW = new List<WB_UploadPromotionTitlesController.PromotionTitleWrapper>();
        WB_UploadPromotionTitlesController.PromotionTitleWrapper ptwObj;
        List<WB_UploadPromotionTitlesController.PromotionTitleWrapper> returnLstPTW = new List<WB_UploadPromotionTitlesController.PromotionTitleWrapper>();
        
        //Data With Playlist Content Entry and PT Records
         ptwObj = new WB_UploadPromotionTitlesController.PromotionTitleWrapper();
        ptwObj.videoVersion = '999999999';
        ptwObj.channel = 'EST';
        ptwObj.format = 'SD';
        ptwObj.WSP = 5;
        ptwObj.wspCurrency = 'AED';
        ptwObj.isRowModified = true;
        lstPTW.add(ptwObj);
        
        returnLstPTW = WB_UploadPromotionTitlesController.savePromotionTitleRecords(lstPTW,promo.Id);
        
        System.assertEquals(1,returnLstPTW.size());
        System.assertEquals(1,WB_UploadPromotionTitlesController.getPromotionTitleRecords(promo.Id,filterWrapperObj).size());//assert
        
        //Promotion Assert
        promo.Country__c = 'India';
        update promo;
        System.assertEquals(1, [SELECT Count() FROM Promotion__c]);
    }
    
    private static testMethod void updatePromotionOwnerCustomSettingTest2(){
        //insert Account
        Id rtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(system.label.AccRecordType).getRecordTypeId();
        Account objAccount1 = new Account(Name='TestAccount1',Customer_Focus__c='Active', recordtypeId = rtypeId);
        objAccount1.Type='Global';
        insert objAccount1;
        
        //insert Country
        Country__c Country_1 = New Country__c();
        Country_1.Name = 'India';
        Country_1.Country_Code2__c = 'IN';
        Country_1.Country_Code__c = 'IND';
        Country_1.Status__c = 'Active';
        Country_1.TV_Day_After_US_Offset__c = 2;
        Country_1.TV_Day_After_Local_Offset__c = 1;
        Country_1.HBO_Override__c = 'EMEALicenseeQ';
        Country_1.Turner_Override__c = 'EMEALicenseeQ';
        insert Country_1;
        
        //insert Promotion
        Promotion__c promo = new Promotion__c(Name='TestPromotion',Start_Date__c=date.today(), End_Date__c=date.today()+100,Account_Multipicklist__c='TestAccount1');
        insert promo;
        
        //Insert Custom Setting Records WB_HBO_TURNER_Countries__c
        WB_HBO_TURNER_Countries__c recCount = new WB_HBO_TURNER_Countries__c(Name = 'India');
        insert recCount;
        //Insert Custom Setting Records WB_HBO_TURNER_Accounts__c
        WB_HBO_TURNER_Accounts__c recAcc = new WB_HBO_TURNER_Accounts__c(Name = 'HBO_Override__c', Studio_Names__c = 'HBO');
        insert recAcc;
        recAcc = new WB_HBO_TURNER_Accounts__c(Name = 'Turner_Override__c', Studio_Names__c = 'Warner Bros.');
        insert recAcc;
        //Insert Custom Setting Records WB_Queue_Id__c
        WB_Queue_Id__c queueRec = new WB_Queue_Id__c(Name = 'EMEALicenseeQ', Value__c = [SELECT Id FROM Group WHERE Name = 'EMEALicenseeQ'].Id);
        insert queueRec;

		//Data Creation Start
        MPM__c mpmRec = new MPM__c(); 
        mpmRec.Name = '2063646';
        mpmRec.MPM_Number__c = '2063646'; 
        mpmRec.Film_Color__c = 'Color';
        insert mpmRec;

        Title__c t1 = new Title__c();
        t1.Name = 'Test Season';
        t1.Digital_Planning__c = 'Yes';
        t1.Clear_to_Avail__c = true;
        t1.Content_Type__c = 'Season';
        t1.Video_Version__c = '999999999';
        t1.MPM__c = mpmRec.id;
        t1.US_TV_Air_Date__c = system.today();
        t1.Formats__c = 'SD;HD';
        t1.DisplayStudio__c = 'Turner';
        Insert t1;
        
        Language__c lanRec = new Language__c();
        lanRec.Name = 'English';
        lanRec.Language_Code_2__c = 'en';
        lanRec.Language_Code_3__c = 'ENG';
        lanRec.EMA_Store_Language__c  = 'en';
        lanRec.Language_Order__c  = 1;
        insert lanRec;
        
        Local_Title__c localTitleRec = new Local_Title__c();
        localTitleRec.Title__c = t1.Id;
        localTitleRec.Country__c = Country_1.Id;
        localTitleRec.Language__c = lanRec.Id;
        insert localTitleRec;
        
        //Data Creation END
        
        WB_UploadPromotionTitlesController controller = new WB_UploadPromotionTitlesController();
        
        //No Data inserted in PT
        WB_UploadPromotionTitlesController.FilterWrapper filterWrapperObj= new WB_UploadPromotionTitlesController.FilterWrapper();
        filterWrapperObj.channel = new  List<CRM_DataObjects.PicklistOption>();
        filterWrapperObj.format = new  List<CRM_DataObjects.PicklistOption>();
        filterWrapperObj.vvText = new  List<String>();
        System.assertEquals(0,WB_UploadPromotionTitlesController.getPromotionTitleRecords(promo.Id,filterWrapperObj).size());
        
        List<WB_UploadPromotionTitlesController.PromotionTitleWrapper> lstPTW = new List<WB_UploadPromotionTitlesController.PromotionTitleWrapper>();
        WB_UploadPromotionTitlesController.PromotionTitleWrapper ptwObj;
        List<WB_UploadPromotionTitlesController.PromotionTitleWrapper> returnLstPTW = new List<WB_UploadPromotionTitlesController.PromotionTitleWrapper>();
        
        //Data With Playlist Content Entry and PT Records
         ptwObj = new WB_UploadPromotionTitlesController.PromotionTitleWrapper();
        ptwObj.videoVersion = '999999999';
        ptwObj.channel = 'EST';
        ptwObj.format = 'SD';
        ptwObj.WSP = 5;
        ptwObj.wspCurrency = 'AED';
        ptwObj.isRowModified = true;
        lstPTW.add(ptwObj);
        
        returnLstPTW = WB_UploadPromotionTitlesController.savePromotionTitleRecords(lstPTW,promo.Id);
        
        System.assertEquals(1,returnLstPTW.size());
        System.assertEquals(1,WB_UploadPromotionTitlesController.getPromotionTitleRecords(promo.Id,filterWrapperObj).size());//assert
        
        //Promotion Assert
        promo.Country__c = 'India';
        update promo;
        System.assertEquals(1, [SELECT Count() FROM Promotion__c]);
    }
}