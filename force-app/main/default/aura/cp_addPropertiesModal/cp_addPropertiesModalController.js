({



    createRecord: function(component, event, helper) {

        console.log("Creating Records.....");
        var action = component.get("c.createRelatedProperties");
        var props = component.get("v.selectedLookUpRecords");
        var accRec = component.get("v.recordId");
        var accRecName = component.get("v.simpleRecord.Name");
        action.setParams({
            "accId": accRec,
            "props": props,
            "accRecName":accRecName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var success  = response.getReturnValue();

                component.set("v.isOpenProp", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "message": success,
                    "type": "success"
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();


            } else if (state == "INCOMPLETE") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Oops!",
                    "message": "No Internet Connection"
                });
                toastEvent.fire();

            } else if (state == "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please contact your administrator"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    createRetailers: function(component, event, helper) {

        console.log("Creating Retailers.....");
        var action = component.get("c.createRelatedRetailers");
        var retls = component.get("v.selectedAccountRecords");
        var accRec = component.get("v.recordId");
        var accRecName = component.get("v.simpleRecord.Name");

        action.setParams({
            "accId": accRec,
            "retls": retls,
            "accRecName":accRecName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var success  = response.getReturnValue();

                component.set("v.isOpenRetl", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "message": success,
                    "type": "success"
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();


            } else if (state == "INCOMPLETE") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Oops!",
                    "message": "No Internet Connection"
                });
                toastEvent.fire();

            } else if (state == "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please contact your administrator"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    closeModal: function(component, event, helper) {
        // set "isOpen" attribute to false for hide/close model box
        component.set("v.isOpenProp", false);
        component.set("v.isOpenRetl", false);
    },

    openModal: function(component, event, helper) {
        // set "isOpen" attribute to true to show model box
        var getEvent = event.getSource().get("v.name")
        console.log(JSON.stringify(getEvent));
        switch (getEvent) {
            case 'propButton':

                component.set("v.isOpenProp", true);
                break;
            case 'retlButton':
                component.set("v.isOpenRetl", true);
                break;
        }


    },
})