/**
   @Author Cognizant
   @name WB_Generate_PBEP_Batch_Test
   @CreateDate 27 July 2020
   @Description This class is used for code coverage of WB_Generate_PBEP_Batch.
   @Version <1.0>
   @reference SNOW Ticket - WBTINC0202832
*/
@isTest
private class WB_Generate_PBEP_Batch_Test{
    @testSetup
    static void setupTestData(){ 
        
        list<Account> crmAcc = CRM_TestDataFactory.createAccounts(1, false);
        crmAcc[0].RecordTypeId = CRM_RecordTypeUtil.RT_ACCOUNT_SOLD_TO;
        crmAcc[0].CurrencyIsoCode = 'USD';
        insert crmAcc;
        
        List<Account> accList = new List<Account>();
        for(Integer i=0;i<2;i++){
            Account objAccount = TestUtil.initAccount();
            objAccount.name = 'Test Account_'+i;
            objAccount.Type='Global';
            accList.add(objAccount);
        }
        insert accList;
        
        list<Country__c> countryList = new list<Country__c>();
        for(Integer i=0;i<2;i++){
            Country__c countryRec =new Country__c(Name ='Test_Country_'+i,Country_Code2__c ='TC_'+i,Country_Code__c='TCC+'+i,Generate_CRM_Product__c=true);
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
        
        WB_PBEP_Product_CreationHandler pbepProdHandler = new WB_PBEP_Product_CreationHandler();        
        pbepProdHandler.assignProductToReleasePlan(rpList);
        pbepProdHandler.updateAssignedProductsFromRP(rpList,null); 
        
        list<Agreement__c> sfList = new List<Agreement__c>();
        for(Account a : accList){
            for(country__c c : countryList){
                 Agreement__c objAgreement = new Agreement__c(Account__c = a.Id
                                                        , country__c = c.Id
                                                        , Status__c = 'Active'
                                                        , Pricing_Currency__c ='FR'
                                                        , Content_Type__c = 'Feature'
                                                        , Channel_Picklist__c = 'EST; VODi'
                                                        , Format__c = 'SD; HD'
                                                        ,SAP_Customer_Number__c='12010421'
                                                        ,CRM_Account__c=crmAcc[0].Id);
                sfList.add(objAgreement);
            }   
        }
        insert sfList;
        
        List<Pricing__c> listPricing = new List<Pricing__c>();
        for(Account a : accList){
            for(Country__c c : countryList){
                for(String ch : channels){
                    for(String f : formats){
                        Pricing__c pr = new Pricing__c();
                        pr.Name = 'PBEP_Gen';
                        pr.Account__c = a.id;
                        pr.Country__c = c.Id;
                        pr.Channel__c= ch;
                        pr.Format__c = f;
                        pr.Content_Type__c = 'Feature';
                        pr.Price_Tier__c = 'PBEP_Gen';
                        pr.Account_Price__c = 10;
                        listPricing.add(pr);
                    }
                }
            }
        }
        insert listPricing;
        
        List<Client_Avail__c> caList = new List<Client_Avail__c>();
        for(Account a : accList){
            for(Commercial_Avail__c rp : rpList){
                Client_Avail__c ca = TestUtil.initClientAvail(a.Id, rp, rp.Local_Title__c);
                ca.Start_Date__c = system.today();
                ca.End_Date__c = system.today()+70;
                ca.Status__c = 'Confirmed';
                ca.Price_Tier_Text__c = 'PBEP_Gen';
                caList.add(ca);
            }
        }
        insert caList;
        
        system.debug('Remaining CPU Time Out : '+(Limits.getLimitCpuTime() - Limits.getCpuTime()));
    }
    
    @IsTest
    static void pbepGenerationTestCase(){
        system.debug('Product : '+[Select Count() From Product2]);
        system.assertEquals(0,[Select Count() From Pricebook_Entry_Period__c]); //No PBEPs created in system.
        
        Test.startTest();
        
        Database.executeBatch(new WB_Generate_PBEP_Batch(system.now().addDays(-1),null));
        
        Test.stopTest();
        
        system.assertEquals([Select Count() From Client_Avail_Price__c],[Select Count() From Pricebook_Entry_Period__c]); // PBEP Generated in system.
    }
}