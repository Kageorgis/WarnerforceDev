global class WB_Batch_CAP_PublishToClientUpdate implements Schedulable,Database.Batchable<sObject>,Database.Stateful{
    
    
    String query = null;
    Id accountRecId = null;//Apple iTunes Account Id
    String titleContentType = WB_PriceUtility.FEATURE;
    Set<String> channelSet = new Set<String>{'VODi','VODc','EST'};
    Set<String> capformatSet = new Set<String>{'SD','HD'};
    List<Country__c> countryList = new List<Country__c>();
    String caStatus = WB_PriceUtility.STATUS_CONF;
    
    /* Start ******** Scheduler Methods************/ 
    global WB_Batch_CAP_PublishToClientUpdate(){
    	
    }
    
	global void execute (SchedulableContext ctx){
		Database.executeBatch(new WB_Batch_CAP_PublishToClientUpdate('PublishToClient Scheduler'));  	
	}
	
	/* End ******* Scheduler Methods************ */
	
    global WB_Batch_CAP_PublishToClientUpdate(String name){
        List<Country_SID_Key__c> selectedCountryList = Country_SID_Key__c.getall().values();
        List<String> countryNameList = new List<String>();
        for(Country_SID_Key__c countryRec : selectedCountryList){
            if(countryRec.isPublishToClient__c)
                countryNameList.add(countryRec.Name);
        }
        System.debug(LoggingLevel.INFO,'countryNameList :'+countryNameList);
        
        String accountName = 'Apple iTunes';
        accountRecId = [Select Id From Account where Name = :accountName and RecordType.Name = 'Digital Client'].Id;
        countryList = [Select Id From Country__c Where Name in :countryNameList];
        
        System.debug(LoggingLevel.INFO,'countryList :'+countryList);
        
        query = 'Select Id,Client_Avail__c,CAP_Lifecycle__c,Publish_to_Client__c,Title_Content_Type__c,Effective_Date__c,Client_Avail_Channel__c,Client_Avail__r.Status__c,Account__c,Country__c, '+ 
        		' Type__c,Category__c,CA_Start_Date__c,Title_Video_Version__c,Client_Avail_Format__c,Client_Avail_Language__c,Client_Avail_Language_Type__c,Client_Avail__r.Commercial_Avail__r.Country_Lookup__c,Client_Avail__r.Commercial_Avail__r.Languages__c '+ 
        		' FROM Client_Avail_Price__c '+ 
        		' WHERE Client_Avail__r.Client__c = :accountRecId '+ 
        		' AND Client_Avail__r.Commercial_Avail__r.Country_Lookup__c IN :countryList '+
        		' AND Expiry_Date__c >= TODAY ';//+
        		//' AND Publish_to_Client__c NOT IN (\'Send\',\'Re-Send\') ';
        		
        System.debug(LoggingLevel.INFO,'Query :'+query);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //List<Client_Avail_Price__c> capList = Database.query(query);
        //system.debug(LoggingLevel.INFO,'Record Size :'+capList.size());
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Client_Avail_Price__c> scope){
        List<Client_Avail_Price__c> capUpdateList = new List<Client_Avail_Price__c>();
        List<Client_Avail_Price__c> firstCAPList = new List<Client_Avail_Price__c>();
        List<Client_Avail_Price__c> firstCAPToBeUpdatedList = new List<Client_Avail_Price__c>();
        Date dateCheckEST = System.Today().adddays(Integer.valueOf(Label.PublishToClient_EST_Window));
        Date dateCheckVODi = System.Today().adddays(Integer.valueOf(Label.PublishToClient_VODi_Window));
        
        system.debug(LoggingLevel.INFO, 'Execute Method :'+scope.size());
        
        for(Client_Avail_Price__c cap : scope){
         
            if(cap.Client_Avail__r.Status__c == WB_PriceUtility.STATUS_CONF && cap.CAP_Lifecycle__c != 'History Expired' && cap.Title_Content_Type__c ==  WB_PriceUtility.FEATURE){
                if(cap.Publish_to_Client__c == 'Send' || cap.Publish_to_Client__c == 'Re-Send')
               	    continue;
               			
                if((cap.Client_Avail_Channel__c == 'EST' && (cap.Client_Avail_Format__c == 'HD' || cap.Client_Avail_Format__c == 'SD') &&  ( (cap.Effective_Date__c >= WB_PriceUtility.gmtDate && cap.Effective_Date__c <= dateCheckEST)  || cap.CAP_Lifecycle__c == 'Active Current') ) ||
                   (cap.Client_Avail_Channel__c == 'VODi' && (cap.Client_Avail_Format__c == 'HD' || cap.Client_Avail_Format__c == 'SD') && ( (cap.Effective_Date__c >= WB_PriceUtility.gmtDate && cap.Effective_Date__c <= dateCheckVODi)  || cap.CAP_Lifecycle__c == 'Active Current') ) 
                   ){
                   	
               		if(cap.Effective_Date__c > cap.CA_Start_Date__c){ //Re-Priced CAP
               			cap.Publish_to_Client__c = 'Send';    
                   		capUpdateList.add(cap);
               		}else if(cap.Effective_Date__c < cap.CA_Start_Date__c) { //Pre-Order CAP
               			//Do nothing for now. Stays as 'Do Not Send'.
               		}else if(cap.Effective_Date__c == cap.CA_Start_Date__c){ //First CAP
               			firstCAPList.add(cap);
               		}
               		
                }
            }
               
        }
            
        firstCAPToBeUpdatedList = setPublishToFirstCAP(firstCAPList);
        
        if(firstCAPToBeUpdatedList != null && firstCAPToBeUpdatedList.size()>0){
            capUpdateList.addAll(firstCAPToBeUpdatedList);
        }
            
        WB_ClientAvailPriceHandler.recursiveUpdate = true;
        if(capUpdateList != null && capUpdateList.size() > 0){
            system.debug(LoggingLevel.INFO,'List to be updated Size:'+capUpdateList.size());
            List<String> errorMessages = new List<String>();
            Map<Id,String> caErrorMap = new Map<Id,String>();
            String errorMessageValue = '';
            
            Database.saveResult[] saveResult  = Database.update(capUpdateList, false);
            if(saveResult != null && saveResult.size()>0){
                for(Integer index=0;index<saveResult.size();index++){
                    Database.SaveResult updateResult = saveResult[index]; 
                    if(!updateResult.isSuccess()){
                        String errorMessage = '';
                        Id caId;
                        for(Database.Error err : updateResult.getErrors()) {
                            errorMessage += err.getMessage();
                        }
                       
                       caId = updateResult.getId();
                       if(!caErrorMap.containsKey(caId))
                            caErrorMap.put(caId, errorMessage);
                    }
                }
            }
            if(capUpdateList.size() != null && capUpdateList.size() > 0){
                createErrorLog(capUpdateList,caErrorMap);
            }
        }
        WB_ClientAvailPriceHandler.recursiveUpdate = false;
        
    }
    
    global void finish(Database.BatchableContext BC){
        
       
    }
    
    public List<Client_Avail_Price__c> setPublishToFirstCAP(List<Client_Avail_Price__c> capList){
        
      Set<String> videoVersionSet = new Set<String>();
      Set<String> titleContentTypeSet = new Set<String>();
      Set<String> countrySet = new Set<String>();
      Set<String> formatSet = new Set<String>();
      Set<String> languageSet = new Set<String>();
      Set<String> languageTypeSet = new Set<String>();
      
      Map<String,Client_Avail__c> caAvailableDataMap = new Map<String,Client_Avail__c>();
      
      if(capList != null && capList.size()>0){
        for(Client_Avail_Price__c cap : capList){
            videoVersionSet.add(cap.Title_Video_Version__c);
            titleContentTypeSet.add(cap.Title_Content_Type__c);
            countrySet.add(cap.Client_Avail__r.Commercial_Avail__r.Country_Lookup__c);
            formatSet.add(cap.Client_Avail_Format__c);
            languageSet.add(cap.Client_Avail__r.Commercial_Avail__r.Languages__c);
            languageTypeSet.add(cap.Client_Avail_Language_Type__c);
        }
        
      } 
      
      system.debug(LoggingLevel.INFO,'Before Query');
  /*  List<Client_Avail__c> caAvailableData = [Select Id,Start_Date__c,End_Date__c,Title_Video_Version__c,Title_Content_Type__c,Release_Plan_Country__c,Release_Plan_Format__c,Release_Plan_Channel__c,Release_Plan_Language__c,RP_Language_Type__c,Client__c,Client__r.Name,Commercial_Avail__c FROM Client_Avail__c
                         WHERE (Commercial_Avail__r.Local_Title__r.Title__r.Video_Version__c IN :videoVersionSet AND Title_Content_Type__c IN :titleContentTypeSet AND Commercial_Avail__r.Country_Lookup__c IN :countrySet AND Release_Plan_Format__c IN :formatSet 
                         AND Release_Plan_Channel__c IN :channelSet AND Commercial_Avail__r.Languages__c IN :languageSet AND RP_Language_Type__c IN :languageTypeSet AND Client__c =:accountRecId)];
      
      system.debug(LoggingLevel.INFO,'After Query ->'+caAvailableData.size());
      
      if(caAvailableData != null && caAvailableData.size()>0){
        for(Client_Avail__c ca :caAvailableData){
            String key = ca.Title_Video_Version__c+'%'+ca.Release_Plan_Country__c+'%'+ca.Release_Plan_Format__c+'%'+ca.Release_Plan_Channel__c+'%'+
		                		 ca.Release_Plan_Language__c+'%'+ca.RP_Language_Type__c+'%'+ca.Client__c+'%'+ca.Title_Content_Type__c;
		            
            Client_Avail__c availInMap = caAvailableDataMap.get(key);
            if(availInMap == null || caRec.Start_Date__c < availInMap.Start_Date__c){
                caAvailableDataMap.put(key,caRec);
            }
        }
        
      }    
     */ 
     
     List<Commercial_Avail__c> rpAvailableData = [ Select Id,Name,(Select Id,Start_Date__c,End_Date__c,Title_Video_Version__c,Title_Content_Type__c,Release_Plan_Country__c,Release_Plan_Format__c,Release_Plan_Channel__c,Release_Plan_Language__c,RP_Language_Type__c,Client__c,Client__r.Name,Commercial_Avail__c FROM Client_Avails__r Where Client__c =:accountRecId)
                          From Commercial_Avail__c WHERE Local_Title__r.Title__r.Video_Version__c IN :videoVersionSet AND Local_Title__r.Title__r.Content_Type__c IN :titleContentTypeSet AND Country_Lookup__c IN :countrySet 
                          AND Format__c IN :formatSet  AND Channel__c IN :channelSet AND Languages__c IN :languageSet AND Language_Type__c IN :languageTypeSet];
      
      system.debug(LoggingLevel.INFO,'After Query ->'+rpAvailableData.size());
  	  
      if(rpAvailableData != null && rpAvailableData.size()>0){
      	for(Commercial_Avail__c rpRec:rpAvailableData){
	    	List<Client_Avail__c> caRecList = rpRec.Client_Avails__r;
	      	if(caRecList != null && caRecList.size() > 0){
	        	for(Client_Avail__c ca :caRecList){
	            	String key = ca.Title_Video_Version__c+'%'+ca.Release_Plan_Country__c+'%'+ca.Release_Plan_Format__c+'%'+ca.Release_Plan_Channel__c+'%'+
		                		 ca.Release_Plan_Language__c+'%'+ca.RP_Language_Type__c+'%'+ca.Client__c+'%'+ca.Title_Content_Type__c;
		            
		            Client_Avail__c availInMap = caAvailableDataMap.get(key);
		            if(availInMap == null || ca.Start_Date__c < availInMap.Start_Date__c){
		                caAvailableDataMap.put(key,ca);
		            }
	        	}
	      	}
      	 }
      }
     
     List<Client_Avail_Price__c> firstCAPUpdateList = new List<Client_Avail_Price__c>();
     List<Client_Avail__c> firstCAList = caAvailableDataMap.values();
     Set<Id> firsCAIdSet = new Set<Id>();
     for(Client_Avail__c firstCA:firstCAList){
     	firsCAIdSet.add(firstCA.Id);	
     }
     
     for(Client_Avail_Price__c cap : capList){
        if(!firsCAIdSet.contains(cap.Client_Avail__c)){
    	    cap.Publish_to_Client__c = 'Send';   
            firstCAPUpdateList.add(cap);
        }else if(cap.Effective_Date__c < System.today()){
        	cap.Publish_to_Client__c = 'Send';   
            firstCAPUpdateList.add(cap);
        }
     }
     
     return firstCAPUpdateList;
 }

  public static void createErrorLog(List<Client_Avail_Price__c> capList,Map<Id,String> caErrorMap){
         List<WB_CAS_ErrorLogger.ErrorLog> errorLogs = new List<WB_CAS_ErrorLogger.ErrorLog>();
         
         if(capList != null && capList.size()>0){
             for(Client_Avail_Price__c cap : capList){
                 if(caErrorMap.get(cap.Id) != null){
                     WB_CAS_ErrorLogger.ErrorLog errorLogInstance = new  WB_CAS_ErrorLogger.ErrorLog();
                     errorLogInstance.recordId = cap.Id;
                     errorLogInstance.errorCategory = 'Publish To Client';
                     errorLogInstance.errorDescription = caErrorMap.get(cap.Id).left(252);
                     errorLogInstance.errorDescriptionLong = caErrorMap.get(cap.Id).left(32000); 
                     errorLogInstance.objectName = cap.Id.getSObjectType().getDescribe().getName();
                     errorLogInstance.account = cap.Account__c;
                     errorLogs.add(errorLogInstance);
                 }
                 
             }
         }
         
         if(errorLogs != null && errorLogs.size()>0){
            WB_CAS_ErrorLogger.logError(errorLogs); 
         }
         
         
    }

}