global without sharing class WB_CreatePreOrderCAPAndMappingAR implements Database.Batchable<sObject>, database.stateful{
 
 global String Query = null;
 Date annExecu = Date.Today();
 public List<Client_Avail__c> availsList;
 
 global WB_CreatePreOrderCAPAndMappingAR(){
   Query = 'SELECT Id FROM Client_Avail__c Where Start_Date__c >:annExecu AND APO_Date__c != NULL AND (Title_Content_Type__c != \'Episode\' OR (Title_Content_Type__c = \'Episode\' AND Parent_Client_Avail__c = null))';
 
      //Query = 'SELECT Id FROM Client_Avail__c Where ID = '+'\'a0G0B00002U4JTlUAN\'' +'AND Start_Date__c >:annExecu AND APO_Date__c != NULL AND (Title_Content_Type__c != \'Episode\' OR (Title_Content_Type__c = \'Episode\' AND Parent_Client_Avail__c = null ))';	
 }
 
 global WB_CreatePreOrderCAPAndMappingAR(List<Client_Avail__c> caList){
    availsList = caList;
    Query = 'SELECT Id FROM Client_Avail__c Where Id In :availsList';
 }
 
 global Database.QueryLocator start(Database.BatchableContext BC){
    
    return Database.getQueryLocator(Query);
    
 }   
 
 global void execute(Database.BatchableContext BC,List<Client_Avail__c> scope){
    
    Map<Id,Client_Avail__c> caMap = new Map<Id,Client_Avail__c>([SELECT Id,Name,CurrencyIsoCode,Title_Content_Type__c,Start_Date__c,End_Date__c,Pricing__c,Price__c,Price_Tier_Text__c,Episode_Price__c,Episode_Price_Tier__c,Local_Data_Category_Picklist__c,Price_Code__c,Local_Title__r.Category__c,Local_Title__r.Local_Category__c,Title__c,Parent_Client_Avail__c,Commercial_Avail__c,Episode_Pricing__c,
                                            APO_Date__c,New_Price_Code__c,Commercial_Avail__r.Country_Lookup__r.Name,Commercial_Avail__r.Country_Code__c,Local_Title__c,Release_Plan_Country__c,SR_Price__c,SR_Per_Episode__c,CA_Rate_Card__c,Episode_Rate_Card__c,(Select Id,Effective_Date__c,Expiry_Date__c, Price__c, Pricing__c, Price_Tier__c, Episode_Price__c, Episode_Price_Tier__c, Price_Code__c,Episode_Rate_Card__c,Episode_Pricing__c,Client_Avail__c,SR_Price__c,SR_Per_Episode__c,
                                            Title_Content_Type__c,Category__c,Announce_Override__c,RecordTypeId,Client_Avail_Status__c,Type__c From Client_Avail_Prices__r Where RecordType.Name = 'PERM' ORDER BY Effective_Date__c ),
                                            (Select Id,Client_Avail_Price__c,CAP_ID__c From Announcement_Client_Avails__r Where (Sales_Channel__c LIKE 'PO%' AND Status__c !=: 'Cancelled') ORDER BY createddate DESC)
                                             FROM Client_Avail__c where Id IN : scope AND Start_Date__c >:annExecu AND APO_Date__c != NULL]);
    system.debug(LoggingLevel.INFO,'###scope:'+caMap);
    
    String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
    List<Client_Avail_Price__c> preOrderCapInsertList = new List<Client_Avail_Price__c>();
    List<Client_Avail_Price__c> preOrderCapInsertWithoutRPList = new List<Client_Avail_Price__c>();
    
    for(Client_Avail__c ca : caMap.values()){
        
        system.debug(LoggingLevel.INFO,'###ca:'+ca);
        system.debug(LoggingLevel.INFO,'###APO_Date__c:'+ca.APO_Date__c);
        if(ca.Client_Avail_Prices__r != null && ca.Client_Avail_Prices__r.size()>0){
            
            
             
            for(Client_Avail_Price__c cap : ca.Client_Avail_Prices__r){
                system.debug(LoggingLevel.INFO,'###cap:'+cap);
                if(cap.Effective_Date__c < ca.Start_Date__c)
                    break;
                if(cap.Effective_Date__c == ca.Start_Date__c){
                    Client_Avail_Price__c preOrderCAP = WB_PriceUtility.createPreOrderCAP(ca,recTypeId,cap);
                    if(preOrderCAP.Category__c == null || preOrderCAP.Category__c == ''){
                        preOrderCAP.Category__c = 'TBD';
                    }
                    system.debug(LoggingLevel.INFO,'###preOrderCAP:'+preOrderCAP);
                    
                    if(ca.Commercial_Avail__c == null){
                        preOrderCapInsertWithoutRPList.add(preOrderCAP);
                    }else
                        preOrderCapInsertList.add(preOrderCAP);
                }
            }
        }
    }
    
    if(preOrderCapInsertList != null && preOrderCapInsertList.size()>0){
        
        //WB_ClientAvailPriceHandler.recursiveInsert = true;
        WB_PriceUtility.SKIP_VALIDATION = true;
        WB_PriceUtility.SKIP_PRICE_VALIDATION = true;
        system.debug(LoggingLevel.INFO,'###preOrderCapInsertList:'+preOrderCapInsertList);
        Database.SaveResult[] preOrderCAPInsertResult = Database.insert(preOrderCapInsertList,false);
        List<Announcement_Record__c> announcementRecordList = new List<Announcement_Record__c>();
        List<Client_Avail_Price__c> preOrderCAPList = new List<Client_Avail_Price__c>();
        
        for(Integer index=0;index< preOrderCAPInsertResult.size();index++){
            Database.SaveResult insertResult = preOrderCAPInsertResult[index];
            if(!insertResult.isSuccess()){
                for(Database.Error err : insertResult.getErrors()){
                    System.debug(LoggingLevel.INFO,'InsertResult Error ->'+ err.getMessage());
                }
            }else{
                Client_Avail_Price__c capRecord = preOrderCapInsertList[index];
                preOrderCAPList.add(capRecord);
                System.debug(LoggingLevel.INFO,'capRecord ->'+ capRecord);
                Client_Avail__c caRecord = caMap.get(capRecord.Client_Avail__c);
                if(caRecord.Announcement_Client_Avails__r.size() > 0){
                    for(Announcement_Record__c annRec : caRecord.Announcement_Client_Avails__r){
                        Announcement_Record__c annRecord = annRec;
                        annRecord.Client_Avail_Price__c = capRecord.id;
                        annRecord.CAP_ID__c = capRecord.id;
                        announcementRecordList.add(annRecord);
                    }
                    
                }
            }
        }
        
        if(preOrderCAPList != null && preOrderCAPList.size()>0){
            WB_PBEP_Product_CreationHandler pbepHandler = new WB_PBEP_Product_CreationHandler();
            pbepHandler.insertOrUpdatePriceBookEntryPeriod(preOrderCAPList);
        }
        
        if(announcementRecordList != null && announcementRecordList.size() > 0){
            Database.Saveresult[] announceUpdateResult  = Database.update(announcementRecordList, false);
			Map<Id,String> aRErrorMap = new Map<Id,String>();
        	for(Integer index=0;index< announceUpdateResult.size();index++){
        	    Database.SaveResult updateResult = announceUpdateResult[index]; 
        	    if(!updateResult.isSuccess()){
     				String errorMessage = ''; 
     				for(Database.Error err : updateResult.getErrors()){
     					System.debug(LoggingLevel.INFO,'InsertResult Error ->'+ err.getMessage());
     				}
     				Id annId = updateResult.getId();
     				if(!aRErrorMap.containsKey(annId))
                            aRErrorMap.put(annId, errorMessage);
     				
 			}
        	    
        	}
        	
        	if(aRErrorMap != null && aRErrorMap.size()>0){
        	    system.debug(LoggingLevel.INFO,'aRErrorMap'+aRErrorMap);
        	}
        }
        
        //WB_ClientAvailPriceHandler.recursiveInsert = false;
        WB_PriceUtility.SKIP_VALIDATION = false;
        WB_PriceUtility.SKIP_PRICE_VALIDATION = false;
        
    }
    
    if(preOrderCapInsertWithoutRPList != null && preOrderCapInsertWithoutRPList.size() > 0){
    	WB_ClientAvailPriceHandler.recursiveInsert = true;
    	
    	system.debug(LoggingLevel.INFO,'###preOrderCapInsertList:'+preOrderCapInsertList);
        Database.SaveResult[] preOrderCAPInsert_Result = Database.insert(preOrderCapInsertWithoutRPList,false);
        
        for(Integer index = 0;index < preOrderCAPInsert_Result.size();index++){
        	Database.SaveResult insertResult = preOrderCAPInsert_Result[index];
        	if(!insertResult.isSuccess()){
        		for(Database.Error err : insertResult.getErrors()){
                    System.debug(LoggingLevel.INFO,'InsertResult Error ->'+ err.getMessage());
                }
        	}
        }
        
    	WB_ClientAvailPriceHandler.recursiveInsert = false;
    }
 }
 
 global void finish(Database.BatchableContext BC){
    
    
 }
 
}