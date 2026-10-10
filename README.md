# Portfolio Marketplace Web (Flutter)

Responsive Flutter Web client for the Portfolio Marketplace. It connects to the Go REST API in `../portfolio-BE`.

## Requirements

- Flutter stable / Dart 3.5+
- Google Chrome (for local browser testing)
- Go backend running at a reachable address

## Generate web platform files if needed

If the `web/` platform directory is not present, run:

```bash
make create-platform
```

Inspect any overwrite prompts carefully if you have already customized platform files.

## Install and run

```bash
make get
make run
```

Open `http://localhost:5000`. By default the web client calls `http://localhost:8080` for its API.

## Build for deployment

```bash
make build API_BASE_URL=https://YOUR_API_HOST
```

The release files are created in `build/web`. Configure your hosting provider to serve `index.html` for application routes if using client-side routing. Use HTTPS and configure backend CORS for your real web domain.

## Useful commands

```bash
make help
make get
make analyze
make test
make run
make build
make clean
```

This is an MVP starter. Finish and test the portfolio editor, image uploads, accessibility, SEO, and production authentication flows before launch.
# -portfolio-web
