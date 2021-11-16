/*========================================================================================================
* @author: Ajit Singh
* @date: 07/07/2021
* @description: Helper class that will implement the functionality of CP_ForecastTriggerHandler

==========================================================================================================*/
public class CP_ForecastTriggerHelper {
    
    /*CPBPP-84: When a forecast cycle status is 'Closed' then it's related Forecast should be locked*/    
    public static void closeForecast(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){
        Id profileId= userinfo.getProfileId();
        String profileName='';
        if(profileId!=null){
         profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        system.debug('ProfileName:'+profileName);
        }
        
        List<String> adminProfiles = Label.CP_ADMIN_RIGHTS_PROFILES.split(',');
        Set<String> profileSet=new Set<String>();
        system.debug('adminProfiles:'+adminProfiles);
        for(String prf:adminProfiles){
            profileSet.add(prf);
        }
        system.debug('profileSet:'+profileSet);
      	
        List<CP_Forecast__c> forecastCycleStatusList=[Select id, Forecast_Cycle__r.Status__c from CP_Forecast__c where id IN :newRecordsMap.keySet()];
        Map<Id,String> foreCastIdVsStatusMap=new Map<Id,String>();
        for(CP_Forecast__c fcList:forecastCycleStatusList){
            foreCastIdVsStatusMap.put(fcList.id,fcList.Forecast_Cycle__r.Status__c);
        }
        
        for(Id forecastId : newRecordsMap.keySet()){
            CP_Forecast__c newRec = (CP_Forecast__c) newRecordsMap.get(forecastId);
            if(foreCastIdVsStatusMap.get(forecastId)==Label.CP_FORECAST_CLOSED && !profileSet.contains(profileName)){
                newRec.addError(Label.CP_PREVENT_MODIFY_FORECAST);
            }
        }
    }
    
    //Default: 1 more than the latest version of forecast the licensee has for that cycle
    /*public static void addVersionToForecast(List<CP_Forecast__c> newItems){ 
        system.debug('&$$$$$$$$$&&&&&&&&&&&& inside addVersionToForecast:');
        Set<Id> foreCastId=new Set<Id>();
        Set<Id> fcstId=new Set<Id>();
        Map<Id,Id> foreCastCycleIdVsLicenseeIdMap=new Map<Id,Id>();
        for(CP_Forecast__c fc :newItems){
            foreCastId.add(fc.Forecast_Cycle__c);
            fcstId.add(fc.id);
            foreCastCycleIdVsLicenseeIdMap.put(fc.Forecast_Cycle__c,fc.Licensee_Name__c);
        }
        system.debug('$$$$$$$$&&& fcstId:'+fcstId);
         system.debug('&$$$$$$$ foreCastCycleIdVsLicenseeIdMap :'+foreCastCycleIdVsLicenseeIdMap);
        List<CP_Forecast_Cycle__c> fcList= [Select id, Status__c,(select id,name,Forecast_Cycle__c,Licensee_Name__c,Latest_forecast_version__c,Forecast_version__c from forecasts__r) from CP_Forecast_Cycle__c where id IN:foreCastId ];
        List<Decimal> forecastVersionList=new List<Decimal>();
        List<CP_forecast__c> forecastVersionListToUpdate=new List<CP_forecast__c>();
        	for(CP_Forecast_Cycle__c fcl:fcList){
            	for(CP_forecast__c fc:fcl.forecasts__r){
                  
                  if(foreCastCycleIdVsLicenseeIdMap.get(fc.Forecast_Cycle__c)==fc.Licensee_Name__c){
               		 forecastVersionList.add(fc.Forecast_version__c);
                    }
                    if(fc.Latest_forecast_version__c==true){
                        CP_forecast__c fcObj=new CP_forecast__c();
                        fcObj.Latest_forecast_version__c=false;
                        fcObj.id=fc.id;
                        forecastVersionListToUpdate.add(fcObj);
                    }
           		 }	
 			} 
        system.debug('forecastVersionList:'+forecastVersionList);
        forecastVersionList.sort();
        Decimal maxValue ;
        if(forecastVersionList.size()!=0){
		  maxValue = forecastVersionList[forecastVersionList.size()-1]; 
        }else{
            maxValue=0.0;
        }
		system.debug('maxValue:'+maxValue);
         Map<id,id> forecastVsForecastCycleIdMap= new Map<id,id>();
        for(CP_Forecast__c fcst: newItems){   
          
            fcst.Forecast_version__c=maxValue+1;
            fcst.Latest_forecast_version__c=true;
            forecastVsForecastCycleIdMap.put(fcst.id,fcst.Forecast_Cycle__r.id);
        }
        system.debug('forecastVersionListToUpdate:'+forecastVersionListToUpdate);
         update forecastVersionListToUpdate;
        system.debug('updated forecastVersionListToUpdate:');
      }*/
    
