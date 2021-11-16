({
    doInit: function( component, event, helper ) {

            console.log("Initializing Component......")

            var recId =  component.get("v.recordId");
            console.log("Id man -->"+recId);
            if(recId != null){
                component.set("v.isOpen",false);
                helper.getRecordTypeId(component,event);
            }
            else {
                component.set("v.isOpen",true);
                helper.getCategories(component,event);
            }



        // "values" must be a subset of values from "options"



    },
    handleSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The  info has been updated.",
            "type": "success"
        });
        toastEvent.fire();
        var recordId = component.get("v.recordId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
       // alert('about to fire the event')
        navEvt.fire();

    },
    handleLoad : function(component, event, helper) {
        //  console.log("The REcord Id"+component.get("v.recordId"))

        //  console.log(JSON.stringify(titleField))
        component.set("v.showSpinner", false);
    },
    handleSubmit : function(cmp,evt,hlp) {
        evt.preventDefault();

       hlp.createProperties(cmp,evt)

    },
    goBackToRecord:function (cmp,evt,hlp) {
        var recordId = cmp.get("v.recordId");
        if (recordId) {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": recordId,
                "slideDevName": "related"
            });
            navEvt.fire();
        }
        else{
            var homeEvent = $A.get("e.force:navigateToObjectHome");
            homeEvent.setParams({
                "scope": "Account"
            });
            homeEvent.fire();
        }
    },
    handleApplicationEvent:function (cmp,evt,hlp) {
        var recId = evt.getParam("recordTypeId");
        var isRetailer = evt.getParam("isRetailer");
        // set the handler attributes based on event data
        cmp.set("v.recordTypeId", recId);
        cmp.set("v.isRetailer", isRetailer);

    //       console.log("Event got the record Id --->  "+recId);
      //  var a = cmp.get('c.doInit');
       // $A.enqueueAction(a);
        hlp.getLayouts(cmp,evt, recId);

    },
    handleSubCatChange: function (cmp, event) {

        cmp.set("v.reRender", false); // first set false to hide the block
        cmp.set("v.reRender", true); // then set back to true to re-render the block

        // This will contain an array of the "value" attribute of the selected options
        var selectedOptionValue = event.getParam("value");

        console.log(JSON.stringify(selectedOptionValue));

        var action = cmp.get("c.populateCategories");
        action.setParams({
            "selectedSubCats":selectedOptionValue

        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {


                var dependecies = response.getReturnValue();
              //  console.log("The dependency list -->"+JSON.stringify(dependecies,null,2))
                var items = [];

                for(var key in dependecies){
                    items.push(key);
                }
             //   cmp.set("v.options", items);
                // "values" must be a subset of values from "options"
              //  cmp.set("v.values", ["opt10", "opt5", "opt7"]);
               // console.log("Items ---->"+JSON.stringify(items,null,2));
             //   console.log("Dependencies --->"+JSON.stringify(dependecies,null,2));
                cmp.set("v.values",items);

            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log( JSON.stringify(errors) );

            }

        });

        $A.enqueueAction(action);

       // component.set("v.options", items);



    },
    handleChange:function (cmp,evt,hlp) {
        var inputField = evt.getSource();
        var subCats = cmp.get("v.subvalues");
        var selectedOptionValue = evt.getParam("value");
        console.log("selCats ---> "+JSON.stringify(selectedOptionValue))

        if(subCats == ""){
            inputField.setCustomValidity('You must choose a subcategory first. Category will be autopopulated.'); //do not get any message
            inputField.reportValidity();

        }
        else {
            inputField.setCustomValidity('You may only choose a subcategory.  Category will be autopopulated.'); //do not get any message
            inputField.reportValidity();
            hlp.getCategories(cmp,evt)
        }

    }
})