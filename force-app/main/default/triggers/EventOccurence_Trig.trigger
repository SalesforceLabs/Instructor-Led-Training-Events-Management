/*
 * Copyright (c) 2022, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

trigger EventOccurence_Trig on Training_Event_Occurrence__c (before insert) {
    
    for(Training_Event_Occurrence__c newOccurance : Trigger.New){
        if(newOccurance.Attendance_Confirmation_Code__c == null) {
            newOccurance.Attendance_Confirmation_Code__c = EventOccuranceCtrl.generateAttendanceConfirmationCode(6);
        }

        System.debug(newOccurance.Id);
    }
}