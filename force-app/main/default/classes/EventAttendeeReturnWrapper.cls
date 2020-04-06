public with sharing class EventAttendeeReturnWrapper {
    @AuraEnabled
    public Id eventAttendeeId { get; set; }

    @AuraEnabled
    public Boolean signUpAlreadyConfirmed { get; set; }

    @AuraEnabled
    public Boolean signUpConfirmed { get; set; }

    @AuraEnabled
    public Boolean noRecordFound { get; set; }
}
