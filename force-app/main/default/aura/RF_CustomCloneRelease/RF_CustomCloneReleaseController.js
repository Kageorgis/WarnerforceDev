({
    doInit : function(component, event, helper) {
        component.set("v.isOpen", true);  
        helper.getCountry(component);
        var releaseRecordId = component.get("v.recordId");
   },
     closeModel: function(component, event, helper) {
         component.set("v.isOpen", false);
         $A.get('e.force:refreshView').fire();
         $A.get("e.force:closeQuickAction").fire(); 
   },
    createCustomCloneRelease: function(component, event, helper) {
        var releaseRecordId = component.get("v.recordId");
      
        var countryName = component.find("InputSelectedCountry");
	
        console.log('countryName:'+countryName.get("v.value"));
 
        var action = component.get("c.createCloneRelease");   
          action.setParams({
            "releaseId": releaseRecordId,
            "countryName": countryName.get("v.value"),
           
          });
        
         action.setCallback(this,function(response){
          
            var state = response.getState(); 
             var resultsToast = $A.get("e.force:showToast");            
         
                var state = response.getState();
                
                if(component.isValid() && state === "SUCCESS"){                       
                    var result = response.getReturnValue();
                    var newReleaseRecordId=response.getReturnValue();
                    var navEvent = $A.get("e.force:navigateToSObject");
                     navEvent.setParams({
                          recordId: newReleaseRecordId,
                          slideDevName: "detail"
                     });
                     navEvent.fire(); 
                    if(newReleaseRecordId==releaseRecordId){
                     resultsToast.setParams({
                     "type": "error",
                     "title": "Error!",
                     "message": 'Clone cannot be created for UPHE source!'
                     });
                    }else{
                         resultsToast.setParams({
                     "type": "Success",
                     "title": "Success!",
                     "message": 'Clone Release is successfully created!'
                     });
                    }
               
                    resultsToast.fire();
                    helper.hideSpinner(component);
                    component.set("v.isOpen", false);
                    $A.get('e.force:refreshView').fire();
               		$A.get("e.force:closeQuickAction").fire(); 
                   
                }else{
                   let errors= response.getError();
                   console.log('errors:'+errors);
                   let errorMessage= 'Unknown error';
             
					if(errors  && errors[0].message){
					 errorMessage= errors[0].message;
					 console.log('errorMessage:'+errorMessage);
					}else{
						errorMessage=response.getError()[0].pageErrors[0].message;
	                }
                  
                 resultsToast.setParams({
                 "type": "Error",
                 "title": "Cannot create Release Clone!",
                 "message": errorMessage
                 });
         		resultsToast.fire();
             
                helper.hideSpinner(component);
			 }
            
        });       
        
        $A.enqueueAction(action);
      
   }
})