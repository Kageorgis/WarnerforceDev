/*******************************************************************************************************************************************
* File Name     :   UpdateMPMonECPiece
* Description   :   Trigger
* @author       :   TCS
* Modification Log
===================================================================================================
* Ver.    Date              Author                  Modification
---------------------------------------------------------------------------------------------------
* 1.0    19 Nov 2014        Harika Bondalapati      This trigger to call the WB_TriggerHandlerECPieces trigger handler 
*                                                   to update the MPM field value on EC Piece object when any insert or update happens.
* 2.0    31 March 2016      Prajakta                CH-01 : Updated handler method
* 3.0	 29 May 2020		Dennis Cho				Add logic to update MPM and Sequence for EC pieces where EC Tracker has changed
********************************************************************************************************************************************/


trigger UpdateMPMonECPiece on EC_Piece__c (after delete,before insert,before update) {
    
    List<EC_Piece__c> ecListMPM = new List<EC_Piece__c>();
    List<EC_Piece__c> ecListUpdated = new List<EC_Piece__c>();
    List<EC_Piece__c> ecListUpdatedTracker = new List<EC_Piece__c>();
    system.debug('Trigger.new  --->> '+Trigger.new);
    system.debug('Trigger.old --->> '+Trigger.old);
   
          // CH03 Implementing Custom Setting as Switch to disable trigger at runtime in Production
         DisableTrigger__c TriggerName = DisableTrigger__c.getvalues('TriggerOnECPiece');
           
            If(TriggerName!= null && TriggerName.isDisabled__c != true){        
                
                System.debug('TriggerDisabled=false');
                if(WB_TriggerHandlerECPieces.updateflag != true || test.isrunningTest() == true){
                  system.debug('came here');
                
                if(Trigger.isDelete  && Trigger.isAfter){
                    WB_TriggerHandlerECPieces.DeleteSequence(Trigger.old);
                }
                
                if(Trigger.isInsert  && Trigger.isBefore){
                    ecListUpdated.clear();
                    ecListMPM.clear();
                    for(EC_Piece__c ecnew:Trigger.new){
                        Boolean SequenceRecordchanges = false;
                        Boolean MPMRecordchanges = false;
                        system.debug('SequenceRecordchanges--->>'+SequenceRecordchanges );
                        system.debug('ecnew--->> '+ecnew);
                        system.debug('MPMRecordchanges--->>'+MPMRecordchanges);
                        if(ecnew.MPM__c == null){
                            system.debug('MPM changed');
                            MPMRecordchanges = true;
                        }
                        if(MPMRecordchanges == true){ 
                            system.debug('MPM changed2');
                            ecListMPM.add(ecnew);   
                        }
                        ecListUpdated.add(ecnew);
                    }
                    WB_TriggerHandlerECPieces.updateMPM(ecListMPM);
                    WB_TriggerHandlerECPieces.InsertSequence(ecListUpdated);
                }
             
                if(Trigger.isUpdate && Trigger.isBefore){
                    ecListUpdated.clear();
                    ecListMPM.clear();
                    ecListUpdatedTracker.clear();
                    List<EC_Piece__c> oldec = new List<EC_Piece__c>();
                    oldec = Trigger.old;
                    for(EC_Piece__c ecnew:Trigger.new){
                        Boolean SequenceRecordchanges = false;
                        Boolean MPMRecordchanges = false;
                        Boolean ECTrackerchanges = false;
                        system.debug('SequenceRecordchanges--->>'+SequenceRecordchanges );
                        system.debug('ecnew--->> '+ecnew);
                        system.debug('MPMRecordchanges--->>'+MPMRecordchanges);
                        if(Trigger.old != null){
                            for(EC_Piece__c ecold:Trigger.old){
                                system.debug('ecold--->>' +ecold);
                                if(ecnew.Sequence__c != ecold.Sequence__c){
                                    system.debug('sequence changed');
                                    SequenceRecordchanges = true;
                                }
                                if(ecnew.MPM__c != ecold.MPM__c || ecnew.MPM__c == null){
                                    system.debug('MPM changed');
                                    MPMRecordchanges = true;
                                }
                                if(ecnew.EC_Tracker__c != ecold.EC_Tracker__c){
                                    system.debug('EC Tracker changed');
                                    ECTrackerchanges = true;
                                }
                            }
                        }
                        if(SequenceRecordchanges == true){ 
                            ecListUpdated.add(ecnew);   
                        }
                        if(MPMRecordchanges == true){ 
                            ecListMPM.add(ecnew);   
                        }
                        if(ECTrackerchanges == true){ 
                            ecnew.Sequence__c = null;
                            ecListMPM.add(ecnew);
                            ecListUpdatedTracker.add(ecnew);
                        }
                    }
                    
                    WB_TriggerHandlerECPieces.updateMPM(ecListMPM);
                    system.debug('oldec----->>>'+oldec);
                    
                    /* Prajakta : CH-01  */
                    //WB_TriggerHandlerECPieces.UpdateSequence(ecListUpdated,oldec);
                    WB_TriggerHandlerECPieces.Update_Sequence(ecListUpdated, trigger.oldMap);
                    WB_TriggerHandlerECPieces.InsertSequence(ecListUpdatedTracker);
                }
            } 
    }
}