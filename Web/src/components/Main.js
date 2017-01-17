require('normalize.css/normalize.css');
require('font-awesome-webpack');
require('styles/App.css');

import React from 'react';
import HomeComponent from './HomeComponent';

class AppComponent extends React.Component {
  render() {
    return (
      <div className="index">
        <HomeComponent />
      </div>
    );
  }
}

AppComponent.defaultProps = {
};

export default AppComponent;
