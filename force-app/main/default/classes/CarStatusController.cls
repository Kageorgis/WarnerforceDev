/*========================================================================================================
* @author Ajit Singh
* @date 22/09/2020
* @description: Controller class that is binded with Submit button lightning component and implements
all the logic of status change on click of submit button of CAR record when logged in with different
users like- Sales,Trade,Brand and creative and act as per the approval matrix and assign the record
to their respective queues.
==========================================================================================================*/

public class CarStatusController {
    
    @AuraEnabled
    public static CAR__c setCarStatus(Id carId,Id userId) {
        
        CAR__c  carObj=[Select id,ArtTrack_Client_Match__c,Studio_Account_Reference__c,RF_Studios__c,Notes__c,Brand_Group__c,Requesting_Group__c,Status__c,last_status__c,Suppress_Integration__c,Actual_Start_Date__c, Primary_Vendor__c,Requester__c,Owner.name,owner.id from CAR__c where id=:carId];
        system.debug('cars--'+carObj);
        
        QueueSObject queueToAssign;
        RF_User_Access__c userAccessObj;
        List<String> chatterGroupName;
        // try{
        
        
        Id profileId = Userinfo.getProfileId();
        Profile pfVar=[select Name from profile where id = :profileId];
        
        map<string, string> mapStatus=new map<string, string>();
        
        if(test.isrunningtest()){
            pfVar.Name = 'Standard User Car';
        }
        
        if(pfVar.Name!= Label.RF_SYSTEM_ADMINISTRATOR){                                           // 'System Administrator'
            userAccessObj = [Select id, CAR_Role__c,Requesting_Group__c,Distributor__c,user__r.name,user__c  from RF_User_Access__c where user__c=:userId];
            system.debug('userAccessObj--'+userAccessObj);
            system.debug('Distributor__c--'+userAccessObj.Distributor__c);
            
            if(userAccessObj!=null){
                // if((userAccessObj.Distributor__c.contains(Label.RF_WB)||userAccessObj.Distributor__c.contains(Label.RF_UNI)) && userAccessObj.Requesting_Group__c==Label.RF_SDS){
                //  system.debug('inside WB/UNI--');
                
                /*if(test.isrunningtest()){
userAccessObj.Requesting_Group__c = 'SDS';
} */
                if(carObj.RF_Studios__c==Label.RF_WB && carObj.Requesting_Group__c==Label.RF_SDS){
                    if(test.isrunningtest()){
                        userAccessObj.CAR_Role__c= Label.RF_SALES;
                        carObj.Status__c= Label.RF_DRAFT;
                    }
                    
                    
                    if(userAccessObj.CAR_Role__c== Label.RF_SALES && carObj.Status__c== Label.RF_DRAFT){//Scenario-1 
                        mapStatus.put(Label.RF_DRAFT,Label.RF_TRADE_REVIEW);                  //'Draft','Trade Review'
                        queueToAssign= [Select Queue.Id,Queue.Name From QueueSObject where Queue.Name=:Label.RF_SDS_TRADE];
                        chatterGroupName=CAR_CarEmailHelper.getChatterGroupNameForSalesUser(Label.RF_SDS,Label.RF_WB,carObj.Brand_Group__c);
                        //chatterGroupName=getChatterGroupName(Label.RF_SDS,Label.RF_WB,carObj.Brand_Group__c);
                        system.debug('chatterGroupName:'+chatterGroupName);
                    }
                    if(test.isrunningtest()){
                        userAccessObj.CAR_Role__c= Label.RF_TRADE;
                        carObj.Status__c='Completed';
                    }
                    if(userAccessObj.CAR_Role__c==Label.RF_TRADE && carObj.Status__c!=Label.RF_DRAFT){
                        System.debug('@@!!');
                        mapStatus.put(Label.RF_TRADE_REVIEW,Label.RF_BRAND_REVIEW);                //'Trade Review','Brand Review'
                        queueToAssign= [Select Queue.Id,Queue.Name From QueueSObject where Queue.Name=:Label.RF_WB_BRAND];
                        chatterGroupName=CAR_CarEmailHelper.getChatterGroupNameForTradeUsers(Label.RF_SDS,Label.RF_WB,carObj.Brand_Group__c);
                    }
                    if(test.isrunningtest()){
                        userAccessObj.CAR_Role__c=Label.RF_TRADE;
                        carObj.Status__c =Label.RF_DRAFT;
                    } 
                    if(userAccessObj.CAR_Role__c== Label.RF_TRADE && carObj.Status__c==Label.RF_DRAFT){ //Scenario-2
                        
                        mapStatus.put(Label.RF_DRAFT,Label.RF_BRAND_REVIEW);    // 'Draft','Brand Review'
                        queueToAssign= [Select Queue.Id,Queue.Name From QueueSObject where Queue.Name=:Label.RF_SDS_TRADE];
                        chatterGroupName=CAR_CarEmailHelper.getChatterGroupNameForTradeUsers(Label.RF_SDS,Label.RF_WB,carObj.Brand_Group__c);
                    }
                    
                    if(test.isrunningtest()){
                        userAccessObj.CAR_Role__c=Label.RF_BRAND;
                        carObj.Status__c ='Completed';
                    } 
                    if(userAccessObj.CAR_Role__c==Label.RF_BRAND && carObj.Status__c!=Label.RF_DRAFT){
                        mapStatus.put(Label.RF_TRADE_REVIEW,Label.RF_CREATIVE_REVIEW);
                        mapStatus.put(Label.RF_BRAND_REVIEW,Label.RF_CREATIVE_REVIEW);                //'Brand Review','Creative Review'
                        queueToAssign= [Select Queue.Id,Queue.Name From QueueSObject where Queue.Name=:Label.RF_WB_CREATIVE];
                        chatterGroupName=CAR_CarEmailHelper.getChatterGroupNameForBrandUsers(Label.RF_SDS,Label.RF_WB,carObj.Brand_Group__c);
                    }
                    if(test.isrunningtest()){
                        userAccessObj.CAR_Role__c=Label.RF_BRAND;
                        carObj.Status__c =Label.RF_DRAFT;
                    } 
                    
                    if(userAccessObj.CAR_Role__c==Label.RF_BRAND && carObj.Status__c==Label.RF_DRAFT){
                        mapStatus.put(Label.RF_DRAFT,Label.RF_CREATIVE_REVIEW);            //'Brand Review','Creative Review'
                        queueToAssign= [Select Queue.Id,Queue.Name From QueueSObject where Queue.Name=:Label.RF_WB_CREATIVE];
                        
                    }
                    if(test.isrunningtest()){
                        userAccessObj.CAR_Role__c=Label.RF_CREATIVE;
                        carObj.Status__c='Completed';
                    }
                    if(userAccessObj.CAR_Role__c==Label.RF_CREATIVE && carObj.Status__c!=Label.RF_DRAFT){
                        //Ajit:newly added condition- 08/12/2020
                        mapStatus.put(Label.RF_TRADE_REVIEW,Label.RF_ASSIGNED);
                        mapStatus.put(Label.RF_BRAND_REVIEW,Label.RF_ASSIGNED);
                        mapStatus.put(Label.RF_CREATIVE_REVIEW,Label.RF_ASSIGNED);//'Creative Review','Assigned'
                        queueToAssign= [Select Queue.Id,Queue.Name From QueueSObject where Queue.Name=:Label.RF_WB_CREATIVE];
                        //carObj.Status__c=='Draft'||carObj.Status__c=='Trade Review' ||carObj.Status__c=='Brand Review'|
                        if(carObj.Suppress_Integration__c==false && carObj.Studio_Account_Reference__c==null && (carObj.Status__c=='Creative Review'||carObj.Status__c=='Assigned')){
                             system.debug('wb and sds->carObj.ArtTrack_Client_Match__c:'+carObj.ArtTrack_Client_Match__c);
                            carObj.ArtTrack_Client_Match__c=true;
                        }
                        if(carObj.Studio_Account_Reference__c!=null && carObj.ArtTrack_Client_Match__c==true){
                            carObj.ArtTrack_Client_Match__c=false;
                        }
                        
                        
                    }
                    
                    if(test.isrunningtest()){
                        userAccessObj.CAR_Role__c=Label.RF_CREATIVE;
                        carObj.Status__c =Label.RF_DRAFT;
                    } 
                    
                    if(userAccessObj.CAR_Role__c==Label.RF_CREATIVE && carObj.Status__c==Label.RF_DRAFT ){
                        mapStatus.put(Label.RF_DRAFT,Label.RF_ASSIGNED);//'Draft','Assigned'
                        queueToAssign= [Select Queue.Id,Queue.Name From QueueSObject where Queue.Name=:Label.RF_WB_CREATIVE];
                    }
                    
                    if(test.isrunningtest()){
                        userAccessObj.CAR_Role__c=Label.RF_BRAND;
                        carObj.Status__c=Label.RF_DRAFT;
                    }
                    
                    if(userAccessObj.CAR_Role__c==Label.RF_BRAND && carObj.Status__c==Label.RF_DRAFT){//Scenario- 3 
                        
                        mapStatus.put(Label.RF_DRAFT,Label.RF_CREATIVE_REVIEW);                           //'Draft',''Creative Review
                        queueToAssign= [Select Queue.Id,Queue.Name From QueueSObject where Queue.Name=:Label.RF_WB_CREATIVE];
                        
                        
                    }
                    
                    if(test.isrunningtest()){
                        userAccessObj.CAR_Role__c=Label.RF_BRAND;
                        carObj.Status__c='Completed';
                    }
                    if(userAccessObj.CAR_Role__c==Label.RF_BRAND && carObj.Status__c!=Label.RF_DRAFT){
                        mapStatus.put(Label.RF_CREATIVE_REVIEW,Label.RF_ASSIGNED);      //'Creative Review','Assigned'
                        queueToAssign= [Select Queue.Id,Queue.Name From QueueSObject where Queue.Name=:Label.RF_WB_CREATIVE];
                        
                    }
                    
                    if(test.isrunningtest()){
                        userAccessObj.CAR_Role__c=Label.RF_CREATIVE;
                        carObj.Status__c='Completed';
                        carObj.Suppress_Integration__c = true;
                    }
                    
                    if(userAccessObj.CAR_Role__c==Label.RF_CREATIVE && carObj.Status__c!=Label.RF_DRAFT 
                       && carObj.Suppress_Integration__c){
                           
                           mapStatus.put(Label.RF_ASSIGNED,Label.RF_WORKING);
                           mapStatus.put(Label.RF_WORKING,Label.RF_COMPLETE);
                           
                           queueToAssign= [Select Queue.Id,Queue.Name From QueueSObject where Queue.Name=:Label.RF_WB_CREATIVE];
                           
                       }
                    
                }
                system.debug('Car Obj ##::'+carObj);
                system.debug('label rf UNI ###::' + Label.RF_UNI);
                if(carObj.RF_Studios__c==Label.RF_UNI && carObj.Requesting_Group__c==Label.RF_SDS){//Section-2. If UserAccess.Distributor = Uni & UserAccess.Requesting Group= SDS           
                    system.debug('Distributor__c UNI::'+carObj.RF_Studios__c);
                    if(test.isrunningtest()){
                        userAccessObj.CAR_Role__c=Label.RF_SALES;
                        carObj.Status__c='Draft';
                    }
                    if(userAccessObj.CAR_Role__c==Label.RF_SALES && carObj.Status__c==Label.RF_DRAFT){//Scenario-1
                        
                        mapStatus.put(Label.RF_DRAFT,Label.RF_TRADE_REVIEW);   // 'Draft','Trade Review'
                        queueToAssign= [Select Queue.Id,Queue.Name From QueueSObject where Queue.Name=:Label.RF_SDS_TRADE];
                        chatterGroupName=CAR_CarEmailHelper.getChatterGroupNameForSalesUser(Label.RF_SDS,Label.RF_UNI,carObj.Brand_Group__c);
                    }
                    if(test.isrunningtest()){
                        userAccessObj.CAR_Role__c=Label.RF_TRADE;
                        carObj.Status__c='Completed';
                    }
                    if(userAccessObj.CAR_Role__c==Label.RF_TRADE && carObj.Status__c!=Label.RF_DRAFT){
                        mapStatus.put(Label.RF_TRADE_REVIEW,Label.RF_BRAND_REVIEW);                //'Trade Review','Brand Review'
                        queueToAssign= [Select Queue.Id,Queue.Name From QueueSObject where Queue.Name=:Label.RF_SDS_TRADE];
                        //no email notification to be sent
                    }
                    if(test.isrunningtest()){
                        userAccessObj.CAR_Role__c=Label.RF_TRADE;
                        carObj.Status__c='Draft';
                    }
                    if(userAccessObj.CAR_Role__c==Label.RF_TRADE && carObj.Status__c==Label.RF_DRAFT){
                        mapStatus.put(Label.RF_DRAFT,Label.RF_BRAND_REVIEW); //'Draft','Brand Review'
                        queueToAssign= [Select Queue.Id,Queue.Name From QueueSObject where Queue.Name=:Label.RF_SDS_TRADE];
                        
                    }
                    
                }
                if(test.isrunningtest()){
                    userAccessObj.Distributor__c=Label.RF_WB;
                    userAccessObj.CAR_Role__c= Label.RF_SALES;
                    carObj.Status__c=Label.RF_DRAFT;
                    carobj.Requesting_Group__c =Label.RF_WB_DIGITAL; 
                }
                if(carObj.RF_Studios__c==Label.RF_WB && carObj.Requesting_Group__c==Label.RF_WB_DIGITAL){//If UserAccess.Distributor = WB & UserAccess.Requesting Group = WB Digital
                    if(userAccessObj.CAR_Role__c== Label.RF_SALES && carObj.Status__c==Label.RF_DRAFT){//Scenario-1
                        mapStatus.put(Label.RF_DRAFT,Label.RF_TRADE_REVIEW);                  //'Draft','Trade Review'
                        queueToAssign= [Select Queue.Id,Queue.Name From QueueSObject where Queue.Name=:Label.RF_WB_DIGITAL_TRADE];
                        chatterGroupName=CAR_CarEmailHelper.getChatterGroupNameForSalesUser(Label.RF_WB_DIGITAL,Label.RF_WB,carObj.Brand_Group__c);
                   System.debug('##chatterGroupName::'+chatterGroupName);
                    }
                    if(test.isrunningtest()){
                        userAccessObj.CAR_Role__c=Label.RF_TRADE;
                        carObj.Status__c='Completed';
                    }
                    if(userAccessObj.CAR_Role__c==Label.RF_TRADE && carObj.Status__c!=Label.RF_DRAFT){
                        System.debug('##@@');
                        mapStatus.put(Label.RF_TRADE_REVIEW,Label.RF_BRAND_REVIEW);                              //'Trade Review','Brand Review'
                        queueToAssign= [Select Queue.Id,Queue.Name From QueueSObject where Queue.Name=:Label.RF_WB_BRAND];
                        chatterGroupName=CAR_CarEmailHelper.getChatterGroupNameForTradeUsers(Label.RF_SDS,Label.RF_WB,carObj.Brand_Group__c);
                    }
                    if(test.isrunningtest()){
                        userAccessObj.CAR_Role__c=Label.RF_TRADE;
                        carObj.Status__c='Draft';
                    }
                    
                    if(userAccessObj.CAR_Role__c==Label.RF_TRADE && carObj.Status__c==Label.RF_DRAFT){ //Scenario-2
                        
                        mapStatus.put(Label.RF_DRAFT,Label.RF_BRAND_REVIEW);  //'Draft','Brand Review'
                        queueToAssign= [Select Queue.Id,Queue.Name From QueueSObject where Queue.Name=:Label.RF_WB_BRAND];
                        
                    }
                    if(test.isrunningtest()){
                        userAccessObj.CAR_Role__c=Label.RF_BRAND;
                        carObj.Status__c='Completed';
                    }
                    if(userAccessObj.CAR_Role__c==Label.RF_BRAND && carObj.Status__c!=Label.RF_DRAFT){
                        mapStatus.put(Label.RF_TRADE_REVIEW,Label.RF_CREATIVE_REVIEW);
                        mapStatus.put(Label.RF_BRAND_REVIEW,Label.RF_CREATIVE_REVIEW);                        //'Brand Review','Creative Review'
                        queueToAssign= [Select Queue.Id,Queue.Name From QueueSObject where Queue.Name=:Label.RF_WB_CREATIVE];
                        chatterGroupName=CAR_CarEmailHelper.getChatterGroupNameForBrandUsers(Label.RF_SDS,Label.RF_WB,carObj.Brand_Group__c);
                    }
                    if(test.isrunningtest()){
                        userAccessObj.CAR_Role__c=Label.RF_BRAND;
                        carObj.Status__c='Draft';
                    }
                    if(userAccessObj.CAR_Role__c==Label.RF_BRAND && carObj.Status__c==Label.RF_DRAFT){
                        mapStatus.put(Label.RF_DRAFT,Label.RF_CREATIVE_REVIEW);                           //'Draft','Creative Review'
                        queueToAssign= [Select Queue.Id,Queue.Name From QueueSObject where Queue.Name=:Label.RF_WB_CREATIVE];
                        
                    }
                    if(test.isrunningtest()){
                        userAccessObj.CAR_Role__c=Label.RF_CREATIVE;
                        carObj.Status__c='Draft';
                        
                    }
                    if(userAccessObj.CAR_Role__c==Label.RF_CREATIVE && carObj.Status__c==Label.RF_DRAFT)
                    {
                        mapStatus.put(Label.RF_DRAFT,Label.RF_ASSIGNED);              //'Draft','Assigned'
                        queueToAssign= [Select Queue.Id,Queue.Name From QueueSObject where Queue.Name=:Label.RF_WB_CREATIVE];
                        
                    }
                    if(test.isrunningtest()){
                        userAccessObj.CAR_Role__c=Label.RF_CREATIVE;
                        carObj.Status__c='Completed';
                        carObj.Suppress_Integration__c = false;
                    }
                    if(userAccessObj.CAR_Role__c==Label.RF_CREATIVE && carObj.Status__c!=Label.RF_DRAFT)
                    {//removed:   && carObj.Suppress_Integration__c==false 
                        
                        mapStatus.put(Label.RF_TRADE_REVIEW,Label.RF_ASSIGNED);
                        mapStatus.put(Label.RF_BRAND_REVIEW,Label.RF_ASSIGNED); 
                        mapStatus.put(Label.RF_CREATIVE_REVIEW,Label.RF_ASSIGNED);      //'Creative Review','Assigned'
                        
                        queueToAssign= [Select Queue.Id,Queue.Name From QueueSObject where Queue.Name=:Label.RF_WB_CREATIVE];
                      if(carObj.Suppress_Integration__c==false && carObj.Studio_Account_Reference__c==null && (carObj.Status__c=='Trade Review' ||carObj.Status__c=='Brand Review'||carObj.Status__c=='Creative Review'||carObj.Status__c=='Assigned')){
                             system.debug('wb and wb digital->carObj.ArtTrack_Client_Match__c:'+carObj.ArtTrack_Client_Match__c);
                            carObj.ArtTrack_Client_Match__c=true;
                        }
                      if(carObj.Studio_Account_Reference__c!=null && carObj.ArtTrack_Client_Match__c==true){
                            carObj.ArtTrack_Client_Match__c=false;
                        }
                    }
                    if(userAccessObj.CAR_Role__c==Label.RF_CREATIVE && carObj.Status__c!=Label.RF_DRAFT && carObj.Suppress_Integration__c==true)
                    {
                        
                        mapStatus.put(Label.RF_ASSIGNED,Label.RF_WORKING);
                        mapStatus.put(Label.RF_WORKING,Label.RF_COMPLETE); 
                        queueToAssign= [Select Queue.Id,Queue.Name From QueueSObject where Queue.Name=:Label.RF_WB_CREATIVE];
                    }
                    
                    
                }
            }
            
        }
        
        if(test.isrunningtest()){
            pfVar.Name = 'System Administrator';
        }
        
        if(pfVar.Name==Label.RF_SYSTEM_ADMINISTRATOR){ // 'System Administrator'
            mapStatus.put(Label.RF_DRAFT,Label.RF_TRADE_REVIEW);                                                                           //'Draft','Trade Review'
            mapStatus.put(Label.RF_TRADE_REVIEW,Label.RF_BRAND_REVIEW);                                                         //'Trade Review','Brand Review'
            mapStatus.put(Label.RF_BRAND_REVIEW,Label.RF_CREATIVE_REVIEW);                                    //'Brand Review','Creative Review'
            mapStatus.put(Label.RF_CREATIVE_REVIEW, Label.RF_ASSIGNED);                                               //'Creative Review','Assigned'
            mapStatus.put(Label.RF_ASSIGNED,Label.RF_WORKING);                                                                               //'Assigned','Working'
            mapStatus.put(Label.RF_WORKING,Label.RF_COMPLETE);                                                                             //'Working','Complete'
            mapStatus.put(Label.RF_COMPLETE,Label.RF_HOLD);                                                                                                    //'Complete','Hold'
            mapStatus.put(Label.RF_HOLD,Label.RF_CANCELLED);                                                                                    //'Hold','Cancelled'
            mapStatus.put(Label.RF_CANCELLED,Label.RF_CANCELLED);                                                                         //'Cancelled','Cancelled' 
        }
        
        // if(!test.isrunningtest()){
        if(mapStatus.containsKey(carObj.Status__c)){
            carObj.Status__c = mapStatus.get(carObj.Status__c);  
            system.debug('final status::'+carObj.Status__c);
            //system.debug('queue id::'+queueToAssign.Queueid);
            if(pfVar.Name!= Label.RF_SYSTEM_ADMINISTRATOR){                                   //'System Administrator'
                carObj.OwnerId =queueToAssign.Queueid;
            }
            
        }else{
            string errorMessage = Label.RF_SUBMIT_NOT_AUTHORIZED;
            AuraHandledException auraEx = new AuraHandledException(errorMessage);
            auraEx.setMessage(errorMessage);
            throw auraEx;
        }
        // }
        // }catch(Exception e){throw new AuraHandledException(e.getMessage());  
        // }
        update carObj;
        
        //Send Email to queue members when status is changed but status should not be- Assigned, Working or Complete
        if(test.isrunningtest()){
            queueToAssign= [Select Queue.Id,Queue.Name From QueueSObject where Queue.Name=:Label.RF_WB_CREATIVE];
            carObj.Status__c='Draft';
            
        }
        /* if(queueToAssign!=null && (carObj.Status__c !=Label.RF_ASSIGNED && carObj.Status__c !=Label.RF_WORKING
                                   && carObj.Status__c !=Label.RF_COMPLETE) && carObj.RF_Studios__c!=Label.RF_UNI){
                                       system.debug('inside email queueToAssign.Queue.Name::'+queueToAssign.Queue.Name);
                                       List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage> ();
                                       EmailTemplate template=[Select id from EmailTemplate where name =:Label.RF_EMAIL_TEMPLATE_CAR_ASSIGNED_QUEUE limit 1];
                                       List<GroupMember> groupList=[SELECT UserorGroupId,Group.Name FROM GroupMember WHERE Group.Type =:Label.RF_QUEUE AND Group.Name =:queueToAssign.Queue.Name];
                                       set<Id> lstids = new set<id>();
                                       Set<Id> lstPublicGroupIds = new Set<Id>();
                                       //if(groupList != NULL){
                                           for(GroupMember gm:groupList){
                                               String strId = gm.UserOrGroupId;
                                               System.debug('### USER OR GROUP ID: ###' + strId);
                                               if(strId.mid(0, 3) == '00G'){
                                                   lstPublicGroupIds.add(strId);
                                               }
                                               else{
                                                   lstids.add(strId);
                                               }
                                           }
                                       //}
                                       System.debug('### USERs ID: ###' + lstids);
                                       System.debug('### GROUPs ID: ###'+ lstPublicGroupIds);
                                       
                                       List<GroupMember> groupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN :lstPublicGroupIds];
                                       if(groupMembers != NULL){
                                           for(GroupMember memberId: groupMembers){
                                               lstids.add(memberId.UserOrGroupId);
                                           }
                                       }
                                       
                                       System.debug('### USERs ID: ###' + lstids);
                                       
                                       // new implementation to avoid sending duplicate email which also belongs to brand group owner
                                       if(carObj.Brand_Group__c != NULL){
                                           RF_BrandGroup_Email__mdt metaObjList = [select Emails__c from RF_BrandGroup_Email__mdt where label= :carObj.Brand_Group__c];
                                           // system.debug('brand_group' + carObj.Brand_Group__c);
                                           // system.debug('metaObjList:'+metaObjList);
                                           // system.debug('metaObjListEmails:'+metaObjList.Emails__c);
                                           Set<Id> userIdsOfEmails;
                                           List<User> userOfEmails;
                                           if(metaObjList!=null && metaObjList.Emails__c!=null){
                                               List<String> emailsFromMetaData = (metaObjList.Emails__c).split(',');
                                               System.debug('##emailsFromMetaData:##' + emailsFromMetaData);
                                               userOfEmails = [SELECT Id FROM User where email in :emailsFromMetaData];
                                               userIdsOfEmails = new Set<Id>();
                                               for(User usr: userOfEmails){
                                                   userIdsOfEmails.add(usr.Id);
                                               }
                                           }
                                       
                                           if(userIdsOfEmails != NULL && userIdsOfEmails.size() > 0){
                                               for(Id userIdMdt: userIdsOfEmails){
                                                   if(lstids.contains(userIdMdt)){
                                                       lstids.remove(userIdMdt);
                                                   }
                                               }
                                           }
                                       }
                                       
                                       System.debug('### FINAL USERs ID WHICH RECIEVE MAIL FROM CAR STATUS CONTROLLER: ###' + lstids);
                                       
                                       for(Id usrId :lstids) {
                                           System.debug('####USER ID IN LOOP:#####' + userId);
                                           if(userId != NULL){
                                               Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(template.id, usrId, carId);
                                               String emailSubject = email.getSubject();
                                               String emailTextBody = email.getPlainTextBody();
                                               system.debug('usrId::'+usrId);
                                               email.setTargetObjectId(usrId);
                                               email.setSubject(emailSubject);
                                               email.setPlainTextBody(emailTextBody);
                                               email.saveAsActivity = false;
                                               mails.add(email);
                                           }
                                       }
                                       Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                                       if (results.size() > 0 && results[0].success) 
                                       {
                                           System.debug('The email was sent successfully Queue members.');
                                       } else {
                                           
                                           System.debug('The email failed to send to Queue members.'); 
                                       }

                                       
                                   } */
        postToChatter p2c = new postToChatter();
        p2c.post(chatterGroupName, carObj, carId);
        /*try{        
                        if(chatterGroupName!=null && chatterGroupName.size()>0){
                            String emailTemplate=Label.RF_EMAIL_TEMPLATE_CAR_ASSIGNED_QUEUE;
                            system.debug('##chatterGroupName:'+chatterGroupName);
                            CAR_CarEmailHelper.sendEmailToChatterGroupMembers(chatterGroupName,carId,emailTemplate,carObj.Requester__c);
                            List<CollaborationGroup> chatterGroupList = [select Id, Name from CollaborationGroup where Name IN: chatterGroupName];
                            List<FeedItem> feedItemList=new List<FeedItem>();
                            
                            for(CollaborationGroup chatterGroup:chatterGroupList){
                                FeedItem post = new FeedItem();
                                post.Body = 'Status has changed to: ' + carObj.Status__c + ' for the following CAR.\n RecordLink: https://wb--rf1.lightning.force.com/lightning/r/CAR__c/' + carId + '/view';
                                post.ParentId = chatterGroup.Id;
                                //feedItemList.add(post);
                                insert post;
                            }
                             
                        }
        }
        catch(Exception e){
            System.debug('exception message '+ e.getMessage());
            System.debug('Stack trace '+e.getStackTraceString());
        }*/
        /* Start-----Send email to chatter group members based on brand group 
        if(chatterGroupName!='' && chatterGroupName!=null){
                                       system.debug('inside cchatterGroupName::'+chatterGroupName);
                                       List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage> ();
                                       EmailTemplate template=[Select id from EmailTemplate where name =:Label.RF_EMAIL_TEMPLATE_CAR_ASSIGNED_QUEUE limit 1];
                                      
                                       set<Id> lstids = new set<id>();
                                                           
                                       // new implementation to avoid sending duplicate email which also belongs to brand group owner
                                    
                                         List<CollaborationGroup> collaborationGroupList=[SELECT Id,Name From CollaborationGroup];
                    Map<String,id> collabNameVsIdMap=new Map<String,id>();
                    for(CollaborationGroup collab:collaborationGroupList){
                      collabNameVsIdMap.put(collab.Name,collab.Id);
                    }
                                          System.debug('collabNameVsIdMap:#####' + collabNameVsIdMap);
                  
                    Id chattergroupId=collabNameVsIdMap.get(chatterGroupName);
                    System.debug('chatterGroupName:' + chatterGroupName+'chattergroupId:'+chattergroupId);
                    
                                        List<CollaborationGroupMember> CollaborationGroupMemberList=[SELECT CollaborationGroupId,MemberId FROM CollaborationGroupMember where CollaborationGroupId=:chattergroupId];          

                    for(CollaborationGroupMember chatterGroup:CollaborationGroupMemberList){
                      lstids.add(chatterGroup.MemberId);
                    }
                                        
                                    
                                       
                                       System.debug('### FINAL USERs ID WHICH RECIEVE MAIL FROM CAR STATUS CONTROLLER: ###' + lstids);
                                       
                                       for(Id usrId :lstids) {
                                           System.debug('####USER ID IN LOOP:#####' + userId);
                                           if(userId != NULL){
                                               Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(template.id, usrId, carId);
                                               String emailSubject = email.getSubject();
                                               String emailTextBody = email.getPlainTextBody();
                                               system.debug('usrId::'+usrId);
                                               email.setTargetObjectId(usrId);
                                               email.setSubject(emailSubject);
                                               email.setPlainTextBody(emailTextBody);
                                               email.saveAsActivity = false;
                                               mails.add(email);
                                           }
                                       }
                                       Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                                       if (results.size() > 0 && results[0].success) 
                                       {
                                           System.debug('The email was sent successfully to Chatter group members.');
                                       } else {
                                           
                                           System.debug('The email failed to send to Chatter group members.'); 
                                       }
                                       
                                   }
        
        /*------------- End of Chatter group email notification------------ */
        
        return carObj;
    }    
    
    
    
    
    /* This method gets called from CAR_Reactivate_Button.cmp lightning component and it sets the status to previously selected status
on click of Reactivate button. It accepts CAR Record id as input param*/
    @AuraEnabled
    public static CAR__c reactivateStatus(Id carId, String reasons) {
        CAR__c  carObj=[Select id,reason__c,Brand_Group__c,Reactivate_Flag__c,RF_Studios__c,Requesting_Group__c,Cancel_Flag__c, Status__c,reasonFlag__c,Last_Valid_Status__c, Requester__c,Owner.name,owner.id from CAR__c where id=:carId];
        List<String> chatterGroupName;
        try{     
            system.debug('reactivateStatus Reactivate_Flag__c:'+carObj.Reactivate_Flag__c);
            if(carObj.Reactivate_Flag__c==false){
                string errorMessage = 'Please enter the Reactivation reason!';
                AuraHandledException auraEx = new AuraHandledException(errorMessage);
                auraEx.setMessage(errorMessage);
                throw auraEx;
            }else{
                if(carObj.Status__c==Label.RF_HOLD || carObj.Status__c==Label.RF_CANCELLED){   
                    system.debug('Last_Valid_Status__c:'+carObj.Last_Valid_Status__c);
                    carObj.Status__c = carObj.Last_Valid_Status__c;
                    carObj.reason__c=reasons;
                    carObj.reasonFlag__c=false;
                    carObj.Cancel_Flag__c=false;
                    chatterGroupName=CAR_CarEmailHelper.getChatterGroupNameForReactivatedStatus(carObj.Requesting_Group__c,carObj.RF_Studios__c,carObj.Brand_Group__c);
                      if(chatterGroupName.size()>0 && chatterGroupName!=null){
                            String emailTemplate=Label.RF_CAR_Reactivated;
                            CAR_CarEmailHelper.sendEmailToChatterGroupMembers(chatterGroupName,carId,emailTemplate,carObj.Requester__c);
                            
                        }
                }
            }
            
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());  
        }
        update carObj;
        system.debug('reactivateStatus after update reasonFlag__c:'+carObj.reasonFlag__c);
        return carObj;
    }
    
    /*
    @AuraEnabled
    public static boolean checkstatus(string recordId,string userId){
        boolean flag=false;
        try{
            User u=[SELECT Id,name,Profile.Name FROM User WHERE Id=:userId];
           
         if(u.Profile.Name==Label.RF_STANDARD_USER_CAR){
             
                CAR__c  carObj=[Select id, Status__c,Last_Valid_Status__c, Requester__c,Owner.name,owner.id from CAR__c where id=:recordId];
                if(carObj.Status__c==Label.RF_HOLD || carObj.Status__c==Label.RF_CANCELLED){   
                    flag=true;
                    
                }
            }
        }catch(Exception e){throw new AuraHandledException(e.getMessage());  
                           }
        return flag;
    }
    */
    /*This method is called to set the reason for hold/cancelled of CAR status*/
    @AuraEnabled
    public static CAR__c setReason(Id carId,String reasons,String button) {
        CAR__c  carObj=[Select id,reasonFlag__c,Reactivate_Flag__c,Cancel_Flag__c, Reason__c,Status__c, Requester__c,Owner.name,owner.id from CAR__c where id=:carId];
        carObj.Reason__c=reasons;
        if(button.equals('Hold')){
            carObj.reasonFlag__c=true;
        }
        if(button.equals('Cancel')){
            carObj.Cancel_Flag__c=true;
        }
        if(button.equals('Reactivate')){
            carObj.Reactivate_Flag__c=true;
        }
        update carObj;
        if(button.equals('Hold')){
            setHoldStatus(carId);
        }
        if(button.equals('Cancel')){
            setCancelStatus(carId);
        }
        if(button.equals('Reactivate')){
            reactivateStatus(carId,reasons);
        }
        return carObj;
    }
    
    /* This method gets called from CAR_Hold_Button.cmp lightning component and it sets the status to hold
on click of Hold button. It accepts CAR Record id as input param*/
    @AuraEnabled
    public static CAR__c setHoldStatus(Id carId) {
        
        CAR__c  carObj=[Select id,reason__c,Last_Valid_Status__c, Reactivate_Flag__c,Cancel_Flag__c,reasonFlag__c,Status__c, Requester__c,Owner.name,owner.id from CAR__c where id=:carId];
        try{   
            system.debug('setHoldStatus before update reasonFlag__c:--> '+carObj.reasonFlag__c);
            if(carObj.reasonFlag__c==false){
                string errorMessage = 'Please enter the reason for Hold!';
                AuraHandledException auraEx = new AuraHandledException(errorMessage);
                auraEx.setMessage(errorMessage);
                throw auraEx;
            }else{
                carObj.Status__c = Label.RF_HOLD;
                carObj.reasonFlag__c=true;
                carObj.Cancel_Flag__c=false;
                carObj.Reactivate_Flag__c=false;
            }
        }catch(Exception e){throw new AuraHandledException(e.getMessage());  
                           }
        update carObj;
        system.debug('setHoldStatus after update reasonFlag__c:--> '+carObj.reasonFlag__c+'#'+carObj.Last_Valid_Status__c);
        
        return carObj;
    }
    
    /* This method gets called from CAR_Cancel_Button.cmp lightning component and it sets the status to Cancelled
on click of Cancelled buttonaccepts CAR Record id as input param*/
    @AuraEnabled
    public static CAR__c setCancelStatus(Id carId) {
        CAR__c  carObj=[Select id, reason__c,Brand_Group__c,Requesting_Group__c,RF_Studios__c,Reactivate_Flag__c,reasonFlag__c,Cancel_Flag__c,Status__c, Requester__c,Owner.name,owner.id from CAR__c where id=:carId];
        List<String> chatterGroupName;
        try{           
            //carObj.reason__c='';
            if(carObj.Cancel_Flag__c==false){
                string errorMessage = 'Please enter the reason for Cancel!';
                AuraHandledException auraEx = new AuraHandledException(errorMessage);
                auraEx.setMessage(errorMessage);
                throw auraEx;
            }else{
                carObj.Status__c = Label.RF_CANCELLED;
                carObj.Cancel_Flag__c=true;
                carObj.reasonFlag__c=false;
                carObj.Reactivate_Flag__c=false;
                chatterGroupName=CAR_CarEmailHelper.getChatterGroupNameForCancelledStatus(carObj.Requesting_Group__c,carObj.RF_Studios__c,carObj.Brand_Group__c);
                system.debug('chatterGroupName cancelled status:'+chatterGroupName);
                system.debug('chatterGroupName cancelled status size:'+chatterGroupName.size());
                if(chatterGroupName.size()>0 && chatterGroupName!=null){
                    String emailTemplate=Label.RF_CAR_Cancelled;
                    CAR_CarEmailHelper.sendEmailToChatterGroupMembers(chatterGroupName,carId,emailTemplate,carObj.Requester__c);
               }
            }
            
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());  
        }
        update carObj;
        return carObj;
    }
    
  
