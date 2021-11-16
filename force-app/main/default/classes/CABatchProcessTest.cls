/*
Class Name   : CABatchProcessTest 
Description  : This class is to do code coverage for CABatchProcess class    
Created By   : Cognizant Technology Solutions - Rashmi
Created On   : JAN 2015

Change History:
-------------------------------------------------------------------------------------------------------------------------------------
Sr#              Description                                               Updated By                                     Updated On
-------------------------------------------------------------------------------------------------------------------------------------
1              [Change Type]                                 Cognizant Technology Solutions - [Developer Name]           [MM/DD/YYYY]

CH01            Added Assertion statements for the              Akash Dalvi                                               5/23/2016    
                required business scenarios.                           
*/
@isTest
public class CABatchProcessTest
{   //CH01 START
    static testmethod void Positive_testCABatch_1()
    {
        Account a = TestUtil.createAccount('Mera Account');
        insert a;
        
        Language__c  L = TestUtil.createLanguage('English', 'en',1);
        insert L;
        
        Country__c C = TestUtil.createCountry('India', 'IN', 'IN');
        insert C;
        
        Title__c T = TestUtil.createTitle('Mera Title', '123456');
        T.Digital_Planning__c = 'Yes';
        T.Formats__c = 'HD';
        T.Content_Type__c = 'Season';
        T.Clear_to_Avail__c = True;
        insert T;
        
        Local_Title__c LT = TestUtil.createLocalData('123456', C, L, 'IN_en', T.Id);
        LT.Price_Code__c = 'USD';
        insert LT;
        
        Commercial_Avail__c CA = TestUtil.createReleasePlan(T.Id, LT.Id, C.Id, L.Id);
        CA.Channel__c = 'EST';
        CA.Format__c = 'HD';
        CA.Exclusive_Date__c = System.today().addDays(-365);//Avail start date
        CA.Rights_End__c = System.today().addDays(365); //Avail End date
        CA.Start_Date__c = System.today().addDays(-30);
        CA.End_Date__c = System.today().addDays(30);
        CA.Country_Lookup__c = C.Id;
        CA.Local_Title__c = LT.Id;
        CA.Status__c = 'Tentative'; 
        insert CA;
        
        System.AssertEquals(true,CA.id!=null);
        System.Assert(CA.Exclusive_Date__c == System.today().addDays(-365));
        System.Assert(CA.Rights_End__c == System.today().addDays(365)); 
        System.Assert(CA.Start_Date__c == System.today().addDays(-30));
        System.Assert(CA.End_Date__c == System.today().addDays(30));
        System.Assert(CA.Country_Lookup__c == C.Id);
        System.Assert(CA.Local_Title__C==LT.Id);
            
        /*Agreement__c StrFrnt = TestUtil.createStoreFront(a.Id, C.Id);
        StrFrnt.Content_Type__c = T.content_Type__c;
        StrFrnt.Format__c = CA.Format__c;
        StrFrnt.Channel_Picklist__c = CA.Channel__c;
        StrFrnt.Status__c ='Active';
        insert StrFrnt;*/

       /* Pricing__c P = TestUtil.createPricing(a.Id, C.Id, StrFrnt.Id);
        P.Content_Type__c = T.content_Type__c;
        P.Name = LT.Price_Code__c;
        P.Account__c = A.Id;
        P.Country__c = C.Id;
        P.Channel__c = CA.Channel__c;
        P.Format__c = CA.Format__c;
        insert P;*/
       
        list<String> commercialIds = new list<String>();
        commercialIds.add(CA.Id);
        
        list<account> accList = new list<account>();
        accList.add(a);
        System.debug('MYDEBUG CA : ' + CA); 
        String ldKey = T.Video_Version__c+C.Name+L.Name;
        String pwKey = CA.Channel__c+CA.Format__c;
        PageReference pageRef = Page.WB_Create_ClientAvail;
        WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',CA.Id);
        controller.deleteExceptionedRecords();
        if((controller.selectedlocalDataMapWrap.get(ldKey) != NULL) && (controller.selectedPricingMapwrap.get(pwKey) != NULL))
        {
            CABatchProcess BP = new CABatchProcess(commercialIds, accList, controller.obj, 'test String', controller.selectedPricingMapwrap ,controller.selectedlocalDataMapWrap);
            System.AssertEquals(BP!=null,True);
            System.AssertEquals(CA.Id!=null, True);
            System.AssertEquals(a.ID!=null, True);
            Database.executeBatch(BP); 
        }
    
    }
    
