var firebase = require('firebase/app');

// all 3 are optional and you only need to require them at the start
require('firebase/auth');
require('firebase/database');
require('firebase/storage');

var config = {
    apiKey: "AIzaSyAEfT9bJrgic3ie_i4V58VunyNt-ujAtQQ",
    authDomain: "qr-reader-4cb08.firebaseapp.com",
    databaseURL: "https://qr-reader-4cb08.firebaseio.com",
    storageBucket: "qr-reader-4cb08.appspot.com",
    messagingSenderId: "1092443794249"
  };

firebase.initializeApp(config);

export const DB = firebase.database();

export const AUTH = firebase.auth();