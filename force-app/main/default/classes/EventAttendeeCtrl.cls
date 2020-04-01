public with sharing class EventAttendeeCtrl {
    
    public static String getSignUpConfirmationUrl(Id eventAttendeeId){

        String communityName = Label.Training_Events_Community;
        String communityConfirmationPage = Label.Training_Events_Community_Confirmation_Page;

        Network myNetwork = [SELECT Id FROM Network WHERE Name =: communityName ];
        ConnectApi.Community  myCommunity = ConnectApi.Communities.getCommunity(myNetwork.id);

        String communityUrl = myCommunity.siteUrl + '/s/' + communityConfirmationPage + '=' + eventAttendeeId;

        return communityUrl;
    }
}
