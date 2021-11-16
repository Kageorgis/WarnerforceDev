import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import HideLightningHeader from '@salesforce/resourceUrl/HideLightningHeader';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import getTabsMetaData from '@salesforce/apex/NavigationUtilityClass.getTabsMetaData';

export default class NavigationUtility extends NavigationMixin(LightningElement) {

    connectedCallback() {
       loadStyle(this, HideLightningHeader)
    }

    @track tabDataInfo;
    @wire(getTabsMetaData) wrapperData({error,data}){
       //console.log(wrapperData);
       this.tabDataInfo=data;
       // this.error=error;
    }

}