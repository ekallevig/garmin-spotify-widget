using Toybox.Communications as Comm;
using Toybox.Application as App;
using Toybox.Application.Storage;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Timer;


class SpotifyTransaction {

    hidden var _path;
    hidden var _method;
    hidden var _methodName;
    hidden var _parameters;
    hidden var _overrideParams;
    hidden var _notifyRequest;
    hidden var _notifyResponse;

    // Constructor
    // @param delegate TransactionDelegate
    function initialize(path, parameters, method, notifyRequest, notifyResponse) {
        _path = path;
        _methodName = method;
        _parameters = parameters;
        _notifyRequest = notifyRequest;
        _notifyResponse = notifyResponse;
        switch (method) {
            case "PUT":
                _method = Comm.HTTP_REQUEST_METHOD_PUT;
            break;
            case "POST":
                _method = Comm.HTTP_REQUEST_METHOD_POST;
            break;
            default:
                _method = Comm.HTTP_REQUEST_METHOD_GET;
            break;
        }

    }

    // Executes the transaction
    function go(params) {
        _overrideParams = params;
        var finalParams;
        if (params == null) {
            finalParams = _parameters;
        } else {
            finalParams = params;
        }
        Sys.println(_methodName + ": " + _path + " " + finalParams);
        
        var accessToken = Storage.getValue("access_token");
        var url = $.ApiUrl + _path;
        _notifyRequest.invoke(_path);
        Comm.makeWebRequest(
            url,
            finalParams,
            {
                :method=>_method,
                :headers=>{
                    "Authorization"=>"Bearer " + accessToken,
                    "Content-Type"=> Comm.REQUEST_CONTENT_TYPE_JSON
                }
            },
            method(:onResponse)
        );
    }

    // Handles response from server
    function onResponse(responseCode, data) {
        if(responseCode == 200) {
            _overrideParams = null;
            System.println("- 200");
            _notifyResponse.invoke(responseCode, data);
        } else if(responseCode == 204) {
            _overrideParams = null;
            System.println("- 204: no content");
            _notifyResponse.invoke(responseCode, {});
        } else if(responseCode == 401) {
            System.println("- 401: renew token");
            onRenew();
        } else {
            _overrideParams = null;
            System.println("- " + responseCode + ": " + data);
            _notifyResponse.invoke(responseCode, null);
        }
    }

    // Handle renewal of the token
    hidden function onRenew() {
        var refreshToken = Storage.getValue("refresh_token");
        var url = "https://accounts.spotify.com/api/token";
        System.println("POST: api/token");
        _notifyRequest.invoke("api/token");
        Comm.makeWebRequest(
            url,
            {
                "grant_type"=>"refresh_token",
                "refresh_token"=>refreshToken,
                "client_id"=>$.ClientId
            },
            {
                :method => Comm.HTTP_REQUEST_METHOD_POST
            },
            method(:handleRefresh)
        );
    }

    // Updates the access token
    function handleRefresh(responseCode, data) {
        if(responseCode == 200) {
            System.println("- 200: got token");
             // TODO: deal with this calling callbacks expecting original call data (not access token response)
            _notifyResponse.invoke(responseCode, data);
            Storage.setValue("access_token", data["access_token"]);
        } else {
            Sys.println(responseCode.toString());
            _notifyResponse.invoke(responseCode, data);
        }
        // Kick off the transaction again
        go(_overrideParams);
    }

}
