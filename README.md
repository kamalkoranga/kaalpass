# KaalPass Demo Branch

This branch is a used for demonstration purpose of **KaalPass**.

## What changed in this branch

- Password rotation is now every 30 seconds.
- Added Progress countdown (30s timer + auto refresh).
- Updated script logic to match 30-second password windows.
- Simplified flow for demo and testing.

## Updated Script
```bash
wget -O kaalpass.sh https://github.com/kamalkoranga/kaalpass/releases/download/demo-v1/kaalpass.sh
```

## Run Flutter Web locally

1. Install Flutter and verify setup.
2. From project root, run:

```bash
flutter clean
flutter pub get
flutter run -d web-server
```

## Build web for deployment

```bash
flutter build web --release
```

Build output is generated in build/web.

## Web link

- https://marvelous-rabanadas-3dea3c.netlify.app

---

> **Note: Keep the same secret value across app and script to generate matching passwords.**

## License

MIT. See [LICENSE](LICENSE).
