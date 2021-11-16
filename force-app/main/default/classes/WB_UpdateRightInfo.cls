/*******************************************************************************************************************************************
* File Name     :   WB_UpdateRightInfo
* Description   :   Class to link Rights to the release plan
* @author       :   CTS
* Modification Log
===================================================================================================------------------
* Modified Date    Author              Modification
------------------------------------------------------------------------------------------------------------------
* 16 Jun 2021      Ketan (CTS)         Optimised the code to remove wrong Rights present on RP if mathcing Rigths not present in system  ER-006561
********************************************************************************************************************************************/
public with sharing class WB_UpdateRightInfo{   
    public WB_UpdateRightInfo(){}
    public void  mapRightsDate(list<commercial_avail__c> commList){
        
        Set<String> rightGroup = new Set<String>();
        Set<String> rightChannel = new Set<String>();
        Set<string> mpmList= new set<string>();  
        Set<String> VideoVersionSet = new set<String>();
        Map <ID,Schema.RecordTypeInfo> rtMapByName = Rights__c.sObjectType.getDescribe().getRecordTypeInfosById();
        
        for (commercial_avail__c ca : [Select Id,Rights_GroupF__c,Channel__c,Title__r.MPM__c,Title_Generic_MPM_Number__c,Title_Video_Version__c From commercial_avail__c Where Id IN :commList]){
            rightGroup.add(ca.Rights_GroupF__c);
            rightChannel.add(ca.Channel__c);
            if(ca.Title_Generic_MPM_Number__c != null){
                mpmList.add(ca.Title__r.MPM__c);
            }else{
                VideoVersionSet.add(ca.Title_Video_Version__c);
            }
        }
        
        Map<String,List < Rights__c>> mapMPMnRights = new Map<String,List < Rights__c>>();
        for(Rights__c rights : [SELECT Name, id, Channel__c, MPM__c, MPM__r.Name , Rights_End__c, Rights_Group__c, Rights_Start__c, Rights_Start_2__c, Rights_End_2__c,
                                     Rights_Start_3__c, Rights_End_3__c, Rights_Start_4__c, Rights_End_4__c, Rights_Start_5__c, Rights_End_5__c, LastModifiedDate,
                                     RecordTypeId, Title__c, Title__r.MPM__r.Id, Video_Version__c,VV_MPM__c
                                FROM Rights__c 
                                WHERE (MPM__c IN: mpmList OR Video_Version__c IN: VideoVersionSet) AND Rights_Group__c IN: rightGroup AND 
                                Channel__c IN: rightChannel ORDER BY LastModifiedDate DESC]){
                                    
            if(rights.VV_MPM__c != null){
                if(mapMPMnRights.containsKey(rights.VV_MPM__c)){
                    mapMPMnRights.get(rights.VV_MPM__c).add(rights);
                }else{
                    mapMPMnRights.put(rights.VV_MPM__c,new List<Rights__c>{rights});    
                }           
            }
        }
        
        for (Commercial_Avail__c objRP : commList) {
            
            Boolean strRPTitleMPMGen = objRP.Title_Generic_MPM_Number__c != null ? false : true;
            Boolean isPefectFound =false;
            Boolean isPefectFound1 =false;
            Boolean isPefectFound2 =false;
            Boolean isPefectFound3 =false;
            
            if(strRPTitleMPMGen){
                if(mapMPMnRights != null && mapMPMnRights.size() > 0 && mapMPMnRights.containsKey(objRP.Title_Video_Version__c)) {
                    for (Rights__c objRight: mapMPMnRights.get(objRP.Title_Video_Version__c)) {
                        if(objRP.Channel__c != null && objRP.Rights_GroupF__c != null && objRP.Exclusive_Date__c != null && 
                           objRP.Rights_End__c != null && objRight.Rights_Group__c != null && objRight.Channel__c != null && 
                           objRP.Title_Video_Version__c != null && objRight.Video_Version__c != null && objRP.Title_Video_Version__c == objRight.Video_Version__c &&
                           objRP.Channel__c == objRight.Channel__c && objRP.Rights_GroupF__c == objRight.Rights_Group__c){
                            
                            if ((objRight.Rights_Start__c != null && objRight.Rights_End__c != null) || (objRight.Rights_Start_2__c != null && objRight.Rights_End_2__c != null) || 
                                (objRight.Rights_Start_3__c != null && objRight.Rights_End_3__c != null) || (objRight.Rights_Start_4__c != null && objRight.Rights_End_4__c != null) || 
                                (objRight.Rights_Start_5__c != null && objRight.Rights_End_5__c != null)) {
                                    
                                if ((objRP.Exclusive_Date__c <= objRight.Rights_End__c && objRP.Rights_End__c >= objRight.Rights_Start__c) || 
                                    (objRP.Exclusive_Date__c <= objRight.Rights_End_2__c && objRP.Rights_End__c >= objRight.Rights_Start_2__c) || 
                                    (objRP.Exclusive_Date__c <= objRight.Rights_End_3__c && objRP.Rights_End__c >= objRight.Rights_Start_3__c) || 
                                    (objRP.Exclusive_Date__c <= objRight.Rights_End_4__c && objRP.Rights_End__c >= objRight.Rights_Start_4__c) || 
                                    (objRP.Exclusive_Date__c <= objRight.Rights_End_5__c && objRP.Rights_End__c >= objRight.Rights_Start_5__c)){

                                    objRP.Rights_ID__c = objRight.Id;
                                    isPefectFound = true;
                                    break;
                                } else {
                                    if(!isPefectFound){
                                        objRP.Rights_ID__c = objRight.Id;
                                        isPefectFound1 = true;
                                    }
                                }
                            }else{
                                if(!isPefectFound1){
                                    objRP.Rights_ID__c = objRight.Id;
                                    isPefectFound2 = true;
                                }
                            }
                        }else if(!(isPefectFound || isPefectFound1 || isPefectFound2) && objRP.Title_Video_Version__c != null && objRight.Video_Version__c != null && 
                                 objRP.Title_Video_Version__c == objRight.Video_Version__c && objRight.Channel__c == null && objRight.Rights_Group__c == null){
                                     
                            objRP.Rights_ID__c = objRight.Id;
                            isPefectFound3 = true;
                            
                        }else if(!(isPefectFound || isPefectFound1 || isPefectFound2 || isPefectFound3)){
                            objRP.Rights_ID__c = null;
                        }
                    }
                }else{                                      
                    objRP.Rights_ID__c = null;
                }
            }else{
                if(mapMPMnRights != null && mapMPMnRights.size() > 0 && mapMPMnRights.containsKey(objRP.Title_Generic_MPM_Number__c)) {
                    for (Rights__c objRight: mapMPMnRights.get(objRP.Title_Generic_MPM_Number__c)) {
                        if(objRP.Channel__c != null && objRP.Rights_GroupF__c != null && objRP.Exclusive_Date__c != null && 
                           objRP.Rights_End__c != null && objRight.Rights_Group__c != null && objRight.Channel__c != null && 
                           objRP.Title_Generic_MPM_Number__c != null && objRight.MPM__c != null && objRP.Title_Generic_MPM_Number__c == objRight.MPM__r.Name &&
                           objRP.Channel__c == objRight.Channel__c && objRP.Rights_GroupF__c == objRight.Rights_Group__c){
                            
                            if ((objRight.Rights_Start__c != null && objRight.Rights_End__c != null) || (objRight.Rights_Start_2__c != null && objRight.Rights_End_2__c != null) || 
                                (objRight.Rights_Start_3__c != null && objRight.Rights_End_3__c != null) || (objRight.Rights_Start_4__c != null && objRight.Rights_End_4__c != null) || 
                                (objRight.Rights_Start_5__c != null && objRight.Rights_End_5__c != null)) {
                                    
                                if ((objRP.Exclusive_Date__c <= objRight.Rights_End__c && objRP.Rights_End__c >= objRight.Rights_Start__c) || 
                                    (objRP.Exclusive_Date__c <= objRight.Rights_End_2__c && objRP.Rights_End__c >= objRight.Rights_Start_2__c) || 
                                    (objRP.Exclusive_Date__c <= objRight.Rights_End_3__c && objRP.Rights_End__c >= objRight.Rights_Start_3__c) || 
                                    (objRP.Exclusive_Date__c <= objRight.Rights_End_4__c && objRP.Rights_End__c >= objRight.Rights_Start_4__c) || 
                                    (objRP.Exclusive_Date__c <= objRight.Rights_End_5__c && objRP.Rights_End__c >= objRight.Rights_Start_5__c)){
                                        
                                    objRP.Rights_ID__c = objRight.Id;
                                    isPefectFound = true;
                                    break;
                                }else{
                                    if(!isPefectFound){
                                        objRP.Rights_ID__c = objRight.Id;
                                        isPefectFound1 = true;
                                    }
                                }
                            } else {
                                if(!isPefectFound1){
                                    objRP.Rights_ID__c = objRight.Id;
                                    isPefectFound2 = true;
                                }
                            }
                        }else if(!(isPefectFound || isPefectFound1 || isPefectFound2) && objRP.Title_Generic_MPM_Number__c != null && objRight.MPM__c != null && 
                                 objRP.Title_Generic_MPM_Number__c == objRight.MPM__r.Name && objRight.Channel__c == null && objRight.Rights_Group__c == null){
                            objRP.Rights_ID__c = objRight.Id;
                            isPefectFound3 = true;
                        }else if(!(isPefectFound || isPefectFound1 || isPefectFound2 || isPefectFound3)){
                            objRP.Rights_ID__c = null;
                        }   
                    }
                }else{                                      
                    objRP.Rights_ID__c = null;
                }
            }
        }
    }
}