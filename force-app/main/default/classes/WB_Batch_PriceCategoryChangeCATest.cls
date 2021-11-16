@isTest
public class WB_Batch_PriceCategoryChangeCATest {
    
    @isTest
    public static void testMethodpriceCategoryChangeCA()
    {
        Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
      
      List<Title__c> ListTitle=new List<Title__c>();
      Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
      ListTitle.add(title1);
      insert ListTitle;
     
      Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='FR',Country_Code__c='FRA');
      insert countryFrance;
      
      Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
      insert languageFrench;
      
      List<Local_Title__c> ListLocTitle=new List<Local_Title__c>();
      Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =ListTitle[0].Id,Country__c = countryFrance.Id,
                  Language__c =languageFrench.Id);
      ListLocTitle.add(local1);
      insert ListLocTitle;
      
      List<Commercial_Avail__c> ListCommAvl=new List<Commercial_Avail__c>();
      Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=ListTitle[0].Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = ListLocTitle[0].Id,
          Languages__c=languageFrench.Id ,Channel__c='EST',Format__c='HD',Language_Type__c='Dub',Status__c='Confirmed',
          Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+10,Rights_End__c=date.today()+11
          
      );
      ListCommAvl.add(releaseplan1);
      insert ListCommAvl;
      
      Agreement__c storefrontGoogle1 = new Agreement__c(
        Account__c=acctGoogle.Id, Country__c=countryFrance.Id, Pricing_Currency__c='FR', Content_Type__c=ListTitle[0].Content_Type__c,
        Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',CRM_Storefront__c=false,
        SAP_Customer_Number__c='12010421'  
      );
      insert storefrontGoogle1; 
      storefrontGoogle1.SFS_Integration__c='Feature_EST_HD';
      update storefrontGoogle1;
      
      List<Pricing__c> ListPric=new List<Pricing__c>();
		Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title1.Content_Type__c,WS_Price__c=56.78,
            Country__c = countryFrance.Id,Channel__c ='DTD',Format__c ='HD'
        );
        ListPric.add(price1);
        
        WB_Pricing_Settings__c setting = new WB_Pricing_Settings__c();
        setting.Name = 'Push to SFS';
        setting.value__c = '7';
        insert setting;
        
        List<Rate_Card__c> rcList = new List<Rate_Card__c>();
        Rate_Card__c rc = new Rate_Card__c();
        rc.Channel__c = 'VODi';
        rc.Country__c = countryFrance.Id;
        rc.Account__c = acctGoogle.Id;
        rc.Start_Date__c = date.today();
        rc.End_Date__c = date.today()+200;
        rc.Content_Type__c = 'Feature';
        rc.Format__c = 'SD';
        rc.Price_Tier__c = 'New Release Test';
        rc.Storefront__c = storefrontGoogle1.Id;
        rc.RC_Category__c = 'NR';
        
        rcList.add(rc);
        
        Rate_Card__c rc1= new Rate_Card__c();
        rc1.Channel__c = 'VODi';
        rc1.Country__c = countryFrance.Id;
        rc1.Account__c = acctGoogle.Id;
        rc1.Start_Date__c = date.today();
        rc1.End_Date__c = date.today()+200;
        rc1.Content_Type__c = 'Feature';
        rc1.Format__c = 'SD';
        rc1.Price_Tier__c = 'New Release Test';
        rc1.Storefront__c = storefrontGoogle1.Id;
        rc1.RC_Category__c = 'CAT';
        insert rc;
        
        rcList.add(rc1);
        //insert rcList;
        
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id,CA_Rate_Card__c=rcList[0].Id,Client__c=acctGoogle.Id,Status__c='Confirmed',Start_Date__c=date.today(),Price__c=56.78,
            End_Date__c=Date.today()+5
        );
        
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        clientAvailList.add(clientAvail1);
        insert clientAvailList;
        
       List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
	   String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
	   Client_Avail_Price__c cap1 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Type__c = WB_PriceUtility.FIRST,Client_Avail__c=clientAvailList[0].id,Category__c='Catalog',Effective_Date__c=clientAvailList[0].Start_Date__c,Expiry_Date__c=clientAvailList[0].Start_Date__c.addDays(2),Price_Tier__c='reprice1');
       Client_Avail_Price__c cap2 = new Client_Avail_Price__c(RecordTypeId=recTypeId,Client_Avail__c=clientAvailList[0].id,Category__c='Catalog',Effective_Date__c=clientAvailList[0].Start_Date__c.addDays(3),Expiry_Date__c=clientAvailList[0].End_Date__c,Price_Tier__c='reprice2',Type__c='Reprice');
	   capList.add(cap1);
	   capList.add(cap2);
       
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
       
        test.startTest();
        
        WB_Batch_PriceCategoryChangeClientAvail batchClass = new WB_Batch_PriceCategoryChangeClientAvail();
        Database.executeBatch(batchClass,10);
        
        test.stopTest();
       
    }

}