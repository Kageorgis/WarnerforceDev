@isTest
public class RF_MpmReleaseDateTriggerHandlerTest {
    
    @testSetup static void setup() {
        MPM__c mpmNew=new MPM__c();
        mpmNew.Name='testMPM';
        mpmNew.MPM_Short_Desc__c='testMPM desc';
        mpmNew.Content_Type__c='VV';
        mpmNew.MPM_Number__c='testMPM2341';
        
        insert mpmNew;
        
        RF_Studio__c rfstu1 = new RF_Studio__c();
        rfstu1.Distributor__c='Warner Bros';
        rfstu1.Name='Warner Bros';
        insert rfstu1;
        
        MPM__c mpmNew1=new MPM__c();
        mpmNew1.Name='testMPM';
        mpmNew1.MPM_Short_Desc__c='SDS USE ONLY';
        mpmNew1.Content_Type__c='VV1';
        mpmNew1.MPM_Number__c='testMPM2342';
        
        insert mpmNew1;
        
        MPM__c mpmNew2=new MPM__c();
        mpmNew2.Name='testMPM2';
        //mpmNew1.MPM_Short_Desc__c='SDS USE ONLY';
        mpmNew2.Content_Type__c='VV1';
        mpmNew2.MPM_Number__c='testMPM2343';
        
        insert mpmNew2;
        
        
        
        
        Country__c cn=new Country__c();
        cn.Name='Canada';
        cn.Country_Code2__c='Canada';
        cn.Country_Code__c='cn';
        insert cn;
        
        Country__c usa=new Country__c();
        usa.Name='USA';
        usa.Country_Code2__c='USA';
        usa.Country_Code__c='usa';
        insert usa;
                MPM_release_date_Default_Studio__c cs = new MPM_release_date_Default_Studio__c();
        		cs.studio__C='Warner Bros';
        
        insert cs;
        
        
    }
    
    public static testmethod void positivetestMetHod() 
    {
    
    test.starttest();
        //user u = [select id,name,email,Alias,EmailEncodingKey,ProfileId from user where name='Sai Santhan'];
        
        List<MPM__c> exMpmLst=[SELECT Id,Name,MPM_Short_Desc__c,MPM_Number__c,Content_Type__c FROM MPM__c];
        List<Country__c> cnList =[SELECT Id,Name FROM Country__c];
        
           
        list<rf_studio__C> rfstu1 = [select id,name from rf_studio__C where name = 'Warner Bros' limit 1];
        
        Release__c tstRl= new Release__c();
        tstRl.Name='tstRelSAINew';
        tstRl.RecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Theatrical').getRecordTypeId();
        tstRl.Country_List__c='Canada';
        tstRl.RF_Studio__c = rfstu1[0].id;
        tstRl.MPM__c= exMpmLst[0].Id;
        insert tstRl;
        
        Release__c tstR3= new Release__c();
        tstR3.Name='tstRelSAINew3';
        tstR3.RecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Theatrical').getRecordTypeId();
        tstR3.Country_List__c='Canada';
        tstR3.RF_Studio__c = rfstu1[0].id;
        tstR3.MPM__c= exMpmLst[0].Id;
        
        insert tstR3;
        
        Release__c tstRl1= new Release__c();
        tstRl1.Name='tstRelSAINew1';
        tstRl1.RecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Theatrical').getRecordTypeId();
        tstRl1.Country_List__c='Canada';
        tstRl1.RF_Studio__c = rfstu1[0].id;
        tstRl1.MPM__c= exMpmLst[1].Id;
        
        insert tstRl1;
        
        Release__c tstRl2= new Release__c();
        tstRl2.Name='tstRelSAINew1';
        tstRl2.RecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Theatrical').getRecordTypeId();
        tstRl2.Country_List__c='USA';
        tstRl2.RF_Studio__c = rfstu1[0].id;
        tstRl2.MPM__c= exMpmLst[1].Id;
        
        insert tstRl2;
        
        
        MPM_Release_Date__c rdt1=new MPM_Release_Date__c();
        rdt1.Country__c=cnList[0].Id;
        rdt1.MPM__c=exMpmLst[0].Id;
        rdt1.Format__c='SD';
        rdt1.Channel__c='EST';
        rdt1.Theatrical_Release_Date__c=System.Today();
        
        insert rdt1;
        
        MPM_Release_Date__c rdt2=new MPM_Release_Date__c();
        rdt2.Country__c=cnList[0].Id;
        rdt2.MPM__c=exMpmLst[1].Id;
        rdt2.Format__c='HD';
        rdt2.Channel__c='PPV';
        rdt2.Theatrical_Release_Date__c=System.Today()+1;
        
        insert rdt2;
        
        test.stopTest();
        rdt1.Theatrical_Release_Date__c=Date.newinstance(System.Today().year()+1, System.Today().month(), System.Today().day());
        update rdt1;
        rdt2.Theatrical_Release_Date__c=NULL;
        update rdt2; 
        
    }
    
