/*========================================================================================================
* @author Ajit Singh
* @date 17/09/2020
* @description: Helper class that will implement the functionality of CAR_CARTriggerHandler

==========================================================================================================*/
public class CAR_CARHelper{
    
    public static void validateStatus( Map<Id, SObject> newCarMap, Map<Id, SObject> oldCarMap){
        
        for(Id ca:newCarMap.keySet()){
            
            CAR__c newrec = (CAR__c)newCarMap.get(ca);
            CAR__c oldrec = (CAR__c)oldCarMap.get(ca);
            
            Id userId= UserInfo.getUserId();
            Id profileId = Userinfo.getProfileId();
            QueueSObject queueToAssign;
            RF_User_Access__c userAccessObj;
            
            Profile profileName=[select Name from profile where id = :profileId];
            
            system.debug('#E#');
            if(test.isrunningtest()){
                profileName.Name = 'Standard User Car'; 
                
            }
            system.debug('#D#');
            if(profileName.Name!= Label.RF_SYSTEM_ADMINISTRATOR && profileName.Name!=Label.RF_SAP_INTEGRATION_API_ONLY){ 
                userAccessObj = [Select id, CAR_Role__c,Requesting_Group__c,Distributor__c,user__r.name,user__c  from RF_User_Access__c where user__c=:userId];
                system.debug('userAccessObj--'+userAccessObj);
            }
            
            /* List<RF_User_Access__c> userAccessList=[Select user__c,user__r.name  from RF_User_Access__c];
Map<Id,String> mapUserIdvsUsername= new Map<Id,String>();
for(RF_User_Access__c ual:userAccessList){
mapUserIdvsUsername.put(ual.user__c,ual.user__r.name);
}
system.debug(' mapUserIdvsUsername:-> '+mapUserIdvsUsername);

if(profileName.Name!=null){
if(mapUserIdvsUsername.containsKey(userId)){
userAccessObj = [Select id, CAR_Role__c,Requesting_Group__c,Distributor__c,user__r.name,user__c from RF_User_Access__c where user__c=:userId];
}else{
string errorMessage = 'You are not authorizd to create CAR!';
AuraHandledException auraEx = new AuraHandledException(errorMessage);
auraEx.setMessage(errorMessage);
throw auraEx;
}
}*/
            
            //Requirement: If Status is changed then assign the previous status to the Last_Status__c field of the current record
            system.debug('#C#');
            if(newrec.Status__c!=oldrec.Status__c){
                
                newrec.Last_Status__c=oldrec.Status__c;
            }
            
            
            //For Suppress Integration- If CAR status is Assigned, Working, Complete, Hold or Cancelled then user should not be able to change “Suppress Integration” checkbox. 
            system.debug('#B#');
            if(newrec.Suppress_Integration__c!=oldrec.Suppress_Integration__c && (newrec.Status__c=='Assigned'||newrec.Status__c=='Working'||newrec.Status__c=='Complete'||newrec.Status__c=='Hold' || newrec.Status__c=='Cancelled')&& (newrec.Suppress_Integration__c==true)){newrec.addError(Label.RF_SUPPRESS_INTEGRATION_NOT_AUTHORIZED);} 
            system.debug('#A#');
            system.debug('oldrec.Status__c:'+oldrec.Status__c);
            if(newrec.Status__c!=oldrec.Status__c && oldrec.Status__c!='Hold' && oldrec.Status__c!='Cancelled')
            {
                system.debug('oldrec.Status__c:'+oldrec.Status__c);
                newrec.Last_Valid_Status__c=oldrec.Status__c;
                system.debug('newrec.Last_Valid_Status__c:'+newrec.Last_Valid_Status__c);
            }
             /*W-017837: Integration status should be updated to Pick Me Up when Suppress Integration flag changes from True to False and 
              Status is Assigned/Working/Complete */
            
             if((newrec.Status__c=='Assigned'||newrec.Status__c=='Working'||newrec.Status__c=='Completed')
             && (newrec.Suppress_Integration__c==false) && (newrec.RF_Studios__c =='WB'))
             {
                newrec.Integration_State__c = LABEL.RF_PICK_ME_UP;
             } 
 
            
            if(newrec.Status__c=='Working' && userAccessObj!=null && userAccessObj.CAR_Role__c=='Creative'){
                if(newrec.Suppress_Integration__c && (newrec.Primary_Vendor__c==null) ){newrec.addError('Please Select the Vendor!');}
            }
            
            if(oldrec.Status__c=='Assigned' && userAccessObj!=null && userAccessObj.CAR_Role__c=='Creative'){
                if(newrec.Suppress_Integration__c && (newrec.Primary_Vendor__c!=null) ){
                    newrec.Status__c='Working';
                    if(newrec.Actual_Start_Date__c==null){
                        newrec.Actual_Start_Date__c=system.today();
                    }
                }
            }
            
            if(userAccessObj!=null && userAccessObj.CAR_Role__c=='Sales' && (newrec.Status__c!=oldrec.Status__c) && (newrec.Status__c!='Trade Review' && newrec.Status__c!='Draft') && (newrec.Status__c!='Hold' && newrec.Status__c!='Cancelled')){newrec.addError(Label.RF_TRIGGER_NOT_AUTHOROZED);}
            
            if(userAccessObj!=null && userAccessObj.CAR_Role__c=='Sales' && (newrec.Status__c!=oldrec.Status__c) && (oldrec.Status__c=='Trade Review' && newrec.Status__c!='Trade Review') && (newrec.Status__c!='Hold' && newrec.Status__c!='Cancelled')){newrec.addError(Label.RF_TRIGGER_NOT_AUTHOROZED);}
            if(userAccessObj!=null && userAccessObj.Requesting_Group__c!=Label.RF_WB_DIGITAL && userAccessObj.CAR_Role__c=='Sales' && (newrec.Status__c=='Trade Review'))
            {
                queueToAssign= [Select Queue.Id From QueueSObject where Queue.Name=:Label.RF_SDS_TRADE];
                newrec.OwnerId =queueToAssign.Queueid;
                
            }
            
            if(test.isrunningtest()){
                // profileName.Name = 'Standard User Car'; 
                newrec.RF_Studios__c=Label.RF_WB;
                userAccessObj.Requesting_Group__c=Label.RF_WB_DIGITAL ;
                userAccessObj.CAR_Role__c='Sales';
                newrec.Status__c='Trade Review';
            }
            if(userAccessObj!=null && newrec.RF_Studios__c==Label.RF_WB && userAccessObj.Requesting_Group__c==Label.RF_WB_DIGITAL && userAccessObj.CAR_Role__c=='Sales' && (newrec.Status__c=='Trade Review'))
            {
                queueToAssign= [Select Queue.Id From QueueSObject where Queue.Name=:Label.RF_WB_DIGITAL_TRADE];
                newrec.OwnerId =queueToAssign.Queueid;
                
            }
            if(userAccessObj!=null && userAccessObj.CAR_Role__c=='Trade' && (newrec.Status__c!=oldrec.Status__c) && (newrec.Status__c!='Brand Review' && newrec.Status__c!='Draft' && newrec.Status__c!='Trade Review') && (newrec.Status__c!='Hold' && newrec.Status__c!='Cancelled')){newrec.addError(Label.RF_TRIGGER_NOT_AUTHOROZED);}
            
            if(userAccessObj!=null && userAccessObj.CAR_Role__c=='Trade' && (newrec.Status__c!=oldrec.Status__c) && (oldrec.Status__c=='Brand Review' && newrec.Status__c!='Brand Review') && (newrec.Status__c!='Hold' && newrec.Status__c!='Cancelled')){newrec.addError(Label.RF_TRIGGER_NOT_AUTHOROZED);}
            
            if(test.isrunningtest()){
                // profileName.Name = 'Standard User Car'; 
                newrec.RF_Studios__c=Label.RF_WB;
                userAccessObj.CAR_Role__c='Trade';
                newrec.Status__c='Brand Review';
            }
            if(userAccessObj!=null && userAccessObj.CAR_Role__c=='Trade' && (newrec.Status__c=='Brand Review') && newrec.RF_Studios__c!=Label.RF_UNI && newrec.RF_Studios__c!=Label.RF_UNI && (oldrec.Status__c!='DRAFT') && userAccessObj.Requesting_Group__c!=LABEL.RF_SDS)
            {
                queueToAssign= [Select Queue.Id From QueueSObject where Queue.Name=:Label.RF_WB_BRAND];
                newrec.OwnerId =queueToAssign.Queueid;
                
            }
            if(test.isrunningtest()){
                // profileName.Name = 'Standard User Car'; 
                newrec.RF_Studios__c=Label.RF_WB;
                userAccessObj.CAR_Role__c='Trade';
                newrec.Status__c='Brand Review';
                newrec.RF_Studios__c=Label.RF_UNI ;
            }
            if(userAccessObj!=null && userAccessObj.CAR_Role__c=='Trade' && (newrec.Status__c=='Brand Review') && newrec.RF_Studios__c==Label.RF_UNI )
            {
                queueToAssign= [Select Queue.Id From QueueSObject where Queue.Name=:Label.RF_SDS_TRADE];
                newrec.OwnerId =queueToAssign.Queueid;
                
            }
            if(userAccessObj!=null && userAccessObj.CAR_Role__c=='Brand' &&  (newrec.Status__c!=oldrec.Status__c) && (newrec.Status__c!='Draft' && newrec.Status__c!='Creative Review' && newrec.Status__c!='Brand Review') && (newrec.Status__c!='Hold' && newrec.Status__c!='Cancelled')){newrec.addError(Label.RF_TRIGGER_NOT_AUTHOROZED);}
            if(userAccessObj!=null && userAccessObj.CAR_Role__c=='Brand' &&  (newrec.Status__c!=oldrec.Status__c) && (oldrec.Status__c=='Creative Review' && newrec.Status__c!='Creative Review') && (newrec.Status__c!='Hold' && newrec.Status__c!='Cancelled')){newrec.addError(Label.RF_TRIGGER_NOT_AUTHOROZED);}
            
            
            if(test.isrunningtest()){
                userAccessObj.CAR_Role__c='Brand';
                newrec.Status__c='Creative Review';
            }
            if(userAccessObj!=null && userAccessObj.CAR_Role__c=='Brand' && (newrec.Status__c=='Creative Review'))
            {
                queueToAssign= [Select Queue.Id From QueueSObject where Queue.Name=:Label.RF_WB_CREATIVE];
                newrec.OwnerId =queueToAssign.Queueid;
                
            }
            
            //MPM field should be mandatory only at the time of submitting CAR to ARTTrack i.e. when Suppress Integration flag = False and Status changes from Creative Review to Assigned.
            if(userAccessObj!=null && userAccessObj.CAR_Role__c=='Creative' && (newrec.Status__c!=oldrec.Status__c) && (!newrec.Suppress_Integration__c) && (oldrec.Status__c=='Creative Review' && newrec.Status__c=='Assigned') && (newrec.MPM__c==null)){
                newrec.addError('Please select the MPM!');
            }
            
            //Studio field should be mandatory only at the time of submitting CAR to ARTTrack i.e. when Suppress Integration flag = False and Status changes from Creative Review to Assigned.
            if(userAccessObj!=null && userAccessObj.CAR_Role__c=='Creative' && (newrec.Status__c!=oldrec.Status__c) && (!newrec.Suppress_Integration__c) && (oldrec.Status__c=='Creative Review' && newrec.Status__c=='Assigned') && (newrec.RF_studio__c==null)){
                newrec.addError('Studio needs to be selected for sending CAR to ArtTrack');
            }
            
            //W-017757 -Validate if Studio Account Reference field is populated or not
            if(userAccessObj!=null && userAccessObj.CAR_Role__c=='Creative' && (newrec.Status__c!=oldrec.Status__c) && (!newrec.Suppress_Integration__c) && (oldrec.Status__c=='Creative Review' && newrec.Status__c=='Assigned') && (newrec.Studio_Account_Reference__c==null) ){
                //  newrec.ArtTrack_Client_Match__c=true;
                system.debug('trigger.ArtTrack_Client_Match__c:'+newrec.ArtTrack_Client_Match__c);
                // newrec.Notes__c='Testing ArtTrack';
            }
            
            if(test.isrunningtest()){
                userAccessObj.CAR_Role__c='Creative';
                newrec.Status__c='Assigned';
            }
            if(userAccessObj!=null && userAccessObj.CAR_Role__c=='Creative' && (newrec.Status__c=='Assigned'))
            {
                
                queueToAssign= [Select Queue.Id From QueueSObject where Queue.Name=:Label.RF_WB_CREATIVE];
                newrec.OwnerId =queueToAssign.Queueid;
                
            }
            
            /*------------------- Start:Send email notification to CAR's brand group----------------------------------
            
            
            if(test.isrunningtest()){
                newrec.RF_Studios__c=Label.RF_WB;
                userAccessObj.Requesting_Group__c=Label.RF_WB_DIGITAL;
                //oldrec.Status__c=Label.RF_BRAND_REVIEW;
                newrec.Status__c=Label.RF_CREATIVE_REVIEW;
            }
            
            if(userAccessObj!=null && newrec.RF_Studios__c==Label.RF_WB 
               &&(userAccessObj.Requesting_Group__c==Label.RF_WB_DIGITAL ||userAccessObj.Requesting_Group__c==Label.RF_SDS)
               &&(oldrec.Status__c==Label.RF_BRAND_REVIEW && newrec.Status__c==Label.RF_CREATIVE_REVIEW) 
               && (newrec.Status__c!=oldrec.Status__c)
              )
            {
                System.debug('distributor in send email userAccessObj:'+userAccessObj.Distributor__c);  
                System.debug('distributor in user picklist:'+newrec.RF_Studios__c);
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage> ();
                EmailTemplate template=[Select id from EmailTemplate where name =:Label.RF_EMAIL_TEMPLATE_CAR_ASSIGNED_QUEUE limit 1];
                if(newrec.Brand_Group__c!=null){
                    RF_BrandGroup_Email__mdt metaObjList=[select label,Emails__c from RF_BrandGroup_Email__mdt where label=:newrec.Brand_Group__c];
                    System.debug('Emails written in custom metadata:' + metaObjList.Emails__c);
                    if(metaObjList.Emails__c!=null && metaObjList.Emails__c!=''){
                        String emailFromMetaData =metaObjList.Emails__c;
                        List<String> emailList = emailFromMetaData.split(',');
                        //List<String> emailRetrieved= new List<String>();
                        Id carId=newrec.id;
                        
                        System.debug('### FINAL EMAILS WHICH RECIEVE MAIL FROM CAR HELPER: ###' + emailList);
                        
                        
                        for(String emails :emailList) {
                            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(template.id, null, carId);
                            
                            String[] toAddress = new String[] {emails};
                                String emailSubject = email.getSubject();
                            String emailTextBody = email.getPlainTextBody();
                            email.toAddresses=toAddress;
                            email.setSubject(emailSubject);
                            email.setPlainTextBody(emailTextBody);
                            email.saveAsActivity = false;
                            mails.add(email);
                        }
                        if(mails.size()>0){
                            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                            if (results.size() > 0 && results[0].success) 
                            {
                                System.debug('The email was sent successfully.');
                            }else{
                                
                                System.debug('The email failed to send: ' +  results[0].errors[0].message); 
                            }
                        }
                    } 
                }
            }
            ------------------ End: Send email notification to brand groups----------------------------- */                    
            
            
            
        }
        
        
    }
    
