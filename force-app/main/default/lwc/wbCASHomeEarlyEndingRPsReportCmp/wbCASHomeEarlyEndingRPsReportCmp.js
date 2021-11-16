import { LightningElement,track,wire } from 'lwc';
import getEarlyEndingRPAllUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getEarlyEndingRPAllUrl';

export default class WbCASHomeEarlyEndingRPsReportCmp extends LightningElement {
    @track earlyEndingRPAllUrl;

    @wire(getEarlyEndingRPAllUrl) getEarlyEndingRPAll({error,data}){
        this.earlyEndingRPAllUrl = data;
        console.log(this.earlyEndingRPAllUrl);
    }
}