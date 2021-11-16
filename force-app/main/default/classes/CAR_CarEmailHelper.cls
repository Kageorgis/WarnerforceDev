/*========================================================================================================
* @author: Ajit Singh
* @date: 04/03/2021
* @description: Helper class that will implement the Email related functionality of CarStatusController

==========================================================================================================*/
public class CAR_CarEmailHelper {
    
    /*---------------START- Get Chatter Group Name when status changes from Draft to Trade Review--*/
    public Static List<String>  getChatterGroupNameForSalesUser(String requestingGroup,String distributor,String brandGroup){
        List<String> chatterGroupName=new List<String>();
        if(requestingGroup==Label.RF_SDS && (distributor==Label.RF_WB ||distributor==Label.RF_UNI) ){
            if(brandGroup==Label.RF_Film){
                chatterGroupName.add(Label.RF_SDS_TRADE_FILM);
            }
            if(brandGroup==Label.RF_TV ||brandGroup==Label.RF_OA_F){
                chatterGroupName.add(Label.RF_SDS_TRADE_TV_O);
            }
            
            if(brandGroup==Label.RF_Multi_BU){
                chatterGroupName.add(Label.RF_SDS_TRADE);
            }
            
        }
        
        if(requestingGroup==Label.RF_WB_DIGITAL && distributor==Label.RF_WB){
            if(brandGroup==Label.RF_Film){
                chatterGroupName.add(Label.RF_WB_Digital_Trade_Film);
                  System.debug('##chatterGroupName for WB and wB Digital:'+chatterGroupName);
            }
            if(brandGroup==Label.RF_TV ||brandGroup==Label.RF_OA_F){
                chatterGroupName.add(Label.RF_WB_Digital_Trade_TV_O);
            }
            
            if(brandGroup==Label.RF_Multi_BU){
                chatterGroupName.add(Label.RF_WB_Digital_Trade);
            }
            
        }
        return chatterGroupName;
        
    }
    
    /*-------------End--------------------------------------------------------------------------*/
    
    /*---------------START- Get Chatter Group Name when status changes from Trade Review to Brand Review--*/
    public Static List<String>  getChatterGroupNameForTradeUsers(String requestingGroup,String distributor,String brandGroup){
        List<String> chatterGroupName=new List<String>();
        if(requestingGroup==Label.RF_SDS && distributor==Label.RF_WB ){
            if(brandGroup==Label.RF_Film){
                chatterGroupName.add(Label.RF_WB_Brand_Film);
            }
            if(brandGroup==Label.RF_TV ||brandGroup==Label.RF_OA_F){
                chatterGroupName.add(Label.RF_WB_Brand_TV_O);
            }
            
            if(brandGroup==Label.RF_Multi_BU){
                chatterGroupName.add(Label.RF_WB_BRAND);
            }
            
        }
        
        if(requestingGroup==Label.RF_WB_DIGITAL && distributor==Label.RF_WB){
            if(brandGroup==Label.RF_Film){
                chatterGroupName.add(Label.RF_WB_Brand_Film);
            }
            if(brandGroup==Label.RF_TV ||brandGroup==Label.RF_OA_F){
                chatterGroupName.add(Label.RF_WB_Brand_TV_O);
            }
            
            if(brandGroup==Label.RF_Multi_BU){
                chatterGroupName.add(Label.RF_WB_BRAND);
            }
            
        }
        return chatterGroupName;
        
    }
    
    /*-------------End-------------------------------------------------------*/
    
    /*-------------------START- Get Chatter Group Name when status changes from Brand Review to Creative Review--*/
    public Static List<String>  getChatterGroupNameForBrandUsers(String requestingGroup,String distributor,String brandGroup){
        List<String> chatterGroupName=new List<String>();
        if(requestingGroup==Label.RF_SDS && distributor==Label.RF_WB ){
            if(brandGroup==Label.RF_Film){
                chatterGroupName.add(Label.RF_WB_Creative_Film_CPM);
                system.debug('chatterGroupName:'+chatterGroupName);
            }
            if(brandGroup==Label.RF_TV ||brandGroup==Label.RF_OA_F){
               chatterGroupName.add(Label.RF_WB_Creative_TVO_CPM);
            }
            
            if(brandGroup==Label.RF_Multi_BU){
                chatterGroupName.add(Label.RF_WB_Creative);
            }
             if(brandGroup==Label.RF_Non_IP){
                chatterGroupName.add(Label.RF_WB_CPM_Team);
            }
      
        }
        
        if(requestingGroup==Label.RF_WB_DIGITAL && distributor==Label.RF_WB){
	          if(brandGroup==Label.RF_Film){
              	 chatterGroupName.add(Label.RF_WB_Creative_Film_CPM);
             }
            if(brandGroup==Label.RF_TV ||brandGroup==Label.RF_OA_F){
                 chatterGroupName.add(Label.RF_WB_Creative_TVO_CPM);
            }
            
            if(brandGroup==Label.RF_Multi_BU){
                chatterGroupName.add(Label.RF_WB_Creative);
            }
            if(brandGroup==Label.RF_Non_IP){
                chatterGroupName.add(Label.RF_WB_CPM_Team);
            }
            
        }
        return chatterGroupName;
        
    }
    
