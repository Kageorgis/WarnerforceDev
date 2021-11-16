/*******************************************************************************************************************************************
* File Name     :   WB_TriggerHandlerECPieces
* Description   :   Trigger
* @author       :   TCS
* Modification Log
===================================================================================================
* Ver.    Date              Author                  Modification
---------------------------------------------------------------------------------------------------
* 1.0    19 Nov 2014        Harika Bondalapati      This class is to update MPM Field value for the trigger UpdateMPMonECPiece 
* 2.0    31 March 2016      Prajakta                CH-01 : Updated Update_Sequence method
********************************************************************************************************************************************/


public class WB_TriggerHandlerECPieces{
    
    public static Boolean updateflag {get; set;}
    
    public static void updateMPM(List<EC_Piece__c> listnew){
      
        Map<Id,String> EcTrackerMap = new Map<Id,String>{};   
        List<EC_Tracker__c> EcTrackerTotalList = new List<EC_Tracker__c>();
        List<EC_Piece__c> ecList2 = new List<EC_Piece__c>();
        List<String> ECTrackersList = new List<String>(); 
        system.debug('listnew--->>>'+listnew);
        String track;
        //get the list of tracker Ids you adding the ec pieces to
        for(EC_Piece__c ec1:listnew){
            ECTrackersList.add(ec1.EC_Tracker__c);
        }
        system.debug('ECTrackersList--->>>'+ECTrackersList);
      
        //get the total list of trackers
        EcTrackerTotalList = [select Id,MPM__c from EC_Tracker__c where Id IN:ECTrackersList];
        system.debug('EcTrackerTotalList--->>>'+EcTrackerTotalList);
        
        //getting the map of tracker Id to MPM
        for(EC_Tracker__c ect:EcTrackerTotalList){
            EcTrackerMap.put(ect.Id,ect.MPM__c);
        }
        system.debug('EcTrackerMap--->>>'+EcTrackerMap);
        
        //updating the mpm value
        for(EC_Piece__c ec:listnew){
            if(ec.EC_Tracker__c!=null && EcTrackerMap.get(ec.EC_Tracker__c)!=null){
                ec.MPM__c = EcTrackerMap.get(ec.EC_Tracker__c);
            }
        } 
    }
  
    public static void DeleteSequence(List<EC_Piece__c> delnew){
        List<EC_Piece__c> ecList = new List<EC_Piece__c>();
        List<EC_Piece__c> restECList = new List<EC_Piece__c>();
        Map<Id,List<Decimal>> deltotlaMap = new Map<Id,List<Decimal>>();
        Set<Id> ectrkSet = new Set<Id>();
        Set<Id> delecIdSet = new Set<Id>();
        
        //collect all tracker Ids and all ec Ids of deleting data
        for(EC_Piece__c trk:delnew){
            ectrkSet.add(trk.EC_Tracker__c);
            delecIdSet.add(trk.Id);
        }
        
        //List of all ECs with the matching ectracker from the del Ecs
        ecList = [select Id,Name,Sequence__c,EC_Tracker__c from EC_Piece__c
                                where EC_Tracker__c IN:ectrkSet];
        //List of all ecs after removing the deleted Ecs           
        restECList = [select Id,Name,Sequence__c,EC_Tracker__c from EC_Piece__c
                                where Id NOT IN:delecIdSet AND EC_Tracker__c IN:ectrkSet];
        
        //Map of tracker and the list of sequence numbers for that tracker that are getting deleted 
        for(Id trker:ectrkSet){
            List<Decimal> tempList = new List<Decimal>();
            for(EC_Piece__c maptrk:delnew){
                if(maptrk.EC_Tracker__c == trker){
                    tempList.add(maptrk.Sequence__c);
                }
            }
            if(tempList.size()>0){
                deltotlaMap.put(trker,tempList);
            }
        }                           
        
        //logic to reduce the sequence of undeleted data
        for(String trker2:ectrkSet){
            Decimal delreq = 0;
            List<Decimal> delseqThisTracker = deltotlaMap.get(trker2);
            delseqThisTracker.sort();
            Integer Size = delseqThisTracker.size();
            Integer i;
            for(i=size-1;i>=0;i--){
                delreq = delseqThisTracker[i];
                for(EC_Piece__c ec2:restECList){
                    if(ec2.EC_Tracker__c == trker2){
                        if(ec2.Sequence__c > delreq){
                            ec2.Sequence__c = ec2.Sequence__c - 1;
                        }
                    }
                }
            }
        }
        
        //update the record and do not trigger the update trigger
        updateflag = true;
        update restECList;
        updateflag = false;
    }
    
