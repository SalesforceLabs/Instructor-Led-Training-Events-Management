public with sharing class EventWrapper {
    @AuraEnabled
    public String Id { get; set; }

    @AuraEnabled
    public String Name { get; set; }

    @AuraEnabled
    public Time StartTime { get; set; }

    @AuraEnabled
    public String StartTimeString { get; set; }

    @AuraEnabled
    public Time EndTime { get; set; }

    @AuraEnabled
    public String EndTimeString { get; set; }

    @AuraEnabled
    public Boolean EventFull { get; set; }

    @AuraEnabled
    public Integer NumSignUps { get; set; }

    @AuraEnabled
    public Integer NumAttendees { get; set; }

    @AuraEnabled
    public List<AttendeesWrapper> Attendees { get; set; }
}
