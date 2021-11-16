import { LightningElement, wire, api, track } from 'lwc';
import Name from '@salesforce/schema/Contact.Name';
import Email from '@salesforce/schema/Contact.Email';
import Phone from '@salesforce/schema/Contact.Phone';
import { NavigationMixin } from 'lightning/navigation';
import getRelatedContactsForListView from '@salesforce/apex/ContactController.getRelatedContactsForListView';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import importStandardURL from '@salesforce/label/c.importStandardURL';
import WBCP_UserRole from '@salesforce/schema/User.WBCP_Access_Role__c';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';


const actions = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }
];

const COLUMNS = [
    { label: 'Name', fieldName: 'redirectURLContName', type: 'url', typeAttributes: {
        label: { fieldName: Name.fieldApiName},
        target: '_self'}
    },
    { label: 'Account Name', fieldName: 'redirectURLAccName', type: 'url', sortable: true, typeAttributes: {
        label: { fieldName: 'AccountName'},
        target: '_self'},
    },
    { label: 'Territories', fieldName: 'Territories', type: 'text' , sortable: true},
    { label: 'Phone', fieldName: Phone.fieldApiName, type: 'phone'},
    { label: 'Email', fieldName: Email.fieldApiName, type: 'email' },
    { label: 'Contact Owner', fieldName: 'OwnerName', type: 'text' , sortable: true},
    { type: 'action', typeAttributes: { rowActions: actions, menuAlignment: 'auto' } }
];

export default class ContactListView extends NavigationMixin(LightningElement) {
    @api contactRecs = [];
    @track columns = COLUMNS;
    @track isLoaded = false;
    @track isUserRoleNotRegLocal = false;
    @wire(getRecord, {recordId: USER_ID, fields: [WBCP_UserRole]})
    wireuser({error,data}) {
        console.log('data:::',data)
        if (data !== undefined && data.fields !== undefined && (data.fields.WBCP_Access_Role__c.value === 'Regional' || data.fields.WBCP_Access_Role__c.value === 'Local')){
            this.isUserRoleNotRegLocal = true;
        }else{
            this.isUserRoleNotRegLocal = false;
        }
    }

    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    @api accName;
    @api isDialogVisible = false;
    @api getRelatedContactsForListViewResult;

    @wire(getRelatedContactsForListView)
    getRelatedContactsForListView(result) {
        this.getRelatedContactsForListViewResult = result
        if(result.data) {
            if(result.data.length != this.contactRecs.length){
                this.contactRecs = JSON.parse(JSON.stringify(result.data));
                for(let i=0; i<this.contactRecs.length; i++){
                    this.contactRecs[i].redirectURLContName = '/lightning/r/'+this.contactRecs[i].Id+'/view';
                    this.contactRecs[i].redirectURLAccName = '/lightning/r/'+this.contactRecs[i].AccountId+'/view';
                    this.contactRecs[i].AccountName = this.contactRecs[i].Account.Name;
                    this.contactRecs[i].Territories = this.contactRecs[i].CP_Territory__c === undefined ? "" : this.contactRecs[i].CP_Territory__c;
                    this.contactRecs[i].OwnerName = this.contactRecs[i].Owner.Name;
                    this.error = undefined;
                }
                this.isLoaded = true;
            }
        } else if(result.error) {
            this.error = result.error;
            this.contactRecs = undefined;
        }
    }

    connectedCallback(){
        this._interval = setInterval(() => {
            getRelatedContactsForListView()
            .then(data => {
                console.log('data.length:::',data.length,':::this.contactRecs.length:::',this.contactRecs.length);
                if(data.length != this.contactRecs.length){
                    return refreshApex(this.getRelatedContactsForListViewResult);
                }
            }).catch(error => {
                this.error = error;
                this.contactRecs = undefined;
            })
        }, 5000);
    }

    createContactAction() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Contact',
                actionName: 'new'
            },
            state: {
                useRecordTypeCheck: 1,
                navigationLocation: 'RELATED_LIST'
            }
        });
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.contactRecs];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.contactRecs = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    sortBy(field, reverse, primer) {
        field = field === 'redirectURLAccName' ? 'AccountName' : field;
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };
        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a.toLowerCase() > b.toLowerCase()) - (b.toLowerCase() > a.toLowerCase()));
        };
    }

    sendEmailMeth() 
    {
        var contactData = {};
        (this.template.querySelector('lightning-datatable').getSelectedRows()).forEach(function(contactRec){
            if(contactRec.Email !== undefined){
                contactData[contactRec.Email]= contactRec.Id;
            }
        });
        const urlWithParameters = '/apex/sendEmailPage?mapContactEmailId='+JSON.stringify(contactData);
        console.log('urlWithParameters...'+urlWithParameters);
        this[NavigationMixin.Navigate]({
        type: 'standard__webPage',
        attributes: {
        url: urlWithParameters
        }
        }, false); //if you set true this will opens the new url in same window
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const rowId = event.detail.row.Id;
        switch (action.name) {
            case 'edit':
                this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        recordId: rowId,
                        objectApiName: 'Contact',
                        actionName: 'edit'
                    }
                });
                break;
            case 'delete':
                this.isDialogVisible = true;
                this.deleteRecordId = rowId;
                break;
        }
    }

    handleClick(event){
        if(event.target !== undefined && event.target.name === 'deleteCompModal'){
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
                        return refreshApex(this.getRelatedContactsForListViewResult);
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

    redirectToImportPage(){
       this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": importStandardURL
            }
        });
    }
}