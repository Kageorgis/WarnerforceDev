/**
   @Author - Cloudcreations
   @name - WBSF_FillOwnerDepartment
   @CreateDate - 31 July 2019
   @Description - Opportunity Trigger Handler for updating Owner Department Field
   @Version - 1.0
   @reference  -None
*/
public without sharing class WBSF_FillOwnerDepartment {
    /**
    *  @Description - Method to update Owner Department Field when it is empty
    *  @name - UpdateOwnerDepartment
    *  @return - void
    */
    public static void UpdateOwnerDepartment(Map<Id, Opportunity> oldDealsMap, List<Opportunity> newDeals){
        Map<Id, User> ownerRoleMap = new Map<Id, User>();
        if(oldDealsMap == null){
            for(Opportunity opportunity:newDeals) if(String.isNotEmpty(opportunity.AccountId)) ownerRoleMap.put(opportunity.OwnerId, new User());
            for(User user:[Select Id, UserRole.Name From User Where id in:ownerRoleMap.keySet()]) ownerRoleMap.put(user.Id, user);
            for(Opportunity opportunity:newDeals) if(String.isNotEmpty(opportunity.AccountId)) opportunity.Owner_Role_Department__c = ownerRoleMap.get(opportunity.OwnerId).UserRole.Name;            
        }
        else{
            for(Opportunity opportunity:newDeals) if(String.isEmpty(oldDealsMap.get(opportunity.id).AccountId) && String.isNotEmpty(opportunity.AccountId)) ownerRoleMap.put(opportunity.OwnerId, new User());
            for(User user:[Select Id, UserRole.Name From User Where id in:ownerRoleMap.keySet()]) ownerRoleMap.put(user.Id, user);
            for(Opportunity opportunity:newDeals) if(String.isEmpty(oldDealsMap.get(opportunity.id).AccountId) && String.isNotEmpty(opportunity.AccountId)) opportunity.Owner_Role_Department__c = ownerRoleMap.get(opportunity.OwnerId).UserRole.Name;            
        }
    }
}