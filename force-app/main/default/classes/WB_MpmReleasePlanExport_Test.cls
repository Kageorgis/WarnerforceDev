@isTest 
private class WB_MpmReleasePlanExport_Test{
    
    static testMethod void displayRights() { 
        
        list<Title__c> titleList = new list<Title__c>();
        MPM__c mpm = new MPM__c(name='testMPM',MPM_Number__c='111119');
        insert mpm;
        MPM__c mpm2 = new MPM__c(name='testMPM2',MPM_Number__c='111129');
        insert mpm2;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle1',Video_Version__c ='1233211',Content_Type__c='Feature',
        Digital_Planning__c='YES',MPM__c = mpm.Id,Formats__c='SD');
        insert title1;
        
        Title__c title2 = new Title__c(Name = 'TestGoogle2',Video_Version__c ='33214553',Content_Type__c='Feature',
        Digital_Planning__c='YES',MPM__c = mpm2.Id,Formats__c='SD');
        
        insert title2;
        
        titleList.add(title1);
        titleList.add(title2);    
            
        Rights__c right = new Rights__c(MPM__c=mpm.Id,Channel__c = 'EST',Rights_Start__c=date.today(),
                                        Rights_End__c=date.today()+7,Status__c='Confirmed', Source__c = 'Cosmos',Rights_Group__c = 'USA');
        insert right;
        
        string Ids = title1.Id+','+title2.Id;
        
         Test.startTest(); 
      
