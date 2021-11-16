({
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    
    getUserAccessRecord : function(component, event, helper, userId) {
        var action = component.get("c.getRecordValues");   
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        action.setParams({
            "userId": userId
        });
        action.setCallback(this,function(response){
            var state = response.getState();    
            if(state === "SUCCESS"){  
                var state = response.getState();
                if(component.isValid() && state === "SUCCESS"){                       
                    var result = response.getReturnValue();
                    helper.hideSpinner(component);
                    $A.get("e.force:closeQuickAction").fire(); 
                    $A.get('e.force:refreshView').fire();
                }
                else{
                    helper.hideSpinner(component);
                }
            }
            else{
                helper.hideSpinner(component);
            }
            
        });       
        
        $A.enqueueAction(action);
    }
})