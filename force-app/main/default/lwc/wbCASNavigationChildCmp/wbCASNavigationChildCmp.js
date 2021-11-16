import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class WbCASNavigationChildCmp extends NavigationMixin (LightningElement) {
    @api urlAllLabel;
    @api urlMyLabel;
    @api urlAllValue;
    @api urlMyValue;

    navigateToAllList(){
        console.log('this.urlAllValue'+this.urlAllValue);
        console.log(this.urlAllLabel);
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: this.urlAllValue
               
            }
        }).then(generatedUrl => {
            window.open(generatedUrl);
        });
    }

    navigateToTerritoryList(){
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: this.urlMyValue
               
            }
        }).then(generatedUrl => {
            window.open(generatedUrl);
        });
    }
}