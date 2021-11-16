/******* 
WB_RedirectContactAssignment
Creation Date- 16 Mar 2015
Description- This class is to Redirect the page from EC Tracker to Contact Assignment New Record and to avoid the Hardcoding Values
Author- Harika Bondalapati
*******/
public class WB_RedirectContactAssignment{
    public final EC_Tracker__c ectracker;
    public List<EC_Tracker__c> trackerList= new List<EC_Tracker__c>();
    public String ECtrackerName;
    public String ECTrackerid;
    public String AccountName;
    public String Accntid;
    List<Custom_Entered_Values__c> customSettingValues = new List<Custom_Entered_Values__c>();
    public String IdThreeDigit;
    public String trackerLookupID;
    public String AccountFieldId;

    public WB_RedirectContactAssignment(ApexPages.StandardController stdController) {
        this.ectracker = (EC_Tracker__c)stdController.getRecord();
    }
    
    public pageReference redirect(){
       ECTrackerid = ectracker.Id;
       trackerList = [select Name from EC_Tracker__c where Id=:ECTrackerid limit 1];
       for(EC_Tracker__c ect:trackerList){
           ECtrackerName = ect.Name;
       }
    
       Map<String,Schema.SobjectType> globalDescribe = Schema.getGlobalDescribe();
       IdThreeDigit = globalDescribe.get('Contact_Assignment__c').getDescribe().getkeyprefix();
    
       //Custom settings
       customSettingValues = Custom_Entered_Values__c.getAll().Values();
       system.debug('customSettingValues--->>>'+customSettingValues);
       for(Custom_Entered_Values__c cstom:customSettingValues){
           if(cstom.Name == 'ECTrackerLookupId' && (trackerLookupID == null || trackerLookupID == '')){
               trackerLookupID = cstom.User_Entered_Value__c;
           }
           if(cstom.Name == 'AccountFieldId' && (AccountFieldId == null || AccountFieldId == '')){
              AccountFieldId = cstom.User_Entered_Value__c;
           } 
           if(cstom.Name == 'AccountNamePrepopulate' && (Accntid == null || Accntid == '')){
              Accntid  = cstom.User_Entered_Value__c;
              List<Account> acctList = [select Id,Name,EC_Digital_Account__c from Account where EC_Digital_Account__c = 'Internal' AND Id =:Accntid];
              for(Account acnt:acctList){
                  AccountName = acnt.Name;
              } 
           } 
        }
        system.debug('trackerLookupID---------->>>'+trackerLookupID);
        system.debug('AccountFieldId---------->>>'+AccountFieldId);
        system.debug('Accntid---------->>>'+Accntid);
        system.debug('AccountName---------->>>'+AccountName);
        PageReference Save1= new PageReference('/' + IdThreeDigit + '/e?CF' + trackerLookupID + '=' + ECtrackerName + '&CF' + trackerLookupID + '_lkid=' + ECTrackerid + '&retURL=%2F' + ECTrackerid + '&CF' + AccountFieldId + '=' + AccountName + '&CF' + AccountFieldId + '_lkid=' + Accntid + '&saveURL=%2F' +ECTrackerid);
        system.debug('save1---------->>>'+Save1);
        Save1.setRedirect(true);
       return Save1;
    }
}