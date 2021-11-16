({
    handleSaveClick : function(component, event, helper) {
        //event.preventDefault();
        
        //alert("In handleSubmit");
        //event.preventDefault();
        /*var fields = event.getParam("fields");
        payload["Name"] = component.get("v.inputName");
        console.log(JSON.stringify(payload));
        component.find("form").submit(payload);*/
        
        var fields = event.getParams();
        console.log(JSON.stringify(fields));
        /*console.log("component.get v.inputName",component.get("v.inputName"));
        fields.Name = component.get("v.inputName");*/
        //component.find("form").submit(fields);
        
        //helper.saveRecord(component, event, fields);
        /*var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been Saved successfully.",
            "type": "success"
        });
        toastEvent.fire();*/
    },
    
    showPromotionHeader : function(component, event, helper) {
        if(component.get("v.promotionHeaderSection") == true)
            component.set("v.promotionHeaderSection",false);
        else
            component.set("v.promotionHeaderSection",true);
    },
    
    showCountriesAccountSection : function(component, event, helper) {
        if(component.get("v.countriesAccountSection") == true)
            component.set("v.countriesAccountSection",false);
        else
            component.set("v.countriesAccountSection",true);
    },
    
    handleEditClick : function(component, event, helper) {
        var editFormRec = component.find('editForm');
        $A.util.addClass(editFormRec, 'slds-show');
        $A.util.removeClass(editFormRec, 'slds-hide');
        var viewFormRec = component.find('viewForm');
        $A.util.addClass(viewFormRec, 'slds-hide');
        $A.util.removeClass(viewFormRec, 'slds-show');
        
        var viewFormRec = component.find('editFormButton');
        $A.util.addClass(viewFormRec, 'slds-hide');
        $A.util.removeClass(viewFormRec, 'slds-show');
        var cloneRec = component.find('cloneButton');
        $A.util.addClass(cloneRec, 'slds-hide');
        $A.util.removeClass(cloneRec, 'slds-show');
        
        component.set("v.countriesAccountSection",false);
        
        var action = component.get("c.getPromotionRecord");
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
                component.set("v.inputName",storeResponse.Name);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleOnSuccess : function(component, event, helper) {
        //alert("In Success");
        helper.saveRecord(component, event);
        /*if(component.get("v.countAccFlag"))
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": "The record has been Saved successfully.",
                "type": "success"
            });
            toastEvent.fire();
        }
        component.set("v.countAccFlag", false);*/
    },
    
    handleOnError : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": "Record not Saved.",
            "type": "error"
        });
        toastEvent.fire();
    },
    
    handleCloneClick : function(component, event, helper) {
        
        var promotionId =  component.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/WB_PromotionClone?id="+promotionId            
        });
        urlEvent.fire();
    },
})