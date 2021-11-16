global with sharing class WB_PriceWizardController {
    
    public String actionValue{get;set;}
    public string availids;
    public String clientIds {get;set;}
    public list<Client_Avail__c> selectedClientAvail_list{get;set;}
    public list<Schema.FieldSetMember> selectedClientAvail_list2 {get; set;}
    public boolean isSeasonReprice=false;
    public boolean stdPage{get;set;} 
    public String param{get;set;}     // Added for page redirect
    public string rpIdRedir{get;set;}
    public Client_Avail__c obj;
    public String uniqueIds {get;set;}
    
    //***** Added by Shubham : ER - 3328 ***************************
    public ApexPages.StandardSetController standardController;
    public List<Client_Avail__c> selectedAvails{get;set;}
    
    public List<Client_Avail_Price__c> selectedCAP{get;set;}
    
    public WB_PriceWizardController(){
          
          actionValue = RE_PRICE;
          if(ApexPages.currentPage().getParameters().containsKey('sfdc.tabName') && ApexPages.currentPage().getParameters().get('sfdc.tabName') != ''){
              
              //check id for rePrice
              if(ApexPages.currentPage().getParameters().get('sfdc.tabName') == WB_PriceUtility.RE_PRICE_TAB){
                  actionValue = RE_PRICE;
              }else if(ApexPages.currentPage().getParameters().get('sfdc.tabName') == WB_PriceUtility.PRICE_UPDATE_TAB){
                   actionValue = PRICE_UPDT;
              }
          }
          
          String actionParam = ApexPages.currentPage().getParameters().get('action');
          if(actionParam != null){
            actionValue = actionParam;
          }
    }
    
    //************************ Added by Shubham : ER - 3328 ,3329 **************************************
          
    public WB_PriceWizardController(ApexPages.StandardSetController standardController){
        this.standardController = standardController;
          
        List<sObject> recordsList = standardController.getRecords();
        string objectName = String.valueOf(recordsList.getSObjectType());
        
        if(objectName == 'Client_Avail__c'){
            selectedAvails = (List<Client_Avail__c>) standardController.getSelected();
        }
        else if(objectName == 'Client_Avail_Price__c'){
            selectedCAP = (List<Client_Avail_Price__c>) standardController.getSelected();
        }
    
    }
    
    //********************************************************************************************
    
    
    /*public static String getDateSeparator(Map<String,Integer> dateMap){
    	Date sampleDate = Date.newInstance(2016,02,09);
    	String character = null;
    	Integer month = 2;
		Integer day = 9;
		Integer year = 2016;
		
		Integer yearIndex;
		Integer monthIndex;
		Integer dayIndex;

        String dateVal = sampleDate.format(); 
        System.debug(dateVal);
          
		try{
			for(Integer index=0;index<dateVal.length();index++){
			  character = dateVal.substring(index,index+1);
			  if(!character.isNumeric()){
			     break;
			    }
			}
	
			String[] dateValues = dateVal.split(character);
			for(Integer index=0;index<dateValues.size();index++){
			   if(Integer.valueOf(dateValues[index]) == year){
			   		yearIndex = index;
			   }else if(Integer.valueOf(dateValues[index]) == month ){
			   		monthIndex = index; 
			   }else{
			   		dayIndex = index;
			   }
			}
	
			dateMap.put('yearIndex',yearIndex);
			dateMap.put('monthIndex',monthIndex);
			dateMap.put('dayIndex',dayIndex);
			System.debug(LoggingLevel.INFO,dateMap);
		}catch(Exception ex){
			System.debug(LoggingLevel.INFO,ex.getMessage());
		}
		
		return character;
		
    }*/
    
    @RemoteAction
    global static List<String> getUniqueIDvalue(String UniqueIdVal){
        list<string> clientIdsVal = new List<String>();       
        system.debug('UNIQUEID ====> ' + UniqueIdVal);
        if(UniqueIdVal != null && UniqueIdVal != ''){
            List<Client_Avail_Id_Store__c> CAIDStoreList = [
                select Id, ID_Store__c
                  from Client_Avail_Id_Store__c
                 where Key__c = :UniqueIdVal limit 1
            ];
            system.debug('CAIDStoreList ====> ' + CAIDStoreList.size() + CAIDStoreList[0].ID_Store__c);
            if(CAIDStoreList != null && CAIDStoreList.size() > 0){
                clientIdsVal = CAIDStoreList[0].ID_Store__c.split(',');
            }
        }
        return clientIdsVal;
    }
    
    @RemoteAction @ReadOnly
    global static List<String> getRecordIDs(List<String> videoVersions,FilterCriteria filterCriteria,String action){
        if(action == RE_PRICE){
            return getCARecordIDs(videoVersions,filterCriteria,action);
        }else if(action == PRICE_UPDT){
            return getCAPRecordIDs(videoVersions,filterCriteria,action);
        }
        
        return null;
    }
        
    @RemoteAction @ReadOnly
    global static List<String> getCARecordIDs(List<String> videoVersions,FilterCriteria filterCriteria,String action){
        String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); // Need to add a Label for this.
        
        System.debug(LoggingLevel.INFO,'Inside getClientAvailsIDs method...');
        System.debug(LoggingLevel.INFO,'Filter Criteria is - >'+filterCriteria);
        
        List<String> selectedCountries = filterCriteria.selectedCountries;
        List<String> selectedAccounts = filterCriteria.selectedAccounts;
        List<String> selectedChannels = filterCriteria.selectedChannels;
        List<String> selectedFormats = filterCriteria.selectedFormats;
        List<String> selectedLangs = filterCriteria.selectedLangs;
        List<String> selectedLangTypes = filterCriteria.selectedLangTypes;
        List<String> selectedWBTerritories = filterCriteria.selectedWBTerritories;
        List<String> selectedContentTypes = filterCriteria.selectedContentTypes;
        List<String> selectedPriceTiers = filterCriteria.selectedPriceTiers;
        List<String> selectedCALifeCycles = filterCriteria.selectedCALifeCycles;
        List<String> mpmNumbers = filterCriteria.mpmNumbers;
        
        if(selectedContentTypes.size() == 0) selectedContentTypes = getContentTypes(action);
        if(selectedCALifeCycles.size() == 0) selectedCALifeCycles = getCALifeCycles();
        
        String query = 'Select Id from Client_Avail__c '; 
                                                    
        String whereClause = '';
        if(videoVersions.size() > 0){
            whereClause = ' Title_Video_Version__c in :videoVersions ';
        }   
                                                            
        if(selectedCountries.size() > 0){
            if(whereClause.length() > 0) whereClause = whereClause+' and ';
            whereClause = whereClause + ' Commercial_Avail__r.Country_Lookup__r.Country_Code__c in :selectedCountries ';
        }
        
        if(selectedAccounts.size() > 0){
            if(whereClause.length() > 0) whereClause = whereClause+' and ';
            whereClause = whereClause + ' AccountF__c in :selectedAccounts ';
        }
        
        if(selectedChannels.size() > 0){
            if(whereClause.length() > 0) whereClause = whereClause+' and ';
            whereClause = whereClause + ' Release_Plan_Channel__c in :selectedChannels ';
        }
        
        if(selectedFormats.size() > 0){
            if(whereClause.length() > 0) whereClause = whereClause+' and ';
            whereClause = whereClause + ' Release_Plan_Format__c in :selectedFormats ';
        }
        
        if(selectedLangs.size() > 0){
            if(whereClause.length() > 0) whereClause = whereClause+' and ';
            whereClause = whereClause + ' Release_Plan_Language__c in :selectedLangs ';
        }
        
        if(selectedLangTypes.size() > 0){
            if(whereClause.length() > 0) whereClause = whereClause+' and ';
            whereClause = whereClause + ' RP_Language_Type__c in :selectedLangTypes ';
        }
        
        if(selectedWBTerritories.size() > 0){
            if(whereClause.length() > 0) whereClause = whereClause+' and ';
            whereClause = whereClause + ' Territory__c in :selectedWBTerritories ';
        }
        
        if(selectedPriceTiers.size() > 0){
            if(whereClause.length() > 0) whereClause = whereClause+' and ';
            whereClause = whereClause + ' Price_Tier_Text__c in :selectedPriceTiers ';
        }
        
        if(selectedContentTypes.size() > 0){
            if(whereClause.length() > 0) whereClause = whereClause+' and ';
            whereClause = whereClause + ' Title_Content_Type__c in :selectedContentTypes ';
        }
        
        if(selectedCALifeCycles.size() > 0){
            if(whereClause.length() > 0) whereClause = whereClause+' and ';
            whereClause = whereClause + ' CA_Lifecycle__c in :selectedCALifeCycles ';
        }
        
        if(mpmNumbers.size() > 0){
        	List<String> mpmListUpdated = new List<String>();
        	for(Integer mpmIndex=0;mpmIndex<mpmNumbers.size();mpmIndex++){
        		if(mpmNumbers[mpmIndex].trim().length() > 0)
        			mpmListUpdated.add(mpmNumbers[mpmIndex].trim());
        	}
        	
        	mpmNumbers = mpmListUpdated;
        	
            if(whereClause.length() > 0) whereClause = whereClause+' and ';
            whereClause = whereClause + ' Local_Title__r.Title__r.MPM__r.MPM_Number__c in :mpmNumbers ';
        }
        
        
        if(whereClause.length() > 0){
            query = query + ' where '+whereClause ;
        }
        
        //query = query + ' Order By Title_Video_Version__c Limit 25001 ';
        query = query + ' Order By Local_Title__r.Title__c,Commercial_Avail__r.Country_Lookup__c,AccountF__c,Release_Plan_Channel__c,Release_Plan_Format__c Limit 25001 ';
        
        System.debug(LoggingLevel.INFO,'query is ->'+query);
        List<Client_Avail__c> clientAvails = Database.query(String.escapeSingleQuotes(query));
        
        List<String> wrapperList = new List<String>();
        if(clientAvails.size() > 25000){
        	wrapperList.add('LIMIT EXCEEDED');
        }else{
	        for(Client_Avail__c caRecord:clientAvails){
	            wrapperList.add(caRecord.Id);
	        }
        }
        //System.debug(LoggingLevel.INFO,clientAvails);
        
        return wrapperList;
    }
    
    
    @RemoteAction @ReadOnly
    global static List<String> getCAPRecordIDs(List<String> videoVersions,FilterCriteria filterCriteria,String action){
        String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); // Need to add a Label for this.
        
        System.debug('###videoVersions:'+videoVersions);
        System.debug('###filterCriteria:'+videoVersions);
        System.debug('###action:'+action);
        
        System.debug(LoggingLevel.INFO,'Inside getClientAvailsIDs method...');
        System.debug(LoggingLevel.INFO,'Filter Criteria is - >'+filterCriteria);
        
        List<String> selectedCountries = filterCriteria.selectedCountries;
        List<String> selectedAccounts = filterCriteria.selectedAccounts;
        List<String> selectedChannels = filterCriteria.selectedChannels;
        List<String> selectedFormats = filterCriteria.selectedFormats;
        List<String> selectedLangs = filterCriteria.selectedLangs;
        List<String> selectedLangTypes = filterCriteria.selectedLangTypes;
        List<String> selectedWBTerritories = filterCriteria.selectedWBTerritories;
        List<String> selectedContentTypes = filterCriteria.selectedContentTypes;
        List<String> selectedPriceTiers = filterCriteria.selectedPriceTiers;
        List<String> selectedCALifeCycles = filterCriteria.selectedCALifeCycles;
        List<String> mpmNumbers = filterCriteria.mpmNumbers;
        
        if(selectedContentTypes.size() == 0) selectedContentTypes = getContentTypes(action);
        if(selectedCALifeCycles.size() == 0) selectedCALifeCycles = getCALifeCycles();
        
        String query = 'Select Id from Client_Avail_Price__c '; 
                                                    
        String whereClause = '';
        if(videoVersions.size() > 0){
            whereClause = ' Title_Video_Version__c in :videoVersions ';
        }   
                                                            
        if(selectedCountries.size() > 0){
            if(whereClause.length() > 0) whereClause = whereClause+' and ';
            whereClause = whereClause + ' Client_Avail__r.Commercial_Avail__r.Country_Lookup__r.Country_Code__c in :selectedCountries ';
        }
        
        if(selectedAccounts.size() > 0){
            if(whereClause.length() > 0) whereClause = whereClause+' and ';
            whereClause = whereClause + ' Account__c in :selectedAccounts ';
        }
        
        if(selectedChannels.size() > 0){
            if(whereClause.length() > 0) whereClause = whereClause+' and ';
            whereClause = whereClause + ' Client_Avail_Channel__c in :selectedChannels ';
        }
        
        if(selectedFormats.size() > 0){
            if(whereClause.length() > 0) whereClause = whereClause+' and ';
            whereClause = whereClause + ' Client_Avail_Format__c in :selectedFormats ';
        }
        
        if(selectedLangs.size() > 0){
            if(whereClause.length() > 0) whereClause = whereClause+' and ';
            whereClause = whereClause + ' Client_Avail_Language__c in :selectedLangs ';
        }
        
        if(selectedLangTypes.size() > 0){
            if(whereClause.length() > 0) whereClause = whereClause+' and ';
            whereClause = whereClause + ' Client_Avail_Language_Type__c in :selectedLangTypes ';
        }
        
        if(selectedWBTerritories.size() > 0){
            if(whereClause.length() > 0) whereClause = whereClause+' and ';
            whereClause = whereClause + ' WB_Territory__c in :selectedWBTerritories ';
        }
        
        if(selectedPriceTiers.size() > 0){
            if(whereClause.length() > 0) whereClause = whereClause+' and ';
            whereClause = whereClause + ' Price_Tier__c in :selectedPriceTiers ';
        }
        
        if(selectedContentTypes.size() > 0){
            if(whereClause.length() > 0) whereClause = whereClause+' and ';
            whereClause = whereClause + ' Title_Content_Type__c in :selectedContentTypes ';
        }
        
        if(selectedCALifeCycles.size() > 0){
            if(whereClause.length() > 0) whereClause = whereClause+' and ';
            whereClause = whereClause + ' CA_Lifecycle__c in :selectedCALifeCycles ';
        }
        
        if(mpmNumbers.size() > 0){
        	List<String> mpmListUpdated = new List<String>();
        	for(Integer mpmIndex=0;mpmIndex<mpmNumbers.size();mpmIndex++){
        		if(mpmNumbers[mpmIndex].trim().length() > 0)
        			mpmListUpdated.add(mpmNumbers[mpmIndex].trim());
        	}
        	
        	mpmNumbers = mpmListUpdated;
        	
            if(whereClause.length() > 0) whereClause = whereClause+' and ';
            whereClause = whereClause + ' Client_Avail__r.Local_Title__r.Title__r.MPM__r.MPM_Number__c in :mpmNumbers ';
        }
        
        
        if(whereClause.length() > 0){
            query = query + ' where '+whereClause;
        }
        
        query = query + ' Order By Title_Video_Version__c,Name Limit 25001 ';
        
        System.debug(LoggingLevel.INFO,'query is ->'+query);
        List<Client_Avail_Price__c> clientAvails = Database.query(String.escapeSingleQuotes(query));
        
        //system.debug('###clientAvails Price:'+clientAvails);
        List<String> wrapperList = new List<String>();
        if(clientAvails.size() > 25000){
        	wrapperList.add('LIMIT EXCEEDED');
        }else{
	        for(Client_Avail_Price__c capRecord:clientAvails){
	            wrapperList.add(capRecord.Id);
	        }
        }
        //System.debug(LoggingLevel.INFO,clientAvails);
        
        return wrapperList;
    }
    
    
    @RemoteAction
    global static List<CAPWrapper> getRecords(List<String> caIDList,String action){
        if(action == RE_PRICE){
            return getCARecords(caIDList);
        }else if(action == PRICE_UPDT){
            return getCAPRecords(caIDList);
        }
        return null;
    }
    
    private static List<CAPWrapper> getCARecords(List<String> caIDList){
        String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); // Need to add a Label for this.
        List<String> selectedContentTypes = getContentTypes(RE_PRICE);
        List<String> selectedCALifeCycles = getCALifeCycles();
        String channelString = 'PO%';
        
        String query = 'Select Id,Name,Title_Video_Version__c,Release_Plan_Title__c,Price_Code__c,Release_Plan_Country__c,AccountF__c,Release_Plan_Channel__c,Release_Plan_Format__c,Release_Plan_Language__c,RP_Language_Type__c,Title_Content_Type__c,Local_Data_Category_Picklist__c,Local_Title__r.Price_Code__c,'+
                                                    ' (Select Id,Name,Effective_Date__c,Expiry_Date__c,Price__c,Price_Tier__c,Episode_Price__c,Episode_Price_Tier__c,SR_Price__c,SR_Per_Episode__c,Price_Code__c,Episode_Price_Override__c  from Client_Avail_Prices__r where recordTypeId = :recTypeId order by Effective_Date__c desc), '+
                                                    ' Start_Date__c,End_Date__c,Price_Start__c,Price__c,Price_Tier_Text__c,Episode_Price__c,Episode_Price_Tier__c,SR_Price__c,SR_Per_Episode__c,Announce_Override__c,'+
                                                    ' (SELECT Id FROM Announcement_Client_Avails__r WHERE (NOT Sales_Channel__c LIKE :channelString) ORDER BY createddate DESC Limit 1) '+
                                                    ' from Client_Avail__c where Id in :caIDList and Title_Content_Type__c in :selectedContentTypes and CA_Lifecycle__c in :selectedCALifeCycles Order By Release_Plan_Title__c,Release_Plan_Country__c,AccountF__c,Release_Plan_Channel__c,Release_Plan_Format__c'; 
        
        System.debug(LoggingLevel.INFO,'Inside getClientAvails method...');
        
        Date todayDate = System.today();
        Integer index = 0;
        List<Client_Avail__c> clientAvails = Database.query(String.escapeSingleQuotes(query));
        Set<String> currentCAPIdSet = new Set<String>();
		
		//ER-004159 - HBO/Turner: Ability to Manually override Episode price - changes
        Map<String,Boolean> epOvrrCAMap = WB_PriceUtility.trackEpOverrEnabledForActiveEpCAMap(clientAvails);
        
        List<CAPWrapper> wrapperList = new List<CAPWrapper>();
        for(Client_Avail__c caRecord:clientAvails){
			
			//ER-004159 - HBO/Turner: Ability to Manually override Episode price - changes
            if(caRecord.Title_Content_Type__c == 'Episode' && epOvrrCAMap != Null && !(epOvrrCAMap.containsKey(caRecord.Id)))
                continue;
			
            CAPWrapper wrapperRecord = new CAPWrapper();
            wrapperRecord.videoVersion = caRecord.Title_Video_Version__c;
            wrapperRecord.title = caRecord.Release_Plan_Title__c;
            wrapperRecord.country = caRecord.Release_Plan_Country__c;
            wrapperRecord.account = caRecord.AccountF__c;
            wrapperRecord.channel = caRecord.Release_Plan_Channel__c;
            wrapperRecord.format = caRecord.Release_Plan_Format__c;
            wrapperRecord.language = caRecord.Release_Plan_Language__c;
            wrapperRecord.languageType = caRecord.RP_Language_Type__c;
            wrapperRecord.contentType = caRecord.Title_Content_Type__c;
            wrapperRecord.caName = caRecord.Name;
            wrapperRecord.caRecordId = caRecord.Id;
            wrapperRecord.caCategory = caRecord.Local_Data_Category_Picklist__c;
            wrapperRecord.priceCodeHidden = caRecord.Local_Title__r.Price_Code__c;
            wrapperRecord.announcementOverride = caRecord.Announce_Override__c;
          //Client_Avail_Price__c capRecord = WB_PriceUtility.getCurrentCAPByStartDate(caRecord);
            wrapperRecord.existingPrice = prepareExistingPriceValue(caRecord,todayDate);
            
            if(caRecord.Announcement_Client_Avails__r.size() > 0){
                wrapperRecord.hasAnnouncement = true;
                wrapperRecord.announcementId = caRecord.Announcement_Client_Avails__r[0].Id;
            }
                
            wrapperList.add(wrapperRecord);
        }
        
        return wrapperList;
    }
    
    private static List<CAPWrapper> getCAPRecords(List<String> capIDList){
        String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME); // Need to add a Label for this.
        /*String query = 'Select Id,Name,Title_Video_Version__c,Release_Plan_Title__c,Price_Code__c,Release_Plan_Country__c,AccountF__c,Release_Plan_Channel__c,Release_Plan_Format__c,Release_Plan_Language__c,RP_Language_Type__c,Title_Content_Type__c,Local_Data_Category_Picklist__c,Local_Title__r.Price_Code__c,'+
                                                    ' (Select Id,Name,Effective_Date__c,Expiry_Date__c,Price__c,Price_Tier__c,Episode_Price__c,Episode_Price_Tier__c,SR_Price__c,SR_Per_Episode__c,Price_Code__c from Client_Avail_Prices__r where recordTypeId = :recTypeId), '+
                                                    ' Start_Date__c,End_Date__c,Price_Start__c,Price__c,Price_Tier_Text__c,Episode_Price__c,Episode_Price_Tier__c,SR_Price__c,SR_Per_Episode__c'+
                                                    ' from Client_Avail__c where Id in :caIDList';*/ 
        String channelString = 'PO%';
        String query = 'Select Id,Name,Effective_Date__c,Expiry_Date__c,Price__c,Price_Tier__c,Episode_Price__c,Episode_Price_Tier__c,SR_Price__c,SR_Per_Episode__c,Price_Code__c,Category__c,Title_Content_Type__c,'+
                        ' Client_Avail__c, Client_Avail__r.Name,Client_Avail__r.Price_Code__c, Title_Video_Version__c,Account__c,Title_Name__c,Country__c,Client_Avail_Channel__c,Client_Avail_Format__c,Client_Avail_Language__c,Client_Avail_Language_Type__c,Client_Avail__r.Announce_Override__c,Client_Avail__r.Status__c, '+
                        ' (SELECT Id FROM Announcement_Records__r WHERE (NOT Sales_Channel__c LIKE :channelString) ORDER BY createddate DESC Limit 1) '+
                        ' from Client_Avail_Price__c where recordTypeId = :recTypeId and Id in :capIDList Order By Title_Video_Version__c,Client_Avail__r.Name';
        
        
        System.debug(LoggingLevel.INFO,'Inside getClientAvails method...');
        
        Integer index = 0;
        List<Client_Avail_Price__c> clientAvailPriceList = Database.query(String.escapeSingleQuotes(query));
        System.debug('####clientAvailPriceList:'+clientAvailPriceList);
        Set<String> currentCAPIdSet = new Set<String>();
        
        List<CAPWrapper> wrapperList = new List<CAPWrapper>();
        for(Client_Avail_Price__c capRecord:clientAvailPriceList){
            CAPWrapper wrapperRecord = new CAPWrapper();
            wrapperRecord.videoVersion = capRecord.Title_Video_Version__c;
            wrapperRecord.title = capRecord.Title_Name__c;
            wrapperRecord.country = capRecord.Country__c;
            wrapperRecord.account = capRecord.Account__c;
            wrapperRecord.channel = capRecord.Client_Avail_Channel__c;
            wrapperRecord.format = capRecord.Client_Avail_Format__c;
            wrapperRecord.language = capRecord.Client_Avail_Language__c;
            wrapperRecord.languageType = capRecord.Client_Avail_Language_Type__c;
            wrapperRecord.contentType = capRecord.Title_Content_Type__c;
            wrapperRecord.capName = capRecord.Name;
            wrapperRecord.caName = capRecord.Client_Avail__r.Name;
            wrapperRecord.capRecordId = capRecord.Id;
            wrapperRecord.caCategory = capRecord.Category__c;
            //wrapperRecord.priceCode = capRecord.Price_Code__c;
            wrapperRecord.priceCodeHidden = capRecord.Client_Avail__r.Price_Code__c;
            
            wrapperRecord.priceEffectDate = capRecord.Effective_Date__c;
            
            if(capRecord.Expiry_Date__c != null){
            //  DateTime dt = DateTime.newInstance(capRecord.Expiry_Date__c.year(),capRecord.Expiry_Date__c.month(),capRecord.Expiry_Date__c.day());
                wrapperRecord.expiryDate = capRecord.Expiry_Date__c.format();
            }
            
            wrapperRecord.price = String.valueOf(capRecord.Price__c);
            wrapperRecord.priceTier = capRecord.Price_Tier__c;
            wrapperRecord.episodePrice = String.valueOf(capRecord.Episode_Price__c);
            wrapperRecord.episodePriceTier = capRecord.Episode_Price_Tier__c;
        	wrapperRecord.announcementOverride = capRecord.Client_Avail__r.Announce_Override__c;
        	
			if(capRecord.Announcement_Records__r.size() > 0){
                wrapperRecord.hasAnnouncement = true;
                wrapperRecord.announcementId = capRecord.Announcement_Records__r[0].Id;
            }
                
            wrapperList.add(wrapperRecord);
        }
        
        wrapperList.sort();
        
        for(CAPWrapper wrapperRecord:wrapperList){
        	if(wrapperRecord.priceEffectDate != null){
            //  DateTime dt = DateTime.newInstance(wrapperRecord.priceEffectDate.year(),wrapperRecord.priceEffectDate.month(),wrapperRecord.priceEffectDate.day());
                wrapperRecord.effectiveDate = wrapperRecord.priceEffectDate.format();
            }
        	wrapperRecord.priceEffectDate = null;
        }
        return wrapperList;
    }
    
        
    @RemoteAction
    global static List<CAPWrapper> savePriceRecords(List<CAPWrapper> capItemWrapperList,String action){
        
        if(action == RE_PRICE){
            return createPriceRecords(capItemWrapperList,action);
        }else if(action == PRICE_UPDT){
            return updatePriceRecords(capItemWrapperList,action);
        }
        return null;
    }
    
    private static List<CAPWrapper> createPriceRecords(List<CAPWrapper> capItemWrapperList,String action){
            System.debug(LoggingLevel.INFO,' capItemWrapperList ->'+capItemWrapperList);
        System.debug(LoggingLevel.INFO,Limits.getHeapSize() +' '+Limits.getLimitHeapSize());
        System.debug(LoggingLevel.INFO,Limits.getCpuTime()  +' '+Limits.getLimitCpuTime());
        
        String recTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME);
        Integer totalFailedRecords = 0;
        List<String> caNameList = new  List<String>();
        Set<String> annOverrideValues = WB_PriceUtility.getAnnouncementOverridePicklistValues();
        Set<String> picklistValues = WB_PriceUtility.getCAPCategoryPicklistValues();
         
        for(CAPWrapper wrapper:capItemWrapperList){
            if(wrapper.isRowModified == true)
                caNameList.add(wrapper.caName);
        }
        
        List<Client_Avail__c> caList = [Select Id,Name,CurrencyIsoCode,Title_Video_Version__c,Release_Plan_Title__c,Price_Code__c,Release_Plan_Country__c,AccountF__c,Release_Plan_Channel__c,Release_Plan_Format__c,Release_Plan_Language__c,RP_Language_Type__c,Title_Content_Type__c,CA_Lifecycle__c,Local_Title__c,Local_Title__r.Price_Code__c,PlayList__r.Total_Playlist_Content__c,Title__c from Client_Avail__c where Name in :caNameList];
        system.debug('####caList-:'+caList);
        Map<String,Client_Avail__c> caNameRecMap = new Map<String,Client_Avail__c>();
        Map<String,Client_Avail__c> caIdRecMap = new Map<String,Client_Avail__c>();
        
        for(Client_Avail__c caRecord:caList){
            caNameRecMap.put(caRecord.Name,caRecord);
            caIdRecMap.put(caRecord.Id,caRecord);
        }
            
        
        List<Client_Avail_Price__c> capRecordList = new List<Client_Avail_Price__c>(); 
        List<CAPWrapper> validWrapperRecords = new List<CAPWrapper>();
        
        Set<String> contentTypeSet = new Set<String>();
        contentTypeSet.addAll(getContentTypes(action));
        Set<String> lifeCycleSet = new Set<String>();
        lifeCycleSet.addAll(getCALifeCycles());
        
        for(CAPWrapper wrapper:capItemWrapperList){
            
            Client_Avail__c caRecord = caNameRecMap.get(wrapper.caName);
            
            if(!(wrapper.isRowModified == true))
                continue;
                
            if(caRecord == null){
                wrapper.validation = WB_PriceUtility.INV_CA_ID+wrapper.caName;
                totalFailedRecords++;
                continue;   
            }else if(!contentTypeSet.contains(caRecord.Title_Content_Type__c)){
                wrapper.validation = WB_PriceUtility.INV_CONT_TYPE_RE_PRICE+caRecord.Title_Content_Type__c;
                totalFailedRecords++;
                continue;
            }else if(!lifeCycleSet.contains(caRecord.CA_Lifecycle__c)){
                wrapper.validation = WB_PriceUtility.INV_CA_LIFE_CYCL+caRecord.CA_Lifecycle__c;
                totalFailedRecords++;
                continue;
            }
            
            if(wrapper.contentType == null && caRecord.Title_Content_Type__c == WB_PriceUtility.SEASON){
                wrapper.contentType = caRecord.Title_Content_Type__c;
                wrapper.episodeCount = caRecord.PlayList__r.Total_Playlist_Content__c != null?caRecord.PlayList__r.Total_Playlist_Content__c.intValue():0;
                continue;
            }else{
                system.debug('####failed 1');
                wrapper.contentType = null;
            }
            
            String announceOverride = wrapper.announcementOverride;
            if(!isDataValid(wrapper,action,caRecord.Title_Content_Type__c)){ 
                 system.debug('####failed 2');
                totalFailedRecords++;
                continue;
            }else if( announceOverride != null && announceOverride.trim().length() > 0 && !annOverrideValues.contains(announceOverride.trim().toUpperCase())){
                wrapper.validation = WB_PriceUtility.INV_ANN_OVERRIDE;
                totalFailedRecords++;
                continue;
            }else if(!picklistValues.contains(wrapper.caCategory.trim().toUpperCase())){
        		wrapper.validation = WB_PriceUtility.INVALID_CATEGORY_ERROR;
            	totalFailedRecords++;
                continue;
        	}
            
            Client_Avail_Price__c capRecord = new Client_Avail_Price__c();
            capRecord.Client_Avail__c = caRecord.Id;
            capRecord.Title__c = caRecord.Title__c;
            capRecord.CurrencyIsoCode = caRecord.CurrencyIsoCode;
            capRecord.Effective_Date__c =  Date.parse(wrapper.effectiveDate);
            capRecord.Price__c =  wrapper.price != null?Decimal.valueOf(wrapper.price):null;
            capRecord.Price_Tier__c = wrapper.priceTier;
            capRecord.Episode_Price__c = wrapper.episodePrice != null?Decimal.valueOf(wrapper.episodePrice):null;
            capRecord.Episode_Price_Tier__c = wrapper.episodePriceTier;
      //    capRecord.SR_Price__c =  wrapper.srPrice!=null?Decimal.valueOf(wrapper.srPrice):null;
      //    capRecord.SR_Per_Episode__c= wrapper.srPerEpisode!=null?Decimal.valueOf(wrapper.srPerEpisode):null;
            capRecord.Category__c = wrapper.caCategory;
            capRecord.Internal_Comment__c = wrapper.internalComment;
            if(wrapper.priceCode != null && wrapper.priceCode.trim().length() > 0){
                capRecord.Price_Code__c = wrapper.priceCode;
            }
            
            capRecord.Announce_Override__c = wrapper.announcementOverride;
            
            capRecordList.add(capRecord);
            validWrapperRecords.add(wrapper);
        }
        
        
         
        if(capRecordList.size() > 0){
            Database.SaveResult[] rePriceResult = Database.insert(capRecordList,false);
            
            //Map<String,CAPWrapper> caNameOverrideFlagMap = new Map<String,CAPWrapper>();
            List<String> successCANameList = new List<String>();
            
            for(Integer index=0;index<rePriceResult.size();index++){
                if(rePriceResult[index].isSuccess()){
                    successCANameList.add(validWrapperRecords.get(index).caName);
                //  caNameOverrideFlagMap.put(validWrapperRecords.get(index).caName,validWrapperRecords.get(index));
                }
            }
            
            Date todayDate = System.today();
            Map<String,String> caNameExistingPriceMap = new Map<String,String>();
            if(successCANameList.size() > 0){
                
                //List<Client_Avail__c> announceOverrideList = new List<Client_Avail__c>();
                
                List<Client_Avail__c> successRePriceCAList = [Select Id,Name,Title_Content_Type__c,(Select Id,Name,Effective_Date__c,Expiry_Date__c,Price__c,Price_Tier__c,Episode_Price__c,Episode_Price_Tier__c from Client_Avail_Prices__r where recordTypeId = :recTypeId order by Effective_Date__c desc) from Client_Avail__c where Name in :successCANameList];
                
                for(Client_Avail__c caRecord:successRePriceCAList){
                    caNameExistingPriceMap.put(caRecord.Name,prepareExistingPriceValue(caRecord,todayDate));
                    
                    /*CAPWrapper wrapper = caNameOverrideFlagMap.get(caRecord.Name);
                    if(wrapper != null && wrapper.announcementOverride != null && wrapper.announcementOverride.trim().length() > 0){
                        caRecord.Announce_Override__c = wrapper.announcementOverride;
                        announceOverrideList.add(caRecord);
                    }*/
                }
                
                /*if(announceOverrideList.size() > 0){
                    List<Database.SaveResult> caSaveResult = Database.update(announceOverrideList,false);
                }*/   
            }
            
            for(Integer index=0;index<rePriceResult.size();index++){
                validWrapperRecords.get(index).numFailedRecords = 0;
                if(rePriceResult[index].isSuccess()){
                    validWrapperRecords.get(index).validation = 'Success';
                    validWrapperRecords.get(index).isRowModified = false;
                    if(caNameExistingPriceMap.get(validWrapperRecords.get(index).caName) != null)
                        validWrapperRecords.get(index).existingPrice = caNameExistingPriceMap.get(validWrapperRecords.get(index).caName);
                }else{
                    for(Database.Error err : rePriceResult[index].getErrors()) {
                        validWrapperRecords.get(index).validation = err.getMessage();
                        totalFailedRecords++;
                        break;
                    }
                }
            }
        }
        
        capItemWrapperList[0].numFailedRecords = totalFailedRecords;
        
        System.debug(LoggingLevel.INFO,'[DML   Rows -> '+ Limits.getDMLRows()   +']\t\t  [DML   Rows Limit -> '+   Limits.getLimitDMLRows()+']');
        System.debug(LoggingLevel.INFO,'[Query Rows -> '+ Limits.getQueryRows() +']\t\t [Query Rows Limit -> '+  Limits.getLimitQueryRows()+']');
        
        return capItemWrapperList;
    }
    
    
    private static List<CAPWrapper> updatePriceRecords(List<CAPWrapper> capItemWrapperList,String action){
        System.debug(LoggingLevel.INFO,' capItemWrapperList size is ->'+capItemWrapperList.size());
        System.debug(LoggingLevel.INFO,Limits.getHeapSize() +' '+Limits.getLimitHeapSize());
        System.debug(LoggingLevel.INFO,Limits.getCpuTime()  +' '+Limits.getLimitCpuTime());
        Integer totalFailedRecords = 0;
        List<String> capNameList = new  List<String>();
        Set<String> annOverrideValues = WB_PriceUtility.getAnnouncementOverridePicklistValues();
   //   Map<String,String> announceOverrideMap = new Map<String,String>();
        Set<String> picklistValues = WB_PriceUtility.getCAPCategoryPicklistValues();
  //    Set<String> caStatusValues = WB_PriceUtility.getCAStatusPicklistValues();
        for(CAPWrapper wrapper:capItemWrapperList){
            if(wrapper.isRowModified == true)
                capNameList.add(wrapper.capName);
        }
        
        List<Client_Avail_Price__c> capList = [Select Id,Name,Client_Avail__c,Title_Content_Type__c,Client_Avail__r.PlayList__r.Total_Playlist_Content__c from Client_Avail_Price__c where Name in :capNameList];
        
        Map<String,Client_Avail_Price__c> capNameRecMap = new Map<String,Client_Avail_Price__c>();
        Map<String,Client_Avail_Price__c> capIdRecMap = new Map<String,Client_Avail_Price__c>();
        
        for(Client_Avail_Price__c capRecord:capList){
            capNameRecMap.put(capRecord.Name,capRecord);
            capIdRecMap.put(capRecord.Id,capRecord);
        }
            
        
        List<Client_Avail_Price__c> capRecordList = new List<Client_Avail_Price__c>(); 
        List<CAPWrapper> validWrapperRecords = new List<CAPWrapper>();
        
        Set<String> contentTypeSet = new Set<String>();
        contentTypeSet.addAll(getContentTypes(action));
        Set<String> lifeCycleSet = new Set<String>();
        lifeCycleSet.addAll(getCALifeCycles());
        
        for(CAPWrapper wrapper:capItemWrapperList){
            
            Client_Avail_Price__c existingCapRecord = capNameRecMap.get(wrapper.capName);
            
            if(!(wrapper.isRowModified == true))
                continue;
                
            if(existingCapRecord == null){
                wrapper.validation = WB_PriceUtility.INV_CAP_ID+wrapper.capName;
                totalFailedRecords++;
                continue;   
            }else if(!contentTypeSet.contains(existingCapRecord.Title_Content_Type__c)){
                wrapper.validation = WB_PriceUtility.INV_CONT_TYPE_PRICE_UPDATE+existingCapRecord.Title_Content_Type__c;
                totalFailedRecords++;
                continue;
            }/*else if(!lifeCycleSet.contains(existingCapRecord.CA_Lifecycle__c)){
                wrapper.validation = 'Price Update does not support CA Life Cycle - '+existingCapRecord.CA_Lifecycle__c;
                totalFailedRecords++;
                continue;
            }*/
            
            if(wrapper.contentType == null && existingCapRecord.Title_Content_Type__c == WB_PriceUtility.SEASON){
                wrapper.contentType = existingCapRecord.Title_Content_Type__c;
                wrapper.episodeCount = existingCapRecord.Client_Avail__r.PlayList__r.Total_Playlist_Content__c != null?existingCapRecord.Client_Avail__r.PlayList__r.Total_Playlist_Content__c.intValue():0;
                continue;
            }else{
                wrapper.contentType = null;
            }
            
            String announceOverride = wrapper.announcementOverride;
            //String caStatus = wrapper.caStatus;
            
            if(wrapper.priceCode != null && wrapper.priceCode.trim().length() > 0){
                wrapper.price = null;
	            wrapper.priceTier = null;
	            wrapper.episodePrice = null;
	            wrapper.episodePriceTier = null;
            }
            
            if(!isDataValid(wrapper,action,existingCapRecord.Title_Content_Type__c)){ 
                totalFailedRecords++;
                continue;
            }else if(announceOverride != null && announceOverride.trim().length() > 0 && !annOverrideValues.contains(announceOverride.trim().toUpperCase())){
                wrapper.validation = WB_PriceUtility.INV_ANN_OVERRIDE;
                totalFailedRecords++;
                continue;
            }else if(!picklistValues.contains(wrapper.caCategory.trim().toUpperCase())){
        		wrapper.validation = WB_PriceUtility.INVALID_CATEGORY_ERROR;
            	totalFailedRecords++;
                continue;
        	}/*else if(caStatus != null && caStatus.trim().length() > 0 && !caStatusValues.contains(caStatus.trim().toUpperCase())){
        		wrapper.validation = 'Invalid Status';
            	totalFailedRecords++;
                continue;
        	}*/
            
            Client_Avail_Price__c capRecord = new Client_Avail_Price__c(Id=existingCapRecord.Id,Client_Avail__c = existingCapRecord.Client_avail__c);
            capRecord.Effective_Date__c =  Date.parse(wrapper.effectiveDate);
            capRecord.Price__c =  wrapper.price != null?Decimal.valueOf(wrapper.price):null;
            capRecord.Price_Tier__c = wrapper.priceTier;
            capRecord.Episode_Price__c = wrapper.episodePrice != null?Decimal.valueOf(wrapper.episodePrice):null;
            capRecord.Episode_Price_Tier__c = wrapper.episodePriceTier;
        //  capRecord.SR_Price__c =  wrapper.srPrice!=null?Decimal.valueOf(wrapper.srPrice):null;
        //  capRecord.SR_Per_Episode__c= wrapper.srPerEpisode!=null?Decimal.valueOf(wrapper.srPerEpisode):null;
            capRecord.Category__c = wrapper.caCategory;
            capRecord.Internal_Comment__c = wrapper.internalComment;
            if(wrapper.priceCode != null && wrapper.priceCode.trim().length() > 0){
                capRecord.Price_Code__c = wrapper.priceCode;
            }else{
            	capRecord.Price_Code__c = null;
            }
            capRecord.Announce_Override__c = wrapper.announcementOverride;
            //capRecord.CA_Status__c = wrapper.caStatus;
            
            capRecordList.add(capRecord);
            validWrapperRecords.add(wrapper);
        //  announceOverrideMap.put(wrapper.capName,existingCapRecord.Client_avail__c);
        }
        
        
        
        Map<String,CAPWrapper> capsWithPriceCodeMap = new Map<String,CAPWrapper>();
        
        if(capRecordList.size() > 0){
            Database.SaveResult[] rePriceResult = Database.update(capRecordList,false);
            
            for(Integer index=0;index<rePriceResult.size();index++){
                validWrapperRecords.get(index).numFailedRecords = 0;
                if(rePriceResult[index].isSuccess()){
                    validWrapperRecords.get(index).validation = 'Success';
                    validWrapperRecords.get(index).isRowModified = false;
                    if(validWrapperRecords.get(index).priceCode != null && validWrapperRecords.get(index).priceCode.trim().length() > 0){
                    	capsWithPriceCodeMap.put(capRecordList[index].Id,validWrapperRecords.get(index));	
                    }
                }else{
                    for(Database.Error err : rePriceResult[index].getErrors()) {
                        validWrapperRecords.get(index).validation = err.getMessage();
                        totalFailedRecords++;
                        break;
                    }
                }
            }
        }
        
        
        if(capsWithPriceCodeMap.size() > 0){
            List<Client_Avail_Price__c> priceCodeCAPList = [Select Id,Name,Price__c,Price_Tier__c,Episode_Price__c,Episode_Price_Tier__c from Client_Avail_Price__c where Id in :capsWithPriceCodeMap.keySet()];
            for(Client_Avail_Price__c capRecord:priceCodeCAPList){
            	CAPWrapper wrapper = capsWithPriceCodeMap.get(capRecord.Id);
            	if(wrapper != null){
            		wrapper.price = String.valueOf(capRecord.Price__c);
		            wrapper.priceTier = capRecord.Price_Tier__c;
		            wrapper.episodePrice = String.valueOf(capRecord.Episode_Price__c);
		            wrapper.episodePriceTier = capRecord.Episode_Price_Tier__c;
            	}		
            }
        }  
                
        capItemWrapperList[0].numFailedRecords = totalFailedRecords;
        
        System.debug(LoggingLevel.INFO,'[DML   Rows -> '+ Limits.getDMLRows()   +']\t\t  [DML   Rows Limit -> '+   Limits.getLimitDMLRows()+']');
        System.debug(LoggingLevel.INFO,'[Query Rows -> '+ Limits.getQueryRows() +']\t\t [Query Rows Limit -> '+  Limits.getLimitQueryRows()+']');
        
        return capItemWrapperList;
    }
    
    private static String prepareExistingPriceValue(Client_Avail__c caRecord,Date todayDate){
        
        String existingPrice = '';
        
        if(caRecord.Client_Avail_Prices__r != null && caRecord.Client_Avail_Prices__r.size() > 0){
            for(Client_Avail_Price__c capRecord:caRecord.Client_Avail_Prices__r){
                        
            //   if(capRecord.Expiry_Date__c < todayDate)
            //	   break;
                    
            //    DateTime dt = DateTime.newInstance(capRecord.Effective_Date__c.year(),capRecord.Effective_Date__c.month(),capRecord.Effective_Date__c.day());
                existingPrice = existingPrice + capRecord.Effective_Date__c.format() +'\t';
                
           //     dt = DateTime.newInstance(capRecord.Expiry_Date__c.year(),capRecord.Expiry_Date__c.month(),capRecord.Expiry_Date__c.day());
                existingPrice = existingPrice +' - '+ capRecord.Expiry_Date__c.format() +'\t';
                
                existingPrice =  existingPrice +' - '+(capRecord.Price__c!=null?String.valueOf(capRecord.Price__c.setScale(2)):capRecord.Price_Tier__c)+'\t';
                
                if(caRecord.Title_Content_Type__c == WB_PriceUtility.SEASON){
                    existingPrice = existingPrice +' - '+ (capRecord.Episode_Price__c != null ?String.valueOf(capRecord.Episode_Price__c.setScale(2)) : capRecord.Episode_Price_Tier__c)+'\r\n';
                }else{
                    existingPrice = existingPrice +'\r\n';
                }
            }
        }
        
        return  existingPrice;
    } 
    
    @testVisible
    private static Boolean isDataValid(CAPWrapper wrapper,String action,String titleContentType){
        Boolean isValid = true;
        
        if(wrapper.caCategory == null || wrapper.caCategory.trim().length() == 0){
            wrapper.validation = WB_PriceUtility.CATEGORY_REQ; 
            return false;
        }
        
        try{
        	Date priceStartDate = Date.parse(wrapper.effectiveDate);
        	/*if(priceStartDate == null){
        		wrapper.validation = WB_PriceUtility.INV_CAP_START_DT;
            	return false;
        	}*/
        	
            if(action == RE_PRICE && priceStartDate < System.today()){
                wrapper.validation = WB_PriceUtility.PRICE_DATE_PAST;
                return false;
            }
        }catch(Exception ex){
            wrapper.validation = WB_PriceUtility.INV_CAP_START_DT;
            return false;           
        }
        
        try{
            if(wrapper.price != null && wrapper.price.trim().length() > 0){
                Decimal.valueOf(wrapper.price);
                if(wrapper.priceTier != null && wrapper.priceTier.trim().length() > 0){
                    wrapper.validation = WB_PriceUtility.PR_PRT_MX_ERROR;
                    return false;
                }
            }else if(wrapper.priceTier == null || wrapper.priceTier.trim().length() == 0){
                //show error if price code is blank. for Re-Price/Update
                if(wrapper.priceCode == null || wrapper.priceCode.trim().length() == 0){
                    wrapper.validation = WB_PriceUtility.PRC_CODE_OR_PRICE;
                    return false;   
                }   
            }
            
        }catch(Exception ex){
            wrapper.validation = WB_PriceUtility.INV_WSP;
            return false;
        }
        
        try{
            if(wrapper.episodePrice != null && wrapper.episodePrice.trim().length() > 0){
                Decimal.valueOf(wrapper.episodePrice);
                if(wrapper.episodePriceTier != null && wrapper.episodePriceTier.trim().length() > 0){
                    wrapper.validation = WB_PriceUtility.EPR_EPRT_MX_ERROR;
                    return false;
                }
            }else if(wrapper.episodePriceTier == null || wrapper.episodePriceTier.trim().length() == 0){
                //show error if price code is blank. for Re-Price/Update, for Season
                if(titleContentType == WB_PriceUtility.SEASON && (wrapper.priceCode == null || wrapper.priceCode.trim().length() == 0)){
                    wrapper.validation = WB_PriceUtility.PRC_CODE_OR_EPRICE;
                    return false;   
                }
            }
            
        }catch(Exception ex){
            wrapper.validation = WB_PriceUtility.INV_EWSP;
            return false;
        }
        
        if(action == RE_PRICE){
            if(wrapper.priceCode != null && wrapper.priceCode.trim().length() > 0){
                if((wrapper.price != null && wrapper.price.trim().length() > 0) || (wrapper.priceTier != null && wrapper.priceTier.trim().length() > 0)){
                    wrapper.validation = WB_PriceUtility.PRC_CODE_OR_PRICE;
                    return false;
                }
                
                if(titleContentType == WB_PriceUtility.SEASON && ((wrapper.episodePrice != null && wrapper.episodePrice.trim().length() > 0) || (wrapper.episodePriceTier != null && wrapper.episodePriceTier.trim().length() > 0))){
                    wrapper.validation = WB_PriceUtility.PRC_CODE_OR_EPRICE;
                    return false;
                }
            }
        }
        
        /*try{
            
            if(wrapper.srPrice != null && wrapper.srPrice.trim().length() > 0)
                Decimal.valueOf(wrapper.srPrice);
                
            if(wrapper.srPerEpisode != null && wrapper.srPerEpisode.trim().length() > 0)    
                Decimal.valueOf(wrapper.srPerEpisode);
                
        }catch(Exception ex){
            wrapper.validation = 'Invalid SR Price/SR Per Episode.';
            return false;
        }*/ 
        return true;
    }
    
    /*public static Date getDate(String dateString){
    	String[] dateValues = dateString.split('/');
    	Integer yearVal = Integer.valueOf(dateValues[2]);
    	Integer monthVal = Integer.valueOf(dateValues[0]);
    	Integer dateVal = Integer.valueOf(dateValues[1]);
    	
    	if(monthVal > 12){
    		return null;
    	}else if(dateVal > Date.daysInMonth(yearVal,monthVal)){
    		return null;
    	}
		return Date.newInstance(yearVal,monthVal,dateVal);
    }*/
    
    @RemoteAction
    global static List<FilterWrapper> getFilterData(String filterName,String action){
        List<FilterWrapper> filterList = new List<FilterWrapper>();
        if(filterName == 'Countries'){
            for(Country__c country:[Select Name,Country_Code__c from Country__c Order By Name])
                filterList.add(new FilterWrapper(country.Country_Code__c,country.Name));
        }else if(filterName == 'Accounts'){
            String dcRecTypeId = WB_PriceUtility.getRecordTypeId(Account.getSobjectType(),WB_PriceUtility.DC_RT_NAME);
            for(Account accountRec:[Select Id,Name from Account where RecordTypeId = :dcRecTypeId Order By Name])
                filterList.add(new FilterWrapper(accountRec.Name,accountRec.Name));
        }else if(filterName == 'Channels'){
            filterList.add(new FilterWrapper('DTD','DTD'));
            filterList.add(new FilterWrapper('EST','EST'));
            filterList.add(new FilterWrapper('Hotel','Hotel'));
            filterList.add(new FilterWrapper('PPV','PPV'));
            filterList.add(new FilterWrapper('VODc','VODc'));
            filterList.add(new FilterWrapper('VODi','VODi'));
        }else if(filterName == 'Formats'){
            filterList.add(new FilterWrapper('SD','SD'));
            filterList.add(new FilterWrapper('HD','HD'));
            filterList.add(new FilterWrapper('3DHD','3DHD'));
            filterList.add(new FilterWrapper('4K UHD','4K UHD'));
        }else if(filterName == 'Languages'){
            for(Language__c language:[Select Name from Language__c Order By Name])
                filterList.add(new FilterWrapper(language.Name,language.Name));
        }else if(filterName == 'LanguageTypes'){
            filterList.add(new FilterWrapper('Audio','Audio'));
            filterList.add(new FilterWrapper('Sub','Sub'));
            filterList.add(new FilterWrapper('Sub & Audio','Sub & Audio'));
        }else if(filterName == 'WBTerritories'){
            Set<String> territorySet = new Set<String>();
            for(Country__c country:[Select Territory__c from Country__c Order By Territory__c]){
                if(!territorySet.contains(country.Territory__c)){
                    filterList.add(new FilterWrapper(country.Territory__c,country.Territory__c));
                    territorySet.add(country.Territory__c);
                }
            }
        }else if(filterName == 'PriceTiers'){
            Set<String> priceTierSet = new Set<String>();
            priceTierSet.add(WB_PriceUtility.PRICE_TIER_TBD);
            priceTierSet.add(WB_PriceUtility.PRICE_TIER_NA);
            //Updated on 10/5/2018 - SINC1931025
            /*
            List<AggregateResult> aggrList = [Select Price_Tier__c from Pricing__c group by Price_Tier__c ];
            for(AggregateResult aggr:aggrList ){
                if(!priceTierSet.Contains((String)aggr.get('Price_Tier__c'))){
                    priceTierSet.add((String)aggr.get('Price_Tier__c'));
                }
            }
           */
           
            for(List<Pricing__c> priceList:[Select Price_Tier__c from Pricing__c Order By Price_Tier__c Limit 49500]){
                 for(Pricing__c prc:priceList){
                     if(!priceTierSet.Contains(prc.Price_Tier__c)){
                        priceTierSet.add(prc.Price_Tier__c);
                    }
                }
            }
            
			
			List<String> priceTiers = new List<String>(priceTierSet);
			priceTiers.sort();
			for(String prcTier:priceTiers){
           		filterList.add(new FilterWrapper(prcTier,prcTier));
			}            
            
        }else if(filterName == 'ContentTypes'){
            for(String contentType:getContentTypes(action)){
                filterList.add(new FilterWrapper(contentType,contentType));
            } 
        }else if(filterName == 'CALifeCycles'){
            for(String lifeCycle:getCALifeCycles()){
                filterList.add(new FilterWrapper(lifeCycle,lifeCycle));
            }
        }
        return  filterList;
    }
    
    public static List<String> getContentTypes(String action){
        List<String> contentTypeList = new List<String>();
        contentTypeList.add('Collection Features');
        contentTypeList.add('Collection TV');
        contentTypeList.add('Feature');
    //  contentTypeList.add('Game');
    //  contentTypeList.add('Music');
        contentTypeList.add('Season');
		contentTypeList.add('Episode'); //ER-004159 - HBO/Turner: Ability to Manually override Episode price - changes
        
        //ER-004159 - HBO/Turner: Ability to Manually override Episode price - changes commented below code
        //if(action == PRICE_UPDT)
           // contentTypeList.add('Episode');
            
        return contentTypeList;
    } 
    
    public static List<String> getCALifeCycles(){
        List<String> caLifeCycleList = new List<String>();
        caLifeCycleList.add('Active Future');
        caLifeCycleList.add('Active Current');
    //  caLifeCycleList.add('History Expired');
    //  caLifeCycleList.add('History Deleted');
    //  caLifeCycleList.add('Cancelled');
        
        return caLifeCycleList;
    }
    
    public String getUserLocale() {
        String currentUserLocale = UserInfo.getLocale();
        if (currentUserLocale.contains('_')) {
            currentUserLocale = currentUserLocale.replace( '_', '-');
        }
        return currentUserLocale;
    }
    
    global class FilterWrapper{
        public String value;
        public String label;
        public Boolean selected;
        
        public FilterWrapper(String value,String label){
            this.value = value;
            this.label = label;
            this.selected = false;  
        }
    }
    
    global class FilterCriteria{
        
        public String processName;
        public List<String> selectedCountries;
        public List<String> selectedAccounts;
        public List<String> selectedChannels;
        public List<String> selectedFormats;
        public List<String> selectedLangs;
        public List<String> selectedLangTypes;
        public List<String> selectedWBTerritories;
        public List<String> selectedPriceTiers;
        public List<String> selectedContentTypes;
        public List<String> selectedCALifeCycles;
        public List<String> mpmNumbers;  
    }
    
    global class CAPWrapper implements Comparable{
        public String videoVersion;
        public String title;
        public String account;
        public String country;
        public String channel;
        public String format;
        public String language;
        public String contentType;
        public String languageType;
        public String capRecordId;
        public String caRecordId;
        public String caCategory;
        public String priceCode;
        public String priceCodeHidden;
        public String effectiveDate;
        public String expiryDate;
        public String price;
        public String priceTier;
        public String episodePrice;
        public String episodePriceTier;
        public String srPrice;
        public String srPerEpisode;
        public String caName;
        public String capName;
        public String internalComment;
        public Date priceEffectDate;
        public String existingPrice;
        
        public String validation='';
        
        public boolean isRowModified=false;
        public boolean isRowRemoved=false;
        public boolean previouslySelectedForRemoval=false;
        public Integer rowIndex;
        public Integer episodeCount;
        public boolean hasAnnouncement = false;
        public boolean hasFuturePrice = false;
        public String announcementId;
        public String announcementOverride;
        public String caStatus;
        
        /*Preperties to track changed values*/
        public boolean iscaCategory;
        public boolean ispriceCode;
        public boolean iseffectiveDate;
        public boolean isprice;
        public boolean ispriceTier;
        public boolean isepisodePrice;
        public boolean isepisodePriceTier;
        public boolean isannouncementOverride;
        public boolean isinternalComment;
		public boolean iscaName;
		public boolean iscapName;
		
        // totalFailedRecords: Number of failed records during (insert/update/delete) operations to be displayed on VF page
        // totalFailedRecords will be taken from first wrapper record always by VF javascript 
        public Integer numFailedRecords;
        
        public String message;
        
        public Integer compareTo(Object obj) {
            CAPWrapper capRecord = (CAPWrapper)(obj);
            
            try{
	            Integer compareResult = title.compareTo(capRecord.title);
	            if(compareResult == 0){
	            	compareResult = country.compareTo(capRecord.country);
	                if(compareResult == 0){
    	            	compareResult = account.compareTo(capRecord.account);
    	            	if(compareResult == 0){
    	            		compareResult = channel.compareTo(capRecord.channel);
    	            		if(compareResult == 0){
    	            			compareResult = format.compareTo(capRecord.format);
    	            			if(compareResult == 0){
    	            				compareResult = caName.compareTo(capRecord.caName);
    	            				if(compareResult == 0){
    				            		if( priceEffectDate == capRecord.priceEffectDate){
    				                		return 0;
    				                	}else if(priceEffectDate < capRecord.priceEffectDate){
    				                		return 1;
    				                	}else{
    				                		return -1;
    				                	}
    	            				}
    	            			}
    	            		}
    	            	}
	                }
	            }
	            
	            return compareResult;
	            
            }catch(Exception ex){
            	System.debug(LoggingLevel.INFO,'Exception in sorting'+ex.getMessage());
            }
            return 0;
        }
    }
    
    
    public static final String RE_PRICE = 'rePrice';
    public static final String PRICE_UPDT = 'priceUpdate';    
}