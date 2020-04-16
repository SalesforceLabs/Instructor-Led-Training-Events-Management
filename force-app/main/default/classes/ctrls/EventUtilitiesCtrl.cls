public with sharing class EventUtilitiesCtrl {
    
    public static Boolean isEventSignUpExternal(String baseUrl) {

        if(System.URL.getSalesforceBaseUrl().toExternalForm().contains(baseUrl)){
            return false;
        }

        return true;
    }
}
