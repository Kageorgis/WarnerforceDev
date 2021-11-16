({
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    getCountry: function (component, event, helper) {
       var action = component.get("c.getCountry");
        var inputIndustry = component.find("InputSelectedCountry");
        var opts=[];
        action.setCallback(this, function(a) {
            opts.push({
                class: "optionClass",
                label: "Select",
                value: ""
            });
            if(a.getReturnValue()!=null){
            for(var i=0;i< a.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
        }
           // console.log('opts:'+opts);
            inputIndustry.set("v.options", opts);
             
        });
        $A.enqueueAction(action); 
        
    },
    getRecordType: function (component, event, helper) {
        var action = component.get("c.getRecordType");
        var inputIndustry = component.find("InputRecordType");
        var opts=[];
        action.setCallback(this, function(a) {
            opts.push({
                class: "optionClass",
                label: "Select",
                value: ""
            });
            if(a.getReturnValue()!=null){
            for(var i=0;i< a.getReturnValue().length;i++){
                opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
          }
            //console.log('opts:'+opts);
            inputIndustry.set("v.options", opts);
             
        });
        $A.enqueueAction(action); 
    }
  
})