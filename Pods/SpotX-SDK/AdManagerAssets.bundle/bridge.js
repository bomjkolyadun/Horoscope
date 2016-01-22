(function(global){
  'use strict';

  var spotx = global.spotx;
  if (!spotx) {
    throw 'spotx module must be loaded prior to the MRAID container';
  }

  function jsonRPC(name, data) {
    return {
      jsonrpc: '2.0',
      method: name,
      params: data
    };
  }

  function SpotXBridge(postNativeMessage) {
    var _events = {};

    spotx.assert(spotx.isFunction(postNativeMessage), 'postNativeMessage is not a function');

    this.onMessage = function onMessage(rpc) {
      setTimeout(function() {
        spotx.dispatchEvent(_events, rpc.method, rpc.params);
      }, 50);
    };

    this.postMessage = function postMessage(name, data) {
      postNativeMessage(jsonRPC(name, data));
    };

    this.postNativeMessage = function(rpc) {
      console.info(JSON.stringify(rpc));
    };

    this.register = function(name, callback) {
      spotx.addEventListener(_events, name, callback);
    };

    this.unregister = function(name, callback) {
      spotx.removeEventListener(_events, name, callback);
    };

  }

  SpotXBridge.create = function(postNativeMessage) {
    return new SpotXBridge(postNativeMessage);
  };

  SpotXBridge.createIframeBridge = function(url) {
    url = url || 'spotx://rpc';

    function triggerMessageAvailable() {
      document.body.appendChild(_iframe);
      _frame.remove();
    }

    var _queue = [];

    var _iframe = document.createElement('iframe');
    _iframe.style.display = 'none';
    _frame.src = url;

    var _bridge = new SpotXBridge(function(rpc) {
      _queue.push(rpc);
      triggerMessageAvailable();
    });

    _bridge.messages = function() {
      var messages = JSON.stringify(_queue);
      _queue.length = 0;
      return messages;
    };

    return _bridge;
  };

  global.SpotXBridge = SpotXBridge;

})(this.window||global);