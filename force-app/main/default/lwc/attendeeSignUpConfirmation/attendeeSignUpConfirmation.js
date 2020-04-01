import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { updateRecord } from 'lightning/uiRecordApi';

import ID_FIELD from '@salesforce/schema/Training_Event_Attendee__c.Id';
import SIGN_UP_CONFIRMATION from '@salesforce/schema/Training_Event_Attendee__c.Sign_Up_Confirmed__c';

export default class AttendeeSignUpConfirmation extends LightningElement {

    //----------------------------------------------------------------------------------------------------
    // Variables
    //----------------------------------------------------------------------------------------------------

    //**********************************************************************************************
    // LOCAL VARIABLES

    @track parameters = {};
    @track signUpConfirmed = false;

    //----------------------------------------------------------------------------------------------------
    // HOOKS
    //----------------------------------------------------------------------------------------------------

    connectedCallback() {
        this.parameters = this.getQueryParameters();

        if ('attendeeId' in this.parameters){
            if (this.parameters.attendeeId !== undefined ){

                const fields = {};

                fields[ID_FIELD.fieldApiName] = this.parameters.attendeeId;
                fields[SIGN_UP_CONFIRMATION.fieldApiName] = true;

                const recordInput = { fields };

                updateRecord(recordInput)
                    .then(() => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'You have successfully confirmed your sign up details!',
                                variant: 'success'
                            })
                        );

                        this.signUpConfirmed = true;
                    })
                    .catch(error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Something Went Wrong",
                                message: "Hmmmm, Looks like something went wrong, please try again!",
                                variant: "error"
                            }),
                        );
                    });
            }
        }
    }

    //----------------------------------------------------------------------------------------------------
    // HELPERS
    //----------------------------------------------------------------------------------------------------

    getQueryParameters() {
        var params = {};
        var search = location.search.substring(1);

        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }

        return params;
    }

    checkUserDetails() {

    }
}