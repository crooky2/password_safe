# password_safe

A new Flutter project.

## OneDrive Azure App Registration

The Microsoft app registration must include this exact redirect URI under
Authentication > Mobile and desktop applications > Custom redirect URI:

```text
com.christopherbach.passwordsafe://oauth2redirect/microsoft
```

The same URI is used by Android and Windows. If Azure still has an older value
such as `passwordsafe://oauth2redirect`, Microsoft login fails with
`invalid_request` before the app receives the callback.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
