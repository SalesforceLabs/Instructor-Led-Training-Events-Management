public with sharing class EventAttendeeCtrl {
    
    public static String getSignUpConfirmationUrl(Id eventAttendeeId){

        String communityName = Label.Training_Events_Community;
        String communityConfirmationPage = Label.Training_Events_Community_Confirmation_Page;

        Network myNetwork = [SELECT Id FROM Network WHERE Name =: communityName ];
        ConnectApi.Community  myCommunity = ConnectApi.Communities.getCommunity(myNetwork.id);

        String communityUrl = myCommunity.siteUrl + '/s/' + communityConfirmationPage + '?attendeeId=' + eventAttendeeId;

        return communityUrl;
    }

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

        return returnWrapper;
    }
}
