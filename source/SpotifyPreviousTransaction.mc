//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
using Toybox.Communications;
using Toybox.System;
using Toybox.Timer;

class SpotifyPreviousTransaction extends Transaction {

    hidden var _method = Communications.HTTP_REQUEST_METHOD_POST;

    function initialize(delegate) {
        Transaction.initialize(delegate);
        _path = "me/player/previous";
    }

    function onResponse(responseCode, data) {
        Transaction.onResponse(responseCode, data);
        if(responseCode == 204) {

            // Delay call to currently-playing b/c sometimes it doesn't
            // update fast enough after the next/prev call.
            var myTimer = new Timer.Timer();
            myTimer.start(method(:refreshCurrentlyPlaying), 500, false);
        }
    }
}
