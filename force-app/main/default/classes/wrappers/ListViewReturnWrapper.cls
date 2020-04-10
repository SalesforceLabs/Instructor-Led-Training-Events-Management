public with sharing class ListViewReturnWrapper {
    @AuraEnabled
    public List<EventWrapper> allEvents { get; set; }

    @AuraEnabled
    public List<EventWrapper> myEvents { get; set; }
}
