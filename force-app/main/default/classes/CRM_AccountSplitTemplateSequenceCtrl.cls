/**
   @Author-Cognizant Technology Solutions
   @name-CRM_AccountSplitTemplateSequenceCtrl
   @CreateDate- 20th July 2017
*/
public with sharing class CRM_AccountSplitTemplateSequenceCtrl {
	
	public static void executeBeforeUpdate(Map<Id,Target_Split_Template__c> mapNewAccSplitTemps,Map<Id,Target_Split_Template__c> mapOldAccSplitTemps){
		CRM_AccountSplitTemplateHandler.preventToUpdateAccSplitTempRecords(mapNewAccSplitTemps,mapOldAccSplitTemps);
	}
}