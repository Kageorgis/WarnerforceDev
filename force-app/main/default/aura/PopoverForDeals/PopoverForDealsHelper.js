({
	loadPopover: function(component) {
		var availableFields = component.get('v.availableFields');
        var apiFieldTypes = {};
        var dealFields = [];
        for(var i in availableFields) {
            if(!availableFields[i].isChild) {
                if(availableFields[i].apiName != 'Opportunity.CreatedBy.Name') {
                    dealFields.push({
                        'label': availableFields[i].label,
                        'value': availableFields[i].apiName
                	});
                }
                apiFieldTypes[availableFields[i].apiName] = availableFields[i].fieldType;
            }
        }
        component.set('v.dealFields',dealFields);
        component.set('v.apiFieldTypes',apiFieldTypes);
        this.loadOperators(component);
	},
    
    loadFieldType: function(component) {
        var apiName = component.get('v.apiName');
        var apiFieldTypes = component.get('v.apiFieldTypes');
        var type = apiFieldTypes[apiName];
        component.set('v.fieldType',type);
        var availableFields = component.get('v.availableFields');
        for(var i in availableFields) {
            if(availableFields[i].apiName == apiName) {
                component.set('v.label',availableFields[i].label);
                component.set('v.fieldName',availableFields[i].fieldName);
            }
        }
        if(type == 'picklist' || type == 'multipicklist') {
            var value = component.get('v.value');
            if(value.length != 0 && value != 'ALL') {
                var values = value.split(';');
                var label = values.length+' option';
                if(values.length>1) label += 's';
                label += ' selected';
                component.set('v.dualListBoxLabel',label);
            } else {
                component.set('v.value','ALL');
                component.set('v.dualListBoxLabel','ALL options selected');
            }
            var loadPicklist = $A.get('e.c:LoadPicklist');
            loadPicklist.fire();
        }
        if(apiName == 'Opportunity.CreatedBy.Name') {
            var value = component.get('v.value');
            if(value.length != 0 && value != 'ALL') {
                var values = value.split(';');
                var label = values.length+' option';
                if(values.length>1) label += 's';
                label += ' selected';
                component.set('v.dualListBoxLabel',label);
            } else {
                component.set('v.value','ALL');
                component.set('v.dualListBoxLabel','ALL options selected');
            }
        }
    },
    
    loadOperators: function(component) {
        this.loadFieldType(component);
        var type = component.get('v.fieldType');
        var operators = component.get('v.operators')[type];
        var operatorsForField = [];
        for(var i in operators) {
            operatorsForField.push({
                'label': operators[i].label,
                'value': operators[i].label
            });
        }
        component.set('v.operatorsForField',operatorsForField);
    },
    
    loadDualListBoxOptions: function(component) {
        var apiName = component.get('v.apiName');
        if(apiName != 'Opportunity.CreatedBy.Name') {
            component.set('v.dualListBoxOptions',component.get('v.picklistValues'));
        } else {
            component.set('v.dualListBoxOptions',component.get('v.studioUsers'));
        }
        var value = component.get('v.value');
        if(value.length != 0 && value != 'ALL') {
            var values = value.split(';');
            var dualListBoxValues = [];
            for(var i in values) {
                dualListBoxValues.push(values[i]);
            }
            component.set('v.dualListBoxValues',dualListBoxValues);
        }
    }
})