    /* Prajakta : CH-01 */
    public static void Update_Sequence(List<EC_Piece__c> newList, map<Id, EC_Piece__c> oldMap){
        
        set<Id> setEcTracker = new set<Id>();
        List<EC_Piece__c> udpatedECPieces = new List<EC_Piece__c>();
        
        // Collect EC Tracker of all the EC Pieces to be updated
        for(EC_Piece__c objECPiece : newList) {
            if(objECPiece.EC_Tracker__c != null) {
                setEcTracker.add(objECPiece.EC_Tracker__c);
            }
        }
        
        if(setEcTracker.size() > 0) {
            // List of all the above EC trackers EC Pieces
            List<EC_Piece__c> ECPieceList = [SELECT Id, EC_Tracker__c, Sequence__c FROM EC_Piece__c WHERE EC_Tracker__c IN: setEcTracker];
            system.debug('------ECPieceList------'+ECPieceList);
            
            // Map of EC Tracker Id to its respective EC Pieces List
            map<Id, List<EC_Piece__c>> mapIdToECPiece = new map<Id, List<EC_Piece__c>>();
            
            for(EC_Piece__c objECPiece : ECPieceList) {
                List<EC_Piece__c> lstECPiece = new List<EC_Piece__c>();
                if(mapIdToECPiece.containsKey(objECPiece.EC_Tracker__c)) {
                    lstECPiece = mapIdToECPiece.get(objECPiece.EC_Tracker__c);
                    lstECPiece.add(objECPiece);
                } else {
                    lstECPiece.add(objECPiece);
                }
                mapIdToECPiece.put(objECPiece.EC_Tracker__c, lstECPiece);
            }
            system.debug('------mapIdToECPiece------'+mapIdToECPiece);
            
            // Check for all the EC Pieces which are being updated
            for(EC_Piece__c objECPiece : newList) {
                if(mapIdToECPiece.containsKey(objECPiece.EC_Tracker__c)) {
                    List<EC_Piece__c> lstECPieces = mapIdToECPiece.get(objECPiece.EC_Tracker__c);
                    if(lstECPieces.size() > 0)
                        system.debug('------lstECPieces------'+lstECPieces.size());
                    
                    // For all the EC Pieces siblings
                    for (EC_Piece__c objECP : lstECPieces) {

                        // Check for rest of the EC Piece and having sequence as old one.
                        if(objECP.Id != objECPiece.Id) {
                            
                            // If 2->4 then 4->3, 3->2, 5->5, 1->1
                            if(objECP.Sequence__c == objECPiece.Sequence__c && (oldMap.get(objECPiece.Id).Sequence__c < objECP.Sequence__c)) { 
                                system.debug('------outer objECP------'+objECPiece.Sequence__c +'===='+oldMap.get(objECPiece.Id).Sequence__c +'===='+objECP.Sequence__c);
                                if (objECPiece.Sequence__c > oldMap.get(objECPiece.Id).Sequence__c) {
                                    objECP.Sequence__c = objECP.Sequence__c - 1;
                                    udpatedECPieces.add(objECP);
                                    system.debug('------11------'+objECP);
                                }
                            } 
                            
                            else if (oldMap.get(objECPiece.Id).Sequence__c < objECP.Sequence__c && objECP.Sequence__c < objECPiece.Sequence__c) {
                                objECP.Sequence__c = objECP.Sequence__c - 1;
                                udpatedECPieces.add(objECP);
                                system.debug('------22------'+objECP);
                            }
                            
                            // If 4->2 then 2->3 , 3->4, 5->5, 1->1
                            else if(objECP.Sequence__c == objECPiece.Sequence__c && (oldMap.get(objECPiece.Id).Sequence__c > objECPiece.Sequence__c)) { 
                                if (objECPiece.Sequence__c < oldMap.get(objECPiece.Id).Sequence__c) {
                                    objECP.Sequence__c = objECP.Sequence__c + 1;
                                    udpatedECPieces.add(objECP);
                                    system.debug('------33------'+objECP);
                                }
                            } else if (oldMap.get(objECPiece.Id).Sequence__c > objECP.Sequence__c && objECP.Sequence__c > objECPiece.Sequence__c) {
                                objECP.Sequence__c = objECP.Sequence__c + 1;
                                udpatedECPieces.add(objECP);
                                system.debug('------44-----'+objECP);
                            }
                        } 
                        else if(objECPiece.Sequence__c > (lstECPieces.size())) {
                            objECPiece.addError('Sequence entered is incorrect as there are only '+ lstECPieces.size() +' EC Pieces.'); //(Label.Sequence_is_incorrect);
                        } 
                        else if(objECPiece.Sequence__c < 1){
                            objECPiece.addError('Sequence can not be less than one.');
                        }
                    }
                }
            }
            if(udpatedECPieces.size() > 0) {
                updateflag = true;
                database.update(udpatedECPieces, true);
                updateflag = false;
            }
        }
    }
    
