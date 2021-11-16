({
    doInit : function(component, event, helper) {
         var carRecordId = component.get("v.recordId");
       //  component.set("v.isOpen", true);
        var action = component.get("c.setHoldStatus");         
        action.setParams({
            "carId": carRecordId,
         });
        
       action.setCallback(this,function(response){
          
            var state = response.getState(); 
            //var errorMsg = response.getError()[0].message;
            var resultsToast = $A.get("e.force:showToast");            
            if(state === "SUCCESS"){  
                  var state = response.getState();
                    var result = response.getReturnValue();
                 //   console.log('result:'+result);
               // console.log('reason__c:'+response.getReturnValue()[0].reason__c);
                    helper.hideSpinner(component);
                     //component.set("v.isOpen", true);
                    $A.get('e.force:refreshView').fire();
               		$A.get("e.force:closeQuickAction").fire(); 
             }
              else{
                //var errorMessage1=response.getError()[0].pageErrors[0].message;
                //console.log('errorMessage1:'+errorMessage1);
                let errors= response.getError();
                console.log('errors:'+errors);
                let errorMessage= 'Unknown error';
                if(errors && errors.length>0 && errors[0].message){
                 errorMessage= errors[0].message;
                 console.log('errorMessage:'+errorMessage);
                }else{
                    errorMessage=response.getError()[0].pageErrors[0].message;
                    console.log('pageErrors:'+errorMessage);
                }
                 resultsToast.setParams({
                 "type": "Error",
                 "title": "Error!",
                 "message": errorMessage
                 });
         		resultsToast.fire();
                helper.hideSpinner(component);
                component.set("v.isOpen", true);
             }
            
        });       
        
        $A.enqueueAction(action);
    },
     closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
         component.set("v.isOpen", false);
         $A.get('e.force:refreshView').fire();
         $A.get("e.force:closeQuickAction").fire(); 
   },
    saveDetails: function(component, event, helper) {
         var carRecordId = component.get("v.recordId");
         var reasonForCAR = component.get("v.reason");
         console.log('reasonForCAR:'+reasonForCAR);
		  var action = component.get("c.setReason");   
          action.setParams({
            "carId": carRecordId,
            "reasons": reasonForCAR,
             "button":'Hold'
         });
        
         action.setCallback(this,function(response){
          
            var state = response.getState(); 
            //var errorMsg = response.getError()[0].message;
            var resultsToast = $A.get("e.force:showToast");            
         
                var state = response.getState();
                if(component.isValid() && state === "SUCCESS"){                       
                    var result = response.getReturnValue();
                    helper.hideSpinner(component);
                    $A.get('e.force:refreshView').fire();
               		$A.get("e.force:closeQuickAction").fire(); 
                   
                }else{
                 let errors= response.getError();
                console.log('errors:'+errors);
                let errorMessage= 'Unknown error';
					if(errors && errors.length>0 && errors[0].message){
					 errorMessage= errors[0].message;
					 console.log('errorMessage:'+errorMessage);
					}else{
						errorMessage=response.getError()[0].pageErrors[0].message;
						
					}
                 resultsToast.setParams({
                 "type": "Error",
                 "title": "Cannot Submit CAR reason!",
                 "message": errorMessage
                 });
         		resultsToast.fire();
             
                helper.hideSpinner(component);
				component.set("v.isOpen", false);
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire(); 

            }
            
        });       
        
        $A.enqueueAction(action);
      
   }
})