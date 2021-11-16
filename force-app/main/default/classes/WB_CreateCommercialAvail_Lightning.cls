/*
   @Author Cognizant 
   @name WB_CreateCommercialAvail_Lightning.
   @CreateDate 23 Jan 2018
   @Description - Apex class for  Create Release Plan (Detail and List) button on Title
   @Version <1.0>
   @Requirement ER-1660
*/

public class WB_CreateCommercialAvail_Lightning {

  private Id id;
  public Boolean titleMessage{get;set;}
  public String Id1 {get;set;}
  public Integer selected_Record {get;set;}
  public ApexPages.StandardSetController setCon;
  /* Added by trupti*/
    public WB_CreateCommercialAvail_Lightning(ApexPages.StandardSetController controller) {
        setCon = controller;
        id1 = '';
        selected_Record = setCon.getSelected().size();
        if(setCon.getSelected() != NULL){
            for ( Title__c title : (Title__c[])setCon.getSelected() ){
                     id1 += title.Id+',';
            }
        } 
        system.debug('id1***'+id1);
        if(!String.isBlank(id1))  
            id1 = id1.substring(0, id1.length() - 1); 
    }
    public WB_CreateCommercialAvail_Lightning(ApexPages.StandardController controller) {
        id = controller.getRecord().Id;
    } 
   
    public PageReference forwardToListController() {
        //PageReference pr = Page.WB_Create_CommercialAvail;
        PageReference pr = Page.WB_Create_Release_Plan;
        if(id!= NULL){
            pr.getParameters().put('ID', id); //&param=std
            pr.getParameters().put('param','std')  ;
             return pr;
            
        }
        else if(!String.isBlank(id1) && selected_Record <= 50 ){
            pr.getParameters().put('ID', id1);
            return pr;
            
        }
        else if(String.isBlank(id1)){
            Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please select at least one record'));
            titleMessage = true; 
            return null;
        }
       
        else if(selected_Record >50){
            Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'The maximum number of titles that can be selected is 50'));
            titleMessage = true; 
            return null;
        }
        return null;
   }

}