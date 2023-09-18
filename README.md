# Spotify Widget

A widget that queries and controls your Spotify player using the Connect IQ OAUTH system.

Supports Garmin Edge 1030+

<a href="https://www.flaticon.com/free-icons/end" title="end icons">End icons created by Those Icons - Flaticon</a>

## Dev Notes

  * Populate `Keys.mc` with values from your own Spotify api app created here: https://developer.spotify.com/dashboard

  * In `SpotifyButtonDelegate.mc`, you need to uncomment the `event.getInstance().setState(:stateDefault);` call due to a bug in the simulator that fails to reset buttons to their default state after selecting on touch screens. If you don't do this, the button will only be able to be selected once.

  * The simulator's oauth browser implementation doesn't seem to support javascript, which Spotify's oauth authorize page needs to function. As a workaround, you can: 
    * Separately generate a refresh token:
        * Load <a href="https://accounts.spotify.com/authorize?client_id=<your-spotify-client-id>&response_type=code&redirect_uri=http://localhost&scope=user-modify-playback-state,user-read-playback-state">this link</a> in a browser
        * Sign into spotify and approve access request
        * You will be redirected to http://localhost/?code=your-access-code (copy the code from url)
        * Use code and your <a href="https://developer.spotify.com/documentation/web-api/tutorials/code-flow">client-id:client-secret hash</a> to request refresh token: 
        ```curl --location 'https://accounts.spotify.com/api/token' \
--header 'Authorization: Basic <spotify-client-id-client-secret-hash>' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'code=<code-copied-from-previous-step>' \
--data-urlencode 'redirect_uri=http://localhost' \
--data-urlencode 'grant_type=authorization_code'```
    * Set refresh token as `RefreshToken` variable in `Keys.mc`
    * Uncomment `setProperty("refresh_token", $.RefreshToken);` in `App.mc`