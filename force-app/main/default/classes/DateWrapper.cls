public with sharing class DateWrapper {
    @AuraEnabled
    public Date EventDate { get; set; }

    @AuraEnabled
    public Integer EventDateNum { get; set; }

    @AuraEnabled
    public List<EventWrapper> Events { get; set; }
}