/**
   @Author Cognizant
   @name CRM_UploadExtractRateCardCtrl_Test 
   @CreateDate 17 May 2018
   @Description Test class for CRM_UploadExtractRateCardCtrl
   @Version <1.0>
   @reference Requirement no : 984/987
*/
@isTest
public class CRM_UploadExtractRateCardCtrl_Test {
    
    public static List<Account> lstAccounts = new List<Account>();
    public static List<Country__c> lstCountry = new List<Country__c>();
    public static List<Agreement__c> storefronts = new List<Agreement__c>();
     /**
    *  Create Test Data. 
    *  @name createTestData
    *  @param None 
    *  @return None
    *  @throws None
    *  @see com.ac.sample.SuperObject#get
    */
    public static void createTestData() {
        
        //create Storefront Account 
        lstAccounts = CRM_TestDataFactory.createAccounts(2, false);
        for(integer i=0;i<lstAccounts.size();i++){
            if(i==0){
                lstAccounts[i].Name = 'Amazone';
            }else{
                lstAccounts[i].Name = 'Google';
            }
            lstAccounts[i].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_DIGITAL_CLIENT;
        }
        insert lstAccounts;
        System.assertEquals(2, lstAccounts.size());
        
        lstCountry = CRM_TestDataFactory.createCountries(new List<String> {'USA','United Kingdom','Germany','Japan'}, 1, false);
        for(Country__c c : lstCountry){
            c.name = c.Region__c;
            if(c.name == 'USA'){
                c.Country_Code2__c = 'USA';
                c.Country_Code__c='USA';
                c.Territory__c  = 'USA';
            }else if(c.name == 'United Kingdom'){
                c.Country_Code2__c = 'UK';
                c.Country_Code__c='UK';
                 c.Territory__c  = 'United Kingdom';
            }else if(c.name == 'Germany'){
                c.Country_Code2__c = 'DE';
                c.Country_Code__c='DE';
                c.Territory__c  = 'Germany';
            }else if(c.name == 'Japan'){
                c.Country_Code2__c = 'JP';
                c.Country_Code__c='JP';
                c.Territory__c  = 'Japan';
            }
            
        }
        insert lstCountry;
        System.assertEquals(4, lstCountry.size());
        
        storefronts = new List<Agreement__c>();
        for(Account a : lstAccounts){
            for(Country__c c : lstCountry){
                Agreement__c sf = new Agreement__c();
                sf.Account__c=a.Id;
                sf.Country__c=c.Id;
                if(c.name == 'USA'){
                    sf.Pricing_Currency__c='USD';
                    sf.WSP_Currency__c='USD';
                }else if(c.name == 'United Kingdom'){
                    sf.Pricing_Currency__c='GBP';
                    sf.WSP_Currency__c='GBP';
                }else if(c.name == 'Germany'){
                    sf.Pricing_Currency__c='EUR';
                    sf.WSP_Currency__c='EUR';
                }else if(c.name == 'Japan'){
                    sf.Pricing_Currency__c='JPY';
                    sf.WSP_Currency__c='JPY';
                }
                sf.Selected_Combination__c = 'Feature_EST_HD , Feature_EST_SD , Feature_VODi_HD , Season_VODi_SD';
                sf.Status__c ='Active';
                storefronts.add(sf);
            }
        }
        insert storefronts;
        System.assertEquals(8, storefronts.size());
        
        List<Rate_card__c> rateCardPrices = new List<Rate_card__c>();    
        for(integer i=0;i<storefronts.size();i++){
            Rate_card__c rc = new Rate_card__c();
            rc.Account__c = storefronts[i].Account__c;
            rc.Country__c = storefronts[i].Country__c;
            rc.WSP1__c = 10+i;
            rc.WSP2__c = 20+i;
            rc.WSP3__c = 30+i;
            rc.SRP__c = 40+i;
            rc.SRP_Currency__c = storefronts[i].Pricing_Currency__c;
            rc.WSP_Currency__c = storefronts[i].WSP_Currency__c;
            rc.Price_Tier__c = 'Price Tier '+i;
            rc.Start_Date__c = System.today();
            rc.End_Date__c = System.today()+30 ;
            if(i < 4){
                rc.Channel__c = 'EST';
                rc.Format__c = 'HD';
                rc.Content_Type__c = 'Feature';
                rc.RC_Category__c = 'CAT';
            }else{
                rc.Channel__c = 'VODi';
                rc.Format__c = 'SD';
                rc.Content_Type__c = 'Season';
                rc.RC_Category__c = 'NR';
            }
            rateCardPrices.add(rc);
        }
        insert rateCardPrices;
        System.assertEquals(8, rateCardPrices.size());
    }
    
