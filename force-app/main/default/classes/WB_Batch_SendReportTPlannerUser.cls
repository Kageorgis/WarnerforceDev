/*******************************************************************************************************************************************
* File Name     :   WB_Batch_SendReportTPlannerUser
* Description   :   Batch used to send report to WB territory planner user 
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
* 1.0     20 Nov.2015       CTS                  ER-000015 : Created the class.
* 2.0     
********************************************************************************************************************************************/

public with sharing class WB_Batch_SendReportTPlannerUser implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts
{
    public Database.QueryLocator start(Database.BatchableContext BC){   
        String queryString = 'select id,Email,Profile.name,Territory__c,IsActive from User where Profile.name = \'WB - Territory Avails Planner\' and IsActive = true and Territory__c != null';//
        if(Test.isRunningTest())
            queryString += ' limit 1';
        return Database.getQueryLocator(queryString);
    }
    public void execute(Database.BatchableContext BC, List<User> scope){
        
        for(User u : scope)
        {
            ApexPages.PageReference report = new ApexPages.PageReference ('/'+Label.WB_Territory_Planner_Report_Id+'?pv0='+u.Territory__c+'&csv=1');//+'?pv0='+u.Territory__c+'&pv1=TODAY&csv=1'
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment ();
            attachment.setFileName (Label.WB_Price_Tier_Report_File_Name);
            if(!Test.isRunningTest())
                attachment.setBody(report.getContent ());
            else
                attachment.setBody(Blob.valueof('Test body'));
            attachment.setContentType('text/csv');
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage ();
            message.setFileAttachments (new Messaging.EmailFileAttachment [] {attachment});
            message.setSubject (Label.WB_Price_Tier_Report_Subject);
            message.setPlainTextBody (Label.WB_Price_Tier_Report_Body);
            //message.setOrgWideEmailAddressId ('0D2q00000008Pcn'); //u.Email
            message.setToAddresses (new String [] {u.Email});
            //message.setToAddresses (new String [] {'srinizkumar.konakanchi@wbconsultant.com'});
            system.debug('message : '+message);
            Messaging.sendEmail (new Messaging.SingleEmailMessage [] {message});                                                                                                                        
        }
    }
    
    public void finish(Database.BatchableContext BC){
     
    }
}