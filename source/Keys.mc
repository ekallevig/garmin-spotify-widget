//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

// Spotify oauth app client_id value generated here: https://developer.spotify.com/dashboard
var ClientId = "<spotify client_id here>";

// Authorization: Basic <base 64 hash> (header described here: https://developer.spotify.com/documentation/web-api/tutorials/code-flow)
var TokenAuthHash = "<spotify authorization header hash here>";

// Needed to run in simulator because oauth browser window used doesn't support javascript (which spotify's authorize page needs)
var RefreshToken = "<refresh token generated manually for local development>";
