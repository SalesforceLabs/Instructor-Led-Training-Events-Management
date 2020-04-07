public with sharing class AttendeesWrapper {
    @AuraEnabled
    public String Id { get; set; }

    @AuraEnabled
    public String Name { get; set; }

    @AuraEnabled
    public String EmailAddress { get; set; }

    @AuraEnabled
    public Boolean SignUpConfirmed { get; set; }

    @AuraEnabled
    public Boolean AttendanceConfirmed { get; set; }
}
