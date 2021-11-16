import { LightningElement,track,wire } from 'lwc';
import getTentativeRPTerritoryUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getTentativeRPTerritoryUrl';
import getTentativeRPAllUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getTentativeRPAllUrl';

export default class WbCASTentativeRPForActionReportCmp extends LightningElement {
    @track tentativeRPTerritoryUrl;
    @track tentativeRPAllUrl;

    @wire(getTentativeRPTerritoryUrl) getTentativeRPTerritory({error,data}){
        this.tentativeRPTerritoryUrl = data;
        console.log(this.tentativeRPTerritoryUrl);
    }

    @wire(getTentativeRPAllUrl) getTentativeRPAll({error,data}){
        this.tentativeRPAllUrl = data;
        console.log(this.tentativeRPAllUrl);
    }
}