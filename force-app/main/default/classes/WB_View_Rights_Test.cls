/***************
WB_View_Rights_Test
Creation Date- 23 Dec 2014
Last Modified Date - 
Last Modified by  -
Description- This class is to do code coverage WB_View_Rights
Author- Imran Hussain

Modified by and Date- Preeti Jha on 21st Nov 2016
Description - Added required field for Rights record.
*******/

@isTest 
private class WB_View_Rights_Test{
    
    static testMethod void displayRights() { 
        
        list<Title__c> titleList = new list<Title__c>();
        MPM__c mpm = new MPM__c(name='testMPM',MPM_Number__c='111119');
        insert mpm;
        
        Title__c title1 = new Title__c(Name = 'TestGoogle1',Video_Version__c ='1233211',Content_Type__c='Feature',
                                       Digital_Planning__c='YES',MPM__c = mpm.Id,Formats__c='SD');
        insert title1;
        
        Title__c title2 = new Title__c(Name = 'TestGoogle2',Video_Version__c ='33214553',Content_Type__c='Feature',
                                       Digital_Planning__c='YES',MPM__c = mpm.Id,Formats__c='SD');
        
        insert title2;
        
        titleList.add(title1);
        titleList.add(title2);    
        
        Rights__c right = new Rights__c(MPM__c=mpm.Id,Channel__c = 'EST',Rights_Start__c=date.today(),
                                        Rights_End__c=date.today()+7,Status__c='Confirmed', Source__c='Cosmos', Rights_Group__c = 'USA');
        insert right;        
        
        Test.startTest(); 
        PageReference pageRef = Page.WB_ViewRights_On_Title;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', title1.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(titleList);
        WB_View_Rights controller = new WB_View_Rights(sc);
        controller.exportToExcel();
        controller.viewAllRightsRecords();
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

        PageReference pageRef = Page.WB_ViewRights_On_Title;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', title3.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(titleList);
        WB_View_Rights controller = new WB_View_Rights(sc);
        controller.exportToExcel();
        controller.RequestRefresh();
        
        ApexPages.currentPage().getParameters().put('id', title4.Id);
        ApexPages.StandardSetController scr = new ApexPages.StandardSetController(titleList);
        WB_View_Rights controller2 = new WB_View_Rights(scr);
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
        
        PageReference pageRef = Page.WB_ViewRights_On_Title;
        Test.setCurrentPage(pageRef);
       
        ApexPages.currentPage().getParameters().put('id', title4.Id);
        ApexPages.StandardSetController scr = new ApexPages.StandardSetController(titleList);
        WB_View_Rights controller2 = new WB_View_Rights(scr);
        controller2.RequestRefresh();
        Test.stopTest();        
    }
    
    static testMethod void customBtn_ViewRights() { 
        
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
        PageReference pageRef = Page.WB_ViewRights_On_Title;
        Test.setCurrentPage(pageRef);
       
        ApexPages.currentPage().getParameters().put('id', title4.Id);
        ApexPages.StandardController scr = new ApexPages.StandardController(title4);
        WB_View_Rights controller2 = new WB_View_Rights(scr);
        controller2.RequestRefresh();
        controller2.forwardToListController();
        Test.stopTest();        
    }
    
    static testMethod void customBtn_ViewRights_NagativeTest() { 
        
        Batch_Ids_Customsetting__c customSetting = new Batch_Ids_Customsetting__c(Name='Test',Rights_Batch_Id__c='1');
        insert customSetting;
        list<Title__c> titleList = new list<Title__c>();
        MPM__c mpm = new MPM__c(name='testMPM',MPM_Number__c='211119');
        insert mpm;
        MPM__c mpm2 = new MPM__c(name='testMPM',MPM_Number__c='11133333',Generic__c = false);
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

        PageReference pageRef = Page.WB_ViewRights_On_Title;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', title3.Id);
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(titleList);
        WB_View_Rights controller = new WB_View_Rights(sc);
        controller.exportToExcel();
        controller.RequestRefresh();
        
        ApexPages.currentPage().getParameters().put('id', title4.Id);
        ApexPages.StandardSetController scr = new ApexPages.StandardSetController(titleList);
        WB_View_Rights controller2 = new WB_View_Rights(scr);
        controller2.RequestRefresh();
        Test.stopTest();        
    }
}