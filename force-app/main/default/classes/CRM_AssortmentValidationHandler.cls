/**
   @Author: Cognizant Team
   @name CRM_AssortmentValidationHandler 
   @CreateDate 10/6/2016
   @Description: To validate the approval lifecycle stages for france profiles
   @Version 1.0
  */
public without sharing class CRM_AssortmentValidationHandler {
    public static List<CRM_Assortment_Transitions__c> assrtTransiotionList;
    //public static List<ProcessInstance> processInstanceList = new List<ProcessInstance>([SELECT Id, Status, TargetObjectId,(SELECT Id, ActorId, actor.name, OriginalActorId, StepStatus, Comments FROM StepsAndWorkitems) FROM ProcessInstance where Status = 'Approved']);
    
    /***
    Purpose    : Fetch Custom Settings for specific profile
    Return     : List of Custom Settings
    ***/
    private static List<CRM_Assortment_Transitions__c> getValidStatusTransitions(String profileName){
        assrtTransiotionList = new CRM_Assortment_Transitions__c[]{};
        for(CRM_Assortment_Transitions__c transitVal : CRM_Assortment_Transitions__c.getall().values()) {
            if(transitVal.Profile__c.trim().equals(profileName)) {
                assrtTransiotionList.add(transitVal);
            }
        }
        system.debug('custom setting values:::::::'+assrtTransiotionList);
        return assrtTransiotionList;
    }
    
    /***
    Purpose    : Check for Assorment Status  for invalid transition before update
    Parameters : Trigger.OldMap , Trigger.New
    Return     : Void
    ***/
    public static void validateStatusForUpdate(Map<Id, Bundle__c> oldAssrt, List<Bundle__c> newAssrt){
        Boolean isFound = false;
        String errorMessage = Label.CRM_Error_Invalid_Assortment_Transition_Status;
        String profileName = getProfileName();
        for (Bundle__c newAssort : newAssrt) {
            if( oldAssrt.get(newAssort.Id).Assortment_Status__c != Null && newAssort.Assortment_Status__c != Null){
                String oldAssortStatus = oldAssrt.get(newAssort.Id).Assortment_Status__c;
                String newAssortStatus = newAssort.Assortment_Status__c;
                if(!(oldAssortStatus.equals(newAssortStatus))){
                    assrtTransiotionList = getValidStatusTransitions(profileName);
                    
                    if(CRM_AppConstants.ASSORTMENT_STATUS_APPROVED.equals(newAssortStatus)){
                        newAssort.Last_Approved_Date__c = system.now();
                        newAssort.Last_Approved_By__c = Userinfo.getUserId();
                    }
                    
                    if(assrtTransiotionList != null && !assrtTransiotionList.isEmpty()) {
                        for(CRM_Assortment_Transitions__c obj : assrtTransiotionList){
                            if(obj.From_Status__c.equals(oldAssortStatus) && obj.To_status__c.equals(newAssortStatus)){
                                
                                isFound = true;
                                break;
                            }
                        }
                       
                        if(!isFound){
                            newAssort.addError(errorMessage);
                        }  
                    }
                }
            }
        }
        system.debug('isFound'+ isFound);
    }

     /***
        Purpose    : Fetch Profile Name of the current user
        Return     : String - Profile Name
    ***/
    private static String getProfileName(){
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        system.debug('ProfileName'+profileName);
        return profileName;
    }
    
    //Added "oldAssrt" Parameter for US : 814
    public void updateDefaultPricingAccount(Bundle__c[] newAssortments,Map<Id, Bundle__c> oldAssrt){
        CRM_Default_Configuration__c defaultConfiguration = CRM_Default_Configuration__c.getInstance(); 
        string defaultPricingAccount  = defaultConfiguration.Default_Pricing_Account__c;
        
        //US : 814 : Finance Review Process on Assortment Profitability
        Boolean isUpdate = oldAssrt != null ? true : false;
        
        for(Bundle__c newAssortment: newAssortments)
        {
             if(newAssortment.Pricing_Account__c == Null && newAssortment.Campaign_Type__c == CRM_AppConstants.ASSORTMENT_TYPE_NATIONAL)
             {
                newAssortment.Pricing_Account__c = defaultPricingAccount;
             }
             //Defect: #3546 - Changing Assortment from National to Trade still generates dummy account
             else {
                 if(newAssortment.Pricing_Account__c != Null && newAssortment.Campaign_Type__c != CRM_AppConstants.ASSORTMENT_TYPE_NATIONAL)
                 {
                    newAssortment.Pricing_Account__c = Null;    
                 }
             }
             
             // Req# 609 : Set default Pricing Mode for Promotional Assortments
             if (newAssortment.RecordTypeId == CRM_RecordTypeUtil.RT_Promotional_Assortment && (newAssortment.Pricing_Method__c == null || newAssortment.Pricing_Method__c == '')) {
                newAssortment.Pricing_Method__c = CRM_AppConstants.ASSORTMENT_PRICING_MODE_FILE_DISCOUNT;
             }
             
              //US : 814 : Finance Review Process on Assortment Profitability
             if(newAssortment.RecordTypeId == CRM_RecordTypeUtil.RT_ASSORTMENT_CAMPAIGN){
                 if(isUpdate && newAssortment.Assortment_Status__c != oldAssrt.get(newAssortment.Id).Assortment_Status__c && newAssortment.Assortment_Status__c == CRM_AppConstants.ASSORTMENT_STATUS_DRAFT){
                    newAssortment.Finance_review_status__c = null;
                 }else if(newAssortment.Finance_review_status__c != null && !isUpdate){
                    newAssortment.Finance_review_status__c = null;
                 }
                 //US#958 - default value for Couponing_Redemption_Rate__c to 65%
                 else if(newAssortment.Couponing_Redemption_Rate__c == null && !isUpdate && newAssortment.Assortment_Status__c == CRM_AppConstants.ASSORTMENT_STATUS_DRAFT){
                    newAssortment.Couponing_Redemption_Rate__c = defaultConfiguration.CRM_Default_Couponing_Redumption_Rate__c;
                 }
                 //US958 - end
             }
        } 
    }  
    
    /**
    *  @Description - Method to Stop user from Deleting Assortment.        
    *  @name - deleteAssortmentError
    *  @return - void
    */
    public static void deleteAssortmentError(List<Bundle__c> oldAssrt){
        String errorMessage = Label.CRM_Assortment_Delete_Error;
        
        CRM_Functional_Permissions__c functionalPermission = CRM_Functional_Permissions__c.getInstance();
               
        Boolean isDeletePermission = (functionalPermission != null && (functionalPermission.Delete_Assortment_Permission__c) == True);
        
        for(Bundle__c bundle : oldAssrt){
            // If Last_Published_Date__c is not null then user cannot Delete Assortment
            if(!(isDeletePermission) && (bundle.Last_Published_Date__c != Null)) {
                //Show an error to user, You cannot delete the Assortment
                bundle.addError(errorMessage);
            }
        }
        
    }
    
    /**
    *  @Description - Method publish assortment .        
    *  @name - publishAssortmentOnApproval
    *  @return - void
    */
    public static void publishAssortmentOnApproval(Map<Id, Bundle__c> oldAssrt, List<Bundle__c> newAssrt){
        List<Bundle__c> approvedAssortmentList = new List<Bundle__c>();
        for (Bundle__c newAssort : newAssrt) {
            if(oldAssrt.get(newAssort.Id).Assortment_Status__c == CRM_AppConstants.ASSORTMENT_STATUS_AWATING_APPROVAL && newAssort.Assortment_Status__c == CRM_AppConstants.ASSORTMENT_STATUS_APPROVED ){
                    CRM_PublishAssortmentHelper.publishAssortment(newAssort.Id);
                    approvedAssortmentList.add(newAssort); 
            }
        }
        
        if(approvedAssortmentList.size() > 0)
            sendAlertEmailsForAssortmentAproval(approvedAssortmentList);
    }
    
    /**
    *  @Description - Method Send Alert Email For Assortment Approval .        
    *  @name - sendAlertEmailsForAssortmentAproval
    *  @return - void
    */
    public static void sendAlertEmailsForAssortmentAproval(List<Bundle__c> approvedAssortmentList){
        List<Messaging.SingleEmailMessage> massEmails = new List<Messaging.SingleEmailMessage>();
        List<String> ccAddresses = new List<String>{Userinfo.getUserEmail()};
        
        for(Bundle__c approvedAssort : approvedAssortmentList){
        
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(approvedAssort.OwnerId);
            message.setccAddresses(ccAddresses);
            message.setSaveAsActivity(false); 
            message.subject = 'Assortment <'+approvedAssort.Name+'> has been approved.';
            
            String htmlEmailBody = '<p>Assortment has been approved successfully. It will get auto publish and conformation email will get after Assortment hass been publish.</p><p>Please find Assortment Details:</p>';
            htmlEmailBody += CRM_PublishAssortmentHelper.createAssortmentInfoTable(approvedAssort);
            message.htmlbody = htmlEmailBody;
            massEmails.add(message);
        }
        Messaging.sendEmail(massEmails);
    }
    
}