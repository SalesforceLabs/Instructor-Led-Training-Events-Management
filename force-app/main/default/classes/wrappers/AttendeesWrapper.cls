/*
 * Copyright (c) 2022, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

public with sharing class AttendeesWrapper {
    @AuraEnabled
    public String Id { get; set; }

    @AuraEnabled
    public String Name { get; set; }

    @AuraEnabled
    public String EmailAddress { get; set; }

    @AuraEnabled
    public Boolean SignUpConfirmed { get; set; }

    @AuraEnabled
    public Boolean AttendanceConfirmed { get; set; }
}
