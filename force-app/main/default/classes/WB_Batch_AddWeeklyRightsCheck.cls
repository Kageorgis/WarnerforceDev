/*******************************************************************************************************************************************
* File Name     :   WB_Batch_AddWeeklyRightsCheck
* Description   :   Batch class to link Rights to the release plan
* @author       :   CTS
* Modification Log
===================================================================================================------------------
* Ver.    Date              Author              Modification
------------------------------------------------------------------------------------------------------------------
* 1.0     15 Feb.2016        CTS                ER-000401 : Created the class. 
* 2.0     16 Nov 2016      Preeti jha(CTS)      Optimised the code and removed query from for loop keeping the existing functionalty same as previous.
* 3.0     07 Dec 2016      Purushottam (CTS)    changed new query on Title and optimized the code to handle System.LimitException: Too many DML rows: 10001
* 4.0     09 Dec 2016      Purushottam (CTS)    Reference No: SINC0757634 changed new query on Title and optimized the code to handle System.LimitException: Too many DML rows: 10001
* 5.0     20 July2018      Sameera (CTS) changed to add RightsId assignment based on rights recordtype (VBOM or MPM ) and releasePlan's title's MPM's generic flag. 
* 6.0     10 Oct 2018      Astha(CTS) changed query condition for filtering RPs (from AND to OR), included 'PhysicalPlanning = Yes'- Title records - ER-002455
********************************************************************************************************************************************/

public class WB_Batch_AddWeeklyRightsCheck implements Database.Batchable<sObject>,Database.Stateful,Schedulable {
    
    String query = '';
    Integer batchSize = Integer.valueOf(System.label.WB_AddWeeklyRightsCheck_BatchSize);
    
    // Schedulable interface
    public void execute(SchedulableContext ctx)  
    {   
        WB_Batch_AddWeeklyRightsCheck CA = new WB_Batch_AddWeeklyRightsCheck();
        database.executebatch(CA,batchSize);
    }
    
    // Constructor
    public WB_Batch_AddWeeklyRightsCheck() {}
    
    // Start Method
    public Database.QueryLocator start(Database.BatchableContext BC) {
        //query = 'SELECT Id, MPM__c FROM Title__c WHERE MPM__c != null';
        // String id = 'a04U000000X6L4y';
        // query = 'SELECT Id, MPM__c FROM Title__c WHERE MPM__c= :id';
        //Special Milon
        //List<Commercial_Avail__c > trplst = [SELECT Title__c FROM Commercial_Avail__c WHERE Rights_ID__c=null LIMIT 50000];
        //List<Commercial_Avail__c > trplst = [SELECT Title__c FROM Commercial_Avail__c WHERE Rights_ID__c=null AND Rights_GroupF__c in ('Lithuania','Hungary','Turkey','Estonia','Korea','Indonesia','Singapore','Taiwan','Bulgaria','Portugal','Philippines','Iceland','Israel','China','Malaysia')];       
        /*
        AggregateResult[] groupedResults = [SELECT Title__r.MPM__c FROM Commercial_Avail__c WHERE Rights_Check__c!='OK' GROUP BY Title__r.MPM__c Limit 50000];
        Set<Id> mpmLst = new Set<Id>();
        for (AggregateResult ar : groupedResults)  {
        mpmLst.add((Id)ar.get('Title__r.MPM__c'));
        }*/        
        //Set<Id> mpmSet = new Set<Id>();
        //List<Title__c > tltlst = [SELECT Id, MPM__c FROM Title__c WHERE MPM__c != null];
        //for(Title__c tlt : tltlst ){
        //     mpmSet.add(tlt.MPM__c);
        // }
       // query   = 'SELECT Id FROM MPM__c WHERE Id in (SELECT MPM__c FROM Title__c WHERE MPM__c != null)';              
       
       // Changed the query on 7-12-26 
       // query   = 'SELECT Id FROM MPM__c WHERE Id in (SELECT MPM__c FROM Title__c WHERE MPM__c != null AND Clear_to_Avail__c = True AND Digital_Planning__c = \'Yes\')'; 
       
       //Changed the query on 20-07-18 
       // query   = 'SELECT Id, Video_Version__c,MPM__c,MPM__r.Id FROM Title__c where (MPM__c != null OR Video_Version__c != null) AND Clear_to_Avail__c = True AND (Digital_Planning__c = \'Yes\' '+'OR Physical_Planning__c =\'Yes\')';  
        query   = 'SELECT Id, Video_Version__c,MPM__c,MPM__r.Id FROM Title__c where (MPM__c != null OR Video_Version__c != null) AND Clear_to_Avail__c = True AND (Digital_Planning__c = \'Yes\' '+'OR Physical_Planning__c =\'Yes\')';  
 
        return Database.getQueryLocator(query);
    }
    
