/*
 * Copyright (c) 2022, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import TRAINING_EVENT from '@salesforce/schema/Training_Events__c';

export default class EventCreationSection extends LightningElement {

    @track eventObjectData = TRAINING_EVENT;
    @track createNewEventSelected = false;

    handleEventCreation(){
        this.createNewEventSelected = false;

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'You have sucessfully created a new event!',
                variant: 'success',
            }),
        );
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