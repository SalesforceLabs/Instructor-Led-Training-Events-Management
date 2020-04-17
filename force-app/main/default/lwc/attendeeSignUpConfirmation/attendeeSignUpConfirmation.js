import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import confirmAttendeeSignUp from '@salesforce/apex/EventAttendeeCtrl.confirmAttendeeSignUp';

export default class AttendeeSignUpConfirmation extends LightningElement {

    //----------------------------------------------------------------------------------------------------
    // Variables
    //----------------------------------------------------------------------------------------------------

    //**********************************************************************************************
    // LOCAL VARIABLES

    @track parameters = {};
    @track signUpConfirmed = false;
    @track showNoRecordsMessage = false;

    //----------------------------------------------------------------------------------------------------
    // HOOKS
    //----------------------------------------------------------------------------------------------------

    connectedCallback() {
        this.parameters = this.getQueryParameters();

        if ('c__attendeeId' in this.parameters){
            if (this.parameters.c__attendeeId !== undefined ){
                this.checkUserDetails(this.parameters.c__attendeeId);
            } else {
                this.signUpConfirmed = true;
                this.showNoRecordsMessage = true;
            }
        } else {
            this.signUpConfirmed = true;
            this.showNoRecordsMessage = true;
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

    checkUserDetails(attendeeRecordId) {
        confirmAttendeeSignUp({ attendeeRecordId : attendeeRecordId })
            .then(result => {
                if(result.signUpAlreadyConfirmed === true){
                    this.signUpConfirmed = true;
                } 
                if(result.signUpConfirmed === true){
                    this.showSuccessMessage();
                    this.signUpConfirmed = true;
                } 
                if(result.noRecordFound === true){
                    this.signUpConfirmed = true;
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