    /**
    *  @name rateCardDateOverlappingPositive_Test
    *  @Description : Positive test secario of date overlapping logic of rate card
    */
    @isTest
    static void rateCardDateOverlappingPositive_Test(){
        
        createTestData();
        List<Rate_card__c> rateCardPrices = new List<Rate_card__c>();  
        for(integer i=0;i<3;i++){
            Rate_card__c rc = new Rate_card__c();
            rc.Account__c = lstAccounts[0].Id;
            rc.Country__c = lstCountry[0].Id;
            rc.WSP1__c = 10+i;
            rc.WSP2__c = 20+i;
            rc.WSP3__c = 30+i;
            rc.SRP__c = 40+i;
            rc.SRP_Currency__c = storefronts[i].Pricing_Currency__c;
            rc.WSP_Currency__c = storefronts[i].WSP_Currency__c;
            rc.Price_Tier__c = 'Price Tier '+i;
            rc.RC_Category__c = 'CAT';
            if(i == 0){
                rc.Channel__c = 'EST';
                rc.Format__c = 'HD';
                rc.Content_Type__c = 'Feature';
                rc.Start_Date__c = System.today();
                rc.End_Date__c = System.today()+30 ;
            }else if(i==2){
                rc.Channel__c = 'EST';
                rc.Format__c = 'All';
                rc.Content_Type__c = 'Feature';
                rc.Start_Date__c = System.today();
                rc.End_Date__c = System.today()+30;
            }else{
                rc.Channel__c = 'EST';
                rc.Format__c = 'HD';
                rc.Content_Type__c = 'All';
                rc.Start_Date__c = System.today();
                rc.End_Date__c = System.today()+30;
            }
            rateCardPrices.add(rc);
        }
        
        Test.startTest();
            Database.SaveResult[] results = Database.insert(rateCardPrices, false);
        Test.stopTest();    
        for(Integer i=0;i<results.size();i++){
            if (!results.get(i).isSuccess()){
                Database.Error error = results.get(i).getErrors().get(0);
                String failedDML = error.getMessage();
                System.assertEquals(true,failedDML.containsIgnoreCase(System.Label.CRM_Rate_Card_Overlapping_Date_Error_Message.replace('{0}','::').split('::')[0]),'Date Overlapping Found');
            }
        }
    }
    
