import { LightningElement,track,wire } from 'lwc';
import getRightsCheckRPTerritoryUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getRightsCheckRPTerritoryUrl';
import getRightsCheckRPAllUrl from '@salesforce/apex/WB_PageReferenceCreationGridURL.getRightsCheckRPAllUrl';

export default class WbCASRPRightsNotOKReportCmp extends LightningElement {
    @track rightsCheckRPTerritoryUrl;
    @track rightsCheckRPAllUrl;

    @wire(getRightsCheckRPTerritoryUrl) getRightsCheckRPTerritory({error,data}){
        this.rightsCheckRPTerritoryUrl = data;
        console.log(this.rightsCheckRPTerritoryUrl);
    }

    @wire(getRightsCheckRPAllUrl) getRightsCheckRPAll({error,data}){
        this.rightsCheckRPAllUrl = data;
        console.log(this.rightsCheckRPAllUrl);
    }
}