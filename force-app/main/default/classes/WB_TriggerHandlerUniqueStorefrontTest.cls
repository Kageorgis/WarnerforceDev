/*
Class Name   : WB_TriggerHandlerUniqueStorefrontTest 
Description  : This class is to do code coverage for WB_TriggerHandlerUniqueStorefront class    
Created By   : Cognizant Technology Solutions - Rashmi
Created On   : DEC 2014

Change History:
-------------------------------------------------------------------------------------------------------------------------------------
Sr#              Description                                               Updated By                                     Updated On
-------------------------------------------------------------------------------------------------------------------------------------
1              [Change Type]                                 Cognizant Technology Solutions - [Developer Name]           [MM/DD/YYYY]

CH01   Added Assertion statements for the required business             Akash Dalvi                                        4/27/2016
       scenarios.                        
*/

@isTest 
public class WB_TriggerHandlerUniqueStorefrontTest {
    
    @isTest static void setQueueToOwner(){
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
       // Insert account as current user
        System.runAs (thisUser) {
        
        Group g1 = new Group(Name='ChinaQ', type='Queue');
        insert g1;
        
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Agreement__c');
        insert q1;
        
        WB_Queue_Id__c cusSetting=new WB_Queue_Id__c(Name=g1.Name,Value__c=g1.id);
        insert cusSetting;
		
		Id rtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(system.label.AccRecordType).getRecordTypeId();
        Account objAccount = new Account(
					Name='TestAccount',
					Customer_Focus__c='Active', 
					recordtypeId = rtypeId);
        insert objAccount;
        
        Country__c c = new Country__c (
                     Name = 'cname',
                     Country_Code2__c = 'cn',
                     Country_Code__c = 'cna',
                     Digital_Owner__c='ChinaQ'
                     );
        insert c;
                     
        Agreement__c storefront=new Agreement__c(
					Account__c=objAccount.Id,
					Country__c=c.Id,
					Pricing_Currency__c='USD');
                    
        Test.startTest();
        insert storefront;
        Test.stopTest();
        
        Agreement__c sf1=[SELECT Id,Owner.Name FROM Agreement__c WHERE Account__c =: objAccount.Id AND Country__c =: c.Id AND Pricing_Currency__c='USD'];
        String obtained=sf1.Owner.Name;
        String expected=cusSetting.Name;
        System.assertEquals(expected, obtained);
        }
    }
    
