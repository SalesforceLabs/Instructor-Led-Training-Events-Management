public with sharing class CalendarCtrl {
    
    /*
        @name: getCalendarData
        @createdBy: Daniel Tilley
        @description: Used to retreive a list of data for the respective object whos api name is passed to the function
        
        @param: showUserRecordsOnly - A boolean to decide whether or not to render the owners records
        @param: currentMonth - Current month as a number (0-11)
        @param: currentYear - Current year as a number e.g 2020

        @returns: List<DateWrapper> - Returns all info for the current month in a wrapper list
    */
    @AuraEnabled(cacheable=true)
    public static List<DateWrapper> getCalendarData(
        Boolean showUserRecordsOnly,
        Integer currentMonth,
        Integer currentYear){
            
            // increment month as it is one number lower in javascript
            currentMonth ++;

            // Result list from the query
            List<Training_Event_Occurrence__c> resultList = new List<Training_Event_Occurrence__c>();

            // Try to execute to query and catch any errors
            try {
                if(showUserRecordsOnly == true){

                    Id userId = UserInfo.getUserId();

                    resultList = [
                        SELECT Id, Training_Event_Name__c, Start_Date_Time__c, End_Date_Time__c, Instructor__c
                        FROM Training_Event_Occurrence__c
                        WHERE CALENDAR_MONTH(Start_Date_Time__c) =: currentMonth AND CALENDAR_YEAR(Start_Date_Time__c) =: currentYear AND Instructor__c = :userId 
                        WITH SECURITY_ENFORCED
                    ];

                } else {

                    resultList = [
                        SELECT Id, Training_Event_Name__c, Start_Date_Time__c, End_Date_Time__c
                        FROM Training_Event_Occurrence__c
                        WHERE CALENDAR_MONTH(Start_Date_Time__c) =: currentMonth AND CALENDAR_YEAR(Start_Date_Time__c) =: currentYear 
                        WITH SECURITY_ENFORCED
                    ];

                }
            } catch(QueryException e) {
                system.debug(e.getMessage());
                resultList = null;
            } // end try / catch

            // return a wrapper to the child cmp
            return convertResultsToWrapper(resultList, currentMonth, currentYear);
    }


    /*
        @name: convertResultsToWrapper
        @createdBy: Daniel Tilley
        @description: Used to transform a list of SObjects to a Wrapper List
        
        @param: resultList - the results from the query
        @param: currentMonth - Current month as a number (0-11)
        @param: currentYear - Current year as a number e.g 2020

        @returns: List<DateWrapper> - Returns all info for the current month in a wrapper list
    */
    private static List<DateWrapper> convertResultsToWrapper(
        List<Training_Event_Occurrence__c> resultList, 
        Integer currentMonth,
        Integer currentYear) {
            
            // Create variables
            List<DateWrapper> returnList = new List<DateWrapper>(); // list to return
            Map<Integer, DateWrapper> tempMap = new Map<Integer, DateWrapper>(); // map that will use date as an index so that we can add multiple events quickly
            Integer numberDays = date.daysInMonth(currentYear, currentMonth); // number of days in the month so that we can create the map

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
            if(resultList != null) {
                for (Training_Event_Occurrence__c resultItem : resultList) {
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