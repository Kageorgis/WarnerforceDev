/*******************************************************************************************************************************************
* File Name     :   WB_CountryTrigger 
* Description   :   trigger on Country.
* @author       :   CTS
* Modification Log
* Created Date  :   10/01/2018
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     26 Feb 2018       CAS Support         ER-1680
********************************************************************************************************************************************/
trigger WB_CountryTrigger on Country__c (before insert, before update) {    
    WB_CountryTriggerHandler countryHandler = new WB_CountryTriggerHandler();
    if(trigger.isBefore){
        countryHandler.checkPrimaryRating(trigger.new);   
        //ER-1680 Starts
        
        if(trigger.isInsert)
        {
            countryHandler.digPhyCheckonQueueOnInsert(Trigger.New);
        }
        if(trigger.isUpdate)
        {
            countryHandler.digPhyCheckonQueueOnUpdate(Trigger.oldMap,Trigger.newMap);
        }
       // ER-1680 Ends
    }
}