import { LightningElement, api } from 'lwc';

export default class ListViewItem extends LightningElement {

    @api currentEvent;

    handleShowMoreClicked(){
        const showMoreEvent = new CustomEvent('showmoreclicked', { detail: this.currentEvent });
        this.dispatchEvent(showMoreEvent);
    }
}