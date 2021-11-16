public without sharing class WB_RateCardHelper {
    
    public static Decimal getStepPrice(Client_Avail_Price__c cap, Rate_Card__c rc){
    	
    	try{
	    	
	    	if(rc.Step_Pricing__c != null && rc.Step_Pricing__c){
	    		
	    		Date dvdRelDate = cap.CA_Local_DVD_Rel_Date__c;
	    		if(dvdRelDate == null)
	    			return rc.WSP1__c;
	    			
	    		Decimal step1Length = rc.Step1_Length_Months__c;
	    		Decimal step2Length = rc.Step2_Length_Months__c;
	    		if(cap.Effective_Date__c <= dvdRelDate.addMonths(Integer.valueOf(step1Length))){
	    			return rc.WSP1__c;
	    		}else if(cap.Effective_Date__c <= dvdRelDate.addMonths(Integer.valueOf(step2Length))){
	    			return rc.WSP2__c;
	    		}else{
	    			return rc.WSP3__c;
	    		}
	    		
	    	}else{
	    		return rc.WSP1__c;	
	    	}
    	}catch(Exception ex){
    		System.debug(LoggingLevel.INFO,'Error while returning stepPrice '+ex.getMessage());
    		return null;
    	}
    		
    }
    
    public static Decimal getStepPrice(Client_Avail_Price__c cap){
    	
    	try{
	    	
	    	if(cap.CAP_Rate_Card__c == null)
	    		return null;
	    	else if(cap.CAP_Rate_Card__r.Step_Pricing__c != null && cap.CAP_Rate_Card__r.Step_Pricing__c){
	    		
	    		Date dvdRelDate = cap.CA_Local_DVD_Rel_Date__c;
	    		if(dvdRelDate == null)
	    			return cap.CAP_Rate_Card__r.WSP1__c;
	    			
	    		Decimal step1Length = cap.CAP_Rate_Card__r.Step1_Length_Months__c;
	    		Decimal step2Length = cap.CAP_Rate_Card__r.Step2_Length_Months__c;
	    		if(cap.Effective_Date__c <= dvdRelDate.addMonths(Integer.valueOf(step1Length))){
	    			return cap.CAP_Rate_Card__r.WSP1__c;
	    		}else if(cap.Effective_Date__c <= dvdRelDate.addMonths(Integer.valueOf(step2Length))){
	    			return cap.CAP_Rate_Card__r.WSP2__c;
	    		}else{
	    			return cap.CAP_Rate_Card__r.WSP3__c;
	    		}
	    		
	    	}else{
	    		return cap.CAP_Rate_Card__r.WSP1__c;	
	    	}
	    }catch(Exception ex){
	    	System.debug(LoggingLevel.INFO,'Error while returning stepPrice '+ex.getMessage());
    		return null;
    	}
    		
    }
    
    public static void assignRateCardToCA(List<Client_Avail__c> caList){
		List<PriceKeyWrapper> wrapperList = new List<PriceKeyWrapper>();    	
    	for(Client_Avail__c ca:caList){
    		PriceKeyWrapper wrapper = new PriceKeyWrapper();
    		wrapper.accountId = ca.Client__c;
	    	wrapper.countryName = ca.Release_Plan_Country__c;
	    	wrapper.channel = ca.Release_Plan_Channel__c;
	    	wrapper.format = ca.Release_Plan_Format__c;
	    	wrapper.contentType = ca.Title_Content_Type__c;
	    	if(ca.Price_Tier_Text__c != Null && ca.Price_Tier_Text__c != '' && ca.Price_Tier_Text__c != 'TBD'){
	    		wrapper.priceTier = ca.Price_Tier_Text__c;
	    	}else if(ca.Price__c != Null){
	    		if((ca.Price__c.scale() <2)|| (ca.Price__c.scale() >2)){
                	ca.Price__c = ca.Price__c.setScale(2);
            	}
				wrapper.wsp = ca.Price__c;
	    	}
    		wrapperList.add(wrapper);
    		
    		//Episode Changes
			if(ca.Title_Content_Type__c == 'Season'){
				PriceKeyWrapper epWrapper = wrapper.clone();
				epWrapper.contentType = 'Episode';
				if(ca.Episode_Price_Tier__c != Null && ca.Episode_Price_Tier__c != '' && ca.Episode_Price_Tier__c != 'TBD'){
					epWrapper.priceTier = ca.Episode_Price_Tier__c;
					epWrapper.wsp = Null;
				}else if(ca.Episode_Price__c != Null){
					if((ca.Episode_Price__c.scale() <2)|| (ca.Episode_Price__c.scale() >2)){
                    	ca.Episode_Price__c = ca.Episode_Price__c.setScale(2);
                	}
					epWrapper.wsp = ca.Episode_Price__c;
					epWrapper.priceTier = Null;
				}
				wrapperList.add(epWrapper);
			}
    	}
    	
    	Map<String,List<Rate_Card__c>> rcMap = getRateCard(wrapperList,false,true);
    	for(Client_Avail__c ca:caList){
    		
    		String rcKey = ca.Client__c+'_'+ca.Release_Plan_Country__c+'_'+ca.Release_Plan_Channel__c+'_'+ca.Release_Plan_Format__c+'_'+ca.Title_Content_Type__c;
    		String ecEpKey;
    		
    		//Episode Changes
			if(ca.Title_Content_Type__c == 'Season'){
				ecEpKey = rcKey+'_Episode';
				if(ca.Episode_Price_Tier__c != Null && ca.Episode_Price_Tier__c != '' && ca.Episode_Price_Tier__c != 'TBD'){
					ecEpKey = ecEpKey+'_'+ca.Episode_Price_Tier__c;
				}else if(ca.Episode_Price__c != Null){
					ecEpKey = ecEpKey+'_'+ca.Episode_Price__c;
				}
				ecEpKey = ecEpKey.toUpperCase();
			}
    		
    		rcKey = rcKey +'_'+ca.Title_Content_Type__c;
    		
    		if(ca.Price_Tier_Text__c != Null && ca.Price_Tier_Text__c != '' && ca.Price_Tier_Text__c != 'TBD'){
    			rcKey = rcKey+'_'+ca.Price_Tier_Text__c;
    		}else if(ca.Price__c != Null){
    			rcKey = rcKey+'_'+ca.Price__c;
    		}
    		rcKey = rcKey.toUpperCase();
			
			//Assign to Client Avail
  			ca.CA_Rate_Card__c = null;
  			getClientAvailRC(ca,rcMap,rcKey);
  			
  			//Episode Changes
			if(ca.Title_Content_Type__c == 'Season'){
			    getClientAvailRC(ca,rcMap,ecEpKey);
			}
  			
  			
    	}								
    }
    
    public static Map<String,Rate_Card__c> assignRateCardToCAP(List<Client_Avail_Price__c> capList){
    	
    	List<PriceKeyWrapper> wrapperList = new List<PriceKeyWrapper>();    	
    	for(Client_Avail_Price__c cap:capList){
    		PriceKeyWrapper wrapper = new PriceKeyWrapper();
			
    		wrapper.accountName = cap.Account__c;
	    	wrapper.countryName = cap.Country__c;
	    	wrapper.channel = cap.Client_Avail_Channel__c;
	    	wrapper.format = cap.Client_Avail_Format__c;
	    	wrapper.contentType = cap.Title_Content_Type__c;
	    	if(cap.Price_Tier__c != Null && cap.Price_Tier__c != '' && cap.Price_Tier__c != 'TBD'){
	    		wrapper.priceTier = cap.Price_Tier__c;
	    	}else if(cap.Price__c != Null){
	    		if((cap.Price__c.scale() <2)|| (cap.Price__c.scale() >2)){
                    cap.Price__c = cap.Price__c.setScale(2);
                }
	    		wrapper.wsp = cap.Price__c;
	    	}
			
			wrapperList.add(wrapper);
			
			//Episode Changes
			if(cap.Title_Content_Type__c == 'Season'){
				PriceKeyWrapper epWrapper = wrapper.clone();
				epWrapper.contentType = 'Episode';
				if(cap.Episode_Price_Tier__c != Null && cap.Episode_Price_Tier__c != '' && cap.Episode_Price_Tier__c != 'TBD'){
					epWrapper.priceTier = cap.Episode_Price_Tier__c;
					epWrapper.wsp = Null;
				}else if(cap.Episode_Price__c != Null){
					if((cap.Episode_Price__c.scale() <2)|| (cap.Episode_Price__c.scale() >2)){
                        cap.Episode_Price__c = cap.Episode_Price__c.setScale(2);
                    }
					epWrapper.wsp = cap.Episode_Price__c;
					epWrapper.priceTier = Null;
				}
				wrapperList.add(epWrapper);
			}
    		
    	}
    	
    	Map<String,List<Rate_Card__c>> rcMap = getRateCard(wrapperList,true,true);
    	Map<String,Rate_Card__c> capIdRCMap = new Map<String,Rate_Card__c>();
    	
    	for(Client_Avail_Price__c cap:capList){
    		
    		String rcKey = cap.Account__c+'_'+cap.Country__c+'_'+cap.Client_Avail_Channel__c+'_'+cap.Client_Avail_Format__c;
  			String ecEpKey;
			
			//Episode Changes
			if(cap.Title_Content_Type__c == 'Season'){
				ecEpKey = rcKey+'_Episode';
				if(cap.Episode_Price_Tier__c != Null && cap.Episode_Price_Tier__c != '' && cap.Episode_Price_Tier__c != 'TBD'){
					ecEpKey = ecEpKey+'_'+cap.Episode_Price_Tier__c;
				}else if(cap.Episode_Price__c != Null){
					ecEpKey = ecEpKey+'_'+cap.Episode_Price__c;
				}
				ecEpKey = ecEpKey.toUpperCase();
			}
			
			rcKey = rcKey +'_'+cap.Title_Content_Type__c;
			
  			if(cap.Price_Tier__c != Null && cap.Price_Tier__c != '' && cap.Price_Tier__c != 'TBD'){
    			rcKey = rcKey+'_'+cap.Price_Tier__c;
    		}else if(cap.Price__c != Null){
    			rcKey = rcKey+'_'+cap.Price__c;
    		}
    		rcKey = rcKey.toUpperCase();
		    
		    //Assign to Client Avail Price
  			cap.CAP_Rate_Card__c = null;
  			cap.Episode_Rate_Card__c = null;
			getRC(cap,rcMap,capIdRCMap,rcKey);
			
			//Episode Changes
			if(cap.Title_Content_Type__c == 'Season'){
				getRC(cap,rcMap,capIdRCMap,ecEpKey);
			}
		}
    	
    	return capIdRCMap;
    }
    
    public static Map<String,List<Rate_Card__c>> getRateCard(List<PriceKeyWrapper> keyWrapperList,Boolean isAccountName,Boolean isCountryName){
    	Set<String> accSet = new Set<String>();
    	Set<String> countrySet = new Set<String>();
    	Set<String> channelSet = new Set<String>();
		Set<String> tierSet = new Set<String>();
		Set<Decimal> wspSet = new Set<Decimal>();
		Map<String,List<Rate_Card__c>> rcMap = new Map<String,List<Rate_Card__c>>();
		Map<String,List<Rate_Card__c>> rcFinalMap = new Map<String,List<Rate_Card__c>>();
		
		Set<String> lifeCycleSet = new Set<String>();
		lifeCycleSet.add(Label.CRM_RC_Life_Cycle_Active_Current);
		lifeCycleSet.add(Label.CRM_RC_Life_Cycle_Active_Future);
		Boolean isCRMCountry = true;
		    	
    	for(PriceKeyWrapper wrap:keyWrapperList){
    		if(isAccountName){
    			accSet.add(wrap.accountName);
    		}else{
    			accSet.add(wrap.accountId);
    		}
    		
    		if(isCountryName){
    			countrySet.add(wrap.countryName);
    		}else{
    			countrySet.add(wrap.countryId);
    		}
    		
    		channelSet.add(wrap.channel);
    		if(wrap.priceTier != Null){
				tierSet.add(wrap.priceTier);
			}else if(wrap.wsp != Null){
				wspSet.add(wrap.wsp);
			}
    	}
    	
    	String query = 'SELECT Id,Name,Start_Date__c,End_Date__c,Account__c,Account__r.Name,Country__c,Country__r.Name,Channel__c,Format__c,Content_Type__c,'+
    					' Price_Tier__c,Rate_Card_Type__c,RC_Lifecycle__c,Step1_Length_Months__c,Step2_Length_Months__c,Step_Pricing__c,Storefront__c,WSP1__c,WSP2__c,WSP3__c,SRP__c '+ 
    					' FROM Rate_Card__c WHERE ';
    	if(isAccountName){
    		query = query + ' Account__r.Name IN :accSet ';
    	}else{
    		query = query + ' Account__c IN :accSet ';
    	}
    	
    	if(isCountryName){
    		query = query + ' AND Country__r.Name IN :countrySet ';
    	}else{
    		query = query + ' AND Country__c IN :countrySet ';
    	}
    	
    	//AND RC_Lifecycle__c IN :lifeCycleSet -- removed this to allow backfill avails(with past start date)
    	query = query + ' AND Channel__c IN :channelSet AND (Price_Tier__c IN :tierSet OR WSP1__c IN :wspSet) AND Storefront__r.CRM_Storefront__c =:isCRMCountry  ORDER BY  Account__c,Country__c,Channel__c,Format__c,Content_Type__c,Price_Tier__c,Start_Date__c';
    	
    	
    	List<Rate_Card__c> rcList = Database.query(query);
    	for(Rate_Card__c rc:rcList){
    		String key = null;
    		if(isAccountName){
    			key = rc.Account__r.Name;	
    		}else{
    			key = rc.Account__c;
    		}
    		
    		if(isCountryName){
    			key = key +'_'+rc.Country__r.Name;	
    		}else{
    			key = key +'_'+rc.Country__c;
    		}
    		
    		key = key +'_'+rc.Channel__c;
    		
    		if(rc.Rate_Card_Type__c != null && rc.Rate_Card_Type__c.contains('WSP') && rc.WSP1__c != Null){
    		    key = key +'_'+rc.WSP1__c;
    		}else{
    		    key = key +'_'+rc.Price_Tier__c;
    		}
    		
    		key = key.toUpperCase();
    		if(rcMap.get(key) == null){
    			rcMap.put(key,new List<Rate_Card__c>());
    		}
    		rcMap.get(key).add(rc);
    		
    	}
    	for(PriceKeyWrapper wrap:keyWrapperList){
    		String key = null;
    		String finalKey = null;
    		if(isAccountName){
    			key = wrap.accountName;	
    		}else{
    			key = wrap.accountId;
    		}
    		if(isCountryName){
    			key = key+'_'+wrap.countryName;	
    		}else{
    			key = key+'_'+wrap.countryId;
    		}
    		
    		finalKey = key;
    		key = key+'_'+wrap.channel;
			
			if(wrap.priceTier != Null){
				key = key +'_'+wrap.priceTier;
			}else if(wrap.wsp != Null){
				key = key +'_'+wrap.wsp;
			}
    		key = key.toUpperCase();
    		List<Rate_Card__c>  availRCList = rcMap.get(key);
  			finalKey = finalKey +'_'+wrap.channel+'_'+wrap.format+'_'+wrap.contentType;
			
			if(wrap.priceTier != Null){
				finalKey = finalKey +'_'+wrap.priceTier;
			}else if(wrap.wsp != Null){
				finalKey = finalKey +'_'+wrap.wsp;
			}
			
			finalKey = finalKey.toUpperCase();
			if(!(availRCList == null || availRCList.isEmpty())){
			    
			for(Rate_Card__c rc:availRCList){
					if((rc.Format__c == wrap.format  || rc.Format__c == ALL) && (rc.Content_Type__c == wrap.contentType || rc.Content_Type__c == ALL)){
  						
  						/*
  						if(availRC == null){
  							availRC = rc;
  						}else{
  							
  							if(availRC.RC_Lifecycle__c != rc.RC_Lifecycle__c)
  								continue;
  							
  								
  							if(availRC.Format__c == ALL){
  								if(rc.Format__c != ALL){
  									availRC = rc;
  								}else{
  									if(availRC.Content_Type__c == ALL && availRC.Content_Type__c != rc.Content_Type__c){
  										availRC = rc;
  									}
  								}
  							}else{
  								if(availRC.Content_Type__c == ALL && availRC.Content_Type__c != rc.Content_Type__c){
  									availRC = rc;
  								}
  							}
  						}
  						*/
  						if(rcFinalMap.get(finalKey) == null)
	  						rcFinalMap.put(finalKey,new List<Rate_Card__c>());
	  					
	  					rcFinalMap.get(finalKey).add(rc);	
	  				
  					}
  				}
  			}	
    	}
    	return rcFinalMap; 
    }
    
    
    public static void updatePBEPs(Map<Id,Rate_Card__c> newMap,Map<Id,Rate_Card__c> oldMap){
    	
    	try{
    		
	    	List<Rate_Card__c> updateRateCards = new List<Rate_Card__c>();
	    	for(Id idVal:newMap.keySet()){
	    		if(newMap.get(idVal).WSP1__c != oldMap.get(idVal).WSP1__c || newMap.get(idVal).WSP2__c != oldMap.get(idVal).WSP2__c || newMap.get(idVal).WSP3__c != oldMap.get(idVal).WSP3__c
	    			|| newMap.get(idVal).SRP__c != oldMap.get(idVal).SRP__c){
	    			updateRateCards.add(newMap.get(idVal));
	    		}
	    	}
	    	
	    	if(updateRateCards.size() == 0)//updates are not related to PBEP.
	    		return;
	    		
	    	List<PriceBook_Entry_Period__c> pbepList = [SELECT Id,Name,Rate_Card__c,Client_Avail_Price__c FROM PriceBook_Entry_Period__c WHERE Rate_Card__c IN :updateRateCards AND Client_Avail_Price__c != null AND Client_Avail_Price__r.CAP_CRM_Country__c = true];
	    	
	    	if(pbepList == null || pbepList.size() == 0)//No associated PBEPs
	    		return;
	    		
	    	List<String> capIds = new List<String>();
	    	for(PriceBook_Entry_Period__c pbep:pbepList){
	    		capIds.add(pbep.Client_Avail_Price__c);
	    	}
	    	
	    	if(capIds.size() == 0) //No CAP reference on PBEP
	    		return;
	    		
	    	Map<Id,Client_Avail_Price__c> capMap = new Map<Id,Client_Avail_Price__c>([Select Id,Name,Price__c,CA_Local_DVD_Rel_Date__c,Effective_Date__c,Country__c,Client_Avail__r.SR_Price__c From Client_Avail_Price__c Where Id in :capIds]);
	    	for(PriceBook_Entry_Period__c pbep:pbepList){
	    		Rate_Card__c rc = newMap.get(pbep.Rate_Card__c);
	    		Client_Avail_Price__c cap = capMap.get(pbep.Client_Avail_Price__c);
	    		
	    		if(cap == null)
	    			continue;
	    			
	    		pbep.Account_Price__c = WB_RateCardHelper.getStepPrice(cap,rc);
	            pbep.List_Price__c = pbep.Account_Price__c; //need to review
	            pbep.Minimum_Price__c = pbep.Account_Price__c;//need to review
	            
	            if(cap.Country__c == CRM_AppConstants.USA_Country||cap.Country__c == CRM_AppConstants.CANADA_Country){
	            	if(rc.SRP__c != null && rc.SRP__c > 0){
	                	pbep.SR_Price__c = rc.SRP__c;
		            }
                    /*ER-003373--> 
                    else{
		                pbep.SR_Price__c = cap.Client_Avail__r.SR_Price__c ;
		            }
					*/
	            }
	    	}
	    	
	    	Database.SaveResult[] updateResult = Database.update(pbepList,false);
	    	
	    	for(Integer index = 0; index < updateResult.size();index++){
	                
	            Database.SaveResult result = updateResult[index];
	            if(!result.isSuccess()){
	                String errorMessage = '';
	                for(Database.Error err : result.getErrors()) {
	                    errorMessage += err.getMessage();
	                }
	                //system.debug(LoggingLevel.INFO,'Error Messages:'+errorMessage);
	            }
	        }
        
    	}catch(Exception ex){
    		System.debug(LoggingLevel.INFO,'Error while returning stepPrice '+ex.getMessage());
    	}	
    }
    
    public static void getRC(Client_Avail_Price__c cap,Map<String,List<Rate_Card__c>> rcMap,Map<String,Rate_Card__c> capIdRCMap,String key){
    	if(cap.CAP_CRM_Country__c && rcMap != null && rcMap.size() > 0 && rcMap.get(key) != null){
    		List<Rate_Card__c> capRCs = rcMap.get(key);
    		for(Rate_Card__c capRC:capRCs){
    			if(cap.Effective_Date__c >= capRC.Start_Date__c && cap.Effective_Date__c <= capRC.End_Date__c){
    				if(key.contains('EPISODE')){
    				    if(cap.Title_Content_Type__c == 'Episode'){
    				        cap.CAP_Rate_Card__c = capRC.Id;
    				    }else
    					    cap.Episode_Rate_Card__c = capRC.Id;
    				}else{
    				    cap.CAP_Rate_Card__c = capRC.Id;
                        capIdRCMap.put(cap.Id,capRC);
    				}
    					
                    break;
      			}
      		}
      		
      	}
    }
    
    public static void getClientAvailRC(Client_Avail__c ca,Map<String,List<Rate_Card__c>> rcMap,String key){
    	if(ca.CA_CRM_Country__c && rcMap != null && rcMap.size() > 0 && rcMap.get(key) != null){
    		List<Rate_Card__c> caRCs = rcMap.get(key);
      		for(Rate_Card__c caRC:caRCs){
    			if(ca.Start_Date__c >= caRC.Start_Date__c && ca.Start_Date__c <= caRC.End_Date__c){
    				if(key.contains('EPISODE')){
    					if(ca.Title_Content_Type__c == 'Episode'){
    				        ca.CA_Rate_Card__c = caRC.Id;
    				    }else
    					    ca.Episode_Rate_Card__c = caRC.Id;
    				}else{
    				    ca.CA_Rate_Card__c = caRC.Id;
                    }
    				break;
      			}
      		}
      	}
    }
    
    public class PriceKeyWrapper{
    	public String accountId;
    	public String countryId;
    	public String accountName;
    	public String countryName;
    	public String channel;
    	public String format;
    	public String contentType;
    	public String priceTier;
		public Decimal wsp;
		
    }
    
    public static final String ALL = 'All';
}