    /*-------------End-------------------------------------------------------*/
    
    /*---------------START- Get Chatter Group Name when status changes from 
						Draft/Trade Review/Brand Review/Creative Review to Cancelled------------------------*/
    public Static List<String>  getChatterGroupNameForCancelledStatus(String requestingGroup,String distributor,String brandGroup){
        List<String> chatterGroupName=new List<String>();
        if(requestingGroup==Label.RF_SDS && (distributor==Label.RF_WB) ){
            if(brandGroup==Label.RF_Film){
                chatterGroupName.add(Label.RF_SDS_TRADE_FILM);
                chatterGroupName.add(Label.RF_WB_Brand_Film);
                chatterGroupName.add(Label.RF_WB_CREATIVE);

            }
            if(brandGroup==Label.RF_TV ||brandGroup==Label.RF_OA_F){
                chatterGroupName.add(Label.RF_SDS_TRADE_TV_O);
                chatterGroupName.add(Label.RF_WB_Brand_TV_O);
                chatterGroupName.add(Label.RF_WB_CREATIVE);

            }
            
            if(brandGroup==Label.RF_Multi_BU){
                chatterGroupName.add(Label.RF_SDS_TRADE);
                chatterGroupName.add(Label.RF_WB_BRAND);
                chatterGroupName.add(Label.RF_WB_CREATIVE);

            }
            
        }
        //newly added: 09/04/2021
        if(requestingGroup==Label.RF_SDS && (distributor==Label.RF_UNI) ){
            if(brandGroup==Label.RF_Film){
                chatterGroupName.add(Label.RF_SDS_TRADE_FILM);
            }
            if(brandGroup==Label.RF_TV ||brandGroup==Label.RF_OA_F){
                chatterGroupName.add(Label.RF_SDS_TRADE_TV_O);
                
            }
            
            if(brandGroup==Label.RF_Multi_BU){
                chatterGroupName.add(Label.RF_SDS_TRADE);
            }
        }

        
        if(requestingGroup==Label.RF_WB_DIGITAL && distributor==Label.RF_WB){
            if(brandGroup==Label.RF_Film){
                chatterGroupName.add(Label.RF_WB_Digital_Trade_Film);
                chatterGroupName.add(Label.RF_WB_Brand_Film);
                chatterGroupName.add(Label.RF_WB_CREATIVE);
            }
            if(brandGroup==Label.RF_TV ||brandGroup==Label.RF_OA_F){
                chatterGroupName.add(Label.RF_WB_Brand_TV_O);
                chatterGroupName.add(Label.RF_WB_Digital_Trade_TV_O);
                chatterGroupName.add(Label.RF_WB_CREATIVE);
            }
            
            if(brandGroup==Label.RF_Multi_BU){
                chatterGroupName.add(Label.RF_WB_BRAND);
                chatterGroupName.add(Label.RF_WB_Digital_Trade);
                chatterGroupName.add(Label.RF_WB_CREATIVE);
            }
            
        }
        return chatterGroupName;
        
    }
    
    /*-------------End-------------------------------------------------------*/
    
    /*------START- Get Chatter Group Name when CAR is Re-activated to last valid 
		   status(Draft/Trade Review/Brand Review/Creative Review)------*/
    public Static List<String>  getChatterGroupNameForReactivatedStatus(String requestingGroup,String distributor,String brandGroup){
        List<String> chatterGroupName=new List<String>();
        if(requestingGroup==Label.RF_SDS && distributor==Label.RF_WB){
            if(brandGroup==Label.RF_Film){
                chatterGroupName.add(Label.RF_SDS_TRADE_FILM);
                chatterGroupName.add(Label.RF_WB_Brand_Film);
                chatterGroupName.add(Label.RF_WB_CREATIVE);
            }
            if(brandGroup==Label.RF_TV ||brandGroup==Label.RF_OA_F){
                chatterGroupName.add(Label.RF_SDS_TRADE_TV_O);
                chatterGroupName.add(Label.RF_WB_Brand_TV_O);
                chatterGroupName.add(Label.RF_WB_CREATIVE);
            }
            
            if(brandGroup==Label.RF_Multi_BU){
                chatterGroupName.add(Label.RF_SDS_TRADE);
                chatterGroupName.add(Label.RF_WB_BRAND);
                chatterGroupName.add(Label.RF_WB_CREATIVE);
                system.debug('inside Multi-BU chatter:'+chatterGroupName);
            }
            
        }
        
        //newly added: 09/04/2021
        if(requestingGroup==Label.RF_SDS && distributor==Label.RF_UNI){
            if(brandGroup==Label.RF_Film){
                chatterGroupName.add(Label.RF_SDS_TRADE_FILM);
            }
            if(brandGroup==Label.RF_TV ||brandGroup==Label.RF_OA_F){
                chatterGroupName.add(Label.RF_SDS_TRADE_TV_O);
                
            }
            
            if(brandGroup==Label.RF_Multi_BU){
                chatterGroupName.add(Label.RF_SDS_TRADE);
            }
        }
        
        if(requestingGroup==Label.RF_WB_DIGITAL && distributor==Label.RF_WB){
            if(brandGroup==Label.RF_Film){
                chatterGroupName.add(Label.RF_WB_Digital_Trade_Film);
                chatterGroupName.add(Label.RF_WB_CREATIVE);
                chatterGroupName.add(Label.RF_WB_Brand_Film);
                
            }
            if(brandGroup==Label.RF_TV ||brandGroup==Label.RF_OA_F){
                chatterGroupName.add(Label.RF_WB_Brand_TV_O);
                chatterGroupName.add(Label.RF_WB_Digital_Trade_TV_O);
                chatterGroupName.add(Label.RF_WB_CREATIVE);
            }
            
            if(brandGroup==Label.RF_Multi_BU){
                chatterGroupName.add(Label.RF_WB_BRAND);
                chatterGroupName.add(Label.RF_WB_Digital_Trade);
                chatterGroupName.add(Label.RF_WB_CREATIVE);
            }
            
        }
        return chatterGroupName;
        
    }
    
