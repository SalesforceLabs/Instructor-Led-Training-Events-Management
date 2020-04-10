public with sharing class EventOccuranceCtrl {

    /*
        @name: confirmAttendeeEventAttendance
        @createdBy: Daniel Tilley
        @description: Used to generate a confirmation code
        
        @param: eventAttendeeId - The Id of the attendee
        @param: confirmationCode - The confirmation code that must be checked

        @returns: Boolean - Return a true / false var to confirm if the code matches
    */

    @AuraEnabled
    public static Boolean confirmAttendeeEventAttendance(Id eventAttendeeId, String confirmationCode){

        Boolean returnBoolean = false;

        try {
            Training_Event_Attendee__c eventAttendee = [
                SELECT Id, Training_Event_Occurrence__c, Attendance_Confirmed__c, Training_Event_Occurrence__r.Attendance_Confirmation_Code__c
                FROM Training_Event_Attendee__c
                WHERE Id =: eventAttendeeId
                WITH SECURITY_ENFORCED
            ];

            // Check the code matches and that hey haven't confirmed attendance already
            if(eventAttendee.Training_Event_Occurrence__r.Attendance_Confirmation_Code__c == confirmationCode && eventAttendee.Attendance_Confirmed__c == false) {
                eventAttendee.Attendance_Confirmed__c = true;
                update eventAttendee;
                returnBoolean = true;
            }

        } catch(Exception e) {
            system.debug(e.getMessage());
            returnBoolean = false;
        }

        system.debug('EventOccuranceCtrl - confirmAttendeeEventAttendance(): returnBoolean');
        system.debug(returnBoolean);

        return returnBoolean;
    }



    /*
        @name: generateAttendanceConfirmationCode
        @createdBy: Daniel Tilley
        @description: Used to generate a confirmation code
        
        @param: len - length of the confirmation code

        @returns: String - The random confirmation code
    */
    public static String generateAttendanceConfirmationCode(Integer len) {

        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

        String randStr = '';

        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }

        system.debug('EventOccuranceCtrl - generateAttendanceConfirmationCode(): randStr');
        system.debug(randStr);

        return randStr; 
    }



    /*
        @name: getTrainingEventOccurancesWithDate
        @createdBy: Daniel Tilley
        @description: Used to obtain a list of training event occurences
        
        @param: currentMonth - Current month as a number (0-11)
        @param: currentYear - Current year as a number e.g 2020

        @returns: List<Training_Event_Occurrence__c> - Returns all info for the current month in an object list
    */
    public static List<Training_Event_Occurrence__c> getTrainingEventOccurancesWithDate(Integer currentMonth, Integer currentYear, Boolean showUserRecordsOnly){
        // Try to execute to query and catch any errors
        List<Training_Event_Occurrence__c> resultList = null;

        try {
            if(showUserRecordsOnly == true){
                Id userId = UserInfo.getUserId();

                resultList = [
                    SELECT
                        Id, RecordTypeId, Training_Event_Name__c, Start_Date_Time__c, End_Date_Time__c, Instructor__c, Instructor__r.Name, Number_Sign_Ups__c, Number_Attendees__c, Event_Full__c,
                              ( SELECT Id, Attendance_Confirmed__c, Sign_Up_Confirmed__c, Related_User__c FROM Training_Event_Attendees__r)
                    FROM Training_Event_Occurrence__c
                    WHERE CALENDAR_MONTH(Start_Date_Time__c) =: currentMonth AND CALENDAR_YEAR(Start_Date_Time__c) =: currentYear AND Training_Event_Occurrence__c.Instructor__c = :userId 
                    WITH SECURITY_ENFORCED
                    ORDER BY Start_Date_Time__c ASC NULLS LAST
                ];

            } else {

                resultList = [
                    SELECT
                        Id, RecordTypeId, Training_Event_Name__c, Start_Date_Time__c, End_Date_Time__c, Instructor__c, Instructor__r.Name, Number_Sign_Ups__c, Number_Attendees__c, Event_Full__c,
                              ( SELECT Id, Attendance_Confirmed__c, Sign_Up_Confirmed__c, Related_User__c FROM Training_Event_Attendees__r)
                    FROM Training_Event_Occurrence__c
                    WHERE CALENDAR_MONTH(Start_Date_Time__c) =: currentMonth AND CALENDAR_YEAR(Start_Date_Time__c) =: currentYear
                    WITH SECURITY_ENFORCED
                    ORDER BY Start_Date_Time__c ASC NULLS LAST
                ];

            }
        } catch(QueryException e) {
            system.debug(e.getMessage());
            resultList = null;
        } // end try / catch

        system.debug('EventOccuranceCtrl - getTrainingEventOccurancesWithDate(): resultList');
        system.debug(resultList);

        return resultList;
    }
}
