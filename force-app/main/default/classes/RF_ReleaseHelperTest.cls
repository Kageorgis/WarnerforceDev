/*========================================================================================================
* @author Kalash
* @date 05/04/2021
* @description: Test class for RF_Releasehelper

==========================================================================================================*/
@isTest
public class RF_ReleaseHelperTest {
    @isTest
    static void firstMethodTheatrical() {
        Country__c countryusa = new Country__c(
            Name = 'USA',
            Country_Code__c = 'US',
            Country_Code2__c = 'US'
        );
        insert countryusa;
        Country__c countrycan = new Country__c(
            Name = 'Canada',
            Country_Code__c = 'CA',
            Country_Code2__c = 'CA'
        );
        insert countrycan;
        RF_Studio__c studioWB = new RF_Studio__c(
            Name = 'Warner Bros.',
            Distributor__c = 'WB'
        );
        insert studioWB;
        
        Test.startTest();
        List<Release__c> releaseList = new List<Release__c>();       
        releaseList.add(new Release__c(Name = 'testRelease' , 
                                       Country_List__c = 'USA', 
                                       RF_Studio__c = studioWB.Id,
                                       Street_Date__c = System.today()));
        releaseList.add(new Release__c(Name = 'testRelease_CA' , 
                                       Country_List__c = 'Canada', 
                                       RF_Studio__c = studioWB.Id,
                                       First_Theatrical_Date__c = System.today(),
                                       Release_Sync__c = releaseList[0].Id
                                      ));
        releaseList.add(new Release__c(Name = 'testRelease3' , 
                                       Country_List__c = 'Canada', 
                                       RF_Studio__c = studioWB.Id,
                                       First_Theatrical_Date__c = System.today(),
                                       In_Plant_Date__c = System.today()
                                      )); 
        insert releaseList ;
        
        Test.stopTest();
        try{
            releaseList[0].Name = 'testRelease1';
            releaseList[0].Country_List__c = 'Canada';
            releaseList[1].Name = 'testRelease2_CA';
            releaseList[1].Country_List__c = 'USA';
            update releaseList;
        }
        Catch(Exception exp){
            
        }
        releaseList[0].Digital_Announce_Date_Status__c  = 'Confirmed';
        releaseList[0].Digital_Copy_Expiration_Date__c  = System.today();
        releaseList[0].Global_First_Available_Date__c  =System.today();
        releaseList[0].Early_Intl_Date_Status__c  ='Confirmed';
        releaseList[0].Music_Rights_Status__c  ='Confirmed'; 
        releaseList[0].Pre_Order_EST_Date_Status__c  ='Confirmed';
        releaseList[0].Premiere_Date_Status__c  ='Confirmed';
        releaseList[0].Finale_Date_Status__c  ='Confirmed';
        releaseList[0].Soft_Pre_Order_Date_Status__c  ='Confirmed';
        releaseList[0].VOD_Date_Status__c  ='Confirmed';                    
        releaseList[0].Early_Pre_Order_Date_Status__c  ='Confirmed';
        releaseList[0].Physical_Announce_Date_Status__c  ='Confirmed';
        releaseList[0].Premium_Release_Announce_Date_Status__c  ='Confirmed';
        releaseList[0].Physical_Date_Status__c  ='Confirmed';
        releaseList[0].EST_Date_Status__c  ='Confirmed';
        releaseList[0].Physical_Rental_Date_Status__c  ='Confirmed';                    
        releaseList[0].Hotel_Date_Status__c  ='Confirmed';
        releaseList[0].PEST_Date_Status__c  ='Confirmed';
        releaseList[0].PVOD_Date_Status__c  ='Confirmed';
        releaseList[0].Premium_Release_Announce_Date__c  =System.today();
        releaseList[0].Soft_Pre_Order_Date__c  =System.today();
        releaseList[0].Order_Due_Date__c  =System.today();
        releaseList[0].PEST_Date__c  =System.today();
        releaseList[0].Trade_Assets_Due_to_JV_Date__c  =System.today();
        releaseList[0].Selling_Guides_Due_Date__c  =System.today();
        releaseList[0].Pre_Order_Close_Date__c  =System.today();
        releaseList[0].Early_Intl_Date__c  =System.today();
        releaseList[0].Premiere_Date__c  =System.today();  // Premiere Dates are country specific and should NOT by synced
        releaseList[0].Music_Rights_End_Date__c  =System.today();
        releaseList[0].Finale_Date__c  =System.today();
        releaseList[0].EST_Date__c  =System.today();
        releaseList[0].PVOD_Date__c  =System.today();
        releaseList[0].First_Theatrical_Date__c  =System.today();
        releaseList[0].U_S_Home_Ent_Announce_Date__c=System.today();
        releaseList[0].Theatrical_Dates__c  =System.today();
        releaseList[0].Street_Date__c=System.today();
        releaseList[0].VOD_Street_Date__c=System.today();
        releaseList[0].Physical_Announce_Date__c=System.today();
        releaseList[0].Digital_Announce_Date__c=System.today();
        releaseList[0].Pre_Order_EST_Date__c=System.today();
        releaseList[0].Trade_Solicitation_Date__c=System.today();
        releaseList[0].In_Plant_Date__c=System.today();
        releaseList[0].Early_Pre_Order_Date__c=System.today();
        releaseList[0].Physical_Rental_Date__c=System.today();
        releaseList[0].Drafting_Start_Date__c=System.today();
        releaseList[0].Drafting_End_Date__c=System.today();
        releaseList[0].Filmmaker_3rd_Party_Due_Date__c=System.today();
        releaseList[0].L1_Review_Date__c=System.today();
        releaseList[0].L2_Review_Date__c=System.today();
        releaseList[0].L3_Review_Date__c=System.today();
        releaseList[0].Artwork_Delivery_Due_Date__c=System.today();
        releaseList[0].Suppression_Lift_Datee__c = System.today();
        
        update releaseList[0];
        releaseList[1].Digital_Announce_Date_Status__c  = 'Confirmed';
        releaseList[1].Digital_Copy_Expiration_Date__c  = System.today();
        releaseList[1].Global_First_Available_Date__c  =System.today();
        releaseList[1].Early_Intl_Date_Status__c  ='Confirmed';
        releaseList[1].Music_Rights_Status__c  ='Confirmed'; 
        releaseList[1].Pre_Order_EST_Date_Status__c  ='Confirmed';
        releaseList[1].Premiere_Date_Status__c  ='Confirmed';
        releaseList[1].Finale_Date_Status__c  ='Confirmed';
        releaseList[1].Soft_Pre_Order_Date_Status__c  ='Confirmed';
        releaseList[1].VOD_Date_Status__c  ='Confirmed';                    
        releaseList[1].Early_Pre_Order_Date_Status__c  ='Confirmed';
        releaseList[1].Physical_Announce_Date_Status__c  ='Confirmed';
        releaseList[1].Premium_Release_Announce_Date_Status__c  ='Confirmed';
        releaseList[1].Physical_Date_Status__c  ='Confirmed';
        releaseList[1].EST_Date_Status__c  ='Confirmed';
        releaseList[1].Physical_Rental_Date_Status__c  ='Confirmed';                    
        releaseList[1].Hotel_Date_Status__c  ='Confirmed';
        releaseList[1].PEST_Date_Status__c  ='Confirmed';
        releaseList[1].PVOD_Date_Status__c  ='Confirmed';
        releaseList[1].Premium_Release_Announce_Date__c  =System.today();
        releaseList[1].Soft_Pre_Order_Date__c  =System.today();
        releaseList[1].Order_Due_Date__c  =System.today();
        releaseList[1].PEST_Date__c  =System.today();
        releaseList[1].Trade_Assets_Due_to_JV_Date__c  =System.today();
        releaseList[1].Selling_Guides_Due_Date__c  =System.today();
        releaseList[1].Pre_Order_Close_Date__c  =System.today();
        releaseList[1].Early_Intl_Date__c  =System.today();
        releaseList[1].Premiere_Date__c  =System.today();  // Premiere Dates are country specific and should NOT by synced
        releaseList[1].Music_Rights_End_Date__c  =System.today();
        releaseList[1].Finale_Date__c  =System.today();
        releaseList[1].EST_Date__c  =System.today();
        releaseList[1].PVOD_Date__c  =System.today();
        releaseList[1].First_Theatrical_Date__c  =System.today();
        releaseList[1].U_S_Home_Ent_Announce_Date__c=System.today();
        releaseList[1].Theatrical_Dates__c  =System.today();
        releaseList[1].Street_Date__c=System.today();
        releaseList[1].VOD_Street_Date__c=System.today();
        releaseList[1].Physical_Announce_Date__c=System.today();
        releaseList[1].Digital_Announce_Date__c=System.today();
        releaseList[1].Pre_Order_EST_Date__c=System.today();
        releaseList[1].Trade_Solicitation_Date__c=System.today();
        releaseList[1].In_Plant_Date__c=System.today();
        releaseList[1].Early_Pre_Order_Date__c=System.today();
        releaseList[1].Physical_Rental_Date__c=System.today();
        releaseList[1].Drafting_Start_Date__c=System.today();
        releaseList[1].Drafting_End_Date__c=System.today();
        releaseList[1].Filmmaker_3rd_Party_Due_Date__c=System.today();
        releaseList[1].L1_Review_Date__c=System.today();
        releaseList[1].L2_Review_Date__c=System.today();
        releaseList[1].L3_Review_Date__c=System.today();
        releaseList[1].Artwork_Delivery_Due_Date__c=System.today();
        releaseList[1].Suppression_Lift_Datee__c = System.today();
        
        update releaseList[1];
    }
    @isTest
    static void firstMethodCatalog() {
        RF_Studio__c studioWB = new RF_Studio__c(
            Name = 'Warner Bros.',
            Distributor__c = 'WB'
        );
        insert studioWB;
        
        List<Release__c> releaseList = new List<Release__c>();       
        releaseList.add(new Release__c(Name = 'testRelease' ,
                                       RecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Catalog').getRecordTypeId(),
                                       Country_List__c = 'USA', 
                                       RF_Studio__c = studioWB.Id,
                                       Street_Date__c = System.today()));
        releaseList.add(new Release__c(Name = 'testRelease_CA' , 
                                       Country_List__c = 'Canada', 
                                       RecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Catalog').getRecordTypeId(),
                                       RF_Studio__c = studioWB.Id,
                                       First_Theatrical_Date__c = System.today(),
                                       Release_Sync__c = releaseList[0].Id,
                                       In_Plant_Date__c = System.today()));
        insert releaseList ;
        
        releaseList[0].Name = 'testRelease1';
        releaseList[0].Country_List__c = 'Canada';
        releaseList[1].Name = 'testRelease2_CA';
        releaseList[1].Country_List__c = 'USA';
        
        update releaseList;
        
        releaseList[0].Digital_Announce_Date_Status__c  = 'Confirmed';
        releaseList[0].Digital_Copy_Expiration_Date__c  = System.today();
        releaseList[0].Global_First_Available_Date__c  =System.today();
        releaseList[0].Early_Intl_Date_Status__c  ='Confirmed';
        releaseList[0].Music_Rights_Status__c  ='Confirmed'; 
        releaseList[0].Pre_Order_EST_Date_Status__c  ='Confirmed';
        releaseList[0].Premiere_Date_Status__c  ='Confirmed';
        releaseList[0].Finale_Date_Status__c  ='Confirmed';
        releaseList[0].Soft_Pre_Order_Date_Status__c  ='Confirmed';
        releaseList[0].VOD_Date_Status__c  ='Confirmed';                    
        releaseList[0].Early_Pre_Order_Date_Status__c  ='Confirmed';
        releaseList[0].Physical_Announce_Date_Status__c  ='Confirmed';
        releaseList[0].Premium_Release_Announce_Date_Status__c  ='Confirmed';
        releaseList[0].Physical_Date_Status__c  ='Confirmed';
        releaseList[0].EST_Date_Status__c  ='Confirmed';
        releaseList[0].Physical_Rental_Date_Status__c  ='Confirmed';                    
        releaseList[0].Hotel_Date_Status__c  ='Confirmed';
        releaseList[0].PEST_Date_Status__c  ='Confirmed';
        releaseList[0].PVOD_Date_Status__c  ='Confirmed';
        releaseList[0].Premium_Release_Announce_Date__c  =System.today();
        releaseList[0].Soft_Pre_Order_Date__c  =System.today();
        releaseList[0].Order_Due_Date__c  =System.today();
        releaseList[0].PEST_Date__c  =System.today();
        releaseList[0].Trade_Assets_Due_to_JV_Date__c  =System.today();
        releaseList[0].Selling_Guides_Due_Date__c  =System.today();
        releaseList[0].Pre_Order_Close_Date__c  =System.today();
        //releaseList[0].Canadian_Ratings__c  =parentrecord.Canadian_Ratings__c;
        //releaseList[0].Send_Media_SD__c  =parentrecord.Send_Media_SD__c;
        //releaseList[0].Announce_Trade_PR__c  =parentrecord.Announce_Trade_PR__c;
        //releaseList[0].Send_Art_to_Talent__c  =parentrecord.Send_Art_to_Talent__c;
        releaseList[0].Early_Intl_Date__c  =System.today();
        releaseList[0].Premiere_Date__c  =System.today();  // Premiere Dates are country specific and should NOT by synced
        releaseList[0].Music_Rights_End_Date__c  =System.today();
        releaseList[0].Finale_Date__c  =System.today();
        releaseList[0].EST_Date__c  =System.today();
        releaseList[0].PVOD_Date__c  =System.today();
        releaseList[0].First_Theatrical_Date__c  =System.today();
        releaseList[0].U_S_Home_Ent_Announce_Date__c=System.today();
        releaseList[0].Theatrical_Dates__c  =System.today();
        releaseList[0].Street_Date__c=System.today();
        releaseList[0].VOD_Street_Date__c=System.today();
        releaseList[0].Physical_Announce_Date__c=System.today();
        releaseList[0].Digital_Announce_Date__c=System.today();
        releaseList[0].Pre_Order_EST_Date__c=System.today();
        releaseList[0].Trade_Solicitation_Date__c=System.today();
        releaseList[0].In_Plant_Date__c=System.today();
        releaseList[0].Early_Pre_Order_Date__c=System.today();
        releaseList[0].Physical_Rental_Date__c=System.today();
        //releaseList[0].Solicitation_Days__c=parentrecord.Solicitation_Days__c;
        releaseList[0].Drafting_Start_Date__c=System.today();
        releaseList[0].Drafting_End_Date__c=System.today();
        //releaseList[0].Marketing_Guidelines_Guardrails__c=parentrecord.Marketing_Guidelines_Guardrails__c;
        //releaseList[0].Approve_Catalog_Drafting_Titles__c=parentrecord.Approve_Catalog_Drafting_Titles__c;
        //releaseList[0].Marketing_Alert_Request_Input_To_Plan__c=parentrecord.Marketing_Alert_Request_Input_To_Plan__c;
        //releaseList[0].Domestic_Initial_Info_To_Mkts_Request__c=parentrecord.Domestic_Initial_Info_To_Mkts_Request__c;
        //releaseList[0].WW_Creative_Kick_Off__c=parentrecord.WW_Creative_Kick_Off__c;
        releaseList[0].Filmmaker_3rd_Party_Due_Date__c=System.today();
        //releaseList[0].Client_Avails_Confirmation__c=parentrecord.Client_Avails_Confirmation__c;
        releaseList[0].L1_Review_Date__c=System.today();
        releaseList[0].L2_Review_Date__c=System.today();
        releaseList[0].L3_Review_Date__c=System.today();
        releaseList[0].Artwork_Delivery_Due_Date__c=System.today();
        releaseList[0].Suppression_Lift_Datee__c = System.today();
        
        update releaseList[0];
    }
    @isTest
    static void firstMethodTV() {
        RF_Studio__c studioWB = new RF_Studio__c(
            Name = 'Warner Bros.',
            Distributor__c = 'WB'
        );
        insert studioWB;
        
        List<Release__c> releaseList = new List<Release__c>();       
        releaseList.add(new Release__c(Name = 'testRelease' ,
                                       RecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('TV').getRecordTypeId(),
                                       Country_List__c = 'Canada',
                                       EST_Date__c = System.Today(),
                                       Premiere_Date__c = System.today(),
                                       RF_Studio__c = studioWB.Id,
                                       Street_Date__c = System.today()));
        releaseList.add(new Release__c(Name = 'testRelease_CA' , 
                                       Country_List__c = 'USA', 
                                       RecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('TV').getRecordTypeId(),
                                       RF_Studio__c = studioWB.Id,
                                       Release_Sync__c = releaseList[0].Id,
                                       Digital_Copy__c = false,
                                       First_Theatrical_Date__c = System.today(),
                                       In_Plant_Date__c = System.today()));
        insert releaseList ;
        
        releaseList[0].Name = 'testRelease1';
        releaseList[0].Country_List__c = 'USA';
        releaseList[0].Premiere_Date__c = System.today()+2;
        releaseList[0].EST_Date__c = System.Today()+2;
        releaseList[0].Pre_Order_Logic__c = '1 week';
        releaseList[1].Name = 'testRelease2_CA';
        releaseList[1].Country_List__c = 'Canada';
        releaseList[1].Street_Date__c = System.today();
        releaseList[1].Digital_Copy__c = true;
        releaseList[1].EST_Date__c = System.Today()+3;
        releaseList[1].Digital_Category__c='Next Day Air (NDA)';
        releaseList[1].Premiere_Date__c = System.today();
        releaseList[1].Pre_Order_Logic__c = '4 week';
        
        update releaseList;
        
        releaseList[1].Digital_Category__c = 'Day After Finale';
        releaseList[1].Finale_Date__c = System.today();
        releaseList[1].Pre_Order_Logic__c = '3 week';
        
        update releaseList[1];
        
        releaseList[0].Pre_Order_Logic__c = '2 week';
        update releaseList[0];
        
        Release_Planning_Release__c tstMPremiere = new Release_Planning_Release__c(
        RecordTypeId = Schema.SObjectType.Release_Planning_Release__c.getRecordTypeInfosByName().get('Digital TV Store').getRecordTypeId(),
        Release__c = releaseList[0].id);
        insert tstMPremiere;
        
        Test.startTest();
        List<Release__c> lstReleaseUpd= [SELECT id,Digital_Copy_Expiration_Date__c,Release_Sync__c,Global_First_Available_Date__c,Early_Intl_Date_Status__c,Music_Rights_Status__c,Pre_Order_EST_Date_Status__c,Premiere_Date_Status__c,Finale_Date_Status__c,Soft_Pre_Order_Date_Status__c,Physical_Rental_Date_Status__c,VOD_Date_Status__c,PVOD_Date_Status__c,Hotel_Date_Status__c,EST_Date_Status__c,PEST_Date_Status__c,Physical_Date_Status__c,Premium_Release_Announce_Date_Status__c,Physical_Announce_Date_Status__c,Early_Pre_Order_Date_Status__c,Premium_Release_Announce_Date__c,Soft_Pre_Order_Date__c,Order_Due_Date__c,Trade_Assets_Due_to_JV_Date__c,Selling_Guides_Due_Date__c,Pre_Order_Close_Date__c,Mechs_Due__c,Canadian_Ratings__c,Send_Media_SD__c,Announce_Trade_PR__c,Send_Art_to_Talent__c,Early_Intl_Date__c,Premiere_Date__c,Music_Rights_End_Date__c,Finale_Date__c,Artwork_Delivery_Due_Date__c,L3_Review_Date__c,L2_Review_Date__c,L1_Review_Date__c,U_S_Home_Ent_Announce_Date__c,Client_Avails_Confirmation__c,Filmmaker_3rd_Party_Due_Date__c,WW_Creative_Kick_Off__c,Domestic_Initial_Info_To_Mkts_Request__c,Marketing_Alert_Request_Input_To_Plan__c,Approve_Catalog_Drafting_Titles__c,Marketing_Guidelines_Guardrails__c,Drafting_End_Date__c,Solicitation_Days__c,Drafting_Start_Date__c,PVOD_Date__c,EST_Window__c,Physical_Rental_Date__c,Early_Pre_Order_Date__c,Pre_Order_EST_Date__c,Trade_Solicitation_Date__c,PEST_Date__c,First_Theatrical_Date__c,Theatrical_Dates__c,Street_Date__c,VOD_Street_Date__c,Physical_Announce_Date__c,Digital_Announce_Date__c,EST_Date__c,PEST_Windows__c FROM Release__c WHERE Name='testRelease1' LIMIT 1];
        RF_Studio__c stuWB = [SELECT Id from RF_Studio__c where Name = 'Warner Bros.' LIMIT 1];
        if(lstReleaseUpd!=null && lstReleaseUpd.size()>0){
            Release__c tstrt4 = lstReleaseUpd[0];
            if(lstReleaseUpd!=null){
                Release__c tstR3= new Release__c();
                tstR3.RecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Theatrical').getRecordTypeId();       
                tstR3.Name='tstRelMaterials';
                tstR3.Country_List__c = 'USA';
                tstR3.Street_Date__c = System.today();
                tstR3.Physical_Date_Status__c = 'Confirmed';
                tstR3.EST_Date__c = System.today();
                tstR3.Premiere_Date__c = System.today();
                tstR3.Finale_Date__c = System.today();   
                tstR3.Release_Sync__c = tstrt4.id;
                tstR3.RF_Studio__c = stuWB.Id;
                system.debug('tstR3.Release_Sync__c====>'+tstR3.Release_Sync__c);
                upsert tstR3;
            }
        }
        Test.stopTest();
    }
    @isTest
    static void firstMethodSDS() {
        RF_Studio__c studioWB = new RF_Studio__c(
            Name = 'Warner Bros.',
            Distributor__c = 'WB'
        );
        insert studioWB;
        
        List<Release__c> releaseList = new List<Release__c>();       
        releaseList.add(new Release__c(Name = 'testRelease' ,
                                       Project_Type__c = 'TV',
                                       RecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('SDS').getRecordTypeId(),
                                       Country_List__c = 'USA', 
                                       RF_Studio__c = studioWB.Id,
                                       VOD_Street_Date__c = System.today(),
                                       U_S_Home_Ent_Announce_Date__c = System.today(),
                                       Street_Date__c = System.today()));
        releaseList.add(new Release__c(Name = 'testRelease_CA' , 
                                       Country_List__c = 'Canada',
                                       Project_Type__c = 'Catalog',
                                       RecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('SDS').getRecordTypeId(),
                                       RF_Studio__c = studioWB.Id,
                                       First_Theatrical_Date__c = System.today(),
                                       VOD_Street_Date__c = System.today(),
                                       U_S_Home_Ent_Announce_Date__c = System.today(),
                                       In_Plant_Date__c = System.today()));
        
        insert releaseList ;
        
        releaseList[0].Name = 'testRelease1';
        releaseList[0].Country_List__c = 'Canada';
        releaseList[1].Name = 'testRelease2_CA';
        releaseList[1].Country_List__c = 'USA';
        
        update releaseList;
    }
}