    // Execute Logic
    public void execute(Database.BatchableContext BC, List<Title__c>scope){
        
        Set<Id> MPMIdSet = new Set<Id>();
        Set<String> VideoVersionSet = new Set<String>();
        map<Id, Commercial_Avail__c> mapIdToupdatedReleasePlan = new map<Id, Commercial_Avail__c>();        
        map<Id, Commercial_Avail__c> mapIdToupdatedReleasePlan2 = new map<Id, Commercial_Avail__c>();
        Map<ID,Schema.RecordTypeInfo> rtMapByName = Rights__c.sObjectType.getDescribe().getRecordTypeInfosById();
        
        // Created set of all the MPMIds which are used in Titles
        /*for(MPM__c mpm : scope) {
            MPMIdSet.add(mpm.Id);
        }*/
        
        for(Title__c title : scope) {
            MPMIdSet.add(title.MPM__r.Id);
            VideoVersionSet.add(title.Video_Version__c);
        }
        
        if(MPMIdSet != null && MPMIdSet.size() > 0) {
            String rightsCheckClause = System.Label.WB_Batch_RP_RightsCheckOK.equalsIgnoreCase('true') ? 'Rights_Check__c=\'OK\'' : 'Rights_Check__c!=\'OK\'';            
           // map<Id, List<Commercial_Avail__c>> mapMPMnReleasePlan = new map<Id,List<Commercial_Avail__c>>(); //commit later 
              map<Id, List<Commercial_Avail__c>> mapTitlenReleasePlan = new map<Id,List<Commercial_Avail__c>>();
            
            string query = 'SELECT Id,Name, Country_Lookup__c, Channel__c, Title__r.MPM__c, Rights_ID__c , Start_Date__c, End_Date__c, Title__r.Digital_Planning__c, Exclusive_Date__c, Rights_End__c, Languages__c,Rights_GroupF__c,Title__r.MPM__r.Id,Title__r.MPM__r.Generic__c,Title__r.Video_Version__c'
                            +' FROM Commercial_Avail__c'
                            //+' WHERE Title__r.MPM__c IN: MPMIdSet AND Channel__c != null AND Exclusive_Date__c != null AND Rights_End__c != null  AND Rights_GroupF__c != null AND '+ rightsCheckClause +' AND Rights_Mismatch__c = true';
                            +' WHERE Title__r.MPM__c IN: MPMIdSet AND Channel__c != null AND Exclusive_Date__c != null AND Rights_End__c != null  AND Rights_GroupF__c != null AND ('+rightsCheckClause +'OR Rights_Mismatch__c = true)';//Changed condition for rightsCheckClause - country ARUBA 
                          
                            
            
            
            List<Commercial_Avail__c> releasePlanList = Database.query(query);
            
            if(releasePlanList != null && releasePlanList.size() > 0){
                
              /*  for(Commercial_Avail__c releasePlan : releasePlanList){
                    
                    if(mapMPMnReleasePlan != null && mapMPMnReleasePlan.containsKey(releasePlan.Title__r.MPM__c)) {
                        List<Commercial_Avail__c> lstcommAvail = mapMPMnReleasePlan.get(releasePlan.Title__r.MPM__c);
                        lstcommAvail.add(releasePlan);
                        mapMPMnReleasePlan.put(releasePlan.Title__r.MPM__c, lstcommAvail);                    
                    } 
                    else {
                        mapMPMnReleasePlan.put(releasePlan.Title__r.MPM__c, new List<Commercial_Avail__c> { releasePlan });
                    }
                } */
                
                for(Commercial_Avail__c c:releasePlanList){
                    if(mapTitlenReleasePlan.containsKey(c.Title__c)) {
                        List<Commercial_Avail__c> releasePlan = mapTitlenReleasePlan.get(c.Title__c);
                        releasePlan.add(c);
                        mapTitlenReleasePlan.put(c.Title__c, releasePlan);
                        
                } 
                    else {
                        mapTitlenReleasePlan.put(c.Title__c, new List<Commercial_Avail__c> { c });
                    }
                } 
            
                map<Id, List<Rights__c>> mapMPMnRights = new map<Id,List<Rights__c>>();
                
                List<Rights__c> rightsList = [SELECT Id,Name, MPM__c, Rights_Group__c, Channel__c, Rights_Start__c, Rights_End__c, LastModifiedDate
                                              ,Rights_Start_2__c,Rights_End_2__c,Rights_Start_3__c,Rights_End_3__c,Rights_Start_4__c,Rights_End_4__c,Rights_Start_5__c,Rights_End_5__c,RecordTypeId,Title__c,Title__r.MPM__r.Id,Video_Version__c
                                              FROM Rights__c 
                                              WHERE (MPM__c IN :MPMIdSet OR Video_Version__c IN: VideoVersionSet) //MPM__c IN :MPMIdSet
                                              AND Rights_Group__c != null
                                              AND Channel__c != null
                                              ORDER BY LastModifiedDate DESC];
                
                if(rightsList != null && rightsList.size() > 0){
                    
                    for(Rights__c rights : rightsList){
                      /*  if(mapMPMnRights.containsKey(rights.MPM__c)) {
                            List<Rights__c> MPMrights = mapMPMnRights.get(rights.MPM__c);
                            MPMrights.add(rights);
                            mapMPMnRights.put(rights.MPM__c, MPMrights);                    
                        } 
                        else {
                            mapMPMnRights.put(rights.MPM__c, new List<Rights__c> { rights });
                        }*/
                        
                        //**
                            if(rights.recordTypeID != null){
                                If(rtMapByName.get(rights.recordTypeID).getName() != null){
                                    if(rtMapByName.get(rights.recordTypeID).getName() == 'VBOM'){
                                       if(mapMPMnRights.containsKey(rights.Title__c)) {
                                            List<Rights__c> MPMrights = mapMPMnRights.get(rights.Title__c);
                                            MPMrights.add(rights);
                                            mapMPMnRights.put(rights.Title__c, MPMrights);
                                        } 
                                        else {
                                            mapMPMnRights.put(rights.Title__c, new List<Rights__c> { rights });
                                        } 
                                    }
                                    else if(rtMapByName.get(rights.recordTypeID).getName() == 'MPM'){
                        if(mapMPMnRights.containsKey(rights.MPM__c)) {
                            List<Rights__c> MPMrights = mapMPMnRights.get(rights.MPM__c);
                            MPMrights.add(rights);
                            mapMPMnRights.put(rights.MPM__c, MPMrights);                    
                        } 
                        else {
                            mapMPMnRights.put(rights.MPM__c, new List<Rights__c> { rights });
                        }
                    } 
                                }
                            }
                        //**
                        
                    } 
            
                    // Checking for all the Release Plan
                    //for(ID MPM : mapMPMnReleasePlan.keyset()){
                      for(ID title : mapTitlenReleasePlan.keyset()){
                        
                       // if(mapMPMnReleasePlan!= null && mapMPMnReleasePlan.containsKey(MPM)){
                          if(mapTitlenReleasePlan!= null && mapTitlenReleasePlan.containsKey(title)){
                        
                            for(Commercial_Avail__c objRP : mapTitlenReleasePlan.get(title)) {
                           // for(Commercial_Avail__c objRP : mapMPMnReleasePlan.get(MPM)) {
                                String strRPKey = String.valueOf(objRP.Title__r.MPM__c);
                                Boolean strRPTitleMPMGen = objRP.Title__r.MPM__r.Generic__c;
                                
                                // Checking for all the Rights which are having MPM same as that of Release Plan
                                //if(mapMPMnRights != null && mapMPMnRights.containsKey(MPM)){
                            if (strRPTitleMPMGen){
                                if(mapMPMnRights != null && mapMPMnRights.size() != null && mapMPMnRights.get(title) != null ){
                                    
                                    //for(Rights__c objRight : mapMPMnRights.get(MPM)) {  
                                    for(Rights__c objRight : mapMPMnRights.get(title)) {
                                      //  if(objRP.Title__r.MPM__c != null && objRP.Channel__c != null && objRP.Rights_GroupF__c != null && objRP.Exclusive_Date__c != null && objRP.Rights_End__c != null && objRight.Rights_Group__c != null  &&  objRight.Channel__c != null && objRight.MPM__c != null && objRP.Title__r.MPM__c == objRight.MPM__c && objRP.Channel__c==objRight.Channel__c && objRP.Rights_GroupF__c  == objRight.Rights_Group__c){
                                          //****strRPTitleMPMGen && 
                                          if(objRP.Title__r.Video_Version__c != null && objRP.Channel__c != null && objRP.Rights_GroupF__c != null && objRP.Exclusive_Date__c != null && objRP.Rights_End__c != null && objRight.Rights_Group__c != null  &&  objRight.Channel__c != null && objRight.Video_Version__c != null && objRP.Title__r.Video_Version__c == objRight.Video_Version__c && objRP.Channel__c==objRight.Channel__c && objRP.Rights_GroupF__c  == objRight.Rights_Group__c){
                                               if((objRight.Rights_Start__c != null && objRight.Rights_End__c != null) || (objRight.Rights_Start_2__c != null && objRight.Rights_End_2__c != null) || (objRight.Rights_Start_3__c != null && objRight.Rights_End_3__c != null) || (objRight.Rights_Start_4__c != null && objRight.Rights_End_4__c != null)|| (objRight.Rights_Start_5__c != null && objRight.Rights_End_5__c !=  null)){
                                                      
                                                      if((objRP.Exclusive_Date__c <= objRight.Rights_End__c && objRP.Rights_End__c >= objRight.Rights_Start__c) || (objRP.Exclusive_Date__c <= objRight.Rights_End_2__c && objRP.Rights_End__c >= objRight.Rights_Start_2__c) || (objRP.Exclusive_Date__c <= objRight.Rights_End_3__c && objRP.Rights_End__c >= objRight.Rights_Start_3__c) || (objRP.Exclusive_Date__c <= objRight.Rights_End_4__c && objRP.Rights_End__c >= objRight.Rights_Start_4__c) || (objRP.Exclusive_Date__c <= objRight.Rights_End_5__c && objRP.Rights_End__c >= objRight.Rights_Start_5__c)){
                                                             
                                                             if(objRP.Rights_ID__c == null || objRP.Rights_ID__c != objRight.Id){
                                                                 objRP.Rights_ID__c = objRight.Id;                                                                 
                                                                 if(mapIdToupdatedReleasePlan.size() < 10000)
                                                                     mapIdToupdatedReleasePlan.put(objRP.Id, objRP);
                                                                 else
                                                                     mapIdToupdatedReleasePlan2.put(objRP.Id, objRP);
                                                             }
                                                             break;
                                                         } else {
                                                             if(objRP.Rights_ID__c == null || objRP.Rights_ID__c != objRight.Id){
                                                                 objRP.Rights_ID__c = objRight.Id;
                                                                 if(mapIdToupdatedReleasePlan.size() < 10000)
                                                                     mapIdToupdatedReleasePlan.put(objRP.Id, objRP);
                                                                 else
                                                                     mapIdToupdatedReleasePlan2.put(objRP.Id, objRP);
                                                             }                                                            
                                                         }
                                                  }else{
                                                      if(objRP.Rights_ID__c == null || objRP.Rights_ID__c != objRight.Id){
                                                          objRP.Rights_ID__c = objRight.Id;
                                                          if(mapIdToupdatedReleasePlan.size() < 10000)
                                                              mapIdToupdatedReleasePlan.put(objRP.Id, objRP);
                                                          else
                                                              mapIdToupdatedReleasePlan2.put(objRP.Id, objRP);
                                                      }                                                      
                                                  }
                                           }else if(objRP.Title__r.MPM__c != null && objRight.MPM__c != null && objRP.Title__r.MPM__c == objRight.MPM__c && objRight.Channel__c == null && objRight.Rights_Group__c == null){
                                               if(objRP.Rights_ID__c == null || objRP.Rights_ID__c != objRight.Id){
                                                   objRP.Rights_ID__c = objRight.Id;
                                                   if(mapIdToupdatedReleasePlan.size() < 10000)
                                                       mapIdToupdatedReleasePlan.put(objRP.Id, objRP);
                                                   else
                                                       mapIdToupdatedReleasePlan2.put(objRP.Id, objRP);
                                               }                                              
                                           }                               
                                    }
                                } // end of for loop right
                                else{                                       
                                        objRP.Rights_ID__c = null;
                                        system.debug('*****5 else if');
                                    }
                            }
                                
                            if(!mapIdToupdatedReleasePlan.containsKey(objRP.Id) || !mapIdToupdatedReleasePlan2.containsKey(objRP.Id)){
                                   //****** 
                                if (!strRPTitleMPMGen){   
                                        if(mapMPMnRights != null && mapMPMnRights.size() != null && mapMPMnRights.get(objRP.title__r.MPM__c) != null ){
                                    
                                        //for(Rights__c objRight : mapMPMnRights.get(MPM)) {  
                                            for(Rights__c objRight : mapMPMnRights.get(objRP.title__r.MPM__c)) {
                                                if(!strRPTitleMPMGen && objRP.Title__r.MPM__c != null && objRP.Channel__c != null && objRP.Rights_GroupF__c != null && objRP.Exclusive_Date__c != null && objRP.Rights_End__c != null && objRight.Rights_Group__c != null  &&  objRight.Channel__c != null && objRight.MPM__c != null && objRP.Title__r.MPM__c == objRight.MPM__c && objRP.Channel__c==objRight.Channel__c && objRP.Rights_GroupF__c  == objRight.Rights_Group__c){
                                               
                                               if((objRight.Rights_Start__c != null && objRight.Rights_End__c != null) || (objRight.Rights_Start_2__c != null && objRight.Rights_End_2__c != null) || (objRight.Rights_Start_3__c != null && objRight.Rights_End_3__c != null) || (objRight.Rights_Start_4__c != null && objRight.Rights_End_4__c != null)|| (objRight.Rights_Start_5__c != null && objRight.Rights_End_5__c !=  null)){
                                                      
                                                      if((objRP.Exclusive_Date__c <= objRight.Rights_End__c && objRP.Rights_End__c >= objRight.Rights_Start__c) || (objRP.Exclusive_Date__c <= objRight.Rights_End_2__c && objRP.Rights_End__c >= objRight.Rights_Start_2__c) || (objRP.Exclusive_Date__c <= objRight.Rights_End_3__c && objRP.Rights_End__c >= objRight.Rights_Start_3__c) || (objRP.Exclusive_Date__c <= objRight.Rights_End_4__c && objRP.Rights_End__c >= objRight.Rights_Start_4__c) || (objRP.Exclusive_Date__c <= objRight.Rights_End_5__c && objRP.Rights_End__c >= objRight.Rights_Start_5__c)){
                                                             
                                                             if(objRP.Rights_ID__c == null || objRP.Rights_ID__c != objRight.Id){
                                                                 objRP.Rights_ID__c = objRight.Id;                                                                 
                                                                 if(mapIdToupdatedReleasePlan.size() < 10000)
                                                                     mapIdToupdatedReleasePlan.put(objRP.Id, objRP);
                                                                 else
                                                                     mapIdToupdatedReleasePlan2.put(objRP.Id, objRP);
                                                             }
                                                             break;
                                                         } else {
                                                             if(objRP.Rights_ID__c == null || objRP.Rights_ID__c != objRight.Id){
                                                                 objRP.Rights_ID__c = objRight.Id;
                                                                 if(mapIdToupdatedReleasePlan.size() < 10000)
                                                                     mapIdToupdatedReleasePlan.put(objRP.Id, objRP);
                                                                 else
                                                                     mapIdToupdatedReleasePlan2.put(objRP.Id, objRP);
                                                             }                                                            
                                                         }
                                                  }else{
                                                      if(objRP.Rights_ID__c == null || objRP.Rights_ID__c != objRight.Id){
                                                          objRP.Rights_ID__c = objRight.Id;
                                                          if(mapIdToupdatedReleasePlan.size() < 10000)
                                                              mapIdToupdatedReleasePlan.put(objRP.Id, objRP);
                                                          else
                                                              mapIdToupdatedReleasePlan2.put(objRP.Id, objRP);
                                                      }                                                      
                                                  }
                                           }else if(objRP.Title__r.MPM__c != null && objRight.MPM__c != null && objRP.Title__r.MPM__c == objRight.MPM__c && objRight.Channel__c == null && objRight.Rights_Group__c == null){
                                               if(objRP.Rights_ID__c == null || objRP.Rights_ID__c != objRight.Id){
                                                   objRP.Rights_ID__c = objRight.Id;
                                                   if(mapIdToupdatedReleasePlan.size() < 10000)
                                                       mapIdToupdatedReleasePlan.put(objRP.Id, objRP);
                                                   else
                                                       mapIdToupdatedReleasePlan2.put(objRP.Id, objRP);
                                               }                                              
                                           }                               
                                    }
                                        } // end of for loop right
                                        else{                                       
                                            objRP.Rights_ID__c = null;
                                            system.debug('*****4 else if');
                                        }
                                
                                    }   //******
                                   
                                }
                            } //end of for loop RP
                        }
                    }//for loop MPMIdSet
                }
            }
        } //if MPMIdSet.size()
        
        if(mapIdToupdatedReleasePlan != null && mapIdToupdatedReleasePlan.size() > 0) {
            // Static variable used to avoid trigger invoke
            TestUtil.isRunning_WB_Batch_AddWeeklyRightsCheck = true;             
            system.debug('----------mapIdToupdatedReleasePlan----------'+mapIdToupdatedReleasePlan.size()+'====='+mapIdToupdatedReleasePlan);
            system.debug('----------mapIdToupdatedReleasePlan2----------'+mapIdToupdatedReleasePlan2.size()+'====='+mapIdToupdatedReleasePlan2);
            
            Database.Saveresult[] saveResult_RP  = Database.update(mapIdToupdatedReleasePlan.values(), false);
            system.debug('----------saveResult_RP----------'+saveResult_RP.size()+'====='+saveResult_RP);
            
            if(mapIdToupdatedReleasePlan2 != null && mapIdToupdatedReleasePlan2.size() > 0){
                Database.Saveresult[] saveResult_RP2  = Database.update(mapIdToupdatedReleasePlan2.values(), false);
                system.debug('----------saveResult_RP2----------'+saveResult_RP2.size()+'====='+saveResult_RP2);
            }                            
        }
    }//end of execute method
     
    public void finish(Database.BatchableContext BC) {
        //ER - 793
         //send Job information to users via email
         BatchStatusNotification batchNotification = new BatchStatusNotification();
         AsyncApexJob jobInfo = [SELECT Status,TotalJobItems,NumberOfErrors,ExtendedStatus 
                                 FROM AsyncApexJob 
                                 WHERE Id=:BC.getJobID()];
         if(jobInfo != NULL)
            batchNotification.sendEmailToUsers(Label.Entity_CAS,'Daily Rights Check',jobInfo.Status,jobInfo.TotalJobItems,jobInfo.NumberOfErrors,jobInfo.ExtendedStatus);
    } 
}