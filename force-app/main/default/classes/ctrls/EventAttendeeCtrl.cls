public with sharing class EventAttendeeCtrl {
    
    /*
        @name: confirmAttendeeSignUp
        @createdBy: Daniel Tilley
        @description: Used to confirm the attendees sign up
        
        @param: attendeeRecordId - The ID related to the attendee

        @returns: EventAttendeeReturnWrapper - Wrapper that detrmines the state of the confirmation
    */

    @AuraEnabled
    public static EventAttendeeReturnWrapper confirmAttendeeSignUp(Id attendeeRecordId){

        EventAttendeeReturnWrapper returnWrapper = new EventAttendeeReturnWrapper();
        returnWrapper.eventAttendeeId = attendeeRecordId;

        Training_Event_Attendee__c currentAttendee = null;

        // get the current attendee
        try{
            currentAttendee = [
                SELECT Id, Sign_Up_Confirmed__c
                FROM Training_Event_Attendee__c
                WHERE Id =: attendeeRecordId
                WITH SECURITY_ENFORCED
            ];
        }catch(QueryException e){
            system.debug(e.getMessage());
        }
         

        // check records returned
        if (currentAttendee != null ){
            // check if user already signed up
            if(currentAttendee.Sign_Up_Confirmed__c == true) {
                returnWrapper.signUpAlreadyConfirmed = true;
            } else {
                // sign user up
                currentAttendee.Sign_Up_Confirmed__c = true;
                update currentAttendee;
                returnWrapper.signUpConfirmed = true;
            }
        // no records found
        } else {
            returnWrapper.noRecordFound = true;
        }

        system.debug('EventAttendeeCtrl - confirmAttendeeSignUp(): returnWrapper');
        system.debug(returnWrapper);

        return returnWrapper;
    }



    /*
        @name: getSignUpConfirmationUrl
        @createdBy: Daniel Tilley
        @description: Used to generate a signup confirmation url that an attendee will click
        
        @param: eventAttendeeId - The ID related to the attendee

        @returns: String - Returns a generated url
    */

    public static String getSignUpConfirmationUrl(Id eventAttendeeId){

        // Get labels for community name and also the url to the confirmation page
        String communityName = Label.Training_Events_Community;
        String communityConfirmationPage = Label.Training_Events_Community_Confirmation_Page;

        String communityUrl = '';

        // Try get the communiy ifno and gen the new url
        try{
            Network myNetwork = [
                SELECT Id 
                FROM Network 
                WHERE Name =: communityName
                WITH SECURITY_ENFORCED
            ];

            ConnectApi.Community  myCommunity = ConnectApi.Communities.getCommunity(myNetwork.id);
            communityUrl = myCommunity.siteUrl + '/s/' + communityConfirmationPage + '?attendeeId=' + eventAttendeeId;

        }catch(Exception e){
            system.debug(e.getMessage());
        }

        system.debug('EventAttendeeCtrl - getSignUpConfirmationUrl(): communityUrl');
        system.debug(communityUrl);

        return communityUrl;
    }



    /*
        @name: getTrainingEventAttendeeUsersMap
        @createdBy: Daniel Tilley
        @description: Used to obtain a list of training event attendees
        
        @param: eventsList - list of events that have been returned from a previous query

        @returns: Map<Id, User> - Returns all contact info for the attendees
    */

    public static Map<Id, User> getTrainingEventAttendeeUsersMap(List<Training_Event_Occurrence__c> eventsList){
        
        Map<Id, User> returnList = new Map<Id, User>();
        List<User> resultList = new List<User>();
        List<Id> userIdsList = new List<Id>();

        // add user ids to list for the query
        for (Training_Event_Occurrence__c eventOccur : eventsList){
            if(eventOccur.Training_Event_Attendees__r.size() > 0){
                for(Training_Event_Attendee__c eventAttendee: eventOccur.Training_Event_Attendees__r){
                    userIdsList.add(eventAttendee.Related_User__c);
                }
            } 
        }

        //remove duplicates
        userIdsList = new List<Id>(new Set<Id>(userIdsList));

        // Try to execute to query and catch any errors
        try {
            
            resultList = [
                SELECT Id, Name, Email
                FROM User
                WHERE Id IN :userIdsList
                WITH SECURITY_ENFORCED
            ];

            for(User user: resultList){
                returnList.put(user.Id, user);
            }

        } catch(QueryException e) {
            system.debug(e.getMessage());
            returnList = null;
        } // end try / catch

        system.debug('EventAttendeeCtrl - getTrainingEventAttendeeUsersMap(): returnList');
        system.debug(returnList);

        return returnList;
    }
}
