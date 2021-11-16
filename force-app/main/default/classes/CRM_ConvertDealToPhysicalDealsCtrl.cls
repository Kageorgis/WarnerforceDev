/**
   @Author: Cognizant Team
   @name CRM_ConvertDealToPhysicalDealsCtrl
   @CreateDate 11/01/2017
   @Description: Controller to convert the deal record type from high level deal to physical deal.
   @Version 1.0
  */
global without sharing class CRM_ConvertDealToPhysicalDealsCtrl {

    //public CRM_ConvertDealToPhysicalDealsCtrl(ApexPages.StandardSetController controller) {}   
    public Opportunity deal{get;set;}    
    
    public CRM_ConvertDealToPhysicalDealsCtrl(ApexPages.StandardController controller) {       
        deal = [select Id,Name from Opportunity where Id = :controller.getId()];
    }
    
    /**
     *  Method to convert the deal record type from high level deal to physical deal. 
     *  @name convertDealToPhysical
     *  @param Id
     *  @return none
     */
    @RemoteAction 
    global static void convertDealToPhysical(Id dealId){
        List<User> runningUser = new List<User>();
        runningUser = [SELECT Profile.Name FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1];            
            system.debug('Profile Name -->'+runningUser[0].Profile.Name);
            system.debug('Condition check --->'+runningUser[0].Profile.Name.contains(CRM_AppConstants.BENELUX_PROFILE_CODE));
            if(!runningUser.isEmpty() && runningUser[0].Profile.Name.contains(CRM_AppConstants.BENELUX_PROFILE_CODE)){
                    Opportunity deal = new Opportunity();
                    deal = [select Id,(select Id from Deal_Product_Groups__r) from Opportunity where Id=:dealId limit 1];
                    List<Deal_Product_Group__c> dealProductGrp = deal.Deal_Product_Groups__r;
                    if(dealProductGrp.isEmpty()){
                        Deal.RecordTypeId = CRM_RecordTypeUtil.RT_DEAL_PHYSICAL;
                        try{                    
                            Update Deal;
                                                    
                        }catch(Exception e){
                            throw New CRM_ChangeRecordTypeException(e.getMessage());
                        }
                    }else{
                        throw new CRM_ChangeRecordTypeException(Label.CRM_Restrict_Deal_RecType_Change_Having_Product_Group);     
                    }                                                    
           }
           else{
               throw new CRM_ChangeRecordTypeException(Label.CRM_Deal_RecordType_Change_Incorrect_Profile);
           }       
        
           
    }
    
     global class OpportunityError {
        global Opportunity dealRec;
        global String error;
        
        global OpportunityError(Opportunity op, String errMsg){
          this.dealRec = op;
          this.error = errMsg;
        }
    }
    public class CRM_ChangeRecordTypeException extends Exception {}
}