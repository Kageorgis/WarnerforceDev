/******* 
WB_MPMSearchController 
Creation Date- 19 Nov 2014
Description- This class is to search MPM based on MPM Number or Short Description
Author- Harika Bondalapati
*******/
public with sharing class WB_MPMSearchController {

  // the soql without the order and limit
  public String soql {get;set;}
  private boolean showbutton {get;set;}
  public String selectedtype{get;set;}
  // the collection of contacts to display
  public List<cMPM> cMPMs {get;set;}
  public List<cMPM> cMPMs2 = new List<cMPM>();
  List<Custom_Entered_Values__c> customSettingValues = new List<Custom_Entered_Values__c>();
  public List<MPM__c> mpms {get;set;}
  public String ids {get;set;}
  public String newid {get;set;}
  public Integer Count;
  public String mpm;
  public String SDescription;
  
   public static String selectedtype1 {get;set;} // 
   
   // init the controller and display some sample data when the page loads
    public WB_MPMSearchController() {
        Schema.DescribeFieldResult dfr = Schema.sObjectType.EC_Tracker__c.fields.MPM__c;
   
        soql = 'select id, Name, MPM_Short_Desc__c, MPM_Number__c from MPM__c where Name!= null';
        runQuery();
    }
    
    //create EC Tracker button
    public PageReference createECT() {
        String RecordTypeIds;
        List<RecordType> trackerRecordtype = [SELECT DeveloperName,Id,IsActive,Name,SobjectType FROM RecordType where IsActive = true and SobjectType = 'EC_Tracker__c' and DeveloperName =:selectedtype];
        for(RecordType rt:trackerRecordtype){
            RecordTypeIds = rt.Id;
        }
        Count = 0;
        if (cMPMs!=null) {
            for (cMPM cm: cMPMs) {
                 if (cm.selected) {
                     count = count + 1;
                     showbutton=true;
                     newid = cm.mpm.id;
                     ids=ids+newid+',';
                 }
            }
        }
        String IdName = CollectNameFromMPMID(newid);
        String MPMLookupID;
        Map<String,Schema.SobjectType> globalDescribe = Schema.getGlobalDescribe();
        String IdThreeDigit = globalDescribe.get('EC_Tracker__c').getDescribe().getkeyprefix();
       
        //Custom settings
        customSettingValues = Custom_Entered_Values__c.getAll().Values();
        for(Custom_Entered_Values__c cstom:customSettingValues){
            if(cstom.Name == 'MPMLookup'){
               MPMLookupID = cstom.User_Entered_Value__c;
            }
        }
        if (count == 1) {
            PageReference ref = new PageReference('/' + IdThreeDigit + '/e?CF' + MPMLookupID + '=' + IdName + '&CF' + MPMLookupID + '_lkid=' + newid + '&&RecordType=' + RecordTypeIds + '&&retURL=apex/WB_MPMSearch');
            return ref;
        }else if(count>1){
            showbutton=false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please pick only one MPM to create a EC Tracker');
            ApexPages.addMessage(myMsg);
            return null;   
        } else return null;   
    }

    //Collecting MPM Name from MPM ID
    public String CollectNameFromMPMID(Id newid){
        String NameValue;
        List<MPM__c> mpmslist = [select Name from MPM__c where Id=:newid];
        if(mpmslist.size()>0){
           for(MPM__c m2:mpmslist){
               NameValue = m2.Name;
           }
        }    
        return NameValue;
    }
    
    //wrapper class to handle the select
    public class cMPM {
        public MPM__c mpm {get; set;}
        public Boolean selected {get; set;}    
        public cMPM(MPM__c m) {
                mpm = m;
                this.selected = false;
        }
     } 

    public boolean getShowbutton() {
         return showbutton;
    }

    // the current sort direction. defaults to asc
    public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
        set;
    }

    // the current field to sort by. defaults to last name
    public String sortField {
        get  { if (sortField == null) {sortField = 'MPM_Short_Desc__c'; } return sortField;  }
        set;
    }

    // format the soql for display on the visualforce page
    public String debugSoql {
        get { return soql + ' order by ' + sortField + ' ' + sortDir + ' limit 100'; }
        set;
    }

   

    // toggles the sorting of query from asc<-->desc
    public void toggleSort() {
        // simply toggle the direction
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        // run the query again
        runQuery();
    }

    // runs the actual query
    public void runQuery() {

        ids='';
        cMPMs = new List<cMPM>();
        cMPMs2 = new List<cMPM>();
        showbutton=false;
        String msdesc;
        if(SDescription != null || SDescription != ''){
           sortField  = 'MPM_Short_Desc__c';
        }
        mpms = Database.query(soql + ' order by ' + sortField + ' ' + sortDir + ' limit 100');
        for(MPM__c m: mpms){
            msdesc = m.MPM_Short_Desc__c;
            Boolean strexists = false;
            if((msdesc != null || msdesc != '') && (SDescription != null && SDescription != '')){
                strexists = msdesc.startsWithIgnoreCase(SDescription);
            }  
            if(SDescription != null || SDescription != ''){ 
               if(strexists == true){
                  cMPMs.add(new cMPM(m));                 
               }else{
                  cMPMs2.add(new cMPM(m));                  
               }
            }else{
                  cMPMs2.add(new cMPM(m));
            } 
          }         
          if(cMPMs == null){
             cMPMs = cMPMs2;
          }else{
             cMPMs.addAll(cMPMs2);
          } 
   }

    // runs the search with parameters passed via Javascript
    public PageReference runSearch() {
        mpm = Apexpages.currentPage().getParameters().get('mpmnumber');
        SDescription = Apexpages.currentPage().getParameters().get('Sdesc');
        if(SDescription != '' && SDescription != null){
               soql = 'select id, Name, MPM_Short_Desc__c, MPM_Number__c from MPM__c where Name!= null';
               soql += ' AND MPM_Short_Desc__c LIKE \'%'+String.escapeSingleQuotes(SDescription)+'%\''; 
        } else if(mpm != '' && mpm !=null){
               soql = 'select id, Name, MPM_Short_Desc__c, MPM_Number__c from MPM__c where Name!= null';
               soql += ' AND Name LIKE \'%'+String.escapeSingleQuotes(mpm)+'%\'';
        } 
       
       // run the query again
       runQuery();
     
       return null;
    }

    public PageReference redirectUser(){
        PageReference ref = new PageReference('/apex/WB_MPMSearch');
        return ref;    
    }
    
    // ER - 001697 Lightning Experience issue : Code added by Shubham
    //wrapper class to handle mpmId && recordtypeId
    public class MPMSearchWrapper {
         @AuraEnabled public string mpmId {get; set;}
         @AuraEnabled public string recordtypeId {get; set;}    
        public MPMSearchWrapper() {
                 this.mpmId='';
                 this.recordtypeId='';
                 
        }
     }
     
   // ER - 001697 Lightning Experience issue : Code added by Shubham
   @AuraEnabled
   public static MPMSearchWrapper createECTFromLighting(String mpmNumber, String recordTypeVal) 
   {
        
        MPMSearchWrapper objWrapper = new MPMSearchWrapper();
        try{
             if (recordTypeVal!=null) {
                List<RecordType> trackerRecordtype1 = [SELECT DeveloperName,Id,IsActive,Name,SobjectType FROM RecordType where IsActive = true and SobjectType = 'EC_Tracker__c' and DeveloperName =:recordTypeVal];
                if(trackerRecordtype1.size()>0){
                for(RecordType rt:trackerRecordtype1){
                    objWrapper.recordtypeId = rt.Id;
                  }
                }
              }
             if (mpmNumber!=null) {
                List<MPM__c> mpmslist = [select Id,Name from MPM__c where Name=:mpmNumber];
                if(mpmslist.size()>0){
                   for(MPM__c m2:mpmslist){
                   objWrapper.mpmId= m2.Id;
                 }
               }   
             } 
          }Catch(Exception e){
             system.debug('Exception----->>>'+e.getMessage()); 
          }
     return objWrapper;
   }
}