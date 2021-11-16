/* eslint-disable no-unused-vars */
/* eslint-disable no-console */
import { LightningElement, track, wire, api } from 'lwc';
import getTopicList from '@salesforce/apex/CRM_TopicsListController.getTopicList';

const columns = [{ label: 'Topic Name', fieldName: 'recordLink', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } }];
const DELAY = 400;

export default class CrmTopicsList extends LightningElement {
    @track searchText = '';
    @track columns = columns;
    @track topics = [];
    @track error;
    @track loaded;
    @api compHeight;

    handleFilterChange(event) {
        window.clearTimeout(this.delayTimeout);
        const searchText = event.target.value;
        if (!searchText.isBlank) {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.delayTimeout = setTimeout(() => {
                this.searchText = searchText;
            }, DELAY);
        }
        this.loaded = false;
    }

    @wire(getTopicList, { searchText: '$searchText' })
    wiredTopics({ error, data }) {
        if (data) {
            let records = data.map(obj => ({ ...obj, recordLink: "/lightning/r/Topic/" + obj.Id + "/view" }))
            this.topics = records;
            this.loaded = true;
        }
        this.error = error;
    }

    get componentHeight() {
        this.compHeight = this.compHeight || 200;

        console.log("Component Height is -> "+this.compHeight);
        return `height: ${this.compHeight}px;`
        
    }
}