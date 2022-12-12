/*
 * Copyright (c) 2022, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

public with sharing class DateWrapper {
    @AuraEnabled
    public Date EventDate { get; set; }

    @AuraEnabled
    public Integer EventDateNum { get; set; }

    @AuraEnabled
    public List<EventWrapper> Events { get; set; }
}