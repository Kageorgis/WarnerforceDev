import { LightningElement,track,wire } from 'lwc';
import getTitleAllUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getTitleAllUrl';
import getTitleTerritoryUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getTitleTerritoryUrl';

export default class WbCASTitlesToClearReportCmp extends LightningElement {
    @track titleAllUrl;
    @track titleTerritoryUrl

    @wire(getTitleAllUrl) getTitleAll({error,data}){
        this.titleAllUrl = data;
        console.log(this.titleAllUrl);
    }

    @wire(getTitleTerritoryUrl) getTitleTerritory({error,data}){
        this.titleTerritoryUrl = data;
        console.log(this.titleTerritoryUrl);
    }

    
}