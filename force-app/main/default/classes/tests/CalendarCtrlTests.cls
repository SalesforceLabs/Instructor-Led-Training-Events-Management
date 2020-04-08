@isTest
public class CalendarCtrlTests {
    
    @testSetup 
    static void setup() {
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
    static void getCalendarDataTest(){
        // Confirmation dates
        Time startTestTime = Time.newInstance(9, 0, 0, 0);
        Time endTestTime = Time.newInstance(10, 0, 0, 0);

        List<DateWrapper> calData = CalendarCtrl.getCalendarData(false, 0, 2010, null);

        for(DateWrapper currentDateWrapper : calData){

            // Test data created on the first date
            if(currentDateWrapper.EventDateNum == 1){

                for(EventWrapper curEventWrapper: currentDateWrapper.Events){

                    System.assertEquals('Test Event', curEventWrapper.Name, 'Event Name does not match');
                    System.assertEquals(startTestTime, curEventWrapper.StartTime, 'Event Start Time does not match');
                    System.assertEquals(endTestTime, curEventWrapper.EndTime, 'Event End Time does not match');
                    System.assertEquals(1, curEventWrapper.Attendees.size(), 'Num Attendees does not match');
                    System.assertEquals(0, curEventWrapper.NumSignUps, 'Num Confirmed Signups does not match');
                    System.assertEquals(0, curEventWrapper.NumAttendees, 'Num Confirmed Attendees does not match');
                    
                    for(AttendeesWrapper curAttendeeWrapper: curEventWrapper.Attendees){

                        System.assertEquals('Test Test', curAttendeeWrapper.Name, 'Attendee Name does not match');
                        System.assertEquals('test123@noemail.com', curAttendeeWrapper.EmailAddress, 'Attendee Email does not match');

                    } //end inner for each
                } // end inner for each

                break;

            }// end if
        }// end for loop
    }
}
