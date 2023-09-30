using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Graphics;

// Store global reference to View
var playerView = null;

// Main view for the application
class SpotifyPlayerView extends Ui.View {

    hidden var _context = $.DEFAULT_CONTEXT_LABEL;
    hidden var _progress = null;
    hidden var _currentTrack = $.LOADING_LABEL;
    hidden var _currentArtist = "";
    hidden var _isPlaying = false;
    hidden var _hasActivePlayer = false;
    hidden var _status = "";
    hidden var _responseCode = "";
    hidden var _button;

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
        var view = View.findDrawableById("context");
        view.setText(_context);
        view = View.findDrawableById("track");
        view.setText(_currentTrack);
        view = View.findDrawableById("artist");
        view.setText(_currentArtist);

        // Update play/pause buttons
        var play = setButtonState("playButton");
        var pause = setButtonState("pauseButton");
        if (!_isPlaying) {
            play.show();
            pause.hide();
        } else {
            play.hide();
            pause.show();
        }

        // Update default/disabled states for remaining buttons
        setButtonState("addButton");
        setButtonState("nextButton");
        setButtonState("previousButton");

        // // Update status/codes/progress
        view = View.findDrawableById("progressLabel");
        var progressBg = View.findDrawableById("progressBackground");
        if (_progress == null) {
            view.setVisible(false);
            progressBg.setVisible(false);
        } else {
            view.setText(_progress);
            view.setVisible(true);
            progressBg.setVisible(true);
        }
        view = View.findDrawableById("status");
        view.setText(_status);
        view = View.findDrawableById("responseCode");
        view.setText(_responseCode);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    function setButtonState(id) {
        var button = View.findDrawableById(id);
        if (_hasActivePlayer) {
            button.setState(:stateDefault);
        } else {
            button.setState(:stateDisabled);
        }
        return button;
    }

    function onReceiveCurrentlyPlaying(track, artist, isPlaying) {
        if (track != null) {
            _currentTrack = track;
        }
        if (artist != null) {
            _currentArtist = artist;
        }
        _hasActivePlayer = track != NO_PLAYER_LABEL;
        _isPlaying = isPlaying;
        Ui.requestUpdate();
    }

    function onReceiveContext(context) {
        _context = context;
        Ui.requestUpdate();
    }

    function onReceiveProgress(progress) {
        _progress = progress;
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


// Main view for the application
class SpotifyPlayerButton extends Ui.Button {

    var initLocX;
    var initLocY;

    function initialize(settings) {
        Ui.Button.initialize(settings);
        initLocX = settings[:locX];
        initLocY = settings[:locY];
    }

    function show() {
        locX = initLocX;
        locY = initLocY;
    }

    function hide() {
        locX = -width;
        locY = -height;
    }

}
