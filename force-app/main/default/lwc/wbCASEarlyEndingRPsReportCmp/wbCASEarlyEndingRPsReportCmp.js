import { LightningElement,track,wire } from 'lwc';
import getEarlyEndingRPTerritoryUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getEarlyEndingRPTerritoryUrl';
import getEarlyEndingRPAllUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getEarlyEndingRPAllUrl';

export default class WbCASEarlyEndingRPsReportCmp extends LightningElement {
    @track earlyEndingRPTerritoryUrl;
    @track earlyEndingRPAllUrl;

    @wire(getEarlyEndingRPTerritoryUrl) getEarlyEndingRPTerritory({error,data}){
        this.earlyEndingRPTerritoryUrl = data;
        console.log(this.earlyEndingRPTerritoryUrl);
    }

    @wire(getEarlyEndingRPAllUrl) getEarlyEndingRPAll({error,data}){
        this.earlyEndingRPAllUrl = data;
        console.log(this.earlyEndingRPAllUrl);
    }
}