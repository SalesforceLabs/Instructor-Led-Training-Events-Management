@isTest
public class ListViewCtrlTests {
    
    

    @testSetup
    static void setup(){
        // create dates for testing
        Date testDate = Date.newInstance(2010, 1, 1);
        DateTime startTestTime = DateTime.newInstance(2010, 1, 1, 9, 0, 0);
        DateTime endTestTime = DateTime.newInstance(2010, 1, 1, 10, 0, 0);

        // create test user
        Id systemAdminProfileId = [select id from profile where name='System Administrator'].id;
        
        User testUser = new User(alias = 'test123', email='test123@noemail.com',
                            emailencodingkey='UTF-8', firstname = 'Test', lastname='Test', languagelocalekey='en_US',
                            localesidkey='en_US', profileid = systemAdminProfileId, country='United States', IsActive=true,
                            timezonesidkey='America/Los_Angeles', username='tester@apextesteruser.test');

        insert testUser;

        // TRAINING EVENT INSERT

        Training_Events__c testEvent = new Training_Events__c();
        testEvent.Training_Event_Description__c = 'Test Description';
        testEvent.Name = 'Test Event';

        insert testEvent;

        // TRAINING EVENT OCCURANCES INSERT

        Training_Event_Occurrence__c testEventOccurance = new Training_Event_Occurrence__c();
        testEventOccurance.RecordTypeId = Schema.SObjectType.Training_Event_Occurrence__c.getRecordTypeInfosByName().get('Virtual').getRecordTypeId();
        testEventOccurance.Instructor__c = testUser.Id;
        testEventOccurance.Max_Attendees__c = 5;
        testEventOccurance.Meeting_Link__c = 'www.google.com';
        testEventOccurance.Training_Event__c = testEvent.Id;
        testEventOccurance.Start_Date_Time__c = startTestTime;
        testEventOccurance.End_Date_Time__c = endTestTime;

        insert testEventOccurance;

        // TRAINING EVENT ATTENDEES INSERT

        Training_Event_Attendee__c testEventAttendee = new Training_Event_Attendee__c();
        testEventAttendee.Training_Event_Occurrence__c = testEventOccurance.Id;
        testEventAttendee.Related_User__c = testUser.Id;

        insert testEventAttendee;
    }



    @isTest
    static void getListViewDataAdminTest(){
        ListViewReturnWrapper wrapper = ListViewCtrl.getListViewData(0, 2010, true, false);
        System.assertEquals(1, wrapper.allEvents.size(), 'List view (all events) admin data not handled correctly');
        System.assertEquals(0, wrapper.myEvents.size(), 'List view (my events) admin data not handled correctly');
    }



    @isTest
    static void getListViewDataAdminNegativeTest(){
        ListViewReturnWrapper wrapper = ListViewCtrl.getListViewData(1, 2010, true, false);
        System.assertEquals(0, wrapper.allEvents.size(), 'List view admin (all events) negative data not handled correctly');
        System.assertEquals(0, wrapper.myEvents.size(), 'List view admin (my events) negative data not handled correctly');
    }



    @isTest
    static void getListViewDataAttendeeTest(){
        ListViewReturnWrapper wrapper = ListViewCtrl.getListViewData(0, 2010, false, true);
        System.assertEquals(1, wrapper.allEvents.size(), 'List view (all events) attendee data not handled correctly');
        System.assertEquals(0, wrapper.myEvents.size(), 'List view (my events) attendee data not handled correctly');
    }



    @isTest
    static void getListViewDataAttendeeNegativeTest(){
        ListViewReturnWrapper wrapper = ListViewCtrl.getListViewData(1, 2010, false, true);
        System.assertEquals(0, wrapper.allEvents.size(), 'List view (all events) attendee negative data not handled correctly');
        System.assertEquals(0, wrapper.myEvents.size(), 'List view (my events) attendee negative data not handled correctly');
    }
}