    static testmethod void Positive_testCABatch_2()
    {
        Account a = TestUtil.createAccount('Mera Account');
        insert a;
        
        Language__c  L = TestUtil.createLanguage('English', 'en',1);
        insert L;
        
        Country__c C = TestUtil.createCountry('India', 'IN', 'IN');
        insert C;
        
        Title__c T = TestUtil.createTitle('Mera Title', '123456');
        T.Digital_Planning__c = 'Yes';
        T.Formats__c = 'HD';
        T.Content_Type__c = 'Season';
        T.clear_to_Avail__c= true;
        insert T;
        
        Local_Title__c LT = TestUtil.createLocalData('123456', C, L, 'IN_en', T.Id);
        LT.Price_Code__c = 'USD';
        insert LT;
        
        Commercial_Avail__c CA = TestUtil.createReleasePlan(T.Id, LT.Id, C.Id, L.Id);
        CA.Channel__c = 'EST';
        CA.Format__c = 'HD';
        CA.Exclusive_Date__c = System.today().addDays(-365);//Avail start date
        CA.Rights_End__c = System.today().addDays(365); //Avail End date
        CA.Start_Date__c = System.today().addDays(-30);
        CA.End_Date__c = System.today().addDays(30);
        CA.Country_Lookup__c = C.Id;
        CA.Local_Title__c = LT.Id;
        CA.Status__c='Tentative';
        insert CA;
        
        Agreement__c StrFrnt = TestUtil.createStoreFront(a.Id, C.Id);
        StrFrnt.Content_Type__c = T.content_Type__c;
        StrFrnt.Format__c = CA.Format__c;
        StrFrnt.Channel_Picklist__c = CA.Channel__c;
        //StrFrnt.Status__c ='Active';
        insert StrFrnt;

        Pricing__c P = TestUtil.createPricing(a.Id, C.Id, StrFrnt.Id);
        P.Content_Type__c = T.content_Type__c;
        P.Name = LT.Price_Code__c;
        P.Account__c = A.Id;
        P.Country__c = C.Id;
        P.Channel__c = CA.Channel__c;
        P.Format__c = 'SD';
        insert P;
        
        list<String> commercialIds = new list<String>();
        commercialIds.add(CA.Id);
        
        list<account> accList = new list<account>();
        accList.add(a);
        
        client_avail__c client1 = new client_avail__c();
        client1.Commercial_Avail__c = CA.Id;
        client1.Client__c = accList[0].Id;
        client1.Start_Date__c = System.today().addDays(-25);
        client1.End_Date__c = System.today().addDays(25);
        client1.Storefront__c =  StrFrnt.Id;
        insert client1; 
        System.debug('MYDEBUG CA : ' + CA);
        String ldKey = T.Video_Version__c+C.Name+L.Name;
        String pwKey = CA.Channel__c+CA.Format__c;
        PageReference pageRef = Page.WB_Create_ClientAvail;
        WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',CA.Id);
        controller.deleteExceptionedRecords();
        if((controller.selectedlocalDataMapWrap.get(ldKey) != NULL) && (controller.selectedPricingMapwrap.get(pwKey) != NULL))
        {
            CABatchProcess BP = new CABatchProcess(commercialIds, accList, controller.obj, 'test String', controller.selectedPricingMapwrap ,controller.selectedlocalDataMapWrap);
            System.AssertEquals(BP!=null,True);
            System.AssertEquals(CA.Id!=null, True);
            System.AssertEquals(a.Id!=null, True);
            Database.executeBatch(BP);
        }
        
        
    }
    
