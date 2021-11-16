({
    saveRecord : function(component, event) {
        //saveRecord : function(component, event, fields) {
        console.log('recordId==='+component.get("v.recordId"));
        console.log('v.lstSelectedCountries==='+component.get("v.lstSelectedCountries"));
        console.log('v.lstSelectedAccounts==='+component.get("v.lstSelectedAccounts"));
        
        var action = component.get("c.saveRec");
        action.setParams({
            'recId' : component.get("v.recordId"),
            'lstCountries' : component.get("v.lstSelectedCountries"),
            'lstAccount' : component.get("v.lstSelectedAccounts")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('In Success');
                var storeResponse = response.getReturnValue();
                console.log('storeResponse==='+storeResponse);
                //component.find("form").submit(fields);
                if(storeResponse == false)
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "You have selected Invalid Accounts.",
                        "type": "error"
                    });
                    toastEvent.fire();
                }
                else
                {
                    var editFormRec = component.find('editForm');
                    $A.util.addClass(editFormRec, 'slds-hide');
                    $A.util.removeClass(editFormRec, 'slds-show');
                    var viewFormRec = component.find('viewForm');
                    $A.util.addClass(viewFormRec, 'slds-show');
                    $A.util.removeClass(viewFormRec, 'slds-hide');
                    
                    /*var editFormRec = component.find('saveFormButton');
                    $A.util.addClass(editFormRec, 'slds-hide');
                    $A.util.removeClass(editFormRec, 'slds-show');*/
                    var viewFormRec = component.find('editFormButton');
                    $A.util.addClass(viewFormRec, 'slds-show');
                    $A.util.removeClass(viewFormRec, 'slds-hide');
                    var cloneRec = component.find('cloneButton');
                    $A.util.addClass(cloneRec, 'slds-show');
                    $A.util.removeClass(cloneRec, 'slds-hide');
                    //component.find("form").submit(fields);
                    //component.set("v.countAccFlag", true);
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "The record has been Saved successfully.",
                        "type": "success"
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    }
})