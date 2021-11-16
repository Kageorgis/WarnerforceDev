// @description: Test class for RF_ExtTitleHelper
@isTest
public class RF_ExtTitleHelpertest {
    
    static testmethod void setMPMFromExt(){
        list<mpm__C> mpmlist = new list<mpm__c>();
        list<string> mpmname= new list<string>();
        for(integer i= 0;i<3;i++){
            string name = '321234'+i;
            mpm__c mp = RF_TestUtil.mpmList(name);
           mp.Financial_Comment_3__c='testSGENNO'+i;
           mp.Financial_Comment_3__c=System.Label.RF_Financial_Comment_3_Prefix_J01+':5464498';
            mpmname.add(name);
            mpmlist.add(mp);                              
        } 
        insert mpmlist;
        
        
        ext_title__c ext = new ext_title__c();
        //  Ext_Title__c ex = RF_TestUtil.extList('MPM Required','Pick me up');
        list<ext_title__C> extlist = new list<ext_title__c>();
        list<string> sgenno =  new list<String>();
        for(integer i=0;i<4;i++){
            string sgn= 'testSGENNO'+i;
            extlist.add(new ext_title__C(Name='Test EXT',SGENNO__c=sgn,MPM_Request_Status__c='Complete',Integration_State__c='Pick me up',Production_Year__c ='1223'));
            sgenno.add(sgn);
        }
        insert extlist;
        list<mpm__C> mpmlistupdate = [select id,name,Financial_Comment_3__c,mpm_number__c from MPM__C where mpm_number__c in : mpmname];
        integer i =0;
        
        for(MPM__C mp : mpmlist){
            
            mp.Financial_Comment_3__c='Test for SGENNO' +i++;
            mpmlistupdate.add(mp);
            
        }
        
        integer x=0;
        list<ext_title__C> extlistupdate = [select id,SGENNO__c,Production_Year__c from ext_title__C where SGENNO__c in : sgenno];
        system.debug('extlistupdate====>'+extlistupdate);
        list<ext_title__C> extlisttoupdate = new list<ext_title__C>();
        for(ext_title__C ext1 : extlistupdate){ 
            ext1.SGENNO__c='Test for SGENNO'+x++;
            ext1.Production_Year__c ='1223';
            extlisttoupdate.add(ext1);
        }
        
        update extlisttoupdate;
        RF_Studio__c std = new RF_Studio__c();
        std.Distributor__c = 'test';
        insert std;
        List<release__c> relList = new list<release__c>();
        release__c rel = RF_TestUtil.releaseList('test',mpmlistupdate[0].id);
        rel.RF_Studio__c = std.id;
        rel.Country_List__c = 'USA';
        rel.ext_title_id__c = ext.id;
        rel.MPM__c = ext.id;
        insert rel;
        System.assertNotEquals(rel.Id, null);
 
    }
    static testmethod void setprefixmethod(){
        MPM__c mplist = new MPM__c();
        mplist.MPM_Number__c = '2345';
        mplist.Financial_Comment_3__c = System.Label.RF_Financial_Comment_3_Prefix_J01+':5464498';
       	mplist.MPM_Short_Desc__c = 'SDS USE ONLY';
        mplist.FRB_Reporting_Group__c = System.Label.RF_UNIVERSAL_WARNER_BROS_JV;
        insert mplist;
    	ext_title__c ext1 = new ext_title__c();
        ext1.Production_Year__c ='1223';
        ext1.SGENNO__c = '5464498';
        insert ext1;
    }  
      static testmethod void setprefixmethod1(){
        MPM__c mplist = new MPM__c();
        mplist.MPM_Number__c = '2345';
        mplist.Financial_Comment_3__c = 'J01:755943451;J67:529562';
        mplist.MPM_Short_Desc__c = 'SDS USE ONLY';
        mplist.FRB_Reporting_Group__c = System.Label.RF_UNIVERSAL_WARNER_BROS_JV;
        insert mplist;
    	ext_title__c ext1 = new ext_title__c();
        ext1.SGENNO__c = mplist.Financial_Comment_3__c;
        ext1.Production_Year__c ='1223';
        insert ext1;
        update ext1;
       System.assertNotEquals(ext1, null);
        
    }  
     static testmethod void setprefixmethod2(){
        MPM__c mplist = new MPM__c();
        mplist.MPM_Number__c = '2345';
        mplist.Financial_Comment_3__c = '2300009';
        mplist.MPM_Short_Desc__c = 'SDS USE ONLY';
        mplist.FRB_Reporting_Group__c = System.Label.RF_UNIVERSAL_WARNER_BROS_JV;
        insert mplist;
    	ext_title__c ext1 = new ext_title__c();
        ext1.SGENNO__c = mplist.Financial_Comment_3__c;
        ext1.Production_Year__c ='1223';
        insert ext1;
        update ext1;
        
    }  
    static testmethod void sgennoIsNullTest(){
        MPM__c mplist = new MPM__c();
        mplist.MPM_Number__c = '2345';
        mplist.Financial_Comment_3__c = 'J91:755943451;J01:529562';
        mplist.MPM_Short_Desc__c = 'SDS USE ONLY';
        mplist.FRB_Reporting_Group__c = System.Label.RF_UNIVERSAL_WARNER_BROS_JV;
        insert mplist;
    	ext_title__c ext1 = new ext_title__c();
        ext1.SGENNO__c = '529562';
        ext1.Production_Year__c ='1223';
        insert ext1;
        ext1.SGENNO__c = '';
        update ext1;
       	System.assertEquals(ext1.MPM__c, null);
        
    }  
    static testmethod void sgennoIsChangedTest(){
        MPM__c mplist = new MPM__c();
        mplist.MPM_Number__c = '2345';
        mplist.Financial_Comment_3__c = 'J91:755943451;J01:529562';
        mplist.MPM_Short_Desc__c = 'SDS USE ONLY';
        mplist.FRB_Reporting_Group__c = System.Label.RF_UNIVERSAL_WARNER_BROS_JV;
        insert mplist;
    	ext_title__c ext1 = new ext_title__c();
        ext1.SGENNO__c = '755943451';
        ext1.Production_Year__c ='1223';
        insert ext1;
        ext1.SGENNO__c = '529562';
        update ext1;
        
    }  
 
    static testmethod void SetMPMRequeststatusTest(){
      ext_title__c ext12 = new ext_title__c();
 	  ext12.MPM_Request_Status__c = System.Label.RF_MPM_Request_Status_MPM_Required;
      ext12.Integration_State__c = LABEL.RF_PICK_ME_UP;
    }
  
}