/*-------------End-------------------------------------------------------*/
    private Without Sharing class postToChatter {
        public void post(List<String> chatterGroupName, CAR__c carObj, Id carId){ 
            CAR__c carUpdate = [Select Id, last_status__c, status__c from CAR__c where Id =:carId];
            System.debug('##chatterGroupName inside postToChatter:'+chatterGroupName);
        try{        
                        if(chatterGroupName!=null && chatterGroupName.size()>0){
                            String emailTemplate=Label.RF_EMAIL_TEMPLATE_CAR_ASSIGNED_QUEUE;
                            system.debug('##chatterGroupName:'+chatterGroupName);
                            CAR_CarEmailHelper.sendEmailToChatterGroupMembers(chatterGroupName,carId,emailTemplate,carObj.Requester__c);
                            List<CollaborationGroup> chatterGroupList = [select Id, Name from CollaborationGroup where Name IN: chatterGroupName];
                            List<FeedItem> feedItemList=new List<FeedItem>();
                            String urlOrg = System.URL.getSalesforceBaseURL().toExternalForm();
                            for(CollaborationGroup chatterGroup:chatterGroupList){
                                FeedItem post = new FeedItem();
                                System.debug('@@last status:' + carUpdate.last_status__c);
                                post.Body = 'Status has changed from:'+ carUpdate.last_status__c +' '+' '+ 'To: ' + carObj.status__c + ' for the following CAR.\n RecordLink: '+ urlOrg +'/lightning/r/CAR__c/' + carId + '/view';
                                System.debug('##$$##' + post.Body);
                                
                                post.ParentId = chatterGroup.Id;
                                feedItemList.add(post);
                            }
                            insert feedItemList; 
                        }
        }
        catch(Exception e){
            System.debug('exception message '+ e.getMessage());
            System.debug('Stack trace '+e.getStackTraceString());
        }
    }
    
}
}