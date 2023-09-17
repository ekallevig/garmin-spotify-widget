//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
using Toybox.Communications;
using Toybox.System;

class SpotifyCurrentlyPlayingDelegate extends TransactionDelegate {

    function initialize(view) {
        TransactionDelegate.initialize(view);
    }

    function handleResponse(data) {
        TransactionDelegate.handleResponse(data);
        // Construct the model class and populate the results
        var result = new SpotifyModel();
        if (data.hasKey("item")) {
            result.track = data["item"]["name"];
            result.artist = data["item"]["artists"][0]["name"];
        } else {
            result.track = "No Track Playing";
            result.artist = "Select Song in Spotify App";
        }
        // Pass the results onto the view
        _view.updateModel(result);
        // _view = null;
    }

}

class SpotifyCurrentlyPlayingTransaction extends Transaction {

    function initialize(delegate) {
        Transaction.initialize(delegate);
        _path = "me/player/currently-playing";
    }

}
