/*
Class Name   : WB_MPMTrigger_Handler
Description  : This class is the Trigger Handler class for the MPM object   for ATOM to CAS  integration (old upsert MPM interface)           
Created By   : Cognizant Technology Solutions - Purushottam Gupta
Created On   : 22th March 2018

Change History:
----------------------------------------------------------------------------------------------------------------------
Sr#  Description                             Updated By                                             Updated On
----------------------------------------------------------------------------------------------------------------------
1.  ER-001691 ATOM to CAS MPM             CTS - Astha Singh                                         [04/13/2018]
    
    
*/
public class WB_MPMTrigger_Handler{
    
     public Set<ID> parentIDs = new Set<ID>();
     
     public void updateMPMFamily(List<MPM__c> lstMPMs){
         
        if(Trigger.isBefore){ 
            List<String> lstFamilyMPMNo = new List<String>();   
            Map<String, MPM__c> mapFamilyMPM = new Map<String, MPM__c>(); 
            
            //Get list of Family MPM numbers
            for(MPM__c mpm : lstMPMs){
                if(mpm.Family_MPM_Number__c != null)
                    lstFamilyMPMNo.add(mpm.Family_MPM_Number__c);
            }
             
            //Get all family MPM details
            for(MPM__c mpm : [Select Id, MPM_Number__c, MPM_Generic_Synopsis__c, MPM_Long_Synopsis__c, MPM_Short_Synopsis__c FROM MPM__c WHERE MPM_Number__c IN : lstFamilyMPMNo])
                mapFamilyMPM.put(mpm.MPM_Number__c, mpm);
                
            //Update the value of Family MPM details   
            for(MPM__c mpm : lstMPMs){
                Id mpmId;
                String strMPMGenericSynp, strMPMLongSynp, strMPMShortSynp;
                
                if(mpm.Family_MPM_Number__c != null){
                    if(mapFamilyMPM.size() > 0 && mapFamilyMPM.containsKey(mpm.Family_MPM_Number__c) && mapFamilyMPM.get(mpm.Family_MPM_Number__c).Id != mpm.Id){
                        mpmId = mapFamilyMPM.get(mpm.Family_MPM_Number__c).Id;
                        strMPMGenericSynp = mapFamilyMPM.get(mpm.Family_MPM_Number__c).MPM_Generic_Synopsis__c;
                        strMPMLongSynp = mapFamilyMPM.get(mpm.Family_MPM_Number__c).MPM_Long_Synopsis__c;
                        strMPMShortSynp = mapFamilyMPM.get(mpm.Family_MPM_Number__c).MPM_Short_Synopsis__c;
                    }
                }
                mpm.Family_MPM_Number_Lookup__c = mpmId;
                mpm.Family_MPM_Generic_Synopsis__c = strMPMGenericSynp;
                mpm.Family_MPM_Long_Synopsis__c = strMPMLongSynp;
                mpm.Family_MPM_Short_Synopsis__c = strMPMShortSynp;
            }
        }
        
        //ER-001691 ATOM to CAS MPM: START
        /* Commented below code as part of ER-007460
        if(Trigger.isAfter){
            for(MPM__c mpmRec :lstMPMs)
             parentIDs.add(mpmRec.id);
            List<MPM__c> updatedChildMPMRecs = new List<MPM__c>();            
            Map<String, MPM__c> mapParentIDChildRec = new Map<String, MPM__c>(); 
            for(MPM__c childMPM: [SELECT Id, MPM_Number__c, MPM_Generic_Synopsis__c, MPM_Long_Synopsis__c, MPM_Short_Synopsis__c,Family_MPM_Number_Lookup__c FROM MPM__c 
                              WHERE Family_MPM_Number_Lookup__c IN : parentIDs]){
                if(Trigger.newMap.get(childMPM.Family_MPM_Number_Lookup__c)!= null){ 
                    MPM__c mpmObj =(MPM__C)Trigger.newMap.get(childMPM.Family_MPM_Number_Lookup__c);
                    if(childMPM.Family_MPM_Number_Lookup__c == mpmObj.Id){ 
                        childMPM.Family_MPM_Generic_Synopsis__c = mpmObj.MPM_Generic_Synopsis__c;
                        childMPM.Family_MPM_Long_Synopsis__c = mpmObj.MPM_Long_Synopsis__c;
                        childMPM.Family_MPM_Short_Synopsis__c = mpmObj.MPM_Short_Synopsis__c; 
                        updatedChildMPMRecs.add(childMPM);
                    }
                }         
            }          
           
            WB_TriggerRecursionHelper.mpmRecursiveUpdate = true;  
            Database.update(updatedChildMPMRecs);
            WB_TriggerRecursionHelper.mpmRecursiveUpdate = false;
        }*/
    }
    ////ER-001691 ATOM to CAS MPM: END
}