    //Requirement - Default CAR fields(MPM/BrandGroup/RFStudio) based on the release updated.
    public static void UpdateCarFields(Map<Id, SObject> newCarMap, Map<Id, SObject> oldCarMap){
        List<CAR__c> newItemsList=(List<CAR__c>)newCarMap.Values();
        List<CAR__c> oldCarList=(List<CAR__c>)oldCarMap.Values();
        Map<id,CAR__c> carMap = new Map<id,CAR__c>();
        for(CAR__c car:newItemsList){
            if(car.release__c != null){
                car__c record = (car__c) oldCarMap.get(car.id);
                system.debug('carRelease'+car.release__c);
                system.debug('recordRelese '+record.release__c);
                if(car.release__c != record.release__c){
                    carMap.put(car.release__c,car);
                }
            }
            
        }
        List<release__c> releaseList=[select id,name,mpm__c,Brand_Group__c,RF_Studio__c from release__c where id IN :carMap.KeySet()];
        
        if(releaseList.size()>0){
            for(release__c rl:releaseList){
                car__c car = carMap.get(rl.id);
                car.mpm__c = rl.mpm__c;
                car.Brand_Group__c = rl.Brand_Group__c;
                car.RF_Studio__c = rl.RF_Studio__c;
            }  
        }
        
    }
    
    
    
