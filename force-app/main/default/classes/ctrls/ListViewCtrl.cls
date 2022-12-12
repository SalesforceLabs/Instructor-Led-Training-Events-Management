/*
 * Copyright (c) 2022, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

public with sharing class ListViewCtrl {

    /*
        @name: getListViewData
        @description: Used to retreive a list events
        
        @param: currentMonth - Current month as a number (0-11)
        @param: currentYear - Current year as a number e.g 2020
        @param: isAdminView - Show admin record
        @param: isAttendeeView - Show attendee record

        @returns: List<DateWrapper> - Returns all info for the current month in a wrapper list
    */
    @AuraEnabled(cacheable=true)
    public static ListViewReturnWrapper getListViewData(Integer currentMonth, Integer currentYear, Boolean isAdminView, Boolean isAttendeeView){

        // increment month as it is one number lower in javascript
        currentMonth ++;

        ListViewReturnWrapper returnWrapper = null;

        if(isAdminView == true){
            returnWrapper = getAdminRecords(currentMonth, currentYear);
        }

        if(isAttendeeView == true){
            returnWrapper = getAttendeeRecords(currentMonth, currentYear);
        }

        system.debug('ListViewCtrl - getListViewData(): returnWrapper');
        system.debug(returnWrapper);

        return returnWrapper;
    }


    /*
        @name: getAdminRecords
        @description: Used to get the list of events for admins in a given month / year
        
        @param: allEvents - the events to convert

        @returns: ListViewReturnWrapper - Contains one list for all events and one for my events
    */
    private static ListViewReturnWrapper getAdminRecords(Integer currentMonth, Integer currentYear){

        List<Training_Event_Occurrence__c> allEvents = EventOccuranceCtrl.getTrainingEventOccurancesWithDate(currentMonth, currentYear, false);
        List<Training_Event_Occurrence__c> myEvents = EventOccuranceCtrl.getTrainingEventOccurancesWithDate(currentMonth, currentYear, true);

        return convertAdminEventOccuranceListToWrapper(allEvents, myEvents);
    }


    /*
        @name: convertAdminEventOccuranceListToWrapper
        @description: Used to convert a list of event occurances to Event Wrappers for admins
        
        @param: allEvents - the events to convert

        @returns: ListViewReturnWrapper - Contains one list for all events and one for my events
    */
    private static ListViewReturnWrapper convertAdminEventOccuranceListToWrapper(List<Training_Event_Occurrence__c> allEvents, List<Training_Event_Occurrence__c> myEvents){
        
        ListViewReturnWrapper returnWrapper = new ListViewReturnWrapper();

        returnWrapper.allEvents = convertEventListToWrapper(allEvents);
        returnWrapper.myEvents = convertEventListToWrapper(myEvents);

        system.debug('ListViewCtrl - convertAdminEventOccuranceListToWrapper(): returnWrapper');
        system.debug(returnWrapper);

        return returnWrapper;
    }


    /*
        @name: getAttendeeRecords
        @description: Used to get the list of events for attendees in a given month / year
        
        @param: allEvents - the events to convert

        @returns: ListViewReturnWrapper - Contains one list for all events and one for my events
    */
    private static ListViewReturnWrapper getAttendeeRecords(Integer currentMonth, Integer currentYear){
        
        List<Training_Event_Occurrence__c> allEvents = EventOccuranceCtrl.getTrainingEventOccurancesWithDate(currentMonth, currentYear, false);
        List<Training_Event_Occurrence__c> myEvents = EventOccuranceCtrl.getAttendeeEventOccurances(allEvents, UserInfo.getUserId());

        return convertAttendeeEventOccuranceListToWrapper(allEvents, myEvents);
    }

    

    /*
        @name: convertAttendeeEventOccuranceListToWrapper
        @description: Used to convert a list of event occurances to Event Wrappers for attendees
        
        @param: allEvents - the events to convert

        @returns: ListViewReturnWrapper - Contains one list for all events and one for my events
    */
    private static ListViewReturnWrapper convertAttendeeEventOccuranceListToWrapper(List<Training_Event_Occurrence__c> allEvents, List<Training_Event_Occurrence__c> myEvents){
        ListViewReturnWrapper returnWrapper = new ListViewReturnWrapper();

        returnWrapper.allEvents = convertEventListToWrapper(allEvents);
        returnWrapper.myEvents = convertEventListToWrapper(myEvents);

        system.debug('ListViewCtrl - convertAttendeeEventOccuranceListToWrapper(): returnWrapper');
        system.debug(returnWrapper);

        return returnWrapper;
    }


    /*
        @name: convertEventListToWrapper
        @description: Used to convert a list of event occurances to Event Wrappers
        
        @param: allEvents - the events to convert

        @returns: List<EventWrapper> - List of event wrappers
    */
    private static List<EventWrapper> convertEventListToWrapper(List<Training_Event_Occurrence__c> allEvents){

        List<EventWrapper> returnWrapper = new List<EventWrapper>();

        if(allEvents != null){

            Map<Id, User> attendeesList = EventAttendeeCtrl.getTrainingEventAttendeeUsersMap(allEvents);
            Id currentUserId = UserInfo.getUserId();

            for(Training_Event_Occurrence__c resultItem : allEvents){
                try{
                    EventWrapper tempEventWrapper = new EventWrapper();

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
                    tempEventWrapper.StartDate = currentRecordStartDate;
                    tempEventWrapper.StartDateString = currentRecordStartDate.format();
                    tempEventWrapper.EndDate = currentRecordEndDate;
                    tempEventWrapper.EndDateString = currentRecordEndDate.format();
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
                
                    returnWrapper.add(tempEventWrapper);

                } catch(Exception e){
                    System.debug(e.getMessage());
                } // end try catch
            }// end for
        }// end if

        system.debug('ListViewCtrl - convertEventListToWrapper(): returnWrapper');
        system.debug(returnWrapper);

        return returnWrapper;
    }



    /*
        @name: convertTimeToString
        @description: Used to convert a Time variable to a string variable
        
        @param: theTime - the time var to convert

        @returns: String - Returns time in the format HH : MM
    */
    private static String convertTimeToString(Time theTime){
        return String.valueOf(theTime).split(':')[0] + ':' + String.valueOf(theTime).split(':')[1];
    }
}
