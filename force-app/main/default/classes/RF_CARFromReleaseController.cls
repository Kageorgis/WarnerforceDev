/*========================================================================================================
* @author: Ajit Singh
* @date  : 03/04/2020
* @description: Controller class that is binded with RF_CARFromRelease lightning component which is present on
				Release layout to create new CAR by defaulting fields from Parent Release.
==================================================================================================================*/
public class RF_CARFromReleaseController {
    
    /*This method is called to create CAR from Release record */
    @AuraEnabled
    public static Id createCAR(Id releaseId,String requestName,Id accountId,Date dueDate, Id userId) {
      system.debug('Inside createCAR:-> '+'accountId:'+accountId+'->'+'requestName:'+requestName+'->'+'dueDate:'+dueDate);
 		Account accountObj;
        RF_User_Access__c userAccessObj;
       try{
            Release__c releaseObj= [select id,Name,Country_List__c,RF_Studio__c,RF_Status__c,MPM__c,Brand_Group__c,
                                    distributor__c,Source__c,
                                    MPM_Short_Description__c,Release_Sync__c from release__c where id=:releaseId];
             
            Id profileId = Userinfo.getProfileId();
            Profile pfVar=[select Name from profile where id = :profileId];
            List<RF_User_Access__c> userAccessList=[Select user__c,user__r.name  from RF_User_Access__c];
            Map<Id,String> mapUserIdvsUsername= new Map<Id,String>();
            for(RF_User_Access__c ual:userAccessList){
                mapUserIdvsUsername.put(ual.user__c,ual.user__r.name);
            }
            system.debug(' mapUserIdvsUsername:-> '+mapUserIdvsUsername);
            
            if(pfVar.Name!=null){
                if(mapUserIdvsUsername.containsKey(userId)){
              	  userAccessObj = [Select id, CAR_Role__c,Requesting_Group__c  from RF_User_Access__c where user__c=:userId];
               }else{
                string errorMessage = 'Sorry.You are not authorizd to create CAR!';
                AuraHandledException auraEx = new AuraHandledException(errorMessage);
                auraEx.setMessage(errorMessage);
                throw auraEx;
              }
               
            List<country__c> countryList=[Select id,name  from country__c];
             Map<String,Id> countrynamevsIdMap=new Map<String,Id>();
                for(country__c cntry:countryList){
                    countrynamevsIdMap.put(cntry.name,cntry.id);
                }
            CAR__c carObj = new CAR__c();
                
            carObj.status__c='Draft';
            carObj.RF_Studio__c=releaseObj.RF_Studio__c;
            carObj.Brand_Group__c=releaseObj.Brand_Group__c;
            carObj.MPM__c=releaseObj.MPM__c;
            carObj.Release__c=releaseObj.id;
            carObj.RF_Studios__c=releaseObj.distributor__c; 
            if(accountId!=null){
            	carObj.Account__c=accountId;
            }
            carObj.Name=requestName;
            carObj.Due_Date__c=dueDate;
            if(userAccessObj!=null){
               carObj.Requesting_Group__c=userAccessObj.Requesting_Group__c;
             }
            if(releaseObj.Country_List__c!=null){   
            	carObj.country__c=countrynamevsIdMap.get(releaseObj.Country_List__c);
             }
            insert carObj;
            return carObj.id;
            }
            else{
               return releaseObj.id;
            }
            }catch(Exception e){
            throw new AuraHandledException(e.getMessage());  
        }
        
    }
    
  }