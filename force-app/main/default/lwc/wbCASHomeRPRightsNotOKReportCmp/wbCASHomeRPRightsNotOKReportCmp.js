import { LightningElement,track,wire } from 'lwc';
import getRightsCheckRPAllUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getRightsCheckRPAllUrl';

export default class WbCASHomeRPRightsNotOKReportCmp extends LightningElement {
    @track rightsCheckRPAllUrl;

    @wire(getRightsCheckRPAllUrl) getRightsCheckRPAll({error,data}){
        this.rightsCheckRPAllUrl = data;
        console.log(this.rightsCheckRPAllUrl);
    }
}