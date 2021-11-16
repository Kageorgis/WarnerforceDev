({
    searchHelper : function(component,event,getInputkeyWord) {

        // call the apex class method
        var action = component.get("c.fetchPropertyValues");
        // set param to method
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),

        });
        // set a callBack
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            console.log(state)
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Records Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Records Found...');
                } else {
                    component.set("v.Message", '');
                    // set searchResult list with return value from server.
                }
                component.set("v.listOfSearchRecords", storeResponse);
            }
            if(state === "ERROR"){

                console.log(JSON.stringify(response.getError()))
            }
        });
        // enqueue the Action
        $A.enqueueAction(action);
    },


});