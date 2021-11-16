/*******************************************************************************************************************************************
* File Name     :   WB_MpmRdReleaseDateRollDownTest
* Description   :   Test class for Batch class MpmRdReleaseDateRollDown 
* @author       :   CTS
* Modification Log
===================================================================================================------------------
* Ver.    Date              Author              Modification
------------------------------------------------------------------------------------------------------------------
* 1.0     23 Oct.2018        CTS                ER-002171  
********************************************************************************************************************************************/
@isTest
private class WB_MpmRdReleaseDateRollDownTest{
    public static List<MPM_Release_Date__c> allMPMReleaseDate=new List<MPM_Release_Date__c>();
    public static String localTitleId;
    Public Static Set<String> LTIDs;
    
       public static void setupData(){
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Announcement_Rule__c annType = TestUtil.initAnnouncementType(acctGoogle.id);
        
        MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
        insert mpm1;
        
        Title__c title1 = TestUtil.initTitle('TestGoogle', '6000047545');
        title1.Digital_Planning__c= 'Yes';
        title1.Formats__c = 'SD';
        title1.mpm__c = mpm1.id;
        insert title1;
        
        Country__c countryFrance = TestUtil.initCountry('TestFrance', 'TR', 'TF');
        insert countryFrance;
        
        Language__c languageFrench = TestUtil.initLanguage('TestFrench', 'fr', 1);
        insert languageFrench;
                
        Local_Title__c localTitle = TestUtil.initLocalTitle(languageFrench.Id, countryFrance.Id);
        localTitle.Title__c=title1.Id;
        insert localTitle;
        localTitleId=localTitle.id;
        
        
        
        system.debug('localTitleId****'+localTitleId);
        MPM_Release_Date__c mpmRDEst=new MPM_Release_Date__c(
                                    MPM__c=mpm1.Id,
                                    Channel__c='EST',
                                    Country__c=countryFrance.Id,
                                    Language__c=languageFrench.Id,
                                    Release_Start__c=date.today(),
                                    Locale__c='fr_TR',
                                    Format__c='SD',
                                    Release_Status__c='Confirmed');
        allMPMReleaseDate.add(mpmRDEst);
        
        MPM_Release_Date__c mpmRDEst2=new MPM_Release_Date__c(
                                    MPM__c=mpm1.Id,
                                    Channel__c='EST',
                                    Country__c=countryFrance.Id,
                                    Language__c=languageFrench.Id,
                                    Release_Start__c=date.today().addDays(-1),
                                    Locale__c='fr_TR',
                                    Release_Status__c='Tentative');
        allMPMReleaseDate.add(mpmRDEst2);
        
        MPM_Release_Date__c mpmRDPhysical=new MPM_Release_Date__c(
                                    MPM__c=mpm1.Id,
                                    Channel__c='Physical',
                                    Country__c=countryFrance.Id,
                                    Language__c=languageFrench.Id,
                                    Release_Start__c=date.today(),
                                    Locale__c='fr_TR',
                                    Release_Status__c='Confirmed');
        allMPMReleaseDate.add(mpmRDPhysical);
        
        MPM_Release_Date__c mpmRDVODi=new MPM_Release_Date__c(
                                    MPM__c=mpm1.Id,
                                    Channel__c='VODi',
                                    Country__c=countryFrance.Id,
                                    Language__c=languageFrench.Id,
                                    Release_Start__c=date.today(),
                                    Locale__c='fr_TR',
                                    Release_Status__c='Confirmed');
        allMPMReleaseDate.add(mpmRDVODi);
        
        //New Data for new method - START - ER-002171
                MPM__c mpm2 = new MPM__c(Name='12346',MPM_Family_Desc__c='test family1',MPM_Short_Desc__c='test short1',MPM_Number__c='12346');   
        insert mpm2;
        
        Title__c title2 = TestUtil.initTitle('TestGoogleNew', '6000047544');
        title2.Digital_Planning__c= 'Yes';
        title2.Formats__c = 'SD';
        title2.mpm__c = mpm2.id;
        insert title2;
        
        Country__c countryIndia = TestUtil.initCountry('TestIndia', 'IR', 'IF');
        insert countryIndia;
        
        Language__c languageHindi = TestUtil.initLanguage('TestHindi', 'hi', 1);
        insert languageHindi;
                
        Local_Title__c localTitle2 = TestUtil.initLocalTitle(languageHindi.Id, countryIndia.Id);
        localTitle2.Title__c=title2.Id;
        insert localTitle2;
        //localTitleId2=localTitle2.id;
        
        set<ID> LTIDs = new set<Id>();
        LTIDs.add(localTitleId);
        LTIDs.add(localTitle2.id);
        
        MPM_Release_Date__c mpmRDVODi2=new MPM_Release_Date__c(
                                    MPM__c=mpm2.Id,
                                    Channel__c='VODi',
                                    Country__c=countryIndia.Id,
                                    Language__c=languageHindi.Id,
                                    Release_Start__c=date.today()+12,
                                    Locale__c='hi_IR',
                                    Release_Status__c='Cancel');
        allMPMReleaseDate.add(mpmRDVODi2);
        
        MPM_Release_Date__c mpmRDPhysical2=new MPM_Release_Date__c(
                                    MPM__c=mpm2.Id,
                                    Channel__c='Physical',
                                    Country__c=countryIndia.Id,
                                    Language__c=languageHindi.Id,
                                    Release_Start__c=date.today()+3,
                                    Locale__c='hi_IR',
                                    Release_Status__c='Cancel');
        allMPMReleaseDate.add(mpmRDPhysical2);
        
        MPM_Release_Date__c mpmRDEst3=new MPM_Release_Date__c(
                                    MPM__c=mpm2.Id,
                                    Channel__c='EST',
                                    Country__c=countryIndia.Id,
                                    Language__c=languageHindi.Id,
                                    Release_Start__c=date.today()+10,
                                    Locale__c='hi_IR',
                                    Format__c='SD',
                                    Release_Status__c='Cancel');
        allMPMReleaseDate.add(mpmRDEst3);
        //New Data for new method - END ER-002171
        
        
        Rights_Group__c rightsGroup=new Rights_Group__c(
                                    Name='fr_TR',
                                    Country__c=countryFrance.id,
                                    Language__c=languageFrench.Id,
                                    Release_Locale__c='fr_TR');
                                    
        insert rightsGroup;
        
        Rights_Group__c rightsGroup1=new Rights_Group__c(
                                    Name='hi_IR',
                                    Country__c=countryIndia.id,
                                    Language__c=languageHindi.Id,
                                    Release_Locale__c='hi_IR');
        insert rightsGroup1;
        
    }
    
