@isTest
public class CRM_PricingHandlerTest {
    
    static List<Account> accList = new List<Account>();
    private static Id standardPricebookId ;
    
    static {
        if(standardPricebookId ==  null){
            standardPricebookId = System.Test.getStandardPricebookId();
        }
    }
    
    @isTest
    public static void UpdateCAOnPricingChngTest(){
        
       TestDataUtility tdu = new TestDataUtility();  
       accList = tdu.createAccountList(); 
       //Start -- To create Client Avail 
       MPM__c m = tdu.createMPM();
       Title__c t = tdu.createTitle(m);
       Language__c l = tdu.createLanguage();
       Country__c c = tdu.createCountry();
       Country_Groups__c countryGroup=new Country_Groups__c(Name='CountryGroup',Account__c=accList[0].Id,Country__c=c.Name);
       insert countryGroup;
       Country_Group_Country__c countryGC = new Country_Group_Country__c (Country_Group__c=countryGroup.Id,Country__c=c.Id);
       insert countryGC; 
       Local_Title__c lt = tdu.createlocalTitle(c, l);

       lt.Title__c=t.id;
       update lt;
      
       //Create Pricing
       Pricing__c newPrice = new Pricing__c();
       newPrice.Content_Type__c = 'Feature';
       newPrice.Account__c = accList[0].Id;
       newPrice.Country__c = c.Id;
       newPrice.Channel__c = 'DTD';
       newPrice.Format__c = 'HD';
       newPrice.WS_Price__c = 120.00;
       insert newPrice;
       
       //Create Release Plan
       Commercial_Avail__c rp = tdu.createReleasePlan(t, c, lt, l);
       rp.Exclusive_Date__c = System.today().addDays(-200);
       rp.Start_Date__c = System.today().addDays(-200);
       rp.End_Date__c = System.today().addDays(500);
       rp.Rights_End__c= System.today().addDays(500);
       rp.Country_Lookup__c = c.Id;
       update rp;
       
       Test.startTest();
       
       Agreement__c sf = tdu.createStorefront(c,rp, t, accList[0]);
       list<Client_Avail__c> CaccListInsert = New list<Client_Avail__c>();
       Client_Avail__c ca = New Client_Avail__c(Commercial_Avail__c = rp.ID,Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(10),End_Date__c=System.today().addDays(300),Storefront__c = sf.id);
       Client_Avail__c ca1 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(200),End_Date__c=System.today().addDays(300),Storefront__c = sf.id);
       Client_Avail__c ca2 = New Client_Avail__c(Commercial_Avail__c = rp.ID, Status__c='Tentative',Client__c = accList[0].id,Title__c = t.id,Start_Date__c=System.today().addDays(20),End_Date__c=System.today().addDays(180),Announce_Override__c='Suppress',Storefront__c = sf.id); 
       
       CaccListInsert.add(ca);
       CaccListInsert.add(ca1);
       CaccListInsert.add(ca2); 
       insert CaccListInsert;
       
