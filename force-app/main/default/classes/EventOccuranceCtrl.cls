public with sharing class EventOccuranceCtrl {
    
    public static String generateAttendanceConfirmationCode(Integer len) {

        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

        String randStr = '';

        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }

        return randStr; 
    }

    @AuraEnabled
    public static Boolean confirmAttendeeEventAttendance(Id eventAttendeeId, String confirmationCode){
        try {

            Training_Event_Attendee__c eventAttendee = [
                SELECT Id, Training_Event_Occurrence__c, Attendance_Confirmed__c, Training_Event_Occurrence__r.Attendance_Confirmation_Code__c
                FROM Training_Event_Attendee__c
                WHERE Id =: eventAttendeeId
                WITH SECURITY_ENFORCED
            ];

            if(eventAttendee.Training_Event_Occurrence__r.Attendance_Confirmation_Code__c == confirmationCode && eventAttendee.Attendance_Confirmed__c == false) {

                eventAttendee.Attendance_Confirmed__c = true;

                update eventAttendee;

                return true;
            } else {
                return false;
            }

        } catch(Exception e) {
            system.debug(e.getMessage());
            return false;
        }
    }
}
