({
    init : function (component, event, helper) {
        /*var action = component.get("c.isUserWorthy");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert("From server: " + response.getReturnValue());
                component.set("v.worthy", response.getReturnValue());
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
        console.log(component.get("v.worthy"));
        $A.enqueueAction(action);*/
        
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
                component.set("v.Request_Type",opts)
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
                        label: allValues[i].trim(),
                        value: allValues[i].trim()
                    });
                }
                /*for (var i = 0; i < allValues.length; i++) {
                    opts.push(allValues[i]);
                }*/
                console.log('Locations_of_impacted_users===',opts);
                component.set("v.Locations_of_impacted_users",opts)
                component.set("v.valuesLocations_of_impacted_users", allValues[0].trim());
            }
        });
        $A.enqueueAction(action);
        
        
        
        
        action = component.get("c.getselectOptions");
        action.setParams({
            objObject : component.get("v.wbProjectObj"),
            fld : 'GWS_Project_Type__c'
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var opts = [];
                /*if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        label: "--None--",
                        value: "--None--"
                    });
                }*/ 
                /*for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        label: allValues[i],
                        value: allValues[i]
                    });
                }*/
                /*if (allValues != undefined && allValues.length > 0) {
                    opts.push("--None--");
                }*/
                for (var i = 0; i < allValues.length; i++) {
                    opts.push(allValues[i]);
                }
                console.log(opts);
                component.set("v.GWS_Project_Type",opts)
            }
        });
        $A.enqueueAction(action);
        
        action = component.get("c.getselectOptions");
        action.setParams({
            objObject : component.get("v.wbProjectObj"),
            fld : 'Cost_Delivery_Estimate__c'
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var opts = [];
                /*if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        label: "--None--",
                        value: "--None--"
                    });
                }*/ 
                /*for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        label: allValues[i],
                        value: allValues[i]
                    });
                }*/
                /*if (allValues != undefined && allValues.length > 0) {
                    opts.push("--None--");
                }*/
                for (var i = 0; i < allValues.length; i++) {
                    opts.push(allValues[i]);
                }
                console.log(opts);
                component.set("v.Cost_Delivery_Estimate",opts)
            }
        });
        $A.enqueueAction(action);
        
        action = component.get("c.getselectOptions");
        action.setParams({
            objObject : component.get("v.wbProjectObj"),
            fld : 'High_Level_Project_Activities__c'
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var opts = [];
                /*if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        label: "--None--",
                        value: "--None--"
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
                }
                for (var i = 0; i < allValues.length; i++) {
                    opts.push(allValues[i]);
                }
                console.log(opts);*/
                component.set("v.High_Level_Project_Activities",opts)
            }
        });
        $A.enqueueAction(action);
        
        action = component.get("c.getselectOptions");
        action.setParams({
            objObject : component.get("v.wbProjectObj"),
            fld : 'Impacted_Teams__c'
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var opts = [];
                /*if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        label: "--None--",
                        value: "--None--"
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
                }
                for (var i = 0; i < allValues.length; i++) {
                    opts.push(allValues[i]);
                }
                console.log(opts);*/
                component.set("v.Impacted_Teams",opts)
            }
        });
        $A.enqueueAction(action);
        
        action = component.get("c.getselectOptions");
        action.setParams({
            objObject : component.get("v.wbProjectObj"),
            fld : 'Other_Potential_Impacts__c'
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var opts = [];
                /*if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        label: "--None--",
                        value: "--None--"
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
                }
                for (var i = 0; i < allValues.length; i++) {
                    opts.push(allValues[i]);
                }
                console.log(opts);*/
                component.set("v.Other_Potential_Impacts",opts)
            }
        });
        $A.enqueueAction(action);
        
        action = component.get("c.getselectOptions");
        action.setParams({
            objObject : component.get("v.wbProjectObj"),
            fld : 'Complexity__c'
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var opts = [];
                /*if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        label: "--None--",
                        value: "--None--"
                    });
                }*/ 
                /*for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        label: allValues[i],
                        value: allValues[i]
                    });
                }*/
                /*if (allValues != undefined && allValues.length > 0) {
                    opts.push("--None--");
                }*/
                for (var i = 0; i < allValues.length; i++) {
                    opts.push(allValues[i]);
                }
                console.log(opts);
                component.set("v.Complexity",opts)
            }
        });
        $A.enqueueAction(action);
        
        action = component.get("c.getselectOptions");
        action.setParams({
            objObject : component.get("v.wbProjectObj"),
            fld : 'Next_Steps__c'
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var opts = [];
                /*if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        label: "--None--",
                        value: "--None--"
                    });
                }*/ 
                /*for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        label: allValues[i],
                        value: allValues[i]
                    });
                }*/
                /*if (allValues != undefined && allValues.length > 0) {
                    opts.push("--None--");
                }*/
                for (var i = 0; i < allValues.length; i++) {
                    opts.push(allValues[i]);
                }
                console.log(opts);
                component.set("v.Next_Steps",opts)
            }
        });
        $A.enqueueAction(action);
        
        action = component.get("c.getValues");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.wbProjectObj",response.getReturnValue());
                var conRec = component.get("v.contactRec");
                //alert(response.getReturnValue().Approval_Stage__c);
                //alert(component.get("v.wbProjectObj.Approval_Stage__c"));
                component.set("v.loaded",true);
                if(response.getReturnValue().Submitter_LookUp__r != null)
                {
                    //alert(response.getReturnValue().Submitter_LookUp__r.Name);
                    conRec.Id = response.getReturnValue().Submitter_LookUp__r.Id;
                    conRec.Name = response.getReturnValue().Submitter_LookUp__r.Name;
                    conRec.Email = response.getReturnValue().Submitter_LookUp__r.Email;
                    conRec.Phone = response.getReturnValue().Submitter_LookUp__r.Phone;
                    component.set("v.contactRec",conRec);
                }
                else
                    console.log('false')
                    //alert('false');
                    if(response.getReturnValue().Request_Type__c != null)
                    {
                        var varRequest_Type = response.getReturnValue().Request_Type__c.split(';');
                        component.set("v.valuesRequest_Type", varRequest_Type);
                    }
                else
                {
                    component.set("v.valuesRequest_Type", ["Training"]);
                }
                if(response.getReturnValue().Required_Services__c != null)
                {
                    var varRequired_Services = response.getReturnValue().Required_Services__c.split(';');
                    component.set("v.valuesRequired_Services", varRequired_Services);
                }
                else
                {
                    component.set("v.valuesRequired_Services", ["SCCM"]);
                }
                console.log('value lcoation',response.getReturnValue().Locations_of_impacted_users__c);
                if(response.getReturnValue().Locations_of_impacted_users__c != null)
                {
                    //var varLocations_of_impacted_users = response.getReturnValue().Locations_of_impacted_users__c.split(';');
                    var varLocations_of_impacted_users = response.getReturnValue().Locations_of_impacted_users__c.split(";").map(function(item) {
                        return item.trim();
                    });
                    console.log('varLocations_of_impacted_users===',varLocations_of_impacted_users);
                    component.set("v.valuesLocations_of_impacted_users", varLocations_of_impacted_users);
                }
                else
                {
                    //component.set("v.valuesLocations_of_impacted_users", ["Afghanistan"]);
                }
                if(response.getReturnValue().High_Level_Project_Activities__c != null)
                {
                    var varHigh_Level_Project_Activities = response.getReturnValue().High_Level_Project_Activities__c.split(';');
                    component.set("v.valuesHigh_Level_Project_Activities", varHigh_Level_Project_Activities);
                }
                else
                {
                    component.set("v.valuesHigh_Level_Project_Activities", ["Technical Modification"]);
                }
                if(response.getReturnValue().Impacted_Teams__c != null)
                {
                    var varImpacted_Teams = response.getReturnValue().Impacted_Teams__c.split(';');
                    component.set("v.valuesImpacted_Teams", varImpacted_Teams);
                }
                else
                {
                    component.set("v.valuesImpacted_Teams", ["Workplace/Tech Architecture"]);
                }
                if(response.getReturnValue().Other_Potential_Impacts__c != null)
                {
                    var varOther_Potential_Impacts = response.getReturnValue().Other_Potential_Impacts__c.split(';');  
                    component.set("v.valuesOther_Potential_Impacts", varOther_Potential_Impacts);
                }
                else
                {
                    component.set("v.valuesOther_Potential_Impacts", ["Lack of in house resources/skill"]);
                }
                var objRec = component.get("v.wbProjectObj");
                if(objRec.Path_Picklist__c == null)
                {
                    var cmpTarget = component.find('wbtDisplay');
                    $A.util.addClass(cmpTarget, 'slds-show');
                    $A.util.removeClass(cmpTarget, 'slds-hide');
                    component.set("v.wbtSection", false);
                    cmpTarget = component.find('wbtEdit');
                    $A.util.addClass(cmpTarget, 'slds-hide');
                    $A.util.removeClass(cmpTarget, 'slds-show');
                    
                    cmpTarget = component.find('gwsDisplay');
                    $A.util.addClass(cmpTarget, 'slds-hide');
                    $A.util.removeClass(cmpTarget, 'slds-show');
                    cmpTarget = component.find('gwsEdit');
                    $A.util.addClass(cmpTarget, 'slds-show');
                    $A.util.removeClass(cmpTarget, 'slds-hide');
                    
                    cmpTarget = component.find('ApprovalEdit');
                    $A.util.addClass(cmpTarget, 'slds-hide');
                    $A.util.removeClass(cmpTarget, 'slds-show');
                }
                else if(objRec.Path_Picklist__c == 'Initial Details')
                {
                    var cmpTarget = component.find('wbtDisplay');
                    $A.util.addClass(cmpTarget, 'slds-hide');
                    $A.util.removeClass(cmpTarget, 'slds-show');
                    cmpTarget = component.find('wbtEdit');
                    $A.util.addClass(cmpTarget, 'slds-show');
                    $A.util.removeClass(cmpTarget, 'slds-hide');
                    
                    cmpTarget = component.find('gwsDisplay');
                    $A.util.addClass(cmpTarget, 'slds-hide');
                    $A.util.removeClass(cmpTarget, 'slds-show');
                    cmpTarget = component.find('gwsEdit');
                    $A.util.addClass(cmpTarget, 'slds-hide');
                    $A.util.removeClass(cmpTarget, 'slds-show');
                    
                    cmpTarget = component.find('ApprovalEdit');
                    $A.util.addClass(cmpTarget, 'slds-hide');
                    $A.util.removeClass(cmpTarget, 'slds-show');
                }
                    else if(objRec.Path_Picklist__c == 'Assessment')
                    {
                        var cmpTarget = component.find('wbtDisplay');
                        $A.util.removeClass(cmpTarget, 'slds-show');
                        $A.util.addClass(cmpTarget, 'slds-hide');
                        component.set("v.wbtSection", false);
                        cmpTarget = component.find('wbtEdit');
                        $A.util.removeClass(cmpTarget, 'slds-hide');
                        $A.util.addClass(cmpTarget, 'slds-show');
                        
                        cmpTarget = component.find('gwsDisplay');
                        $A.util.addClass(cmpTarget, 'slds-hide');
                        $A.util.removeClass(cmpTarget, 'slds-show');
                        cmpTarget = component.find('gwsEdit');
                        $A.util.addClass(cmpTarget, 'slds-show');
                        $A.util.removeClass(cmpTarget, 'slds-hide');
                        
                        cmpTarget = component.find('ApprovalEdit');
                        $A.util.addClass(cmpTarget, 'slds-hide');
                        $A.util.removeClass(cmpTarget, 'slds-show');
                    }
                        else if(objRec.Path_Picklist__c == 'Approval')
                        {
                            var cmpTarget = component.find('wbtDisplay');
                            $A.util.removeClass(cmpTarget, 'slds-show');
                            $A.util.addClass(cmpTarget, 'slds-hide');
                            component.set("v.wbtSection", false);
                            cmpTarget = component.find('wbtEdit');
                            $A.util.removeClass(cmpTarget, 'slds-hide');
                            $A.util.addClass(cmpTarget, 'slds-show');
                            
                            cmpTarget = component.find('gwsDisplay');
                            $A.util.removeClass(cmpTarget, 'slds-show');
                            $A.util.addClass(cmpTarget, 'slds-hide');
                            component.set("v.wbtSection", false);
                            cmpTarget = component.find('gwsEdit');
                            $A.util.removeClass(cmpTarget, 'slds-hide');
                            $A.util.addClass(cmpTarget, 'slds-show');
                            
                            cmpTarget = component.find('ApprovalEdit');
                            $A.util.addClass(cmpTarget, 'slds-show');
                            $A.util.removeClass(cmpTarget, 'slds-hide');
                        }
                /*if(objRec.Path_Picklist__c == null)
                {
                    var cmpTarget = component.find('wbtDisplay');
                    $A.util.addClass(cmpTarget, 'slds-show');
                    $A.util.removeClass(cmpTarget, 'slds-hide');
                    component.set("v.wbtSection", false);
                    cmpTarget = component.find('wbtEdit');
                    $A.util.addClass(cmpTarget, 'slds-hide');
                    $A.util.removeClass(cmpTarget, 'slds-show');
                    
                    cmpTarget = component.find('gwsDisplay');
                    $A.util.addClass(cmpTarget, 'slds-hide');
                    $A.util.removeClass(cmpTarget, 'slds-show');
                    cmpTarget = component.find('gwsEdit');
                    $A.util.addClass(cmpTarget, 'slds-show');
                    $A.util.removeClass(cmpTarget, 'slds-hide');
                    
                    cmpTarget = component.find('ApprovalEdit');
                    $A.util.addClass(cmpTarget, 'slds-hide');
                    $A.util.removeClass(cmpTarget, 'slds-show');
                }
                else if(objRec.Path_Picklist__c == 'Initial Details')
                {
                    var cmpTarget = component.find('wbtDisplay');
                    $A.util.addClass(cmpTarget, 'slds-hide');
                    $A.util.removeClass(cmpTarget, 'slds-show');
                    cmpTarget = component.find('wbtEdit');
                    $A.util.addClass(cmpTarget, 'slds-show');
                    $A.util.removeClass(cmpTarget, 'slds-hide');
                    
                    cmpTarget = component.find('gwsDisplay');
                    $A.util.addClass(cmpTarget, 'slds-hide');
                    $A.util.removeClass(cmpTarget, 'slds-show');
                    cmpTarget = component.find('gwsEdit');
                    $A.util.addClass(cmpTarget, 'slds-hide');
                    $A.util.removeClass(cmpTarget, 'slds-show');
                    
                    cmpTarget = component.find('ApprovalEdit');
                    $A.util.addClass(cmpTarget, 'slds-hide');
                    $A.util.removeClass(cmpTarget, 'slds-show');
                }
                    else if(objRec.Path_Picklist__c == 'Assessment')
                    {
                        var cmpTarget = component.find('wbtDisplay');
                        $A.util.addClass(cmpTarget, 'slds-show');
                        $A.util.removeClass(cmpTarget, 'slds-hide');
                        component.set("v.wbtSection", false);
                        cmpTarget = component.find('wbtEdit');
                        $A.util.addClass(cmpTarget, 'slds-hide');
                        $A.util.removeClass(cmpTarget, 'slds-show');
                        
                        cmpTarget = component.find('gwsDisplay');
                        $A.util.addClass(cmpTarget, 'slds-hide');
                        $A.util.removeClass(cmpTarget, 'slds-show');
                        cmpTarget = component.find('gwsEdit');
                        $A.util.addClass(cmpTarget, 'slds-show');
                        $A.util.removeClass(cmpTarget, 'slds-hide');
                        
                        cmpTarget = component.find('ApprovalEdit');
                        $A.util.addClass(cmpTarget, 'slds-hide');
                        $A.util.removeClass(cmpTarget, 'slds-show');
                    }
                        else if(objRec.Path_Picklist__c == 'Approval')
                        {
                            var cmpTarget = component.find('wbtDisplay');
                            $A.util.addClass(cmpTarget, 'slds-show');
                            $A.util.removeClass(cmpTarget, 'slds-hide');
                            component.set("v.wbtSection", false);
                            cmpTarget = component.find('wbtEdit');
                            $A.util.addClass(cmpTarget, 'slds-hide');
                            $A.util.removeClass(cmpTarget, 'slds-show');
                            
                            cmpTarget = component.find('gwsDisplay');
                            $A.util.addClass(cmpTarget, 'slds-show');
                            $A.util.removeClass(cmpTarget, 'slds-hide');
                            component.set("v.wbtSection", false);
                            cmpTarget = component.find('gwsEdit');
                            $A.util.addClass(cmpTarget, 'slds-hide');
                            $A.util.removeClass(cmpTarget, 'slds-show');
                            
                            cmpTarget = component.find('ApprovalEdit');
                            $A.util.addClass(cmpTarget, 'slds-show');
                            $A.util.removeClass(cmpTarget, 'slds-hide');
                        }*/
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
            var controllerField = component.get("v.controllingFieldAPI");
            var dependentField = component.get("v.dependingFieldAPI");
            var objDetails = component.get("v.wbProjectObj");
            // call the helper function
            //helper.fetchPicklistValues(component,objDetails,controllingFieldAPI, dependingFieldAPI);
            var action2 = component.get("c.getDependentMap");
            // pass paramerters [object definition , contrller field name ,dependent field name] -
            // to server side function 
            action2.setParams({
                'objDetail' : objDetails,
                'contrfieldApiName': controllerField,
                'depfieldApiName': dependentField 
            });
            //set callback   
            action2.setCallback(this, function(response) {
                if (response.getState() == "SUCCESS") {
                    //store the return response from server (map<string,List<string>>)  
                    var StoreResponse = response.getReturnValue();
                    
                    // once set #StoreResponse to depnedentFieldMap attribute 
                    component.set("v.depnedentFieldMap",StoreResponse);
                    
                    // create a empty array for store map keys(@@--->which is controller picklist values) 
                    var listOfkeys = []; // for store all map keys (controller picklist values)
                    var ControllerField = []; // for store controller picklist value to set on lightning:select. 
                    
                    // play a for loop on Return map 
                    // and fill the all map key on listOfkeys variable.
                    for (var singlekey in StoreResponse) {
                        listOfkeys.push(singlekey);
                    }
                    
                    //set the controller field value for lightning:select
                    for (var i = 0; i < listOfkeys.length; i++) {
                        ControllerField.push(listOfkeys[i]);
                    }  
                    // set the ControllerField variable values to country(controller picklist field)
                    component.set("v.listControllingValues", ControllerField);
                    var objRec = component.get("v.wbProjectObj");
                    console.log(objRec.Project_Name__c);
                    //alert(component.get("v.wbProjectObj.Approval_Stage__c"));
                    //var controllerValueKey = objRec.Approval_Stage__c;
                    var controllerValueKey = component.get("v.wbProjectObj.Approval_Stage__c");
                    if (controllerValueKey != '--- None ---') {
                        var depnedentFieldMap = component.get("v.depnedentFieldMap");
                        var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
                        //alert(ListOfDependentFields);
                        if(ListOfDependentFields != undefined && ListOfDependentFields.length > 0){
                            component.set("v.bDisabledDependentFld" , false);  
                            helper.fetchDepValues(component, ListOfDependentFields);    
                        }
                        else{
                            component.set("v.bDisabledDependentFld" , true); 
                            component.set("v.listDependingValues", ['--- None ---']);
                        } 
                    }
                }else{
                    //alert('Something went wrong..');
                }
            });
            $A.enqueueAction(action2);
        });
        $A.enqueueAction(action);
        
        action = component.get("c.checkUserProfile");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isProfileAccess", response.getReturnValue());
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
        console.log(component.get("v.worthy"));
        $A.enqueueAction(action);
    },
    
    handleClickWBTNext : function (component, event, helper) {
        var flag=0;
        var valInput = component.find("wbtInput");
        for(var i=0 ; i < valInput.length ;i++)
        {
            var val = valInput[i].get('v.value');
            
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
            var obj = component.get("v.wbProjectObj");
            
            if(component.find("projecttype").get("v.value") != null)
                obj.Project_Type__c = component.find("projecttype").get("v.value");
            if(component.find("typeofrequest").get("v.value") != null)
                obj.Request_Type__c = component.find("typeofrequest").get("v.value");
            console.log('Location Display Valu===',component.find("locationofimpactedusers").get("v.value"));
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
                        countryName=countryName+valCheckJS[key]+',';
                    }
                } 
                obj.Locations_of_impacted_users__c = countryName;
            }
            console.log('whatservicesarerequired Display Valu===',component.find("whatservicesarerequired").get("v.value"));
            if(component.find("whatservicesarerequired").get("v.value") != null)
                obj.Required_Services__c = component.find("whatservicesarerequired").get("v.value");
            if(component.find("userslevel").get("v.value") != null && component.find("userslevel").get("v.value") != '--None--')
                obj.Users_Level__c = component.find("userslevel").get("v.value");
            else
                obj.Users_Level__c = null;
            if(component.find("projectapproved").get("v.value") != null)
                obj.Project_Approved__c = component.find("projectapproved").get("v.value");
            
            if(component.find("projectfunded").get("v.value") != null && component.find("projectfunded").get("v.value") != '--None--')
                obj.Project_Funded__c = component.find("projectfunded").get("v.value");
            else
                obj.Project_Funded__c = null;
            
            if(component.find("projectaligntospecificbusiness").get("v.value") != null && component.find("projectaligntospecificbusiness").get("v.value") != '--None--')
                obj.Project_align_to_specific_business__c = component.find("projectaligntospecificbusiness").get("v.value");
            else
                obj.Project_align_to_specific_business__c = null;
            /*if(component.find("projectfunded").get("v.value") != null)
                obj.Project_Funded__c = component.find("projectfunded").get("v.value");
            if(component.find("projectaligntospecificbusiness").get("v.value") != null)
                obj.Project_align_to_specific_business__c = component.find("projectaligntospecificbusiness").get("v.value");*/
            obj.Submitter_LookUp__c = component.get("v.contactRec").Id;
            //obj.Project_Requester__c = component.get("v.selectedProjectRequester").Id;
            obj.Path_Picklist__c = 'Assessment';
            
            var action = component.get("c.updateRec");
            action.setParams({ recObj : obj });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('Inserted WBT Edit Successfully');
                    window.location.reload();
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
    
    picklistGWS: function (obj) {
        if(component.find("gwsprojecttype").get("v.value") != null)
            obj.GWS_Project_Type__c = component.find("gwsprojecttype").get("v.value");
        if(component.find("highlevelprojectactivities").get("v.value") != null)
            obj.High_Level_Project_Activities__c = component.find("highlevelprojectactivities").get("v.value");
        if(component.find("impactedteams").get("v.value") != null)
            obj.Impacted_Teams__c = component.find("impactedteams").get("v.value");
        if(component.find("otherpotentialimpacts").get("v.value") != null)
            obj.Other_Potential_Impacts__c = component.find("otherpotentialimpacts").get("v.value");
        if(component.find("costanddeliveryestimate").get("v.value") != null && component.find("costanddeliveryestimate").get("v.value") != '--None--')
            obj.Cost_Delivery_Estimate__c = component.find("costanddeliveryestimate").get("v.value");
        else
            obj.Cost_Delivery_Estimate__c = null;
        if(component.find("complexity").get("v.value") != null && component.find("complexity").get("v.value") != '--None--')
            obj.Complexity__c = component.find("complexity").get("v.value");
        else
            obj.Complexity__c = null;
        if(component.find("nextsteps").get("v.value") != null)
            obj.Next_Steps__c = component.find("nextsteps").get("v.value");
        return obj;
    },
    
    handleClickGWSBack: function (component, event, helper) {
        var obj = component.get("v.wbProjectObj");
        
        if(component.find("gwsprojecttype").get("v.value") != null)
            obj.GWS_Project_Type__c = component.find("gwsprojecttype").get("v.value");
        if(component.find("highlevelprojectactivities").get("v.value") != null)
            obj.High_Level_Project_Activities__c = component.find("highlevelprojectactivities").get("v.value");
        if(component.find("impactedteams").get("v.value") != null)
            obj.Impacted_Teams__c = component.find("impactedteams").get("v.value");
        if(component.find("otherpotentialimpacts").get("v.value") != null)
            obj.Other_Potential_Impacts__c = component.find("otherpotentialimpacts").get("v.value");
        if(component.find("costanddeliveryestimate").get("v.value") != null && component.find("costanddeliveryestimate").get("v.value") != '--None--')
            obj.Cost_Delivery_Estimate__c = component.find("costanddeliveryestimate").get("v.value");
        else
            obj.Cost_Delivery_Estimate__c = null;
        if(component.find("complexity").get("v.value") != null && component.find("complexity").get("v.value") != '--None--')
            obj.Complexity__c = component.find("complexity").get("v.value");
        else
            obj.Complexity__c = null;
        if(component.find("nextsteps").get("v.value") != null)
            obj.Next_Steps__c = component.find("nextsteps").get("v.value");
        
        //obj = picklistGWS(obj);
        
        obj.Path_Picklist__c = 'Initial Details';
        
        var action = component.get("c.updateRec");
        action.setParams({ recObj : obj });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Back GWS to WBT Successfully');
                window.location.reload();
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
    },
    
    handleClickGWSSave : function (component, event, helper) {
        var obj = component.get("v.wbProjectObj");
        
        if(component.find("gwsprojecttype").get("v.value") != null)
            obj.GWS_Project_Type__c = component.find("gwsprojecttype").get("v.value");
        if(component.find("highlevelprojectactivities").get("v.value") != null)
            obj.High_Level_Project_Activities__c = component.find("highlevelprojectactivities").get("v.value");
        if(component.find("impactedteams").get("v.value") != null)
            obj.Impacted_Teams__c = component.find("impactedteams").get("v.value");
        if(component.find("otherpotentialimpacts").get("v.value") != null)
            obj.Other_Potential_Impacts__c = component.find("otherpotentialimpacts").get("v.value");
        if(component.find("costanddeliveryestimate").get("v.value") != null && component.find("costanddeliveryestimate").get("v.value") != '--None--')
            obj.Cost_Delivery_Estimate__c = component.find("costanddeliveryestimate").get("v.value");
        else
            obj.Cost_Delivery_Estimate__c = null;
        if(component.find("complexity").get("v.value") != null && component.find("complexity").get("v.value") != '--None--')
            obj.Complexity__c = component.find("complexity").get("v.value");
        else
            obj.Complexity__c = null;
        if(component.find("nextsteps").get("v.value") != null)
            obj.Next_Steps__c = component.find("nextsteps").get("v.value");
        
        //obj = picklistGWS(obj);
        
        var action = component.get("c.updateRec");
        action.setParams({ recObj : obj });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Inserted GWS Edit Successfully');
                window.location.reload();
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
    },
    
    handleClickGWSSendForApproval : function (component, event, helper) {
        var flag=0;
        var valInput = component.find("gwsInput");
        for(var i=0 ; i < valInput.length ;i++)
        {
            var val = valInput[i].get('v.value');
            if(val === undefined || val === null || val === '')
            {
                //$A.util.addClass(valInput[i], 'slds-has-error');
                valInput[i].setCustomValidity('This is required field');
                valInput[i].reportValidity();
                flag++;
            }
            else{
                //alert(val);
                valInput[i].setCustomValidity('  ');                               
                valInput[i].reportValidity();
                $A.util.removeClass(valInput[i], 'slds-has-error');
            }            
        }
        
        /*valInput = component.find("gwsprojecttype");
        if(valInput.get("v.value") == undefined)
        {
            valInput[i].setCustomValidity('This is required field');
            valInput[i].reportValidity();
            flag++;
        }*/
        valInput = component.find("highlevelprojectactivities");
        if(valInput.get("v.value") == '')
        {
            valInput.setCustomValidity('This is required field');
            valInput.reportValidity();
            flag++;
        }
        valInput = component.find("impactedteams");
        if(valInput.get("v.value") == '')
        {
            valInput.setCustomValidity('This is required field');
            valInput.reportValidity();
            flag++;
        }
        valInput = component.find("otherpotentialimpacts");
        if(valInput.get("v.value") == '')
        {
            valInput.setCustomValidity('This is required field');
            valInput.reportValidity();
            flag++;
        }
        
        if(flag == 0)
        {
            var obj = component.get("v.wbProjectObj");
            
            if(component.find("gwsprojecttype").get("v.value") != null)
                obj.GWS_Project_Type__c = component.find("gwsprojecttype").get("v.value");
            if(component.find("highlevelprojectactivities").get("v.value") != null)
                obj.High_Level_Project_Activities__c = component.find("highlevelprojectactivities").get("v.value");
            if(component.find("impactedteams").get("v.value") != null)
                obj.Impacted_Teams__c = component.find("impactedteams").get("v.value");
            if(component.find("otherpotentialimpacts").get("v.value") != null)
                obj.Other_Potential_Impacts__c = component.find("otherpotentialimpacts").get("v.value");
            if(component.find("costanddeliveryestimate").get("v.value") != null && component.find("costanddeliveryestimate").get("v.value") != '--None--')
                obj.Cost_Delivery_Estimate__c = component.find("costanddeliveryestimate").get("v.value");
            else
                obj.Cost_Delivery_Estimate__c = null;
            if(component.find("complexity").get("v.value") != null && component.find("complexity").get("v.value") != '--None--')
                obj.Complexity__c = component.find("complexity").get("v.value");
            else
                obj.Complexity__c = null;
            if(component.find("nextsteps").get("v.value") != null)
                obj.Next_Steps__c = component.find("nextsteps").get("v.value");
            
            //obj = picklistGWS(obj);
            
            obj.Path_Picklist__c = 'Approval';
            
            var action = component.get("c.updateRec");
            action.setParams({ recObj : obj });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('Inserted Successfully');
                    window.location.reload();
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
    
    showGWS :function(component, event, helper)
    {
        var val = component.get("v.gwsSection");
        if(val == true)
            val= false;
        else
            val= true;
        component.set("v.gwsSection", val);
    },
    
    showWBT:function(component, event, helper)
    {
        var val = component.get("v.wbtSection");
        if(val == true)
            val= false;
        else
            val= true;
        component.set("v.wbtSection", val);
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
        if(getInputkeyWord.length > 1)
        {
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
                    console.log('In Success');
                    var storeResponse = response.getReturnValue();
                    console.log('Length',storeResponse.length);
                    if (storeResponse.length == 0) {
                        component.set("v.Message", 'No Records Found...');
                    } else {
                        component.set("v.Message", '');
                    }
                    component.set("v.listOfSearchRecords", storeResponse); 
                    console.log('storeResponse===',storeResponse);
                }
                else{
                    component.set("v.Message", 'No Records Found...');
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
    
    onblur : function(component, event, helper) {
        var cmpTarget = component.find('lookupContact');
        $A.util.addClass(cmpTarget, 'slds-is-close');
        $A.util.removeClass(cmpTarget, 'slds-is-open');
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
    
    handleClickApprovalBack : function(component, event, helper) {
        var obj = component.get("v.wbProjectObj");
        obj.Approval_Stage__c = 'No Decision';
        obj.Reason__c = '';
        obj.Path_Picklist__c = 'Assesment';
        
        var action = component.get("c.updateRec");
        action.setParams({ recObj : obj });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Back Approval to GWS Successfully');
                window.location.reload();
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
    },
    
    handleClickApprovalSubmit : function(component, event, helper) {
        var obj = component.get("v.wbProjectObj");
        
        var action = component.get("c.updateRec");
        action.setParams({ recObj : obj });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Back Approval to GWS Successfully');
                window.location.reload();
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
    },
    
    onControllerFieldChange: function(component, event, helper) {     
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        
        if (controllerValueKey != '--- None ---') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields);    
            }else{
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.listDependingValues", ['--- None ---']);
            }  
            
        } else {
            component.set("v.listDependingValues", ['--- None ---']);
            component.set("v.bDisabledDependentFld" , true);
        }
    },
    
    showWBTSubmitterDetails : function(component, event, helper)
    {
        var val = component.get("v.wbtSubmitterDetailsSection");
        if(val == true)
            val= false;
        else
            val= true;
        component.set("v.wbtSubmitterDetailsSection", val);
    },
    
    showWBTProjectAdministrationDetails : function(component, event, helper)
    {
        var val = component.get("v.wbtProjectAdministrationDetailsSection");
        if(val == true)
            val= false;
        else
            val= true;
        component.set("v.wbtProjectAdministrationDetailsSection", val);
    },
    
    showWBTTypeofRequest : function(component, event, helper)
    {
        var val = component.get("v.wbtTypeofRequestSection");
        if(val == true)
            val= false;
        else
            val= true;
        component.set("v.wbtTypeofRequestSection", val);
    },
    
    showWBTProjectObjectiveBackground : function(component, event, helper)
    {
        var val = component.get("v.wbtProjectObjectiveBackgroundSection");
        if(val == true)
            val= false;
        else
            val= true;
        component.set("v.wbtProjectObjectiveBackgroundSection", val);
    },
    
    showGWSProjectDetails : function(component, event, helper)
    {
        var val = component.get("v.gwsProjectDetailsSection");
        if(val == true)
            val= false;
        else
            val= true;
        component.set("v.gwsProjectDetailsSection", val);
    },
    
    showGWSAssessmentDetails : function(component, event, helper)
    {
        var val = component.get("v.gwsAssessmentDetailsSection");
        if(val == true)
            val= false;
        else
            val= true;
        component.set("v.gwsAssessmentDetailsSection", val);
    },
    
    showGWSCostAndDeliveryEstimate : function(component, event, helper)
    {
        var val = component.get("v.gwsAssessmentCostAndDeliveryEstimate");
        if(val == true)
            val= false;
        else
            val= true;
        component.set("v.gwsAssessmentCostAndDeliveryEstimate", val);
    },
})