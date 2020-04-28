public with sharing class CalendarCtrl {
    
    /*
        @name: getCalendarData
        @createdBy: Daniel Tilley
        @description: Used to retreive a list of data for the respective object whos api name is passed to the function
        
        @param: showUserRecordsOnly - A boolean to decide whether or not to render the owners records
        @param: currentMonth - Current month as a number (0-11)
        @param: currentYear - Current year as a number e.g 2020
        @param: changedRecordId - Any records that have changed forcing this to be fired

        @returns: List<DateWrapper> - Returns all info for the current month in a wrapper list
    */

    @AuraEnabled(cacheable=true)
    public static List<DateWrapper> getCalendarData(
        Boolean showUserRecordsOnly,
        Integer currentMonth,
        Integer currentYear,
        String changedRecordId){

            // increment month as it is one number lower in javascript
            currentMonth ++;

            System.debug('Current Month: ' + currentMonth);
            System.debug('Current Year: ' + currentYear);

            // Result list from the query
            List<Training_Event_Occurrence__c> eventOccuranceList = EventOccuranceCtrl.getTrainingEventOccurancesWithDate(currentMonth, currentYear, showUserRecordsOnly);

            // Result list from the query
            Map<Id, User> attendeeList = EventAttendeeCtrl.getTrainingEventAttendeeUsersMap(eventOccuranceList);
            
            // return a wrapper to the child cmp
            return convertResultsToWrapper(eventOccuranceList, attendeeList, currentMonth, currentYear);
    }


    
    /*
        @name: convertResultsToWrapper
        @createdBy: Daniel Tilley
        @description: Used to transform a list of SObjects to a Wrapper List
        
        @param: eventOccuranceList - the results from the query
        @param: attendeesList - List of users related to events
        @param: currentMonth - Current month as a number (0-11)
        @param: currentYear - Current year as a number e.g 2020

        @returns: List<DateWrapper> - Returns all info for the current month in a wrapper list
    */
    private static List<DateWrapper> convertResultsToWrapper(
        List<Training_Event_Occurrence__c> eventOccuranceList, 
        Map<Id, User> attendeesList,
        Integer currentMonth,
        Integer currentYear) {
            
            // Create variables
            List<DateWrapper> returnList = new List<DateWrapper>();                 // list to return
            Map<Integer, DateWrapper> tempMap = new Map<Integer, DateWrapper>();    // map that will use date as an index so that we can add multiple events quickly
            Integer numberDays = date.daysInMonth(currentYear, currentMonth);       // number of days in the month so that we can create the map
            Id currentUserId = UserInfo.getUserId();                                // get user id to check if they are attending any events

            // loop through the number of days in a month and create a map list of similar size
            for(Integer i = 1 ; i < numberDays + 1 ; i ++) {
                Date currentDate = Date.newInstance(currentYear,currentMonth,i);
                DateWrapper currentDateWrapper = new DateWrapper();

                // add the current dates so we can use these as an index to add events later
                currentDateWrapper.EventDate = currentDate;
                currentDateWrapper.EventDateNum = currentDate.day();

                tempMap.put(i, currentDateWrapper);
            }
            
            // If the results list is not null, add the values, otherwise, don't push any events 
            if(eventOccuranceList != null) {
                for (Training_Event_Occurrence__c resultItem : eventOccuranceList) {
                    // Create new events wrapper to add events to
                    EventWrapper tempEventWrapper = new EventWrapper();
                    DateWrapper tempDateWrapper = new DateWrapper();

                    try{
                        // Get the start time fields and add them to the event
                        Datetime tempStartDateTime = (Datetime) resultItem.Start_Date_Time__c;
                        Date currentRecordStartDate = tempStartDateTime.date();
                        Time currentRecordStartTime = tempStartDateTime.time();

                        // Get the end time fields and add them to the event
                        Datetime tempEndDateTime = (Datetime) resultItem.End_Date_Time__c;
                        Date currentRecordEndDate = tempEndDateTime.date();
                        Time currentRecordEndTime = tempEndDateTime.time();

                        // Add variables to the even object
                        tempEventWrapper.Id = (String) resultItem.Id;
                        tempEventWrapper.Name = (String) resultItem.Training_Event_Name__c;
                        tempEventWrapper.StartTime = currentRecordStartTime;
                        tempEventWrapper.StartTimeString = convertTimeToString(currentRecordStartTime);
                        tempEventWrapper.EndTime = currentRecordEndTime;
                        tempEventWrapper.EndTimeString = convertTimeToString(currentRecordEndTime);
                        tempEventWrapper.NumSignUps = resultItem.Number_Sign_Ups__c;
                        tempEventWrapper.NumAttendees = resultItem.Number_Attendees__c;
                        tempEventWrapper.EventFull = true;
                        tempEventWrapper.EventType = Schema.SObjectType.Training_Event_Occurrence__c.getRecordTypeInfosById().get(resultItem.RecordTypeId).getName();
                        tempEventWrapper.InstructorId = resultItem.Instructor__c;
                        tempEventWrapper.InstructorName = resultItem.Instructor__r.Name;
                        tempEventWrapper.CurrentUserIsInstructor = false;
                        tempEventWrapper.CurrentUserRegistered = false;
                        tempEventWrapper.CurrentUserAttendee = null;

                        if( tempEventWrapper.InstructorId == UserInfo.getUserId()) { tempEventWrapper.CurrentUserIsInstructor = true; } 

                        // Loop through attendees and add them to the wrapper
                        if(resultItem.Training_Event_Attendees__r.size() > 0){

                            tempEventWrapper.Attendees = new List<AttendeesWrapper>();

                            // Loop through event attendees and add contacts to the return wrapper
                            for(Training_Event_Attendee__c eventAttendee: resultItem.Training_Event_Attendees__r){

                                AttendeesWrapper tempAttendeeWrapper = new AttendeesWrapper();
                                
                                tempAttendeeWrapper.Id = eventAttendee.Id;
                                tempAttendeeWrapper.AttendanceConfirmed = eventAttendee.Attendance_Confirmed__c	;
                                tempAttendeeWrapper.SignUpConfirmed = eventAttendee.Sign_Up_Confirmed__c;
                                tempAttendeeWrapper.Name = attendeesList.get(eventAttendee.Related_User__c).Name;
                                tempAttendeeWrapper.EmailAddress = attendeesList.get(eventAttendee.Related_User__c).Email;

                                // add current user info to event wrapper if the user is registered
                                if(currentUserId == eventAttendee.Related_User__c){
                                    tempEventWrapper.CurrentUserRegistered = true;
                                    tempEventWrapper.CurrentUserAttendee = tempAttendeeWrapper;
                                }

                                tempEventWrapper.Attendees.add(tempAttendeeWrapper);
                            }
                        } 
                        
                        // Check to see if the events list is initialised to avoid pushing to null list
                        tempDateWrapper = tempMap.get(currentRecordStartDate.day());
                        if (tempDateWrapper.Events == null) {
                            tempDateWrapper.Events = new List<EventWrapper>();
                        }
                        // Add item to the list and update the temp map
                        tempDateWrapper.Events.add(tempEventWrapper);
                        tempMap.put(currentRecordStartDate.day(), tempDateWrapper);
                        
                    }catch(Exception e){
                        System.debug(e.getMessage());
                    }
                }
            } 
            
            // Convert the map back to the return list
            for(Integer i = 1 ; i < tempMap.size() + 1 ; i ++) {
                returnList.add(tempMap.get(i));
            }
                
            return returnList;
    }



    /*
        @name: convertTimeToString
        @createdBy: Daniel Tilley
        @description: Used to convert a Time variable to a string variable
        
        @param: theTime - the time var to convert

        @returns: String - Returns time in the format HH : MM
    */
    private static String convertTimeToString(Time theTime){
        return String.valueOf(theTime).split(':')[0] + ':' + String.valueOf(theTime).split(':')[1];
    }
}