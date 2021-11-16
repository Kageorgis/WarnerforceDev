@isTest
public class WB_Batch_AutomatedReleaseDateRPTest {

    public static list<Id> titleIdList= new list<Id>();
    public static List<String> listCountryIds = new List<String>();
    public static Map<String, String> mapRightsGrp = new Map<String, String>();
    public static List<Rights__c> lstRights = new List<Rights__c>();
    public static Set<String> SelectedFormatStrSet = new Set<String>();
    public static List<WB_CreateCommercialAvail_Controller> cccList = new List<WB_CreateCommercialAvail_Controller>();
    public static List<Title__c> titleList= new List<Title__c>();
    public static list<country__c> conList= new  list<country__c>();
    public static List<Language__c> languages = new List<Language__c>();
    
    public static void createTestData(){
        //List<Title__c> titleList= new List<Title__c>();
        
        Batch_Ids_Customsetting__c batchIDs= new Batch_Ids_Customsetting__c(name='Batch1',RP_Batch_Id__c='1' );
        insert batchIDs;
        
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        for(Integer i=1;i<3;i++){
            titleList.add(new Title__c(Name='New Title'+i,Content_Type__c = 'Feature', Video_Version__c='0723456789'+i,Formats__c='HD',First_Available_Date__c=system.today(),MPM__c = mpm.id,Studio__c='BBC',Genre__c='ACTION',Short_Synopsis__c='short description',Digital_Planning__c='Yes'));
        }
        insert titleList;
        
        Title__c title = titleList[0];
        for(Integer i=0;i<2;i++){
            titleIdList.add(titleList[i].id);
        }
         
       
        Language__c Language1 = new Language__c (Name='English',Language_Order__c = 1,Language_Code_2__c='en');
        languages.add(Language1);
        Language__c Language2 = new Language__c (Name='Arabic', Language_Order__c = 2,Language_Code_2__c='ar');
        languages.add(Language2);
        Language__c Language3 = new Language__c (Name='Danish', Language_Order__c = 2,Language_Code_2__c='da');
        languages.add(Language3);
        insert languages;
        
        List<Available_Languages__c> availLangs = new List<Available_Languages__c>();
        Available_Languages__c availLangTitle1 = new Available_Languages__c(Language__c=languages[0].Id ,Language_Types__c='Sub',Title__c=titleList[0].id,Clear_To_Avail__c=true);
        availLangs.add(availLangTitle1);
        Available_Languages__c availLangTitle2 = new Available_Languages__c(Language__c=languages[0].Id ,Language_Types__c='Audio',Title__c=titleList[1].id,Clear_To_Avail__c=true); //,Provisional__c=true
        availLangs.add(availLangTitle2);
        insert availLangs;
        
        
        
        country__c con= new country__c(Name='India',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='EST;VODi',Territory__c='testTerritory',Status__c='Active');
        
        country__c con1= new country__c(Name='UK',Country_Code__c='Te1', Country_Code2__c='t1',Status__c='Active');
        conList.add(con);
        conList.add(con1);
        insert conList;
        listCountryIds.add(con.id);
        listCountryIds.add(con1.id);
        
        
        Language_Preference__c langPrefTest1= new Language_Preference__c(Country__c=con.Id,Language__c=languages[0].Id,Level__c='0',Physical_Only__c=false);
        insert langPrefTest1;    
        
        Rights_Group__c rightGroup = new Rights_Group__c(Name = 'Australia',Country__c=con.id,Language__c=languages[0].id, Rights_Group__c='Australia');
        insert rightGroup;
        
        Rights__c rights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id,Rights_Start__c= system.today(),Rights_End__c=system.today()+3,Rights_Start_2__c= system.today()+5,Rights_End_2__c=system.today()+6,Rights_Start_3__c= system.today()+9,Rights_End_3__c=system.today()+10,Rights_Start_4__c= system.today()+13,Rights_End_4__c=system.today()+14,Rights_Start_5__c= system.today()+17,Rights_End_5__c=system.today()+18, Rights_Group__c = rightGroup.Name,Status__c='Confirmed', Source__c = 'Cosmos');
        lstRights.add(rights);
        insert rights;
        
