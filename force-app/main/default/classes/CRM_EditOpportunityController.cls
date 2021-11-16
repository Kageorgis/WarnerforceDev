/**
   @Author-Cognizant Technology Solutions
   @name-CRM_EditOpportunityController
   @CreateDate- 10 May 2017
   @Description-Controller handles list view edit of Deals
   @Version-1.0
   @reference-None
*/
global class CRM_EditOpportunityController {
    public Opportunity deal {get;set;}
    public Opportunity[] lstDeals {get;set;}
    
    /*
    *  @Description - constructor
    *  @name  CRM_EditOpportunityController
    */
    public CRM_EditOpportunityController(ApexPages.StandardSetController stdSetController){
        String dealId = ApexPages.currentPage().getParameters().get('id');
        
        if(dealId != null) {
            this.deal = [select Id, Name from Opportunity where Id =:dealId ];
        }
        else {
            this.lstDeals = (Opportunity[]) stdSetController.getSelected();
        }
    }
    
    @RemoteAction
    global static OpportunityError[] closeCoop(String[] dealIds){
        List<Opportunity> lstOppty = new List<Opportunity>();
        Map<Id, OpportunityError> mapFailedDeals = new Map<Id,OpportunityError>();
        List<Opportunity> updatelistDeals = new List<Opportunity>();
        
        lstOppty = [SELECT Id,Name,Co_op_Closed__c,Sales_Organisation__c,Digital_Country_Code__c
                    FROM Opportunity WHERE Id IN :dealIds];
        for(Opportunity opp : lstOppty){
            if(!opp.Co_op_Closed__c &&
               (CRM_AppConstants.GERMANY_SALES_ORGS.contains(opp.Sales_Organisation__c) ||
                CRM_AppConstants.GERMANY_DIGITAL_COUNTRY_CODES.contains(opp.Digital_Country_Code__c))){
                    opp.Co_op_Closed__c = true;
                    updatelistDeals.add(opp);
            }else if(opp.Co_op_Closed__c){
                 mapFailedDeals.put(opp.Id, new OpportunityError(opp, Label.CRM_Deal_Co_op_is_already_Closed));
            }else if(!CRM_AppConstants.GERMANY_SALES_ORGS.contains(opp.Sales_Organisation__c) ||
                 !CRM_AppConstants.GERMANY_DIGITAL_COUNTRY_CODES.contains(opp.Digital_Country_Code__c)){
                 mapFailedDeals.put(opp.Id, new OpportunityError(opp, Label.CRM_Choose_a_German_Deal));
            }
        }
        
        Database.SaveResult[] resultCP = Database.Update(updatelistDeals,false);
        for(Integer i=0; i < resultCP.size(); i++ ){
                if(!resultCP[i].isSuccess()){
                    Database.Error error = resultCP.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    
                    Opportunity failedDeal = updatelistDeals[i];
                    mapFailedDeals.put(failedDeal.Id, new OpportunityError(failedDeal, failedDML));
                }
        }
        
        return mapFailedDeals.values();
    }
    
    global class OpportunityError {
        global String id;
        global String name;
        global String error;
        
        global OpportunityError(Opportunity deal, String errMsg){
          this.id = deal.Id;
          this.name = deal.Name;
          this.error = errMsg;
        }
    }
}