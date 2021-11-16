@isTest
public class WB_Batch_VBOMRightsRequestWizard_Test {
        public static List<MPM__c> mpmList = new List<MPM__c>();
        public static list<title__c> titleList;
        public static Title__c titleRec,titleRec2,titleRec3,titleRec4;
        public static Title_BOM__c titleBOM,titleBOM2,titleBOM3;
        public static List<Rights__c> rightsList;
        public static Rights__c rights,rights1,rights2,rights3,rights4;
        public static country__c con,con2;
        public static Language__c Language,Language1;
        public static Rights_Group__c rightGroup,rightGroup2;
    
   
     public static void creatTestData(){
        MPM__c mpm,mpm2,mpm3,mpm4;
        mpm = new MPM__c(name='MPM record1',MPM_Number__c='21231',MPM_Short_Desc__c = 'test mpm desc',Production_Year__c = '2015',Status__c = 'Released/Del',Film_Color__c='Color',Generic__c=false);
        mpmList.add(mpm);
        mpm2 = new MPM__c(name='MPM record2',MPM_Number__c='22341',MPM_Short_Desc__c = 'test mpm desc',Production_Year__c = '2016',Status__c = 'Released/Del',Film_Color__c='Color',Generic__c=true);
        mpmList.add(mpm2);
        mpm3 = new MPM__c(name='MPM record3',MPM_Number__c='12341',MPM_Short_Desc__c = 'test mpm desc',Production_Year__c = '2017',Status__c = 'Released/Del',Film_Color__c='Color',Generic__c=false);
        mpmList.add(mpm3);
        mpm4 = new MPM__c(name='MPM record3',MPM_Number__c='23451',MPM_Short_Desc__c = 'test mpm desc',Production_Year__c = '2017',Status__c = 'Released/Del',Film_Color__c='Color',Generic__c=true);
        mpmList.add(mpm4);
        insert mpmList;
        
        titleList = new list<title__c>();
        titleRec = new Title__c(Name = 'TestGoogle',MPM__c=mpm.id,Video_Version__c ='1234567',Content_Type__c='Feature',Digital_Planning__c='YES',Clear_to_Avail__c = true,
        US_BD_Release_Date__c=date.today()-3,US_TV_Air_Date__c=date.today()-3,US_UV_Publish_Date__c=date.today()-3,US_Box_Office__c=1111.00,US_DVD_Release_Date__c=date.today()-3,
        US_Pay_TV_Start_Date__c = date.today()-3,Formats__c ='SD');
        titleList.add( titleRec);
        titleRec2 = new Title__c(Name = 'TestApple',MPM__c=mpm2.id,Video_Version__c ='555666',Content_Type__c='Episode',Physical_Planning__c='YES',Digital_Planning__c='YES',Clear_to_Avail__c = true,
        US_BD_Release_Date__c=date.today()-3,US_TV_Air_Date__c=date.today()-3,US_UV_Publish_Date__c=date.today()-3,US_Box_Office__c=1111.00,US_DVD_Release_Date__c=date.today()-3,
        US_Pay_TV_Start_Date__c = date.today()-3,Formats__c ='BD');
        titleList.add( titleRec2);
        titleRec3 = new Title__c(Name = 'TestApple2',MPM__c=mpm3.id,Video_Version__c ='555666123',Content_Type__c='Episode',Physical_Planning__c='YES',Digital_Planning__c='YES',Clear_to_Avail__c = true,
        US_BD_Release_Date__c=date.today()-3,US_TV_Air_Date__c=date.today()-3,US_UV_Publish_Date__c=date.today()-3,US_Box_Office__c=1111.00,US_DVD_Release_Date__c=date.today()-3,
        US_Pay_TV_Start_Date__c = date.today()-3,Formats__c ='BD');
        titleList.add( titleRec3);
        titleRec4 = new Title__c(Name = 'TestApple3',MPM__c=mpm4.id,Video_Version__c ='55566612345',Content_Type__c='Episode',Physical_Planning__c='YES',Digital_Planning__c='YES',Clear_to_Avail__c = true,
        US_BD_Release_Date__c=date.today()-3,US_TV_Air_Date__c=date.today()-3,US_UV_Publish_Date__c=date.today()-3,US_Box_Office__c=1111.00,US_DVD_Release_Date__c=date.today()-3,
        US_Pay_TV_Start_Date__c = date.today()-3,Formats__c ='BD');
        titleList.add(titleRec4);
        insert titleList;
        
        titleBOM = new Title_BOM__c();
        titleBOM.Title__c = titleRec.id;
        titleBOM.MPM__c = mpm.Id;
        titleBOM.BOM_Type__c = 'VBOM';
        insert titleBOM;
        titleBOM2 = new Title_BOM__c();
        titleBOM2.Title__c = titleRec2.id;
        titleBOM2.MPM__c = mpm2.Id;
        titleBOM2.BOM_Type__c = 'VBOM';
        insert titleBOM2;
        titleBOM3 = new Title_BOM__c();
        titleBOM3.Title__c = titleRec3.id;
        titleBOM3.MPM__c = mpm3.Id;
        titleBOM3.BOM_Type__c = 'VBOM';
         insert titleBOM3;
        
        rightsList = new List<Rights__c>();
        rights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id,Rights_End__c=system.today()+3, Rights_Group__c = 'USA',Rights_Start__c= system.today(),Status__c='Confirmed',Source__c = 'cosmos',Rights_Query_Start_Date__c= system.today(),Title__c=titleRec.id);
        rightsList.add(rights);
        rights1 = new Rights__c(Channel__c = 'VODI',MPM__c = mpm2.id,Rights_End__c=system.today()+3, Rights_Group__c = 'USA',Rights_Start__c= system.today(),Status__c='Confirmed',Source__c = 'cosmos',Rights_Query_Start_Date__c= null,Title__c=titleRec2.id);
        rightsList.add(rights1);
        rights2 = new Rights__c(Channel__c = 'VODI',MPM__c = mpm4.id,Rights_End__c=system.today()+3, Rights_Group__c = 'USA',Rights_Start__c= system.today(),Status__c='Confirmed',Source__c = 'cosmos',Rights_Query_Start_Date__c= system.today(),Title__c=titleRec4.id);
        rightsList.add(rights2);
        insert rightsList;
        
