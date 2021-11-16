/**
   @Author-Cognizant Technology Solutions
   @name-CRM_CountryPlanTargetSequenceHandler
   @CreateDate-<5 april 2016>
   @Description-The class is used to delete targets related to this country plan targets.
   @Version-1.0
   @reference-None
*/
public with sharing class CRM_CountryPlanTargetSequenceHandler{

    /**
    *  @Description - This method call the related targets
    *  @name - deleteTargets
    *  @return - void
    **/
    public void deleteTargets(List<Country_Plan_Target__c> lstCountryPlanTarget) {
        
        List<Target__c> listTargetsFetched = new List<Target__c>();
        
        try{
            if(!lstCountryPlanTarget.isEmpty()) {
                listTargetsFetched = getRelatedTargets(lstCountryPlanTarget);
            }
            if(!listTargetsFetched.isEmpty()) {
                delete listTargetsFetched;
            } 
        }         
        catch(Exception e){
            logAnException(e,null);
        }
    }    
    
    /**
        *  @Description - The method prepares a (list) collection of Targets
        *  @return - return related targets
    */ 
    private List<Target__c> getRelatedTargets(List<Country_Plan_Target__c> lstCountryPlanTrgt) {
    
        List<Target__c> listTargets = new List<Target__c>();
        set<string> countryPlanNameSet = new set<String>();
        for(Country_Plan_Target__c cpt : lstCountryPlanTrgt){
        if(cpt.name != null){
                countryPlanNameSet.add(cpt.name+'%');                
           }
        }
        
        listTargets = [select Id, Unique_Key__c from Target__c where Unique_Key__c Like : countryPlanNameSet];
                        
        return listTargets;
    }
    //US842 Starts
    /**
     * @Description : US842 - Need to prevent mixture of revenue and Units under one Country_Plan__c. all Country_Plan_Targets__r should be of same type
     * @name: doValidateCPT
     * @Param: list<Country_Plan_Target__c> 
     * @Return : void
     */ 
    public void doValidateCPT(list<Country_Plan_Target__c> cptList){
        set<string> unitRevenueSet = new set<string>();
        SET<Id> cpIdsSet = new set<Id>();
        map<id,Country_Plan_Target__c> cptIdObjectMap;
        for(Country_Plan_Target__c cpt : cptList){
            cpIdsSet.add(cpt.Country_Plan__c);
        }
        cptIdObjectMap = new map<Id,Country_Plan_Target__c>([SELECT Id,Target_Quantity__c,Target__c,Country_Plan__c FROM Country_Plan_Target__c
                                                WHERE Country_Plan__c IN : cpIdsSet
                                                AND Id NOT IN : cptList]);
        for(Country_Plan_Target__c cpt : cptIdObjectMap.values()){
            if(cpt.Target_Quantity__c !=null){
                unitRevenueSet.add('Quantity'+cpt.Country_Plan__c);
            }
            if(cpt.Target__c != null){
                unitRevenueSet.add('Revenue'+cpt.Country_Plan__c);
            }
        }
           
        for(Country_Plan_Target__c cpt : cptList){
            
            if(cpt.Target_Quantity__c !=null){
                unitRevenueSet.add('Quantity'+cpt.Country_Plan__c);
                if(unitRevenueSet.contains('Revenue'+cpt.Country_Plan__c)){
                     
                   cpt.adderror('All Country Plan Targets must be in either units or revenue');
                }
            }
            if(cpt.Target__c != null){
                unitRevenueSet.add('Revenue'+cpt.Country_Plan__c);
                if(unitRevenueSet.contains('Quantity'+cpt.Country_Plan__c)){
                    cpt.adderror('All Country Plan Targets must be in either units or revenue');
                }
            }
            if(cpt.Target_Quantity__c !=null && cpt.Target__c != null){
                cpt.adderror('Cannot enter a Country Plan Target in both Units and Revenue. Please enter a Country Plan Target in Units or Revenue');
            }
        }  
    }
    //US842 Ends
   /*
    *  This method will take the exception occured as an input and forward it to the common utility class. 
    *  @name: logAnException
    *  @param: Exception ex
    *  @return: void 
    */
    public void logAnException(Exception ex, Id recordId){
        CRM_ErrorLogger.ErrorLog errorLogInstance = new CRM_ErrorLogger.ErrorLog();
        errorLogInstance.functionalModule = 'CRM_CountryPlanTargetSequenceHandler';
        if(ex != null){ 
        errorLogInstance.errorMessage = ex.getMessage();}
        CRM_ErrorLogger.logError(errorLogInstance);     
    }
}