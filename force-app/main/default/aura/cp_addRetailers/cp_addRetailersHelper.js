({
    searchHelper : function(component,event,getInputkeyWord) {
        var existingRets = component.get("v.relRets");
        var selRets = component.get("v.lstSelectedRecords");
        console.log("The existion Option List -->"+JSON.stringify(existingRets,null,2));

        var retItems = [];
        for (var i = 0; i < existingRets.length; i++) {

            var retItem = {
                "Id": existingRets[i].Id,
                "Name": existingRets[i].Name
            };

           retItems.push(retItem);

        }
        if(selRets != null){
            console.log(JSON.stringify(selRets));
            for (var i = 0; i < selRets.length; i++) {

                var selRetItem = {
                    "Id": selRets[i].Id,
                    "Name": selRets[i].Name
                };

                retItems.push(selRetItem);

            }
        }

        // call the apex class method 
        var action = component.get("c.fetchRetailerValues");
        // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'ExcludeitemsList' : retItems
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