    /*New forecast should not be created if related Forecast cycle status is closed*/
    public static void preventForecastInsert(List<CP_Forecast__c> newItems){
         system.debug('$$$$$$$$$$$$$$$ inside preventForecastInsert:');
        Id profileId= userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        system.debug('ProfileName:'+profileName);
        
        List<String> adminProfiles = Label.CP_ADMIN_RIGHTS_PROFILES.split(',');//Admin, CP-Global Ops
        Set<String> profileSet=new Set<String>();
        system.debug('adminProfiles:'+adminProfiles);
        for(String prf:adminProfiles){
            profileSet.add(prf);
        }
        system.debug('profileSet:'+profileSet);
        
        Set<Id> foreCastId=new Set<Id>();
        Set<Id> accountId=new Set<Id>();
        Map<Id,String> foreCastIdVsStatusMap=new Map<Id,String>();
        Map<Id,Id> foreCastCycleIdVsLicenseeIdMap=new Map<Id,Id>();
       
		for(CP_Forecast__c fc :newItems){
            accountId.add(fc.Licensee_Name__c);
            foreCastId.add(fc.Forecast_Cycle__c);
            foreCastCycleIdVsLicenseeIdMap.put(fc.Forecast_Cycle__c,fc.Licensee_Name__c);
        }   
        system.debug('foreCastCycleIdVsLicenseeIdMap:'+foreCastCycleIdVsLicenseeIdMap);
        //fcyl-0077,mattel
        Boolean checkDraftOrOpenStatus=false;
        Boolean checkDraftOrOpenStatusForecastCycle=false;
         Map<Id,String> foreCastCycleIdVsfcStatusMap=new Map<Id,String>();
         List<CP_Forecast_Cycle__c> fcList= [Select id, Status__c from CP_Forecast_Cycle__c where id IN:foreCastId ];
        for(CP_Forecast_Cycle__c fc :fcList){
            foreCastCycleIdVsfcStatusMap.put(fc.id,fc.Status__c);
        }
        system.debug('foreCastCycleIdVsfcStatusMap'+foreCastCycleIdVsfcStatusMap);
        List<CP_Forecast_Cycle__c> fcycleList= [Select id, Status__c,(select id,name,Forecast_Cycle__c,Licensee_Name__c,Forecast_Status__c from forecasts__r) from CP_Forecast_Cycle__c where id IN:foreCastId ];
        for(CP_Forecast_Cycle__c fcl:fcycleList){
           // Id licencseeName=foreCastCycleIdVsLicenseeIdMap.get(fcl.Forecast_Cycle__c);
            for(CP_forecast__c fc:fcl.forecasts__r){
            
                if(fc.Licensee_Name__c==foreCastCycleIdVsLicenseeIdMap.get(fc.Forecast_Cycle__c)
                   && (fc.Forecast_Status__c==Label.CP_FORECAST_OPEN ||fc.Forecast_Status__c==Label.CP_DRAFT_FORECAST)){
                       system.debug('inside checkDraftOrOpenStatusForecastCycle:');
                    checkDraftOrOpenStatusForecastCycle=true;
                }
            }
        }
            system.debug('checkDraftOrOpenStatusForecastCycle:'+checkDraftOrOpenStatusForecastCycle);
     
         system.debug('checkDraftOrOpenStatus:'+checkDraftOrOpenStatus);
         system.debug('profile stat:'+!profileSet.contains(profileName));
        for(CP_Forecast__c fc :newItems){
             //system.debug('acc fc status:'+foreCastIdVsStatusMap.get(fc.Forecast_Cycle__c));
            if(!profileSet.contains(profileName)  ){
   				 fc.addError(Label.CP_PREVENT_CREATE_NEW_FORECAST_PROFILE);
            }
            if(checkDraftOrOpenStatusForecastCycle||foreCastCycleIdVsfcStatusMap.get(fc.Forecast_Cycle__c)==Label.CP_FORECAST_CLOSED){
   				 fc.addError(Label.CP_PREVENT_CREATE_NEW_FORECAST);
            }
       }
        
    }
    
   
     /*CPBPP:93 When a forecast with "Open" status is edited then the status of the forecast should automatically
			   changed to "Draft"*/
    public static void updateStatustToDraft(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){
        
        if(CP_CheckRecursive.runOnce()){
        Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.CP_Forecast__c.fields.getMap();
          
            for(Id ca:newRecordsMap.keySet()){
                CP_Forecast__c newrec = (CP_Forecast__c)newRecordsMap.get(ca);
                CP_Forecast__c oldrec = (CP_Forecast__c)oldRecordsMap.get(ca);
               
                for (String str : mapFields.keyset()) 
                {
                  
                    if(newrec.get(str)!=oldrec.get(str) && oldrec.Forecast_Status__c=='Open'
                       && (oldrec.Amount_Type__c!=newrec.Amount_Type__c ||oldrec.Note__c!=newrec.Note__c
                          || oldrec.Date_submitted__c!=newrec.Date_submitted__c
                          || oldrec.Forecast_Cycle__c!=newrec.Forecast_Cycle__c
                          ) )
                       
                    { 
					
					  newrec.Forecast_Status__c=Label.CP_DRAFT_FORECAST;
					}
					
			     }
			  }
        }  
    }
    
