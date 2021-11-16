public class WB_Release_Plan_Split_Lightning {
  
  private String id;
  public Boolean errorMessage{get;set;}
  public String Id1 {get;set;}
  public Integer selected_Record {get;set;}
  public ApexPages.StandardSetController setCon;
  
  public WB_Release_Plan_Split_Lightning(ApexPages.StandardSetController controller){
  		
  	setCon = controller;
    id1 = '';
    selected_Record = setCon.getSelected().size();
    if(setCon.getSelected() != NULL){
    	for ( Commercial_Avail__c rp : (Commercial_Avail__c[])setCon.getSelected() ){
        	id1 += rp.Id+',';
        }
    } 
    system.debug('id1***'+id1);
    if(!String.isBlank(id1))  
    	id1 = id1.substring(0, id1.length() - 1);
  }
  
  public WB_Release_Plan_Split_Lightning(ApexPages.StandardController controller) {
  	//id = controller.getRecord().Id;
  	id = ApexPages.currentPage().getParameters().get('IDs');
  	if(id == null || id.trim().length() == 0){
  		id = ApexPages.currentPage().getParameters().get('ID');
  	}
  } 
  
  public PageReference forwardToListController() {
  	PageReference pr = Page.WB_SplitReleaseplanPage;
  	
  	
  	String UniqueId = ApexPages.currentPage().getParameters().get('UNIQUEID');
  	if(UniqueId != null){
  		uniqueId = UniqueId;
  		system.debug('uniqueId***'+uniqueId);
  	}
  	
  	
   if(id!= NULL){
   
  	pr.getParameters().put('ID', id);
	return pr;
            
   }
   else if(!String.isBlank(id1)){
     pr.getParameters().put('ID', id1);
     return pr;
   }
   else if(uniqueId != Null){
     pr.getParameters().put('UNIQUEID', uniqueId);
     return pr;
   }
   else if(String.isBlank(id1)){
     Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please select at least one record'));
     errorMessage = true; 
     return null;
   }
   
   else if(selected_Record >50){
     Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'The maximum number of titles that can be selected is 50'));
     errorMessage = true; 
     return null;
   }
        return null;
   }

}