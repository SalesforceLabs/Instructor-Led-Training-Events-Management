import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import TRAINING_EVENT from '@salesforce/schema/Training_Events__c';

export default class EventCreationSection extends LightningElement {

    @track eventObjectData = TRAINING_EVENT;
    @track createNewEventSelected = false;

    handleEventCreation(){
        this.createNewEventSelected = false;
    }

    handleEventFormCancelled(){
        this.createNewEventSelected = false;
    }

    handleNewEventClick() {
        this.createNewEventSelected = true;
    }

    handleFormError(){
        const evt = new ShowToastEvent({
            title: "Something Went Wrong",
            message: "Hmmmm, Looks like something went wrong, please try again!",
            variant: "error"
        });
        this.dispatchEvent(evt);
    }
}