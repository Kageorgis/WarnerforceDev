({
    doInit : function(component, event, helper) {
         var carRecordId = component.get("v.recordId");
        var action = component.get("c.setCancelStatus");         
        action.setParams({
            "carId": carRecordId,
         });
        
       action.setCallback(this,function(response){
          
            var state = response.getState(); 
            //var errorMsg = response.getError()[0].message;
            var resultsToast = $A.get("e.force:showToast");            
            if(state === "SUCCESS"){  
                var state = response.getState();
                if(component.isValid() && state === "SUCCESS"){                       
                    var result = response.getReturnValue();
                    helper.hideSpinner(component);
                    //helper.handleHideSpinner(component);
                    $A.get('e.force:refreshView').fire();
               		$A.get("e.force:closeQuickAction").fire(); 
                   
                }
                else{
                  helper.hideSpinner(component);
                    //helper.handleHideSpinner(component);
                }
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
                 "title": "Cannot Submit CAR status!",
                 "message": errorMessage
                 });
         		resultsToast.fire();
                helper.hideSpinner(component);
                //helper.handleHideSpinner(component);
                component.set("v.isOpen", true);
               // $A.get('e.force:refreshView').fire();
                //$A.get("e.force:closeQuickAction").fire(); 
 
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
          var isSpinner = component.get("v.isSpinner");
          console.log('isSpinner value:'+isSpinner);
           component.set("v.isSpinner", false); 
          action.setParams({
            "carId": carRecordId,
            "reasons": reasonForCAR,
             "button":'Cancel'
         });
        
         action.setCallback(this,function(response){
          
            var state = response.getState(); 
            //var errorMsg = response.getError()[0].message;
            var resultsToast = $A.get("e.force:showToast");            
         
                var state = response.getState();
                if(component.isValid() && state === "SUCCESS"){                       
                    var result = response.getReturnValue();
                    //helper.hideSpinner(component);
                    component.set("v.isSpinner", false); 
                    //helper.handleHideSpinner(component);
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
             
                //helper.hideSpinner(component);
                //helper.handleHideSpinner(component);
				component.set("v.isOpen", false);
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire(); 

            }
            
        });       
        
        $A.enqueueAction(action);
      
   },
    //Call by aura:waiting event  
    handleShowSpinner: function(component, event, helper) {
        console.log('#handleShowSpinner js:');
        component.set("v.isSpinner", true); 
    },
     
    //Call by aura:doneWaiting event 
    handleHideSpinner : function(component,event,helper){
        console.log('$handleHideSpinner js:');
        component.set("v.isSpinner", false);
    }
})