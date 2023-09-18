//!
//! Copyright 2016 by Garmin Ltd. or its subsidiaries.
//! Subject to Garmin SDK License Agreement and Wearables
//! Application Developer Agreement.
//!
using Toybox.WatchUi;
using Toybox.Attention;

class SpotifyButtonDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelectable(event) {
        // System.println("onSelectable");

        // Needed when developing in sim because sim has bug preventing
        // buttons from resetting to default state on touch screens.
        // event.getInstance().setState(:stateDefault);
    }

    function onRefresh() {
        // System.println("onRefresh");
        currentView._transaction.go();
        return false;
    }

    function onPlay() {
        // System.println("onPlay");
        currentView._playTransaction.go();
        return false;
    }

    function onPause() {
        // System.println("onPause");
        currentView._pauseTransaction.go();
        return false;
    }

    function onPrevious() {
        // System.println("onPrevious");
        currentView._previousTransaction.go();
        return false;
    }

    function onNext() {
        // System.println("onNext");
        currentView._nextTransaction.go();
        return false;
    }
}