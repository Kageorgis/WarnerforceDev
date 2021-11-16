/*******************************************************************************************************************************************
* File Name     :   WB_MPMTalentTrigger_Handler
* Description   :   handler class for MPM Talent.
* @author       :   CTS
* Modification Log
* Created Date  :   30/01/2018
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 
********************************************************************************************************************************************/
public class WB_MPMTalentTrigger_Handler{

    public void deleteMPMTalent(List<MPM_Talent__c> lstMPMTalent){
       
        List<Id> delIDs = new List<Id>();
        for(MPM_Talent__c mpmtalentRec : lstMPMTalent){
            if(mpmtalentRec.Delete__c)
                delIDs.add(mpmtalentRec.id);
        }
        if(!delIDs.isEmpty()) 
            Database.delete(delIDs);
    }
}