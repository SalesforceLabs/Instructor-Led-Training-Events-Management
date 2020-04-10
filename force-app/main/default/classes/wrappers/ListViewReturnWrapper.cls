public with sharing class ListViewReturnWrapper {
    @AuraEnabled
    public static List<EventWrapper> allEvents { get; set; }

    @AuraEnabled
    public static List<EventWrapper> myEvents { get; set; }
}
