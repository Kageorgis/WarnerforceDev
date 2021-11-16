/*========================================================================================================
* @author Ajit Singh
* @date 13/10/2020
* @description: Controller class that is binded with New Release button lightning component which is present on
				MPM layout to create new Release by defaulting fields from MPM.
==========================================================================================================*/
public class RF_ReleaseController {
    
    /*This method is called to create new Release from MPM*/
    @AuraEnabled
    public static Id createRelease(Id mpmId,String releaseName,String countryName,String recordTypeName, Date streetDate,Date vodDate,Date estDate,Id studioId) {
        Release__c  releaseObj=new Release__c();
        Map<String,Id> recordTypeIdvsNameMap= new  Map<String,Id>() ;
        List<release__c> recordTypeList= [select RecordTypeId,RecordType.Name from release__c];
        for(release__c rec:recordTypeList){
            recordTypeIdvsNameMap.put(rec.RecordType.Name,rec.RecordTypeId);
        }
        
        try{
            if(mpmId!=null && recordTypeIdvsNameMap.get(recordTypeName)!=null && countryName!=''){
                
                if(releaseName.contains('SDS USE ONLY-')){
                    String releaseNameTrimmed =releaseName.substringAfter('-');
                	releaseObj.Name=releaseNameTrimmed;
                }else{
                    releaseObj.Name=releaseName;
                }
                releaseObj.Country_List__c=countryName;
                releaseObj.MPM__c=mpmId;
                releaseObj.RecordTypeId=recordTypeIdvsNameMap.get(recordTypeName);
                releaseObj.Street_Date__c=streetDate;
                releaseObj.VOD_Street_Date__c=vodDate;
                releaseObj.EST_Date__c=estDate;
                releaseObj.RF_Studio__c=studioId;
            }
             else{
                 string errorMessage='';
                 if(countryName==''){
                     errorMessage = 'Please select the Country';
                 }
                 if(recordTypeIdvsNameMap.get(recordTypeName)==null){
                     errorMessage = 'Please enter the Record Type';
                 }
                  if(countryName=='' && recordTypeIdvsNameMap.get(recordTypeName)==null){
                     errorMessage = 'Please select the Country and the Record Type';
                 }
                    AuraHandledException auraEx = new AuraHandledException(errorMessage);
                    auraEx.setMessage(errorMessage);
                    throw auraEx;
                }
            }catch(Exception e){
                       throw new AuraHandledException(e.getMessage());  
            }
            insert releaseObj;
            return releaseObj.id;
            
        }
    
    /*This method is called to fetch country picklist values from Release__c object */
    @AuraEnabled
    public static List<String> getCountry(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Release__c.Country_List__c.getDescribe();
        if(fieldResult!=null){
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
       }
        return options;
    }
    
    /*This method is called to fetch recordType values from Release__c object */
    @AuraEnabled
    public static List<String> getRecordType(){
        List<String> options = new List<String>();
        Map<String,Schema.RecordTypeInfo> fieldResultMap =Schema.SObjectType.Release__c.getRecordTypeInfosByName();
        for (String p: fieldResultMap.keyset()) {
             if(p!='Master'){
               options.add(p);
             }
        }
        return options;
    }
    @AuraEnabled
    public static String getMPMShortDesc(String recordId){
        system.debug('MPM record Id rcved: '+recordId);
        
        MPM__c mp=[SELECT Id,MPM_Short_Desc__c FROM MPM__c WHERE Id=:recordId LIMIT 1];
        
        system.debug('MPM desc: '+mp.MPM_Short_Desc__c+'---mp:'+mp);
        if(mp!=null && mp.MPM_Short_Desc__c!=null){
            return mp.MPM_Short_Desc__c;
        }else{
            return null;
        }
        
    }
     
    }