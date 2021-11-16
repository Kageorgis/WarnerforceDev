import { LightningElement,track,wire } from 'lwc';
import getOpenRPTerritoryUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getOpenRPTerritoryUrl';
import getOpenRPAllUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getOpenRPAllUrl';

export default class WbCASOpenRPsReportCmp extends LightningElement {
    @track openRPTerritoryUrl;
    @track openRPAllUrl;

    @wire(getOpenRPTerritoryUrl) getOpenRPTerritory({error,data}){
        this.openRPTerritoryUrl = data;
        console.log(this.openRPTerritoryUrl);
    }

    @wire(getOpenRPAllUrl) getOpenRPAll({error,data}){
        this.openRPAllUrl = data;
        console.log(this.openRPAllUrl);
    }
}