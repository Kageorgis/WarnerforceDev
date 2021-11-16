import { LightningElement,track,wire } from 'lwc';
import getNRRepriceCATerritoryUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getNRRepriceCATerritoryUrl';
import getNRRepriceCAAllUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getNRRepriceCAAllUrl';

export default class WbCASNRToCatRepriceReportCmp extends LightningElement {
    @track nrRepriceCATerritoryUrl;
    @track nrRepriceCAAllUrl;

    @wire(getNRRepriceCATerritoryUrl) getDraftCATerritory({error,data}){
        this.nrRepriceCATerritoryUrl = data;
        console.log(this.nrRepriceCATerritoryUrl);
    }

    @wire(getNRRepriceCAAllUrl) getDraftCAAll({error,data}){
        this.nrRepriceCAAllUrl = data;
        console.log(this.nrRepriceCAAllUrl);
    }
}