@isTest
public class RF_MPMTest {
   @testSetup static void setupData() {
        // Create common test MPMs
        List<MPM__c> testMPMs = new List<MPM__c>();
        for(Integer i=1;i<3;i++) 
            testMPMs.add(new MPM__c(Name = '100000'+i, MPM_Number__c='100000'+i,MPM_Short_Desc__c='SDS USE ONLY'+i ,Financial_Comment_3__c=System.Label.RF_Financial_Comment_3_Prefix_J01+':5666666'+i, Family_MPM_Number__c = '1000002', MPM_Generic_Synopsis__c = 'Generic Synopsis', MPM_Long_Synopsis__c = 'Long Synopsis', MPM_Short_Synopsis__c = 'Short Synopsis'));
            
        insert testMPMs; 	
        update testMPMs;
       list<ext_title__C> exttitlelist= new list<ext_title__C>();
       for(integer i=0;i<3;i++){
           exttitlelist.add(new ext_title__C(Name='100000'+1,SGENNO__c='5666666'+i,Production_Year__c = '3434',MPM_Request_Status__c='Complete',Integration_State__c = 'Pick me up'));
       }
       insert exttitlelist; 
       MPM__c mm = new MPM__C();
       mm.Name = '12233';
       mm.MPM_Number__c = '122332';
       mm.Financial_Comment_3__c = System.Label.RF_Financial_Comment_3_Prefix_J01+':23322';
       insert mm;
       ext_title__C ex = new ext_title__C();
       ex.Production_Year__c = '5559';
       ex.MPM_Number__c = mm.MPM_Number__c;
       ex.SGENNO__c = 'SDS USE ONLY';
       ex.MPM__c = mm.id;
      // ex.id = mm.id;
       insert ex;
    }

    public static testmethod void testUpdateMPMFamily(){
        MPM__c mpm = [SELECT Id,Financial_Comment_3__c, Family_MPM_Number__c,MPM_Short_Desc__c FROM MPM__c WHERE MPM_Number__c='1000002' LIMIT 1];
        mpm.Family_MPM_Number__c = System.Label.RF_Financial_Comment_3_Prefix_J01+':567652';
        mpm.MPM_Short_Desc__c = 'SDS USE ONLY';
        mpm.FRB_Reporting_Group__c = System.Label.RF_UNIVERSAL_WARNER_BROS_JV;
        update mpm;
    }
     static testmethod void setprefixtest() {
        MPM__c mp = new MPM__c();
         mp.MPM_Number__c ='344555';
         mp.MPM_Short_Desc__c ='SDS USE ONLY';
         mp.Financial_Comment_3__c =System.Label.RF_Financial_Comment_3_Prefix_J01+':45666';
         mp.FRB_Reporting_Group__c = System.Label.RF_UNIVERSAL_WARNER_BROS_JV;
         insert mp;
    }
    static testmethod void setprefixtest1() {
        MPM__c mp = new MPM__c();
         mp.MPM_Number__c ='344555';
         mp.MPM_Short_Desc__c ='SDS USE ONLY';
         mp.Financial_Comment_3__c ='J01:7555941;J67:529562';
         insert mp;
         mp.FRB_Reporting_Group__c = System.Label.RF_UNIVERSAL_WARNER_BROS_JV;
         update mp;
    }
    static testmethod void setprefixtest2() {
         Ext_Title__c ext=new Ext_Title__c();
         ext.Name='test Ext Title';
         ext.Production_Year__c='2021';
         ext.SGENNO__c='7555941';
         insert ext;
         MPM__c mp = new MPM__c();
         mp.MPM_Number__c ='344555';
         mp.MPM_Short_Desc__c ='SDS USE ONLY';
         mp.FRB_Reporting_Group__c = System.Label.RF_UNIVERSAL_WARNER_BROS_JV;
         insert mp;
         mp.Financial_Comment_3__c =System.Label.RF_Financial_Comment_3_Prefix_J01+':'+ext.SGENNO__c;
         update mp;
    }
    static testmethod void setprefixtest3() {
        Ext_Title__c ext=new Ext_Title__c();
         ext.Name='test Ext Title';
         ext.Production_Year__c='2021';
         ext.SGENNO__c='7555941';
         insert ext;
        MPM__c mp = new MPM__c();
         mp.MPM_Number__c ='344555';
         mp.MPM_Short_Desc__c ='SDS USE ONLY';
         mp.FRB_Reporting_Group__c = System.Label.RF_UNIVERSAL_WARNER_BROS_JV;
         mp.Financial_Comment_3__c =System.Label.RF_Financial_Comment_3_Prefix_J01+':'+ext.SGENNO__c;
         insert mp;
    }
    public static testmethod void setMpmNullOnNoMatchTest(){
        Ext_Title__c ext=new Ext_Title__c();
         ext.Name='test Ext Title';
         ext.Production_Year__c='2021';
         ext.SGENNO__c='7555941';
         insert ext;
        MPM__c mp = new MPM__c();
         mp.MPM_Number__c ='344555';
         mp.MPM_Short_Desc__c ='SDS USE ONLY';
         mp.FRB_Reporting_Group__c = System.Label.RF_UNIVERSAL_WARNER_BROS_JV;
         mp.Financial_Comment_3__c ='J91:7555941';
         insert mp;
    }
    public static testmethod void setMpmWhenMatchedTest(){
        MPM__c mp1 = [SELECT Id,Financial_Comment_3__c, Family_MPM_Number__c,MPM_Short_Desc__c,MPM_Number__c FROM MPM__c WHERE MPM_Number__c='1000002' LIMIT 1];
        
        Ext_Title__c ext=new Ext_Title__c();
         ext.Name='test Ext Title';
         ext.Production_Year__c='2021';
         ext.SGENNO__c='7555941';
         ext.MPM__c = mp1.Id;
         ext.MPM_Number__c= mp1.MPM_Number__c;
         insert ext;
        MPM__c mp2 = new MPM__c();
         mp2.MPM_Number__c ='344555';
         mp2.MPM_Short_Desc__c ='SDS USE ONLY';
         mp2.FRB_Reporting_Group__c = System.Label.RF_UNIVERSAL_WARNER_BROS_JV;
         mp2.Financial_Comment_3__c =System.Label.RF_Financial_Comment_3_Prefix_J01+':'+ext.SGENNO__c;
         insert mp2;
        
    }
    public static testmethod void setMpmNullWhenFC3BlankTest(){
        Ext_Title__c ext=new Ext_Title__c();
         ext.Name='test Ext Title';
         ext.Production_Year__c='2021';
         ext.SGENNO__c='7555941';
         ext.MPM__c=null;
         ext.MPM_Number__c='';	
         insert ext;
        MPM__c mp = new MPM__c();
         mp.MPM_Number__c ='344555';
         mp.MPM_Short_Desc__c ='SDS USE ONLY';
         mp.FRB_Reporting_Group__c = System.Label.RF_UNIVERSAL_WARNER_BROS_JV;
         mp.Financial_Comment_3__c = System.Label.RF_Financial_Comment_3_Prefix_J01+':'+ext.SGENNO__c;
         insert mp;
         mp.Financial_Comment_3__c ='';
        update mp;
        system.assertEquals(ext.MPM_Number__c, '');
    }
}