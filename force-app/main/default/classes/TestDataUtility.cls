@isTest
public class TestDataUtility {
    
    public List<Account> createAccountList(){
        //Create AccountList 
        List<Account> acctList = new List<Account>{
            new Account(Name='ApexTestAccount1'),
            new Account(Name='ApexTestAccount2'),
            new Account(Name='ApexTestAccount3')
        };
        insert acctList;
        return acctList;
        
    }
    
    public static Account createAccount(String accName, Boolean isInsert){
        Account objAccount = new Account(Name=accName);
        
        if(isInsert)
            insert objAccount;
        return objAccount;
    }
    
    public  List<Contact> createContact(Account a){
        List<Contact> contactList = new List<Contact>();
        Contact  objContact1 = new Contact(
            FirstName='Test1',
            LastName = 'Name1',
            Email = 'Test1@test.com',
            AccountId = a.Id
        );
        
        Contact  objContact2 = new Contact(
            FirstName='Test2',
            LastName = 'Name2',
            Email = 'Test2@test.com',
            AccountId = a.Id
        );
        contactList.add(objContact1);
        contactList.add(objContact2);
        insert contactList;
        return contactList;
    }
    
    public MPM__c createMPM(){
        MPM__c mpm = new MPM__c(
            Name = 'Test MPM',
            MPM_Number__c = '11223'
        );
        insert mpm;
        return mpm;
    }
    
    public Rights__c createRights(Language__c l,Country__c c,MPM__c m){
            Rights__c objRt = new Rights__c(
            Channel__c = 'DTD',
            MPM__c = m.Id,
            Rights_Group__c = createRightsGroup(c.Id, l.Id).Id,
            Rights_Start__c = Date.today().addDays(1),
            Rights_End__c = Date.today().addDays(7),
            Status__c = 'Confirmed'
        );
        insert objRt;
        return objRt;
    }
    
    public  Rights_Group__c createRightsGroup(Id countryId, Id languageId){
        Rights_Group__c objRG = new Rights_Group__c(
            Name = 'Test Rights Group',
            Locale_Key__c = 'myKey',
            Rights_Group__c = 'France',
            Country__c = countryId,
            Language__c = languageId
        );
        insert objRG;
        return objRG;
    }
    
    public Country__c createCountry(){
        Country__c newCountry = new Country__c(
            Name ='France',
            Country_Code2__c ='AA',
            Country_Code__c='TC'
        );
        insert newCountry;
        return newCountry;
    }
    
    
    public  Language__c createLanguage(){
        Language__c language = new Language__c(Name='English',Language_Order__c = 1,Language_Code_2__c='en');
        insert language;
        return language;
    }
    
    public  Local_Title__c createlocalTitle(Country__c c,Language__c l){
        
        Local_Title__c localTitle = new Local_Title__c(
            Num_Local_Episodes__c = 10,
            Country__c = c.Id,
            Language__c = l.Id,
            Category__c='Catalog'
             
        );
        insert localTitle;
        return localTitle;
    }
    
    
    public  Title__c createTitle(MPM__c m){
        Title__c title1 = new Title__c(
            Name = 'TestGoogle1',
            Video_Version__c ='1243355672',
            Content_Type__c='Feature',
            Digital_Planning__c='Yes',
            Clear_to_Avail__c = true,
            MPM__c = m.Id,
            Formats__c = 'SD'
        );
        insert title1;
        return title1;
    }
        
    public Playlist__c createPlaylist(Title__c t,Country__c c){
       Playlist__c playlist1 = new Playlist__c(
       Country__c = c.id,
       Parent_Title__c = t.id,
       Playlist_Status__c = 'Active'
       );
       insert playlist1;
       return playlist1;
    }
    
    public Playlist_Content__c createPlaylistContent(Title__c t, Playlist__c p){
        Playlist_Content__c playlistCont = new Playlist_Content__c(
            Content_Title__c = t.id,
            Playlist__c = p.id
            );
            insert playlistCont;
            return playlistCont;
    }
    
    public Country_Groups__c createCountryGroup(Country__c c,Account a){
            
        Country_Groups__c countryGroup = new Country_Groups__c(
            Account__c = a.Id,
            Country__c = c.Id,
            NameUnique__c = 'France1'
        );
        insert countryGroup;
        return countryGroup;
     }
     
