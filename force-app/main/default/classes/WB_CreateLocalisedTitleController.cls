public with sharing class WB_CreateLocalisedTitleController{
Public Local_Title__c localtitileobj;
public string titleid;
public String var {get;set;}
public Title__c lst_titledetails {get; set;}

    public WB_CreateLocalisedTitleController(ApexPages.StandardSetController controller) {
        localtitileobj = (Local_Title__c) controller.getRecord();
        titleid = ApexPages.currentPage().getParameters().get('ID');                
        localtitileobj.Title__c = titleid; 
        lst_titledetails = [SELECT id,name,Video_Version__c FROM Title__c WHERE id = :titleid ];
     //   localtitileobj.Readiness__c ='Requires Review';
       
     }
    public pageReference savelocalisedtitle(){
        Local_Title__c localtitleobjs = new Local_Title__c();
        if(localtitileobj.Name!= null && localtitileobj.Title__c!= null && localtitileobj.Language__c!=null && lst_titledetails.Video_Version__c!= null && localtitileobj.Country__c!= null ){
        
        integer localTitleCount=[select count() from local_title__c where Title_VV_F__c=:lst_titledetails.Video_Version__c AND Country__c=: localtitileobj.Country__c AND Language__c=:localtitileobj.Language__c AND External_Company__c = Null] ;
        if(localTitleCount==0){
        localtitleobjs.name = localtitileobj.name;
        //localtitleobjs.Video_Version__c= lst_titledetails.Video_Version__c;
        localtitleobjs.Title__c= lst_titledetails.id;
        localtitleobjs.Country__c= localtitileobj.Country__c;
        localtitleobjs.Language__c= localtitileobj.Language__c;
        
        if(localtitileobj.Status__c != null){
            localtitleobjs.Status__c= localtitileobj.Status__c;
        }else{localtitleobjs.Status__c = '';}
        
        if(localtitileobj.Edit_EIDR_2D__c != null){
        	localtitleobjs.Edit_EIDR_2D__c= localtitileobj.Edit_EIDR_2D__c;
        }
        else if(localtitileobj.Edit_EIDR_3D__c != null){
        	localtitleobjs.Edit_EIDR_3D__c= localtitileobj.Edit_EIDR_3D__c;
        }
        else{
        	localtitleobjs.Edit_EIDR_2D__c = '';
        	localtitleobjs.Edit_EIDR_3D__c = '';
        }        

        if(localtitileobj.Local_Rating__c!= null){
            localtitleobjs.Local_Rating__c= localtitileobj.Local_Rating__c;
        }else{localtitleobjs.Local_Rating__c = '';
        }
       
        if(localtitileobj.Local_Synopsis__c!= null){
            localtitleobjs.Local_Synopsis__c= localtitileobj.Local_Synopsis__c;
        }else{localtitleobjs.Local_Synopsis__c = '';
        }
        
        if(localtitileobj.Local_Label__c!= null){
            localtitleobjs.Local_Label__c= localtitileobj.Local_Label__c;
        }else{localtitleobjs.Local_Label__c = '';
        }
        
        if(localtitileobj.Caption_Included_picklist__c!= null){
            localtitleobjs.Caption_Included_picklist__c= localtitileobj.Caption_Included_picklist__c;
        }else{localtitleobjs.Caption_Included_picklist__c = '';
        }
        
        
        if(localtitileobj.Local_Run_Time__c != null){
            localtitleobjs.Local_Run_Time__c= localtitileobj.Local_Run_Time__c;
        }
        
        if(localtitileobj.Local_Theatrical_Release_Date__c != null){
            localtitleobjs.Local_Theatrical_Release_Date__c= localtitileobj.Local_Theatrical_Release_Date__c;
        }
        
        if(localtitileobj.Local_TV_Air_Date__c != null){
            localtitleobjs.Local_TV_Air_Date__c= localtitileobj.Local_TV_Air_Date__c;
        }
        
        if(localtitileobj.Local_DVD_Release_Date__c != null){
            localtitleobjs.Local_DVD_Release_Date__c= localtitileobj.Local_DVD_Release_Date__c;
        }
        
        if(localtitileobj.Local_BD_Release_Date__c != null){
            localtitleobjs.Local_BD_Release_Date__c= localtitileobj.Local_BD_Release_Date__c;
        }
        
        if(localtitileobj.UV_Published_Date__c != null){
            localtitleobjs.UV_Published_Date__c= localtitileobj.UV_Published_Date__c;
        }
        
        if(localtitileobj.ALID__c != null){
            localtitleobjs.ALID__c= localtitileobj.ALID__c;
        }else{localtitleobjs.ALID__c =''; 
        }
        
        if(localtitileobj.CID__c != null){
            localtitleobjs.CID__c= localtitileobj.CID__c;
        }else{localtitleobjs.CID__c =''; 
        }
        
     /*   if(localtitileobj.Readiness__c != null){
            localtitleobjs.Readiness__c= localtitileobj.Readiness__c;
        }else{
            localtitleobjs.Readiness__c ='';
        }
     */   
        localtitleobjs.Caption_Required__c= localtitileobj.Caption_Required__c;//ER-000023 : As this assignment was missing, trigger was not working as expected
        
        try{
            insert localtitleobjs;
            
            pageReference PageRef = new Pagereference('/'+lst_titledetails.id);
            return PageRef;  
        }Catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
            Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Duplicate Video Version Id'));
        }
               
        } else Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Duplicate Local Data'));
        
        }
        else {         
          Apexpages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please select all required values'));
        }
         return null; 
        }  
         
}