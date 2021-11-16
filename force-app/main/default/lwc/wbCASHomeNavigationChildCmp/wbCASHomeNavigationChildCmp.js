import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class WbCASHomeNavigationChildCmp extends NavigationMixin (LightningElement) {

    @api urlAllLabel;
    @api urlAllValue;
   
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
}