global class WB_RequestRightonMPM_Controller{
//ER-006863 -start
    public string errorMessage{get; set;}
    public string messageType{get; set;}
//ER-006863 -end
public ID idRec{get;set;}
public String idList{get;set;}  
public ApexPages.StandardSetController setCon;
public List<MPM__c> selectedMPMs = new List<MPM__c>();
//standard controller
public WB_RequestRightonMPM_Controller(ApexPages.StandardController controller){
    idRec =controller.getRecord().Id;
}
//standard set controller
public WB_RequestRightonMPM_Controller(ApexPages.StandardSetController controller){
    setCon = controller;
    idList='';
    selectedMPMs = setCon.getSelected();
    for(MPM__c mpmRec: selectedMPMs){
        idList+=mpmRec.id+',';
    }
    if(!String.isBlank(idList))  
        idList = idList.substring(0, idList.length() - 1);
}
public PageReference passIDReferences(){

    if(checkPageAccess()){  //ER-006863 
    PageReference pgref = Page.WB_Request_Refresh;
    if(idRec!=null){            
        pgref.getParameters().put('id',idRec);  
        pgref.getParameters().put('param','std');
        return pgref;
    }   
    else if(!String.isBlank(idList) && selectedMPMs.size()<=50){            
        pgref.getParameters().put('id',idList);              
        return pgref;
    }
    else if(selectedMPMs.size()==0){
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please select at least one record'));        
        errorMessage = 'Please select at least one record';
        return null;
    }
    else if(selectedMPMs.size()>50){
        //ApexPages.addmessage(new Apexpages.message(ApexPages.severity.FATAL,'The maximum number of mpms that can be selected is 50'));
        errorMessage = 'The maximum number of mpms that can be selected is 50';
        return null;
    }       
    return null;
}else{   //ER-006863 -start
    errorMessage = 'You do not have the level of access necessary to perform the operation you requested.Please press OK to go back to previous page.';
    messageType = 'error';
    return null;
}
}
//ER-006863 -start
@RemoteAction
global static boolean checkRightRequestPermissionMPM() {
    return checkPageAccess();
}
private static boolean checkPageAccess(){
    List <SetupEntityAccess> SEA =[SELECT Id FROM SetupEntityAccess WHERE Parent.Profile.Id = :UserInfo.getProfileId() AND SetupEntityId in (SELECT Id FROM ApexPage WHERE Name = 'WB_Request_Refresh')];
    if(SEA.isEmpty()){
        return false;
    }else{
        return true;
    }
}
//ER-006863 -end
}