/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-17-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-17-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class WB_PageReferenceCreationGridURL {
    @AuraEnabled(cacheable=true)
    public static String getTentativeRPTerritoryUrl(){
        String urlVal = setParameters('CF_QP_Tentative_RP_Territory','Commercial_Avail__c');
        return urlVal;
    }

    @AuraEnabled(cacheable=true)
    public static String getTentativeRPAllUrl(){
        String urlVal = setParameters('CF_QP_Tentative_RP_All','Commercial_Avail__c');
        return urlVal;
    }
    
    //Tentative CA 
    @AuraEnabled(cacheable=true)
    public static String getTentativeCATerritoryUrl(){
        String urlVal = setParameters('CF_QP_Tentative_CA_Territory','Client_Avail__c');
        return urlVal;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getTentativeCAAllUrl(){

        String urlVal = setParameters('CF_QP_Tentative_CA_All','Client_Avail__c');
        return urlVal;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getOpenRPTerritoryUrl(){
        String urlVal = setParameters('CF_QP_Open_RP_Territory','Commercial_Avail__c');
        return urlVal;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getOpenRPAllUrl(){
        String urlVal = setParameters('CF_QP_Open_RP_All','Commercial_Avail__c');
        return urlVal;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getRightsCheckRPTerritoryUrl(){
        String urlVal = setParameters('CF_QP_RightsCheck_RP_Territory','Commercial_Avail__c');
        return urlVal;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getRightsCheckRPAllUrl(){
        String urlVal = setParameters('CF_QP_RightsCheck_RP_All','Commercial_Avail__c');
        return urlVal;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getEarlyEndingRPTerritoryUrl(){
        String urlVal = setParameters('CF_QP_EarlyEnding_RP_Territory','Commercial_Avail__c');
        return urlVal;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getEarlyEndingRPAllUrl(){
        String urlVal = setParameters('CF_QP_EarlyEnding_RP_All','Commercial_Avail__c');
        return urlVal;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getEarlyEndingCATerritoryUrl(){
        String urlVal = setParameters('CF_QP_EarlyEnd_CA_Territory','Client_Avail__c');
        return urlVal;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getEarlyEndingCAAllUrl(){
        String urlVal = setParameters('CF_QP_EarlyEnd_CA_All','Client_Avail__c');
        return urlVal;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getTitleAllUrl(){
        String urlVal = setParameters('CF_QP_Title_All','Title__c');
        return urlVal; 
    }

    @AuraEnabled(cacheable=true)
    public static String getTitleTerritoryUrl(){
        String urlVal = setParameters('CF_QP_Title_Territory','Title__c');
        return urlVal; 
    }
    
    //RP without CA
    @AuraEnabled(cacheable=true)
    public static String getWithoutCARPTerritoryUrl(){
        String urlVal = setParameters('CF_QP_Without_CA_RP_Territory','Commercial_Avail__c');
        return urlVal;
    }

    @AuraEnabled(cacheable=true)
    public static String getWithoutCARPAllUrl(){
        String urlVal = setParameters('CF_QP_Without_CA_RP_All','Commercial_Avail__c');
        return urlVal;
    }
    
    //Draft CA
    @AuraEnabled(cacheable=true)
    public static String getDraftCATerritoryUrl(){
        String urlVal = setParameters('CF_QP_Draft_CA_Territory','Client_Avail__c');
        return urlVal;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getDraftCAAllUrl(){
        String urlVal = setParameters('CF_QP_Draft_CA_All','Client_Avail__c');
        return urlVal;
    }
    
    //NR To Catalog Reprice CA
    @AuraEnabled(cacheable=true)
    public static String getNRRepriceCATerritoryUrl(){
        String urlVal = setParameters('CF_QP_NR_Reprice_CA_Territory','Client_Avail__c');
        return urlVal;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getNRRepriceCAAllUrl(){
        String urlVal = setParameters('CF_QP_NR_Reprice_CA_All','Client_Avail__c');
        return urlVal;
    }

    //Storefront Missing CA
    @AuraEnabled(cacheable=true)
    public static String getSFMissingCATerritoryUrl(){
        String urlVal = setParameters('CF_QP_SF_Missing_CA_Territory','Client_Avail__c');
        return urlVal;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getSFMissingCAAllUrl(){
        String urlVal = setParameters('CF_QP_SF_Missing_CA_All','Client_Avail__c');
        return urlVal;
    }

    @AuraEnabled(cacheable=true)
    public static String getRepriceReminderTerritoryUrl(){
        String urlVal = setParameters('CF_QP_Reprice_Reminder_Territory','Client_Avail__c');
        return urlVal;
    }

    @AuraEnabled(cacheable=true)
    public static String getRepriceReminderAllUrl(){
        String urlVal = setParameters('CF_QP_Reprice_Reminder_All','Client_Avail__c');
        return urlVal;
    }

    public static String setParameters(String serverParameter,String objectName){
        Pagereference PageRef = new Pagereference('/apex/PQ_Grid');
        Pageref.getParameters().put('al','true');
        Pageref.getParameters().put('obj',objectName);
        Pageref.getParameters().put(serverParameter,'Yes');
        if(objectName == 'Commercial_Avail__c'){
            Pageref.getParameters().put('qpn','PQ_Commercial_Avail__c');
        }else if(objectName == 'Client_Avail__c'){
            Pageref.getParameters().put('qpn','PQ_Client_Avail__c');
        }else if(objectName == 'Title__c'){
            Pageref.getParameters().put('qpn','PQ_Title__c');
        }
       
        String urlVal = String.valueOf(PageRef);
        urlVal = urlVal.replace('System.PageReference', '');
        
        urlVal = urlVal.replace('[','');
        urlVal = urlVal.replace(']','');
        return urlVal;
    }
}