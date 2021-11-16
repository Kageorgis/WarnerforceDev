@isTest
public class WB_Request_Refresh_Title_Controller_Test {
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
        
        List<Title_BOM__c> TitleBOMList = new List<Title_BOM__c>();
        titleBOM = new Title_BOM__c();
        titleBOM.Title__c = titleRec.id;
        titleBOM.MPM__c = mpm.Id;
        titleBOM.BOM_Type__c = 'VBOM';
        TitleBOMList.add(titleBOM);
        titleBOM2 = new Title_BOM__c();
        titleBOM2.Title__c = titleRec2.id;
        titleBOM2.MPM__c = mpm2.Id;
        titleBOM2.BOM_Type__c = 'VBOM';
         TitleBOMList.add(titleBOM2);
        titleBOM3 = new Title_BOM__c();
        titleBOM3.Title__c = titleRec3.id;
        titleBOM3.MPM__c = mpm3.Id;
        titleBOM3.BOM_Type__c = 'VBOM';
         TitleBOMList.add(titleBOM3);
         insert TitleBOMList;
        
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
    
    static testmethod void WB_Request_Refresh_Title_Test1_Positive(){
        
               
        creatTestData();
        Request_Rights_error_log__c RightsError = new Request_Rights_error_log__c(Channel__c='HD',Name='Test');
        insert RightsError;
        
        WB_Request_Refresh_Title_Controller.titleMPMWrapper titleMPMWrap1 = new WB_Request_Refresh_Title_Controller.titleMPMWrapper(titleBOM);
        titleMPMWrap1.FilmColor=titleBOM.MPM__r.Film_Color__c;
        titleMPMWrap1.Name=titleBOM.MPM__r.Name;
        titleMPMWrap1.ProductionYear=titleBOM.MPM__r.Production_Year__c; 
        titleMPMWrap1.VideoVersion=titleBOM.Title__r.Video_Version__c;
        titleMPMWrap1.VideoVersionId=titleBOM.Title__r.id;
        titleMPMWrap1.description=titleBOM.MPM__r.MPM_Short_Desc__c;
        titleMPMWrap1.generic=titleBOM.MPM__r.Generic__c; 
        titleMPMWrap1.isLink=true;
        titleMPMWrap1.recordTypeName='MPM'; 
        titleMPMWrap1.status=titleBOM.MPM__r.Status__c ;
        titleMPMWrap1.vvmpmID=titleBOM.MPM__r.ID;
        
        WB_Request_Refresh_Title_Controller.titleMPMWrapper titleMPMWrap2 = new WB_Request_Refresh_Title_Controller.titleMPMWrapper(titleRec);
        titleMPMWrap2.FilmColor=titleRec.Film_Color_formula__c;
        titleMPMWrap2.Name=titleRec.Video_Version__c;
        titleMPMWrap2.ProductionYear=titleRec.Production_Year_formula__c;
        titleMPMWrap2.VideoVersion=titleRec.Video_Version__c;
        titleMPMWrap2.VideoVersionId=titleRec.id;
        titleMPMWrap2.description=titleRec.Name;
        titleMPMWrap2.generic=titleRec.MPM__r.Generic__c;
        titleMPMWrap2.isLink=false;
        titleMPMWrap2.recordTypeName='VBOM';
        titleMPMWrap2.status=titleRec.Status__c;
        titleMPMWrap2.vvmpmID= titleRec.Id;
        
    
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

        Test.startTest();
        Test.setCurrentPageReference(Page.WB_Request_Refresh_Title);
        ApexPages.currentPage().getParameters().put('ID',titleRec.id);
        
         WB_Request_Refresh_Title_Controller obj_WB_Request_Refresh_Title = new WB_Request_Refresh_Title_Controller();
        obj_WB_Request_Refresh_Title.selectedRightsGroup.add(new SelectOption('USA','USA'));
        obj_WB_Request_Refresh_Title.selectedRightsGroup.add(new SelectOption('INDIA','India'));
        obj_WB_Request_Refresh_Title.selectedRightsChannel.add(new SelectOption('EST','EST'));
        obj_WB_Request_Refresh_Title.selectedRightsChannel.add(new SelectOption('VODI','VODI'));
        obj_WB_Request_Refresh_Title.isAllChannelSelected = false;
        obj_WB_Request_Refresh_Title.isAllRightsGroupSelected = false;
       
        obj_WB_Request_Refresh_Title.RequestRefresh();
        //obj_WB_Request_Refresh_Title.selectAllRightsGroup();
        //obj_WB_Request_Refresh_Title.selectAllChannel();
        list<Rights__c> testLstRights = obj_WB_Request_Refresh_Title.batchIdGeneration(rightsList);
        Schema.sObjectType expectedObjType = Schema.Rights__c.getSObjectType();
        System.assertEquals(expectedObjType, testLstRights[0].getSobjectType());
        //obj_WB_Request_Refresh_Title.selectedRightsChannel.add(new SelectOption('All','All')); 
         Test.stopTest();
    }
    static testmethod void WB_Request_Refresh_Title_Test2_GenericMPM(){
        
               
        creatTestData();
        Request_Rights_error_log__c RightsError = new Request_Rights_error_log__c(Channel__c='HD',Name='Test');
        insert RightsError;
        WB_Request_Refresh_Title_Controller.titleMPMWrapper titleMPMWrap3 = new WB_Request_Refresh_Title_Controller.titleMPMWrapper(titleBOM2);
        titleMPMWrap3.FilmColor=titleBOM2.MPM__r.Film_Color__c;
        titleMPMWrap3.Name=titleBOM2.MPM__r.Name;
        titleMPMWrap3.ProductionYear=titleBOM2.MPM__r.Production_Year__c; 
        titleMPMWrap3.VideoVersion=titleBOM2.Title__r.Video_Version__c;
        titleMPMWrap3.VideoVersionId=titleBOM2.Title__r.id;
        titleMPMWrap3.description=titleBOM2.MPM__r.MPM_Short_Desc__c;
        titleMPMWrap3.generic=titleBOM2.MPM__r.Generic__c; 
        titleMPMWrap3.isLink=true;
        titleMPMWrap3.recordTypeName='MPM'; 
        titleMPMWrap3.status=titleBOM2.MPM__r.Status__c ;
        titleMPMWrap3.vvmpmID=titleBOM2.MPM__r.ID;
        
        
        WB_Request_Refresh_Title_Controller.titleMPMWrapper titleMPMWrap4 = new WB_Request_Refresh_Title_Controller.titleMPMWrapper(titleRec2);
        titleMPMWrap4.FilmColor=titleRec2.Film_Color_formula__c;
        titleMPMWrap4.Name=titleRec2.Video_Version__c;
        titleMPMWrap4.ProductionYear=titleRec2.Production_Year_formula__c;
        titleMPMWrap4.VideoVersion=titleRec2.Video_Version__c;
        titleMPMWrap4.VideoVersionId=titleRec2.id;
        titleMPMWrap4.description=titleRec2.Name;
        titleMPMWrap4.generic=titleRec2.MPM__r.Generic__c;
        titleMPMWrap4.isLink=false;
        titleMPMWrap4.recordTypeName='VBOM';
        titleMPMWrap4.status=titleRec2.Status__c;
        titleMPMWrap4.vvmpmID= titleRec2.Id;

        Test.startTest();
        Test.setCurrentPageReference(Page.WB_Request_Refresh_Title);
        //ApexPages.currentPage().getParameters().put('ID',titleRec.id+','+titleRec2.id);
        ApexPages.currentPage().getParameters().put('ID',titleRec2.id);
        
        WB_Request_Refresh_Title_Controller obj_WB_Request_Refresh_Title = new WB_Request_Refresh_Title_Controller();
        obj_WB_Request_Refresh_Title.selectedRightsChannel.add(new SelectOption('All','All')); 
        obj_WB_Request_Refresh_Title.selectedRightsGroup.add(new SelectOption('All','All')); 
        obj_WB_Request_Refresh_Title.allChannels.add(new SelectOption('All','All'));
        obj_WB_Request_Refresh_Title.isAllRightsGroupSelected = true;
        obj_WB_Request_Refresh_Title.isAllChannelSelected = true;
        obj_WB_Request_Refresh_Title.RequestRefresh();
        obj_WB_Request_Refresh_Title.selectAllRightsGroup();
        obj_WB_Request_Refresh_Title.selectAllChannel();
        obj_WB_Request_Refresh_Title.batchIdGeneration(rightsList);
        

        Test.stopTest();
    }
    
