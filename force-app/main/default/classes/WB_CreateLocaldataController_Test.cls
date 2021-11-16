/******* 
Name:WB_CreateLocaldataController_Test
Creation Date- 05 Nov 2014
Last Modified Date - 
Last Modified by  - 05 Nov 2014
Description- This class is to do code coverage WB_CreateLocalisedTitleController
Author- Tejas Mulye

*******/

@isTest 
private class WB_CreateLocaldataController_Test{


static testMethod void create_localdata(){
   integer localTitleCount;
    //create Title
    
        Title__c title = new Title__c(Name='TestTitle12Sep22', Video_Version__c='12345678901',Digital_Planning__c='YES',Formats__c='SD');
        
        Title__c title2 = new Title__c(Name='TestTitle12Sep', Video_Version__c='123456789',Digital_Planning__c='YES',Formats__c='SD');
        
        insert title2;
        
        List<Title__c> titleList = new List<Title__c>();
        titleList.add(title);
        insert title;
    
    //create Language
        
        Language__c Language = new Language__c (Name='TestLanguage',Language_Order__c = 1);
        insert Language;

    //create Language 2
        
        Language__c Language2 = new Language__c (Name='TestLanguage2',Language_Order__c =1);
        insert Language2;
        
    //create Country
    
        Country__c Country= new Country__c(Name='TestCountry',Country_Code__c='3',Country_Code2__c='2',
        Channel__c = 'DTD',Territory__c='testTerritory');
        insert Country;
 
     //create Country 2
    
        Country__c Country2= new Country__c(Name='TestCountry2',Country_Code__c='5',Country_Code2__c='5',Channel__c = 'DTD');
        insert Country2;
     
        
     Title__c lst_titletest = [SELECT id,name,Video_Version__c FROM Title__c WHERE id = :title.id ];
     
     Title__c lst_titletest2 = [SELECT id,name,Video_Version__c FROM Title__c WHERE id = :title2.id ];
     
     //create Local Data 1
     
        Local_Title__c localdata = new Local_Title__c(Name= 'test local data',Title__c =lst_titletest.id,
        Country__c =Country.id,Language__c=Language.id,
        Status__c='Active',/*Version_EIDR__c='Version EIDR',*/Local_Rating_System__c='A',
        Local_Rating__c='A',Local_Synopsis__c='description for synopsis',Local_Label__c='label',
        Caption_Included_picklist__c='YES',Local_Run_Time__c=0123.00,
        Local_Theatrical_Release_Date__c=date.today(),Local_TV_Air_Date__c=date.today(),
        Local_DVD_Release_Date__c=date.today(),Local_BD_Release_Date__c=date.today(),
        UV_Published_Date__c=date.today(),ALID__c='alid1',CID__c='cid1');
        
     //create Local Data 2
        Local_Title__c localdata2 = new Local_Title__c(Name= 'test local data',Title__c =lst_titletest2.id,
        Country__c =Country2.id,Language__c=Language2.id,
        Status__c='Active',/*Version_EIDR__c='Version EIDR',*/Local_Rating_System__c='A',
        Local_Rating__c='A',Local_Synopsis__c='description for synopsis',Local_Label__c='label',
        Caption_Included_picklist__c='YES',Local_Run_Time__c=0123.00,
        Local_Theatrical_Release_Date__c=date.today(),Local_TV_Air_Date__c=date.today(),
        Local_DVD_Release_Date__c=date.today(),Local_BD_Release_Date__c=date.today(),
        UV_Published_Date__c=date.today(),ALID__c='alid1',CID__c='cid1');
     
        
        List<Local_Title__c> localdataList = new List<Local_Title__c>();
        localdataList.add(localdata);
        localdataList.add(localdata2);
        insert localdataList;
     
       List<Country__c> countryDetail = [Select id,name,Territory__c FROM Country__c
                                         where Territory__c='testTerritory'];                                  
       
       // end to code coverag of LimitCreationOfLocalDataByTerritory     
      Test.startTest();
      PageReference pageRef = Page.WB_CreateLocalisedTitlePage;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', lst_titletest.Id);
      ApexPages.StandardSetController sc = new ApexPages.StandardSetController(localdataList);
      WB_CreateLocalisedTitleController controller = new WB_CreateLocalisedTitleController(sc);
      Local_Title__c localtitleobjs = new Local_Title__c();     
      controller.localtitileobj = localdata;
      controller.localtitileobj = localdata2; 
      controller.savelocalisedtitle();        
      Test.stopTest();
      
  }      
       

}