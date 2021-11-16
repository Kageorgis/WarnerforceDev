global without sharing class WB_compareLastAndFromDates1 {

    public List<Announcement_Trigger_Field__c> annFieldsList = new List<Announcement_Trigger_Field__c>();
    public List<String> statusSet = new List<String>{'Price Change','Price End','Price Start','Change'};
    public Set<String> tvContentTypeSet = new Set<String>{'Season','Episode','Collection TV'};
    public Set<String> featureContentTypeSet = new Set<String>{'Collection Features','Feature'};
    public Set<String> caOptionalFieldsSet = new Set<String>();
    
    global WB_compareLastAndFromDates1(){
    
        /*annFieldsList = [Select Id,Name,Changed_Field__c,Changed_Status__c,Destination_API__c,Destination_Object__c,Source_API__c,Source_Object__c,Trigger_Status__c,TV__c,Feature__c FROM Announcement_Trigger_Field__c];
        
        for(Announcement_Trigger_Field__c arTriggerRec : annFieldsList){
          
          if(arTriggerRec.Source_Object__c == 'Client Avail'){
              caOptionalFieldsSet.add(arTriggerRec.Changed_Field__c);
          }
          
       }*/
        
    }
    
    global WB_compareLastAndFromDates1(List<Announcement_Trigger_Field__c> annFields){
        annFieldsList = annFields;
        for(Announcement_Trigger_Field__c arTriggerRec : annFieldsList){
          if(arTriggerRec.Source_Object__c == 'Client Avail'){ 
              caOptionalFieldsSet.add(arTriggerRec.Changed_Field__c);
          }
       }
    }
    
    public Announcement_Record__c compareLastAndFromDates(client_avail__c clientAvailRec, announcement__c annID, List<Announcement_Rule__c> announcementRuleList,Client_Avail_Price__c capRecord,Announcement_Record__c annRecOnCA,Boolean isLastInList){  // Sprint 2 changes
    
    
   
    String CAN = 'Cancelled';
    Announcement_Record__c clientActivityRecord = new Announcement_Record__c();
    Set<String> optionalFieldsSet = new Set<String>();
        
    if(announcementRuleList != null && announcementRuleList.size() > 0){
        
        if(announcementRuleList[0].Optional_Triggers__c != null && announcementRuleList[0].Optional_Triggers__c!=''){
            for(String val : announcementRuleList[0].Optional_Triggers__c.split(';')){
                optionalFieldsSet.add(val);
            } 
        }
        
        integer counter = 0;
        if(annRecOnCA != null){// Sprint 2 changes
            //ER 452 - Announce Override - As per ABC FORCE and Suppress should bypass
            if(clientAvailRec.Announce_Override__c==null || clientAvailRec.Announce_Override__c==''){
                if(announcementRuleList[0].Date_Last_Run__c == NULL || annRecOnCA.Announcement_Run_Date__c == NULL)
                {
                    counter++;
                    //ER-000101 Announced Cancelled Client Avails Once Only
                    if((clientAvailRec.Status__c==CAN && annRecOnCA.Status__c==CAN) ||
                        (clientAvailRec.End_Date__c==annRecOnCA.Client_End__c && clientAvailRec.End_Date__c<Date.today())) {
                        return null;
                    }else {
                        clientActivityRecord = compareChange(clientAvailRec, annRecOnCA,annID.Id, annID,capRecord,isLastInList,optionalFieldsSet);
                    }
                } else if(announcementRuleList[0].Date_Last_Run__c >= annRecOnCA.Announcement_Run_Date__c && counter == 0){
                    counter++;
                    //ER-000101 Announced Cancelled Client Avails Once Only
                    if((clientAvailRec.Status__c==CAN && annRecOnCA.Status__c==CAN) ||
                        (clientAvailRec.End_Date__c==annRecOnCA.Client_End__c && clientAvailRec.End_Date__c<Date.today())){
                        return null;
                    }else {
                        clientActivityRecord = compareChange(clientAvailRec, annRecOnCA,annID.Id, annID,capRecord,isLastInList,optionalFieldsSet);
                    }
                }
           }else{
                counter++;
                clientActivityRecord = compareChange(clientAvailRec, annRecOnCA,annID.Id, annID,capRecord,isLastInList,optionalFieldsSet);
            }
        } 
        
        if(counter == 0){
            clientActivityRecord.Change_Status__c='Price Start';
        }
    } 
    
    clientActivityRecord.Announcement__c = annId.Id;
    clientActivityRecord.Client_Avail__c = clientAvailRec.Id;
    clientActivityRecord.Client_Avail_Price__c = capRecord.Id;
    clientActivityRecord.Playlist__c = clientAvailRec.Playlist__c;
    clientActivityRecord.Client_Start__c = capRecord.Effective_Date__c;
    clientActivityRecord.Client_End__c = capRecord.Expiry_Date__c;
    
    assignCaCapValues(clientAvailRec,clientActivityRecord);
    
    return clientActivityRecord;
   }
   
    public Announcement_Record__c compareChange (client_avail__c clientAvailRec,Announcement_Record__c annRecOnCA, ID annID, Announcement__c annRecordSingle,Client_Avail_Price__c capRecord,Boolean isLastInList,Set<String> optionalFieldsSet){ // Sprint 2 changes
       
        Announcement_Record__c clientActivity = new Announcement_Record__c();
        clientActivity.Change_Status__c = '';
        clientActivity.Changed_Fields__c = '';
        
        Map<String,Integer> statusPriorityMap = new Map<String,Integer>();
       
        Integer priorityVal = 0 ;
        for(String Status:statusSet){
            
            priorityVal = priorityVal+1;
            if(!statusPriorityMap.containsKey(Status))
                statusPriorityMap.put(Status,priorityVal);
        }
       
        if(annFieldsList.size() != null && annFieldsList.size()>0){
            for(Announcement_Trigger_Field__c annTriggerRec : annFieldsList){
             
               /*
                  Trigger Status - Optional on Announcement Trigger Object  and not included in Optional Fields on Announcement Type then skip
                  CAP Content Type contains any of values -  Season, Episode and TV is unchecked on Announcement Trigger Object then skip
                  CAP Content Type contains any of values -  Collection Tv, Collection Features, Feature and Feature is unchecked on Announcement Trigger Object then skip
               */
               if((annTriggerRec.Trigger_Status__c == 'Optional' && !optionalFieldsSet.contains(annTriggerRec.Name)) || 
                  (tvContentTypeSet.contains(clientAvailRec.CA_Content_Type__c) && !annTriggerRec.TV__c) ||
                  (featureContentTypeSet.contains(clientAvailRec.CA_Content_Type__c) && !annTriggerRec.Feature__c)){
                   continue;
               }
               
               //if source is Client Avail
                if(annTriggerRec.Source_Object__c == 'Client Avail'){
                    
                    if(clientAvailRec.get(annTriggerRec.Source_API__c) != annRecOnCA.get(annTriggerRec.Destination_API__c)){
                        
                        //Status is not null assign according to the priority of Status
                        if(clientActivity.Change_Status__c != null && clientActivity.Change_Status__c != ''){
                           
                            //Status with priority 1 should always be given priority
                            if(statusPriorityMap.get(clientActivity.Change_Status__c) > statusPriorityMap.get(annTriggerRec.Changed_Status__c )){
                               clientActivity.Change_Status__c =  annTriggerRec.Changed_Status__c;
                            }
                        }else{
                            
                            clientActivity.Change_Status__c = annTriggerRec.Changed_Status__c;
                        }
                        
                       
                        clientActivity.Changed_Fields__c=clientActivity.Changed_Fields__c+','+annTriggerRec.Changed_Field__c;
                    }
                }else if(annTriggerRec.Source_Object__c == 'Client Avail Pricing'){
                    
                   Boolean isWSPchange = false;
                   Decimal wspValue = Null;
                   if((annTriggerRec.Name == 'WSP' || annTriggerRec.Name == 'Episode WSP')){
                        if(capRecord.get(annTriggerRec.Source_API__c) != Null){
                            wspValue = (Decimal)capRecord.get(annTriggerRec.Source_API__c);
                            Integer scaleValue = wspValue.scale();
                            
                            if(scaleValue > 2){
                                wspValue = wspValue.setScale(2);
                            }
                           
                        }
                        
                        if(wspValue != annRecOnCA.get(annTriggerRec.Destination_API__c)){
                            isWSPchange = true;
                        }
                        
                       
                    }else if(capRecord.get(annTriggerRec.Source_API__c) != annRecOnCA.get(annTriggerRec.Destination_API__c)){
                        isWSPchange = true;
                    }
                   
                   if(isWSPchange){
                   //if(capRecord.get(annTriggerRec.Source_API__c) != annRecOnCA.get(annTriggerRec.Destination_API__c))	
                        if(clientActivity.Change_Status__c != null && clientActivity.Change_Status__c != '' ){
                               //Status with priority 1 should always be given priority
                                if(statusPriorityMap.get(clientActivity.Change_Status__c) > statusPriorityMap.get(annTriggerRec.Changed_Status__c )){
                                   
                                   if((annTriggerRec.Name == 'Price Start' && (capRecord.Effective_Date__c == clientAvailRec.Start_Date__c )) || 
                                      (annTriggerRec.Name == 'Price End'  && (capRecord.Expiry_Date__c == clientAvailRec.End_Date__c|| (isLastInList && capRecord.RecordType.Name == WB_PriceUtility.PERM_PRICE_RT_NAME)))){
                                       clientActivity.Change_Status__c='Change';
                                   }else
                                        clientActivity.Change_Status__c =  annTriggerRec.Changed_Status__c;
                                } 
                           }else{
                           
                           if((annTriggerRec.Name == 'Price Start' && (capRecord.Effective_Date__c == clientAvailRec.Start_Date__c)) || 
                                 (annTriggerRec.Name == 'Price End'  && (capRecord.Expiry_Date__c == clientAvailRec.End_Date__c|| (isLastInList && capRecord.RecordType.Name == WB_PriceUtility.PERM_PRICE_RT_NAME)))){
                                
                                clientActivity.Change_Status__c='Change';
                                
                            }else
                                clientActivity.Change_Status__c = annTriggerRec.Changed_Status__c;
                        }
                       clientActivity.Changed_Fields__c=clientActivity.Changed_Fields__c+','+annTriggerRec.Changed_Field__c; 
                        
                    }
                }
            }
           
        }
   
        
        if(clientActivity.Change_Status__c !='' && (clientActivity.Change_Status__c == 'Change' || clientActivity.Change_Status__c == 'Price Change'|| clientActivity.Change_Status__c == 'Price Start'||clientActivity.Change_Status__c == 'Price End')){
               
                 if(clientActivity.Changed_Fields__c.indexOf(',', 0) == 0){
                    clientActivity.Changed_Fields__c = clientActivity.Changed_Fields__c.substring(1, clientActivity.Changed_Fields__c.length());  
                    //Milon commenting the below line as requested by David "Change Fields had double spaces between fields"
                    //clientActivity.Changed_Fields__c = clientActivity.Changed_Fields__c.replaceAll(',',', ');  
                 }
                 clientActivity.Changed_Fields__c = clientActivity.Changed_Fields__c.replaceAll(',',', '); 
                
             }          
             
             
             if (clientActivity.Change_Status__c == '' || clientActivity.Change_Status__c == NULL ){
                clientActivity.Change_Status__c = 'No Change';
             } 
            
             
             return clientActivity;
    
   }
   
   public Boolean checkForForceOrSuppress(client_avail__c clientAvailRec,Client_Avail_Price__c capRecord,Announcement_Record__c annRecOnCA,Announcement__c annRecordSingle,Integer CAPcount){
      if((capRecord.Effective_Date__c <= System.Today() && capRecord.Expiry_Date__c >= System.Today()) || ((CAPcount == 0 || annRecOnCA!=null) && capRecord.Expiry_Date__c >= System.Today().addDays(-45))){ //ER-003090
          return true;
      }else{
        return false; 
      }
      
   }
   
   public void assignCaCapValues(Client_Avail__c ca,Announcement_Record__c annRec){
       
       if(ca != null && annRec != null){
           
           annRec.EMA_MA_ID__c = ca.EMA_DMA_ID_Formula__c;
       }
   }
   
   
   //Added by Tejasvini
   public void caChangesOnAnnouncementRecords(Announcement_Record__c arRec,Map<String,String> caChangedFieldsMap){
       
       String changedStatus = '';
        
       if(arRec.Changed_Fields__c != null){
           for(String val : arRec.Changed_Fields__c.split(',') ){
                val = val.trim();
                if(caOptionalFieldsSet.contains(val)){
                    
                     if(changedStatus == '')
                        changedStatus = changedStatus+val;
                    else
                        changedStatus = changedStatus+', '+val;
                }
           }
           //Changed Field track for CA
            if(!caChangedFieldsMap.containsKey(arRec.Client_Avail__c))
                caChangedFieldsMap.put(arRec.Client_Avail__c,changedStatus);
       }
       
  }
   
   public static void updateAnnouncementEndDate(Announcement__c announcement,Client_Avail__c CA,Announcement_Record__c annR,Announcement_Record__c prevAnnRec){
        
        annR.Client_End__c = CA.End_Date__c;
        if(annR.Change_Status__c!=null && annR.Changed_Fields__c!= null){
            //Only for Change Status and last in the list but CA-End Date not changed
            
            if(prevAnnRec!=null && prevAnnRec.Client_End__c == CA.End_Date__c){
                if(annR.Changed_Fields__c.contains('End Date')){
                    if( annR.Change_Status__c == 'Price Change' ){
                        annR.Changed_Fields__c = annR.Changed_Fields__c.remove('End Date');
                    }else if(annR.Change_Status__c == 'Price End' || annR.Change_Status__c == 'Change'){
                        
                        if(annR.Changed_Fields__c.containsOnly('End Date')){
                            annR.Change_Status__c = 'No Change';
                            annR.Changed_Fields__c = '';
                            annR.Changed_Fields__c = annR.Changed_Fields__c.remove('End Date');
                        }else{
                            annR.Changed_Fields__c = annR.Changed_Fields__c.remove('End Date');
                            if(annR.Changed_Fields__c.contains('Start Date')){
                                if(annR.Client_Start__c == CA.Start_Date__c){
                                    annR.Change_Status__c = 'Change';   
                                }else{
                                    annR.Change_Status__c = 'Price Start';
                                }
                            }else{
                                annR.Change_Status__c = 'Change';
                            }
                        }
                    }
                }
            }/*else if (prevAnnRec!=null && prevAnnRec.Client_End__c != CA.End_Date__c && capRecord.Expiry_Date__c != CA.End_Date__c){
                annR.Change_Status__c = 'Price Change';
            }*/
           
           
          
            
            if(annR.Changed_Fields__c.contains(', ,')){
                annR.Changed_Fields__c=annR.Changed_Fields__c.replace(', ,',',');
                
            }
            
            if(String.isBlank(annR.Changed_Fields__c.substringAfterLast(','))){
                annR.Changed_Fields__c = annR.Changed_Fields__c.trim();
                annR.Changed_Fields__c = annR.Changed_Fields__c.removeEnd(',');
            }
            if(annR.Changed_Fields__c.indexOf(',', 0) == 0){
                annR.Changed_Fields__c = annR.Changed_Fields__c.substring(1, annR.Changed_Fields__c.length());  
            }
            annR.Changed_Fields__c = annR.Changed_Fields__c.replaceAll(',',', '); 
            
        }
       
   }
    
    /**
        This method splits/adjusts dates of PERM Cap records if there is a TEMP cap overlappaing it. Retruns List of contiguous caps.
    */
    public List<Client_Avail_Price__c> getOrderedCAPList(Client_Avail__c caRecord, Boolean isTempPrice){
        
        //Code to handle overlapping TEMP caps - Start
        List<Client_Avail_Price__c> allCapsList = new List<Client_Avail_Price__c>();
        Client_Avail_Price__c prevCap = null;
        if(isTempPrice){
            for(Client_Avail_Price__c cap : caRecord.Client_Avail_Prices__r){
                if(cap.RecordType.Name == WB_PriceUtility.PERM_PRICE_RT_NAME){
                    prevCap = cap;
                    allCapsList.add(cap);
                }else if(cap.RecordType.Name == WB_PriceUtility.TEMP_PRICE_RT_NAME){
                    if(prevCap == null || prevCap.RecordType.Name == WB_PriceUtility.PERM_PRICE_RT_NAME){
                        prevCap = cap;
                        allCapsList.add(cap);
                    }else{
                        if(prevCap.Expiry_Date__c < cap.Effective_Date__c){
                            prevCap = cap;
                            allCapsList.add(cap);
                        }else{
                            if(prevCap.Expiry_Date__c < cap.Expiry_Date__c){
                                if(prevCap.Effective_Date__c <= cap.Effective_Date__c){
                                    cap.Effective_Date__c = prevCap.Expiry_Date__c.adddays(1);
                                }
                                allCapsList.add(cap);
                                prevCap = cap;
                            }else if(prevCap.Expiry_Date__c > cap.Expiry_Date__c){
                                if(prevCap.Effective_Date__c < cap.Effective_Date__c){ //split
                                    Client_Avail_Price__c splitCap = prevCap.clone(true,false,true,true);
                                    prevCap.Expiry_Date__c = cap.Effective_Date__c.addDays(-1);
                                    splitCap.Effective_Date__c = cap.Expiry_Date__c.adddays(1);
                                    allCapsList.add(cap);
                                    allCapsList.add(splitCap);
                                    prevCap = splitCap;
                                }else{
                                    prevCap.Effective_Date__c = cap.Expiry_Date__c.adddays(1);
                                    allCapsList.remove(allCapsList.size()-1);
                                    allCapsList.add(cap);
                                    allCapsList.add(prevCap);
                                }
                            }else{
                                if(prevCap.Effective_Date__c < cap.Effective_Date__c){
                                    prevCap.Expiry_Date__c = cap.Effective_Date__c.addDays(-1); 
                                }
                                allCapsList.add(cap);
                                prevCap = cap;
                            }
                        } 
                    }
                }
            }
        }else{
            allCapsList = caRecord.Client_Avail_Prices__r;
        }
        //Code to handle overlapping TEMP caps - End
        
        List<Client_Avail_Price__c> capList = new List<Client_Avail_Price__c>();
        prevCap = null;
        for(Client_Avail_Price__c cap : allCapsList){
                if(!isTempPrice && cap.RecordType.Name == WB_PriceUtility.TEMP_PRICE_RT_NAME){
                    continue;
                }
                
                if(prevCap == null){
                    prevCap = cap;
                    capList.add(cap);
                }else{
                    if(cap.RecordType.Name == WB_PriceUtility.PERM_PRICE_RT_NAME && prevCap.RecordType.Name == WB_PriceUtility.TEMP_PRICE_RT_NAME  ){
                        if(cap.Expiry_Date__c > prevCap.Expiry_Date__c){
                            cap.Effective_Date__c = prevCap.Expiry_Date__c.addDays(1);
                            capList.add(cap);
                            prevCap = cap;
                        }
                    }else if( prevCap.RecordType.Name == WB_PriceUtility.PERM_PRICE_RT_NAME && cap.RecordType.Name == WB_PriceUtility.TEMP_PRICE_RT_NAME){
                        if(cap.Effective_Date__c > prevCap.Effective_Date__c){
                            if(cap.Expiry_Date__c < prevCap.Expiry_Date__c){
                                Client_Avail_Price__c splitCap = prevCap.clone(true,false,true,true);
                                prevCap.Expiry_Date__c = cap.Effective_Date__c.addDays(-1);
                                splitCap.Effective_Date__c = cap.Expiry_Date__c.addDays(1);
                                capList.add(cap); 
                                capList.add(splitCap);
                                prevCap = splitCap;
                            }else{
                                prevCap.Expiry_Date__c = cap.Effective_Date__c.addDays(-1);
                                capList.add(cap);
                                prevCap = cap;
                            }
                        }else if(cap.Expiry_Date__c < prevCap.Expiry_Date__c){
                            prevCap.Effective_Date__c = cap.Expiry_Date__c.addDays(1);
                            capList.remove(capList.size()-1);
                            capList.add(cap);
                            capList.add(prevCap);
                        //  prevCap = cap;
                        }else{
                            capList.remove(capList.size()-1);
                            capList.add(cap);
                            prevCap = cap;
                        }
                    }else{
                        capList.add(cap);
                        prevCap = cap;
                    }
                }
            
        }
        return capList;
   }
   
   /**
    This method returns Map of previous announcement records of each cap of an avail. If there are multiple announcement records for a cap it id due to temp cap record.
    If temp cap is deleted and there is announcement record, the perm cap gets one announcement record in map(by merging both of its previous announcement records).
   */
   public Map<String,Announcement_Record__c> populateCAPAnnouncementRecords(Client_Avail__c caRecord,List<Client_Avail_Price__c> capList,Set<String> mergedCapSet){
        Map<String,Announcement_Record__c> capAnnouncementRecordMapFinal = new Map<String,Announcement_Record__c>();
        
        Map<String,Client_Avail_Price__c> capIdDateKeyMap = new Map<String,Client_Avail_Price__c>();
        Map<String,List<Client_Avail_Price__c>> splitCapMap = new Map<String,List<Client_Avail_Price__c>>();
        Map<String,List<AnnouncementRecordWrapper>> annRecordListByCAPMap = new Map<String,List<AnnouncementRecordWrapper>>();
        
        for(Client_Avail_Price__c cap : caRecord.Client_Avail_Prices__r){
            
            String key = String.valueof(caRecord.Id);   
            key += String.valueof(cap.Id);
            
            if(annRecordListByCAPMap.get(cap.Id) == null){
                annRecordListByCAPMap.put(cap.Id,new List<AnnouncementRecordWrapper>());
            }
            
            if(splitCapMap.get(cap.Id) == null){
                splitCapMap.put(cap.Id,new List<Client_Avail_Price__c>());  
            }
            
            String announcementId = null;
            for(Announcement_Record__c annRecOnCA : caRecord.Announcement_Client_Avails__r){
                if(annRecOnCA.Client_Avail_Price__c == cap.Id || (annRecOnCA.Client_Avail_Price__c == null && cap.Effective_Date__c == caRecord.Start_Date__c && 					
																	annRecordListByCAPMap.get(cap.Id).size() ==0 )){
                    if(announcementId == null){
                        announcementId = annRecOnCA.Announcement__c;
                    }else if(announcementId != annRecOnCA.Announcement__c){
                        break;
                    }
                    
                    if(annRecOnCA.Client_Avail_Price__c == null)
                       annRecOnCA.Client_Avail_Price__c = cap.Id;
                       
                    annRecordListByCAPMap.get(cap.Id).add(new AnnouncementRecordWrapper(annRecOnCA));
                }
            }
            
            for(Client_Avail_Price__c splitCAP:capList){
                if(cap.Id == splitCAP.Id){
                    splitCapMap.get(cap.Id).add(splitCAP);
                    capIdDateKeyMap.put(key+String.valueof(splitCAP.Effective_Date__c),splitCAP);
                }
            }
        }
      
        
        for(Client_Avail_Price__c capRecord : caRecord.Client_Avail_Prices__r){
            
            String key = String.valueof(caRecord.Id);   
            key += String.valueof(capRecord.Id);
            
            List<Client_Avail_Price__c> splitCapList = splitCapMap.get(capRecord.Id);    
            List<AnnouncementRecordWrapper> capAnnRecWrapList = annRecordListByCAPMap.get(capRecord.Id);
            if(splitCapList.size() == 1){
                if(capAnnRecWrapList.size() > 0){
                    key += String.valueof(capRecord.Effective_Date__c);
                    capAnnouncementRecordMapFinal.put(key,capAnnRecWrapList[0].annrecord);
                }
            }else{
                
                capAnnRecWrapList.sort();
                
                Announcement_Record__c firstRecord = null;
                Announcement_Record__c lastRecord = null;
                Date splitCapStartDate = null;
                for(Client_Avail_Price__c splitCap:splitCapList){
                    
                    firstRecord = null;
                    lastRecord = null;
                    splitCapStartDate = splitCap.Effective_Date__c;
                    
                    for(AnnouncementRecordWrapper annRecWrapper:capAnnRecWrapList){
                        if(annRecWrapper.isProcessed)
                            continue;
                            
                        if(firstRecord == null){
                            firstRecord = annRecWrapper.annrecord;
                            lastRecord = firstRecord;
                            annRecWrapper.isProcessed = true;
                        }else{ 
                            if(capAnnRecWrapList.size() <= splitCapList.size() || capIdDateKeyMap.get(key+String.valueof(annRecWrapper.startDate)) != null){
                                break;
                            }
                            lastRecord = annRecWrapper.annrecord;
                            annRecWrapper.isProcessed = true;
                        } 
                    }//end announcement loop
                    
                    if(firstRecord != null){
                        if(lastRecord != null && firstRecord != lastRecord){
                            firstRecord.Client_End__c = lastRecord.Client_End__c;
                            mergedCapSet.add(key+String.valueof(splitCapStartDate));    
                        }
                        capAnnouncementRecordMapFinal.put(key+String.valueof(splitCapStartDate),firstRecord);
                    }
                }//end split cap loop
            }
        }//end cap loop
        
        
        return capAnnouncementRecordMapFinal;
   }
   
   //PreOrder Changes
   public List<Announcement_Record__c> createARForPreOrderCAP(Client_Avail__c CA,Map<String,Announcement_Record__c> mapCAANDCAPAnnRecord, Announcement__c announcement,List<Announcement_Rule__c> announcementRuleList,List<Client_Avail_Price__c> capList,List<Announcement_Trigger_Field__c> annFieldsList,Set<String> statusValues){
       
       date framedStart =  Date.Today().addDays(-45);
      date framedEnd =  Date.Today().addDays(120);
      date annExecu = Date.Today();
      List<Announcement_Record__c> announcementList = new List<Announcement_Record__c>(); 
      WB_compareLastAndFromDates1 wb = new WB_compareLastAndFromDates1(annFieldsList);
       if(capList != null && capList.size()>0){
         Boolean isPreOrderReprice = false;
         if((CA.Start_Date__c != null && CA.APO_Date__c != null) && CA.Start_Date__c > annExecu){
           for(Client_Avail_Price__c capRec : capList){
             String keyCAP = String.valueof(CA.Id)+String.valueof(capRec.id)+String.valueof(capRec.Effective_Date__c);
               Announcement_Record__c clientActivity = new Announcement_Record__c();
               
                  if((capRec.Effective_Date__c < CA.Start_Date__c) && (mapCAANDCAPAnnRecord.get(keyCAP) != null)){
                 clientActivity = compareLastAndFromDates(CA,announcement,announcementRuleList,capRec,mapCAANDCAPAnnRecord.get(keyCAP),false);
                            if(clientActivity != null && clientActivity.Change_Status__c != null && !clientActivity.Change_Status__c.contains('No Change')){
                   isPreOrderReprice = true;
                 }
               }
               if((capRec.Effective_Date__c == CA.Start_Date__c) && (mapCAANDCAPAnnRecord.get(keyCAP) != null) && isPreOrderReprice){
                 clientActivity = compareLastAndFromDates(CA,announcement,announcementRuleList,capRec,mapCAANDCAPAnnRecord.get(keyCAP),false);
                 if(clientActivity != null){
                   if(announcement.Selection_Criteria__c == 'Framed Delta'){
                     if((clientActivity.Change_Status__c =='No Change' || statusValues.contains(clientActivity.Change_Status__c ) )  &&
                                   ( ( CA.APO_Date__c >= framedStart && CA.APO_Date__c <= framedEnd && capRec.Type__c == WB_PriceUtility.FIRST && capRec.Effective_Date__c > annExecu ) ||
                                   ( capRec.Effective_Date__c >= framedStart && capRec.Effective_Date__c <= framedEnd ) ||
                                   ( capRec.Expiry_Date__c >= framedStart && capRec.Expiry_Date__c <= framedEnd ) 
                                 )){
                                   announcementList.add(clientActivity);
                     }
                   }
                   if(announcement.Selection_Criteria__c == 'Delta'){
                     if(clientActivity.Change_Status__c =='No Change' || statusValues.contains(clientActivity.Change_Status__c )){
                       announcementList.add(clientActivity);
                     }
                   }
                 }
               }
           }
         }
       }
      return announcementList;
   }
   
   
  public static void createErrorLog(Map<Id,String> caErrorMap, String Category){
         List<WB_CAS_ErrorLogger.ErrorLog> errorLogs = new List<WB_CAS_ErrorLogger.ErrorLog>();
         
         if(caErrorMap != null && caErrorMap.size()>0){
           
           for(Id caId: caErrorMap.keySet()){
             
             if(caErrorMap.get(caId) != null){
               WB_CAS_ErrorLogger.ErrorLog errorLogInstance = new  WB_CAS_ErrorLogger.ErrorLog();
                     errorLogInstance.recordId = caId;
                     errorLogInstance.errorCategory = Category;
                     errorLogInstance.errorDescription = caErrorMap.get(caId).left(252);
                     errorLogInstance.errorDescriptionLong = caErrorMap.get(caId).left(32000); 
                     errorLogInstance.objectName = caId.getSObjectType().getDescribe().getName();
                     errorLogs.add(errorLogInstance);
             }
           }
         }
         
         if(errorLogs != null && errorLogs.size()>0){
            WB_CAS_ErrorLogger.logError(errorLogs); 
         }
       
    }
   
   
   class AnnouncementRecordWrapper implements Comparable{
        Announcement_Record__c annrecord;
        Date startDate;
        Boolean isProcessed = false;
        public AnnouncementRecordWrapper(Announcement_Record__c annrecord){
            this.annrecord = annrecord;
            startDate  = annrecord.Client_Start__c;
        }
        
        public Integer compareTo(Object obj) {
            AnnouncementRecordWrapper annWrapper = (AnnouncementRecordWrapper) obj;
            
            try{
                if( startDate == annWrapper.startDate){
                    return 0;
                }else if(startDate < annWrapper.startDate){
                    return -1;
                }else{
                    return 1;
                }
            }catch(Exception ex){
                System.debug(LoggingLevel.INFO,'Exception in sorting'+ex.getMessage());
            }
            return 0;
        }
   }
   
}