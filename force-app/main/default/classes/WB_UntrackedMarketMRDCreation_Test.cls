@isTest
public class WB_UntrackedMarketMRDCreation_Test {
    
    @testSetup
    static void createData(){
        
        //Create Untracked_Markets_TRD_Offset__c Custom Setting Data
        List<Untracked_Markets_TRD_Offset__c> lstcustSetData =new List<Untracked_Markets_TRD_Offset__c>();
        Untracked_Markets_TRD_Offset__c custSetData = new Untracked_Markets_TRD_Offset__c(Name='Equals TM_Monday', Untracked_Market_TRD_Offset__c=0);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='Equals TM_Tuesday', Untracked_Market_TRD_Offset__c=0);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='Equals TM_Wednesday', Untracked_Market_TRD_Offset__c=0);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='Equals TM_Thursday', Untracked_Market_TRD_Offset__c=0);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='Equals TM_Friday', Untracked_Market_TRD_Offset__c=0);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='Equals TM_Saturday', Untracked_Market_TRD_Offset__c=0);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='Equals TM_Sunday', Untracked_Market_TRD_Offset__c=0);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='Friday After TM_Monday', Untracked_Market_TRD_Offset__c=4);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='Friday After TM_Tuesday', Untracked_Market_TRD_Offset__c=3);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='Friday After TM_Wednesday', Untracked_Market_TRD_Offset__c=2);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='Friday After TM_Thursday', Untracked_Market_TRD_Offset__c=1);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='Friday After TM_Friday', Untracked_Market_TRD_Offset__c=0);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='Friday After TM_Saturday', Untracked_Market_TRD_Offset__c=6);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='Friday After TM_Sunday', Untracked_Market_TRD_Offset__c=5);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='TM +7 Days_Monday', Untracked_Market_TRD_Offset__c=7);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='TM +7 Days_Tuesday', Untracked_Market_TRD_Offset__c=7);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='TM +7 Days_Wednesday', Untracked_Market_TRD_Offset__c=7);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='TM +7 Days_Thursday', Untracked_Market_TRD_Offset__c=7);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='TM +7 Days_Friday', Untracked_Market_TRD_Offset__c=7);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='TM +7 Days_Saturday', Untracked_Market_TRD_Offset__c=7);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='TM +7 Days_Sunday', Untracked_Market_TRD_Offset__c=7);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='Wednesday After TM_Monday', Untracked_Market_TRD_Offset__c=2);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='Wednesday After TM_Tuesday', Untracked_Market_TRD_Offset__c=1);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='Wednesday After TM_Wednesday', Untracked_Market_TRD_Offset__c=0);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='Wednesday After TM_Thursday', Untracked_Market_TRD_Offset__c=6);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='Wednesday After TM_Friday', Untracked_Market_TRD_Offset__c=5);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='Wednesday After TM_Saturday', Untracked_Market_TRD_Offset__c=4);
        lstcustSetData.add(custSetData);
        custSetData = new Untracked_Markets_TRD_Offset__c(Name='Wednesday After TM_Sunday', Untracked_Market_TRD_Offset__c=3);
        lstcustSetData.add(custSetData);        
        insert lstcustSetData;

        //Create MPM Record
        MPM__c mpmRec = TestUtil.initMPM('9999999');
        insert mpmRec;
        
        // Create country record
        List<Country__c> lstCountry = new List<Country__c>();
        Country__c countryTrackedRec = TestUtil.initCountry('USA', 'US', 'USA');
        insert countryTrackedRec;
        Country__c countryRec = TestUtil.initCountry('Bermuda', 'BM', 'BMU');
        countryRec.Tracked_Market__c=countryTrackedRec.Id;
        countryRec.Untracked_Market_TRD_Calc__c='Equals TM';
        lstCountry.add(countryRec);
        countryRec = TestUtil.initCountry('Cambodia', 'KH', 'KHM');
        countryRec.Tracked_Market__c=countryTrackedRec.Id;
        countryRec.Untracked_Market_TRD_Calc__c='Friday After TM';
        lstCountry.add(countryRec);
        countryRec = TestUtil.initCountry('Cayman Islands', 'KY', 'CYM');
        countryRec.Tracked_Market__c=countryTrackedRec.Id;
        countryRec.Untracked_Market_TRD_Calc__c='TM +7 Days';
        lstCountry.add(countryRec);
        countryRec = TestUtil.initCountry('Dominica', 'DM', 'DMA');
        countryRec.Tracked_Market__c=countryTrackedRec.Id;
        countryRec.Untracked_Market_TRD_Calc__c='Wednesday After TM';
        lstCountry.add(countryRec);
        insert lstCountry;
    }
    
    @isTest
    static void createSingleTrackedMRD(){
        
        MPM__c mpmRec = [SELECT Id,Name FROM MPM__c WHERE Name = '9999999'];
        Country__c countryRec = [SELECT Id,Name FROM Country__c WHERE Name = 'USA'];
        
        //Created MRD Record for USA
        MPM_Release_Date__c lstMRD =new MPM_Release_Date__c(MPM__c=mpmRec.Id,Country__c=countryRec.Id,Theatrical_Release_Date__c=date.newInstance(2019,04,20));
        insert lstMRD;
        
        //Check if Count is same(5) as per the tracked and untracked marcket records
        System.assertEquals(5, [SELECT count() FROM MPM_Release_Date__c WHERE MPM__r.Name = '9999999']);
    }
    
    @isTest
    static void flowDate2KeyTo4Key(){
		
        MPM__c mpmRec = [SELECT Id,Name FROM MPM__c WHERE Name = '9999999'];
        Country__c countryRec = [SELECT Id,Name FROM Country__c WHERE Name = 'USA'];
        
        //Create 4 Key MRD for USA
        MPM_Release_Date__c mrdRec =new MPM_Release_Date__c(MPM__c=mpmRec.Id, Country__c=countryRec.Id, Locale__c='na_US', Record_Status__c='Active', Channel__c='Physical', Format__c='3DBD', Avail_Start__c=date.newInstance(2019,04,15), Release_Start__c=date.newInstance(2019,04,15), Release_Status__c='Draft', EAI_Processing_Status__c = 'Ready To Process',Key__c='2067815_na_US_Physical_3DBD');
        insert mrdRec;
        
        //This should returns TRD as null
        System.assertEquals(null, [SELECT Id,Theatrical_Release_Date__c FROM MPM_Release_Date__c WHERE Key__c = '2067815_na_US_Physical_3DBD' Limit 1].Theatrical_Release_Date__c);
        
        //Created 2 Key MRD Record for USA
        mrdRec =new MPM_Release_Date__c(MPM__c=mpmRec.Id,Country__c=countryRec.Id,Theatrical_Release_Date__c=date.newInstance(2019,04,20));
        insert mrdRec;
        
        //This should returns TRD date(04/20/2019) same as 2 Key MRD Country Record, as the TRD should flow from 2 Key MRD Country to 4 Key RP MRD record.
        System.assertEquals(date.newInstance(2019,04,20), [SELECT Id,Theatrical_Release_Date__c FROM MPM_Release_Date__c WHERE Key__c = '2067815_na_US_Physical_3DBD' Limit 1].Theatrical_Release_Date__c);
        
        //This should returns same date(04/20/2019) as the calculation picklist on the country is null(this is a tracked market record)
        System.assertEquals(date.newInstance(2019,04,20), [SELECT Id,Theatrical_Release_Date__c FROM MPM_Release_Date__c WHERE Key__c = '9999999_US' Limit 1].Theatrical_Release_Date__c);
        
        MPM_Release_Date__c mrd = [SELECT Id,Theatrical_Release_Date__c FROM MPM_Release_Date__c WHERE Key__c = '9999999_US' Limit 1];
        mrd.Theatrical_Release_Date__c = null;
        
        update mrd;
        
        //This should returns TRD date(null) same as 2 Key MRD Country Record, as the TRD should flow from 2 Key MRD Country to 4 Key RP MRD record.
        System.assertEquals(null, [SELECT Id,Theatrical_Release_Date__c FROM MPM_Release_Date__c WHERE Key__c = '2067815_na_US_Physical_3DBD' Limit 1].Theatrical_Release_Date__c);
        
        //This should returns same date(null) as the calculation picklist on the country is null(this is a tracked market record)
        System.assertEquals(null, [SELECT Id,Theatrical_Release_Date__c FROM MPM_Release_Date__c WHERE Key__c = '9999999_US' Limit 1].Theatrical_Release_Date__c);
    }
    
    @isTest
    static void flowNullDate2KeyTo4Key(){
                
        MPM__c mpmRec = [SELECT Id,Name FROM MPM__c WHERE Name = '9999999'];
        Country__c countryRec = [SELECT Id,Name FROM Country__c WHERE Name = 'USA'];
        
        //Create 4 Key MRD for USA
        MPM_Release_Date__c mrdRec =new MPM_Release_Date__c(MPM__c=mpmRec.Id, Country__c=countryRec.Id, Locale__c='na_US', Record_Status__c='Active', Channel__c='Physical', Format__c='3DBD', Avail_Start__c=date.newInstance(2019,04,15), Release_Start__c=date.newInstance(2019,04,15), Release_Status__c='Draft', EAI_Processing_Status__c = 'Ready To Process',Key__c='2067815_na_US_Physical_3DBD');
        insert mrdRec;
        
        //This should returns TRD as null
        System.assertEquals(null, [SELECT Id,Theatrical_Release_Date__c FROM MPM_Release_Date__c WHERE Key__c = '2067815_na_US_Physical_3DBD' Limit 1].Theatrical_Release_Date__c);
        
        //Created 2 Key MRD Record for USA
        mrdRec =new MPM_Release_Date__c(MPM__c=mpmRec.Id,Country__c=countryRec.Id,Theatrical_Release_Date__c=null);
        insert mrdRec;
        
        //This should returns TRD date(null) same as 2 Key MRD Country Record, as the TRD should flow from 2 Key MRD Country to 4 Key RP MRD record.
        System.assertEquals(null, [SELECT Id,Theatrical_Release_Date__c FROM MPM_Release_Date__c WHERE Key__c = '2067815_na_US_Physical_3DBD' Limit 1].Theatrical_Release_Date__c);
        
        //This should returns same date(null) as the calculation picklist on the country is null(this is a tracked market record)
        System.assertEquals(null, [SELECT Id,Theatrical_Release_Date__c FROM MPM_Release_Date__c WHERE Key__c = '9999999_US' Limit 1].Theatrical_Release_Date__c);
    }
    
    @isTest
    static void flowRollUp2KeyTo4Key(){
		
        MPM__c mpmRec = [SELECT Id,Name,Generic__c FROM MPM__c WHERE Name = '9999999'];
        System.debug('mpmRec==='+mpmRec);
        Country__c countryRec = [SELECT Id,Name FROM Country__c WHERE Name = 'USA'];
        
        //Create Title Record
        Title__c titleRec = TestUtil.initTitle('New Title','1111111111');
        titleRec.MPM__c=mpmRec.Id;
        insert titleRec;
		
        // Create Language record
        Language__c langRec = TestUtil.initLanguage('English', 'EN',1);
        insert langRec;
        
        // Create Local Title
        Local_Title__c localTitleRec = TestUtil.initLocalTitle(langRec.Id, countryRec.Id);
        localTitleRec.Title__c = titleRec.Id;
        insert localTitleRec;
        
        //Create Locale
        //Rights_Group__c localeRec = TestUtil.initRightsGroup(countryRec, langRec, 'USA');
        //localeRec.Release_Locale__c = 'na_US';
        //insert localeRec;
        
        // Create Release Plan
        Commercial_Avail__c relPlanRec = TestUtil.initReleasePlan(titleRec.Id, localTitleRec.Id, countryRec.Id, langRec.Id);
        relPlanRec.MRD_Roll_up__c = true;
        relPlanRec.Release_Locale__c = 'na_US';
 		insert relPlanRec;
        System.debug('relPlanRec==='+relPlanRec.MPM_Release_Date_Key__c);
        System.debug('rel rec==='+[Select Id,Release_Locale__c,Channel__c,Format__c,Title__r.MPM__r.Generic__c,MPM_Release_Date_Key__c FROM Commercial_Avail__c]);
        //Created 2 Key MRD Record for USA
        MPM_Release_Date__c mrdRec =new MPM_Release_Date__c(MPM__c=mpmRec.Id,Country__c=countryRec.Id,Theatrical_Release_Date__c=date.newInstance(2019,08,05));
        insert mrdRec;
        
        Test.startTest();
        Database.executeBatch((new WB_Batch_MPMRD_Rollup((new Map<Id,Commercial_Avail__c>([SELECT Id
                                                                                           FROM Commercial_Avail__c
                                                                                           WHERE MPM_Release_Date_Key__c != null AND (MRD_Roll_up__c = True OR MPMRD_Mismatch__c = TRUE) LIMIT 10000]
                                                                                         )).keySet())));
        Test.stopTest();
		/*
        WB_CheckingDateOverlapController.UpdateMRMReleaseDate([SELECT Id, Name, Title__c, Title__r.MPM__c, Exclusive_Date__c, Start_Date__c, Status__c,
                                                               MPM_Release_Date_Key__c, Languages__c, Country_Lookup__c, Channel__c, Format__c, Release_Locale__c,MRD_ID__c
                                                               FROM Commercial_Avail__c
                                                               WHERE MPM_Release_Date_Key__c != null AND (MRD_Roll_up__c = True OR MPMRD_Mismatch__c = TRUE)]);
        
        System.debug('MMRD==='+[SELECT Id,Theatrical_Release_Date__c,Key__c FROM MPM_Release_Date__c]);
		*/
        System.assertEquals(date.newInstance(2019,08,05), [SELECT Id,Theatrical_Release_Date__c
                                                           FROM MPM_Release_Date__c
                                                           WHERE Key__c = '9999999_na_US_VODc_HD' Limit 1].Theatrical_Release_Date__c
                           );
    }
}