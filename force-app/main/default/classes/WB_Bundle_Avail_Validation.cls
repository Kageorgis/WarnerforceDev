public class WB_Bundle_Avail_Validation {
	
	public String selectedRPs{get;set;}
	public String selectedClients{get;set;}
	public String selectedDate{get;set;}
	public WB_Bundle_Avail_Validation(){
		selectedRPs = ApexPages.currentPage().getParameters().get('rpIds');
		selectedClients = ApexPages.currentPage().getParameters().get('clientIds');
		selectedDate = ApexPages.currentPage().getParameters().get('date');
	} 
	
    @RemoteAction
    public static BundleAvailOutputWrapper getRecords(BundleAvailInputWrapper inputWrapper){
    	
    	/*inputWrapper = new BundleAvailInputWrapper();
    	inputWrapper.releasePlans = new List<String>();
    	inputWrapper.accounts = new List<String>();
    	inputWrapper.startDateOverride = null;
    	
    	inputWrapper.releasePlans.add('a0H0v000001QDpa');
    	inputWrapper.accounts.add('0010v000002Lj0F');
    	*/
    	//inputWrapper.releasePlans = EncodingUtil.urlDecode(inputWrapper.releasePlans, 'UTF-8');
    	//String[] releasePlans = decodedVal.split('#');
    	String[] releasePlans = inputWrapper.releasePlans.split('#');
    	String[] accounts = inputWrapper.accounts.split('#');
    	
    	System.debug('releasePlans -> '+releasePlans);
    	System.debug('accounts -> '+accounts);
    	
    	List<BundleComponentWrapper> componentWrapList = new List<BundleComponentWrapper>();
        Set<Id> playListIdSet = new set<Id>();
        Set<Id> countryIdSet = new Set<Id>();
        Set<String> channelSet = new Set<String>();
        Set<String> formatSet = new Set<String>();
        Map<String,List<Commercial_Avail__c>> playListToSelectedRP = new Map<String,List<Commercial_Avail__c>>();
        Map<String,String> titleVVMap = new Map<String,String>();
        
        Map<Id,Account> clientMap = new Map<Id,Account>([Select Id,Name From Account Where ID IN :accounts AND RecordType.Name = 'Digital Client']);
        
        Map<Id,Commercial_Avail__c> selectedRPMap = new Map<Id,Commercial_Avail__c>([Select Id,Name,Playlist__c,Title_Content_Type__c,Start_Date__c,End_Date__c,
        												Country_Formula__c,Country_Lookup__c,Format__c,Channel__c,Title_Formula__c,Language_Formula__c,Language_Type__c,
        												Title_Video_Version__c,Playlist__r.Parent_Title__r.Name  
        												From Commercial_Avail__c Where Id in :releasePlans]);
        
        for(String rpRecordId : selectedRPMap.keySet()) {
        	Commercial_Avail__c rpRecord = selectedRPMap.get(rpRecordId);
            if(rpRecord.Title_Content_Type__c == Label.Collection_Features && rpRecord.Playlist__c != null) {
                playListIdSet.add(rpRecord.Playlist__c);
                countryIdSet.add(rpRecord.Country_Lookup__c);
                channelSet.add(rpRecord.Channel__c);
                formatSet.add(rpRecord.Format__c);
                
                if(!playListToSelectedRP.containsKey(rpRecord.Playlist__r.Parent_Title__r.Name)){
                	playListToSelectedRP.put(rpRecord.Playlist__r.Parent_Title__r.Name,new List<Commercial_Avail__c>());
                }
                
                playListToSelectedRP.get(rpRecord.Playlist__r.Parent_Title__r.Name).add(rpRecord);
                	
                if(inputWrapper.startDateOverride != null && inputWrapper.startDateOverride.length() > 0){
                	try{
                		rpRecord.Start_Date__c = Date.parse(inputWrapper.startDateOverride);
                	}catch(Exception ex){
                		
                	}
                }	
            }
        }
        
        System.debug(LoggingLevel.INFO,'**********playListIdSet : '+playListIdSet);
        if(playListIdSet.size() > 0) {
            
            // Map used to store the collection related to feature titles
            Map<String,Set<String>> contentCollectionTitleSet = new Map<String,Set<String>>();
            Set<String> setVideoVersion= new set<String>();
            // Map used to store the feature avails respective with collection titles 
            Map<String, Map<String, Map<String, Map<String,List<Client_Avail__c>>>>> mapClientAvails = new Map<String, Map<String, Map<String, Map<String,List<Client_Avail__c>>>>>();
                
            for(Playlist_Content__c content : [SELECT id,Content_Title__r.Name,Content_Title__r.Video_Version__c,Playlist__r.Parent_Title__r.Name FROM Playlist_Content__c 
                                                	WHERE Playlist__c in: playListIdSet])
            	{   
                	if(!contentCollectionTitleSet.containsKey(content.Content_Title__r.Name))
                    	contentCollectionTitleSet.put(content.Content_Title__r.Name,new Set<String>());
                	
                	contentCollectionTitleSet.get(content.Content_Title__r.Name).add(content.Playlist__r.Parent_Title__r.Name);
                	setVideoVersion.add(content.Content_Title__r.Video_Version__c);
                	
                	titleVVMap.put(content.Content_Title__r.Name,content.Content_Title__r.Video_Version__c);
                	
	                if(!mapClientAvails.containsKey(content.Playlist__r.Parent_Title__r.Name )) {
	                    mapClientAvails.put(content.Playlist__r.Parent_Title__r.Name , new Map<String, Map<String, Map<String,List<Client_Avail__c>>>>());
	                }
                
	                if(!mapClientAvails.get(content.Playlist__r.Parent_Title__r.Name).containsKey(content.Content_Title__r.Name)) {
	                    mapClientAvails.get(content.Playlist__r.Parent_Title__r.Name).put(content.Content_Title__r.Name, new Map<String, Map<String,List<Client_Avail__c>>>());
	                }
            	}
            	
            Map<String,List<Commercial_Avail__c>> existingRPMap = new Map<String,List<Commercial_Avail__c>>();  
            List<String> caLifeCycles = new List<String>{'Active Future','Active Current'};
             
            for(Commercial_Avail__c existingRP:[SELECT Id,Name,Country_Formula__c,Format__c,Channel__c,Title_Formula__c,Language_Formula__c,Language_Type__c,Start_Date__c , End_Date__c,Status__c,
            																		(Select Id,Name,Commercial_Avail__c,Client__c,Release_Plan_Title__c,Title_Video_Version__c,Release_Plan_Country__c,Release_Plan_Language__c,RP_Language_Type__c,Release_Plan_Channel__c,Release_Plan_Format__c,
            																			AccountF__c,Start_Date__c,End_Date__c,Status__c,Local_Data_Category_Picklist__c,Price_Code__c,Price_Tier_Text__c,Price__c,SR_Price__c,Episode_Price_Tier__c,Episode_Price__c,SR_Per_Episode__c,APO_Date__c,
            																			Announce_Date__c,Comments__c,Client_Title_ID__c,Local_Data_Rating__c,Local_Data_Num_of_Episodes__c,Local_Edit_Version__c,Change_Context__c,Announce_Override__c,Vendor_ID__c 
                                                                                     FROM Client_Avails__r Where Client__c in :accounts AND CA_Lifecycle__c IN: caLifeCycles ORDER BY Start_Date__c ASC
                                                                                    )
                                                                                   From Commercial_Avail__c Where Title__r.Name IN :contentCollectionTitleSet.keyset()
                                                                                   AND Title__r.Video_Version__c IN:setVideoVersion
                                                                                   AND Country_Lookup__c IN :countryIdSet
                                                                                   AND Channel__c IN :channelSet
                                                                                   AND Format__c IN :formatSet ORDER BY Start_Date__c]){
            	//Title Name	Video Version	Country	Language	Language Type	Channel	Format	Account Name	Client Start	Client End	Status	Title Category	New Price Code	Price Tier	WS Cost	SR Price	Episode Price Tier	Episode Price	Episode SR Price	Pre-Order Date	Suppression End Date	Avail Notes	Retailer Product ID	Local Data Rating	Local Data # of Episodes	Local Edit Required	Change Context	Announce Override	Vendor ID
            	//Release_Plan_Title__c,Title_Video_Version__c,Release_Plan_Country__c,Release_Plan_Language__c,RP_Language_Type__c,Release_Plan_Channel__c,Release_Plan_Format__c,AccountF__c,Start_Date__c,End_Date__c,Status__c,Local_Data_Category_Picklist__c,Price_Code__c,Price_Tier_Text__c,Price__c,SR_Price__c,Episode_Price_Tier__c,Episode_Price__c,SR_Per_Episode__c,APO_Date__c,Announce_Date__c,Comments__c,Client_Title_ID__c,Local_Data_Rating__c,Local_Data_Num_of_Episodes__c,Local_Edit_Version__c,Change_Context__c,Announce_Override__c,Vendor_ID__c
            	// Created map which contains Collection Title => List<Title> => (Combination of Client, Country, Format, Channel) => List<Client Avail>
                String strRPKey = existingRP.Country_Formula__c + existingRP.Format__c + existingRP.Channel__c + existingRP.Language_Formula__c ;
                
                if(!existingRPMap.containsKey(existingRP.Title_Formula__c+strRPKey)){
                	existingRPMap.put(existingRP.Title_Formula__c+strRPKey,new List<Commercial_Avail__c>());	
                }
                existingRPMap.get(existingRP.Title_Formula__c+strRPKey).add(existingRP);
                
                List<Client_Avail__c> existingCAList = existingRP.Client_Avails__r;
                for(String collectionTitle : contentCollectionTitleSet.get(existingRP.Title_Formula__c)){
                
                    if(!mapClientAvails.get(collectionTitle).get(existingRP.Title_Formula__c).containsKey(strRPKey)) {
                        mapClientAvails.get(collectionTitle).get(existingRP.Title_Formula__c).put(strRPKey, new Map<String,List<Client_Avail__c>>()); 
                    }
                    
                    for(Client_Avail__c existingCA:existingCAList){
	                    if(!mapClientAvails.get(collectionTitle).get(existingRP.Title_Formula__c).get(strRPKey).containsKey(existingCA.Client__c)) {
	                        mapClientAvails.get(collectionTitle).get(existingRP.Title_Formula__c).get(strRPKey).put(existingCA.Client__c, new List<Client_Avail__c>()); 
	                    }
                    
                    	mapClientAvails.get(collectionTitle).get(existingRP.Title_Formula__c).get(strRPKey).get(existingCA.Client__c).add(existingCA);
                	}
            	}
            }
            
            System.debug(LoggingLevel.INFO,'**********mapClientAvails : After '+mapClientAvails);
            
            // Created set of error message strings depending of errors to be displayed
            
            if(mapClientAvails.size() > 0) {
            	Set<String> playListTitleSet = mapClientAvails.keySet();
            	for(String playListTitle:playListTitleSet){
            		List<Commercial_Avail__c> rpRecordList = playListToSelectedRP.get(playListTitle);
            		Map<String,Map<String,Map<String,List<Client_Avail__c>>>> playListContents = mapClientAvails.get(playListTitle);
            		Set<String> playListContentTitleSet = playListContents.keySet();
            		for(Commercial_Avail__c rpRecord:rpRecordList){
            			String strRPKey = rpRecord.Country_Formula__c + rpRecord.Format__c + rpRecord.Channel__c + rpRecord.Language_Formula__c ; //Add language and Languagetype ???
            			for(String playListContentTitle:playListContentTitleSet){
            				Boolean isRPMissing = true;
               					
            				Map<String,Map<String,List<Client_Avail__c>>> playListRPMap = playListContents.get(playListContentTitle);
            				
            				if(playListRPMap != null && playListRPMap.size() > 0){
            					isRPMissing = false;
            					
            					Map<String,List<Client_Avail__c>> playListClientMap = playListRPMap.get(strRPKey);
            					if(playListClientMap == null || playListClientMap.size() == 0){
            						Boolean isRPDataValid = true;
            						/** Release Plan Validation start */
	            					List<Commercial_Avail__c> existingRPList = existingRPMap.get(playListContentTitle+strRPKey);
	            					Boolean isGap = false;
	            				    if(existingRPList != Null && existingRPList.size()>0){
    									for(Integer i=0; i < existingRPList.size() - 1; i++){
    									        if(existingRPList[i].End_Date__c.daysBetween(existingRPList[i+1].Start_Date__c) > 1 && existingRPList[i].End_Date__c >= rpRecord.Start_Date__c && existingRPList[i+1].Start_Date__c <= rpRecord.End_Date__c){
                                            	isGap = true;
                                            	BundleComponentWrapper wrapperObject = new BundleComponentWrapper(titleVVMap.get(playListContentTitle),playListContentTitle,existingRPList[i]);
                                            	wrapperObject.addMessage('There is Gap between two Component Title Release Plans.'+existingRPList[i].Name + ' '+existingRPList[i].Start_Date__c +' '+existingRPList[i].End_Date__c);
                                            	componentWrapList.add(wrapperObject);
                                            	
                                            	wrapperObject = new BundleComponentWrapper(titleVVMap.get(playListContentTitle),playListContentTitle,existingRPList[i+1]);
                                            	wrapperObject.addMessage('There is Gap between two Component Title Release Plans.'+existingRPList[i+1].Name + ' '+existingRPList[i+1].Start_Date__c +' '+existingRPList[i+1].End_Date__c);
                                            	componentWrapList.add(wrapperObject);
                                            	isRPDataValid = false;
                                            	break;
                                        	}
    									}
	            					}
									
                                	if(!isGap) {
                                	    if(existingRPList != Null && existingRPList.size()>0){
                                    		if(existingRPList.size() == 1){
                                    		    BundleComponentWrapper wrapperObject = new BundleComponentWrapper(titleVVMap.get(playListContentTitle),playListContentTitle,existingRPList[0]);
                                    			validateReleasePlan(rpRecord,existingRPList[0],wrapperObject);
                                    			if(wrapperObject.errorMessage != null && wrapperObject.errorMessage != ''){
    												componentWrapList.add(wrapperObject);
    												isRPDataValid = false;
                                    			}
    		                                    		
                                    		}else{
                                    		    Commercial_Avail__c componentReleaseRec = null;
                                    			if(rpRecord.End_Date__c < existingRPList[0].Start_Date__c)
                                    				componentReleaseRec = existingRPList[0];
                                    			else if(rpRecord.Start_Date__c > existingRPList[existingRPList.size() - 1].End_Date__c)
                                    				componentReleaseRec = existingRPList[existingRPList.size() - 1];
                                    				
                                    			if(componentReleaseRec != null){
                                    				BundleComponentWrapper wrapperObject = new BundleComponentWrapper(titleVVMap.get(playListContentTitle),playListContentTitle,componentReleaseRec);
                                    				validateReleasePlan(rpRecord,componentReleaseRec,wrapperObject);
                                    				if(wrapperObject.errorMessage != null && wrapperObject.errorMessage != ''){
    													componentWrapList.add(wrapperObject);
    													isRPDataValid = false;
                                    				}
                                    			}else{
    		                                		for(Integer i=0; i < existingRPList.size(); i++) {
    		                                			componentReleaseRec = existingRPList[i];
    		                                			if(componentReleaseRec.End_Date__c < rpRecord.Start_Date__c || componentReleaseRec.Start_Date__c > rpRecord.End_Date__c)
    		                                				continue;
    		                                				
    		                                			BundleComponentWrapper wrapperObject = new BundleComponentWrapper(titleVVMap.get(playListContentTitle),playListContentTitle,componentReleaseRec);
    	                                				if(!(componentReleaseRec.Status__c == 'Confirmed' || componentReleaseRec.Status__c == 'Tentative')){
    														wrapperObject.addMessage('Component Title Status of Release Plan must be tentative or confirmed.');
    														componentWrapList.add(wrapperObject);
    														isRPDataValid = false;
    	                                				}
    		                                		}
                                    			}
                                    		}
                                    	}
                                	}
                                	
                                	if(!isRPDataValid) continue;
								}
							   	
							   	
							   	
            					for(String clientId:accounts){
            						Boolean isCAMissing = true;	
            						
            						if(playListClientMap != Null && playListClientMap.size()>0){
                						List<Client_Avail__c> componentAvails = playListClientMap.get(clientId);
                						
                						/** Client Avail Validation start */
                						if(componentAvails != null && componentAvails.size() > 0) {
                							isCAMissing = false;
                							Boolean isGap = false;
    	                                	
                							for(Integer i=0; i < componentAvails.size() - 1; i++) {
                							    if(componentAvails[i].End_Date__c.daysBetween(componentAvails[i+1].Start_Date__c) > 1 && componentAvails[i].End_Date__c >= rpRecord.Start_Date__c && componentAvails[i+1].Start_Date__c <= rpRecord.End_Date__c){
    	                                        	isGap = true;
    	                                        	BundleComponentWrapper wrapperObject = new BundleComponentWrapper(titleVVMap.get(playListContentTitle),playListContentTitle,rpRecord,componentAvails[i]);
    	                                        	wrapperObject.setClient(clientMap.get(clientId).Name);
    	                                        	wrapperObject.addMessage('There is Gap between two Component Title Client Avails.'+componentAvails[i].Name + ' '+componentAvails[i].Start_Date__c +' '+componentAvails[i].End_Date__c);
    	                                        	componentWrapList.add(wrapperObject);
    	                                        	
    	                                        	wrapperObject = new BundleComponentWrapper(titleVVMap.get(playListContentTitle),playListContentTitle,rpRecord,componentAvails[i+1]);
    	                                        	wrapperObject.setClient(clientMap.get(clientId).Name);
    	                                        	wrapperObject.addMessage('There is Gap between two Component Title Client Avails.'+componentAvails[i+1].Name + ' '+componentAvails[i+1].Start_Date__c +' '+componentAvails[i+1].End_Date__c);
    	                                        	componentWrapList.add(wrapperObject);
    	                                        	break;
    	                                    	}
    	                                	} 
    	                                	
    	                                	
    	                                	// If no gap is exists between client avail dates, check if the Start & End dates are aligning
    	                                	if(!isGap) {
    	                                		if(componentAvails.size() == 1){
    	                                			BundleComponentWrapper wrapperObject = new BundleComponentWrapper(titleVVMap.get(playListContentTitle),playListContentTitle,rpRecord,componentAvails[0]);
    	                                			wrapperObject.setClient(clientMap.get(clientId).Name);
    	                                			validateClientAvail(rpRecord,componentAvails[0],wrapperObject);
    	                                			if(wrapperObject.errorMessage != null && wrapperObject.errorMessage != '')
        												componentWrapList.add(wrapperObject);
    		                                    		
    	                                		}else{
    	                                			
    	                                			Client_Avail__c componentAvailRec = null;
    	                                			if(rpRecord.End_Date__c < componentAvails[0].Start_Date__c)
    	                                				componentAvailRec = componentAvails[0];
    	                                			else if(rpRecord.Start_Date__c > componentAvails[componentAvails.size() - 1].End_Date__c)
    	                                				componentAvailRec = componentAvails[componentAvails.size() - 1];
    	                                				
    	                                			if(componentAvailRec != null){
    	                                				BundleComponentWrapper wrapperObject = new BundleComponentWrapper(titleVVMap.get(playListContentTitle),playListContentTitle,rpRecord,componentAvailRec);
    	                                				wrapperObject.setClient(clientMap.get(clientId).Name);
    	                                				validateClientAvail(rpRecord,componentAvailRec,wrapperObject);
    	                                				if(wrapperObject.errorMessage != null && wrapperObject.errorMessage != '')
        													componentWrapList.add(wrapperObject);
    	                                			}else{
    			                                		for(Integer i=0; i < componentAvails.size(); i++) {
    			                                			componentAvailRec = componentAvails[i];
    			                                			if(componentAvailRec.End_Date__c < rpRecord.Start_Date__c || componentAvailRec.Start_Date__c > rpRecord.End_Date__c)
    			                                				continue;
    			                                				
    			                                			BundleComponentWrapper wrapperObject = new BundleComponentWrapper(titleVVMap.get(playListContentTitle),playListContentTitle,rpRecord,componentAvailRec);
    		                                				wrapperObject.setClient(clientMap.get(clientId).Name);
    		                                				if(!(componentAvailRec.Status__c == 'Confirmed' || componentAvailRec.Status__c == 'Tentative')){
    															wrapperObject.addMessage('Component Title Status of Client Avail must be tentative or confirmed.');
    															componentWrapList.add(wrapperObject);
    		                                				}
    			                                		}
    	                                			}
    	                                		}
    	                                	}
                						}
            						}
            						
            						if(isCAMissing){
            							//validate RPs
            							BundleComponentWrapper wrapperObject = new BundleComponentWrapper(titleVVMap.get(playListContentTitle),playListContentTitle,rpRecord);
	                                	wrapperObject.setClient(clientMap.get(clientId).Name);
            							wrapperObject.addMessage('Client Avail is missing from Component Title.');
            							componentWrapList.add(wrapperObject);
            						}
            						
            						/** Client Avail Validation end */
            					}
            				}
            				
            				if(isRPMissing){
            					BundleComponentWrapper wrapperObject = new BundleComponentWrapper(titleVVMap.get(playListContentTitle),playListContentTitle,rpRecord);
            					wrapperObject.addMessage('Release Plan is missing from Component Title.');
            					componentWrapList.add(wrapperObject);
            				}
            			}
            		}
            	}
            }
        }
        
        BundleAvailOutputWrapper outputWrapper = new BundleAvailOutputWrapper();
        for(BundleComponentWrapper componentWrapper:componentWrapList){
        	if(componentWrapper.account == null)
        		outputWrapper.addRPError(componentWrapper);
        	else
        		outputWrapper.addAvailError(componentWrapper);
        }
        
        outputWrapper.sortErrors();
            	
    	return outputWrapper;
    }
    
    public static void validateReleasePlan(Commercial_Avail__c rpRecord,Commercial_Avail__c existingRPRecord,BundleComponentWrapper wrapperObject){
    	
    	if(rpRecord.Start_Date__c < existingRPrecord.Start_Date__c && rpRecord.End_Date__c > existingRPrecord.End_Date__c) {
        	wrapperObject.addMessage('Component Title Release Plan start date and end date not within bundle effective date.');
        } else if(rpRecord.Start_Date__c < existingRPrecord.Start_Date__c) {
        	wrapperObject.addMessage('Component Title Release Plan start date is within the bundle effective date.');
    	} else if(rpRecord.End_Date__c > existingRPrecord.End_Date__c) {
        	wrapperObject.addMessage('Component Title Release Plan end date Is within bundle effective date.');
    	}
    	
    	if(!(existingRPrecord.Status__c == 'Confirmed' || existingRPrecord.Status__c == 'Tentative'))
    		wrapperObject.addMessage('Component Title Status of Release Plan must be tentative or confirmed.');
    		
    	
    }
    
    public static void validateClientAvail(Commercial_Avail__c rpRecord,Client_Avail__c caRecord,BundleComponentWrapper wrapperObject){
    	
    	if(rpRecord.Start_Date__c < caRecord.Start_Date__c && rpRecord.End_Date__c > caRecord.End_Date__c) {
        	wrapperObject.addMessage('Component Title Client Avail start date and end date not within bundle effective date.');
        } else if(rpRecord.Start_Date__c < caRecord.Start_Date__c) {
        	wrapperObject.addMessage('Component Title Client Avail start date not within bundle effective date.');
    	} else if(rpRecord.End_Date__c > caRecord.End_Date__c) {
        	wrapperObject.addMessage('Component Title Client Avail end date not within bundle effective date.');
    	}
    	
    	if(!(caRecord.Status__c == 'Confirmed' || caRecord.Status__c == 'Tentative'))
    		wrapperObject.addMessage('Component Title Status of Client Avail must be tentative or confirmed.');	
    	
    }
    
    public class BundleAvailInputWrapper{
    	@TestVisible String releasePlans;
    	@TestVisible String accounts;
    	@TestVisible String startDateOverride;
    }
    
    public class BundleAvailOutputWrapper{
    	List<BundleComponentWrapper> caErrors = new List<BundleComponentWrapper>();
    	List<BundleComponentWrapper> rpErrors = new List<BundleComponentWrapper>();
    	
    	public void addRPError(BundleComponentWrapper componentWrapper){
    		rpErrors.add(componentWrapper);	
    	}
    	
    	public void addAvailError(BundleComponentWrapper componentWrapper){
    		caErrors.add(componentWrapper);
    	}
    	
    	public void sortErrors(){
    		caErrors.sort();
    		rpErrors.sort();
    	}
    }
    
    public class BundleComponentWrapper implements Comparable{
    	
        public String title;
        public String videoVersion;
        public String country;
        public String language;
        public String languageType;
        public String channel;
        public String format;
        public String account;
        public String startDate;
        public String endDate;
        public String status;
        public String titleCategory;
        public String newPriceCode;
        public String priceTier;
        public String wsCost;
        /*ER-003373-->  public String srPrice;*/
        public String episodePriceTier;
        public String episodePrice;
        public String episodeSRPrice;
        public String preOrderDate;
        public String suppressionEndDate;
        public String availNotes;
        public String retailerProductId;
        public String localDataRating;
        public String localDataNoOfEpisodes;
        public String localEditRequired;
        public String changeContext;
        public String announceOverride;
        public String vendorID;
        public String errorMessage;
        
        public BundleComponentWrapper(){
        	this.errorMessage = '';
        }
        
        public BundleComponentWrapper(String videoVersion,String title,String country,String channel,String format,String language,String languageType){
        	this.videoVersion = videoVersion;
	        this.title = title;
	        this.country = country;
	        this.channel = channel;
	        this.format = format;
	        this.language = language;
	        this.languageType = languageType;
	        this.errorMessage = '';
        }
        
        public BundleComponentWrapper(String videoVersion,String contentTitle,Commercial_Avail__c rpRecord){
        	this(videoVersion,contentTitle,rpRecord.Country_Formula__c,rpRecord.Channel__c,rpRecord.Format__c,rpRecord.Language_Formula__c,rpRecord.Language_Type__c);
        }
        
        public BundleComponentWrapper(String videoVersion,String contentTitle,Commercial_Avail__c rpRecord,Client_Avail__c clientAvail){
        	this.title = clientAvail.Release_Plan_Title__c;
	        this.videoVersion = clientAvail.Title_Video_Version__c;
	        this.country = clientAvail.Release_Plan_Country__c;
	        this.language = clientAvail.Release_Plan_Language__c;
	        this.languageType = clientAvail.RP_Language_Type__c;
	        this.channel = clientAvail.Release_Plan_Channel__c;
	        this.format = clientAvail.Release_Plan_Format__c;
	    //  this.account = clientAvail.AccountF__c;
	        this.startDate = clientAvail.Start_Date__c!= null?clientAvail.Start_Date__c.format():null;
	        this.endDate = clientAvail.End_Date__c!=null?clientAvail.End_Date__c.format():null;
	        this.status = clientAvail.Status__c;
	        this.titleCategory = clientAvail.Local_Data_Category_Picklist__c;
	        this.newPriceCode = clientAvail.Price_Code__c;
	        this.priceTier = clientAvail.Price_Tier_Text__c;
	        this.wsCost = String.valueOf(clientAvail.Price__c);
	    /*ER-003373-->    this.srPrice = String.valueOf(clientAvail.SR_Price__c); */
	        this.episodePriceTier = clientAvail.Episode_Price_Tier__c;
	        this.episodePrice = String.valueOf(clientAvail.Episode_Price__c);
	     /*ER-003373  Episode SR Price Field on CA-->   this.episodeSRPrice = String.valueOf(clientAvail.SR_Per_Episode__c); */
	        this.preOrderDate = clientAvail.APO_Date__c!=null?clientAvail.APO_Date__c.format():null;
	        this.suppressionEndDate = clientAvail.Announce_Date__c!=null?clientAvail.Announce_Date__c.format():null;
	        this.availNotes = clientAvail.Comments__c;
	        this.retailerProductId = clientAvail.Client_Title_ID__c;
	        this.localDataRating = clientAvail.Local_Data_Rating__c;
	        this.localDataNoOfEpisodes = String.valueOf(clientAvail.Local_Data_Num_of_Episodes__c);
	        this.localEditRequired = clientAvail.Local_Edit_Version__c;
	        this.changeContext = clientAvail.Change_Context__c;
	        this.announceOverride = clientAvail.Announce_Override__c;
	        this.vendorID = clientAvail.Vendor_ID__c;
        }
        
        public void setClient(String account){
        	this.account = account;
        }
        
        public void addMessage(String message){
            
            if(this.errorMessage == null && (message != null && message != '')){
                this.errorMessage = message;
            }else{
        	    this.errorMessage = this.errorMessage +'\n'+ message;
        	}
        		
        }
        
         public Integer compareTo(Object obj) {
            BundleComponentWrapper bundleCompWrap = (BundleComponentWrapper)(obj);
            
            try{
	            Integer compareResult = title.compareTo(bundleCompWrap.title);
	            if(compareResult == 0){
	            	compareResult = country.compareTo(bundleCompWrap.country);
	                if(compareResult == 0){
	            		compareResult = channel.compareTo(bundleCompWrap.channel);
	            		if(compareResult == 0){
	            			compareResult = format.compareTo(bundleCompWrap.format);
	            			if(compareResult == 0){
	            				compareResult = language.compareTo(bundleCompWrap.language);
	            				if(compareResult == 0){
				            		compareResult = languageType.compareTo(bundleCompWrap.languageType);
				            		if(compareResult == 0 && account != null && bundleCompWrap.account != null){
				            			compareResult = account.compareTo(bundleCompWrap.account);
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
}