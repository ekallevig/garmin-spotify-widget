//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
using Toybox.Communications as Comm;
using Toybox.Application as App;
using Toybox.System as Sys;

// Base class for the TransactionDelegate
class TransactionDelegate {
    hidden var _view;

    function initialize(view) {
        _view = view;
    }

    // Function to put error handling
    function handleError(error) {
        _view.findDrawableById("error").setText(error);
        // _view.findDrawableById("track").setText(error);
    }

    // Function to put response handling
    function handleResponse(data) {
        _view.findDrawableById("error").setText("");
    }
}

// Base class for transactions to an OAUTH API
class Transaction
{
    hidden var _path;
    hidden var _method = Comm.HTTP_REQUEST_METHOD_GET;
    hidden var _parameters;
    hidden var _delegate;

    // Constructor
    // @param delegate TransactionDelegate
    function initialize(delegate) {
        _delegate = delegate;
        // switch (name) {
        //     case "play":
        //         _method = Communications.HTTP_REQUEST_METHOD_PUT;
        //         _path = "me/player/play";
        //     break;
        // }
    }

    // Executes the transaction
    function go() {
        System.println("transaction go()");
        var accessToken = App.getApp().getProperty("access_token");
        var url = $.ApiUrl + _path;

        Comm.makeWebRequest(
            url,
            _parameters,
            {
                :method=>_method,
                :headers=>{ "Authorization"=>"Bearer " + accessToken }
            },
            method(:onResponse)
        );
    }

    // Handles response from server
    function onResponse(responseCode, data) {
        if(responseCode == 200) {
            System.println("200: " + data);
            _delegate.handleResponse(data);
        } else if(responseCode == 204) {
            System.println("204: no content");
            _delegate.handleResponse({});
        } else if(responseCode == 401) {
            System.println("401: renew token");
            onRenew();
        } else {
            System.println(responseCode + ": " + data);
            _delegate.handleError(responseCode.toString());
        }
    }

    // Handle renewal of the token
    hidden function onRenew() {
        var refreshToken = App.getApp().getProperty("refresh_token");
        var url = "https://accounts.spotify.com/api/token";
        Comm.makeWebRequest(
            url,
            {
                "grant_type"=>"refresh_token",
                "refresh_token"=>refreshToken
            },
            {
                :method => Comm.HTTP_REQUEST_METHOD_POST,
                :headers=>{ "Authorization"=>"Basic " + $.TokenAuthHash }
            },
            method(:handleRefresh)
        );
    }

    // Updates the access token
    function handleRefresh(responseCode, data) {
        if(responseCode == 200) {
            // App.getApp().setProperty("refresh_token", data["refresh_token"]);
            App.getApp().setProperty("access_token", data["access_token"]);
        } else {
            Sys.println("Received code " + responseCode);
        }
        // Kick off the transaction again
        go();
    }

}