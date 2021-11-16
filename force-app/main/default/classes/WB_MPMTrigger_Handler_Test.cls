/*
Class Name   : WB_MPMTrigger_Handler_Test
Description  : This class is to do code coverage for WB_MPMTrigger_Handler class    
Created By   : Cognizant Technology Solutions - Purushottam Gupta
Created On   : 22th March 2018
*/
@isTest
public class WB_MPMTrigger_Handler_Test{
    
   @testSetup static void setupData() {
        // Create common test MPMs
        List<MPM__c> testMPMs = new List<MPM__c>();
        for(Integer i=1;i<3;i++) 
            testMPMs.add(new MPM__c(Name = '100000'+i, MPM_Number__c='100000'+i, Family_MPM_Number__c = '1000002', MPM_Generic_Synopsis__c = 'Generic Synopsis', MPM_Long_Synopsis__c = 'Long Synopsis', MPM_Short_Synopsis__c = 'Short Synopsis'));
            
        insert testMPMs;        
    }

    public static testmethod void testUpdateMPMFamily(){
        MPM__c mpm = [SELECT Id, Family_MPM_Number__c FROM MPM__c WHERE MPM_Number__c='1000002' LIMIT 1];
        mpm.Family_MPM_Number__c = '1000001';
        update mpm;
    }
}