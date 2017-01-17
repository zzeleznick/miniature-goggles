'use strict';

import React from 'react';
// import Company from './Company';
import { BootstrapTable, TableHeaderColumn } from 'react-bootstrap-table';

require('styles/Home.css');
require('styles/Table.css');

const products = [];
const names = ["Basil Pizza", "Pasta", "Red Wine", "Bob's Burger"]
const costs = [12.60, 8.40, 24.00, 51.20, 6.60]
const counts = [3,1,4,2,1,5]
const countOptions = []
for (let i = 1; i <= 10; i++) {
    countOptions.push(i);
}

function addProducts(quantity) {
  const startId = products.length;
  for (let i = 0; i < quantity; i++) {
    const id = startId + i;
    products.push({
      id: id,
      name: id >= names.length ? `Item ${id}` : names[id],
      cost: costs[i % costs.length],
      count: counts[i % counts.length],
      paid: 0
    });
  }
}

addProducts(4);

function onAfterInsertRow(row) {
  let newRowStr = '';
  for (const prop in row) {
    newRowStr += prop + ': ' + row[prop] + ' \n';
  }
  console.log('The new row is:\n ' + newRowStr);
  products.push(row);
}

function onAddRow(row) {
    row.paid = 0;
}

const options = {
  afterInsertRow: onAfterInsertRow,   // A hook for after insert rows
  onAddRow: onAddRow
};

// validator function pass the user input value and should return true|false.
function jobNameValidator(value) {
  const response = { isValid: true, notification: { type: 'success', msg: '', title: '' } };
  if (!value) {
    response.isValid = false;
    response.notification.type = 'error';
    response.notification.msg = 'Name must be present';
    response.notification.title = 'Name Invalid';
  }
  return response;
}

function valueValidator(value) {
  const response = { isValid: true, notification: { type: 'success', msg: '', title: '' } };
  if (!value) {
    response.isValid = false;
    response.notification.type = 'error';
    response.notification.msg = 'Value must be present';
    response.notification.title = 'Invalid Value';
  }
  return response;
}

function priceFormatter(cellValue, row) {
  if (!cellValue || typeof(cellValue) != 'number') {
    return cellValue
  }
  return `<i class='glyphicon glyphicon-usd'></i> ${cellValue.toFixed(2)}`;
}

class InsertRowTable extends React.Component {
  render() {
    return (
      <BootstrapTable data={ products } insertRow={ true } options={ options }>
          <TableHeaderColumn dataField='id' isKey autoValue hidden>Order ID</TableHeaderColumn>
          <TableHeaderColumn dataField='name' editable={{ validator: jobNameValidator }}>Order Name</TableHeaderColumn>
          <TableHeaderColumn dataField='cost' dataFormat={ priceFormatter }
            editable={{ validator: valueValidator }}>Order Cost</TableHeaderColumn>
          <TableHeaderColumn dataField='count' editable={{ type: 'select', options: { values: countOptions }}}>Order Count</TableHeaderColumn>
          <TableHeaderColumn dataField='paid' hiddenOnInsert > Order Paid</TableHeaderColumn>

      </BootstrapTable>
    );
  }
}

const buttonPressed = () => {
    console.log('Button pressed');
    console.log(products);
    let dict = encodeJSON(products);
    console.log(JSON.stringify(dict));
}

const encodeJSON = (items) => {
    let dishNames = items.map((el) => el.name);
    let payload = {items: dishNames}
    Object.keys(items).map( (k) => {
        const {name, cost, count, paid} = items[k];
        if (payload[name]) {
            let [ocost, ocount] = [payload[name].cost, payload[name].count]
            payload[name].cost = (isNaN(ocost) ? 0 : ocost) + ocost;
            payload[name].count = (isNaN(ocount) ? 0 : ocount) + count;
        }
        else {
            payload[name] = {cost: cost, count: count, paid: paid}
        }
    })
    return payload
}

class HomeComponent extends React.Component {
  render() {
    return (
      <div className="home-component">
        <InsertRowTable />
            <div className="toJSON btn-primary btn" onClick={(e) => buttonPressed() }> toJSON </div>
            <div className="JSON-rep"> </div>
      </div>
    );
  }
}

HomeComponent.displayName = 'HomeComponent';

// Uncomment properties you need
// HomeComponent.propTypes = {};
// HomeComponent.defaultProps = {};

export default HomeComponent;
