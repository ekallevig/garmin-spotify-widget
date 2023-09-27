using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Timer;
using Toybox.Application.Storage;

class SpotifyPlayerDelegate extends Ui.BehaviorDelegate {

    hidden var _view;
    hidden var _currentlyPlayingTransaction;
    hidden var _currentTrack;
    hidden var _currentRefreshTimer = new Timer.Timer();
    hidden var _isPlaying = false;
    hidden var _menuView;
    hidden var _playlistsBatch = new [0];
    // hidden var _saveTransaction; // TODO: add save button
    // hidden var _shuffleTransaction; // TODO: add shuffle button

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
        _currentlyPlayingTransaction = new SpotifyTransaction(
            "me/player",
            {
                "market" => "US"
            },
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
    }

    function onMenu() {
        var storedPlaylists = Storage.getValue("playlists");
        if (storedPlaylists == null) {
            System.println("onmenu, storedPlaylists == null");
            getPlaylists(null, null);
        } else {
            System.println("onmenu, storedPlaylists has contnet");
            _menuView = new SpotifyPlaylistsMenu(storedPlaylists);
            WatchUi.pushView(_menuView, new SpotifyPlaylistsMenuDelegate(method(:onMenuItem)), WatchUi.SLIDE_IMMEDIATE);
        }
        return true;
    }

    function onMenuItem(item) {
        var txn = new SpotifyTransaction(
            "me/player/play",
            {
                "context_uri"=>item.getId()
            },
            "PUT",
            method(:onReceiveRequest),
            method(:onReceiveRefreshNeededResponse)
        );
        txn.go(null);
    }

    function getPlaylists(limit, offset) {
        System.println("limit offset " + limit + " " + offset);
        var txn = new SpotifyTransaction(
            "me/playlists",
            {
                "limit" => limit == null ? 5 : limit,
                "offset" => offset == null ? 0 : offset
            },
            "GET",
            method(:onReceiveRequest),
            method(:onReceivePlaylistsResponse)
        );
        txn.go(null);
    }

    function onReceivePlaylistsResponse(responseCode, data) {
        _view.onReceiveResponseCode(responseCode.toString());
        if (data == null) {
            System.println("onReceivePlaylistsResponse data == null");
        } else if (data.hasKey("items") && data["items"].size() > 0) {
            System.println("onReceivePlaylistsResponse data[items].size() > 0");
            var items = data["items"];
            for( var i = 0; i < items.size(); i++ ) {
                _playlistsBatch.add({
                    "n" => items[i]["name"],
                    "u" => items[i]["uri"]
                });
            }
            if (_playlistsBatch.size() > 50) {
                System.println("onReceivePlaylistsResponse _playlistsBatch > 50, set storage, onmenu");
                Storage.setValue("playlists", _playlistsBatch);
                onMenu();
            } else {
                System.println("onReceivePlaylistsResponse _playlistsBatch < 50, get more");
                getPlaylists(data["limit"], data["offset"] + data["limit"]);
            }
        } else {
            System.println("onReceivePlaylistsResponse data != null but no data[items], set storage, onmenu");
            Storage.setValue("playlists", _playlistsBatch);
            onMenu();
        }
    }

    function onRefreshButton() {
        // System.println("onRefreshButton");
        _currentlyPlayingTransaction.go(null);
        return false;
    }

    function startRefreshTimer() {
        if (_isPlaying) {            
            System.println("startRefreshTimer");
            _currentRefreshTimer.start(method(:refreshCurrentlyPlaying), 10000, true);
        }
    }

    function stopRefreshTimer() {
            System.println("stopRefreshTimer");
        _currentRefreshTimer.stop();
    }

    function onReceiveCurrentlyPlayingResponse(responseCode, data) {
        _view.onReceiveResponseCode(responseCode.toString());
        if (data != null && data.hasKey("item")) {
            _currentTrack = data["item"];
            _isPlaying = data["is_playing"];
            if (_isPlaying) {
                startRefreshTimer();
            } else {
                stopRefreshTimer();
            }
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
            _view.onReceiveCurrentlyPlaying(track, artist, data["is_playing"]);

            // Get context info
            getContextInfo(data["context"]["uri"]);
        } else {
            _currentTrack = null;
            _isPlaying = false;
            stopRefreshTimer();
            _view.onReceiveCurrentlyPlaying($.NO_PLAYER_LABEL, $.NO_PLAYER_SUB_LABEL, false);
        }

    }

    function getContextInfo(uri) {
        var id;
        var path;
        var isPlaylist = uri.find("playlist:");
        if (isPlaylist != null) {
            id = uri.substring(isPlaylist+9, uri.length());
            path = "playlists/" + id;
        }
        var txn = new SpotifyTransaction(
            path,
            {
                "market" => "US",
                "fields" => "name"
            },
            "GET",
            method(:onReceiveRequest),
            method(:onReceiveContextResponse)
        );
        txn.go(null);
    }

    function onReceiveContextResponse(responseCode, data) {
        _view.onReceiveResponseCode(responseCode.toString());
        if (data != null && data.hasKey("name")) {
            _view.onReceiveContext(data["name"]);
        }
    }

    function onPlayButton() {
        // System.println("onPlay");
        _view.onReceiveCurrentlyPlaying(null, null, true);
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
        _view.onReceiveCurrentlyPlaying(null, null, false);
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

    function onAddButton() {
        if (_currentTrack != null) {
            var txn = new SpotifyTransaction(
                "me/tracks",
                {
                    "ids" => [_currentTrack["id"]],
                },
                "PUT",
                method(:onReceiveRequest),
                method(:onReceiveRefreshNeededResponse)
            );
            txn.go(null);
        }
        return false;
    }

    function onPreviousButton() {
        // System.println("onPrevious");
        var txn = new SpotifyTransaction(
            "me/player/previous",
            null,
            "POST",
            method(:onReceiveRequest),
            method(:onReceiveRefreshNeededResponse)
        );
        txn.go(null);
        return false;
    }

    function onNextButton() {
        // System.println("onNext");
        // Ui.showToast("Next song!", null);
        var txn = new SpotifyTransaction(
            "me/player/next",
            null,
            "POST",
            method(:onReceiveRequest),
            method(:onReceiveRefreshNeededResponse)
        );
        txn.go(null);
        return false;
    }

    function onReceiveRefreshNeededResponse(responseCode, data) {
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
