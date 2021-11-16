/******* 
WB_StorefrontAssociateClientAvailTest
Creation Date- 6 Nov 2014
Last Modified Date - 
Last Modified by  -
Description- This class is to do code coverage WB_StorefrontAssociateClientAvail
Author- Imran Hussain
*******/

@isTest
private class WB_StorefrontAssociateClientAvailTest{

     static testMethod void StorefrontAssociateClientAvailChk() {
    	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        Title__c title1 = new Title__c(Name = 'TestGoogle1',MPM__c = mpm.id,Video_Version__c ='6000047245111',
                                       Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
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
                                                                   Language_Type__c='Dub',Status__c='Draft',
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
                                                          Format__c=releaseplan1.Format__c,
                                                          Status__c = 'Active',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
    
    
        Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,                                                      
                                                      Client__c=acctGoogle.Id,                                                      
                                                      Status__c='Draft',Start_Date__c=releaseplan1.Start_Date__c,
                                                      End_Date__c=releaseplan1.End_Date__c );
     
    
          
    	
    
        insert clientAvail1;
        Test.startTest();
        update clientAvail1; 
        delete clientAvail1;
        delete releaseplan1;                                                     
        Test.stopTest();                                                    
     }
    
    
     // ER:7 - Added testmethod to cover new logic of ER-7
     static testMethod void StorefrontAssociateClientAvailChk2() {
    	Test.startTest();
    	MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123',MPM_Short_Desc__c = 'MPM record');
        insert mpm;
        
        Account acctGoogle = TestUtil.initAccount();
        acctGoogle.EC_Digital_Account__c='Digital';
        insert acctGoogle;
        
        EC_Tracker__c tracker = new EC_Tracker__c(Name='tracker test name',MPM__c=mpm.Id);
        insert tracker;
        //create or update EC Piece
        EC_Piece__c ec1 = new EC_Piece__c(EC_Name__c='ec test piece1',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm.Id,Min__c=56,Sec__c=45);
        insert ec1;
        EC_Piece__c ec2 = new EC_Piece__c(EC_Name__c='ec test piece2',EC_Menu_Icon__c='Deleted Scenes',EC_Tracker__c=tracker.Id,MPM__c=mpm.Id,Min__c=56,Sec__c=45);
        insert ec2;
        
        
        Title__c title1 = new Title__c(Name = 'TestGoogle1',MPM__c = mpm.id,Video_Version__c ='6000047245111',
                                       Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
        EC_Title_Allocation__c titleAllocation = new EC_Title_Allocation__c(EC_Piece__c=ec1.id,Title__c=title1.id,MPM__c=mpm.id);
        insert titleAllocation;
        //Create a record on ECTitelAllocaiton Object to add ecs to titles
        EC_Account_Allocation__c eca1 = new EC_Account_Allocation__c(Title__c=title1.Id,EC_Piece__c=ec2.Id,MPM__c=mpm.Id,Account__c=acctGoogle.Id,Format__c='HD');
        insert eca1;
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TFR',
                                                Country_Code__c='TF');
        insert countryFrance;
    
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
    
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,
                                                                   Country_Lookup__c=countryFrance.Id,
                                                                   Languages__c=languageFrench.Id ,
                                                                   Channel__c='EST',Format__c='HD',
                                                                   Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, 
                                                                   Start_Date__c=date.today(),
                                                                   End_Date__c= date.today()+1,
                                                                   Rights_End__c=date.today()+2);
        insert releaseplan1;
        
    
        Agreement__c storefrontGoogle1 = new Agreement__c(Account__c=acctGoogle.Id,
                                                          Country__c=countryFrance.Id,Pricing_Currency__c='FR',
                                                          Content_Type__c=title1.Content_Type__c,
                                                          Channel_Picklist__c = releaseplan1.Channel__c,
                                                          Format__c=releaseplan1.Format__c,
                                                          Status__c = 'Active',Formats_with_EC__c='HD',SAP_Customer_Number__c='12010421');
        insert storefrontGoogle1;
    
    
        Client_Avail__c clientAvail1 = new Client_Avail__c(Commercial_Avail__c=releaseplan1.Id,                                                      
                                                      Client__c=acctGoogle.Id,                                                      
                                                      Status__c='Draft',Start_Date__c=releaseplan1.Start_Date__c,
                                                      End_Date__c=releaseplan1.End_Date__c );
     
    
          
        
        insert clientAvail1;
        update clientAvail1; 
        Test.stopTest();                                                    
     }

}