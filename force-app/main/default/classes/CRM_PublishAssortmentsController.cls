/**
   @Author Cognizant (Dilip Mistry)
   @name CRM_PublishAssortmentsController
   @CreateDate 15 June 2016
   @Description Controller to have the assortment publish logic
   @Version <1.0>
*/
public with sharing class CRM_PublishAssortmentsController {
    private Id id;
    
    /* Constructor with StandardController*/
    public CRM_PublishAssortmentsController(ApexPages.StandardController stdCon) {
        id = stdCon.getRecord().Id;
    }
    
        
    @RemoteAction 
    public static void publishAssortment(Id assortmentId) {
        CRM_PublishAssortmentHelper.publishAssortment(assortmentId); 
    }
}