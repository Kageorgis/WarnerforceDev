({
    init : function (component, event, helper) {
        var operators = {
            'date' : [ 
                { 'label' : 'equals', 'value' : 'equals' }, 
                { 'label' : 'not equal to', 'value' : 'notEqual' }, 
                { 'label' : 'less than', 'value' : 'lessThan' }, 
                { 'label' : 'greater than', 'value' : 'greaterThan' }, 
                { 'label' : 'less or equal', 'value' : 'lessOrEqual' }, 
                { 'label' : 'greater or equal', 'value' : 'greaterOrEqual' } 
            ],
            'string' : [ 
                { 'label' : 'equals', 'value' : 'equals' }, 
                { 'label' : 'not equal to', 'value' : 'notEqual' }, 
                { 'label' : 'less than', 'value' : 'lessThan' }, 
                { 'label' : 'greater than', 'value' : 'greaterThan' }, 
                { 'label' : 'less or equal', 'value' : 'lessOrEqual' }, 
                { 'label' : 'greater or equal', 'value' : 'greaterOrEqual' }, 
                { 'label' : 'contains', 'value' : 'contains' }, 
                { 'label' : 'does not contain', 'value' : 'notContain' }, 
                { 'label' : 'starts with', 'value' : 'startsWith' } 
            ],
            'double' : [ 
                { 'label' : 'equals', 'value' : 'equals' }, 
                { 'label' : 'not equal to', 'value' : 'notEqual' }, 
                { 'label' : 'less than', 'value' : 'lessThan' }, 
                { 'label' : 'greater than', 'value' : 'greaterThan' }, 
                { 'label' : 'less or equal', 'value' : 'lessOrEqual' }, 
                { 'label' : 'greater or equal', 'value' : 'greaterOrEqual' } 
            ],
            'picklist' : [ 
                { 'label' : 'equals', 'value' : 'equals' }, 
                { 'label' : 'not equal to', 'value' : 'notEqual' } 
            ], 
            'textarea' : [ 
                { 'label' : 'equals', 'value' : 'equals' }, 
                { 'label' : 'not equal to', 'value' : 'notEqual' }, 
                { 'label' : 'less than', 'value' : 'lessThan' }, 
                { 'label' : 'greater than', 'value' : 'greaterThan' }, 
                { 'label' : 'less or equal', 'value' : 'lessOrEqual' }, 
                { 'label' : 'greater or equal', 'value' : 'greaterOrEqual' }, 
                { 'label' : 'contains', 'value' : 'contains' }, 
                { 'label' : 'does not contain', 'value' : 'notContain' }, 
                { 'label' : 'starts with', 'value' : 'startsWith' } 
            ],
            'percent' : [ 
                { 'label' : 'equals', 'value' : 'equals' }, 
                { 'label' : 'not equal to', 'value' : 'notEqual' }, 
                { 'label' : 'less than', 'value' : 'lessThan' }, 
                { 'label' : 'greater than', 'value' : 'greaterThan' }, 
                { 'label' : 'less or equal', 'value' : 'lessOrEqual' }, 
                { 'label' : 'greater or equal', 'value' : 'greaterOrEqual' } 
            ],
            'url' : [ 
                { 'label' : 'equals', 'value' : 'equals' }, 
                { 'label' : 'not equal to', 'value' : 'notEqual' }, 
                { 'label' : 'less than', 'value' : 'lessThan' }, 
                { 'label' : 'greater than', 'value' : 'greaterThan' }, 
                { 'label' : 'less or equal', 'value' : 'lessOrEqual' }, 
                { 'label' : 'greater or equal', 'value' : 'greaterOrEqual' }, 
                { 'label' : 'contains', 'value' : 'contains' }, 
                { 'label' : 'does not contain', 'value' : 'notContain' }, 
                { 'label' : 'starts with', 'value' : 'startsWith' } 
            ],
            'int' : [ 
                { 'label' : 'equals', 'value' : 'equals' }, 
                { 'label' : 'not equal to', 'value' : 'notEqual' }, 
                { 'label' : 'less than', 'value' : 'lessThan' }, 
                { 'label' : 'greater than', 'value' : 'greaterThan' }, 
                { 'label' : 'less or equal', 'value' : 'lessOrEqual' }, 
                { 'label' : 'greater or equal', 'value' : 'greaterOrEqual' } 
            ], 
            'reference' : [ 
                { 'label' : 'equals', 'value' : 'equals' }, 
                { 'label' : 'not equal to', 'value' : 'notEqual' }, 
                { 'label' : 'less than', 'value' : 'lessThan' }, 
                { 'label' : 'greater than', 'value' : 'greaterThan' }, 
                { 'label' : 'less or equal', 'value' : 'lessOrEqual' }, 
                { 'label' : 'greater or equal', 'value' : 'greaterOrEqual' }, 
                { 'label' : 'contains', 'value' : 'contains' }, 
                { 'label' : 'does not contain', 'value' : 'notContain' }, 
                { 'label' : 'starts with', 'value' : 'startsWith' } 
            ],
            'datetime' : [ 
                { 'label' : 'equals', 'value' : 'equals' }, 
                { 'label' : 'not equal to', 'value' : 'notEqual' }, 
                { 'label' : 'less than', 'value' : 'lessThan' }, 
                { 'label' : 'greater than', 'value' : 'greaterThan' }, 
                { 'label' : 'less or equal', 'value' : 'lessOrEqual' }, 
                { 'label' : 'greater or equal', 'value' : 'greaterOrEqual' } 
            ],
            'boolean' : [ 
                { 'label' : 'equals', 'value' : 'equals' }, 
                { 'label' : 'not equal to', 'value' : 'notEqual' } 
            ],
            'phone' : [ 
                { 'label' : 'equals', 'value' : 'equals' }, 
                { 'label' : 'not equal to', 'value' : 'notEqual' }, 
                { 'label' : 'less than', 'value' : 'lessThan' }, 
                { 'label' : 'greater than', 'value' : 'greaterThan' }, 
                { 'label' : 'less or equal', 'value' : 'lessOrEqual' }, 
                { 'label' : 'greater or equal', 'value' : 'greaterOrEqual' }, 
                { 'label' : 'contains', 'value' : 'contains' }, 
                { 'label' : 'does not contain', 'value' : 'notContain' }, 
                { 'label' : 'starts with', 'value' : 'startsWith' } 
            ],
            'currency' : [ 
                { 'label' : 'equals', 'value' : 'equals' }, 
                { 'label' : 'not equal to', 'value' : 'notEqual' }, 
                { 'label' : 'less than', 'value' : 'lessThan' }, 
                { 'label' : 'greater than', 'value' : 'greaterThan' }, 
                { 'label' : 'less or equal', 'value' : 'lessOrEqual' }, 
                { 'label' : 'greater or equal', 'value' : 'greaterOrEqual' } 
            ],
            'id' : [ 
                { 'label' : 'equals', 'value' : 'equals' }, 
                { 'label' : 'not equal to', 'value' : 'notEqual' } 
            ],
            'email' : [ 
                { 'label' : 'equals', 'value' : 'equals' }, 
                { 'label' : 'not equal to', 'value' : 'notEqual' }, 
                { 'label' : 'less than', 'value' : 'lessThan' }, 
                { 'label' : 'greater than', 'value' : 'greaterThan' }, 
                { 'label' : 'less or equal', 'value' : 'lessOrEqual' }, 
                { 'label' : 'greater or equal', 'value' : 'greaterOrEqual' }, 
                { 'label' : 'contains', 'value' : 'contains' }, 
                { 'label' : 'does not contain', 'value' : 'notContain' }, 
                { 'label' : 'starts with', 'value' : 'startsWith' } 
            ], 
            'multipicklist' : [ 
                { 'label' : 'equals', 'value' : 'equals' }, 
                { 'label' : 'not equal to', 'value' : 'notEqual' }, 
                { 'label' : 'includes', 'value' : 'includes' }, 
                { 'label' : 'excludes', 'value' : 'excludes' } 
            ]
        };
        component.set('v.operators',operators);
        helper.getData(component, event, 'getListViews', 'listViews');
        var maxHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
        component.set('v.viewportSize',maxHeight);
        window.addEventListener('resize', $A.getCallback(function(){
            if(component.isValid()) {
                var newHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
        		component.set('v.viewportSize',newHeight);
            }
        }));
    },
    
    handleListViewSelect: function (component, event, helper) {
        // This will contain the index (position) of the selected lightning:menuItem
        var selectedMenuItemValue = event.getParam('value');
        // Find all menu items
        var menuItems = component.find('menuItems');
        var listViews = component.get('v.listViews');
        menuItems.forEach(function (menuItem) {
            // For each menu item, if it was checked, un-check it. This ensures that only one
            // menu item is checked at a time
            if (menuItem.get('v.checked')) {
                menuItem.set('v.checked', false);
            }
            // Check the selected menu item
            if (menuItem.get('v.value') === selectedMenuItemValue) {
                menuItem.set('v.checked', true);
            }
        });
        for(var view in listViews) {
            listViews[view].isSelected = false;
            if(listViews[view].value === selectedMenuItemValue) {
                listViews[view].isSelected = true;
                component.set('v.listViewSelected',listViews[view]);
                component.set('v.resume','Loading Items');
                component.set('v.tabsLoaded',false);
                component.set('v.filtered',false);
                component.set('v.showPopoverEditFilter',false);
                component.set('v.showFilterPanel',false);
                helper.getData(component, event, 'getPickListValues', 'categories');
            }
        }
    },
    
    handleCreateNewRecordMenu : function (component, event, helper) {
        component.set('v.showPopoverEditFilter',false);
        component.set('v.showFilterPanel',false);
        var selectedMenuItemValue = event.getParam('value');
        var createRecordEvent = $A.get('e.force:createRecord');
        switch (selectedMenuItemValue) {
            case 'Deal':
                createRecordEvent.setParams({ 
                    'entityApiName': 'Opportunity' ,
                    'recordTypeId': '0120B000000QybbQAC'
                });
                break;
            case 'RelatedContact':
                createRecordEvent.setParams({ 
                    'entityApiName': 'WBSF_Related_Contacts__c' 
                });
                break;
            case 'RelatedCompany':
                createRecordEvent.setParams({
                    'entityApiName': 'WBSF_Related_Company__c' 
                });
                break;
        }
        createRecordEvent.fire();
    },
    
    handleSearchKeyChange: function (component, event, helper) {
        component.set('v.contactsToFollow',[]);
        var searchEvent = $A.get('e.c:SearchKeyChange');
        searchEvent.setParams({
            'searchKey': component.get('v.searchKey')
        });
        var timer = component.get('v.timer');
        clearTimeout(timer);
        var timer = setTimeout(function(){
            searchEvent.fire();
            clearTimeout(timer);
            component.set('v.timer',null);
        }, 300);
        component.set('v.timer',timer);
    },
    
    handleSelectedContacts: function (component, event, helper) {
        var action = event.getParam('action');
        if(action == 'evaluate') {
            var contactsReceived = event.getParam('contactIds');
            var contactIds = [];
            for(var i in contactsReceived) {
                contactIds.push(contactsReceived[i]);
            }
            component.set('v.contactsToFollow',contactIds);
        }
    },
    
    handleFollowContacts: function (component, event, helper) {
        helper.getData(component, event, 'followContacts', 'contactsToFollow');
    },
    
    handleViewSettingsMenu : function (component, event, helper) {
        var selectedMenuItemValue = event.getParam('value');
        component.set('v.showPopoverEditFilter',false);
        component.set('v.showFilterPanel',false);
        switch (selectedMenuItemValue) {
            case 'New':
                component.set('v.showModalNewListView',true);
                break;
            case 'Clone':
                alert('Clone View');
                break;
            case 'Fields':
                component.set('v.selectedObject','parent');
                var optionObjects = [
                    { value: 'parent', label: 'Available Deal fields' },
                    { value: 'child', label: 'Available '+component.get('v.listViewSelected').child+' fields' }
                ];
                component.set('v.optionObjects',optionObjects);
                var valueFields = [];
                var requiredFields = [];
                var columns = component.get('v.columns');
                for(var i in columns) {
                    if(columns[i].isVisible) {
                        if(columns[i].isRestricted) {
                            requiredFields.push(columns[i].apiName);
                        }
                        if (!columns[i].isChild) {
                            valueFields.push(columns[i].apiName);
                        }
                    }
                }
                var optionsRetained = [];
                for(var i in columns) {
                    if(columns[i].isVisible && columns[i].isChild) {
                        optionsRetained.push(columns[i].apiName);
                    }
                }
                component.set('v.valueFields',valueFields);
                component.set('v.requiredFields',requiredFields);
                component.set('v.optionsRetained',optionsRetained);
                var availableFields = component.get('v.availableFields');
                component.set('v.showModalEditFields',true);
                helper.loadDualListBoxOptions(component);
                break;
            case 'Delete':
                component.set('v.showModalDeleteListView',true);
                break;
            case 'Widths':
                alert('Reset Widths');
                break;
        }
    },
    
    handleChangeObject: function (component, event, helper) {
        // Get the string of the 'value' attribute on the selected option
        var selectedOptionValue = event.getParam('value');
        component.set('v.selectedObject',selectedOptionValue);
        var values = component.find('fieldsSelected').get('v.value');
        var retained = component.get('v.optionsRetained');
        component.set('v.valueFields',retained);
        component.set('v.optionsRetained',values);
        helper.loadDualListBoxOptions(component);
    },
    
    handleModalNewListSave: function (component, event, helper) {
        var newListName = component.find('newListName');
        var newListJoin = component.find('newListJoin');
        newListName.set('v.required',true);
        newListJoin.set('v.required',true);
        newListName.showHelpMessageIfInvalid();
        newListJoin.showHelpMessageIfInvalid();
        if(newListName.checkValidity() && newListJoin.checkValidity()) {
            var newViewFieldValues = [
                newListName.get('v.value'),
                newListJoin.get('v.value')
            ];
            newListName.set('v.value','');
        	newListJoin.set('v.value','');
            component.set('v.newViewFieldValues',newViewFieldValues);
            component.set('v.showModalNewListView',false);
            helper.getData(component, event, 'insertView', '');
        }
    },
    
    handleModalNewListCancel: function (component) {
        var newListName = component.find('newListName');
        var newListJoin = component.find('newListJoin');
        newListName.set('v.value','');
        newListJoin.set('v.value','');
        component.set('v.showModalNewListView',false);
    },
    
    handleModalEditFieldsSave: function (component, event, helper) {
        var comboValue = component.find('objectSelected').get('v.value');
        var values = component.find('fieldsSelected').get('v.value');
        var retained = component.get('v.optionsRetained');
        var fields = [];
        if(comboValue === 'child') {
            fields = retained;
            for(var i in values) {
                fields.push(values[i]);
            }
        } else {
            fields = values;
            for(var i in retained) {
                fields.push(retained[i]);
            }
        }
        var availableFields = component.get('v.availableFields');
        var requiredFields = component.get('v.requiredFields');
        var savedFields = [];
        for(var i in fields) {
            var apiNameField = fields[i];
            var restricted = false;
            for(var j in requiredFields) {
                if(requiredFields[j] === apiNameField) restricted = true;
            }
            for(var k in availableFields) {
                if(availableFields[k].apiName === apiNameField) {
                    availableFields[k].isRestricted = restricted;
                    savedFields.push(availableFields[k]);
                }
            }
        }
        component.set('v.savedFields',savedFields);
        component.set('v.showModalEditFields',false);
        component.set('v.tabsLoaded',false);
        helper.getData(component, event, 'updateColumns', '');
    },
    
    handleModalEditFieldsCancel: function(component) {
        component.set('v.showModalEditFields',false);
    },
    
    handleUpdateFilters: function(component,event,helper) {
        component.set('v.resume','Loading Items');
        component.set('v.tabsLoaded',false);
        helper.getData(component, event, 'updateFilters', '');
    },
    
    handleModalCloneDealSave: function(component, event, helper) {
        var cloneDeal = component.find('cloneDeal');
        cloneDeal.set('v.required',true);
        cloneDeal.showHelpMessageIfInvalid();
        if(cloneDeal.checkValidity()) {
            component.set('v.showPopoverEditFilter',false);
            component.set('v.showFilterPanel',false);
            component.set('v.tabsLoaded',false);
            component.set('v.resume','Loading Items');
            component.set('v.showModalCloneDeal',false);
            helper.getData(component, event, 'cloneDeal', '');
        }
        cloneDeal.set('v.value','');
    },
    
    handleModalCloneDealCancel: function(component) {
        var cloneDeal = component.find('cloneDeal');
        cloneDeal.set('v.value','');
        component.set('v.showModalCloneDeal',false);
    },
    
    handleModalListViewDelete: function (component, event, helper) {
        component.set('v.showModalDeleteListView',false);
        helper.getData(component, event, 'deleteView', '');
    },
    
    handleModalListViewCancel: function (component) {
        component.set('v.showModalDeleteListView',false);
    },
    
    handleRefresh: function (component, event, helper) {
        component.set('v.searchKey','');
        component.set('v.showPopoverEditFilter',false);
        component.set('v.showFilterPanel',false);
        component.set('v.tabsLoaded',false);
        component.set('v.resume','Loading Items');
        component.set('v.contactsToFollow',[]);
        helper.getData(component, event, 'updateData', 'data');
    },
    
    handleFilterPanel: function (component, event, helper) {
        var availableFields = component.get('v.availableFields');
        component.set('v.showFilterPanel', !component.get('v.showFilterPanel'));
        if(!component.get('v.showFilterPanel')) {
            component.set('v.showPopoverEditFilter',false);
        }
    },
    
    handleLoadPicklist: function (component, event, helper) {
        helper.getData(component, event, 'getPickListValues', 'picklistValues');
    },
    
    handleCloneHideDeal: function (component, event, helper) {
        var action = event.getParam('action');
        switch(action) {
            case 'copy':
                component.set('v.showModalCloneDeal',true);
                component.set('v.dealId',event.getParam('dealId'));
                component.set('v.dealName','Copy of '+event.getParam('dealName'));
                break;
            case 'hide':
                var filters = component.get('v.filters');
                if(filters.length>12) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Excess of custom filters",
                        message: "You have reached the limit of 12 custom filters",
                        type: "error"
                    });
                    toastEvent.fire();
                } else {
                    component.set('v.dealId',event.getParam('dealId'));
                    component.set('v.dealName',event.getParam('dealName'));
                    component.set('v.resume','Loading Items');
                    component.set('v.tabsLoaded',false);
                    helper.getData(component, event, 'hideDeal', '');
                }
                break;
        }
    }
})