/*
 * Copyright (c) 2022, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

import { LightningElement, api } from 'lwc';

export default class DateDisplayBlock extends LightningElement {

    //----------------------------------------------------------------------------------------------------
    // Variables
    //----------------------------------------------------------------------------------------------------

    //**********************************************************************************************
    // Constant values
    monthsList = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]; // months array that holds names of the months (can be changed)

    //**********************************************************************************************
    // Date Variables
    @api currentMonth;
    @api currentYear;

    //**********************************************************************************************
    // Getters
    get currentMonthLabel() { return this.monthsList[this.currentMonth]; } // used to display the month label to the user
    


    //----------------------------------------------------------------------------------------------------
    // Onclick / Event Handlers
    //----------------------------------------------------------------------------------------------------
    previousMonthClicked(){
        let currentYear = (this.currentMonth === 0) ? this.currentYear - 1 : this.currentYear;
        let currentMonth = (this.currentMonth === 0) ? 11 : this.currentMonth - 1;

        const monthChangeEvent = new CustomEvent('monthchanged', { detail: currentMonth });
        this.dispatchEvent(monthChangeEvent);

        const yearChangeEvent = new CustomEvent('yearchanged', { detail: currentYear });
        this.dispatchEvent(yearChangeEvent);
    }

    nextMonthClicked(){
        let currentYear = (this.currentMonth === 11) ? this.currentYear + 1 : this.currentYear;
        let currentMonth = (this.currentMonth + 1) % 12;

        const monthChangeEvent = new CustomEvent('monthchanged', { detail: currentMonth });
        this.dispatchEvent(monthChangeEvent);

        const yearChangeEvent = new CustomEvent('yearchanged', { detail: currentYear });
        this.dispatchEvent(yearChangeEvent);
    }

    handleDateTextSelected(){
        this.dispatchEvent(new CustomEvent('dateselected'));
    }
}