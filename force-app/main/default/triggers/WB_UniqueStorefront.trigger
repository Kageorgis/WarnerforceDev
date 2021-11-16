/******* 
Name:WB_UniqueStorefront 
Creation Date- 8th Sept'2014
Description- Trigger Handler for Unique ness of Storefront
Author- Navjyoti Mohanta
********/
trigger WB_UniqueStorefront on Agreement__c (before insert,before update) {

    if(Trigger.isbefore && Trigger.isUpdate)
    {
       WB_TriggerHandlerUniqueStorefront.assignChannelFormatValues(Trigger.oldMap,trigger.new);
       WB_TriggerHandlerUniqueStorefront.UniqueStorefrontOnUpdate();
       WB_MultiselectPage_Controller wb = new WB_MultiselectPage_Controller();
       wb.selectedCombinations(Trigger.oldMap,Trigger.new);
       
       
    
    	//US#987 
        //CRM functional Code added to Set Rate Card Invalid Capability Flag
        //Whenever storefront Selected Combination will chnage 
        CRM_StorefrontSequenceController.executeBeforeUpdate(trigger.oldMap,trigger.newMap);
        
    }
    
    if(Trigger.isInsert)
    {
        WB_TriggerHandlerUniqueStorefront.UniqueStorefront();
    }
    if(Trigger.isbefore && Trigger.isInsert){
        WB_TriggerHandlerUniqueStorefront.setQueueToOwner(trigger.new);
        WB_TriggerHandlerUniqueStorefront.assignChannelFormatValues(Null,trigger.new);
    }
}