    //Send email to forecast owner when Forecast status=Pending Approval and also send custom notification
    public static void sendEmailToForecastOwner(Map<Id, sObject> newRecordsMap, Map<Id, sObject> oldRecordsMap){
       Map<Id,String> ownerIdVsStatusMap=new Map<Id, String>();
        for(Id ex:newRecordsMap.keySet()){
            CP_Forecast__c newrec = (CP_Forecast__c)newRecordsMap.get(ex);
            CP_Forecast__c oldrec = (CP_Forecast__c)oldRecordsMap.get(ex);
            ownerIdVsStatusMap.put(newrec.ownerId,newrec.Forecast_Status__c);
       }
        List<CP_Forecast__c> forecastRecord = [SELECT id,Name,Licensee_Name__r.name,forecast_cycle__r.name,Forecast_Status__c,Total_Amount__c,ownerId,Licensee_Name__c FROM CP_Forecast__c WHERE id IN:newRecordsMap.keyset()];
       Set<Id> ownerId = new Set<Id>();
        Map<Id,Id> ownerIdVsRecordIdMap= new Map<Id,Id>();
        Map<Id,String> ownerIdVsForecastNameMap= new Map<Id,String>();
        Map<Id,String> ownerIdVsForecastCycleNameMap= new Map<Id,String>();
        Map<Id,String> ownerIdVsAccountNameMap= new Map<Id,String>();
        Map<Id,Decimal> ownerIdVsSubTotalMap= new Map<Id,Decimal>();
       
       for(CP_Forecast__c fc : forecastRecord){
         ownerId.add(fc.ownerId);
         ownerIdVsRecordIdMap.put(fc.ownerId, fc.id);
         ownerIdVsForecastNameMap.put(fc.ownerId,fc.name);
         ownerIdVsAccountNameMap.put(fc.ownerId,fc.Licensee_Name__r.name);
         if(fc.forecast_cycle__r.name!=null){
         	ownerIdVsForecastCycleNameMap.put(fc.ownerId,fc.forecast_cycle__r.name);
          }
         ownerIdVsSubTotalMap.put(fc.ownerId,fc.Total_Amount__c);
       }
        
        EmailTemplate template=[SELECT Id,Body,Subject FROM EmailTemplate WHERE Name = 'CP Pending Approval'];
        system.debug('ownerIdVsStatusMap:'+ownerIdVsStatusMap+'ownerId:'+ownerId);
       
        String plainText = template.Body; 
       List<String> emailList = new List<String>();
     CustomNotificationType custNotification=   [SELECT Id, CustomNotifTypeName, DeveloperName from CustomNotificationType WHERE DeveloperName ='CP_Forecast_Approval'];
              
       List<User> userEmails =  [SELECT Id,Name,Email FROM User WHERE Id IN:ownerId];
        
       for(User usr : userEmails){
          if(ownerIdVsStatusMap.get(usr.Id)=='Pending Approval'){
            system.debug('$$$ send email to:'+usr.Email);
             Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(template.id, usr.Id, ownerIdVsRecordIdMap.get(usr.Id));
        
              String emailSubject = mail.getSubject();
              String emailTextBody = mail.getPlainTextBody();
              mail.setTargetObjectId(usr.Id);
              mail.setSubject(emailSubject);
              mail.setPlainTextBody(emailTextBody);
              mail.saveAsActivity = false;
              
            Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            system.debug('$$$ results mail:'+results); 
              
              /*Send custom notification to the Forecast approver*/
              String forecastName=ownerIdVsForecastNameMap.get(usr.Id);
              String forecastStatus=ownerIdVsStatusMap.get(usr.Id);
              String forecastCycleName=ownerIdVsForecastCycleNameMap.get(usr.Id);
              String accountName=ownerIdVsAccountNameMap.get(usr.Id);
              Id customNotificationId=custNotification.id;
              Decimal subTotal=ownerIdVsSubTotalMap.get(usr.Id);
              String msgBody='Forecast Id:'+forecastName+'.'+' Forecast Status:'+forecastStatus+'.'+'Forecast Cycle Name:'+forecastCycleName+'.'+'Subtotal:'+subTotal;
              system.debug('$$$ msgBody:'+msgBody); 
              //String title=usr.Name+' '+' is requesting approval for Forecast';
               String title=accountName+' '+' '+forecastCycleName+' '+' is pending for your approval.';
               system.debug('$$$ title:'+title); 
              CP_SendCustomNotification.sendNotificationsToForecastOwner(msgBody, '', usr.Id, title, customNotificationId, new set<String>{usr.Id});
              system.debug('$$$ sendNotificationsToForecastOwner done'); 
          }
        }

    }
    
  
    
