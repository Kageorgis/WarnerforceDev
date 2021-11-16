({
    init : function (component) {
        var action = component.get("c.getselectOptions");
        action.setParams({
            objObject : component.get("v.wbProjectObj"),
            fld : 'Project_Type__c'
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var opts = [];
                /*if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        label: "--- None ---",
                        value: "--- None ---"
                    });
                }*/ 
                /*for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        label: allValues[i],
                        value: allValues[i]
                    });
                }*/
                for (var i = 0; i < allValues.length; i++) {
                    opts.push(allValues[i]);
                }
                //console.log(opts);
                component.set("v.Project_Type",opts)
            }
        });
        $A.enqueueAction(action);
        
        action = component.get("c.getselectOptions");
        action.setParams({
            objObject : component.get("v.wbProjectObj"),
            fld : 'Request_Type__c'
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var opts = [];
                /*if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        label: "--- None ---",
                        value: "--- None ---"
                    });
                }*/ 
                for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                /*for (var i = 0; i < allValues.length; i++) {
                    opts.push(allValues[i]);
                }*/
                console.log(opts);
                component.set("v.Request_Type",opts);
                component.set("v.valuesRequest_Type", allValues[0]);
            }
        });
        $A.enqueueAction(action);
        
        action = component.get("c.getselectOptions");
        action.setParams({
            objObject : component.get("v.wbProjectObj"),
            fld : 'Required_Services__c'
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var opts = [];
                /*if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        label: "--- None ---",
                        value: "--- None ---"
                    });
                }*/ 
                for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                /*for (var i = 0; i < allValues.length; i++) {
                    opts.push(allValues[i]);
                }*/
                console.log(opts);
                component.set("v.Required_Services",opts)
                component.set("v.valuesRequired_Services", allValues[0]);
            }
        });
        $A.enqueueAction(action);
        
        action = component.get("c.getselectOptions");
        action.setParams({
            objObject : component.get("v.wbProjectObj"),
            fld : 'Users_Level__c'
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var opts = [];
                /*if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        label: "--- None ---",
                        value: "--- None ---"
                    });
                }*/ 
                /*for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        label: allValues[i],
                        value: allValues[i]
                    });
                }*/
                if (allValues != undefined && allValues.length > 0) {
                    opts.push("--None--");
                }
                for (var i = 0; i < allValues.length; i++) {
                    opts.push(allValues[i]);
                }
                console.log(opts);
                component.set("v.Users_Level",opts)
            }
        });
        $A.enqueueAction(action);
        
        action = component.get("c.getCountries");
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var opts = [];
                /*if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        label: "--- None ---",
                        value: "--- None ---"
                    });
                }*/ 
                for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                /*for (var i = 0; i < allValues.length; i++) {
                    opts.push(allValues[i]);
                }*/
                //console.log(opts);
                component.set("v.Locations_of_impacted_users",opts);
                console.log('allValues==='+allValues[0]);
                component.set("v.valuesLocations_of_impacted_users", allValues[0]);
                //component.set("v.valuesLocations_of_impacted_users", ["Afghanistan"]);
            }
        });
        $A.enqueueAction(action);
        
        action = component.get("c.getselectOptions");
        action.setParams({
            objObject : component.get("v.wbProjectObj"),
            fld : 'Service_Type__c'
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var opts = [];
                /*if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        label: "--- None ---",
                        value: "--- None ---"
                    });
                }*/ 
                for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                /*if (allValues != undefined && allValues.length > 0) {
                    opts.push("--None--");
                }*/
                /*for (var i = 0; i < allValues.length; i++) {
                    opts.push(allValues[i]);
                }*/
                console.log(opts);
                component.set("v.Service_Type",opts)
                console.log('allValues==='+allValues[0]);
                component.set("v.valuesService_Type", allValues[0]);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleClickWBTSave : function (component, event, helper) {
        //alert('In Handler');
        var flag=0;
        var valInput = component.find("wbtInput");
        var val;
        for(var i=0 ; i < valInput.length ;i++)
        {
            val = valInput[i].get('v.value');
            
            if(val === undefined || val === null || val === '')
            {
                //$A.util.addClass(valInput[i], 'slds-has-error');
                valInput[i].setCustomValidity('This is required field');
                valInput[i].reportValidity();
                flag++;
            }
            else{
                valInput[i].setCustomValidity('  ');                               
                valInput[i].reportValidity();
                $A.util.removeClass(valInput[i], 'slds-has-error');
            }            
        }
        
        /*var reg = new RegExp('^[0-9]+$');
        valInput = component.find("wbtInputPhNo")
        val = valInput.get('v.value')
        if(val === undefined || val === null || val === '')
        {
            //$A.util.addClass(valInput[i], 'slds-has-error');
            valInput.setCustomValidity('This is required field');
            valInput.reportValidity();
            flag++;
        }
        else{
            if(reg.test(val))
            {
                valInput.setCustomValidity('  ');                               
                valInput.reportValidity();
                $A.util.removeClass(valInput, 'slds-has-error');
            }
            else
            {
                valInput.setCustomValidity('This field should contain numbers');
                valInput.reportValidity();
                flag++;
            }
        }

        reg = new RegExp('[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}');
        valInput = component.find("wbtInputEmail")
        val = valInput.get('v.value')
        if(val === undefined || val === null || val === '')
        {
            //$A.util.addClass(valInput[i], 'slds-has-error');
            valInput.setCustomValidity('This is required field');
            valInput.reportValidity();
            flag++;
        }
        else{
            if(reg.test(val))
            {
                valInput.setCustomValidity('  ');                               
                valInput.reportValidity();
                $A.util.removeClass(valInput, 'slds-has-error');
            }
            else
            {
                valInput.setCustomValidity('This field should contain email format');
                valInput.reportValidity();
                flag++;
            }
        }
        */
        valInput = component.find("lookupDiv");
        val = component.get("v.contactRec");
        if(val == null)
        {
            $A.util.addClass(valInput, 'slds-has-error');
            var err = component.find("errorId");
            $A.util.addClass(err, 'slds-show');
            $A.util.removeClass(err, 'slds-hide');
            flag++;
        }
        else{
            $A.util.removeClass(valInput, 'slds-has-error');
            var err = component.find("errorId");
            $A.util.addClass(err, 'slds-hide');
            $A.util.removeClass(err, 'slds-show');
        }
        
        if(flag == 0)
        {
            //alert('In Flag');
            var obj = component.get("v.wbProjectObj");
            
            if(component.find("projecttype").get("v.value") != null)
                obj.Project_Type__c = component.find("projecttype").get("v.value");
            if(component.find("typeofrequest").get("v.value") != null)
                obj.Request_Type__c = component.find("typeofrequest").get("v.value");
            if(component.find("whatservicesarerequired").get("v.value") != null)
                obj.Required_Services__c = component.find("whatservicesarerequired").get("v.value");
            if(component.find("userslevel").get("v.value") != null && component.find("userslevel").get("v.value") != '--None--')
                obj.Users_Level__c = component.find("userslevel").get("v.value");
            else
                obj.Users_Level__c = null;
            if(component.find("locationofimpactedusers").get("v.value") != null)
            {
                var valCheckJS = component.find("locationofimpactedusers").get("v.value");
                var countryName = '';
                var key = 0;
                console.log('Location Display Valu===',valCheckJS.length);
                console.log('key===',key);
                for (key in valCheckJS) {
                    if (valCheckJS.hasOwnProperty(key)) {
                        console.log(key + " = " + valCheckJS[key]);
                        countryName=countryName+valCheckJS[key]+';';
                    }
                } 
                obj.Locations_of_impacted_users__c = countryName;
                //obj.Locations_of_impacted_users__c = component.find("locationofimpactedusers").get("v.value");
            }
            if(component.find("projectapproved").get("v.value") != null)
                obj.Project_Approved__c = component.find("projectapproved").get("v.value");
            //if(component.find("projectfunded").get("v.value") != null)
            //obj.Project_Funded__c = component.find("projectfunded").get("v.value");
            //if(component.find("projectaligntospecificbusiness").get("v.value") != null)
            //obj.Project_align_to_specific_business__c = component.find("projectaligntospecificbusiness").get("v.value");
            if(component.find("projectfunded").get("v.value") != null && component.find("projectfunded").get("v.value") != '--None--')
                obj.Project_Funded__c = component.find("projectfunded").get("v.value");
            else
                obj.Project_Funded__c = null;
            
            if(component.find("projectaligntospecificbusiness").get("v.value") != null && component.find("projectaligntospecificbusiness").get("v.value") != '--None--')
                obj.Project_align_to_specific_business__c = component.find("projectaligntospecificbusiness").get("v.value");
            else
                obj.Project_align_to_specific_business__c = null;
            //alert(component.find("servicetype").get("v.value"));
            //if(component.find("servicetype").get("v.value") != null )
                //obj.Service_Type__c = component.find("servicetype").get("v.value");
			if(component.find("servicetype").get("v.value") != null)
                obj.Service_Type__c = component.find("servicetype").get("v.value");
            //alert(component.get("v.contactRec"));
            obj.Submitter_LookUp__c = component.get("v.contactRec").Id;
            //obj.Path_Picklist__c = 'Assessment';
            
            var action = component.get("c.insertRec");
            action.setParams({ recObj : obj });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //alert('Inserted WBT Save Successfully');
                    console.log('Inserted WBT Save Successfully');
                    //window.location.reload();
                    //alert(response.getReturnValue());
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": response.getReturnValue()
                    });
                    navEvt.fire();
                }
                else{
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    onfocus : function(component,event,helper){
        component.set("v.listOfSearchRecords", null ); 
        component.set("v.contactRec", null ); 
        var forOpen = component.find("lookupContact");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        var getInputkeyWord = '';
        component.set("v.Message", 'Please Enter More than 1 Character..');
        /*var action = component.get("c.fetchContacts");
        action.setParams({
            'searchKeyWord': getInputkeyWord,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Records Found...');
                } else {
                    component.set("v.Message", '');
                }
                component.set("v.listOfSearchRecords", storeResponse); 
                console.log('storeResponse===',storeResponse);
            }
        });
        $A.enqueueAction(action);*/
    },
    
    keyPressController : function(component,event,helper){
        var getInputkeyWord = component.get("v.SearchKeyWord");
        if(getInputkeyWord.length > 1){
            var cmpTarget = component.find('lookupContact');
            $A.util.addClass(cmpTarget, 'slds-show');
            $A.util.removeClass(cmpTarget, 'slds-hide');
            cmpTarget = component.find('lookupValue');
            $A.util.addClass(cmpTarget, 'slds-hide');
            $A.util.removeClass(cmpTarget, 'slds-show');
            var action = component.get("c.fetchContacts");
            action.setParams({
                'searchKeyWord': getInputkeyWord,
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    if (storeResponse.length == 0) {
                        component.set("v.Message", 'No Records Found...');
                    } else {
                        component.set("v.Message", '');
                    }
                    component.set("v.listOfSearchRecords", storeResponse); 
                    console.log('storeResponse===',storeResponse);
                }
            });
            $A.enqueueAction(action);
        }
        else
        {  
            component.set("v.Message", 'Please Enter More than 1 Character..');
            component.set("v.listOfSearchRecords", null ); 
            var cmpTarget = component.find('lookupContact');
            $A.util.addClass(cmpTarget, 'slds-show');
            $A.util.removeClass(cmpTarget, 'slds-hide');
            cmpTarget = component.find('lookupValue');
            $A.util.addClass(cmpTarget, 'slds-hide');
            $A.util.removeClass(cmpTarget, 'slds-show');
        }
    },
    
    handleComponentEvent : function(component, event, helper) {
        console.log('In handleComponentEvent---');
        component.set("v.SearchKeyWord",null);
        var selectedRecGetFromEvent = event.getParam("recordByEvent");
        component.set("v.contactRec",selectedRecGetFromEvent);
        var wbProObj = component.get("v.wbProjectObj");
        var conName = selectedRecGetFromEvent.Name.split(' ');
        wbProObj.Submitter_First_Name__c = conName[0];
        wbProObj.Submitter_Last_Name__c = conName[1];
        wbProObj.Submitter_Email_Id__c = selectedRecGetFromEvent.Email;
        wbProObj.Submitter_Phone_Number__c = selectedRecGetFromEvent.Phone;
        component.set("v.wbProjectObj",wbProObj);
        var cmpTarget = component.find('lookupContact');
        component.set("v.submitterInfo", true);
        $A.util.addClass(cmpTarget, 'slds-hide');
        $A.util.removeClass(cmpTarget, 'slds-show');
        cmpTarget = component.find('lookupValue');
        $A.util.addClass(cmpTarget, 'slds-show');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    
    clear : function(component, event, helper) {
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.contactRec", null );
        component.set("v.submitterInfo", false);
        var cmpTarget = component.find('lookupContact');
        $A.util.addClass(cmpTarget, 'slds-show');
        $A.util.removeClass(cmpTarget, 'slds-hide');
        $A.util.addClass(cmpTarget, 'slds-is-close');
        $A.util.removeClass(cmpTarget, 'slds-is-open');
        cmpTarget = component.find('lookupValue');
        $A.util.addClass(cmpTarget, 'slds-hide');
        $A.util.removeClass(cmpTarget, 'slds-show');
    },
    
    onblur : function(component, event, helper) {
        var cmpTarget = component.find('lookupContact');
        $A.util.addClass(cmpTarget, 'slds-is-close');
        $A.util.removeClass(cmpTarget, 'slds-is-open');
    },
})