        con= new country__c(Name='USA',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='VODI;EST');
        insert con;
        con2= new country__c(Name='India',Country_Code__c='Ind', Country_Code2__c='In',Channel__c='VODI;EST');
        insert con2;
        
        Language = new Language__c (Name='English', Language_Order__c = 1);
        insert Language;
        Language1 = new Language__c (Name='Hindi', Language_Order__c = 1);
        insert Language1;
        
        RightGroup = new Rights_Group__c(Name = 'USA',Country__c=con.id,Language__c=Language.id,Rights_Group__c='USA', Rights_Locale__c = True);
        insert rightGroup;
        
        RightGroup2 = new Rights_Group__c(Name = 'India',Country__c=con2.id,Language__c=Language1.id,Rights_Group__c = 'India', Rights_Locale__c = True);
        insert RightGroup2;

    }
    static testmethod void WB_Batch_VBOMRightsRequest_positive(){
        
         Batch_Ids_Customsetting__c batchIdCustomSetting = new Batch_Ids_Customsetting__c(
            Name = userInfo.getUserId(),
            CA_Batch_Id__c = '12',
            CA_Created_Date__c = system.today().addDays(-1),
            CA_User_Detail__c = userInfo.getUserId(),
            RP_Batch_Id__c = '15',
            RP_Created_Date__c = system.today(),
            Rights_Batch_Id__c = '1'
        );
                
        insert batchIdCustomSetting;
        
        creatTestData();
        map<String,MPM__c> mapMPMrecords   = new map<String,MPM__c>();
        for(MPM__c mpmRecord:[SELECT ID,Generic__c,Name, Film_Color__c, MPM_Short_Desc__c,Production_Year__c, Status__c,MPM_Number__c,
            (select id,Name,Source__c,Rights_Group__c,Channel__c,Request_Refresh__c,Status__c,Rights_Query_Start_Date__c,Rights_End__c,Rights_Start__c from Rights__r) FROM MPM__c WHERE ID IN:mpmList]){
            mapMPMrecords.put(mpmRecord.Name,mpmRecord);
        }
        
        map<ID,String> maptitleIDandMPM = new map<ID,String>();
        map<ID,String> mapTBOMIDandMPM = new map<ID,String>(); 
        map<ID,Set<ID>> maptitleIDListTBOMID = new map<ID,Set<ID>>(); 
       
        List<Title__c> lstSelectedTitle = [Select Id,Name,Status__c,Film_Color_formula__c,Video_Version__c ,Production_Year_formula__c,MPM__r.Generic__c,MPM__r.ID,MPM__r.Name, MPM__r.Film_Color__c, MPM__r.MPM_Short_Desc__c,MPM__r.Production_Year__c, MPM__r.Status__c,(select id,Name,Source__c,Rights_Group__c,Channel__c,Request_Refresh__c,Status__c,Rights_Query_Start_Date__c,Rights_End__c,Rights_Start__c,MPM__r.Name from Rights__r),
            (Select ID, Name, MPM__r.ID,MPM__r.Name, MPM__r.Film_Color__c, MPM__r.MPM_Short_Desc__c,MPM__r.Production_Year__c, MPM__r.Status__c, MPM__r.Generic__c,Title__r.Video_Version__c,BOM_Type__c FROM Title_BOM__r where BOM_Type__c='VBOM') from Title__c where Id IN:titleList];
        for(Title__c title : lstSelectedTitle){
            if(title.MPM__r.ID!=null){
                maptitleIDandMPM.put(title.id,title.MPM__r.Name);
            }
            for(Title_BOM__c titleBOM : title.Title_BOM__r){
                mapTBOMIDandMPM.put(titleBOM.ID,titleBOM.MPM__r.Name);
                if(maptitleIDListTBOMID.containsKey(title.ID))
                maptitleIDListTBOMID.get(title.ID).add(titleBOM.ID);
                else{   
                    Set<ID> TBOMIds = new Set<ID>();
                    TBOMIds.add(titleBOM.ID);
                    maptitleIDListTBOMID.put(title.ID,TBOMIds); 
                }
            }
        }
        Set<string> setGroupsAndchannel = new Set<string>{'India_EST','India_VODI','USA_EST','USA_VODI'};
        Rights__c  objRights = new Rights__c();
            WB_Batch_VBOMRightsRequestWizard vBOMRightsRequestBatch = new WB_Batch_VBOMRightsRequestWizard(lstSelectedTitle,mapMPMrecords,maptitleIDandMPM,maptitleIDListTBOMID,mapTBOMIDandMPM,setGroupsAndchannel,objRights);
            
        Test.startTest();
            
            Database.executeBatch(vBOMRightsRequestBatch,10);   
            vBOMRightsRequestBatch.batchIdGeneration(rightsList);
        Test.stopTest();
    }
    
    static testmethod void WB_Batch_VBOMRightsRequest_genericMPM(){
       
        creatTestData();
        for(MPM__c mpmRecord:mpmList){
            mpmRecord.Generic__c=true;
        }
        update mpmList;
        
        map<String,MPM__c> mapMPMrecords   = new map<String,MPM__c>();
        for(MPM__c mpmRecord:[SELECT ID,Generic__c,Name, Film_Color__c, MPM_Short_Desc__c,Production_Year__c, Status__c,MPM_Number__c,
            (select id,Name,Source__c,Rights_Group__c,Channel__c,Request_Refresh__c,Status__c,Rights_Query_Start_Date__c,Rights_End__c,Rights_Start__c from Rights__r) FROM MPM__c WHERE ID IN:mpmList]){
            mapMPMrecords.put(mpmRecord.Name,mpmRecord);
        }
        
        map<ID,String> maptitleIDandMPM = new map<ID,String>();
        map<ID,String> mapTBOMIDandMPM = new map<ID,String>(); 
        map<ID,Set<ID>> maptitleIDListTBOMID = new map<ID,Set<ID>>(); 

        List<Title__c> lstSelectedTitle = [Select Id,Name,Status__c,Film_Color_formula__c,Video_Version__c ,Production_Year_formula__c,MPM__r.Generic__c,MPM__r.ID,MPM__r.Name, MPM__r.Film_Color__c, MPM__r.MPM_Short_Desc__c,MPM__r.Production_Year__c, MPM__r.Status__c,(select id,Name,Source__c,Rights_Group__c,Channel__c,Request_Refresh__c,Status__c,Rights_Query_Start_Date__c,Rights_End__c,Rights_Start__c,MPM__r.Name from Rights__r),
            (Select ID, Name, MPM__r.ID,MPM__r.Name, MPM__r.Film_Color__c, MPM__r.MPM_Short_Desc__c,MPM__r.Production_Year__c, MPM__r.Status__c, MPM__r.Generic__c,Title__r.Video_Version__c,BOM_Type__c FROM Title_BOM__r where BOM_Type__c='VBOM') from Title__c where Id IN:titleList];
        for(Title__c title : lstSelectedTitle){
            if(title.MPM__r.ID!=null){
                maptitleIDandMPM.put(title.id,title.MPM__r.Name);
            }
            for(Title_BOM__c titleBOM : title.Title_BOM__r){
                mapTBOMIDandMPM.put(titleBOM.ID,titleBOM.MPM__r.Name);
                if(maptitleIDListTBOMID.containsKey(title.ID))
                maptitleIDListTBOMID.get(title.ID).add(titleBOM.ID);
                else{   
                    Set<ID> TBOMIds = new Set<ID>();
                    TBOMIds.add(titleBOM.ID);
                    maptitleIDListTBOMID.put(title.ID,TBOMIds); 
                }
            }
        }

        Set<string> setGroupsAndchannel = new Set<string>{'India_EST','India_VODI','USA_EST','USA_VODI'};
        Rights__c  objRights = new Rights__c();
            WB_Batch_VBOMRightsRequestWizard vBOMRightsRequestBatch = new WB_Batch_VBOMRightsRequestWizard(lstSelectedTitle,mapMPMrecords,maptitleIDandMPM,maptitleIDListTBOMID,mapTBOMIDandMPM,setGroupsAndchannel,objRights);
            
        Test.startTest();
            Database.executeBatch(vBOMRightsRequestBatch,10);   
           
        Test.stopTest();
    }
    
     static testmethod void WB_Batch_VBOMRightsRequest_MPM_NotStartsWithTwo(){
       
        creatTestData();
        Integer i = 0;
        for(MPM__c mpmRecord:mpmList){
            mpmRecord.MPM_Number__c='12341'+i;
            i++;
        }
        update mpmList;
        
        map<String,MPM__c> mapMPMrecords   = new map<String,MPM__c>();
        for(MPM__c mpmRecord:[SELECT ID,Generic__c,Name, Film_Color__c, MPM_Short_Desc__c,Production_Year__c, Status__c,MPM_Number__c,
            (select id,Name,Source__c,Rights_Group__c,Channel__c,Request_Refresh__c,Status__c,Rights_Query_Start_Date__c,Rights_End__c,Rights_Start__c from Rights__r) FROM MPM__c WHERE ID IN:mpmList]){
            mapMPMrecords.put(mpmRecord.Name,mpmRecord);
        }
        
        map<ID,String> maptitleIDandMPM = new map<ID,String>();
        map<ID,String> mapTBOMIDandMPM = new map<ID,String>(); 
        map<ID,Set<ID>> maptitleIDListTBOMID = new map<ID,Set<ID>>(); 

        List<Title__c> lstSelectedTitle = [Select Id,Name,Status__c,Film_Color_formula__c,Video_Version__c ,Production_Year_formula__c,MPM__r.Generic__c,MPM__r.ID,MPM__r.Name, MPM__r.Film_Color__c, MPM__r.MPM_Short_Desc__c,MPM__r.Production_Year__c, MPM__r.Status__c,(select id,Name,Source__c,Rights_Group__c,Channel__c,Request_Refresh__c,Status__c,Rights_Query_Start_Date__c,Rights_End__c,Rights_Start__c,MPM__r.Name from Rights__r),
            (Select ID, Name, MPM__r.ID,MPM__r.Name, MPM__r.Film_Color__c, MPM__r.MPM_Short_Desc__c,MPM__r.Production_Year__c, MPM__r.Status__c, MPM__r.Generic__c,Title__r.Video_Version__c,BOM_Type__c FROM Title_BOM__r where BOM_Type__c='VBOM') from Title__c where Id IN:titleList];
        for(Title__c title : lstSelectedTitle){
            if(title.MPM__r.ID!=null){
                maptitleIDandMPM.put(title.id,title.MPM__r.Name);
            }
            for(Title_BOM__c titleBOM : title.Title_BOM__r){
                mapTBOMIDandMPM.put(titleBOM.ID,titleBOM.MPM__r.Name);
                if(maptitleIDListTBOMID.containsKey(title.ID))
                maptitleIDListTBOMID.get(title.ID).add(titleBOM.ID);
                else{   
                    Set<ID> TBOMIds = new Set<ID>();
                    TBOMIds.add(titleBOM.ID);
                    maptitleIDListTBOMID.put(title.ID,TBOMIds); 
                }
            }
        }
        
        Set<string> setGroupsAndchannel = new Set<string>{'India_EST','India_VODI','USA_EST','USA_VODI'};
        Rights__c  objRights = new Rights__c();
            WB_Batch_VBOMRightsRequestWizard vBOMRightsRequestBatch = new WB_Batch_VBOMRightsRequestWizard(lstSelectedTitle,mapMPMrecords,maptitleIDandMPM,maptitleIDListTBOMID,mapTBOMIDandMPM,setGroupsAndchannel,objRights);

        Test.startTest();
            Database.executeBatch(vBOMRightsRequestBatch,10);   
           
        Test.stopTest();
    }
    
    
}