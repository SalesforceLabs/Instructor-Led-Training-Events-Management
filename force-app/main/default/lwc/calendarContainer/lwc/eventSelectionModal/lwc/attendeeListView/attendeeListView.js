import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { deleteRecord } from 'lightning/uiRecordApi';

export default class AttendeeListView extends LightningElement {

    //----------------------------------------------------------------------------------------------------
    // Variables
    //----------------------------------------------------------------------------------------------------

    @api attendeeList;

    get showAttendeeList() {
        if (this.attendeeList === undefined){ return false; } 
        else {
            if(this.attendeeList.length === 0){ return false; } 
            else { return true; }
        }
    }

    //----------------------------------------------------------------------------------------------------
    // Onclick Handlers
    //----------------------------------------------------------------------------------------------------

    handleDeleteAttendee(event) {   
        let recId = event.currentTarget.dataset.id;
        
        if (window.confirm("Do you really want to remove this attendee?")){
            deleteRecord(recId)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'We have successfully removed the attendee!',
                        variant: 'success'
                    })
                );
                
                const parentEvent = new CustomEvent("attendeeremoved", { detail: recId });
                this.dispatchEvent(parentEvent);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Something Went Wrong",
                        message: "Hmmmm, Looks like something went wrong, please try again!",
                        variant: "error"
                    })
                );
            });
        }
    }
}