    /*-------------End-------------------------------------------------------*/
    
    /*-------------Start: Send email to chatter group members based on brand group------------*/
    public Static void  sendEmailToChatterGroupMembers(List<String> chatterGroupName,Id carId, String emailTemplate,Id requestor){
        system.debug('inside sendEmailToChatterGroupMembers::'+chatterGroupName);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage> ();
        EmailTemplate template=[Select id from EmailTemplate where name =:emailTemplate limit 1];
        
        set<Id> lstids = new set<id>();
        
        // new implementation to avoid sending duplicate email which also belongs to brand group owner
        
        List<CollaborationGroup> collaborationGroupList=[SELECT Id,Name From CollaborationGroup];
        Map<String,id> collabNameVsIdMap=new Map<String,id>();
        for(CollaborationGroup collab:collaborationGroupList){
            collabNameVsIdMap.put(collab.Name,collab.Id);
        }
        System.debug('collabNameVsIdMap:#####' + collabNameVsIdMap);
        Set<Id> chattergroupId= new Set<Id> ();
        system.debug('chatterGroupName size:'+chatterGroupName.size());
        for(String chatterName:chatterGroupName){
            
            chattergroupId.add(collabNameVsIdMap.get(chatterName));
        }
        
        //Id chattergroupId=collabNameVsIdMap.get(chatterGroupName);
        System.debug('chattergroupId:'+chattergroupId);
        
        List<CollaborationGroupMember> CollaborationGroupMemberList=[SELECT CollaborationGroupId,MemberId FROM CollaborationGroupMember where CollaborationGroupId IN:chattergroupId];					
        
        for(CollaborationGroupMember chatterGroup:CollaborationGroupMemberList){
            lstids.add(chatterGroup.MemberId);
        }
        system.debug('lstids size before requestor:'+lstids.size());
        system.debug('lstids before requestor:'+lstids);
        if(emailTemplate==Label.RF_CAR_Cancelled || emailTemplate==Label.RF_CAR_Reactivated){
            system.debug('inside requestor id'+requestor);
            if(!lstids.contains(requestor)){
            	lstids.add(requestor);
            }
         }
       system.debug('lstids size after requestor:'+lstids.size());
            

        List<User> userList=[SELECT id,email FROM User where id in :lstids];
        Set<String> emailsOfUser = new Set<String>();
        
        System.debug('##Before Listids:' + lstids);
        for(User u:userList){
            if(!emailsOfUser.contains(u.Email)){
                emailsOfUser.add(u.Email);
            }
            else{
                lstids.remove(u.Id);
            }
        }
        System.debug('##emails' +emailsOfUser);
        System.debug('##After duplicate check Listids:' +lstids);
        
        System.debug('### FINAL USERs ID WHICH RECIEVE MAIL FROM CAR STATUS CONTROLLER: ###' + lstids);
        
        for(Id usrId :lstids) {
            	System.debug('####USER ID IN LOOP:#####' + usrId);
              if(usrId != NULL){
                System.debug('####Inside send mail:#####');
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(template.id, usrId, carId);
                String emailSubject = email.getSubject();
                String emailTextBody = email.getPlainTextBody();
                system.debug('usrId::'+usrId);
                email.setTargetObjectId(usrId);
                // email.setToAddresses(emailList);
                email.setSubject(emailSubject);
                email.setPlainTextBody(emailTextBody);
                email.saveAsActivity = false;
                mails.add(email);
            }
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
        if (results.size() > 0 && results[0].success) 
        {
            System.debug('The email was sent successfully to Chatter group members from sendEmailToChatterGroupMembers().');
        } else {
            
            System.debug('The email failed to send to Chatter group members.'); 
        }
        
    }
    /*-------------End----------------------------------------- --------------*/
    
}