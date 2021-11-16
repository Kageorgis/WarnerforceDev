global without sharing class WB_Announcement_Full_Extract1 implements Database.Batchable<sObject>, database.stateful{

    list<Announcement__c> annList= new list<Announcement__c>();
    set<Id> announementIdSet = new set<Id>() ; 
    List<Announcement_Rule__c> announcementRuleList = new List<Announcement_Rule__c>();
    Set<String> vvCountry = new Set<String>();
    Set<Id> accnts = new Set<Id>();
  
  List<Announcement_Trigger_Field__c> annFieldsList = null;
    global WB_Announcement_Full_Extract1(list<Announcement__c> annList, List<Announcement_Rule__c> announcementRuleList, set<Id> announementIdSet,List<Announcement_Trigger_Field__c> annFields){
        this.annList = annList;
        this.announementIdSet = announementIdSet;
        this.announcementRuleList = announcementRuleList;
        annFieldsList = annFields;
    }     
    
    global Iterable<sObject> start(Database.BatchableContext BC){  
        
        list<Announcement_Record__c> annRecList = [SELECT Id, Client_Avail__c, Client_Avail__r.Client__c, Client_Avail__r.Id, Client_Avail__r.Title_Video_Version__c, Client_Avail__r.Release_Plan_Country__c, Status__c FROM Announcement_Record__c WHERE Announcement__c IN :annList];
        Map<String,List<Client_Avail__c>> mapClientAvail  = new Map<String,List<Client_Avail__c>>();
        set<Id> firstStepAvailIds = new Set<Id>();
        List<Announcement_Record__c> cancelledAnnouncements = new List<Announcement_Record__c>();
        Map<String,Announcement_Record__c> otherActiveInAnn = new Map<String,Announcement_Record__c>();        
        Map<String,Client_Avail__c> activeAvails = new Map<String,Client_Avail__c>();
        List<Announcement_Record__c> arUpdateList = new List<Announcement_Record__c>();

        for(Announcement_Record__c annRec : annRecList){
            vvCountry.add(annRec.Client_Avail__r.Title_Video_Version__c + '_' + annRec.Client_Avail__r.Release_Plan_Country__c);
            accnts.add(annRec.Client_Avail__r.Client__c);
            firstStepAvailIds.add(annRec.Client_Avail__r.Id);
            if(annRec.Status__c == 'Cancelled')
                cancelledAnnouncements.add(annRec);
            else
                otherActiveInAnn.put(annRec.Client_Avail__r.Title_Video_Version__c + '_' + annRec.Client_Avail__r.Release_Plan_Country__c,annRec);
        }
        
        Map<Id,Client_Avail__c> allAvails = new Map<Id,Client_Avail__c>([SELECT ID,
                            Release_Plan_Title__c, 
                            Client__c, 
                            Title_Alias__c,
                            CA_Content_Type__c, 
                            Release_Plan_Channel__c,
                            Release_Plan_Country__c, 
                            Local_Data__c, 
                            Local_Data_Rating__c,
                            Local_Data_Rating_System__c, 
                            EMA_LocalData_Season__c,
                            Local_Data_Num_of_Episodes__c,
                            Local_Title_Version_EIDR__c, 
                            Title_Abstract_EIDR__c,
                            RP_Language_Type__c,
                            Start_Date__c,
                            End_Date__c,Status__c,
                            Announce_Override__c,
                            APO_Date__c,
                            Announce_Date__c,
                            Local_Title_DVD_Release_Dt__c,
                            Local_DVD_Release_Date__c, //ER-1043
                            Local_Title_Theatrical_Release__c,
                            Local_Data_Category_Picklist__c,
                            Local_Edit_Version__c,                              //Added on 08-Feb-2017 for ER-844. This was missed in implementation.
                            Price_Tier_Text__c,
                            Price__c,
                            Episode_Price_Tier__c,
                            Episode_Price__c,
                            Episode_Number__c,                                  /*Added for RCE: ER-1037*/
                            Title__c,
                            Local_Title__r.Title__c,
                            Title_Video_Version__c,
                            EMA_LicenseType__c,
                            Change_Context__c,
                            First_Announcement_Change_Status__c,               //ER-1139 Return to Window changes
                            VV_Country__c,
                            Playlist__c,
                            EMA_DMA_ID_Formula__c,
                            EC_Available__c,Vendor_ID__c,
                            Client_Title_ID__c,EMA_BundleALIDs__c,
                            UPC__c,Local_Data_TV_Air_Date__c,
                            EMA_RatingReason__c,Local_Data_ALID__c,
                            EMA_AltID__c,
                            Local_TitleName__c 
                         FROM client_avail__c 
                        WHERE VV_Country__c IN :vvCountry 
                          AND Client__c IN :accnts
                          AND Release_Plan_Channel__c in: announcementRuleList[0].Channels__c.split(';') 
                          AND Status__c IN: announcementRuleList[0].Statuses__c.split(';') 
                          AND CA_Lifecycle__c LIKE 'Active%'
                          AND id NOT IN :firstStepAvailIds
                          AND CA_Content_Type__c IN: announcementRuleList[0].Content_Type__c.split(';')] );
                    
        for(Client_Avail__c ca : allAvails.values())
            activeAvails.put(ca.VV_Country__c,ca);
        
        for(Announcement_Record__c ar : cancelledAnnouncements){
            if(activeAvails.get(ar.Client_Avail__r.Title_Video_Version__c + '_' + ar.Client_Avail__r.Release_Plan_Country__c) == null &&
               otherActiveInAnn.get(ar.Client_Avail__r.Title_Video_Version__c + '_' + ar.Client_Avail__r.Release_Plan_Country__c) == null 
              ){
                ar.EMA_Entry_Type__c = 'Full Delete';
                arUpdateList.add(ar);
            }
            else {
                ar.Announce_Override__c = 'Suppress';
                arUpdateList.add(ar);
            }
        }
        update arUpdateList;

        return allAvails.values();
        
    }
    
    global void execute(Database.BatchableContext BC, list<sObject> scope){
        List<Announcement_Record__c> annRecordListFinal = new List<Announcement_Record__c>();
        WB_compareLastAndFromDates1 compare = new WB_compareLastAndFromDates1(annFieldsList);
        Map<String,String> caChangedFieldsMap = new Map<String,String>();
        Map<Id,String> caErrorMap = new Map<Id,String>();
        
        List<Client_Avail__c> caErrorList = new  List<Client_Avail__c>();
        Map<Id,Client_Avail__c> allAvails = new Map<Id,Client_Avail__c>([SELECT ID,
                            Release_Plan_Title__c, 
                            Client__c, 
                            Title_Alias__c,
                            CA_Content_Type__c, 
                            Release_Plan_Channel__c,
                            Release_Plan_Country__c, 
                            Local_Data__c, 
                            Local_Data_Rating__c,
                            Local_Data_Rating_System__c, 
                            EMA_LocalData_Season__c,
                            Local_Data_Num_of_Episodes__c,
                            Local_Title_Version_EIDR__c, 
                            Title_Abstract_EIDR__c,
                            RP_Language_Type__c,
                            Start_Date__c,
                            End_Date__c,Status__c,
                            Announce_Override__c,
                            APO_Date__c,
                            Announce_Date__c,
                            Local_Title_DVD_Release_Dt__c,
                            Local_DVD_Release_Date__c, //ER-1043
                            Local_Title_Theatrical_Release__c,
                            Local_Data_Category_Picklist__c,
                            Local_Edit_Version__c,                              //Added on 08-Feb-2017 for ER-844. This was missed in implementation.
                            Price_Tier_Text__c,
                            Price__c,
                            Episode_Price_Tier__c,
                            Episode_Price__c,
                            Episode_Number__c,                                  /*Added for RCE: ER-1037*/
                            Title__c,
                            Local_Title__r.Title__c,
                            Title_Video_Version__c,
                            EMA_LicenseType__c,
                            Change_Context__c,
                            First_Announcement_Change_Status__c,               //ER-1139 Return to Window changes
                            VV_Country__c,
                            Playlist__c,
                            EMA_DMA_ID_Formula__c,
                            EC_Available__c,Vendor_ID__c,
                            Client_Title_ID__c,EMA_BundleALIDs__c,
                            UPC__c,Local_Data_TV_Air_Date__c,
                            EMA_RatingReason__c,Title_ALID__c,
                            EMA_AltID__c,Local_TitleName__c,
                            (Select id,Price_Tier__c,Price__c,Episode_Price__c,Episode_Price_Tier__c,SR_Price__c,SR_Per_Episode__c,
                                Effective_Date__c,Expiry_Date__c,Pricing__c,CAP_Lifecycle__c,Type__c,RecordTypeId,RecordType.Name 
                              FROM Client_Avail_Prices__r where CAP_Lifecycle__c LIKE 'Active%' ORDER BY Effective_Date__c,RecordType.Name ASC
                            ),// Sprint 2 change
                            (
                                SELECT Id,Announcement_Run_Date__c,
                                    Announcement__c,
                                    Title__c,
                                    Local_Title__c,
                                    Global_Title__c,
                                    Local_Rating__c,
                                    Local_Rating_System__c,
                                    Local_Season__c,
                                    Local_Episode_Count__c,
                                    Local_Edit_Required__c,                     //Added on 08-Feb-2017 for ER-844. This was missed in implementation.
                                    Abstract_EIDR__c,
                                    Version_EIDR__c,
                                    Language_Type__c,
                                    Client_Start__c,
                                    Client_End__c,
                                    Status__c,
                                    Pre_Order_Date__c,
                                    Suppression_End_Date__c,
                                    Local_DVD_Release_Date__c,
                                    Local_Theatrical_Release_Date__c,
                                    Category__c,Price_Tier__c,
                                    WS_Cost__c,
                                    Episode_Number__c,                                  /*Added for RCE: ER-1037*/
                                    Episode_Price_Tier__c,
                                    Episode_Price__c,Change_Context__c,
                                    client_avail__c,Client_Avail_Price__c,
                                    CAP_Comment__c,CAP_Id__c,
                                    EMA_MA_ID__c,EC_Available_Flag__c,Vendor_ID__c,
                                    Retailer_Product_ID__c,Bundle_ALID__c,
                                    UPC__c,Local_TV_Air_Date__c,
                                    Rating_Reason__c,ALID__c,
                                    Alt_ID__c
                                FROM Announcement_Client_Avails__r
                                WHERE (NOT Sales_Channel__c LIKE 'PO%')  
                                  AND Change_Status__c != NULL //ER-993
                                ORDER BY createddate DESC Limit 50
                             )
                         FROM client_avail__c 
                        WHERE VV_Country__c IN :vvCountry 
                          AND Client__c IN :accnts
                          AND Release_Plan_Channel__c in :announcementRuleList[0].Channels__c.split(';') 
                          AND Status__c IN: announcementRuleList[0].Statuses__c.split(';') 
                          AND CA_Lifecycle__c LIKE 'Active%'
                          AND id IN :scope]);
        
        Boolean isTempPrice = false;
      
            
        
            if(announcementRuleList != null && announcementRuleList.size() > 0){
                if(announcementRuleList[0].Include_Promotional_Price__c){
                    isTempPrice = true;
                }
            }
            
        for(Client_Avail__c CA : allAvails.values()){
            try{
                List<Announcement_Record__c> clientActivityList = new List<Announcement_Record__c>();
                
                Set<String> mergedCapSet = new Set<String>();
             List<Client_Avail_Price__c> capList = compare.getOrderedCAPList(CA,isTempPrice);
             Map<String,Announcement_Record__c> mapCAANDCAPAnnRecord = compare.populateCAPAnnouncementRecords(CA,capList,mergedCapSet);
             
                if(annList != null && annList.size() > 0){
                    Integer CAPcount = 0;
                    Map<String,Client_Avail_Price__c> mapAnnRecCAP = new Map<String,Client_Avail_Price__c>();
                    for(Client_Avail_Price__c cap : capList){
                        
                        if(cap.Effective_Date__c < CA.Start_Date__c)
                          continue;
                          
                        String keyCAP = String.valueof(CA.id)+String.valueof(cap.id)+String.valueof(cap.Effective_Date__c);
                        
                        Announcement_Record__c clientActivity = null;
                        Announcement_Record__c annRecOnCA = null;
                        
                        if(mapCAANDCAPAnnRecord.get(keyCAP) != null){
                           annRecOnCA = mapCAANDCAPAnnRecord.get(keyCAP);
                           clientActivity = compare.compareLastAndFromDates(CA,annList[0],announcementRuleList,cap,annRecOnCA,false);
                           
                           if(mergedCapSet.contains(keyCAP)){
                             clientActivity.Change_Status__c = 'Price Change';  
                         }
                          
                        }else{
                          clientActivity = new Announcement_Record__c();
                          clientActivity.Announcement__c = annList[0].Id;
                          clientActivity.Client_Avail__c = CA.Id;
                          clientActivity.Client_Avail_Price__c = cap.id;
                          clientActivity.Playlist__c = CA.Playlist__c;
                          clientActivity.Client_Start__c = cap.Effective_Date__c;
                          clientActivity.Client_End__c = cap.Expiry_Date__c;
                          
                          compare.assignCaCapValues(CA,clientActivity);
                          
                          if(CAPcount == 0 && (cap.Effective_Date__c == CA.Start_Date__c || cap.Type__c == 'First' )){ //CAP Release2 sprint 1 changes
                            if(CA.First_Announcement_Change_Status__c == 'Return'){         //ER-1139 Return to Window changes start
                                clientActivity.Change_Status__c = 'Return';       
                            }else 
                                clientActivity.Change_Status__c = 'New';                    //ER-1139 Return to Window changes end
                          }else{
                            clientActivity.Change_Status__c = 'Price Start';
                          }
                        }
                        
                        if( clientActivity!=null && (/*cap.CAP_Lifecycle__c == 'Active Current'*/ (cap.Effective_Date__c <= System.Today() && cap.Expiry_Date__c >= System.Today()) || annRecOnCA!=null || CAPcount == 0)){
                           clientActivityList.add(clientActivity);
                        }
                       CAPcount++;
                       mapAnnRecCAP.put(cap.Id+String.valueOf(cap.Effective_Date__c),cap);
                       
                       if((cap.Effective_Date__c > CA.Start_Date__c) ){
                           WB_PriceUtility.announcementRecordChanges(clientActivity);
                        }
                    }
                    Announcement_Record__c lastAnnouncement;
                    if(clientActivityList.size()>0){
                        lastAnnouncement = clientActivityList[clientActivityList.size()-1];
                      if(lastAnnouncement.Client_End__c != CA.End_Date__c){
                        Client_Avail_Price__c lastCap =  mapAnnRecCAP.get(String.valueOf(lastAnnouncement.Client_Avail_Price__c)+String.valueOf(lastAnnouncement.Client_Start__c));
                        String prevAnnRecKey = String.valueOf(lastAnnouncement.Client_Avail__c);
                          prevAnnRecKey += String.valueOf(lastAnnouncement.Client_Avail_Price__c);
                          prevAnnRecKey += lastCap!= null?String.valueOf(lastCap.Effective_Date__c):'';
                          Announcement_Record__c prevAnnRec = mapCAANDCAPAnnRecord.get(prevAnnRecKey);
                          WB_compareLastAndFromDates1.updateAnnouncementEndDate(annList[0],CA,lastAnnouncement,prevAnnRec);
                      }  
                    }
                    
                }
                
                for(Integer index=0;index < clientActivityList.size();index++){
                
                Announcement_Record__c annRecForLabel = clientActivityList[index];
                if(index == 0){
                  
                  compare.caChangesOnAnnouncementRecords(annRecForLabel,caChangedFieldsMap);
                }else if(annRecForLabel.Change_Status__c == 'Price Start' && (annRecForLabel.Changed_Fields__c == '' || annRecForLabel.Changed_Fields__c == null)){
                    
                  if(caChangedFieldsMap.get(annRecForLabel.Client_Avail__c) != null)
                      annRecForLabel.Changed_Fields__c = caChangedFieldsMap.get(annRecForLabel.Client_Avail__c);
                }
              }
                annRecordListFinal.addAll(clientActivityList);
            }catch(Exception e) {
              system.debug('Exception in working with Full Extract Avail - Exception Reason: '+e);
              caErrorMap.put(CA.Id, e.getMessage());
        }
        }
        
         if(annRecordListFinal != null && annRecordListFinal.size()>0){
      
    WB_ClientAvailPriceHandler.recursiveInsert = true;
      Database.Saveresult[] saveResult_CActivity = Database.insert(annRecordListFinal, false);
      for(Integer index = 0; index < saveResult_CActivity.size();index++){
      
        Database.SaveResult insertResult = saveResult_CActivity[index];
        if(!insertResult.isSuccess()){
          String errorMessage = '';
          Id caId;
          for(Database.Error err : insertResult.getErrors()) {
                  errorMessage += err.getMessage();
              }
          caId = annRecordListFinal[index].Client_Avail__c;
          if(!caErrorMap.containsKey(caId))
                  caErrorMap.put(caId, errorMessage);
              
        }
      }
      
      
      integer count =0;
          For(Database.Saveresult s : saveResult_CActivity)
          {
              if(s.isSuccess())
                  count++;
              else
                  system.debug(s.getErrors());
          }
           system.debug('countBatch ===: ' + count);
      
      }
         
       if(caErrorMap != null && caErrorMap.size()>0){
        WB_compareLastAndFromDates1.createErrorLog(caErrorMap,'Full Extract');
    }  
         
        
    }

    global void finish(Database.BatchableContext BC){
      Database.executeBatch(new WB_Announcement_PreOrders (annList,announcementRuleList,announementIdSet,annFieldsList), 200); 
        //Database.executeBatch(new WB_Announcement_Pre_Orders (annList,announcementRuleList,announementIdSet), 200);  
   }
        
}