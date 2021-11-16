import { LightningElement,track,wire } from 'lwc';
import getEarlyEndingCATerritoryUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getEarlyEndingCATerritoryUrl';
import getEarlyEndingCAAllUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getEarlyEndingCAAllUrl';

export default class WbCASEarlyEndingCAsReportCmp extends LightningElement {
    @track earlyEndingCATerritoryUrl;
    @track earlyEndingCAAllUrl;

    @wire(getEarlyEndingCATerritoryUrl) getEarlyEndingCATerritory({error,data}){
        this.earlyEndingCATerritoryUrl = data;
        console.log(this.earlyEndingCATerritoryUrl);
    }

    @wire(getEarlyEndingCAAllUrl) getEarlyEndingCAAll({error,data}){
        this.earlyEndingCAAllUrl = data;
        console.log(this.earlyEndingCAAllUrl);
    }
}