import { LightningElement,api,wire} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import CLOSED_LABEL from '@salesforce/label/c.CP_FORECAST_CLOSED';


const FIELDS = [
    'CP_Forecast_Cycle__c.Status__c',
]

export default class Cp_forecast_close extends LightningElement {
    @api
    recordId;

    @wire(getRecord , {recordId : '$recordId',fields : FIELDS})
    forecastCycle;

    isLoading = false;

    @api invoke() {
        this.isLoading = true;
        let record = {
            fields : {
                Id : this.recordId,
                Status__c : CLOSED_LABEL
            }
        };
        updateRecord(record);
    }
}