    public static void  updateOwnerOnForecast(List<sObject> newRecordsList , Map<Id, sObject> newItems){
        system.debug('inside updateOwnerOnForecast:');
       
        List<CP_Forecast__c> fCList= new List<CP_Forecast__c>();
        List<CP_Forecast__c> foreCastList=[select id,name,Forecast_Cycle__r.id,Forecast_Status__c,Licensee_Name__r.Forecasting_Approver__c from CP_Forecast__c where Id IN:newItems.keyset()];
        system.debug('owner foreCastList:'+foreCastList); 		
        for(CP_Forecast__c fcl : foreCastList){ 
            CP_Forecast__c fcobj=new CP_Forecast__c();
            if(fcl.Licensee_Name__r.Forecasting_Approver__c!=null){
                fcobj.ownerid=fcl.Licensee_Name__r.Forecasting_Approver__c;
                fcobj.id=fcl.id;
                fCList.add(fcobj);
            }
        }
        if(fCList.size()>0){
            update fCList;
        }
    }
       
    //CPBP:383 File should be uploaded to forecast from forecast cycle when forecast is manually created
    public static void  updateFileOnForecast(List<sObject> newRecordsList , Map<Id, sObject> newItems){ 
        system.debug('>>>>>>updateFileOnForecast');
        
        Set<Id> fcstId=new Set<Id>();
        Id forecastid=null;
        
        Set<Id> fcstCycleId=new Set<Id>();
        
        Map<id,id> forecastVsForecastCycleIdMap= new Map<id,id>();
        
        List<CP_Forecast__c> foreCastList=[select id,name,Forecast_Cycle__r.id,Forecast_Status__c,Licensee_Name__r.Forecasting_Approver__c from CP_Forecast__c where Id IN:newItems.keyset()];
        system.debug('>>>>>>foreCastList'+foreCastList);
        for(CP_Forecast__c fcl : foreCastList){ 
            fcstId.add(fcl.id);
            forecastid=fcl.id;
            fcstCycleId.add(fcl.Forecast_Cycle__r.id);
            forecastVsForecastCycleIdMap.put(fcl.id,fcl.Forecast_Cycle__r.id);
        }
        system.debug('fcstCycleId:'+fcstCycleId);
        List<ContentDocumentLink> cdLink=new List<ContentDocumentLink>();
        
        List<ContentDocumentLink> cdlList=[SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId IN:fcstCycleId];	
        system.debug('cdlList:'+cdlList);
        Map<id,id> fcyleIdVsContentIdMap=new Map<id,id>();
        for(ContentDocumentLink cd :cdlList){
            fcyleIdVsContentIdMap.put(cd.LinkedEntityId,cd.ContentDocumentId);
        }
        
        if(cdlList.size()>0){
            for(ContentDocumentLink cdl:cdlList){
                system.debug('cdl for loop:'+cdl);
                ContentDocumentLink cDe = new ContentDocumentLink();
                //Id forecastCycleId=forecastVsForecastCycleIdMap.get(fcst);
                //  cDe.ContentDocumentId = fcyleIdVsContentIdMap.get(forecastCycleId); 
                cDe.ContentDocumentId = cdl.ContentDocumentId;
                cDe.LinkedEntityId =forecastid; 
                cDe.ShareType = 'I'; 
                cDe.Visibility = 'AllUsers';
                cdLink.add(cDe);
            }
            system.debug('cdLink:'+cdLink);
            insert cdLink;
        }        
    }
    
    
    
