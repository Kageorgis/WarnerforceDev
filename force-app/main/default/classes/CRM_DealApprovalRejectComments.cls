public with sharing class CRM_DealApprovalRejectComments{
    public String DealIds {get;set;}
    public ProcessInstanceStep pStep{get;set;}
    
    public CRM_DealApprovalRejectComments(){}
 
	public ProcessInstanceStep getApprovalSteps() {
		if (DealIds != null) {
        	pStep = [Select SystemModstamp, StepStatus, ProcessInstanceId, OriginalActorId,OriginalActor.Name,
    						Comments, ActorId 
    			     From ProcessInstanceStep 
    			     where ProcessInstance.TargetObjectId=:DealIds order by SystemModstamp desc Limit 1];  
    
  		}
    	return pStep ;
    }
}