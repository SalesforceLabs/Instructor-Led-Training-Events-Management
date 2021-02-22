/*
 * Copyright (c) 2022, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

import { LightningElement, track, api } from 'lwc';

export default class DateFilterConatiner extends LightningElement {

    //----------------------------------------------------------------------------------------------------
    // Variables
    //----------------------------------------------------------------------------------------------------

    //**********************************************************************************************
    // Date Variables
    @track todaysDate = new Date();
    @api selectedMonth;
    @api selectedYear;

    monthsList = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]; // months array that holds names of the months (can be changed)

    //**********************************************************************************************
    // Getters
    get monthsPicklistOptions() {
        let optionsList = [];

        this.monthsList.forEach( (item, i)=> {
            optionsList.push({ label: item, value: i.toString(10) });
        });

        return optionsList;
    }

    get yearsPicklistOptions() {
        let optionsList = [];
        let startingYear = parseInt(this.selectedYear) - 2;

        for(let i = 0; i < 5; i++){
            optionsList.push({ label: startingYear + i, value: (startingYear + i).toString(10) });
        }

        return optionsList;
    }

    //----------------------------------------------------------------------------------------------------
    // Onclick / Event Handlers
    //----------------------------------------------------------------------------------------------------

    handleCloseDateSelection(){
        this.dispatchEvent(new CustomEvent('closefilter'));
    }

    handleTodayClicked() {
        this.dispatchEvent(new CustomEvent('todayclicked'));
    }

    handleMonthSelectionChange(event) {
        const monthChangeEvent = new CustomEvent('monthchanged', { detail: parseInt(event.detail.value) });
        this.dispatchEvent(monthChangeEvent);
    }

    handleYearSelectionChange(event){
        const yearChangeEvent = new CustomEvent('yearchanged', { detail: parseInt(event.detail.value) });
        this.dispatchEvent(yearChangeEvent);
    }
}