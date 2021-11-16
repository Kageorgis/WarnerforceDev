@isTest(SeeAllData=false)
public class WB_Batch_CAP_PublishToClientUpdateTest{
   
    public static List<Local_Title__c> listlocaltitles;
    static List<Pricing__c> lPricing = new List<Pricing__c>();
    public static List<Client_Avail__c> listClientavails;
    static List<Local_Title__c> lTitle = new List<Local_Title__c>();
    static List<Commercial_Avail__c> cAvailList = new List<Commercial_Avail__c>();
    static List<Agreement__c> agreementList = new List<Agreement__c>();
    static List<Client_Avail__c> clAvailList = new List<Client_Avail__c>();
    static List<Client_Avail_Price__c> clAvailPriceList = new List<Client_Avail_Price__c>();
    static List<Country_SID_Key__c> countrySIDList = new List<Country_SID_Key__c>();
    static List<String> selectedClientAvailIds = new List<String>();
    static Integer count=3; 
    
   @isTest
    public static void testMethodForWB_compare2()
    {
      try{                 /* -- MPM creation-- */
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
        
        Pricing__c pricing1 = new Pricing__c();
        pricing1.Name = 'CheckPriceCode1';
        pricing1.Account__c = objAccount.id;
        pricing1.Country__c = Country.id;
        pricing1.Channel__c='EST';
        pricing1.Content_Type__c='Feature';       
        pricing1.Price_Tier__c ='reprice1';
        //pricing2.Episode_Price_Tier__c='test1';
        pricing1.Format__c='SD';
        lPricing.add(pricing1);
        
        Pricing__c pricing2 = new Pricing__c();
        pricing2.Name = 'CheckPriceCode';
        pricing2.Account__c = objAccount.id;
        pricing2.Country__c = Country.id;
        pricing2.Channel__c='EST';
        pricing2.Content_Type__c='Feature';       
        pricing2.Price_Tier__c ='reprice2';
        //pricing2.Episode_Price_Tier__c='test1';
        pricing2.Format__c='SD';
        lPricing.add(pricing2);
        
        Pricing__c pricing3 = new Pricing__c();
        pricing3.Name = 'CheckPriceCode3';
        pricing3.Account__c = objAccount.id;
        pricing3.Country__c = Country.id;
        pricing3.Channel__c='VODi';
        pricing3.Content_Type__c='Feature';       
        pricing3.Price_Tier__c ='reprice3';
        //pricing2.Episode_Price_Tier__c='test1';
        pricing3.Format__c='SD';
        lPricing.add(pricing3);
        
        Pricing__c pricing4 = new Pricing__c();
        pricing4.Name = 'CheckPriceCode4';
        pricing4.Account__c = objAccount.id;
        pricing4.Country__c = Country.id;
        pricing4.Channel__c='VODi';
        pricing4.Content_Type__c='Feature';       
        pricing4.Price_Tier__c ='reprice4';
        //pricing2.Episode_Price_Tier__c='test1';
        pricing4.Format__c='SD';
        lPricing.add(pricing4);
        
        insert lPricing;
        
        Local_Title__c LT = New Local_Title__c();
        LT.Name = t.Name;
        LT.Title__c = t.Id;
        LT.Country__c = Country.Id;
        LT.Local_Theatrical_Release_Date__c = date.today();
        LT.Language__c = Language.Id;
        LT.Local_TV_Air_Date__c = System.today()+2;
        LT.Price_Code__c = 'CheckPriceCode1';
        //LT.Playlist__C = playlist.id;
        listlocaltitles.add(LT);
        insert listlocaltitles;
        
        List<Commercial_Avail__c> listReleaseplan = new List<Commercial_Avail__c>();
        Commercial_Avail__c releasePlan1 = new Commercial_Avail__c();
        releasePlan1.Channel__c = 'EST';
        releasePlan1.APO__c = 'Yes';
        releasePlan1.Local_Title__c = listlocaltitles[0].id;
        releasePlan1.Title__c=t.id;
        releasePlan1.Languages__c = Language.id;
        releasePlan1.Country_Lookup__c = Country.id;
        releasePlan1.Format__c = 'SD';
        releasePlan1.Language_Type__c = 'Sub & Audio';
        releasePlan1.Exclusive_Date__c = date.today()-200;
        releasePlan1.Start_Date__c = date.today()+10;
        releasePlan1.End_Date__c = date.today()+80;
        releasePlan1.Rights_End__c=date.today()+200;
        releasePlan1.Status__c = 'Confirmed';
        listReleaseplan.add(releasePlan1);
        
        Commercial_Avail__c releasePlan2 = new Commercial_Avail__c();
        releasePlan2.Channel__c = 'VODi';
        releasePlan2.APO__c = 'Yes';
        releasePlan2.Local_Title__c = listlocaltitles[0].id;
        releasePlan2.Title__c=t.id;
        releasePlan2.Languages__c = Language.id;
        releasePlan2.Country_Lookup__c = Country.id;
        releasePlan2.Format__c = 'SD';
        releasePlan2.Language_Type__c = 'Sub & Audio';
        releasePlan2.Exclusive_Date__c = date.today()-200;
        releasePlan2.Start_Date__c = date.today()+5;
        releasePlan2.End_Date__c = date.today()+80;
        releasePlan2.Rights_End__c=date.today()+200;
        releasePlan2.Status__c = 'Confirmed';
        listReleaseplan.add(releasePlan2);
        
        Commercial_Avail__c releasePlan3 = new Commercial_Avail__c();
        releasePlan3.Channel__c = 'Hotel';
        releasePlan3.APO__c = 'Yes';
        releasePlan3.Local_Title__c = listlocaltitles[0].id;
        releasePlan3.Title__c=t.id;
        releasePlan3.Languages__c = Language.id;
        releasePlan3.Country_Lookup__c = Country.id;
        releasePlan3.Format__c = 'SD';
        releasePlan3.Language_Type__c = 'Sub & Audio';
        releasePlan3.Exclusive_Date__c = date.today()-200;
        releasePlan3.Start_Date__c = date.today()+10;
        releasePlan3.End_Date__c = date.today()+80;
        releasePlan3.Rights_End__c=date.today()+200;
        releasePlan3.Status__c = 'Confirmed';
        listReleaseplan.add(releasePlan3);
        
        insert listReleaseplan;
         
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(objAccount.Id, country.Id, releasePlan1, t);
        insert storefrontGoogle1;
        storefrontGoogle1.APO__c = 'Yes';
        
        update storefrontGoogle1;
        
        test.startTest();
        Country_SID_Key__c createRPC = new Country_SID_Key__c();
        createRPC.Name = 'INDIA';
        createRPC.Country_Code__c = 'IND';
        createRPC.Region__c = 'Asia Pacific';
        createRPC.Locale_SID_Key__c = 'Asia/Kolkata';
        createRPC.Country_Code2_c__c = 'IN';
        createRPC.isPublishToClient__c = True;
        insert createRPC;
        
        WB_Pricing_Settings__c pricingFlag = new WB_Pricing_Settings__c();
        pricingFlag.Name = 'Publish to Client';
        pricingFlag.IsPublishToClient__c = True;
        insert pricingFlag;
        
        listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[0], listlocaltitles[0].Id);
        //clientAvail.Playlist__c = playlist.id;
        clientAvail.Local_Title__c = listlocaltitles[0].id;
        clientAvail.APO__c = 'Yes';
        clientAvail.Status__c = 'Confirmed';
        clientAvail.Price_Tier_Text__c = 'reprice1';
        clientAvail.Storefront__c = storefrontGoogle1.Id;
        clientAvail.Local_Data_Category_Picklist__c = 'TV Day After Local';
        listClientavails.add(clientAvail);
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[1], listlocaltitles[0].Id);
        clientAvail1.Local_Title__c = listlocaltitles[0].id;
        clientAvail1.APO__c = 'Yes';
        clientAvail1.Status__c = 'Confirmed';
        clientAvail1.Price_Tier_Text__c = 'reprice3';
        clientAvail1.Storefront__c = storefrontGoogle1.Id;
        clientAvail1.Local_Data_Category_Picklist__c = 'TV Day After Local';
        listClientavails.add(clientAvail1);
        
