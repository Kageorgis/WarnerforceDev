import { LightningElement,track,wire } from 'lwc';
import getWithoutCARPTerritoryUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getWithoutCARPTerritoryUrl';
import getWithoutCARPAllUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getWithoutCARPAllUrl';

export default class WbCASRPswithoutCAReportCmp extends LightningElement {
    @track withoutCARPsTerritoryUrl;
    @track withoutCARPsAllUrl;

    @wire(getWithoutCARPTerritoryUrl) getWithoutCARPsTerritory({error,data}){
        this.withoutCARPsTerritoryUrl = data;
        console.log(this.withoutCARPsTerritoryUrl);
    }

    @wire(getWithoutCARPAllUrl) getWithoutCARPsAll({error,data}){
        this.withoutCARPsAllUrl = data;
        console.log(this.withoutCARPsAllUrl);
    }
}