   /*  public static void  massApproveForecast(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        system.debug('inside massApproveForecast:');
         List<CP_Forecast__c> foreCastListToUpdate=new List<CP_Forecast__c>();
         List<CP_Forecast__c> foreCastList=[select id,name,Forecast_Status__c,Licensee_Name__r.Forecasting_Approver__c from CP_Forecast__c where id IN:newItems.keyset()];
         system.debug('massApproveForecast foreCastList:'+foreCastList);
        Map<Id,String> recordIdVsStatusMap=new Map<Id, String>();
        for(Id ex:newItems.keySet()){
            CP_Forecast__c newrec = (CP_Forecast__c)newItems.get(ex);
            CP_Forecast__c oldrec = (CP_Forecast__c)oldItems.get(ex);
            recordIdVsStatusMap.put(newrec.id,newrec.Forecast_Status__c);
       }
          system.debug('recordIdVsStatusMap:'+recordIdVsStatusMap);
        for(CP_Forecast__c fcl :foreCastList){
            if(recordIdVsStatusMap.get(fcl.id)=='Submitted'){
            CP_Forecast__c fcObj=new CP_Forecast__c();
            fcObj.id=fcl.id;
            fcObj.Forecast_Status__c='Submitted';
            foreCastListToUpdate.add(fcObj);
            }
         }
         upsert foreCastListToUpdate;
      }*/
    
    public static void  cloneNewVersionForecast(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
      // if(CP_CheckRecursive.runOnce()){
        system.debug('inside cloneNewVersionForecast:');
         List<CP_Forecast__c> foreCastList=[select id,Latest_forecast_version__c,name,Amount_Type__c,Forecast_Status__c,Licensee_Name__r.Forecasting_Approver__c from CP_Forecast__c where id IN:newItems.keyset()];
        String forecastStatus='';
        for(CP_Forecast__c fcl :foreCastList){
            forecastStatus=fcl.Forecast_Status__c;
           
        }
        
       if(forecastStatus=='Rejected'){
        system.debug('inside forecastStatus:'+forecastStatus);
        Set<Id> forecastId=newItems.keyset();
         system.debug('inside forecastId:'+forecastId);
        Id fcstId=null;
        for(Id fcId:forecastId){
            fcstId=fcid;
        }
        system.debug('inside fcstId:'+fcstId);
        DescribeSObjectResult describeResult = fcstId.getSObjectType().getDescribe();
         system.debug('describeResult:'+describeResult);
			List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
          system.debug('fieldNames:'+fieldNames);
            String query =
                ' SELECT ' +
                String.join( fieldNames, ',' ) +
                ' FROM ' +
                describeResult.getName() +
                ' WHERE ' +
                ' id = :fcstId ' ;
            
         system.debug('query:'+query);
        CP_Forecast__c forecastObj = Database.query( query );
        
        String sobject_type = 'cp_forecast_item__c';
		Map<String, Schema.SObjectType> global_describe = Schema.getGlobalDescribe();
		Map<String, Schema.SObjectField> object_fields_map = global_describe.get(sobject_type).getDescribe().fields.getMap();
        List<String> fieldNamesForecastItem =  new List<String>(object_fields_map.keySet());
        String fcItemquery =
                ' SELECT ' +
                String.join( fieldNamesForecastItem, ',' ) +
                ' FROM ' +
                sobject_type +
                ' WHERE ' +
                ' Forecast__c = :fcstId ' ;
        
        List<cp_forecast_item__c> forecastItemObjList = Database.query( fcItemquery );
        system.debug('forecastItemObjList:'+forecastItemObjList);
        system.debug('forecastObj Forecast_Status__c:'+forecastObj.Forecast_Status__c);
        system.debug('inside test status:'+forecastStatus=='Rejected');
       List<cp_forecast_item__c> fcItemList=[select id,name,Forecast__c from cp_forecast_item__c where Forecast__c=:fcstId];
        List<cp_forecast_item__c> fcItemListToInsert=new  List<cp_forecast_item__c>();
       // if(forecastStatus=='Rejected'){
            system.debug('inside clone:');
             CP_Forecast__c clonedForecastObj=forecastObj.clone(false,true);
             clonedForecastObj.Forecast_Status__c='Draft';
            if(clonedForecastObj.Forecast_version__c!=null){
               clonedForecastObj.Forecast_version__c=clonedForecastObj.Forecast_version__c+1;
            }
            if(clonedForecastObj.Amount_Type__c!=null && clonedForecastObj.Amount_Type__c!=''){
                clonedForecastObj.Amount_Type__c = clonedForecastObj.Amount_Type__c;
            }  
             system.debug(' clonedForecastObj:'+clonedForecastObj);
             insert clonedForecastObj;
              system.debug(' clonedForecastObj. id:'+clonedForecastObj.id);
            system.debug('forecastItemObjList:'+forecastItemObjList);
             for(cp_forecast_item__c fcitem:forecastItemObjList){
                cp_forecast_item__c fcCopy = fcitem.clone(false,true);
                system.debug('fcCopy:'+fcCopy);
           	   fcCopy.Forecast__c = clonedForecastObj.id;
               fcItemListToInsert.add(fcCopy);
            }
            if(fcItemListToInsert.size()>0){
             insert fcItemListToInsert;
            system.debug('fcItemListToInsert id:'+fcItemListToInsert);
            }
            
             // List<ContentDocumentLink> cdLink=new List<ContentDocumentLink>();
                
              /*List<ContentDocumentLink> cdl=[SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId=:clonedForecastObj.Forecast_Cycle__c];	
              system.debug('cdl clone:'+cdl);
            if(cdl.size()>0){
                for(ContentDocumentLink cd:cdl){
                ContentDocumentLink cDe = new ContentDocumentLink();
                cDe.ContentDocumentId = cd.ContentDocumentId; 
                cDe.LinkedEntityId =clonedForecastObj.id; 
                cDe.ShareType = 'I'; 
                cDe.Visibility = 'AllUsers';
                cdLink.add(cDe);
                 system.debug('->cdLink:'+cdLink);
                }
                insert cdLink;
               }
            
            system.debug('->clonedForecastObj id:'+clonedForecastObj.id);
           */
           
        }
     // }
    }
    
