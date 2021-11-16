import { LightningElement,track,wire } from 'lwc';
import getDraftCATerritoryUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getDraftCATerritoryUrl';
import getDraftCAAllUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getDraftCAAllUrl';

export default class WbCASDraftCAReportCmp extends LightningElement {
    @track draftCATerritoryUrl;
    @track draftCAAllUrl;

    @wire(getDraftCATerritoryUrl) getDraftCATerritory({error,data}){
        this.draftCATerritoryUrl = data;
        console.log(this.draftCATerritoryUrl);
    }

    @wire(getDraftCAAllUrl) getDraftCAAll({error,data}){
        this.draftCAAllUrl = data;
        console.log(this.draftCAAllUrl);
    }
}