@isTest
public class WB_Batch_Update_LocalTitle_Owner_Test {

    public static List<Title__c> title_List = new List<Title__c>();
    public static List<Country__c> country_List = new List<Country__c>();
    public static List<Pricing__c> price_List = new List<Pricing__c>();
    public static List<Local_Title__c> listlocaltitles;
    static List<Pricing__c> lPricing = new List<Pricing__c>();
    public static List<Client_Avail__c> listClientavails;
    static List<Client_Avail_Price__c> clAvailPriceList = new List<Client_Avail_Price__c>();
    
 
    @isTest
    static void TestAllBatchFlow() {
        
       // Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
       
        
        Country__c countryFrance =new Country__c(Name ='New Zealand',Country_Code2__c ='TR',Country_Code__c='TF',Turner_Override__c='BrazilQ',HBO_Override__c='EMEALicesnseeQ');
        insert countryFrance;
        
        Country__c countryJapan =new Country__c(Name ='Australia',Country_Code2__c ='TA',Country_Code__c='TJ',Turner_Override__c='BrazilQ',HBO_Override__c='EMEALicesnseeQ');
        insert countryJapan;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title1.Content_Type__c,
                                           Country__c = countryFrance.Id,Channel__c ='DTD',Format__c ='HD'
                                          );
        insert price1;
        
