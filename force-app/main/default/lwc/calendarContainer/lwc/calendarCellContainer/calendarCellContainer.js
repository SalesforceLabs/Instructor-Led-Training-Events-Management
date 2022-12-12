/*
 * Copyright (c) 2022, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

import { LightningElement, api } from 'lwc';

export default class CalendarCellContainer extends LightningElement {

    //----------------------------------------------------------------------------------------------------
    // Variables
    //----------------------------------------------------------------------------------------------------
    
    /**
     * @type {Object} : {
        calOptions: {
            allowEventCreation: Boolean
        },
        cellId: num,
        cssTileClass: text,
        cssClasses: {
            element: 'class-name'
        }
        data: {
            numItems: num,
            numHiddenItems: num,
            shortList: array -> obj,
            fullList: array -> obj,
            
                e.g: {
                    { Id: 1, Name: 'Test 1', StartTime: '08.00 am', EndTime: '09.00am'}
                }
        },
        date: text,
        dateNumber: text,
    }
    */
    @api currentCellData; // cell data passed from parent

    //**********************************************************************************************
    // GETTERS
    get anyDataToShow() {
        return this.currentCellData.data.numItems !== 0;
    }

    get extraItemsToShow() {
        return this.currentCellData.data.numHiddenItems !==0;
    }

    get dateBlockClass(){
        return this.currentCellData.cssClasses.dateBlock;
    }

    get dateNumberClass() {
        return this.currentCellData.cssClasses.dateNumberText;
    }

    //----------------------------------------------------------------------------------------------------
    // Onclick Handlers
    //----------------------------------------------------------------------------------------------------

    eventClicked(event) {
        this.dispatchEvent(new CustomEvent("openselectmodal", { detail: { type: 'event', modalData : this.currentCellData.data.shortList[event.currentTarget.dataset.id] }}));
    }

    showMoreEventsClicked() {
        this.dispatchEvent(new CustomEvent("openselectmodal", { detail: { type: 'events', modalData : this.currentCellData }}));
    }

    eventDateClicked() {
        if(this.currentCellData.date !== '' && this.currentCellData.dateNumber !== '' && this.currentCellData.calOptions.allowEventCreation === true){
            this.dispatchEvent(new CustomEvent("eventdateclicked", { detail: { type: 'events', modalData : this.currentCellData }}));   
        }
    }
}