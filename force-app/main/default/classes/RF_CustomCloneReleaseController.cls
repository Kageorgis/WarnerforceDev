/*========================================================================================================
* @author: Ajit Singh
* @date  : 27/11/2020
* @description: Controller class that is binded with RF_CustomCloneRelease lightning component which is present on
				Release layout to create new Clone Release by defaulting fields from Parent Release.
==================================================================================================================*/
public class RF_CustomCloneReleaseController {
    
    /*This method is called to create clone of the Release record */
    @AuraEnabled
    public static Id createCloneRelease(Id releaseId,String countryName) {
     
        try{
            DescribeSObjectResult describeResult = releaseId.getSObjectType().getDescribe();
			List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            String query =
                ' SELECT ' +
                String.join( fieldNames, ',' ) +
                ' FROM ' +
                describeResult.getName() +
                ' WHERE ' +
                ' id = :releaseId ' ;
            
            Release__c releaseObj = Database.query( query );
         
            /*Release__c releaseObj= [select id,Name,Country_List__c,RF_Studio__c,RF_Status__c,MPM__c,Brand_Group__c,
                                   Integration_State__c,Physical_Formats__c,RecordTypeId,Source__c,
                                  RF_Lifecycle__c,MPM_Short_Description__c,Release_Sync__c from release__c where id=:releaseId];*/
            
           if(releaseObj.Source__c!='UPHE'){
            Release__c clonedReleaseObj = releaseObj.clone(false);
            if(countryName==Label.RF_COUNTRY_CANADA){
                if(!clonedReleaseObj.Name.contains('_Canada')){
                clonedReleaseObj.Name=clonedReleaseObj.Name+'_Canada';
                }else{
                    clonedReleaseObj.Name=clonedReleaseObj.Name;
                }
                clonedReleaseObj.Country_List__c=countryName;
            }
           if(countryName=='USA'){
               if(clonedReleaseObj.Name.contains('_Canada')){
                clonedReleaseObj.Name=clonedReleaseObj.Name.replace('_Canada','');
                }
                clonedReleaseObj.Country_List__c=countryName;
            }
            if(clonedReleaseObj.Release_Sync__c==null){
                clonedReleaseObj.Release_Sync__c=releaseObj.id;
            }else{
                 clonedReleaseObj.Release_Sync__c=null;
            }
            
            insert clonedReleaseObj;
            return clonedReleaseObj.id;
                
            }else{
                return releaseObj.id;
            }
            
        }
        	
       catch(Exception e){
           throw new AuraHandledException(e.getMessage());  
        }
        
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
     
  }