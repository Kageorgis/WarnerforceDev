@isTest
private class WB_ReleasePlanTriggerHandler_Test 
{    
    private static testMethod void test() 
    {
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        MPM__c mpm = TestUtil.createMPM('2070337');
        insert mpm;
        
        Title__c title = TestUtil.createTitle('Batman Returns','6000100174');
        title.Digital_Planning__c = 'Yes';
        title.Formats__c = 'SD';
        insert title;
        
        Country__c countryFrance = TestUtil.initCountry('TestFrance', 'TR', 'TF');
        insert countryFrance;
        
        Language__c languageFrench = TestUtil.initLanguage('TestFrench', '', 1);
        insert languageFrench;
        
        Agreement__c storeFront = TestUtil.initStoreFront2(acctGoogle.Id, countryFrance.Id);
        Insert storeFront;
        
        Local_Title__c locTitle = TestUtil.createLocalData('20010', countryFrance, languageFrench, 'French', title.Id);
        Insert locTitle;
        
        Available_Languages__c avl1 = TestUtil.initAvailableLang(languageFrench.Id, 'Sub', title.Id);
        Insert avl1;
        
        Available_Languages__c avl2 = TestUtil.initAvailableLang(languageFrench.Id, 'Audio', title.Id);
        Insert avl2;
        
        Commercial_Avail__c rp = TestUtil.initReleasePlan(title.Id, locTitle.Id, countryFrance.Id, languageFrench.Id);
        rp.Exclusive_Date__c = date.today() - 1;
        rp.Rights_End__c = date.today() + 11;
        rp.Start_Date__c = date.today();
        rp.End_Date__c = date.today() + 10;
        Insert rp;
                
        Commercial_Avail__c rp2 = TestUtil.initReleasePlan(title.Id, locTitle.Id, countryFrance.Id, languageFrench.Id);
        rp2.Language_Type__c = 'Sub & Audio';
        rp2.Exclusive_Date__c = date.today() + 3;
        rp2.Rights_End__c = date.today() + 12;
        rp2.Start_Date__c = date.today() + 5;
        rp2.End_Date__c = date.today() + 10;
        Insert rp2;
        
        test.startTest();
        
        rp.Language_Type__c = 'Audio';
        update rp;
        
        rp.Language_Type__c = 'Sub & Audio';
        try{
            update rp;
        }
        catch(exception e)
        {
            system.assert(e.getMessage().contains('One or More Release Plans With Matching attributes Already Exist For Start & End Date Window'));
        }
        
        test.stopTest();       
    }    
}