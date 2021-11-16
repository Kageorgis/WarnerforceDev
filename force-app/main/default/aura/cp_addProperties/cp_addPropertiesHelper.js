({
    searchHelper : function(component,event,getInputkeyWord) {
        var existingProps = component.get("v.relProps");
        var selProps = component.get("v.lstSelectedRecords");
        console.log("The existion Option List -->"+JSON.stringify(existingProps,null,2));

        var propitems = [];
        for (var i = 0; i < existingProps.length; i++) {

            var propitem = {
                "Id": existingProps[i].Property__c,
                "Name": existingProps[i].Property__r.Name
            };

            propitems.push(propitem);

        }
        if(selProps != null){
            console.log(JSON.stringify(selProps));
            for (var i = 0; i < selProps.length; i++) {

                var selPropItem = {
                    "Id": selProps[i].Id,
                    "Name": selProps[i].Name
                };

                propitems.push(selPropItem);

            }
        }

        // call the apex class method 
        var action = component.get("c.fetchLookUpValues");
        // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'ExcludeitemsList' : propitems
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
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
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
})