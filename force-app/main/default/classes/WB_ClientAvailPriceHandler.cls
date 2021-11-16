public class WB_ClientAvailPriceHandler{

     //SC To SFS Integration Changes
  public Map<String,String> getAccountingCategoryData(){
    Map<string,String> availableCatgryMap = new Map<string,String>();
    for(SFS_Accounting_Category__mdt cmd : [SELECT MasterLabel, QualifiedApiName,Accounting_Category__c,CAP_Category__c,Content_Type__c FROM SFS_Accounting_Category__mdt]){
          availableCatgryMap.put(cmd.Content_Type__c+'-'+cmd.CAP_Category__c,cmd.Accounting_Category__c);
        }
        
        return availableCatgryMap;
  }
  
  //SC To SFS Integration Changes
  public Boolean assignAccountingCategory(Map<string,String> availableCatgryMap,Client_Avail_Price__c cap,String contentType,String category){
    String key = contentType+'-'+category;
    Boolean changed = false;
    if(availableCatgryMap.size() > 0 && availableCatgryMap.containsKey(key)){
            if(cap.Accounting_Category__c != availableCatgryMap.get(key)){
                cap.Accounting_Category__c = availableCatgryMap.get(key); 
                changed = true;
            }
        }else{
          cap.Accounting_Category__c = 'N/A';
          changed = true;
        }
        return changed;
  }
  
  //SC To SFS Integration Changes
  public void populateAccountingCategory(List<Client_Avail_Price__c> capInsertList){
    Map<string,String> availableCatgryMap = getAccountingCategoryData();  
    for(Client_Avail_Price__c cap:capInsertList){
            Boolean isChanged = assignAccountingCategory(availableCatgryMap,cap,cap.Title_Content_Type__c,cap.Category__c);
        }
  }
  
  //SC To SFS Integration Changes
  public void updatePushToSFS(List<Client_Avail_Price__c> capInsertList,Map<Id,Client_Avail_Price__c> oldCAPMap){
    Map<string,String> availableCatgryMap = getAccountingCategoryData();
    Set<String> storefrontIDs = new Set<String>();  
    for(Client_Avail_Price__c cap:capInsertList){
      storefrontIDs.add(cap.Storefront__c);
    }
    List<Agreement__c> storefronts = [Select Id,SFS_Integration__c from Agreement__c where Id IN :storefrontIDs];
    Map<Id,Client_Avail_Price__c> filteredCAPs = getFilteredCAPs(capInsertList,storefronts);
    for(Client_Avail_Price__c cap:capInsertList){
            Client_Avail_Price__c oldCap = oldCAPMap.get(cap.Id);
      Boolean isChanged = false;
                  
            if(cap.Category__c != oldCap.Category__c)
              isChanged = assignAccountingCategory(availableCatgryMap,cap,cap.Title_Content_Type__c,cap.Category__c);
             
            if(filteredCAPs.get(cap.Id) != null && cap.Push_to_SFS__c != null){  
              if( isChanged == TRUE || 
                cap.Effective_Date__c != oldCap.Effective_Date__c || 
                cap.Expiry_Date__c != oldCap.Expiry_Date__c || 
                cap.Price_Tier__c != oldCap.Price_Tier__c || 
                cap.Price__c != oldCap.Price__c){
					cap.Push_to_SFS__c = System.now();
                }
            }
        }
        
        
  }
  
  //SC To SFS Integration Changes
    //Method is used to update Push To SFS value on CAP based on Status Change on CA
    public void updatePushToSFSOnCAStatusChange(Map<String,Client_Avail_Price__c> updateCAPMap,Map<Id,Client_Avail__c> updatedClientAvailMap,Map<Id,Client_Avail__c> oldClientAvailMap){
        Set<String> storefrontIDs = new Set<String>();
        Map<Id,Client_Avail_Price__c> capMap = new Map<Id,Client_Avail_Price__c>();
        for(Client_Avail__c ca : updatedClientAvailMap.values()){
            boolean sfFlag = false;
            boolean statusChnage = (ca.Status__c != oldClientAvailMap.get(ca.id).Status__c);
            boolean startDateChange = (ca.Start_Date__c != oldClientAvailMap.get(ca.id).Start_Date__c);
            boolean endDateChange = (ca.End_Date__c != oldClientAvailMap.get(ca.id).End_Date__c);
            
            if(ca.Client_Avail_Prices__r != null){
                for(Client_Avail_Price__c cap : ca.Client_Avail_Prices__r){
                    if((statusChnage && cap.Effective_Date__c >= ca.Start_Date__c) || 
                       (startDateChange && cap.Effective_Date__c == ca.Start_Date__c) || 
                       (endDateChange && cap.Expiry_Date__c == ca.End_Date__c)){
                        sfFlag = true;
                        if(!capMap.containsKey(cap.Id)){
                            capMap.put(cap.Id,cap);
                        }
                    }
                }
                if(sfFlag){
                              storefrontIDs.add(ca.Storefront__c);
                }       
            }
        }
        
        if(!capMap.values().isEmpty()){        
               List<Agreement__c> storefronts = [Select Id,SFS_Integration__c from Agreement__c where Id IN :storefrontIDs];
                                                Map<Id,Client_Avail_Price__c> filteredCAPs = getFilteredCAPs(capMap.values(),storefronts);
            for(Client_Avail_Price__c cap : filteredCAPs.values()){
                if(cap.Push_to_SFS__c != null){
                    if(updateCAPMap.containsKey(cap.id)){
                        updateCAPMap.get(cap.id).Push_to_SFS__c = System.now();
                    }else{
                        cap.Push_to_SFS__c = system.now();
                        updateCAPMap.put(cap.id,cap);
                    }
                }
            }
        }
        
    }

    //SC To SFS Integration Changes
    //This method is used to get the Filter CAP List based on Content Type + Channel + Format combination present on parent CA -> Storefront -> SFS_Integration__c Lists 
    public Map<Id,Client_Avail_Price__c> getFilteredCAPs(List<Client_Avail_Price__c> capList,List<Agreement__c> storefronts){
        Map<Id,Set<String>> mapStoreToSFCombs = new  Map<Id,Set<String>>();
        Map<Id,Client_Avail_Price__c> filteredCAPMap = new Map<Id,Client_Avail_Price__c>();
        for(Agreement__c storefront : storefronts){
            Set<String> sfCombinations = new Set<String>();
            if(storefront.SFS_Integration__c != null){
                sfCombinations = new Set<String>(storefront.SFS_Integration__c.split(' , '));
            }
            mapStoreToSFCombs.put(storefront.Id,sfCombinations);
        }
        if(mapStoreToSFCombs.size() > 0){
            for(Client_Avail_Price__c cap : capList){
                String key = cap.Title_Content_Type__c +'_'+ cap.Client_Avail_Channel__c+'_'+cap.Client_Avail_Format__c;
                Set<String> sfComs = mapStoreToSFCombs.containsKey(cap.Storefront__c) ? mapStoreToSFCombs.get(cap.Storefront__c) : new Set<String>();
                if(sfComs.size() > 0 && sfComs.contains(key)){
                    filteredCAPMap.put(cap.Id,cap);
                }
            }
        }
        
        return filteredCAPMap;
    }
 
    
    //This method assigns price related fields on Client Avail. This would be called on Before Insert.
    public void populatePriceFieldsOnCA(List<Client_Avail__c> clientAvailInsertList){ 
      for(Client_Avail__c clientAvail:clientAvailInsertList){
            clientAvail.Price_Start__c = clientAvail.Start_Date__c;
			clientAvail.Price_End__c = clientAvail.End_Date__c;
            clientAvail.Price_Type__c = WB_PriceUtility.PERM_PRICE_RT_NAME;
		   //ER-006644 - Catalog Reprice Reminder - Start
            if(clientAvail.Local_Data_Category_Picklist__c != Null && clientAvail.Title_Content_Type__c != Null && clientAvail.Title_Content_Type__c.equals('Feature') && !(clientAvail.Local_Data_Category_Picklist__c.equals('Catalog') || clientAvail.Local_Data_Category_Picklist__c.equals('Catalog New To Format'))){
                clientAvail.Catalog_CAP_Required__c = true;
            }else if(clientAvail.CA_Rate_Card__c != Null && clientAvail.Title_Content_Type__c != Null && clientAvail.Title_Content_Type__c.equals('Feature') && clientAvail.CA_RC_Category__c != Null && (clientAvail.CA_RC_Category__c.equals('NR') || clientAvail.CA_RC_Category__c.equals('Premium'))){
                clientAvail.Catalog_CAP_Required__c = true;
            }
            //ER-006644 - Catalog Reprice Reminder - End
        } 
    }
     
    //This method creates new Client_Avail_Price__c record for each Client_Avail__c getting created in the System.
    public void createClientAvailPrice(List<Client_Avail__c> clientAvailInsertList){
        
        List<Client_Avail_Price__c> capRecordList = new List<Client_Avail_Price__c>();
        List<Client_Avail__c> episodeCAList = new List<Client_Avail__c>();
        Map<Id,Client_Avail__c> clientAvailMap = new Map<Id,Client_Avail__c>();
        String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
    
    //SC To SFS Integration Changes
        Map<string,String> availableCatgryMap = getAccountingCategoryData();

        
        for(Client_Avail__c clientAvail:clientAvailInsertList){
          //SINC1125828 - updated below if condition. Added the condition after ||.
            if(clientAvail.Title_Content_Type__c != WB_PriceUtility.EPISODE || (clientAvail.Title_Content_Type__c == WB_PriceUtility.EPISODE && clientAvail.Parent_Client_Avail__c == null)){
              
              //PreOrder CAP changes modified by Tejasvini
              if(clientAvail.APO_Date__c != null){
                  Client_Avail_Price__c preOrderCapRecord = WB_PriceUtility.createPreOrderCAP(clientAvail,recTypeId,null);
                  if(preOrderCapRecord.Category__c == null || preOrderCapRecord.Category__c == ''){
                    preOrderCapRecord.Category__c = 'TBD';
                  }
                  capRecordList.add(preOrderCapRecord);
              }
              
              Client_Avail_Price__c capRecord = WB_PriceUtility.createFirstCAP(clientAvail,recTypeId);
              clientAvailMap.put(clientAvail.Id,clientAvail);
              
              if(capRecord.Category__c == null || capRecord.Category__c == ''){
                capRecord.Category__c = 'TBD';
              }
              capRecordList.add(capRecord);
        //SC To SFS Integration Changes
              assignAccountingCategory(availableCatgryMap,capRecord,clientAvail.Title_Content_Type__c,capRecord.Category__c); 
            }else{
              episodeCAList.add(clientAvail);
            }
        } 
        
        try{
          
          WB_ClientAvailPriceHandler.recursiveInsert = true;
          if(capRecordList.size() > 0){
            Database.Saveresult[] saveResult  = Database.insert(capRecordList, false);
          }
          
          if(episodeCAList.size() > 0){
            populateEpisodePriceEntry(episodeCAList,WB_PriceUtility.INSERT_OP);
          }
          
            //WB_PBEP_Product_CreationHandler pbepHandler = new WB_PBEP_Product_CreationHandler();
            //pbepHandler.insertOrUpdatePriceBookEntryPeriod(clientAvailInsertList);
        }catch(Exception ex){
          System.debug(LoggingLevel.INFO,'Exception in createClientAvailPrice '+ex.getMessage());
        }
        
        WB_ClientAvailPriceHandler.recursiveInsert = false; 
    }
	
	//ER-006644 - Catalog Reprice Reminder - Start
    public static void updateCatalogCAPRequiredOnCA(List<Client_Avail_Price__c> capList,Map<Id,Client_Avail_Price__c> oldClientAvailMap,String operation){
        List<Client_Avail__c> updateCAFinal = new List<Client_Avail__c>();
        Set<String> caIDSet = new Set<String>();
        List<CAS_Error_Log__c> lstCasErrorLog = new List<CAS_Error_Log__c>();
        Map<String,CAS_Error_Log__c> caIdCASErrorLogMap = new Map<String,CAS_Error_Log__c>();
        String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
        if(capList!=null && capList.size()>0){
            for(Client_Avail_Price__c capRecord:capList){
                
                Client_Avail_Price__c oldCap;
                if(operation == 'Update'){
                    oldCap = (Client_Avail_Price__c)oldClientAvailMap.get(capRecord.Id);
                }
                
                if((capRecord.RecordTypeId != recTypeId) || capRecord.Title_Content_Type__c != 'Feature'|| (capRecord.Effective_Date__c < capRecord.CA_Start_Date__c) || (operation == 'Insert' && capRecord.Effective_Date__c == capRecord.CA_Start_Date__c))
                    continue;
                if(operation == 'Insert' || (operation == 'Update' && (capRecord.Category__c != oldCap.Category__c || capRecord.CAP_Rate_Card__c != oldCap.CAP_Rate_Card__c))|| operation == 'Delete' || operation == 'Batch'){
                    caIDSet.add(capRecord.Client_Avail__c);
                }
            }  
        }
        Date currentDate = System.today();
        
        Map<Id,Client_Avail__c>  clientAvailMap = new Map<Id,Client_Avail__c>([Select Id,Name,Commercial_Avail__r.Country_Code__c,Catalog_CAP_Required__c,End_Date__c,Start_Date__c,Price_Start__c,Price_End__c,Price__c,Price_Tier_Text__c,Episode_Price__c,Episode_Price_Tier__c,Title_Content_Type__c,APO_Date__c,
                                                                               (Select Id,Name,Effective_Date__c,Title_Content_Type__c,Expiry_Date__c,Price__c,RecordTypeId,RC_Category__c,Price_Tier__c,Episode_Price__c,Episode_Price_Tier__c,Category__c from Client_Avail_Prices__r Where RecordTypeId =: recTypeId Order by Effective_Date__c) 
                                                                               From Client_Avail__c Where Id In :caIDSet AND End_Date__c >= :currentDate]);
        for(Id caId: clientAvailMap.keySet()){
            Boolean nrOrPremiumCAP = false;
            Boolean priceCatCAP = false;
            Boolean catCAP = false;
            for(Client_Avail_Price__c capRecord: clientAvailMap.get(caId).Client_Avail_Prices__r){
                if(capRecord != null){
                    if(capRecord.Category__c.equals('Catalog') || capRecord.Category__c.equals('Catalog New To Format')){
                        catCAP = true;
                    }
                    if(capRecord.RC_Category__c != null){
                        if(capRecord.RC_Category__c.contains('NR') || capRecord.RC_Category__c.equals('Premium') ){
                            nrOrPremiumCAP = true;
                        }
                        if(capRecord.RC_Category__c.contains('CAT')){
                            priceCatCAP = true;
                        }
                    }  
                }
            }

            if(!catCAP){
                clientAvailMap.get(caId).Catalog_CAP_Required__c = true;
            }else if(nrOrPremiumCAP && (!priceCatCAP)){
                clientAvailMap.get(caId).Catalog_CAP_Required__c = true;
            }else{  
                clientAvailMap.get(caId).Catalog_CAP_Required__c = false;
            }
            updateCAFinal.add(clientAvailMap.get(caId));
        }
        try{
            if(updateCAFinal.size() > 0){
            	WB_ClientAvailPriceHandler.recursiveUpdate = true;
                Database.SaveResult[] updateResultList = Database.update(updateCAFinal,false);
                WB_ClientAvailPriceHandler.recursiveUpdate = false;
                for(Integer index=0;index<updateResultList.size();index++){
                    for(Database.Error err : updateResultList[index].getErrors()) {
                        System.debug(LoggingLevel.INFO,'Error Message -> '+err.getMessage());
                        if(operation == 'Batch')
                        {
                            Database.SaveResult updateResult = updateResultList[index];
                            if(!updateResult.isSuccess()){
                                String errorMessage ='';
                                
                                CAS_Error_Log__c casErrorLog = new CAS_Error_Log__c(Object_Name__c = updateCAFinal[index].Id.getSObjectType().getDescribe().getName(),
                                                                                    Error_Description__c = errorMessage.left(252),Error_Description_Long__c = errorMessage.left(99998),
                                                                                    Error_Category__c = 'Release Plan - Catalog Reprice Reminder Error',Record_Id__c = updateCAFinal[index].Id);
                                lstCasErrorLog.add(casErrorLog);
                            }  
                        }
                        
                        break;
                    }
                }
            }
            if(lstCasErrorLog != NULL && lstCasErrorLog.size() > 0 && operation == 'Batch'){
                Database.SaveResult[] insertCASerrorList = Database.insert(lstCasErrorLog,false);
            }
        }catch(Exception ex){
            System.debug(LoggingLevel.INFO,'Exception in updateCatalogCAPRequiredOnCA '+ex.getMessage());	 
        }
    }  
    //ER-006644 - Catalog Reprice Reminder - End
    
    
    //This method creates new PreOrder Client_Avail_Price__c record whenever PreOrder Date is saved
    public Map<String,Client_Avail_Price__c> createPreOrderClientAvailPrice(Map<Id,Client_Avail__c> newClientAvailMap,Map<Id,Client_Avail__c> oldClientAvailMap,Map<Id,Client_Avail__c> updatedClientAvailMap){
        
        List<Client_Avail_Price__c> capRecordList = new List<Client_Avail_Price__c>();
        String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
        List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
        Map<String,Client_Avail_Price__c> capMapToUpdate = new Map<String,Client_Avail_Price__c>();
        
        for(String caId : newClientAvailMap.keySet()){
          Client_Avail__c newClientAvail = (Client_Avail__c)newClientAvailMap.get(caId);
          Client_Avail__c oldClientAvail = (Client_Avail__c)oldClientAvailMap.get(caId);
          
          if(updatedClientAvailMap != null && updatedClientAvailMap.size()>0){
            if(updatedClientAvailMap.get(caId) != null){
              capList = updatedClientAvailMap.get(caId).Client_Avail_Prices__r;
             
             }
          }
          
          Integer preOrderCapCount = 0;
          Boolean createPreOrderCAP = false;
          for(Client_Avail_Price__c capRec :capList){
              if(((capRec.Effective_Date__c < oldClientAvail.Start_Date__c))){
                  preOrderCapCount = preOrderCapCount + 1;
                  break;
              }
          }
          
          if((preOrderCapCount == 0 ) && (newClientAvail.APO_Date__c != Null) && (newClientAvail.APO_Date__c < newClientAvail.Start_Date__c)){
              createPreOrderCAP = true;
          }
          
          if(createPreOrderCAP){
            
            if(newClientAvail.Title_Content_Type__c != WB_PriceUtility.EPISODE || (newClientAvail.Title_Content_Type__c == WB_PriceUtility.EPISODE && newClientAvail.Parent_Client_Avail__c == null)){
                  //PreOrder CAP changes modified by Tejasvini
                  //if(newClientAvail.APO_Date__c != null){
                    Client_Avail_Price__c firstCap;
                    for(Client_Avail_Price__c cap:capList){
                      
                      if((cap.Type__c == 'FIRST') || (cap.Effective_Date__c == newClientAvail.Start_Date__c)){
                        firstCap = cap;
                      }
                       
                    }
                    Client_Avail_Price__c preOrderCapRecord = WB_PriceUtility.createPreOrderCAP(newClientAvail,recTypeId,firstCap);
                    if(preOrderCapRecord.Category__c == null || preOrderCapRecord.Category__c == ''){
                          preOrderCapRecord.Category__c = 'TBD';
                    }
                    capRecordList.add(preOrderCapRecord);
              } 
              
              try{
              
                WB_ClientAvailPriceHandler.recursiveInsert = true;
                
                if(capRecordList.size() > 0){
                  Database.Saveresult[] saveResult  = Database.insert(capRecordList, false);
                  for(Integer index = 0;index < saveResult.size();index++){
                    Database.Saveresult saveResultRecord = saveResult[index];
                    if(saveResultRecord.isSuccess()){
                      capMapToUpdate.put(capRecordList[index].Id,capRecordList[index]);
                    } 
                  }
                }
              
            //    WB_PBEP_Product_CreationHandler pbepHandler = new WB_PBEP_Product_CreationHandler();
            //    pbepHandler.insertOrUpdatePriceBookEntryPeriod(newClientAvailMap.values());
              }catch(Exception ex){
                System.debug(LoggingLevel.INFO,'Exception in createClientAvailPrice '+ex.getMessage());
              }
              
             WB_ClientAvailPriceHandler.recursiveInsert = false; 
          }
          
        }
        
        return capMapToUpdate;
        
    }
    
    //This method invoked onBefore Insert. Validates input data and populates Price values.
    public void populatePrice(List<Client_Avail_Price__c> newClientAvailPriceInsertList){
        
        if(newClientAvailPriceInsertList == null || newClientAvailPriceInsertList.isEmpty())
          return;
          
        List<Client_Avail_Price__c> filteredCAPList = new List<Client_Avail_Price__c>();
        String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); 
        Set<String> picklistValues = WB_PriceUtility.getCAPCategoryPicklistValues();
        
        for(Client_Avail_Price__c capRecord : newClientAvailPriceInsertList){
            
            
            if(capRecord.Type__c == WB_PriceUtility.FIRST) 
                continue;
            
            if(!WB_PriceUtility.isValidData(capRecord,null,picklistValues,WB_PriceUtility.INSERT_OP)){
              continue;
            }
                
            if(capRecord.RecordTypeId == null)
                capRecord.RecordTypeId =  recTypeId;
                    
            filteredCAPList.add(capRecord);
            
        }
        
        if(filteredCAPList.size() > 0){
            String objectName = 'CAP';
            WB_PriceUtility.checkPriceMatch(filteredCAPList,null,null,WB_PriceUtility.INSERT_OP);
            //Publish to Client Flag changes
            //WB_PriceUtility.setPublishFlagToClient(filteredCAPList,objectName);
        }
        
      
    }
   
    //This method invoked onBefore Update. Validates input data and updates Price values.
    public void updatePrice(Map<Id,Client_Avail_Price__c> newClientAvailPriceMap,Map<Id,Client_Avail_Price__c> oldClientAvailPriceMap){
        
        if(newClientAvailPriceMap == null || newClientAvailPriceMap.isEmpty())
          return;
          
        Map<String,Client_Avail_Price__c> filteredCAPMap = new Map<String,Client_Avail_Price__c>();
        Map<String,String> errorMap = new Map<String,String>();
        Map<Id,Client_Avail_Price__c> capAnnouncementMap = new Map<Id,Client_Avail_Price__c>([Select Id,Title_Content_Type__c,Client_Avail__c,Client_Avail_Status__c,Client_Avail__r.Status__c,Client_Avail__r.Price_Tier_Text__c,Client_Avail__r.Episode_Price_Tier__c,Client_Avail__r.Start_Date__c,Type__c,Client_Avail__r.Commercial_Avail__r.Country_Code__c,Client_Avail__r.Playlist__c,Client_Avail__r.Lock_Pricing_Update__c,Client_Avail__r.Parent_Client_Avail__r.Status__c,Client_Avail__r.Parent_Client_Avail__r.Episode_Price_Tier__c,Client_Avail__r.Parent_Client_Avail__r.Episode_Price__c,(Select Id,Name,Announcement_Date__c,Client_Start__c from Announcement_Records__r Order by Client_Start__c desc Limit 1) from Client_Avail_Price__c where Id in :newClientAvailPriceMap.keySet()]);
        Set<String> picklistValues = WB_PriceUtility.getCAPCategoryPicklistValues();
        List<Client_Avail_Price__c> filteredCAPList = new List<Client_Avail_Price__c>();
         
         
        //Map<String,Integer> countryOffsetMap = WB_PriceUtility.getCountryOffset();
        
        List<String> seasonCAIDList = new List<String>();
        List<String> episodeCAPIDList = new List<String>();
        for(Client_Avail_Price__c capRecord:newClientAvailPriceMap.values()){
          if(capAnnouncementMap.get(capRecord.Id).Title_Content_Type__c == WB_PriceUtility.SEASON){
            seasonCAIDList.add(capRecord.Client_Avail__c);
          }else if(capAnnouncementMap.get(capRecord.Id).Title_Content_Type__c == WB_PriceUtility.EPISODE){
            episodeCAPIDList.add(capRecord.Id);
          }
        
        }
        
        Map<String,List<Client_Avail__c>> seasonEpisodeMap = WB_PriceUtility.getSeasonEpisodeAvails(seasonCAIDList);
        
        //Map<Id,Client_Avail_Price__c> episodeMap = WB_PriceUtility.getEpisodeCAPs(episodeCAPIDList);
        //Query Episode Client Avails for All Seasons.
        for(Client_Avail_Price__c capRecord:newClientAvailPriceMap.values()){
            
            Client_Avail_Price__c oldCapRecord = oldClientAvailPriceMap.get(capRecord.Id);
            Boolean isValid = true;
            if(!WB_PriceUtility.isValidData(capRecord,oldCapRecord,picklistValues,WB_PriceUtility.UPDATE_OP)){
              isValid = false;
            } 
            
            if(capAnnouncementMap.get(capRecord.Id).Title_Content_Type__c == WB_PriceUtility.SEASON && capRecord.Episode_Price_Tier__c != oldCapRecord.Episode_Price_Tier__c && capRecord.Episode_Price_Tier__c == WB_PriceUtility.PRICE_TIER_TBD){
            if(!WB_PriceUtility.isSeasonDataValid(capRecord,capAnnouncementMap.get(capRecord.Id),seasonEpisodeMap)){
              capRecord.addError(WB_PriceUtility.SEASON_WITH_PLY_TBD);
                isValid = false; 
              }
          }
            
            if(capAnnouncementMap.get(capRecord.Id).Title_Content_Type__c == WB_PriceUtility.EPISODE && capRecord.Price_Tier__c != oldCapRecord.Price_Tier__c && capRecord.Price_Tier__c == WB_PriceUtility.PRICE_TIER_TBD){
              //Episode Avails cannot be confirmed with a TBD price tier. 
              if(!WB_PriceUtility.isEpiodeDataValid(capRecord,capAnnouncementMap.get(capRecord.Id))){
                capRecord.addError(WB_PriceUtility.EPISODE_TBD_CONF);
                isValid = false; 
              }  
            }
              
            
            if(capRecord.Type__c == WB_PriceUtility.FIRST && capRecord.Effective_Date__c != capAnnouncementMap.get(capRecord.Id).Client_Avail__r.Start_Date__c){
              capRecord.addError(WB_PriceUtility.FIRST_CAP_INV_DT);
              isValid = false;
            }
            
            //ER-004159 - HBO/Turner: Ability to Manually override Episode price - changes
            if(capAnnouncementMap.get(capRecord.Id).Title_Content_Type__c == WB_PriceUtility.EPISODE && !capRecord.Episode_Price_Override__c && (capRecord.Episode_Price_Override__c != oldCapRecord.Episode_Price_Override__c)){
                
                if(capRecord.Expiry_Date__c < System.Today()){
                    capRecord.addError('Episode Price Override cannot be turned off for History Expired CAP record.');
                    isValid = false;
                }else if((capRecord.Price_Tier__c != Null && capRecord.Price_Tier__c != capAnnouncementMap.get(capRecord.Id).Client_Avail__r.Parent_Client_Avail__r.Episode_Price_Tier__c)  ||
                         (capRecord.Price__c != Null && capRecord.Price__c != capAnnouncementMap.get(capRecord.Id).Client_Avail__r.Parent_Client_Avail__r.Episode_Price__c) ){
                    
                    capRecord.addError('Episode Price Override cannot be turned off unless Epiosde Price value is same as that of Season Client Avail Price values.');
                    isValid = false;
                }
                
            }
            
            if(!isValid){
              errorMap.put(capRecord.Client_Avail__c,'Invalid Data');
              continue;
            }
            
             filteredCAPMap.put(capRecord.id,capRecord);
        }
        
        Set<String> successCaps = filteredCAPMap.keySet();
        for(String capId:successCaps){
          Client_Avail_Price__c capRecord = filteredCAPMap.get(capId);
          if(errorMap.get(capRecord.Client_Avail__c) != null){
            capRecord.addError(errorMap.get(capRecord.Client_Avail__c));
            filteredCAPMap.remove(capRecord.Id);
          }
          
        }
        
        if(filteredCAPMap.size() > 0){
            String objectName = 'CAP';
            filteredCAPList = filteredCAPMap.values();
          
            WB_PriceUtility.checkPriceMatch(filteredCAPMap.values(),oldClientAvailPriceMap,capAnnouncementMap,WB_PriceUtility.UPDATE_OP);
            //Publish to Client Flag changes
            //WB_PriceUtility.setPublishFlagToClient(filteredCAPList,objectName);
        }
        
    }
    
    public void calculateExpiryDates(Map<Id,Client_Avail_Price__c> newClientAvailPriceMap,String operation){
      calculateExpiryDates(newClientAvailPriceMap,operation,null);
    }
    
    //This method sets Dates for CAP record as CAP records are added,updated and deleted.    
    public void calculateExpiryDates(Map<Id,Client_Avail_Price__c> newClientAvailPriceMap,String operation,Map<Id,Client_Avail_Price__c> oldClientAvailPriceMap){
      
      if(newClientAvailPriceMap == null || newClientAvailPriceMap.isEmpty()) 
          return;
          
        String ppRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME);
        String tpRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME);
        
        Set<String> excludedRecords = new Set<String>();
        
        Map<String,List<Client_Avail_Price__c>> clientAvailCAPListMap = new Map<String,List<Client_Avail_Price__c>>();
        for(Client_Avail_Price__c cap : newClientAvailPriceMap.values()){
            
            if( clientAvailCAPListMap.get(cap.Client_Avail__c) == null)
                clientAvailCAPListMap.put(cap.Client_Avail__c,new List<Client_Avail_Price__c>());
            
            clientAvailCAPListMap.get(cap.Client_Avail__c).add(cap);
        }
        
                
        Map<String,List<Client_Avail_Price__c>> filteredCAPMap = new Map<String,List<Client_Avail_Price__c>>();
        Map<Id,Boolean> isDifferentProviderMap = new Map<Id,Boolean>();
        
        
        Map<Id,Client_Avail__c> clientAvailMap = new Map<Id,Client_Avail__c>([Select Id,Pricing__c,Price__c,Price_Tier_Text__c,Episode_Price__c,Episode_Price_Tier__c,SR_Price__c,SR_Per_Episode__c,Start_Date__c,End_Date__c,Title_Content_Type__c,Parent_Client_Avail__c, APO_Date__c,Commercial_Avail__r.Country_Code__c,DisplayStudio__c,Storefront__r.HBO_Transfer_Date__c,Storefront__r.Turner_Transfer_Date__c,
                                            (Select Id,Client_Avail__c,Pricing__c,Price__c,Price_Tier__c,Episode_Price__c,Episode_Price_Tier__c,SR_Price__c,SR_Per_Episode__c,Effective_Date__c,Expiry_Date__c,Title_Content_Type__c,Category__c,Price_Code__c,Announce_Override__c,RecordTypeId,Client_Avail_Status__c,Type__c, Title__c,CAP_Rate_Card__c,CAP_Rate_Card__r.Start_Date__c,Episode_Rate_Card__c, Episode_Pricing__c, CAP_CRM_Country__c,Contract_Provider__c,Provider__c,CAP_EMA_DisplayName__c from Client_Avail_Prices__r where RecordTypeId=:ppRecTypeId  order by Effective_Date__c,LastModifiedDate) 
                                            from Client_Avail__c where Id in :clientAvailCAPListMap.keySet()] );
                                            
        
        //PreOrder Change - on price update in CA window                                     
        List<Client_Avail_Price__c> capRecordToInsert = new List<Client_Avail_Price__c>();
        Map<String,String> seasonCAIDErrorMAP = new Map<String,String>();
        for(String clientAvailId:clientAvailMap.keySet()){
            Client_Avail__c caRecord = clientAvailMap.get(clientAvailId);
            filteredCAPMap.put(clientAvailId,new List<Client_Avail_Price__c>());
            
            Boolean removePriceRecords = false;
            Boolean isExempt = false; 
            Client_Avail_Price__c prevRecord = null;
            
            //PreOrder Change 
            Client_Avail_Price__c firstRecord = null;
            Client_Avail_Price__c nextPreOrderRecord = null;
            String CAPId = null;
            
            for(Client_Avail_Price__c capRecord:caRecord.Client_Avail_Prices__r){
              
              if(caRecord.Title_Content_Type__c == WB_PriceUtility.EPISODE && seasonCAIDErrorMAP.keySet().contains(caRecord.Parent_Client_Avail__c)){
                if(newClientAvailPriceMap.get(capRecord.Id) != null){
                  newClientAvailPriceMap.get(capRecord.Id).addError(seasonCAIDErrorMAP.get(caRecord.Parent_Client_Avail__c));
                }
                continue;
              }
              
              
              //PreOrder Changes start
              for(Client_Avail_Price__c  capRec:caRecord.Client_Avail_Prices__r){
                //To set first CAP's value on PreOrder CAP on price Change
                if(capRec.Effective_Date__c == caRecord.Start_Date__c || capRec.Type__c ==  WB_PriceUtility.FIRST){
                  firstRecord = capRec;
                  break;
                }
              }
              
              Map<String,Integer> countryOffsetMap = WB_PriceUtility.getCountryOffset();
        DateTime currentTime = System.now();
              
             if(firstRecord!= NULL && newClientAvailPriceMap.containsKey(firstRecord.Id) && operation == WB_PriceUtility.UPDATE_OP){
                Client_Avail_Price__c updateCAPNew = newClientAvailPriceMap.get(firstRecord.Id);
                    Client_Avail_Price__c updateCAPOld = oldClientAvailPriceMap.get(firstRecord.Id);
                    
                //PreOrder Change - CA price update and PreOrder CAP is in future
                if(capRecord.Effective_Date__c < caRecord.Start_Date__c && (updateCAPNew.Price_Tier__c != updateCAPOld.Price_Tier__c || updateCAPNew.Price__c != updateCAPOld.Price__c 
                                                  || (caRecord.Title_Content_Type__c == WB_PriceUtility.SEASON && (updateCAPNew.Episode_Price_Tier__c != updateCAPOld.Episode_Price_Tier__c || updateCAPNew.Episode_Price__c != updateCAPOld.Episode_Price__c)))){
                  
                  /*String countryCode = caRecord.Commercial_Avail__r.Country_Code__c;
                  Boolean isCurrentPrice = WB_PriceUtility.isCurrentPrice(capRecord,countryCode,countryOffsetMap,currentTime);
                  
                  Datetime capEffectiveDate = datetime.newInstance(capRecord.Effective_Date__c.year(), capRecord.Effective_Date__c.month(),capRecord.Effective_Date__c.day());
                  Date capEffectiveGMTDate = capEffectiveDate.dateGMT();
                  
                  Datetime capExpiryDate = datetime.newInstance(capRecord.Expiry_Date__c.year(), capRecord.Expiry_Date__c.month(),capRecord.Expiry_Date__c.day());
                  Date capExpiryGMTDate = capExpiryDate.dateGMT();*/
                  
                  if( (capRecord.Effective_Date__c  > System.today() && capRecord.Effective_Date__c == caRecord.APO_Date__c) || capRecord.Effective_Date__c  == System.today()){
                    WB_PriceUtility.assignPricingValues(firstRecord,capRecord);
                    filteredCAPMap.get(clientAvailId).add(capRecord);
                  }else if(capRecord.Effective_Date__c < System.today() && capRecord.Expiry_Date__c > System.today()){
                    
                    for(Integer count = 0; count < caRecord.Client_Avail_Prices__r.size(); count ++){
                      //Fetch first CAP record 
                      /*if(caRecord.Client_Avail_Prices__r[count].Type__c ==  WB_PriceUtility.FIRST){
                        firstRecord = caRecord.Client_Avail_Prices__r[count];
                      }*/
                      //Fetch Repriced PreOrder CAP record to compare the consecutive price values
                      if(caRecord.Client_Avail_Prices__r[count] ==  capRecord && caRecord.Client_Avail_Prices__r[count].Expiry_Date__c != caRecord.Start_Date__c - 1){
                        nextPreOrderRecord = caRecord.Client_Avail_Prices__r[count + 1];
                      }
                    }
                    
                    //If Preorder Repriced CAP and First CAP in CA window has consecutive price value,then break PreOrder first CAP and Preorder Repriced CAP should start from today.
                    if(nextPreOrderRecord != null && WB_PriceUtility.isCAPPriceSame(firstRecord,nextPreOrderRecord)){
                      nextPreOrderRecord.Effective_Date__c = system.Today(); //review
                      capRecord.Expiry_Date__c = system.Today() - 1; //review
                      filteredCAPMap.get(clientAvailId).add(capRecord);
                      filteredCAPMap.get(clientAvailId).add(nextPreOrderRecord);
                    } else if(!WB_PriceUtility.isCAPPriceSame(firstRecord,capRecord)){ //If PreOrder CAP is already started and First CAP in CA window updates, then reprice in PreOrder window with new updated price starting today.
                        
                      Client_Avail_Price__c repriceRecord = capRecord.clone(false, true, false, false) ;
                      WB_PriceUtility.assignPricingValues(firstRecord,repriceRecord);
                      repriceRecord.Effective_Date__c = system.Today(); //review
                      repriceRecord.Expiry_Date__c = capRecord.Expiry_Date__c; //review
                      repriceRecord.Type__c = WB_PriceUtility.PREORDER;
                      capRecord.Expiry_Date__c = system.Today() - 1; //review
                      //Incase of new PreOrder CAP insertion, need this flag for further reference at line no 416
                      isExempt = true;
                      CAPId = capRecord.Id;
                      filteredCAPMap.get(clientAvailId).add(capRecord);
                        
                        
                      //Reprice PreOrder CAP to be inserted 
                        capRecordToInsert.add(repriceRecord);
                    }
                  }
                  
                  
                }
              }//PreOrder Changes start
              
              
              
              
              //PreOrder CAP changes
              if(capRecord.Effective_Date__c < caRecord.Start_Date__c &&  capRecord.Type__c == null ){
                capRecord.Type__c = WB_PriceUtility.PREORDER;
              } else if(capRecord.Type__c == null && capRecord.Effective_Date__c > caRecord.Start_Date__c){
                capRecord.Type__c = WB_PriceUtility.REPRICE;
              }
              
                if(prevRecord == null){ 
                    prevRecord=capRecord;
                    continue;
                }
               
               
               
                if(prevRecord.Effective_Date__c == capRecord.Effective_Date__c){
               
             if(caRecord.Title_Content_Type__c == WB_PriceUtility.EPISODE)
                    seasonCAIDErrorMAP.put(caRecord.Parent_Client_Avail__c,WB_PriceUtility.SAME_DATE_ERROR);
                           
             if(operation == WB_PriceUtility.INSERT_OP || operation == WB_PriceUtility.UPDATE_OP){
               WB_PriceUtility.addError(prevRecord,capRecord,newClientAvailPriceMap,WB_PriceUtility.SAME_DATE_ERROR,excludedRecords);
               removePriceRecords = true;
               break;
             }               
                }
                
                
                //ER-003619 - HBO/Turner - Allow Identical Re-Prices For new Contracts start
                Boolean isDifferentProvider = false;
                if(capRecord.Provider__c == WB_PriceUtility.HBO){
                    if((capRecord.Provider__c != capRecord.Contract_Provider__c) && (capRecord.Effective_Date__c == caRecord.Storefront__r.HBO_Transfer_Date__c)){
                        isDifferentProvider = true;
                    }
                }
                
                if(capRecord.Provider__c == WB_PriceUtility.TURNER){
                    if((capRecord.Provider__c != capRecord.Contract_Provider__c) && (capRecord.Effective_Date__c == caRecord.Storefront__r.Turner_Transfer_Date__c)){
                        isDifferentProvider = true;
                    }
                }
                
                if((!isDifferentProvider) && capRecord.CAP_Rate_Card__c != Null && (capRecord.Effective_Date__c == capRecord.CAP_Rate_Card__r.Start_Date__c)){
                    isDifferentProvider = true;
                }
                
               isDifferentProviderMap.put(capRecord.Id,isDifferentProvider);
                //ER-003619 - HBO/Turner - Allow Identical Re-Prices For new Contracts end
                if(prevRecord.Expiry_Date__c > capRecord.Effective_Date__c){  
                    
                    if(WB_PriceUtility.isCAPPriceSame(prevRecord,capRecord) && 
                    (( WB_PriceUtility.PriceTypeSet.contains(prevRecord.Type__c) && WB_PriceUtility.PriceTypeSet.contains( capRecord.Type__c)) || (prevRecord.Type__c == WB_PriceUtility.PREORDER && capRecord.Type__c == WB_PriceUtility.PREORDER  ))){
                        if(!isDifferentProvider){
                            if(caRecord.Title_Content_Type__c == WB_PriceUtility.EPISODE)
                            seasonCAIDErrorMAP.put(caRecord.Parent_Client_Avail__c,WB_PriceUtility.DATE_OVERLAP_ERROR);
                                 
                            if(operation == WB_PriceUtility.INSERT_OP || operation == WB_PriceUtility.UPDATE_OP){
                                WB_PriceUtility.addError(prevRecord,capRecord,newClientAvailPriceMap,WB_PriceUtility.DATE_OVERLAP_ERROR,excludedRecords);
                                removePriceRecords = true; 
                                break;
                            }
                            
                        }
                        
                    }
                    
                    if(capRecord.Expiry_Date__c == null || prevRecord.Expiry_Date__c > capRecord.Expiry_Date__c)
                          capRecord.Expiry_Date__c = prevRecord.Expiry_Date__c;
                          
                  prevRecord.Expiry_Date__c = capRecord.Effective_Date__c.adddays(-1);
                      
                     filteredCAPMap.get(clientAvailId).add(prevRecord);
                     filteredCAPMap.get(clientAvailId).add(capRecord);
                    
                }else if(prevRecord.Expiry_Date__c < capRecord.Effective_Date__c.adddays(-1) && !(isExempt && CAPId == prevRecord.Id)){ //Addition of isExempt flag check,when new PreOrder CAP is inserted in PreOrder window due to CA Price update, it should not update Previous PreOrder record  
                  
                    prevRecord.Expiry_Date__c = capRecord.Effective_Date__c.adddays(-1);
                    filteredCAPMap.get(clientAvailId).add(prevRecord);
                }else if(prevRecord.Expiry_Date__c == capRecord.Effective_Date__c){
                
                  if(caRecord.Title_Content_Type__c == WB_PriceUtility.EPISODE)
                    seasonCAIDErrorMAP.put(caRecord.Parent_Client_Avail__c,WB_PriceUtility.INSUFF_DATE_RANGE_ERROR);
                    
                    if(operation == WB_PriceUtility.INSERT_OP || operation == WB_PriceUtility.UPDATE_OP){
                        WB_PriceUtility.addError(prevRecord,capRecord,newClientAvailPriceMap,WB_PriceUtility.INSUFF_DATE_RANGE_ERROR,excludedRecords);
                        removePriceRecords = true;
                        break;
                    }else if(operation == WB_PriceUtility.DELETE_OP){
                        //NA
                    }
                }
                if(prevRecord.Expiry_Date__c == capRecord.Effective_Date__c.addDays(-1)){
                   
                  if(WB_PriceUtility.isCAPPriceSame(prevRecord,capRecord) && 
                    (( WB_PriceUtility.PriceTypeSet.contains(prevRecord.Type__c) && WB_PriceUtility.PriceTypeSet.contains( capRecord.Type__c)) || (prevRecord.Type__c == WB_PriceUtility.PREORDER && capRecord.Type__c == WB_PriceUtility.PREORDER  ))){
                        if(!isDifferentProvider){
                            if(caRecord.Title_Content_Type__c == WB_PriceUtility.EPISODE)
                               seasonCAIDErrorMAP.put(caRecord.Parent_Client_Avail__c,WB_PriceUtility.DATE_OVERLAP_ERROR);
                            //if(operation == WB_PriceUtility.INSERT_OP || operation == WB_PriceUtility.UPDATE_OP){
                            WB_PriceUtility.addError(prevRecord,capRecord,newClientAvailPriceMap,WB_PriceUtility.DATE_OVERLAP_ERROR,excludedRecords);
                            removePriceRecords = true;
                            break;
                        //}
                        }
                     
                    }
                }
                
                prevRecord = capRecord;
            }
            if(removePriceRecords){
                filteredCAPMap.remove(clientAvailId);
                if(caRecord.Title_Content_Type__c == WB_PriceUtility.EPISODE){
                  //remove all CAPs with parentCA as caRecord Parent from filteredCAPMap.
                  WB_PriceUtility.removeEpisodeCAP(caRecord,filteredCAPMap,seasonCAIDErrorMAP,clientAvailMap,newClientAvailPriceMap,excludedRecords);
                }
            }else{
                if(prevRecord != null && prevRecord.Expiry_Date__c != caRecord.End_Date__c){
                    prevRecord.Expiry_Date__c = caRecord.End_Date__c;
                    filteredCAPMap.get(clientAvailId).add(prevRecord);
                }
            }
        }
        
        List<Client_Avail_Price__c> changedCAPRecords = new List<Client_Avail_Price__c>();
        if(filteredCAPMap.values().size() > 0){
            Set<String> filteredCAPSet = new Set<String>(); 
            for(List<Client_Avail_Price__c> capList:filteredCAPMap.values()){
                for(Client_Avail_Price__c capRecord:capList){
                    if(!filteredCAPSet.contains(capRecord.Id)){
                        changedCAPRecords.add(capRecord);
                        filteredCAPSet.add(capRecord.Id);
                    }   
                }
            }
        }
            
        //********************Episode CAP - Start ***************//
        List<Client_Avail_Price__c> seasonCAPList = new List<Client_Avail_Price__c>();
        if(operation == WB_PriceUtility.INSERT_OP){
          for(Client_Avail_Price__c capRecord:newClientAvailPriceMap.values()){
              Client_Avail__c caRecord = clientAvailMap.get(capRecord.Client_Avail__c);
              if(capRecord.Title_Content_Type__c == WB_PriceUtility.SEASON && !excludedRecords.contains(capRecord.id)){
              Client_Avail_Price__c prevRecord = WB_PriceUtility.getPreviousPrice(capRecord,caRecord.Client_Avail_Prices__r);
                Boolean isDifferentProvider;
              if(isDifferentProviderMap != Null && isDifferentProviderMap.get(capRecord.Id) != Null){
                  isDifferentProvider = isDifferentProviderMap.get(capRecord.Id);
              }
              if(prevRecord == null || capRecord.Episode_Price__c != prevRecord.Episode_Price__c || 
                  capRecord.Episode_Price_Tier__c != prevRecord.Episode_Price_Tier__c || 
                  (isDifferentProvider && (capRecord.Episode_Price__c == prevRecord.Episode_Price__c || capRecord.Episode_Price_Tier__c == prevRecord.Episode_Price_Tier__c))){
            
            seasonCAPList.add(capRecord);
                }                
              }  
          }
          
          List<Client_Avail_Price__c> changedSeasonCAPs = new List<Client_Avail_Price__c>();
          for(Client_Avail_Price__c seasonCAP:seasonCAPList){
            for(Client_Avail_Price__c changedCAP:changedCAPRecords){
              if(seasonCAP.Id == changedCAP.Id){
                changedSeasonCAPs.add(changedCAP);
                break;
              }
            }
          }
          
          seasonCAPList = changedSeasonCAPs;
        
        }else if(operation == WB_PriceUtility.UPDATE_OP){
          for(Client_Avail_Price__c capRecord:newClientAvailPriceMap.values()){
              if(capRecord.Title_Content_Type__c == WB_PriceUtility.SEASON && !excludedRecords.contains(capRecord.id)){
                if(capRecord.Episode_Price__c != oldClientAvailPriceMap.get(capRecord.id).Episode_Price__c || 
                      capRecord.Episode_Price_Tier__c != oldClientAvailPriceMap.get(capRecord.id).Episode_Price_Tier__c || 
                      capRecord.Effective_Date__c != oldClientAvailPriceMap.get(capRecord.id).Effective_Date__c || 
                      capRecord.Expiry_Date__c != oldClientAvailPriceMap.get(capRecord.id).Expiry_Date__c  || 
                      capRecord.Category__c != oldClientAvailPriceMap.get(capRecord.id).Category__c || 
                      capRecord.Announce_Override__c != null){// ||  capRecord.Client_Avail_Status__c != null){
              
              seasonCAPList.add(capRecord);                  
                }
              }
          }
        }else if(operation == WB_PriceUtility.DELETE_OP){
        for(Client_Avail_Price__c capRecord:newClientAvailPriceMap.values()){
          if(capRecord.Title_Content_Type__c == WB_PriceUtility.SEASON && !excludedRecords.contains(capRecord.id)){
              seasonCAPList.add(capRecord);
          }
        }
        }
        
        
        Map<String,Client_Avail__c> seasonEpisodeCAMap = new Map<String,Client_Avail__c>();
        if(seasonCAPList.size() > 0 && !WB_PriceUtility.SKIP_EPISODE_PROCESS){
          WB_PriceUtility.SKIP_EPISODE_PBEP_PROCESS = true; 
          try{
            
            List<Client_Avail_Price__c> failedSeasonList = processEpisodeCAP(seasonCAPList,operation,newClientAvailPriceMap,oldClientAvailPriceMap,seasonEpisodeCAMap);
            //Get failed records. Remove those from changedCAPRecords. add it in Excluded Records.
            WB_PriceUtility.removeFailedSeasonRecords(changedCAPRecords,failedSeasonList,excludedRecords);
          }catch(Exception ex){
            System.debug(LoggingLevel.INFO,'Exception in processEpisodeCAP '+ex.getMessage());
          }
          WB_PriceUtility.SKIP_EPISODE_PBEP_PROCESS = false; 
        }
        
        //******************Episode CAP - End *****************//
            
        Map<String,Client_Avail_Price__c> finalCAPMapForPriceUpdate = new Map<String,Client_Avail_Price__c>();
        if(changedCAPRecords.size() > 0 ||capRecordToInsert.size() > 0){
            
            changedCAPRecords.addAll(capRecordToInsert);
            Database.UpsertResult[] updateResultList = Database.upsert(changedCAPRecords,false);
            for(Integer index=0;index<updateResultList.size();index++){
                Database.UpsertResult updateResult = updateResultList[index]; 
                
                if(updateResult.isSuccess()){
                  finalCAPMapForPriceUpdate.put(changedCAPRecords.get(index).Id,changedCAPRecords.get(index));
                }else{
                    for(Database.Error err : updateResult.getErrors()) {
                      System.debug(LoggingLevel.INFO,'updateResult Error ->'+ err.getMessage());
                  }
                }
            }
        }
      
        List<Client_Avail_Price__c> capAnnOverrideStatusClearList = new List<Client_Avail_Price__c>();
        //Take CAP records passed to this method and changedCAPRecords. Remove failed records in Above update from this list.
        if(operation != WB_PriceUtility.DELETE_OP){
            for(Client_Avail_Price__c capRecord:newClientAvailPriceMap.values()){
                if(!excludedRecords.contains(capRecord.Id)){
                    if(finalCAPMapForPriceUpdate.get(capRecord.Id) == null)
                      finalCAPMapForPriceUpdate.put(capRecord.Id,capRecord);
                      
                    capAnnOverrideStatusClearList.add(capRecord);
                    
                }
            }
        }
        
        Map<String,String> failedCAMap = null;
        if(finalCAPMapForPriceUpdate.values().size() > 0){
          failedCAMap = updateClientAvailPriceFields(finalCAPMapForPriceUpdate.values(),newClientAvailPriceMap);
        }
        
        /*if(seasonEpisodeCAMap.size() > 0){
         Database.SaveResult[] updateResultList = Database.update(seasonEpisodeCAMap.values(),false);   
        }*/
        //Start - To clear announcement override on CAP after CA update. This can be removed if we need to keep these values on CAP.
        if(capAnnOverrideStatusClearList.size() > 0){
          List<Client_Avail_Price__c> fieldsClearedList = new List<Client_Avail_Price__c>();
          for(Client_Avail_Price__c capRecord:capAnnOverrideStatusClearList){
            if(failedCAMap != null && failedCAMap.get(capRecord.Client_Avail__c) != null){
              capRecord.addError(failedCAMap.get(capRecord.Client_Avail__c));
              
            }else{
                if(capRecord.Announce_Override__c != null){
                fieldsClearedList.add(new  Client_Avail_Price__c(Id=capRecord.Id,Announce_Override__c=null));        
            }
            }
          }  
          
          if(fieldsClearedList.size() > 0){
            Database.SaveResult[] updateResultList = Database.update(fieldsClearedList,false);
          }
        }
        //End - To clear announcement override and CA status fields on CAP after CA update
    } 
    
    
    private List<Client_Avail_Price__c> processEpisodeCAP(List<Client_Avail_Price__c> seasonCAPList,String operation,Map<Id,Client_Avail_Price__c> newClientAvailPriceMap,Map<Id,Client_Avail_Price__c> oldClientAvailPriceMap,Map<String,Client_Avail__c> seasonEpisodeCAMap){
      
        String ppRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME);
        String tpRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME);
        
     // Map<String,Integer> countryOffsetMap = WB_PriceUtility.getCountryOffset();
     // DateTime currentTime = System.now(); 
        
        List<String> caIDList = new List<String>();
        for(Client_Avail_Price__c seasonCAP:seasonCAPList){
          caIDList.add(seasonCAP.Client_Avail__c);
        }
        Map<String,Client_Avail__c> episodeCAMap = new Map<String,Client_Avail__c>([Select Id,CurrencyIsoCode,Pricing__c,Price__c,Price_Tier_Text__c,Episode_Price__c,Episode_Price_Tier__c,SR_Price__c,SR_Per_Episode__c,Start_Date__c,End_Date__c,Title_Content_Type__c,Parent_Client_Avail__c,Local_Data_Category_Picklist__c,Price_Code__c,Lock_Pricing_Update__c,Title__c,Commercial_Avail__r.Country_Code__c,Local_Title__r.Local_TV_Air_Date__c,CA_Rate_Card__c,Episode_Rate_Card__c,Episode_Pricing__c,
                                                (Select Id,Client_Avail__c,Pricing__c,Price__c,Price_Tier__c,Episode_Price__c,Episode_Price_Tier__c,SR_Price__c,SR_Per_Episode__c,Effective_Date__c,Expiry_Date__c,Title_Content_Type__c,Category__c,Type__c,RecordTypeId,CAP_Rate_Card__c,Episode_Rate_Card__c,Episode_Pricing__c,CAP_CRM_Country__c,Episode_Price_Override__c from Client_Avail_Prices__r where RecordTypeId=:ppRecTypeId order by Effective_Date__c,LastModifiedDate) 
                                                from Client_Avail__c where Parent_Client_Avail__c in :caIDList]);
        List<Client_Avail_Price__c> episodeCAPList = new List<Client_Avail_Price__c>();
        List<Client_Avail_Price__c> toBeUpsertedEpisodeCAPList = new List<Client_Avail_Price__c>();
        Map<String,String> caIdErrorMap = new Map<String,String>();
        List<Client_Avail_Price__c> failedSeasonCAPList = new List<Client_Avail_Price__c>();
        
        //SINC0916133 - Start
        if(episodeCAMap == null || episodeCAMap.size() == 0){
          return failedSeasonCAPList;  
        }
        //SINC0916133 - End
        
        //ER-004159 - HBO/Turner: Ability to Manually override Episode price - changes
        Map<String,Boolean> epOvrrCAMap = WB_PriceUtility.trackEpOverrEnabledCAMap(episodeCAMap.values());
        
      if(operation == WB_PriceUtility.INSERT_OP){

        for(Client_Avail_Price__c seasonCAP:seasonCAPList){
              for(Client_Avail__c episodeCA:episodeCAMap.values()){
        
        if(seasonCAP.Client_Avail__c == episodeCA.Parent_Client_Avail__c){
                  
                  if(seasonCAP.Expiry_Date__c < episodeCA.Start_Date__c) continue;
                  
                  if(seasonCAP.Effective_Date__c <= episodeCA.Start_Date__c){
                    //Get First CAP and update Price if end date is same as seasonCAP, otherwise create new CAP with new price and make it First. skip trigger for these.
                  
                    Client_Avail_Price__c episodeFirstCAP = episodeCA.Client_Avail_Prices__r[0];
                    
                    //ER-004159 - HBO/Turner: Ability to Manually override Episode price - changes
                    //If Episode CAP is enabled Episode Price override
                    if(episodeFirstCAP.Episode_Price_Override__c) continue;
                    
                    if(episodeFirstCAP.Expiry_Date__c == seasonCAP.Expiry_Date__c){
                      episodeFirstCAP.Price__c = seasonCAP.Episode_Price__c;
                      episodeFirstCAP.Price_Tier__c = seasonCAP.Episode_Price_Tier__c;
                      episodeFirstCAP.Category__c = seasonCAP.Category__c;
                    }else{
                      Client_Avail_Price__c newEpisodeFirstCAP = WB_PriceUtility.createEpisodeCAP(seasonCAP,episodeCA,ppRecTypeId);
                      newEpisodeFirstCAP.Expiry_Date__c = seasonCAP.Expiry_Date__c;
                      newEpisodeFirstCAP.Type__c = WB_PriceUtility.FIRST;
                      episodeFirstCAP.Effective_Date__c = newEpisodeFirstCAP.Expiry_Date__c.addDays(1); 
                      episodeFirstCAP.Type__c = null;
                      toBeUpsertedEpisodeCAPList.add(newEpisodeFirstCAP);
                    }
                    
                    toBeUpsertedEpisodeCAPList.add(episodeFirstCAP);
                    
                  }else{
                    
                    //ER-004159 - HBO/Turner: Ability to Manually override Episode price - changes
                    //Check if Season CAP lies with any of the Episode CAP and whether it is Episode Price Override enabled
                    if(WB_PriceUtility.checkSeasonCAPwithinEpisodeCAP(seasonCAP,episodeCA.Client_Avail_Prices__r)) continue;
                    
                    episodeCAPList.add(WB_PriceUtility.createEpisodeCAP(seasonCAP,episodeCA,ppRecTypeId));
                  }
                }
              }
            }
            
            
            Set<String> failedCAs = new Set<String>();
            Boolean prevInsValue = WB_ClientAvailPriceHandler.recursiveInsert;
          WB_ClientAvailPriceHandler.recursiveInsert = false;
            
          try{
            if(episodeCAPList.size() > 0){
            
              Database.SaveResult[] episodeCAPSaveResult = Database.insert(episodeCAPList,false);
            
              for(Integer index=0;index<episodeCAPList.size();index++){
                Client_Avail_Price__c episodeCAP = episodeCAPList[index];
                Client_Avail__c episodeCA = episodeCAMap.get(episodeCAP.Client_Avail__c);
                if(caIdErrorMap.get(episodeCA.Parent_Client_Avail__c) ==  null && !episodeCAPSaveResult[index].isSuccess()){
                  for(Database.Error err : episodeCAPSaveResult[index].getErrors()) {
                          caIdErrorMap.put(episodeCA.Parent_Client_Avail__c,err.getMessage());
                          failedCAs.add(episodeCA.Id);
                          break;
                      }
                    
                } 
              }
            }
      
            //System.debug(LoggingLevel.INFO,'Episode Insert, toBeUpsertedEpisodeCAPList -> '+toBeUpsertedEpisodeCAPList);

            if(toBeUpsertedEpisodeCAPList.size() > 0){
              WB_ClientAvailPriceHandler.recursiveInsert = true;
              List<Client_Avail_Price__c> finalList = new List<Client_Avail_Price__c>();
              for(Client_Avail_Price__c tobeupsertCap:toBeUpsertedEpisodeCAPList){
                if(!failedCAs.contains(tobeupsertCap.Client_Avail__c)){
                  finalList.add(tobeupsertCap);
                }
              }
              
              if(finalList.size() > 0){
                Database.upsert(finalList,false);
                updateClientAvailPriceFields(finalList,new Map<Id,Client_Avail_Price__c>());
              }
            }
            }catch(Exception ex){
            
          }
          WB_ClientAvailPriceHandler.recursiveInsert = prevInsValue;
            
        }else if(operation == WB_PriceUtility.UPDATE_OP){
          
          Map<String,Client_Avail_Price__c> newEpisodeCAPInsertMap = new Map<String,Client_Avail_Price__c>();
          Map<String,Client_Avail_Price__c> toBeDeletedCAPs = new Map<String,Client_Avail_Price__c>();
          Map<Id,Client_Avail__c> seasonCAMap = new Map<Id,Client_Avail__c>([Select Id,(Select Id,Effective_Date__c,Expiry_Date__c,Category__c,Price__c,Price_Tier__c,Episode_Price__c,Episode_Price_Tier__c,Announce_Override__c,Client_Avail_Status__c FROM Client_Avail_Prices__r WHERE RecordTypeId=:ppRecTypeId Order by Effective_Date__c) FROM Client_Avail__c where Id in :caIDList]);
           
            for(Client_Avail_Price__c seasonCAP:seasonCAPList){
              for(Client_Avail__c episodeCA:episodeCAMap.values()){
                  
                if(seasonCAP.Client_Avail__c == episodeCA.Parent_Client_Avail__c){
                  
                  if(episodeCA.Lock_Pricing_Update__c == true) continue;
                  if(seasonCAP.Expiry_Date__c < episodeCA.Start_Date__c) continue;
         
          Client_Avail_Price__c existingEpisodeCAP = WB_PriceUtility.getExistingEpisodeCAP(oldClientAvailPriceMap.get(seasonCAP.Id),episodeCA);
                
                //ER-004159 - HBO/Turner: Ability to Manually override Episode price - changes - Start
                Boolean skipEpUpdateEpPriceOverrEnabled = false;
                
                //If Episode CAP is enabled Episode Price Override, skip the update but category update should be done as existing
                if(existingEpisodeCAP != Null && existingEpisodeCAP.Episode_Price_Override__c){
                   skipEpUpdateEpPriceOverrEnabled = true;
                }else if(existingEpisodeCAP == Null && epOvrrCAMap != Null && epOvrrCAMap.containsKey(episodeCA.Id)){ //Check if either of Episode CAP is Episode Price Override, if yes continue but update Category as existing
                    skipEpUpdateEpPriceOverrEnabled = true;
                }
                
                if(skipEpUpdateEpPriceOverrEnabled){
                  if(existingEpisodeCAP == Null && seasonCAP.Type__c == WB_PriceUtility.FIRST){
                    existingEpisodeCAP = episodeCA.Client_Avail_Prices__r[0];
                  }
                  if(existingEpisodeCAP != Null && (!existingEpisodeCAP.Category__c.contains('Day After') ||
                    (existingEpisodeCAP.Category__c.contains('Day After') && (episodeCA.Local_Title__r.Local_TV_Air_Date__c == null || episodeCA.Local_Title__r.Local_TV_Air_Date__c > system.today())))){
                    
                      if(seasonCAP.Category__c != existingEpisodeCAP.Category__c){
                        existingEpisodeCAP.Category__c = seasonCAP.Category__c;
                        episodeCAPList.add(existingEpisodeCAP);
                      }
                  }
                  
                  continue;
                }
                  //ER-004159 - HBO/Turner: Ability to Manually override Episode price - changes - End
                  
                  if(existingEpisodeCAP != null){ 
                     
                    Date existingEpisodeCAPStartDate = existingEpisodeCAP.Effective_Date__c;
                    episodeCAPList.add(WB_PriceUtility.updateEpisodeCAP(seasonCAP,episodeCA,existingEpisodeCAP));//update.
                    
                    if(seasonCAP.Effective_Date__c < episodeCA.Start_Date__c){
                      // delete if there is any price with expirydate less than old episode start date. Mark above updated price as First.
                      existingEpisodeCAP.Type__c = WB_PriceUtility.FIRST;
                      Integer index = 0;
                      Decimal tempPrice = 0.01;
                      for(Client_Avail_Price__c episodeCAP:episodeCA.Client_Avail_Prices__r){
                    if(existingEpisodeCAP.Id != episodeCAP.Id && episodeCAP.Effective_Date__c < existingEpisodeCAPStartDate){
                      episodeCAP.Price_Code__c = null;
                      episodeCAP.Price__c = tempPrice;
                      episodeCAP.Type__c = null;
                      episodeCAP.Price_Tier__c = null;
                      episodeCAP.Expiry_Date__c = episodeCA.End_Date__c.addDays(-index);
                      index = index+1;
                      episodeCAP.Effective_Date__c =  episodeCA.End_Date__c.addDays(-index);
                      index = index+2;
                      tempPrice = tempPrice +0.01;
                      toBeDeletedCAPs.put(episodeCAP.Id,episodeCAP);
                    }
                  }
                    }
                  }else{//else if(seasonCAP.Episode_Price__c != oldClientAvailPriceMap.get(seasonCAP.id).Episode_Price__c || seasonCAP.Episode_Price_Tier__c != oldClientAvailPriceMap.get(seasonCAP.id).Episode_Price_Tier__c){
                    //create
                    
                    existingEpisodeCAP = episodeCA.Client_Avail_Prices__r[0];
                    if(seasonCAP.Effective_Date__c <= episodeCA.Start_Date__c){
                      episodeCAPList.add(WB_PriceUtility.updateEpisodeCAP(seasonCAP,episodeCA,existingEpisodeCAP));
                    }else{
                      //check if episode price on prev season cap is same.
                      Client_Avail_Price__c prevSeasonCAP = WB_PriceUtility.getPreviousPrice(seasonCAP,seasonCAMap.get(seasonCAP.Client_Avail__c).Client_Avail_Prices__r); 
                      if(prevSeasonCAP == null || (prevSeasonCAP.Episode_Price_Tier__c == seasonCAP.Episode_Price_Tier__c && prevSeasonCAP.Episode_Price__c == seasonCAP.Episode_Price__c)){
                        //if same, Do Nothing. No need to update dates and prices. 
                      }else if(prevSeasonCAP.Effective_Date__c < episodeCA.Start_Date__c){
                        //if not same, update existing(first) episode cap, remove 'First' and create one more cap as 'First'.
                        episodeCAPList.add(WB_PriceUtility.updateEpisodeCAP(seasonCAP,episodeCA,existingEpisodeCAP));
                        existingEpisodeCAP.Type__c = null;
                        Client_Avail_Price__c newFirstCAP = WB_PriceUtility.createEpisodeCAP(prevSeasonCAP,episodeCA,ppRecTypeId);
                        newFirstCAP.Type__c = WB_PriceUtility.FIRST;
                        newFirstCAP.Expiry_Date__c = existingEpisodeCAP.Effective_Date__c;
                        newFirstCAP.Expiry_Date__c = newFirstCAP.Expiry_Date__c.addDays(-1);
                        newEpisodeCAPInsertMap.put(episodeCA.Id,newFirstCAP);
                      }  
                    }
                    //System.debug(LoggingLevel.INFO,'Episode Update, existingEpisodeCAP null and Price change-> '+existingEpisodeCAP);
                  }
          
                }
              }
            }
            
            Boolean prevUpdtValue = WB_ClientAvailPriceHandler.recursiveUpdate; 
            WB_ClientAvailPriceHandler.recursiveUpdate = false;
            WB_PriceUtility.PLAY_LIST_UPDATE = true;
            
            Boolean isException = false;
            try{
            if(toBeDeletedCAPs.size() > 0){   
              episodeCAPList.addAll(toBeDeletedCAPs.values());
            }  
            Database.SaveResult[] episodeCAPUpdateResult = Database.update(episodeCAPList,false);
            
            for(Integer index=0;index<episodeCAPList.size();index++){
              Client_Avail_Price__c episodeCAP = episodeCAPList[index];
              Client_Avail__c episodeCA = episodeCAMap.get(episodeCAP.Client_Avail__c);
              if(!episodeCAPUpdateResult[index].isSuccess()){
                if(caIdErrorMap.get(episodeCA.Parent_Client_Avail__c) ==  null){
                  for(Database.Error err : episodeCAPUpdateResult[index].getErrors()) {
                          caIdErrorMap.put(episodeCA.Parent_Client_Avail__c,err.getMessage());
                          break;
                      }
                }
                toBeDeletedCAPs.remove(episodeCAP.Id);
                newEpisodeCAPInsertMap.remove(episodeCA.Id);  
              }
            }
            }catch(Exception ex){
              isException = true;
            }
            
            if(!isException){
              try{
                if(toBeDeletedCAPs.size() > 0)
                  Database.DeleteResult[] CAPDeleteResult = Database.delete(toBeDeletedCAPs.values(),false);
              }catch(Exception ex){
                
              }
              
              Boolean prevInsValue = WB_ClientAvailPriceHandler.recursiveInsert;
              WB_ClientAvailPriceHandler.recursiveInsert = false;
              try{
                if(newEpisodeCAPInsertMap.size() > 0)
                  Database.SaveResult[] CAPInsertResult = Database.insert(newEpisodeCAPInsertMap.values(),false);
              }catch(Exception ex){
                
              }
        WB_ClientAvailPriceHandler.recursiveInsert = prevInsValue;
            }
            
            WB_ClientAvailPriceHandler.recursiveUpdate = prevUpdtValue;
            WB_PriceUtility.PLAY_LIST_UPDATE = false;            
        }else if(operation == WB_PriceUtility.DELETE_OP){
            
            Map<String,Client_Avail_Price__c> tobeUpdatedCAPs = new Map<String,Client_Avail_Price__c>();
            List<Client_Avail_Price__c> tobeInsertedCAPs = new List<Client_Avail_Price__c>();
            List<String> seasonCAIds = new List<String>();
            for(Client_Avail_Price__c seasonCAP:seasonCAPList){
              seasonCAIds.add(seasonCAP.Client_Avail__c);
            }
            
            Map<String,Client_Avail__c> seasonCAPriceMap = new Map<String,Client_Avail__c>([Select id,(Select id,Price__c,Price_Tier__c,Episode_Price__c,Episode_Price_Tier__c,Category__c,Effective_Date__c,Expiry_Date__c,Announce_Override__c from Client_Avail_Prices__r WHERE RecordTypeId=:ppRecTypeId order by Effective_Date__c) from Client_Avail__c where Id in :seasonCAIds]);
            for(Client_Avail_Price__c seasonCAP:seasonCAPList){
              for(Client_Avail__c episodeCA:episodeCAMap.values()){
               
               if(seasonCAP.Client_Avail__c == episodeCA.Parent_Client_Avail__c){
                
                  if(seasonCAP.Expiry_Date__c < episodeCA.Start_Date__c) continue;
                  
                  Client_Avail_Price__c existingEpisodeCAP = WB_PriceUtility.getExistingEpisodeCAP(oldClientAvailPriceMap.get(seasonCAP.Id),episodeCA);
                  //if(existingEpisodeCAP is first dont delete. update price with previous Season CAP price) else if(existingEpisodeCAP is null, take first price and update price with previous Season CAP price)
                
                 //ER-004159 - HBO/Turner: Ability to Manually override Episode price - changes
                 if(existingEpisodeCAP != null && existingEpisodeCAP.Episode_Price_Override__c){
                    continue;
                 }else if(existingEpisodeCAP == Null && epOvrrCAMap != Null && epOvrrCAMap.containsKey(episodeCA.Id)){ //check if either Episode CAP is Episode Price Override enabled
                    continue;
                 }
                
                  if(existingEpisodeCAP != null && existingEpisodeCAP.Type__c != WB_PriceUtility.FIRST){
                    if(existingEpisodeCAP.Expiry_Date__c > seasonCAP.Expiry_Date__c){
                      existingEpisodeCAP.Effective_Date__c = seasonCAP.Expiry_Date__c;
                      existingEpisodeCAP.Effective_Date__c = existingEpisodeCAP.Effective_Date__c.addDays(1);
                      tobeUpdatedCAPs.put(existingEpisodeCAP.id,existingEpisodeCAP);
                    }else{
                      episodeCAPList.add(existingEpisodeCAP);                      
                    }
                  } else if(episodeCA.Start_Date__c < seasonCAP.Expiry_Date__c || episodeCA.Start_Date__c == episodeCA.End_Date__c){
                  
                List<Client_Avail_Price__c> allSeasonCAPs = new List<Client_Avail_Price__c>(); //To Hold all the Episode Unique Price records with adjusted dates.
                Client_Avail_Price__c prevSeasCAP = null;
                for(Client_Avail_Price__c seasonPrice:seasonCAPriceMap.get(seasonCAP.Client_Avail__c).Client_Avail_Prices__r){
              
                  if(seasonPrice.Expiry_Date__c == seasonCAP.Effective_Date__c.addDays(-1))
                    seasonPrice.Expiry_Date__c = seasonCAP.Expiry_Date__c;
                    
                  if(seasonPrice.Expiry_Date__c < episodeCA.Start_Date__c) continue;
                  
                  if(prevSeasCAP == null){ 
                    allSeasonCAPs.add(seasonPrice);
                    prevSeasCAP = seasonPrice;
                    continue;
                  }
                  
                  if(seasonPrice.Episode_Price__c == prevSeasCAP.Episode_Price__c && seasonPrice.Episode_Price_Tier__c == prevSeasCAP.Episode_Price_Tier__c){
                   prevSeasCAP.Expiry_Date__c = seasonPrice.Expiry_Date__c;
                   continue;    
                }else{
                  allSeasonCAPs.add(seasonPrice);
                }
                  prevSeasCAP = seasonPrice;
                
                }
                prevSeasCAP.Expiry_Date__c = episodeCA.End_Date__c;
                
                List<Client_Avail_Price__c> episodePriceList = episodeCA.Client_Avail_Prices__r;
                if(episodePriceList.size() > allSeasonCAPs.size()){
                  //System.debug(LoggingLevel.INFO,'*****Episode has More Price records than Season. Unable to adjust. Need to update manually.');
                }else{
              
                  Boolean hasPriceRecord = false;
                  for(Integer seaonCapIndex=0;seaonCapIndex < allSeasonCAPs.size();seaonCapIndex++){ 
                    Client_Avail_Price__c seasonPrice = allSeasonCAPs[seaonCapIndex];
                  
                    if(seasonPrice.Expiry_Date__c < episodeCA.Start_Date__c) continue;
                    
                    
                  
                    if(seaonCapIndex < episodePriceList.size()){
                      hasPriceRecord = true;
                      Client_Avail_Price__c  episodeCAP = episodePriceList[seaonCapIndex];

                      if(episodeCAP.Episode_Price_Override__c) continue;
                      
                      if(seasonPrice.Episode_Price__c != episodeCAP.Price__c || seasonPrice.Episode_Price_Tier__c != episodeCAP.Price_Tier__c){
                        episodeCAP.Price__c = seasonPrice.Episode_Price__c;
                        episodeCAP.Price_Tier__c = seasonPrice.Episode_Price_Tier__c;
                        tobeUpdatedCAPs.put(episodeCAP.Id,episodeCAP);
                      }
                    }else{
                      Client_Avail_Price__c episodeCAP = WB_PriceUtility.createEpisodeCAP(seasonPrice,episodeCA,ppRecTypeId);
                      if(!hasPriceRecord){
                        episodeCAP.Type__c = WB_PriceUtility.FIRST;
                        hasPriceRecord = true;
                      }
                      tobeInsertedCAPs.add(episodeCAP);
                    }
                  }
                }
                  }
                  
                  
                }
              }
            }
            
           Boolean prevDelValue = WB_ClientAvailPriceHandler.recursiveDelete;
            WB_ClientAvailPriceHandler.recursiveDelete = false;
            
            try{
            Database.DeleteResult[] episodeCAPDeleteResult = Database.delete(episodeCAPList,false);
            
            Set<String> failedEpisodeCAs = new Set<String>();
            for(Integer index=0;index<episodeCAPList.size();index++){
              Client_Avail_Price__c episodeCAP = episodeCAPList[index];
              Client_Avail__c episodeCA = episodeCAMap.get(episodeCAP.Client_Avail__c);
              if(!episodeCAPDeleteResult[index].isSuccess()){
                failedEpisodeCAs.add(episodeCA.Id);
                if(caIdErrorMap.get(episodeCA.Parent_Client_Avail__c) ==  null){
                  for(Database.Error err : episodeCAPDeleteResult[index].getErrors()) {
                          caIdErrorMap.put(episodeCA.Parent_Client_Avail__c,err.getMessage());
                          break;
                      }
                }  
              } 
            }
            
            List<Client_Avail_Price__c> finalList = new List<Client_Avail_Price__c>();
            WB_PriceUtility.PLAY_LIST_UPDATE = true;
            if(tobeUpdatedCAPs.values().size() > 0){
              Set<String> capKeySet = tobeUpdatedCAPs.keySet(); 
              for(String capId:capKeySet){
                if(!failedEpisodeCAs.contains(tobeUpdatedCAPs.get(capId).Client_Avail__c))
                  finalList.add(tobeUpdatedCAPs.get(capId));      
              }
            }
            
          Boolean prevUpdtValue = WB_ClientAvailPriceHandler.recursiveUpdate;
          WB_ClientAvailPriceHandler.recursiveUpdate = false;
          if(finalList.size() > 0){
            Database.SaveResult[] updateResultList = Database.update(finalList,false);
            for(Integer index=0;index<updateResultList.size();index++){
              for(Database.Error err : updateResultList[index].getErrors()) {
                        System.debug(LoggingLevel.INFO,'Error Message -> '+err.getMessage());
                        break;
                    }
            }
          }
            WB_ClientAvailPriceHandler.recursiveUpdate = prevUpdtValue;
            
            finalList.clear();
            for(Client_Avail_Price__c newCap:tobeInsertedCAPs){
              if(!failedEpisodeCAs.contains(newCap.Client_Avail__c))
                finalList.add(newCap);
            }
            
            Boolean prevInsValue = WB_ClientAvailPriceHandler.recursiveInsert;
            WB_ClientAvailPriceHandler.recursiveInsert = false;
            if(finalList.size() > 0){
              Database.SaveResult[] insertResultList = Database.insert(finalList,false);
            }
            WB_ClientAvailPriceHandler.recursiveInsert = prevInsValue;
            
            }catch(Exception ex){
              
            }
            WB_PriceUtility.PLAY_LIST_UPDATE = false;
            WB_ClientAvailPriceHandler.recursiveDelete = prevDelValue;
            
            
        }
        
        for(Client_Avail_Price__c seasonCAP:seasonCAPList){
          if(caIdErrorMap.get(seasonCAP.Client_Avail__c) != null){
            newClientAvailPriceMap.get(seasonCAP.Id).addError(WB_PriceUtility.EPISODE+' - '+caIdErrorMap.get(seasonCAP.Client_Avail__c));
            failedSeasonCAPList.add(seasonCAP);
          }  
        }
        
        return failedSeasonCAPList;
    }
    
    //  Update Client_Avail_Price__c start and end dates, if there is change in Client_Avail__c start/end date.
    //  No need for any validations, so Setting  isCADateChange=true to avoid Client_Avail_Price__c trigger execution.
    
    public void updateClientAvailPriceStartEndDate(Map<Id,Client_Avail__c> newClientAvailMap,Map<Id,Client_Avail__c> oldClientAvailMap){
        
        WB_ClientAvailPriceHandler.isCADateChange = true;
    //  String ppRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME);
        
        Map<String,Client_Avail_Price__c> updateCAPMap = new Map<String,Client_Avail_Price__c>();
        Map<String,Client_Avail_Price__c> toBeDeletedCAPMap = new Map<String,Client_Avail_Price__c>();
        Map<String,Client_Avail_Price__c> priceUpdateCAPMap  = new Map<String,Client_Avail_Price__c>();
        
        List<Client_Avail__c> episodeCAList = new List<Client_Avail__c>();
        
        List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
        List<Client_Avail_Price__c> capPubishToClientList = new List<Client_Avail_Price__c>();
        List<Client_Avail_Price__c> capPubishToClientUpdateList = new List<Client_Avail_Price__c>();
        List<Client_Avail__c> caPBEPList = new List<Client_Avail__c>();
        Map<String,Client_Avail_Price__c> preOderCAPMap = new Map<String,Client_Avail_Price__c>(); 
        
        try{
          
          Map<Id,Client_Avail__c> updatedClientAvailMap = new Map<Id,Client_Avail__c>([Select Id,Start_Date__c,End_Date__c,Status__c,Release_Plan_Channel__c,Storefront__c,Title_Content_Type__c,Release_Plan_Format__c, //Added SF fields for SC TO SFS Int
                                                  (Select Id,Effective_Date__c,Client_Avail__c,Account__c,Client_Avail_Status__c,Client_Avail__r.Status__c,Client_Avail__r.Release_Plan_Channel__c,Expiry_Date__c,Type__c,Pricing__c,Price__c,Price_Tier__c,SR_Price__c,Episode_Price__c,Episode_Price_Tier__c,SR_Per_Episode__c,Category__c,RecordTypeId,RecordType.Name,Publish_to_Client__c,Title_Content_Type__c,Client_Avail_Channel__c,CAP_Lifecycle__c,Country__c,CA_Start_Date__c,Announce_Override__c, Price_Code__c,CAP_Rate_Card__c,Deal_Start_Date__c,Deal_End_Date__c,Episode_Rate_Card__c,Episode_Pricing__c,CAP_CRM_Country__c,Push_to_SFS__c,Client_Avail_Format__c,Storefront__c FROM Client_Avail_Prices__r ORDER BY Effective_Date__c,RecordType.Name ASC) 
                                                  from Client_Avail__c where Id in:newClientAvailMap.keySet()] );  ////SINC1192693 -- removed Limit 1

          
          preOderCAPMap = createPreOrderClientAvailPrice(newClientAvailMap,oldClientAvailMap,updatedClientAvailMap);
          for(String clientAvailId : newClientAvailMap.keySet()){
              Client_Avail__c newClientAvail = (Client_Avail__c) newClientAvailMap.get(clientAvailId);
              Client_Avail__c oldClientAvail = (Client_Avail__c) oldClientAvailMap.get(clientAvailId);
              
              if(updatedClientAvailMap != null && updatedClientAvailMap.size()>0){
                  
                  if(updatedClientAvailMap.get(newClientAvail.Id) != null){
                      capList = updatedClientAvailMap.get(newClientAvail.Id).Client_Avail_Prices__r;
             
                      capPubishToClientList.addAll(updatedClientAvailMap.get(newClientAvail.Id).Client_Avail_Prices__r); 
                  }
                     
              }
              
              
              if(newClientAvail.Title_Content_Type__c == WB_PriceUtility.EPISODE && ((newClientAvail.Parent_Client_Avail__c != null && newClientAvail.Parent_Client_Avail__c != oldClientAvail.Parent_Client_Avail__c) ||
                    newClientAvail.Start_Date__c != oldClientAvail.Start_Date__c || newClientAvail.End_Date__c != oldClientAvail.End_Date__c)){
                episodeCAList.add(newClientAvail);
              }
              
              //PreOrder CAP changes done by Tejasvini
              //Setting CAP Start Date
              if(newClientAvail.Start_Date__c != oldClientAvail.Start_Date__c || newClientAvail.APO_Date__c != oldClientAvail.APO_Date__c){
                  if( capList != null && capList.size() > 0){
                    Boolean isStartDateGTEndDate = true;
                    Boolean isPreOrderGTStartDateNGTEndDate = true;
                    Client_Avail_Price__c lastPreOrderCAP = null;
            Client_Avail_Price__c firstPreOrderCAP = null;
                    
                    for(Client_Avail_Price__c capRecord:capList){
                      
                      if(capRecord.RecordType.Name == WB_PriceUtility.TEMP_PRICE_RT_NAME)
                      continue;
              
              if(capRecord.Type__c == 'PreOrder'){
                if(oldClientAvail.APO_Date__c == null && newClientAvail.APO_Date__c != null){
                  isPreOrderGTStartDateNGTEndDate = false;
                  continue;
                }else if(oldClientAvail.APO_Date__c != null && newClientAvail.APO_Date__c == null){
                  isPreOrderGTStartDateNGTEndDate = false;
                  toBeDeletedCAPMap.put(capRecord.id,capRecord);
                }else{
                  if(capRecord.Expiry_Date__c < newClientAvail.APO_Date__c || capRecord.Effective_Date__c >= newClientAvail.Start_Date__c){
                    toBeDeletedCAPMap.put(capRecord.id,capRecord);
                  }else if(firstPreOrderCAP == null){
                    if(capRecord.Effective_Date__c != newClientAvail.APO_Date__c){
                      capRecord.Effective_Date__c = newClientAvail.APO_Date__c;
                      updateCAPMap.put(capRecord.id,capRecord);
                    }
                    lastPreOrderCAP = capRecord;
                    firstPreOrderCAP = capRecord;
                    isPreOrderGTStartDateNGTEndDate = false;
                  }else{
                    lastPreOrderCAP = capRecord;
                    isPreOrderGTStartDateNGTEndDate = false;
                  }
                }  
              }else if(newClientAvail.Start_Date__c != oldClientAvail.Start_Date__c){ 
                  
                  if(lastPreOrderCAP != null && lastPreOrderCAP.Expiry_Date__c != newClientAvail.Start_Date__c -1){
                    lastPreOrderCAP.Expiry_Date__c = newClientAvail.Start_Date__c -1;
                    updateCAPMap.put(lastPreOrderCAP.id,lastPreOrderCAP);
                    }
                    
                  if(capRecord.Expiry_Date__c >= newClientAvail.Start_Date__c){
                    capRecord.Effective_Date__c = newClientAvail.Start_Date__c;
                          capRecord.Type__c = WB_PriceUtility.FIRST;
                          if(capRecord.Category__c == null) 
                             capRecord.Category__c = newClientAvail.Local_Data_Category_Picklist__c;
                          updateCAPMap.put(capRecord.id,capRecord);
                          isStartDateGTEndDate = false;
                          break;
                  }else{
                          toBeDeletedCAPMap.put(capRecord.id,capRecord);
                      }
                }  
             }
                    
                    //TEMP Price record- Start
                    for(Client_Avail_Price__c capRecord:capList){
                       
                      if(capRecord.RecordType.Name == WB_PriceUtility.TEMP_PRICE_RT_NAME){
                          
                        if(capRecord.Expiry_Date__c < newClientAvail.Start_Date__c &&  newClientAvail.APO_Date__c == null){     //PreOrder CAP changes - check if PreOrde Date exists
                          toBeDeletedCAPMap.put(capRecord.id,capRecord);
                         
                        }else if(capRecord.Effective_Date__c < newClientAvail.Start_Date__c &&  newClientAvail.APO_Date__c == null){
                            capRecord.Effective_Date__c = newClientAvail.Start_Date__c;
                          updateCAPMap.put(capRecord.id,capRecord);
                        }else if(capRecord.Effective_Date__c <  newClientAvail.APO_Date__c &&  newClientAvail.APO_Date__c != null){
                          capRecord.Effective_Date__c = newClientAvail.APO_Date__c;
                          updateCAPMap.put(capRecord.id,capRecord);
                        }else if((capRecord.Effective_Date__c > newClientAvail.Start_Date__c) || (newClientAvail.APO_Date__c != null && capRecord.Effective_Date__c > newClientAvail.APO_Date__c)){
                            if(capRecord.Effective_Date__c > newClientAvail.Start_Date__c){
                                if(capRecord.Deal_Start_Date__c != Null && (newClientAvail.Start_Date__c < capRecord.Deal_Start_Date__c)){
                                    capRecord.Effective_Date__c = capRecord.Deal_Start_Date__c;
                                }
                                updateCAPMap.put(capRecord.id,capRecord);
                            }else if(newClientAvail.APO_Date__c != null && capRecord.Effective_Date__c > newClientAvail.APO_Date__c){
                                if(capRecord.Deal_Start_Date__c != Null && (newClientAvail.APO_Date__c < capRecord.Deal_Start_Date__c)){
                                    capRecord.Effective_Date__c = capRecord.Deal_Start_Date__c;
                                }
                                updateCAPMap.put(capRecord.id,capRecord);
                            }
                        }
                      }
                    }
                    //TEMP Price record- End
                    
                    //SINC0897860 - Start
                    if(isStartDateGTEndDate && newClientAvail.Start_Date__c != oldClientAvail.Start_Date__c){
                      Client_Avail_Price__c capRecord = capList[capList.size() - 1];
                      toBeDeletedCAPMap.remove(capRecord.id);
                      capRecord.Effective_Date__c = newClientAvail.Start_Date__c;
                      capRecord.Type__c = WB_PriceUtility.FIRST;
                      if(capRecord.Category__c == null) 
                        capRecord.Category__c = newClientAvail.Local_Data_Category_Picklist__c;
                          
                      updateCAPMap.put(capRecord.id,capRecord);
                    }
                    //SINC0897860 - End
                    
                    if(isPreOrderGTStartDateNGTEndDate && newClientAvail.APO_Date__c != oldClientAvail.APO_Date__c){
                      Client_Avail_Price__c preordcapRecord = capList[0];
                      if(preordcapRecord.Type__c == 'PreOrder'){
                        toBeDeletedCAPMap.remove(preordcapRecord.id);
                        preordcapRecord.Effective_Date__c = newClientAvail.APO_Date__c;
                        preordcapRecord.Expiry_Date__c = newClientAvail.Start_Date__c - 1;
                        if(preordcapRecord.Category__c == null) 
                          preordcapRecord.Category__c = newClientAvail.Local_Data_Category_Picklist__c;
                        updateCAPMap.put(preordcapRecord.id,preordcapRecord);
                      }
                      
                    }
                  }
              } 
              
              //Setting CAP End Date
              if(newClientAvail.End_Date__c != oldClientAvail.End_Date__c){
                if( capList != null && capList.size() > 0){
                    for(Integer index=capList.size()-1;index >=0;index--){
                      if(capList[index].RecordType.Name == WB_PriceUtility.TEMP_PRICE_RT_NAME)
                        continue;
                      
                      //PreOrder CAP changes done by Tejasvini  
                      if(capList[index].Type__c == 'PreOrder')
                          continue;
                      if(capList[index].Effective_Date__c <= newClientAvail.End_Date__c){
                        capList[index].Expiry_Date__c = newClientAvail.End_Date__c;
                        if(capList[index].Category__c == null) 
                          capList[index].Category__c = newClientAvail.Local_Data_Category_Picklist__c;
                          
                        updateCAPMap.put(capList[index].id,capList[index]);
                        break;
                      }else{
                        toBeDeletedCAPMap.put(capList[index].id,capList[index]);
                      }  
                    }
                    
                    //TEMP Price record- Start
                    for(Integer index=capList.size()-1;index >=0;index--){
                      if(capList[index].RecordType.Name == WB_PriceUtility.TEMP_PRICE_RT_NAME){
                          if(capList[index].Effective_Date__c > newClientAvail.End_Date__c){
                          toBeDeletedCAPMap.put(capList[index].id,capList[index]);
                        }else if(capList[index].Expiry_Date__c > newClientAvail.End_Date__c){
                          capList[index].Expiry_Date__c = newClientAvail.End_Date__c;
                          updateCAPMap.put(capList[index].id,capList[index]);
                        }else if((capList[index].Expiry_Date__c < newClientAvail.End_Date__c) ){
                            if(capList[index].Deal_End_Date__c < newClientAvail.End_Date__c){
                                capList[index].Expiry_Date__c = capList[index].Deal_End_Date__c;
                                updateCAPMap.put(capList[index].id,capList[index]);
                            }
                        }
                      }
                    }
                    //TEMP Price record- End
                }
            }
            
            if(newClientAvail.APO_Date__c != oldClientAvail.APO_Date__c || newClientAvail.Start_Date__c != oldClientAvail.Start_Date__c || newClientAvail.End_Date__c != oldClientAvail.End_Date__c || 
              (newClientAvail.Client_Title_ID__c != oldClientAvail.Client_Title_ID__c )||
              (newClientAvail.Parent_Client_Avail__c != null && newClientAvail.Parent_Client_Avail__c != oldClientAvail.Parent_Client_Avail__c) ||
              (newClientAvail.Status__c != oldClientAvail.Status__c && (newClientAvail.Status__c == WB_PriceUtility.STATUS_CONF || newClientAvail.Status__c == WB_PriceUtility.STATUS_TENTVE))){
                caPBEPList.add(newClientAvail);  
            }
            
            //Code to add First Pre-Order CAP or First CAP to update map. this is required to update price on Avail.
            for(Client_Avail_Price__c capRecord:capList){
              if(capRecord != null && !updateCAPMap.containsKey(capRecord.Id) && !toBeDeletedCAPMap.containsKey(capRecord.Id)){
                if(oldClientAvail.APO_Date__c != newClientAvail.APO_Date__c && (capRecord.Effective_Date__c == newClientAvail.APO_Date__c || capRecord.Effective_Date__c == newClientAvail.Start_Date__c)){
              priceUpdateCAPMap.put(capRecord.Id,capRecord);
            }  
          }  
            }
          }
          
          if(preOderCAPMap != null && preOderCAPMap.size()>0){
            priceUpdateCAPMap.putAll(preOderCAPMap);
          }
          //Publish to Client Flag changes
          /*if(capPubishToClientList.size()>0){
              
              String objectName = 'CA';
             
              capPubishToClientUpdateList = WB_PriceUtility.setPublishFlagToClient(capPubishToClientList,objectName);
             
             for(Client_Avail_Price__c capRec : capPubishToClientUpdateList){
                if(!updateCAPMap.containsKey(capRec.Id) && !toBeDeletedCAPMap.containsKey(capRec.Id)){
                   updateCAPMap.put(capRec.Id,capRec);
                }  
             }
          }*/
        
           
             
           if(toBeDeletedCAPMap.values().size() > 0){
            Database.DeleteResult[] deleteResult = Database.delete(toBeDeletedCAPMap.values(),false);
            for(Integer index=0;index<deleteResult.size();index++){
                    Database.DeleteResult deleteResultRec = deleteResult[index]; 
                    if(!deleteResultRec.isSuccess()){
                        for(Database.Error err : deleteResultRec.getErrors()) {
                          System.debug(LoggingLevel.INFO,'Delete CAP Result Error ->'+ err.getMessage());
                        }
                    }
                }
          }
      
      //SC To SFS Integration Changes
            updatePushToSFSOnCAStatusChange(updateCAPMap,updatedClientAvailMap,oldClientAvailMap);

            //Error handling pending.
          if(updateCAPMap.values().size() > 0){    
                Database.saveResult[] saveResult  = Database.update(updateCAPMap.values(), false);
              for(Integer index=0;index<saveResult.size();index++){
                    Database.SaveResult updateResult = saveResult[index]; 
                    if(!updateResult.isSuccess()){
                        for(Database.Error err : updateResult.getErrors()) {
                          System.debug(LoggingLevel.INFO,'Update CAP Result Error ->'+ err.getMessage());
                        }
                    }
                }
          }
          
          updateCAPMap.putAll(priceUpdateCAPMap);
          if(updateCAPMap.values().size() > 0){
            updateClientAvailPriceFields(updateCAPMap.values(),new Map<Id,Client_Avail_Price__c>());
          }
          
          WB_ClientAvailPriceHandler.isCADateChange = false;
        
          WB_PriceUtility.SKIP_EPISODE_PBEP_PROCESS = true;
          try{
            
            if(episodeCAList != null && episodeCAList.size() > 0){
              //Set Flag to Skip PBEP Processing in Trigger. This  flag is to skip Episodes(When update is on Season)
              populateEpisodePriceEntry(episodeCAList,WB_PriceUtility.UPDATE_OP);
            }
          }catch(Exception ex){
            System.debug(LoggingLevel.INFO,'Exception in populateEpisodePriceEntry '+ex.getMessage());
          }
          WB_PriceUtility.SKIP_EPISODE_PBEP_PROCESS = false;
          
          
          /*if(caPBEPList != null && caPBEPList.size() > 0){
            WB_PBEP_Product_CreationHandler pbepHandler = new WB_PBEP_Product_CreationHandler();
            pbepHandler.insertOrUpdatePriceBookEntryPeriod(caPBEPList);
          }*/
          
        }catch(Exception ex){
            System.debug(LoggingLevel.INFO,'Exception in updateClientAvailPriceStartEndDate '+ex.getMessage());
            system.debug(LoggingLevel.INFO,'Logs: '+ex.getStackTraceString());
        }
        
        WB_ClientAvailPriceHandler.isCADateChange = false; 
        WB_ClientAvailPriceHandler.recursiveInsert = false;
      WB_ClientAvailPriceHandler.recursiveUpdate = false;
      
      
      
    }
    
    // Reject Deletion of First Client_Avail_Price__c and Current Client_Avail_Price__c
    
    public void validateCAPDelete(Map<Id,Client_Avail_Price__c> newClientAvailPriceMap){
      
      if(newClientAvailPriceMap == null || newClientAvailPriceMap.isEmpty())
          return;
          
      String ppRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME);
        Map<String,Integer> countryOffsetMap = WB_PriceUtility.getCountryOffset();
        DateTime currentTime = System.now(); 
        List<String> clientAvailIdList = new List<String>();
        for(Client_Avail_Price__c capRecord : newClientAvailPriceMap.values()){
            clientAvailIdList.add(capRecord.Client_Avail__c);
        }
        Map<Id,Client_Avail__c> clientAvailMap = new Map<Id,Client_Avail__c>([Select Id,Name,Status__c,Commercial_Avail__c,Commercial_Avail__r.Local_Title__r.Price_Code__c,
                  Client__c,Release_Plan_Country__c,Release_Plan_Channel__c,Release_Plan_Format__c,Title_Content_Type__c,APO_Date__c from Client_Avail__c where Id in:clientAvailIdList]);
      
      Map<Id,Map<String,Map<String,Map<String,Map<String,Map<String,Pricing__c>>>>>> mapPricingRecords = WB_Update_Price_Tier_Handler.getPricingRecords(clientAvailMap.values());            
      
        Map<Id,Client_Avail_Price__c> capCountryCodeMap = new Map<Id,Client_Avail_Price__c>([Select Id,Client_Avail__r.Commercial_Avail__r.Country_Code__c,(Select Id,Name,Announcement_Date__c,Client_Start__c from Announcement_Records__r Limit 1) from Client_Avail_Price__c where Id in :newClientAvailPriceMap.keySet() AND RecordTypeId=:ppRecTypeId]);
        for(Client_Avail_Price__c cap : newClientAvailPriceMap.values()){
            String countryCode = null;
            Client_Avail__c clientAvail = clientAvailMap.get(cap.Client_Avail__c);
            if(capCountryCodeMap.get(cap.id) != null){
                countryCode = capCountryCodeMap.get(cap.id).Client_Avail__r.Commercial_Avail__r.Country_Code__c;
            }
            if(cap.Type__c == WB_PriceUtility.FIRST){
              cap.addError(WB_PriceUtility.FIRST_CAP_DEL);
           }else if(cap.Type__c == 'PreOrder' && cap.Effective_Date__c == clientAvail.APO_Date__c){
              cap.addError('First preorder CAP can\'t be deleted. Please update/delete APO Date on Client Avail.');  
            }else if(cap.CAP_Lifecycle__c == WB_PriceUtility.STATUS_HISTORY_EXP){
                cap.addError(WB_PriceUtility.HISTORY_EXP_CAP_DEL);
            }else if(WB_PriceUtility.isPriceTierPresent(cap,mapPricingRecords,clientAvail)){
                if(capCountryCodeMap.get(cap.Id).Announcement_Records__r.size() > 0 && cap.CAP_Lifecycle__c == 'Active Current'){
                   cap.addError(WB_PriceUtility.ACTIVE_CURR_CAP_DEL);
                }
            }
        }
    }
    
        
    //This method updates Price fields on Client_Avail__c if there is change in Price Fields of current Client_Avail_Price__c.  
    
    public Map<String,String>  updateClientAvailPriceFields(List<Client_Avail_Price__c> newClientAvailPriceUpdateList,Map<Id,Client_Avail_Price__c> triggerContextMap){
        Map<String,Integer> countryOffsetMap = WB_PriceUtility.getCountryOffset();
        DateTime currentTime = System.now();
        Date currentDate = System.today();
        String tpRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME);
        String permRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME);
        Map<String,Client_Avail__c> updatedClientAvailMap = new Map<String,Client_Avail__c>();
        Map<String,Local_Title__c> updatedLocalData = new Map<String,Local_Title__c>();
        
        Set<String> clientAvailIdSet = new Set<String>();
        for(Client_Avail_Price__c capRecord:newClientAvailPriceUpdateList){
            clientAvailIdSet.add(capRecord.Client_Avail__c);
        }
        
        Map<Id,Client_Avail__c> clientAvailMap = new Map<Id,Client_Avail__c>([Select Id,Pricing__c,Price__c,Price_Tier_Text__c,Episode_Price__c,Episode_Price_Tier__c,SR_Price__c,SR_Per_Episode__c,
                                            Release_Plan_Country__c,Status__c,Commercial_Avail__r.Country_Code__c,Title_Content_Type__c,Start_Date__c,End_Date__c,Price_Start__c,Price_End__c,
                                            Local_Title__c,Local_Title__r.Price_Code__c,Local_Title__r.Category__c,Local_Data_Category_Picklist__c,APO_Date__c,CA_Rate_Card__c,CA_Lifecycle__c,
                                            Episode_Rate_Card__c,Episode_Pricing__c,
                                             (Select Id,Name,Effective_Date__c,Expiry_Date__c,CAP_Status__c,RecordTypeId from Client_Avail_Prices__r Where Expiry_Date__c >= :currentDate) 
                                               FROM Client_Avail__c where Id in :clientAvailIdSet]);
        for(Client_Avail_Price__c capRecord:newClientAvailPriceUpdateList){
            
            Client_Avail__c caRecord = clientAvailMap.get(capRecord.Client_Avail__c);
            
            String countryCode = caRecord.Commercial_Avail__r.Country_Code__c;
          Boolean isCurrentPrice = WB_PriceUtility.isCurrentPrice(capRecord,countryCode,countryOffsetMap,currentTime);
          
            //Compare current price values and Client_Avail__c price fields. If different, update Client_Avail__c price fields with current price.
            if(caRecord.Pricing__c != capRecord.Pricing__c || caRecord.CA_Rate_Card__c != capRecord.CAP_Rate_Card__c || !WB_PriceUtility.isPriceSame(caRecord,capRecord) || 
                        caRecord.Price_Start__c != capRecord.Effective_Date__c || caRecord.Price_End__c != capRecord.Expiry_Date__c 
             || caRecord.Local_Data_Category_Picklist__c != capRecord.Category__c || caRecord.Episode_Pricing__c != capRecord.Episode_Pricing__c
                                    || caRecord.Episode_Rate_Card__c != capRecord.Episode_Rate_Card__c){
              
              
                         
                if( isCurrentPrice || (caRecord.APO_Date__c != null ? (capRecord.Effective_Date__c == caRecord.APO_Date__c && caRecord.APO_Date__c >=currentDate) : (capRecord.Effective_Date__c == caRecord.Start_Date__c && caRecord.Start_Date__c >= currentDate))){
                  //to identify Current Temp Price -Start
                  Boolean isTempCurrent = false;
                  if(capRecord.RecordTypeId != tpRecTypeId && 
                      caRecord.Client_Avail_Prices__r != null && !caRecord.Client_Avail_Prices__r.isEmpty()){
                    for(Client_Avail_Price__c tempCapRecord:caRecord.Client_Avail_Prices__r){
                      if(tempCapRecord.RecordTypeId != tpRecTypeId) 
                        continue;
                        
                      isTempCurrent = WB_PriceUtility.isCurrentPrice(tempCapRecord,countryCode,countryOffsetMap,currentTime);
                      isTempCurrent = isTempCurrent || (caRecord.APO_Date__c != null ? (tempCapRecord.Effective_Date__c == caRecord.APO_Date__c && caRecord.APO_Date__c >= currentDate) : (tempCapRecord.Effective_Date__c == caRecord.Start_Date__c && caRecord.Start_Date__c >= currentDate)); 
                      if(isTempCurrent) break;
                    }
                  }
                  //to identify Current Temp Price - End
                  
                  if(!isTempCurrent && !updatedClientAvailMap.containsKey(caRecord.Id)){
                      populateClientAvailPriceFields(capRecord,caRecord,isCurrentPrice,tpRecTypeId);
                      updatedClientAvailMap.put(caRecord.Id,caRecord);
            if(isCurrentPrice)                    
                        populateLocalDataFields(capRecord,caRecord,updatedLocalData);
                  }
                  //ER-006739 - Start
                  else if(isCurrentPrice && !updatedClientAvailMap.containsKey(caRecord.Id) && caRecord.Local_Data_Category_Picklist__c != capRecord.Category__c){ 
                      caRecord.Local_Data_Category_Picklist__c = capRecord.Category__c;
                      updatedClientAvailMap.put(caRecord.Id,caRecord);
                  }
                  //ER-006739 - End
                }
            }        
                    
            if(triggerContextMap.get(capRecord.Id) != null && capRecord.Announce_Override__c != null){
            if(updatedClientAvailMap.get(caRecord.Id) != null){
              updatedClientAvailMap.get(caRecord.Id).Announce_Override__c = capRecord.Announce_Override__c;
            }else{
              caRecord.Announce_Override__c =  capRecord.Announce_Override__c;
              updatedClientAvailMap.put(caRecord.Id,caRecord);
            }          
            }   
            
            //Update Price ER-002744
            try{
                if(triggerContextMap.get(capRecord.Id) != null){
                    if((capRecord.Expiry_Date__c == caRecord.End_Date__c) && (caRecord.End_Date__c < Date.today()) && (caRecord.CA_Lifecycle__c.contains('History'))){
                        
                       if(updatedClientAvailMap.get(caRecord.Id) != null){
                            populateClientAvailPriceFields(capRecord,updatedClientAvailMap.get(caRecord.Id),isCurrentPrice,tpRecTypeId);
                           
                        }else{
                            populateClientAvailPriceFields(capRecord,caRecord,isCurrentPrice,tpRecTypeId);
                            updatedClientAvailMap.put(caRecord.Id,caRecord);
                        }
                    }
                }
            }catch(Exception ex){
               System.debug(LOGGINGLEVEL.INFO,'Exception occurred -> '+ex.getMessage()); 
            }
            
        }
        
        Map<String,String> failedCAMap = new Map<String,String>();
        if(updatedClientAvailMap.size() > 0){
          List<Client_Avail__c> caList = updatedClientAvailMap.values();
            Database.Saveresult[] updateResults  = Database.update(caList, false);
            for(Integer index=0;index<updateResults.size();index++){
                Database.SaveResult updateResult = updateResults[index]; 
                if(!updateResult.isSuccess()){
                  for(Database.Error err : updateResult.getErrors()) {
                  failedCAMap.put(caList[index].Id,err.getMessage());
                  System.debug(LoggingLevel.INFO,'saveResult Error ->'+ err.getMessage());
                  break;
                  }
                }
      }
        }
        
        if(updatedLocalData.values().size() > 0){
            Database.SaveResult[] saveResult = Database.update(updatedLocalData.values(),false);
        }
        
        return failedCAMap;
    }
    
    
    public void populateClientAvailPriceFields(Client_Avail_Price__c capRecord,Client_Avail__c caRecord,Boolean isCurrentPrice,String tempRecId){
        caRecord.Pricing__c = capRecord.Pricing__c;
        caRecord.Price__c = capRecord.Price__c;
        caRecord.Price_Tier_Text__c = capRecord.Price_Tier__c;
        
    //  caRecord.SR_Price__c = capRecord.SR_Price__c;
    //  caRecord.Episode_Price__c = capRecord.Episode_Price__c;
    //  caRecord.Episode_Price_Tier__c = capRecord.Episode_Price_Tier__c;
    //  caRecord.SR_Per_Episode__c = capRecord.SR_Per_Episode__c;
        caRecord.Price_Start__c = capRecord.Effective_Date__c;
        caRecord.Price_End__c = capRecord.Expiry_Date__c;
   //   caRecord.Local_Data_Category_Picklist__c = capRecord.Category__c;
        caRecord.Price_Type__c = capRecord.RecordTypeId == tempRecId? WB_PriceUtility.TEMP_PRICE_RT_NAME : WB_PriceUtility.PERM_PRICE_RT_NAME;
        
        //ER-006603 - Sync CAP Category and Act Curr Category on Episode Avails
        if(isCurrentPrice || caRecord.Title_Content_Type__c != WB_PriceUtility.EPISODE || 
      capRecord.Category__c.contains('Day After') || !caRecord.Local_Data_Category_Picklist__c.contains('Day After')){
           caRecord.Local_Data_Category_Picklist__c = capRecord.Category__c;
      }else if(!WB_PriceUtility.SKIP_EPISODE_PBEP_PROCESS && !WB_ClientAvailPriceHandler.isCADateChange){
          caRecord.Local_Data_Category_Picklist__c = capRecord.Category__c;
        }

        if(capRecord.Announce_Override__c != null){
        caRecord.Announce_Override__c =  capRecord.Announce_Override__c;          
      }
      
        //SINC0897860 - Start
        if(caRecord.Title_Content_Type__c == 'Season'){
            caRecord.Episode_Price__c = capRecord.Episode_Price__c;
            caRecord.Episode_Price_Tier__c = capRecord.Episode_Price_Tier__c;
            caRecord.Episode_Pricing__c = capRecord.Episode_Pricing__c;
            if(capRecord.CAP_CRM_Country__c){
                caRecord.Episode_Pricing__c = Null;
                caRecord.Episode_Rate_Card__c = capRecord.Episode_Rate_Card__c;
            }
       //   caRecord.SR_Per_Episode__c = capRecord.SR_Per_Episode__c;
        }else{
          caRecord.Episode_Price__c = null;
            caRecord.Episode_Price_Tier__c = null;
            caRecord.Episode_Pricing__c = Null;
            caRecord.Episode_Rate_Card__c = Null;
            
        }
        
        //SINC0897860 - End
        
        caRecord.CA_Rate_Card__c = capRecord.CAP_Rate_Card__c;
        
        if(caRecord.Client_Avail_Prices__r != null && !caRecord.Client_Avail_Prices__r.isEmpty()){
          for(Client_Avail_Price__c cap:caRecord.Client_Avail_Prices__r){
            if(capRecord.Id == cap.Id){
              caRecord.CAP_Name__c = cap.Name;  
              break;
            }
          }
       }
    }
    
    
    public void populateEpisodePriceEntry(List<Client_Avail__c> episodeCAList,String operation){
      
      String ppRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME);
      
    //SC To SFS Integration Changes
      Map<String,String> availableCatgryMap = getAccountingCategoryData();
      List<String> seasonCAIdList = new List<String>();
      for(Client_Avail__c episodeCA:episodeCAList){
        seasonCAIdList.add(episodeCA.Parent_Client_Avail__c);
      }
      
      Map<Id,Client_Avail__c> seasonCAMap = new Map<Id,Client_Avail__c>([Select Id,(Select Id,Effective_Date__c,Expiry_Date__c,Category__c,Price__c,Price_Tier__c,Episode_Price__c,Episode_Price_Tier__c,Announce_Override__c,RecordTypeId,Client_Avail_Status__c,Episode_Rate_Card__c,Episode_Pricing__c,CAP_CRM_Country__c FROM Client_Avail_Prices__r WHERE RecordTypeId = :ppRecTypeId Order by Effective_Date__c) 
                                        FROM Client_Avail__c where Id in :seasonCAIdList]);
      List<Client_Avail_Price__c> capRecordList = new List<Client_Avail_Price__c>(); 
      
      if(operation == WB_PriceUtility.UPDATE_OP){
        Map<Id,Client_Avail__c> episodeCAMap = new Map<Id,Client_Avail__c>([Select Id,CurrencyIsoCode,Parent_Client_Avail__c,Start_Date__c,End_Date__c,Lock_Pricing_Update__c,Title__c,Local_Title__r.Local_TV_Air_Date__c,CA_Rate_Card__c,Pricing__c,
                                            (Select Id,Type__c,Effective_Date__c,Expiry_Date__c,Category__c,Price__c,Price_Tier__c,Episode_Price__c,Episode_Price_Tier__c,Announce_Override__c,RecordTypeId,Client_Avail_Status__c,Episode_Price_Override__c FROM Client_Avail_Prices__r WHERE RecordTypeId = :ppRecTypeId Order by Effective_Date__c) 
                                              FROM Client_Avail__c where Id in :episodeCAList]);
        Map<String,Client_Avail_Price__c> updatedEpisodeCAPMap = new Map<String,Client_Avail_Price__c>();
        List<Client_Avail_Price__c> toBeInsertedEpisodeCAPList = new List<Client_Avail_Price__c>();
    
    //ER-004159 - HBO/Turner: Ability to Manually override Episode price - changes - parameter added
      Map<String,Boolean> epOvrrCAMap = WB_PriceUtility.trackEpOverrEnabledCAMap(episodeCAMap.values());
        
        for(Client_Avail__c episodeCA:episodeCAMap.values()){
      
      //ER-004159 - HBO/Turner: Ability to Manually override Episode price - changes - parameter added
        if(epOvrrCAMap != Null && epOvrrCAMap.containsKey(episodeCA.Id))
        continue;
    
          Client_Avail__c seasonCA = seasonCAMap.get(episodeCA.Parent_Client_Avail__c);
          //SINC1125828 - Added below if condition. 
          if(seasonCA == null)
            continue;
          
          List<Client_Avail_Price__c> seasonCAPList = new List<Client_Avail_Price__c>(); //To Hold all the Episode Unique Price records with adjusted dates.
          Client_Avail_Price__c prevSeasCAP = null;
          for(Client_Avail_Price__c seasonCAP:seasonCA.Client_Avail_Prices__r){
            
            if(seasonCAP.Expiry_Date__c < episodeCA.Start_Date__c) continue;
            
            if(prevSeasCAP == null){ 
              seasonCAPList.add(seasonCAP);
              prevSeasCAP = seasonCAP;
              continue;
            }
            
            if(seasonCAP.Episode_Price__c == prevSeasCAP.Episode_Price__c && seasonCAP.Episode_Price_Tier__c == prevSeasCAP.Episode_Price_Tier__c){
             prevSeasCAP.Expiry_Date__c = seasonCAP.Expiry_Date__c;
             continue;    
          }else{
            seasonCAPList.add(seasonCAP);
          }
            prevSeasCAP = seasonCAP;
          }
          
            
          List<Client_Avail_Price__c> episodeCAPList = episodeCA.Client_Avail_Prices__r;
          if(episodeCAPList.size() > seasonCAPList.size()){
            //Keep first CAP and delete remaining if any...Pending
            //System.debug(LoggingLevel.INFO,'*****Episode has More Price records than Season. Unable to adjust. Need to update manually.');
          }else{
            
            Boolean hasPriceRecord = false;
            for(Integer seaonCapIndex=0;seaonCapIndex < seasonCAPList.size();seaonCapIndex++){ 
              Client_Avail_Price__c seasonCAP = seasonCAPList[seaonCapIndex];
              
              if(seaonCapIndex < episodeCAPList.size()){
                
                Client_Avail_Price__c  episodeCAP = episodeCAPList[seaonCapIndex];
                if(seasonCAP.Episode_Price__c != episodeCAP.Price__c || seasonCAP.Episode_Price_Tier__c != episodeCAP.Price_Tier__c){
                  episodeCAP.Price__c = seasonCAP.Episode_Price__c;
                  episodeCAP.Price_Tier__c = seasonCAP.Episode_Price_Tier__c;
                  episodeCAP.Category__c = seasonCAP.Category__c; //Category
                  //Price Code
                  updatedEpisodeCAPMap.put(episodeCAP.Id,episodeCAP);
                }
                
                if(!hasPriceRecord){
                  episodeCAP.Type__c = WB_PriceUtility.FIRST;
                  hasPriceRecord = true;
                }else{
                  episodeCAP.Type__c = null;
                }
              }else{
                Client_Avail_Price__c episodeCAP = WB_PriceUtility.createEpisodeCAP(seasonCAP,episodeCA,ppRecTypeId);
                if(!hasPriceRecord){
                  episodeCAP.Type__c = WB_PriceUtility.FIRST;
                //  episodeCAP.Category__c = episodeCA.Local_Data_Category_Picklist__c;
                //  episodeCAP.Category__c = (episodeCAP.Category__c == null || episodeCAP.Category__c == '')?'TBD':episodeCAP.Category__c;
                  hasPriceRecord = true;
                }
                toBeInsertedEpisodeCAPList.add(episodeCAP);
              }
            }
            
            //System.debug(LoggingLevel.INFO,'*****toBeInsertedEpisodeCAPList is -> '+toBeInsertedEpisodeCAPList);
            //System.debug(LoggingLevel.INFO,'*****updatedEpisodeCAPMap is -> '+updatedEpisodeCAPMap);
            
            }
          }
        
        //Skip price validation in this scenario(Episode added back to Play list)
        WB_PriceUtility.SKIP_VALIDATION = true;
        WB_PriceUtility.PLAY_LIST_UPDATE  = true;
        if(updatedEpisodeCAPMap.size() > 0){
          Database.SaveResult[] updateEpisodeResult = Database.update(updatedEpisodeCAPMap.values(),false);
        }
        
        if(toBeInsertedEpisodeCAPList.size() > 0){
          Database.SaveResult[] insertedEpisodeResult = Database.insert(toBeInsertedEpisodeCAPList,false);
          for(Database.SaveResult saveResult:insertedEpisodeResult){
            if(!saveResult.isSuccess()){
              for(Database.Error err : saveResult.getErrors()) {
                      System.debug(LoggingLevel.INFO,'saveResult Error ->'+ err.getMessage());
                      }
            }
          }  
        }
        WB_PriceUtility.SKIP_VALIDATION = false;
        WB_PriceUtility.PLAY_LIST_UPDATE  = false;
      }else if(operation == WB_PriceUtility.INSERT_OP){
      for(Client_Avail__c episodeCA:episodeCAList){
        Client_Avail__c seasonCA = seasonCAMap.get(episodeCA.Parent_Client_Avail__c);
        Client_Avail_Price__c prevEpCAP = null;
        if(seasonCA != null && seasonCA.Client_Avail_Prices__r != null){
          
            for(Client_Avail_Price__c seasonCAP:seasonCA.Client_Avail_Prices__r){
              
              if(seasonCAP.Expiry_Date__c < episodeCA.Start_Date__c) continue;
              
              if(prevEpCAP != null && seasonCAP.Episode_Price__c == prevEpCAP.Price__c && seasonCAP.Episode_Price_Tier__c == prevEpCAP.Price_Tier__c){
                 prevEpCAP.Expiry_Date__c = seasonCAP.Expiry_Date__c;    
              }else{
                Client_Avail_Price__c episodeCAP = WB_PriceUtility.createEpisodeCAP(seasonCAP,episodeCA,ppRecTypeId);
                if(prevEpCAP == null){  
                  episodeCAP.Type__c = WB_PriceUtility.FIRST;
                //  episodeCAP.Category__c = episodeCA.Local_Data_Category_Picklist__c;
                //  episodeCAP.Category__c = (episodeCAP.Category__c == null || episodeCAP.Category__c == '')?'TBD':episodeCAP.Category__c;
                }
                episodeCAP.Expiry_Date__c = seasonCAP.Expiry_Date__c;
                capRecordList.add(episodeCAP);
                prevEpCAP = episodeCAP;
        //SC To SFS Integration Changes
          assignAccountingCategory(availableCatgryMap,episodeCAP,WB_PriceUtility.EPISODE,episodeCAP.Category__c);

              }
            }
      //ER-004158 - Add field "Episode End Date Calc" to Playlist - change 
        prevEpCAP.Expiry_Date__c = episodeCA.End_Date__c;
        }
      }
      
      try{
        List<Client_Avail_Price__c> successRecords = new List<Client_Avail_Price__c>();
        Database.SaveResult[] insertResultList = Database.insert(capRecordList,false);
        for(Integer index=0;index<insertResultList.size();index++){
                  Database.SaveResult insertResult = insertResultList[index]; 
                  if(insertResult.isSuccess()){
                    successRecords.add(capRecordList[index]);
                  }else{
                    System.debug(LoggingLevel.INFO,'saveResult Error ->'+ insertResult.getErrors());
                  }
        }
        
        updateClientAvailPriceFields(successRecords,new Map<Id,Client_Avail_Price__c>());
              
      }catch(Exception ex){
        System.debug(LoggingLevel.INFO,'Exception in populateEpisodePriceEntry '+ex.getMessage());
      }
      }  
    }
    
    public void populateLocalDataFields(Client_Avail_Price__c capRecord, Client_Avail__c caRecord,Map<String,Local_Title__c> updatedLocalData){
      Local_Title__c localData = updatedLocalData.get(caRecord.Local_Title__c);
    if(localData == null){
      localData = new Local_Title__c(Id=caRecord.Local_Title__c);
    }
      
      //ER-002361  - Stop PriceCode update on Local Data from CAPs(Re-Price/Price Update) 
      //Local Data Proce code update code is commented due to abover ER-002361
      /*if(capRecord.Price_Code__c != null && capRecord.Price_Code__c.length() > 0 && capRecord.Price_Code__c != caRecord.Local_Title__r.Price_Code__c){
        localData.Price_Code__c = capRecord.Price_Code__c;
        updatedLocalData.put(caRecord.Local_Title__c,localData);
      }*/
      
      if(capRecord.Category__c != null && capRecord.Category__c.length() > 0 && capRecord.Category__c != caRecord.Local_Title__r.Category__c
            && caRecord.Title_Content_Type__c != WB_PriceUtility.SEASON && caRecord.Title_Content_Type__c != WB_PriceUtility.EPISODE){
        localData.Category__c = capRecord.Category__c;
        updatedLocalData.put(caRecord.Local_Title__c,localData);
      }
        
    }
    
    //This method validates Temporary CAP record.
    public void validateTempCAP(List<Client_Avail_Price__c> capList,Map<Id,Client_Avail_Price__c> oldClientAvailPriceMap,String operation){
        
        //String tpRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME);
        Map<Id,Client_Avail__c> caMapValue = new Map<Id,Client_Avail__c>();
        List<Client_Avail_Price__c> capRecordList = new List<Client_Avail_Price__c>();
        Set<Id> caIDSet = new Set<Id>();
        Boolean isError = false;
        
        
        for(Client_Avail_Price__c capRec : capList){
            if(capRec.Deal_ID__c == null && capRec.promotion__c == null) 
                caIDSet.add(capRec.Client_Avail__c);   
        }
        
        if(caIDSet != null && caIDSet.size()>0){
            caMapValue = new Map<Id,Client_Avail__c>([Select Id,Name,Start_Date__c,End_Date__c,Status__c,Local_Data_Category_Picklist__c,APO_Date__c 
                                      From Client_Avail__c Where Id In :caIDSet]);
        }
        
        
        for(Client_Avail_Price__c cap : capList){
           Client_Avail__c caRecord = caMapValue.get(cap.Client_Avail__c);
           
           if(caRecord != null){
               
               if(caRecord.Status__c != WB_PriceUtility.STATUS_CONF && caRecord.Status__c != WB_PriceUtility.STATUS_TENTVE){
                 cap.addError('Client Avail Status is not tentative/confirmed'); 
                 isError = true;
               }else if(cap.Effective_Date__c == null){
                 cap.addError(WB_PriceUtility.EFF_DATE_REQ_ERROR);
                 isError = true;
               }else if(cap.Expiry_Date__c == null){
                 cap.addError('Price End Date must be entered'); 
                 isError = true;
               }else if(caRecord.APO_Date__c != null ? cap.Effective_Date__c < caRecord.APO_Date__c : cap.Effective_Date__c < caRecord.Start_Date__c){
                 cap.addError('Promotional Price Start Date must be on or after Avail Start Date'); 
                 isError = true;
               }else if(cap.Expiry_Date__c > caRecord.End_Date__c){
                 cap.addError('Promotional Price End Date must be on or before Avail End Date'); 
                 isError = true;
               }else if(cap.Price_Tier__c == null && cap.Price__c == null){
                 cap.addError('Please enter either Price Tier or WSP value'); 
                 isError = true;
               }else if(cap.Price_Tier__c != null && cap.Price__c != null){
                 cap.addError(WB_PriceUtility.PR_PRT_MX_ERROR); 
                 isError = true;
               } 
               
               //SINC1192693 
               if(!isError)
                capRecordList.add(cap);
                
            }
            isError = false;      ////SINC1192693 -- reset the flag
          
           
        }
        
        if(capRecordList != null && capRecordList.size()>0){
            if( operation == WB_PriceUtility.INSERT_OP)
                WB_PriceUtility.checkPriceMatch(capRecordList,null,null,WB_PriceUtility.INSERT_OP);
            if(operation == WB_PriceUtility.UPDATE_OP)
                WB_PriceUtility.checkPriceMatch(capRecordList,oldClientAvailPriceMap,null,WB_PriceUtility.UPDATE_OP); 
        }
        
    }
    
    //ER-006802 -- Round CAP WSP price to 2 decimal places on insert & update
    public void roundPricingtwoDigit(List<Client_Avail_Price__c> lstCapRecords){

        for(Client_Avail_Price__c capRecordBeforeUpdate:lstCapRecords){  
             Decimal wsp = capRecordBeforeUpdate.Price__c;
             Decimal episodeWsp=capRecordBeforeUpdate.Episode_Price__c ;
            if(wsp != NULL && wsp.scale()>2){       
          Decimal roundedWSP = wsp.setScale(2);
                    capRecordBeforeUpdate.Price__c = roundedWSP;
            }
            if(episodeWsp != NULL && episodeWsp.scale()>2){               
          Decimal roundedEpisodeWSP = episodeWsp.setScale(2);
          capRecordBeforeUpdate.Episode_Price__c = roundedEpisodeWSP;
                }              
           
        }  
    }
    public void displayRecordCount(List<Client_Avail_Price__c> capList){
      //System.debug(LoggingLevel.INFO,'capList size is -> '+(capList!= null?capList.size()+'':'This is Delete'));
      //System.debug(LoggingLevel.INFO,'Insert Flag is -> '+WB_ClientAvailPriceHandler.recursiveInsert);
    }
    
    public static boolean recursiveInsert = false;
    public static boolean recursiveUpdate = false;
    public static boolean recursiveDelete = false;
    public static boolean isCADateChange = false;
    
}