//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Lang as Lang;

// Store global reference to View
var currentView = null;

// Main view for the application
class SpotifyView extends Ui.View {
    var _transaction;
    var _playTransaction;
    var _pauseTransaction;
    var _nextTransaction;
    var _previousTransaction;
    var _divisors;
    var _labels;

    // Constructor
    function initialize() {
        View.initialize();
        // Initialize global reference
        currentView = self;
    }

    // Function called when the information is returned by the transaction
    function updateModel(model) {
        var view = View.findDrawableById("track");
        view.setText( model[:track] );
        view = View.findDrawableById("artist");
        view.setText( model[:artist] );
        Ui.requestUpdate();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.Summary(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        if (_transaction == null) {
            _transaction = new SpotifyCurrentlyPlayingTransaction( new SpotifyCurrentlyPlayingDelegate(self) );
            _transaction.go();
            _playTransaction = new SpotifyPlayTransaction( new TransactionDelegate(self) );
            _pauseTransaction = new SpotifyPauseTransaction( new TransactionDelegate(self) );
            _previousTransaction = new SpotifyPreviousTransaction( new TransactionDelegate(self) );
            _nextTransaction = new SpotifyNextTransaction( new TransactionDelegate(self) );
        }
    }

    // Update the view
    function onUpdate(dc) {
        // Get and show the current time

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }


}