        Client_Avail__c clientAvail2 = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[2], listlocaltitles[0].Id);
        clientAvail2.Local_Title__c = listlocaltitles[0].id;
        clientAvail2.APO__c = 'Yes';
        clientAvail2.Status__c = 'Draft';
        clientAvail2.Price_Tier_Text__c = 'reprice3';
        clientAvail2.Storefront__c = storefrontGoogle1.Id;
        clientAvail2.Local_Data_Category_Picklist__c = 'TV Day After Local';
        listClientavails.add(clientAvail2);
        
        WB_ClientAvailPriceHandler.recursiveInsert = True;
        insert listClientavails;
        List<Client_Avail_Price__c> clAvailPriceList1 = new List<Client_Avail_Price__c>();
        clAvailPriceList1 = [SELECT Id,Client_Avail_Status__c,Title_Content_Type__c,RecordTypeId,Episode_Price_Tier__c,Episode_Price__c,Price_Code__c,Price_Tier__c,Price__c,Type__c,Category__c,Client_Avail__r.Status__c,Country__c,Account__c,Publish_to_Client__c,Effective_Date__c,Client_Avail_Channel__c,CAP_Lifecycle__c FROM Client_Avail_Price__c ];
        system.debug('clAvailPriceList1 size:'+clAvailPriceList1.size());
        for(Client_Avail_Price__c ccap1 : clAvailPriceList1 ){
            system.debug('CAP:'+ccap1);  
        }
         //Insert Client Avail Pricing for CA
        List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
	   String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
	   Client_Avail_Price__c cap1 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=listClientavails[0].id,Category__c='Catalog',Effective_Date__c=listClientavails[0].Start_Date__c,Expiry_Date__c=listClientavails[0].Start_Date__c.addDays(2),Price_Tier__c='reprice1');
       Client_Avail_Price__c cap2 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=listClientavails[0].id,Category__c='Catalog',Effective_Date__c=listClientavails[0].Start_Date__c.addDays(3),Expiry_Date__c=listClientavails[0].End_Date__c,Price_Tier__c='reprice2',Type__c='Reprice');
	   Client_Avail_Price__c cap3 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=listClientavails[1].id,Category__c='Catalog',Effective_Date__c=listClientavails[1].Start_Date__c,Expiry_Date__c=listClientavails[1].Start_Date__c.addDays(2),Price_Tier__c='reprice3');
       Client_Avail_Price__c cap4 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=listClientavails[1].id,Category__c='Catalog',Effective_Date__c=listClientavails[1].Start_Date__c.addDays(3),Expiry_Date__c=listClientavails[1].End_Date__c,Price_Tier__c='reprice4',Type__c='Reprice');
	   Client_Avail_Price__c cap5 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Publish_to_Client__c= '',Client_Avail__c=listClientavails[2].id,Category__c='Catalog',Effective_Date__c=listClientavails[2].Start_Date__c,Expiry_Date__c=listClientavails[2].Start_Date__c.addDays(2));
       //Client_Avail_Price__c cap6 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=listClientavails[2].id,Category__c='Catalog',Effective_Date__c=listClientavails[2].Start_Date__c.addDays(3),Expiry_Date__c=listClientavails[2].End_Date__c,Price_Tier__c='reprice4',Type__c='Reprice');
	   capList.add(cap1);
	   capList.add(cap2);
       capList.add(cap3);
       capList.add(cap4);
       capList.add(cap5);
       //capList.add(cap6);
	   
	   WB_ClientAvailPriceHandler.recursiveInsert = false;
        Database.SaveResult[] insertResultList = Database.insert(capList,false);
        for(Integer index=0;index<insertResultList.size();index++){
            Database.SaveResult insertResult = insertResultList[index]; 
            if(!insertResult.isSuccess()){
                for(Database.Error err : insertResult.getErrors()) {
                    System.debug(LoggingLevel.INFO,'insertResult Error ->'+ err.getMessage());
                }
            }
        }
        system.debug('Before listClientavails[0].Status__c'+ listClientavails[0].Status__c);
        listClientavails[0].Status__c = 'Confirmed';
        WB_ClientAvailPriceHandler.recursiveUpdate = False;
        update listClientavails;
        capList[4].Price_Code__c = null;
        capList[4].Publish_to_Client__c = null;
        //update capList[4];
        clAvailPriceList = [SELECT Id,Client_Avail_Status__c,Title_Content_Type__c,RecordTypeId,Episode_Price_Tier__c,Episode_Price__c,Price_Code__c,Price_Tier__c,Price__c,Type__c,Category__c,Client_Avail__r.Status__c,Country__c,Account__c,Publish_to_Client__c,Effective_Date__c,Client_Avail_Channel__c,CAP_Lifecycle__c FROM Client_Avail_Price__c ];
        
        WB_ClientAvailPriceHandler clientAvailPriceHandler = new WB_ClientAvailPriceHandler();
        clientAvailPriceHandler.populatePrice(clAvailPriceList);
        
        try{
          WB_Batch_CAP_PublishToClientUpdate batchClass = new WB_Batch_CAP_PublishToClientUpdate('PublishToClient Scheduler');
          Database.executeBatch(batchClass,10);
          Map<Id,String> caErrorMap = new Map<Id,String>();
          caErrorMap.put(capList[4].Id,'Please check CAP Dates');
          WB_Batch_CAP_PublishToClientUpdate.createErrorLog(capList,caErrorMap);
        }catch(Exception ex){
          
        }
        Test.stopTest();
        
      }catch(Exception ex){
                    system.debug(LoggingLevel.INFO,'Exception:'+ex);
                }
    }
    
    
    
    @isTest
    public static void testMethodForWB_compare1()
    {
      try{                 /* -- MPM creation-- */
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
        
        Pricing__c pricing1 = new Pricing__c();
        pricing1.Name = 'CheckPriceCode1';
        pricing1.Account__c = objAccount.id;
        pricing1.Country__c = Country.id;
        pricing1.Channel__c='EST';
        pricing1.Content_Type__c='Feature';       
        pricing1.Price_Tier__c ='reprice1';
        //pricing2.Episode_Price_Tier__c='test1';
        pricing1.Format__c='SD';
        lPricing.add(pricing1);
        
        Pricing__c pricing2 = new Pricing__c();
        pricing2.Name = 'CheckPriceCode';
        pricing2.Account__c = objAccount.id;
        pricing2.Country__c = Country.id;
        pricing2.Channel__c='EST';
        pricing2.Content_Type__c='Feature';       
        pricing2.Price_Tier__c ='reprice2';
        //pricing2.Episode_Price_Tier__c='test1';
        pricing2.Format__c='SD';
        lPricing.add(pricing2);
        
        Pricing__c pricing3 = new Pricing__c();
        pricing3.Name = 'CheckPriceCode3';
        pricing3.Account__c = objAccount.id;
        pricing3.Country__c = Country.id;
        pricing3.Channel__c='VODi';
        pricing3.Content_Type__c='Feature';       
        pricing3.Price_Tier__c ='reprice3';
        //pricing2.Episode_Price_Tier__c='test1';
        pricing3.Format__c='SD';
        lPricing.add(pricing3);
        
        Pricing__c pricing4 = new Pricing__c();
        pricing4.Name = 'CheckPriceCode4';
        pricing4.Account__c = objAccount.id;
        pricing4.Country__c = Country.id;
        pricing4.Channel__c='VODi';
        pricing4.Content_Type__c='Feature';       
        pricing4.Price_Tier__c ='reprice4';
        //pricing2.Episode_Price_Tier__c='test1';
        pricing4.Format__c='SD';
        lPricing.add(pricing4);
        
        insert lPricing;
        
        Local_Title__c LT = New Local_Title__c();
        LT.Name = t.Name;
        LT.Title__c = t.Id;
        LT.Country__c = Country.Id;
        LT.Local_Theatrical_Release_Date__c = date.today();
        LT.Language__c = Language.Id;
        LT.Local_TV_Air_Date__c = System.today()+2;
        LT.Price_Code__c = 'CheckPriceCode1';
        //LT.Playlist__C = playlist.id;
        listlocaltitles.add(LT);
        insert listlocaltitles;
        
        List<Commercial_Avail__c> listReleaseplan = new List<Commercial_Avail__c>();
        Commercial_Avail__c releasePlan4 = new Commercial_Avail__c();
        releasePlan4.Channel__c = 'EST';
        releasePlan4.APO__c = 'Yes';
        releasePlan4.Local_Title__c = listlocaltitles[0].id;
        releasePlan4.Title__c=t.id;
        releasePlan4.Languages__c = Language.id;
        releasePlan4.Country_Lookup__c = Country.id;
        releasePlan4.Format__c = 'SD';
        releasePlan4.Language_Type__c = 'Sub & Audio';
        releasePlan4.Exclusive_Date__c = date.today()-100;
        releasePlan4.Start_Date__c = date.today()-100;
        releasePlan4.End_Date__c = date.today();
        releasePlan4.Rights_End__c=date.today();
        releasePlan4.Status__c = 'Confirmed';
        listReleaseplan.add(releasePlan4);
        
        /*Commercial_Avail__c releasePlan5 = new Commercial_Avail__c();
        releasePlan5.Channel__c = 'EST';
        releasePlan5.APO__c = 'Yes';
        releasePlan5.Local_Title__c = listlocaltitles[0].id;
        releasePlan5.Title__c=t.id;
        releasePlan5.Languages__c = Language.id;
        releasePlan5.Country_Lookup__c = Country.id;
        releasePlan5.Format__c = 'SD';
        releasePlan5.Language_Type__c = 'Sub & Audio';
        releasePlan5.Exclusive_Date__c = date.today()+2;
        releasePlan5.Start_Date__c = date.today()+2;
        releasePlan5.End_Date__c = date.today()+10;
        releasePlan5.Rights_End__c=date.today()+10;
        releasePlan5.Status__c = 'Confirmed';
        listReleaseplan.add(releasePlan5);*/
        
        Commercial_Avail__c releasePlan1 = new Commercial_Avail__c();
        releasePlan1.Channel__c = 'EST';
        releasePlan1.APO__c = 'Yes';
        releasePlan1.Local_Title__c = listlocaltitles[0].id;
        releasePlan1.Title__c=t.id;
        releasePlan1.Languages__c = Language.id;
        releasePlan1.Country_Lookup__c = Country.id;
        releasePlan1.Format__c = 'SD';
        releasePlan1.Language_Type__c = 'Sub & Audio';
        releasePlan1.Exclusive_Date__c = date.today()-200;
        releasePlan1.Start_Date__c = date.today()+10;
        releasePlan1.End_Date__c = date.today()+80;
        releasePlan1.Rights_End__c=date.today()+200;
        releasePlan1.Status__c = 'Confirmed';
        listReleaseplan.add(releasePlan1);
        
        
        
        Commercial_Avail__c releasePlan2 = new Commercial_Avail__c();
        releasePlan2.Channel__c = 'VODi';
        releasePlan2.APO__c = 'Yes';
        releasePlan2.Local_Title__c = listlocaltitles[0].id;
        releasePlan2.Title__c=t.id;
        releasePlan2.Languages__c = Language.id;
        releasePlan2.Country_Lookup__c = Country.id;
        releasePlan2.Format__c = 'SD';
        releasePlan2.Language_Type__c = 'Sub & Audio';
        releasePlan2.Exclusive_Date__c = date.today()-200;
        releasePlan2.Start_Date__c = date.today()+5;
        releasePlan2.End_Date__c = date.today()+80;
        releasePlan2.Rights_End__c=date.today()+200;
        releasePlan2.Status__c = 'Confirmed';
        listReleaseplan.add(releasePlan2);
        
        Commercial_Avail__c releasePlan3 = new Commercial_Avail__c();
        releasePlan3.Channel__c = 'Hotel';
        releasePlan3.APO__c = 'Yes';
        releasePlan3.Local_Title__c = listlocaltitles[0].id;
        releasePlan3.Title__c=t.id;
        releasePlan3.Languages__c = Language.id;
        releasePlan3.Country_Lookup__c = Country.id;
        releasePlan3.Format__c = 'SD';
        releasePlan3.Language_Type__c = 'Sub & Audio';
        releasePlan3.Exclusive_Date__c = date.today()-200;
        releasePlan3.Start_Date__c = date.today()+10;
        releasePlan3.End_Date__c = date.today()+80;
        releasePlan3.Rights_End__c=date.today()+200;
        releasePlan3.Status__c = 'Confirmed';
        listReleaseplan.add(releasePlan3);
        
        /*Commercial_Avail__c releasePlan5 = new Commercial_Avail__c();
        releasePlan5.Channel__c = 'EST';
        releasePlan5.APO__c = 'Yes';
        releasePlan5.Local_Title__c = listlocaltitles[0].id;
        releasePlan5.Title__c=t.id;
        releasePlan5.Languages__c = Language.id;
        releasePlan5.Country_Lookup__c = Country.id;
        releasePlan5.Format__c = 'SD';
        releasePlan5.Language_Type__c = 'Sub & Audio';
        releasePlan5.Exclusive_Date__c = date.today()+2;
        releasePlan5.Start_Date__c = date.today()+2;
        releasePlan5.End_Date__c = date.today()+10;
        releasePlan5.Rights_End__c=date.today()+10;
        releasePlan5.Status__c = 'Confirmed';
        listReleaseplan.add(releasePlan5);*/
        
        insert listReleaseplan;
         
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(objAccount.Id, country.Id, releasePlan1, t);
        insert storefrontGoogle1;
        storefrontGoogle1.APO__c = 'Yes';
        
        update storefrontGoogle1;
        
        test.startTest();
        Country_SID_Key__c createRPC = new Country_SID_Key__c();
        createRPC.Name = 'INDIA';
        createRPC.Country_Code__c = 'IND';
        createRPC.Region__c = 'Asia Pacific';
        createRPC.Locale_SID_Key__c = 'Asia/Kolkata';
        createRPC.Country_Code2_c__c = 'IN';
        createRPC.isPublishToClient__c = True;
        insert createRPC;
        
        WB_Pricing_Settings__c pricingFlag = new WB_Pricing_Settings__c();
        pricingFlag.Name = 'Publish to Client';
        pricingFlag.IsPublishToClient__c = True;
        insert pricingFlag;
        
        listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[0], listlocaltitles[0].Id);
        //clientAvail.Playlist__c = playlist.id;
        clientAvail.Local_Title__c = listlocaltitles[0].id;
        clientAvail.APO__c = 'Yes';
        clientAvail.Status__c = 'Confirmed';
        clientAvail.Price_Tier_Text__c = 'reprice1';
        clientAvail.Storefront__c = storefrontGoogle1.Id;
        clientAvail.Local_Data_Category_Picklist__c = 'TV Day After Local';
        listClientavails.add(clientAvail);
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[1], listlocaltitles[0].Id);
        clientAvail1.Local_Title__c = listlocaltitles[0].id;
        clientAvail1.APO__c = 'Yes';
        clientAvail1.Status__c = 'Confirmed';
        clientAvail1.Price_Tier_Text__c = 'reprice3';
        clientAvail1.Storefront__c = storefrontGoogle1.Id;
        clientAvail1.Local_Data_Category_Picklist__c = 'TV Day After Local';
        listClientavails.add(clientAvail1);
        
        Client_Avail__c clientAvail2 = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[2], listlocaltitles[0].Id);
        clientAvail2.Local_Title__c = listlocaltitles[0].id;
        clientAvail2.APO__c = 'Yes';
        clientAvail2.Status__c = 'Draft';
        clientAvail2.Price_Tier_Text__c = 'reprice3';
        clientAvail2.Storefront__c = storefrontGoogle1.Id;
        clientAvail2.Local_Data_Category_Picklist__c = 'TV Day After Local';
        listClientavails.add(clientAvail2);
        
        WB_ClientAvailPriceHandler.recursiveInsert = True;
        insert listClientavails;
        /*List<Client_Avail_Price__c> clAvailPriceList1 = new List<Client_Avail_Price__c>();
        clAvailPriceList1 = [SELECT Id,Client_Avail_Status__c,Title_Content_Type__c,RecordTypeId,Episode_Price_Tier__c,Episode_Price__c,Price_Code__c,Price_Tier__c,Price__c,Type__c,Category__c,Client_Avail__r.Status__c,Country__c,Account__c,Publish_to_Client__c,Effective_Date__c,Client_Avail_Channel__c,CAP_Lifecycle__c FROM Client_Avail_Price__c ];
        system.debug('clAvailPriceList1 size:'+clAvailPriceList1.size());
        for(Client_Avail_Price__c ccap1 : clAvailPriceList1 )*/
         //Insert Client Avail Pricing for CA
        List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
	   String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
	   Client_Avail_Price__c cap1 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=listClientavails[0].id,Category__c='Theatrical New Release',Effective_Date__c=listClientavails[0].Start_Date__c,Expiry_Date__c=listClientavails[0].Start_Date__c.addDays(2),Price_Tier__c='reprice1');
       Client_Avail_Price__c cap2 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=listClientavails[0].id,Category__c='Catalog',Effective_Date__c=listClientavails[0].Start_Date__c.addDays(3),Expiry_Date__c=listClientavails[0].End_Date__c,Price_Tier__c='reprice2',Type__c='Reprice');
	   Client_Avail_Price__c cap3 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=listClientavails[1].id,Category__c='Catalog',Effective_Date__c=listClientavails[1].Start_Date__c,Expiry_Date__c=listClientavails[1].Start_Date__c.addDays(2),Price_Tier__c='reprice3');
       Client_Avail_Price__c cap4 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=listClientavails[1].id,Category__c='Catalog',Effective_Date__c=listClientavails[1].Start_Date__c.addDays(3),Expiry_Date__c=listClientavails[1].End_Date__c,Price_Tier__c='reprice4',Type__c='Reprice');
	   Client_Avail_Price__c cap5 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Publish_to_Client__c= null,Client_Avail__c=listClientavails[2].id,Category__c='Catalog',Effective_Date__c=listClientavails[2].Start_Date__c,Expiry_Date__c=listClientavails[2].Start_Date__c.addDays(2));
       //Client_Avail_Price__c cap6 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=listClientavails[2].id,Category__c='Catalog',Effective_Date__c=listClientavails[2].Start_Date__c.addDays(3),Expiry_Date__c=listClientavails[2].End_Date__c,Price_Tier__c='reprice4',Type__c='Reprice');
	   capList.add(cap1);
	   capList.add(cap2);
       capList.add(cap3);
       capList.add(cap4);
       capList.add(cap5);
       //capList.add(cap6);
	   
	   WB_ClientAvailPriceHandler.recursiveInsert = false;
        Database.SaveResult[] insertResultList = Database.insert(capList,false);
        for(Integer index=0;index<insertResultList.size();index++){
            Database.SaveResult insertResult = insertResultList[index]; 
            if(!insertResult.isSuccess()){
                for(Database.Error err : insertResult.getErrors()) {
                    System.debug(LoggingLevel.INFO,'insertResult Error ->'+ err.getMessage());
                }
            }
        }
        system.debug('Before listClientavails[0].Status__c'+ listClientavails[0].Status__c);
        listClientavails[0].Status__c = 'Confirmed';
        WB_ClientAvailPriceHandler.recursiveUpdate = False;
        update listClientavails;
        capList[4].Price_Code__c = null;
        capList[4].Publish_to_Client__c = null;
        //update capList[4];
        clAvailPriceList = [SELECT Id,Client_Avail_Status__c,Title_Content_Type__c,RecordTypeId,Episode_Price_Tier__c,Episode_Price__c,Price_Code__c,Price_Tier__c,Price__c,Type__c,Category__c,Client_Avail__r.Status__c,Country__c,Account__c,Publish_to_Client__c,Effective_Date__c,Client_Avail_Channel__c,CAP_Lifecycle__c FROM Client_Avail_Price__c ];
        
        WB_ClientAvailPriceHandler clientAvailPriceHandler = new WB_ClientAvailPriceHandler();
        clientAvailPriceHandler.populatePrice(clAvailPriceList);
        
        try{
          WB_Batch_CAP_PublishToClientUpdate batchClass = new WB_Batch_CAP_PublishToClientUpdate('PublishToClient Scheduler');
          Database.executeBatch(batchClass,10);
          WB_PriceUtility.setReturnToWindowFlag(listReleaseplan, listClientavails);
         
        }catch(Exception ex){
          
        }
        Test.stopTest();
        
      }catch(Exception ex){
                    system.debug(LoggingLevel.INFO,'Exception:'+ex);
                }
    }
    
     @isTest
    public static void testMethodForWB_compare3()
    {
        try{
        MPM__c Mpm = new MPM__c();
        Mpm.Name = '2063646';
        Mpm.MPM_Number__c = '2063646';
        Mpm.Film_Color__c = 'Color';
        insert Mpm;
	     
	    Account objAccount = TestUtil.createAccount('Movies Anywhere');
        objAccount.Customer_Focus__c = 'Active';
        objAccount.Type='Global';
        insert objAccount;
        
        TestDataUtility tdu = new TestDataUtility(); 
        Title__c t = tdu.createTitle(Mpm);
        t.Video_Version__c = 'v0909';
        update t;
        
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
        
        Pricing__c pricing1 = new Pricing__c();
        pricing1.Name = 'CheckPriceCode1';
        pricing1.Account__c = objAccount.id;
        pricing1.Country__c = Country.id;
        pricing1.Channel__c='EST';
        pricing1.Content_Type__c='Feature';       
        pricing1.Price_Tier__c ='reprice1';
        //pricing2.Episode_Price_Tier__c='test1';
        pricing1.Format__c='SD';
        lPricing.add(pricing1);
        insert lPricing;
        
        Local_Title__c LT = New Local_Title__c();
        LT.Name = t.Name;
        LT.Title__c = t.Id;
        LT.Country__c = Country.Id;
        LT.Local_Theatrical_Release_Date__c = date.today();
        LT.Language__c = Language.Id;
        LT.Local_TV_Air_Date__c = System.today()+2;
        LT.Price_Code__c = 'CheckPriceCode1';
        LT.LT_MA_Flag__c = True;
        lTitle.add(LT);
        insert lTitle;
        
        List<Commercial_Avail__c> listReleaseplan = new List<Commercial_Avail__c>();
        Commercial_Avail__c releasePlan1 = new Commercial_Avail__c();
        releasePlan1.Channel__c = 'EST';
        releasePlan1.APO__c = 'Yes';
        releasePlan1.Local_Title__c = lTitle[0].id;
        releasePlan1.Title__c=t.id;
        releasePlan1.Languages__c = Language.id;
        releasePlan1.Country_Lookup__c = Country.id;
        releasePlan1.Format__c = 'SD';
        releasePlan1.Language_Type__c = 'Sub & Audio';
        releasePlan1.Exclusive_Date__c = date.today()-200;
        releasePlan1.Start_Date__c = date.today()-200;
        releasePlan1.End_Date__c = date.today();
        releasePlan1.Rights_End__c=date.today();
        releasePlan1.Status__c = 'Confirmed';
        listReleaseplan.add(releasePlan1);
        
        Commercial_Avail__c releasePlan2 = new Commercial_Avail__c();
        releasePlan2.Channel__c = 'EST';
        releasePlan2.APO__c = 'Yes';
        releasePlan2.Local_Title__c = lTitle[0].id;
        releasePlan2.Title__c=t.id;
        releasePlan2.Languages__c = Language.id;
        releasePlan2.Country_Lookup__c = Country.id;
        releasePlan2.Format__c = 'SD';
        releasePlan2.Language_Type__c = 'Sub & Audio';
        releasePlan2.Exclusive_Date__c = date.today()+1;
        releasePlan2.Start_Date__c = date.today()+1;
        releasePlan2.End_Date__c = date.today()+80;
        releasePlan2.Rights_End__c=date.today()+80;
        releasePlan2.Status__c = 'Confirmed';
        listReleaseplan.add(releasePlan2);
        
        Commercial_Avail__c releasePlan3 = new Commercial_Avail__c();
        releasePlan3.Channel__c = 'EST';
        releasePlan3.APO__c = 'Yes';
        releasePlan3.Local_Title__c = lTitle[0].id;
        releasePlan3.Title__c=t.id;
        releasePlan3.Languages__c = Language.id;
        releasePlan3.Country_Lookup__c = Country.id;
        releasePlan3.Format__c = 'SD';
        releasePlan3.Language_Type__c = 'Sub & Audio';
        releasePlan3.Exclusive_Date__c = date.today()+85;
        releasePlan3.Start_Date__c = date.today()+85;
        releasePlan3.End_Date__c = date.today()+200;
        releasePlan3.Rights_End__c=date.today()+200;
        releasePlan3.Status__c = 'Confirmed';
        listReleaseplan.add(releasePlan3);
        insert listReleaseplan;
        
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(objAccount.Id, country.Id, releasePlan1, t);
        insert storefrontGoogle1;
        storefrontGoogle1.APO__c = 'Yes';
        storefrontGoogle1.SF_MA_Flag__c = True;
        update storefrontGoogle1;
        
         Test.startTest();
        Country_SID_Key__c createRPC = new Country_SID_Key__c();
        createRPC.Name = 'INDIA';
        createRPC.Country_Code__c = 'IND';
        createRPC.Region__c = 'Asia Pacific';
        createRPC.Locale_SID_Key__c = 'Asia/Kolkata';
        createRPC.Country_Code2_c__c = 'IN';
        createRPC.isPublishToClient__c = True;
        insert createRPC;
        
        listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[0], lTitle[0].Id);
        //clientAvail.Playlist__c = playlist.id;
        clientAvail.Local_Title__c = lTitle[0].id;
        clientAvail.APO__c = 'Yes';
        clientAvail.Status__c = 'Confirmed';
        clientAvail.Price_Tier_Text__c = 'reprice1';
        clientAvail.Storefront__c = storefrontGoogle1.Id;
        clientAvail.Local_Data_Category_Picklist__c = 'TV Day After Local';
        insert clientAvail;
        //listClientavails.add(clientAvail);
        
         Client_Avail__c clientAvail1 = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[1], lTitle[0].Id);
        //clientAvail.Playlist__c = playlist.id;
        clientAvail1.Local_Title__c = lTitle[0].id;
        clientAvail1.APO__c = 'Yes';
        clientAvail1.Status__c = 'Confirmed';
        clientAvail1.Price_Tier_Text__c = 'reprice1';
        clientAvail1.Storefront__c = storefrontGoogle1.Id;
        clientAvail1.Local_Data_Category_Picklist__c = 'TV Day After Local';
        insert clientAvail1;
        //listClientavails.add(clientAvail1);
         List<Client_Avail__c> CAList = [SELECT Id,Status__c FROM Client_Avail__c];
         system.debug('CAList**************'+CAList);
         Client_Avail__c clientAvail2 = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[2], lTitle[0].Id);
        //clientAvail.Playlist__c = playlist.id;
        clientAvail2.Local_Title__c = lTitle[0].id;
        clientAvail2.APO__c = 'Yes';
        clientAvail2.Status__c = 'Confirmed';
        clientAvail2.Price_Tier_Text__c = 'reprice1';
        clientAvail2.Storefront__c = storefrontGoogle1.Id;
        clientAvail2.Local_Data_Category_Picklist__c = 'TV Day After Local';
        listClientavails.add(clientAvail2);
        //insert clientAvail2;
        //insert listClientavails;
        List<Commercial_Avail__c> RPList = [SELECT Id,Title__r.Content_Type__c,Title__r.Video_Version__c,Language_Type__c,Format__c,Channel__c,Languages__r.Name,Country_Lookup__r.Name,Country_Lookup__c FROM Commercial_Avail__c ];
        WB_PriceUtility.setReturnToWindowFlag(RPList, listClientavails);
        System.debug('listClientavails>>>>>>>>>>>'+listClientavails);
        Test.stopTest();
        
      }catch(Exception ex){
                    system.debug(LoggingLevel.INFO,'Exception:'+ex);
                }
    }
        
}