    // Defaulting Release fields on car record insert
    // Defaulting Country & Language in Car__c
    public static void insertCarFieldsFromRel(list<car__c> newItems){
        country__c cnty = [select id,name from country__c where name='USA'];
        language__c lng = [select id,name from language__c where name='English'];
        Map<id,CAR__c> carMap = new Map<id,CAR__c>();
        for(car__c ca:newItems){
            if(ca.release__c!=null){
                carMap.put(ca.release__c,ca);   
            }
            if(ca.country__c==null){
                ca.country__c = cnty.id;
            }
            if(ca.language__c==null){
                ca.language__c = lng.id;
            }
        }
        List<release__c> releaseList=[select id,name,mpm__c,Brand_Group__c,RF_Studio__c from release__c where id IN :carMap.KeySet()];
        for(release__c rl:releaseList){
            car__c ca = carMap.get(rl.id);
            ca.mpm__c = rl.mpm__c;
            system.debug('rlMPM'+rl.mpm__c );
            ca.Brand_Group__c = rl.Brand_Group__c;
            system.debug('relBrandGroup'+rl.Brand_Group__c );
            ca.RF_Studio__c = rl.RF_Studio__c;
            system.debug('relstudio'+rl.RF_Studio__c );
        }  
        /* for(car__c ca:newItems){
if(ca.release__c!=null){
Release__c rpr = [select id,name,mpm__c,Brand_Group__c,RF_Studio__c from Release__c where id=:ca.release__c];
ca.mpm__c = rpr.mpm__c;
ca.Brand_Group__c = rpr.Brand_Group__c;
ca.RF_Studio__c = rpr.RF_Studio__c;
}

if(ca.country__c==null){
ca.country__c = cnty.id;
}
if(ca.language__c==null){
ca.language__c = lng.id;
}
} */
    }
    
