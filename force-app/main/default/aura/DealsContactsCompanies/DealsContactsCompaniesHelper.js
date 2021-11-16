({
	getData : function(component, event, methodName, targetAttribute) {
        var action = component.get('c.'+methodName);
        switch (methodName) {
            case 'getPickListValues':
                if(targetAttribute === 'categories') {
                    action.setParams({
                        'objectApi': component.get('v.objectApi'),
                        'pickListApi': component.get('v.pickListApi'),
                        'useRecordType': false
                    });
                } else {
                    action.setParams({
                        'objectApi': 'Opportunity',
                        'pickListApi': component.get('v.fieldName'),
                        'useRecordType': true
                    });
                }
                break;
            case 'getView':
                action.setParams({
                    'listViewId': component.get('v.listViewSelected').viewId,
                    'child': component.get('v.listViewSelected').child
                });
                break;
            case 'followContacts':
                var contactsToFollow = component.get('v.contactsToFollow');
                var contactIds = '';
                for(var i=0; i<contactsToFollow.length; i++) {
                    contactIds += contactsToFollow[i];
                    if(i+1 < contactsToFollow.length) contactIds += ';';
                }
                action.setParams({
                    'followRecordIds': contactIds
                });
                break;
            case 'insertView':
                var category = component.get('v.objectApi')+'.'+component.get('v.pickListApi');
                action.setParams({
                    'listViewName': component.get('v.newViewFieldValues')[0],
                    'joinRelationship': component.get('v.newViewFieldValues')[1],
                    'category': category
                });
                break;
            case 'updateColumns':
                var category = component.get('v.objectApi')+'.'+component.get('v.pickListApi');
                action.setParams({
                    'listViewId': component.get('v.listViewSelected').viewId,
                    'child': component.get('v.listViewSelected').child,
                    'category': category,
                    'updateColumnsList': JSON.stringify(component.get('v.savedFields')),
                    'filtersList': JSON.stringify(component.get('v.filters'))
                });
                break;
            case 'updateFilters':
                action.setParams({
                    'listViewId': component.get('v.listViewSelected').viewId,
                    'child': component.get('v.listViewSelected').child,
                    'columnsList': JSON.stringify(component.get('v.columns')),
                    'updateFiltersList': JSON.stringify(component.get('v.filters'))
                });
                break;
            case 'deleteView':
                action.setParams({
                    'listViewName': component.get('v.listViewSelected').value
                });
                break;
            case 'cloneDeal':
                action.setParams({
                    'dealIdToClone': component.get('v.dealId'),
                    'dealName': component.get('v.dealName')
                });
                break;
            case 'hideDeal':
                action.setParams({
                    'dealIdToHide': component.get('v.dealId'),
                    'dealName': component.get('v.dealName'),
                    'listViewId': component.get('v.listViewSelected').viewId
                });
                break;
            case 'updateData':
                action.setParams({
                    'child': component.get('v.listViewSelected').child,
                    'columnsList': JSON.stringify(component.get('v.columns')),
                    'filtersList': JSON.stringify(component.get('v.filters'))
                });
                break;
        }
        var that = this;
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                switch (methodName) {
                    case 'getListViews':
                        var flattenedObject = this.flattenQueryResult(response.getReturnValue());
                        var listViewSelected = component.get('v.listViewSelected');
                        if(listViewSelected === null) {
                            listViewSelected = flattenedObject[1];
                            listViewSelected.isSelected = true;
                            component.set('v.listViewSelected',listViewSelected);
                        } else {
                            flattenedObject.forEach(function (view) {
                                if(view.value === listViewSelected.value) view.isSelected = true;
                            });
                        }
                        component.set('v.'+targetAttribute, flattenedObject);
                        component.set('v.resume','Loading Items');
                        this.getData(component, event, 'getPickListValues', 'categories');
                        break;
                    case 'getPickListValues':
                        if(targetAttribute === 'categories') {
                            component.set('v.'+targetAttribute, response.getReturnValue());
                            component.set('v.columns',[]);
                            component.set('v.data',[]);
                            component.set('v.tabsLoaded',false);
                            this.getData(component, event, 'getView', '');
                        } else {
                            var values = response.getReturnValue();
                            var picklistValues = [];
                            for(var i in values) {
                                picklistValues.push({
                                    'label': values[i],
                                    'value': values[i]
                                });
                            }
                            component.set('v.picklistValues',picklistValues);
                        }
                        break;
                    case 'getView':
                        var mainSpinner = component.find("mainSpinner");
                        $A.util.addClass(mainSpinner, "slds-hide");
                        this.loadViewElements(component,response);
                        break;
                    case 'followContacts':
                        var count = response.getReturnValue();
                        var toastEvent = $A.get("e.force:showToast");
                        if(count != 0) {
                            var message = count+' more contact';
                            if(count != 1) {
                                message += 's';
                            }
                            toastEvent.setParams({
                                title: "Subscriptions updated",
                                message: "You're following "+message,
                                type: "success"
                            });
                        } else {
                            toastEvent.setParams({
                                title: "Subscriptions updated",
                                message: "You're already following that contacts",
                                type: "warning"
                            });
                        }
                        toastEvent.fire();
                        component.set('v.'+targetAttribute, []);
                        break;
                    case 'insertView':
                        component.set('v.listViewSelected',response.getReturnValue());
                        component.set('v.listViews',[]);
                        component.set('v.resume','Loading Items');
                        component.set('v.columns',[]);
                        component.set('v.data',[]);
                        component.set('v.tabsLoaded',false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "New list view!",
                            message: "Your view '"+response.getReturnValue().label+"' is ready",
                            type: "success"
                        });
                        toastEvent.fire();
                        this.getData(component, event, 'getListViews', 'listViews');
                        break;
                    case 'updateColumns':
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Data updated",
                            message: "Your columns has been updated",
                            type: "success"
                        });
                        toastEvent.fire();
                        this.loadViewElements(component,response);
                        break;
                    case 'updateFilters':
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Data updated",
                            message: "Your filters has been updated",
                            type: "success"
                        });
                        toastEvent.fire();
                        this.loadViewElements(component,response);
                        break;
                    case 'deleteView':
                        component.set('v.listViews',[]);
                        component.set('v.resume','Loading Items');
                        component.set('v.columns',[]);
                        component.set('v.data',[]);
                        component.set('v.tabsLoaded',false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "List view Deleted",
                            message: "Your view '"+component.get('v.listViewSelected').label+"' has been deleted",
                            type: "success"
                        });
                        component.set('v.listViewSelected',null);
                        toastEvent.fire();
                        this.getData(component, event, 'getListViews', 'listViews');
                        break;
                    case 'cloneDeal':
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Deal cloned",
                            message: "'"+response.getReturnValue()+"' has been successfully created",
                            type: "success"
                        });
                        toastEvent.fire();
                        this.getData(component, event, 'updateData', 'data');
                        break;
                    case 'hideDeal':
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Deal hided",
                            message: "'"+response.getReturnValue()+"' has been added to the filter list",
                            type: "success"
                        });
                        toastEvent.fire();
                        this.getData(component, event, 'getView', '');
                        break;
                    case 'updateData':
                        var flattenedObject = this.flattenQueryResult(response.getReturnValue());
                		component.set('v.'+targetAttribute, flattenedObject);
                        component.set('v.resume','Loading Items');
                        var resume = '';
                        switch(flattenedObject.length) {
                            case 0:
                                resume = 'no items';
                                break;
                            case 1:
                                resume = flattenedObject.length + ' item';
                                break;
                            default:
                                resume = flattenedObject.length + ' items';
                                break;
                        }
                        component.set('v.resume',resume);
                        component.set('v.tabsLoaded',true);
                        break;
                }
            } else if (state === 'ERROR') {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    },
    
    flattenQueryResult : function(listOfObjects) {
        var table = [];
        // This function will verify if there was no childRow on the parentRow
        function isEmpty(obj) {
            for(var key in obj) {
                if(obj.hasOwnProperty(key)) return false;
            }
            return true;
        }
        // 
        for(var i=0; i<listOfObjects.length; i++) {
            var parentRow = {};
            var childRow = {};
            var obj = listOfObjects[i];
            for(var prop in obj) {
                // First, we add all the properties of the object to the parentRow
                if(typeof obj[prop] != 'object' && typeof obj[prop] != 'Array') {
                    parentRow[prop] = obj[prop];
                    if(prop === 'Id') {
                        parentRow['url'+prop] = '/'+obj[prop];
                    }
                    if(prop === 'Name') {
                        parentRow['copy'+prop] = 'Clone the deal: '+obj[prop];
                        parentRow['hide'+prop] = 'Hide the deal: '+obj[prop];
                    }
                } else if(typeof obj[prop] == 'object' && !Array.isArray(obj[prop])) {
                    // If the property is an object, we need to flatten this
                    Object.assign(parentRow, this.flattenObject(prop,obj[prop]));
                }
            }
            for(var prop in obj) {
                if(typeof obj[prop] == 'object' && Array.isArray(obj[prop])) {
                    for(var j=0; j<obj[prop].length; j++) {
                        childRow = {};
                        Object.assign(childRow, parentRow);
                        Object.assign(childRow, this.flattenObject(prop,obj[prop][j]));
                        table.push(childRow);
                    }
                }
            }
            if(isEmpty(childRow)) table.push(parentRow);
        }
        for(var i=0; i<table.length; i++) {
            table[i]['tableId'] = i;
        }
        return table;
    },
    
    flattenObject : function(propName, obj) {
        // We create an object to save all the properties as a list
        var flatObject = [];
        for(var prop in obj)
        {
            // If this property is an object, we need to flatten again
            if(typeof obj[prop] == 'object') {
                Object.assign(flatObject, this.flattenObject(propName+'.'+prop,obj[prop]));
            } else {
                flatObject[propName+'.'+prop] = obj[prop];
                if(prop === 'Id') {
                    flatObject[propName+'.'+'url'+prop] = '/'+obj[prop];
                }
            }
        }
        return flatObject;
    },
    
    loadViewElements: function(component,response) {
        var availableFields = component.get('v.availableFields');
        if(availableFields === '[]' || availableFields.length == 0) {
            var flattenedReferences = this.flattenQueryResult(response.getReturnValue().references);
            component.set('v.availableFields', flattenedReferences);
            var flattenedStudioUsers = this.flattenQueryResult(response.getReturnValue().studioUsers);
            component.set('v.studioUsers', flattenedStudioUsers);
        }
        var flattenedFilters = this.flattenQueryResult(response.getReturnValue().filters);
        component.set('v.filters', flattenedFilters);
        var flattenedColumns = this.flattenQueryResult(response.getReturnValue().columns);
        component.set('v.columns', flattenedColumns);
        var flattenedData = this.flattenQueryResult(response.getReturnValue().data);
        component.set('v.data', flattenedData);
        var resume = '';
        switch(flattenedData.length) {
            case 0:
                resume = 'no items';
                break;
            case 1:
                resume = flattenedData.length + ' item';
                break;
            default:
                resume = flattenedData.length + ' items';
                break;
        }
        component.set('v.resume',resume);
        component.set('v.tabsLoaded',true);
    },
    
    loadDualListBoxOptions: function(component) {
        var object = component.get('v.selectedObject');
        var child = object === 'parent' ? false : true;
        var childName = component.get('v.listViewSelected').child;
        var availableFields = component.get('v.availableFields');
        var fieldsRemoved = [];
        var remove = component.get('v.columns');
        for(var i in remove) {
            if(!remove[i].isVisible) {
                fieldsRemoved.push(remove[i]);
            }
        }
        var optionsFields = [];
        for(var i in availableFields) {
            if(availableFields[i].isChild == child) {
                var addField = true;
                for(var j in fieldsRemoved) {
                    if(!fieldsRemoved[j].isVisible && availableFields[i].apiName === fieldsRemoved[j].apiName) {
                        addField = false;
                    }
                }
                if(child && availableFields[i].objectLabel != childName) {
                    addField = false;
                }
                if(availableFields[i].fieldType == 'id') {
                    addField = false;
                }
                if(addField) {
                    optionsFields.push({
                        value: availableFields[i].apiName,
                        label: availableFields[i].label
                    });
                }
            }
        }
        component.set('v.optionsFields',optionsFields);
    }
})