/*
 * Copyright (c) 2022, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

public with sharing class EventAttendeeReturnWrapper {
    @AuraEnabled
    public Id eventAttendeeId { get; set; }

    @AuraEnabled
    public Boolean signUpAlreadyConfirmed { get; set; }

    @AuraEnabled
    public Boolean signUpConfirmed { get; set; }

    @AuraEnabled
    public Boolean noRecordFound { get; set; }
}