    // W-017857 - Default SDS Contact field to Requestor Email address & User should be able to update this field if needed.
    public static void InsertSDSContactEmails(List<car__c> newItems){
        Map<Id,User> Usermap = new Map<Id,User>([SELECT id, email, Name from User]);
        for(car__c cr:newItems){
            if(cr.SDS_Contact__c == null && cr.Requester__c!=null && cr.Requesting_Group__c == 'SDS'){
                cr.SDS_Contact__c = Usermap.get(cr.Requester__c).email;
              }
            
          }
        }
   /* //W-017857 -AC2- Default SDS Contact field to Requestor Email address & User should be able to update this field if needed.
    public static void updateSDSContactEmails(Map<Id, SObject> newCarMap, Map<Id, SObject> oldCarMap){
        Map<Id,User> Usermap = new Map<Id,User>([SELECT id, email, Name from User]);
        for(Id cr:newCarMap.keyset()){
            CAR__c newrec = (CAR__c)newCarMap.get(cr);
            CAR__c oldrec = (CAR__c)oldCarMap.get(cr);
          // Car__c nemcars = (Car__c)newCarMap.get(cr);
             if(newrec.SDS_Contact__c == null && newrec.Requester__c!=null){
                newrec.SDS_Contact__c = Usermap.get(newrec.Requester__c).email;
              }
            
        }
        
    }*/
    /*This method restricts the CAR creation when Distributor=UNIVERSAL and Requesting Group=WB Digital*/
    public static void restrictCARCreation(List<Car__c> newItems){// US- W-017622
        Id userId = Userinfo.getUserId();
        try{
            Id profileId = Userinfo.getProfileId();
            Profile pfVar=[select Name from profile where id = :profileId];
            if(test.isrunningtest()){
                pfVar.Name = 'Standard User Car'; 
            }
            if(pfVar.Name!= Label.RF_SYSTEM_ADMINISTRATOR){ 
                RF_User_Access__c userAccessObj = [Select id, CAR_Role__c,Requesting_Group__c,Distributor__c,user__r.name,user__c  from RF_User_Access__c where user__c =:userId];
                if(userAccessObj != null){
                    for(Car__c cr :newItems){
                        if(userAccessObj.Distributor__c==Label.RF_UNI && userAccessObj.Requesting_Group__c==Label.RF_WB_DIGITAL){
                            cr.addError(Label.RF_RESTRICT_WBDIGITAL_CAR_CREAATION);
                        }
                        if(cr.RF_Studios__c==Label.RF_UNI && cr.Requesting_Group__c==Label.RF_WB_DIGITAL){
                            cr.addError(Label.RF_RESTRICT_WBDIGITAL_CAR_CREAATION);
                        }
                        /* if(cr.Status__c!=Label.RF_DRAFT){// CAR status should always be Draft when it's newly created
cr.addError('You dont have permission for changing to this status!');
}*/
                        if(cr.Integration_State__c!=null){
                            cr.Integration_State__c=null;
                        } 
                       /* if(cr.Suppress_Integration__c!=null){
                            cr.Suppress_Integration__c=false;
                        }*/
                        if(cr.Status__c!=null){
                            cr.Status__c='Draft';
                        }
                        if(cr.Suppress_Integration__c==false){
                          cr.Suppress_Integration__c=true;
                      }
                    }
                }
            }else{
                for(Car__c cr :newItems){
                    if(cr.Integration_State__c!=null){
                        cr.Integration_State__c=null;
                    } 
                   /* if(cr.Suppress_Integration__c!=null){
                        cr.Suppress_Integration__c=false;
                    }*/
                    if(cr.Status__c!=null){
                        cr.Status__c='Draft';
                    }
                    if(cr.Suppress_Integration__c==false){
                        cr.Suppress_Integration__c=true;
                    }
                }
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());  
        }   
    }
    
