require('styles/Modal.css');

import React from 'react';

class ModalComponent extends React.Component {
  constructor(props) {
    super(props);
    // let initial = props.isOpen !== undefined ? props.isOpen : false
    this.state = { isOpen: false, isClosing: false};
    this.open = this.open.bind(this);
    this.close = this.close.bind(this);
    this.submit = this.submit.bind(this);
  }
  close() {
    const { isOpen } = this.state;
    const {callback} = this.props;
    if (isOpen) {
      this.setState({isOpen: false, isClosing:true});
      callback(false);
    }
  }
  open(event) {
    console.log('Received request for user requests modal open');
    this.setState({isOpen: true, isClosing:false});
  }
  submit() {
    const {callback} = this.props;
    callback(true);
  }
  componentWillMount() {
    let self = this;
    const { registerOpen, registerClose } = this.props;
    document.addEventListener('keydown', function(ev) {
        var keyCode = ev.keyCode || ev.which;
        if(keyCode === 27) { // escape
            self.close();
        }
    });
    registerOpen(this.open);
    registerClose(this.close);
  }
  componentWillUnmount() {
  }
  render() {
    const { children, callback } = this.props;
    const { isOpen, isClosing } = this.state;
    let content = children;
    let additional = isOpen ? ' dialog--open' : (isClosing ? ' dialog--close': '')
    if (!content) {
        content = <h2><strong>Howdy</strong>, I'm a dialog box</h2>
    }
    return (
      <div className="modal-component">
        <div className={"dialog" + additional}>
            <div className="dialog__overlay"></div>
            <div className="dialog__content">
                { content }
                <div className='action-wrapper'>
                    <button className="action"
                    onClick={this.submit}> Submit</button>
                    <i className="fa fa-times" onClick={this.close}></i>
                </div>
            </div>
        </div>
      </div>
    );
  }
}

ModalComponent.displayName = 'ModalComponent';

// Uncomment properties you need
// ModalComponent.propTypes = {};
// ModalComponent.defaultProps = {};

export default ModalComponent;