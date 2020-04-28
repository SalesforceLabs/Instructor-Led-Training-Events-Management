import { LightningElement, track, api } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EventSelectionModal extends LightningElement {

    //----------------------------------------------------------------------------------------------------
    // Variables
    //----------------------------------------------------------------------------------------------------

    //**********************************************************************************************
    // RECORD VARS
    @track selectedRecord;
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

    get isUserEventOwner(){
        if(this.showEventModal){
            return this.modalData.CurrentUserIsInstructor;
        }

        if(this.showEventsModal){
            if(this.selectedRecord !== undefined){
                return this.selectedRecord.CurrentUserIsInstructor;
            } else{
                return false;
            }
        }
    }
        
    //----------------------------------------------------------------------------------------------------
    // Onclick / Event Handlers
    //----------------------------------------------------------------------------------------------------

    handleAttendeeDeleted(event){
        this.recordChangedHelper(event.detail)
    }

    handleDeleteEventClicked(){
        if(confirm("Are you sure you want to delete this event?")){

            let recordId;

            if(this.showEventModal){ recordId = this.modalData.Id; }
            if(this.showEventsModal){ recordId = this.selectedRecordId; }

            this.deleteEventHelper(recordId);
        }
    }

    cancelClickedHandler() {
        this.dispatchEvent(new CustomEvent("cancel"));
    }

    closeClickedHandler() {
        this.dispatchEvent(new CustomEvent("close"));
    }

    eventClicked(event) {
        this.selectedRecordId = event.currentTarget.dataset.id;
        this.selectedRecord = this.modalData.data.fullList.find( item => item.Id === this.selectedRecordId);

        console.log(this.selectedRecord);

        let tempList = this.selectedRecord.Attendees;

        // To get over the render condition (if both items are undefined)
        if(tempList === undefined){
            this.selectedAttendeeList = [];
        } else {
            this.selectedAttendeeList = tempList;
        }
    }

    //----------------------------------------------------------------------------------------------------
    // Onclick / Event Handlers
    //----------------------------------------------------------------------------------------------------

    deleteEventHelper(recordId){
        deleteRecord(recordId)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'We have successfully deleted the event!',
                        variant: 'success'
                    })
                );

                this.recordChangedHelper(recordId);
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

    recordChangedHelper(recordId){
        const parentEvent = new CustomEvent("recordchanged", { detail : recordId });
        this.dispatchEvent(parentEvent);
        this.closeClickedHandler();
    }
}