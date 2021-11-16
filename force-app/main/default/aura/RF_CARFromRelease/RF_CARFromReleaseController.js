({
    doInit : function(component, event, helper) {
        component.set("v.isOpen", true);  
        var releaseRecordId = component.get("v.recordId");
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        console.log('userId:'+userId);
   },
     closeModel: function(component, event, helper) {
         component.set("v.isOpen", false);
         $A.get('e.force:refreshView').fire();
         $A.get("e.force:closeQuickAction").fire(); 
   },
   
    createNewCAR: function(component, event, helper) {
        var accountId =  component.get("v.selectedLookUpRecord").Id;
        console.log("accountId==>>",accountId);
        var releaseRecordId = component.get("v.recordId");
        var requestName = component.get("v.requestName");
        var dueDate = component.find("inputDueDate");
        var userId = $A.get("$SObjectType.CurrentUser.Id");
                
        if(dueDate!=null){
            var dueDateActual= dueDate.get("v.value");
        }
      
        console.log('accountName:'+accountId+'->'+'requestName:'+requestName+'->'+'dueDate:'+dueDate);
 
        var action = component.get("c.createCAR");   
          action.setParams({
            "releaseId": releaseRecordId,
            "requestName": requestName,
            "accountId": accountId,
            "dueDate": dueDateActual,
             "userId":userId
                     
          });
        
         action.setCallback(this,function(response){
          
            var state = response.getState(); 
             var resultsToast = $A.get("e.force:showToast");            
         
                var state = response.getState();
                
                if(component.isValid() && state === "SUCCESS"){                       
                    var result = response.getReturnValue();
                    var newCARRecordId=response.getReturnValue();
                    var navEvent = $A.get("e.force:navigateToSObject");
                     navEvent.setParams({
                          recordId: newCARRecordId,
                          slideDevName: "detail"
                     });
                     navEvent.fire(); 
                    if(newCARRecordId==releaseRecordId){
                     resultsToast.setParams({
                     "type": "error",
                     "title": "Error!",
                     "message": 'CAR cannot be created for this user!'
                     });
                    }else{
                         resultsToast.setParams({
                     "type": "Success",
                     "title": "Success!",
                     "message": 'CAR is successfully created!'
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
                 "title": "Cannot create CAR!",
                 "message": errorMessage
                 });
         		resultsToast.fire();
             
                helper.hideSpinner(component);
			 }
            
        });       
        
        $A.enqueueAction(action);
      
   }
})