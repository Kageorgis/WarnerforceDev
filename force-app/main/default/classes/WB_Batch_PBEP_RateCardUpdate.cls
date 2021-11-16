global class WB_Batch_PBEP_RateCardUpdate implements Database.Batchable<sObject>,Database.Stateful{
    
    global List<Agreement__c> storefrontList;
    global Set<Id> storefrontIds;
    global Boolean updateCA = false;
    global Boolean updateCAP = false;
    
    global WB_Batch_PBEP_RateCardUpdate(List<Agreement__c> storefrontList,Boolean updateCA, Boolean updateCAP){
        storefrontList = storefrontList;
        storefrontIds = new Set<Id>();
        this.updateCA = updateCA;
        this.updateCAP = updateCAP;
        
        for(Agreement__c sf : storefrontList){
            if(sf.CRM_Storefront__c){
              storefrontIds.add(sf.Id);  
            }
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        
        //String caId = 'a0G0B00002RVamu';
        String Query = 'SELECT Id,Client__c,Release_Plan_Country__c,Release_Plan_Channel__c,Release_Plan_Format__c,Title_Content_Type__c,Price_Tier_Text__c,CA_CRM_Country__c,CA_Rate_Card__c,SR_Price__c,SR_Per_Episode__c,Pricing__c FROM Client_Avail__c WHERE Storefront__c IN : storefrontIds';
        //Query = Query + ' AND Title_Video_Version__c  = \'6000077122\'';
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<Client_Avail__c> scope){
        
        Map<String,Client_Avail__c> caMap = new Map<String,Client_Avail__c>();
        List<Client_Avail_Price__c> capUpdateList = new List<Client_Avail_Price__c>();
		List<Client_Avail_Price__c> capExistingRateCardList = new List<Client_Avail_Price__c>();
        List<Pricebook_Entry_Period__c> pbepUpdateList = new List<Pricebook_Entry_Period__c>();
      
        List<Client_Avail_Price__c> capList = [Select Id,Name,Type__c,Account__c,Country__c,Client_Avail_Channel__c,Client_Avail_Format__c,CAP_Lifecycle__c,
                                                Title_Content_Type__c,Price_Tier__c,Price__c,Effective_Date__c, Expiry_Date__c, Category__c,CAP_Rate_Card__c,CAP_CRM_Country__c,Episode_Price_Tier__c,Episode_Price__c,Episode_Rate_Card__c,Episode_Pricing__c,
                                                Client_Avail__c,Client_Avail__r.Price_Tier_Text__c,Client_Avail__r.Price__c,Client_Avail__r.CA_Rate_Card__c,Client_Avail__r.APO_Date__c,Client_Avail__r.Start_Date__c,Client_Avail__r.End_Date__c,Client_Avail__r.Episode_Pricing__c,Client_Avail__r.Episode_Rate_Card__c,
                                                (Select Id,Name From Pricebook_Entry_Periods__r) 
                                                FROM Client_Avail_Price__c WHERE Client_Avail__c IN : scope AND CAP_Lifecycle__c LIKE 'Active%'  
                                                AND ((Price_Tier__c != Null AND Price_Tier__c != '' AND Price_Tier__c != 'TBD') OR Price__c != Null)
                                                AND RecordType.Name = 'PERM'];
												
		
		Map<Id,Client_Avail_Price__c> capRateCardExistingMap = new Map<Id,Client_Avail_Price__c>([Select id,CAP_Rate_Card__c,Episode_Rate_Card__c FROM Client_Avail_Price__c 
                                                where Client_Avail__c IN : scope AND CAP_Lifecycle__c LIKE 'Active%'  
                                                AND ((Price_Tier__c != Null AND Price_Tier__c != '' AND Price_Tier__c != 'TBD') OR Price__c != Null)
                                                AND RecordType.Name = 'PERM' AND CAP_Rate_Card__c != NULL]);
												
        Map<String,Rate_Card__c> capIdRCMap = assignRateCardToCAP(capList);
        List<Client_Avail_Price__c> tobeConvertedCAPs = new List<Client_Avail_Price__c>();
        
        for(Client_Avail_Price__c cap:capList){
            if(cap.CAP_Rate_Card__c != null){
            	tobeConvertedCAPs.add(cap);
            	
                if(capIdRCMap.get(cap.Id)!= null){
					
					if(!(capRateCardExistingMap != Null && capRateCardExistingMap.get(cap.Id)!= null && capRateCardExistingMap.get(cap.Id).CAP_Rate_Card__c != Null)){
						cap.Pricing__c = null;
						capUpdateList.add(cap);
					}else if(cap.Title_Content_Type__c == 'Season' && cap.Episode_Rate_Card__c != Null){
					    cap.Pricing__c = null;
						capUpdateList.add(cap);
					}
                    
                    if(cap.Pricebook_Entry_Periods__r != null && cap.Pricebook_Entry_Periods__r.size() > 0){
                      Pricebook_Entry_Period__c pbep = cap.Pricebook_Entry_Periods__r[0];
                      pbep.pricing__c = null;  
                      pbep.Rate_Card__c = cap.CAP_Rate_Card__c;
                      pbepUpdateList.add(pbep);
                    }
                    
                    if((cap.Price_Tier__c != cap.Client_Avail__r.Price_Tier_Text__c) || (cap.Price__c != cap.Client_Avail__r.Price__c))
                        continue;
                    
                    Boolean updateAvail = false;
                    if(cap.CAP_Lifecycle__c == 'Active Current'){
                        updateAvail = true;
                    }else if(cap.CAP_Lifecycle__c == 'Active Future' && cap.Client_Avail__r.Start_Date__c > System.today()){
                        if(cap.Client_Avail__r.APO_Date__c != null){
                            if(cap.Effective_Date__c == cap.Client_Avail__r.APO_Date__c)
                                updateAvail = true;
                        }else if(cap.Effective_Date__c == cap.Client_Avail__r.Start_Date__c){
                            updateAvail = true;
                        }
                    }
                    
                    if(updateAvail){
                        if(cap.Title_Content_Type__c == 'Season' ){
                            if((cap.Episode_Rate_Card__c != null || cap.Client_Avail__r.CA_Rate_Card__c == null)){
                                caMap.put(cap.Client_Avail__c,new Client_Avail__c(Id=cap.Client_Avail__c,CA_Rate_Card__c = cap.CAP_Rate_Card__c,Pricing__c = null,Episode_Rate_Card__c = cap.Episode_Rate_Card__c,Episode_Pricing__c = null));
                            }
                            
                        }else{
							if(cap.Client_Avail__r.CA_Rate_Card__c == null)
								caMap.put(cap.Client_Avail__c,new Client_Avail__c(Id=cap.Client_Avail__c,CA_Rate_Card__c = cap.CAP_Rate_Card__c,Pricing__c = null));
						}
                            
                    }
                        
                    
                }
            }
        }   
        
        
        
        
        
        if(caMap != Null && caMap.size()>0 && updateCA){
            
            List<Client_Avail__c> caUpdateList = caMap.values();
            WB_ClientAvailPriceHandler.recursiveUpdate = true;
            Database.SaveResult[] updateResult = Database.update(caUpdateList,false);
            
            for(Integer index = 0; index < updateResult.size();index++){
                
                Database.SaveResult result = updateResult[index];
                if(!result.isSuccess()){
                    system.debug(LoggingLevel.INFO,'Error CA:'+caUpdateList[index].id);
                    String errorMessage = '';
                    for(Database.Error err : result.getErrors()) {
                        errorMessage += err.getMessage();
                    }
                    system.debug(LoggingLevel.INFO,'Error Messages:'+errorMessage);
                }
            }
        }
        
        if(capUpdateList != Null && capUpdateList.size()>0 && updateCAP){
            
            WB_ClientAvailPriceHandler.recursiveUpdate = true;
            Database.SaveResult[] updateResult = Database.update(capUpdateList,false);
            
            for(Integer index = 0; index < updateResult.size();index++){
                
                Database.SaveResult result = updateResult[index];
                if(!result.isSuccess()){
                    system.debug(LoggingLevel.INFO,'Error CAP:'+capUpdateList[index].id);
                    String errorMessage = '';
                    for(Database.Error err : result.getErrors()) {
                        errorMessage += err.getMessage();
                    }
                    system.debug(LoggingLevel.INFO,'Error Messages:'+errorMessage);
                }
            }
            
        }
        
        if(pbepUpdateList != null && pbepUpdateList.size() > 0){
          Database.SaveResult[] updateResult = Database.update(pbepUpdateList,false);
            
            for(Integer index = 0; index < updateResult.size();index++){
                
                Database.SaveResult result = updateResult[index];
                if(!result.isSuccess()){
                    system.debug(LoggingLevel.INFO,'Error CAP:'+pbepUpdateList[index].id);
                    String errorMessage = '';
                    for(Database.Error err : result.getErrors()) {
                        errorMessage += err.getMessage();
                    }
                    system.debug(LoggingLevel.INFO,'Error Messages:'+errorMessage);
                }
            }  
        }
        
        if(tobeConvertedCAPs != Null && tobeConvertedCAPs.size()>0){
            WB_PBEP_Product_CreationHandler wb = new WB_PBEP_Product_CreationHandler();
            wb.insertOrUpdatePriceBookEntryPeriod(tobeConvertedCAPs);
        }
    }
    
    public static Map<String,Rate_Card__c> assignRateCardToCAP(List<Client_Avail_Price__c> capList){
      List<WB_RateCardHelper.PriceKeyWrapper> wrapperList = new List<WB_RateCardHelper.PriceKeyWrapper>();      
      for(Client_Avail_Price__c cap:capList){
        WB_RateCardHelper.PriceKeyWrapper wrapper = new WB_RateCardHelper.PriceKeyWrapper();
        wrapper.accountName = cap.Account__c;
        wrapper.countryName = cap.Country__c;
        wrapper.channel = cap.Client_Avail_Channel__c;
        wrapper.format = cap.Client_Avail_Format__c;
        wrapper.contentType = cap.Title_Content_Type__c;
        if(cap.Price_Tier__c != Null && cap.Price_Tier__c != '' && cap.Price_Tier__c != 'TBD'){
          wrapper.priceTier = cap.Price_Tier__c;
        }else if(cap.Price__c != Null){
          wrapper.wsp = cap.Price__c;
        }
        wrapperList.add(wrapper);
      
      //Episode Changes
      if(cap.Title_Content_Type__c == 'Season'){
        WB_RateCardHelper.PriceKeyWrapper epWrapper = wrapper.clone();
        epWrapper.contentType = 'Episode';
        if(cap.Episode_Price_Tier__c != Null && cap.Episode_Price_Tier__c != '' && cap.Episode_Price_Tier__c != 'TBD'){
          epWrapper.priceTier = cap.Episode_Price_Tier__c;
          epWrapper.wsp = Null;
        }else if(cap.Episode_Price__c != Null){
          if(cap.Episode_Price__c.scale() <2){
                        cap.Episode_Price__c = cap.Episode_Price__c.setScale(2);
                    }
          epWrapper.wsp = cap.Episode_Price__c;
          epWrapper.priceTier = Null;
        }
        wrapperList.add(epWrapper);
      }
      }
      
      Map<String,List<Rate_Card__c>> rcMap = WB_RateCardHelper.getRateCard(wrapperList,true,true);
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
        if(cap.CAP_CRM_Country__c && rcMap != null && rcMap.size() > 0 && rcMap.get(rcKey) != null){
          List<Rate_Card__c> capRCs = rcMap.get(rcKey);
        
          Boolean assigned = false;
          Rate_Card__c alternateRC = null;
          for(Rate_Card__c capRC:capRCs){
            if(cap.Effective_Date__c >= capRC.Start_Date__c && cap.Effective_Date__c <= capRC.End_Date__c){
                    cap.CAP_Rate_Card__c = capRC.Id;
                    capIdRCMap.put(cap.Id,capRC);
                    assigned = true;
                    break;
            }else if(cap.Effective_Date__c < capRC.Start_Date__c && cap.Expiry_Date__c >= capRC.Start_Date__c && cap.Expiry_Date__c <= capRC.End_Date__c){
              alternateRC = capRC;
            }
          }
          
          if(assigned == false && alternateRC != null){
            cap.CAP_Rate_Card__c = alternateRC.Id;
                capIdRCMap.put(cap.Id,alternateRC);
          }
        
        //Episode changes
        if(cap.Title_Content_Type__c == 'Season' && rcMap.get(ecEpKey) != null){
          List<Rate_Card__c> capEpRCs = rcMap.get(ecEpKey);
        
          Boolean assignedEp = false;
          Rate_Card__c alternateEpRC = null;
          for(Rate_Card__c capRC:capEpRCs){
            if(cap.Effective_Date__c >= capRC.Start_Date__c && cap.Effective_Date__c <= capRC.End_Date__c){
              cap.Episode_Rate_Card__c = capRC.Id;
              assignedEp = true;
              break;
            }else if(cap.Effective_Date__c < capRC.Start_Date__c && cap.Expiry_Date__c >= capRC.Start_Date__c && cap.Expiry_Date__c <= capRC.End_Date__c){
              alternateEpRC = capRC;
            }
          }
          
          if(assigned == false && alternateEpRC != null){
            cap.Episode_Rate_Card__c = alternateEpRC.Id;
            
          }
          
        }
        }
      }
      
      return capIdRCMap;
    }
    
    
    global void finish(Database.BatchableContext BC){
    }

}