/*
 * Copyright (c) 2022, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

import { LightningElement, api, track } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import Id from '@salesforce/user/Id';

import confirmAttendeeEventAttendance from '@salesforce/apex/EventOccuranceCtrl.confirmAttendeeEventAttendance';
import createNewEventAttendee from '@salesforce/apex/EventAttendeeCtrl.createNewEventAttendee';

export default class AttendeeInfoView extends LightningElement {

    //----------------------------------------------------------------------------------------------------
    // Variables
    //----------------------------------------------------------------------------------------------------

    //**********************************************************************************************
    // MODAL VARIABLES
    @api currentUserAttending
    @api currentUserAttendeeInfo;
    @api eventId;

    //**********************************************************************************************
    // LOCAL VARIABLES
    @track newAttendeeId;
    @track newSignUpConfirmationStatus = false;
    @track newAttendanceConfirmationStatus = false;

    @track showAttendanceConfirmInput = false;
    @track attendanceConfirmationCode;

    //**********************************************************************************************
    // GETTERS
    get signUpConfirmed() {
        if(this.currentUserAttending === true || this.newAttendeeId != undefined){
            return true;
        }
    }

    get currentUserAttendeeId() {
        if(this.currentUserAttendeeInfo === undefined){
            return this.newAttendeeId; 
        } else { return this.currentUserAttendeeInfo.Id }
    }

    get currentUserSignUpConfirmationStatus() {
        if(this.currentUserAttendeeInfo === undefined){
            return this.newSignUpConfirmationStatus; 
        } else { return this.currentUserAttendeeInfo.SignUpConfirmed }
    }

    get currentUserAttendanceConfirmationStatus() {
        if(this.currentUserAttendeeInfo === undefined){
            return this.newAttendanceConfirmationStatus; 
        } else {
            return this.currentUserAttendeeInfo.AttendanceConfirmed;
        }
    }

    get currentUserAttendanceConfirmButtonDisabled() {
        if( this.currentUserAttendanceConfirmationStatus === true ) {
            return true;    
        } else {
            if( this.currentUserSignUpConfirmationStatus === false ) { 
                return true; 
            }
            else { 
                return false; 
            }
        }
    }

    get cancelSignUpButtonDisabled() {
        return this.currentUserAttendanceConfirmationStatus == true;
    }

    //----------------------------------------------------------------------------------------------------
    // Onclick / Event Handlers
    //----------------------------------------------------------------------------------------------------

    handleUserSignUpClicked() {
        let domainUrl = window.location.protocol + '//' + window.location.hostname;

        createNewEventAttendee({ currentUserId : Id, relatedEventId : this.eventId, currentDomainUrl : domainUrl  })
            .then(trainingEventAttendee => {
                if(trainingEventAttendee !== undefined){
                    this.newAttendeeId = trainingEventAttendee.Id;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Thanks for signing up! Please check your e-mail for confirmation.',
                            variant: 'success',
                        }),
                    );
                } else {
                    this.showGenericErrorHelper();
                }
            })
            .catch(error => {
                console.log(error);
                this.showGenericErrorHelper();
            });
    }


    handleUserCancelSignUpClicked() {
        if(confirm('Are you sure you want to cancel your attendance?')){
            let tempRecordID = this.currentUserAttendeeId;

            deleteRecord(tempRecordID)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'You have sucessfully cancelled your sign up for this event!',
                        variant: 'success',
                    }),
                );

                const deletedEvent = new CustomEvent('attendanceupdated', { detail: tempRecordID });
                this.dispatchEvent(deletedEvent);
            })
            .catch(error => {
                this.showGenericErrorHelper();

                window.console.log(error);
            });
        }
    }

    handleUserAttendanceConfirmationClicked() {
        this.showAttendanceConfirmInput = true;
    }

    attendanceCodeChanged(event) {
        this.attendanceConfirmationCode = event.target.value;
    }

    handleAttendanceCodeSubmitClicked() {
        confirmAttendeeEventAttendance({ eventAttendeeId: this.currentUserAttendeeId, confirmationCode: this.attendanceConfirmationCode })
        .then(result => {

            if(result == true){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'You have sucessfully confirmed your attendance for this event!',
                        variant: 'success',
                    }),
                );
                
                this.showAttendanceConfirmInput = false;
                this.newAttendanceConfirmationStatus = true;

                const updatedEvent = new CustomEvent('attendanceupdated', { detail: this.currentUserAttendeeId });
                this.dispatchEvent(updatedEvent);
            } else {
                this.showGenericErrorHelper();
            }
        })
        .catch(error => {
            this.showGenericErrorHelper();

            window.console.log(error);
        })
    }

    handleAttendanceCodeCancelClicked() {
        this.showAttendanceConfirmInput = false;
    }

    //----------------------------------------------------------------------------------------------------
    // Helpers
    //----------------------------------------------------------------------------------------------------

    showGenericErrorHelper(){
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Something Went Wrong",
                message: "Hmmmm, Looks like something went wrong, please try again!",
                variant: "error"
            }),
        );
    }
}