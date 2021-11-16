global class WB_RequestRightsButton_Controller{
    
    public string errorMessage{get; set;}
    public string messageType{get; set;}
    public ID idRec{get;set;}
    public String idList{get;set;}  
    public ApexPages.StandardSetController setCon;
    public List<Title__c> selectedTitles = new List<Title__c>();
    //standard controller
    public WB_RequestRightsButton_Controller(ApexPages.StandardController controller){
        idRec =controller.getRecord().Id;
    }
    //standard set controller
    public WB_RequestRightsButton_Controller(ApexPages.StandardSetController controller){
        setCon = controller;
        idList='';
        selectedTitles = setCon.getSelected();
        for(Title__c titleRec: selectedTitles){
                idList+=titleRec.id+',';
        }
        if(!String.isBlank(idList))  
            idList = idList.substring(0, idList.length() - 1);
    }
    public PageReference passIDReferences(){
        if(checkPageAccess()){
            PageReference pgref = Page.WB_Request_Refresh_Title;
            if(idRec!=null){            
                pgref.getParameters().put('id',idRec);  
                pgref.getParameters().put('param','std');
                return pgref;
            }   
            else if(!String.isBlank(idList) && selectedTitles.size()<=50){
                pgref.getParameters().put('id',idList);              
                return pgref;
            }
            else if(selectedTitles.size()==0){
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please select at least one record'));
                errorMessage = 'Please select at least one record. Please press OK to go back to previous page.';
                messageType = 'offline';
                return null;
            }
            else if(selectedTitles.size()>50){
                //ApexPages.addmessage(new Apexpages.message(ApexPages.severity.FATAL,'The maximum number of titles that can be selected is 50'));
                errorMessage = 'The maximum number of titles that can be selected is 50. Please press OK to go back to previous page.';
                messageType = 'offline';
                return null;
            }       
            return null;
        }else{
            errorMessage = 'You do not have the level of access necessary to perform the operation you requested.Please press OK to go back to previous page.';
            messageType = 'error';
            return null;
        }
    }
    
    @RemoteAction
    global static boolean checkRightRequestPermission() {
        return checkPageAccess();
    }
    
    private static boolean checkPageAccess(){
        List <SetupEntityAccess> SEA =[SELECT Id FROM SetupEntityAccess WHERE Parent.Profile.Id = :UserInfo.getProfileId() AND SetupEntityId in (SELECT Id FROM ApexPage WHERE Name = 'WB_Request_Refresh_Title')];
        if(SEA.isEmpty()){
            return false;
        }else{
            return true;
        }
    }
}