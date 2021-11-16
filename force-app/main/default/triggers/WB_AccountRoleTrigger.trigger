trigger WB_AccountRoleTrigger on Account_Role__c (Before Insert, Before Update) 
{
    WB_AccountRoleTriggerHandler WB_AccountRoleTriggerHandlerInstance = new WB_AccountRoleTriggerHandler();
    WB_AccountRoleTriggerHandlerInstance.checkDuplicateAccRoles(trigger.new);
}