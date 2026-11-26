# Practice 11 — A Real Server

## Level 1: Postman / curl

`GET https://jsonplaceholder.typicode.com/users` → 200, Content-Type: application/json, a list of 10 users.
(<- CHECK in Postman and put the real status and headers here)

### User

| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| id | number | int | no |
| name | string | String | no |
| username | string | String | no |
| email | string | String | no |
| phone | string | String | no |
| website | string | String? | treated as optional |
| address | object | Address | no |
| company | object | Company (record) | no |

### Address

| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| street | string | String | no |
| suite | string | String | no |
| city | string | String | no |
| zipcode | string | String | no |
| geo | object | Geo | no |

### Geo (nested twice: address.geo)

| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| lat | string ("-37.3159") | double (double.parse) | no |
| lng | string | double (double.parse) | no |

### Company

| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| name | string | String | no |
| catchPhrase | string | String | no |
| bs | string | not used | — |

## Statuses

- `GET /users/999` → status: <- FILL IN (Postman), body: <- FILL IN
- `POST /users` with JSON → status: <- FILL IN, the server adds: <- FILL IN (id)
- `GET /users?id=3` → a list of one item, not an object.

## Level 5: two kinds of "no network"

- Airplane mode: the Offline view appeared after <- FILL IN seconds.
- Wi-Fi without internet: the Offline view appeared after <- FILL IN seconds (about 10, the timeout).


---

# Practice 12 — Survive a Restart

## Level 1: package verdicts (checked on pub.dev)

1. **shared_preferences** — verified publisher flutter.dev, 2.5.6 released October 2026, all six platforms, 160/160 pub points, BSD-3, depends only on its own per-platform packages; the right place for settings, not secrets.
2. **flutter_secure_storage** — verified publisher steenbakker.dev (community, not Google), 11.2.0 released September 2026, all six platforms, 160/160 points, BSD-3, depends on its own per-platform packages and `meta`; the only one of the six that talks to Keychain / Keystore.
3. **path_provider** — verified publisher flutter.dev, 2.1.6 released June 2026, Android/iOS/Windows/Linux/macOS (no web), 160/160 points, BSD-3, depends on its platform packages only; it gives me the Documents folder that survives and the Temporary one that does not.
4. **image_picker** — verified publisher flutter.dev, 1.2.4 released October 2026, all six platforms, 160/160 points, BSD-3, depends on its platform packages only; returns `null` on Cancel.
5. **permission_handler** — verified publisher baseflow.com, 13.0.2 released September 2026, Android/iOS/Windows/web (no desktop Linux/macOS), 160/160 points, MIT, depends on `meta` and its platform packages; needs manifest / Info.plist declarations to work.
6. **url_launcher** — verified publisher flutter.dev, 6.3.3 released October 2026, all six platforms, 160/160 points, BSD-3, depends on its platform packages only; `launchUrl` returns `false` when no app can open the link.

### The caret and pubspec.lock

- `flutter pub add shared_preferences flutter_secure_storage path_provider image_picker permission_handler url_launcher` wrote `^2.5.6`, `^11.2.0`, `^2.1.6`, `^1.2.4`, `^13.0.2`, `^6.3.3`.
- `pubspec.lock` resolved `http` to exactly **1.6.0** (pubspec says `^1.6.0`).
- `^1.2.0` means `>=1.2.0 <2.0.0`: it accepts 1.2.0, 1.2.5, 1.6.0, 1.99.0; it refuses 1.1.9 (too old) and 2.0.0 (a major version may break the API, semver).
- `pubspec.lock` is committed for an app so every machine and CI builds with the exact same versions I tested; for a library it is not committed because the consumers resolve their own versions.
- Experiment: `http: 1.2.0` (no caret) pins it exactly, `pub get` then resolves 1.2.0 and `pub outdated` shows everything newer as not upgradable. Caret put back.

### flutter pub outdated

`cupertino_icons` is 1.0.9 and 2.0.0 exists. It was not upgraded because it is a new major version: `^1.0.8` refuses 2.0.0 by design, and an upgrade should be a conscious step with a changelog read, not a side effect. Transitive ones (e.g. `shared_preferences_foundation` 2.5.7 → 2.6.2) are not mine to bump; `shared_preferences` decides.

## Level 2: why the read is in main()

`getBool` in main() before `runApp` means the very first frame already has the saved theme. When I moved the read into the model constructor (default `false`, read later) the app showed one light frame and then switched to dark. `setDark` calls `notifyListeners()` before `await _prefs.setBool(...)` so the screen never waits for the disk.

## Level 3: where a token must NOT go

- `prefs.setString('token', …)` would put the token in a plain file: an XML file in `shared_prefs/` on Android, a plist in `Library/Preferences` on iOS, inside the app folder.
- Who can read it: anyone with a backup of the device, a rooted/jailbroken phone, or someone with a cable and a debug build (`adb run-as`, an iTunes backup). The token lets that person *be* the user.
- `flutter_secure_storage` writes to iOS Keychain / Android Keystore-encrypted storage, so the file on disk is encrypted with a key the OS guards.
- Platform surprises: **iOS** — Keychain items can survive an uninstall, so after a reinstall the app may still find an old token (clear it on first launch if that matters). **Android** — if the user removes the lock screen, the Keystore keys that are tied to it can be wiped, and the token becomes unreadable: `readToken()` can fail or return null, so treat that as "signed out".
- The token is never printed. The debug-only "Copy token to clipboard" button (`kDebugMode`) is how I prove the header exists; DevTools → Network shows `Authorization: Bearer tok_…`.

## Level 4: the offline list

`UsersCache` writes `users.json` into `getApplicationDocumentsDirectory()`. `getAll()` saves after every successful fetch, returns the saved list on `NoConnectionException` (with `fromCache: true`, so the screen shows "Saved data · no connection · Retry"), and rethrows when there is no file (a fresh install offline shows the honest Offline screen, not an empty list). On break-it: with the file in `getTemporaryDirectory()`, "Clear cache" in Android settings deleted it and the offline list vanished — the OS kept the promise of the directory's name.

## Level 5: permissions

- Android (emulator): No → No → third tap: `request()` returns `permanentlyDenied` immediately, no system dialog, my dialog appears; "Open settings" opens the app's permission page. After 2 No's the status is `permanentlyDenied`.
- iOS: the system asks **once**. One "Don't Allow" and the status is already `permanentlyDenied` (afterwards only Settings can change it). The fourth Photos state, besides granted / denied / restricted, is **limited** (the user shared only selected photos).
- `launchUrl(Uri.parse('kbtu.edu.kz'))` without a scheme returns `false` and nothing opens; with `https://` the browser opens. The detail screen checks the returned bool and shows "No app can open this".
