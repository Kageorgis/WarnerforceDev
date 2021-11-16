/*
Class Name   : WB_MPMTalentTrigger_Handler_Test
Description  : This class is to do code coverage for WB_MPMTalentTrigger_Handler class    
Change History:
-------------------------------------------------------------------------------------------------------------------------------------
Sr#              Description                                               Updated By                                     Updated On
-------------------------------------------------------------------------------------------------------------------------------------
*/
@isTest
public class WB_MPMTalentTrigger_Handler_Test{

    public static testmethod void testDeleteMPMTalent(){
         MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
         insert mpm;
         Talent__c talent = new Talent__c (AKAs__c='testtalent1' , Talent_Id__c='test1');
         insert talent;
         MPM_Talent__c mpmtalent1 = new MPM_Talent__c(MPM__c=mpm.id, Talent__c=talent.id,Delete__c=true,key__c='ygbj-vbgr' );
         MPM_Talent__c mpmtalent2 = new MPM_Talent__c(MPM__c=mpm.id, Talent__c=talent.id,Delete__c=false,key__c='ygbr-rtfg');
         List<MPM_Talent__c> mpmtalents = new List<MPM_Talent__c>();
         mpmtalents.add(mpmtalent1);
         mpmtalents.add(mpmtalent2);
         
         test.startTest();
         insert mpmtalents;
         test.stoptest();
    }
}