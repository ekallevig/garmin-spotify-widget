//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
using Toybox.Communications;
using Toybox.System;

class SpotifyCurrentlyPlayingDelegate extends TransactionDelegate {

    var result;

    function initialize(view) {
        TransactionDelegate.initialize(view);
        result = new SpotifyModel();
    }

    function handleResponse(responseCode, data) {
        TransactionDelegate.handleResponse(responseCode, data);
        // Construct the model class and populate the results
        if (data.hasKey("item")) {
            var track = data["item"]["name"];
            var artist = data["item"]["artists"][0]["name"];
            System.println("- song: " + track);
            System.println("- artist: " + artist);

            // Truncate song/artist if too long
            if (track.length() > 25) {
                track = track.substring(0, 25) + "...";
            }
            result.track = track;
            if (artist.length() > 25) {
                artist = artist.substring(0, 25) + "...";
            }
            result.artist = artist;
        } else {
            result.track = "No Active Player";
            result.artist = "Start Song in Spotify App";
        }
        // Pass the results onto the view
        relatedView.updateModel(result);
    }

}

class SpotifyCurrentlyPlayingTransaction extends Transaction {

    function initialize(delegate) {
        Transaction.initialize(delegate);
        _path = "me/player/currently-playing";
    }

}
