/*========================================================================================================
* @author: Ajit Singh
* @date: 20/10/2020
* @description: This class is binded with RightGroupDT lightning component which fetches the right group's field
                 present on Release MPM's right group list.
==========================================================================================================*/
public class RF_RightGroupController {
    
    /* This method looks upto to Release's MPM object and then fetches all the right group records from it related list */
    @AuraEnabled
    public static List <RightGroupWrapper> fetchRightGroup(Id releaseRecordId) {
        List<RightGroupWrapper> dataTableList= new List<RightGroupWrapper> ();
          
        Release__c releaseObj=[select id,Name,MPM__c,Country_List__c from Release__c where id=:releaseRecordId];
        
        List<MPM__c> mpmList=[select id,Name,MPM_Short_Desc__c, (select Channel__c,Status__c,Rights_Group__c,
                             Date_Last_Changed__c,Notes__c,Rights_Start__c,Rights_End__c,Rights_Start_2__c,Rights_Start_3__c,
                             Rights_Start_4__c,Rights_Start_5__c,Rights_End_2__c,Rights_End_3__c,Rights_End_4__c,Rights_End_5__c,                            
                             RecordType.Name,RT_Lifecycle__c,Name from rights__r where Rights_Group__c=:releaseObj.Country_List__c) from MPM__c where id=:releaseObj.MPM__c];
       system.debug('mpmList size::'+mpmList.size());
       system.debug('mpmList'+mpmList);
        RightGroupWrapper rightGroupWrapperObj;
        for(MPM__c mpm:mpmList){
            for(rights__c rgts:mpm.rights__r){
                system.debug('rgts:'+rgts);
                if(rgts.RecordType.Name==Label.RF_MPM){
                system.debug('inside rgts:'+rgts.RecordType.Name);
                rightGroupWrapperObj=new RightGroupWrapper();
                rightGroupWrapperObj.RightGroup=rgts.Rights_Group__c;
                rightGroupWrapperObj.Channel=rgts.Channel__c;
                rightGroupWrapperObj.Status=rgts.Status__c;
                rightGroupWrapperObj.DateLastChanged=rgts.Date_Last_Changed__c;
                rightGroupWrapperObj.Notes=rgts.Notes__c;
                rightGroupWrapperObj.RightStart1=rgts.Rights_Start__c;
                rightGroupWrapperObj.RightEnd1=rgts.Rights_End__c;
                rightGroupWrapperObj.RightStart2=rgts.Rights_Start_2__c;
                rightGroupWrapperObj.RightEnd2=rgts.Rights_End_2__c;
                rightGroupWrapperObj.RightStart3=rgts.Rights_Start_3__c;
                rightGroupWrapperObj.RightEnd3=rgts.Rights_End_3__c	;
                rightGroupWrapperObj.RightStart4=rgts.Rights_Start_4__c;
                rightGroupWrapperObj.RightEnd4=rgts.Rights_End_4__c;
                rightGroupWrapperObj.RightStart5=rgts.Rights_Start_5__c;
                rightGroupWrapperObj.RightEnd5=rgts.Rights_End_5__c;
                rightGroupWrapperObj.Rights=rgts.Name;
                rightGroupWrapperObj.MPM=mpm.Name;
                system.debug('mpm.MPM_Short_Desc__c:'+mpm.MPM_Short_Desc__c);
                rightGroupWrapperObj.MPMDescription=mpm.MPM_Short_Desc__c;
                rightGroupWrapperObj.Release=releaseObj.Name;
                dataTableList.add(rightGroupWrapperObj);
                system.debug('dataTableList:'+dataTableList);
               }
            }
         }
   
        return dataTableList;
    }
    
    /*This is wrapper class which has the fields of MPM and Release object*/
    public class RightGroupWrapper{
        @AuraEnabled
        public String Release {get;set;}
        @AuraEnabled
        public String ReleaseName {get;set;}
        @AuraEnabled
        public String MPM {get;set;}
        @AuraEnabled
        public String MPMDescription {get;set;}
        @AuraEnabled
        public String RightGroup {get;set;}
        @AuraEnabled
        public String Channel {get;set;}
        @AuraEnabled
        public String Status {get;set;}
        @AuraEnabled
        public Date DateLastChanged {get;set;}
        @AuraEnabled
        public String Notes {get;set;}
        @AuraEnabled
        public Date RightStart1 {get;set;}
        @AuraEnabled
        public Date RightEnd1 {get;set;}
        @AuraEnabled
        public Date RightStart2 {get;set;}
        @AuraEnabled
        public Date RightEnd2 {get;set;}
        @AuraEnabled
        public Date RightStart3 {get;set;}
        @AuraEnabled
        public Date RightEnd3 {get;set;}
        @AuraEnabled
        public Date RightStart4 {get;set;}
        @AuraEnabled
        public Date RightEnd4 {get;set;}
        @AuraEnabled
        public Date RightStart5 {get;set;}
        @AuraEnabled
        public Date RightEnd5 {get;set;}
        @AuraEnabled
        public String Rights {get;set;}
    }
}