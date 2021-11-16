@istest
public class WB_Batch_RightsRequestWizard_Test {
    static testmethod void TestRequestRefresh() {
        
        Request_Rights_error_log__c RightsError = new Request_Rights_error_log__c(Channel__c='EST',Name='Test');
        insert RightsError;
        
        Batch_Ids_Customsetting__c customSetting = new Batch_Ids_Customsetting__c(Name='Test',Rights_Batch_Id__c='1');
        insert customSetting;
        
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        MPM__c mpm2 = new MPM__c(name='1234',MPM_Number__c='2234');
        insert mpm2;
        MPM__c mpm3 = new MPM__c(name='123455',MPM_Number__c='123455',Generic__c= true);
        insert mpm3;
        ApexPages.currentPage().getParameters().put('ID', mpm.Id+','+mpm2.Id+','+mpm3.Id);
        
        list<string> lstSelectedMPMIds = new list<String>();
        string MPMIds = ApexPages.currentPage().getParameters().get('ID');
        if(!string.isBlank(MPMIds)){
            lstSelectedMPMIds = MPMIds.split(','); 
        }
        
        set<string> setGroupsAndchannel = new set<string>();
        setGroupsAndchannel.add('India_EST');
        setGroupsAndchannel.add('USA_EST');
        
         Rights__c objRights = new Rights__c();
        
         Rights__c rights = new Rights__c(Channel__c = 'EST',MPM__c = mpm.id,Rights_End__c=system.today()+3, Rights_Group__c = 'USA',Rights_Start__c= system.today(),Status__c='Confirmed',Source__c = 'cosmos');
        insert rights;
         Rights__c rights1 = new Rights__c(Channel__c = 'VODI',MPM__c = mpm2.id,Rights_End__c=system.today()+3, Rights_Group__c = 'USA',Rights_Start__c= system.today(),Status__c='Confirmed',Source__c = 'cosmos');
        insert rights1;
        
        WB_Batch_RightsRequestWizard objRequestRefresh = new WB_Batch_RightsRequestWizard(lstSelectedMPMIds, setGroupsAndchannel, objRights);             
        objRequestRefresh.queryString = 'Select Id,Name,MPM_Short_Desc__c,Abstract_EIDR__c,Status__c,Generic__c from MPM__c where Id IN:lstSelectMPM';
        objRequestRefresh.batchIdGeneration(new List<Rights__c>());
        
        Test.startTest();
            Database.executeBatch(objRequestRefresh, 200);
        Test.stopTest();
    }
}