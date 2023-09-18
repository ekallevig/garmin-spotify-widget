//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
using Toybox.Communications as Comm;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Application as App;

// The LoginTransaction is a special transaction that handles
// getting the OAUTH token.
class LoginTransaction
{
    hidden var _delegate;
    hidden var _complete;

    // Constructor
    function initialize(delegate) {
        _delegate = delegate;
        _complete = false;
        // Register a callback to handle a response from the
        // OAUTH request. If there is a response waiting this
        // will fire right away
        Comm.registerForOAuthMessages(method(:accessCodeResult));
    }

    // Handle converting the authorization code to the access token
    // @param value Content of JSON response
    function accessCodeResult(value) {
        if( value.data != null) {
            _complete = true;
            System.println("accessCode value: " + value.toString());
            // Extract the access code from the JSON response
            getAccessToken(value.data["value"]);
        }
        else {
            Sys.println("Error in accessCodeResult");
            Sys.println("data = " + value.data);
            _delegate.handleError(value.responseCode);
        }
    }

    // Convert the authorization code to the access token
    function getAccessToken(accessCode) {
        var params = {
                "code"=>accessCode,
                "redirect_uri"=>$.RedirectUri,
                "grant_type"=>"authorization_code"
        };
        System.println(params.toString());
        // Make HTTPS POST request to request the access token
        Comm.makeWebRequest(
            // URL
            "https://accounts.spotify.com/api/token",
            // Post parameters
            params,
            // Options to the request
            {
                :method => Comm.HTTP_REQUEST_METHOD_POST,
                :headers=>{ "Authorization"=>"Basic " + $.TokenAuthHash }
            },
            // Callback to handle response
            method(:handleAccessResponse)
        );
    }


    // Callback to handle receiving the access code
    function handleAccessResponse(responseCode, data) {
        // If we got data back then we were successful. Otherwise
        // pass the error onto the delegate
        if( data != null) {
            _delegate.handleResponse(responseCode, data);
        } else {
            Sys.println("Error in handleAccessResponse");
            Sys.println("data = " + data);
            _delegate.handleError(responseCode);
        }
    }

    // Method to kick off tranaction
    function go() {
        // Kick of a request for the user's credentials. This will
        // cause a notification from Connect Mobile to file
        var params = {
                "client_id"=>$.ClientId,
                "response_type"=>"code",
                "scope"=>"user-modify-playback-state,user-read-playback-state,user-read-currently-playing",
                "redirect_uri"=>$.RedirectUri
        };
        System.println(params.toString());
        Comm.makeOAuthRequest(
            // URL for the authorization URL
            "https://accounts.spotify.com/authorize",
            // POST parameters
            params,
            // {
            //     "client_id"=>$.ClientId,
            //     "response_type"=>"code",
            //     "scope"=>"public",
            //     "redirect_uri"=>$.RedirectUri
            // },
            // Redirect URL
            $.RedirectUri,
            // Response type
            Comm.OAUTH_RESULT_TYPE_URL,
            // Value to look for
            {"code"=>"value"}
            );
    }
}


// This is a TransactionDelegate for handling the login
class LoginTransactionDelegate extends TransactionDelegate{

    // Handle a error from the server
    function handleError(code) {
        var msg = WatchUi.loadResource( Rez.Strings.error );
        msg += code;
        Ui.switchToView(new ErrorView(msg), null, Ui.SLIDE_IMMEDIATE);
    }

    // Handle a successful response from the server
    function handleResponse(responseCode, data) {
        // Store the access and refresh tokens in properties
        // For app store apps the properties are encrypted using
        // a randomly generated key
        App.getApp().setProperty("refresh_token", data["refresh_token"]);
        App.getApp().setProperty("access_token", data["access_token"]);
        // Switch to the data view
        Ui.switchToView(new SpotifyView(), new SpotifyButtonDelegate(), Ui.SLIDE_IMMEDIATE);
    }

}