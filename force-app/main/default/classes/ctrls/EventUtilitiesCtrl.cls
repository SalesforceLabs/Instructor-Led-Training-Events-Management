/*
 * Copyright (c) 2022, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

public with sharing class EventUtilitiesCtrl {

    /*
        @name: isEventSignUpExternal
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
}