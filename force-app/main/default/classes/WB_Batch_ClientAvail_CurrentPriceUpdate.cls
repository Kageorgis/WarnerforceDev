/**

*/
global class WB_Batch_ClientAvail_CurrentPriceUpdate implements Database.Batchable<sObject>{
  
    String query = null;
    String tpRecTypeId = null;
    DateTime gmtTime = null;
    Date gmtDate = null;
    Date nextDate = null;
    Date prevDate = null;
    Map<String,Integer> countryOffsetMap = null;
  
    global WB_Batch_ClientAvail_CurrentPriceUpdate(){
        gmtTime = System.now();
        DateTime nextDateTime = System.now().addHours(12);
        DateTime prevDateTime = System.now().addHours(-12);
        tpRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME);
        
        countryOffsetMap = WB_PriceUtility.getCountryOffset();
        
        gmtDate  = Date.newInstance(gmtTime.yearGmt(),gmtTime.monthGmt(),gmtTime.dayGmt());
        nextDate = Date.newInstance(nextDateTime.yearGmt(),nextDateTime.monthGmt(),nextDateTime.dayGmt());
        prevDate = Date.newInstance(prevDateTime.yearGmt(),prevDateTime.monthGmt(),prevDateTime.dayGmt());
        
        /*query =  'SELECT Id,Type__c,Effective_Date__c,Expiry_Date__c,Client_Avail__c,Recordtype.name,Client_Avail__r.Title_Content_Type__c,Client_Avail__r.Start_Date__c,'+
        ' Client_Avail__r.End_Date__c,Client_Avail__r.Status__c,Client_Avail__r.Commercial_Avail__r.Country_Code__c,Client_Avail__r.Local_Title__c,Client_Avail__r.Local_Title__r.Price_Code__c,Client_Avail__r.Local_Title__r.Category__c,'+ 
        ' Pricing__c,Client_Avail__r.Pricing__c,Price__c,Client_Avail__r.Price__c,Price_Tier__c,Client_Avail__r.Price_Tier_Text__c,'+
        ' Episode_Price__c,Client_Avail__r.Episode_Price__c,Episode_Price_Tier__c,Client_Avail__r.Episode_Price_Tier__c,SR_Price__c,Client_Avail__r.SR_Price__c,SR_Per_Episode__c,Client_Avail__r.SR_Per_Episode__c,'+
        ' Category__c,Price_Code__c '+
        ' FROM Client_Avail_Price__c WHERE Effective_Date__c =:gmtDate OR Effective_Date__c =:nextDate OR (RecordTypeId = :tpRecTypeId AND (Expiry_Date__c =:gmtDate OR Expiry_Date__c =:prevDate)) ';
        */          
        query = 'Select Id,Client_Avail__c FROM Client_Avail_Price__c WHERE Effective_Date__c =:gmtDate OR Effective_Date__c =:nextDate OR (RecordTypeId = :tpRecTypeId AND (Expiry_Date__c =:gmtDate OR Expiry_Date__c =:prevDate)) Order By Client_Avail__r.Title_Video_Version__c,Client_Avail__r.Release_Plan_Country__c';          
    }
  
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
  
    // Compare price fields, update if there is difference. If CA status is 'Confirmed' and PriceTier is not found, update CA status to 'Tentative'. 
    global void execute(Database.BatchableContext BC, List<Client_Avail_Price__c> scope){
      
        System.debug(LoggingLevel.INFO,'In Execute Method -> '+scope.size());
        List<String> clientAvailIdList = new List<String>();
        for(Client_Avail_Price__c capRecord:scope){
            clientAvailIdList.add(capRecord.Client_Avail__c);  
        }
      
        List<Client_Avail__c> clientAvailList = [SELECT Id,Name,Title_Content_Type__c,Start_Date__c,End_Date__c,Status__c,Commercial_Avail__r.Country_Code__c,Local_Data_Category_Picklist__c,
                                                Local_Title__c,Local_Title__r.Price_Code__c,Local_Title__r.Category__c,Pricing__c,Price__c,Price_Tier_Text__c,Episode_Price__c,Episode_Price_Tier__c,CA_Rate_Card__c,Episode_Rate_Card__c,Episode_Pricing__c,
                                                (Select Id,Name,Client_Avail__c,Type__c,Effective_Date__c,Expiry_Date__c,RecordType.Name,Pricing__c,Price__c,Price_Tier__c,Episode_Price__c,Episode_Price_Tier__c,Category__c,Price_Code__c,CAP_Rate_Card__c,Episode_Rate_Card__c,Episode_Pricing__c FROM Client_Avail_Prices__r ORDER BY Effective_Date__c,RecordType.Name ASC) 
                                                FROM Client_Avail__c WHERE Id IN :clientAvailIdList Order By Title_Video_Version__c,Release_Plan_Country__c];
    
        List<Client_Avail__c> clientAvailUpdateList = new List<Client_Avail__c>();
        Map<String,Local_Title__c> updatedLocalData = new Map<String,Local_Title__c>();
        WB_compareLastAndFromDates1 compare = new WB_compareLastAndFromDates1();
        
        for(Client_Avail__c availRecord:clientAvailList){
      
            List<Client_Avail_Price__c> capList = compare.getOrderedCAPList(availRecord,true);
        
            for(Client_Avail_Price__c capRecord:capList){
                if(WB_PriceUtility.isCurrentPrice(capRecord,availRecord.Commercial_Avail__r.Country_Code__c,countryOffsetMap,gmtTime)){ 
            
                    Boolean hasFound = false;
            
                    if(capRecord.Pricing__c != availRecord.Pricing__c || availRecord.CA_Rate_Card__c != capRecord.CAP_Rate_Card__c || availRecord.Episode_Rate_Card__c != capRecord.Episode_Rate_Card__c || capRecord.Price__c != availRecord.Price__c || capRecord.Price_Tier__c != availRecord.Price_Tier_Text__c || 
                       capRecord.Episode_Price__c != availRecord.Episode_Price__c || capRecord.Episode_Price_Tier__c != availRecord.Episode_Price_Tier__c ||
                       (capRecord.RecordType.Name == WB_PriceUtility.PERM_PRICE_RT_NAME && availRecord.Local_Data_Category_Picklist__c != capRecord.Category__c))
                    {
          
                        Client_Avail__c caRecord = new Client_Avail__c(Id=capRecord.Client_Avail__c);
                        caRecord.CAP_Name__c = capRecord.Name;
                        caRecord.Pricing__c = capRecord.Pricing__c;
                        caRecord.Price__c = capRecord.Price__c;
                        caRecord.Price_Tier_Text__c = capRecord.Price_Tier__c;
                        caRecord.Price_Start__c = capRecord.Effective_Date__c;
                        caRecord.Price_End__c = capRecord.Expiry_Date__c;
                        caRecord.Price_Type__c = capRecord.RecordType.Name;

                        if(caRecord.Price_Type__c == WB_PriceUtility.PERM_PRICE_RT_NAME)
                            caRecord.Local_Data_Category_Picklist__c = capRecord.Category__c;
          
                        if(availRecord.Title_Content_Type__c == 'Season'){
                            caRecord.Episode_Price__c = capRecord.Episode_Price__c;
                            caRecord.Episode_Price_Tier__c = capRecord.Episode_Price_Tier__c;
                            caRecord.Episode_Rate_Card__c = capRecord.Episode_Rate_Card__c;
                            caRecord.Episode_Pricing__c = capRecord.Episode_Pricing__c;
                        }else{
                            caRecord.Episode_Price__c = null;
                            caRecord.Episode_Price_Tier__c = null;
                        }
                        
                        caRecord.CA_Rate_Card__c = capRecord.CAP_Rate_Card__c;
                        
                        clientAvailUpdateList.add(caRecord);
                        hasFound = true;
                    }
                    //For Temp Price, Don't update Local Data.
          
                    if(hasFound && capRecord.RecordType.Name != WB_PriceUtility.TEMP_PRICE_RT_NAME){  
                        //Local Data changes -start
                        Local_Title__c localData = updatedLocalData.get(availRecord.Local_Title__c);
                        if(localData == null){
                            localData = new Local_Title__c(Id=availRecord.Local_Title__c);
                        }
                        
                        //ER-002361	- Stop PriceCode update on Local Data from CAPs(Re-Price/Price Update) 
			    	    //Local Data Proce code update code is commented due to abover ER-002361
                        /*if(capRecord.Price_Code__c != null && capRecord.Price_Code__c.length() > 0 && capRecord.Price_Code__c != availRecord.Local_Title__r.Price_Code__c){
                            localData.Price_Code__c = capRecord.Price_Code__c;
                            updatedLocalData.put(availRecord.Local_Title__c,localData);
                        }*/
                    
                        if(capRecord.Category__c != null && capRecord.Category__c.length() > 0 && capRecord.Category__c != availRecord.Local_Title__r.Category__c
                           && availRecord.Title_Content_Type__c != WB_PriceUtility.SEASON && availRecord.Title_Content_Type__c != WB_PriceUtility.EPISODE){
                            localData.Category__c = capRecord.Category__c;
                            updatedLocalData.put(availRecord.Local_Title__c,localData);
                        }
                        //Local Data changes -end
                    }
          
                    if(hasFound)
                        break;
                }
            }
        }
        
        WB_ClientAvailPriceHandler.recursiveUpdate = true;
        
        if(clientAvailUpdateList.size() > 0){
            Database.saveResult[] saveResult  = Database.update(clientAvailUpdateList, false);
            for(Integer index=0;index<saveResult.size();index++){
                Database.SaveResult updateResult = saveResult[index]; 
                if(!updateResult.isSuccess()){
                    for(Database.Error err : updateResult.getErrors()) {
                        System.debug(LoggingLevel.INFO,'Update CA Result Error ->'+ err.getMessage());
                    }
                }
            }
        }
        
        if(updatedLocalData.values().size() > 0){
            Database.SaveResult[] saveResult = Database.update(updatedLocalData.values(),false);
            for(Integer index=0;index<saveResult.size();index++){
                Database.SaveResult updateResult = saveResult[index]; 
                if(!updateResult.isSuccess()){
                    for(Database.Error err : updateResult.getErrors()) {
                        System.debug(LoggingLevel.INFO,'Update Local Data Result Error ->'+ err.getMessage());
                    }
                }
            }
        }
        
        WB_ClientAvailPriceHandler.recursiveUpdate = false;
    }
 
    global void finish(Database.BatchableContext BC){}
}