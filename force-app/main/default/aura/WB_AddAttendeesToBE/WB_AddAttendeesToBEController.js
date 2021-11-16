({
	doInit : function(component, event, helper) {
        component.set("v.columns", [
            {label: 'Brand', fieldName: 'Account_name', type: 'Text'},
            {label: 'Contact', fieldName: 'Contact_name', type: 'text'},
            {label: 'Email', fieldName: 'email', type: 'email'},
            {label: 'Phonoe', fieldName: 'phone', type: 'phone'},
            {label: 'Role', fieldName: 'Role', type: 'text'},
            {label: 'Brand Contact', fieldName: 'Name', type: 'Text'}
        ]);
		helper.getBrandContacts(component, event, helper);
	},
    handleClick : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    addAttendees: function(component, event, helper) {
        component.set("v.isLoading",true);
      	var action = component.get("c.addAttendeesToBE");	
        var brandEngId = component.get('v.recordId');
        var bcList = component.get('v.selectedBCList');
        action.setParams({
            'bcList':bcList,
            'brandEngId': brandEngId
        });
        action.setCallback(this, function (response) {
            console.log('added attendees ',response.getReturnValue());
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.selectedRows',[]);
                if(response.getReturnValue().length > 0){
                	component.set("v.brandContact", response.getReturnValue());    
                }else{
                    component.set("v.brandContact",[]);
                    component.set("v.message",'All Brand Contacts are added as Attendees to this Engagement!!');
                }
                component.set('v.selectedBCList',[]);
                $A.get('e.force:refreshView').fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: 'Success',
                    mode: 'sticky',
                    message:'Selected Attendees are added successfully!!',  
                });
                toastEvent.fire();
                component.set("v.isLoading",false);
            }else if (state === "INCOMPLETE") {
                system.debug('INCOMPLETE');
                component.set("v.isLoading",false);
            }
            else if (state === "ERROR") {
                component.set("v.isLoading",false);
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.log("Error message: ",errors[0].message);
                } else {
                    console.log("Unknown error");
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: 'Error',
                    mode: 'sticky',
                    message:errors[0].message,  
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    updateSelectedText: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        console.log('selectedRows',selectedRows,component.get("v.selectedRows"));
        component.set('v.selectedBCList', selectedRows);
    }
})