    static testmethod void Positive_testCABatch_3()
    {
        Account a = TestUtil.createAccount('Mera Account');
        insert a;
        
        Account a1 = TestUtil.createAccount('Mera Account');
        insert a1;
        
        Language__c  L = TestUtil.createLanguage('English', 'en',1);
        insert L;
        
        Country__c C = TestUtil.createCountry('India', 'IN', 'IN');
        insert C;
        
        Country__c C1 = TestUtil.createCountry('USA', 'US', 'US');
        insert C1;
        
        Title__c T = TestUtil.createTitle('Mera Title', '123456');
        T.Digital_Planning__c = 'Yes';
        T.Formats__c = 'HD';
        T.Content_Type__c = 'Season';
        T.Clear_to_Avail__c = True;
        insert T;
        
        Local_Title__c LT = TestUtil.createLocalData('123456', C, L, 'IN_en', T.Id);
        LT.Price_Code__c = 'USD';
        insert LT;
        
        Commercial_Avail__c CA = TestUtil.createReleasePlan(T.Id, LT.Id, C.Id, L.Id);
        CA.Channel__c = 'EST';
        CA.Format__c = 'HD';
        CA.Exclusive_Date__c = System.today().addDays(-365);//Avail start date
        CA.Rights_End__c = System.today().addDays(365); //Avail End date
        CA.Start_Date__c = System.today().addDays(-30);
        CA.End_Date__c = System.today().addDays(30);
        CA.Country_Lookup__c = C.Id;
        CA.Local_Title__c = LT.Id;
        CA.Status__c = 'Tentative';
        insert CA;
        
       /* Agreement__c StrFrnt = TestUtil.createStoreFront(a.Id, C.Id);
        StrFrnt.Content_Type__c = T.content_Type__c;
        StrFrnt.Format__c = CA.Format__c;
        StrFrnt.Channel_Picklist__c = CA.Channel__c;
        StrFrnt.Status__c ='Active';
        insert StrFrnt;*/
        
        Agreement__c StrFrnt1 = TestUtil.createStoreFront(a1.Id, C.Id);
        StrFrnt1.Content_Type__c = T.content_Type__c;
        StrFrnt1.Format__c = CA.Format__c;
        StrFrnt1.Channel_Picklist__c = CA.Channel__c;
        StrFrnt1.Status__c ='Active';
        StrFrnt1.Selected_Combination__c = 'Episode_EST_HD';
        insert StrFrnt1;
        
        Pricing__c P = TestUtil.createPricing(a.Id, C.Id, StrFrnt1.Id);
        P.Content_Type__c = T.content_Type__c;
        P.Name = LT.Price_Code__c;
        P.Account__c = A.Id;
        P.Country__c = C.Id;
        P.Channel__c = CA.Channel__c;
        P.Format__c = CA.Format__c;
        insert P;
        
        list<String> commercialIds = new list<String>();
        commercialIds.add(CA.Id);
        
        list<account> accList = new list<account>();
        accList.add(a);
        accList.add(a1);
        System.debug('MYDEBUG CA : ' + CA);
        String ldKey = T.Video_Version__c+C.Name+L.Name;
        String pwKey = CA.Channel__c+CA.Format__c;
        PageReference pageRef = Page.WB_Create_ClientAvail;
        WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',CA.Id);
        controller.deleteExceptionedRecords();
        if((controller.selectedlocalDataMapWrap.get(ldKey) != NULL) && (controller.selectedPricingMapwrap.get(pwKey) != NULL))
        {
            CABatchProcess BP = new CABatchProcess(commercialIds, accList, controller.obj, 'test String', controller.selectedPricingMapwrap ,controller.selectedlocalDataMapWrap);
            System.AssertEquals(BP!=null,True);
            System.AssertEquals(CA.Id!=null, True);
            System.AssertEquals(a.Id!=null, True);
            Database.executeBatch(BP);
        }
    }
    
