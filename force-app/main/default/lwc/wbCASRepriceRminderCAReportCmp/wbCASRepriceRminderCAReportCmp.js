import { LightningElement,track,wire } from 'lwc';
import getRepriceReminderTerritoryUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getRepriceReminderTerritoryUrl';
import getRepriceReminderAllUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getRepriceReminderAllUrl';

export default class WbCASRepriceRminderCAReportCmp extends LightningElement {
    @track repriceReminderTerritoryUrl;
    @track repriceReminderAllUrl;

    @wire(getRepriceReminderTerritoryUrl) getRepriceReminderTerritory({error,data}){
        this.repriceReminderTerritoryUrl = data;
        console.log(this.repriceReminderTerritoryUrl);
    }

    @wire(getRepriceReminderAllUrl) getRepriceReminderAll({error,data}){
        this.repriceReminderAllUrl = data;
        console.log(this.repriceReminderAllUrl);
    }
}