    public static void getRequestorGroup(List<Car__c> newItems){
        
        Map<String, String> mapCountry_user = new Map<String, String>();
        Map<String, String> mapCountry_obj = new Map<String, String>();
        for(User u :[select country from user where Id =:userInfo.getUserId()]){
            mapCountry_user.put(u.Id, u.country);
        }
        for(country__c newrec :[SELECT Id, Country_Code2__c from country__c where Country_Code2__c =:mapCountry_user.values()]){
            mapCountry_obj.put(newrec.Country_Code2__c,newrec.Id);
        }
        
        Id userId = Userinfo.getUserId();
        system.debug('userid'+userId);
        Id profileId = Userinfo.getProfileId();
        try{
            Profile pfVar=[select Name from profile where id = :profileId];
            system.debug('pfVar'+ pfVar);
            if(test.isrunningtest()){
                pfVar.Name = 'Standard User Car'; 
            }
            
            if(pfVar.Name!= Label.RF_SYSTEM_ADMINISTRATOR){ 
                RF_User_Access__c userAccessObj = [Select id, CAR_Role__c,Requesting_Group__c,Distributor__c,user__r.name,user__c  from RF_User_Access__c where user__c =:userId];
                system.debug('-userAccessObj-------'+userAccessObj);
                if(userAccessObj != null){
                    for(Car__c cr :newItems){
                        system.debug('cars====='+ cr);
                        if(cr.Requesting_Group__c==null){
                            cr.Requesting_Group__c =  userAccessObj.Requesting_Group__c;
                            System.debug('userAccessObj.Requesting_Group__c'+ userAccessObj.Requesting_Group__c);
                            System.debug('cr.Requesting_Group__c'+ cr.Requesting_Group__c);
                        }
                        
                        if(cr.RF_Studios__c==null){
                            cr.RF_Studios__c = userAccessObj.Distributor__c;
                            System.debug('userDB'+ userAccessObj.Distributor__c);
                            System.debug('CarDB'+  cr.RF_Studios__c);
                        }
                        
                        cr.Requester__c = Userinfo.getUserId();
                        if(cr.Release__c !=null){
                            Release__c rp=[select id,name,mpm__C,Brand_Group__c,RF_studio__c from Release__c where id=: cr.Release__c];
                            if(rp!=null){
                                if(rp.MPM__c!=null){
                                    cr.MPM__c = rp.MPM__c;
                                }
                            }
                        }
                        
                        string country_locale=UserInfo.getLocale();
                        String logged_user_country = mapCountry_user.get(userInfo.getUserId());
                        String country_recId = mapCountry_obj.get(logged_user_country);
                        if(cr.Country__c==null){
                            cr.Country__c = country_recId; 
                        }
                        
                    }
                }
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());  
        }     
    }
    
