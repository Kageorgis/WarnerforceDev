/* eslint-disable no-console */
import { LightningElement, api } from 'lwc';

export default class CrmDynamicCalendar extends LightningElement {
    @api recordId;
    @api calendarIds;
    @api calHeight;

    get calendarFrameURL() {
        console.log("this.recordKey-->"+this.recordId);
        console.log("this.calendarIds-->"+this.calendarIds);
        return encodeURI(`/apex/CRM_DynamicCalendar?recKey=${this.recordId}&caIds=${this.calendarIds}`);
    }

}