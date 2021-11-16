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
        
        action = component.get("c.loadCountries");
        
        action.setParams({
            'recId' : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('loadibng records');
                var storeResponse = response.getReturnValue();        
                component.set("v.lstAvailableCountries", storeResponse); 
            }
        });
        
        $A.enqueueAction(action);
    },
    
    searchHelper : function(component,event,getInputkeyWord) {
        // call the apex class method 
        var action = component.get("c.fetchLookUpValues");
        console.log('listofCG Search helper===',component.get("v.listOfCG"));
        // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ExcludeitemsList' : component.get("v.listOfCG")
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
                console.log('storeResponse===',storeResponse);
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
    
    searchHelperCountry : function(component,event,getInputkeyWord) {
        // call the apex class method 
        var action = component.get("c.fetchCountryNames");
        console.log('listofCG Search helper===',component.get("v.listOfCount"));
        // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ExcludeitemsList' : component.get("v.listOfCount"),
            'selectedRecords' : component.get("v.lstSelectedRecords"),
            'availableCountries' : component.get("v.lstAvailableCountries")
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Records Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.MessageCountry", 'No Records Found...');
                } else {
                    component.set("v.MessageCountry", '');
                    // set searchResult list with return value from server.
                }
                component.set("v.listOfSearchRecordsCountry", storeResponse);
                console.log('storeResponse===',storeResponse);
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
    
    searchCountryGroupHelper : function(component,event,selectedRecFromEvent) {
        console.log('lstSelectedRecords===',component.get("v.lstSelectedRecords"));
        console.log('selectedRecFromEvent==='+selectedRecFromEvent);
        // call the apex class method 
        var action = component.get("c.fetchCountryValues");
        // set param to method  
        action.setParams({
            'selectedRec': selectedRecFromEvent,
            'existingItems' : component.get("v.lstSelectedRecords"),
            'availableCountries' : component.get("v.lstAvailableCountries")
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var lstOfCG = component.get("v.listOfCG");
                console.log('lstOfCG==='+lstOfCG);
                console.log('selectedRecFromEvent==='+selectedRecFromEvent);
                lstOfCG.push(selectedRecFromEvent);
                component.set("v.listOfCG" , lstOfCG);
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Records Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Records Found...');
                } else {
                    component.set("v.Message", '');
                    // set searchResult list with return value from server.
                }
                
                //console.log('storeResponse===',storeResponse);
                //component.set("v.lstSelectedRecords", storeResponse); 
                
                console.log('storeResponse===',storeResponse);
                component.set("v.lstSelectedRecords", storeResponse);
                var spinnerCount = component.find("spinnerCountries");
        		$A.util.addClass(spinnerCount, 'slds-hide');
        		$A.util.removeClass(spinnerCount, 'slds-show');
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
    
    searchCountryGroupHelperCountry : function(component,event,selectedRecFromEvent) {
        console.log('lstSelectedRecords===',component.get("v.lstSelectedRecords"));
        console.log('selectedRecFromEvent==='+selectedRecFromEvent);
        // call the apex class method 
        var action = component.get("c.fetchCountryValuesCountry");
        // set param to method  
        action.setParams({
            'selectedRec': selectedRecFromEvent,
            'existingItems' : component.get("v.lstSelectedRecords"),
            'availableCountries' : component.get("v.lstAvailableCountries")
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var lstOfCount = component.get("v.listOfCount");
                console.log('lstOfCount==='+lstOfCount);
                console.log('selectedRecFromEvent==='+selectedRecFromEvent);
                lstOfCount.push(selectedRecFromEvent);
                component.set("v.listOfCount" , lstOfCount);
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Records Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.MessageCountry", 'No Records Found...');
                } else {
                    component.set("v.MessageCountry", '');
                    // set searchResult list with return value from server.
                }
                
                //console.log('storeResponse===',storeResponse);
                //component.set("v.lstSelectedRecords", storeResponse); 
                
                console.log('storeResponse===',storeResponse);
                component.set("v.lstSelectedRecords", storeResponse);
                var spinnerCount = component.find("spinnerCountries");
        		$A.util.addClass(spinnerCount, 'slds-hide');
        		$A.util.removeClass(spinnerCount, 'slds-show');
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
        
        
        /*var selRecs = component.get("v.lstSelectedRecords");
        console.log('selRecs==='+selRecs);
        console.log('selectedRecFromEvent==='+selectedRecFromEvent);
        if(selectedRecFromEvent != null)
        selRecs.push(selectedRecFromEvent);
        component.set("v.lstSelectedRecords", selRecs);*/
    },
    
    saveRecord : function(component, event) {
        var countryData = component.get("v.lstSelectedRecords"); 
        
        console.log('countryData==='+countryData);
        console.log('recordId==='+component.get("v.recordId"));
        // call the apex class method 
        var action = component.get("c.saveRec");
        // set param to method  
        action.setParams({
            'recId' : component.get("v.recordId"),
            'countData' : component.get("v.lstSelectedRecords")
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