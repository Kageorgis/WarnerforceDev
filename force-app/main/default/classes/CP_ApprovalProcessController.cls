/*========================================================================================================
* @author: Ajit Singh
* @date :10/08/2021
* @description: Controller class that is binded with Approve/Reject button lightning component and implements
                all the logic of status change on click of Approve/Reject button of Forecast record.
==========================================================================================================*/
public class CP_ApprovalProcessController {
    
     @AuraEnabled
     public static void approveForecast(Id forecastId,Id userId) {
         
         User userObj=[Select id,name from user where id=:userId];
         Id profileId = Userinfo.getProfileId();
         Profile pfVar=[select Name from profile where id = :profileId];
        
         CP_Forecast__c  forecastObj=[Select id,Forecast_Status__c,owner.name from CP_Forecast__c where id=:forecastId];
        
         //Forecast owner and Global Ops users should be able to Approve/Reject a Forecast
         if((pfVar.name==label.CP_GLOBAL_OPS_PROFILE ||userObj.name==forecastObj.owner.name) && forecastObj.Forecast_Status__c== Label.CP_PENDING_APPROVAL){
        	 forecastObj.Forecast_Status__c= Label.CP_SUBMITTED;
         	 update forecastObj;
         }else{
              string errorMessage='';
             if(forecastObj.Forecast_Status__c!=Label.CP_PENDING_APPROVAL){
                  errorMessage = Label.CP_NO_AUTHORIZE_APPROVE_FORECAST_STATUS;
                 }else{
                  errorMessage = Label.CP_NO_AUTHORIZE_APPROVE_FORECAST;
             }
             AuraHandledException auraEx = new AuraHandledException(errorMessage);
             auraEx.setMessage(errorMessage);
             throw auraEx;
         }
         
         
                
       
    }
    
     @AuraEnabled
     public static void rejectForecast(Id forecastId,Id userId) {
        
         User userObj=[Select id,name from user where id=:userId];
         system.debug('name::'+userObj.name);
         Id profileId = Userinfo.getProfileId();
         Profile pfVar=[select Name from profile where id = :profileId];
        
         CP_Forecast__c  forecastObj=[Select id,Forecast_Status__c,owner.name from CP_Forecast__c where id=:forecastId];
        system.debug('Forecast_Status__c::'+forecastObj.Forecast_Status__c);
          system.debug('forecastObj.owner.name::'+forecastObj.owner.name);
         //Forecast owner/Category Manager and Global Ops users should be able to Approve/Reject a Forecast
        if((pfVar.name==label.CP_GLOBAL_OPS_PROFILE||pfVar.name==label.CP_CATEGORY_MANAGER||userObj.name==forecastObj.owner.name) && forecastObj.Forecast_Status__c== Label.CP_PENDING_APPROVAL){
        	 forecastObj.Forecast_Status__c= Label.CP_REJECTED;
         	 update forecastObj;
         }else{
             string errorMessage='';
             if(forecastObj.Forecast_Status__c!= Label.CP_PENDING_APPROVAL){
                  errorMessage = Label.CP_NO_AUTHORIZE_REJECT_FORECAST_STATUS;
                 }else{
                  errorMessage = Label.CP_NO_REJECT_APPROVE_FORECAST;
             }
             AuraHandledException auraEx = new AuraHandledException(errorMessage);
             auraEx.setMessage(errorMessage);
             throw auraEx;
         }
         
         
       
    }
    
}