'use strict';

import React from 'react';
// import Company from './Company';
import { BootstrapTable, TableHeaderColumn } from 'react-bootstrap-table';
import { DB } from '../sources/fire';

require('styles/Home.css');
require('styles/Table.css');

const products = [];
let names = ['Sushi',
'Steak',
'Entrecote',
'Ramen',
'Fried Rice',
'Chicken Curry',
'Rice with beans',
'Buttered spinach',
'Caprese Salad',
'Penne al pommodoro',
'Naan serving',
'Fuze Tea',
'Quinoa Salad',
'Chocolate croissant',
'Cappuccino',
'Fries',
'Milkshake',
'Chocolate Fondant',
'Shawarma Laffa',
'Falafel on the plate']

function shuffle(array) {
  var currentIndex = array.length, temporaryValue, randomIndex;
  // While there remain elements to shuffle...
  while (0 !== currentIndex) {
    // Pick a remaining element...
    randomIndex = Math.floor(Math.random() * currentIndex);
    currentIndex -= 1;

    // And swap it with the current element.
    temporaryValue = array[currentIndex];
    array[currentIndex] = array[randomIndex];
    array[randomIndex] = temporaryValue;
  }
  return array;
}
names = shuffle(names);
//['Basil Pizza', 'Pasta', 'Red Wine', 'Bob's Burger']
let costs = [12.60, 3.10, 5.25, 8.40, 4.30, 1.20, 6.60]
costs = shuffle(costs);
let counts = [3,1,4,2,1,5]
const countOptions = []
for (let i = 1; i <= 10; i++) {
    countOptions.push(i);
}
const roomID = (Math.random() * 1000).toString().replace('.', '').slice(0,6)
let orderCount = parseInt(Math.random() * (10)) + 2;

function addProducts(quantity) {
  const startId = products.length;
  for (let i = 0; i < quantity; i++) {
    const id = startId + i;
    const count = counts[i % counts.length];
    products.push({
      id: id,
      name: id >= names.length ? `Item ${id}` : names[id],
      cost: costs[i % costs.length] * count,
      count: count,
      paid: 0
    });
  }
}
addProducts(orderCount);


DB.ref().on('value', (snapshot) => {
      let val = snapshot.val();
      if (val) {
        console.log(`DICT: ${JSON.stringify(val, null, 4)}`);
      }
});

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

const fireButtonPressed = () => {
    console.log('Fire Button pressed');
    console.log(products);
    let dict = encodeJSON(products);
    console.log(JSON.stringify(dict));
    DB.ref(`${roomID}`).set(dict);
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
    const roomString = `Room ${roomID}`
    return (
      <div className='home-component'>
        <h4 className='room'> {roomString} </h4>
        <InsertRowTable />
            <div className='toJSON btn-primary btn' onClick={(e) => buttonPressed() }> toJSON </div>
            <div className='toFB btn-primary btn' onClick={(e) => fireButtonPressed() }> push </div>

      </div>
    );
  }
}

HomeComponent.displayName = 'HomeComponent';

// Uncomment properties you need
// HomeComponent.propTypes = {};
// HomeComponent.defaultProps = {};

export default HomeComponent;