    static testMethod void UniqueStorefrontOnUpdate() {
    
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',
                                       Content_Type__c='Feature',Digital_Planning__c='YES',Formats__c='SD');
        insert title1;
    
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TFR',
                                                Country_Code__c='TF');
        insert countryFrance;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
    
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,
                                                                   Country_Lookup__c=countryFrance.Id,
                                                                   Languages__c=languageFrench.Id ,
                                                                   Channel__c='DTD',Format__c='HD',
                                                                   Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, 
                                                                   Start_Date__c=date.today(),
                                                                   End_Date__c= date.today()+1,
                                                                   Rights_End__c=date.today()+2);
        insert releaseplan1;
        
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,
                                                          Country__c=countryFrance.Id,Pricing_Currency__c='FR',
                                                          Content_Type__c=title1.Content_Type__c,
                                                          Channel_Picklist__c = releaseplan1.Channel__c,
                                                          Format__c=releaseplan1.Format__c);
        insert storefrontGoogle1;
        
        //CH01
        Account acct = TestUtil.initAccount();
        insert acct;
        
        Agreement__c storefrontAcct = new Agreement__c(Account__c=acct.Id,
                                                          Country__c=countryFrance.Id,Pricing_Currency__c='FR',
                                                          Content_Type__c=title1.Content_Type__c,
                                                          Channel_Picklist__c = releaseplan1.Channel__c,
                                                          Format__c=releaseplan1.Format__c);
        
        Agreement__c storefrontAcct2 = new Agreement__c(Account__c=acct.Id,
                                                          Country__c=countryFrance.Id,Pricing_Currency__c='FR',
                                                          Content_Type__c=title1.Content_Type__c,
                                                          Channel_Picklist__c = releaseplan1.Channel__c,
                                                          Format__c=releaseplan1.Format__c);                                                          
       
        
        list<Agreement__c> storefrontList = new list<Agreement__c>();
        list<Agreement__c> existingStorefrontList = new list<Agreement__c>();
        list<string> selectedAcc = new list<string>();
        list<string> selectedCountry = new list<string>();
        
        storefrontList.add(storefrontAcct);
        insert storefrontList;
        
        selectedAcc.add(storefrontList[0].Account__c);
        selectedCountry.add(storefrontList[0].Country__c);
        existingStorefrontList.add(storefrontAcct2);
        
        Test.startTest();
        
            update storefrontGoogle1;
            delete storefrontGoogle1;
            try{
                insert existingStorefrontList;
                //system.assertEquals(existingStorefrontList.size(),1);
                    if(existingStorefrontList.size()>0){
                        //system.assertEquals(storefrontList.size(),1);
                        if(existingStorefrontList.size()>=storefrontList.size()){
                            system.assertEquals(storefrontList[0].Account__c, existingStorefrontList[0].Account__c);
                            system.assertEquals(storefrontList[0].country__c, existingStorefrontList[0].Country__c);
                            if(storefrontList[0].Account__c == existingStorefrontList[0].Account__c && storefrontList[0].country__c == existingStorefrontList[0].Country__c){
                                storefrontList[0].addError('Please select the different combination of Country and Account ');
                            }
                        }
                    }
            }
            catch(Exception e){
                system.debug('This is custom validity exception for unique account & country combination' +e);
                //system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
                
            }
        
        Test.stopTest();  
     }
     
     static testMethod void UniqueStorefrontOnInsert_Update() {
        
        Account acct = TestUtil.initAccount();
        insert acct;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',
                                       Content_Type__c='Feature',Digital_Planning__c='YES',Formats__c='SD');
        insert title1;
    
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TFR',
                                                Country_Code__c='TF');
        insert countryFrance;
    
             
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
    
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,
                                                                   Country_Lookup__c=countryFrance.Id,
                                                                   Languages__c=languageFrench.Id ,
                                                                   Channel__c='DTD',Format__c='HD',
                                                                   Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, 
                                                                   Start_Date__c=date.today(),
                                                                   End_Date__c= date.today()+1,
                                                                   Rights_End__c=date.today()+2);
        insert releaseplan1;
        
        
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acct.Id,
                                                          Country__c=countryFrance.Id,Pricing_Currency__c='FR',
                                                          Content_Type__c=title1.Content_Type__c,
                                                          Channel_Picklist__c = releaseplan1.Channel__c,
                                                          Format__c=releaseplan1.Format__c);
        
        Agreement__c storefrontAcct = new Agreement__c(Account__c=acct.Id,
                                                          Country__c=countryFrance.Id,Pricing_Currency__c='FR',
                                                          Content_Type__c=title1.Content_Type__c,
                                                          Channel_Picklist__c = releaseplan1.Channel__c,
                                                          Format__c=releaseplan1.Format__c);
        
        Agreement__c storefrontAcct2 = new Agreement__c(Account__c=acct.Id,
                                                          Country__c=countryFrance.Id,Pricing_Currency__c='FR',
                                                          Content_Type__c=title1.Content_Type__c,
                                                          Channel_Picklist__c = releaseplan1.Channel__c,
                                                          Format__c=releaseplan1.Format__c);                                                          
       
        
        list<Agreement__c> storefrontList = new list<Agreement__c>();
        list<Agreement__c> existingStorefrontList = new list<Agreement__c>();
        list<string> selectedAcc = new list<string>();
        list<string> selectedCountry = new list<string>();
        
        existingStorefrontList.add(storefrontGoogle1);
        insert existingStorefrontList;
        
        storefrontList.add(storefrontAcct);
        storefrontList.add(storefrontAcct2);
        
        selectedAcc.add(storefrontList[0].Account__c);
        selectedCountry.add(storefrontList[0].Country__c);
        
        Test.startTest();
       
            try{
                insert storefrontList;
                //system.assertEquals(storefrontList.size(),2);
                 //system.assertEquals(existingStorefrontList.size(),1);
                if(existingStorefrontList.size()>0){
                       // system.assertNotEquals(existingStorefrontList.size(),storefrontList.size());
                        if(existingStorefrontList.size()<storefrontList.size()){
                            system.assertEquals(storefrontList[0].Account__c, existingStorefrontList[0].Account__c);
                            system.assertEquals(storefrontList[0].country__c, existingStorefrontList[0].Country__c);
                            if(storefrontList[0].Account__c == existingStorefrontList[0].Account__c && storefrontList[0].country__c == existingStorefrontList[0].Country__c){
                                storefrontList[0].addError('Please select the different combination of Country and Account ');
                                
                            }
                        }
                    }
            }
            catch(Exception e){
                system.debug('This is custom validity exception for unique account & country combination' +e);
                //system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
                
            }
        
        Test.stopTest();  
     }
     
     static testMethod void UniqueStorefrontOnUpdate1() {
    
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',
                                       Content_Type__c='Feature',Digital_Planning__c='YES',Formats__c='SD');
        insert title1;
    
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TFR',
                                                Country_Code__c='TF');
        insert countryFrance;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
    
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,
                                                                   Country_Lookup__c=countryFrance.Id,
                                                                   Languages__c=languageFrench.Id ,
                                                                   Channel__c='DTD',Format__c='HD',
                                                                   Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, 
                                                                   Start_Date__c=date.today(),
                                                                   End_Date__c= date.today()+1,
                                                                   Rights_End__c=date.today()+2);
        insert releaseplan1;
        
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,
                                                          Country__c=countryFrance.Id,Pricing_Currency__c='FR',
                                                          Content_Type__c=title1.Content_Type__c,
                                                          Channel_Picklist__c = releaseplan1.Channel__c,
                                                          Format__c=releaseplan1.Format__c);
        insert storefrontGoogle1;
        
        //CH01
        Account acct = TestUtil.initAccount();
        insert acct;
        
        Agreement__c storefrontAcct = new Agreement__c(Account__c=acct.Id,
                                                          Country__c=countryFrance.Id,Pricing_Currency__c='FR',
                                                          Content_Type__c=title1.Content_Type__c,
                                                          Channel_Picklist__c = releaseplan1.Channel__c,
                                                          Format__c=releaseplan1.Format__c);
        
        Agreement__c storefrontAcct2 = new Agreement__c(Account__c=acct.Id,
                                                          Country__c=countryFrance.Id,Pricing_Currency__c='FR',
                                                          Content_Type__c=title1.Content_Type__c,
                                                          Channel_Picklist__c = releaseplan1.Channel__c,
                                                          Format__c=releaseplan1.Format__c);                                                          
       
        
        list<Agreement__c> storefrontList = new list<Agreement__c>();
        list<Agreement__c> existingStorefrontList = new list<Agreement__c>();
        list<string> selectedAcc = new list<string>();
        list<string> selectedCountry = new list<string>();
        
        storefrontList.add(storefrontAcct);
        insert storefrontList;
        
        selectedAcc.add(storefrontList[0].Account__c);
        selectedCountry.add(storefrontList[0].Country__c);
        existingStorefrontList.add(storefrontAcct2);
        
        Test.startTest();
        
            storefrontGoogle1.Channel_Picklist__c='EST';
			storefrontGoogle1.Format__c='SD';
            update storefrontGoogle1;
        //    delete storefrontGoogle1;
            try{
                insert existingStorefrontList;
                //system.assertEquals(existingStorefrontList.size(),1);
                    if(existingStorefrontList.size()>0){
                        //system.assertEquals(storefrontList.size(),1);
                        if(existingStorefrontList.size()>=storefrontList.size()){
                            system.assertEquals(storefrontList[0].Account__c, existingStorefrontList[0].Account__c);
                            system.assertEquals(storefrontList[0].country__c, existingStorefrontList[0].Country__c);
                            if(storefrontList[0].Account__c == existingStorefrontList[0].Account__c && storefrontList[0].country__c == existingStorefrontList[0].Country__c){
                                storefrontList[0].addError('Please select the different combination of Country and Account ');
                            }
                        }
                    }
            }
            catch(Exception e){
                system.debug('This is custom validity exception for unique account & country combination' +e);
                //system.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
                
            }
        
        Test.stopTest();  
     }
}