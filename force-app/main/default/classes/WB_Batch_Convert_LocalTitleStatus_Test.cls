@isTest
public Class WB_Batch_Convert_LocalTitleStatus_Test{
@isTest static Void checkPosAndNeg(){
    List<Country__c> countryList = new List<Country__c>();
    List<Local_Title__c> localTitleList = new List<Local_Title__c>();
    Title__c title = TestUtil.initTitle('Title 1','123456');
        insert title;
        
    Country__c country1 = TestUtil.initCountry('India','In','Ind');
        countryList.add(country1);
    Country__c country2 = TestUtil.initCountry('USA','us','USA');
        country2.Local_Title_Status__c = 'Pending';
        countryList.add(country2);
    insert countryList;
    
    Language__c language = TestUtil.initLanguage('English','en',1);
    insert language;
    
    Local_Title__c localTitle1 = TestUtil.initLocalTitle(language.Id, country1.Id);
        localTitle1.Title__c = title.Id;
        localTitle1.Readiness__c = 'Complete';
        localTitleList.add(localTitle1);
    Local_Title__c localTitle2 = TestUtil.initLocalTitle(language.Id, country2.Id);
        localTitle2.Name = 'LT 2';
        localTitle2.Title__c = title.Id;
        localTitleList.add(localTitle2);
    insert localTitleList;
    WB_Batch_Convert_LocalTitleStatus batchInstance = new WB_Batch_Convert_LocalTitleStatus();
    Test.StartTest();
        Database.executeBatch(batchInstance);
    Test.StopTest();
    List<Local_Title__c> ltList1 = [SELECT Id,Readiness__c FROM Local_Title__c WHERE Readiness__c = 'Confirmed'];
        System.assertEquals(1,ltList1.size());
    List<Local_Title__c> ltList2 = [SELECT Id FROM Local_Title__c WHERE Readiness__c = 'Pending'];
        System.assertEquals(1,ltList2.size());
    
}
}