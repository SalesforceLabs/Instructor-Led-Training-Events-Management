/*
 * Copyright (c) 2022, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import confirmAttendeeSignUp from '@salesforce/apex/EventAttendeeCtrl.confirmAttendeeSignUp';

export default class AttendeeSignUpConfirmation extends LightningElement {

    //----------------------------------------------------------------------------------------------------
    // Variables
    //----------------------------------------------------------------------------------------------------

    //**********************************************************************************************
    // LOCAL VARIABLES

    @track pageRef;
    
    @track isLoading = true;
    @track signUpConfirmed = false;

    // WIRE VARIABLES
    @wire(CurrentPageReference)
    wiredPageRef(pageRef) {
        if (pageRef) {
            this.pageRef = pageRef;

            if (pageRef.state.c__attendeeId) {
                this.checkUserDetails(decodeURIComponent(pageRef.state.c__attendeeId));
            } else {
                this.isLoading = false;
                this.showNoRecordsMessage = true;
            }
        }
    }

    //----------------------------------------------------------------------------------------------------
    // HELPERS
    //----------------------------------------------------------------------------------------------------

    checkUserDetails(attendeeRecordId) {
        confirmAttendeeSignUp({ attendeeRecordId : attendeeRecordId })
            .then(result => {
                if(result.signUpAlreadyConfirmed === true){
                    this.isLoading = false;
                } 
                if(result.signUpConfirmed === true){
                    this.showSuccessMessage();
                    this.isLoading = false;
                } 
                if(result.noRecordFound === true){
                    this.isLoading = false;
                    this.showNoRecordsMessage = true;
                }
            })
            .catch(error => {
                this.showErrorMessage();
                console.log(error);
            });
    }

    showSuccessMessage(){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'You have successfully confirmed your sign up details!',
                variant: 'success'
            })
        );
    }

    showErrorMessage() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Something Went Wrong",
                message: "Hmmmm, Looks like something went wrong, please try again!",
                variant: "error"
            }),
        );
    }
}