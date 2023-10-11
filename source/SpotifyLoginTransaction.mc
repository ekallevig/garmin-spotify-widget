//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
using Toybox.Communications as Comm;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Application.Storage;

// The LoginTransaction is a special transaction that handles
// getting the OAUTH token.
class LoginTransaction {
    hidden var _delegate;
    hidden var _complete;
    hidden var _state;
    hidden var _codeVerifier;

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
    function accessCodeResult(msg) {
        if (msg.data != null) {
            _complete = true;
            System.println("authorize resp code: " + msg.data["code"]);
            System.println("authorize resp state: " + msg.data["state"]);
            getAccessToken(msg.data["code"], msg.data["state"]);
        } else {
            Sys.println("Error in accessCodeResult");
            Sys.println("data = " + msg.data);
            _delegate.handleError(msg.responseCode);
        }
    }

    // Convert the authorization code to the access token
    function getAccessToken(accessCode, state) {
        if (!state.equals(_state)) {
            System.println("state mismatch: " + state + " != " + _state);
            handleAccessResponse(401, null);
        }
        var params = {
                "code"=>accessCode,
                "redirect_uri"=>$.RedirectUri,
                "grant_type"=>"authorization_code",
                "client_id"=>$.ClientId,
                "code_verifier"=>_codeVerifier
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
                :method => Comm.HTTP_REQUEST_METHOD_POST
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

        // Generate PKCE code verifier/challenge
        // https://developer.spotify.com/documentation/web-api/tutorials/code-pkce-flow
        _codeVerifier = generateRandomString(128);
        var codeChallenge = generateHash(_codeVerifier);
        var sanitizedChallenge = stringReplace(codeChallenge, "/", "_");
        sanitizedChallenge = stringReplace(sanitizedChallenge, "+", "-");
        sanitizedChallenge = stringReplace(sanitizedChallenge, "=", "");

        _state = generateRandomString(16);
        System.println("_state: " + _state);
        System.println("_codeVerifier: " + _codeVerifier);
        System.println("codeChallenge: " + codeChallenge);
        System.println("sanitizedChallenge: " + sanitizedChallenge);

        var params = {
                "client_id"=>$.ClientId,
                "response_type"=>"code",
                "scope"=>"user-modify-playback-state,user-read-playback-state,user-read-currently-playing,playlist-read-private,user-library-modify",
                "redirect_uri"=>$.RedirectUri,
                "state"=>_state,
                "code_challenge_method"=>"S256",
                "code_challenge"=>sanitizedChallenge
        };
        System.println(params.toString());
        Comm.makeOAuthRequest(
            "https://accounts.spotify.com/authorize",
            params,
            $.RedirectUri,
            Comm.OAUTH_RESULT_TYPE_URL,
            {"code"=>"code", "state"=>"state"}
        );
    }
}


// This is a TransactionDelegate for handling the login
class LoginTransactionDelegate extends Ui.BehaviorDelegate {

    // Handle a error from the server
    function handleError(code) {
        // var msg = WatchUi.loadResource( Rez.Strings.error );
        // msg += code;
        Ui.switchToView(new ErrorView("Error: " + code), null, Ui.SLIDE_IMMEDIATE);
    }

    // Handle a successful response from the server
    function handleResponse(responseCode, data) {

        // Store the access and refresh tokens in properties
        // For app store apps the properties are encrypted using
        // a randomly generated key
        Storage.setValue("refresh_token", data["refresh_token"]);
        Storage.setValue("access_token", data["access_token"]);

        // Switch to the data view
        var view = new SpotifyPlayerView();
        Ui.switchToView(view, new SpotifyPlayerDelegate(view), Ui.SLIDE_IMMEDIATE);
    }

}