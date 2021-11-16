@isTest
PRIVATE class WB_Populate_ReleaseDate_V2_TEST {
	private static testMethod void testOnLocalDataPositiveScenario1() {
        
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
        
        MPM_Release_Date__c mpmReleaseDate1 = new MPM_Release_Date__c(Country__c =countryList[0].Id,
                                                                      Theatrical_Release_Date__c=date.today()-2,  
                                                                      MPM__c=mpm.Id
                                                                       );
        MPM_Release_Date__c mpmReleaseDate2= new MPM_Release_Date__c(Country__c =countryList[1].Id,
                                                                      Theatrical_Release_Date__c=date.today()-5,  
                                                                      MPM__c=mpm.Id
                                                                       );
        mpmReleaseDateList.ADD(mpmReleaseDate1);
        mpmReleaseDateList.ADD(mpmReleaseDate2);
        INsert mpmReleaseDateList;

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
        WB_Populate_ReleaseDate_V2 instancevar = new WB_Populate_ReleaseDate_V2(system.now().addhours(-1),system.now());          
            //String sch = '0  00 1 3 * ?';
            //system.schedule('Test', sch, instancevar);
            database.executeBatch(instancevar,200);
         Test.stopTest();
         
        List<Local_Title__c> LocalTitleRecs = [select id, Local_Theatrical_Release_Date__c, Country__c, TITLE__R.MPM__C from Local_Title__c];
        List<MPM_Release_Date__c> mpmReleaseDateList1=[SELECT ID, Country__c,Theatrical_Release_Date__c, MPM__C FROM MPM_Release_Date__c];
        for(Local_Title__c LT :LocalTitleRecs) {
            FOR (MPM_Release_Date__c MPMRD: mpmReleaseDateList1){
                IF(mpmrd.MPM__C==lt.TITLE__r.MPM__c && MPMRD.Country__c == lt.Country__c){
                    system.assertEquals(MPMRD.Theatrical_Release_Date__c, LT.Local_Theatrical_Release_Date__c);
                }
                
            }
        }

    }
    
    private static testMethod void testOnLocalDataPositiveScenario2() {
        
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
        
        MPM_Release_Date__c mpmReleaseDate1 = new MPM_Release_Date__c(Country__c =countryList[0].Id,
                                                                      Theatrical_Release_Date__c=date.today()-2,  
                                                                      MPM__c=mpm.Id
                                                                       );
        MPM_Release_Date__c mpmReleaseDate2= new MPM_Release_Date__c(Country__c =countryList[1].Id,
                                                                      Theatrical_Release_Date__c=date.today()-5,  
                                                                      MPM__c=mpm.Id
                                                                       );
        mpmReleaseDateList.ADD(mpmReleaseDate1);
        mpmReleaseDateList.ADD(mpmReleaseDate2);
        INsert mpmReleaseDateList;

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
        WB_Populate_ReleaseDate_V2 instancevar = new WB_Populate_ReleaseDate_V2(system.now().addhours(-1),system.now());          
            String sch = '0  00 1 3 * ?';
            system.schedule('Test', sch, instancevar);
         Test.stopTest();
         
    }
    
    private static testMethod void testOnLocalDataPositiveScenario3() {
        
        WB_Populate_TRD_On_LT__c cs2 = new WB_Populate_TRD_On_LT__c(name='WB_Client_Avail_Limit_On_LT',Batch_Size__c=5);
        insert cs2;
        
        List<Account> accList = new List<Account>();
        for(Integer i=0;i<2;i++){
            Account objAccount = TestUtil.initAccount();
            objAccount.name = 'Test Account_'+i;
            objAccount.Type='Global';
            accList.add(objAccount);
        }
        insert accList;
        
        list<Country__c> countryList = new list<Country__c>();
        for(Integer i=0;i<5;i++){
            Country__c countryRec =new Country__c(Name ='Test_Country_'+i,Country_Code2__c ='TC_'+i,Country_Code__c='TCC+'+i);
            countryList.add(countryRec);
        }
        insert countryList;
        
        //Create Language records
        List<Language__c> languageList = new List<Language__c>();
        
        Language__c languageEnglish = new Language__c(Name='English',Language_Order__c = 1,Language_Code_2__c='en',Language_Code_3__c='ENG');
        languageList.add(languageEnglish);
        
        Language__c languageGerman = new Language__c(Name='German',Language_Order__c = 1,Language_Code_2__c='de',Language_Code_3__c='GER');
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
        for(Integer i=0;i<5;i++){
            MPM_Release_Date__c mpmRD = new MPM_Release_Date__c(Country__c =countryList[i].Id,
                                                                      Theatrical_Release_Date__c=date.today()-2,  
                                                                      MPM__c=mpm.Id
                                                                       );
            mpmReleaseDateList.add(mpmRD);
        }   
        insert mpmReleaseDateList;
        
        list<Local_Title__c> localTitleList = new list<Local_Title__c>();
        for(Title__c tl : titleList){
            for(Country__c c : countryList){
                for(Language__c l : languageList){
                    Local_Title__c lt = new Local_Title__c(
                            Name='Test LT_'+tl.Video_Version__c+'_'+c.Country_Code__c+'_'+l.Language_Code_3__c,
                            Title__c = tl.Id, 
                            Country__c = c.Id,
                            Language__c = l.Id,
                            Local_Box_Office__c=1245.00);
                    localTitleList.add(lt);
                }
            }
        }
        insert localTitleList;
        
        List<String> channels = new List<String>{'EST','VODi'};
        List<String> formats = new List<String>{'HD','SD'};
        List<Commercial_Avail__c> rpList = new List<Commercial_Avail__c>();
        for(Local_Title__c lt : localTitleList){
            for(String c : channels){
                for(String f : formats){
                    Commercial_Avail__c rp = new Commercial_Avail__c();
                    rp.Channel__c = c;
                    rp.Title__c=lt.Title__c;
                    rp.Languages__c = lt.Language__c;
                    rp.Country_Lookup__c = lt.Country__c;
                    rp.Format__c = f;
                    rp.Language_Type__c = 'Sub & Audio';
                    rp.Exclusive_Date__c = system.today()-200;
                    rp.Start_Date__c = system.today()-70;
                    rp.End_Date__c = system.today()+70;
                    rp.Rights_End__c=system.today()+200;
                    rp.Status__c = 'Confirmed';
                    rp.Local_Title__c = lt.Id;
                    rpList.add(rp);
                }
            }
        }
        insert rpList;
        
        Test.startTest();
        
        list<Agreement__c> sfList = new List<Agreement__c>();
        for(Account a : accList){
            for(country__c c : countryList){
                 Agreement__c objAgreement = new Agreement__c(Account__c = a.Id
                                                        , country__c = c.Id
                                                        , Status__c = 'Active'
                                                        , Pricing_Currency__c ='FR'
                                                        , Content_Type__c = 'Feature'
                                                        , Channel_Picklist__c = 'EST; VODi'
                                                        , Format__c = 'SD; HD',SAP_Customer_Number__c='12010421');
                sfList.add(objAgreement);
            }   
        }
        insert sfList;
        
        List<Client_Avail__c> caList = new List<Client_Avail__c>();
        for(Account a : accList){
            for(Commercial_Avail__c rp : rpList){
                if(rp.Title__c == titleList[0].id){
                    Client_Avail__c ca = TestUtil.initClientAvail(a.Id, rp, rp.Local_Title__c);
                    ca.Start_Date__c = system.today();
                    ca.End_Date__c = system.today()+70;
                    ca.Status__c = 'Draft';
                    ca.Price_Tier_Text__c = 'test2';
                    caList.add(ca);
                }else if(rp.Channel__c == 'EST'){
                    Client_Avail__c ca = TestUtil.initClientAvail(a.Id, rp, rp.Local_Title__c);
                    ca.Start_Date__c = system.today();
                    ca.End_Date__c = system.today()+70;
                    ca.Status__c = 'Draft';
                    ca.Price_Tier_Text__c = 'test2';
                    caList.add(ca);
                }
            }
        }
        insert caList;
        
        WB_Populate_ReleaseDate_V2 rd = new WB_Populate_ReleaseDate_V2();
        rd = new WB_Populate_ReleaseDate_V2(new set<Id>());
        WB_Populate_ReleaseDate_V2 rd2 = new WB_Populate_ReleaseDate_V2(null,null);
        database.executebatch(rd2,200);
        
        Test.stopTest();
        
        Set<Id> ltIdsNotProcessed = new Set<Id>();
        Set<Id> ltIdsProcessed = new Set<Id>();
        for(AggregateResult a : [SELECT Count(id),Local_Title__c FROM Client_Avail__c Where Local_Title__c IN :localTitleList Group By Local_Title__c]){
            if((Integer)a.get('expr0') > cs2.Batch_Size__c){
                ltIdsNotProcessed.add((Id)a.get('Local_Title__c'));
            }else{
                ltIdsProcessed.add((Id)a.get('Local_Title__c'));
            }
        }
        
        for(Local_Title__c lt : [SELECT ID,Local_Theatrical_Release_Date__c from Local_Title__c Where Id IN :ltIdsNotProcessed]){
            system.assertEquals(null,lt.Local_Theatrical_Release_Date__c);
        }
        
        for(Local_Title__c lt : [SELECT ID,Local_Theatrical_Release_Date__c from Local_Title__c Where Id IN :ltIdsProcessed]){
            system.assertEquals((date.today()-2),lt.Local_Theatrical_Release_Date__c);
        }
    }
}