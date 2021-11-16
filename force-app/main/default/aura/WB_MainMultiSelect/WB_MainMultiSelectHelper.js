({
    saveRecord : function(component, event) {
        console.log('recordId==='+component.get("v.recordId"));
        var lstCountRecs = component.get("v.lstSelectedCountries");
        var lstAccRecs = component.get("v.lstSelectedAccounts");
        console.log(lstCountRecs);
        var actionCustomSetting = component.get("c.getCustomSettings");
        actionCustomSetting.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                var maxCountriesAllowed = storeResponse[0];
                var maxAccountsAllowed = storeResponse[1];
                
                if((lstCountRecs != null && lstCountRecs.length > maxCountriesAllowed) || (lstAccRecs != null && lstAccRecs.length > maxAccountsAllowed))
                {
                    var toastEvent = $A.get("e.force:showToast");
                    if(lstCountRecs.length > maxCountriesAllowed)
                    {
                        toastEvent.setParams({
                            "title": "Error",
                            "message": "Maximum "+maxCountriesAllowed+" countries only allowed to save, please remove "+(lstCountRecs.length - maxCountriesAllowed)+" countries to save the record.",
                            "type":"Error"
                        });
                    }
                    else if(lstAccRecs.length > maxAccountsAllowed)
                    {
                        toastEvent.setParams({
                            "title": "Error",
                            "message": "Maximum "+maxAccountsAllowed+" accounts only allowed to save, please remove "+(lstAccRecs.length - maxAccountsAllowed)+" accounts to save the record.",
                            "type":"Error"
                        });
                    }
                    toastEvent.fire();
                } else
                {
                    var action = component.get("c.saveRec");
                    // set param to method  
                    action.setParams({
                        'recId' : component.get("v.recordId"),
                        'lstCountries' : lstCountRecs,
                        'lstAccount' : lstAccRecs
                    });
                    // set a callBack    
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            console.log('In Success');
                            var storeResponse = response.getReturnValue();
                            console.log('storeResponse==='+storeResponse);
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
                    // enqueue the Action  
                    $A.enqueueAction(action);
                }
            }
        });
        $A.enqueueAction(actionCustomSetting);
    }
})