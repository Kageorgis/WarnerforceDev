/*
Class Name   : WB_Populate_ReleaseDate_Test 
Description  : This class is to do code coverage for WB_Populate_ReleaseDate class   */


@isTest
private class WB_Populate_ReleaseDate_Test {

    private static testMethod void testOnLocalDataPositiveScenario() {
        
        //Create Coutry records
        list<Country__c> countryList = new list<Country__c>();
        
        Country__c countryArgentina =new Country__c(Name ='Argentina',Country_Code2__c ='ARG',Country_Code__c='AR');
        Country__c countryGermany =new Country__c(Name ='Germany',Country_Code2__c ='778',Country_Code__c='F88');
        
        countryList.add(countryArgentina);
        countryList.add(countryGermany);
        insert countryList;

        //Create Language records
        List<Language__c> languageList = new List<Language__c>();
        
        Language__c languageEnglish = new Language__c(Name='English',Language_Order__c = 1);
        languageList.add(languageEnglish);
        
        Language__c languageGerman = new Language__c(Name='German',Language_Order__c = 1);
        languageList.add(languageGerman);
        
        insert languageList;
        
        //Create MPM records
        MPM__c mpm = new MPM__c(name='MPM Test',MPM_Number__c='56789');
        insert mpm;
        
        //Create Title Records
        list<title__c> titleList = new list<title__c>();
        
        Title__c titleRecord1 = new Title__c(Name='Ant Bully, The',Video_Version__c='6000008302',MPM_Long_Desc__c='The Ant Bully',Content_Type__c='Feature',
                                            MPM__c=mpm.id,Status__c='Active',Digital_Planning__c = 'Yes',Clear_to_Avail__c=true,Studio__c='WARNER BROS.',
                                            US_DVD_Release_Date__c=date.Today()-15,US_UV_Publish_Date__c=date.Today()-30,Territory__c='Home Office',Formats__c='SD');
                                            
        Title__c titleRecord2 = new Title__c(Name='Ant Bully, The (BD)',Video_Version__c='6000062639',MPM_Long_Desc__c='The Ant Bully',Content_Type__c='Feature',
                                            MPM__c=mpm.id,Status__c='Active',Digital_Planning__c = 'Yes',Clear_to_Avail__c=true,Studio__c='WARNER BROS.',
                                            US_DVD_Release_Date__c=date.Today()-15,US_UV_Publish_Date__c=date.Today()-30,Territory__c='Home Office',Formats__c='SD');
        titleList.add(titleRecord1);
        titleList.add(titleRecord2);
        insert titleList;
        
        list<MPM_Release_Date__c> mpmReleaseDateList = new List<MPM_Release_Date__c>();
        
        MPM_Release_Date__c mpmReleaseDate1 = new MPM_Release_Date__c(Language__c =languageList[0].Id ,
                                                                      Country__c =countryList[0].Id,
                                                                      Theatrical_Release_Date__c=date.today()-2,  
                                                                      MPM__c=mpm.Id
                                                                       );
        insert mpmReleaseDate1;

        //Create Local Title Data Records
        list<Local_Title__c> localTitleList = new list<Local_Title__c>();
        
        Local_Title__c localtitle1 = new Local_Title__c(Name='test Local Title',Title__c = titleRecord1.Id, Country__c = countryList[0].Id,Language__c = languageList[0].Id,
        Local_Box_Office__c=1245.00);
        
        Local_Title__c localtitle2 = new Local_Title__c(Name='testCTS Local Title',Title__c = titleRecord2.Id, Country__c = countryList[1].Id, Language__c = languageList[1].Id,
        Local_Box_Office__c=1300.00);
        
        localTitleList.add(localtitle1);
        localTitleList.add(localtitle2);
        
        insert localTitleList;

        
        Test.startTest();
            WB_Populate_ReleaseDate instancevar = new WB_Populate_ReleaseDate();      
            String sch = '0  00 1 3 * ?';
            system.schedule('Test', sch, instancevar);
         Test.stopTest();
         List<Local_Title__c> LocalTitleRecs = [select id from Local_Title__c];
         system.assertNotEquals(NULL,LocalTitleRecs);
    }


}