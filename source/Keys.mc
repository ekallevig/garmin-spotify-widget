const DEFAULT_PLACEHOLDER = "<insert_value_here>";
const NO_PLAYER_LABEL = "No Active Player";
const NO_PLAYER_SUB_LABEL = "Start Song in Spotify App";
const DEFAULT_CONTEXT_LABEL = "Spotify";
const LOADING_LABEL = "Loading player...";

// Spotify oauth app client_id value generated here: https://developer.spotify.com/dashboard
var ClientId = DEFAULT_PLACEHOLDER;

// Needed to run in simulator because oauth browser window used doesn't support javascript (which spotify's authorize page needs)
var RefreshToken = DEFAULT_PLACEHOLDER;
