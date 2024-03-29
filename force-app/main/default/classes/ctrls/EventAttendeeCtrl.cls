/*
 * Copyright (c) 2022, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

public with sharing class EventAttendeeCtrl {
    
    /*
        @name: confirmAttendeeSignUp
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

                List<Training_Event_Attendee__c> recordsToUpdate = new List<Training_Event_Attendee__c>();
                recordsToUpdate.add(currentAttendee);
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, recordsToUpdate);
                update securityDecision.getRecords();

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
        @description: Used to generate a signup confirmation url that an attendee will click
        
        @param: eventAttendeeId - The ID related to the attendee

        @returns: String - Returns a generated url
    */

    public static String getSignUpConfirmationUrl(Id eventAttendeeId, Boolean isUserExternal, Boolean isTestRun){

        String signUpUrl = '';

        if(isUserExternal == true){
            // Get labels for community name and also the url to the confirmation page
            String communityName = Label.Training_Events_Community;
            String communityConfirmationPage = Label.Training_Events_Community_Confirmation_Page;

            // Try get the communiy ifno and gen the new url
            if(isTestRun == false){
                try{
                    Network myNetwork = [
                        SELECT Id 
                        FROM Network 
                        WHERE Name =: communityName
                        WITH SECURITY_ENFORCED
                    ];
    
                    // Requires Admin Perms
                    /*
                    ConnectApi.Community  myCommunity = ConnectApi.Communities.getCommunity(myNetwork.id);
                    signUpUrl = myCommunity.siteUrl + '/s/' + communityConfirmationPage + '?attendeeId=' + eventAttendeeId;
                    */
    
                    String communityLoginUrl = Network.getLoginUrl(myNetwork.Id);
                    String[] splitCommunityLoginUrl = communityLoginUrl.split('/');
    
                    signUpUrl = splitCommunityLoginUrl[0] + '//' + splitCommunityLoginUrl[2] + '/' + splitCommunityLoginUrl[3] + '/' + communityConfirmationPage + '?c__attendeeId=' + eventAttendeeId;
    
                }catch(Exception e){
                    system.debug(e.getMessage());
                }
            } else {
                signUpUrl = 'www.salesforce.com/test' + '?c__attendeeId=' + eventAttendeeId; 
            }
        } else {
            String orgConfirmationPage = Label.Training_Events_Internal_Confirmation_Page;

            signUpUrl = System.URL.getOrgDomainUrl().toExternalForm() + '/' + orgConfirmationPage + '?c__attendeeId=' + eventAttendeeId;
        }
        

        system.debug('EventAttendeeCtrl - getSignUpConfirmationUrl(): signUpUrl');
        system.debug(signUpUrl);

        return signUpUrl;
    }



    /*
        @name: getTrainingEventAttendeeUsersMap
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

        system.debug('EventAttendeeCtrl - getTrainingEventAttendeeUsersMap(): userIdsList');
        system.debug(userIdsList);

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



    /*
        @name: createNewEventAttendee
        @description: Used to create a new event attendee record
        
        @param: currentUserId - Id of the current user thats trying to signup
        @param: relatedEventId - Id of the related event that they are trying to signup for
        @param: currentDomainUrl - Url of the signup page

        @returns: Boolean - To determine whether or not the record has been created or not
    */
    @AuraEnabled
    public static Training_Event_Attendee__c createNewEventAttendee(Id currentUserId, Id relatedEventId, String currentDomainUrl){
        try {
            List<Training_Event_Attendee__c> recordsToInsert = new List<Training_Event_Attendee__c>();
            Training_Event_Attendee__c newAttendee = new Training_Event_Attendee__c();

            newAttendee.Related_User__c = currentUserId;
            newAttendee.Training_Event_Occurrence__c = relatedEventId;
            newAttendee.Is_Attendee_External__c = EventUtilitiesCtrl.isEventSignUpExternal(currentDomainUrl);
            recordsToInsert.add(newAttendee);

            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, recordsToInsert);

            List<Training_Event_Attendee__c> newAttendees = securityDecision.getRecords();
            insert newAttendees;

            if(newAttendees != null){
                return newAttendees.get(0);
            } else {
                return null;
            }

        } catch(Exception e){
            System.debug(e.getMessage());
            return null;
        }
    }
}
