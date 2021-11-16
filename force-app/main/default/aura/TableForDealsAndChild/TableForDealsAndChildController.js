({
	init : function (component, event, helper) {
        var columns = [];
        var viewColumns = component.get('v.columns');
        for(var column in viewColumns) {
            if(viewColumns[column].isVisible) {
                switch (viewColumns[column].fieldType) {
                    case 'integer':
                    case 'double':
                        columns.push({
                            label: viewColumns[column].label,
                            fieldName: viewColumns[column].fieldName,
                            sortable: viewColumns[column].isSortable,
                            type: 'number'
                        });
                        break;
                    case 'currency':
                        columns.push({
                            label: viewColumns[column].label,
                            fieldName: viewColumns[column].fieldName,
                            sortable: viewColumns[column].isSortable,
                            type: 'currency',
                            typeAttributes: { 
                                currencyCode: 'USD' 
                            }
                        });
                        break;
                    case 'string':
                    case 'textarea':
                    case 'picklist':
                    case 'multipicklist':
                        if(viewColumns[column].fieldName === 'Name') {
                            columns.push({
                                label: viewColumns[column].label,
                                fieldName: 'urlId',
                                sortable: viewColumns[column].isSortable,
                                type: 'url',
                                typeAttributes: { 
                                    label: { fieldName: viewColumns[column].fieldName }
                                }
                            });
                        } else {
                            columns.push({
                                label: viewColumns[column].label,
                                fieldName: viewColumns[column].fieldName,
                                sortable: viewColumns[column].isSortable,
                                type: 'text'
                            });
                        }
                        break;
                    case 'datetime':
                        columns.push({
                            label: viewColumns[column].label,
                            fieldName: viewColumns[column].fieldName,
                            sortable: false,
                            type: 'date',
                            typeAttributes: { 
                                day: 'numeric',
                                month: 'short',
                                year: 'numeric',
                                hour: '2-digit',
                                minute: '2-digit',
                                second: '2-digit',
                                hour12: true
                            }
                        });
                        break;
                    case 'reference':
                        columns.push({
                            label: viewColumns[column].label,
                            fieldName: viewColumns[column].fieldName+'.urlId',
                            sortable: viewColumns[column].isSortable,
                            type: 'url',
                            typeAttributes: { 
                                label: { fieldName: viewColumns[column].fieldName+'.Name' }
                            }
                        });
                        break;
                    default:
                        columns.push({
                            label: viewColumns[column].label,
                            fieldName: viewColumns[column].fieldName,
                            sortable: viewColumns[column].isSortable,
                            type: viewColumns[column].fieldType
                        });
                        break;
                }
            }
        }
        columns.push(
            { 
                type: 'button-icon',
                fixedWidth: 50,
                typeAttributes: { 
                    alternativeText: { fieldName: 'copyName' },
                    name: 'copy',
                    iconName: 'utility:copy',
                    iconClass: 'slds-icon-text-success',
                    variant: 'container'
                } 
            },
            { 
                type: 'button-icon',
                fixedWidth: 50,
                typeAttributes: { 
                    alternativeText: { fieldName: 'hideName' },
                    name: 'hide',
                    iconName: 'utility:hide',
                    iconClass: 'slds-icon-text-error',
                    variant: 'container'
                } 
            }
        );
        component.set('v.tableColumns', columns);
        var data = component.get('v.data');
        for(var i=0; i<data.length; i++) {
            if(data[i].hasOwnProperty('Related_Contacts__r.Relationship_Strength__c')) {
                var relationship = data[i]['Related_Contacts__r.Relationship_Strength__c'];
                switch(relationship) {
                    case 'High':
                        data[i]['Related_Contacts__r.WBSF_Contact__r.Name'] = data[i]['Related_Contacts__r.WBSF_Contact__r.Name']+' \u207D\u00B9\u207E';
                        break;
                    default:
                        data[i]['Related_Contacts__r.WBSF_Contact__r.Name'] = data[i]['Related_Contacts__r.WBSF_Contact__r.Name']+' \u207D\u00B2\u207E';
                        break;
                }
            }
            if(data[i].hasOwnProperty('Probability')) {
                var percent = data[i]['Probability'];
                percent = percent/100;
                data[i]['Probability'] = percent;
            }
        }
        component.set('v.data',data)
        helper.loadData(component);
    },
    
    handleUpdateData: function(component, event, helper) {
        var searchKey = event.getParam('searchKey');
        component.set('v.searchOnTable',searchKey);
        component.set('v.searching',true);
        var datatable = component.find('dataTable');
        datatable.set('v.selectedRows',[]);
        helper.loadData(component,event,searchKey);
    },
    
    handleActiveTab: function (component, event, helper) {
        var categoryId = event.getSource().get('v.id');
        var dataByCategories = component.get('v.dataByCategories');
        var dataTable = dataByCategories[categoryId];
        component.set('v.dataTable',dataTable);
        var fieldName = component.get('v.sortedBy');
        var switchSort = component.get('v.switchSort');
        var sortDirection = component.get('v.sortedDirection') === 'asc' ? 'desc' : 'asc';
        if(switchSort) {
            sortDirection = component.get('v.sortedDirection') === 'desc' ? 'asc' : 'desc';
        }
        fieldName = fieldName.replace('urlId','Name');
        component.set('v.sortedDirection', sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
    
    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        if(sortDirection === 'desc') {
            component.set('v.switchSort',true);
        } else {
            component.set('v.switchSort',false);
        }
        // assign the latest attribute with the sorted column fieldName and sorted direction
        component.set('v.sortedBy', fieldName);
        component.set('v.sortedDirection', sortDirection);
        fieldName = fieldName.replace('urlId','Name');
        helper.sortData(component, fieldName, sortDirection);
    },
    
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        var dealCopyHideEvent = $A.get('e.c:CloneHideDeal');
        dealCopyHideEvent.setParams({
            'action': action.name,
            'dealId': row.Id,
            'dealName': row.Name
        });
        dealCopyHideEvent.fire();
    },
    
    handleRowSelection: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        var contactsToFollow = [];
        for(var row in selectedRows) {
            if(selectedRows[row].hasOwnProperty('Related_Contacts__r.WBSF_Contact__r.Name')) {
                var contactId = selectedRows[row]['Related_Contacts__r.WBSF_Contact__r.Id'];
            	if(contactsToFollow.indexOf(contactId) === -1) contactsToFollow.push(contactId);
            }
        }
        var followEvent = $A.get('e.c:ContactsToFollow');
        followEvent.setParams({
            'action': 'evaluate',
            'contactIds': contactsToFollow
        });
        followEvent.fire();
    }
})