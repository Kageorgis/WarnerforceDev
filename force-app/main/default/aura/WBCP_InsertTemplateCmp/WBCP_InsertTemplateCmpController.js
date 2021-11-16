({
	doAction : function(component, event, helper) {
        component.set("v.showModal",true);
        component.set("v.columns", [
            {label: 'Template Name', fieldName: 'Name', type: 'Text',sortable: true},
            {label: 'Description', fieldName: 'Description', type: 'text'},
            {label: 'Folder', fieldName: 'FolderName', type: 'text'},
            {label: 'Select', type: 'button', initialWidth: 135, typeAttributes: { label: 'Select', name: 'Select', title: 'Select Template'},cellAttributes: { alignment: 'center' }}
        ]);
        helper.getEmailTemplateHelper(component, event);
	},
    closeModel:function(component, event, helper) {
		component.set("v.showModal",false);
	},
    onSelectEmailFolder: function(component, event, helper){
        component.set('v.loaded',true);
        component.set('v.folderId',event.getParam("value"));
        var searchPhrase = component.get("v.searchText");
    	helper.searchRecordsBySearchPhrase(component,searchPhrase);
    },
    
    handleRowAction: function (component, event) {
        component.set('v.loaded',true);
        var action = event.getParam('action');
        var row = event.getParam('row');
        console.log('action.name : ',action.name, row.Id);
        if(action.name == 'Select'){
            var sendEmailTempEvent = component.getEvent("emailTempSendEvent");
            sendEmailTempEvent.setParams({ "emailTemplate" : row });
            sendEmailTempEvent.fire();
        }
    },
    
    handleSort: function(component, event, helper) {
        var sortedBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        helper.handleSort(component, sortedBy, sortDirection);
    },
    
    onSearchTemplates: function(component,event,helper){
        component.set('v.loaded',true);
        var searchPhrase = component.get("v.searchText");
        helper.searchRecordsBySearchPhrase(component,searchPhrase);
    }
})