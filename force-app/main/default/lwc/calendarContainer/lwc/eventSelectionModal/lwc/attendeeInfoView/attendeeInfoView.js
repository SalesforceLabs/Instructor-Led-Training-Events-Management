import { LightningElement, api, track } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import Id from '@salesforce/user/Id';

import TRAINING_EVENT_ATTENDEE_OBJ from '@salesforce/schema/Training_Event_Attendee__c';
import RELATED_USER from '@salesforce/schema/Training_Event_Attendee__c.Related_User__c';
import RELATED_TRAINING_EVENT_OCC from '@salesforce/schema/Training_Event_Attendee__c.Training_Event_Occurrence__c';

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
        } else { return this.currentUserAttendeeInfo.AttendanceConfirmed }
    }

    get currentUserAttendanceConfirmButtonDisabled() {
        if( this.currentUserAttendanceConfirmationStatus === true ) {
            console.log('ATTENDANCE CONFIEMED');
            return true;    
        } else {
            console.log('ATTENDANCE NOT CONFIEMED');

            if( this.currentUserSignUpConfirmationStatus === false ) { 
                console.log('SIGN UP NOT CONFIEMED');
                return true; 
            }
            else { 
                console.log('SIGN UP CONFIEMED');
                return false; 
            }
        }
    }

    //----------------------------------------------------------------------------------------------------
    // Onclick / Event Handlers
    //----------------------------------------------------------------------------------------------------

    handleUserSignUpClicked() {
        const fields = {};

        fields[RELATED_USER.fieldApiName] = Id;
        fields[RELATED_TRAINING_EVENT_OCC.fieldApiName] = this.eventId;

        const recordInput = { apiName: TRAINING_EVENT_ATTENDEE_OBJ.objectApiName, fields };

        createRecord(recordInput)
            .then(trainingEventAttendee => {
                this.newAttendeeId = trainingEventAttendee.id;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Thanks for signing up! Please check your e-mail for confirmation.',
                        variant: 'success',
                    }),
                );
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

                const deletedEvent = new CustomEvent('attendanceremoved', { detail: tempRecordID });
                this.dispatchEvent(deletedEvent);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Something Went Wrong",
                        message: "Hmmmm, Looks like something went wrong, please try again!",
                        variant: "error"
                    }),
                );

                window.console.log(error)
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
        
    }

    handleAttendanceCodeCancelClicked() {
        this.showAttendanceConfirmInput = false;
    }
}