       String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
       Client_Avail_Price__c cap1 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca.id,Category__c='Catalog',Effective_Date__c=CaccListInsert[0].Start_Date__c,Expiry_Date__c=CaccListInsert[0].End_Date__c, Pricing__c=newPrice.Id,Price__c=10.99);
       //Client_Avail_Price__c cap2 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca1.id,Category__c='Catalog',Effective_Date__c=ca1.Start_Date__c,Expiry_Date__c=ca1.End_Date__c,Price__c=10.01);
       //Client_Avail_Price__c cap3 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=ca2.id,Category__c='Catalog',Effective_Date__c=ca2.Start_Date__c,Expiry_Date__c=ca2.Start_Date__c.addDays(20),Price__c=12.02);
       
       
       List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
       capList.add(cap1);
       //capList.add(cap2);
       //capList.add(cap3);
       
       WB_ClientAvailPriceHandler.recursiveInsert = true;
        Database.SaveResult[] insertResultList = Database.insert(capList,false);
        for(Integer index=0;index<insertResultList.size();index++){
            Database.SaveResult insertResult = insertResultList[index]; 
            if(!insertResult.isSuccess()){
                for(Database.Error err : insertResult.getErrors()) {
                    System.debug(LoggingLevel.INFO,'insertResult Error ->'+ err.getMessage());
                }
            }
        }
       
       Product_Group__c objProductGroup = new Product_Group__c();
       objProductGroup.name = 'Digital - Games - PS4';
       objProductGroup.External_Id__c = 'UK_Digital_Games_PS4_Target_Test_' ;
       objProductGroup.Franchise_Type__c = 'Games';
       objProductGroup.CurrencyIsoCode = 'USD';
       insert objProductGroup;
       
       Product2 objProduct = new Product2();                
       objProduct.Product_Format__c = 'DVD';                
       objProduct.Name = 'PR ' + 1 + Math.random();
       objProduct.NR_period_weeks__c = 2;                
       objProduct.Street_Date__c = System.today()-40;             
       objProduct.NR_period_weeks__c = 7;         
       objProduct.Product_Group__c = objProductGroup.Id;  
       objProduct.Delivery_Lead_Days__c = 4;
       objProduct.IsActive = true;
       objProduct.CanUseQuantitySchedule = true;
       objProduct.SAP_Dist_chain_product_Status__c = '01';
       objProduct.CanUseRevenueSchedule = true;
       objProduct.External_Id__c = string.valueOf(math.random())+ string.ValueOf(1);
       insert objProduct;
       
       Date dtTodayDate = Date.today();
       List<Pricebook_Entry_Period__c> lstPriceBookEntryPeriod = new List<Pricebook_Entry_Period__c>();
       
       Pricebook_Entry_Period__c objPriceBookEntryProduct = new Pricebook_Entry_Period__c();
       objPriceBookEntryProduct.Product__c = objProduct.Id;
       objPriceBookEntryProduct.List_Price__c = 20;
       objPriceBookEntryProduct.Start_Date__c = dtTodayDate;
       objPriceBookEntryProduct.End_Date__c = dtTodayDate + 30;
       objPriceBookEntryProduct.Price_Book__c = standardPricebookId; 
       objPriceBookEntryProduct.CurrencyISOCode ='USD';
       objPriceBookEntryProduct.Client_Avail__c = CaccListInsert[0].Id;
       objPriceBookEntryProduct.Client_Avail_Price__c = capList[0].Id;
       lstPriceBookEntryPeriod.add(objPriceBookEntryProduct);
       insert lstPriceBookEntryPeriod;
       
       
       CRM_PricingHandler instance = new CRM_PricingHandler();
       
       Map<Id,Pricing__c> mapOldPricingObj = new Map<Id,Pricing__c>();
       mapOldPricingObj.put(newPrice.Id,newPrice);
       newPrice.Suggested_Price__c = 1.11;
       update newPrice;
       
       Map<Id,Pricing__c> mapNewPricingObj = new Map<Id,Pricing__c>();
       mapNewPricingObj.put(newPrice.Id,newPrice);
       instance.UpdateClientAvailOnPricingChanged(mapOldPricingObj, mapNewPricingObj);
       
       Map<Id,Client_Avail_Price__c> mapClientAvailsprice = new Map<Id,Client_Avail_Price__c>();
       mapClientAvailsprice.put(capList[0].Id,capList[0]);
       instance.updatePBEPs(mapClientAvailsprice, lstPriceBookEntryPeriod);
       
       //Delete PBEPs before deleting CAs
       //WB_TriggerHandlerDateOverlapClientAvail.deleteClientAvail(CaccListInsert);
       
       Exception ex = new DMLException('My DML EXCEPTION');
       try{
           instance.logAnException(ex, CaccListInsert[0].Id);
       }
       Catch(Exception e){
           
       }
       
       Test.stopTest();
    }
}