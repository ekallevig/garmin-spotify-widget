// Spotify oauth app client_id value generated here: https://developer.spotify.com/dashboard
var localClientId = Properties.getValue("client_id");
var ClientId = localClientId == null ? "c20d7db6520e45f18ffd44294b7b1090" : localClientId;

// Needed to run in simulator because oauth browser window used doesn't support javascript (which spotify's authorize page needs)
// var RefreshToken = "<insert_refresh_token>";

var NO_PLAYER_LABEL = "No Active Player";
var NO_PLAYER_SUB_LABEL = "Start Song in Spotify App";
var DEFAULT_CONTEXT_LABEL = "Spotify";
var LOADING_LABEL = "Loading player...";