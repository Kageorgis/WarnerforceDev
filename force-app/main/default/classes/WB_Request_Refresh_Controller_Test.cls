@istest
public class WB_Request_Refresh_Controller_Test {
    static testmethod void TestRequestRefresh() {
        
        Request_Rights_error_log__c RightsError = new Request_Rights_error_log__c(Channel__c='EST',Name='Test');
        insert RightsError;
        
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        MPM__c mpm2 = new MPM__c(name='1234',MPM_Number__c='2234');
        insert mpm2;
        MPM__c mpm3 = new MPM__c(name='123455',MPM_Number__c='223455',Generic__c= true);
        insert mpm3;
        ApexPages.currentPage().getParameters().put('ID', mpm.Id+','+mpm2.Id+','+mpm3.Id);
        
         Rights__c rights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id,Rights_End__c=system.today()+3, Rights_Group__c = 'USA',Rights_Start__c= system.today(),Status__c='Confirmed',Source__c = 'cosmos');
        insert rights;
         Rights__c rights1 = new Rights__c(Channel__c = 'VODI',MPM__c = mpm2.id,Rights_End__c=system.today()+3, Rights_Group__c = 'USA',Rights_Start__c= system.today(),Status__c='Confirmed',Source__c = 'cosmos');
        insert rights1;
        
        WB_Request_Refresh_Controller objRequestRefresh = new WB_Request_Refresh_Controller();
        objRequestRefresh.selectedRightsGroup.add(new SelectOption('USA','USA'));
        objRequestRefresh.selectedRightsGroup.add(new SelectOption('INDIA','India'));
        objRequestRefresh.selectedRightsChannel.add(new SelectOption('EST','EST'));
        objRequestRefresh.selectedRightsChannel.add(new SelectOption('VODI','VODI'));
        objRequestRefresh.selectedRightsChannel.add(new SelectOption('All','All'));        
        
        country__c con= new country__c(Name='USA',Country_Code__c='Tes', Country_Code2__c='te',Channel__c='DTD;EST');
        insert con;
        country__c con2= new country__c(Name='India',Country_Code__c='Ind', Country_Code2__c='In',Channel__c='VODI;EST');
        insert con2;
        
        Language__c Language = new Language__c (Name='English', Language_Order__c = 1);
        insert Language;
        Language__c Language1 = new Language__c (Name='Hindi', Language_Order__c = 1);
        insert Language1;
        
        Rights_Group__c rightGroup = new Rights_Group__c(Name = 'USA',Country__c=con.id,Language__c=Language.id,Rights_Group__c='USA', Rights_Locale__c = True);
        insert rightGroup;
        
        Rights_Group__c RightGroup2 = new Rights_Group__c(Name = 'India',Country__c=con2.id,Language__c=Language1.id,Rights_Group__c = 'India', Rights_Locale__c = True);
        insert RightGroup2;
        
        Rights_Group__c RightGroup3 = new Rights_Group__c(Name = 'USAA',Country__c=con.id,Language__c=Language1.id,Rights_Group__c = 'USA', Rights_Locale__c = True);
        insert RightGroup3;
        
        objRequestRefresh.RequestRefresh();
        objRequestRefresh.selectAllRightsGroup();
        objRequestRefresh.selectAllChannel();
    }
}