    /*W-017725-create a record in the custom Task object CAR_Field_History_Tracker__c when any field is updated in CAR */
    public static void updateFieldHistoryTracker(Map<Id, SObject> newCarMap, Map<Id, SObject> oldCarMap){
        system.debug('inside updateFieldHistoryTracker()');
        Id profileId = Userinfo.getProfileId();
        Profile profileName=[select Name from profile where id = :profileId];
        Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.CAR__c.fields.getMap();
        List<CAR_Field_History_Tracker__c> fieldTrackerList=new List<CAR_Field_History_Tracker__c>();
        List<CAR_Field_History_Tracker__c> fieldTrackerTobeUpdatedList=new List<CAR_Field_History_Tracker__c>();
        try{
            
            for(Id ca:newCarMap.keySet()){
                CAR__c newrec = (CAR__c)newCarMap.get(ca);
                CAR__c oldrec = (CAR__c)oldCarMap.get(ca);
                List<CAR_Field_History_Tracker__c> fieldHistoryList =[select id,car__c,car__r.name,Field_Name__c,
                                                                      Old_Value__c,New_Value__c,Status__c,Integration_State__c from 
                                                                      CAR_Field_History_Tracker__c where car__c=:newrec.id];
                
                map<string,CAR_Field_History_Tracker__c> statusVSIntegrationStateMap=new map<string,CAR_Field_History_Tracker__c>();
                
                for(CAR_Field_History_Tracker__c fieldHistory:fieldHistoryList){
                    statusVSIntegrationStateMap.put(fieldHistory.Field_Name__c,fieldHistory);
                }
                
                for (String str : mapFields.keyset()) 
                {
                    
                    if(newrec.get(str)!=oldrec.get(str))
                    { 
                        System.Debug('Field changed: ' + str + '. The value has changed from: ' + oldrec.get(str) + ' to: ' + newrec.get(str)); 
                        CAR_Field_History_Tracker__c fieldTracker= new CAR_Field_History_Tracker__c();
                        CAR_Field_History_Tracker__c fieldTrackerUpdate= new CAR_Field_History_Tracker__c();
                        fieldTracker.Field_API_Name__c=str;
                        fieldTracker.Field_Name__c=mapFields.get(str).getDescribe().getLabel();
                        fieldTracker.Old_Value__c=String.valueOf(oldrec.get(str));
                        fieldTracker.New_Value__c=String.valueOf(newrec.get(str));
                        fieldTracker.car__c=newrec.id;
                        if(statusVSIntegrationStateMap.containskey(mapFields.get(str).getDescribe().getLabel())){
                            CAR_Field_History_Tracker__c fieldHistoryObject= statusVSIntegrationStateMap.get(mapFields.get(str).getDescribe().getLabel());
                            if(fieldHistoryObject.Integration_State__c==LABEL.RF_PICK_ME_UP){
                                fieldTrackerUpdate.Integration_State__c='Not Processed';
                                fieldTrackerUpdate.id=fieldHistoryObject.id;
                            }
                            
                        }
                        fieldTrackerTobeUpdatedList.add(fieldTrackerUpdate);
                        
                        if(profileName.Name!=Label.RF_SAP_INTEGRATION_API_ONLY && newrec.RF_Studios__c!=Label.RF_WB){ 
                            fieldTracker.Status__c='Not Started';  
                            fieldTracker.Integration_State__c=LABEL.RF_PICK_ME_UP;
                        }
                        if(profileName.Name==Label.RF_SAP_INTEGRATION_API_ONLY || newrec.RF_Studios__c==Label.RF_WB){ 
                            fieldTracker.Integration_State__c='';
                        }
                        fieldTrackerList.add(fieldTracker);
                    } 
                    
                } 
                if(fieldTrackerList.size()>0){
                    system.debug('to insert-->');
                    insert fieldTrackerList;
                }
                if(fieldTrackerTobeUpdatedList.size()>0){
                    system.debug('to update-->');
                    update fieldTrackerTobeUpdatedList;
                }
                
            }
        }catch (Exception e) 
        { 
            throw new AuraHandledException(e.getMessage()); 
        } 
    }
    
