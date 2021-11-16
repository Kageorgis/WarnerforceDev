({
    /* On the component Load this function call the apex class method,
        * which is return the list of RecordTypes of object
        * and set it to the lstOfRecordType attribute to display record Type values
        * on ui:inputSelect component. */

    fetchListOfRecordTypes: function(component, event, helper) {

        var action = component.get("c.fetchRecordTypeValues");
        action.setCallback(this, function(response) {
            component.set("v.lstOfRecordType", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },

    /* In this "createRecord" function, first we have call apex class method
     * and pass the selected RecordType values[label] and this "getRecTypeId"
     * apex method return the selected recordType ID.
     * When RecordType ID comes, we have call  "e.force:createRecord"
     * event and pass object API Name and
     * set the record type ID in recordTypeId parameter. and fire this event
     * if response state is not equal = "SUCCESS" then display message on various situations.
     */
    createRecord: function(component, event, helper) {
        component.set("v.isOpen", true);

        var action = component.get("c.getRecTypeId");
        var recordTypeLabel = component.find("selectid").get("v.value");

        action.setParams({
            "recordTypeLabel": recordTypeLabel
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var RecTypeID  = response.getReturnValue();

                component.set("v.isOpen", false);
                component.set("v.recordTypeId", RecTypeID);
                var appEvent = $A.get("e.c:cp_accountCreateSuccesEvent");
                if(recordTypeLabel == 'WBCP Retailer'){
                    var isRetailer = true;
                }
                appEvent.setParams({
                    "recordTypeId" : RecTypeID,
                    "isRetailer": isRetailer
                });
                appEvent.fire();

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
        component.set("v.isOpen", false);
        var a = component.get('c.gotoList');
        $A.enqueueAction(a);

    },
    gotoList : function (component, event, helper) {
        var action = component.get("c.getListViews");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "Contact"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    openModal: function(component, event, helper) {
        // set "isOpen" attribute to true to show model box
        component.set("v.isOpen", true);
    },
})