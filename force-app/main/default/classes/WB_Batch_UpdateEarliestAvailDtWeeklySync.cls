/*
Created Date - 5 May 2017
Created By - Cognizant Team
Description - Batch will process finds EAD records with unlocked status
              Then fetches matched Confirmed CA with Key on EAD with least Avail Start date
              If derived date does not match with EAD then update date with derived date.
              If not found confirmed CA it will update EAD record's Date with NULL.
              
*/

public class WB_Batch_UpdateEarliestAvailDtWeeklySync implements Database.Batchable<sObject>,Schedulable {
    String query = '';
    Integer batchSize ;
    
    public void execute(SchedulableContext ctx)  
    {   
        WB_Batch_UpdateEarliestAvailDtWeeklySync sch = new WB_Batch_UpdateEarliestAvailDtWeeklySync();
        database.executebatch(sch,50);
    }
    
    //Constructor
    public WB_Batch_UpdateEarliestAvailDtWeeklySync(){}

    public WB_Batch_UpdateEarliestAvailDtWeeklySync(Integer size){
        batchSize = size;
    }
    //fetch EAD object’s unlocked records
    public Database.QueryLocator start(Database.BatchableContext bc){
        //ER-001996 - added 'Source__c' field in query.
        query = 'SELECT id,Video_Version__c,Country_Code_2__c,Earliest_Avail_Date__c,Channel__c,Format__c, key__c,Source__c FROM Earliest_Avail_Date__c WHERE Status__c = \'Unlocked\'';
        return Database.getQueryLocator(query);
        
    }
    //Execute Logic
    public void execute(Database.BatchableContext BC, List<Earliest_Avail_Date__c> lstEarlyAvailDt){
        
        Map<String,Earliest_Avail_Date__c> mapKeyEarliestAvailDt = new Map<String,Earliest_Avail_Date__c>();
        Map<String,AggregateResult> mapkeyConfirmedClientAvail = new Map<String,AggregateResult>();
        Map<String,Earliest_Avail_Date__c> finalMapEarliestAvailDt = new Map<String,Earliest_Avail_Date__c>();
        
        Set<String> setVideoVersion = new Set<String>();
        Set<String> setCountryCode = new Set<String>();
        Set<String> setChannel = new Set<String>();
        Set<String> setFormat = new Set<String>();
        
        for(Earliest_Avail_Date__c earlyAvailDt : lstEarlyAvailDt){
            setVideoVersion.add(earlyAvailDt.Video_Version__c);
            setCountryCode.add(earlyAvailDt.Country_Code_2__c);
            setChannel.add(earlyAvailDt.Channel__c);
            setFormat.add(earlyAvailDt.Format__c);
            
            /*String key = earlyAvailDt.Video_Version__c.trim() +'_'+ earlyAvailDt.Country_Code_2__c.trim() +'_'+ earlyAvailDt.Channel__c.trim() +'_'+ earlyAvailDt.Format__c.trim();
            key = key.trim();
            if(!mapKeyEarliestAvailDt.containsKey(key))*/
                mapKeyEarliestAvailDt.put(earlyAvailDt.key__c,earlyAvailDt);
        }
            
        //fetch CA for Key
        List<AggregateResult> scope = [ SELECT Local_Title__r.Title__c,//Commercial_Avail__r.Title__c,
                                        Commercial_Avail__r.Country_Lookup__r.Country_Code2__c,
                                        Commercial_Avail__r.Country_Lookup__c,
                                        MIN(Start_Date__c)minDate,Local_Title__r.Title__r.Video_Version__c,Commercial_Avail__r.Channel__c,Commercial_Avail__r.Format__c  
                                        FROM Client_Avail__c
                                        WHERE Status__c = 'Confirmed' 
                                        AND Commercial_Avail__r.Country_Lookup__r.Country_Code2__c IN: setCountryCode 
                                        AND Commercial_Avail__r.Channel__c IN:setChannel
                                        AND Commercial_Avail__r.Format__c  IN: setFormat
                                        AND Local_Title__r.Title__r.Video_Version__c IN: setVideoVersion
                                        Group BY Local_Title__r.Title__r.Video_Version__c, Local_Title__r.Title__c,Commercial_Avail__r.Country_Lookup__r.Country_Code2__c,
                                        Commercial_Avail__r.Country_Lookup__c,//Commercial_Avail__r.Title__c,
                                        Commercial_Avail__r.Channel__c,Commercial_Avail__r.Format__c];
        system.debug('scope****'+scope);
        
        for(AggregateResult ar: scope){
            //String key = ar.Title_Video_Version__c.trim() +'_'+ ar.Commercial_Avail__r.Country_Lookup__r.Country_Code2__c.trim() +'_'+ ar.Release_Plan_Channel__c.trim() +'_'+ ar.Release_Plan_Format__c.trim();
            String key = (String)ar.get('Video_Version__c')+'_'+(String)ar.get('Country_Code2__c')+'_'+(String)ar.get('Channel__c')+'_'+(String)ar.get('Format__c');
            key = key.trim();
            if(!mapkeyConfirmedClientAvail.containsKey(key))
                mapkeyConfirmedClientAvail.put(key,ar);
            else if((date)mapkeyConfirmedClientAvail.get(key).get('minDate') > (date)ar.get('minDate'))
                mapkeyConfirmedClientAvail.put(key,ar);
        }
        system.debug('mapkeyConfirmedClientAvail***'+mapkeyConfirmedClientAvail);
        //Check if Client Avail find for key in EAD
       for(String keyInAvailDt: mapKeyEarliestAvailDt.keyset()){
            //if(mapKeyEarliestAvailDt.get(keyInAvailDt) != NULL){
                Earliest_Avail_Date__c availDtRec = mapKeyEarliestAvailDt.get(keyInAvailDt);
                if(mapkeyConfirmedClientAvail.containsKey(keyInAvailDt)) {
					if((Date)mapkeyConfirmedClientAvail.get(keyInAvailDt).get('minDate') != availDtRec.Earliest_Avail_Date__c){
						availDtRec.Earliest_Avail_Date__c = (Date)mapkeyConfirmedClientAvail.get(keyInAvailDt).get('minDate');
						finalMapEarliestAvailDt.put(availDtRec.key__c,availDtRec);
                   	}
                   	//START : ER-001996 - code snippet added to update source field on EAD to 'Client Avails' if Client avail exists for the EAD.
                   	if(availDtRec.Source__c != Label.WB_EAD_Client_Avails_Source){
                   	    availDtRec.Source__c = Label.WB_EAD_Client_Avails_Source;
                   	    finalMapEarliestAvailDt.put(availDtRec.key__c,availDtRec);
                   	}
                   	//END : ER-001996
                //ER-001996 - added extra check to update the Earliest avail date to blank only if source is "Client Avails".   
				}else if(availDtRec.Earliest_Avail_Date__c != NULL && availDtRec.Source__c == Label.WB_EAD_Client_Avails_Source){
					availDtRec.Earliest_Avail_Date__c = NULL;
					finalMapEarliestAvailDt.put(availDtRec.key__c,availDtRec);
				}
            //}
        }
        
         Database.SaveResult[]  results = database.update(finalMapEarliestAvailDt.values(),false);
         List<CAS_Error_Log__c> lstCasErrorLog = new List<CAS_Error_Log__c>();
         
         for ( Database.SaveResult sr : results)
         {
            if (!sr.isSuccess()){
                // Failed upsert and need to update response with error message and log error message - could be multiple
                for (Database.Error err : sr.getErrors())
                {
                    CAS_Error_Log__c CasErrorLog = new CAS_Error_Log__c();
                    // Update response
                    CasErrorLog.Error_Description__c = err.getMessage();
                    CasErrorLog.Object_Name__c= 'Earliest_Avail_Date__c';
                    CasErrorLog.Record_Id__c = sr.getId();
                     // Add to Error Log list
                    lstCasErrorLog.add(CasErrorLog);
                }
            }
        }
        if(lstCasErrorLog != NULL && lstCasErrorLog.size() > 0){
            try{
                insert lstCasErrorLog;
            }catch(exception e){
                system.debug('++++Following Error:'+e.getMessage());
            }
        }
            
        //Clear variables
        mapKeyEarliestAvailDt.clear();
        mapkeyConfirmedClientAvail.clear();
        finalMapEarliestAvailDt.clear();
        setVideoVersion.clear();
        setCountryCode.clear();
        setChannel.clear();
        setChannel.clear();
        setFormat.clear();
        scope.clear();
        lstCasErrorLog.clear();
    }
    public void finish(Database.BatchableContext BC) {}
    
}