public class WB_PriceUtility {
  
  
     
  public static String getRecordTypeId(Schema.SObjectType objectName,String recordTypeName){
    Schema.DescribeSObjectResult describeResult = objectName.getDescribe();
    Map<String,Schema.RecordTypeInfo> rtMapByName = describeResult.getRecordTypeInfosByName();
    Schema.RecordTypeInfo rtByName =  rtMapByName.get(recordTypeName);
    
    if(rtByName == null) 
      return null;
    
    return rtByName.getRecordTypeId();
  }
    
    public static Set<String> getPicklistValues(Schema.SObjectType objectName, String fieldName) {
      Set<String> pickListValues = new Set<String>(); //new list for holding all of the picklist options
      Schema.DescribeSObjectResult sobjectDescribe = objectName.getDescribe(); //describe the sobject
      Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap(); //get a map of fields for the passed sobject
      List<Schema.PicklistEntry> pickListValueEntries = fieldMap.get(fieldName).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
      for (Schema.PicklistEntry plvEntry : pickListValueEntries) { //for all values in the picklist list
            pickListValues.add(plvEntry.getValue().toUpperCase()); //add the value and label to our final list
      }
      return pickListValues; //return the List
  }
  
  public static Set<String> getCAPCategoryPicklistValues(){
    return getPicklistValues(Client_Avail_Price__c.getSobjectType(),'Category__c');
  }
  
  public static Set<String> getAnnouncementOverridePicklistValues(){
    return getPicklistValues(Client_Avail__c.getSobjectType(),'Announce_Override__c');
  }
  
  public static Set<String> getCAStatusPicklistValues(){
    return getPicklistValues(Client_Avail__c.getSobjectType(),'Status__c');
  } 
  
    public static Map<String,Integer> getCountryOffset(){
      Map<String,Integer> countryOffsetMap = new Map<String,Integer>();
    List<Country_SID_Key__c> localeSIDKeyList = Country_SID_Key__c.getAll().values();
    DateTime gmtDateTime = System.now(); 
    
    for(Country_SID_Key__c sidKey:localeSIDKeyList){
      Timezone  timeZoneInstance = Timezone.getTimeZone(sidKey.Locale_SID_Key__c);
      Integer minutes = 0;
      if(timeZoneInstance == null){
        minutes = 0;
      }else{
        Integer offsetMilliSeconds = timeZoneInstance.getOffset(gmtDateTime);
        minutes = (offsetMilliSeconds/1000)/60;
      }
      countryOffsetMap.put(sidKey.Country_Code__c,minutes);
    }
          
      return  countryOffsetMap;
    }
    
    public static Boolean isCurrentPrice(Client_Avail_Price__c capRecord,String countryCode,Map<String,Integer> countryOffsetMap,DateTime currentTime){
      if(countryCode == null)
        countryCode = 'America/Los_Angeles';
      DateTime capCountryTime = currentTime.addMinutes(countryOffsetMap.get(countryCode));
      Date newDate = Date.newInstance(capCountryTime.yearGmt(),capCountryTime.monthGmt(),capCountryTime.dayGmt());
      if(newDate >= capRecord.Effective_Date__c && newDate <= capRecord.Expiry_Date__c)
        return true;
      
      return false;  
    }
    
    public static Client_Avail_Price__c getCurrentPrice(List<Client_Avail_Price__c> capRecordList,String countryCode,Map<String,Integer> countryOffsetMap,DateTime currentTime){
      
      for(Client_Avail_Price__c capRecord:capRecordList){
        if(isCurrentPrice(capRecord,countryCode,countryOffsetMap,currentTime)){
          return capRecord;
        }
      }
      return null;  
    }
    
    public static Client_Avail_Price__c getNextPrice(Client_Avail_Price__c currentPrice,List<Client_Avail_Price__c> capRecordList){
      for(Client_Avail_Price__c capRecord:capRecordList){
          if(currentPrice != null && currentPrice.Expiry_Date__c != null){
            if(capRecord.Effective_Date__c == currentPrice.Expiry_Date__c.addDays(1)){
              return capRecord;
            }
          }
      }
      return null;
    }
    
    public static Client_Avail_Price__c getPreviousPrice(Client_Avail_Price__c changedCapRecord,List<Client_Avail_Price__c> capRecordList){
      
      Client_Avail_Price__c prevRecord = null;
      for(Client_Avail_Price__c capRecord:capRecordList){
          if(capRecord.Id == changedCapRecord.Id){
             return prevRecord;
          }
          prevRecord = capRecord;
      }
      return null;
    }
    
    /*
    public static Client_Avail_Price__c getPreviousPriceOfDeleted(Client_Avail_Price__c changedCapRecord,List<Client_Avail_Price__c> capRecordList){
      for(Client_Avail_Price__c capRecord:capRecordList){
        Date deleCapEffDate = changedCapRecord.Effective_Date__c;
          if(capRecord.Expiry_Date__c == deleCapEffDate.addDays(-1)){
             return capRecord;
          }
      }
      return null;
    }
    
    
    public static Client_Avail_Price__c getCurrentCAPByStartDate(Client_Avail__c caRecord){
      for(Client_Avail_Price__c capRecord:caRecord.Client_Avail_Prices__r){
        if(caRecord.Price_Start__c == null){
          if(caRecord.Start_Date__c == capRecord.Effective_Date__c)
            return capRecord;
        }else{
          if(caRecord.Price_Start__c == capRecord.Effective_Date__c)
            return capRecord;
        }
      }
      return null;
    }
    */
    
    public static Boolean isCAPPriceSame(Client_Avail_Price__c capRecord1,Client_Avail_Price__c capRecord2){
      if(capRecord1.Price__c == capRecord2.Price__c && capRecord1.Price_Tier__c == capRecord2.Price_Tier__c && 
        capRecord1.Episode_Price__c == capRecord2.Episode_Price__c && capRecord1.Episode_Price_Tier__c == capRecord2.Episode_Price_Tier__c)
         //&&  capRecord1.SR_Price__c == capRecord2.SR_Price__c && capRecord1.SR_Per_Episode__c == capRecord2.SR_Per_Episode__c)
        return true;
         
      return false;
    }
    
    public static Boolean isPriceSame(Client_Avail__c caRecord,Client_Avail_Price__c capRecord){
      
      if(caRecord.Price__c == capRecord.Price__c && caRecord.Price_Tier_Text__c == capRecord.Price_Tier__c && 
        caRecord.Episode_Price__c == capRecord.Episode_Price__c && caRecord.Episode_Price_Tier__c == capRecord.Episode_Price_Tier__c) 
          //&&  caRecord.SR_Price__c == capRecord.SR_Price__c && caRecord.SR_Per_Episode__c == capRecord.SR_Per_Episode__c)
        return true;
        
      return false;
    }
    
    public static Client_Avail_Price__c createFirstCAP(Client_Avail__c clientAvail,String recTypeId){
      
      Client_Avail_Price__c capRecord = new Client_Avail_Price__c();
      capRecord.Client_Avail__c = clientAvail.Id;
      capRecord.Pricing__c = clientAvail.Pricing__c;
      capRecord.Price__c = clientAvail.Price__c;
      capRecord.Price_Tier__c = clientAvail.Price_Tier_Text__c;
      capRecord.Effective_Date__c = clientAvail.Start_Date__c;
      capRecord.Expiry_Date__c = clientAvail.End_Date__c;
      capRecord.Episode_Price__c = clientAvail.Episode_Price__c;
      capRecord.Episode_Price_Tier__c = clientAvail.Episode_Price_Tier__c;
      if(clientAvail.Title_Content_Type__c == WB_PriceUtility.SEASON){
        
        if(clientAvail.Episode_Price__c == null && clientAvail.Episode_Price_Tier__c == null){
            capRecord.Episode_Price_Tier__c = PRICE_TIER_TBD;  
        }else if(clientAvail.Episode_Price_Tier__c != Null){
            capRecord.Episode_Pricing__c = ClientAvail.Episode_Pricing__c;
        }
        
      }
      capRecord.Title__c = clientAvail.Title__c;
  //  capRecord.SR_Price__c = clientAvail.SR_Price__c;
  //  capRecord.SR_Per_Episode__c = clientAvail.SR_Per_Episode__c;
      capRecord.Category__c = clientAvail.Local_Data_Category_Picklist__c;
      capRecord.Price_Code__c = clientAvail.New_Price_Code__c;
      capRecord.Type__c = FIRST;
      capRecord.RecordTypeId = recTypeId;
      
      capRecord.CurrencyIsoCode = clientAvail.CurrencyIsoCode;
      
      capRecord.CAP_Rate_Card__c = clientAvail.CA_Rate_Card__c;
      capRecord.Episode_Rate_Card__c = clientAvail.Episode_Rate_Card__c;
      return capRecord; 
    }
    
    
    //PreOrder CAP changes modified by Tejasvini
    public static Client_Avail_Price__c createPreOrderCAP(Client_Avail__c clientAvail,String recTypeId,Client_Avail_Price__c firstCap){
      
      Client_Avail_Price__c capRecord = createFirstCAP(clientAvail,recTypeId);
      capRecord.Effective_Date__c = clientAvail.APO_Date__c;
      capRecord.Expiry_Date__c = clientAvail.Start_Date__c - 1;
      capRecord.Type__c = PREORDER;
      if(firstCap != null){
        capRecord.Pricing__c = firstCap.Pricing__c;
        capRecord.Price__c = firstCap.Price__c;
        capRecord.Price_Tier__c = firstCap.Price_Tier__c;
        capRecord.Episode_Price__c = firstCap.Episode_Price__c;
        capRecord.Episode_Price_Tier__c = firstCap.Episode_Price_Tier__c;
        capRecord.Price_Code__c = firstCap.Price_Code__c;
      }
      
      return capRecord;
      
    }
    
