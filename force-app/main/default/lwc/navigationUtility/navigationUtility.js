import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import HideLightningHeader from '@salesforce/resourceUrl/HideLightningHeader';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import getTabsMetaData from '@salesforce/apex/NavigationUtilityClass.getTabsMetaData';

export default class NavigationUtility extends NavigationMixin(LightningElement) {

    connectedCallback() {
       loadStyle(this, HideLightningHeader)
    }

    /*navigateToRepriceWizard(){
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Re_Price_Wizard'
            }
        });
    }

    navigateToPriceUpdateWizard(){
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Price_Update_Wizard'
            }
        });
    }

    navigateToAnnouncementTypes(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Announcement_Rule__c',
                actionName: 'home'
            }
        });
    }

    navigateToWBGrid(){
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'WB_Grid'
            }
        });
    }

    navigateToEarliestAvailDates(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Earliest_Avail_Date__c',
                actionName: 'home'
            }
        });
    }

    navigateToTitleGroups(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Title_Group__c',
                actionName: 'home'
            }
        });
    }

    navigateToEADMaintenance(){
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'EAD_Maintenance'
            }
        });
    }

    navigateToCACreationStatus(){
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Client_Avails_Creation_Status'
            }
        });
    }

    navigateToRateCards(){
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Rate_Cards'
            }
        });
    }

    navigateToEADMaintenance(){
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'EAD_Maintenance'
            }
        });
    }*/
    @track tabDataInfo;
    @wire(getTabsMetaData) wrapperData({error,data}){
       //console.log(wrapperData);
       this.tabDataInfo=data;
       // this.error=error;
    }

}