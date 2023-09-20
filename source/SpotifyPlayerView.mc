using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Lang as Lang;

// Store global reference to View
var playerView = null;

// Main view for the application
class SpotifyPlayerView extends Ui.View {

    hidden var _currentTrack = "Loading player...";
    hidden var _currentArtist = "";
    hidden var _isPlaying = false;
    hidden var _status = "";
    hidden var _responseCode = "";

    function initialize() {
        View.initialize();

        // Initialize global reference
        playerView = self;

    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.Summary(dc));
    }

    // Update the view
    function onUpdate(dc) {

        // Update currently playing info
        var view = View.findDrawableById("track");
        view.setText(_currentTrack);
        view = View.findDrawableById("artist");
        view.setText(_currentArtist);

        // Update play/pause buttons
        // view = View.findDrawableById("play");
        // view.setVisible(!_isPlaying);

        // Update status/codes
        view = View.findDrawableById("status");
        view.setText(_status);
        view = View.findDrawableById("responseCode");
        view.setText(_responseCode);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    function onReceiveCurrentlyPlaying(track, artist, isPlaying) {
        _currentTrack = track;
        _currentArtist = artist;
        _isPlaying = isPlaying;
        Ui.requestUpdate();
    }

    function onReceiveStatus(status) {
        _status = status;
        _responseCode = "...";
        Ui.requestUpdate();
    }

    function onReceiveResponseCode(responseCode) {
        _responseCode = responseCode;
        Ui.requestUpdate();
    }

}