        List<Local_Title__c> listLT= new List<Local_Title__c>();
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title1.Id,Country__c = countryFrance.Id,
                                                   Language__c =languageFrench.Id,Price_Code__c =price1.Name,DisplayStudioOverride__c='HBO');
        
        listLT.add(local1);
        insert listLT ;
        
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                   
                                                                  );
        insert releaseplan1;
                               
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=countryFrance.Id, Pricing_Currency__c='FR', Content_Type__c=title1.Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',Turner_SAP_Customer__c='112345',
            HBO_SAP_Customer__c='456789',SAP_Customer_Number__c='456789'
        );
        insert storefrontGoogle1; 
        
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Draft',
            Client_Start_Ovver__c = date.today()+3,End_Date__c=releaseplan1.End_Date__c
            
        );
        
        insert clientAvail1;
          
         title1.DisplayStudio__c='Adult Swim';
        try{
        update title1;
        }
        catch(Exception e){
            System.debug('MESSAGE'+e.getMessage());
        }
        
        Batch_Ids_Customsetting__c batchIdCustomSetting = new Batch_Ids_Customsetting__c(
            Name = userInfo.getUserId(),
            CA_Batch_Id__c = '12',
            CA_Created_Date__c = system.today().addDays(-1),
            CA_User_Detail__c = userInfo.getUserId(),
            RP_Batch_Id__c = '15',
            RP_Created_Date__c = system.today()
        );
        insert batchIdCustomSetting;
        Map<Id,String> ltpErrorMap = new Map<Id,String>();
        Local_Title__c lt= [select id from Local_Title__c where id IN:listLT];
        ltpErrorMap.put(lt.id,'Too many Errors');
        Test.startTest();
         WB_Batch_Update_LocalTitle_Owner controller = new WB_Batch_Update_LocalTitle_Owner(); 
        String sch = '0  00 1 3 * ?';
       	system.schedule('Test', sch, controller);
        controller.createErrorLog(ltpErrorMap.keySet(),ltpErrorMap);
        Test.stopTest();              
        
    }   
    @isTest
    static void TestRPcreateErrorLog() {
        
        //Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
       
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF',Turner_Override__c='BrazilQ',HBO_Override__c='EMEALicesnseeQ');
        insert countryFrance;
        
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ',Turner_Override__c='BrazilQ',HBO_Override__c='EMEALicesnseeQ');
        insert countryJapan;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title1.Content_Type__c,
                                           Country__c = countryFrance.Id,Channel__c ='DTD',Format__c ='HD'
                                          );
        insert price1;
        
        List<Local_Title__c> listLT= new List<Local_Title__c>();
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title1.Id,Country__c = countryFrance.Id,
                                                   Language__c =languageFrench.Id,Price_Code__c =price1.Name,DisplayStudioOverride__c='HBO');
        
        listLT.add(local1);
        insert listLT ;
        
        List<Commercial_Avail__c> listRP= new List<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                               );
         listRP.add(releaseplan1);   
        insert listRP;
                               
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=countryFrance.Id, Pricing_Currency__c='FR', Content_Type__c=title1.Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',Turner_SAP_Customer__c='112345',
            HBO_SAP_Customer__c='456789',SAP_Customer_Number__c='456789'
        );
        insert storefrontGoogle1; 
        
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Draft',
            Client_Start_Ovver__c = date.today()+3,End_Date__c=releaseplan1.End_Date__c
            
        );

        insert clientAvail1;
 
         title1.DisplayStudio__c='Adult Swim';
        try{
        update title1;
        }
        catch(Exception e){
            System.debug('MESSAGE'+e.getMessage());
        }
        
        Batch_Ids_Customsetting__c batchIdCustomSetting = new Batch_Ids_Customsetting__c(
            Name = userInfo.getUserId(),
            CA_Batch_Id__c = '12',
            CA_Created_Date__c = system.today().addDays(-1),
            CA_User_Detail__c = userInfo.getUserId(),
            RP_Batch_Id__c = '15',
            RP_Created_Date__c = system.today()
        );
        insert batchIdCustomSetting;
         Map<Id,String> capErrorMap = new Map<Id,String>();
        Commercial_Avail__c ca= [select id from Commercial_Avail__c where id IN:listRP];
       // List<Client_Avail__c> ca1= [select id,Local_Title__c from Client_Avail__c where id IN:listCA];
       // SET<>
        Set<ID> idSet=new Set<ID>();
        for(Local_Title__c lt:listLT){
            idSet.add(lt.id);
        }
        capErrorMap.put(ca.id,'Too many Errors');
        Test.startTest();
         WB_Batch_Update_ReleasePlan_Owner controller = new WB_Batch_Update_ReleasePlan_Owner(idSet); 
       // String sch = '0  00 1 3 * ?';
       //	system.schedule('Test', sch, controller);
        controller.createErrorLog(capErrorMap.keySet(),capErrorMap);
        Test.stopTest();              
        
    }
    @isTest
    static void TestCAcreateErrorLog() {
        
        //Account acctGoogle = TestDataUtility.createAccount('TestGoogle', true);
        Account acctGoogle = TestUtil.initAccount();
        insert acctGoogle;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle',Video_Version__c ='6000047545',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,Formats__c='SD');
        insert title1;
       
        
        Country__c countryFrance =new Country__c(Name ='TestFrance',Country_Code2__c ='TR',Country_Code__c='TF',Turner_Override__c='BrazilQ',HBO_Override__c='EMEALicesnseeQ');
        insert countryFrance;
        
        Country__c countryJapan =new Country__c(Name ='TestJapan',Country_Code2__c ='TA',Country_Code__c='TJ',Turner_Override__c='BrazilQ',HBO_Override__c='EMEALicesnseeQ');
        insert countryJapan;
        
        Language__c languageFrench = new Language__c(Name='TestFrench',Language_Order__c = 1);
        insert languageFrench;
        
        Pricing__c price1 = new Pricing__c(Name ='Pr1',Account__c = acctGoogle.Id,Content_Type__c = title1.Content_Type__c,
                                           Country__c = countryFrance.Id,Channel__c ='DTD',Format__c ='HD'
                                          );
        insert price1;
        
        List<Local_Title__c> listLT= new List<Local_Title__c>();
        Local_Title__c local1 = new Local_Title__c(Name = 'local1',Title__c =title1.Id,Country__c = countryFrance.Id,
                                                   Language__c =languageFrench.Id,Price_Code__c =price1.Name,DisplayStudioOverride__c='HBO');
        
        listLT.add(local1);
        insert listLT ;
        
        List<Commercial_Avail__c> listRP= new List<Commercial_Avail__c>();
        Commercial_Avail__c releaseplan1 = new Commercial_Avail__c(Title__c=title1.Id,Country_Lookup__c=countryFrance.Id,Local_Title__c = local1.Id,
                                                                   Languages__c=languageFrench.Id ,Channel__c='DTD',Format__c='HD',Language_Type__c='Dub',Status__c='Tentative',
                                                                   Exclusive_Date__c = date.today()-1, Start_Date__c=date.today(),End_Date__c= date.today()+1,Rights_End__c=date.today()+2
                                                                   
                                                                  );
       // insert releaseplan1;
        listRP.add(releaseplan1);
        insert listRP;
                               
        
        Agreement__c storefrontGoogle1 = new Agreement__c(
            Account__c=acctGoogle.Id, Country__c=countryFrance.Id, Pricing_Currency__c='FR', Content_Type__c=title1.Content_Type__c,
            Channel_Picklist__c=releaseplan1.Channel__c, Format__c=releaseplan1.Format__c, Status__c ='Active',Turner_SAP_Customer__c='112345',
            HBO_SAP_Customer__c='456789',SAP_Customer_Number__c='456789'
        );
        insert storefrontGoogle1; 
        
        List<Client_Avail__c> listCA= new List<Client_Avail__c>();
        Client_Avail__c clientAvail1 = new Client_Avail__c(
            Commercial_Avail__c=releaseplan1.Id, Client__c=acctGoogle.Id,Status__c='Draft',
            Client_Start_Ovver__c = date.today()+3,End_Date__c=releaseplan1.End_Date__c
            
        );
        listCA.add(clientAvail1);
        insert listCA ;

        
         title1.DisplayStudio__c='Adult Swim';
        try{
        update title1;
        }
        catch(Exception e){
            System.debug('MESSAGE'+e.getMessage());
        }
        
        Batch_Ids_Customsetting__c batchIdCustomSetting = new Batch_Ids_Customsetting__c(
            Name = userInfo.getUserId(),
            CA_Batch_Id__c = '12',
            CA_Created_Date__c = system.today().addDays(-1),
            CA_User_Detail__c = userInfo.getUserId(),
            RP_Batch_Id__c = '15',
            RP_Created_Date__c = system.today()
        );
        insert batchIdCustomSetting;
        Map<Id,String> capErrorMap = new Map<Id,String>();
        Client_Avail__c ca= [select id from Client_Avail__c where id IN:listCA];
        Set<ID> idSet=new Set<ID>();
        for(Commercial_Avail__c rp:listRP){
            idSet.add(rp.id);
        }
        capErrorMap.put(ca.id,'Too many Errors');
        Test.startTest();
         WB_Batch_Update_ClientAvail_Owner controller = new WB_Batch_Update_ClientAvail_Owner(idSet); 
        controller.createErrorLog(capErrorMap.keySet(),capErrorMap);
        Test.stopTest();              
        
    }
}