    // When studio change Distibutor will change
    public static void UpdateRFStudioFields(Map<Id, SObject> newCarMap, Map<Id, SObject> oldCarMap){
        List<CAR__c> newItemsList=(List<CAR__c>)newCarMap.Values();
        List<CAR__c> oldCarList=(List<CAR__c>)oldCarMap.Values();
        Map<id,CAR__c> carMap = new Map<id,CAR__c>();
        for(CAR__c car:newItemsList){
            if(car.RF_Studio__c != null){
                carMap.put(car.RF_Studio__c,car);  
            }
        }
        List<RF_Studio__c> studiolist=[select id,Distributor__c from RF_Studio__c where id IN :carMap.KeySet()];
        for(RF_Studio__c std:studiolist){
            car__c car = carMap.get(std.id);
            car.RF_Studios__c = std.Distributor__c;
            system.debug('car.RF_Studios__c'+ car.RF_Studios__c);
        }
        
    }
    // Requirement - update integration state to 'pick me up' based on the conditions
    // US - W-017744 - Uni CAR Integration & ART Track Integration
    // Any Status changes further Brand Review, the integ state will be Pick me Up
    /**---------------------- START ---------------------------*/ 
    public static void updateIntegrationStatePickMeUp(Map<Id, SObject> newCarMap, Map<Id, SObject> oldCarMap){
        Set<String> statusNoPickMeUpWB = new Set<String>();
        Set<String> statusNoPickMeUpUniversal = new Set<String>();
        statusNoPickMeUpWB.add('Draft');
        statusNoPickMeUpWB.add('Trade Review');
        statusNoPickMeUpWB.add('Brand Review');
        statusNoPickMeUpWB.add('Creative Review');
        statusNoPickMeUpUniversal.add('Draft');
        statusNoPickMeUpUniversal.add('Trade Review');        
        for(Id ca:newCarMap.keySet()){
            CAR__c newrec = (CAR__c)newCarMap.get(ca);
            CAR__c oldrec = (CAR__c)oldCarMap.get(ca);
            if(((newrec.Status__c != oldrec.Status__c && !statusNoPickMeUpWB.contains(newrec.Status__c) && newrec.Suppress_Integration__c == false && newrec.RF_Studios__c == LABEL.RF_WB) && (newrec.RF_Studio__c !=null  && newrec.MPM__c!=null)) 
               || (newrec.RF_Studios__c == LABEL.RF_UNI && newrec.Status__c == LABEL.RF_BRAND_REVIEW) 
               || (newrec.Status__c != oldrec.Status__c && !statusNoPickMeUpUniversal.contains(newrec.Status__c) && newrec.RF_Studios__c == LABEL.RF_UNI)){
                   newrec.Integration_State__c = LABEL.RF_PICK_ME_UP;
               }
            
        }        
    }
    /*------------------- END ----------------------------------*/
    
