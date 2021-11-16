({
	doInit : function(component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
         var forecastRecordId = component.get("v.recordId");
        console.log('userId:'+userId);
        console.log('forecastRecordId:'+forecastRecordId);
        var action = component.get("c.approveForecast");         
        action.setParams({
            "forecastId": forecastRecordId,
             "userId": userId
         });
        
       action.setCallback(this,function(response){
            var state = response.getState(); 
            var resultsToast = $A.get("e.force:showToast");            
            if(state === "SUCCESS"){  
                var state = response.getState();
                //var result = response.getReturnValue();
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire(); 
             }
              else{
                 let errors= response.getError();
                console.log('errors:'+errors);
                 var errorMessage= errors[0].message;
                 console.log('errorMessage1:'+errorMessage);
                //let errorMessage= 'You are not authorized to Approve the Forecast!';
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