    @isTest static void WB_MpmRdReleaseDateRollDown(){
        
        setupData();
        Test.StartTest();
        insert allMPMReleaseDate;
        Test.StopTest();
        
        Local_Title__c localTitleQueried = [SELECT Initial_Physical_Release_Date__c,Initial_EST_Release_Date__c,Initial_VOD_Release_Date__c 
                                            FROM Local_Title__c 
                                            WHERE Id = :localTitleId];
        Date physicalDate=localTitleQueried.Initial_Physical_Release_Date__c;
        Date estDate=localTitleQueried.Initial_EST_Release_Date__c;
        Date vodDate=localTitleQueried.Initial_VOD_Release_Date__c;
        system.assertEquals(allMPMReleaseDate[0].Release_Start__c,estDate);
        //System.assertEquals(allMPMReleaseDate[1].Release_Start__c,estDate);
        //System.assertEquals(allMPMReleaseDate[2].Release_Start__c,physicalDate);
        //System.assertEquals(allMPMReleaseDate[3].Release_Start__c,vodDate);
        
        
    }
    
    
    
    @isTest static void WB_BatchMpmRdReleaseDateRollDown(){
        setupData();
        insert allMPMReleaseDate;
        
        Test.StartTest();
        WB_BatchMpmRdReleaseDateRollDown p = new WB_BatchMpmRdReleaseDateRollDown(system.now().addhours(-1),system.now());
        String sch = '0 0 13 * * ?';
        system.schedule('Roll Down', sch, p);
        Test.StopTest();
        
        
        Local_Title__c localTitleQueried = [SELECT Initial_Physical_Release_Date__c,Initial_EST_Release_Date__c,Initial_VOD_Release_Date__c FROM Local_Title__c WHERE Id = :localTitleId];
        Date physicalDate=localTitleQueried.Initial_Physical_Release_Date__c;
        Date estDate=localTitleQueried.Initial_EST_Release_Date__c;
        Date vodDate=localTitleQueried.Initial_VOD_Release_Date__c;
        System.assertEquals(allMPMReleaseDate[0].Release_Start__c,estDate);
        System.assertEquals(allMPMReleaseDate[2].Release_Start__c,physicalDate);
        System.assertEquals(allMPMReleaseDate[3].Release_Start__c,vodDate);
        
        
    }
    
}