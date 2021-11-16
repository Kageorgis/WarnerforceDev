({
	doInit : function(component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
         var forecastRecordId = component.get("v.recordId");
        var action = component.get("c.rejectForecast");  
         console.log('userId:'+userId);
        console.log('forecastRecordId:'+forecastRecordId);
        action.setParams({
            "forecastId": forecastRecordId,
             "userId": userId
         });
        
       action.setCallback(this,function(response){
           var state = response.getState(); 
            var resultsToast = $A.get("e.force:showToast");            
            if(state === "SUCCESS"){  
                var state = response.getState();
              
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire(); 
             }
              else{
                 let errors= response.getError();
                console.log('errors:'+errors);
                var errorMessage= errors[0].message;
                //let errorMessage= 'You are not authorized to Reject the Forecast!';
               
                 resultsToast.setParams({
                 "type": "Error",
                 "title": "Error",
                 "message": errorMessage
                 });
         		resultsToast.fire();
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire(); 
               
            }
            
        });       
        
        $A.enqueueAction(action);
    }
})