/**
   @Author Cognizant Technology Solutions
   @name CRM_CloneDealWithProductsController
   @CreateDate 12/4/2015
   @Description The class is used to pass the Deal Id to visual flow parameter and redirect to new Deal Id created using Flow
   @Version 1.0
   @reference None
  */
public with Sharing class CRM_CloneDealNDealProductGrpController{
   
    private final Opportunity opt;
    public Map<String, Object> params;
    
    //Constructor
    public CRM_CloneDealNDealProductGrpController(ApexPages.StandardController controller) {
        this.opt= (Opportunity)controller.getRecord();
        params = new Map<String, Object>();                
    }
    /**
    *  Description-The method is used to pass parameter to Flow and instantiate the page to which the flow should redirect
    *  @name-startFlow
    *  @param-None
    *  @return-The return parameter redirects to the new Deal edit layout
    *  @throws exception-An unhandled fault has occurred while processing the flow.Please contact your system administrator for more information.
    */
    public PageReference startFlow(){
        
        PageReference OppPage;
        try{
            
            params.put('Var_CurrentDealId',opt.ID);
            Flow.Interview.CRM_Clone_Deals_Deal_Product_Groups CRMCloneDeal = new Flow.Interview.CRM_Clone_Deals_Deal_Product_Groups(params);
            CRMCloneDeal.Start();
            String returnValue = (String)CRMCloneDeal.getVariableValue('Var_NewDealId');
            
            if(String.isNotBlank(returnValue)){
                OppPage = new PageReference('/'+returnValue+'/e?retURL=%2F'+returnValue);
                OppPage.setRedirect(true);
            }
            System.debug('Exception');
            return OppPage;
        }
        catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
        
    }
}