//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
using Toybox.Application as App;

const ApiUrl = "https://api.spotify.com/v1/";
const RedirectUri = "http://localhost";

// The Application class is the bootstrap for the
// widget. It handles app lifecycle
class SpotifyWidget extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        // setProperty("refresh_token", $.RefreshToken);
        var token = getProperty("refresh_token");

        if(!System.getDeviceSettings().phoneConnected) {
            return [new ConnectToGcmView() ];
        } else if ( token == null ) {
            return [ new LoginView(), new LoginDelegate() ];
        } else {
            return [ new SpotifyView(), new SpotifyButtonDelegate() ];
        }
    }

}
