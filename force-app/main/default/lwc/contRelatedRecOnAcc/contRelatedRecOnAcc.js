import { LightningElement, api, wire, track } from 'lwc';
import getRelatedContacts from '@salesforce/apex/ContactController.getRelatedContacts';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';

const cardTitleContact = 'Contacts '

export default class ContRelatedRecOnAcc extends NavigationMixin(LightningElement) {
    @api recordId;
    @api getRelatedContactsResult;
    @api contactRecs = [];
    @api showContactRecs = [];
    @api recordTypeIdValue;
    @api cardTitle = cardTitleContact+'(0)';
    @api showSearchComponentFlag = false;
    @api deleteRecordId;
    @api isDialogVisible = false;
    @api isViewAllProp = false;

    @wire(getRecord, { recordId: '$recordId', fields: ['Account.Name'] })//,'Account.Id'] })
    accountInfo;

    @wire(getRelatedContacts,{accountIdValue : '$recordId'})
    getRelatedContacts(result) {
        this.getRelatedContactsResult = result
        console.log('result:::'+result);
        if(result.data) {
            console.log('cardTitle:::'+this.cardTitle);
            if(result.data === undefined || result.data.length == 0){
                this.error = 'No Contact Records Found';
            }else{
                this.contactRecs = JSON.parse(JSON.stringify(result.data));
                this.cardTitle = cardTitleContact+'('+this.contactRecs.length+')';
                if(this.contactRecs.length > 6){
                    this.cardTitle = cardTitleContact+'(6+)';
                }
                for(let i=0; i<this.contactRecs.length; i++){
                    this.contactRecs[i].redirectURL = '/lightning/r/'+this.contactRecs[i].Id+'/view';
                    if(i<6){
                        this.showContactRecs[i] = this.contactRecs[i];
                    }
                    this.error = undefined;
                }
            }
        } else if(result.error) {
            this.error = result.error;
            this.contactRecs = undefined;
        }
    }

    connectedCallback() {
        this._interval = setInterval(() => {
            getRelatedContacts({ accountIdValue : this.accountRecordId })
            .then(data => {
                if(data.length != this.contactRecs.length){
                    return refreshApex(this.getRelatedContactsResult);
                }
            }).catch(error => {
                this.error = error;
                this.contactRecs = undefined;
            })
        }, 5000);
    }
    showcreateContactComponent() {
        this.showSearchComponentFlag = true;
    }

    handleChildEvent(event){
        this.showSearchComponentFlag = false;
        console.log(':::event.detail.closeValue:::'+event.detail.closeValue);
        //console.log(':::event.detail.recordTypeIdValue:::'+event.detail.recordTypeIdValue);
        if(!event.detail.closeValue){
            //this.recordTypeIdValue = event.detail.recordTypeIdValue;
            this.createContactAction();
        }
    }

    createContactAction() {
        const defaultValues = encodeDefaultFieldValues({
            AccountId : this.recordId
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
        //return refreshApex(this.getRelatedContactsResult);
        //eval("$A.get('e.force:refreshView').fire();");
    }

    editContactAction(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                recordId: event.target.value,
                objectApiName: 'Contact',
                actionName: 'edit'
            }
        });
    }

    handleClick(event){
        if(event.target !== undefined){
            if(event.target.name === 'deleteAction'){
                this.isDialogVisible = true;
                this.deleteRecordId = event.target.value;
                //console.log('deleteRecordId:::'+this.deleteRecordId);
            }else if(event.target.name === 'deleteCompModal'){
                if(event.detail !== 1){
                    if(event.detail.status === 'delete') {
                        deleteRecord(this.deleteRecordId)
                        .then(() => {
                            const event = new ShowToastEvent({
                                title: 'Success',
                                message: 'Record deleted',
                                variant: 'success'
                            });
                            this.dispatchEvent(event);
                            refreshApex(this.getRelatedContactsResult);
                        })
                        .catch(error => {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error deleting record',
                                    message: error.body.message,
                                    variant: 'error'
                                })
                            );
                        });
                    }
                    this.deleteRecordId = '';
                    this.isDialogVisible = false;
                }
            }
        }
    }

    //If new component will get open
    handleNavigate() {
        if(this.recordId != undefined){
            var compDefinition = {
                componentDef: "c:contRelatedRecsDataTable",
                attributes: {
                    contactRecs: this.contactRecs,
                    accountRecordId: this.accountInfo.data.id,
                    accName: this.accountInfo.data.fields.Name.value
                }
            };
            // Base64 encode the compDefinition JS object
            var encodedCompDef = btoa(JSON.stringify(compDefinition));
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/one/one.app#' + encodedCompDef
                }
            });
        }
    }

    handleViewAll(){
        this.isViewAllProp = true;
    }
}