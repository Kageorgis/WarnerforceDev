import {LightningElement, api} from 'lwc';

export default class DeleteContactConfirmModal extends LightningElement {
    @api visible;

    handleClick(event){
        let finalEvent = {
            status: event.target.name
        };

        this.dispatchEvent(new CustomEvent('click', {detail: finalEvent}));
    }
}