import { LightningElement, api, wire, track } from 'lwc';
import getCurrencyList from '@salesforce/apex/CP_ForecastingItemController.getForecastingCurrencyForPOC';

export default class Cp_datatablePicklistCurrency extends LightningElement {
    @api value;
    @api context;
    @track options;

    @wire(getCurrencyList) 
    wiredCurrencies({error, data}) {
        if(data){
            var op = []
            Object.keys(data).forEach(key =>{
                op.push({label: data[key], value: data[key]})
            })
            this.options = op;
        }
        else if(error){
            console.log(error);
        }
    }

    handleChange(event) {
        //show the selected value on UI
        this.value = event.detail.value;
        //fire event to send context and selected value to the data table
        this.dispatchEvent(new CustomEvent('currencypicklistchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: {Id: this.context, value: this.value }
            }
        }));
    }
}