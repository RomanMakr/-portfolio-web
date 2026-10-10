# Portfolia Web

Portfolia Web is a Flutter web client for portfolio creation. The current app opens on an authentication screen with Sign in and Sign up forms.

## Current scope

- Sign in with an email and password.
- Create an account with a name, email, and password.
- Show API success and error messages.
- Save the authentication token returned by the API in browser-backed shared preferences.

The portfolio dashboard and portfolio browsing screens are not currently part of the app flow. “Forgot password?” is display text only; password recovery is not implemented.

## Requirements

- Flutter SDK with Dart 3.5 or later.
- Google Chrome for local web development.
- A reachable backend that implements the authentication endpoints below.

## Run locally

From the project directory:

```bash
flutter pub get
flutter run -d chrome --web-port=5000 --dart-define=API_BASE_URL=http://localhost:8080
```

Open `http://localhost:5000`. The API URL defaults to `http://localhost:8080`; change `API_BASE_URL` if your backend runs elsewhere. If port 5000 is already in use, choose another port with `--web-port`, for example `--web-port=5001`.

The Makefile provides equivalent shortcuts:

```bash
make get
make run API_BASE_URL=http://localhost:8080
```

If the Flutter project has no `web/` platform directory, generate it with:

```bash
flutter create --platforms=web .
```

Review any overwrite prompts before accepting them if you have customized platform files.

## Backend API

The client sends requests to:

| Action | Method and path | Request fields |
| --- | --- | --- |
| Sign up | `POST /api/v1/auth/register` | `display_name`, `email`, `password` |
| Sign in | `POST /api/v1/auth/login` | `email`, `password` |

Both successful endpoints must return a JSON object containing a string `token` field. The client uses `API_BASE_URL` as the base URL and expects the backend to allow requests from the web app origin through CORS.

## Build for web

```bash
flutter build web --release --dart-define=API_BASE_URL=https://YOUR_API_HOST
```

The deployable files are written to `build/web`. Configure your hosting provider to serve `index.html` for client-side routes, use HTTPS, and allow the deployed web origin in the backend CORS configuration.

## Development commands

```bash
make help
make analyze
make test
make build API_BASE_URL=https://YOUR_API_HOST
make clean
```
