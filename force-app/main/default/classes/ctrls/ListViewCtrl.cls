public with sharing class ListViewCtrl {

    /*
        @name: getListViewData
        @createdBy: Daniel Tilley
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

        if(isAdminView == true){
            return getAdminRecords(currentMonth, currentYear);
        }

        if(isAttendeeView == true){
            return getAttendeeRecords(currentMonth, currentYear);
        }
    }

    private static ListViewReturnWrapper getAdminRecords(Integer currentMonth, Integer currentYear){
        ListViewReturnWrapper returnWrapper = new ListViewReturnWrapper();
        returnWrapper.allEvents = new List<EventWrapper>();
        returnWrapper.myEvents = new List<EventWrapper>();

        List<Training_Event_Occurrence__c> allEvents = EventOccuranceCtrl.getTrainingEventOccurancesWithDate();
        List<Training_Event_Occurrence__c> myEvents = EventOccuranceCtrl.getTrainingEventOccurancesWithDate();

        return returnWrapper;
    }

    private static ListViewReturnWrapper getAttendeeRecords(Integer currentMonth, Integer currentYear){
        ListViewReturnWrapper returnWrapper = new ListViewReturnWrapper();
        returnWrapper.allEvents = new List<EventWrapper>();
        returnWrapper.myEvents = new List<EventWrapper>();

        List<Training_Event_Occurrence__c> allEvents = EventOccuranceCtrl.getTrainingEventOccurancesWithDate();
        //List<Training_Event_Occurrence__c> myEvents = EventOccuranceCtrl.getTrainingEventOccurancesWithDate();

        return returnWrapper;
    }
}
