# flutter_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Bond API run mode

`Market Information > Market Management > Bond` uses a runtime mode to decide
whether New/Edit/Delete (and list/read) call mock storage or real HTTP API.

- Default: `mock`
- API mode: `api` (or `remote`)

### 1) Mock mode (default)

```bash
flutter run
```

Or explicitly:

```bash
flutter run --dart-define=BOND_API_MODE=mock
```

### 2) Real API mode

```bash
flutter run --dart-define=BOND_API_MODE=api --dart-define=BOND_API_BASE_URL=http://localhost:8080
```

If `BOND_API_MODE=api` and `BOND_API_BASE_URL` is missing, app startup throws
an error.
