public class WB_ClientAvailTempPriceHandler {
	
	
	public static void validateTempPrice(List<Client_Avail_Price__c> capList,String operation){
		List<Client_Avail_Price__c> tempCAPList = getTempPriceRecords(capList);
		 List<String> caIDList = new List<String>();
		if(tempCAPList.isEmpty())
			return;
			
		//Profile validation. if GPP, throw error
		Id profileId=userinfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        WB_GPP_Pricing_Profiles__c loginedInUserProfile = WB_GPP_Pricing_Profiles__c.getInstance(profileName);
        String objectName = 'CAP';   
        if(loginedInUserProfile != null && !loginedInUserProfile.TPP_Enable__c){
			for(Client_Avail_Price__c tempCap:tempCAPList){
				tempCap.addError('Insufficient access rights on object');
			}
        }else if(operation != WB_PriceUtility.DELETE_OP){
        //    WB_PriceUtility.setPublishFlagToClient(tempCAPList,objectName);
        }
            
         
		
	}
	
	
	public static void updateClientAvailWithTempPrice(List<Client_Avail_Price__c> capList,Map<Id,Client_Avail_Price__c> oldCapMAP,String operation){
		List<Client_Avail_Price__c> tempCAPList = getTempPriceRecords(capList);
		if(tempCAPList.isEmpty())
			return;
		
		try{
			String ppRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME);
			Map<String,Integer> countryOffsetMap = WB_PriceUtility.getCountryOffset();
	        DateTime currentTime = System.now();
	        Date currentDate = System.today();
			Set<String> caIDSet = new Set<String>();
	    	for(Client_Avail_Price__c capRecord:tempCAPList){
	    		caIDSet.add(capRecord.Client_Avail__c);
	    	}
	    	
	    	Map<Id,Client_Avail__c>  updatedClientAvailMap = new Map<Id,Client_Avail__c>();
	    	Map<Id,Client_Avail__c>  clientAvailMap = new Map<Id,Client_Avail__c>([Select Id,Name,Commercial_Avail__r.Country_Code__c,Start_Date__c,Price_Start__c,Price_End__c,Price__c,Price_Tier_Text__c,Episode_Price__c,Episode_Price_Tier__c,Title_Content_Type__c,APO_Date__c,
	    																				(Select Id,Name,Effective_Date__c,Expiry_Date__c,Price__c,Price_Tier__c,Episode_Price__c,Episode_Price_Tier__c,Category__c from Client_Avail_Prices__r Where Expiry_Date__c >= :currentDate and RecordTypeId=:ppRecTypeId Order by Effective_Date__c) 
	    																				From Client_Avail__c Where Id In :caIDSet]);
	    	for(Client_Avail_Price__c tempCapRecord:tempCAPList){
	    		Client_Avail__c caRecord = clientAvailMap.get(tempCapRecord.Client_Avail__c);
	    		if(caRecord == null) continue;
	    		Boolean populatePermPrice = false;
	    		String countryCode = caRecord.Commercial_Avail__r.Country_Code__c;
	    		Boolean isCurrentPrice = WB_PriceUtility.isCurrentPrice(tempCapRecord,countryCode,countryOffsetMap,currentTime);
	    		if(isCurrentPrice || (caRecord.APO_Date__c != null ?(tempCapRecord.Effective_Date__c == caRecord.APO_Date__c && caRecord.APO_Date__c >= currentDate) : (tempCapRecord.Effective_Date__c == caRecord.Start_Date__c && caRecord.Start_Date__c >= currentDate))){
		    		if(operation == WB_PriceUtility.INSERT_OP || operation == WB_PriceUtility.UPDATE_OP){
		    			if(!WB_PriceUtility.isPriceSame(caRecord,tempCapRecord) ||	caRecord.Price_Start__c != tempCapRecord.Effective_Date__c || caRecord.Price_End__c != tempCapRecord.Expiry_Date__c){
	            			populatePriceOnClientAvail(caRecord,tempCapRecord,WB_PriceUtility.TEMP_PRICE_RT_NAME);
	            			updatedClientAvailMap.put(caRecord.Id,caRecord);						
	            		}
		    		}else if(operation == WB_PriceUtility.DELETE_OP){
		    			populatePermPrice = true;
		    		}
	    		}else if(operation == WB_PriceUtility.UPDATE_OP){
	    			isCurrentPrice = WB_PriceUtility.isCurrentPrice(oldCapMAP.get(tempCapRecord.Id),countryCode,countryOffsetMap,currentTime);
	    			if(isCurrentPrice || (caRecord.APO_Date__c != null?(oldCapMAP.get(tempCapRecord.Id).Effective_Date__c == caRecord.APO_Date__c && caRecord.APO_Date__c >= currentDate) : (oldCapMAP.get(tempCapRecord.Id).Effective_Date__c == caRecord.Start_Date__c && caRecord.Start_Date__c >= currentDate))){
	    				populatePermPrice = true;	
	    			}
	    		}
	    		
	    		if(populatePermPrice && caRecord.Client_Avail_Prices__r != null && !caRecord.Client_Avail_Prices__r.isEmpty()){
	    			for(Client_Avail_Price__c permCapRecord:caRecord.Client_Avail_Prices__r){
		    			if(isCurrentPrice || (permCapRecord.Effective_Date__c == caRecord.APO_Date__c && caRecord.APO_Date__c >= currentDate) || (permCapRecord.Effective_Date__c == caRecord.Start_Date__c && caRecord.Start_Date__c >= currentDate)){
		    				populatePriceOnClientAvail(caRecord,permCapRecord,WB_PriceUtility.PERM_PRICE_RT_NAME);
		            		updatedClientAvailMap.put(caRecord.Id,caRecord);
		            		break;
		    			}
	    			}
	    		}
	    	}
			
			if(updatedClientAvailMap.size() > 0){
				List<Client_Avail__c> caList = updatedClientAvailMap.values();
	        	Database.Saveresult[] updateResults  = Database.update(caList, false);
			}
		}catch(Exception ex){
			System.debug(LoggingLevel.INFO,'Exception in updateClientAvailWithTempPrice '+ex.getMessage());	
		}
	}
	
	private static void populatePriceOnClientAvail(Client_Avail__c caRecord,Client_Avail_Price__c capRecord,String priceRecordType){
		caRecord.Price__c = capRecord.Price__c;
        caRecord.Price_Tier_Text__c = capRecord.Price_Tier__c;
        caRecord.Price_Start__c = capRecord.Effective_Date__c;
        caRecord.Price_End__c = capRecord.Expiry_Date__c;
    //  caRecord.Local_Data_Category_Picklist__c = capRecord.Category__c;
        caRecord.Price_Type__c = priceRecordType;
        
        caRecord.CAP_Name__c = capRecord.Name;
        
        if(caRecord.Title_Content_Type__c == 'Season'){
            caRecord.Episode_Price__c = capRecord.Episode_Price__c;
            caRecord.Episode_Price_Tier__c = capRecord.Episode_Price_Tier__c;
        }else{
        	caRecord.Episode_Price__c = null;
            caRecord.Episode_Price_Tier__c = null;
        }		
	}
	
	public static List<Client_Avail_Price__c> getPermanentPriceRecords(List<Client_Avail_Price__c> capList){
		List<Client_Avail_Price__c> permCAPList = new List<Client_Avail_Price__c>();
		String ppRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME);
        for(Client_Avail_Price__c capRecord:capList){
        	if(capRecord.RecordTypeId == null || capRecord.RecordTypeId == ppRecTypeId)
        		permCAPList.add(capRecord);
        }
		return permCAPList;
	}
    
    public static Map<Id,Client_Avail_Price__c> getPermanentPriceRecords(Map<Id,Client_Avail_Price__c> capMap){
		Map<Id,Client_Avail_Price__c> permCAPMap = new Map<Id,Client_Avail_Price__c>();
		String ppRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.PERM_PRICE_RT_NAME);
		
		for(Id capId:capMap.keySet()){
			if(capMap.get(capId).RecordTypeId == null || capMap.get(capId).RecordTypeId == ppRecTypeId){
				permCAPMap.put(capId,capMap.get(capId));
			}
		}
		return permCAPMap;
	}
	
	public static List<Client_Avail_Price__c> getTempPriceRecords(List<Client_Avail_Price__c> capList){
		List<Client_Avail_Price__c> tempCAPList = new List<Client_Avail_Price__c>();
		String tpRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME);
		for(Client_Avail_Price__c capRecord:capList){
        	if(capRecord.RecordTypeId == tpRecTypeId)
        		tempCAPList.add(capRecord);
        }
		return tempCAPList;
	}
    
    public static Map<Id,Client_Avail_Price__c> getTempPriceRecords(Map<Id,Client_Avail_Price__c> capMap){
		Map<Id,Client_Avail_Price__c> tempCAPMap = new Map<Id,Client_Avail_Price__c>();
		String tpRecTypeId = WB_PriceUtility.getRecordTypeId(Client_Avail_Price__c.getSobjectType(),WB_PriceUtility.TEMP_PRICE_RT_NAME);
		for(Id capId:capMap.keySet()){
			if(capMap.get(capId).RecordTypeId == tpRecTypeId){
				tempCAPMap.put(capId,capMap.get(capId));
			}
		}
		return tempCAPMap;
	}
}