    public Commercial_Avail__c createReleasePlan(Title__c t,Country__c c,Local_Title__c lt,Language__c l){   
         Commercial_Avail__c  releasePlan = new Commercial_Avail__c(
             Title__c= t.Id,
             Country_Lookup__c = c.Id,
             Local_Title__c = lt.Id,
             Languages__c = l.Id ,
             Channel__c='DTD',
             Format__c='HD',
             Language_Type__c='Sub',
             Status__c='Tentative',
             Exclusive_Date__c = date.today()-1,
             Start_Date__c = date.today()-1,
             End_Date__c = date.today()+1,
             Rights_End__c = date.today()+2
        );
        insert releasePlan;
        return releasePlan;
     }
     
     public Commercial_Avail__c createReleasePlan_EST(Title__c t,Country__c c,Local_Title__c lt,Language__c l){   
         Commercial_Avail__c  releasePlan = new Commercial_Avail__c(
             Title__c= t.Id,
             Country_Lookup__c = c.Id,
             Local_Title__c = lt.Id,
             Languages__c = l.Id ,
             Channel__c='EST',
             Format__c='HD',
             Language_Type__c='Sub',
             Status__c='Tentative',
             Exclusive_Date__c = date.today()-1,
             Start_Date__c = date.today()-1,
             End_Date__c = date.today()+1,
             Rights_End__c = date.today()+2
        );
        insert releasePlan;
        return releasePlan;
     }
     
    public  List<Agreement__c> createStorefrontList(Country__c c, Commercial_Avail__c rp, Title__c t, Account a){
        //Create AccountList
        List<Agreement__c> storefrontList = new List<Agreement__c>();
        Agreement__c objAgreement1 = new Agreement__c(
            Account__c = a.Id,
            Country__c = c.Id,
            Pricing_Currency__c = 'FR',
            Content_Type__c = t.Content_Type__c,
            Channel_Picklist__c = rp.Channel__c,
            Format__c = rp.Format__c,
            Status__c = 'Active',
            SAP_Customer_Number__c='12010421'
        );
        
        Agreement__c objAgreement2 = new Agreement__c(
            Account__c = a.Id,
            Country__c = c.Id,
            Pricing_Currency__c = 'FR',
            Content_Type__c = t.Content_Type__c,
            Channel_Picklist__c = rp.Channel__c,
            Format__c = rp.Format__c,
            Status__c = 'Active',
            SAP_Customer_Number__c='12010421'
        );
        
        storefrontList.add(objAgreement1);
        storefrontList.add(objAgreement2);
        insert storefrontList;
        return storefrontList;
     }
     
     public  Agreement__c createStorefront(Country__c c,Commercial_Avail__c rp,Title__c t,Account a){
        Agreement__c objAgreement1 = new Agreement__c(
            Account__c = a.Id,
            Country__c = c.Id,
            Pricing_Currency__c = 'FR',
            Content_Type__c = t.Content_Type__c,
            Channel_Picklist__c = rp.Channel__c,
            Format__c = rp.Format__c,
            Status__c = 'Active',
            SAP_Customer_Number__c='12010421'
        );
        insert objAgreement1;
        return objAgreement1;
     }
     
    public  List<Client_Avail__c> createClientAvailList
                (Commercial_Avail__c objCommAvail,Agreement__c objStorefront,
                Account a){
         
        List<Client_Avail__c> clientAvailList = new List<Client_Avail__c>();
        Client_Avail__c objCA1 = new Client_Avail__c(Commercial_Avail__c = objCommAvail.Id,
            Client__c = a.Id,
            Status__c = 'Tentative',
            Start_Date__c = objCommAvail.Start_Date__c,
            End_Date__c = objCommAvail.End_Date__c,
            Storefront__c = objStorefront.Id
        );
        Client_Avail__c objCA2 = new Client_Avail__c(Commercial_Avail__c = objCommAvail.Id,
            Client__c = a.Id,
            Status__c = 'Confirmed',
            Start_Date__c = objCommAvail.Start_Date__c,
            End_Date__c = objCommAvail.End_Date__c,
            Storefront__c = objStorefront.Id
        );
        Client_Avail__c objCA3 = new Client_Avail__c(Commercial_Avail__c = objCommAvail.Id,
            Client__c = a.Id,
            Status__c = 'Cancelled',
            Start_Date__c = objCommAvail.Start_Date__c,
            End_Date__c = objCommAvail.End_Date__c,
            Storefront__c = objStorefront.Id
        );
        clientAvailList.add(objCA1);
        clientAvailList.add(objCA2);  
        clientAvailList.add(objCA3);        
        insert clientAvailList;
        return clientAvailList;
     }
     
