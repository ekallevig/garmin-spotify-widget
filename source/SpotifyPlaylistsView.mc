using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Lang as Lang;


class SpotifyPlaylistsMenu extends Ui.Menu2 {

    // hidden var _playlists;

    public function initialize(playlists) {
        Menu2.initialize({:title=>"Playlists"});
        self.addItem(
            new MenuItem(
                "Clear Cache",
                null,
                "clear_cache",
                {}
            )
        );
        for( var i = 0; i < playlists.size(); i++ ) {
            // Sys.println("adding menu item: " + items[i]["name"]);
            self.addItem(
                new Ui.MenuItem(
                    playlists[i]["n"],
                    null,
                    playlists[i]["u"],
                    {}
                )
            );
        }
    }

    function onReceivePlaylists(items) {
        Sys.println("menu onReceivePlaylists, got " + items.size());
        for( var i = 0; i < items.size(); i++ ) {
            Sys.println("adding menu item: " + items[i]["name"]);
            self.addItem(
                new Ui.MenuItem(
                    items[i]["n"],
                    null,
                    items[i]["u"],
                    {}
                )
            );
        }
    }

    function onUpdate(dc) {
        View.onUpdate(dc);
    }

    function onLayout(dc) {
        Sys.println("menu onlayout");
    }

}


class SpotifyPlaylistsMenuDelegate extends Ui.Menu2InputDelegate {

    hidden var _callback;

    function initialize(callback) {
        Menu2InputDelegate.initialize();
        _callback = callback;
    }

    function onSelect(item) {
        System.println("menu item selected: " + item.getLabel());
        _callback.invoke(item);
        Ui.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    function onBack() {
        System.println("onBack");
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function onPreviousPage() {
        System.println("onPreviousPage");
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function onPreviousMode() {
        System.println("onPreviousMode");
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

}
