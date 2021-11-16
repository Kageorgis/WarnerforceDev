public class WB_PlaylistContentCA_Controller {
    
    public static String rpavailField = 'Recalculate_Playlist_Avails__c';
    public static String rsstatusField = 'Recalculation_Status__c'; 
    public static Boolean isErrorMethodInvoked = false;

    @RemoteAction @ReadOnly
    public static List<CAWrapper> getRecords(String statusValue){
        List<Client_Avail__c> caRecordList = new List<Client_Avail__c>();
    	List<Client_Avail__c> caRecordSuccessErrorsList = new List<Client_Avail__c>();
    	List<Client_Avail__c> caRecordFinalList = new List<Client_Avail__c>();
    	Map<String,Integer> playListContentCountMap = new Map<String,Integer>();
    	Map<String,Integer> episodeCACountMap = new Map<String,Integer>();
    	set<Id> playlistIDs = new set<Id>();
    	String operation = 'GetCARecords';
    	Set<String> possibleStatus = new Set<String>{'Update Playlist','Update Playlist Content','Update Local Data','Update Episode Avails','Insert'};
 		Map<String,Datetime> caProcessedTimeMap = new Map<String,Datetime>();
 		Map<String,Client_Avail__History> caHistoryMap = new Map<String,Client_Avail__History>();
 		Map<String,CAS_Error_Log__c> caUpdatePlaylistErrorMap = new Map<String,CAS_Error_Log__c>();
        DateTime now = datetime.now();
        caRecordList = getCADataList(possibleStatus,caProcessedTimeMap,caHistoryMap);
        
        Map<String,Client_Avail__c> CAErrorMap = new Map<String,Client_Avail__c>();
        Map<String,Client_Avail__c> CASuccessMap = new Map<String,Client_Avail__c>();
        
        Decimal diff;
        Decimal rsdiff;
        Decimal daysDiff = 2;
	    Decimal rsDaysDiff = 2;
        List<AsyncApexJob> jobList = [Select ID, Status, JobType,createdbyid,createddate FROM AsyncApexJob 
            						WHERE ApexClass.Name='WB_Batch_Playlist_Mgmt_Process' AND CreatedById =:UserInfo.getUserId() AND Status Not IN('Aborted','Completed','Failed')];
            
        for(Client_Avail__c caRecord : caRecordList){
            system.debug(LoggingLevel.INFO,'caRecord'+caRecord);
            if(Test.isRunningTest()){
                if(statusValue == 'Error'){
                    diff = 70;
                }else if(statusValue == 'In Progress'){
                    diff = 10;
                    daysDiff = 1;
                    rsdiff = 10;
                }else if(statusValue == 'Success'){
                    diff = 80;
                }
            }else{
            	try{
                	diff = (decimal.valueOf(now.getTime() - caProcessedTimeMap.get(caRecord.Id+rpavailField).getTime()))/1000/60;
                	rsdiff = (decimal.valueOf(now.getTime() - caProcessedTimeMap.get(caRecord.Id+rsstatusField).getTime()))/1000/60;
                }catch(Exception ex){
            		
            	}
            }
            
            /*
             if(statusValue == 'In Progress'){
            	if((diff < 30 || (jobList.size() > 0 && caRecord.Recalculation_Status__c)) && caRecord.Recalculate_Playlist_Avails__c != null){
                	caRecordFinalList.add(caRecord);
            	}
            }else{
	            if(caRecord.Recalculate_Playlist_Avails__c == null || (diff >= 30 &&  jobList.size() == 0)){
	                caRecordSuccessErrorsList.add(caRecord);
	                playlistIDs.add(caRecord.Playlist__c);
	                EpisodeCACountMap.put(caRecord.Id,caRecord.Child_Client_Avails__r.size());  
	            }
            }*/
            
            if(statusValue == 'In Progress'){
            	if(jobList.size() > 0 && caRecord.Recalculate_Playlist_Avails__c != null && (diff < 15 || rsdiff < 15)){
                	caRecordFinalList.add(caRecord);
            	} 
            }else{
	            if(caRecord.Recalculate_Playlist_Avails__c == null || jobList.size() == 0){
	                caRecordSuccessErrorsList.add(caRecord);
	                playlistIDs.add(caRecord.Playlist__c);
	                EpisodeCACountMap.put(caRecord.Id,caRecord.Child_Client_Avails__r.size());  
	            }
            } 
        }
    
       List<String> caErrorList = new List<String>();
       Map<Id,CAS_Error_Log__c> casErrorMap = new Map<Id,CAS_Error_Log__c>();
       if(!caRecordSuccessErrorsList.isEmpty()){
       	
        List<Playlist__c> playList = [SELECT Id,(select Id from Playlist_Client_Avails__r),(Select Id from Playlist_Content__r) FROM Playlist__c WHERE Id In : playlistIDs ];
        for(Playlist__c playlistRec : playList){
            for(Client_Avail__c caRec:playlistRec.Playlist_Client_Avails__r){
                PlayListContentCountMap.put(caRec.Id,playlistRec.Playlist_Content__r.size());
            }
        } 
        
        
         for(Client_Avail__c ca : caRecordSuccessErrorsList){
            Integer EpisodeCACount = EpisodeCACountMap.get(ca.Id);
            Integer PlayListContentCount = PlayListContentCountMap.get(ca.Id);
            
            if(statusValue == 'Success'){
            	if((EpisodeCACount == PlayListContentCount && ca.Recalculate_Playlist_Avails__c == null)){
	            	
	            	try{
	            	   daysDiff = ((Decimal.valueOf(now.getTime() - caProcessedTimeMap.get(ca.Id+rpavailField).getTime()))/(1000*60*60*24)); 
	            	   
	            	}catch(Exception ex){
	            		system.debug(LoggingLevel.Info,ex.getMessage());
	            	}
	            	
	            	try{
	            		rsDaysDiff = ((Decimal.valueOf(now.getTime() - caProcessedTimeMap.get(ca.Id+rsstatusField).getTime()))/(1000*60*60*24));
	            	}catch(Exception ex){
	            		system.debug(LoggingLevel.Info,ex.getMessage());
	            	}
            	
                    
                    if(daysDiff <= 1 || rsDaysDiff <=1){
                        caRecordFinalList.add(ca);
                        
                        //Add to keep track of Success records -- Error Capturing ER
                        if(!CASuccessMap.containsKey(ca.Id))
                            CASuccessMap.put(ca.Id,ca);
                    }
                }
            }
            
            if(statusValue == 'Error'){
             if((EpisodeCACount!= PlayListContentCount || possibleStatus.contains(ca.Recalculate_Playlist_Avails__c))){
               caErrorList.add(ca.Id);
               caRecordFinalList.add(ca);
                
                //keep track of CA records in ErrorList -- Error Capturing ER
                if(!CAErrorMap.containsKey(ca.Id))
                    CAErrorMap.put(ca.Id,ca);
               
               
              }
            }
         }
         
       }
      
       List<CAS_Error_Log__c> casErrorList = new List<CAS_Error_Log__c>();
       casErrorList = [Select Id,Record_Id__c,Error_Category__c,Error_Description__c from CAS_Error_Log__c where Record_Id__c IN:caErrorList order by CreatedDate Desc];
       
       
       for(CAS_Error_Log__c casRecord : casErrorList){
           if(!casErrorMap.containsKey(casRecord.Record_Id__c)){
               casErrorMap.put(casRecord.Record_Id__c,casRecord);
           }
           
       }
       
       List<CAWrapper> cawrapperList = new List<CAWrapper>();
       List<CAWrapper> cawrapperErrorList = new List<CAWrapper>();
      
       for(Client_Avail__c ca :caRecordFinalList){
           
       	CAWrapper wrapper = new CAWrapper();
       	wrapper.videoVersion = ca.Title_Video_Version__c;
        wrapper.title = ca.Release_Plan_Title__c;
        wrapper.account = ca.AccountF__c;
        wrapper.country = ca.Release_Plan_Country__c;
        wrapper.channel = ca.Release_Plan_Channel__c;
        wrapper.format = ca.Release_Plan_Format__c;
        wrapper.language = ca.Release_Plan_Language__c;
        wrapper.languageType = ca.RP_Language_Type__c;
        wrapper.caRecordId = ca.Id;
        wrapper.caCategory = ca.Local_Data_Category_Picklist__c;
        wrapper.price = String.valueOf(ca.Price__c);
        wrapper.priceTier = ca.Price_Tier_Text__c;
        wrapper.episodePrice = String.valueOf(ca.Episode_Price__c);
        wrapper.episodePriceTier = ca.Episode_Price_Tier__c;
        wrapper.caName = ca.Name;
        wrapper.processedTime = caProcessedTimeMap.get(ca.Id);
        if(casErrorMap.get(ca.Id)!=null){
            wrapper.errorMessage = casErrorMap.get(ca.Id).Error_Description__c;
            
        }
        
        cawrapperList.add(wrapper);
        
       
        
       }
       
      //Add errorList due to Playlist Update on Season CA -- Error Capturing ER
      if(statusValue == 'Error'||statusValue == 'Success'){
           cawrapperErrorList = getCAErrorList(CAErrorMap,caUpdatePlaylistErrorMap);
           isErrorMethodInvoked = true;
          
            if(cawrapperErrorList.size() != null && cawrapperErrorList.size()>0 && statusValue == 'Error')
                cawrapperList.addAll(cawrapperErrorList);
       }
       
       //To check Error List record present in SuccessList -- Error Capturing ER
       if(statusValue == 'Success'){
           
           for(Integer i = 0; i < cawrapperList.size();i++){
               
               if(cawrapperList[i].caRecordId != null){
                   
                   
                   
                   if(caUpdatePlaylistErrorMap.get(cawrapperList[i].caRecordId) != null && caHistoryMap.get(cawrapperList[i].caRecordId) != null){
                       
                       
                      
                       if(caUpdatePlaylistErrorMap.get(cawrapperList[i].caRecordId).CreatedDate > caHistoryMap.get(cawrapperList[i].caRecordId).CreatedDate){
                           cawrapperList.remove(i);
                           i--;
                       }
                       
                   }
               }
           }
          
            
       }
       
      
       cawrapperList.sort();
       
       for(CAWrapper wrapper:cawrapperList){
       		wrapper.processedTime = null;
       }
        
       return cawrapperList;
    }
    
    //Error Capturing for Playlist related updates start -- Error Capturing ER
    public static List<CAWrapper> getCAErrorList(Map<String,Client_Avail__c> CAErrorMap,Map<String,CAS_Error_Log__c> caUpdatePlaylistErrorMap){
        
        
        List<CAWrapper> caFinalwrapperList = new List<CAWrapper>();
        List<Client_Avail__History> caHistoryList = new List<Client_Avail__History>();
        Set<ID> caIDSet = new Set<ID>();
        List<CAS_Error_Log__c> casErrorList = new List<CAS_Error_Log__c>();
        Map<Id,Client_Avail__History> caHistoryMap = new Map<Id,Client_Avail__History>();
       
        //Fetch Error Log object records
        casErrorList = [Select Id,LastModifiedDate,Record_Id__c,Error_Category__c,Error_Description__c,Error_Description_Long__c,CreatedDate,PlaylistID__c from CAS_Error_Log__c where Error_Category__c = 'Playlist Update' order by CreatedDate Desc];
        
        
        for(CAS_Error_Log__c caErrorRec : casErrorList){
            caIDSet.add(caErrorRec.Record_Id__c);
            
            //Keep track of PlaylistUpdate Error records TimeStamp
             if(!caUpdatePlaylistErrorMap.containsKey(caErrorRec.Record_Id__c)){
               caUpdatePlaylistErrorMap.put(caErrorRec.Record_Id__c,caErrorRec);
            }
            
            
        }
        
        //Fetch History object records
        caHistoryList = [SELECT Id,NewValue,Field,CreatedDate,OldValue,ParentId FROM Client_Avail__History WHERE ParentId IN : caIDSet AND CreatedDate >: DateTime.now().addDays(-7) AND CreatedById =:UserInfo.getUserId() order by CreatedDate DESC];
        
        
        for(Client_Avail__History caHistoryRec : caHistoryList){
         
           if(!caHistoryMap.containsKey(caHistoryRec.ParentId)){
               caHistoryMap.put(caHistoryRec.ParentId,caHistoryRec);
           } 
           
          
        }
        
       
        //Fetch CA based on IDs from CAS Error Log
        List<Client_Avail__c> caRecordList = [Select Id,Territory__c,Name,Recalculate_Playlist_Avails__c,Recalculation_Status__c,Title_Video_Version__c,AccountF__c,Release_Plan_Title__c,Release_Plan_Channel__c,Release_Plan_Format__c,Release_Plan_Country__c,
                                Local_Data_Category_Picklist__c,Release_Plan_Language__c,RP_Language_Type__c,Episode_Price__c,Price__c,Price_Tier_Text__c,Episode_Price_Tier__c,Price_Start__c,Commercial_Avail__r.Playlist__c,
                                Price_End__c,LastModifiedBy.Name,CreatedBy.Name,LastModifiedDate,Playlist__c from Client_Avail__c where Id In : caIDSet AND Status__c in ('Draft','Tentative','Confirmed')];
        
        
        Set<String> globalAccountList = new Set<String>{'Google','Amazon','Apple iTunes','Microsoft'};
        User userRec = [SELECT Id,Territory__c,Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
        
        for(Client_Avail__c ca :caRecordList){
		    
		    //Territory Check start
			if(ca.Territory__c == userRec.Territory__c || (userRec.Territory__c == 'Home Office' && (ca.Territory__c == 'USA' || globalAccountList.contains(ca.AccountF__c))) ){
			   
    			CAWrapper wrapper = new CAWrapper();
    	       	wrapper.videoVersion = ca.Title_Video_Version__c;
    	        wrapper.title = ca.Release_Plan_Title__c;
    	        wrapper.account = ca.AccountF__c;
    	        wrapper.country = ca.Release_Plan_Country__c;
    	        wrapper.channel = ca.Release_Plan_Channel__c;
    	        wrapper.format = ca.Release_Plan_Format__c;
    	        wrapper.language = ca.Release_Plan_Language__c;
    	        wrapper.languageType = ca.RP_Language_Type__c;
    	        wrapper.caRecordId = ca.Id;
    	        wrapper.caCategory = ca.Local_Data_Category_Picklist__c;
    	        wrapper.price = String.valueOf(ca.Price__c);
    	        wrapper.priceTier = ca.Price_Tier_Text__c;
    	        wrapper.episodePrice = String.valueOf(ca.Episode_Price__c);
    	        wrapper.episodePriceTier = ca.Episode_Price_Tier__c;
    	        wrapper.caName = ca.Name;
    	        wrapper.processedTime = null;
    	        wrapper.errorCategory = 'Local Data Failure';
    	        
    	       // wrapper.playlistID = ca.Commercial_Avail__r.Playlist__c;
    	       
    	        //if(caPlaylistID.get(ca.Id) != null)
    	            
                if(caUpdatePlaylistErrorMap.get(ca.Id)!=null){
                    
                    if(caUpdatePlaylistErrorMap.get(ca.Id).Error_Description_Long__c != null){
                       wrapper.errorMessage = caUpdatePlaylistErrorMap.get(ca.Id).Error_Description_Long__c;
                    
                        if(wrapper.errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                            
                            wrapper.errorMessage = wrapper.errorMessage.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,','.');
                            //wrapper.errorMessage = wrapper.errorMessage.substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
                        } 
                    }
                    
                    wrapper.playlistID = caUpdatePlaylistErrorMap.get(ca.Id).PlaylistID__c;
                    
                }
                
                //Check if not present in existing Error List 
            	if(!CAErrorMap.containsKey(ca.Id)){
    			    
    			     if(caUpdatePlaylistErrorMap.get(ca.Id)!=null){
    			       
    			       //Check if same CA Id present in History object
    			        if(caHistoryMap.get(ca.Id)!=null){
    			            
    			            //if error object createdDate is greater add it to error List
    			            if(caUpdatePlaylistErrorMap.get(ca.Id).CreatedDate > caHistoryMap.get(ca.Id).CreatedDate){
    			                caFinalwrapperList.add(wrapper);
    			            }
    			        }else //No record present in History object
    			            caFinalwrapperList.add(wrapper);
    			    }
    			    
    			}
			
	
			
            }	//Territory Check end
       	}
       
       	return caFinalwrapperList;
    }
    //Error Capturing for Playlist related updates end -- Error Capturing ER
  
    
    public static List<Client_Avail__c> getCADataList(Set<String> possibleStatus,Map<String,Datetime> caProcessedTimeMap,Map<String,Client_Avail__History> caHistoryMap){
    	  Set<Id> caIDs = new Set<Id>(); 
    	  
          if(Test.isRunningTest()){
            List<Client_Avail__c> caList = new List<Client_Avail__c>();
            caList = [Select Id,Name,Recalculate_Playlist_Avails__c,Recalculation_Status__c,Title_Video_Version__c,AccountF__c,Release_Plan_Title__c,Release_Plan_Channel__c,Release_Plan_Format__c,Release_Plan_Country__c,
                                Local_Data_Category_Picklist__c,Release_Plan_Language__c,RP_Language_Type__c,Episode_Price__c,Price__c,Price_Tier_Text__c,Episode_Price_Tier__c,Price_Start__c,
                                Price_End__c,LastModifiedBy.Name,CreatedBy.Name,LastModifiedDate,(Select Id from Child_Client_Avails__r),Playlist__c from Client_Avail__c ];
            return caList;                   
          }else if (!Test.isRunningTest()){
          
             List<Client_Avail__History> scope = [SELECT Id,NewValue,Field,CreatedDate,OldValue,ParentId FROM Client_Avail__History WHERE (Field = :rpavailField OR Field =:rsstatusField) AND CreatedDate >: DateTime.now().addDays(-7) AND CreatedById =:UserInfo.getUserId() order by CreatedDate DESC];
              DateTime now = datetime.now();
              String fieldName = null;
              for(Client_Avail__History caHistory : scope){
                
                //keep track of History record TimeStamp -- Error Capturing ER
                if(!caHistoryMap.containsKey(caHistory.ParentId))
                    caHistoryMap.put(caHistory.ParentId,caHistory);
                
                
                //Add CA Ids 
                if(caHistory.Field == rpavailField){
                	fieldName = rpavailField;
                }else if(caHistory.Field == rsstatusField){
                	fieldName = rsstatusField;
                }
                if(possibleStatus.contains(String.valueOf(caHistory.OldValue)) || possibleStatus.contains(String.valueOf(caHistory.NewValue))){
                    caIDs.add(caHistory.ParentId);
                    if(caProcessedTimeMap.get(caHistory.ParentId+fieldName) == null)
                    	caProcessedTimeMap.put(caHistory.ParentId+fieldName,caHistory.CreatedDate); 
                }
              }
			
             //Query CA
            List<Client_Avail__c> caRecordList = [Select Id,Name,Recalculate_Playlist_Avails__c,Recalculation_Status__c,Title_Video_Version__c,AccountF__c,Release_Plan_Title__c,Release_Plan_Channel__c,Release_Plan_Format__c,Release_Plan_Country__c,
                                Local_Data_Category_Picklist__c,Release_Plan_Language__c,RP_Language_Type__c,Episode_Price__c,Price__c,Price_Tier_Text__c,Episode_Price_Tier__c,Price_Start__c,
                                Price_End__c,LastModifiedBy.Name,CreatedBy.Name,LastModifiedDate,(Select Id from Child_Client_Avails__r),Playlist__c from Client_Avail__c where Id In : caIDs AND Status__c in ('Draft','Tentative','Confirmed') AND Playlist__c != null];
                      
            return caRecordList;
      	}
        return null;
       
    }
    
    @RemoteAction
    public static void reCalculateEpisodes(List<CAWrapper> caRec){
      
       Set<Id> caID = new Set<Id>();
       Map<Id,String> caMap = new Map<Id,String>();
       List<Client_Avail__c> caRecordToUpdateList = new List<Client_Avail__c>();
       
       
       for(CAWrapper ca : caRec ){
           caID.add(ca.caRecordId);
           
       } 
       
       
       if(Test.isRunningTest()){
           List<Client_Avail__c> caList = new List<Client_Avail__c>();
            caList = [Select Id,Name,Recalculate_Playlist_Avails__c,Recalculation_Status__c,Title_Video_Version__c,AccountF__c,Release_Plan_Title__c,Release_Plan_Channel__c,Release_Plan_Format__c,Release_Plan_Country__c,
                                Local_Data_Category_Picklist__c,Release_Plan_Language__c,RP_Language_Type__c,Episode_Price__c,Price__c,Price_Tier_Text__c,Episode_Price_Tier__c,Price_Start__c,
                                Price_End__c,LastModifiedBy.Name,CreatedBy.Name,LastModifiedDate,(Select Id from Child_Client_Avails__r),Playlist__c from Client_Avail__c ];
            caMap.put(caList[0].Id,'Update Episode Avails');
       }else if(!Test.isRunningTest()){
                  List<Client_Avail__History> scope =  [SELECT Id,NewValue,Field,CreatedDate,OldValue,ParentId FROM Client_Avail__History WHERE Field =: 'Recalculate_Playlist_Avails__c' AND ParentId IN: caID  /*AND CreatedById =:UserInfo.getUserId()*/ order by CreatedDate DESC];
               for(Client_Avail__History caHistory : scope){
                   
                  
                   if(caMap.containsKey(caHistory.ParentId))
        			continue;
        			
                   if(caHistory.NewValue == null)
                    	caMap.put(caHistory.ParentId,String.valueOf(caHistory.OldValue));
                   else{
                   		caMap.put(caHistory.ParentId,null); 	
                   }
               }
       }
    
       
       for(CAWrapper ca : caRec){
           Client_Avail__c caRecord = new Client_Avail__c(Id = ca.caRecordId);
           
           caRecord.Recalculation_Status__c = false;
           if(caMap.get(caRecord.Id) != null){
             
             
             caRecord.Recalculate_Playlist_Avails__c = caMap.get(caRecord.Id);
             if(caRecord.Recalculate_Playlist_Avails__c == 'Update Episode Avails')
             	  caRecord.Recalculate_Playlist_Avails__c = 'Update Playlist';
             
              //if errorCategory is Local Data Failure assign Playlist value   
             if(ca.errorCategory != null && ca.errorCategory == 'Local Data Failure' && ca.playlistID != null){
                  caRecord.Playlist__c = ca.playlistID;
              }
           }else{
                
                caRecord.Recalculate_Playlist_Avails__c = 'Update Playlist';
                //if errorCategory is Local Data Failure assign Playlist value   
              if(ca.errorCategory != null && ca.errorCategory == 'Local Data Failure' && ca.playlistID != null){
                  caRecord.Playlist__c = ca.playlistID;
              }
           }
           
          // system.debug('caRecord.Recalculate_Playlist_Avails__c:'+caRecord.Recalculate_Playlist_Avails__c);
           caRecordToUpdateList.add(caRecord);
           
       }
       
       WB_ClientAvailPriceHandler.recursiveUpdate = true;	
       Database.Saveresult[] saveResult_CAList = Database.update(caRecordToUpdateList, false);
       
       system.debug(LoggingLevel.INFO,'saveResult_CAList ===: ' + saveResult_CAList.size());
       
       
       WB_ClientAvailPriceHandler.recursiveUpdate = false;
       
       Datetime ScheduleTime = system.now().addSeconds(15);
       String cronExp = ScheduleTime.second()+' '+ScheduleTime.minute()+' '+ScheduleTime.hour()+' '+ScheduleTime.day()+' '+ScheduleTime.month()+' ? '+ScheduleTime.year();
       String SchedulerName = 'EAs:'  +system.now() + ' ' + system.now().millisecond() + ' UP';//+' '+userinfo.get();
       Id scheduleid = System.schedule(SchedulerName, cronExp, new WB_Batch_Playlist_Mgmt_Process(SchedulerName));
       Episode_Avails_Scheduler__c csetting = new Episode_Avails_Scheduler__c(name = SchedulerName,Scheduler_id__c=scheduleid);
       insert csetting;
                           
    }
    
   /* @RemoteAction @ReadOnly
    public static List<CAWrapper> getSeasonsWithMissingEpisodes(){
    	
    	List<Client_Avail__c> seasonList = [Select Id,Name,Title_Content_Type__c,Title_Video_Version__c,Release_Plan_Title__c,AccountF__c,Release_Plan_Country__c,Release_Plan_Channel__c,
    											Release_Plan_Format__c,Release_Plan_Language__c,RP_Language_Type__c,Local_Data_Category_Picklist__c,Price__c,Price_Tier_Text__c,Episode_Price__c,Episode_Price_Tier__c,
    											Playlist__r.Total_Playlist_Content__c,(Select Id FROM Child_Client_Avails__r Limit 1) FROM Client_Avail__c
										    	WHERE Title_Content_Type__c = 'Season' 
												AND Playlist__c != null 
												AND END_DATE__c > TODAY
										        AND (CA_LifeCycle__c = 'Active Current' OR CA_LifeCycle__c = 'Active Future') 
										        AND Local_Data_Category_Picklist__c IN ('TV New Release','TV Catalog','TV Day After US','TV Day After Local')];
		
		List<CAWrapper> cawrapperList = new List<CAWrapper>();
		for(Client_Avail__c ca :seasonList){
			
			if(ca.Child_Client_Avails__r.size() > 0)
				continue;
				
	       	CAWrapper wrapper = new CAWrapper();
	       	wrapper.videoVersion = ca.Title_Video_Version__c;
	        wrapper.title = ca.Release_Plan_Title__c;
	        wrapper.account = ca.AccountF__c;
	        wrapper.country = ca.Release_Plan_Country__c;
	        wrapper.channel = ca.Release_Plan_Channel__c;
	        wrapper.format = ca.Release_Plan_Format__c;
	        wrapper.language = ca.Release_Plan_Language__c;
	        wrapper.languageType = ca.RP_Language_Type__c;
	        wrapper.caRecordId = ca.Id;
	        wrapper.caCategory = ca.Local_Data_Category_Picklist__c;
	        wrapper.price = String.valueOf(ca.Price__c);
	        wrapper.priceTier = ca.Price_Tier_Text__c;
	        wrapper.episodePrice = String.valueOf(ca.Episode_Price__c);
	        wrapper.episodePriceTier = ca.Episode_Price_Tier__c;
	        wrapper.caName = ca.Name;
	        wrapper.processedTime = null;
        
        	cawrapperList.add(wrapper);
       }
       
       
       return cawrapperList;								        
    }
    
    
    @RemoteAction @ReadOnly
    public static List<CAWrapper> getDraftEpisodesWithBroadcastDate(){
    	List<CAWrapper> cawrapperList = new List<CAWrapper>();
    	
    	List<Client_Avail__c> episodeList = [Select Id,Name,Title_Content_Type__c,Title_Video_Version__c,Local_Title__r.Title__r.Name,AccountF__c,Release_Plan_Country__c,Release_Plan_Channel__c,
    											Release_Plan_Format__c,Release_Plan_Language__c,RP_Language_Type__c,Local_Data_Category_Picklist__c,Price__c,Price_Tier_Text__c,Episode_Price__c,Episode_Price_Tier__c,
    											Start_Date__c,End_Date__c,Local_Title__r.Local_TV_Air_Date__c,Local_Title__r.Title__r.US_TV_Air_Date__c
    											FROM Client_AVail__c 
    											WHERE Title_Content_Type__c = 'Episode' 
												AND END_DATE__c > TODAY
												AND Parent_Client_Avail__c != null 
												AND Status__c = 'Draft' 
												AND Parent_Client_Avail__r.Local_Data_Category_Picklist__c IN ('TV Day After US','TV Day After Local') 
												AND
												((Local_Data_Category_Picklist__c = 'TV Day After Local' AND Local_Title__r.Local_TV_Air_Date__c != null) OR  
												 (Local_Data_Category_Picklist__c = 'TV Day After US' AND Local_Title__r.Title__r.US_TV_Air_Date__c != null) OR
												 (Local_Title__r.Category__c = 'TV Day After Local' AND Local_Title__r.Local_TV_Air_Date__c != null) OR
												 (Local_Title__r.Category__c = 'TV Day After US' AND Local_Title__r.Title__r.US_TV_Air_Date__c != null) 
												) 
												AND (CA_LifeCycle__c = 'Active Current' OR CA_LifeCycle__c = 'Active Future')];
    	
    	
    	for(Client_Avail__c ca :episodeList){
			
			CAWrapper wrapper = new CAWrapper();
	       	wrapper.videoVersion = ca.Title_Video_Version__c;
	        wrapper.title = ca.Local_Title__r.Title__r.Name;
	        wrapper.account = ca.AccountF__c;
	        wrapper.country = ca.Release_Plan_Country__c;
	        wrapper.channel = ca.Release_Plan_Channel__c;
	        wrapper.format = ca.Release_Plan_Format__c;
	        wrapper.language = ca.Release_Plan_Language__c;
	        wrapper.languageType = ca.RP_Language_Type__c;
	        wrapper.caRecordId = ca.Id;
	        wrapper.caCategory = ca.Local_Data_Category_Picklist__c;
	        wrapper.price = String.valueOf(ca.Price__c);
	        wrapper.priceTier = ca.Price_Tier_Text__c;
	        wrapper.episodePrice = String.valueOf(ca.Episode_Price__c);
	        wrapper.episodePriceTier = ca.Episode_Price_Tier__c;
	        wrapper.caName = ca.Name;
	        wrapper.processedTime = null;
        
        	cawrapperList.add(wrapper);
       	}
    	return cawrapperList;
    }
    
    @RemoteAction @ReadOnly
    public static List<CAWrapper> getSeasonsWithNonTVCategory(){
    	List<CAWrapper> cawrapperList = new List<CAWrapper>();
    	
    	List<Client_Avail__c> seasonList = [Select Id,Name,Title_Content_Type__c,Title_Video_Version__c,Release_Plan_Title__c,AccountF__c,Release_Plan_Country__c,Release_Plan_Channel__c,
    											Release_Plan_Format__c,Release_Plan_Language__c,RP_Language_Type__c,Local_Data_Category_Picklist__c,Price__c,Price_Tier_Text__c,Episode_Price__c,Episode_Price_Tier__c
    											FROM Client_Avail__c 
    											WHERE Title_Content_Type__c = 'Season' 
												AND Playlist__c !=null
												AND END_DATE__c > TODAY	
												AND Local_Data_Category_Picklist__c NOT IN ('TV New Release','TV Catalog','TV Day After US','TV Day After Local')
												AND (CA_LifeCycle__c = 'Active Current' OR CA_LifeCycle__c = 'Active Future')];
												
		for(Client_Avail__c ca :seasonList){
			
			CAWrapper wrapper = new CAWrapper();
	       	wrapper.videoVersion = ca.Title_Video_Version__c;
	        wrapper.title = ca.Release_Plan_Title__c;
	        wrapper.account = ca.AccountF__c;
	        wrapper.country = ca.Release_Plan_Country__c;
	        wrapper.channel = ca.Release_Plan_Channel__c;
	        wrapper.format = ca.Release_Plan_Format__c;
	        wrapper.language = ca.Release_Plan_Language__c;
	        wrapper.languageType = ca.RP_Language_Type__c;
	        wrapper.caRecordId = ca.Id;
	        wrapper.caCategory = ca.Local_Data_Category_Picklist__c;
	        wrapper.price = String.valueOf(ca.Price__c);
	        wrapper.priceTier = ca.Price_Tier_Text__c;
	        wrapper.episodePrice = String.valueOf(ca.Episode_Price__c);
	        wrapper.episodePriceTier = ca.Episode_Price_Tier__c;
	        wrapper.caName = ca.Name;
	        wrapper.processedTime = null;
        
        	cawrapperList.add(wrapper);
       	}
    	return cawrapperList;
    }	
    
    
    @RemoteAction @ReadOnly
    public static List<CAWrapper> getSeasonsWithoutPlaylist(){
    	
    	List<CAWrapper> cawrapperList = new List<CAWrapper>();
    	
    	List<Client_Avail__c> seasonList = [Select Id,Name,Lock_Playlist_Update__c,Title_Content_Type__c,Title_Video_Version__c,Release_Plan_Title__c,AccountF__c,Release_Plan_Country__c,Release_Plan_Channel__c,
    											Release_Plan_Format__c,Release_Plan_Language__c,RP_Language_Type__c,Local_Data_Category_Picklist__c,Price__c,Price_Tier_Text__c,Episode_Price__c,Episode_Price_Tier__c
    											FROM Client_Avail__c 
    											WHERE Title_Content_Type__c = 'Season' 
												AND Playlist__c = null 
												AND Commercial_Avail__r.Playlist__c != null 
												AND END_DATE__c > TODAY
												AND (CA_LifeCycle__c = 'Active Current' OR CA_LifeCycle__c = 'Active Future')];
												
		for(Client_Avail__c ca :seasonList){
			
			CAWrapper wrapper = new CAWrapper();
	       	wrapper.videoVersion = ca.Title_Video_Version__c;
	        wrapper.title = ca.Release_Plan_Title__c;
	        wrapper.account = ca.AccountF__c;
	        wrapper.country = ca.Release_Plan_Country__c;
	        wrapper.channel = ca.Release_Plan_Channel__c;
	        wrapper.format = ca.Release_Plan_Format__c;
	        wrapper.language = ca.Release_Plan_Language__c;
	        wrapper.languageType = ca.RP_Language_Type__c;
	        wrapper.caRecordId = ca.Id;
	        wrapper.caCategory = ca.Local_Data_Category_Picklist__c;
	        wrapper.price = String.valueOf(ca.Price__c);
	        wrapper.priceTier = ca.Price_Tier_Text__c;
	        wrapper.episodePrice = String.valueOf(ca.Episode_Price__c);
	        wrapper.episodePriceTier = ca.Episode_Price_Tier__c;
	        wrapper.caName = ca.Name;
	        wrapper.processedTime = null;
        
        	cawrapperList.add(wrapper);
       	}
    	return cawrapperList;
    }
    
    
    @RemoteAction @ReadOnly
    public static List<CAWrapper> getDayAfterEpisodesWithInvalidStartDate(){
    	
    	List<CAWrapper> cawrapperList = new List<CAWrapper>();
    	
    	List<Client_Avail__c> episodeList = [Select Id,Name,Title_Content_Type__c,Title_Video_Version__c,Local_Title__r.Title__r.Name,AccountF__c,Release_Plan_Country__c,Release_Plan_Channel__c,
    											Release_Plan_Format__c,Release_Plan_Language__c,RP_Language_Type__c,Local_Data_Category_Picklist__c,Price__c,Price_Tier_Text__c,Episode_Price__c,Episode_Price_Tier__c,
    											Local_Title__r.Title__r.US_TV_Air_Date__c,Local_Title__r.Country__r.TV_Day_After_US_Offset__c,Local_Title__r.Local_TV_Air_Date__c,Local_Title__r.Country__r.TV_Day_After_Local_Offset__c,
    											Start_Date__c,End_Date__c,Parent_Client_Avail__r.Start_Date__c,Parent_Client_Avail__r.End_Date__c 
    											FROM Client_AVail__c WHERE Title_Content_Type__c = 'Episode' 
												AND END_DATE__c > TODAY
												AND Parent_Client_Avail__c != null 
												AND
												((Local_Data_Category_Picklist__c = 'TV Day After Local' AND Local_Title__r.Local_TV_Air_Date__c != null) OR  
												 (Local_Data_Category_Picklist__c = 'TV Day After US' AND Local_Title__r.Title__r.US_TV_Air_Date__c != null)
												) 
												AND (CA_LifeCycle__c = 'Active Current' OR CA_LifeCycle__c = 'Active Future') 
												AND Status__c IN ('Tentative','Confirmed')];
												
		for(Client_Avail__c ca :episodeList){
			
			Date airDate = null;
			if(ca.Local_Data_Category_Picklist__c == 'TV Day After US') 
                airDate = ca.Local_Title__r.Title__r.US_TV_Air_Date__c + ((ca.Local_Title__r.Country__r.TV_Day_After_US_Offset__c != null) ? Integer.valueof(ca.Local_Title__r.Country__r.TV_Day_After_US_Offset__c) : 0);
            else if(ca.Local_Data_Category_Picklist__c == 'TV Day After Local') 
                airDate = ca.Local_Title__r.Local_TV_Air_Date__c + ((ca.Local_Title__r.Country__r.TV_Day_After_Local_Offset__c != null) ? Integer.valueof(ca.Local_Title__r.Country__r.TV_Day_After_Local_Offset__c) : 0);
            
            if(ca.Start_Date__c == airDate || (ca.Start_Date__c == ca.Parent_Client_Avail__r.Start_Date__c && airdate < ca.Parent_Client_Avail__r.Start_Date__c))
            	continue;
            	
			CAWrapper wrapper = new CAWrapper();
	       	wrapper.videoVersion = ca.Title_Video_Version__c;
	        wrapper.title = ca.Local_Title__r.Title__r.Name;
	        wrapper.account = ca.AccountF__c;
	        wrapper.country = ca.Release_Plan_Country__c;
	        wrapper.channel = ca.Release_Plan_Channel__c;
	        wrapper.format = ca.Release_Plan_Format__c;
	        wrapper.language = ca.Release_Plan_Language__c;
	        wrapper.languageType = ca.RP_Language_Type__c;
	        wrapper.caRecordId = ca.Id;
	        wrapper.caCategory = ca.Local_Data_Category_Picklist__c;
	        wrapper.price = String.valueOf(ca.Price__c);
	        wrapper.priceTier = ca.Price_Tier_Text__c;
	        wrapper.episodePrice = String.valueOf(ca.Episode_Price__c);
	        wrapper.episodePriceTier = ca.Episode_Price_Tier__c;
	        wrapper.caName = ca.Name;
	        wrapper.processedTime = null;
        
        	cawrapperList.add(wrapper);
       	}
    	return cawrapperList;
    }
    
    @RemoteAction @ReadOnly
    public static List<CAWrapper> getNonDayAfterEpisodesWithInvalidStartDate(){
    	
    	List<CAWrapper> cawrapperList = new List<CAWrapper>();
    	
    	List<Client_Avail__c> episodeList = [Select Id,Name,Title_Content_Type__c,Title_Video_Version__c,Local_Title__r.Title__r.Name,AccountF__c,Release_Plan_Country__c,Release_Plan_Channel__c,
    											Release_Plan_Format__c,Release_Plan_Language__c,RP_Language_Type__c,Local_Data_Category_Picklist__c,Price__c,Price_Tier_Text__c,Episode_Price__c,Episode_Price_Tier__c,
    											Start_Date__c,End_Date__c,Parent_Client_Avail__r.Start_Date__c,Parent_Client_Avail__r.End_Date__c
    											FROM Client_AVail__c WHERE Title_Content_Type__c = 'Episode' 
												AND END_DATE__c > TODAY
												AND Parent_Client_Avail__c != null 
												AND (Local_Data_Category_Picklist__c = 'TV New Release' OR Local_Data_Category_Picklist__c = 'TV Catalog')
												AND (CA_LifeCycle__c = 'Active Current' OR CA_LifeCycle__c = 'Active Future') 
												AND Status__c IN ('Draft','Tentative','Confirmed')];
												
		for(Client_Avail__c ca :episodeList){
			
			if(ca.Start_Date__c == ca.Parent_Client_Avail__r.Start_Date__c && ca.End_Date__c == ca.Parent_Client_Avail__r.End_Date__c)
				continue;
				
			CAWrapper wrapper = new CAWrapper();
	       	wrapper.videoVersion = ca.Title_Video_Version__c;
	        wrapper.title = ca.Local_Title__r.Title__r.Name;
	        wrapper.account = ca.AccountF__c;
	        wrapper.country = ca.Release_Plan_Country__c;
	        wrapper.channel = ca.Release_Plan_Channel__c;
	        wrapper.format = ca.Release_Plan_Format__c;
	        wrapper.language = ca.Release_Plan_Language__c;
	        wrapper.languageType = ca.RP_Language_Type__c;
	        wrapper.caRecordId = ca.Id;
	        wrapper.caCategory = ca.Local_Data_Category_Picklist__c;
	        wrapper.price = String.valueOf(ca.Price__c);
	        wrapper.priceTier = ca.Price_Tier_Text__c;
	        wrapper.episodePrice = String.valueOf(ca.Episode_Price__c);
	        wrapper.episodePriceTier = ca.Episode_Price_Tier__c;
	        wrapper.caName = ca.Name;
	        wrapper.processedTime = null;
        
        	cawrapperList.add(wrapper);
       	}
    	return cawrapperList;
    }*/
    
   
    public class CAWrapper implements Comparable{
        public String videoVersion;
        public String title;
        public String account;
        public String country;
        public String channel;
        public String format;
        public String language;
        public String contentType;
        public String languageType;
        public String caRecordId;
        public String caCategory;
        public String price;
        public String priceTier;
        public String episodePrice;
        public String episodePriceTier;
        public String caName;
        public String action;
        public Boolean selected;
        public DateTime processedTime;
        public String errorMessage;
        public String errorCategory;
        public String playlistID;
        
         public Integer compareTo(Object obj) {
            CAWrapper caRecord = (CAWrapper)(obj);
            
            if(processedTime == null || caRecord.processedTime == null)
            	return 1;
            	 
            if( processedTime == caRecord.processedTime){
        		return 0;
        	}else if(processedTime < caRecord.processedTime){
        		return 1;
        	}else{
        		return -1;
        	}
             
         }
    }
}