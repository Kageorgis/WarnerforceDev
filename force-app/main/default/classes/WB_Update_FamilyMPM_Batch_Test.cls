/**
   @Author Cognizant
   @name WB_Update_FamilyMPM_Batch_Test
   @CreateDate 15 Sept 2020
   @Description This class is used for code coverage of WB_Update_FamilyMPM_Batch.
   @Version <1.0>
   @reference ER-006470
*/
@isTest
private class WB_Update_FamilyMPM_Batch_Test {
    @testSetup
    static void setupTestData(){ 
        
        //Create MPM records
        List<MPM__c> mpms = new List<MPM__c>();
        for(integer i=0;i<10;i++){
            MPM__c mpm = new MPM__c();
            mpm.Name = 'MPMNum'+i;
            mpm.MPM_Number__c = 'MPMNum'+i;
            mpm.Family_MPM_Number__c = 'FMPMNO'+i;
            mpm.MPM_Generic_Synopsis__c = 'MPM Generic Synopsis - '+i;
            mpm.MPM_Long_Synopsis__c = 'MPM Long Synopsis - '+i;
            mpm.MPM_Short_Synopsis__c = 'MPM Short Synopsis - '+i;
            mpms.add(mpm);
        }
        insert mpms;
        
        //Create Family MPM records
        List<MPM__c> familyMpms = new List<MPM__c>();
        for(integer i=0;i<10;i++){
            MPM__c mpm = new MPM__c();
            mpm.Name = 'FMPMNO'+i;
            mpm.MPM_Number__c = 'FMPMNO'+i;
            mpm.MPM_Generic_Synopsis__c = 'Family MPM Generic Synopsis - '+i;
            mpm.MPM_Long_Synopsis__c = 'Family MPM Long Synopsis - '+i;
            mpm.MPM_Short_Synopsis__c = 'Family MPM Short Synopsis - '+i;
            familyMpms.add(mpm);
        }
        insert familyMpms;
    }
    
    @IsTest
    static void schedulerTestCase(){
        
        Test.startTest();
        
        WB_Update_FamilyMPM_Batch sh1  = new WB_Update_FamilyMPM_Batch();          
        String sch = '0 0 2 * * ?';
        system.schedule('Test', sch, sh1);
        
        Test.stopTest();
        
    }
    
    @IsTest
    static void updateFamilyMPMTestCase(){
        
        //Before batch process, Family MPM is not linked to MPM & have the null values for Family MPM Synopsis 
        for(MPM__c mpm : [Select Id,Family_MPM_Number_Lookup__c,Family_MPM_Generic_Synopsis__c,Family_MPM_Long_Synopsis__c,Family_MPM_Short_Synopsis__c From MPM__c Where Family_MPM_Number__c != null]){
            system.assertEquals(null,mpm.Family_MPM_Number_Lookup__c);  
            system.assertEquals(null,mpm.Family_MPM_Generic_Synopsis__c);
            system.assertEquals(null,mpm.Family_MPM_Long_Synopsis__c);
            system.assertEquals(null,mpm.Family_MPM_Short_Synopsis__c);
        }
        Test.startTest();
        
        Database.executeBatch(new WB_Update_FamilyMPM_Batch(system.now().addDays(-1),null));
        
        Test.stopTest();
        
        //After batch process, Family MPM linked to MPM & updated the Family MPM Synopsis values from Family MPM Record
        for(MPM__c mpm : [Select Id,Family_MPM_Number_Lookup__r.name,Family_MPM_Generic_Synopsis__c,Family_MPM_Long_Synopsis__c,Family_MPM_Short_Synopsis__c,Family_MPM_Number__c,Family_MPM_Number_Lookup__r.MPM_Generic_Synopsis__c, Family_MPM_Number_Lookup__r.MPM_Long_Synopsis__c, Family_MPM_Number_Lookup__r.MPM_Short_Synopsis__c From MPM__c Where Family_MPM_Number__c != null]){
            system.assertEquals(mpm.Family_MPM_Number__c,mpm.Family_MPM_Number_Lookup__r.name);  
            system.assertEquals(mpm.Family_MPM_Number_Lookup__r.MPM_Generic_Synopsis__c,mpm.Family_MPM_Generic_Synopsis__c);
            system.assertEquals(mpm.Family_MPM_Number_Lookup__r.MPM_Long_Synopsis__c,mpm.Family_MPM_Long_Synopsis__c);
            system.assertEquals(mpm.Family_MPM_Number_Lookup__r.MPM_Short_Synopsis__c,mpm.Family_MPM_Short_Synopsis__c);
        }
       
    }
}