    /*CPBPP-120*/
  /*  public static void  shareForecastRecordWithAgent(List<sObject> newRecordsList , Map<Id, sObject> newItems){
        system.debug('inside shareForecastRecordWithAgent:');
        List<CP_Forecast__Share> fcshareList= new List<CP_Forecast__Share> ();
        List<CP_Forecast__c> foreCastList=[select id,name,Licensee_Name__c,Forecast_Status__c from CP_Forecast__c where Id IN:newItems.keyset()];
        system.debug('foreCastList to share:'+foreCastList); 
        Set<Id> accountId= new Set<Id>();
        for(CP_Forecast__c fcl : foreCastList){ 
            accountId.add(fcl.Licensee_Name__c);
        }
        List<Account> accList=[select id,name,ParentId,WBCP_Licensee_Agent__c from account where id IN:accountId];
        Set<Id> relatedAccountId= new Set<Id>();
        for(Account acc : accList){
            //for(CP_Related_Account__c rAcc:acc.Related_Accounts__r){
                relatedAccountId.add(acc.WBCP_Licensee_Agent__c);
            //}
        }
        
       List<Account> relatedAccountList= [select id,name,(select id,name from contacts) from account where id IN:relatedAccountId];
       Set<Id> agentsContactId= new Set<Id>();
        for(Account relAcc:relatedAccountList){
             for(Contact cont:relAcc.contacts){
                agentsContactId.add(cont.Id);
            }
         }
        system.debug('agentsContactId:'+agentsContactId);
        List<User> contactUserList=[Select Id, Contact.Id from User where Contact.Id IN:agentsContactId];
        Set<Id> contactUserId= new Set<Id>();
        for(User userId:contactUserList){
            contactUserId.add(userId.Id);
        }
        system.debug('contactUserId:'+contactUserId);
       // for(CP_Forecast__c fcl : foreCastList){ 
        for(Id agentId:contactUserId){ 
            CP_Forecast__Share forecastRecordToShare = new CP_Forecast__Share();
            
            /* Access Level (‘Read’ or ‘Edit’ only cannot mention ‘All’) */
            
