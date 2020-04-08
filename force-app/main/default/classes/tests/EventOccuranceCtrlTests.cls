@isTest
public class EventOccuranceCtrlTests {



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
    static void confirmAttendeeEventAttendanceTest(){

        Training_Event_Attendee__c testEventAttendee = [
            SELECT Id, Related_User__c, Training_Event_Occurrence__c
            FROM Training_Event_Attendee__c
            WHERE Related_User__r.Name = 'Test Test'
        ];

        Training_Event_Occurrence__c testEventOccurance = [
            SELECT Id, Name, Attendance_Confirmation_Code__c
            FROM Training_Event_Occurrence__c
            WHERE Id =: testEventAttendee.Training_Event_Occurrence__c
        ];

        System.assert(EventOccuranceCtrl.confirmAttendeeEventAttendance(testEventAttendee.Id, testEventOccurance.Attendance_Confirmation_Code__c), 'Confirmation code not handled correctly');
    }



    @isTest
    static void confirmAttendeeEventAttendanceNegativeTest(){

        Training_Event_Attendee__c testEventAttendee = [
            SELECT Id, Related_User__c, Training_Event_Occurrence__c
            FROM Training_Event_Attendee__c
            WHERE Related_User__r.Name = 'Test Test'
        ];

        Training_Event_Occurrence__c testEventOccurance = [
            SELECT Id, Name, Attendance_Confirmation_Code__c
            FROM Training_Event_Occurrence__c
            WHERE Id =: testEventAttendee.Training_Event_Occurrence__c
        ];

        System.assertEquals(false, EventOccuranceCtrl.confirmAttendeeEventAttendance(testEventAttendee.Id, testEventOccurance.Attendance_Confirmation_Code__c.reverse()), 'Wrong confirmation code was not handled properly');
    }



    @isTest
    static void generateAttendanceConfirmationCodeTest(){
        System.assertEquals(6, EventOccuranceCtrl.generateAttendanceConfirmationCode(6).length());
    }



    @isTest
    static void getTrainingEventOccurancesWithDateTest(){
        List<Training_Event_Occurrence__c> testEventOccuranceList = EventOccuranceCtrl.getTrainingEventOccurancesWithDate(1, 2010, false);

        System.assertEquals(1, testEventOccuranceList.size(), 'Number of occurances does not match');
    }



    @isTest
    static void getMyTrainingEventOccurancesWithDateTest(){
        List<Training_Event_Occurrence__c> testEventOccuranceList = EventOccuranceCtrl.getTrainingEventOccurancesWithDate(1, 2010, true);

        System.assertEquals(0, testEventOccuranceList.size(), 'Number of my occurances does not match');
    }



    @isTest
    static void getTrainingEventOccurancesWithDateNegativeTest(){
        List<Training_Event_Occurrence__c> testEventOccuranceList = EventOccuranceCtrl.getTrainingEventOccurancesWithDate(2, 2011, false);

        System.assertEquals(0, testEventOccuranceList.size(), 'Number of occurances does not match');
    }
}
