import { LightningElement, api, wire, track } from 'lwc';
import Id from '@salesforce/user/Id';
import getContractList from '@salesforce/apex/CP_ForecastingItemController.getContractsForPOC';

export default class Cp_datatablePicklistContract extends LightningElement {
    @api value;
    @api context;
    @track options;
    @api recordid;
    userId = Id;

    @wire(getContractList, { forecastId: '$recordid' }) 
    wiredContracts({error, data}) {
        if(data){
            //console.log('User Id from Contracts:' + this.userId);
            //console.log('Record Id from Contracts:' + this.recordid);
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
        this.dispatchEvent(new CustomEvent('contractpicklistchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: {Id: this.context, value: this.value }
            }
        }));
    }
}