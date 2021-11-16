@isTest
private class WB_Batch_UpdateEADtWeeklySync_Test {
    @isTest static void WB_Batch_UpdateEarliestAvailDtRecs(){
Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Announcement_Rule__c annType = TestUtil.initAnnouncementType(acctGoogle.id);
        
        MPM__c mpm1 = new MPM__c(Name='123456',MPM_Family_Desc__c='test family',MPM_Short_Desc__c='test short',MPM_Number__c='123456');   
        insert mpm1;
        
        
        Title__c title1 = TestUtil.initTitle('TestGoogle', '6000047545');
        title1.Digital_Planning__c= 'Yes';
        title1.Formats__c = 'HD';
        title1.mpm__c = mpm1.id;
        insert title1;
        
        Country__c countryFrance = TestUtil.initCountry('TestFrance', 'TR', 'TF');
        insert countryFrance;
        
        Pricing__c pricing = TestUtil.initPricing(acctGoogle.Id, countryFrance.Id);
        pricing.Price_Code_Status__c = 'Active' ;
        insert pricing;
        
        Language__c languageFrench = TestUtil.initLanguage('TestFrench', '', 1);
        insert languageFrench;
        
        Local_Title__c localTitle = TestUtil.initLocalTitle(languageFrench.Id, countryFrance.Id);
        localTitle.Title__c = title1.Id;
        insert localTitle;
        
        Commercial_Avail__c CommercialAvail = TestUtil.initReleasePlan(title1.Id, localTitle.Id, countryFrance.Id, languageFrench.Id);
        CommercialAvail.End_Date__c=CommercialAvail.End_Date__c + 10;
	    insert CommercialAvail;

        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(acctGoogle.Id, countryFrance.Id, CommercialAvail, title1);
        insert storefrontGoogle1;

		        
        Client_Avail__c clientAvail = TestUtil.initClientAvail(acctGoogle.Id, CommercialAvail, localTitle.Id);
        clientAvail.Start_Date__c=clientAvail.Start_Date__c + 1;
        clientAvail.Status__c='Confirmed';
        insert clientAvail;
        

		//Insert EAD record
		List<Earliest_Avail_Date__c> lstEAD = new List<Earliest_Avail_Date__c>();
		Earliest_Avail_Date__c  eDate=new Earliest_Avail_Date__c(
                                        Title__c=title1.Id,
                                        Country__c=countryFrance.Id,
                                        Channel__c='VODc',
                                        Format__c='HD',
                                        Status__c = 'Unlocked');
        
       
        lstEAD.add(eDate);
        insert lstEAD;
        
        Test.startTest();
        system.debug('eDate****'+eDate.Key__c);
        WB_Batch_UpdateEarliestAvailDtWeeklySync batchInstance= new WB_Batch_UpdateEarliestAvailDtWeeklySync();
        Database.executeBatch(batchInstance);
        Test.stopTest();
        
    }
    
     @isTest static void WB_Batch_UpdateEarliestAvailDtRecs1(){
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
        
        Pricing__c pricing = TestUtil.initPricing(acctGoogle.Id, countryFrance.Id);
        pricing.Price_Code_Status__c = 'Active' ;
        insert pricing;
        
        Language__c languageFrench = TestUtil.initLanguage('TestFrench', '', 1);
        insert languageFrench;
        
        Local_Title__c localTitle = TestUtil.initLocalTitle(languageFrench.Id, countryFrance.Id);
        localTitle.Title__c = title1.Id;
        insert localTitle;
        
        Commercial_Avail__c CommercialAvail = TestUtil.initReleasePlan(title1.Id, localTitle.Id, countryFrance.Id, languageFrench.Id);
        CommercialAvail.End_Date__c=CommercialAvail.End_Date__c + 10;
		CommercialAvail.IsClientAvailChanged__c=TRUE;
        insert CommercialAvail;
        
        Agreement__c storefrontGoogle1 = TestUtil.initStoreFront(acctGoogle.Id, countryFrance.Id, CommercialAvail, title1);
        insert storefrontGoogle1;
        
        List<Client_Avail__c> cainsertion=new List<Client_Avail__c>();
        
        Client_Avail__c clientAvail = TestUtil.initClientAvail(acctGoogle.Id, CommercialAvail, localTitle.Id);
        clientAvail.Status__c='Confirmed';
        //clientAvail.Price_Tier_Text__c = '';
        cainsertion.add(clientAvail);
		
        
        Client_Avail__c clientAvail1 = TestUtil.initClientAvail(acctGoogle.Id, CommercialAvail, localTitle.Id);
        clientAvail1.Start_Date__c=clientAvail1.Start_Date__c + 1;
		clientAvail1.End_Date__c=clientAvail1.End_Date__c - 5;
		clientAvail1.Status__c='Confirmed';
		//clientAvail1.Price_Tier_Text__c = '';
        cainsertion.add(clientAvail1);
		
		Earliest_Avail_Date__c eDate=new Earliest_Avail_Date__c(
                                        Title__c=title1.Id,
                                        Country__c=countryFrance.Id,
                                        Channel__c='VODc',
                                        Format__c='HD',
                                        Status__c = 'Unlocked',
                                        Earliest_Avail_Date__c=date.today());
    
        insert eDate;
        
        
        Test.startTest();
        system.debug('eDate****'+eDate.Key__c);
        System.schedule('ScheduleBatchApexClass', '0 58 * * * ? ', new WB_Batch_UpdateEarliestAvailDtWeeklySync(5));
        Test.stopTest();
        
    }
   
}