(function InitializeMraid() {
    'use strict';

    /** To allow time to open the debugger in safari **/
 //alert('Open up your safari debugger');

    try {
        /**** MRAID CONSTANTS ****/
        var mraid = window.mraid = {};

        var STATES = mraid.STATES =
        {
            LOADING: 'loading',
            DEFAULT: 'default',
            RESIZED: 'resized',
            EXPANDED: 'expanded',
            HIDDEN: 'hidden'
        };

        var EVENTS = mraid.EVENTS =
        {
            ERROR: 'error',
            READY: 'ready',
            SIZECHANGE: 'sizeChange',
            STATECHANGE: 'stateChange',
            VIEWABLECHANGE: 'viewableChange'
        };

        var CONTROLS = mraid.CONTROLS =
        {
            BACK: 'back',
            FORWARD: 'forward',
            REFRESH: 'refresh',
            ALL: 'all'
        };

        var FEATURES = mraid.FEATURES =
        {
            SMS: 'sms',
            PHONE: 'tel',
            CALENDAR: 'calendar',
            CAMERA: 'storePicture',
            VIDEO: 'inlineVideo'
        };

        var PLACEMENTTYPES = mraid.PLACEMENTTYPES =
        {
            INLINE: 'inline',
            INTERSTITIAL: 'interstitial'
        };

        var VPAIDEVENTS = mraid.VPAIDEVENTS = {
            AD_LOADED: "AdLoaded",
            AD_STARTED: "AdStarted",
            AD_STOPPED: "AdStopped",
            AD_SKIPPED: "AdSkipped",
            AD_LINEAR_CHANGE: "AdLinearChange",
            AD_SIZE_CHANGE: "AdSizeChange",
            AD_EXPANDED_CHANGE: "AdExpandedChange",
            AD_SKIPPABLE_STATE_CHANGE: "AdSkippableStateChange",
            AD_REMAINING_TIME_CHANGE: "AdRemainingTimeChange",
            AD_DURATION_CHANGE: "AdDurationChange",
            AD_VOLUME_CHANGE: "AdVolumeChange",
            AD_IMPRESSION: "AdImpression",
            AD_VIDEO_START: "AdVideoStart",
            AD_VIDEO_FIRST_QUARTILE: "AdVideoFirstQuartile",
            AD_VIDEO_MIDPOINT: "AdVideoMidpoint",
            AD_VIDEO_THIRD_QUARTILE: "AdVideoThirdQuartile",
            AD_VIDEO_COMPLETE: "AdVideoComplete",
            AD_CLICKED: "AdClickThru",
            AD_INTERACTION: "AdInteraction",
            AD_USER_ACCEPT_INVITATION: "AdUserAcceptInvitation",
            AD_USER_MINIMIZE: "AdUserMinimize",
            AD_USER_CLOSE: "AdUserClose",
            AD_PAUSED: "AdPaused",
            AD_PLAYING: "AdPlaying",
            AD_LOG: "AdLog",
            AD_ERROR: "AdError"
        };

        /**** MRAID BRIDGE ****/

        /** The set of listeners for mraid Native Bridge Events **/
        var listeners = {};

        /** A Queue of Calls to the Native SDK that still need execution **/
        var nativeCallQueue = [];

        /** Identifies if a native call is currently in progress **/
        var nativeCallInFlight = false;

        /** timer for identifying iframes **/
        var timer;
        var totalTime;

        /**** SDK CONTROLLED PROPERTIES ****/
        var placementType = PLACEMENTTYPES.INLINE;
        var state = STATES.LOADING;
        var viewable = false;
        var version = "2.0";

        var maxSize =
        {
            width: 0,
            height: 0
        };

        var screenSize =
        {
            width: 0,
            height: 0
        };

        var size =
        {
            width: 0,
            height: 0
        };

        var defaultPosition =
        {
            x: 0,
            y: 0,
            width: 0,
            height: 0
        };

        var currentPosition =
        {
            x: 0,
            y: 0,
            width: 0,
            height: 0
        };

        var expandProperties =
        {
            width: 0,
            height: 0,
            useCustomClose: false,
            isModal: true
        };

        var orientationProperties =
        {
            allowOrientationChange: true,
            forceOrientation: "none"
        };

        var resizeProperties =
        {
            customClosePosition: "top-right",
            allowOffscreen: true
        };

        var supports =
        {
            'sms': true,
            'tel': true,
            'calendar': true,
            'storePicture': true,
            'inlineVideo': true,
            // the following are not required by MRAID
            'orientation': true,
            'network': true,
            'phone': true,
            'email': true,
            'camera': true,
            'audio': true,
            'video': true
        };

        /**** HELPER METHODS ****/
        var clone = function(obj) {
            return JSON.parse(JSON.stringify(obj));
        };

        var isDefined = function(property) {
            return property !== null && typeof property !== "undefined";
        };

        var messages = [];

        var iframe = document.createElement('iframe');
        iframe.style.display = 'none';
        iframe.src = 'spotx://rpc';

        var postMessage = function postMessage(name, data) {
          messages.push(jsonRPC(name, data || {}));
          triggerMessageAvailable();
        };

        var jsonRPC = function jsonRPC(name, data) {
          return {
            jsonrpc: '2.0',
            method: name,
            params: data
          };
        };

        var triggerMessageAvailable = function triggerMessageAvailable() {
          document.body.appendChild(iframe);
          iframe.remove();
        };

        /**** PUBLIC MRAID ****/
        mraid.addEventListener = function(event, listener) {
            var handlers = listeners[event];

            // Create the listeners for the event if not already created
            if (!handlers) {
                listeners[event] = [];
                handlers = listeners[event];
            }

            // Verify handler doesn't already exist
            for (var handler in handlers) {
                if (handler === listener) {
                    return;
                }
            }

            // Add the new listener
            handlers.push(listener);
        };

        mraid.createCalendarEvent = function(details) {
            postMessage("createCalendarEvent", details);
        };

        mraid.close = function() {
            /** to stop the safari debugger from closing **/
                //alert("IM CLOSING");
            postMessage("close", {"state": state});
        };

        mraid.expand = function(url) {
            var expandProps = this.getExpandProperties();
            expandProps.state = state;
            if (url) {
                expandProps.url = url;
            }
            postMessage("expand", expandProps);
        };

        mraid.getCurrentPosition = function() {
            return clone(currentPosition);
        };

        mraid.getDefaultPosition = function() {
            return clone(defaultPosition);
        };

        mraid.getExpandProperties = function() {
            return clone(expandProperties);
        };

        mraid.getMaxSize = function() {
            return clone(maxSize);
        };

        mraid.getOrientationProperties = function() {
            return clone(orientationProperties);
        };

        mraid.getPlacementType = function() {
            return placementType.toString();
        };

        mraid.getResizeProperties = function() {
            return clone(resizeProperties);
        };

        mraid.getScreenSize = function() {
            return clone(screenSize);
        };

        mraid.getState = function() {
            return state.toString();
        };

        mraid.getVersion = function() {
            return version.toString();
        };

        mraid.isViewable = function() {
            return viewable;
        };

        mraid.open = function(url) {
            postMessage("open", {"url": url});
        };

        mraid.playVideo = function(url) {
            // plays video in native player
            if (!url || typeof url != 'string') {
                spotxsdk.fireErrorEvent('Request must specify a URL', 'playVideo');
            }
            else {
                postMessage("playVideo", {"url": url});
            }
        };

        mraid.removeEventListener = function(event, listener) {
            if (listeners.hasOwnProperty(event)) {
                var handlers = listeners[event];
                if (handlers) {
                    if (listener) {
                        var index = handlers.indexOf(listener);
                        if (index !== -1) {
                            handlers.splice(index, 1);
                        }
                    }
                    else {
                        // remove all listeners
                        while (handlers.length > 0) {
                            handlers.pop();
                        }
                    }
                }
            }
        };

        mraid.resize = function() {
            var resizeProps = this.getResizeProperties();
            resizeProps.state = state;
            postMessage("resize", resizeProps);
        };

        mraid.setExpandProperties = function(properties) {
            if (isDefined(properties.width)) {
                expandProperties.width = properties.width;
            }
            if (isDefined(properties.height)) {
                expandProperties.height = properties.height;
            }
            if (isDefined(properties.useCustomClose)) {
                expandProperties.useCustomClose = properties.useCustomClose;
            }
            postMessage("setExpandProperties", expandProperties);
        };

        mraid.setOrientationProperties = function(properties) {
            if (isDefined(properties.allowOrientationChange)) {
                orientationProperties.allowOrientationChange = properties.allowOrientationChange;
            }
            if (isDefined(properties.forceOrientation)) {
                orientationProperties.forceOrientation = properties.forceOrientation;
            }
            postMessage("setOrientationProperties", orientationProperties);
        };

        mraid.setResizeProperties = function(properties) {
            if (isDefined(properties.width)) {
                resizeProperties.width = properties.width;
            }
            if (isDefined(properties.height)) {
                resizeProperties.height = properties.height;
            }
            if (isDefined(properties.offsetX)) {
                resizeProperties.offsetX = properties.offsetX;
            }
            if (isDefined(properties.offsetY)) {
                resizeProperties.offsetY = properties.offsetY;
            }
            if (isDefined(properties.customClosePosition)) {
                resizeProperties.customClosePosition = properties.customClosePosition;
            }
            if (isDefined(properties.allowOffscreen)) {
                resizeProperties.allowOffscreen = properties.allowOffscreen;
            }
        };

        mraid.storePicture = function(url) {
            postMessage("storePicture", {"url": url});
        };

        mraid.supports = function(feature) {
            return supports[feature];
        };

        mraid.useCustomClose = function(useCustomClose) {
            expandProperties.useCustomClose = useCustomClose;
            postMessage("useCustomClose", {"useCustomClose": useCustomClose});
        };

        /**** iOS SDK METHODS ****/

            // Non-MRAID methods
        window.spotxsdk = (window.spotx || {});

        // used for precached ads to not autoplay,
        // can be set in spotxsdk.initializeAD()
        // always assume to autoplay
        spotxsdk.autoPlay = true;
        spotxsdk.startFired = false;

        spotxsdk.fireErrorEvent = function(message, action) {
            this.fireEvent(EVENTS.ERROR, message, action);
        };

        spotxsdk.fireReadyEvent = function() {
            this.fireEvent(EVENTS.READY);
        };

        spotxsdk.fireSizeChangeEvent = function(newSize) {
            size = newSize;
            this.fireEvent(EVENTS.SIZECHANGE, size.width, size.height);
        };

        spotxsdk.fireStateChangeEvent = function(newState) {
            // fire state change first
            this.fireEvent(EVENTS.STATECHANGE, newState);

            if (state === STATES.LOADING && newState === STATES.DEFAULT) {
                this.fireReadyEvent();
            }

            state = newState;
        };

        spotxsdk.fireViewableChangeEvent = function(newViewable) {
            viewable = newViewable;
            this.fireEvent(EVENTS.VIEWABLECHANGE, viewable);
        };

        spotxsdk.fireEvent = function(event) {
            console.log("Fire Event: " + event);

            var handlers = listeners[event];
            if (handlers) {
                for (var i = 0; i < handlers.length; ++i) {
                    if (arguments.length == 1) {
                        handlers[i]();
                    }
                    else if (arguments.length == 2) {
                        handlers[i](arguments[1]);
                    }
                    else if (arguments.length == 3) {
                        handlers[i](arguments[1], arguments[2]);
                    }
                }
            }
        };

        spotxsdk.setCurrentPosition = function(value) {
            currentPosition = value;
        };

        spotxsdk.setDefaultPosition = function(value) {
            defaultPosition = value;
        };

        spotxsdk.setMaxSize = function(value) {
            maxSize = value;
        };

        spotxsdk.setPlacementType = function(value) {
            placementType = value;
        };

        spotxsdk.setScreenSize = function(value) {
            screenSize = value;
        };

        spotxsdk.setSize = function(value) {
            size = value;
        };

        spotxsdk.play = function() {
            window.oAdOS.startAd();
        };

        spotxsdk.init = function() {
            window.oAdOS.initAd(
                width,
                height,
                bitrate,
                ENVVARS
            );
        };

        spotxsdk.adLoaded = function() {
            // the ad has been loaded with no error
            console.log("iOS SDK: spotxsdk.adLoaded()");
            postMessage("adLoaded");
            // the iOS SDK will take care of starting the ad after the ad has loaded
            /*
             if(spotxsdk.autoPlay)
             {
             spotxsdk.startAd();
             }
             */
        };

        spotxsdk.startAd = function() {
            console.log("iOS SDK: spotxsdk.startAd()");

            if (!spotxsdk.startFired) {
                postMessage("adStarted");
                spotxsdk.startFired = true;
            }

            //spotxsdk.oSDKAdOS.subscribe(spotxsdk.adStarted, VPAIDEVENTS.AD_STARTED);

            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_LOADED);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_STARTED);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_STOPPED);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_SKIPPED);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_LINEAR_CHANGE);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_SIZE_CHANGE);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_EXPANDED_CHANGE);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_SKIPPABLE_STATE_CHANGE);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_REMAINING_TIME_CHANGE);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_DURATION_CHANGE);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_VOLUME_CHANGE);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_IMPRESSION);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_VIDEO_START);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_VIDEO_FIRST_QUARTILE);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_VIDEO_MIDPOINT);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_VIDEO_THIRD_QUARTILE);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_VIDEO_COMPLETE);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_CLICKED);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_INTERACTION);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_USER_ACCEPT_INVITATION);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_USER_MINIMIZE);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_USER_CLOSE);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_PAUSED);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_PLAYING);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_LOG);
            spotxsdk.subscribeVpaid(VPAIDEVENTS.AD_ERROR);

            spotxsdk.oSDKAdOS.startAd();

            return "Ad started";
        };

        spotxsdk.stopAd = function() {
            console.log("iOS SDK: spotxsdk.stopAd()");
            spotxsdk.oSDKAdOS.stopAd();
            spotxsdk.startFired = false;
            return "Ad stopped";
        };

        spotxsdk.pauseAd = function() {
            console.log("iOS SDK: spotxsdk.pauseAd()");
            spotxsdk.oSDKAdOS.pauseAd();
            return "Ad paused";
        };

        spotxsdk.resumeAd = function() {
            console.log("iOS SDK: spotxsdk.resumeAd()");
            spotxsdk.oSDKAdOS.resumeAd();
            return "Ad resumed";
        };

        spotxsdk.adError = function() {
            console.log("iOS SDK: spotxsdk.adError()");
            // AFTER we send an error, let's just use mraid.close to shut it down
            postMessage("adError");
            mraid.close();
            spotxsdk.startFired = false;
            return "Ad error";
        };

        spotxsdk.adCompleted = function() {
            postMessage("adCompleted");
            spotxsdk.startFired = false;
        };

        spotxsdk.getMessages = function getMessages() {
          var json = JSON.stringify(messages);
          messages.length = 0;
          return json;
        };

        // also takes in an 'autoplay' boolean, used for precached ads
        spotxsdk.initializeAd = function() {
            // check if autoplay bool is passed in, assume always autoplay
            if (arguments.length !== 0) {
                spotxsdk.autoPlay = Boolean(arguments[0]);
            }
            oEnvVars.autoplay = spotxsdk.autoPlay;
            // get the ad from the MRAID AdOS
            console.log("iOS SDK: getMRAIDAd(" + iContentWidth + ", " + iContentHeight + ")");
            spotxsdk.oSDKAdOS = getMRAIDAd(
                iContentWidth,
                iContentHeight,
                oEnvVars.media_transcoding,
                0,
                JSON.stringify(oCreativeData),
                oEnvVars
            );

            // subscribe to VPAID events
            spotxsdk.oSDKAdOS.subscribe(spotxsdk.adLoaded, VPAIDEVENTS.AD_LOADED);
            spotxsdk.oSDKAdOS.subscribe(spotxsdk.startAd, VPAIDEVENTS.AD_STARTED);
            spotxsdk.oSDKAdOS.subscribe(spotxsdk.adCompleted, VPAIDEVENTS.AD_VIDEO_COMPLETE);
            spotxsdk.oSDKAdOS.subscribe(mraid.close, VPAIDEVENTS.AD_STOPPED);
            spotxsdk.oSDKAdOS.subscribe(spotxsdk.adError, VPAIDEVENTS.AD_ERROR);

            // initialize the ad
            console.log("iOS SDK: oSDKAdOS.initAd()");
            spotxsdk.oSDKAdOS.initAd(
                iContentWidth,
                iContentHeight,
                strViewMode,
                0,
                JSON.stringify(oCreativeData),
                oEnvVars
            );
        };

        spotxsdk.verifyCache = function() {
            postMessage("verifyCache");
        };

        spotxsdk.subscribeVpaid = function(e) {
            spotxsdk.oSDKAdOS.subscribe(function() {
                postMessage("passVpaidEvent", {"event": e});
            }, e);
        };

        // set the default state
        spotxsdk.fireStateChangeEvent("default");
    }
    catch (oError) {
        console.log("iOS SDK MRAID.js JS Error!");
        console.log(oError);
    }

})();