        List<commercial_avail__c> listComm = new List<commercial_avail__c>();
        Date reference = system.today().addYears(1);
        commercial_avail__c commAvailTest= new commercial_avail__c();          
        commAvailTest.Exclusive_Date__c = reference;// AVAIL START
        commAvailTest.Rights_End__c = reference.addDays(25); // AVAIL END
        commAvailTest.Start_Date__c = reference.addDays(10); // REL START
        commAvailTest.End_Date__c = reference.addDays(15); //REL START
        commAvailTest.status__c='Open';
        commAvailTest.Country_Lookup__c = con.id;
        commAvailTest.title__c = titleList[0].id;
        commAvailTest.Languages__c = languages[0].id;
        commAvailTest.Channel__c = null;
        commAvailTest.RP_AutoCalc__c = true;
        commAvailTest.Rights_ID__c= rights.Id;
        listComm.add(commAvailTest);
        
        commercial_avail__c commAvailTest2= new commercial_avail__c(); 
        commAvailTest2.Rights_End__c=null;
        commAvailTest2.Exclusive_Date__c=null;
        commAvailTest2.Start_Date__c=null;
        commAvailTest2.End_Date__c=null;
        commAvailTest2.status__c='Open';
        commAvailTest2.Country_Lookup__c = con.id;
        commAvailTest2.title__c = titleList[0].id;
        commAvailTest2.Languages__c = languages[0].id;
        commAvailTest2.Channel__c = 'Hotel';
        listComm.add(commAvailTest2);
        
        insert listComm;
        
        PageReference pRef = Page.WB_Create_CommercialAvail;
        pRef.getParameters().put('id',titleList[0].id);
        Test.setCurrentPage(pRef);
        
        
        List<Commercial_Avail__c> caList = new List<Commercial_Avail__c>();
        Country_Groups__c conGrp= new Country_Groups__c(Name='TestGrp');
        insert conGrp;
        caList.add(new Commercial_Avail__c(Country_Group__c=conGrp.Id));
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(caList);
        WB_CreateCommercialAvail_Controller ccc = new WB_CreateCommercialAvail_Controller(sc);
        
        WB_CreateCommercialAvail_Controller.channelWrapper channelWrapper = new WB_CreateCommercialAvail_Controller.channelWrapper();
        channelWrapper.countryChannel = 'EST';
        channelWrapper.additionalInfo = commAvailTest;
        
        channelWrapper.renderExclusiveDate = true;
        ccc.channelGridList = new List<WB_CreateCommercialAvail_Controller.channelWrapper>();
        ccc.channelGridList.add(channelWrapper);
        ccc.mapRightsDate(listComm);
        
        WB_CreateCommercialAvail_Controller.channelWrapper channelWrapper2 = new WB_CreateCommercialAvail_Controller.channelWrapper();
        channelWrapper2.countryChannel = 'VODi';
        channelWrapper2.additionalInfo = commAvailTest2;  
        ccc.channelGridList.add(channelWrapper2);  
        ccc.titleList = titleList;
        cccList.add(ccc);
       
        mapRightsGrp.put(languages[0].Language_Code_2__c+'_'+con1.Country_Code2__c, rightGroup.Rights_Group__c);
        
        
        
        SelectedFormatStrSet.add('HD');
        
        
    }
    
    
    public static testmethod void updateReleasePlan() {
        createTestData();
        Test.startTest();
        
        WB_Batch_AutomatedReleaseDateRP batchRP = new WB_Batch_AutomatedReleaseDateRP();
        Database.executeBatch(batchRP);
        Test.stoptest();
    }
    
    public static testmethod void updateReleasePlanNeg() {
        createTestData();
        Test.startTest();
        
        country__c conNeg= new country__c(Name='UAE',Country_Code__c='UAE', Country_Code2__c='UAE2',Channel__c='EST;VODi',Territory__c='testTerritoryNeg',Status__c='Active');
        insert conNeg;
        
        commercial_avail__c commAvailTestNeg= new commercial_avail__c(); 
        commAvailTestNeg.Rights_End__c=date.today()+5;
        commAvailTestNeg.Exclusive_Date__c=date.today();
        commAvailTestNeg.Start_Date__c=date.today();
        commAvailTestNeg.End_Date__c=date.today()+1;
        commAvailTestNeg.status__c='Open';
        commAvailTestNeg.Country_Lookup__c = conNeg.id;
        commAvailTestNeg.title__c = titleList[0].id;
        commAvailTestNeg.Languages__c = languages[0].id;
        commAvailTestNeg.Channel__c = null;
        commAvailTestNeg.RP_AutoCalc__c = true;
        insert commAvailTestNeg;
        
        
        WB_Batch_AutomatedReleaseDateRP batchRP = new WB_Batch_AutomatedReleaseDateRP();
        Database.executeBatch(batchRP);
        Test.stoptest();
    }
    
}