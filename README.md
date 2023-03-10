<h1 align="center">Game Jolt API for Godot</h1>
<p align="center">
  <img width="75%" alt="Game Jolt API for Godot" src="addons/gamejolt/example/screenshot.jpg">
</p>

Wrapper for the Game Jolt API running through HTTP requests. It contains all Game Jolt API endpoints and aims to simplify its use where it's possible. Compatible with **Godot 3.5.x**.

It implements the following endpoints:

- Users
- Sessions
- Scores
- Trophies
- Data Storage
- Friends
- Time
- Batch Calls

## API Reference
You can use the methods below on the singleton `GameJolt` when the plugin is enabled.

### General
General methods to configure `GameJolt` singleton locally.

#### set_user_name(value: String) -> void
Set the user name for auth and other user scope tasks.

#### get_user_name() -> String
Get current user name.

#### set_user_token(value: String) -> void
Set the user token for auth and other user scope tasks.

#### get_user_token() -> String
Get current user game token.

### Users
#### users_fetch(user_name := "", user_ids := []) -> self
Returns a user's data.

- `user_name: String` (optional) -> The username of the user whose data you'd like to fetch.
- `user_ids: Array[String|int]` (optional) -> The IDs of the users whose data you'd like to fetch.

**Note:** The parameters `user_name` and `user_ids` are mutually exclusive, you should use only one of them, or none.
If none were provided, will fetch from the current user name set in `GameJolt` singleton.

#### users_auth() -> self
Authenticates the user's information.
This should be done before you make any calls for the user, to make sure the user's credentials (username and token) are valid.
The user name and token must be set on `GameJolt` singleton for it to succeed.

### Sessions
#### sessions_open() -> self
Opens a game session for a particular user and allows you to tell Game Jolt that a user is playing your game.
You must ping the session to keep it active and you must close it when you're done with it.

**Notes:**
- You can only have one open session for a user at a time. If you try to open a new session while one is running, the system will close out the current one before opening the new one.
- Requires user name and token to be set on `GameJolt` singleton.

#### sessions_ping(status := "") -> self
Pings an open session to tell the system that it's still active.
If the session hasn't been pinged within 120 seconds, the system will close the session and you will have to open another one.
It's recommended that you ping about every 30 seconds or so to keep the system from clearing out your session.
You can also let the system know whether the player is in an `"active"` or `"idle"` state within your game.

- `status: String` (optional) -> Sets the status of the session to either `"active"` or `"idle"`.

**Note:** Requires user name and token to be set on `GameJolt` singleton.

#### sessions_check() -> self
Checks to see if there is an open session for the user.
Can be used to see if a particular user account is active in the game.

**Notes:**
- This endpoint returns `false` for the `"success"`` field when no open session exists. That behaviour is different from other endpoints which use this field to indicate an error state.
- Requires user name and token to be set on `GameJolt` singleton.

#### sessions_close() -> self
Closes the active session.

**Note:** Requires user name and token to be set on `GameJolt` singleton.

### Scores
#### scores_fetch(limit = null, table_id = null, guest := "", better_than = null, worse_than = null, this_user := false) -> self
Returns a list of scores either for a user or globally for a game.

- `limit: String|int` (optional) -> The number of scores you'd like to return.
- `table_id: String|int` (optional) -> The ID of the score table.
- `guest: String` (optional) -> A guest's name.
- `better_than: String|int` (optional) -> Fetch only scores better than this score sort value.
- `worse_than: String|int` (optional) -> Fetch only scores worse than this score sort value.
- `this_user: bool` (optional) -> If `true`, fetch only scores of current user. Else, fetch scores of all users.

**Notes:**
- Requires user name and token to be set on `GameJolt` singleton if `this_user` is `true`.
- The default value for `limit` is `10` scores. The maximum amount of scores you can retrieve is `100`.
- If ``table_id`` is left blank, the scores from the primary score table will be returned.
- Only pass in `this_user` as `true` if you would like to retrieve scores for just the user set in the class constructor. Leave `this_user` as `true` and `guest` as `""` to retrieve all scores.
- `guest` allows you to fetch scores by a specific guest name. Only pass either the `this_user` as `true` or the `guest` (or none), never both.
- Scores are returned in the order of the score table's sorting direction. e.g. for descending tables the bigger scores are returned first.

#### scores_tables() -> self
Returns a list of high score tables for a game.

#### scores_add(score: String, sort, table_id = null, guest := "", extra_data = null) -> self
Adds a score for a user or guest.

- `score: String` -> This is a string value associated with the score. Example: `"500 Points"`.
- `sort: String|int` -> This is a numerical sorting value associated with the score. All sorting will be based on this number. Example: `500`.
- `table_id: String|int` (optional) -> The ID of the score table to submit to.
- `guest: String` (optional) -> The guest's name. Overrides the `GameJolt` singleton's user name.
- `extra_data: String|int|Dictionary|Array` (optional) -> If there's any extra data you would like to store as a string, you can use this variable.

**Notes:**
- You can either store a score for a user or a guest. If you're storing for a user, you must set user name and toke on `GameJolt` singleton and leave `guest` as empty. If you're storing for a guest, you must pass in the `guest` parameter.
- The `extra_data` value is only retrievable through the API and your game's dashboard. It's never displayed publicly to users on the site. If there is other data associated with the score such as time played, coins collected, etc., you should definitely include it. It will be helpful in cases where you believe a gamer has illegitimately achieved a high score.
- If `table_id` is left blank, the score will be submitted to the primary high score table.

#### scores_get_rank(sort, table_id := "") -> self
Returns the rank of a particular score on a score table.

- `sort: String|int` -> This is a numerical sorting value that is represented by a rank on the score table.
- `table_id: String|int` (optional) -> The ID of the score table from which you want to get the rank.

**Notes:**
- If `table_id` is left blank, the ranks from the primary high score table will be returned.
- If the score is not represented by any rank on the score table, the request will return the rank that is closest to the requested score.