    /**
    *  @name rateCardDateOverlappingPositive_Test
    *  @Description : Negative test secario of date overlapping logic of rate card
    */
    @isTest
    static void rateCardDateOverlappingNegative_Test(){
        createTestData();
        List<Rate_card__c> rateCardPrices = new List<Rate_card__c>();  
        for(integer i=0;i<3;i++){
            Rate_card__c rc = new Rate_card__c();
            rc.Account__c = lstAccounts[0].Id;
            rc.Country__c = lstCountry[0].Id;
            rc.WSP1__c = 10+i;
            rc.WSP2__c = 20+i;
            rc.WSP3__c = 30+i;
            rc.SRP__c = 40+i;
            rc.SRP_Currency__c = storefronts[i].Pricing_Currency__c;
            rc.WSP_Currency__c = storefronts[i].WSP_Currency__c;
            rc.Price_Tier__c = 'Price Tier '+i;
            rc.RC_Category__c  = 'NR';
            if(i == 0){
                rc.Channel__c = 'EST';
                rc.Format__c = 'HD';
                rc.Content_Type__c = 'Feature';
                rc.Start_Date__c = System.today()+31;
                rc.End_Date__c = System.today()+62;
            }else if(i==2){
                rc.Channel__c = 'EST';
                rc.Format__c = 'All';
                rc.Content_Type__c = 'Feature';
                rc.Start_Date__c = System.today()+63;
                rc.End_Date__c = System.today()+95;
            }else{
                rc.Channel__c = 'EST';
                rc.Format__c = 'HD';
                rc.Content_Type__c = 'All';
                rc.Start_Date__c = System.today()+96;
                rc.End_Date__c = System.today()+127;
            }
            rateCardPrices.add(rc);
        }  
        
        Test.startTest();
            Database.SaveResult[] results = Database.insert(rateCardPrices, false);
        Test.stopTest();
        system.assertEquals(11,[Select Count() From Rate_card__c],'Successfully added Rate cards');
    }
    
    /**
    *  @name rateCardStorefrontNegative_Test
    *  @Description : Storefront linking to rate card logic test method
    */
    @isTest
    static void rateCardStorefrontNegative_Test(){
        createTestData();
        Delete [Select Id From Agreement__c Where Account__r.Name = 'Amazone'];
        
        List<Rate_card__c> rateCardPrices = new List<Rate_card__c>();  
        for(integer i=0;i<2;i++){
            Rate_card__c rc = new Rate_card__c();
            rc.Account__c = lstAccounts[0].Id;
            rc.Country__c = lstCountry[0].Id;
            rc.WSP1__c = 10+i;
            rc.WSP2__c = 20+i;
            rc.WSP3__c = 30+i;
            rc.SRP__c = 40+i;
            rc.SRP_Currency__c = storefronts[i].Pricing_Currency__c;
            rc.WSP_Currency__c = storefronts[i].WSP_Currency__c;
            rc.Price_Tier__c = 'Price Tier '+i;
            rc.Channel__c = 'EST';
            rc.Format__c = 'HD';
            rc.RC_Category__c  = 'NR';
            rc.Content_Type__c = 'Feature';
            rc.Start_Date__c = System.today()+31;
            rc.End_Date__c = System.today()+62;
            rateCardPrices.add(rc);
        }
        
        Test.startTest();
            Database.SaveResult[] results = Database.insert(rateCardPrices, false);
        Test.stopTest();    
        for(Integer i=0;i<results.size();i++){
            if (!results.get(i).isSuccess()){
                Database.Error error = results.get(i).getErrors().get(0);
                String failedDML = error.getMessage();
                System.assertEquals(true,failedDML.containsIgnoreCase(System.Label.CRM_Rate_Card_Valid_Storefront_Not_found));    
            }
        }
    }
    