           // forecastRecordToShare.AccessLevel = 'Read';
            
            /* UserId or Public Group Id or RoleId  */
            
            //for(Id agentId:contactUserId){
              // system.debug('agentId:'+agentId);
              // forecastRecordToShare.UserOrGroupId =agentId;//Licensee Demo3
            //}
            
            /*  ParentId is the id of record which is to be shared */
           // for(CP_Forecast__c fcl : foreCastList){ 
           //  forecastRecordToShare.ParentID = fcl.Id;//fcycleid
           // }
            
            /*  Mention sharing reason, If this field is missed then by default Manual will be set as reason */
            
            //forecastRecordToShare.RowCause = Schema.CP_Forecast__Share.RowCause.New_Sharing_Reason_Example__c;
            
           // fcshareList.add(forecastRecordToShare);
      //  }
       
        //Insert fcshareList;
        //system.debug('after insert fcshareList:'+fcshareList);
    // }*/
    
     /*Share Contracts to Agent portal users so that they can have access to  
       all Contracts that are related to child accounts of its Licensee accounts*/
   /* public static void  shareContractsWithAgent(List<sObject> newRecordsList , Map<Id, sObject> newItems){
           system.debug('@@@@inside shareContractsWithAgent:');
        if(newItems.keyset()!=null){
        List<CP_Forecast__c> foreCastList=[select id,name,Licensee_Name__c,Licensee_Name__r.WBCP_Licensee_Agent__c,Licensee_Name__r.ParentId,Forecast_Status__c from CP_Forecast__c where Id IN:newItems.keyset()];
        system.debug('foreCastList-->>'+foreCastList); 
        system.debug('foreCastList size-->>'+foreCastList.size()); 
        Set<Id> accountId= new Set<Id>();
         Set<Id> childAccountId= new Set<Id>();
         Set<Id> agentAccountId= new Set<Id>();
        for(CP_Forecast__c fcl : foreCastList){ 
            accountId.add(fcl.Licensee_Name__c);
            agentAccountId.add(fcl.Licensee_Name__r.WBCP_Licensee_Agent__c);
        }
         system.debug('accountId:'+accountId);
        system.debug('agentAccountId:'+agentAccountId);
       List<Account> accountList=[select id,name,WBCP_Licensee_Agent__c,WBCP_Licensee_Agent__r.name,ParentId,Parent.WBCP_Licensee_Agent__c from account where Parent.WBCP_Licensee_Agent__c IN:agentAccountId];
       system.debug('accountList:'+accountList);
        for(Account acc:accountList){
            childAccountId.add(acc.id);
           
        }
         system.debug('childAccountId:'+childAccountId);
      
        Set<Id> agentsContactId= new Set<Id>();
        List<Contact> contactList=[select id,name,AccountId from Contact where AccountId IN:agentAccountId];
        system.debug('contactList:'+contactList);
        for(Contact cont:contactList){
            agentsContactId.add(cont.id);
        }
         system.debug('agentsContactId:'+agentsContactId);
        List<CP_Contract__Share> contractShareListToInsert=new List<CP_Contract__Share> ();
        List<CP_Contract__c> contractList=[select id,name,Account_Licensee__c from CP_Contract__c where Account_Licensee__c IN:childAccountId];
        system.debug('contractList:'+contractList);
         List<User> contactUserList=[Select Id,name, Contact.Id from User where Contact.Id IN:agentsContactId];  
        system.debug('contactUserList:'+contactUserList);
          for(CP_Contract__c contr:contractList){ 
            
            CP_Contract__Share contractRecordToShare = new CP_Contract__Share();
            contractRecordToShare.AccessLevel = 'Read';
            for(User usr:contactUserList){
         
            	contractRecordToShare.UserOrGroupId =usr.Id;
             }
            contractRecordToShare.ParentID = contr.Id;
            contractShareListToInsert.add(contractRecordToShare);
         }
        system.debug('contractShareListToInsert:'+contractShareListToInsert);
         Insert contractShareListToInsert;
         system.debug('contractShareListToInsert done:');
      }
    }*/
    
