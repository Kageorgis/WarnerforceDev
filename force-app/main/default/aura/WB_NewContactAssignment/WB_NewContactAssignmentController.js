({
	doInit : function(component, event, helper) {
		var recid= component.get("v.recordId");
        component.find("ectrackerField").set("v.value", recid);      
        var accId=$A.get("$Label.c.WB_Internal_Account");
        component.find("accntField").set("v.value", accId);    
     },    
    handleSuccess: function(component, event, helper) {
        var saveNewbtnClicked= component.get("v.saveNewFlag");            
        if(saveNewbtnClicked === true)
        {
            var payload = event.getParams().response;
            var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({        
        "type":"success",
        "message": "Contact Assignment \""+payload.fields.Name.value+"\" was created"
    });
    component.find('field').forEach(function(f) {
            f.reset();
        });  
         component.find("conField").set("v.value", null);  
        component.set("v.saveNewFlag",false);     
    toastEvent.fire();
          component.set("v.FormLoadComplete",true);   
        }else{ 
        component.set("v.FormLoadComplete",false);  
        var payload = event.getParams().response;
        var navService = component.find("navService");    
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                "recordId": payload.id,
                "objectApiName": "Contact_Assignment__c",
                "actionName": "view"
            }
        }
        event.preventDefault();
        navService.navigate(pageReference);
            
      }      
    },
    handleSubmit: function(component, event, helper) {
        event.preventDefault();
        component.set("v.FormLoadComplete",false);  
            component.find("editForm").submit();     
    },
    handleCancel : function(component, event, helper) {
      event.preventDefault();
          $A.get("e.force:closeQuickAction").fire();
    },
    handleSaveNew : function(component, event, helper) {
        event.preventDefault();
        component.set("v.FormLoadComplete",false);  
            component.find("editForm").submit();
         component.set("v.saveNewFlag",true);
      },
    handleLoad: function(component, event, helper) {        
        component.set("v.FormLoadComplete",true);
    },
   showSpinner: function(component, event, helper) {   
       if(component.get("v.FormLoadComplete") === true)
           component.set("v.Spinner", false);
       else
        component.set("v.Spinner", true);
   },
    
    hideSpinner : function(component,event,helper){       
       component.set("v.Spinner", false);
    },
    
})