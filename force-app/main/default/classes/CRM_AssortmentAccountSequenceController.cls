/** 
   * Author: Cognizant Team
   * Description: This Sequence Controller is used to call methods from the handllers.
   * Date Created: 20 September 2016
   * Version: 1.0   
   */
public with sharing class CRM_AssortmentAccountSequenceController{
 
    public static void executeBeforeDelete(Map<Id,Assortment_Account__c> mapAssortAccount) {
        CRM_AssortmentAccountHandler.cancelDeals(mapAssortAccount);
    }    
}