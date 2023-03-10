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

- `user_name: String` (optional) -> Fetch user information by user name.
- `user_ids: Array[String|int]` (optional) -> Fetch information from a list of users by IDs.

**Note:** The parameters `user_name` and `user_ids` are mutually exclusive, you should use only one of them, or none.
If none were provided, will fetch from the current user name set in `GameJolt` singleton.

#### users_auth() -> self:
Authenticates the user's information. The user name and token must be set on `GameJolt` singleton for it to succeed.

### Sessions
#### sessions_open() -> self:
Opens a game session for a particular user and allows you to tell Game Jolt that a user is playing your game.

**Note:** Requires user name and token to be set on `GameJolt` singleton.

#### sessions_ping(status := ""):
Opens a game session for a particular user and allows you to tell Game Jolt that a user is playing your game.

- `status: String` (optional) -> Sets the status of the session to either `"active"` or `"idle"`.

**Note:** Requires user name and token to be set on `GameJolt` singleton.

#### sessions_check() -> self:
Checks to see if there is an open session for the user.

**Note:** Requires user name and token to be set on `GameJolt` singleton.

#### sessions_close() -> self:
Closes the active session.

**Note:** Requires user name and token to be set on `GameJolt` singleton.

### Scores
#### scores_fetch(limit = null, table_id = null, guest := "", better_than = null, worse_than = null, this_user := false) -> self:
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

