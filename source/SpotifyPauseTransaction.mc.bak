//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
using Toybox.Communications;
using Toybox.System;

class SpotifyPauseTransaction extends Transaction {

    hidden var _method = Communications.HTTP_REQUEST_METHOD_PUT;

    function initialize(delegate) {
        Transaction.initialize(delegate);
        _path = "me/player/pause";
    }

}
