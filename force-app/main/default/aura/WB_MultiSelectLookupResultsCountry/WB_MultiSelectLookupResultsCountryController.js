({
    selectRecord : function(component, event, helper){       
        var getSelectRecord = component.get("v.oRecord"); 
        var compEvent = component.getEvent("oSelectedRecordEventCountry");
        compEvent.setParams({"recordByEvent" : getSelectRecord });  
        compEvent.fire();
    },
})