     /**
    *  @name rateCardInvalidCapability_Test
    *  @Description : Test Rate card channel,format and Content type match with linked storefront selected combination.
    */
    @isTest
    static void rateCardInvalidCapability_Test(){
        createTestData();
        Test.startTest();
            List<Rate_card__c> validCapabilityRc = [Select Id,Invalid_Capability__c,Format__c From Rate_card__c Where Channel__c = 'VODi' AND Format__c = 'SD' AND Content_Type__c = 'Season'];
            for(Rate_card__c rc : validCapabilityRc){
                System.assertEquals(false,rc.Invalid_Capability__c,'CT_Ch_F combination of RC present in linked Storefrots Selected Combination');    
                rc.Format__c = 'HD';
            }
            update validCapabilityRc;
            
            Set<Id> sfIds = new Set<Id>();
            validCapabilityRc = [Select Id,Invalid_Capability__c,Format__c,Storefront__c From Rate_card__c Where Channel__c = 'VODi' AND Format__c = 'HD' AND Content_Type__c = 'Season'];
            for(Rate_card__c rc : validCapabilityRc){
                sfIds.add(rc.Storefront__c);
                System.assertEquals(true,rc.Invalid_Capability__c,'Invalid Capability set as true after updating RC format to HD. Mismatch with Linked SF selected combination');    
            }
            
            List<Agreement__c> sfList = new List<Agreement__c>();
            for(Agreement__c sf : [Select Id,Selected_Combination__c From Agreement__c Where Id IN :sfIds]){
                sf.Selected_Combination__c = sf.Selected_Combination__c + ' , Season_VODi_HD';
                sfList.add(sf);
            }
            update sfList;
            
            validCapabilityRc = [Select Id,Invalid_Capability__c,Format__c,RC_Category__c From Rate_card__c Where Channel__c = 'VODi' AND Format__c = 'SD' AND Content_Type__c = 'Season'];
            for(Rate_card__c rc : validCapabilityRc){
                System.assertEquals(false,rc.Invalid_Capability__c,'Invalid Capability set as false again as Season_VODi_HD combination added in linked Storefront');    
            }
        Test.stopTest();    
    }
    
    /**
    *  @name getRateCard_Test
    *  @Description : Test get rate card method of controller
    */
    @isTest
    static void getRateCard_Test(){
        createTestData();
        Test.startTest();
            CRM_UploadExtractRateCardCtrl ctrl = new CRM_UploadExtractRateCardCtrl();
            CRM_UploadExtractRateCardCtrl.FilterWrapper filter = new CRM_UploadExtractRateCardCtrl.FilterWrapper();
            filter.text = 'Testing';
            List<CRM_UploadExtractRateCardCtrl.RateCardWrapper> rcWrapList = CRM_UploadExtractRateCardCtrl.getRateCardRecords(filter);
            system.assertEquals(1,rcWrapList.size());
            system.assertEquals(true,rcWrapList[0].maxLimitExceededMsg.containsIgnoreCase(System.Label.CRM_No_Records_Found_For_NR_Mass_Update));    
            
            Test.setFixedSearchResults(new List<Id>{lstAccounts[0].Id});
            filter.text = 'Amazone';
            filter.countryId = lstCountry[0].Id;
            filter.contentType = new List<CRM_DataObjects.PicklistOption>{new CRM_DataObjects.PicklistOption('Feature','Feature')};
            filter.channel = new List<CRM_DataObjects.PicklistOption>{new CRM_DataObjects.PicklistOption('EST','EST')};
            filter.format = new List<CRM_DataObjects.PicklistOption>{new CRM_DataObjects.PicklistOption('HD','HD')};
            filter.WBTerritory = new List<CRM_DataObjects.PicklistOption>{new CRM_DataObjects.PicklistOption('USA','USA')};
            filter.RCLifecycle = new List<CRM_DataObjects.PicklistOption>{new CRM_DataObjects.PicklistOption('Active Current','Active Current')};
            filter.rcCategory = new List<CRM_DataObjects.PicklistOption>{new CRM_DataObjects.PicklistOption('CAT','CAT')};
            rcWrapList = CRM_UploadExtractRateCardCtrl.getRateCardRecords(filter);
            system.assertEquals(1,rcWrapList.size(),'Recrods fetched');
            
            for(CRM_UploadExtractRateCardCtrl.RateCardWrapper rcWrap : rcWrapList){
                rcWrap.contentType = 'Season';
                rcWrap.channel = 'VODi';
                rcWrap.format = 'SD';
                rcWrap.rcCategory = 'CAT';
            }
            
            rcWrapList = CRM_UploadExtractRateCardCtrl.saveRateCards(rcWrapList);
            for(CRM_UploadExtractRateCardCtrl.RateCardWrapper rcWrap : rcWrapList){
                system.assertEquals('Season',rcWrap.contentType);
                system.assertEquals('VODi',rcWrap.channel);
                system.assertEquals('SD',rcWrap.format);
            }
            
        Test.stopTest();
    }
    
