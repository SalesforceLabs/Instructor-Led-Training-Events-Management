import { LightningElement, track, api } from 'lwc';

export default class EventSelectionModal extends LightningElement {

    //----------------------------------------------------------------------------------------------------
    // Variables
    //----------------------------------------------------------------------------------------------------

    //**********************************************************************************************
    // RECORD VARS
    @track selectedRecordId;
    @track selectedAttendeeList;
    @api objectData;

    //**********************************************************************************************
    // MODAL VARIABLES
    @api cancelLabel = "Cancel";
    @api hideFooter = false;
    @api saveDisabled = false;
    @api modalSelectionType;
    @api isAttendeeView;
    @api isAdminView;
    
    /**
     * @type {Object} : {
        cellId: num,
        cssTileClass: text,
        cssClasses: {
            element: 'class-name',
            element: 'class-name',
        }
        data: {
            numItems: num,
            numHiddenItems: num,
            shortList: array -> obj,
            fullList: array -> obj,
            
                e.g: {
                    { Id: 1, Name: 'Test 1', StartTime: '08.00 am', EndTime: '09.00am'}
                }
        },
        date: text,
        dateNumber: text,
    }
    */
    @api modalData; // data to display in the modal

    //**********************************************************************************************
    // GETTERS
    get showRecordData() {
        return this.selectedRecordId !== undefined
    }

    get showAttendeeData() {
        return this.selectedAttendeeList !== undefined;
    }

    get showEventModal() {
        return this.modalSelectionType === 'event';
    }

    get showEventsModal() {
        return this.modalSelectionType === 'events';
    }

    get currentDateString() {
        if(this.modalData.date !== undefined) {
            return this.modalData.date.toDateString();
        } 
        return '';
    }
        
    //----------------------------------------------------------------------------------------------------
    // Onclick / Event Handlers
    //----------------------------------------------------------------------------------------------------

    handleAttendeeDeleted(event){
        const parentEvent = new CustomEvent("recorddeleted", { detail : event.detail });
        this.dispatchEvent(parentEvent);
        this.closeClickedHandler();
    }

    cancelClickedHandler() {
        this.dispatchEvent(new CustomEvent("cancel"));
    }

    closeClickedHandler() {
        this.dispatchEvent(new CustomEvent("close"));
    }

    eventClicked(event) {
        this.selectedRecordId = event.currentTarget.dataset.id;
        let tempList = this.modalData.data.fullList.find( item => item.Id === this.selectedRecordId).Attendees;

        // To get over the render condition (if both items are undefined)
        if(tempList === undefined){
            this.selectedAttendeeList = [];
        } else {
            this.selectedAttendeeList = tempList;
        }
    }
}