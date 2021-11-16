({
    init: function(component, event, helper) {
        var filters = component.get('v.filters');
        var filtersEdited = [];
        for(var i in filters) {
            filtersEdited.push({
                'apiName': filters[i].apiName,
                'fieldType': filters[i].fieldType,
                'filterId': filters[i].filterId,
                'isActive': filters[i].isActive,
                'isRestricted': filters[i].isRestricted,
                'label': filters[i].label,
                'operator': filters[i].operator,
                'operatorLabel': filters[i].operatorLabel,
                'tableId': filters[i].tableId,
                'value': filters[i].value,
            });
        }
        component.set('v.filtersEdited',filtersEdited);
    },
    
    handleClosePanel: function(component) {
        component.set('v.isActive', false);
    },
    
    handleCancelEdit: function(component) {
        component.set('v.showEditCancel',false);
        var filters = component.get('v.filters');
        var filtersEdited = [];
        for(var i in filters) {
            filtersEdited.push({
                'apiName': filters[i].apiName,
                'fieldType': filters[i].fieldType,
                'filterId': filters[i].filterId,
                'isActive': filters[i].isActive,
                'isRestricted': filters[i].isRestricted,
                'label': filters[i].label,
                'operator': filters[i].operator,
                'operatorLabel': filters[i].operatorLabel,
                'tableId': filters[i].tableId,
                'value': filters[i].value,
            });
        }
        component.set('v.filtersEdited',filtersEdited);
    },
    
    handleSaveEdit: function(component) {
        component.set('v.showEditCancel',false);
        var filtersToSave = component.get('v.filtersEdited');
        var filters = [];
        for(var i in filtersToSave) {
            filters.push({
                'apiName': filtersToSave[i].apiName,
                'fieldType': filtersToSave[i].fieldType,
                'filterId': filtersToSave[i].filterId,
                'isActive': filtersToSave[i].isActive,
                'isRestricted': filtersToSave[i].isRestricted,
                'label': filtersToSave[i].label,
                'operator': filtersToSave[i].operator,
                'operatorLabel': filtersToSave[i].operatorLabel,
                'tableId': filtersToSave[i].tableId,
                'value': filtersToSave[i].value,
            });
        }
        component.set('v.filters',filters);
        var updateFilters = $A.get('e.c:UpdateFilters');
        updateFilters.fire();
    },
    
    handleLoadFilter: function(component, event, helper) {
        //var value = event.getSource().get('v.value');
        //var filters = component.find('filter');
        //var minHeight = 400;
        //var h = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
        //filters.forEach(function (filter) {
            //var title = filter.getElement().getAttribute('title');
            //var filterRect = filter.getElement().getBoundingClientRect();
            //if(minHeight > filterRect.top) minHeight = filterRect.top;
            //if(title == value) {
                //console.log('max height: '+(h/16));
                //console.log('use this for top');
                //var top = 0;
                //if(minHeight-264>0) {
                //    top = ((filterRect.top-264)/16);
                //} else {
                //    top = ((filterRect.top)/16)-10;
                //}
                //console.log(top);
                //console.log(filterRect.top+' - '+filterRect.bottom+' & '+filterRect.height);
            //}
        //});
        var tableId = event.getSource().get('v.value');
        var filtersEdited = component.get('v.filtersEdited');
        for(var i in filtersEdited) {
            if(filtersEdited[i].tableId == tableId) {
                var loadFilter = $A.get('e.c:LoadEditFilterPopover');
                loadFilter.setParams({
                    'tableId': filtersEdited[i].tableId,
                    'apiName': filtersEdited[i].apiName,
                    'operator': filtersEdited[i].operator,
                    'value': filtersEdited[i].value,
                    'action': 'Edit'
                });
                loadFilter.fire();
            }
        }
        component.set('v.blockPanel',true);
        //var div = filter.getBoundingClientRect();
    },
    
    handleAddFilter: function(component, event, helper) {
        var filtersEdited = component.get('v.filtersEdited');
        if(filtersEdited.length>12) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Excess of custom filters",
                message: "You have reached the limit of 12 custom filters",
                type: "error"
            });
            toastEvent.fire();
        } else {
            var loadFilter = $A.get('e.c:LoadEditFilterPopover');
            loadFilter.setParams({
                'tableId': -1,
                'apiName': '',
                'operator': '',
                'value': '',
                'action': 'Add'
            });
            loadFilter.fire();
            component.set('v.blockPanel',true);
        }
    },
    
    handleUpdateFilters: function(component,event,helper) {
        var action = event.getParam('action');
        var filtersEdited = component.get('v.filtersEdited');
        var showEditCancel = false;
        if(action === 'Save') {
            var tableId = event.getParam('tableId');
            var label = event.getParam('label');
            var apiName = event.getParam('apiName');
            var operator = event.getParam('operator');
            var value = event.getParam('value');
            if(tableId == -1) {
                var operatorLabel = operator.toLowerCase()+' '+value.toUpperCase();
                operatorLabel = operatorLabel.replace(';',', ');
                filtersEdited.push({
                    'apiName': apiName,
                    'isActive': true,
                    'isRestricted': false,
                    'label': label,
                    'operator': operator,
                    'operatorLabel': operatorLabel,
                    'tableId': filtersEdited.length,
                    'value': value,
                });
                showEditCancel = true;
            } else {
                for(var i in filtersEdited) {
                    if(filtersEdited[i].tableId == tableId) {
                        if(filtersEdited[i].apiName != apiName) {
                            filtersEdited[i].label = label;
                            filtersEdited[i].apiName = apiName;
                            showEditCancel = true;
                        }
                        if(filtersEdited[i].operator != operator) {
                            filtersEdited[i].operator = operator;
                            showEditCancel = true;
                        }
                        if(filtersEdited[i].value != value) {
                            filtersEdited[i].value = value;
                            showEditCancel = true;
                        }
                        if(showEditCancel) {
                            var operatorLabel = filtersEdited[i].operator.toLowerCase()+' '+filtersEdited[i].value.toUpperCase();
                            if(filtersEdited[i].apiName == 'Opportunity.CreatedBy.Name' && value != 'ALL') {
                                var values = value.split(';');
                                var valueForLabel = values.length+' Studio User';
                                if(values.length>1) valueForLabel += 's';
                                operatorLabel = filtersEdited[i].operator.toLowerCase()+' '+valueForLabel.toUpperCase();
                            }
                            operatorLabel = operatorLabel.replace(';',', ');
                            filtersEdited[i].operatorLabel = operatorLabel;
                        }
                    }
                }
            }
            if(showEditCancel) {
                component.set('v.showEditCancel',true);
                component.set('v.filtersEdited',filtersEdited);
            }
        }
    },
    
    handleRemoveFilter: function(component,event,helper) {
        var tableId = event.getSource().get('v.value');
        var filters = component.get('v.filtersEdited');
        var filtersEdited = [];
        for(var i in filters) {
            if(filters[i].tableId != tableId) {
                filtersEdited.push({
                    'apiName': filters[i].apiName,
                    'fieldType': filters[i].fieldType,
                    'filterId': filters[i].filterId,
                    'isActive': filters[i].isActive,
                    'isRestricted': filters[i].isRestricted,
                    'label': filters[i].label,
                    'operator': filters[i].operator,
                    'operatorLabel': filters[i].operatorLabel,
                    'tableId': filtersEdited.length,
                    'value': filters[i].value
                });
            }
        }
        component.set('v.showEditCancel',true);
        component.set('v.filtersEdited',filtersEdited);
    },
    
    handleRemoveAllFilters: function(component,event,helper) {
        var tableId = event.getSource().get('v.value');
        var filters = component.get('v.filtersEdited');
        var filtersEdited = [];
        for(var i in filters) {
            if(filters[i].isRestricted) {
                filtersEdited.push({
                    'apiName': filters[i].apiName,
                    'fieldType': filters[i].fieldType,
                    'filterId': filters[i].filterId,
                    'isActive': filters[i].isActive,
                    'isRestricted': filters[i].isRestricted,
                    'label': filters[i].label,
                    'operator': filters[i].operator,
                    'operatorLabel': filters[i].operatorLabel,
                    'tableId': filtersEdited.length,
                    'value': filters[i].value
                });
            }
        }
        component.set('v.showEditCancel',true);
        component.set('v.filtersEdited',filtersEdited);
    }
})