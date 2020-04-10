import { LightningElement, track, api, wire } from 'lwc';
import getCalendarData from '@salesforce/apex/CalendarCtrl.getCalendarData';
import { refreshApex } from '@salesforce/apex';

import TRAINING_EVENT_OCCURANCE from '@salesforce/schema/Training_Event_Occurrence__c';

export default class CalendarContainer extends LightningElement {

    //----------------------------------------------------------------------------------------------------
    // Variables
    //----------------------------------------------------------------------------------------------------

    //**********************************************************************************************
    // Constant values
    daysOfWeekList = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];                                      // months array that holds names of the days (can be changed)

    //**********************************************************************************************
    // Display + Org Data
    @track calendarData;                // calendar data that is sent back to the html
    @track salesforceRecords;           // sf data that is returned from the org

    wiredReference;

    objectData = {
        apiName: TRAINING_EVENT_OCCURANCE.objectApiName,
        schemaData : TRAINING_EVENT_OCCURANCE,
        fields: {
            
        }
    }; 

    //**********************************************************************************************
    // Modal Variables
    @track showEventSelectModal = false;    // used to determine whther or not to show the event select modal
    @track showEventCreateModal = false;    // used to determine whther or not to show the event create modal
    @track modalSelectionType = 'events';   // used to determine what type of modal to show (either a single event or events)
    @track modalData;                       // the data to be passed to the modal
    @track changedRecordId = '';            // will be updated when a child cmp changed a record

    //**********************************************************************************************
    // Date Variables
    @track todaysDate = new Date();                      // the current date
    @track currentMonth = this.todaysDate.getMonth();    // selected month
    @track currentYear = this.todaysDate.getFullYear();  // selected year

    @track showDateSelection = false;   // allow users to input date options 

    //**********************************************************************************************
    // Design attributes
    @api showOnlyMyRecords = false;
    @api allowEventCreation = false;
    @api isAdminView = false;
    @api isAttendeeView = false;

    //**********************************************************************************************
    // Getters
    get monthVarString() { return this.currentMonth.toString(10); }
    get yearVarString() { return this.currentYear.toString(10); }

    //**********************************************************************************************
    // Wire Variables
    @wire(getCalendarData, { 
        showUserRecordsOnly: '$showOnlyMyRecords',
        currentMonth: '$currentMonth',
        currentYear: '$currentYear',
        changedRecordId: '$changedRecordId',
    })
    wiredData(value) {
        this.wiredReference = value;
        const { data, error } = value;

        if(data){
            // get data and render cal
            this.salesforceRecords = data;
            this.renderCalHelper();
        } else if(error) {
            window.console.log(error);
            this.calendarData = undefined;
        }
    }



    //----------------------------------------------------------------------------------------------------
    // Hooks
    //----------------------------------------------------------------------------------------------------

    connectedCallback() {
        this.renderCalHelper();
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
    // Modal Handlers
    handleOpenEventSelectModal(event) { // When an event is selected
        this.modalSelectionType = event.detail.type;
        this.modalData = event.detail.modalData;
        this.openEventSelectModalHelper();
    }

    handleCloseEventSelectModal() { // When the event selection modal close is called by a child
        this.closeEventSelectModalHelper();
    }

    handleEventDateClicked() { // When the user clicks on a date on the calendar
        this.openEventCreateModalHelper();
    }

    handleCloseEventCreateModal() {  // When the event creation modal close is called by a child
        this.closeEventCreateModalHelper();
    }

    handleForceRefreshData(){ // When a child wants data updated
        this.refreshDataHelper();
    }

    handleRecordChanged(event){ // When a childs record changes
        this.changedRecordId = event.detail;
    }
    
    //----------------------------------------------------------------------------------------------------
    // Helpers
    //----------------------------------------------------------------------------------------------------

    renderCalHelper() { // Used to avoid passing params from the wire and also so that we can all from the connected callback
        this.renderCalendar(this.currentMonth, this.currentYear); 
    }

    refreshDataHelper(){
        return refreshApex(this.wiredReference);
    }

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

    /**
        @description: Used to create data for a calendar to be displayed on the screen
        @param: month - the month which you want to render
        @param: year - the year which you want to render
    */
    renderCalendar(month, year) {
        this.calendarData = []; // The data we are returning to the the html

        let daysInMonth = 32 - new Date(year, month, 32).getDate();             // How many days are in the current month?
        let firstDayOfMonth = new Date(year, month, 1);                         // What is the first day of the month?
        let firstDayNum = firstDayOfMonth.getDay();                             // The first day of the month as a number
        let lastDayOfMonth = new Date(year, month + 1 , 0);                     // What is the last day of the month?
        let cellsUsed = firstDayOfMonth.getDay() + lastDayOfMonth.getDate();    // How many cells are used by the data?
        let numRows = Math.ceil( cellsUsed / 7);                                // How many rows are displayed in the cal.

        let cellId = 0;                         // Cell Id - Used for rendering a list
        let currentCellDate = firstDayOfMonth;  // The date number - used for rendering

        let maxDateReached = false;

        for (let i = 0; i < numRows; i++) {
            // creates a table row
            let rowObj = {}
            let rowData = [];
            
            //creating individual cells, filing them up with data.
            for (let j = 0; j < 7; j++) {
                // create empty data record
                let cellData = {
                    calOptions: {
                        allowEventCreation: this.allowEventCreation
                    },
                    cellId: cellId ++,
                    cssClasses: {
                        dateNumberText: 'date',
                        dateBlock: 'date-block'
                    },
                    data: {
                        numItems: 0,
                        numHiddenItems: 0,
                        shortList: [],
                        fullList: [],
                    },
                    date: '',
                    dateNumber: '',
                }

                // if the date in the array is less that the start date, push an empty cell
                if (i === 0 && j < firstDayNum || maxDateReached === true) {
                    rowData.push(cellData);
                }
                // When there is a date to push
                else {
                    if(currentCellDate.getDate() === daysInMonth) {
                        maxDateReached = true;
                    }

                    // Do something with todays Date
                    if (currentCellDate.getDate() === this.todaysDate.getDate() && year === this.todaysDate.getFullYear() && month === this.todaysDate.getMonth()) {
                        cellData.cssClasses.dateNumberText = cellData.cssClasses.dateNumberText + ' date-today';
                    }

                    // get the date and cell id and push them to the data + increment the date
                    cellData.dateNumber = currentCellDate.getDate();
                    cellData.date = currentCellDate;
                    cellData.cellId = cellId ++;
                    cellData.cssClasses.dateNumberText = cellData.cssClasses.dateNumberText + ' date-standard';
                    if(this.allowEventCreation === true) {
                        cellData.cssClasses.dateBlock = cellData.cssClasses.dateBlock +' date-block-selectable';
                    }
                    cellData.data = this.formatSalesforceRecord(currentCellDate);

                    rowData.push(cellData);
                    currentCellDate = new Date(year, month, (currentCellDate.getDate() + 1));
                }
            }
            
            // add data to row list
            rowObj.rowId = i;
            rowObj.rowData = rowData;
            this.calendarData.push(rowObj);
        }
    }

    /**
        @description: Used to refactor salesforce records into a format that can be displayed by the calendar. Called for a single date by 'renderCalendar'
        @param: date - the current date that we are transforming the data for
    */
    formatSalesforceRecord(date){
        let tempData = {
            numItems: 0,
            numHiddenItems: 0,
            shortList: [],
            fullList: [],
        };

        if(this.salesforceRecords !== undefined) {

            //Get the current data for the date
            let currentSFDateData = this.salesforceRecords[date.getDate()-1];


            //Check if there are any events
            if('Events' in currentSFDateData) {

                if(currentSFDateData.Events.length > 2){
                    tempData.shortList = currentSFDateData.Events.slice(0,2);
                    tempData.fullList = currentSFDateData.Events;
                    tempData.numItems = currentSFDateData.Events.length;
                    tempData.numHiddenItems = currentSFDateData.Events.length - 2;
                } else {
                    tempData.shortList = currentSFDateData.Events;
                    tempData.fullList = currentSFDateData.Events;
                    tempData.numItems = currentSFDateData.Events.length;
                    tempData.numHiddenItems = 0;
                }
            }
        }
        
        return tempData;
    }
}