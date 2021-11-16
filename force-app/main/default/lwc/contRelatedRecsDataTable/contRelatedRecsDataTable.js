import { LightningElement, wire, api, track } from 'lwc';
import Name from '@salesforce/schema/Contact.Name';
import Title from '@salesforce/schema/Contact.Title';
import Email from '@salesforce/schema/Contact.Email';
import Phone from '@salesforce/schema/Contact.Phone';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { NavigationMixin } from 'lightning/navigation';
import getRelatedContacts from '@salesforce/apex/ContactController.getRelatedContacts';

const COLUMNS = [
    { label: 'Contact Name', fieldName: 'redirectURL', type: 'url', typeAttributes: {
        label: { fieldName: Name.fieldApiName},
        target: '_self'}
    },
    { label: 'Title', fieldName: Title.fieldApiName, type: 'text' },
    { label: 'Email', fieldName: Email.fieldApiName, type: 'email' },
    { label: 'Phone', fieldName: Phone.fieldApiName, type: 'phone' }
];

export default class ContRelatedRecsDataTable extends NavigationMixin(LightningElement) {
    @api viewallprop;
    @api accountRecordId;
    @api contactRecs;
    @track columns = COLUMNS;
    @track isLoaded = true;
    @api accName;
    accNavURL = "/lightning/r/";

    /*
    @wire(getRelatedContacts,{accountIdValue : this.accountRecordId})
    getRelatedContacts({ error, data }) {
        console.log('data:::'+JSON.stringify(data)+':::error:::'+error);
        console.log('columns:::'+JSON.stringify(this.columns));
        if (data) {
            this.contactRecs = JSON.parse(JSON.stringify(data));
            this.cardTitle = cardTitleContact+'('+this.contactRecs.length+')';
            for(let i=0; i<this.contactRecs.length; i++){
                this.contactRecs[i].redirectURL = '/lightning/r/'+this.contactRecs[i].Id+'/view';
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.contactRecs = undefined;
        }
    }
    */
    connectedCallback(){
        if(this.accountRecordId != undefined){
            console.log('In If'+this.accountRecordId);
            this.accNavURL = this.accNavURL + this.accountRecordId+"/view";
            this._interval = setInterval(() => {
                console.log('In If 2');
                getRelatedContacts({ accountIdValue : this.accountRecordId })
                .then(data => {
                    console.log('In If 3');
                    if(data.length != this.contactRecs.length){
                        this.contactRecs = JSON.parse(JSON.stringify(data));
                        for(let i=0; i<this.contactRecs.length; i++){
                            this.contactRecs[i].redirectURL = '/lightning/r/'+this.contactRecs[i].Id+'/view';
                            this.error = undefined;
                        }
                        //return refreshApex(this.getRelatedContactsResult);
                    }
                }).catch(error => {
                    console.log('In If 4');
                    this.error = error;
                    this.contactRecs = undefined;
                })
            }, 5000);
            /*getRelatedContacts({ accountIdValue : this.accountRecordId })
            .then(data => {
                this.contactRecs = JSON.parse(JSON.stringify(data));
                this.cardTitle = cardTitleContact+'('+this.contactRecs.length+')';
                for(let i=0; i<this.contactRecs.length; i++){
                    this.contactRecs[i].redirectURL = '/lightning/r/'+this.contactRecs[i].Id+'/view';
                }
                this.error = undefined;
                this.isLoaded = true;
            })
            .catch(error => {
                this.error = error;
                this.contactRecs = undefined;
            })*/
        }
    }

    createContactAction() {
        const defaultValues = encodeDefaultFieldValues({
            AccountId : this.accountRecordId
        });
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Contact',
                actionName: 'new'
            },
            state: {
                useRecordTypeCheck: 1,
                defaultFieldValues: defaultValues,
                navigationLocation: 'RELATED_LIST'
            }
        });
    }
}