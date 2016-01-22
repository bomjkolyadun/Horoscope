(function(global) {
  'use strict';

  var spotx = global.spotx = {};

  spotx.assert = console.assert || function(condition, message) {
    if (!condition) {
      throw message || 'assertion failed';
    }
  };

  spotx.isDefined = function isDefined(value) {
    return (value !== null) && (typeof value !== 'undefined');
  };

  spotx.isString = function isString(value) {
    return (typeof value === 'string');
  };

  spotx.isFunction = function isFunction(value) {
    return (typeof value === 'function');
  };

  spotx.hasValue = function hasValue(obj, value) {
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

  spotx.shallowCopy = function shallowCopy(obj) {
    var copy = {}, key;
    for (key in obj) {
      if (obj.hasOwnProperty(key)) {
        copy[key] = obj[key];
      }
    }
    return copy;
  };

  spotx.safeAssign = function safe_assign(target, source) {
    var key;
    for (key in target) {
      if (source.hasOwnProperty(key) && isDefined(source[key])) {
        target[key] = source[key];
      }
    }
    return target;
  };

  spotx.bindAll = function bindAll(obj) {
    var key;
    for (key in obj) {
      if (spotx.isFunction(obj[key])) {
        obj[key] = obj[key].bind(obj);
      }
    }
    return obj;
  };

  spotx.addEventListener = function addEventListener(obj, name, callback) {
    var callbacks = obj[name] || (obj[name] = []);
    callbacks.push(callback);
  };

  spotx.removeEventListener = function removeEventListener(obj, name, callback) {
    var callbacks = obj[name] || (obj[name] = []);
    var index = callbacks.indexOf(callback);
    if (index >= 0) {
      callbacks.splice(index, 1);
    }
  };

  spotx.dispatchEvent = function dispatchEvent(obj, name) {
    var callbacks = obj[name] || (obj[name] = []);
    var args = Array.prototype.slice.call(arguments, 2);
    callbacks.forEach(function(callback) {
      callback.apply(null, args);
    });
  };

})(this.window||global);