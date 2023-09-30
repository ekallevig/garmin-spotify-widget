//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

// Spotify oauth app client_id value generated here: https://developer.spotify.com/dashboard
var ClientId = "c20d7db6520e45f18ffd44294b7b1090";

// Authorization: Basic <base 64 hash> (header described here: https://developer.spotify.com/documentation/web-api/tutorials/code-flow)
var TokenAuthHash = "YzIwZDdkYjY1MjBlNDVmMThmZmQ0NDI5NGI3YjEwOTA6ZmIyNzgzMzE2OTNmNDQ2MjkwNzI5MDI5MThmNmNkNDQ=";

// Needed to run in simulator because oauth browser window used doesn't support javascript (which spotify's authorize page needs)
var RefreshToken = "AQDHqc0Qt7XMHzebShVTlMiqiJEOaXqIAVji4StQEftAWEcqQa3vUHTKb2bF-1T2oj0VxeF8aBPRf9THAKwPwbMcl6EQnxpzM8awWNtBwj1AShGsG4bWkK769r6lq8yHFWg";

var NO_PLAYER_LABEL = "No Active Player";
var NO_PLAYER_SUB_LABEL = "Start Song in Spotify App";
var DEFAULT_CONTEXT_LABEL = "Spotify";
var LOADING_LABEL = "Loading player...";