import { LightningElement, api, wire, track  } from 'lwc';

export default class DatatableData extends LightningElement {
    @api column;
    @api record;

    // PRIVATE ATTRIBUTES
    _isLink;
    _isCurrency;
    _isDate;
    _isText;
    _isNumber;
    _isPercent;
    _recordValue;
    _recordId;

    /**
    * @description Connected Callback Method
    **/
    connectedCallback() {
        // set field type
        this.setFieldType();
        this.setData();
    }

    /**
    * @description Method to set fieldType
    **/
    setFieldType () {
        if (this.column.type.toLowerCase() == 'text') {
            this._isText = true;
        } else if (this.column.type.toLowerCase() == 'currency') {
            this._isCurrency = true;
        } else if (this.column.type.toLowerCase() == 'date') {
            this._isDate = true;
        } else if (this.column.type.toLowerCase() == 'link') {
            this._isLink = true;
        } else if (this.column.type.toLowerCase() == 'number') {
            this._isNumber = true;
        } else if (this.column.type.toLowerCase() == 'percent') {
            this._isPercent = true;
        } 
    }

    /**
    * @description Method to set data
    **/
    setData () {
        if (this.column.name.indexOf('.') == -1) {
            this._recordValue = this.record[this.column.name] != undefined ? this.record[this.column.name] : '';
        } else {
            let fieldsList = this.column.name.split('.');
            if (fieldsList.length == 5) {
                this._recordValue = (this.record[fieldsList[0]] ? (this.record[fieldsList[0]][fieldsList[1]] ? (this.record[fieldsList[0]][fieldsList[1]][fieldsList[2]] ? (this.record[fieldsList[0]][fieldsList[1]][fieldsList[2]] ? (this.record[fieldsList[0]][fieldsList[1]][fieldsList[2]][fieldsList[3]] ? (this.record[fieldsList[0]][fieldsList[1]][fieldsList[2]][fieldsList[3]] ? (this.record[fieldsList[0]][fieldsList[1]][fieldsList[2]][fieldsList[3]][fieldsList[4]] ? this.record[fieldsList[0]][fieldsList[1]][fieldsList[2]][fieldsList[3]][fieldsList[4]] : '') : '') : '') : '') : '') : '') : '');
            } else if (fieldsList.length == 4) {
                this._recordValue = (this.record[fieldsList[0]] ? (this.record[fieldsList[0]][fieldsList[1]] ? (this.record[fieldsList[0]][fieldsList[1]][fieldsList[2]] ? (this.record[fieldsList[0]][fieldsList[1]][fieldsList[2]] ? (this.record[fieldsList[0]][fieldsList[1]][fieldsList[2]][fieldsList[3]] ? this.record[fieldsList[0]][fieldsList[1]][fieldsList[2]][fieldsList[3]] : '') : '') : '') : '') : '');
            } else if (fieldsList.length == 3) {
                this._recordValue = (this.record[fieldsList[0]] ? (this.record[fieldsList[0]][fieldsList[1]] ? (this.record[fieldsList[0]][fieldsList[1]][fieldsList[2]] ? this.record[fieldsList[0]][fieldsList[1]][fieldsList[2]] : '') : '') : '');
                if (this._isLink) this._recordId = window.location.origin+'/'+this.record[fieldsList[0]][fieldsList[1]]['Id'];
            } else if (fieldsList.length == 2) {
                this._recordValue = (this.record[fieldsList[0]] ? (this.record[fieldsList[0]][fieldsList[1]] ? this.record[fieldsList[0]][fieldsList[1]] : '') : '');
                if (this._isLink) this._recordId = window.location.origin+'/'+this.record[fieldsList[0]]['Id'];
            } 
        }

        if (this.column.type.toLowerCase() == 'percent' && this._recordValue) {
            this._recordValue = this._recordValue / 100;
        } 
    }
}