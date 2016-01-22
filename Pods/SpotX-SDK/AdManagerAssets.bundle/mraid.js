(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
'use strict';
var util = require('./util.js');

function jsonRPC(name, data) {
  return {
    jsonrpc: '2.0',
    method: name,
    params: data
  };
}

module.exports = function (callback) {
  var _events = {};

  this.onMessage = function onMessage(rpc) {
    setTimeout(function() {
      callback(rpc.method, rpc.params);
    }, 50);
  };
  var postNativeMessage = function(){};

  this.postMessage = function postMessage(name, data) {
    postNativeMessage(jsonRPC(name, data));
  };


  this.initialize = function(settings, nativeCallback) {
    util.assert(util.isFunction(postNativeMessage));
    postNativeMessage = nativeCallback;
  };

  this.initializeIframeBridge = function(settings, url) {
    url = url || 'spotx://rpc';

    function triggerMessageAvailable() {
      document.body.appendChild(_iframe);
      _iframe.remove();
    }

    var _queue = [];

    var _iframe = document.createElement('iframe');
    _iframe.style.display = 'none';
    _iframe.src = url;

    this.initialize(settings, function(rpc) {
      _queue.push(rpc);
      triggerMessageAvailable();
    });

    this.messages = function() {
      var messages = JSON.stringify(_queue);
      _queue.length = 0;
      return messages;
    };
  };

}

},{"./util.js":4}],2:[function(require,module,exports){
(function() {
  'use strict';

  window.mraid = require('./mraid.js').create();

})();

},{"./mraid.js":3}],3:[function(require,module,exports){
'use strict';
var util = require('./util.js');
var Bridge = require('./bridge.js');


//- Utility Functions

function size(width, height) {
  return {
    width: width || 0,
    height: height || 0
  };
}

function rect(x, y, width, height) {
  return {
    x: x || 0,
    y: y || 0,
    width: width || 0,
    height: height || 0
  };
}


//-

var STATES = {
  LOADING: 'loading',
  DEFAULT: 'default',
  RESIZED: 'resized',
  EXPANDED: 'expanded',
  HIDDEN: 'hidden'
};

var EVENTS = {
  ERROR: 'error',
  READY: 'ready',
  CLOSE: 'close',
  SIZECHANGE: 'sizeChange',
  STATECHANGE: 'stateChange',
  VIEWABLECHANGE: 'viewableChange'
};

var CONTROLS = {
  BACK: 'back',
  FORWARD: 'forward',
  REFRESH: 'refresh',
  ALL: 'all'
};


var FEATURES = {
  SMS: 'sms',
  PHONE: 'tel',
  CALENDAR: 'calendar',
  CAMERA: 'storePicture',
  VIDEO: 'inlineVideo'
};

var PLACEMENT_TYPES = {
  INLINE: 'inline',
  INTERSTITIAL: 'interstitial'
};

var VPAID_EVENTS = {
  AD_LOADED: 'AdLoaded',
  AD_STARTED: 'AdStarted',
  AD_STOPPED: 'AdStopped',
  AD_SKIPPED: 'AdSkipped',
  AD_LINEAR_CHANGE: 'AdLinearChange',
  AD_SIZE_CHANGE: 'AdSizeChange',
  AD_EXPANDED_CHANGE: 'AdExpandedChange',
  AD_SKIPPABLE_STATE_CHANGE: 'AdSkippableStateChange',
  AD_REMAINING_TIME_CHANGE: 'AdRemainingTimeChange',
  AD_DURATION_CHANGE: 'AdDurationChange',
  AD_VOLUME_CHANGE: 'AdVolumeChange',
  AD_IMPRESSION: 'AdImpression',
  AD_VIDEO_START: 'AdVideoStart',
  AD_VIDEO_FIRST_QUARTILE: 'AdVideoFirstQuartile',
  AD_VIDEO_MIDPOINT: 'AdVideoMidpoint',
  AD_VIDEO_THIRD_QUARTILE: 'AdVideoThirdQuartile',
  AD_VIDEO_COMPLETE: 'AdVideoComplete',
  AD_CLICKED: 'AdClickThru',
  AD_INTERACTION: 'AdInteraction',
  AD_USER_ACCEPT_INVITATION: 'AdUserAcceptInvitation',
  AD_USER_MINIMIZE: 'AdUserMinimize',
  AD_USER_CLOSE: 'AdUserClose',
  AD_PAUSED: 'AdPaused',
  AD_PLAYING: 'AdPlaying',
  AD_LOG: 'AdLog',
  AD_ERROR: 'AdError'
};


//- MRAID Interface

function Mraid(settings) {
  var that = this;

  this._events = {};

  this._state = STATES.LOADING;
  this._placementType = PLACEMENT_TYPES.INTERSTITIAL;

  this._size = size(0, 0);
  this._max_size = size(0, 0);
  this._screen_size = size(0, 0);

  this._currentPosition = rect(0, 0, 0, 0);
  this._defaultPosition = rect(0, 0, 0, 0);

  this._expandProperties = {
    width: 0,
    height: 0,
    useCustomClose: false,
    isModal: true
  };

  this._orientationProperties = {
    allowOrientationChange: true,
    forceOrientation: 'none'
  };

  this._resizeProperties = {
    customClosePosition: 'top-right',
    allowOffscreen: true
  };

  this.initialize = function(settings, postNativeMessage, doc) {
    console.log("MRAID Init");
    var that = this;
    this._bridge = new Bridge(function(name, params){
      switch(name) {
        case EVENTS.VIEWABLECHANGE:
          setViewable(params.viewable);
          break;
        case EVENTS.SIZECHANGE:
          setSize(params.width, params.height);
          break;
        case 'sdk_ready':
          that._debug = !!params.debug;
          that._supports = params.supports;
          util.dispatchEvent(that._events, EVENTS.READY);
          break;
      }
    });
    if(util.isFunction(postNativeMessage)) {
      this._bridge.initialize({}, postNativeMessage);
    }
    else {
      this._bridge.initializeIframeBridge(settings);
    }
    this._debug = settings.debug;
    this._version = settings.version || '1.0';
    this._supports = settings.supports || {};
    this._viewable = settings.viewable || false;
    this._state = STATES.DEFAULT;

    var setViewable = function(viewable){
      that._viewable = viewable;
      console.log('Viewability changed  ' + viewable);
      util.dispatchEvent(that._events, EVENTS.VIEWABLECHANGE, that._viewable);
    };

    var setSize = function(width, height) {
      that._currentPosition.width = width;
      that._currentPosition.height = height;
      util.dispatchEvent(that._events, EVENTS.SIZECHANGE, width, height);
    };

    /*
    var closeButton = doc.createElement("a");
    closeButton.innerHTML = '\u274E'; // Negative Squared Cross Mark emoji
    closeButton.style.position = 'absolute';
    closeButton.style.right = 0;
    closeButton.style.top = 0;
    closeButton.style['font-size'] = '50px';
    closeButton.style['z-index'] = 9101;
    closeButton.addEventListener("click", this.close.bind(this), false);
    */

    this._showCloseButton = function() {
      //doc.body.appendChild(closeButton);
    }

    this._hideCloseButton = function() {
      //closeButton.style['visibility'] = 'hidden';
    }

    this._bridge.postMessage('sdk_loaded');
  }
}

Mraid.prototype.addEventListener = function addEventListener(event, callback) {
  util.addEventListener(this._events, event, callback);
};

Mraid.prototype.removeEventListener = function removeEventListener(event, callback) {
  util.removeEventListener(this._events, event, callback);
};

Mraid.prototype.getVersion = function() {
  return this._version;
};

Mraid.prototype.supports = function(feature) {
  return this._supports[feature];
};

Mraid.prototype.getState = function() {
  return this._state;
};

Mraid.prototype.isViewable = function() {
  if(this._state === STATES.LOADING){
    return false;
  }
  return this._viewable;
};


Mraid.prototype.createCalendarEvent = function createCalendarEvent(details) {
  this._bridge.postMessage('createCalendarEvent', details);
};

Mraid.prototype.close = function() {
  this._bridge.postMessage('close');
};

Mraid.prototype.expand = function(url) {
};

Mraid.prototype.getCurrentPosition = function() {
  if(this._state === STATES.LOADING){
    return;
  }
  return util.shallowCopy(this._currentPosition);
};

Mraid.prototype.getDefaultPosition = function() {
  if(this._state === STATES.LOADING){
    return;
  }
  return util.shallowCopy(this._defaultPosition);
};

Mraid.prototype.getExpandProperties = function() {
  if(this._state === STATES.LOADING){
    return;
  }
  return util.shallowCopy(this._expandProperties);
};

Mraid.prototype.getMaxSize = function() {
  if(this._state === STATES.LOADING){
    return;
  }
  return util.shallowCopy(this._max_size);
};

Mraid.prototype.getOrientationProperties = function() {
  if(this._state === STATES.LOADING){
    return;
  }
  return util.shallowCopy(this._orientationProperties);
};

Mraid.prototype.getPlacementType = function() {
  if(this._state === STATES.LOADING){
    return;
  }
  return this._placementType;
};

Mraid.prototype.getResizeProperties = function() {
  if(this._state === STATES.LOADING){
    return;
  }
  return util.shallowCopy(this._resizeProperties);
};

Mraid.prototype.getScreenSize = function() {
  if(this._state === STATES.LOADING){
    return;
  }
  return util.shallowCopy(this._screen_size);
};

Mraid.prototype.open = function(url) {
  if(this._state === STATES.LOADING){
    return;
  }
  this._bridge.postMessage('openUrl', { url: url });
};

Mraid.prototype.playVideo = function(url) {
  if(this._state === STATES.LOADING){
    return;
  }
  if (util.isString(url)) {
    this._bridge.postMessage('playVideo', { url: url });
  }
  else {
    util.dispatchEvent(this._events, EVENTS.ERROR, 'invalid URL: ' + url, 'playVideo');
  }
};

Mraid.prototype.resize = function() {
  if(this._state === STATES.LOADING){
    return;
  }
};

Mraid.prototype.setExpandProperties = function(properties) {
  if(this._state === STATES.LOADING){
    return;
  }
  util.safeAssign(this._expandProperties, properties);
};

Mraid.prototype.setOrientationProperties = function(properties) {
  if(this._state === STATES.LOADING){
    return;
  }
  util.safeAssign(this._orientationProperties, properties);
  this._bridge.postMessage('setOrientationProperties', properties);
};

Mraid.prototype.setResizeProperties = function(properties) {
  if(this._state === STATES.LOADING){
    return;
  }
  util.safeAssign(this._resizeProperties, properties);
};

Mraid.prototype.storePicture = function(url) {
  if(this._state === STATES.LOADING){
    return;
  }
  this._bridge.postMessage('storePicture', {'url': url});
};

Mraid.prototype.useCustomClose = function(useCustomClose) {
  if(this._state === STATES.LOADING){
    return;
  }

  this._hideCloseButton();

  this._bridge.postMessage('useCustomClose', {'state': useCustomClose});
};

// MRAID 2.0 with Video Addendum
Mraid.prototype.initVpaid = function (oVpaid) {
    var $this = this;
    var callback = function (event) {
        $this._bridge.postMessage('vpaidEvent', {'event': event});
    }

    for(var event in VPAID_EVENTS) {
        oVpaid.subscribe(callback.bind(null, VPAID_EVENTS[event]), VPAID_EVENTS[event]);
    }

    oVpaid.subscribe(this._showCloseButton, VPAID_EVENTS['AD_STARTED']);

    this._vpaid = oVpaid;
};

/* SpotXchange MRAID Extensions */

Mraid.prototype.fireBeacon = function (method, url, data)
{
    this._bridge.postMessage('fireBeacon',
        {
            'method': method,
            'url': url,
            'postData': data
        });
}

Mraid.prototype.startAd = function() {
  if (this._vpaid) {
    this._vpaid.startAd();
  }
}

Mraid.prototype.skipAd = function() {
  if (this._vpaid) {
    this._vpaid.skipAd();
  }
}


//- Exported Interface

module.exports = {
  version: '1.0',
  create: function() {
    var mraid = new Mraid();
    return util.bindAll(mraid);
  }
};

},{"./bridge.js":1,"./util.js":4}],4:[function(require,module,exports){
//- Exported Interface

var util = exports;

util.assert = function(condition, message) {
  if (!condition) {
    throw message || 'assertion failed';
  }
};

util.isDefined = function isDefined(value) {
  return (value !== null) && (typeof value !== 'undefined');
};

util.isString = function isString(value) {
  return (typeof value === 'string');
};

util.isFunction = function isFunction(value) {
  return (typeof value === 'function');
};

util.isObject = function isFunction(value) {
  return (typeof value === 'object');
};

util.hasValue = function hasValue(obj, value) {
  var key;
  for (key in obj) {
    if (obj.hasOwnProperty(key)) {
      if (obj[key] === value) {
        return true;
      }
    }
  }
  return false;
};

util.shallowCopy = function shallowCopy(obj) {
  var copy = {}, key;
  for (key in obj) {
    if (obj.hasOwnProperty(key)) {
      copy[key] = obj[key];
    }
  }
  return copy;
};

util.safeAssign = function safe_assign(target, source) {
  var key;
  for (key in target) {
    if (source.hasOwnProperty(key) && util.isDefined(source[key])) {
      target[key] = source[key];
    }
  }
  return target;
};

util.bindAll = function bindAll(obj) {
  var key;
  for (key in obj) {
    if (util.isFunction(obj[key])) {
      obj[key] = obj[key].bind(obj);
    }
  }
  return obj;
};

util.addEventListener = function addEventListener(obj, name, callback) {
  var callbacks = obj[name] || (obj[name] = []);
  callbacks.push(callback);
};

util.removeEventListener = function removeEventListener(obj, name, callback) {
  var callbacks = obj[name] || (obj[name] = []);
  var index = callbacks.indexOf(callback);
  if (index >= 0) {
    callbacks.splice(index, 1);
  }
};

util.dispatchEvent = function dispatchEvent(obj, name) {
  var callbacks = obj[name] || (obj[name] = []);
  var args = Array.prototype.slice.call(arguments, 2);
  callbacks.forEach(function(callback) {
    callback.apply(null, args);
  });
};

},{}]},{},[2]);

window.document.addEventListener('DOMContentLoaded', function(event) {
  window.mraid.initialize({}, undefined, window.document);
});