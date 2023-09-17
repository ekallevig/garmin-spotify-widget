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

    function onRefresh() {
        System.println("onRefresh");
        currentView._transaction.go();
        return true;
    }

    function onPlay() {
        System.println("onPlay");
        // currentView.findDrawableById("artist").setText("hi");
        WatchUi.requestUpdate();
        currentView._playTransaction.go();
        return false;
    }

    function onPause() {
        System.println("onPause");
        currentView._pauseTransaction.go();
        return true;
    }

    function onPrevious() {
        System.println("onPrevious");
        currentView._previousTransaction.go();
        return true;
    }

    function onNext() {
        System.println("onNext");
        currentView._nextTransaction.go();
        return true;
    }
}