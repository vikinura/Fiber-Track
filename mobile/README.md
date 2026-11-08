# Fiber Track Mobile

Aplikasi mobile untuk pelaporan dan pemantauan gangguan jaringan fiber optic multi-tenant dan multi-vendor.

## Struktur Folder

```
lib/
  main.dart
  app.dart
  core/
    config/
    constants/
    di/
    error/
    network/
    router/
    theme/
    utils/
    widgets/
  features/
    auth/
    ticket/
    master/
    dashboard/
    notification/
    settings/
```

## Menjalankan Aplikasi

Jalankan dengan perintah:
```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```
