@isTest
public class MPMReleaseDateTriggerTest
{
    static testMethod void testMPMReleaseDateTrigger()
    {
        Test.startTest();
        
        MPM__c mpm = Testutil.createMPM('10001');
        insert mpm;
        
        Title__c title = Testutil.createTitle('Test', '20001');
        title.MPM__c = mpm.Id;
        insert title;
        
        list<Country__c> cList = new list<Country__c>();
        Country__c usa = TestUtil.createCountry('India', 'IN', 'IND');
        cList.add(usa);
        Country__c india = TestUtil.createCountry('India', 'US', 'USA');
        cList.add(india);
        insert cList;
        
        list<Language__c> lList = new list<Language__c>();
        Language__c eng = TestUtil.createLanguage('English', 'EN',1);
        lList.add(eng);
        Language__c hin = TestUtil.createLanguage('Hindi', 'HN',1);
        lList.add(hin);
        insert lList;
        
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',MPM__c=mpm.id,Video_Version__c ='555555',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,
        US_BD_Release_Date__c=date.today()-3,US_TV_Air_Date__c=date.today()-3,US_UV_Publish_Date__c=date.today()-3,US_Box_Office__c=1111.00,US_DVD_Release_Date__c=date.today()-3,
        US_Pay_TV_Start_Date__c = date.today()-3,Formats__c='SD');
        insert title1;
        
        Rights_Group__c locales = new Rights_Group__c(Name ='na_SP',Country__c =usa.Id,Language__c= eng.id,Release_Locale__c='na_SP');
        insert locales;
        
        list<Local_Title__c> ltList = new list<Local_Title__c>();
        Local_Title__c LT = TestUtil.createLocalData('555555', usa, eng, 'US_EN', title.Id);
        LT.Local_Theatrical_Release_Date__c = Date.today();
        LT.Title__c = title1.id;
        ltList.add(LT);
        Local_Title__c LT1 = TestUtil.createLocalData('20001', india, eng, 'IN_EN', title.Id);
        ltList.add(LT1);
        Local_Title__c LT2 = TestUtil.createLocalData('20001', india, hin, 'IN_HN', title.Id);
        LT2.Local_Theatrical_Release_Date__c = Date.today();
        ltList.add(LT2);
        insert ltList;
        
        list<MPM_Release_date__c> mrdList = new list<MPM_Release_date__c>();
        MPM_Release_date__c mrd = TestUtil.createMPMReleaseDate(mpm.Id, usa.Id, Date.today(), Date.today().addDays(7));
        mrd.Locale__c ='na_SP';
        mrd.Format__c ='DVD';
        mrd.Release_Status__c ='Confirmed';
        mrd.Record_Status__c = 'Active';
        mrdList.add(mrd);
        MPM_Release_date__c mrd1 = TestUtil.createMPMReleaseDate(mpm.Id, india.Id, Date.today(), Date.today().addDays(8));
        mrdList.add(mrd1);
        insert mrdList;
        
        Local_Title__c LTitle = [select id, Local_Theatrical_Release_Date__c, Local_TV_Air_Date__c from Local_Title__c where Id =:LT.Id];
        System.assertEquals(LTitle.Local_Theatrical_Release_Date__c, Date.today());
        System.assertEquals(LTitle.Local_TV_Air_Date__c, null);
        
        Local_Title__c LTitle1 = [select id, Local_Theatrical_Release_Date__c, Local_TV_Air_Date__c from Local_Title__c where Id =:LT2.Id];
        System.assertEquals(LTitle1.Local_Theatrical_Release_Date__c, Date.today());
        System.assertEquals(LTitle1.Local_TV_Air_Date__c, null);
        
       
        
        Test.stopTest();
    }
}