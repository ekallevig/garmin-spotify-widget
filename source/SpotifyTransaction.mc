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
using Toybox.WatchUi as Ui;

// Base class for the TransactionDelegate
class TransactionDelegate {
    var relatedView;

    function initialize(view) {
        relatedView = view;
    }

    // Function to put error handling
    function handleError(error) {
        relatedView.findDrawableById("responseCode").setText(error);
        Ui.requestUpdate();
    }

    // Function to put response handling
    function handleResponse(responseCode, data) {
        relatedView.findDrawableById("responseCode").setText(responseCode.toString());
        Ui.requestUpdate();
    }

    // Function to put response handling
    function handleRequest(data) {
        relatedView.findDrawableById("status").setText(data);
        relatedView.findDrawableById("responseCode").setText("...");
        Ui.requestUpdate();    }
}

// Base class for transactions to an OAUTH API
class Transaction
{
    hidden var _path;
    hidden var _method = Comm.HTTP_REQUEST_METHOD_GET;
    hidden var _methodName;
    hidden var _parameters;
    hidden var _delegate;

    // Constructor
    // @param delegate TransactionDelegate
    function initialize(delegate) {
        _delegate = delegate;
        switch (_method) {
            case 1:
                _methodName = "GET";
            break;
            case 2:
                _methodName = "PUT";
            break;
            case 3:
                _methodName = "POST";
            break;
        }
    }

    // Executes the transaction
    function go() {
        System.println(_methodName + ": " + _path);
        var accessToken = App.getApp().getProperty("access_token");
        var url = $.ApiUrl + _path;
        _delegate.handleRequest(_path);
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
            System.println("- 200");
            _delegate.handleResponse(responseCode, data);
        } else if(responseCode == 204) {
            System.println("- 204: no content");
            _delegate.handleResponse(responseCode, {});
        } else if(responseCode == 401) {
            System.println("- 401: renew token");
            onRenew();
        } else {
            System.println("- " + responseCode + ": " + data);
            _delegate.handleError(responseCode.toString());
        }
    }

    // Handle renewal of the token
    hidden function onRenew() {
        var refreshToken = App.getApp().getProperty("refresh_token");
        var url = "https://accounts.spotify.com/api/token";
        System.println("POST: api/token");
        _delegate.handleRequest("api/token");
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
            System.println("- 200: got token");
            _delegate.handleResponse(responseCode, data);
            App.getApp().setProperty("access_token", data["access_token"]);
        } else {
            Sys.println(responseCode.toString());
            _delegate.handleResponse("- " + responseCode, data);
        }
        // Kick off the transaction again
        go();
    }

    function refreshCurrentlyPlaying() {
        _delegate.relatedView._transaction.go();
    }

}