    /* Prajakta : CH-01 */
   
    public static void InsertSequence(List<EC_Piece__c> listnew){
        
        List<EC_Piece__c> ecList = new List<EC_Piece__c>();
        List<EC_Piece__c> newecList = new List<EC_Piece__c>();
        List<EC_Piece__c> restECList = new List<EC_Piece__c>();
        List<EC_Piece__c> existList = new List<EC_Piece__c>();
        List<EC_Piece__c> newNullList = new List<EC_Piece__c>();
        Map<Id,List<Decimal>> intotalMap = new Map<Id,List<Decimal>>();
        Map<Id,Decimal> dupTestMap = new Map<Id,Decimal>();
        Set<Id> ectrkSet = new Set<Id>();
        Set<Id> newectrkSet = new Set<Id>();
        Set<Id> newNullectrkSet = new Set<Id>();
        Integer count = 0;
        
        //collect all tracker Ids and all ec Ids of deleting data
        for(EC_Piece__c trk:listnew){
            ectrkSet.add(trk.EC_Tracker__c);
            if((dupTestMap.size() > 0) && dupTestMap.get(trk.EC_Tracker__c) == trk.Sequence__c && trk.Sequence__c != null){
                count = count + 1;
                trk.addError('Please avoid duplicates in Sequence field while inserting the EC Pieces');
            } else {
               dupTestMap.put(trk.EC_Tracker__c,trk.Sequence__c);
            }
        }
        if(count > 0){
            ectrkSet.clear();
        }
        
        //List of all ECs with the matching ectracker from the del Ecs
        //ecList = [select Id,Name,Sequence__c,EC_Tracker__c from EC_Piece__c
              //                      where EC_Tracker__c IN:ectrkSet];
        //List of all ecs after removing the deleted Ecs           
        restECList = [select Id, Name, Sequence__c,EC_Tracker__c from EC_Piece__c where EC_Tracker__c IN:ectrkSet];
                                    
        //check whether the record with the same sequence exists or not for the actual update
        for(EC_Piece__c inig:listnew){
            if(inig.Sequence__c == null){
                newNullList.add(inig);
                newNullectrkSet.add(inig.EC_Tracker__c);
            }else{
                Boolean recExists = false;
                for(EC_Piece__c ig:restECList){
                    if(ig.Sequence__c == inig.Sequence__c){
                        recExists = true;             
                    }
                }
                if(recExists == true){
                    existList.add(inig);
                    newectrkSet.add(inig.EC_Tracker__c);
                }
            }      
        }
        if(count > 0){
            newectrkSet.clear();
        }     
        
        //Map of tracker and the list of sequence numbers for that tracker that are getting deleted 
        for(String trker:newectrkSet){
            List<Decimal> tempList = new List<Decimal>();
            for(EC_Piece__c maptrk:existList){
                if(maptrk.EC_Tracker__c == trker){
                   tempList.add(maptrk.Sequence__c);
                }
            }
            if(tempList.size()>0){
                intotalMap.put(trker,tempList);
            }
        }                           
        //logic to reduce the sequence of undeleted data
        for(String trker2:newectrkSet){
            Decimal inreq = 0;
            List<Decimal> inseqThisTracker = intotalMap.get(trker2);
            inseqThisTracker.sort();
            Integer Size = inseqThisTracker.size();
            Integer i;
            
            for(i=0;i<size;i++){
                inreq = inseqThisTracker[i];
                for(EC_Piece__c ec2:restECList){
                    if(ec2.EC_Tracker__c == trker2){
                        if(ec2.Sequence__c >= inreq){
                            ec2.Sequence__c = ec2.Sequence__c + 1;
                        }
                    }
                }
            }
        }
        //update the record and do not trigger the update trigger
        updateflag = true;
        update restECList;
        updateflag = false;
        
        //change the sequence number from null to highest + 1 for the records with sequence is null
        
        //Collect all the ECs after update
        newecList = [select Id,Name,Sequence__c,EC_Tracker__c from EC_Piece__c
                                    where EC_Tracker__c IN:newNullectrkSet];
            
        //Map of EC Tracker and high sequence number for that Tracker
        for(String trker3:newNullectrkSet){
            Decimal highnumber = 0;
            for(EC_Piece__c ec3:newecList){
                if(trker3 == ec3.EC_Tracker__c && highnumber < ec3.Sequence__c){
                   highnumber = ec3.Sequence__c;
                }
            }
            system.debug('highnumber---->>>'+highnumber);
            for(EC_Piece__c ec4:newNullList){
                if(trker3 == ec4.EC_Tracker__c){
                   ec4.Sequence__c = highnumber + 1;
                   highnumber = ec4.Sequence__c;
                }
            }
        }
    }
}