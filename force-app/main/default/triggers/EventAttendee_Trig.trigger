trigger EventAttendee_Trig on Training_Event_Attendee__c (after insert) {

    List<Training_Event_Attendee__c> eventAttendeesToUpdate = new List<Training_Event_Attendee__c>();

    for (Training_Event_Attendee__c eventAttendee : Trigger.New){
        if(eventAttendee.Sign_Up_Confirmed__c == false && eventAttendee.Attendance_Confirmed__c == false){
            Training_Event_Attendee__c tempEventAttendee = new Training_Event_Attendee__c();
            tempEventAttendee.Id = eventAttendee.Id;
            tempEventAttendee.Is_Attendee_External__c = eventAttendee.Is_Attendee_External__c;
            tempEventAttendee.Email_Sign_Up_Confirmation_Link__c = EventAttendeeCtrl.getSignUpConfirmationUrl(tempEventAttendee.Id, tempEventAttendee.Is_Attendee_External__c, false);
            eventAttendeesToUpdate.add(tempEventAttendee);
        }
    }

    update eventAttendeesToUpdate;
}