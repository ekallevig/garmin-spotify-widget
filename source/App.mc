using Toybox.Application as App;
using Toybox.Communications as Comms;
using Toybox.Timer;
using Toybox.WatchUi;

const ApiUrl = "https://api.spotify.com/v1/";
const RedirectUri = "http://localhost";

// The Application class is the bootstrap for the
// widget. It handles app lifecycle
class SpotifyWidget extends App.AppBase {

    hidden var _connectionCheckTimer;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
        if (_connectionCheckTimer != null) {
            _connectionCheckTimer.stop();
        }
    }

    function checkConnection() {
        var isConnected = System.getDeviceSettings().phoneConnected;
        System.println("phone connected: " + isConnected);
        if (isConnected) {
            _connectionCheckTimer.stop();
            _connectionCheckTimer = null;
            System.println("phone now connected, loading login view");
            setup(null);
            // return [ new LoginView(), new LoginDelegate() ];
        }
    }

    function setup(init) {
        // Needed when developing in sim because sim's oauth browser
        // doesn't support JS, which spotify's auth page needs.
        // Storage.setValue("refresh_token", $.RefreshToken);
        var token = Storage.getValue("refresh_token");

        if(!System.getDeviceSettings().phoneConnected) {
            if (_connectionCheckTimer == null) {
                _connectionCheckTimer = new Timer.Timer();
                _connectionCheckTimer.start(method(:checkConnection), 2000, true);
            }
            System.println("no phone connection, gcm view");
            if (init) {
                return [new ConnectToGcmView() ];
            } else {
                WatchUi.switchToView(new ConnectToGcmView(), null, WatchUi.SLIDE_IMMEDIATE);
            }
        } else if (token == null) {
            System.println("no refresh token, login view");
            if (init) {
                return [ new LoginView(), new LoginDelegate() ];
            } else {
                WatchUi.switchToView(new LoginView(), new LoginDelegate(), WatchUi.SLIDE_IMMEDIATE);
            }
        } else {
            System.println("refresh token found, player view");
            var view = new SpotifyPlayerView();
            if (init) {
                return [ view, new SpotifyPlayerDelegate(view) ];
            } else {
                WatchUi.switchToView(view, new SpotifyPlayerDelegate(view), WatchUi.SLIDE_IMMEDIATE);
            }
        }
    }

    // Return the initial view of your application here
    function getInitialView() {
        return setup(true);
    }

}
