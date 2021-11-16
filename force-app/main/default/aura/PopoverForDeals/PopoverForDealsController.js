({
	handleCancel: function(component) {
        component.set('v.dualListBoxValues',[]);
        component.set('v.isActive', false);
    },
    
    handleLoadFilter: function(component, event, helper) {
        var action = event.getParam('action');
        var tableId = event.getParam('tableId');
        var apiName = event.getParam('apiName');
        var operator = event.getParam('operator');
        var value = event.getParam('value');
        if(action === 'Edit') {
            component.set('v.apiName',apiName);
            component.set('v.operatorSelected',operator);
            component.set('v.value',value);
            if(component.get('v.fieldType') === 'boolean') component.set('v.valueBoolean',value);
        } else {
            component.set('v.apiName','');
            component.set('v.operatorSelected','');
            component.set('v.value','');
        }
        helper.loadPopover(component);
        component.set('v.tableId',tableId);
        component.set('v.action',action);
    },
    
    handleChangeField: function(component, event, helper) {
        component.set('v.apiName',event.getParam('value'));
        component.set('v.operatorSelected','');
        component.set('v.value','');
        component.set('v.valueBoolean','true');
        helper.loadOperators(component);
    },
    
    handleBooleanChange: function(component, event, helper) {
        component.set('v.valueBoolean',event.getParam("value"));
    },
    
    handleModalSelectValuesOpen: function(component, event, helper) {
        component.set('v.showDualListBoxSelector',true);
        helper.loadDualListBoxOptions(component);
    },
    
    handleModalSelectValuesSave: function(component, event, helper) {
        component.set('v.showDualListBoxSelector',false);
        var dualListBoxOptions = component.get('v.dualListBoxOptions');
        var dualListBoxValues = component.get('v.dualListBoxValues');
        var value = '';
        var count = 0;
        for(var i in dualListBoxOptions) {
            for(var j in dualListBoxValues) {
                if(dualListBoxOptions[i].value == dualListBoxValues[j]) {
                    value += dualListBoxOptions[i].value+';';
                    count++;
                }
            }
        }
        var label = count+' option';
        if(count == 0) {
            value = 'ALL';
            label = 'ALL option';
        } else {
            value = value.substring(0,(value.length-1));
            label = count+' option';
        }
        if(count != 1) label += 's';
        label += ' selected';
        component.set('v.dualListBoxLabel',label);
        component.set('v.value',value);
    },
    
    handleModalSelectValuesCancel: function(component, event, helper) {
        component.set('v.showDualListBoxSelector',false);
    },
    
    handleOnChangeInput: function(component,event,helper) {
        var valueForFilter = component.find('valueForFilter');
        valueForFilter.setCustomValidity('');
        valueForFilter.reportValidity();
    },
    
    saveFilter: function(component,event,helper) {
        var apiName = component.get('v.apiName');
        var fieldType = component.get('v.fieldType');
        var tableId = component.get('v.tableId');
        switch(fieldType) {
            case 'date':
            case 'datetime':
                var fieldForFilter = component.find('fieldForFilter');
                var operatorForFilter = component.find('operatorForFilter');
                var valueForFilter = component.find('valueForFilter');
                var value = valueForFilter.get('v.value');
                value = value.replace(/\s+/g, ' ').trim();
                value = value.toUpperCase();
                valueForFilter.set('v.value',value);
                fieldForFilter.set('v.required',true);
                operatorForFilter.set('v.required',true);
                valueForFilter.set('v.required',true);
                fieldForFilter.showHelpMessageIfInvalid();
                operatorForFilter.showHelpMessageIfInvalid();
                valueForFilter.showHelpMessageIfInvalid();
                if(fieldForFilter.checkValidity() && operatorForFilter.checkValidity() && valueForFilter.checkValidity()) {
                    var valid = false;
                    var dateValue = value.replace(/\s+/g, '_');
                    var relativeFilters = [
                        'YESTERDAY','TODAY','TOMORROW','LAST_WEEK','THIS_WEEK','NEXT_WEEK','LAST_MONTH','THIS_MONTH',
                        'NEXT_MONTH','LAST_90_DAYS','NEXT_90_DAYS','LAST_QUARTER','THIS_QUARTER','NEXT_QUARTER',
                        'LAST_YEAR','THIS_YEAR','NEXT_YEAR','LAST_FISCAL_QUARTER','THIS_FISCAL_QUARTER',
                        'NEXT_FISCAL_QUARTER','LAST_FISCAL_YEAR','THIS_FISCAL_YEAR','NEXT_FISCAL_YEAR'
                    ];
                    var relativeFiltersWithN = [
                        'LAST_N_WEEKS','NEXT_N_WEEKS','N_WEEKS_AGO','NEXT_N_MONTHS','LAST_N_MONTHS','N_MONTHS_AGO',
                        'N_DAYS_AGO','LAST_N_QUARTERS','NEXT_N_QUARTERS','N_QUARTERS_AGO','N_YEARS_AGO','LAST_N_YEARS',
                        'NEXT_N_YEARS','LAST_N_FISCAL_QUARTERS','NEXT_N_FISCAL_QUARTERS','N_FISCAL_QUARTERS_AGO',
                        'LAST_N_FISCAL_YEARS','NEXT_N_FISCAL_YEARS','N_FISCAL_YEARS_AGO'
                    ];
                    valid = relativeFilters.includes(dateValue);
                    if(!valid) {
                        dateValue = dateValue.replace(/[0-9]+/g,'N');
                        valid = relativeFiltersWithN.includes(dateValue);
                    }
                    if(!valid) {
                        var dateRegex = new RegExp('(?:(?:0[1-9]|1[0-2])[/]?(?:0[1-9]|[12][0-9])|(?:(?:0[13-9]|1[0-2])[/]?30)|(?:(?:0[13578]|1[02])[/]?31))[/]?(?:19|20)[0-9]{2}');
                        dateValue = value;
                        valid = dateRegex.test(dateValue);
                    }
                    if(!valid) {
                        valueForFilter.setCustomValidity('That is not an accepted value. Example: 01/15/2019');
                    } else {
                        valueForFilter.setCustomValidity('');
                    }
                    valueForFilter.reportValidity();
                    if(valid) {
                        var saveFilter = $A.get('e.c:LoadEditFilterPopover');
                        component.set('v.isActive', false);
                        saveFilter.setParams({
                            'tableId': tableId,
                            'label': component.get('v.label'),
                            'apiName': fieldForFilter.get('v.value'),
                            'operator': operatorForFilter.get('v.value'),
                            'value': value,
                            'action': 'Save'
                        });
                        saveFilter.fire();
                    }
                }
                break;
            case 'boolean':
                var fieldForFilter = component.find('fieldForFilter');
                var operatorForFilter = component.find('operatorForFilter');
                var valueForFilterBoolean = component.find('valueForFilterBoolean');
                fieldForFilter.set('v.required',true);        
                operatorForFilter.set('v.required',true);
                valueForFilterBoolean.set('v.required',true);
                fieldForFilter.showHelpMessageIfInvalid();
                operatorForFilter.showHelpMessageIfInvalid();
                if(fieldForFilter.checkValidity() && operatorForFilter.checkValidity()) {
                    var saveFilter = $A.get('e.c:LoadEditFilterPopover');
                    component.set('v.isActive', false);
                    saveFilter.setParams({
                        'tableId': tableId,
                        'label': component.get('v.label'),
                        'apiName': fieldForFilter.get('v.value'),
                        'operator': operatorForFilter.get('v.value'),
                        'value': component.get('v.valueBoolean'),
                        'action': 'Save'
                    });
                    saveFilter.fire();
                }
                break;
            case 'picklist':
            case 'multipicklist':
                var fieldForFilter = component.find('fieldForFilter');
                var operatorForFilter = component.find('operatorForFilter');
                var dualListBoxValues = component.get('v.dualListBoxValues');
                fieldForFilter.set('v.required',true);
                operatorForFilter.set('v.required',true);
                fieldForFilter.showHelpMessageIfInvalid();
                operatorForFilter.showHelpMessageIfInvalid();
                if(fieldForFilter.checkValidity() && operatorForFilter.checkValidity()) {
                    var saveFilter = $A.get('e.c:LoadEditFilterPopover');
                    component.set('v.isActive', false);
                    saveFilter.setParams({
                        'tableId': tableId,
                        'label': component.get('v.label'),
                        'apiName': fieldForFilter.get('v.value'),
                        'operator': operatorForFilter.get('v.value'),
                        'value': component.get('v.value'),
                        'action': 'Save'
                    });
                    saveFilter.fire();
                }
                break;
            default:
                if(apiName != 'Opportunity.CreatedBy.Name') {
                    var fieldForFilter = component.find('fieldForFilter');
                    var operatorForFilter = component.find('operatorForFilter');
                    var valueForFilter = component.find('valueForFilter');
                    var value = valueForFilter.get('v.value');
                    value = value.replace(/\s+/g, " ").trim();
                    valueForFilter.set('v.value',value);
                    fieldForFilter.set('v.required',true);
                    operatorForFilter.set('v.required',true);
                    valueForFilter.set('v.required',true);
                    fieldForFilter.showHelpMessageIfInvalid();
                    operatorForFilter.showHelpMessageIfInvalid();
                    valueForFilter.showHelpMessageIfInvalid();
                    if(fieldForFilter.checkValidity() && operatorForFilter.checkValidity() && valueForFilter.checkValidity()) {
                        var saveFilter = $A.get('e.c:LoadEditFilterPopover');
                        component.set('v.isActive', false);
                        saveFilter.setParams({
                            'tableId': tableId,
                            'label': component.get('v.label'),
                            'apiName': fieldForFilter.get('v.value'),
                            'operator': operatorForFilter.get('v.value'),
                            'value': valueForFilter.get('v.value'),
                            'action': 'Save'
                        });
                        saveFilter.fire();
                    }
                } else {
                    var saveFilter = $A.get('e.c:LoadEditFilterPopover');
                    component.set('v.isActive', false);
                    saveFilter.setParams({
                        'tableId': tableId,
                        'label': component.get('v.label'),
                        'apiName': component.get('v.apiName'),
                        'operator': component.get('v.operatorSelected'),
                        'value': component.get('v.value'),
                        'action': 'Save'
                    });
                    saveFilter.fire();
                }
                break;
        }
    }
})