    public  Client_Avail__c createClientAvail(Commercial_Avail__c rp,Agreement__c sf,Account a){
        Client_Avail__c objCA1 = new Client_Avail__c(
            Commercial_Avail__c = rp.Id,
            Client__c = a.Id,
            Status__c = 'Tentative',
            Start_Date__c = rp.Start_Date__c,
            End_Date__c = rp.End_Date__c,
            Storefront__c = sf.Id
        );
        system.debug('rp =====> ' + rp);
        insert objCA1;
        return objCA1;
     }
     
     public  Announcement_Rule__c createAnnouncementType(Account a){
        Announcement_Rule__c objAnnType = new Announcement_Rule__c(
            Account__c = a.Id,
            Announcement_Type__c = 'test11'+a.name,
            Channels__c = 'DTD',
            Content_Type__c = 'Feature',
            Disposition__c = 'Active',
            Announcement_From_Email__c = 'test@test.com',
            Announcement_From_Name__c = 'Test',
            Statuses__c = 'Confirmed',
            Selection_Criteria__c = 'Delta',
            File_Format__c = 'CSV'
        );
        insert objAnnType;
        return objAnnType;
     }
     
     //Report SOQL requires SeeAllData as TRUE hence we are not inserting Announcement record and returning instance og it
     public  Announcement__c createAnnouncement(Account a,Announcement_Rule__c ar){ 
        Announcement__c objAnnType = new Announcement__c(
            Announcement_Type__c = ar.Id,
            Account__c = a.Id,
            Report_Id__c = '',
            Report_Name__c = 'WB_Standard_Combined',
            Email_Template__c = 'Announcement USA Standard',
            Name__c = 'Test Announcement',
            Run_Date__c = Date.today(),
            From_Date__c = Date.today(),
            Status__c = 'Confirmed,Tentative,Cancelled',
            Sent_Date__c = Date.today(),
            Job_Run_Status__c = 'Completed',
            Selection_Criteria__c = 'Delta',
            Channels__c = 'DTD',
            Content_Type__c = 'Feature',
            File_Format__c = 'CSV',
            Internal__c = true,
            Announced_User__c=UserInfo.getUserId()
           
        );
        insert objAnnType;
        return objAnnType;
     }
     
    public  List<Announcement_Record__c> createAnnouncementRecord
                    (List<Announcement__c> announcemntIdList, Account a,
                                List<Client_Avail__c> clientAvailIdList){
        List<Announcement_Record__c> objAnnRecordList = 
                                        new List<Announcement_Record__c>();
        for(Announcement__c announcemntId : announcemntIdList){
            for(Client_Avail__c clientAvailId:clientAvailIdList ){
                Announcement_Record__c objAnnRecord = new Announcement_Record__c(
                Client_Avail__c = clientAvailId.Id,
                Announcement__c = announcemntId.Id,
                Change_Status__c = 'New',
                Account__c = a.Id
                );
                objAnnRecordList.add(objAnnRecord);
            }
        }
        insert objAnnRecordList;
        return objAnnRecordList;
    }
    
    public  List<Announcement_Receipient__c> createAnnouncementReceipient
                                (Announcement_Rule__c id,List<Contact> cList,String toccbcc){
        List<Announcement_Receipient__c> objAnnRecpList = 
                                        new List<Announcement_Receipient__c>();
        for (Contact c : cList){
            Announcement_Receipient__c objAnnRecp = new Announcement_Receipient__c(
            Contact__c = c.id,
            Announcement_Type__c = id.Id,
            TO_CC_BCC__c = 'TO'
            );
            objAnnRecpList.add(objAnnRecp);
        }
        insert objAnnRecpList;
        return objAnnRecpList;
    }
    
    
    
}