    public static Client_Avail_Price__c createEpisodeCAP(Client_Avail_Price__c seasonCAP,Client_Avail__c episodeCA,String recTypeId){
      
      Client_Avail_Price__c episodeCAP = new Client_Avail_Price__c();
      episodeCAP.Client_Avail__c = episodeCA.Id;
      episodeCAP.RecordTypeId = recTypeId;
      episodeCAP.CurrencyIsoCode = episodeCA.CurrencyIsoCode;
      
      if(seasonCAP.Effective_Date__c < episodeCA.Start_Date__c){
       episodeCAP.Effective_Date__c = episodeCA.Start_Date__c;
     }else{
        episodeCAP.Effective_Date__c = seasonCAP.Effective_Date__c;
     }
     
     if(seasonCAP.Announce_Override__c != null){
          episodeCAP.Announce_Override__c = seasonCAP.Announce_Override__c;
        }
        episodeCAP.Category__c = seasonCAP.Category__c;
        
      episodeCAP.Price__c = seasonCAP.Episode_Price__c;
      episodeCAP.Price_Tier__c = seasonCAP.Episode_Price_Tier__c;
      episodeCAP.Title__c = episodeCA.Title__c;
      
      if(seasonCAP.CAP_CRM_Country__c){
          episodeCAP.CAP_Rate_Card__c = seasonCAP.Episode_Rate_Card__c;
          episodeCAP.Pricing__c = Null;
          episodeCAP.Episode_Rate_Card__c = Null;
      }else{
          episodeCAP.Pricing__c = seasonCAP.Episode_Pricing__c;
          episodeCAP.Episode_Rate_Card__c = Null;
      }
      
      //episodeCAP.CAP_Rate_Card__c = seasonCAP.Episode_Rate_Card__c;
      
      return episodeCAP;
    }
    
	public static Client_Avail_Price__c updateEpisodeCAP(Client_Avail_Price__c seasonCAP,Client_Avail__c episodeCA,Client_Avail_Price__c episodeCAP){
      
     if(seasonCAP.Effective_Date__c < episodeCA.Start_Date__c){
       episodeCAP.Effective_Date__c = episodeCA.Start_Date__c;
     }else{
        episodeCAP.Effective_Date__c = seasonCAP.Effective_Date__c;
     }
      if(episodeCA.Lock_Pricing_Update__c == false){
        episodeCAP.Price__c = seasonCAP.Episode_Price__c;
        episodeCAP.Price_Tier__c = seasonCAP.Episode_Price_Tier__c;
          
      }
        
        if(seasonCAP.Announce_Override__c != null){
          episodeCAP.Announce_Override__c = seasonCAP.Announce_Override__c;
        }
        
      //episodeCAP.Category__c = seasonCAP.Category__c;
     
     //ER-000639 - start
      if(!episodeCAP.Category__c.contains('Day After') ||
        (episodeCAP.Category__c.contains('Day After') && (episodeCA.Local_Title__r.Local_TV_Air_Date__c == null || episodeCA.Local_Title__r.Local_TV_Air_Date__c > system.today()))){
        episodeCAP.Category__c = seasonCAP.Category__c;
    }
    //ER-000639 - end
       
    return episodeCAP;
        
    }
    
    /*public static Boolean setStatusToEpisodeCAP(Client_Avail_Price__c seasonCAP,Client_Avail__c episodeCA,Client_Avail_Price__c episodeCAP){
      if(seasonCAP.Client_Avail_Status__c == 'Confirmed' || seasonCAP.Client_Avail_Status__c == 'Tentative')
        {
           if(episodeCA.Start_Date__c != episodeCA.End_Date__c){
               episodeCAP.Client_Avail_Status__c = seasonCAP.Client_Avail_Status__c;
               return true;
           }
        }else{
            episodeCAP.Client_Avail_Status__c = seasonCAP.Client_Avail_Status__c;
            return true;
        }
        return false;
    }*/
        /*
        if(clientAvail.Start_Date__C > seasonAvail.End_Date__C)
        {
            clientAvail.Start_Date__C = seasonAvail.End_Date__C;
            if(clientAvail.Status__c != 'Draft') // Do not update the status to cancelled if the previous status was in Draft.
                clientAvail.Status__c = 'Cancelled';
        }
                       
        if(seasonCAP.Client_Avail_Status__c == 'Draft' || episodeCA.Start_Date__c != episodeCA.End_Date__c){
          episodeCAP.Client_Avail_Status__c = seasonCAP.Client_Avail_Status__c;
        }
        */   
    
    public static Client_Avail_Price__c getExistingEpisodeCAP(Client_Avail_Price__c seasonCAPOld,Client_Avail__c episodeCA){
      for(Client_Avail_Price__c episodeCAP:episodeCA.Client_Avail_Prices__r){
        if(seasonCAPOld.Effective_Date__c == episodeCAP.Effective_Date__c){// &&  ((episodeCAP.Price__c != null && seasonCAPOld.Episode_Price__c == episodeCAP.Price__c) || (episodeCAP.Price_Tier__c != null && seasonCAPOld.Episode_Price_Tier__c == episodeCAP.Price_Tier__c))){
          return episodeCAP;
        }
      }
      
      return null;
    }
	
    public static Boolean isValidData(Client_Avail_Price__c newCapRecord,Client_Avail_Price__c oldCapRecord,Set<String> picklistValues,String operation){
    
    if(WB_PriceUtility.SKIP_VALIDATION){
        return true;
      }
      
    if(newCapRecord.Effective_Date__c == null){
            newCapRecord.addError(EFF_DATE_REQ_ERROR);
            return false;
        }
        
        if(operation == INSERT_OP && newCapRecord.Effective_Date__c < System.today()){
      newCapRecord.addError(PRICE_DATE_PAST);
      return false;
    }
      
        if(!picklistValues.contains(newCapRecord.Category__c.toUpperCase())){
          newCapRecord.addError(INVALID_CATEGORY_ERROR);
            return false;
        }
        
        if(newCapRecord.Price__c != null && newCapRecord.Price_Tier__c != null){
            newCapRecord.addError(PR_PRT_MX_ERROR);
            return false;
        }else if(newCapRecord.Price__c == null && newCapRecord.Price_Tier__c == null){
          //Price Code should be there
          if(newCapRecord.Price_Code__c == null){
            newCapRecord.addError(PRC_CODE_OR_PRICE);
              return false;
          }
        }else if(operation == INSERT_OP ||(operation == UPDATE_OP && (newCapRecord.Price__c != oldCapRecord.Price__c || newCapRecord.Price_Tier__c != oldCapRecord.Price_Tier__c || newCapRecord.Price_Code__c != oldCapRecord.Price_Code__c))){
          //Either WSP or Tier Present. Price Code should not be there for insert. for update it is fine, unless none of these are modified.
          if(newCapRecord.Price_Code__c != null){
            newCapRecord.addError(PRC_CODE_OR_PRICE);
              return false;
          }
        }
        
        if(newCapRecord.Episode_Price__c != null && newCapRecord.Episode_Price_Tier__c != null){
            newCapRecord.addError(EPR_EPRT_MX_ERROR);
            return false;
        }else if(newCapRecord.Episode_Price__c == null && newCapRecord.Episode_Price_Tier__c == null){
          //For Season. Price Code should be there
          if(newCapRecord.Title_Content_Type__c == WB_PriceUtility.SEASON && newCapRecord.Price_Code__c == null){
            newCapRecord.addError(PRC_CODE_OR_EPRICE);
              return false;
          }
        }else if(operation == INSERT_OP ||(operation == UPDATE_OP && (newCapRecord.Episode_Price__c != oldCapRecord.Episode_Price__c || newCapRecord.Episode_Price_Tier__c != oldCapRecord.Episode_Price_Tier__c || newCapRecord.Price_Code__c != oldCapRecord.Price_Code__c))){
          //For Season. Either E.WSP or E.Tier Present. Price Code should not be there for insert. for update it is fine, unless none of these are modified.
          if(newCapRecord.Title_Content_Type__c == WB_PriceUtility.SEASON && newCapRecord.Price_Code__c != null){
            newCapRecord.addError(PRC_CODE_OR_EPRICE);
              return false;
          }
        }
        
        return true;
    }
    
