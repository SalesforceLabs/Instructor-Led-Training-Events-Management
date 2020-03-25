import { LightningElement, api } from 'lwc';

export default class AttendeeListView extends LightningElement {

    @api attendeeList;

    get showAttendeeList() {
        if (this.attendeeList === undefined){ return false; } 
        else {
            if(this.attendeeList.length === 0){ return false; } 
            else { return true; }
        }
    }
}