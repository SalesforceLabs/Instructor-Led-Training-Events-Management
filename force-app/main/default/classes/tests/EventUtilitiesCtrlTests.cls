/*
 * Copyright (c) 2022, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

@isTest
public class EventUtilitiesCtrlTests {


    
    @isTest
    static void isEventSignUpExternalTest(){
        System.assertEquals(true, EventUtilitiesCtrl.isEventSignUpExternal('https://mydomaintest.force.com'), 'URL is not correctly verified');
    }



    @isTest
    static void isEventSignUpExternalNegativeTest(){
        System.assertEquals(false, EventUtilitiesCtrl.isEventSignUpExternal(System.URL.getOrgDomainUrl().toExternalForm()), 'URL is not correctly verified');
    }
}
