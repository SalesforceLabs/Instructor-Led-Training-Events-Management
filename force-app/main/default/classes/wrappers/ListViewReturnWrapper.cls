/*
 * Copyright (c) 2022, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

public with sharing class ListViewReturnWrapper {
    @AuraEnabled
    public List<EventWrapper> allEvents { get; set; }

    @AuraEnabled
    public List<EventWrapper> myEvents { get; set; }
}
