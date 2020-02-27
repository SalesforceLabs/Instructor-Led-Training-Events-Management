public with sharing class DateWrapper {

    public class EventWrapper {

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
    }

    @AuraEnabled
    public Date EventDate { get; set; }

    @AuraEnabled
    public Integer EventDateNum { get; set; }

    @AuraEnabled
    public List<EventWrapper> Events { get; set; }
}