    static testmethod void Negative_testCABatch_1()
    {
        Account a = TestUtil.createAccount('Mera Account');
        insert a;
        
        Account a1 = TestUtil.createAccount('Tera Account');
        insert a1;
        
        Language__c  L = TestUtil.createLanguage('English', 'en',1);
        insert L;
        
        Country__c C = TestUtil.createCountry('India', 'IN', 'IN');
        insert C;
        
        Title__c T = TestUtil.createTitle('Mera Title', '123456');
        T.Formats__c = 'HD';
        T.Clear_to_Avail__c = True;
        T.Digital_Planning__c = 'Yes';
        T.Content_Type__c = 'Season';
        insert T;
        
        Local_Title__c LT = TestUtil.createLocalData('123456', C, L, 'IN_en', T.Id);
        LT.Price_Code__c = 'USD';
        insert LT;
        
        Commercial_Avail__c CA = TestUtil.createReleasePlan(T.Id, LT.Id, C.Id, L.Id);
        CA.Channel__c = 'EST';
        CA.Format__c = 'HD';
        CA.Exclusive_Date__c = System.today().addDays(-365);//Avail start date
        CA.Rights_End__c = System.today().addDays(365); //Avail End date
        CA.Start_Date__c = System.today().addDays(-30);
        CA.End_Date__c = System.today().addDays(30);
        CA.Country_Lookup__c = C.Id;
        CA.Local_Title__c = LT.Id;
        CA.Status__c='Tentative';   
        insert CA;
        
        Agreement__c StrFrnt1 = TestUtil.createStoreFront(a1.Id, C.Id);
        StrFrnt1.Content_Type__c = T.content_Type__c;
        StrFrnt1.Format__c = CA.Format__c;
        StrFrnt1.Channel_Picklist__c = CA.Channel__c;
        StrFrnt1.Status__c ='Expired';
        insert StrFrnt1;
        
        Pricing__c P = TestUtil.createPricing(a.Id, C.Id, StrFrnt1.Id);
        P.Content_Type__c = T.content_Type__c;
        P.Name = LT.Price_Code__c;
        P.Account__c = A.Id;
        P.Country__c = C.Id;
        P.Channel__c = CA.Channel__c;
        P.Format__c = CA.Format__c;
        insert P;
        
        list<String> commercialIds = new list<String>();
        commercialIds.add(CA.Id);
        
        list<account> accList = new list<account>();
        accList.add(a);
        accList.add(a1);
        
        System.debug('MYDEBUG CA : ' + CA);
        String ldKey = T.Video_Version__c+C.Name+L.Name;
        String pwKey = CA.Channel__c+CA.Format__c;
        PageReference pageRef = Page.WB_Create_ClientAvail;
        WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',CA.Id);
        controller.deleteExceptionedRecords();
        if((controller.selectedlocalDataMapWrap.get(ldKey) != NULL) && (controller.selectedPricingMapwrap.get(pwKey) != NULL))
        {
            CABatchProcess BP = new CABatchProcess(commercialIds, accList, controller.obj, 'test String', controller.selectedPricingMapwrap ,controller.selectedlocalDataMapWrap);
            System.AssertEquals(BP!=null,True);
            System.AssertEquals(CA.Id!=null, True);
            System.AssertEquals(a.Id!=null, True);
            Database.executeBatch(BP);
        }
        
 
   }
   static testmethod void Positive_testCABatch_5()
   {
        Account a = TestUtil.createAccount('Mera Account');
        insert a;
        
        Account a1 = TestUtil.createAccount('Mera Account');
        insert a1;
        
        Language__c  L = TestUtil.createLanguage('English', 'en',1);
        insert L;
        
        Country__c C = TestUtil.createCountry('India', 'IN', 'IN');
        insert C;
        
        Country__c C1 = TestUtil.createCountry('USA', 'US', 'US');
        insert C1;
        
        Title__c T = TestUtil.createTitle('Mera Title', '123456');
        T.Digital_Planning__c = 'Yes';
       	T.Formats__c = 'HD';
        T.Content_Type__c = 'Season';
        T.Clear_to_Avail__c = True;
        insert T;
        
        Local_Title__c LT = TestUtil.createLocalData('123456', C, L, 'IN_en', T.Id);
        LT.Price_Code__c = 'USD';
        insert LT;
        
        Commercial_Avail__c CA = TestUtil.createReleasePlan(T.Id, LT.Id, C.Id, L.Id);
        CA.Channel__c = 'EST';
        CA.Format__c = 'HD';
        CA.Exclusive_Date__c = System.today().addDays(-365);//Avail start date
        CA.Rights_End__c = System.today().addDays(365); //Avail End date
        CA.Start_Date__c = System.today().addDays(-30);
        CA.End_Date__c = System.today().addDays(30);
        CA.Country_Lookup__c = C.Id;
        CA.Local_Title__c = LT.Id;
        CA.Status__c='Tentative'; 
        insert CA;
        
        Agreement__c StrFrnt = TestUtil.createStoreFront(a.Id, C.Id);
        StrFrnt.Content_Type__c ='Episode';
        StrFrnt.Format__c = 'SD';
        StrFrnt.Channel_Picklist__c = CA.Channel__c;
        StrFrnt.Status__c ='Active';
        insert StrFrnt;
        
        Agreement__c StrFrnt1 = TestUtil.createStoreFront(a1.Id, C1.Id);
        //StrFrnt1.Content_Type__c ='Episode';
        //StrFrnt1.Format__c = 'SD';
        StrFrnt1.Channel_Picklist__c = CA.Channel__c;
        StrFrnt1.Status__c ='Active';
        insert StrFrnt1;

        Pricing__c P = TestUtil.createPricing(a.Id, C.Id, StrFrnt.Id);
        P.Content_Type__c = T.content_Type__c;
        P.Name = LT.Price_Code__c;
        P.Account__c = A.Id;
        P.Country__c = C.Id;
        P.Channel__c = CA.Channel__c;
        P.Format__c = 'SD';
        insert P;
        
        list<String> commercialIds = new list<String>();
        commercialIds.add(CA.Id);
        
        list<account> accList = new list<account>();
        accList.add(a);
        
        System.debug('MYDEBUG CA : ' + CA);
        String ldKey = T.Video_Version__c+C.Name+L.Name;
        String pwKey = CA.Channel__c+CA.Format__c;
        PageReference pageRef = Page.WB_Create_ClientAvail;
        WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',CA.Id);
        controller.deleteExceptionedRecords();
        if((controller.selectedlocalDataMapWrap.get(ldKey) != NULL) && (controller.selectedPricingMapwrap.get(pwKey) != NULL))
        {
            CABatchProcess BP = new CABatchProcess(commercialIds, accList, controller.obj, 'test String', controller.selectedPricingMapwrap ,controller.selectedlocalDataMapWrap);
            System.AssertEquals(BP!=null,True);
            System.AssertEquals(CA.Id!=null, True);
            System.AssertEquals(a.Id!=null, True);
            Database.executeBatch(BP);
        }
    }
    /*static testmethod void Positive_testCABatch_6()
   {
        Account a = TestUtil.createAccount('Mera Account');
        insert a;
        
        Language__c  L = TestUtil.createLanguage('English', 'en',1);
        insert L;
        
        Country__c C = TestUtil.createCountry('India', 'IN', 'IN');
        insert C;
        
        Title__c T = TestUtil.createTitle('Mera Title', '123456');
        T.Digital_Planning__c = 'Yes';
       //	T.Formats__c = 'HD';
        T.Content_Type__c = 'Season';
        T.Clear_to_Avail__c = True;
        insert T;
        
        Local_Title__c LT = TestUtil.createLocalData('123456', C, L, 'IN_en', T.Id);
        LT.Price_Code__c = 'USD';
        insert LT;
        
        Commercial_Avail__c CA = TestUtil.createReleasePlan(T.Id, LT.Id, C.Id, L.Id);
        CA.Channel__c = 'EST';
        CA.Format__c = 'SD';
        CA.Exclusive_Date__c = System.today().addDays(-365);//Avail start date
        CA.Rights_End__c = System.today().addDays(365); //Avail End date
        CA.Start_Date__c = System.today().addDays(-30);
        CA.End_Date__c = System.today().addDays(30);
        CA.Country_Lookup__c = C.Id;
        CA.Local_Title__c = LT.Id;
        CA.Status__c='Tentative'; 
        insert CA;
        
        Agreement__c StrFrnt1 = TestUtil.createStoreFront(a.Id, C.Id);
        //StrFrnt1.Content_Type__c ='Episode';
        //StrFrnt1.Format__c = 'SD';
        StrFrnt1.Channel_Picklist__c = CA.Channel__c;
        StrFrnt1.Status__c ='Active';
        insert StrFrnt1;

        Pricing__c P = TestUtil.createPricing(a.Id, C.Id, StrFrnt1.Id);
        P.Content_Type__c = T.content_Type__c;
        P.Name = LT.Price_Code__c;
        P.Account__c = A.Id;
        P.Country__c = C.Id;
        P.Channel__c = CA.Channel__c;
        P.Format__c = 'SD';
        insert P;
        
        list<String> commercialIds = new list<String>();
        commercialIds.add(CA.Id);
        
        list<account> accList = new list<account>();
        accList.add(a);
        
        System.debug('MYDEBUG CA : ' + CA);
        String ldKey = T.Video_Version__c+C.Name+L.Name;
        String pwKey = CA.Channel__c+CA.Format__c;
        PageReference pageRef = Page.WB_Create_ClientAvail;
        WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',CA.Id);
        controller.deleteExceptionedRecords();
        System.debug('++++Printing Local Data Wrapper'+controller.selectedlocalDataMapWrap);
        System.debug('++++Printing Pricing Wrapper'+controller.selectedPricingMapwrap);
        if((controller.selectedlocalDataMapWrap.get(ldKey) != NULL) && (controller.selectedPricingMapwrap.get(pwKey) != NULL))
        {
            CABatchProcess BP = new CABatchProcess(commercialIds, accList, controller.obj, 'test String', controller.selectedPricingMapwrap ,controller.selectedlocalDataMapWrap);
            System.AssertEquals(BP!=null,True);
            System.AssertEquals(CA.Id!=null, True);
            System.AssertEquals(a.Id!=null, True);
            Database.executeBatch(BP);
        }
    }*/
      /*static testmethod void Positive_testCABatch_7()
      {
        Account a = TestUtil.createAccount('Mera Account');
        insert a;
        
        Language__c  L = TestUtil.createLanguage('English', 'en',1);
        insert L;
        
        Country__c C = TestUtil.createCountry('India', 'IN', 'IN');
        insert C;
        
        Title__c T = TestUtil.createTitle('Mera Title', '123456');
        T.Digital_Planning__c = 'Yes';
        T.Formats__c = 'HD';
        T.Content_Type__c = 'Season';
        T.Clear_to_Avail__c = false;
        insert T;
        
        Local_Title__c LT = TestUtil.createLocalData('123456', C, L, 'IN_en', T.Id);
        LT.Price_Code__c = 'USD';
        insert LT;
        
        Commercial_Avail__c CA = TestUtil.createReleasePlan(T.Id, LT.Id, C.Id, L.Id);
        CA.Channel__c = 'VODi';
        CA.Format__c = 'HD';
        CA.Exclusive_Date__c = System.today().addDays(-365);//Avail start date
        CA.Rights_End__c = System.today().addDays(365); //Avail End date
        CA.Start_Date__c = System.today().addDays(-30);
        CA.End_Date__c = System.today().addDays(30);
        CA.Country_Lookup__c = C.Id;
        CA.Local_Title__c = LT.Id;
        insert CA;
        
        Agreement__c StrFrnt = TestUtil.createStoreFront(a.Id, C.Id);
        StrFrnt.Content_Type__c = T.content_Type__c;
        StrFrnt.Format__c = CA.Format__c;
        StrFrnt.Channel_Picklist__c = 'EST;HD';
        StrFrnt.Status__c ='Active';
        insert StrFrnt;

        Pricing__c P = TestUtil.createPricing(a.Id, C.Id, StrFrnt.Id);
        P.Content_Type__c = T.content_Type__c;
        P.Name = LT.Price_Code__c;
        P.Account__c = A.Id;
        P.Country__c = C.Id;
        P.Channel__c = CA.Channel__c;
        P.Format__c = 'SD';
        insert P;
        
        list<String> commercialIds = new list<String>();
        commercialIds.add(CA.Id);
        
        list<account> accList = new list<account>();
        accList.add(a);
        
        System.debug('MYDEBUG CA : ' + CA);
        CABatchProcess BP = new CABatchProcess(commercialIds, accList, 'Draft', 'Initial Release', '1',System.today());
        System.AssertEquals(BP!=null,True);
        System.AssertEquals(CA.Id!=null, True);
        System.AssertEquals(a.Id!=null, True);
        Database.executeBatch(BP);
    }*/
    @isTest
    public static void coverageWithNewParameters(){
        
        Account a = TestUtil.createAccount('Mera Account');
        insert a;
        
        Language__c  L = TestUtil.createLanguage('English', 'en',1);
        insert L;
        
        Country__c C = TestUtil.createCountry('India', 'IN', 'IN');
        insert C;
        
        Title__c T = TestUtil.createTitle('Mera Title', '123456');
        T.Digital_Planning__c = 'Yes';
        T.Formats__c = 'HD';
        T.Content_Type__c = 'Season';
        T.Clear_to_Avail__c = True;
        insert T;
        
        Local_Title__c LT = TestUtil.createLocalData('123456', C, L, 'IN_en', T.Id);
        LT.Price_Code__c = 'USD';
        insert LT;
        
        Commercial_Avail__c CA = TestUtil.createReleasePlan(T.Id, LT.Id, C.Id, L.Id);
        CA.Channel__c = 'EST';
        CA.Format__c = 'HD';
        CA.Exclusive_Date__c = System.today().addDays(-365);//Avail start date
        CA.Rights_End__c = System.today().addDays(365); //Avail End date
        CA.Start_Date__c = System.today().addDays(-30);
        CA.End_Date__c = System.today().addDays(30);
        CA.Country_Lookup__c = C.Id;
        CA.Local_Title__c = LT.Id;
        CA.Status__c = 'Tentative'; 
        insert CA;
        
        System.AssertEquals(true,CA.id!=null);
        System.Assert(CA.Exclusive_Date__c == System.today().addDays(-365));
        System.Assert(CA.Rights_End__c == System.today().addDays(365)); 
        System.Assert(CA.Start_Date__c == System.today().addDays(-30));
        System.Assert(CA.End_Date__c == System.today().addDays(30));
        System.Assert(CA.Country_Lookup__c == C.Id);
        System.Assert(CA.Local_Title__C==LT.Id);
            
        Agreement__c StrFrnt = TestUtil.createStoreFront(a.Id, C.Id);
        StrFrnt.Content_Type__c = T.content_Type__c;
        StrFrnt.Format__c = CA.Format__c;
        StrFrnt.Channel_Picklist__c = CA.Channel__c;
        StrFrnt.Status__c ='Active';
        StrFrnt.CRM_Storefront__c = True;
        insert StrFrnt;

        Pricing__c P = TestUtil.createPricing(a.Id, C.Id, StrFrnt.Id);
        P.Content_Type__c = T.content_Type__c;
        P.Name = LT.Price_Code__c;
        P.Account__c = A.Id;
        P.Country__c = C.Id;
        P.Channel__c = CA.Channel__c;
        P.Format__c = CA.Format__c;
        p.Price_Tier__c = '100';
        insert P;
        
        Rate_Card__c rc = new Rate_Card__c();
            rc.Channel__c = CA.Channel__c;
            rc.Country__c = C.Id;
            rc.Account__c = a.Id;
            rc.Start_Date__c = System.today().addDays(-30);
            rc.End_Date__c = System.today().addDays(30);
            rc.Content_Type__c = T.Content_Type__c;
            rc.Format__c = CA.Format__c;
            rc.Price_Tier__c = '100';
        insert rc;
            
        
        list<String> commercialIds = new list<String>();
        commercialIds.add(CA.Id);
        
        list<account> accList = new list<account>();
        accList.add(a);
        System.debug('MYDEBUG CA : ' + CA);
        String ldKey = T.Video_Version__c+C.Name+L.Name;
        String pwKey = CA.Channel__c+CA.Format__c;
        PageReference pageRef = Page.WB_Create_ClientAvail;
        WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', CA.Id);
        controller.deleteExceptionedRecords();
        
       
        if((controller.selectedlocalDataMapWrap.get(ldKey) != NULL) && (controller.selectedPricingMapwrap.get(pwKey) != NULL))
        {
            CABatchProcess BP = new CABatchProcess(commercialIds, accList, controller.obj, 'test String', controller.selectedPricingMapwrap ,controller.selectedlocalDataMapWrap);
            
            System.AssertEquals(BP!=null,True);
            System.AssertEquals(CA.Id!=null, True);
            System.AssertEquals(a.ID!=null, True);
            Database.executeBatch(BP);   
        }
    }
    //CH01 END

