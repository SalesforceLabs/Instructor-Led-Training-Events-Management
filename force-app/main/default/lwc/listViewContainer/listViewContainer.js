/*
 * Copyright (c) 2022, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

import { LightningElement, track, api, wire } from 'lwc';
import getListViewData from '@salesforce/apex/ListViewCtrl.getListViewData';
import { refreshApex } from '@salesforce/apex';

import TRAINING_EVENT_OCCURANCE from '@salesforce/schema/Training_Event_Occurrence__c';

export default class ListViewContainer extends LightningElement {

    //----------------------------------------------------------------------------------------------------
    // Variables
    //----------------------------------------------------------------------------------------------------

    //**********************************************************************************************
    // Display + Org Data
    @track allEvents;
    @track myEvents;

    @track showAllEvents = true;
    @track showMyEvents = false;

    wiredReference;

    objectData = {
        apiName: TRAINING_EVENT_OCCURANCE.objectApiName,
        schemaData : TRAINING_EVENT_OCCURANCE,
        fields: {
            
        }
    }; 

    //**********************************************************************************************
    // Date Variables
    @track todaysDate = new Date();                      // the current date
    @track currentMonth = this.todaysDate.getMonth();    // selected month
    @track currentYear = this.todaysDate.getFullYear();  // selected year

    @track showDateSelection = false;   // allow users to input date options 

    //**********************************************************************************************
    // Modal Variables
    @track showEventSelectModal = false;    // used to determine whther or not to show the event select modal
    @track showEventCreateModal = false;    // used to determine whther or not to show the event create modal
    @track modalSelectionType = 'event';    // used to determine what type of modal to show (either a single event or events)
    @track modalData;                       // the data to be passed to the modal
    @track changedRecordId = '';            // will be updated when a child cmp changed a record

    //**********************************************************************************************
    // Design attributes
    @api allowEventCreation = false;
    @api isAdminView = false;
    @api isAttendeeView = false;

    //**********************************************************************************************
    // Getters
    get monthVarString() { return this.currentMonth.toString(10); }
    get yearVarString() { return this.currentYear.toString(10); }

    get allEventsClass(){ 
        if( this.showAllEvents === true ){
            return 'item item-selected';
        } else {
            return 'item item-not-selected';
        }
    }

    get myEventsClass(){ 
        if( this.showMyEvents === true ){
            return 'item item-selected';
        } else {
            return 'item item-not-selected';
        }
    }

    get showMyEventsList() {
        if(this.myEvents !== undefined){ return this.myEvents.length > 0; }
        else { return false; }
    }

    get showAllEventsList() {
        if(this.allEvents !== undefined){ return this.allEvents.length > 0; }
        else { return false; }
    }

    //**********************************************************************************************
    // Wire Variables

    @wire(getListViewData, { 
        currentMonth: '$currentMonth',
        currentYear: '$currentYear',
        isAdminView: '$isAdminView',
        isAttendeeView: '$isAttendeeView',
    })
    wiredData(value) {
        this.wiredReference = value;
        const { data, error } = value;

        if(data){
            this.allEvents = data.allEvents;
            this.myEvents = data.myEvents;
        } else if(error) {
            console.log(error);
        }
    }


    //----------------------------------------------------------------------------------------------------
    // Onclick / Event Handlers
    //----------------------------------------------------------------------------------------------------

    //**********************************************************************************************
    // Date Handlers
    handleTodayClicked(){ // When the reset to today button is clicked in a child cmp
        this.setCurrentDateToToday();
    }

    handleDisplayDateClicked(){ // When the user clicks the date from a child cmp
        this.showDateSelection = !this.showDateSelection;
    }

    handleCloseDateSelection(){ // When the cancel button is clicked from the child date filter cmp
        this.showDateSelection = false;
    }

    handleMonthSelectionChange(event) { // When a child cmp changes the date
        this.currentMonth = event.detail;
    }

    handleYearSelectionChange(event){ // When a child cmp changes the year
        this.currentYear = event.detail;
    }

    //**********************************************************************************************
    // Button Handlers
    handleShowAllEventsClicked(){
        this.showMyEvents = false;
        this.showAllEvents = true;
    }

    handleShowMyEventsClicked(){
        this.showMyEvents = true;
        this.showAllEvents = false;
    }

    //**********************************************************************************************
    // Modal Handlers
    handleShowMoreClicked(event) { // When an event is selected
        this.modalData = event.detail;
        this.openEventSelectModalHelper();
    }

    handleCloseEventSelectModal() { // When the event selection modal close is called by a child
        this.closeEventSelectModalHelper();
    }

    handleCreateNewEventClicked() { // When the user clicks on a date on the calendar
        this.openEventCreateModalHelper();
    }

    handleCloseEventCreateModal() {  // When the event creation modal close is called by a child
        this.closeEventCreateModalHelper();
    }

    handleRecordChanged() { // When a childs record changes
        this.refreshDataHelper();
    }

    //----------------------------------------------------------------------------------------------------
    // Helpers
    //----------------------------------------------------------------------------------------------------

    setCurrentDateToToday() {
        this.currentMonth = this.todaysDate.getMonth();
        this.currentYear = this.todaysDate.getFullYear(); 
    }

    openEventSelectModalHelper() {
        this.showEventSelectModal = true;
    }

    closeEventSelectModalHelper() {
        this.showEventSelectModal = false;
    }

    openEventCreateModalHelper() {
        this.showEventCreateModal = true;
    }

    closeEventCreateModalHelper() {
        this.refreshDataHelper();
        this.showEventCreateModal = false;
    }

    refreshDataHelper(){
        return refreshApex(this.wiredReference);
    }
}