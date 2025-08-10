import { LightningElement, api, wire, track } from 'lwc';

export default class Datatable extends LightningElement {
    // PUBLIC ATTRIBUTES
    @api columns;
    @api recordsList;
    @api recordId;
    @api rowSelection;

    // PRIVATE ATTRIBUTES
    _selectedRowIds;

    /**
    * @description Constructor
    **/
    constructor() {
        super();
        this._selectedRowIds = new Array();
    }

    /**
    * @description Method to handle record select event
    **/
    handleSelectRecord(event) {
        if (event.target.checked) this._selectedRowIds.push(event.target.dataset.id);
        else this._selectedRowIds.splice(this._selectedRowIds.indexOf(event.target.dataset.id), 1);
        this.dispatchEvent(new CustomEvent('selectedrows', {
            detail: {
                selectedRowIds: this._selectedRowIds
            }
        }));
    }

    /**
    * @description Method to check if record exists
    **/
    get hasRecordsExists() {
        return this.recordsList && this.recordsList.length > 0;
    }

}