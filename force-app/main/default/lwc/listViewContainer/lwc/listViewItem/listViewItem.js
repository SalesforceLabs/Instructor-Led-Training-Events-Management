/*
 * Copyright (c) 2022, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

import { LightningElement, api } from 'lwc';

export default class ListViewItem extends LightningElement {

    @api currentEvent;

    handleShowMoreClicked(){
        const showMoreEvent = new CustomEvent('showmoreclicked', { detail: this.currentEvent });
        this.dispatchEvent(showMoreEvent);
    }
}