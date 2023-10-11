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
    hidden var _contextCache;
    hidden var _busy;
    // hidden var _saveTransaction; // TODO: add save button
    // hidden var _shuffleTransaction; // TODO: add shuffle button
    // hidden var _radioTransaction; // TODO: add radio button

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
        var _initialContextCache = Storage.getValue("context_cache");
        if (_initialContextCache == null) {
            _contextCache = {};
        } else {
            _contextCache = _initialContextCache;
        }
        _currentlyPlayingTransaction = new SpotifyTransaction(
            "me/player",
            {
                "market" => "US",
                "additional_types" => "track,episode"
            },
            "GET",
            method(:onReceiveRequest),
            method(:onReceiveCurrentlyPlayingResponse)
        );
        _currentlyPlayingTransaction.go(null);
        _busy = true;
    }

    function onReceiveRequest(path) {
        _view.onReceiveStatus(path);
    }

    function onReceiveResponse(responseCode, data) {
        _view.onReceiveResponseCode(responseCode.toString());
    }

    // function onSelectable(event) {

    //     // Needed when developing in sim because sim has bug preventing
    //     // buttons from resetting to default state on touch screens.
    //     event.getInstance().setState(:stateHighlighted);
    // }

    function onMenu() {
        if (_busy) {
            return;
        }
        var storedPlaylists = Storage.getValue("playlists");
        if (storedPlaylists == null) {
            System.println("onmenu, storedPlaylists == null");
            _view.onReceiveProgress("Downloading playlists...");
            getPlaylists(null, null);
        } else {
            System.println("onmenu, storedPlaylists has contnet");
            _menuView = new SpotifyPlaylistsMenu(storedPlaylists);
            WatchUi.pushView(_menuView, new SpotifyPlaylistsMenuDelegate(method(:onMenuItem)), WatchUi.SLIDE_IMMEDIATE);
        }
        return true;
    }

    function onMenuItem(item) {
        var id = item.getId();
        if (id.equals("clear_cache")) {
            System.println("clear cache");
            Storage.setValue("context_cache", {});
            _contextCache = {};
            Storage.deleteValue("playlists");
            Storage.deleteValue("access_token");
            Storage.deleteValue("refresh_token");
            _playlistsBatch = new [0];
        } else {
            var txn = new SpotifyTransaction(
                "me/player/play",
                {
                    "context_uri" => "spotify:playlist:" + id
                },
                "PUT",
                method(:onReceiveRequest),
                method(:onReceiveRefreshNeededResponse)
            );
            txn.go(null);
        }
    }

    function getPlaylists(limit, offset) {
        System.println("limit offset " + limit + " " + offset);
        _busy = true;
        // limit = limit == null ? 5 : limit;
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
            var maxPlaylists = data["total"] < 50 ? data["total"] : 50;
            _view.onReceiveProgress("Downloading playlists: " + (data["items"].size()+data["offset"]) + "/" + maxPlaylists);
            var items = data["items"];
            for( var i = 0; i < items.size(); i++ ) {
                var uriParts = parseUri(items[i]["uri"]);
                _playlistsBatch.add({
                    "n" => items[i]["name"],
                    "u" => uriParts["id"]
                });
            }
            if (_playlistsBatch.size() >= maxPlaylists) {
                System.println("onReceivePlaylistsResponse _playlistsBatch > 50, set storage, onmenu");
                Storage.setValue("playlists", _playlistsBatch);
                _view.onReceiveProgress(null);
                _busy = false;
                onMenu();
            } else {
                System.println("onReceivePlaylistsResponse _playlistsBatch < 50, get more");
                getPlaylists(data["limit"], data["offset"] + data["limit"]);
            }
        } else {
            System.println("onReceivePlaylistsResponse data != null but no data[items], set storage, onmenu");
            Storage.setValue("playlists", _playlistsBatch);
            _view.onReceiveProgress(null);
            _busy = false;
            onMenu();
        }
    }

    function onRefreshButton() {
        // System.println("onRefreshButton");
        if (_busy) {
            return;
        }
        _currentlyPlayingTransaction.go(null);
        return false;
    }

    function startRefreshTimer(interval) {
        System.println("startRefreshTimer " + interval + "ms interval");
        _currentRefreshTimer.stop();
        _currentRefreshTimer.start(method(:refreshCurrentlyPlaying), interval, true);
    }

    function stopRefreshTimer() {
        System.println("stopRefreshTimer");
        _currentRefreshTimer.stop();
    }

    function onReceiveCurrentlyPlayingResponse(responseCode, data) {
        _busy = false;
        _view.onReceiveResponseCode(responseCode.toString());
        if (data != null && data.hasKey("item") && data["item"] != null) {

            // Refresh timer
            _isPlaying = data["is_playing"];
            if (_isPlaying) {
                startRefreshTimer(10000);
            } else {
                startRefreshTimer(20000);
            }

            // If track hasn't changed since last check, return
            if (_currentTrack != null) {
                if (_currentTrack["id"].equals(data["item"]["id"])) {
                    return;
                }
            }
            _currentTrack = data["item"];

            var isTrack = data["currently_playing_type"].equals("track");
            var context = !isTrack ? data["item"]["show"]["name"] : data["item"]["album"]["name"];
            
            // Track & artist data
            var track = data["item"]["name"];
            var artist = isTrack ? data["item"]["artists"][0]["name"] : data["item"]["show"]["publisher"];
            System.println("- song: " + track);
            System.println("- artist: " + artist);

            // Truncate song/artist/context if too long
            track = truncate(track, 25);
            artist = truncate(artist, 25);
            context = truncate(context, 25);
            _view.onReceiveCurrentlyPlaying(track, artist, data["is_playing"]);

            // Get context info
            if (isTrack && data["context"] != null) {
                var uri = data["context"]["uri"];
                var uriParts = parseUri(uri);
                if (_contextCache.hasKey(uriParts["id"])) {

                    // Get from cache
                    _view.onReceiveContext(truncate(_contextCache[uriParts["id"]], 25));
                } else {

                    // Fetch from API
                    _view.onReceiveContext("...");
                    getContextInfo(uri);
                }
            } else {
                _view.onReceiveContext(context);
            }
        } else {
            _currentTrack = null;
            _isPlaying = false;
            startRefreshTimer(20000);
            _view.onReceiveCurrentlyPlaying($.NO_PLAYER_LABEL, $.NO_PLAYER_SUB_LABEL, false);
            _view.onReceiveContext($.DEFAULT_CONTEXT_LABEL);
        }

    }

    function truncate(val, length) {
        if (val.length() > length) {
            val = val.substring(0, length) + "...";
        }
        return val;
    }

    function parseUri(uri) {
        if (uri.find("playlist:") != null) { // e.g. "spotify:playlist:23we0fs0df9as0df"
            return {"type"=>"playlist", "id"=>uri.substring(8+9, uri.length())};
        } else if (uri.find("artist:") != null) { // e.g. "spotify:artist:23we0fs0df9as0df"
            return {"type"=>"artist", "id"=>uri.substring(8+7, uri.length())};
        } else if (uri.find("album:") != null) { // e.g. "spotify:album:23we0fs0df9as0df"
            return {"type"=>"album", "id"=>uri.substring(8+6, uri.length())};
        } else if (uri.find("show:") != null) { // e.g. "spotify:show:23we0fs0df9as0df"
            return {"type"=>"show", "id"=>uri.substring(8+5, uri.length())};
        } else if (uri.find("spotify:user:") != null) { // e.g. "spotify:user:erik.kallevig:collection" (for liked songs)
            return {"type"=>"user", "id"=>uri.substring(8+5, uri.length()-11)};
        }
        return null;
    }

    function getContextInfo(uri) {
        var uriParts = parseUri(uri);
        if (uriParts != null && !uriParts["type"].equals("user")) {
            var txn = new SpotifyTransaction(
                uriParts["type"] + "s/" + uriParts["id"],
                {
                    "market" => "US",
                    "fields" => "name,id"
                },
                "GET",
                method(:onReceiveRequest),
                method(:onReceiveContextResponse)
            );
            txn.go(null);
        } else if (uriParts["type"].equals("user")) {

            // Pretty sure this context type (user "collection") is only 
            // available for current user's special "Liked Songs" faux-playlist
            onReceiveContextResponse("200", {"name"=>"Liked Songs", "id"=>uriParts["id"]});
        } else {
            onReceiveContextResponse("200", null);
        }
    }

    function onReceiveContextResponse(responseCode, data) {
        _view.onReceiveResponseCode(responseCode.toString());
        if (data != null && data.hasKey("name")) {
            if (!_contextCache.hasKey(data["id"])) {
                _contextCache[data["id"]] = data["name"];
                Storage.setValue("context_cache", _contextCache);
            }
            _view.onReceiveContext(truncate(data["name"], 25));
        } else {
            _view.onReceiveContext($.DEFAULT_CONTEXT_LABEL);
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
        return true;
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
        return true;
    }

    function onReceiveRefreshNeededResponse(responseCode, data) {
        onReceiveResponse(responseCode, data);
        delayedRefreshCurrentlyPlaying();
    }

    function refreshCurrentlyPlaying() {
        if (_busy) {
            return;
        }
        _currentlyPlayingTransaction.go(null);
    }

    function delayedRefreshCurrentlyPlaying() {

        // Delay call to currently-playing b/c sometimes it doesn't
        // update fast enough after the previous api call.
        var myTimer = new Timer.Timer();
        myTimer.start(method(:refreshCurrentlyPlaying), 500, false);
    }

}