    public static testmethod void NegativetestMetHod() 
    {
        Test.startTest();
        
        List<MPM__c> exMpmLst1=[SELECT Id,Name,MPM_Short_Desc__c,MPM_Number__c,Content_Type__c FROM MPM__c where MPM_Short_Desc__c!=null];
        List<Country__c> cnList1 =[SELECT Id,Name FROM Country__c where Name!=null limit 1];
        system.debug('exMpmLst1===>'+exMpmLst1);
        system.debug('cnList1===>'+cnList1);
        RF_Studio__c rfstu = new RF_Studio__c();
        rfstu.distributor__C='Warner Bros';
        insert rfstu; 
        Release__c tstRll= new Release__c();
        tstRll.Name='tstRelSAINew111';
        tstRll.RecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Theatrical').getRecordTypeId();
        tstRll.Country_List__c='usa';
        tstRll.RF_Studio__c = rfstu.id;
        tstRll.MPM__c= exMpmLst1[0].Id;
        
        insert tstRll; 
        
        Release__c tstRl0= new Release__c();
        tstRl0.Name='tstRelSAINew1';
        tstRl0.RecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Theatrical').getRecordTypeId();
        tstRl0.Country_List__c='USA';
        tstRl0.RF_Studio__c = rfstu.id;
        tstRl0.MPM__c= exMpmLst1[1].Id;
        
        insert tstRl0;
        
        MPM_Release_Date__c rdt0=new MPM_Release_Date__c();
        rdt0.Country__c=cnList1[0].Id;
        rdt0.MPM__c=exMpmLst1[0].Id;
        // rdt0.Format__c='SD';
        // rdt0.Channel__c='EST';
        rdt0.Theatrical_Release_Date__c=System.Today()+30;
        
        insert rdt0;
        
        MPM_Release_Date__c rdt22=new MPM_Release_Date__c();
        rdt22.Country__c=cnList1[0].Id;
        rdt22.MPM__c=exMpmLst1[1].Id;
        rdt22.Format__c='HD';
        rdt22.Channel__c='PPV';
        rdt22.Theatrical_Release_Date__c=System.Today()+10;
        list<MPM_Release_Date__c> releaselist = new list<MPM_Release_Date__c>();
        releaselist.add(rdt22);
        
       // insert rdt22;
        
        MPM__c mpmdis = [SELECT Id,Name,MPM_Short_Desc__c,MPM_Number__c,Content_Type__c FROM MPM__c where name='testMPM2'];
        
        MPM_Release_Date__c  rdt23 = new MPM_Release_Date__c ();
        //rdt23.Country__c=cnList1[0].Id;
        rdt23.MPM__c=mpmdis.Id;
        rdt23.Channel__c='VODc';
        rdt23.Format__c='3DBD';
        rdt23.Theatrical_Release_Date__c=System.Today()+20;
        releaselist.add(rdt23);
        
        
        
        MPM_Release_Date__c  rdt24 = new MPM_Release_Date__c ();
        //rdt23.Country__c=cnList1[0].Id;
        rdt24.MPM__c=exMpmLst1[0].Id;
        rdt24.Channel__c='VODc';
        rdt24.Format__c='3DBD';
        rdt24.Theatrical_Release_Date__c=System.Today()+40;
        releaselist.add(rdt24);
        
        
        MPM_Release_Date__c  rdt25 = new MPM_Release_Date__c ();
        rdt25.Country__c=cnList1[0].Id;
        system.debug('coun'+rdt25.Country__c);
        rdt25.MPM__c=exMpmLst1[0].Id;
        system.debug( 'MPMM'+rdt25.MPM__c);
        rdt25.Channel__c='PPV';
        system.debug('channel'+rdt25.Channel__c);
        rdt25.Format__c='HD+BD';
        system.debug('formate'+rdt25.Format__c);
        rdt25.Theatrical_Release_Date__c=System.Today()+60;
        system.debug('theatrical'+rdt25.Theatrical_Release_Date__c);
        releaselist.add(rdt25);
       
        insert releaselist;
        
        system.debug('rdt23.MPM_Short_Description__c===>'+rdt23.MPM_Short_Description__c);
        system.debug('rdt23.country__C===>'+rdt23.MPM_Short_Description__c);
        
        system.debug('rdt24.country__C===>'+rdt24.MPM_Short_Description__c);
        system.debug('rdt24.MPM_Short_Description__c===>'+rdt24.MPM_Short_Description__c); 
        
        
        
        
       /* rdt0.Theatrical_Release_Date__c=Date.newinstance(System.Today().year()+10, System.Today().month()+10, System.Today().day()-1);
        update rdt0;*/
        
		test.stopTest();        
    }
    
    public static testmethod void ExceptiontestMetHod() 
    {
        list<MPM__c> rlist = new list<MPM__c>();
        insert rlist;
        
    }
}