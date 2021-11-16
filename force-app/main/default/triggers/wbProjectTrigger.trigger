trigger wbProjectTrigger on WB_Project__c (Before Insert) {
if(Trigger.isBefore && Trigger.isInsert && GWSController.insertTrriggerFlag)
{
GWSController.checkForContact(Trigger.New);
}
}