        PageReference pageRef = Page.WB_MpmReleasePlanExportPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', Ids);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(titleList);
        WB_MpmReleasePlanExport controller = new WB_MpmReleasePlanExport(sc);
        controller.exportToExcel();
        controller.getDisableExcel();
        Test.stopTest();

    }
     static testMethod void displayRights1() { 
        Batch_Ids_Customsetting__c customSetting = new Batch_Ids_Customsetting__c(Name='Test',Rights_Batch_Id__c='1');
        insert customSetting;
        list<Title__c> titleList = new list<Title__c>();
        MPM__c mpm = new MPM__c(name='testMPM',MPM_Number__c='211119');
        insert mpm;
        MPM__c mpm2 = new MPM__c(name='testMPM',MPM_Number__c='11133333',Generic__c = true);
        insert mpm2;
        
        Request_Rights_error_log__c RightsError = new Request_Rights_error_log__c(Channel__c='EST',Name='Test');
        insert RightsError;
        
        Title__c title3 = new Title__c(Name = 'TestGoogle1',Video_Version__c ='1233211',Content_Type__c='Feature',
                                       Digital_Planning__c='YES',Formats__c='SD' ,MPM__c = mpm.Id);
        insert title3;
        
        Title__c title4 = new Title__c(Name = 'TestGoogle2',Video_Version__c ='33214553',Content_Type__c='Feature',
                                       Digital_Planning__c='YES',Formats__c='SD',MPM__c = mpm2.Id);
        
        insert title4;
        
        titleList.add(title3);
        titleList.add(title4);    
        
        Rights__c right = new Rights__c(MPM__c=mpm.Id,Channel__c = 'EST',Rights_Start__c= date.today(),
                                        Rights_End__c=date.today()+7,Status__c='Confirmed', Source__c='Cosmos', Rights_Group__c = 'USA');
        insert right;   
        
         Rights__c right2 = new Rights__c(MPM__c=mpm2.Id,Channel__c = 'VOdi',Rights_Start__c= date.today(),
                                        Rights_End__c=date.today()+7,Status__c='Confirmed', Source__c='Cosmos', Rights_Group__c = 'USA');
        
        insert right2;   
        Test.startTest(); 
        
        PageReference pageRef = Page.WB_MpmReleasePlanExportPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', title3.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(titleList);
        WB_MpmReleasePlanExport controller = new WB_MpmReleasePlanExport(sc);
        controller.exportToExcel();
        controller.RequestRefresh();
        
        ApexPages.currentPage().getParameters().put('id', title4.Id);
        ApexPages.StandardSetController scr = new ApexPages.StandardSetController(titleList);
        WB_MpmReleasePlanExport controller2 = new WB_MpmReleasePlanExport(scr);
        controller2.RequestRefresh();
        Test.stopTest();        
    }
    static testMethod void RequestRefresh() { 
        
        Batch_Ids_Customsetting__c customSetting = new Batch_Ids_Customsetting__c(Name='Test',Rights_Batch_Id__c='1');
         insert customSetting;
         
        list<Title__c> titleList = new list<Title__c>();
        MPM__c mpm2 = new MPM__c(name='testMPM',MPM_Number__c='21133333',Generic__c = true);
        insert mpm2;
        
        Request_Rights_error_log__c RightsError = new Request_Rights_error_log__c(Channel__c='EST',Name='Test');
        insert RightsError;
        
        Title__c title4 = new Title__c(Name = 'TestGoogle2',Video_Version__c ='33214553',Content_Type__c='Feature',
                                       Digital_Planning__c='YES',Formats__c='SD',MPM__c = mpm2.Id);
        
        insert title4;
        
        titleList.add(title4);    
        
        Rights__c right = new Rights__c(MPM__c=mpm2.Id,Channel__c = 'EST',Rights_Start__c= date.today(),
                                        Rights_End__c=date.today()+7,Status__c='Confirmed', Source__c='Cosmos', Rights_Group__c = 'USA');
        insert right;        
        
        Test.startTest(); 
        
        PageReference pageRef = Page.WB_MpmReleasePlanExportPage;
        Test.setCurrentPage(pageRef);
       
        ApexPages.currentPage().getParameters().put('id', title4.Id);
        ApexPages.StandardSetController scr = new ApexPages.StandardSetController(titleList);
        WB_MpmReleasePlanExport controller2 = new WB_MpmReleasePlanExport(scr);
        controller2.RequestRefresh();
        Test.stopTest();        
    }

    static testMethod void RequestRefresh1() { 
        
        Batch_Ids_Customsetting__c customSetting = new Batch_Ids_Customsetting__c(Name='Test',Rights_Batch_Id__c='1');
         insert customSetting;
         
        list<Title__c> titleList = new list<Title__c>();
        MPM__c mpm2 = new MPM__c(name='testMPM',MPM_Number__c='31133333',Generic__c = true);
        insert mpm2;
        
        Request_Rights_error_log__c RightsError = new Request_Rights_error_log__c(Channel__c='Hotel',Name='Test');
        insert RightsError;
        
        Title__c title4 = new Title__c(Name = 'TestGoogle2',Video_Version__c ='23214553',Content_Type__c='Feature',
                                       Digital_Planning__c='YES',Formats__c='SD',MPM__c = mpm2.Id);
        
        insert title4;
        
        titleList.add(title4);    
        
        Rights__c right = new Rights__c(MPM__c=mpm2.Id,Channel__c = 'Hotel',Rights_Start__c= date.today(),
                                        Rights_End__c=date.today()+7,Status__c='Confirmed', Source__c='Cosmos', Rights_Group__c = 'USA');
        insert right;    
        
        List<Rights__c> rightsList = [SELECT id,name,Channel__c,MPM__c,MPM__r.Generic__c,MPM__r.MPM_Number__c,MPM_Short_Description__c,Notes__c,
        Rights_End__c,Rights_Start__c,Rights_Start_2__c,Rights_Start_3__c,Rights_Start_4__c,Rights_Start_5__c,Rights_End_2__c,
        Rights_End_3__c,Rights_End_4__c,Rights_End_5__c,Rights_Group__c,Status__c,Request_Refresh__c,Date_Last_Changed__c,
        MPM__r.Name,RT_Lifecycle__c,RecordType.Name,Title_MPM_Description__c,VV_MPM__c
        FROM Rights__c];
        
        Test.startTest(); 
        
        PageReference pageRef = Page.WB_MpmReleasePlanExportPage;
        Test.setCurrentPage(pageRef);
       
        ApexPages.currentPage().getParameters().put('id', title4.Id);
        ApexPages.StandardSetController scr = new ApexPages.StandardSetController(titleList);
        WB_MpmReleasePlanExport controller2 = new WB_MpmReleasePlanExport(scr);
        controller2.rightsList = rightsList;
        controller2.RequestRefresh();
        Test.stopTest();        
    }
}