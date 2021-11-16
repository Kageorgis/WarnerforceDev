({



    openModel: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
    },

    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
        component.set("v.isOpen", false);
        var compEvent = component.getEvent("errEvt");

        compEvent.setParams({"errMsgTrue" : true });
        compEvent.fire();

    },


})