    static testmethod void WB_Request_Refresh_Title_Test3_MPMStartsWithOne(){
        
               
        creatTestData();
        WB_Request_Refresh_Title_Controller.titleMPMWrapper titleMPMWrap5 = new WB_Request_Refresh_Title_Controller.titleMPMWrapper(titleRec3);
        titleMPMWrap5.FilmColor=titleRec3.Film_Color_formula__c;
        titleMPMWrap5.Name=titleRec3.Video_Version__c;
        titleMPMWrap5.ProductionYear=titleRec3.Production_Year_formula__c;
        titleMPMWrap5.VideoVersion=titleRec3.Video_Version__c;
        titleMPMWrap5.VideoVersionId=titleRec3.id;
        titleMPMWrap5.description=titleRec3.Name;
        titleMPMWrap5.generic=titleRec3.MPM__r.Generic__c;
        titleMPMWrap5.isLink=false;
        titleMPMWrap5.recordTypeName='VBOM';
        titleMPMWrap5.status=titleRec3.Status__c;
        titleMPMWrap5.vvmpmID= titleRec3.Id;
        

        Test.startTest();
        Test.setCurrentPageReference(Page.WB_Request_Refresh_Title);
        ApexPages.currentPage().getParameters().put('ID',titleRec3.id);
        
        WB_Request_Refresh_Title_Controller obj_WB_Request_Refresh_Title = new WB_Request_Refresh_Title_Controller();
        obj_WB_Request_Refresh_Title.selectedRightsChannel.add(new SelectOption('All','All')); 
        obj_WB_Request_Refresh_Title.selectedRightsGroup.add(new SelectOption('All','All')); 
        obj_WB_Request_Refresh_Title.allChannels.add(new SelectOption('All','All'));
        obj_WB_Request_Refresh_Title.isAllRightsGroupSelected = true;
        obj_WB_Request_Refresh_Title.isAllChannelSelected = true;
        obj_WB_Request_Refresh_Title.RequestRefresh();
        obj_WB_Request_Refresh_Title.selectAllRightsGroup();
        obj_WB_Request_Refresh_Title.selectAllChannel();
        obj_WB_Request_Refresh_Title.batchIdGeneration(rightsList);
        

        Test.stopTest();
    }
    static testmethod void WB_Request_Refresh_Title_Test4_Title_With_NoVBOM(){
        
               
        creatTestData();
        WB_Request_Refresh_Title_Controller.titleMPMWrapper titleMPMWrap5 = new WB_Request_Refresh_Title_Controller.titleMPMWrapper(titleRec4);
        titleMPMWrap5.FilmColor=titleRec4.Film_Color_formula__c;
        titleMPMWrap5.Name=titleRec4.Video_Version__c;
        titleMPMWrap5.ProductionYear=titleRec4.Production_Year_formula__c;
        titleMPMWrap5.VideoVersion=titleRec4.Video_Version__c;
        titleMPMWrap5.VideoVersionId=titleRec4.id;
        titleMPMWrap5.description=titleRec4.Name;
        titleMPMWrap5.generic=titleRec4.MPM__r.Generic__c;
        titleMPMWrap5.isLink=false;
        titleMPMWrap5.recordTypeName='VBOM';
        titleMPMWrap5.status=titleRec4.Status__c;
        titleMPMWrap5.vvmpmID= titleRec4.Id;
        

        Test.startTest();
        Test.setCurrentPageReference(Page.WB_Request_Refresh_Title);
        ApexPages.currentPage().getParameters().put('ID',titleRec4.id);
        
        WB_Request_Refresh_Title_Controller obj_WB_Request_Refresh_Title = new WB_Request_Refresh_Title_Controller();
        obj_WB_Request_Refresh_Title.selectedRightsChannel.add(new SelectOption('All','All')); 
        obj_WB_Request_Refresh_Title.selectedRightsGroup.add(new SelectOption('All','All')); 
        obj_WB_Request_Refresh_Title.allChannels.add(new SelectOption('All','All'));
        obj_WB_Request_Refresh_Title.isAllRightsGroupSelected = true;
        obj_WB_Request_Refresh_Title.isAllChannelSelected = true;
        PageReference pgTest= obj_WB_Request_Refresh_Title.RequestRefresh();
       // Schema.sObjectType expectedObjType = Schema.PageReference.getSObjectType();
       // System.assertEquals(expectedObjType, pgTest.getSobjectType());
        System.assertEquals('/apex/WB_RequestRights_Redirect',pgTest.getUrl());
        Test.stopTest();
    }
}