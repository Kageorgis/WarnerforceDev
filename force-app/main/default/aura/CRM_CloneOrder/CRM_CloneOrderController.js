({
    CloneOrder: function (component, event, helper){
        //debugger;
        component.set("v.IsSpinner", true);
        var selectedVal = component.get("v.cloneOption");
        var orderWithProduct = selectedVal == 'CloneWithProducts' ? true : false ;
        console.log(selectedVal + '--' + orderWithProduct + '--' + component.get("v.recordId"));
        
        var cloneAction = component.get("c.cloneOrderProducts");
        cloneAction.setParams({
            orderId: component.get("v.recordId"),
            cloneProducts: orderWithProduct
        });
        cloneAction.setCallback(this, function(response){
        	var state = response.getState();
            var clonedOrderResponse = response.getReturnValue();
            console.log('clonedOrderId:'+clonedOrderResponse);
            var isOrderSuccess = clonedOrderResponse[0].startsWith("801");
            //debugger;
            if(isOrderSuccess){
                //var clonedOrderId = response.getReturnValue();
                console.log('clonedOrderId:'+clonedOrderResponse);
                //var isOrderSuccess = clonedOrderResponse.startsWith("801");
                //debugger;
                component.set("v.IsSpinner", false);
                $A.get("e.force:closeQuickAction").fire();
                window.setTimeout(
                    $A.getCallback(function(){
                        var editRecordEvent = $A.get("e.force:editRecord");
                        editRecordEvent.setParams({
                            "recordId": clonedOrderResponse[0],
                        });
                        editRecordEvent.fire();
                    }), 2000
                ); 
                
                var urlEvent = $A.get("e.force:navigateToSObject");
                urlEvent.setParams({
                    "recordId": clonedOrderResponse[0],
                    "isredirect": "true"
                });
                urlEvent.fire();
                
            }else if(!isOrderSuccess){
                component.set("v.hasError", true);
                component.set("v.IsSpinner", false);
                //var errors = response.getError();
                var combinedErrors = ""; 
                for(var i=0; i<clonedOrderResponse.length; i++){
                    combinedErrors +=  clonedOrderResponse[i] + "\n";
                }
                 component.set("v.errorMessage",combinedErrors);
                 console.log("Error message: " + combinedErrors);
            }
        });
        $A.enqueueAction(cloneAction);
    },
    
    CloneCancel: function (component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    }
})