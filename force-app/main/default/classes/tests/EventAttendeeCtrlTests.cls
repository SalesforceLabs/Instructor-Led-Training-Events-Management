/*
 * Copyright (c) 2022, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

@isTest
public class EventAttendeeCtrlTests {



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
    static void confirmAttendeeSignUpTest(){

        Training_Event_Attendee__c testEventAttendee = [
            SELECT Id, Related_User__c, Training_Event_Occurrence__c
            FROM Training_Event_Attendee__c
            WHERE Related_User__r.Name = 'Test Test'
        ];

        EventAttendeeReturnWrapper firstSignUpWrapper = EventAttendeeCtrl.confirmAttendeeSignUp(testEventAttendee.Id);
        System.assertEquals(true, firstSignUpWrapper.signUpConfirmed, 'First Sign up request not handled properly');

        EventAttendeeReturnWrapper secondSignUpWrapper = EventAttendeeCtrl.confirmAttendeeSignUp(testEventAttendee.Id);
        System.assertEquals(true, secondSignUpWrapper.signUpAlreadyConfirmed, 'Second Sign up request not handled properly');
    }



    @isTest
    static void confirmAttendeeSignUpNegativeTest(){
        EventAttendeeReturnWrapper firstSignUpWrapper = EventAttendeeCtrl.confirmAttendeeSignUp('a0B5J000001O21UUXT');
        System.assertEquals(true, firstSignUpWrapper.noRecordFound, 'Wrong Sign up request not handled properly');
    }



    @isTest
    static void getSignUpConfirmationUrlInternalTest(){

        Training_Event_Attendee__c testEventAttendee = [
            SELECT Id, Related_User__c, Training_Event_Occurrence__c
            FROM Training_Event_Attendee__c
            WHERE Related_User__r.Name = 'Test Test'
        ];

        System.assertEquals(true, EventAttendeeCtrl.getSignUpConfirmationUrl(testEventAttendee.Id, false, true).contains(testEventAttendee.Id), 'Sign Up URL Does Not Match');
    }



    @isTest
    static void getSignUpConfirmationUrlExternalTest(){

        Training_Event_Attendee__c testEventAttendee = [
            SELECT Id, Related_User__c, Training_Event_Occurrence__c
            FROM Training_Event_Attendee__c
            WHERE Related_User__r.Name = 'Test Test'
        ];

        System.assertEquals(true, EventAttendeeCtrl.getSignUpConfirmationUrl(testEventAttendee.Id, true, true).contains(testEventAttendee.Id), 'Sign Up URL Does Not Match');
    }



    @isTest
    static void getTrainingEventAttendeeUsersMapTest() {
        Map<Id, User> testUserMap = EventAttendeeCtrl.getTrainingEventAttendeeUsersMap(EventOccuranceCtrl.getTrainingEventOccurancesWithDate(1, 2010, false));

        System.assertEquals(1, testUserMap.size(), 'User Map Does Not Match');
    }



    @isTest
    static void createNewEventAttendeeTest(){
        Training_Event_Occurrence__c testEventOccurance = [
            SELECT Id, Name, Attendance_Confirmation_Code__c
            FROM Training_Event_Occurrence__c
            WHERE Training_Event__r.Name = 'Test Event'
        ];

        User ownerUser = [SELECT Id FROM User WHERE Username = 'tester@apextesteruser.test'];

        System.assertEquals(false, EventAttendeeCtrl.createNewEventAttendee(ownerUser.Id, testEventOccurance.Id, System.URL.getOrgDomainUrl().toExternalForm()).Is_Attendee_External__c, 'User sign up locations dont match');
    }
}
