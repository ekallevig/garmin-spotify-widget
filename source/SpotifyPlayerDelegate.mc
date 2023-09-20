using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class SpotifyPlayerDelegate extends Ui.BehaviorDelegate {

    hidden var _view;
    hidden var _currentlyPlayingTransaction; // TODO: get play/pause status to combine buttons
    hidden var _playTransaction;
    hidden var _pauseTransaction;
    hidden var _nextTransaction;
    hidden var _previousTransaction;
    // hidden var _saveTransaction; // TODO: add save button
    // hidden var _shuffleTransaction; // TODO: add shuffle button

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
        _currentlyPlayingTransaction = new SpotifyTransaction(
            "me/player/currently-playing",
            null,
            "GET",
            method(:onReceiveRequest),
            method(:onReceiveCurrentlyPlayingResponse)
        );
        _currentlyPlayingTransaction.go(null);
        // _playTransaction = new SpotifyPlayTransaction(method(:onReceiveCurrentlyPlaying));
        // _pauseTransaction = new SpotifyPauseTransaction( new TransactionDelegate(self) );
        // _previousTransaction = new SpotifyPreviousTransaction( new TransactionDelegate(self) );
        // _nextTransaction = new SpotifyNextTransaction( new TransactionDelegate(self) );
    }

    function onReceiveRequest(path) {
        _view.onReceiveStatus(path);
    }

    function onReceiveResponse(responseCode, data) {
        _view.onReceiveResponseCode(responseCode.toString());
    }

    function onSelectable(event) {

        // Needed when developing in sim because sim has bug preventing
        // buttons from resetting to default state on touch screens.
        event.getInstance().setState(:stateDefault);
        event.getInstance().setVisible(false);
    }

    function onMenu() {

        // WatchUi.pushView(new SpotifyPlaylistsView(), new SpotifyPlaylistsInputDelegate(), WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    function onRefreshButton() {
        // System.println("onRefreshButton");
        _currentlyPlayingTransaction.go(null);
        return false;
    }

    function onReceiveCurrentlyPlayingResponse(responseCode, data) {
        _view.onReceiveResponseCode(responseCode.toString());
        if (data.hasKey("item")) {
            var track = data["item"]["name"];
            var artist = data["item"]["artists"][0]["name"];
            System.println("- song: " + track);
            System.println("- artist: " + artist);

            // Truncate song/artist if too long
            if (track.length() > 25) {
                track = track.substring(0, 25) + "...";
            }
            if (artist.length() > 25) {
                artist = artist.substring(0, 25) + "...";
            }
            _view.onReceiveCurrentlyPlaying(track, artist, data["isPlaying"]);
        } else {
            _view.onReceiveCurrentlyPlaying("No Active Player", "Start Song in Spotify App", false);
        }

    }

    function onPlayButton() {
        // System.println("onPlay");
        var txn = new SpotifyTransaction(
            "me/player/play",
            null,
            "PUT",
            method(:onReceiveRequest),
            method(:onReceiveResponse)
        );
        txn.go(null);
        return false;
    }

    function onPauseButton() {
        // System.println("onPause");
        var txn = new SpotifyTransaction(
            "me/player/pause",
            null,
            "PUT",
            method(:onReceiveRequest),
            method(:onReceiveResponse)
        );
        txn.go(null);
        return false;
    }

    function onPreviousButton() {
        // System.println("onPrevious");
        var txn = new SpotifyTransaction(
            "me/player/previous",
            null,
            "POST",
            method(:onReceiveRequest),
            method(:onReceiveNextResponse)
        );
        txn.go(null);
        return false;
    }

    function onNextButton() {
        // System.println("onNext");
        Ui.showToast("Next song!", null);
        var txn = new SpotifyTransaction(
            "me/player/next",
            null,
            "POST",
            method(:onReceiveRequest),
            method(:onReceiveNextResponse)
        );
        txn.go(null);
        return false;
    }

    function onReceiveNextResponse(responseCode, data) {
        onReceiveResponse(responseCode, data);
        delayedRefreshCurrentlyPlaying();
    }

    function refreshCurrentlyPlaying() {
       _currentlyPlayingTransaction.go(null);
    }

    function delayedRefreshCurrentlyPlaying() {

        // Delay call to currently-playing b/c sometimes it doesn't
        // update fast enough after the previous api call.
        var myTimer = new Timer.Timer();
        myTimer.start(method(:refreshCurrentlyPlaying), 500, false);
    }

}
