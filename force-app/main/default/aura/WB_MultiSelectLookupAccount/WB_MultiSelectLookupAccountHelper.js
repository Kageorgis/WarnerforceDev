({
    loaddata : function(component,event) {
        console.log('recordId==='+component.get("v.recordId"));
        // call the apex class method 
        var action = component.get("c.loadRec");
        // set param to method  
        action.setParams({
            'recId' : component.get("v.recordId")
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('loadibng records');
                var storeResponse = response.getReturnValue();
                console.log('storeResponse===',storeResponse);
                component.set("v.lstSelectedRecords", storeResponse); 
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
    
    searchHelper : function(component,event,getInputkeyWord) {
        console.log('In Account searchHelper');
        console.log('v.lstSelectedRecords',component.get("v.lstSelectedRecords"));
        // call the apex class method 
        var action = component.get("c.searchAccounts");
        
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ExcludeAccounts' : component.get("v.lstSelectedRecords"),
            'lstCountries' : component.get("v.passLstCountries")
        });
        
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Records Found...');
                } else {
                    component.set("v.Message", '');
                    console.log('loading records');
                    var storeResponse = response.getReturnValue();        
                    component.set("v.listOfSearchRecords", storeResponse); 
                }
            }
            else
                component.set("v.Message", 'No Records Found...');
        });
        
        $A.enqueueAction(action);
    },
    
    searchAccountHelper : function(component,event,selectedRecFromEvent) {
        console.log('lstSelectedRecords===',component.get("v.lstSelectedRecords"));
        console.log('selectedRecFromEvent==='+selectedRecFromEvent);
        var action = component.get("c.fetchAccounts");
        action.setParams({
            'selectedRec': selectedRecFromEvent,
            'existingItems' : component.get("v.lstSelectedRecords"),
        });
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Records Found...');
                } else {
                    component.set("v.Message", '');
                }
                console.log('storeResponse===',storeResponse);
                component.set("v.lstSelectedRecords", storeResponse);
                var spinnerAcc = component.find("spinnerAccounts");
                $A.util.addClass(spinnerAcc, 'slds-hide');
                $A.util.removeClass(spinnerAcc, 'slds-show');
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
    
    saveRecord : function(component, event) {
        var accountData = component.get("v.lstSelectedRecords"); 
        
        console.log('accountData==='+accountData);
        console.log('recordId==='+component.get("v.recordId"));
        // call the apex class method 
        var action = component.get("c.saveRec");
        // set param to method  
        action.setParams({
            'recId' : component.get("v.recordId"),
            'lstAccount' : component.get("v.lstSelectedRecords")
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('REFRESINGG');
                //location.reload();
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    }
    
})