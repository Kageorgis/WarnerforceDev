@isTest
public class WB_ViewLanguageComCtrl_Test {
     
    static testMethod void getVideoVersionFromTitleId(){
        MPM__c mpm = new MPM__c(name='MPM record',MPM_Number__c='0123');
        insert mpm;
        
        Title__c titleRec = new Title__c(Name = 'Coll1',MPM__c = mpm.id,Video_Version__c ='1243355670',Content_Type__c=Label.Collection_Features,Digital_Planning__c='Yes',Clear_to_Avail__c = true, Formats__c = 'HD');
        insert titleRec;
        
        String vv = WB_ViewLanguageComCtrl.getVideoVersion(titleRec.Id);
        system.assertEquals(vv,titleRec.Video_Version__c);
    }
}