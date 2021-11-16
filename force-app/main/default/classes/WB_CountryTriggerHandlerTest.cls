/*******************************************************************************************************************************************
* File Name     :   WB_CountryTriggerHandlerTest
* Description   :   Test class for WB_CountryTriggerHandler.
* @author       :   CTS
* Modification Log
===================================================================================================
* Ver.    Date              Author              Modification
---------------------------------------------------------------------------------------------------
*
********************************************************************************************************************************************/


@isTest
public Class WB_CountryTriggerHandlerTest{
  
    @isTest
    public static void countryTriggerHandlerTestMethod1(){
        List<WB_Queue_Id__c> queList=new List<WB_Queue_Id__c>();
        List<Country__c> countryList=new List<Country__c>();
        
        WB_Queue_Id__c q=new WB_Queue_Id__c();
        q.Name='AAAA';
        q.Value__c='123456789';
        queList.add(q);
        
        WB_Queue_Id__c q1=new WB_Queue_Id__c();
        q1.Name='BBB';
        q1.Value__c='987456321';
        queList.add(q1);
        insert queList;
        
        Country__c c=new Country__c();
        c.Name='Switzerland';
        c.Country_Code__c='Tes';
        c.Country_Code2__c='Te';
        countryList.add(c);
        
        Country__c c1=new Country__c();
        c1.Name='UK';
        c1.Country_Code__c='UK1';
        c1.Country_Code2__c='UK';
        c1.Physical_Owner__c='AAAA';
        c1.Digital_Owner__c='BBB';
        countryList.add(c1);
        
        Country__c c2=new Country__c();
        c2.Name='USA';
        c2.Country_Code__c='USA';
        c2.Country_Code2__c='US';
        c2.Physical_Owner__c='XYZ';
        c2.Digital_Owner__c='123';
        countryList.add(c2);
        
        Country__c c3=new Country__c();
        c3.Name='Germany';
        c3.Country_Code__c='DEe';
        c3.Country_Code2__c='DE';
        c3.Physical_Owner__c='AAAA';
        c3.Digital_Owner__c='BBB';
        
        insert c3;
        
        c3.Physical_Owner__c='XYZ';
        c3.Digital_Owner__c='123';
        
        countryList.add(c3);
        Schema.SObjectField f=Country__c.Id;
        
        
        test.startTest();
           Database.upsert(countryList,f,False); 
           system.debug('countryList****'+countryList);
        test.stopTest();
        List<Country__c> cList=[SELECT Id FROM Country__c];
        System.assertEquals(3, cList.size());
        
    }
    @isTest
    public static void primaryRatingTest(){
    
     List<WB_Queue_Id__c> queList=new List<WB_Queue_Id__c>();
     List<Country__c> countryList=new List<Country__c>();  
     
     WB_Queue_Id__c q=new WB_Queue_Id__c();
        q.Name='AAAA';
        q.Value__c='123456789';
        queList.add(q);
        
        WB_Queue_Id__c q1=new WB_Queue_Id__c();
        q1.Name='BBB';
        q1.Value__c='987456321';
        queList.add(q1);
        insert queList;     
                
        Country__c c1=new Country__c();
        c1.Name='Abcde';
        c1.Country_Code__c='Abc';
        c1.Country_Code2__c='Ab';
        c1.Physical_Owner__c='AAAA';
        c1.Digital_Owner__c='BBB';
        c1.Valid_Rating_Systems__c='ae-movies';
        c1.Default_Feature_Rating_Systems__c='ae-movies'; 
        c1.Default_TV_Rating_System__c='ae-movies';
        countryList.add(c1);
       
         
        test.startTest();
        Database.insert(countryList);
        test.stopTest();
     }
}