@isTest(SeeAllData=false)
public class WB_Batch_LocalData_MA_UpdateTest{
    
    public static List<Client_Avail__c> listClientavails;
    static List<Pricing__c> lPricing = new List<Pricing__c>();
    static List<Local_Title__c> lTitle = new List<Local_Title__c>();
    
    @isTest
    public static void LocalDataMAUpdate_TestMethod(){
        
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
        releasePlan1.Start_Date__c = date.today()+10;
        releasePlan1.End_Date__c = date.today()+80;
        releasePlan1.Rights_End__c=date.today()+200;
        releasePlan1.Status__c = 'Confirmed';
        listReleaseplan.add(releasePlan1);
        insert listReleaseplan;
        
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(objAccount.Id, country.Id, releasePlan1, t);
        insert storefrontGoogle1;
        storefrontGoogle1.APO__c = 'Yes';
        storefrontGoogle1.SF_MA_Flag__c = True;
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
        
        listClientavails = new List<Client_Avail__c>();
        Client_Avail__c clientAvail = TestUtil.initClientAvail(objAccount.Id, listReleaseplan[0], lTitle[0].Id);
        //clientAvail.Playlist__c = playlist.id;
        clientAvail.Local_Title__c = lTitle[0].id;
        clientAvail.APO__c = 'Yes';
        clientAvail.Status__c = 'Confirmed';
        clientAvail.Price_Tier_Text__c = 'reprice1';
        clientAvail.Storefront__c = storefrontGoogle1.Id;
        clientAvail.Local_Data_Category_Picklist__c = 'TV Day After Local';
        listClientavails.add(clientAvail);
        insert listClientavails;
        
        try{
            
          WB_Batch_LocalData_MA_Update localDataMAUpdateBatch= new WB_Batch_LocalData_MA_Update();
        String jobId = System.schedule('localDataUpdateBatchJob', '0 0 * * * ?', localDataMAUpdateBatch);
        localDataMAUpdateBatch.execute(null);
       
         
        }catch(Exception ex){
          
        }
        
        Test.stopTest();
	     
	 }catch(Exception e) {
        System.debug('An unexpected error has occurred: ' + e.getMessage());
     }
  } 
}