public with sharing class EventUtilitiesCtrl {

    /*
        @name: isEventSignUpExternal
        @createdBy: Daniel Tilley
        @description: Used to check if the user is internal or external
        
        @param: domainUrl - the domain url obtained from the client side

        @returns: Boolean - To determine whether or not the user is external or not
    */
    public static Boolean isEventSignUpExternal(String domainUrl) {


        String[] splitUserDomainUrl = domainUrl.split('\\.');
        String[] splitOrgUrl = (System.URL.getOrgDomainUrl().toExternalForm()).split('\\.');
        
        Boolean isEventSignUpExternal;

        if(splitUserDomainUrl[0] == splitOrgUrl[0]){
            isEventSignUpExternal = false;
        } else {
            isEventSignUpExternal = true;
        }

        system.debug('EventUtilitiesCtrl - isEventSignUpExternal(): isEventSignUpExternal');
        system.debug(isEventSignUpExternal);

        return isEventSignUpExternal;
    }



    // REDUNDANT E-MAIL CODE THAT HAS BEEN REPLACED VIA E-MAIL TEMPLATES

    /*
        @name: createConfirmationEmail
        @createdBy: Daniel Tilley
        @description: Used to create + send the confirmation email to an attendee
        
        @param: emailRecipient - the event attendee record
        @param: relatedEvent - the event attendee record

        @returns: Boolean - To determine whether or not the user is external or not
    */
    /*
    private static Boolean createConfirmationEmail(Training_Event_Attendee__c emailRecipient, Training_Event_Occurrence__c relatedEvent){

        // Setup Email
        Messaging.SingleEmailMessage newEmail = new Messaging.SingleEmailMessage();
     	String[] toAddresses = new String[] {emailRecipient.Related_User__r.Email}; 
        newEmail.setToAddresses(toAddresses);
        OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'OWE_NAME'];
        newEmail.setOrgWideEmailAddressId(owea.Id);
        newEmail.setSubject('Thanks For Signing Up!');
        newEmail.setPlainTextBody(createEmailBody(emailRecipient, relatedEvent));  

        // Setup attachment
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();   
        attach.filename = 'EventTraining.ics'; 
        attach.ContentType = 'text/calendar';     
        attach.inline = true;     
        attach.body = createICSInviteAttachment(emailRecipient, relatedEvent);   
        newEmail.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});   

        // Send Email
        try{
            Messaging.SendEmailResult[] er = Messaging.sendEmail(new Messaging.Email[] { newEmail });
            return true;
        }catch(Exception e){
            return false;
        }
    }
    */



    /*
        @name: createEmailBody
        @createdBy: Daniel Tilley
        @description: Used to create the plain text e-mail body
        
        @param: emailRecipient - the event attendee record
        @param: relatedEvent - the event attendee record

        @returns: Boolean - To determine whether or not the user is external or not
    */
    /*
    private static String createEmailBody(Training_Event_Attendee__c emailRecipient, Training_Event_Occurrence__c relatedEvent){

        // determine the event type for later!
        String eventType = Schema.SObjectType.Training_Event_Occurrence__c.getRecordTypeInfosById().get(relatedEvent.RecordTypeId).getName();

        String emailBodyText = '';

        // Intro
        emailBodyText += 'Hello ' + emailRecipient.Related_User__r.Name + '!\n\n';
        emailBodyText += 'Thank you for signing up for ' + relatedEvent.Training_Event_Name__c + '.\n\n';

        // Check for pre-work
        if(relatedEvent.PreWork__c != null){
            emailBodyText += 'Before attending, we ask that you complete the following Pre-Work:\n\n';
            emailBodyText += relatedEvent.PreWork__c + '\n\n';
        }

        // Event details
        emailBodyText += 'The details of the event are as follows:\n\n';
        emailBodyText += 'Your Instructor is: ' + relatedEvent.Instructor__r.Name + '\n';
        emailBodyText += 'Your Session Starts at: ' + relatedEvent.Start_Date_Time__c + '\n';

        // Location
        if(eventType == 'Virtual'){
            emailBodyText += '\nHere is the Virtual Session Link: \n\n';

            emailBodyText += relatedEvent.Meeting_Link__c + '\n';
        }

        if(eventType == 'In Person'){
            emailBodyText += '\nHere is the Location of the Session: \n\n';

            if(relatedEvent.Street__c != null) { emailBodyText += relatedEvent.Street__c + '\n'; }
            if(relatedEvent.City__c != null) { emailBodyText += relatedEvent.City__c + '\n'; }
            if(relatedEvent.Postal_Code__c != null) { emailBodyText += relatedEvent.Postal_Code__c + '\n'; }
            if(relatedEvent.Country__c != null) { emailBodyText += relatedEvent.Country__c + '\n'; }
        }
        
        // Confirmation Link
        emailBodyText += '\nPlease click the following link to confirm your attendance:\n\n';
        emailBodyText += emailRecipient.Email_Sign_Up_Confirmation_Link__c;

        return emailBodyText;
    }
    */



    /*
        @name: createICSInviteAttachment
        @createdBy: Daniel Tilley
        @description: Used to create the ics invite attachement for the e-mail
        
        @param: emailRecipient - the event attendee record
        @param: relatedEvent - the event record

        @returns: Blob - The attachement blob
    */
    /*
    private static Blob createICSInviteAttachment(Training_Event_Attendee__c emailRecipient, Training_Event_Occurrence__c relatedEvent){

        // Event record type to check for later
        String eventType = Schema.SObjectType.Training_Event_Occurrence__c.getRecordTypeInfosById().get(relatedEvent.RecordTypeId).getName();

        String txtInvite = '';
        
        // Ical setup
        txtInvite += 'BEGIN:VCALENDAR\n';
        txtInvite += 'VERSION:2.0\n';
        txtInvite += 'PRODID:-//Salesforce//Training Events Cal//EN\n';
        txtInvite += 'METHOD:PUBLISH\n';
        txtInvite += 'X-MS-OLK-FORCEINSPECTOROPEN:TRUE\n';

        txtInvite += 'BEGIN:VEVENT\n';
        txtInvite += 'CLASS:PUBLIC\n';

        // Event details
        txtInvite += 'UID:' + emailRecipient.Id + '-' + relatedEvent.Id + '-' + Datetime.now().formatGMT('YYYYMMdd\'T\'HH:mm:ssZ') + '\n';
        txtInvite += 'SUMMARY:' + relatedEvent.Training_Event_Name__c + '\n';
        txtInvite += 'SEQUENCE:1\n';
        txtInvite += 'ORGANIZER:' + relatedEvent.Instructor__r.Email + '\n';
        txtInvite += 'DTSTAMP:' + Datetime.now().formatGMT('YYYYMMdd\'T\'HH:mm:ssZ') + '\n';
        txtInvite += 'DTSTART:' + relatedEvent.Start_Date_Time__c.formatGMT('YYYYMMdd\'T\'HH:mm:ssZ') + '\n';
        txtInvite += 'DTEND:'+ relatedEvent.End_Date_Time__c.formatGMT('YYYYMMdd\'T\'HH:mm:ssZ') + '\n';

        if(eventType == 'Virtual'){
            txtInvite += 'LOCATION:Virtual\n';
        }

        if(eventType == 'In Person'){
            txtInvite += 'LOCATION:';

            Boolean addressAdded = false;

            if(relatedEvent.Street__c != null) { txtInvite += relatedEvent.Street__c + ', '; addressAdded = true; }
            if(relatedEvent.City__c != null) { txtInvite += relatedEvent.City__c + ', '; addressAdded = true; }
            if(relatedEvent.Postal_Code__c != null) { txtInvite += relatedEvent.Postal_Code__c + ', '; addressAdded = true; }
            if(relatedEvent.Country__c != null) { txtInvite += relatedEvent.Country__c + ', '; addressAdded = true; }

            if(addressAdded == true) { txtInvite = txtInvite.removeEnd(', '); }

            txtInvite += '\n';
        }

        // More Ical stuff
        txtInvite += 'LANGUAGE=en-us:Salesforce\n';
        txtInvite += 'TRANSP:OPAQUE\n';

        txtInvite += 'X-ALT-DESC;FMTTYPE=text/html:<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN"><HTML><HEAD><META NAME="Generator" CONTENT="MS Exchange Server version 08.00.0681.000"><TITLE></TITLE></HEAD><BODY><!-- Converted from text/plain format --></BODY></HTML>\n';
        txtInvite += 'X-MICROSOFT-CDO-BUSYSTATUS:BUSY\n';
        txtInvite += 'X-MICROSOFT-CDO-IMPORTANCE:1\n';

        // Ical alerts 
        txtInvite += 'BEGIN:VALARM\n';
        txtInvite += 'ACTION:DISPLAY\n';
        txtInvite += 'DESCRIPTION:Test Event\n';
        txtInvite += 'TRIGGER:-PT15M\n';
        txtInvite += 'END:VALARM\n';

        txtInvite += 'END:VEVENT\n';
        txtInvite += 'END:VCALENDAR';
        
        return Blob.valueOf(txtInvite);
    }
    */
}