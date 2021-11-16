import { LightningElement,track,wire } from 'lwc';
import getTentativeCATerritoryUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getTentativeCATerritoryUrl';
import getTentativeCAAllUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getTentativeCAAllUrl';

export default class WbCASTentativeCAReportCmp extends LightningElement {
    @track tentativeCATerritoryUrl;
    @track tentativeCAAllUrl;

    @wire(getTentativeCATerritoryUrl) getTentativeCATerritory({error,data}){
        this.tentativeCATerritoryUrl = data;
        console.log(this.tentativeCATerritoryUrl);
    }

    @wire(getTentativeCAAllUrl) getTentativeCAAll({error,data}){
        this.tentativeCAAllUrl = data;
        console.log(this.tentativeCAAllUrl);
    }
}