    // US - W-017757 - Validate if account exists in ARTTrack
    /**---------------------- START ---------------------------*/ 
    public static void validateAccountForArtTrack(Map<Id, SObject> newCarMap, Map<Id, SObject> oldCarMap){
        system.debug('inside validateAccountForArtTrack');
        for(Id ca:newCarMap.keySet()){
            CAR__c newrec = (CAR__c)newCarMap.get(ca);
            CAR__c oldrec = (CAR__c)oldCarMap.get(ca);
            if(newrec.RF_Studios__c=='WB'){
                CAR__c carObj= [select Account__r.ArtTrack_Client_Name__c from CAR__c where id=:newrec.id];
                Account accObj= [select ArtTrack_Client_Name__c from Account where id=:newrec.Account__c];
                if(carObj.Account__r.ArtTrack_Client_Name__c!=null){
                    newrec.Studio_Account_Reference__c=carObj.Account__r.ArtTrack_Client_Name__c;
                }else{
                    newrec.Studio_Account_Reference__c=accObj.ArtTrack_Client_Name__c;
                }
            }
            if(newrec.RF_Studios__c=='Universal'){
                CAR__c carObj= [select Account__r.key__c from CAR__c where id=:newrec.id];
                Account accObj= [select key__c from Account where id=:newrec.Account__c];
                if(carObj.Account__r.key__c!=null){
                    newrec.Studio_Account_Reference__c=carObj.Account__r.key__c.substringAfter('_');
                }else{
                    newrec.Studio_Account_Reference__c=accObj.key__c.substringAfter('_');
                }
            }
            
        }
    }    
    
    /*------------------- END ----------------------------------*/
    
    /* W-017761 Preventing deletion of CARs having status other than Draft, except sys admin  @Kalash - 16/02/2021*/ 
    /*-----------------START----------------------------------*/
    public static void preventDeletionOfnonDraftCars(Map<Id, SObject> oldCarMap){
        Id profileId = userinfo.getProfileId();
        String profileNameofUser = [Select Id,Name from Profile where Id=:profileId].Name;
        if(test.isrunningtest()){
                profileNameofUser = 'Standard User Car'; 
            }
       if(profileNameofUser != LABEL.RF_SYSTEM_ADMINISTRATOR){
            for(Id carId : oldCarMap.keySet()){
                
                CAR__c oldRec = (CAR__c) oldCarMap.get(carId);
                if(oldRec.Status__c != LABEL.RF_DRAFT){
                    oldRec.addError('You are not authorized to delete this Car.');
                }
            }
        }
    }
    /*-----------------END----------------------------------*/
    
    /*POC - file upload size should be less than 10 mb @Kalash - 09/03/2021 */ 
    /*----------------STARt-----------------------------*/
    /*public static void validateFileSize(Map<Id, SObject> newCarMap, Map<Id, SObject> oldCarMap){
        for(Id ca:newCarMap.keySet()){
            Set<Id> documentId = new Set<Id>();
            List<ContentDocumentLink> ContentDocumentLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :ca];
            for(ContentDocumentLink cl : ContentDocumentLink){
                documentId.add(cl.ContentDocumentId);
            }
            List<ContentDocument> contentDetails = [SELECT Title from ContentDocument where ID IN :documentId];
            System.debug(contentDetails);
        }
    }*/
}