trigger EventOccurence_Trig on Training_Event_Occurrence__c (before insert) {
    
    for(Training_Event_Occurrence__c newOccurance : Trigger.New){
        if(newOccurance.Attendance_Confirmation_Code__c == null) {
            newOccurance.Attendance_Confirmation_Code__c = EventOccuranceCtrl.generateAttendanceConfirmationCode(6);
        }
    }
}