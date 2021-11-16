/*
Created Date - 2 May 2017
Created By - Cognizant Team
Description - Batch will process Confirmed CA and finds EAD records matching the Key(VV,Country,Channel,Format) 
              If match found it will update the EAD field on EAD object if EAD field not equal to least Avail Start Date for CA record assoicated with Key
              If not found it will create new EAD record with 'Unlocked' status
              In the end it will clear flag on RPs  
Updated on    Updated by       Description
26 May 2018   CAS Support      Code updated as per the conditions mentioned in SINC1645373. 
*/

public class WB_Batch_UpdateEarliestAvailableDt implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
     String query = '';
     Integer batchSize ;
     private Static String STATUSUNLOCKED = 'Unlocked';
     private Static String STATUSLOCKED = 'Locked';
     
     
      // Schedulable interface
    public void execute(SchedulableContext ctx)  
    {   
        WB_Batch_UpdateEarliestAvailableDt sch = new WB_Batch_UpdateEarliestAvailableDt();
        database.executebatch(sch,batchSize);
    }
    //Constructor
    public WB_Batch_UpdateEarliestAvailableDt(Integer size){
        batchSize = size;
    }
    public WB_Batch_UpdateEarliestAvailableDt(){
    }
    
    //Start Method
    //Fetch Release plan records where IsClientAvailChanged is checked
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        ByPassAutomationRules__c byPass = new ByPassAutomationRules__c(SetupOwnerId = UserInfo.getUserId(), Active__c = true, name = 'test');
        insert byPass;

        String isWhereCondition = Label.WB_EAD_DailyBatch_Flag; //added on 1-Dec-2017  SINC1355400 
        if(isWhereCondition == 'FALSE')
            query = 'Select Id, Local_Title__r.Title__r.Video_Version__c, Country_Lookup__r.Country_Code2__c, Channel__c, Format__c, Playlist__c, IsClientAvailChanged__c from Commercial_Avail__c';
        else
            query = 'Select Id, Local_Title__r.Title__r.Video_Version__c, Country_Lookup__r.Country_Code2__c, Channel__c, Format__c, Playlist__c, IsClientAvailChanged__c from Commercial_Avail__c where IsClientAvailChanged__c = True';
            
        return Database.getQueryLocator(query);
    }

    //Execute Logic
    public void execute(Database.BatchableContext BC, List<Commercial_Avail__c> commAvailLst){
       
       Set<String> vvSet = new Set<String>();
       Set<String> countryCodeSet = new Set<String>();
       Set<String> channelSet = new Set<String>();
       Set<String> formatSet = new Set<String>();
       Set<String> playListSet = new Set<String>();
       set<String> uniqueEADSet = new Set<String>();
       set<Id> rpIdSet=new Set<Id>();
       
       List<Playlist_Content__c> plContent = new List<Playlist_Content__c>();
       
       for(Commercial_Avail__c commAvail: commAvailLst)
       {
           rpIdSet.add(commAvail.Id);
           vvSet.add(commAvail.Local_Title__r.Title__r.Video_Version__c);
           countryCodeSet.add(commAvail.Country_Lookup__r.Country_Code2__c);
           channelSet.add(commAvail.Channel__c);
           formatSet.add(commAvail.Format__c);
           if(commAvail.Playlist__c != NULL)
                playListSet.add(commAvail.Playlist__c);
       }
       if(playListSet != NULL && playListSet.size() > 0)
            plContent = [select id, Content_VV__c from Playlist_Content__c where Playlist__c =:playListSet];
        if(plContent != NULL && plContent.size() > 0)
            for(Playlist_Content__c plc : plContent)
                vvSet.add(plc.Content_VV__c);
        List<Client_Avail__c> caList=[SELECT Id,Local_Title__r.Title__r.Video_Version__c FROM Client_Avail__c WHERE Commercial_Avail__c =:rpIdSet];
        for(Client_Avail__c ca:caList)
            vvSet.add(ca.Local_Title__r.Title__r.Video_Version__c);
            
        //Clear the RP Flag
        List<Commercial_Avail__c> lstReleasePlanUpdateFlag = new List<Commercial_Avail__c>();
        for(Commercial_Avail__c releasePlan: commAvailLst){
            if(releasePlan.IsClientAvailChanged__c == true)
            {
                releasePlan.IsClientAvailChanged__c = false;
                lstReleasePlanUpdateFlag.add(releasePlan);
            }
        }
        database.update(lstReleasePlanUpdateFlag,false); //SINC1717495 - Added FALSE for partial updation 
        
        
        List<AggregateResult> scope = [Select Local_Title__r.Title__r.Video_Version__c,Local_Title__r.Title__c,Commercial_Avail__r.Country_Lookup__r.Country_Code2__c,Commercial_Avail__r.Country_Lookup__c,Commercial_Avail__r.Channel__c,
                                        Commercial_Avail__r.Format__c, MIN(Start_Date__c)minDate From Client_Avail__c Where Status__c = 'Confirmed' AND ((Local_Title__r.Title__r.Video_Version__c =: vvSet 
                                        AND Commercial_Avail__r.Country_Lookup__r.Country_Code2__c =: countryCodeSet AND Commercial_Avail__r.Channel__c =: channelSet AND 
                                        Commercial_Avail__r.Format__c =: formatSet) OR Commercial_Avail__c =:rpIdSet)
                                        Group by  Local_Title__r.Title__r.Video_Version__c,Local_Title__r.Title__c,
                                        Commercial_Avail__r.Country_Lookup__r.Country_Code2__c,Commercial_Avail__r.Country_Lookup__c,
                                        Commercial_Avail__r.Channel__c,Commercial_Avail__r.Format__c];
      
            
        Map<String,AggregateResult> mapkeyConfirmedClientAvail = new Map<String,AggregateResult>();
        List<Earliest_Avail_Date__c> lstEarliestAvailDt = new List<Earliest_Avail_Date__c>();
        
        Map<String,Earliest_Avail_Date__c> finalMapEarliestAvailDt = new Map<String,Earliest_Avail_Date__c>();
        List<Earliest_Avail_Date__c> finalLstEarliestAvailDt = new List<Earliest_Avail_Date__c>();
       
        for(AggregateResult ar : scope){
            
            String key = (string)ar.get('Video_Version__c') +'_'+ (string)ar.get('Country_Code2__c') +'_'+ (string)ar.get('Channel__c') +'_'+ (string)ar.get('Format__c');
            key = key.trim();
            if(!mapkeyConfirmedClientAvail.containskey(key))
                mapkeyConfirmedClientAvail.put(key,ar);
        
            else if((date)mapkeyConfirmedClientAvail.get(key).get('minDate') > (date)ar.get('minDate'))
                mapkeyConfirmedClientAvail.put(key,ar);
        }
        system.debug('+++++MapOfClientAvails:'+mapkeyConfirmedClientAvail);
        //Querying all EADs corresponding to attributes of IsClientAvailChanged RPs
        lstEarliestAvailDt = [Select Id,key__c ,Status__c,Earliest_Avail_Date__c ,Source__c //ER-001996 - new field added in query
                                from Earliest_Avail_Date__c 
                                where Video_Version__c =: vvSet AND Country_Code_2__c =: countryCodeSet 
                                AND Channel__c =: channelSet AND Format__c =: formatSet/* AND Status__c =: STATUSUNLOCKED*//* Condition removed for SINC1645373*/];
        
        Map<String,Earliest_Avail_Date__c> mapEarliestAvailDt = new Map<String,Earliest_Avail_Date__c>();
        for(Earliest_Avail_Date__c availDateRecord: lstEarliestAvailDt){
            uniqueEADSet.add(availDateRecord.key__c.trim());//For NULL date update logic if the only existing confirmed CA for a VV+Country+Channel+Format combination is deleted
            mapEarliestAvailDt.put(availDateRecord.key__c.trim(),availDateRecord);
        }
            
        
        for(String key: mapkeyConfirmedClientAvail.keySet()){
            if(mapEarliestAvailDt.containsKey(key)){
                Earliest_Avail_Date__c availDateRec = mapEarliestAvailDt.get(key);
                uniqueEADSet.remove(key);
                if(availDateRec.Status__c!=STATUSLOCKED){/*Condition Added for SINC1645373 */
                    if(availDateRec.Earliest_Avail_Date__c != (date)mapkeyConfirmedClientAvail.get(key).get('minDate')){
                            availDateRec.Earliest_Avail_Date__c =  (date)mapkeyConfirmedClientAvail.get(key).get('minDate');
                            //availDateRec.batch_id__c = batchId;
                            system.debug('availDateRec***'+availDateRec);
                            finalMapEarliestAvailDt.put(availDateRec.key__c,availDateRec);
                    }
                    //START : ER- 001996 : code snippet added to update the source to "Cilent avails" if existing source is not the same.
                    if(availDateRec.Source__c != Label.WB_EAD_Client_Avails_Source){
                        availDateRec.Source__c = Label.WB_EAD_Client_Avails_Source;
                        finalMapEarliestAvailDt.put(availDateRec.key__c,availDateRec);
                    }
                    //END : ER-001996
                }
            }
            else {
                Earliest_Avail_Date__c earliestAvailDtRecord  = new Earliest_Avail_Date__c();
                earliestAvailDtRecord.Status__c = STATUSUNLOCKED;
                earliestAvailDtRecord.Channel__c = (String) mapkeyConfirmedClientAvail.get(key).get('Channel__c');
                earliestAvailDtRecord.Title__c = (Id) mapkeyConfirmedClientAvail.get(key).get('Title__c');
                earliestAvailDtRecord.Country__c =  (Id) mapkeyConfirmedClientAvail.get(key).get('Country_Lookup__c');
                earliestAvailDtRecord.Format__c =  (String) mapkeyConfirmedClientAvail.get(key).get('Format__c');
                earliestAvailDtRecord.Earliest_Avail_Date__c = (Date) mapkeyConfirmedClientAvail.get(key).get('minDate');
                earliestAvailDtRecord.Key__c = (String) mapkeyConfirmedClientAvail.get(key).get('Video_Version__c') +'_'+ (String) mapkeyConfirmedClientAvail.get(key).get('Country_Code2__c') +'_'+(String) mapkeyConfirmedClientAvail.get(key).get('Channel__c') +'_'+(String) mapkeyConfirmedClientAvail.get(key).get('Format__c');
                //ER- 001996 : line of code added to update the source to "Cilent avails".
                earliestAvailDtRecord.Source__c = Label.WB_EAD_Client_Avails_Source;
                finalMapEarliestAvailDt.put(earliestAvailDtRecord.Key__c,earliestAvailDtRecord);
            }

        }
        
        //NULL date update logic if the only existing confirmed CA for a VV+Country+Channel+Format combination is deleted
        if(uniqueEADSet != NULL && uniqueEADSet.size() > 0){
           for(String uniqueKey : uniqueEADSet){
                Earliest_Avail_Date__c availDateRec2 = mapEarliestAvailDt.get(uniqueKey);
                //ER-001996 - Code check added to update the EAD to blank if the source of EAD record is 'Client Avails'.
                if(availDateRec2.Source__c == Label.WB_EAD_Client_Avails_Source){
                    availDateRec2.Earliest_Avail_Date__c = NULL;
                    finalMapEarliestAvailDt.put(availDateRec2.Key__c,availDateRec2);
                }
            } 
        }
            
        Schema.SObjectField f = Earliest_Avail_Date__c.Fields.Key__c;
        finalLstEarliestAvailDt.addAll(finalMapEarliestAvailDt.values());
        Database.UpsertResult[] resultAssAcc= database.upsert(finalLstEarliestAvailDt,f,false);
        system.debug('finalLstEarliestAvailDt****'+finalLstEarliestAvailDt);
        for (Database.UpsertResult sr : resultAssAcc) {
            if (!sr.isSuccess()){
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('EAD fields that affected this error: ' + err.getFields());
                }
            }
        }

        //Clear all variables
        mapkeyConfirmedClientAvail.clear();
        lstEarliestAvailDt.clear();
        finalMapEarliestAvailDt.clear();
        finalLstEarliestAvailDt.clear();
        mapEarliestAvailDt.clear();
        vvSet.clear();
        countryCodeSet.clear();
        channelSet.clear();
        formatSet.clear();
        playListSet.clear();
        uniqueEADSet.clear();
        plContent.clear();
    }

    public void finish(Database.BatchableContext BC) {
        ByPassAutomationRules__c bp = ByPassAutomationRules__c.getInstance(UserInfo.getUserId());
        delete bp;
    }

}