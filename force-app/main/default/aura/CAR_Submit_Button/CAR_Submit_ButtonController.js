({
    doInit : function(component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
         var carRecordId = component.get("v.recordId");
        var action = component.get("c.setCarStatus");         
        action.setParams({
            "carId": carRecordId,
             "userId": userId
         });
        
       action.setCallback(this,function(response){
          
            var state = response.getState(); 
            //var errorMsg = response.getError()[0].message;
            var resultsToast = $A.get("e.force:showToast");            
            if(state === "SUCCESS"){  
                var state = response.getState();
                
                if(component.isValid() && state === "SUCCESS"){                       
                    var result = response.getReturnValue();
                    const objJSON = JSON.stringify(result);
                    console.log('objJSON:'+objJSON);
                    JSON.parse(objJSON, (key, value) => {
                        console.log('key:'+key);
                        console.log('value:'+value);
                      if (key === 'ArtTrack_Client_Match__c' && value==true) {
                         window.$Label = window.$Label || {};
                         $Label.RF_ASSIGNED = '{!JSENCODE($Label.RF_ASSIGNED)}';
                         var x =  $Label.RF_ASSIGNED;
                        console.log(x);
                         alert('Selected Account is missing a mapped ArtTrack Client Name.Please update the account or work with ArtTrack Support to add a mapped ArtTrack Client Name.');
                      }
                    });
                    
                    helper.hideSpinner(component);
                    $A.get('e.force:refreshView').fire();
               		$A.get("e.force:closeQuickAction").fire(); 
                   
                }
                else{
                   helper.hideSpinner(component);
                }
            }
            else{
              // var errorMessage1=response.getError()[0].pageErrors[0].message;
               // console.log('errorMessage1:'+errorMessage1);
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
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire(); 
              //  component.set("v.isOpen", true);
 
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
            "reasons": reasonForCAR
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