    /**
    *  @name saveRateCardsAndValidation_Test
    *  @Description : Test save rate card method of controller
    */
    @isTest
    static void saveRateCardsAndValidation_Test(){
        createTestData();
        List<CRM_UploadExtractRateCardCtrl.RateCardWrapper> rcWrapList = new List<CRM_UploadExtractRateCardCtrl.RateCardWrapper>();
        for(integer i=0;i<3;i++){
            CRM_UploadExtractRateCardCtrl.RateCardWrapper rcWrap = new CRM_UploadExtractRateCardCtrl.RateCardWrapper();
            if(i==0){
                rcWrap.accountName = 'Testing';
                rcWrap.country = 'USA';
                rcWrap.contentType = 'Feature';
                rcWrap.rcCategory = 'CAT';
            }else if(i==1){
                rcWrap.accountName = 'Amazone';
                rcWrap.country = 'Test';
                rcWrap.contentType = 'Feature';
                rcWrap.rcCategory = 'CAT';
            }else{
                rcWrap.accountName = 'Google';
                rcWrap.country = 'USA';
                rcWrap.contentType = 'Test';
                rcWrap.rcCategory = 'NR';
            }
            rcWrap.channel = 'EST';
            rcWrap.startDate = (system.today()).format();
            rcWrap.endDate = (system.today()+30).format();
            rcWrap.format = 'HD';
            rcWrap.priceTier = 'PC - '+i;
            rcWrap.WSP1 = 25;
            rcWrap.WSP2 = 30;
            rcWrap.WSP3 = 40;
            rcWrap.SRP = 60;
            rcWrap.SRPCurrency = 'USD';
            rcWrap.WSPCurrency = 'USD';
            rcWrap.rateCardType = 'Standard';
            rcWrap.isRowModified = true;
            rcWrapList.add(rcWrap);
        }
        
        Test.startTest();
            rcWrapList = CRM_UploadExtractRateCardCtrl.saveRateCards(rcWrapList);
            for(integer i=0;i<3;i++){
                if(i==0){
                    system.assertEquals(system.label.CRM_Rate_Cear_Account_Not_found, rcWrapList[i].validation);
                }else if(i==1){
                    system.assertEquals(system.label.CRM_Rate_card_Country_Not_Found, rcWrapList[i].validation);
                }else{
                    system.assertEquals(true,rcWrapList[i].validation.containsIgnoreCase('Content Type: bad value for restricted picklist field'));
                }
            }
            
            for(integer i=0;i<3;i++){
                if(i==0){
                    rcWrapList[i].accountName = 'Amazone';
                }else if(i==1){
                    rcWrapList[i].country = 'USA';
                }else{
                    rcWrapList[i].contentType = 'Season';
                }
            }
            rcWrapList = CRM_UploadExtractRateCardCtrl.saveRateCards(rcWrapList);
            system.assertEquals(11,[Select Count() From Rate_Card__c],'Total num of RC records are 11 after adding 3 new record');
        Test.stopTest();    
    }
    
