import { LightningElement, wire, api, track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import FORECASTING_ITEM from '@salesforce/schema/CP_Forecast_Item__c';
import REVENUE_TYPE from '@salesforce/schema/CP_Forecast_Item__c.Revenue_Type__c';
export default class Cp_datatablePicklistRevenueType extends LightningElement {
    @api value;
    @api context;
    @track options;

    @wire(getObjectInfo, { objectApiName: FORECASTING_ITEM })
    forecastingItemMetadata;
    @wire(getPicklistValues, {
        recordTypeId: '$forecastingItemMetadata.data.defaultRecordTypeId',
        fieldApiName: REVENUE_TYPE
    })
    revenueTypePicklist({ error, data }) {
        if(data){
            var op = []
            data.values.forEach(element =>{
                op.push({label: element.label, value: element.value})
            })
            this.options = op;
        }
        else if(error){
            console.log(error);
        }
    };

    handleChange(event) {
        //show the selected value on UI
        this.value = event.detail.value;
        //fire event to send context and selected value to the data table
        this.dispatchEvent(new CustomEvent('revenuetypepicklistchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { Id: this.context, value: this.value }
            }
        }));
    }
}