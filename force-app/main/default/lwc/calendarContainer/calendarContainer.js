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
    daysOfWeekList = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']; // months array that holds names of the months (can be changed)
    monthsList = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]; // moths array that holds names of the months (can be changed)

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

    @track showDateSelection = false;   // allow users to input date options 

    //**********************************************************************************************
    // Modal Variables
    @track showEventSelectModal = false;    // used to determine whther or not to show the event select modal
    @track showEventCreateModal = false;    // used to determine whther or not to show the event create modal
    @track modalSelectionType = 'events';   // used to determine what type of modal to show (either a single event or events)
    @track modalData;                       // the data to be passed to the modal
    @track changedRecordId = '';            // will be updated when a child cmp changed a record

    //**********************************************************************************************
    // Date Variables
    @track todaysDate = new Date();                     // the current date
    @track currentMonth = this.todaysDate.getMonth();   // the month we are currently displaying data for
    @track currentYear = this.todaysDate.getFullYear(); // the year we are currently displaying data for

    //**********************************************************************************************
    // Design attributes
    @api showOnlyMyRecords = false;
    @api allowEventCreation = false;
    @api isAdminView = false;
    @api isAttendeeView = false;

    //**********************************************************************************************
    // Getters
    get currentMonthLabel() { return this.monthsList[this.currentMonth]; } // used to display the month label to the user

    get monthsPicklistOptions() {
        let optionsList = [];

        this.monthsList.forEach( (item, i)=> {
            optionsList.push({ label: item, value: i });
        });

        return optionsList;
    }

    get yearsPicklistOptions() {
        let optionsList = [];
        let startingYear = (this.todaysDate.getFullYear()) - 1;

        for(let i = 0; i < 3; i++){
            optionsList.push({ label: startingYear + i, value: startingYear + i });
        }

        return optionsList;
    }

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

    previousMonthClicked(){
        this.setCurrentDateToPreviousMonth();
    }

    nextMonthClicked(){
        this.setCurrentDateToNextMonth();
    }

    handleEventDateClicked() {
        this.showEventCreateModal = true;
    }
    
    handleOpenEventSelectModal(event) {
        this.modalSelectionType = event.detail.type;
        this.modalData = event.detail.modalData;
        this.openEventSelectModalHelper();
    }

    
    handleCloseEventSelectModal() {
        this.closeEventSelectModalHelper();
    }

    handleOpenEventCreateModal() {
        this.openEventCreateModalHelper();
    }

    
    handleCloseEventCreateModal() {
        this.closeEventCreateModalHelper();
    }

    handleDateTextSelected() {
        this.showDateSelection = true;
    }

    handleCloseDateSelection(){
        this.showDateSelection = false;
    }

    handleMonthSelectionChange(event) {
        this.currentMonth = event.detail.value;
    }

    handleYearSelectionChange(event){
        this.currentYear = event.detail.value;
    }

    handleForceRefreshData(){
        this.refreshDataHelper();
    }

    handleRecordChanged(event){
        this.changedRecordId = event.detail;
    }
    
    //----------------------------------------------------------------------------------------------------
    // Helpers
    //----------------------------------------------------------------------------------------------------
    // Used to avoid passing params from the wire and also so that we can all from the connected callback
    renderCalHelper() {
        this.renderCalendar(this.currentMonth, this.currentYear); 
    }

    refreshDataHelper(){
        return refreshApex(this.wiredReference);
    }

    setCurrentDateToToday() {
        this.currentYear = this.todaysDate.getFullYear();
        this.currentMonth = this.todaysDate.getMonth();
    }

    setCurrentDateToNextMonth() {
        this.currentYear = (this.currentMonth === 11) ? this.currentYear + 1 : this.currentYear;
        this.currentMonth = (this.currentMonth + 1) % 12;
    }

    setCurrentDateToPreviousMonth() {
        this.currentYear = (this.currentMonth === 0) ? this.currentYear - 1 : this.currentYear;
        this.currentMonth = (this.currentMonth === 0) ? 11 : this.currentMonth - 1;
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