    /*
    public static void assignPriceCodeByPriceTier(List<Client_Avail_Price__c> capRecordList,Map<Id,Client_Avail__c> clientAvailMap){
      
      Map<Id,Map<String,Map<String,Map<String,Map<String,Map<String,Pricing__c>>>>>> mapPricingRecords = WB_Update_Price_Tier_Handler.getPricingRecords(clientAvailMap.values());
      
      for(Client_Avail_Price__c capRecord:capRecordList){
        if(capRecord.Price__c != null){
              continue;
            }
            
           Client_Avail__c clientAvail = clientAvailMap.get(capRecord.Client_Avail__c);
        try{
        Map<String,Pricing__c> allPriceTiers = mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c).get(clientAvail.Release_Plan_Channel__c).get(clientAvail.Title_Content_Type__c); //.get(mapClientAvail.get(clientAvail.id).Local_Title__r.Price_Code__c);
            for(Pricing__c pricingRecord : allPriceTiers.values()){
                if(pricingRecord != null && capRecord.Price_Tier__c == pricingRecord.Price_Tier__c && (capRecord.Episode_Price__c != null || capRecord.Episode_Price_Tier__c == pricingRecord.Episode_Price_Tier__c)){
                    capRecord.Pricing__c = pricingRecord.Id;
                    capRecord.Price_Code__c = pricingRecord.Name;
                    break;
                }
            }
      }catch(Exception ex){ }      
      }
    }
    */
    
    
    //public static Boolean isPriceTierPresent(Client_Avail_Price__c capRecord,Map<Id,Map<String,Map<String,Map<String,Map<String,Map<String,Pricing__c>>>>>> mapPricingRecords,Client_Avail__c clientAvail){
    public static Boolean isPriceTierPresent(Client_Avail_Price__c capRecord,Map<Id,Map<String,Map<String,Map<String,Map<String,Map<String,Pricing__c>>>>>> mapPricingRecords,Client_Avail__c clientAvail){
      Boolean isPriceFound = false;
      try{
        
        if(capRecord.Price__c != null){
          if(clientAvail.Title_Content_Type__c != SEASON){
            return true;
          }else{
            if(capRecord.Episode_Price__c != null){
              return true;
            }else{
                if(capRecord.CAP_CRM_Country__c){
                    if(capRecord.CAP_Rate_Card__c != null)
                        return true;
                }else{
                  Map<String,Pricing__c> allPriceTiers = mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c).get(clientAvail.Release_Plan_Channel__c).get(EPISODE); 
                    for(Pricing__c pricingRecord : allPriceTiers.values()){
                        if(pricingRecord != null){
                          if(capRecord.Episode_Price_Tier__c == pricingRecord.Price_Tier__c){
                              return true;
                            }
                        }
                    }
                }
              return false;
            }
          }
        }else if(capRecord.Price_Tier__c != null){
          if(capRecord.CAP_CRM_Country__c){
                if(capRecord.CAP_Rate_Card__c != null)
                    return true;
          }else{
            Map<String,Pricing__c> allPriceTiers = mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c).get(clientAvail.Release_Plan_Channel__c).get(clientAvail.Title_Content_Type__c); 
            for(Pricing__c pricingRecord : allPriceTiers.values()){
                if(pricingRecord != null){
                    if(clientAvail.Title_Content_Type__c != SEASON){
                      if(capRecord.Price_Tier__c == pricingRecord.Price_Tier__c){
                        isPriceFound = true;
                        break;
                      }
                    }else{
                      if(capRecord.Price_Tier__c == pricingRecord.Price_Tier__c){
                        if(capRecord.Episode_Price__c != null){
                          isPriceFound = true;
                          break;
                        }else if(capRecord.Episode_Price_Tier__c == pricingRecord.Episode_Price_Tier__c){
                          isPriceFound = true;
                          break;
                        }
                      }
                    }
                }
            }//end for
          }//end else
        }
    }catch(Exception ex){ }
    
    return isPriceFound;
    } 
    
    public static void checkPriceMatch(List<Client_Avail_Price__c> capRecordList,Map<Id,Client_Avail_Price__c> oldClientAvailPriceMap,Map<Id,Client_Avail_Price__c> capAnnouncementMap,String operation){
      
      if(WB_PriceUtility.SKIP_PRICE_VALIDATION){
        return;
      }
      
      Boolean skipannounceValidation = false;
      String userId = UserInfo.getUserId();
      WB_Pricing_Settings__c pricingSetting = WB_Pricing_Settings__c.getInstance(userId.substring(0,15));
      if(pricingSetting != null && pricingSetting.SkipAnnounceValidation__c == true){
        skipannounceValidation = true;
      }else{
        String profileId = UserInfo.getProfileId();
        pricingSetting = WB_Pricing_Settings__c.getInstance(profileId.substring(0,15));
        if(pricingSetting != null && pricingSetting.SkipAnnounceValidation__c == true)
          skipannounceValidation = true;
      }
     
      DateTime currentTime = System.now();
      Map<String,Integer> countryOffsetMap = WB_PriceUtility.getCountryOffset();
      
      List<String> clientAvailIdList = new List<String>();
      Set<String> priceCodeSet = new Set<String>();
      
      for(Client_Avail_Price__c capRecord:capRecordList){
          clientAvailIdList.add(capRecord.Client_Avail__c);
          priceCodeSet.add(capRecord.Price_Code__c);
        }
        
      Map<Id,Client_Avail__c> clientAvailMap = new Map<Id,Client_Avail__c>([Select Id,Name,Status__c,Commercial_Avail__c,Commercial_Avail__r.Local_Title__r.Price_Code__c,
                  Client__c,Release_Plan_Country__c,Release_Plan_Channel__c,Release_Plan_Format__c,Title_Content_Type__c from Client_Avail__c where Id in:clientAvailIdList]);
      
        List<Pricing__c> pricingRecordList = [Select id,Name,Account__c,Channel__c,Format__c,Content_Type__c,Country__c,Country__r.Name,Effective_Date__c,Episode_Price__c,Episode_Price_Tier__c,Price_Tier__c,SR_Per_Episode__c,SR_Price__c,WS_Price__c,Price_Code_Status__c
                                  from Pricing__c where Name in :priceCodeSet];
       Map<Id,Map<String,Map<String,Map<String,Map<String,Map<String,Pricing__c>>>>>> mapPricingRecords = WB_Update_Price_Tier_Handler.getPricingRecords(clientAvailMap.values());
        
        List<Client_Avail_Price__c> rcCAPList = new List<Client_Avail_Price__c>();
        for(Client_Avail_Price__c capRecord:capRecordList){
          Client_Avail__c clientAvail = clientAvailMap.get(capRecord.Client_Avail__c);
          
          /*SINC0916133 - start*/
          //Logic to allow Invalid price tier update - start
          if(operation == UPDATE_OP && !WB_PriceUtility.PLAY_LIST_UPDATE && capAnnouncementMap != null && !skipannounceValidation){
            Client_Avail_Price__c oldCapRecord = oldClientAvailPriceMap.get(capRecord.Id);
            List<Announcement_Record__c> annRecord = capAnnouncementMap.get(capRecord.Id).Announcement_Records__r;
            if(annRecord.size() > 0 && annRecord[0].Client_Start__c <= System.today()){
              if(oldCapRecord.Price_Tier__c != WB_PriceUtility.PRICE_TIER_TBD && oldCapRecord.Price_Tier__c != WB_PriceUtility.PRICE_TIER_NA){
                
                Boolean ispriceTierPresent = false;
                if(oldCapRecord.Price_Tier__c != capRecord.Price_Tier__c || oldCapRecord.Price__c != capRecord.Price__c || 
                  oldCapRecord.Episode_Price_Tier__c != capRecord.Episode_Price_Tier__c || oldCapRecord.Episode_Price__c != capRecord.Episode_Price__c){
                  ispriceTierPresent = isPriceTierPresent(oldCapRecord,mapPricingRecords,clientAvail);
                }
                if(oldCapRecord.Effective_Date__c != capRecord.Effective_Date__c || oldCapRecord.Price_Code__c != capRecord.Price_Code__c || ispriceTierPresent){
                    capRecord.addError(WB_PriceUtility.ANNOUN_START_DT_PAST);
                    continue;
                  }
              }
              }
          }
            //Logic to allow Invalid price tier update - end
            /*SINC0916133 - End*/
            
            
              Boolean isError = false;
            if(capRecord.Price__c != null){
             //capRecord.CAP_Rate_Card__c = null;
             
             if(capRecord.Pricing__c != null && capRecord.Price_Code__c == null)    
                capRecord.Pricing__c = null;
             
            }
            
            if(capRecord.Episode_Price__c != null){
             
             if(capRecord.Episode_Pricing__c != null && capRecord.Price_Code__c == null)    
                capRecord.Episode_Pricing__c = null;
             
            }
            
            Boolean isPriceFound = false;
            Boolean isEpisodePriceFound = false;
            String errorMsg;
            if(capRecord.Price_Code__c != null && (operation == INSERT_OP || (operation == UPDATE_OP && capRecord.Price__c == null && capRecord.Price_Tier__c == null))){
              for(Pricing__c price:pricingRecordList){
                    if(capRecord.Price_Code__c == price.Name && price.Price_Code_Status__c == 'Active'){
                      if(price.Account__c == clientAvail.Client__c && price.Channel__c == clientAvail.Release_Plan_Channel__c && price.Format__c == clientAvail.Release_Plan_Format__c 
                            && price.Country__r.Name == clientAvail.Release_Plan_Country__c && price.Content_Type__c == clientAvail.Title_Content_Type__c){
                            isPriceFound = true; 
                            capRecord.Pricing__c = price.Id;
                            capRecord.Price__c = price.WS_Price__c ;
                            capRecord.Price_Tier__c = price.Price_Tier__c ;
                            if(clientAvail.Title_Content_Type__c == SEASON){
                                Pricing__c episodePrice = WB_CreateClientAvail_Controller.fetchEpisodePricing(price,pricingRecordList);
                                if(episodePrice != Null){
                                    capRecord.Episode_Pricing__c = episodePrice.Id;
                                    capRecord.Episode_Price__c = episodePrice.WS_Price__c ;
                                    capRecord.Episode_Price_Tier__c = episodePrice.Price_Tier__c ;
                                    isEpisodePriceFound = true;
                                }else
                                    isEpisodePriceFound = false;
                            }else{
                                capRecord.Episode_Price__c = null;
                                capRecord.Episode_Price_Tier__c = null;
                            }
                            break;
                        }
                    }
                }
              
                if(!isPriceFound){ /* & (clientAvail.Title_Content_Type__c == FEATURE || clientAvail.Title_Content_Type__c == SEASON))*/
                    errorMsg = '1.'+PRICE_RECORD_NOT_AVLB+'\n';
                    capRecord.addError(PRICE_RECORD_NOT_AVLB);
                    isError = true;
                }
                if(!isEpisodePriceFound && clientAvail.Title_Content_Type__c == SEASON){
                    if(!isError){
                       capRecord.addError('No match found for the given Episode Price Tier in the Pricing table.');
                       isError = true; 
                    }else{
                        errorMsg = errorMsg + '2. No match found for the given Episode Price Tier in the Pricing table.';
                        capRecord.addError(errorMsg);
                    }
                    
                }
                  
                if(!isError && capRecord.CAP_CRM_Country__c && (capRecord.Price_Tier__c != null || capRecord.Price__c != Null)){
                    rcCAPList.add(capRecord);
                }
                
            }else if(capRecord.Price_Tier__c != null && (operation == INSERT_OP || (operation == UPDATE_OP && oldClientAvailPriceMap.get(capRecord.Id).Price_Tier__c != capRecord.Price_Tier__c))){
            
              try{
                Map<String,Pricing__c> allPriceTiers = mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c).get(clientAvail.Release_Plan_Channel__c).get(clientAvail.Title_Content_Type__c); //.get(mapClientAvail.get(clientAvail.id).Local_Title__r.Price_Code__c);
                    for(Pricing__c pricingRecord : allPriceTiers.values()){
                        if(pricingRecord != null && (pricingRecord.Price_Code_Status__c == 'Active' || pricingRecord.Price_Code_Status__c == 'Validation Only')){
                            if(capRecord.Price_Tier__c == pricingRecord.Price_Tier__c){
                                isPriceFound = true;
                                capRecord.Pricing__c = pricingRecord.Id;
                                break;
                            }
                            
                        }
                    }
              }catch(Exception ex){ }
                                  
                  if(clientAvail.Title_Content_Type__c <> SEASON){
                      capRecord.Episode_Price__c = null;
                      capRecord.Episode_Price_Tier__c = null;
                      capRecord.SR_Per_Episode__c = null;
                  }
                  
                  if(!capRecord.CAP_CRM_Country__c){
                     if(!isPriceFound && (clientAvail.Title_Content_Type__c == FEATURE || clientAvail.Title_Content_Type__c == SEASON || clientAvail.Title_Content_Type__c == 'Collection Features'||clientAvail.Title_Content_Type__c == 'Episode')){
                        errorMsg = '1. '+PRICE_TIER_NOT_MATCHING+'\n';
                        capRecord.addError(PRICE_TIER_NOT_MATCHING);
                        isError = true;
                     }
                     
                  }else if(capRecord.CAP_CRM_Country__c && capRecord.Price_Tier__c != null){
                    rcCAPList.add(capRecord);
                  }
                  
            }else if(capRecord.Price__c != Null && capRecord.CAP_CRM_Country__c && (operation == INSERT_OP || (operation == UPDATE_OP && (oldClientAvailPriceMap.get(capRecord.Id).Price__c != capRecord.Price__c || oldClientAvailPriceMap.get(capRecord.Id).Episode_Price__c != capRecord.Episode_Price__c)))){
                
                rcCAPList.add(capRecord);
            }
            
            //Episode changes
            if(capRecord.Price_Code__c == Null && capRecord.Episode_Price_Tier__c != Null && (operation == INSERT_OP || (operation == UPDATE_OP && oldClientAvailPriceMap.get(capRecord.Id).Episode_Price_Tier__c != capRecord.Episode_Price_Tier__c))){
                try{
                    Map<String,Pricing__c> allPriceTiers = mapPricingRecords.get(clientAvail.Client__c).get(clientAvail.Release_Plan_Country__c).get(clientAvail.Release_Plan_Format__c).get(clientAvail.Release_Plan_Channel__c).get('Episode');
                    for(Pricing__c episodePricingRec : allPriceTiers.values()){
                        if(episodePricingRec != Null && (episodePricingRec.Price_Tier__c != Null && episodePricingRec.Price_Tier__c != '') && (capRecord.Episode_Price_Tier__c == episodePricingRec.Price_Tier__c) && (episodePricingRec.Price_Code_Status__c == 'Active' || episodePricingRec.Price_Code_Status__c == 'Validation Only')){
                            isEpisodePriceFound = true;
                            capRecord.Episode_Pricing__c = episodePricingRec.Id;
                            break;
                        }
                    }
                   
                }catch(Exception e){}
                if(!capRecord.CAP_CRM_Country__c){
                    if(!isEpisodePriceFound && (clientAvail.Title_Content_Type__c == SEASON )){
                        if(!isError){
                            capRecord.addError('Episode Price Tier pricing not found in Pricing table.');
                            isError = true;
                        }else{
                            errorMsg = errorMsg + '2. Episode Price Tier pricing not found in Pricing table.';
                            capRecord.addError(errorMsg);
                        }
                        /*capRecord.addError('Episode Price Tier pricing not found in Pricing table.');
                        isError = true;*/
                    }
                }else if(operation == UPDATE_OP){
                    Boolean isPresentRCList = false;
                    for(Client_Avail_Price__c capRCRec : rcCAPList){
                        if(capRCRec.Id == capRecord.Id){
                            isPresentRCList = true;
                            break;
                        }
                    }
                    
                    if(!isPresentRCList){
                        rcCAPList.add(capRecord);
                    }
                }
                
            }
            capRecord.Use_Price_Code__c = false;
          }
          
          //Below method assigns rate card to CAP if exists
          if(rcCAPList.size() > 0){
            WB_RateCardHelper.assignRateCardToCAP(rcCAPList);
            Boolean isError = false;
            String errorMsg;
            for(Client_Avail_Price__c cap:rcCAPList){
                cap.Pricing__c = null; 
                cap.Episode_Pricing__c = null;
                Client_Avail__c clientAvail = clientAvailMap.get(cap.Client_Avail__c);
                if(cap.CAP_Rate_Card__c == null && cap.Price_Tier__c != Null && (clientAvail.Title_Content_Type__c == FEATURE || clientAvail.Title_Content_Type__c == SEASON || clientAvail.Title_Content_Type__c == 'Collection Features'|| clientAvail.Title_Content_Type__c == EPISODE)){
                    
                    errorMsg = '1. Price Tier not found on the rate card table.'+'\n';
                    cap.addError('Price Tier not found on the rate card table.');
                     isError = true;
                }
                if(clientAvail.Title_Content_Type__c == SEASON && cap.Episode_Rate_Card__c == Null && cap.Episode_Price_Tier__c != Null){
                    
                    if(!isError){
                        cap.addError('Episode Price Tier not found on the rate card table.');
                        isError = true;
                    }else{
                        errorMsg = errorMsg + '2. Episode Price Tier not found on the rate card table.';
                        cap.addError(errorMsg);
                    }
                    //cap.addError('Episode Price Tier not found on the rate card table');
                }
            }
            
            //if Rate card reference was not null eralier but null now since tier is not present on Rate card. if not feature/Season, there is no validation.
            //what to do with the existing PBEP, Delete? Since no valid Rate Card is not there to update WSP on PBEP.
          }
            
            
          
            
          
    }
    
    public static Map<String,List<Client_Avail__c>> getSeasonEpisodeAvails(List<String> seasonCAIDList){
      Map<String,List<Client_Avail__c>> seasonEpisodeMap = new  Map<String,List<Client_Avail__c>>();
      
      if(seasonCAIDList.size() > 0){
          List<Client_Avail__c> seasonAndEpisodeClientAvails = [Select id, Price_Tier_Text__c, Episode_Price_Tier__c,Parent_Client_Avail__c, Start_Date__c, End_Date__c, Status__c, Lock_Pricing_Update__c FROM Client_Avail__c 
                                                where Title_Content_Type__c = :WB_PriceUtility.EPISODE AND Local_Data_Category_Picklist__c LIKE 'TV%' AND Parent_Client_Avail__c in: seasonCAIDList];
      for(Client_Avail__c episodeCA:seasonAndEpisodeClientAvails){
        if(seasonEpisodeMap.get(episodeCA.Parent_Client_Avail__c) == null)
          seasonEpisodeMap.put(episodeCA.Parent_Client_Avail__c,new List<Client_Avail__c>());
        
        seasonEpisodeMap.get(episodeCA.Parent_Client_Avail__c).add(episodeCA);
          
      }
      }
    return seasonEpisodeMap;                                              
    }
    
    /*public static Map<Id,Client_Avail_Price__c> getEpisodeCAPs(List<String> episodeCAPIDList){
      Map<Id,Client_Avail_Price__c> episodeMap = new  Map<Id,Client_Avail_Price__c>();
      
      if(episodeCAPIDList.size() > 0){
          episodeMap = new Map<Id,Client_Avail_Price__c>([Select id, Client_Avail__r.Price_Tier_Text__c, Client_Avail__r.Parent_Client_Avail__c,Client_Avail__r.Parent_Client_Avail__r.Status__c, Client_Avail__r.Start_Date__c, Client_Avail__r.End_Date__c, Client_Avail__r.Status__c,Client_Avail__r.Local_Data_Category_Picklist__c,Client_Avail__r.Commercial_Avail__r.Country_Code__c FROM Client_Avail_Price__c 
                                                where Title_Content_Type__c = :WB_PriceUtility.EPISODE AND Id in :episodeCAPIDList]);
      }
    return episodeMap;                                              
    }*/
    
    public static Boolean isSeasonDataValid(Client_Avail_Price__c capRecord,Client_Avail_Price__c capRecordForCA,Map<String,List<Client_Avail__c>> seasonEpisodeMap){
      List<Client_Avail__c> episodeAvails = seasonEpisodeMap.get(capRecord.Client_Avail__c);
      if( episodeAvails != null && episodeAvails.size() > 0 && capRecordForCA.Client_Avail__r.Status__c == STATUS_CONF){
            for(Client_Avail__c episodeAvail : episodeAvails){
                if(episodeAvail.Lock_Pricing_Update__c == false && episodeAvail.Start_Date__c != episodeAvail.End_Date__c){
                  return false;
                }
            }
      }
      
      return true;
    }
    
    public static Boolean isEpiodeDataValid(Client_Avail_Price__c capRecord,Client_Avail_Price__c capRecordForCA){
      if(capRecordForCA.Client_Avail__r.Lock_Pricing_Update__c == true && capRecord.Effective_Date__c != capRecord.Expiry_Date__c &&
         capRecordForCA.Client_Avail__r.Parent_Client_Avail__r.Status__c == STATUS_CONF)
        {
          return false;
        }
      
      return true;
    }
    
    /*
      List<Client_Avail__c> episodeAvails = seasonEpisodeMap.get(capRecord.Client_Avail__c);
      String capAvailStatus = capRecord.Client_Avail_Status__c;
      String availStatus = capRecordForCA.Client_Avail__r.Status__c;
    DateTime currentTime = System.now(); 
    String countryCode = capRecordForCA.Client_Avail__r.Commercial_Avail__r.Country_Code__c;
    
    if((capAvailStatus == STATUS_CONF || (capAvailStatus == null && availStatus == STATUS_CONF)) && capRecordForCA.Client_Avail__r.PlayList__c !=null) { 
      if(capRecord.Episode_Price_Tier__c == 'tbd' || (!isCurrentPrice(capRecord,countryCode,countryOffsetMap,currentTime) && capRecordForCA.Client_Avail__r.Episode_Price_Tier__c == 'tbd'))
        return false;  
    }
              
      if( episodeAvails != null && episodeAvails.size() > 0){
        
            for(Client_Avail__c episodeAvail : episodeAvails) {
              
                if((episodeAvail.Lock_Pricing_Update__c == false && episodeAvail.Start_Date__c != episodeAvail.End_Date__c &&
                   (capAvailStatus == STATUS_CONF || (capAvailStatus == null && availStatus == STATUS_CONF)) &&
                   (capRecord.Episode_Price_Tier__c == 'tbd' || (!isCurrentPrice(capRecord,countryCode,countryOffsetMap,currentTime) && capRecordForCA.Client_Avail__r.Episode_Price_Tier__c == 'tbd')))// (!isCurrentPrice(capRecord,countryCode,countryOffsetMap,currentTime) && capRecordForCA.Client_Avail__r.Episode_Price_Tier__c == 'tbd'))) 
                   )
                   {
                       return false;
                   }
            }
      }
      
      return true;  
    }
    */
    
    /*public static Boolean isEpisodeStatusTierValid(Client_Avail_Price__c capRecord,Client_Avail_Price__c capRecordSaved,Map<String,Integer> countryOffsetMap){
      
      String capAvailStatus = capRecord.Client_Avail_Status__c;
      String availStatus = capRecordSaved.Client_Avail__r.Status__c;
        
      if(capAvailStatus == STATUS_CONF || (capAvailStatus == null && availStatus == STATUS_CONF)){
        DateTime currentTime = System.now(); 
        String countryCode = capRecordSaved.Client_Avail__r.Commercial_Avail__r.Country_Code__c;
        if(isCurrentPrice(capRecord,countryCode,countryOffsetMap,currentTime) || (capRecord.Effective_Date__c == capRecordSaved.Client_Avail__r.Start_Date__c && capRecordSaved.Client_Avail__r.Start_Date__c > currentTime)){ 
          if(capRecord.Category__c.contains('TV') && capRecord.Price_Tier__c == PRICE_TIER_TBD)
            return false;
        }else{
           String categoryVal = capRecordSaved.Client_Avail__r.Local_Data_Category_Picklist__c;
           if(categoryVal != null && categoryVal.contains('TV')){
             if(capRecord.Price_Tier__c == PRICE_TIER_TBD || capRecordSaved.Client_Avail__r.Price_Tier_Text__c == PRICE_TIER_TBD){
                return false;
              }
           }
        } 
      }
      return true;
    }
    
    public static Boolean isEpisodeStatusAdvanceValid(Client_Avail_Price__c capRecord,Client_Avail_Price__c capRecordSaved){
    if(capRecord.Client_Avail_Status__c == STATUS_CONF){
      if(WB_PriceUtility.SKIP_EPISODE_CA_STATUS_UPDATE == false && (capRecordSaved.Client_Avail__r.Parent_Client_Avail__r.Status__c == 'Tentative' || capRecordSaved.Client_Avail__r.Parent_Client_Avail__r.Status__c == 'Draft')){
        return false;
      }
    }else if(capRecord.Client_Avail_Status__c == 'Tentative'){
      if(WB_PriceUtility.SKIP_EPISODE_CA_STATUS_UPDATE == false && capRecordSaved.Client_Avail__r.Parent_Client_Avail__r.Status__c == 'Draft'){
        return false;
      }
    }
      return true;
    }
    */
    
    public static void addError(Client_Avail_Price__c prevRecord,Client_Avail_Price__c nextRecord,Map<Id,Client_Avail_Price__c> newClientAvailPriceMap,String message,Set<String> errorRecords){
      for(Client_Avail_Price__c capRecord:newClientAvailPriceMap.values()){
        if(prevRecord.Client_Avail__c == capRecord.Client_Avail__c){
          capRecord.addError(message);
          errorRecords.add(capRecord.Id);
        }
      }
    }
    
    public static void removeEpisodeCAP(Client_Avail__c caRecord,Map<String,List<Client_Avail_Price__c>> filteredCAPMap,Map<String,String> seasonCAIDErrorMAP,Map<Id,Client_Avail__c> clientAvailMap,Map<Id,Client_Avail_Price__c> newClientAvailPriceMap,Set<String> excludedRecords){
      Set<String> filterCAPSet = filteredCAPMap.keySet();
      for(String clientAvailId:filterCAPSet){
        Client_Avail__c episodeCA = clientAvailMap.get(clientAvailId);
        if(episodeCA.Title_Content_Type__c == WB_PriceUtility.EPISODE && episodeCA.Parent_Client_Avail__c == caRecord.Parent_Client_Avail__c){
          for(Client_Avail_Price__c capRecord:filteredCAPMap.get(clientAvailId)){
            if(newClientAvailPriceMap.get(capRecord.Id) != null){
              newClientAvailPriceMap.get(capRecord.Id).addError(seasonCAIDErrorMAP.get(episodeCA.Parent_Client_Avail__c));
              excludedRecords.add(capRecord.id);
            }
          }
          filteredCAPMap.remove(clientAvailId);
        }  
      }
    }
    
    public static void removeFailedSeasonRecords(List<Client_Avail_Price__c> changedCAPRecords,List<Client_Avail_Price__c> failedSeasonList,Set<String> excludedRecords){
      List<Integer> indexListToRemove = new List<Integer>();
      for(Integer index=0;index<changedCAPRecords.size();index++){
        Client_Avail_Price__c capRecord = changedCAPRecords[index];
        for(Client_Avail_Price__c failedSeasonCAP:failedSeasonList){
          if(failedSeasonCAP.id == capRecord.id || failedSeasonCAP.Client_Avail__c == capRecord.Client_Avail__c){
            indexListToRemove.add(index);
            excludedRecords.add(capRecord.id);
          }
        }
      }
      
      
      for(Integer index=indexListToRemove.size();index > 0;index--){
        changedCAPRecords.remove(indexListToRemove[index-1]);
      }    
    }
    
    //Publish to Client changes start
    /*public static List<Client_Avail_Price__c> setPublishFlagToClient(List<Client_Avail_Price__c> capList,String objectName){
        
        Map<Id,Client_Avail__c> clientAvailMap = new Map<Id,Client_Avail__c>();
        List<Client_Avail_Price__c> capUpdateList = new List<Client_Avail_Price__c>();
        String clientAvailStatus = '';
        Set<Id> caIDSet = new Set<ID>();
        List<Country_SID_Key__c> countryList = Country_SID_Key__c.getall().values();
        Set<String> setCountryList = new Set<String>();
        for(Country_SID_Key__c countryRec : countryList){
            if(countryRec.isPublishToClient__c)
                setCountryList.add(countryRec.Name);
        }
        
        WB_Pricing_Settings__c  publishToClientSetting = WB_Pricing_Settings__c.getInstance('Publish to Client');
        
        
       if(publishToClientSetting != null && publishToClientSetting.isPublishToClient__c){
            for(Client_Avail_Price__c cap: capList){
                
                
                try{
                    if( cap.Account__c == 'Apple iTunes' && cap.Title_Content_Type__c == FEATURE && setCountryList.contains(cap.Country__c) 
                      && cap.Client_Avail_Status__c == STATUS_CONF && cap.CAP_Lifecycle__c != 'History Expired'){
                        
                        if(cap.Publish_to_Client__c == 'Send' && cap.Publish_to_Client__c == 'Re-Send')
                     continue;
                 
                        if((cap.Client_Avail_Channel__c == 'EST' &&  ( (cap.Effective_Date__c >= gmtDate && cap.Effective_Date__c <= dateCheckEST)  || cap.CAP_Lifecycle__c == 'Active Current') ) ||
                           (cap.Client_Avail_Channel__c == 'VODi' && ( (cap.Effective_Date__c >= gmtDate && cap.Effective_Date__c <= dateCheckVODi)  || cap.CAP_Lifecycle__c == 'Active Current') )
                          ){
                            
                            if(cap.Effective_Date__c == cap.CA_Start_Date__c || cap.Type__c == 'First') //First CAPs will be set in Batch Job.
                              continue;
                            
                            cap.Publish_to_Client__c = 'Send';    
                            capUpdateList.add(cap);
                          
                        }else if(cap.Publish_to_Client__c != 'Do Not Send'){
                             cap.Publish_to_Client__c = 'Do Not Send';    
                             capUpdateList.add(cap);
                        }
                    }
                    
                }catch(Exception ex){
                    system.debug(LoggingLevel.INFO,'Exception:'+ex);
                }
                
                
            }
        
        }
        
        return capUpdateList;
        
    }*/
    //Publish to Client changes end 
    
    //ER-1139 Return to Window changes Start
    public static void setReturnToWindowFlag(List<Commercial_Avail__c> releasePlanList,List<Client_Avail__c> caList){
      
      Set<Commercial_Avail__c> rpSet = new Set<Commercial_Avail__c>(releasePlanList); 
      Set<String> videoVersionSet = new Set<String>();
      Set<String> titleContentTypeSet = new Set<String>();
      Set<String> countrySet = new Set<String>();
      Set<String> formatSet = new Set<String>();
      Set<String> channelSet = new Set<String>();
      Set<String> languageSet = new Set<String>();
      Set<String> languageTypeSet = new Set<String>();
      Set<String> clientSet = new Set<String>();
      List<Client_Avail__c> caAvailableData = new List<Client_Avail__c>();
      
      Map<String,List<ClientAvailWrapper>> caListInsertMap = new Map<String,List<ClientAvailWrapper>>();
      Map<String,List<ClientAvailWrapper>> caAvailableDataMap = new Map<String,List<ClientAvailWrapper>>();
      List<Client_Avail__c> caSortedList = new List<Client_Avail__c>();
      List<Client_Avail__c> caFinalInsertList = new List<Client_Avail__c>();
      List<ClientAvailWrapper> CAWrapperList = new List<ClientAvailWrapper>();
      List<ClientAvailWrapper> CAExistingWrapperList = new List<ClientAvailWrapper>();
      Boolean isMatch = false; 
      Boolean isNoDiff = false;
     
      try{
        
      for(Client_Avail__c caSortRec :caList){
         CAWrapperList.add(new ClientAvailWrapper(caSortRec));
      }
      CAWrapperList.sort();
     
   
      for(Commercial_Avail__c rpRec : rpSet){
        
        if(rpRec.Title__r.Content_Type__c != FEATURE) continue;
        
        //Create a set of the parameters on which existing CA needs to be filtered out
        videoVersionSet.add(rpRec.Title__r.Video_Version__c);       //Video Version
        titleContentTypeSet.add(rpRec.Title__r.Content_Type__c);    //Content Type
        countrySet.add(rpRec.Country_Lookup__c);                    //Country
        formatSet.add(rpRec.Format__c);                             //Format
        channelSet.add(rpRec.Channel__c);                           //Channel
        languageSet.add(rpRec.Languages__c);                        //Language
        languageTypeSet.add(rpRec.Language_Type__c);                //Language Type
        
        
        if(CAWrapperList != null && CAWrapperList.size()>0){
            for(ClientAvailWrapper caRec : CAWrapperList){
                clientSet.add(caRec.ca.client__c);                    //Account
                String key = '';
                
                //Form the key for the CA to be inserted
                if(caRec.ca.Commercial_Avail__c == rpRec.Id){
                    //Key - Video Verion + Country + Format + Channel + Language + Language Type + Account + Content Type
                    key = rpRec.Title__r.Video_Version__c+'%'+rpRec.Country_Lookup__c +'%'+rpRec.Format__c+'%'+rpRec.Channel__c+'%'+rpRec.Languages__c+'%'+rpRec.Language_Type__c+'%';
                    key+=caRec.ca.client__c+'%'+rpRec.Title__r.Content_Type__c;
                   
                    
                    //Create a map for the CA to be inserted 
                    if(!caListInsertMap.containsKey(key)){
                        caListInsertMap.put(key,new List<ClientAvailWrapper>{caRec});
                    }else
                        caListInsertMap.get(key).add(caRec);
                   
                  }
            }
            
           
        } 
      }

      
      caAvailableData = [Select Id,Start_Date__c,End_Date__c,Title_Video_Version__c,Title_Content_Type__c,Commercial_Avail__r.Country_Lookup__c,Release_Plan_Country__c,Release_Plan_Format__c,Release_Plan_Channel__c,Commercial_Avail__r.Languages__c,Release_Plan_Language__c,RP_Language_Type__c,Client__c,Client__r.Name,Commercial_Avail__c FROM Client_Avail__c
                         WHERE (Commercial_Avail__r.Local_Title__r.Title__r.Video_Version__c IN:videoVersionSet AND Title_Content_Type__c IN : titleContentTypeSet AND Commercial_Avail__r.Country_Lookup__c IN : countrySet AND Release_Plan_Format__c IN : formatSet 
                         AND Release_Plan_Channel__c IN :channelSet AND Commercial_Avail__r.Languages__c IN : languageSet AND RP_Language_Type__c IN : languageTypeSet AND Client__c IN :clientSet) ORDER BY Start_Date__c ASC];
     
     if(caAvailableData != null && caAvailableData.size()>0){
        for(Client_Avail__c ca :caAvailableData){
            CAExistingWrapperList.add(new ClientAvailWrapper(ca));
        }
     }
     
     //Form the key same as that as of to be inserted CA and create Map for existing CA
     if(CAExistingWrapperList != null && CAExistingWrapperList.size()>0){
         for(ClientAvailWrapper caRec :CAExistingWrapperList){
            String key = caRec.ca.Title_Video_Version__c+'%'+caRec.ca.Commercial_Avail__r.Country_Lookup__c+'%'+caRec.ca.Release_Plan_Format__c+'%'+caRec.ca.Release_Plan_Channel__c+'%'+
                         caRec.ca.Commercial_Avail__r.Languages__c+'%'+caRec.ca.RP_Language_Type__c+'%'+caRec.ca.Client__c+'%'+caRec.ca.Title_Content_Type__c;
           
           if(!caAvailableDataMap.containsKey(key)){
                caAvailableDataMap.put(key,new List<ClientAvailWrapper>{caRec});
            }else
                caAvailableDataMap.get(key).add(caRec);
         }
     }
    
     
     for(String keyToMatch : caListInsertMap.keySet()){
         
        if(caAvailableDataMap.containsKey(keyToMatch)){
            
            caAvailableDataMap.get(keyToMatch).addAll(caListInsertMap.get(keyToMatch));
            caAvailableDataMap.get(keyToMatch).sort();
            
            for(ClientAvailWrapper toBeInsertedCA : caListInsertMap.get(keyToMatch)){
               
               for(Integer i = 0;i<=caAvailableDataMap.get(keyToMatch).size()-1;i++){
                   
                   if((toBeInsertedCA.ca.Start_Date__c == caAvailableDataMap.get(keyToMatch)[i].ca.Start_Date__c ) && (toBeInsertedCA.ca.End_Date__c == caAvailableDataMap.get(keyToMatch)[i].ca.End_Date__c )){
                        
                        if(i != 0 && (caAvailableDataMap.get(keyToMatch)[i-1].ca.End_Date__c.daysBetween(toBeInsertedCA.ca.Start_Date__c) > 1)){
                          
                          toBeInsertedCA.ca.First_Announcement_Change_Status__c = 'Return';
                          
                        }else{
                          toBeInsertedCA.ca.First_Announcement_Change_Status__c = 'New';
                          
                         
                      }
                          
                   }
                   
               } 
               
               caFinalInsertList.add(toBeInsertedCA.ca); 
              
            }
          
         }else{
             
             for(Integer i = 0;i<=caListInsertMap.get(keyToMatch).size()-1;i++){
                if(i != 0 && (caListInsertMap.get(keyToMatch)[i-1].ca.End_Date__c.daysBetween(caListInsertMap.get(keyToMatch)[i].ca.Start_Date__c) > 1)){
                    
                    caListInsertMap.get(keyToMatch)[i].ca.First_Announcement_Change_Status__c = 'Return';
                }else
                    caListInsertMap.get(keyToMatch)[i].ca.First_Announcement_Change_Status__c = 'New'; 
                
                caFinalInsertList.add(caListInsertMap.get(keyToMatch)[i].ca); 
                 
             }
             
            
         }
       
        
     }
     
     }catch(Exception ex){
        System.debug(LoggingLevel.INFO,'Exception in setReturnToWindowFlag '+ex.getMessage());
     }
     
 }
 
 //Error Capturing added by Tejasvini
 /*public static void createErrorLog(List<Client_Avail__c> caList,String errorMessage){
         List<WB_CAS_ErrorLogger.ErrorLog> errorLogs = new List<WB_CAS_ErrorLogger.ErrorLog>();
         
         system.debug('Within Error Log:'+caList+'Error Message:'+errorMessage);
         if(caList != null && caList.size()>0){
             for(Client_Avail__c ca : caList){
                 WB_CAS_ErrorLogger.ErrorLog errorLogInstance = new  WB_CAS_ErrorLogger.ErrorLog();
                 errorLogInstance.recordId = ca.Id;
                 errorLogInstance.errorCategory = WB_PriceUtility.PLAYLIST_UPDATE;
                 errorLogInstance.errorDescription = errorMessage.left(252);
                 errorLogInstance.errorDescriptionLong = errorMessage.left(32000); 
                 errorLogInstance.objectName = ca.Id.getSObjectType().getDescribe().getName();
                 errorLogInstance.account = ca.Client__c;
                 errorLogs.add(errorLogInstance);
             }
         }
         
         if(errorLogs != null && errorLogs.size()>0){
            WB_CAS_ErrorLogger.logError(errorLogs); 
         }
         
         
 }*/
 
 public static void createErrorLog(List<Client_Avail__c> caList,Map<Id,String> caErrorMap,Map<Id,String> caPlaylistIDMap){
         List<WB_CAS_ErrorLogger.ErrorLog> errorLogs = new List<WB_CAS_ErrorLogger.ErrorLog>();
         
         if(caList != null && caList.size()>0){
             for(Client_Avail__c ca : caList){
                 if(ca.Title_Content_Type__c == 'Season' && caErrorMap.get(ca.Id) != null){
                     WB_CAS_ErrorLogger.ErrorLog errorLogInstance = new  WB_CAS_ErrorLogger.ErrorLog();
                     errorLogInstance.recordId = ca.Id;
                     errorLogInstance.errorCategory = WB_PriceUtility.PLAYLIST_UPDATE;
                     //if(caErrorMap.get(ca.Id) != null){
                         errorLogInstance.errorDescription = caErrorMap.get(ca.Id).left(252);
                         errorLogInstance.errorDescriptionLong = caErrorMap.get(ca.Id).left(32000);
                         /*if(caErrorMap.get(ca.Id).contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                             errorLogInstance.errorDescriptionLong = caErrorMap.get(ca.Id).substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
                         }else
                            errorLogInstance.errorDescriptionLong = caErrorMap.get(ca.Id).left(32000);*/
                   //  }
                      
                     errorLogInstance.objectName = ca.Id.getSObjectType().getDescribe().getName();
                     errorLogInstance.account = ca.Client__c;
                     
                     if(caPlaylistIDMap.get(ca.Id) != null)
                        errorLogInstance.playlistId = caPlaylistIDMap.get(ca.Id);
                     errorLogs.add(errorLogInstance);
                 }
                 
             }
         }
         
         if(errorLogs != null && errorLogs.size()>0){
            WB_CAS_ErrorLogger.logError(errorLogs); 
         }
         
         
 }
 
 //added by Tejasvini Mar Release 2018
 public static Boolean availableCombination(Commercial_Avail__c rpRec,Agreement__c storefrontRec){
     Set<String> contentTypeSet = new Set<String>();
     Set<String> channelSet = new Set<String>();
     Set<String> formatSet = new Set<String>();
     Map<String,String> selectedCOmbinationMap = new Map<String,String>();
     Set<String> availableCombinationSet = new Set<String>();
    
     if(rpRec != null && storefrontRec != null){
         String releasePlanCombination;
         releasePlanCombination = rpRec.Title__r.Content_Type__c + '_'+rpRec.Channel__c+'_'+rpRec.Format__c;
         
         
         if(storefrontRec.Selected_Combination__c != null){
             for(String availableValue :  storefrontRec.Selected_Combination__c.split(',')){
            
                availableValue = availableValue.trim();
                availableCombinationSet.add(availableValue);
                
             }
             if(releasePlanCombination != null){
                 if(availableCombinationSet.contains(releasePlanCombination)){
                     return false;
                 }else{
                    return true;
                 }
             }
         }else
            return false;
         
         
     }
     
     
     return null;
 }
 
 public static void assignPricingValues(Client_Avail_Price__c firstCap, Client_Avail_Price__c tobeChangedCap){
   
   if((firstCap.Price_Tier__c != null || firstCap.Price__c != null) || (firstCap.Episode_Price__c != null || firstCap.Episode_Price_Tier__c != null)){
    tobeChangedCap.Price_Code__c = null;
    tobeChangedCap.Price_Tier__c = firstCap.Price_Tier__c;
    tobeChangedCap.Price__c = firstCap.Price__c;
    tobeChangedCap.Episode_Price__c = firstCap.Episode_Price__c;
    tobeChangedCap.Episode_Price_Tier__c = firstCap.Episode_Price_Tier__c;
    tobeChangedCap.Pricing__c = firstCap.Pricing__c;
  }
 }
 
 public static Boolean checkContractProvider(Commercial_Avail__c vCommercialAvails,Agreement__c selectStrfront,Map<String,Map<String,Set<String>>> mapErrorRPAccount,account acc,Integer countExcpetionRec,List<WB_CreateClientAvail_Controller.releaseplanwrapper2> notMatchedCommercialWrap_list2){
  String Provider = '';
  Boolean isContractProviderNotEnabled = false;
    if(vCommercialAvails.Local_Title__r.LocalDisplayStudio__c != Null && vCommercialAvails.Local_Title__r.LocalDisplayStudio__c !=''){
        if(Label.TurnerVal.contains(vCommercialAvails.Local_Title__r.LocalDisplayStudio__c)){
            Provider = TURNER;
                                                          
            if(selectStrfront.Turner_SAP_Customer__c == Null || selectStrfront.Turner_SAP_Customer__c ==''){
                //system.debug(LoggingLevel.INFO,'WIthin check selectStrfront.Account__r.Name:'+selectStrfront.Account__r.Name);
                    isContractProviderNotEnabled = true;
                    if(!mapErrorRPAccount.containsKey(SF_TURNER_NOT_ENABLED)){
                        mapErrorRPAccount.put(SF_TURNER_NOT_ENABLED,new Map<String,Set<String>>());
                    }
                    if(!mapErrorRPAccount.get(SF_TURNER_NOT_ENABLED).containsKey(vCommercialAvails.Name)){
                        mapErrorRPAccount.get(SF_TURNER_NOT_ENABLED).put(vCommercialAvails.Name,new Set<String>());
                    }
                    if(!mapErrorRPAccount.get(SF_TURNER_NOT_ENABLED).get(vCommercialAvails.Name).contains(selectStrfront.Account__r.Name)){
                        mapErrorRPAccount.get(SF_TURNER_NOT_ENABLED).get(vCommercialAvails.Name).add(selectStrfront.Account__r.Name);
                    }
                    //system.debug(LoggingLevel.INFO,'mapErrorRPAccount:'+mapErrorRPAccount);
                    if(isContractProviderNotEnabled){
                        //system.debug(LoggingLevel.INFO,'isContractProviderTurnerNotEnabled..:'+isContractProviderTurnerNotEnabled);
                        countExcpetionRec++;
                        WB_CreateClientAvail_Controller.releaseplanwrapper2 real= new WB_CreateClientAvail_Controller.releaseplanwrapper2();    
                        string str = vCommercialAvails.Id+string.valueof(countExcpetionRec);    
                        String errorMessage =  SF_TURNER_NOT_ENABLED;
                        WB_CreateClientAvail_Controller.clientAvailCreationError(real,str,errorMessage,vCommercialAvails,acc);
                        notMatchedCommercialWrap_list2.add(real);
                    }
                    return isContractProviderNotEnabled;
                                                                   
            }
        }else if(vCommercialAvails.Local_Title__r.LocalDisplayStudio__c == HBO){
            Provider = HBO;
            //system.debug(LoggingLevel.INFO,'Provider HBO..');
            if(selectStrfront.HBO_SAP_Customer__c == Null || selectStrfront.HBO_SAP_Customer__c ==''){
                //system.debug(LoggingLevel.INFO,'WIthin check selectStrfront.Account__r.Name:'+selectStrfront.Account__r.Name);
                isContractProviderNotEnabled = true;
                if(!mapErrorRPAccount.containsKey(SF_HBO_NOT_ENABLED)){
                    mapErrorRPAccount.put(SF_HBO_NOT_ENABLED,new Map<String,Set<String>>());
                }
                if(!mapErrorRPAccount.get(SF_HBO_NOT_ENABLED).containsKey(vCommercialAvails.Name)){
                    mapErrorRPAccount.get(SF_HBO_NOT_ENABLED).put(vCommercialAvails.Name,new Set<String>());
                }
                if(!mapErrorRPAccount.get(SF_HBO_NOT_ENABLED).get(vCommercialAvails.Name).contains(selectStrfront.Account__r.Name)){
                    mapErrorRPAccount.get(SF_HBO_NOT_ENABLED).get(vCommercialAvails.Name).add(selectStrfront.Account__r.Name);
                }
                //system.debug(LoggingLevel.INFO,'mapErrorRPAccount:'+mapErrorRPAccount);
                if(isContractProviderNotEnabled){
                    //system.debug(LoggingLevel.INFO,'isContractProviderHBONotEnabled..:'+isContractProviderHBONotEnabled);
                    countExcpetionRec++;
                    WB_CreateClientAvail_Controller.releaseplanwrapper2 real= new WB_CreateClientAvail_Controller.releaseplanwrapper2();    
                    string str = vCommercialAvails.Id+string.valueof(countExcpetionRec);    
                    String errorMessage =  SF_HBO_NOT_ENABLED;
                    WB_CreateClientAvail_Controller.clientAvailCreationError(real,str,errorMessage,vCommercialAvails,acc);
                    //system.debug(LoggingLevel.INFO,'real:'+real);
                    notMatchedCommercialWrap_list2.add(real);
                }
                return isContractProviderNotEnabled;
                                                                   
            }
        }else{
            Provider = WB;
        }
                                                        
    }else{
    Provider = WB;
    }
                                                       
    if(Provider == WB){
        if(selectStrfront.SAP_Customer_Number__c == Null || selectStrfront.SAP_Customer_Number__c ==''){
            //system.debug(LoggingLevel.INFO,'WIthin check selectStrfront.Account__r.Name:'+selectStrfront.Account__r.Name);
            isContractProviderNotEnabled = true;
            if(!mapErrorRPAccount.containsKey(SF_WB_NOT_ENABLED)){
        mapErrorRPAccount.put(SF_WB_NOT_ENABLED,new Map<String,Set<String>>());
            }
            if(!mapErrorRPAccount.get(SF_WB_NOT_ENABLED).containsKey(vCommercialAvails.Name)){
                mapErrorRPAccount.get(SF_WB_NOT_ENABLED).put(vCommercialAvails.Name,new Set<String>());
            }
            if(!mapErrorRPAccount.get(SF_WB_NOT_ENABLED).get(vCommercialAvails.Name).contains(selectStrfront.Account__r.Name)){
                    mapErrorRPAccount.get(SF_WB_NOT_ENABLED).get(vCommercialAvails.Name).add(selectStrfront.Account__r.Name);
            }
            //system.debug(LoggingLevel.INFO,'mapErrorRPAccount:'+mapErrorRPAccount);
            if(isContractProviderNotEnabled){
                //system.debug(LoggingLevel.INFO,'isContractProviderWBNotEnabled..:'+isContractProviderWBNotEnabled);
                countExcpetionRec++;
                WB_CreateClientAvail_Controller.releaseplanwrapper2 real= new WB_CreateClientAvail_Controller.releaseplanwrapper2();  
                string str = vCommercialAvails.Id+string.valueof(countExcpetionRec);    
                String errorMessage =  SF_WB_NOT_ENABLED;
                WB_CreateClientAvail_Controller.clientAvailCreationError(real,str,errorMessage,vCommercialAvails,acc);
                notMatchedCommercialWrap_list2.add(real);
            }
            return isContractProviderNotEnabled;
        }
                                                          
    }
    return isContractProviderNotEnabled;
}

    public static Boolean announcementRecordChanges(Announcement_Record__c rec){
        Boolean isARModified = false;
        if(rec != Null && rec.Change_Status__c != Null && rec.Changed_Fields__c != Null){
           /* if(rec.Change_Status__c.containsOnly('Change') && rec.Changed_Fields__c.containsOnly('Supp End Date')){
                rec.Change_Status__c = 'No Change';
            }*/
            
            if(rec.Changed_Fields__c.contains('Supp End Date')){
                rec.Changed_Fields__c = rec.Changed_Fields__c.remove('Supp End Date');
                if(rec.Changed_Fields__c.contains(', ,')){
                    rec.Changed_Fields__c=rec.Changed_Fields__c.replace(', ,',',');
                    
                }
                
                if(String.isBlank(rec.Changed_Fields__c.substringAfterLast(','))){
                    rec.Changed_Fields__c = rec.Changed_Fields__c.trim();
                    rec.Changed_Fields__c = rec.Changed_Fields__c.removeEnd(',');
                }
                if(rec.Changed_Fields__c.indexOf(',', 0) == 0){
                    rec.Changed_Fields__c = rec.Changed_Fields__c.substring(1, rec.Changed_Fields__c.length());  
                }
                //rec.Changed_Fields__c = rec.Changed_Fields__c.replaceAll(',',', '); 
                isARModified = true;
            }
        
        }
        
        
        return isARModified;
        
    }
	
	//ER-004159 - HBO/Turner: Ability to Manually override Episode price - changes
	//Method creats a Map if Episode CAP is Enabled Episode Price Override
    public static Map<String,Boolean> trackEpOverrEnabledCAMap(List<Client_Avail__c> caList){
        
        Map<String,Boolean> epOvrCAMap = new Map<String,Boolean>();
        if(caList != Null && caList.size()>0){
            for(Client_Avail__c ca : caList){
                List<Client_Avail_Price__c> capList = ca.Client_Avail_Prices__r;
                for(Client_Avail_Price__c cap : capList){
                    if(cap.Episode_Price_Override__c){
                        if(epOvrCAMap != Null){
                            epOvrCAMap.put(ca.Id,true);
                        }
                        break;
                    }
                    
                }
            }
        }
        return epOvrCAMap;
    }
    
    //ER-004159 - HBO/Turner: Ability to Manually override Episode price - changes
    //Method called from WB_PriceWizardController - method checks whether Episode is enabled Episode Price Override and is not History Expired
    public static Map<String,Boolean> trackEpOverrEnabledForActiveEpCAMap(List<Client_Avail__c> caList){
        
        Map<String,Boolean> epOvrCAMap = new Map<String,Boolean>();
        if(caList != Null && caList.size()>0){
            for(Client_Avail__c ca : caList){
                List<Client_Avail_Price__c> capList = ca.Client_Avail_Prices__r;
                for(Client_Avail_Price__c cap : capList){
                    if(cap.Episode_Price_Override__c && (cap.Expiry_Date__c >= System.Today())){
                        if(epOvrCAMap != Null){
                            epOvrCAMap.put(ca.Id,true);
                        }
                        break;
                    }
                    
                }
            }
        }
        return epOvrCAMap;
    }
    
    //ER-004159 - HBO/Turner: Ability to Manually override Episode price - changes
    //check if Seasson CAP falls within either Episode CAP and Episode is Episode Price Override Enabled
    public static Boolean checkSeasonCAPwithinEpisodeCAP(Client_Avail_Price__c seasonCAP,List<Client_Avail_Price__c> episodeCAPList){
        Boolean seasonCAPwithinEpCAPAndEpOvr = false;
        
        if(episodeCAPList != Null && episodeCAPList.size()>0){
            for(Client_Avail_Price__c episodeCAP : episodeCAPList){
                if(seasonCAP.Effective_Date__c >= episodeCAP.Effective_Date__c && seasonCAP.Effective_Date__c < episodeCAP.Expiry_Date__c && episodeCAP.Episode_Price_Override__c){
                    seasonCAPwithinEpCAPAndEpOvr = true;
                    break;
                }
            }
        }
        
        return seasonCAPwithinEpCAPAndEpOvr;
    }
    
    
 Public class ClientAvailWrapper implements Comparable{
    Public Client_Avail__c ca;
        
    Public ClientAvailWrapper(Client_Avail__c c){
        ca = c;
    }
        
    public Integer compareTo(Object compareTo){
        ClientAvailWrapper compareToCa = (ClientAvailWrapper)compareTo;
        Integer returnValue = 0;
        if (ca.Start_Date__c > compareToCa.ca.Start_Date__c) 
            returnValue = 1;
        else if (ca.Start_Date__c < compareToCa.ca.Start_Date__c)
            returnValue = -1;
            
        return returnValue;       
    }
}
//ER-1139 Return to Window changes end   
    
    public static Boolean PLAY_LIST_UPDATE = false;
    public static Boolean SKIP_PRICE_VALIDATION = false;
    public static Boolean SKIP_VALIDATION = false;
    public static Boolean SKIP_EPISODE_PROCESS = false;
    public static Boolean SKIP_EPISODE_PBEP_PROCESS = false;
   
    public static Date gmtDate = System.Today();
    public static Date dateCheckEST = System.Today().adddays(10); //ER-002192 . changed window from 30 to 10.
    public static Date dateCheckVODi = System.Today().adddays(5);
    public static Date dateCheckNR = System.Today().adddays(2);
    
    public static final String PERM_PRICE_RT_NAME = 'PERM';
    public static final String TEMP_PRICE_RT_NAME = 'TEMP';
    public static final String DC_RT_NAME = 'Digital Client';
    public static final String INSERT_OP = 'Insert';
    public static final String DELETE_OP = 'Delete';
    public static final String UPDATE_OP = 'Update';
    public static final String STATUS_CONF = 'Confirmed';
    
    public static final String STATUS_TENTVE = 'Tentative';
    public static final String STATUS_CANCD ='Cancelled';
   
    public static final String FIRST = 'First';
    public static final String PREORDER = 'PreOrder';
    public static final String REPRICE = 'Reprice';
    public static final String SEASON = 'Season';
    public static final String FEATURE = 'Feature';
    public static final String EPISODE = 'Episode';
    public static final String PRICE_TIER_TBD = 'TBD';
    public static final String PRICE_TIER_NA = 'N/A';
    public static final String PR_PRT_MX_ERROR = Label.WB_CAP_Error_PriceTier_Price_Mutual_Exclusive;
    public static final String EPR_EPRT_MX_ERROR = Label.WB_CAP_Error_Epi_PriceTier_Price_Mutual_Exclusive;
    public static final String EFF_DATE_REQ_ERROR = Label.WB_CAP_PriceStartDate_Must_Enter;
    public static final String INSUFF_DATE_RANGE_ERROR = Label.WB_CAP_Insufficient_Date_range;
    public static final String DATE_OVERLAP_ERROR = Label.WB_CAP_Same_Dates_Price_Overlap;
    public static final String SAME_DATE_ERROR = Label.WB_CAP_Same_Dates_Price_Exist;
    public static final String INVALID_CATEGORY_ERROR = Label.WB_CAP_Invalid_Category_Error;
    public static final String PRICE_RECORD_NOT_AVLB = Label.WB_CAP_Price_Record_Not_Available;
    public static final String PRICE_TIER_NOT_MATCHING = Label.WB_CAP_Price_Tier_Not_Matching;
    public static final String SEASON_WITH_PLY_TBD = Label.WB_CAP_Season_With_Playlist_TBD;
    public static final String ANNOUN_START_DT_PAST = Label.WB_CAP_Announcement_Start_Date_Past;
    public static final String PRC_CODE_OR_PRICE = Label.WB_CAP_PriceCode_Or_Price;
    public static final String PRC_CODE_OR_EPRICE =Label.WB_CAP_PriceCode_Or_EpisodePrice;
    public static final String PRICE_DATE_PAST = Label.WB_CAP_Price_Start_Date_Past;
    public static final String INV_CA_ID = Label.WB_CAP_Invalid_CA_ID;
    public static final String INV_CONT_TYPE_RE_PRICE = Label.WB_CAP_Invalid_ContentType_RePrice;
    public static final String INV_CA_LIFE_CYCL = Label.WB_CAP_Invalid_CA_LifeCycle;
    public static final String INV_ANN_OVERRIDE = Label.WB_CAP_Invalid_Announce_Override;
    public static final String INV_CAP_ID = Label.WB_CAP_Invalid_CAP_ID;
    public static final String INV_CONT_TYPE_PRICE_UPDATE = Label.WB_CAP_Invalid_ContentType_PriceUpdate;
    public static final String CATEGORY_REQ = Label.WB_CAP_Category_Req;
    public static final String INV_CAP_START_DT = Label.WB_CAP_Invalid_CAP_Start_Date;
    public static final String INV_WSP = Label.WB_CAP_Invalid_WSP;
    public static final String INV_EWSP = Label.WB_CAP_Invalid_Episode_WSP;
    public static final String FIRST_CAP_DEL = Label.WB_CAP_First_CAP_Deleted;
    public static final String FIRST_CAP_INV_DT = Label.WB_CAP_First_CAP_Invalid_Date;
    public static final String CAP_DEL_ANNOUNCE = Label.WB_CAP_Delete_Announcement;
    public static final String CURR_CAP_DEL = Label.WB_CAP_Current_CAP_Del; 
    public static final String RE_PRICE_TAB = Label.WB_CAP_Re_Price_Wizard_Tab;
    public static final String PRICE_UPDATE_TAB = Label.WB_CAP_Price_Update_Wizard_Tab;
    public static final String CA_CONF_INVALID_TIER = 'A Client Avail cannot be “Confirmed” with invalid price tier';
    public static final String EPISODE_TBD_CONF = 'Episode Avails cannot be confirmed with a TBD price tier';
    public static final String EPISODE_STATUS_ADV = 'Episode CA Status must not advance past the current Season Status'; 
    public static final String STATUS_HISTORY_EXP ='History Expired';
    public static final String HISTORY_EXP_CAP_DEL = 'Client Avail Pricing with History Expired Life Cycle cannot be deleted';
    public static final String ACTIVE_CURR_CAP_DEL = 'Client Avail Pricing with Active Current Life Cycle and valid Price cannot be deleted'; 
    public static final String PLAYLIST_UPDATE = 'Playlist Update';
    public static final String SF_HBO_NOT_ENABLED = Label.Storefront_Not_Enabled_for_HBO;
    public static final String SF_TURNER_NOT_ENABLED = Label.Storefront_Not_Enabled_for_Turner;
    public static final String SF_WB_NOT_ENABLED = Label.Storefront_Not_Enabled_for_Warner_Bros;
    public static final String HBO = Label.HBOVal;
    public static final String TURNER = 'Turner';
    public static final String WB = Label.WBVal;
    
    public static final Set<String> PriceTypeSet = new Set<String>{FIRST,REPRICE};
}