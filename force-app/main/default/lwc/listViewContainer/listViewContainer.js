import { LightningElement, track, api } from 'lwc';

export default class ListViewContainer extends LightningElement {

    //----------------------------------------------------------------------------------------------------
    // Variables
    //----------------------------------------------------------------------------------------------------

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
    @track modalSelectionType = 'event';   // used to determine what type of modal to show (either a single event or events)
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
        //this.refreshDataHelper();
        this.showEventCreateModal = false;
    }
}