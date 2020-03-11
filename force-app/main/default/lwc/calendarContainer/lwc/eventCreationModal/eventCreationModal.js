import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import TRAINING_EVENT_OCCURANCE from '@salesforce/schema/Training_Event_Occurrence__c';


export default class EventCreationModal extends LightningElement {

    //----------------------------------------------------------------------------------------------------
    // Variables
    //----------------------------------------------------------------------------------------------------

    //**********************************************************************************************
    // RECORD VARS
    @api objectData;
    @api selectedDate;

    @track selectedRecordTypeId = '';

    //**********************************************************************************************
    // MODAL VARIABLES
    @api cancelLabel = "Cancel";
    @api hideFooter = false;
    @api saveDisabled = false;
    @api isAttendeeView;
    @api isAdminView;

    //**********************************************************************************************
    // GETTERES
    get recordTypeSelected(){
        return this.selectedRecordTypeId !== '';
    }

    get recordTypeRadioOptions() {
        let uiCombobox = [];

        let recordtypeinfo = this.objectInfo.data.recordTypeInfos;

        for(let eachRecordtype in  recordtypeinfo){
            if(recordtypeinfo.hasOwnProperty(eachRecordtype) && recordtypeinfo[eachRecordtype].name !== 'Master'){
                uiCombobox.push({ label: recordtypeinfo[eachRecordtype].name, value: recordtypeinfo[eachRecordtype].recordTypeId })
            }
        }

        return uiCombobox;
    }

    //**********************************************************************************************
    // WIRES
    @wire(getObjectInfo, { objectApiName: TRAINING_EVENT_OCCURANCE })
    objectInfo

    //----------------------------------------------------------------------------------------------------
    // Onclick / Event Handlers
    //----------------------------------------------------------------------------------------------------

    cancelClickedHandler() {
        this.dispatchEvent(new CustomEvent("cancel"));
    }

    closeClickedHandler() {
        this.closeModalHelper();
    }

    handleEventOccuranceCreation(event){
        this.closeModalHelper();
    }

    handleEventOccuranceFormCancelled() {
        this.closeModalHelper();
    }

    handleFormError(){
        const evt = new ShowToastEvent({
            title: "Something Went Wrong",
            message: "Hmmmm, Looks like something went wrong, please try again!",
            variant: "error"
        });
        this.dispatchEvent(evt);
    }

    handleRecordTypeSelected(event){
        this.selectedRecordTypeId = event.detail.value;
    }

    //----------------------------------------------------------------------------------------------------
    // Helpers
    //----------------------------------------------------------------------------------------------------

    closeModalHelper(){
        this.dispatchEvent(new CustomEvent("close"));
    }
}