     /*UnShare Contracts to Agent portal users when Agent is removed from licensee account so that they can only have 
       access to all Contracts that are related to child accounts of its Licensee accounts*/
   /* public static void  UnshareContractsWithAgent(Map<Id,Account> mapOldAccounts, Map<Id,Account> mapNewAccounts){
        
        system.debug('%% inside UnshareContractsWithAgent :');
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId();
        for(Account acc : mapNewAccounts.values()) {
            if(acc.RecordTypeId==accRecordTypeId){//Record type check for WBCP Licensee Accounts
                
                Account oldAccount = Trigger.isUpdate && mapOldAccounts.get(acc.Id) != null ? mapOldAccounts.get(acc.Id) : null;
                
                if(Trigger.isUpdate && acc.WBCP_Licensee_Agent__c != oldAccount.WBCP_Licensee_Agent__c
                   && acc.WBCP_Licensee_Agent__c==null) {
                       system.debug('%% logic implementation for contract sharing :');
                       Set<Id> childAccountId=new Set<Id>();
                       List<Account> childAccountList=[select id,name,ParentId,Parent.WBCP_Licensee_Agent__c from account where ParentId =:acc.id];
                       system.debug('childAccountList:'+childAccountList);
                       for(Account accnt:childAccountList){
                           childAccountId.add(accnt.id);
                       }
                       system.debug('childAccountId:'+childAccountId);
                       
                       Set<Id> agentsContactId= new Set<Id>();
                       List<Contact> contactList=[select id,name,AccountId from Contact where AccountId =:oldAccount.WBCP_Licensee_Agent__c];
                       system.debug('contactList:'+contactList);
                       for(Contact cont:contactList){
                           agentsContactId.add(cont.id);
                       }
                       system.debug('agentsContactId:'+agentsContactId);
                       
                       set<string>  contractName=new set<string>();
                       
                       List<CP_Contract__c> contractList=[select id,name,Account_Licensee__c from CP_Contract__c where Account_Licensee__c IN:childAccountId];
                       system.debug('contractList:'+contractList);
                       for(CP_Contract__c cnt:contractList){
                           contractName.add(cnt.name);
                       }
                       
                       List<User> contactUserList=[Select Id,name, Contact.Id from User where Contact.Id IN:agentsContactId];  
                       system.debug('contactUserList:'+contactUserList);
                       
                       List<CP_Contract__Share> contractSharedList=[select id,parentId,parent.name,UserOrGroupId from CP_Contract__Share where parent.name IN:contractName];
                       system.debug('%% contractSharedList:'+contractSharedList);
                       delete contractSharedList;
 
                   }
  			  }
        }
    }*/
    

   /*  public static void  updateAgentsOnChildAccount(Map<Id,Account> mapOldAccounts, Map<Id,Account> mapNewAccounts){
        system.debug('%% inside updateAgentsOnChildAccount :');
         List<Account> parentAccountList=[Select id,WBCP_Licensee_Agent__c from Account where id IN:mapNewAccounts.keyset()];
         system.debug('parentAccountList:'+parentAccountList);
         Set<Id> parentAccountId=new Set<Id>();
         Map<Id,Id> parentAccountVsLookupAgent=new  Map<Id,Id>();
         for(Account acc:parentAccountList){
             parentAccountId.add(acc.id);
             parentAccountVsLookupAgent.put(acc.id,acc.WBCP_Licensee_Agent__c);
         }
          system.debug('parentAccountId:'+parentAccountId);
         system.debug('parentAccountVsLookupAgent:'+parentAccountVsLookupAgent);
         List<Account> childAccountList=[Select id,RecordTypeId,ParentId,Agency__c,name,WBCP_Licensee_Agent__c from Account where ParentId IN:parentAccountId];
         system.debug('childAccountList'+childAccountList);
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('WBCP Licensee').getRecordTypeId();
        List<Account> updateAccountList=new List<Account>();
		
		
		 for(Id accId:mapNewAccounts.keySet()){
                Account newrec = (Account)mapNewAccounts.get(accId);
                Account oldrec = (Account)mapOldAccounts.get(accId);
				
		   if(newrec.RecordTypeId == accRecordTypeId){
		     
			 if(newrec.WBCP_Licensee_Agent__c != oldrec.WBCP_Licensee_Agent__c){
			   for(Account acc : childAccountList) {
				    Account account=new Account();
                    account.Agency__c=parentAccountVsLookupAgent.get(acc.ParentId);
                    system.debug('agency:'+parentAccountVsLookupAgent.get(acc.ParentId));
                    account.id=acc.id;
                    updateAccountList.add(account);
			 
				}
			  }
			}
				
	    }
		update updateAccountList;

     }*/
    
   
}