     /**
    *  @name saveRateCardsAndValidation_TestER-002518 
    *  @Description : Test save rate card method of controller
    */
    @isTest
    static void saveRateCardsAndValidation_Test_ER_002518 (){
        createTestData();
        List<CRM_UploadExtractRateCardCtrl.RateCardWrapper> rcWrapList = new List<CRM_UploadExtractRateCardCtrl.RateCardWrapper>();
        for(integer i=0;i<3;i++){
            CRM_UploadExtractRateCardCtrl.RateCardWrapper rcWrap = new CRM_UploadExtractRateCardCtrl.RateCardWrapper();
            if(i==0){
                rcWrap.accountName = 'Testing';
                rcWrap.country = 'USA';
                rcWrap.contentType = 'Feature';
            }else if(i==1){
                rcWrap.accountName = 'Amazone';
                rcWrap.country = 'Test';
                rcWrap.contentType = 'Feature';
            }else{
                rcWrap.accountName = 'Google';
                rcWrap.country = 'USA';
                rcWrap.contentType = 'Test';
            }
            rcWrap.channel = 'EST';
            rcWrap.startDate = (system.today()).format();
            rcWrap.endDate = (system.today()+30).format();
            rcWrap.format = 'HD';
           // rcWrap.priceTier = 'PC - '+i;
            rcWrap.WSP1 = 25;
           // rcWrap.WSP2 = 30;
          //  rcWrap.WSP3 = 40;
            rcWrap.SRP = 60;
            rcWrap.SRPCurrency = 'USD';
            rcWrap.WSPCurrency = 'USD';
            rcWrap.rateCardType = 'WSP';
            rcWrap.isRowModified = true;
            rcWrap.rcCategory = 'CAT';
            rcWrapList.add(rcWrap);
        }
        
        Test.startTest();
            rcWrapList = CRM_UploadExtractRateCardCtrl.saveRateCards(rcWrapList);
            for(integer i=0;i<3;i++){
                if(i==0){
                    system.assertEquals(system.label.CRM_Rate_Cear_Account_Not_found, rcWrapList[i].validation);
                }else if(i==1){
                    system.assertEquals(system.label.CRM_Rate_card_Country_Not_Found, rcWrapList[i].validation);
                }else{
                    system.assertEquals(true,rcWrapList[i].validation.containsIgnoreCase('Content Type: bad value for restricted picklist field'));
                }
            }
            
            for(integer i=0;i<3;i++){
                if(i==0){
                    rcWrapList[i].accountName = 'Amazone';
                }else if(i==1){
                    rcWrapList[i].country = 'USA';
                }else{
                    rcWrapList[i].contentType = 'Season';
                }
            }
            rcWrapList = CRM_UploadExtractRateCardCtrl.saveRateCards(rcWrapList);
            system.assertEquals(9,[Select Count() From Rate_Card__c]);
        Test.stopTest();    
    }
    
    
    /**
    *  @name saveRateCardsAndValidation_Test
    *  @Description : Test remove rate card from grid scenario of VF page
    */
    @isTest
    static void removeRateCards_Test(){
        createTestData();
        Test.startTest();
            CRM_UploadExtractRateCardCtrl ctrl = new CRM_UploadExtractRateCardCtrl();
            
            ctrl.getUserLocale();
            ctrl.getUserLocaleLanguage();
            ctrl.getUserLocaleLowerCase();
            ctrl.getUserDateFormat();
            ctrl.getChunkSizeForRateCards();
            ctrl.getRCEditAccess();
            
            CRM_UploadExtractRateCardCtrl.FilterWrapper filter = new CRM_UploadExtractRateCardCtrl.FilterWrapper();
            
            filter.countryId = lstCountry[0].Id;
            List<CRM_UploadExtractRateCardCtrl.RateCardWrapper> rcWrapList = CRM_UploadExtractRateCardCtrl.getRateCardRecords(filter);
            system.assertEquals(2,rcWrapList.size(),'Recrods are fetched');
            
            for(CRM_UploadExtractRateCardCtrl.RateCardWrapper rcWrap : rcWrapList){
                rcWrap.isRowRemoved = true;
            }
            
            rcWrapList = CRM_UploadExtractRateCardCtrl.saveRateCards(rcWrapList);
            system.assertEquals(6,[Select Count() From Rate_Card__c],'2 Rate card records are deleted, 6 remains out of 8 Rate card records');
            
        Test.stopTest();
    }
}