    static testmethod void sf_method()
    {
        Account a = TestUtil.createAccount('Mera Account');
        insert a;
        
        Language__c  L = TestUtil.createLanguage('English', 'en',1);
        insert L;
        
        Country__c C = TestUtil.createCountry('India', 'IN', 'IN');
        insert C;
        
        Title__c T = TestUtil.createTitle('Mera Title', '123456');
        T.Digital_Planning__c = 'Yes';
        T.Formats__c = 'HD';
        T.Content_Type__c = 'Season';
        T.clear_to_Avail__c= true;
        insert T;
		
		List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=L.Id ,Language_Types__c='Sub',Title__c=T.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=L.Id ,Language_Types__c='Audio',Title__c=T.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle2);
        insert listAvailLang;
        
        List<Language_Preference__c> langPrefList = new List<Language_Preference__c>();
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=C.Id,Type__c = 'Country',Language__c=L.Id,Level__c='1');
        langPrefList.add(langPrefTest);
        
        insert langPrefList;
        
        Local_Title__c LT = TestUtil.createLocalData('123456', C, L, 'IN_en', T.Id);
        LT.Price_Code__c = 'USD';
        insert LT;
        
        Commercial_Avail__c CA = TestUtil.createReleasePlan(T.Id, LT.Id, C.Id, L.Id);
        CA.Channel__c = 'EST';
        CA.Format__c = 'HD';
        CA.Exclusive_Date__c = System.today().addDays(-365);//Avail start date
        CA.Rights_End__c = System.today().addDays(365); //Avail End date
        CA.Start_Date__c = System.today().addDays(-30);
        CA.End_Date__c = System.today().addDays(30);
        CA.Country_Lookup__c = C.Id;
        CA.Local_Title__c = LT.Id;
        CA.Status__c='Tentative';
        insert CA;
        
        Agreement__c StrFrnt = TestUtil.createStoreFront(a.Id, C.Id);
        StrFrnt.Content_Type__c = T.content_Type__c;
        StrFrnt.Format__c = CA.Format__c;
        StrFrnt.Channel_Picklist__c = CA.Channel__c;
        //StrFrnt.Status__c ='Active';
        insert StrFrnt;
		
		List<Language_Preference__c> langPrefListTypeSF = new List<Language_Preference__c>();
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=C.Id,Type__c = 'Storefront',Language__c=L.Id,Level__c='1',Account__c = a.Id,Storefront__c=StrFrnt.Id);
        langPrefListTypeSF.add(langPrefTest1);
        
        insert langPrefListTypeSF;

        Pricing__c P = TestUtil.createPricing(a.Id, C.Id, StrFrnt.Id);
        P.Content_Type__c = T.content_Type__c;
        P.Name = LT.Price_Code__c;
        P.Account__c = A.Id;
        P.Country__c = C.Id;
        P.Channel__c = CA.Channel__c;
        P.Format__c = 'SD';
        insert P;
        
        list<String> commercialIds = new list<String>();
        commercialIds.add(CA.Id);
        
        list<account> accList = new list<account>();
        accList.add(a);
        
        client_avail__c client1 = new client_avail__c();
        client1.Commercial_Avail__c = CA.Id;
        client1.Client__c = accList[0].Id;
        client1.Start_Date__c = System.today().addDays(-25);
        client1.End_Date__c = System.today().addDays(25);
        client1.Storefront__c =  StrFrnt.Id;
        insert client1; 
        System.debug('MYDEBUG CA : ' + CA);
        String ldKey = T.Video_Version__c+C.Name+L.Name;
        String pwKey = CA.Channel__c+CA.Format__c;
        PageReference pageRef = Page.WB_Create_ClientAvail;
        WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',CA.Id);
        controller.deleteExceptionedRecords();
        if((controller.selectedlocalDataMapWrap.get(ldKey) != NULL) && (controller.selectedPricingMapwrap.get(pwKey) != NULL))
        {
            CABatchProcess BP = new CABatchProcess(commercialIds, accList, controller.obj, 'test String', controller.selectedPricingMapwrap ,controller.selectedlocalDataMapWrap);
            System.AssertEquals(BP!=null,True);
            System.AssertEquals(CA.Id!=null, True);
            System.AssertEquals(a.Id!=null, True);
            Database.executeBatch(BP);
        }
        
        
    }

    static testmethod void nosf_method()
    {
        Account a = TestUtil.createAccount('Apple iTunes');
        insert a;
        
        /*Language__c  L = TestUtil.createLanguage('English', 'en',1);
        insert L;*/
		
		List<Language__c> langList = new List<Language__c>();
        Language__c languageFrench = new Language__c(Name='French',Language_Order__c = 1,Language_Code_2__c='fr');
        langList.add(languageFrench);
		
		Language__c languageEnglish = new Language__c(Name='English',Language_Order__c = 1,Language_Code_2__c='en');
        langList.add(languageEnglish);
		
		Language__c languageSpanish = new Language__c(Name='Spanish',Language_Order__c = 1,Language_Code_2__c='sp');
        langList.add(languageSpanish);
		
		insert langList;
        
        Country__c C = TestUtil.createCountry('India', 'IN', 'IN');
        insert C;
        
        Title__c T = TestUtil.createTitle('Mera Title', '123456');
        T.Digital_Planning__c = 'Yes';
        T.Formats__c = 'HD';
        T.Content_Type__c = 'Season';
        T.clear_to_Avail__c= true;
        insert T;
		
		List<Available_Languages__c> listAvailLang = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=langList[0].Id ,Language_Types__c='Sub',Title__c=T.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle1);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=langList[0].Id ,Language_Types__c='Audio',Title__c=T.Id,Clear_To_Avail__c=true);
        listAvailLang.add(availLangTitle2);
        insert listAvailLang;
        
        List<Language_Preference__c> langPrefList = new List<Language_Preference__c>();
        Language_Preference__c langPrefTest= new Language_Preference__c(Country__c=C.Id,Type__c = 'Country',Language__c=langList[0].Id,Level__c='1');
        langPrefList.add(langPrefTest);
        
        insert langPrefList;
        
        Local_Title__c LT = TestUtil.createLocalData('123456', C, langList[0], 'IN_en', T.Id);
        LT.Price_Code__c = 'USD';
        insert LT;
        
        Commercial_Avail__c CA = TestUtil.createReleasePlan(T.Id, LT.Id, C.Id, langList[0].Id);
        CA.Channel__c = 'EST';
        CA.Format__c = 'HD';
        CA.Exclusive_Date__c = System.today().addDays(-365);//Avail start date
        CA.Rights_End__c = System.today().addDays(365); //Avail End date
        CA.Start_Date__c = System.today().addDays(-30);
        CA.End_Date__c = System.today().addDays(30);
        CA.Country_Lookup__c = C.Id;
        CA.Local_Title__c = LT.Id;
        CA.Status__c='Tentative';
        insert CA;
        
        Agreement__c StrFrnt = TestUtil.createStoreFront(a.Id, C.Id);
        StrFrnt.Content_Type__c = T.content_Type__c;
        StrFrnt.Format__c = CA.Format__c;
        StrFrnt.Channel_Picklist__c = CA.Channel__c;
        //StrFrnt.Status__c ='Active';
        insert StrFrnt;
		
		List<Language_Preference__c> langPrefListTypeSF = new List<Language_Preference__c>();
        Language_Preference__c langPrefTest3= new Language_Preference__c(Country__c=C.Id,Type__c = 'Storefront',Language__c=langList[2].Id,Level__c='1',Account__c = a.Id,Storefront__c=StrFrnt.Id);
        langPrefListTypeSF.add(langPrefTest3);
		
		Language_Preference__c langPrefTest2= new Language_Preference__c(Country__c=C.Id,Type__c = 'Storefront',Language__c=langList[1].Id,Level__c='0',Account__c = a.Id,Storefront__c=StrFrnt.Id);
        langPrefListTypeSF.add(langPrefTest2);
        
        insert langPrefListTypeSF;

        Pricing__c P = TestUtil.createPricing(a.Id, C.Id, StrFrnt.Id);
        P.Content_Type__c = T.content_Type__c;
        P.Name = LT.Price_Code__c;
        P.Account__c = A.Id;
        P.Country__c = C.Id;
        P.Channel__c = CA.Channel__c;
        P.Format__c = 'SD';
        insert P;
        
        list<String> commercialIds = new list<String>();
        commercialIds.add(CA.Id);
        
        list<account> accList = new list<account>();
        accList.add(a);
        
        client_avail__c client1 = new client_avail__c();
        client1.Commercial_Avail__c = CA.Id;
        client1.Client__c = accList[0].Id;
        client1.Start_Date__c = System.today().addDays(-25);
        client1.End_Date__c = System.today().addDays(25);
        client1.Storefront__c =  StrFrnt.Id;
        insert client1; 
        System.debug('MYDEBUG CA : ' + CA);
        String ldKey = T.Video_Version__c+C.Name+langList[0].Name;
        String pwKey = CA.Channel__c+CA.Format__c;
        PageReference pageRef = Page.WB_Create_ClientAvail;
        WB_CreateClientAvail_Controller controller = new WB_CreateClientAvail_Controller();
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',CA.Id);
        controller.deleteExceptionedRecords();
        if((controller.selectedlocalDataMapWrap.get(ldKey) != NULL) && (controller.selectedPricingMapwrap.get(pwKey) != NULL))
        {
            CABatchProcess BP = new CABatchProcess(commercialIds, accList, controller.obj, 'test String', controller.selectedPricingMapwrap ,controller.selectedlocalDataMapWrap);
            System.AssertEquals(BP!=null,True);
            System.AssertEquals(CA.Id!=null, True);
            System.AssertEquals(a.Id!=null, True);
            Database.executeBatch(BP);
        }
        
        
    }
}