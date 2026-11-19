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
